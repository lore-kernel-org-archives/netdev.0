From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] Use new kconfig 'select' for networking crypto
Date: Wed, 4 Jun 2003 12:28:50 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306041222190.28457-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@digeo.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The patch below against recent bk uses the new 'select' feature of kconfig 
to configure crypto features for ipsec and ipv6 privacy extensions.

This should solve a lot of the build problems people have been having, and 
it also enables the crypto submenu (which previously did not work).

The sctp folk may also want to look at this scheme for their stuff.


- James
-- 
James Morris
<jmorris@intercode.com.au>

diff -urN -X dontdiff bk.pending/crypto/Kconfig bk.w1/crypto/Kconfig
--- bk.pending/crypto/Kconfig	2003-06-04 11:41:26.000000000 +1000
+++ bk.w1/crypto/Kconfig	2003-06-04 12:28:36.234711904 +1000
@@ -6,16 +6,12 @@
 
 config CRYPTO
 	bool "Cryptographic API"
-	default y if INET_AH=y || INET_AH=m || INET_ESP=y || INET_ESP=m || INET6_AH=y || INET6_AH=m || \
-		     INET6_ESP=y || INET6_ESP=m || INET6_IPCOMP=y || INET6_IPCOMP=m || IPV6_PRIVACY=y
 	help
 	  This option provides the core Cryptographic API.
 
 config CRYPTO_HMAC
 	bool "HMAC support"
 	depends on CRYPTO
-	default y if INET_AH=y || INET_AH=m || INET_ESP=y || INET_ESP=m || INET6_AH=y || INET6_AH=m || \
-		     INET6_ESP=y || INET6_ESP=m
 	help
 	  HMAC: Keyed-Hashing for Message Authentication (RFC2104).
 	  This is required for IPSec.
@@ -35,16 +31,12 @@
 config CRYPTO_MD5
 	tristate "MD5 digest algorithm"
 	depends on CRYPTO
-	default y if INET_AH=y || INET_AH=m || INET_ESP=y || INET_ESP=m || INET6_AH=y || INET6_AH=m || \
-	             INET6_ESP=y || INET6_ESP=m || IPV6_PRIVACY=y
 	help
 	  MD5 message digest algorithm (RFC1321).
 
 config CRYPTO_SHA1
 	tristate "SHA1 digest algorithm"
 	depends on CRYPTO
-	default y if INET_AH=y || INET_AH=m || INET_ESP=y || INET_ESP=m  || INET6_AH=y || INET6_AH=m || \
-	             INET6_ESP=y || INET6_ESP=m
 	help
 	  SHA-1 secure hash standard (FIPS 180-1/DFIPS 180-2).
 
@@ -72,7 +64,6 @@
 config CRYPTO_DES
 	tristate "DES and Triple DES EDE cipher algorithms"
 	depends on CRYPTO
-	default y if INET_ESP=y || INET_ESP=m || INET6_ESP=y || INET6_ESP=m
 	help
 	  DES cipher algorithm (FIPS 46-2), and Triple DES EDE (FIPS 46-3).
 
@@ -138,7 +129,6 @@
 config CRYPTO_DEFLATE
 	tristate "Deflate compression algorithm"
 	depends on CRYPTO
-	default y if INET_IPCOMP=y || INET_IPCOMP=m || INET6_IPCOMP=y || INET6_IPCOMP=m
 	help
 	  This is the Deflate algorithm (RFC1951), specified for use in
 	  IPSec with the IPCOMP protocol (RFC3173, RFC2394).
diff -urN -X dontdiff bk.pending/net/ipv4/Kconfig bk.w1/net/ipv4/Kconfig
--- bk.pending/net/ipv4/Kconfig	2003-06-04 11:42:08.000000000 +1000
+++ bk.w1/net/ipv4/Kconfig	2003-06-04 12:24:06.752679400 +1000
@@ -343,6 +343,10 @@
 
 config INET_AH
 	tristate "IP: AH transformation"
+	select CRYPTO
+	select CRYPTO_HMAC
+	select CRYPTO_MD5
+	select CRYPTO_SHA1
 	---help---
 	  Support for IPsec AH.
 
@@ -350,6 +354,11 @@
 
 config INET_ESP
 	tristate "IP: ESP transformation"
+	select CRYPTO
+	select CRYPTO_HMAC
+	select CRYPTO_MD5
+	select CRYPTO_SHA1
+	select CRYPTO_DES
 	---help---
 	  Support for IPsec ESP.
 
@@ -357,6 +366,8 @@
 
 config INET_IPCOMP
 	tristate "IP: IPComp transformation"
+	select CRYPTO
+	select CRYPTO_DEFLATE
 	---help---
 	  Support for IP Paylod Compression (RFC3173), typically needed
 	  for IPsec.
diff -urN -X dontdiff bk.pending/net/ipv6/Kconfig bk.w1/net/ipv6/Kconfig
--- bk.pending/net/ipv6/Kconfig	2003-06-04 11:42:09.000000000 +1000
+++ bk.w1/net/ipv6/Kconfig	2003-06-04 12:24:05.242908920 +1000
@@ -4,6 +4,8 @@
 config IPV6_PRIVACY
 	bool "IPv6: Privacy Extensions (RFC 3041) support"
 	depends on IPV6
+	select CRYPTO
+	select CRYPTO_MD5
 	---help---
 	  Privacy Extensions for Stateless Address Autoconfiguration in IPv6
 	  support.  With this option, additional periodically-alter 
@@ -20,6 +22,10 @@
 config INET6_AH
 	tristate "IPv6: AH transformation"
 	depends on IPV6
+	select CRYPTO
+	select CRYPTO_HMAC
+	select CRYPTO_MD5
+	select CRYPTO_SHA1
 	---help---
 	  Support for IPsec AH.
 
@@ -28,6 +34,11 @@
 config INET6_ESP
 	tristate "IPv6: ESP transformation"
 	depends on IPV6
+	select CRYPTO
+	select CRYPTO_HMAC
+	select CRYPTO_MD5
+	select CRYPTO_SHA1
+	select CRYPTO_DES
 	---help---
 	  Support for IPsec ESP.
 
@@ -36,6 +47,8 @@
 config INET6_IPCOMP
 	tristate "IPv6: IPComp transformation"
 	depends on IPV6
+	select CRYPTO
+	select CRYPTO_DEFLATE
 	---help---
 	  Support for IP Paylod Compression (RFC3173), typically needed
 	  for IPsec.
