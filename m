From: Tom Lendacky <toml@us.ibm.com>
Subject: [PATCH] IPSec: Use of "sizeof" for header sizes, part II
Date: 01 Apr 2003 16:04:32 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1049234673.5116.11.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Below is a patch for your consideration removing the hard coded 8 that
represented the ESP spi and sequence number fields.  I had to define
a pointer to ip(v6)_esp_header in esp(6)_init_state in order to obtain
the size of the enc_data member in the most straight forward way.

Please review and let me know if any changes are required.

Thanks,
Tom

diff -ur linux-2.5.66-orig/net/ipv4/esp.c linux-2.5.66/net/ipv4/esp.c
--- linux-2.5.66-orig/net/ipv4/esp.c	2003-03-31 14:47:18.000000000 -0600
+++ linux-2.5.66/net/ipv4/esp.c	2003-03-31 14:46:39.000000000 -0600
@@ -134,7 +134,8 @@
 
 	if (esp->auth.icv_full_len) {
 		esp->auth.icv(esp, skb, (u8*)esph-skb->data,
-		              8+esp->conf.ivlen+clen, trailer->tail);
+		              (sizeof(struct ip_esp_hdr) - sizeof(esph->enc_data)) + esp->conf.ivlen + clen,
+		              trailer->tail);
 		pskb_put(skb, trailer, alen);
 	}
 
@@ -171,7 +172,7 @@
 	struct sk_buff *trailer;
 	int blksize = crypto_tfm_alg_blocksize(esp->conf.tfm);
 	int alen = esp->auth.icv_trunc_len;
-	int elen = skb->len - 8 - esp->conf.ivlen - alen;
+	int elen = skb->len - (sizeof(struct ip_esp_hdr) - sizeof(esph->enc_data)) - esp->conf.ivlen - alen;
 	int nfrags;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr)))
@@ -220,7 +221,8 @@
 			if (!sg)
 				goto out;
 		}
-		skb_to_sgvec(skb, sg, 8+esp->conf.ivlen, elen);
+		skb_to_sgvec(skb, sg,
+		             (sizeof(struct ip_esp_hdr) - sizeof(esph->enc_data)) + esp->conf.ivlen, elen);
 		crypto_cipher_decrypt(esp->conf.tfm, sg, sg, elen);
 		if (unlikely(sg != sgbuf))
 			kfree(sg);
@@ -237,8 +239,8 @@
 		iph->protocol = nexthdr[1];
 		pskb_trim(skb, skb->len - alen - padlen - 2);
 		memcpy(workbuf, skb->nh.raw, iph->ihl*4);
-		skb->h.raw = skb_pull(skb, 8 + esp->conf.ivlen);
-		skb->nh.raw += 8 + esp->conf.ivlen;
+		skb->h.raw = skb_pull(skb, (sizeof(struct ip_esp_hdr) - sizeof(esph->enc_data)) + esp->conf.ivlen);
+		skb->nh.raw += (sizeof(struct ip_esp_hdr) - sizeof(esph->enc_data)) + esp->conf.ivlen;
 		memcpy(skb->nh.raw, workbuf, iph->ihl*4);
 		skb->nh.iph->tot_len = htons(skb->len);
 	}
@@ -308,6 +310,7 @@
 
 int esp_init_state(struct xfrm_state *x, void *args)
 {
+	struct ip_esp_hdr *esph = NULL;
 	struct esp_data *esp = NULL;
 
 	/* null auth and encryption can have zero length keys */
@@ -365,7 +368,7 @@
 		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
 	}
 	crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
-	x->props.header_len = 8 + esp->conf.ivlen;
+	x->props.header_len = (sizeof(struct ip_esp_hdr) - sizeof(esph->enc_data)) + esp->conf.ivlen;
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct iphdr);
 	x->data = esp;
diff -ur linux-2.5.66-orig/net/ipv6/esp6.c linux-2.5.66/net/ipv6/esp6.c
--- linux-2.5.66-orig/net/ipv6/esp6.c	2003-03-31 14:47:18.000000000 -0600
+++ linux-2.5.66/net/ipv6/esp6.c	2003-03-31 14:46:39.000000000 -0600
@@ -232,7 +232,8 @@
 
 	if (esp->auth.icv_full_len) {
 		esp->auth.icv(esp, skb, (u8*)esph-skb->data,
-			8+esp->conf.ivlen+clen, trailer->tail);
+			(sizeof(struct ipv6_esp_hdr) - sizeof(esph->enc_data)) + esp->conf.ivlen + clen,
+			trailer->tail);
 		pskb_put(skb, trailer, alen);
 	}
 
@@ -262,7 +263,7 @@
 	struct sk_buff *trailer;
 	int blksize = crypto_tfm_alg_blocksize(esp->conf.tfm);
 	int alen = esp->auth.icv_trunc_len;
-	int elen = skb->len - 8 - esp->conf.ivlen - alen;
+	int elen = skb->len - (sizeof(struct ipv6_esp_hdr) - sizeof(esph->enc_data)) - esp->conf.ivlen - alen;
 
 	int hdr_len = skb->h.raw - skb->nh.raw;
 	int nfrags;
@@ -319,7 +320,7 @@
 			if (!sg)
 				goto out;
 		}
-		skb_to_sgvec(skb, sg, 8+esp->conf.ivlen, elen);
+		skb_to_sgvec(skb, sg, (sizeof(struct ipv6_esp_hdr) - sizeof(esph->enc_data)) + esp->conf.ivlen, elen);
 		crypto_cipher_decrypt(esp->conf.tfm, sg, sg, elen);
 		if (unlikely(sg != sgbuf))
 			kfree(sg);
@@ -338,8 +339,8 @@
 
 		ret_nexthdr = ((struct ipv6hdr*)tmp_hdr)->nexthdr = nexthdr[1];
 		pskb_trim(skb, skb->len - alen - padlen - 2);
-		skb->h.raw = skb_pull(skb, 8 + esp->conf.ivlen);
-		skb->nh.raw += 8 + esp->conf.ivlen;
+		skb->h.raw = skb_pull(skb, (sizeof(struct ipv6_esp_hdr) - sizeof(esph->enc_data)) + esp->conf.ivlen);
+		skb->nh.raw += (sizeof(struct ipv6_esp_hdr) - sizeof(esph->enc_data)) + esp->conf.ivlen;
 		memcpy(skb->nh.raw, tmp_hdr, hdr_len);
 	}
 	kfree(tmp_hdr);
@@ -410,6 +411,7 @@
 
 int esp6_init_state(struct xfrm_state *x, void *args)
 {
+	struct ipv6_esp_hdr *esph = NULL;
 	struct esp_data *esp = NULL;
 
 	if (x->aalg) {
@@ -466,7 +468,7 @@
 		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
 	}
 	crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
-	x->props.header_len = 8 + esp->conf.ivlen;
+	x->props.header_len = (sizeof(struct ipv6_esp_hdr) - sizeof(esph->enc_data)) + esp->conf.ivlen;
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct ipv6hdr);
 	x->data = esp;
