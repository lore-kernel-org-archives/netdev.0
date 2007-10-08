From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/7] [IPSEC] esp: Remove keys from esp_data structure
Date: Mon, 08 Oct 2007 19:29:37 +0800
Message-ID: <E1Ieqnp-0000nz-00@gondolin.me.apana.org.au>
References: <20071008112818.GA3010@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1724 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752818AbXJHL3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 07:29:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC] esp: Remove keys from esp_data structure

The keys are only used during initialisation so we don't need to carry them
in esp_data.  Since we don't have to allocate them again, there is no need
to place a limit on the authentication key length anymore.

This patch also kills the unused auth.icv member.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/esp.h |    7 -------
 net/ipv4/esp4.c   |   16 +++++-----------
 net/ipv6/esp6.c   |   15 ++++-----------
 3 files changed, 9 insertions(+), 29 deletions(-)

diff --git a/include/net/esp.h b/include/net/esp.h
index d05d8d2..e793d76 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -13,8 +13,6 @@ struct esp_data
 
 	/* Confidentiality */
 	struct {
-		u8			*key;		/* Key */
-		int			key_len;	/* Key length */
 		int			padlen;		/* 0..255 */
 		/* ivlen is offset from enc_data, where encrypted data start.
 		 * It is logically different of crypto_tfm_alg_ivsize(tfm).
@@ -28,14 +26,9 @@ struct esp_data
 
 	/* Integrity. It is active when icv_full_len != 0 */
 	struct {
-		u8			*key;		/* Key */
-		int			key_len;	/* Length of the key */
 		u8			*work_icv;
 		int			icv_full_len;
 		int			icv_trunc_len;
-		void			(*icv)(struct esp_data*,
-		                               struct sk_buff *skb,
-		                               int offset, int len, u8 *icv);
 		struct crypto_hash	*tfm;
 	} auth;
 };
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 98767a4..d233e2e 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -343,11 +343,6 @@ static int esp_init_state(struct xfrm_state *x)
 	struct crypto_blkcipher *tfm;
 	u32 align;
 
-	/* null auth and encryption can have zero length keys */
-	if (x->aalg) {
-		if (x->aalg->alg_key_len > 512)
-			goto error;
-	}
 	if (x->ealg == NULL)
 		goto error;
 
@@ -359,15 +354,14 @@ static int esp_init_state(struct xfrm_state *x)
 		struct xfrm_algo_desc *aalg_desc;
 		struct crypto_hash *hash;
 
-		esp->auth.key = x->aalg->alg_key;
-		esp->auth.key_len = (x->aalg->alg_key_len+7)/8;
 		hash = crypto_alloc_hash(x->aalg->alg_name, 0,
 					 CRYPTO_ALG_ASYNC);
 		if (IS_ERR(hash))
 			goto error;
 
 		esp->auth.tfm = hash;
-		if (crypto_hash_setkey(hash, esp->auth.key, esp->auth.key_len))
+		if (crypto_hash_setkey(hash, x->aalg->alg_key,
+				       (x->aalg->alg_key_len + 7) / 8))
 			goto error;
 
 		aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
@@ -389,8 +383,7 @@ static int esp_init_state(struct xfrm_state *x)
 		if (!esp->auth.work_icv)
 			goto error;
 	}
-	esp->conf.key = x->ealg->alg_key;
-	esp->conf.key_len = (x->ealg->alg_key_len+7)/8;
+
 	tfm = crypto_alloc_blkcipher(x->ealg->alg_name, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm))
 		goto error;
@@ -403,7 +396,8 @@ static int esp_init_state(struct xfrm_state *x)
 			goto error;
 		esp->conf.ivinitted = 0;
 	}
-	if (crypto_blkcipher_setkey(tfm, esp->conf.key, esp->conf.key_len))
+	if (crypto_blkcipher_setkey(tfm, x->ealg->alg_key,
+				    (x->ealg->alg_key_len + 7) / 8))
 		goto error;
 	x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
 	if (x->props.mode == XFRM_MODE_TUNNEL)
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 2db31ce..7728106 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -297,11 +297,6 @@ static int esp6_init_state(struct xfrm_state *x)
 	struct esp_data *esp = NULL;
 	struct crypto_blkcipher *tfm;
 
-	/* null auth and encryption can have zero length keys */
-	if (x->aalg) {
-		if (x->aalg->alg_key_len > 512)
-			goto error;
-	}
 	if (x->ealg == NULL)
 		goto error;
 
@@ -316,15 +311,14 @@ static int esp6_init_state(struct xfrm_state *x)
 		struct xfrm_algo_desc *aalg_desc;
 		struct crypto_hash *hash;
 
-		esp->auth.key = x->aalg->alg_key;
-		esp->auth.key_len = (x->aalg->alg_key_len+7)/8;
 		hash = crypto_alloc_hash(x->aalg->alg_name, 0,
 					 CRYPTO_ALG_ASYNC);
 		if (IS_ERR(hash))
 			goto error;
 
 		esp->auth.tfm = hash;
-		if (crypto_hash_setkey(hash, esp->auth.key, esp->auth.key_len))
+		if (crypto_hash_setkey(hash, x->aalg->alg_key,
+				       (x->aalg->alg_key_len + 7) / 8))
 			goto error;
 
 		aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
@@ -346,8 +340,6 @@ static int esp6_init_state(struct xfrm_state *x)
 		if (!esp->auth.work_icv)
 			goto error;
 	}
-	esp->conf.key = x->ealg->alg_key;
-	esp->conf.key_len = (x->ealg->alg_key_len+7)/8;
 	tfm = crypto_alloc_blkcipher(x->ealg->alg_name, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm))
 		goto error;
@@ -360,7 +352,8 @@ static int esp6_init_state(struct xfrm_state *x)
 			goto error;
 		esp->conf.ivinitted = 0;
 	}
-	if (crypto_blkcipher_setkey(tfm, esp->conf.key, esp->conf.key_len))
+	if (crypto_blkcipher_setkey(tfm, x->ealg->alg_key,
+				    (x->ealg->alg_key_len + 7) / 8))
 		goto error;
 	x->props.header_len = sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
 	if (x->props.mode == XFRM_MODE_TUNNEL)
