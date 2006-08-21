From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/7] [IPSEC]: Use HMAC template and hash interface
Date: Tue, 22 Aug 2006 00:27:51 +1000
Message-ID: <E1GFAkp-00074Q-00@gondolin.me.apana.org.au>
References: <20060821142407.GA26988@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40454 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751885AbWHUO1z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 10:27:55 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Use HMAC template and hash interface

This patch converts IPsec to use the new HMAC template.  The names of
existing simple digest algorithms may still be used to refer to their
HMAC composites.

The same structure can be used by other MACs such as AES-XCBC-MAC.

This patch also switches from the digest interface to hash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---

 include/net/ah.h     |   29 ++++++++++++++++++-----------
 include/net/esp.h    |   26 +++++++++++++++-----------
 include/net/xfrm.h   |    9 +++++----
 net/ipv4/ah4.c       |   36 ++++++++++++++++++++++++------------
 net/ipv4/esp4.c      |   36 +++++++++++++++++++++---------------
 net/ipv6/ah6.c       |   35 +++++++++++++++++++++++------------
 net/ipv6/esp6.c      |   42 ++++++++++++++++++++++++------------------
 net/xfrm/xfrm_algo.c |   40 +++++++++++++++++++++++++++-------------
 8 files changed, 157 insertions(+), 96 deletions(-)

diff --git a/include/net/ah.h b/include/net/ah.h
--- a/include/net/ah.h
+++ b/include/net/ah.h
@@ -15,22 +15,29 @@ struct ah_data
 	int			icv_full_len;
 	int			icv_trunc_len;
 
-	void			(*icv)(struct ah_data*,
-	                               struct sk_buff *skb, u8 *icv);
-
-	struct crypto_tfm	*tfm;
+	struct crypto_hash	*tfm;
 };
 
-static inline void
-ah_hmac_digest(struct ah_data *ahp, struct sk_buff *skb, u8 *auth_data)
+static inline int ah_mac_digest(struct ah_data *ahp, struct sk_buff *skb,
+				u8 *auth_data)
 {
-	struct crypto_tfm *tfm = ahp->tfm;
+	struct hash_desc desc;
+	int err;
+
+	desc.tfm = ahp->tfm;
+	desc.flags = 0;
 
 	memset(auth_data, 0, ahp->icv_trunc_len);
-	crypto_hmac_init(tfm, ahp->key, &ahp->key_len);
-	skb_icv_walk(skb, tfm, 0, skb->len, crypto_hmac_update);
-	crypto_hmac_final(tfm, ahp->key, &ahp->key_len, ahp->work_icv);
-	memcpy(auth_data, ahp->work_icv, ahp->icv_trunc_len);
+	err = crypto_hash_init(&desc);
+	if (unlikely(err))
+		goto out;
+	err = skb_icv_walk(skb, &desc, 0, skb->len, crypto_hash_update);
+	if (unlikely(err))
+		goto out;
+	err = crypto_hash_final(&desc, ahp->work_icv);
+
+out:
+	return err;
 }
 
 #endif
diff --git a/include/net/esp.h b/include/net/esp.h
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -35,7 +35,7 @@ struct esp_data
 		void			(*icv)(struct esp_data*,
 		                               struct sk_buff *skb,
 		                               int offset, int len, u8 *icv);
-		struct crypto_tfm	*tfm;
+		struct crypto_hash	*tfm;
 	} auth;
 };
 
@@ -43,18 +43,22 @@ extern int skb_to_sgvec(struct sk_buff *
 extern int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer);
 extern void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
 
-static inline void
-esp_hmac_digest(struct esp_data *esp, struct sk_buff *skb, int offset,
-                int len, u8 *auth_data)
+static inline int esp_mac_digest(struct esp_data *esp, struct sk_buff *skb,
+				 int offset, int len)
 {
-	struct crypto_tfm *tfm = esp->auth.tfm;
-	char *icv = esp->auth.work_icv;
+	struct hash_desc desc;
+	int err;
 
-	memset(auth_data, 0, esp->auth.icv_trunc_len);
-	crypto_hmac_init(tfm, esp->auth.key, &esp->auth.key_len);
-	skb_icv_walk(skb, tfm, offset, len, crypto_hmac_update);
-	crypto_hmac_final(tfm, esp->auth.key, &esp->auth.key_len, icv);
-	memcpy(auth_data, icv, esp->auth.icv_trunc_len);
+	desc.tfm = esp->auth.tfm;
+	desc.flags = 0;
+
+	err = crypto_hash_init(&desc);
+	if (unlikely(err))
+		return err;
+	err = skb_icv_walk(skb, &desc, offset, len, crypto_hash_update);
+	if (unlikely(err))
+		return err;
+	return crypto_hash_final(&desc, esp->auth.work_icv);
 }
 
 #endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -984,12 +984,13 @@ extern struct xfrm_algo_desc *xfrm_aalg_
 extern struct xfrm_algo_desc *xfrm_ealg_get_byname(char *name, int probe);
 extern struct xfrm_algo_desc *xfrm_calg_get_byname(char *name, int probe);
 
-struct crypto_tfm;
+struct hash_desc;
 struct scatterlist;
-typedef void (icv_update_fn_t)(struct crypto_tfm *, struct scatterlist *, unsigned int);
+typedef int (icv_update_fn_t)(struct hash_desc *, struct scatterlist *,
+			      unsigned int);
 
-extern void skb_icv_walk(const struct sk_buff *skb, struct crypto_tfm *tfm,
-			 int offset, int len, icv_update_fn_t icv_update);
+extern int skb_icv_walk(const struct sk_buff *skb, struct hash_desc *tfm,
+			int offset, int len, icv_update_fn_t icv_update);
 
 static inline int xfrm_addr_cmp(xfrm_address_t *a, xfrm_address_t *b,
 				int family)
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -1,3 +1,4 @@
+#include <linux/err.h>
 #include <linux/module.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
@@ -97,7 +98,10 @@ static int ah_output(struct xfrm_state *
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(++x->replay.oseq);
 	xfrm_aevent_doreplay(x);
-	ahp->icv(ahp, skb, ah->auth_data);
+	err = ah_mac_digest(ahp, skb, ah->auth_data);
+	if (err)
+		goto error;
+	memcpy(ah->auth_data, ahp->work_icv, ahp->icv_trunc_len);
 
 	top_iph->tos = iph->tos;
 	top_iph->ttl = iph->ttl;
@@ -119,6 +123,7 @@ static int ah_input(struct xfrm_state *x
 {
 	int ah_hlen;
 	int ihl;
+	int err = -EINVAL;
 	struct iphdr *iph;
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
@@ -166,8 +171,11 @@ static int ah_input(struct xfrm_state *x
 		
 		memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
 		skb_push(skb, ihl);
-		ahp->icv(ahp, skb, ah->auth_data);
-		if (memcmp(ah->auth_data, auth_data, ahp->icv_trunc_len)) {
+		err = ah_mac_digest(ahp, skb, ah->auth_data);
+		if (err)
+			goto out;
+		err = -EINVAL;
+		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
 			x->stats.integrity_failed++;
 			goto out;
 		}
@@ -179,7 +187,7 @@ static int ah_input(struct xfrm_state *x
 	return 0;
 
 out:
-	return -EINVAL;
+	return err;
 }
 
 static void ah4_err(struct sk_buff *skb, u32 info)
@@ -204,6 +212,7 @@ static int ah_init_state(struct xfrm_sta
 {
 	struct ah_data *ahp = NULL;
 	struct xfrm_algo_desc *aalg_desc;
+	struct crypto_hash *tfm;
 
 	if (!x->aalg)
 		goto error;
@@ -223,24 +232,27 @@ static int ah_init_state(struct xfrm_sta
 
 	ahp->key = x->aalg->alg_key;
 	ahp->key_len = (x->aalg->alg_key_len+7)/8;
-	ahp->tfm = crypto_alloc_tfm(x->aalg->alg_name, 0);
-	if (!ahp->tfm)
+	tfm = crypto_alloc_hash(x->aalg->alg_name, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
+		goto error;
+
+	ahp->tfm = tfm;
+	if (crypto_hash_setkey(tfm, ahp->key, ahp->key_len))
 		goto error;
-	ahp->icv = ah_hmac_digest;
 	
 	/*
 	 * Lookup the algorithm description maintained by xfrm_algo,
 	 * verify crypto transform properties, and store information
 	 * we need for AH processing.  This lookup cannot fail here
-	 * after a successful crypto_alloc_tfm().
+	 * after a successful crypto_alloc_hash().
 	 */
 	aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
 	BUG_ON(!aalg_desc);
 
 	if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
-	    crypto_tfm_alg_digestsize(ahp->tfm)) {
+	    crypto_hash_digestsize(tfm)) {
 		printk(KERN_INFO "AH: %s digestsize %u != %hu\n",
-		       x->aalg->alg_name, crypto_tfm_alg_digestsize(ahp->tfm),
+		       x->aalg->alg_name, crypto_hash_digestsize(tfm),
 		       aalg_desc->uinfo.auth.icv_fullbits/8);
 		goto error;
 	}
@@ -264,7 +276,7 @@ static int ah_init_state(struct xfrm_sta
 error:
 	if (ahp) {
 		kfree(ahp->work_icv);
-		crypto_free_tfm(ahp->tfm);
+		crypto_free_hash(ahp->tfm);
 		kfree(ahp);
 	}
 	return -EINVAL;
@@ -279,7 +291,7 @@ static void ah_destroy(struct xfrm_state
 
 	kfree(ahp->work_icv);
 	ahp->work_icv = NULL;
-	crypto_free_tfm(ahp->tfm);
+	crypto_free_hash(ahp->tfm);
 	ahp->tfm = NULL;
 	kfree(ahp);
 }
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -121,9 +121,9 @@ static int esp_output(struct xfrm_state 
 	}
 
 	if (esp->auth.icv_full_len) {
-		esp->auth.icv(esp, skb, (u8*)esph-skb->data,
-		              sizeof(struct ip_esp_hdr) + esp->conf.ivlen+clen, trailer->tail);
-		pskb_put(skb, trailer, alen);
+		err = esp_mac_digest(esp, skb, (u8 *)esph - skb->data,
+				     sizeof(*esph) + esp->conf.ivlen + clen);
+		memcpy(pskb_put(skb, trailer, alen), esp->auth.work_icv, alen);
 	}
 
 	ip_send_check(top_iph);
@@ -163,15 +163,16 @@ static int esp_input(struct xfrm_state *
 
 	/* If integrity check is required, do this. */
 	if (esp->auth.icv_full_len) {
-		u8 sum[esp->auth.icv_full_len];
-		u8 sum1[alen];
-		
-		esp->auth.icv(esp, skb, 0, skb->len-alen, sum);
+		u8 sum[alen];
 
-		if (skb_copy_bits(skb, skb->len-alen, sum1, alen))
+		err = esp_mac_digest(esp, skb, 0, skb->len - alen);
+		if (err)
+			goto out;
+
+		if (skb_copy_bits(skb, skb->len - alen, sum, alen))
 			BUG();
 
-		if (unlikely(memcmp(sum, sum1, alen))) {
+		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
 			x->stats.integrity_failed++;
 			goto out;
 		}
@@ -307,7 +308,7 @@ static void esp_destroy(struct xfrm_stat
 	esp->conf.tfm = NULL;
 	kfree(esp->conf.ivec);
 	esp->conf.ivec = NULL;
-	crypto_free_tfm(esp->auth.tfm);
+	crypto_free_hash(esp->auth.tfm);
 	esp->auth.tfm = NULL;
 	kfree(esp->auth.work_icv);
 	esp->auth.work_icv = NULL;
@@ -335,22 +336,27 @@ static int esp_init_state(struct xfrm_st
 
 	if (x->aalg) {
 		struct xfrm_algo_desc *aalg_desc;
+		struct crypto_hash *hash;
 
 		esp->auth.key = x->aalg->alg_key;
 		esp->auth.key_len = (x->aalg->alg_key_len+7)/8;
-		esp->auth.tfm = crypto_alloc_tfm(x->aalg->alg_name, 0);
-		if (esp->auth.tfm == NULL)
+		hash = crypto_alloc_hash(x->aalg->alg_name, 0,
+					 CRYPTO_ALG_ASYNC);
+		if (IS_ERR(hash))
+			goto error;
+
+		esp->auth.tfm = hash;
+		if (crypto_hash_setkey(hash, esp->auth.key, esp->auth.key_len))
 			goto error;
-		esp->auth.icv = esp_hmac_digest;
 
 		aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
 		BUG_ON(!aalg_desc);
 
 		if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
-		    crypto_tfm_alg_digestsize(esp->auth.tfm)) {
+		    crypto_hash_digestsize(hash)) {
 			NETDEBUG(KERN_INFO "ESP: %s digestsize %u != %hu\n",
 				 x->aalg->alg_name,
-				 crypto_tfm_alg_digestsize(esp->auth.tfm),
+				 crypto_hash_digestsize(hash),
 				 aalg_desc->uinfo.auth.icv_fullbits/8);
 			goto error;
 		}
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -213,7 +213,10 @@ static int ah6_output(struct xfrm_state 
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(++x->replay.oseq);
 	xfrm_aevent_doreplay(x);
-	ahp->icv(ahp, skb, ah->auth_data);
+	err = ah_mac_digest(ahp, skb, ah->auth_data);
+	if (err)
+		goto error_free_iph;
+	memcpy(ah->auth_data, ahp->work_icv, ahp->icv_trunc_len);
 
 	err = 0;
 
@@ -251,6 +254,7 @@ static int ah6_input(struct xfrm_state *
 	u16 hdr_len;
 	u16 ah_hlen;
 	int nexthdr;
+	int err = -EINVAL;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_auth_hdr)))
 		goto out;
@@ -292,8 +296,11 @@ static int ah6_input(struct xfrm_state *
 		memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
 		memset(ah->auth_data, 0, ahp->icv_trunc_len);
 		skb_push(skb, hdr_len);
-		ahp->icv(ahp, skb, ah->auth_data);
-		if (memcmp(ah->auth_data, auth_data, ahp->icv_trunc_len)) {
+		err = ah_mac_digest(ahp, skb, ah->auth_data);
+		if (err)
+			goto free_out;
+		err = -EINVAL;
+		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
 			LIMIT_NETDEBUG(KERN_WARNING "ipsec ah authentication error\n");
 			x->stats.integrity_failed++;
 			goto free_out;
@@ -310,7 +317,7 @@ static int ah6_input(struct xfrm_state *
 free_out:
 	kfree(tmp_hdr);
 out:
-	return -EINVAL;
+	return err;
 }
 
 static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt, 
@@ -338,6 +345,7 @@ static int ah6_init_state(struct xfrm_st
 {
 	struct ah_data *ahp = NULL;
 	struct xfrm_algo_desc *aalg_desc;
+	struct crypto_hash *tfm;
 
 	if (!x->aalg)
 		goto error;
@@ -355,24 +363,27 @@ static int ah6_init_state(struct xfrm_st
 
 	ahp->key = x->aalg->alg_key;
 	ahp->key_len = (x->aalg->alg_key_len+7)/8;
-	ahp->tfm = crypto_alloc_tfm(x->aalg->alg_name, 0);
-	if (!ahp->tfm)
+	tfm = crypto_alloc_hash(x->aalg->alg_name, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
+		goto error;
+
+	ahp->tfm = tfm;
+	if (crypto_hash_setkey(tfm, ahp->key, ahp->key_len))
 		goto error;
-	ahp->icv = ah_hmac_digest;
 	
 	/*
 	 * Lookup the algorithm description maintained by xfrm_algo,
 	 * verify crypto transform properties, and store information
 	 * we need for AH processing.  This lookup cannot fail here
-	 * after a successful crypto_alloc_tfm().
+	 * after a successful crypto_alloc_hash().
 	 */
 	aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
 	BUG_ON(!aalg_desc);
 
 	if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
-	    crypto_tfm_alg_digestsize(ahp->tfm)) {
+	    crypto_hash_digestsize(tfm)) {
 		printk(KERN_INFO "AH: %s digestsize %u != %hu\n",
-		       x->aalg->alg_name, crypto_tfm_alg_digestsize(ahp->tfm),
+		       x->aalg->alg_name, crypto_hash_digestsize(tfm),
 		       aalg_desc->uinfo.auth.icv_fullbits/8);
 		goto error;
 	}
@@ -396,7 +407,7 @@ static int ah6_init_state(struct xfrm_st
 error:
 	if (ahp) {
 		kfree(ahp->work_icv);
-		crypto_free_tfm(ahp->tfm);
+		crypto_free_hash(ahp->tfm);
 		kfree(ahp);
 	}
 	return -EINVAL;
@@ -411,7 +422,7 @@ static void ah6_destroy(struct xfrm_stat
 
 	kfree(ahp->work_icv);
 	ahp->work_icv = NULL;
-	crypto_free_tfm(ahp->tfm);
+	crypto_free_hash(ahp->tfm);
 	ahp->tfm = NULL;
 	kfree(ahp);
 }
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -125,9 +125,9 @@ static int esp6_output(struct xfrm_state
 	}
 
 	if (esp->auth.icv_full_len) {
-		esp->auth.icv(esp, skb, (u8*)esph-skb->data,
-			sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen+clen, trailer->tail);
-		pskb_put(skb, trailer, alen);
+		err = esp_mac_digest(esp, skb, (u8 *)esph - skb->data,
+				     sizeof(*esph) + esp->conf.ivlen + clen);
+		memcpy(pskb_put(skb, trailer, alen), esp->auth.work_icv, alen);
 	}
 
 error:
@@ -162,15 +162,16 @@ static int esp6_input(struct xfrm_state 
 
 	/* If integrity check is required, do this. */
         if (esp->auth.icv_full_len) {
-		u8 sum[esp->auth.icv_full_len];
-		u8 sum1[alen];
+		u8 sum[alen];
 
-		esp->auth.icv(esp, skb, 0, skb->len-alen, sum);
+		ret = esp_mac_digest(esp, skb, 0, skb->len - alen);
+		if (ret)
+			goto out;
 
-		if (skb_copy_bits(skb, skb->len-alen, sum1, alen))
+		if (skb_copy_bits(skb, skb->len - alen, sum, alen))
 			BUG();
 
-		if (unlikely(memcmp(sum, sum1, alen))) {
+		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
 			x->stats.integrity_failed++;
 			ret = -EINVAL;
 			goto out;
@@ -279,7 +280,7 @@ static void esp6_destroy(struct xfrm_sta
 	esp->conf.tfm = NULL;
 	kfree(esp->conf.ivec);
 	esp->conf.ivec = NULL;
-	crypto_free_tfm(esp->auth.tfm);
+	crypto_free_hash(esp->auth.tfm);
 	esp->auth.tfm = NULL;
 	kfree(esp->auth.work_icv);
 	esp->auth.work_icv = NULL;
@@ -308,24 +309,29 @@ static int esp6_init_state(struct xfrm_s
 
 	if (x->aalg) {
 		struct xfrm_algo_desc *aalg_desc;
+		struct crypto_hash *hash;
 
 		esp->auth.key = x->aalg->alg_key;
 		esp->auth.key_len = (x->aalg->alg_key_len+7)/8;
-		esp->auth.tfm = crypto_alloc_tfm(x->aalg->alg_name, 0);
-		if (esp->auth.tfm == NULL)
+		hash = crypto_alloc_hash(x->aalg->alg_name, 0,
+					 CRYPTO_ALG_ASYNC);
+		if (IS_ERR(hash))
+			goto error;
+
+		esp->auth.tfm = hash;
+		if (crypto_hash_setkey(hash, esp->auth.key, esp->auth.key_len))
 			goto error;
-		esp->auth.icv = esp_hmac_digest;
  
 		aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
 		BUG_ON(!aalg_desc);
  
 		if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
-			crypto_tfm_alg_digestsize(esp->auth.tfm)) {
-				printk(KERN_INFO "ESP: %s digestsize %u != %hu\n",
-					x->aalg->alg_name,
-					crypto_tfm_alg_digestsize(esp->auth.tfm),
-					aalg_desc->uinfo.auth.icv_fullbits/8);
-				goto error;
+		    crypto_hash_digestsize(hash)) {
+			NETDEBUG(KERN_INFO "ESP: %s digestsize %u != %hu\n",
+				 x->aalg->alg_name,
+				 crypto_hash_digestsize(hash),
+				 aalg_desc->uinfo.auth.icv_fullbits/8);
+			goto error;
 		}
  
 		esp->auth.icv_full_len = aalg_desc->uinfo.auth.icv_fullbits/8;
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -30,7 +30,8 @@
  */
 static struct xfrm_algo_desc aalg_list[] = {
 {
-	.name = "digest_null",
+	.name = "hmac(digest_null)",
+	.compat = "digest_null",
 	
 	.uinfo = {
 		.auth = {
@@ -47,7 +48,8 @@ static struct xfrm_algo_desc aalg_list[]
 	}
 },
 {
-	.name = "md5",
+	.name = "hmac(md5)",
+	.compat = "md5",
 
 	.uinfo = {
 		.auth = {
@@ -64,7 +66,8 @@ static struct xfrm_algo_desc aalg_list[]
 	}
 },
 {
-	.name = "sha1",
+	.name = "hmac(sha1)",
+	.compat = "sha1",
 
 	.uinfo = {
 		.auth = {
@@ -81,7 +84,8 @@ static struct xfrm_algo_desc aalg_list[]
 	}
 },
 {
-	.name = "sha256",
+	.name = "hmac(sha256)",
+	.compat = "sha256",
 
 	.uinfo = {
 		.auth = {
@@ -98,7 +102,8 @@ static struct xfrm_algo_desc aalg_list[]
 	}
 },
 {
-	.name = "ripemd160",
+	.name = "hmac(ripemd160)",
+	.compat = "ripemd160",
 
 	.uinfo = {
 		.auth = {
@@ -480,11 +485,12 @@ EXPORT_SYMBOL_GPL(xfrm_count_enc_support
 
 /* Move to common area: it is shared with AH. */
 
-void skb_icv_walk(const struct sk_buff *skb, struct crypto_tfm *tfm,
-		  int offset, int len, icv_update_fn_t icv_update)
+int skb_icv_walk(const struct sk_buff *skb, struct hash_desc *desc,
+		 int offset, int len, icv_update_fn_t icv_update)
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
+	int err;
 	struct scatterlist sg;
 
 	/* Checksum header. */
@@ -496,10 +502,12 @@ void skb_icv_walk(const struct sk_buff *
 		sg.offset = (unsigned long)(skb->data + offset) % PAGE_SIZE;
 		sg.length = copy;
 		
-		icv_update(tfm, &sg, 1);
+		err = icv_update(desc, &sg, copy);
+		if (unlikely(err))
+			return err;
 		
 		if ((len -= copy) == 0)
-			return;
+			return 0;
 		offset += copy;
 	}
 
@@ -519,10 +527,12 @@ void skb_icv_walk(const struct sk_buff *
 			sg.offset = frag->page_offset + offset-start;
 			sg.length = copy;
 			
-			icv_update(tfm, &sg, 1);
+			err = icv_update(desc, &sg, copy);
+			if (unlikely(err))
+				return err;
 
 			if (!(len -= copy))
-				return;
+				return 0;
 			offset += copy;
 		}
 		start = end;
@@ -540,15 +550,19 @@ void skb_icv_walk(const struct sk_buff *
 			if ((copy = end - offset) > 0) {
 				if (copy > len)
 					copy = len;
-				skb_icv_walk(list, tfm, offset-start, copy, icv_update);
+				err = skb_icv_walk(list, desc, offset-start,
+						   copy, icv_update);
+				if (unlikely(err))
+					return err;
 				if ((len -= copy) == 0)
-					return;
+					return 0;
 				offset += copy;
 			}
 			start = end;
 		}
 	}
 	BUG_ON(len);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(skb_icv_walk);
 
