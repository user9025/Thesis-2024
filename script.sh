#!/bin/bash

cd /media/kali/c7632987-030a-4e09-a818-c4e0dd812703/Downloads/RealExperiment

output_file="experiment_results.txt" 
echo "Experiment Results:" > $output_file

for dir in $(find . -mindepth 1 -type d); do 

	total_size=0 
	total_time_aes=0 
	total_time_camellia=0 
	
	extra_bytes_aes=0 
	extra_bytes_camellia=0 
	
	extra_bytes_gzip_aes=0 
	extra_bytes_zip_aes=0 
	extra_bytes_rar_aes=0
	
	extra_bytes_gzip_camellia=0 
	extra_bytes_zip_camellia=0 
	extra_bytes_rar_camellia=0
	
	number_of_files=0
	
	for file in ${dir}/*; do
		
	    number_of_files=$(($number_of_files + 1))
	    
	    original_size=$(du -b "${file}" | cut -f1)
	    total_size=$(($total_size + $original_size))

	    start_time_aes=$(date +%s.%N)
	    openssl enc -aes-128-cbc -e -in "${file}" -out "${file}.aes" -k WZHGVuRf9cCfhYs
	    end_time_aes=$(date +%s.%N)
	    elapsed_time_aes=$(echo "$end_time_aes - $start_time_aes" | bc)
	    total_time_aes=$(echo "$total_time_aes + $elapsed_time_aes" | bc)

	    start_time_camellia=$(date +%s.%N)
	    openssl enc -camellia-128-cbc -e -in "${file}" -out "${file}.camellia" -k WZHGVuRf9cCfhYs
	    end_time_camellia=$(date +%s.%N)
	    elapsed_time_camellia=$(echo "$end_time_camellia - $start_time_camellia" | bc)
	    total_time_camellia=$(echo "$total_time_camellia + $elapsed_time_camellia" | bc)

	    before_compress_aes=$(du -b "${file}.aes" | cut -f1)
	    
	    gzip -k "${file}.aes"
	    after_compress_aes_gzip=$(du -b "${file}.aes.gz" | cut -f1)
	    extra_bytes_gzip_aes=$(($extra_bytes_gzip_aes + $after_compress_aes_gzip - $before_compress_aes ))

	    zip "${file}.aes.zip" "${file}.aes"
	    after_compress_aes_zip=$(du -b "${file}.aes.zip" | cut -f1)
	    extra_bytes_zip_aes=$(($extra_bytes_zip_aes + $after_compress_aes_zip - $before_compress_aes ))

            rar a "${file}.aes.rar" "${file}.aes"
	    after_compress_aes_rar=$(du -b "${file}.aes.rar" | cut -f1)
	    extra_bytes_rar_aes=$(($extra_bytes_rar_aes + $after_compress_aes_rar - $before_compress_aes ))

	    before_compress_camellia=$(du -b "${file}.camellia" | cut -f1)
	    
	    gzip -k "${file}.camellia"
	    after_compress_camellia_gzip=$(du -b "${file}.camellia.gz" | cut -f1)
	    extra_bytes_gzip_camellia=$(($extra_bytes_gzip_camellia + $after_compress_camellia_gzip - $before_compress_camellia))

            zip "${file}.camellia.zip" "${file}.camellia" 
	    after_compress_camellia_zip=$(du -b "${file}.camellia.zip" | cut -f1)
	    extra_bytes_zip_camellia=$(($extra_bytes_zip_camellia + $after_compress_camellia_zip - $before_compress_camellia))

            rar a "${file}.camellia.rar" "${file}.camellia"
	    after_compress_camellia_rar=$(du -b "${file}.camellia.rar" | cut -f1)
	    extra_bytes_rar_camellia=$(($extra_bytes_rar_camellia + $after_compress_camellia_rar - $before_compress_camellia))

	    rm "${file}.aes"  
	    rm "${file}.aes.rar" 
	    rm "${file}.aes.zip" 
	    rm "${file}.aes.gz" 
		    
	    rm "${file}.camellia"  
	    rm "${file}.camellia.rar"  
	    rm "${file}.camellia.zip"  
	    rm "${file}.camellia.gz"  
	done

	average_throughput_aes=$(echo "scale=2; $total_size / $total_time_aes" | bc)
	average_throughput_aes_kb=$(echo "scale=2; $average_throughput_aes / 1000" | bc)
	echo "Average throughput for ${dir} AES: ${average_throughput_aes_kb} KB/sec" >> $output_file
	echo "Average extra bytes after compression for AES (Gzip): $(echo "$extra_bytes_gzip_aes / $number_of_files" | bc) bytes" >> $output_file
	echo "Average extra bytes after compression for AES (Zip): $(echo "$extra_bytes_zip_aes / $number_of_files" | bc) bytes" >> $output_file
	echo "Average extra bytes after compression for AES (RAR): $(echo "$extra_bytes_rar_aes / $number_of_files" | bc) bytes
" >> $output_file
	

	average_throughput_camellia=$(echo "scale=2; $total_size / $total_time_camellia" | bc)
	average_throughput_camellia_kb=$(echo "scale=2; $average_throughput_camellia / 1000" | bc)
	echo "Average throughput for ${dir} Camellia: ${average_throughput_camellia_kb} KB/sec" >> $output_file
	echo "Average extra bytes after compression for Camellia (Gzip): $(echo "$extra_bytes_gzip_camellia / $number_of_files" | bc) bytes" >> $output_file
	echo "Average extra bytes after compression for Camellia (Zip): $(echo "$extra_bytes_zip_camellia / $number_of_files" | bc) bytes" >> $output_file
	echo "Average extra bytes after compression for Camellia (RAR): $(echo "$extra_bytes_rar_camellia / $number_of_files" | bc) bytes
" >> $output_file
	
done
