From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 12/16] [IPSEC] ESP: Use block ciphers where applicable
Date: Sun, 13 Aug 2006 22:20:20 +1000
Message-ID: <E1GCEx2-0004gP-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:15881 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751099AbWHMMUa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:20:30 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC] ESP: Use block ciphers where applicable

This patch converts IPSec/ESP to use the new block cipher type where
applicable.  Similar to the HMAC conversion, existing algorithm names
have been kept for compatibility.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/esp.h    |    2 +-
 net/ipv4/Kconfig     |    1 +
 net/ipv4/esp4.c      |   49 +++++++++++++++++++++++++++++--------------------
 net/ipv6/Kconfig     |    1 +
 net/ipv6/esp6.c      |   48 ++++++++++++++++++++++++++++--------------------
 net/xfrm/xfrm_algo.c |   24 ++++++++++++++++--------
 6 files changed, 76 insertions(+), 49 deletions(-)

diff --git a/include/net/esp.h b/include/net/esp.h
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -22,7 +22,7 @@ struct esp_data
 		 * >= crypto_tfm_alg_ivsize(tfm). */
 		int			ivlen;
 		int			padlen;		/* 0..255 */
-		struct crypto_tfm	*tfm;		/* crypto handle */
+		struct crypto_blkcipher	*tfm;		/* crypto handle */
 	} conf;
 
 	/* Integrity. It is active when icv_full_len != 0 */
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -386,6 +386,7 @@ config INET_ESP
 	select CRYPTO
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
+	select CRYPTO_CBC
 	select CRYPTO_SHA1
 	select CRYPTO_DES
 	---help---
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -1,3 +1,4 @@
+#include <linux/err.h>
 #include <linux/module.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
@@ -16,7 +17,8 @@ static int esp_output(struct xfrm_state 
 	int err;
 	struct iphdr *top_iph;
 	struct ip_esp_hdr *esph;
-	struct crypto_tfm *tfm;
+	struct crypto_blkcipher *tfm;
+	struct blkcipher_desc desc;
 	struct esp_data *esp;
 	struct sk_buff *trailer;
 	int blksize;
@@ -36,7 +38,9 @@ static int esp_output(struct xfrm_state 
 	esp = x->data;
 	alen = esp->auth.icv_trunc_len;
 	tfm = esp->conf.tfm;
-	blksize = ALIGN(crypto_tfm_alg_blocksize(tfm), 4);
+	desc.tfm = tfm;
+	desc.flags = 0;
+	blksize = ALIGN(crypto_blkcipher_blocksize(tfm), 4);
 	clen = ALIGN(clen + 2, blksize);
 	if (esp->conf.padlen)
 		clen = ALIGN(clen, esp->conf.padlen);
@@ -92,7 +96,7 @@ static int esp_output(struct xfrm_state 
 	xfrm_aevent_doreplay(x);
 
 	if (esp->conf.ivlen)
-		crypto_cipher_set_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
+		crypto_blkcipher_set_iv(tfm, esp->conf.ivec, esp->conf.ivlen);
 
 	do {
 		struct scatterlist *sg = &esp->sgbuf[0];
@@ -103,14 +107,17 @@ static int esp_output(struct xfrm_state 
 				goto error;
 		}
 		skb_to_sgvec(skb, sg, esph->enc_data+esp->conf.ivlen-skb->data, clen);
-		crypto_cipher_encrypt(tfm, sg, sg, clen);
+		err = crypto_blkcipher_encrypt(&desc, sg, sg, clen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
 	} while (0);
 
+	if (unlikely(err))
+		goto error;
+
 	if (esp->conf.ivlen) {
-		memcpy(esph->enc_data, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
-		crypto_cipher_get_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
+		memcpy(esph->enc_data, esp->conf.ivec, esp->conf.ivlen);
+		crypto_blkcipher_get_iv(tfm, esp->conf.ivec, esp->conf.ivlen);
 	}
 
 	if (esp->auth.icv_full_len) {
@@ -121,8 +128,6 @@ static int esp_output(struct xfrm_state 
 
 	ip_send_check(top_iph);
 
-	err = 0;
-
 error:
 	return err;
 }
@@ -137,8 +142,10 @@ static int esp_input(struct xfrm_state *
 	struct iphdr *iph;
 	struct ip_esp_hdr *esph;
 	struct esp_data *esp = x->data;
+	struct crypto_blkcipher *tfm = esp->conf.tfm;
+	struct blkcipher_desc desc = { .tfm = tfm };
 	struct sk_buff *trailer;
-	int blksize = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
+	int blksize = ALIGN(crypto_blkcipher_blocksize(tfm), 4);
 	int alen = esp->auth.icv_trunc_len;
 	int elen = skb->len - sizeof(struct ip_esp_hdr) - esp->conf.ivlen - alen;
 	int nfrags;
@@ -146,6 +153,7 @@ static int esp_input(struct xfrm_state *
 	u8 nexthdr[2];
 	struct scatterlist *sg;
 	int padlen;
+	int err;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr)))
 		goto out;
@@ -178,7 +186,7 @@ static int esp_input(struct xfrm_state *
 
 	/* Get ivec. This can be wrong, check against another impls. */
 	if (esp->conf.ivlen)
-		crypto_cipher_set_iv(esp->conf.tfm, esph->enc_data, crypto_tfm_alg_ivsize(esp->conf.tfm));
+		crypto_blkcipher_set_iv(tfm, esph->enc_data, esp->conf.ivlen);
 
 	sg = &esp->sgbuf[0];
 
@@ -188,9 +196,11 @@ static int esp_input(struct xfrm_state *
 			goto out;
 	}
 	skb_to_sgvec(skb, sg, sizeof(struct ip_esp_hdr) + esp->conf.ivlen, elen);
-	crypto_cipher_decrypt(esp->conf.tfm, sg, sg, elen);
+	err = crypto_blkcipher_decrypt(&desc, sg, sg, elen);
 	if (unlikely(sg != &esp->sgbuf[0]))
 		kfree(sg);
+	if (unlikely(err))
+		return err;
 
 	if (skb_copy_bits(skb, skb->len-alen-2, nexthdr, 2))
 		BUG();
@@ -254,7 +264,7 @@ out:
 static u32 esp4_get_max_size(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
-	u32 blksize = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
+	u32 blksize = ALIGN(crypto_blkcipher_blocksize(esp->conf.tfm), 4);
 
 	if (x->props.mode) {
 		mtu = ALIGN(mtu + 2, blksize);
@@ -293,7 +303,7 @@ static void esp_destroy(struct xfrm_stat
 	if (!esp)
 		return;
 
-	crypto_free_tfm(esp->conf.tfm);
+	crypto_free_blkcipher(esp->conf.tfm);
 	esp->conf.tfm = NULL;
 	kfree(esp->conf.ivec);
 	esp->conf.ivec = NULL;
@@ -307,6 +317,7 @@ static void esp_destroy(struct xfrm_stat
 static int esp_init_state(struct xfrm_state *x)
 {
 	struct esp_data *esp = NULL;
+	struct crypto_blkcipher *tfm;
 
 	/* null auth and encryption can have zero length keys */
 	if (x->aalg) {
@@ -353,13 +364,11 @@ static int esp_init_state(struct xfrm_st
 	}
 	esp->conf.key = x->ealg->alg_key;
 	esp->conf.key_len = (x->ealg->alg_key_len+7)/8;
-	if (x->props.ealgo == SADB_EALG_NULL)
-		esp->conf.tfm = crypto_alloc_tfm(x->ealg->alg_name, CRYPTO_TFM_MODE_ECB);
-	else
-		esp->conf.tfm = crypto_alloc_tfm(x->ealg->alg_name, CRYPTO_TFM_MODE_CBC);
-	if (esp->conf.tfm == NULL)
+	tfm = crypto_alloc_blkcipher(x->ealg->alg_name, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
 		goto error;
-	esp->conf.ivlen = crypto_tfm_alg_ivsize(esp->conf.tfm);
+	esp->conf.tfm = tfm;
+	esp->conf.ivlen = crypto_blkcipher_ivsize(tfm);
 	esp->conf.padlen = 0;
 	if (esp->conf.ivlen) {
 		esp->conf.ivec = kmalloc(esp->conf.ivlen, GFP_KERNEL);
@@ -367,7 +376,7 @@ static int esp_init_state(struct xfrm_st
 			goto error;
 		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
 	}
-	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
+	if (crypto_blkcipher_setkey(tfm, esp->conf.key, esp->conf.key_len))
 		goto error;
 	x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
 	if (x->props.mode)
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -77,6 +77,7 @@ config INET6_ESP
 	select CRYPTO
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
+	select CRYPTO_CBC
 	select CRYPTO_SHA1
 	select CRYPTO_DES
 	---help---
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -24,6 +24,7 @@
  * 	This file is derived from net/ipv4/esp.c
  */
 
+#include <linux/err.h>
 #include <linux/module.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
@@ -44,7 +45,8 @@ static int esp6_output(struct xfrm_state
 	int hdr_len;
 	struct ipv6hdr *top_iph;
 	struct ipv6_esp_hdr *esph;
-	struct crypto_tfm *tfm;
+	struct crypto_blkcipher *tfm;
+	struct blkcipher_desc desc;
 	struct esp_data *esp;
 	struct sk_buff *trailer;
 	int blksize;
@@ -67,7 +69,9 @@ static int esp6_output(struct xfrm_state
 
 	alen = esp->auth.icv_trunc_len;
 	tfm = esp->conf.tfm;
-	blksize = ALIGN(crypto_tfm_alg_blocksize(tfm), 4);
+	desc.tfm = tfm;
+	desc.flags = 0;
+	blksize = ALIGN(crypto_blkcipher_blocksize(tfm), 4);
 	clen = ALIGN(clen + 2, blksize);
 	if (esp->conf.padlen)
 		clen = ALIGN(clen, esp->conf.padlen);
@@ -96,7 +100,7 @@ static int esp6_output(struct xfrm_state
 	xfrm_aevent_doreplay(x);
 
 	if (esp->conf.ivlen)
-		crypto_cipher_set_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
+		crypto_blkcipher_set_iv(tfm, esp->conf.ivec, esp->conf.ivlen);
 
 	do {
 		struct scatterlist *sg = &esp->sgbuf[0];
@@ -107,14 +111,17 @@ static int esp6_output(struct xfrm_state
 				goto error;
 		}
 		skb_to_sgvec(skb, sg, esph->enc_data+esp->conf.ivlen-skb->data, clen);
-		crypto_cipher_encrypt(tfm, sg, sg, clen);
+		err = crypto_blkcipher_encrypt(&desc, sg, sg, clen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
 	} while (0);
 
+	if (unlikely(err))
+		goto error;
+
 	if (esp->conf.ivlen) {
-		memcpy(esph->enc_data, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
-		crypto_cipher_get_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
+		memcpy(esph->enc_data, esp->conf.ivec, esp->conf.ivlen);
+		crypto_blkcipher_get_iv(tfm, esp->conf.ivec, esp->conf.ivlen);
 	}
 
 	if (esp->auth.icv_full_len) {
@@ -123,8 +130,6 @@ static int esp6_output(struct xfrm_state
 		pskb_put(skb, trailer, alen);
 	}
 
-	err = 0;
-
 error:
 	return err;
 }
@@ -134,8 +139,10 @@ static int esp6_input(struct xfrm_state 
 	struct ipv6hdr *iph;
 	struct ipv6_esp_hdr *esph;
 	struct esp_data *esp = x->data;
+	struct crypto_blkcipher *tfm = esp->conf.tfm;
+	struct blkcipher_desc desc = { .tfm = tfm };
 	struct sk_buff *trailer;
-	int blksize = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
+	int blksize = ALIGN(crypto_blkcipher_blocksize(tfm), 4);
 	int alen = esp->auth.icv_trunc_len;
 	int elen = skb->len - sizeof(struct ipv6_esp_hdr) - esp->conf.ivlen - alen;
 
@@ -182,7 +189,7 @@ static int esp6_input(struct xfrm_state 
 
 	/* Get ivec. This can be wrong, check against another impls. */
 	if (esp->conf.ivlen)
-		crypto_cipher_set_iv(esp->conf.tfm, esph->enc_data, crypto_tfm_alg_ivsize(esp->conf.tfm));
+		crypto_blkcipher_set_iv(tfm, esph->enc_data, esp->conf.ivlen);
 
         {
 		u8 nexthdr[2];
@@ -197,9 +204,11 @@ static int esp6_input(struct xfrm_state 
 			}
 		}
 		skb_to_sgvec(skb, sg, sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen, elen);
-		crypto_cipher_decrypt(esp->conf.tfm, sg, sg, elen);
+		ret = crypto_blkcipher_decrypt(&desc, sg, sg, elen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
+		if (unlikely(ret))
+			goto out;
 
 		if (skb_copy_bits(skb, skb->len-alen-2, nexthdr, 2))
 			BUG();
@@ -225,7 +234,7 @@ out:
 static u32 esp6_get_max_size(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
-	u32 blksize = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
+	u32 blksize = ALIGN(crypto_blkcipher_blocksize(esp->conf.tfm), 4);
 
 	if (x->props.mode) {
 		mtu = ALIGN(mtu + 2, blksize);
@@ -266,7 +275,7 @@ static void esp6_destroy(struct xfrm_sta
 	if (!esp)
 		return;
 
-	crypto_free_tfm(esp->conf.tfm);
+	crypto_free_blkcipher(esp->conf.tfm);
 	esp->conf.tfm = NULL;
 	kfree(esp->conf.ivec);
 	esp->conf.ivec = NULL;
@@ -280,6 +289,7 @@ static void esp6_destroy(struct xfrm_sta
 static int esp6_init_state(struct xfrm_state *x)
 {
 	struct esp_data *esp = NULL;
+	struct crypto_blkcipher *tfm;
 
 	/* null auth and encryption can have zero length keys */
 	if (x->aalg) {
@@ -327,13 +337,11 @@ static int esp6_init_state(struct xfrm_s
 	}
 	esp->conf.key = x->ealg->alg_key;
 	esp->conf.key_len = (x->ealg->alg_key_len+7)/8;
-	if (x->props.ealgo == SADB_EALG_NULL)
-		esp->conf.tfm = crypto_alloc_tfm(x->ealg->alg_name, CRYPTO_TFM_MODE_ECB);
-	else
-		esp->conf.tfm = crypto_alloc_tfm(x->ealg->alg_name, CRYPTO_TFM_MODE_CBC);
-	if (esp->conf.tfm == NULL)
+	tfm = crypto_alloc_blkcipher(x->ealg->alg_name, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
 		goto error;
-	esp->conf.ivlen = crypto_tfm_alg_ivsize(esp->conf.tfm);
+	esp->conf.tfm = tfm;
+	esp->conf.ivlen = crypto_blkcipher_ivsize(tfm);
 	esp->conf.padlen = 0;
 	if (esp->conf.ivlen) {
 		esp->conf.ivec = kmalloc(esp->conf.ivlen, GFP_KERNEL);
@@ -341,7 +349,7 @@ static int esp6_init_state(struct xfrm_s
 			goto error;
 		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
 	}
-	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
+	if (crypto_blkcipher_setkey(tfm, esp->conf.key, esp->conf.key_len))
 		goto error;
 	x->props.header_len = sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
 	if (x->props.mode)
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -118,7 +118,8 @@ static struct xfrm_algo_desc aalg_list[]
 
 static struct xfrm_algo_desc ealg_list[] = {
 {
-	.name = "cipher_null",
+	.name = "ecb(cipher_null)",
+	.compat = "cipher_null",
 	
 	.uinfo = {
 		.encr = {
@@ -135,7 +136,8 @@ static struct xfrm_algo_desc ealg_list[]
 	}
 },
 {
-	.name = "des",
+	.name = "cbc(des)",
+	.compat = "des",
 
 	.uinfo = {
 		.encr = {
@@ -152,7 +154,8 @@ static struct xfrm_algo_desc ealg_list[]
 	}
 },
 {
-	.name = "des3_ede",
+	.name = "cbc(des3_ede)",
+	.compat = "des3_ede",
 
 	.uinfo = {
 		.encr = {
@@ -169,7 +172,8 @@ static struct xfrm_algo_desc ealg_list[]
 	}
 },
 {
-	.name = "cast128",
+	.name = "cbc(cast128)",
+	.compat = "cast128",
 
 	.uinfo = {
 		.encr = {
@@ -186,7 +190,8 @@ static struct xfrm_algo_desc ealg_list[]
 	}
 },
 {
-	.name = "blowfish",
+	.name = "cbc(blowfish)",
+	.compat = "blowfish",
 
 	.uinfo = {
 		.encr = {
@@ -203,7 +208,8 @@ static struct xfrm_algo_desc ealg_list[]
 	}
 },
 {
-	.name = "aes",
+	.name = "cbc(aes)",
+	.compat = "aes",
 
 	.uinfo = {
 		.encr = {
@@ -220,7 +226,8 @@ static struct xfrm_algo_desc ealg_list[]
 	}
 },
 {
-        .name = "serpent",
+        .name = "cbc(serpent)",
+        .compat = "serpent",
 
         .uinfo = {
                 .encr = {
@@ -237,7 +244,8 @@ static struct xfrm_algo_desc ealg_list[]
         }
 },
 {
-        .name = "twofish",
+        .name = "cbc(twofish)",
+        .compat = "twofish",
                  
         .uinfo = {
                 .encr = {
