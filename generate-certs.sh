#!/usr/bin/env bash

SERVER="${SERVER:-localhost}"

CORPORATION=PE
GROUP=My-Corporate-Group
CITY=Nantes
STATE=State
COUNTRY=FR

OUT=certificats

mkdir ${OUT}

rm -f ${OUT}/*

# Generates ca private Key
openssl genrsa -out "${OUT}/ca.key" 2048

# Converts from PKCS#1 to PKCS#8
openssl pkcs8 -topk8 -inform PEM -in "${OUT}/ca.key" -out "${OUT}/ca.PKCS8.key" -nocrypt

# Generates CA cert
openssl req -x509 -new -nodes -key "${OUT}/ca.PKCS8.key" -sha256 -days 1825 -out "${OUT}/ca.pem" -subj "/CN=$SERVER.ca/OU=$GROUP/O=$CORPORATION/L=$CITY/ST=$STATE/C=$COUNTRY"

# Generates mockserver private Key
openssl genrsa -out "${OUT}/mockserver.key" 2048

# Converts from PKCS#1 to PKCS#8
openssl pkcs8 -topk8 -inform PEM -in "${OUT}/mockserver.key" -out "${OUT}/mockserver.PKCS8.key" -nocrypt

# Generates CSR for MockerServer
openssl req -new -key "${OUT}/mockserver.PKCS8.key" -out "${OUT}/mockserver.csr" -subj "/CN=$SERVER.ca/OU=$GROUP/O=$CORPORATION/L=$CITY/ST=$STATE/C=$COUNTRY"

# Generates mockserver certificate from CA using CSR
openssl x509 -req -in "${OUT}/mockserver.csr" -CA "${OUT}/ca.pem" -CAkey "${OUT}/ca.PKCS8.key" -CAcreateserial -out "${OUT}/mockserver.crt" -days 825 -sha256

chmod +r ${OUT}/*