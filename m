From: Tom Lendacky <toml@us.ibm.com>
Subject: [PATCH] IPSec: Use of "sizeof" for header sizes
Date: 31 Mar 2003 12:07:08 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1049134030.1253.143.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Below is a patch for your consideration eliminating the use of some
constants in the AH and ESP routines for IPv4 and IPv6.  I believe
there was also a typo in a memcpy statement in net/ipv4/ah.c where
iph->ihl was multiplied by 5 instead of 4.

Also, the ESP files often use the constant 8 when calculating header
length.  This could be replaced a couple of ways:
  - use sizeof spi and sizeof seq_no
  - use sizeof ip(v6)_esp_hdr and substract the sizeof enc_data
  - remove enc_data[8] from the ip(v6)_esp_hdr.  You could then use
    sizeof ip(v6)_esp_hdr, but you would then need to fix the
    references to enc_data in the code (3 refs in each version).
I thought I'd get some comments or other suggestions on which
approach would be best and most understandable/readable.

Thanks,
Tom

diff -ur linux-2.5.66-orig/net/ipv4/ah.c linux-2.5.66/net/ipv4/ah.c
--- linux-2.5.66-orig/net/ipv4/ah.c	2003-03-31 09:35:36.000000000 -0600
+++ linux-2.5.66/net/ipv4/ah.c	2003-03-31 09:22:47.000000000 -0600
@@ -18,7 +18,7 @@
 static int ip_clear_mutable_options(struct iphdr *iph, u32 *daddr)
 {
 	unsigned char * optptr = (unsigned char*)(iph+1);
-	int  l = iph->ihl*4 - 20;
+	int  l = iph->ihl*4 - sizeof(struct iphdr);
 	int  optlen;
 
 	while (l > 0) {
@@ -132,7 +132,7 @@
 		top_iph->frag_off = iph->frag_off;
 		top_iph->daddr = iph->daddr;
 		if (iph->ihl != 5)
-			memcpy(top_iph+1, iph+1, iph->ihl*5 - 20);
+			memcpy(top_iph+1, iph+1, iph->ihl*4 - sizeof(struct iphdr));
 	}
 	ip_send_check(top_iph);
 
@@ -288,7 +288,7 @@
 	
 	x->props.header_len = XFRM_ALIGN8(ahp->icv_trunc_len + AH_HLEN_NOICV);
 	if (x->props.mode)
-		x->props.header_len += 20;
+		x->props.header_len += sizeof(struct iphdr);
 	x->data = ahp;
 
 	return 0;
diff -ur linux-2.5.66-orig/net/ipv4/esp.c linux-2.5.66/net/ipv4/esp.c
--- linux-2.5.66-orig/net/ipv4/esp.c	2003-03-31 09:35:36.000000000 -0600
+++ linux-2.5.66/net/ipv4/esp.c	2003-03-31 09:22:47.000000000 -0600
@@ -367,7 +367,7 @@
 	crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
 	x->props.header_len = 8 + esp->conf.ivlen;
 	if (x->props.mode)
-		x->props.header_len += 20;
+		x->props.header_len += sizeof(struct iphdr);
 	x->data = esp;
 	x->props.trailer_len = esp4_get_max_size(x, 0) - x->props.header_len;
 	return 0;
diff -ur linux-2.5.66-orig/net/ipv6/ah6.c linux-2.5.66/net/ipv6/ah6.c
--- linux-2.5.66-orig/net/ipv6/ah6.c	2003-03-31 09:37:20.000000000 -0600
+++ linux-2.5.66/net/ipv6/ah6.c	2003-03-31 09:22:47.000000000 -0600
@@ -287,7 +287,7 @@
 	
 	x->props.header_len = XFRM_ALIGN8(ahp->icv_trunc_len + AH_HLEN_NOICV);
 	if (x->props.mode)
-		x->props.header_len += 40;
+		x->props.header_len += sizeof(struct ipv6hdr);
 	x->data = ahp;
 
 	return 0;
diff -ur linux-2.5.66-orig/net/ipv6/esp6.c linux-2.5.66/net/ipv6/esp6.c
--- linux-2.5.66-orig/net/ipv6/esp6.c	2003-03-31 09:37:20.000000000 -0600
+++ linux-2.5.66/net/ipv6/esp6.c	2003-03-31 09:22:47.000000000 -0600
@@ -468,7 +468,7 @@
 	crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
 	x->props.header_len = 8 + esp->conf.ivlen;
 	if (x->props.mode)
-		x->props.header_len += 40;  /* XXX ext hdr */
+		x->props.header_len += sizeof(struct ipv6hdr);
 	x->data = esp;
 	return 0;
 
