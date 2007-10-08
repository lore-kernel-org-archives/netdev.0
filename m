From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/7] [IPSEC] ah: Remove keys from ah_data structure
Date: Mon, 08 Oct 2007 19:29:38 +0800
Message-ID: <E1Ieqnq-0000o3-00@gondolin.me.apana.org.au>
References: <20071008112818.GA3010@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1728 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752506AbXJHL3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 07:29:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC] ah: Remove keys from ah_data structure

The keys are only used during initialisation so we don't need to carry them
in esp_data.  Since we don't have to allocate them again, there is no need
to place a limit on the authentication key length anymore.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/ah.h |    2 --
 net/ipv4/ah4.c   |    9 ++-------
 net/ipv6/ah6.c   |    9 ++-------
 3 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/include/net/ah.h b/include/net/ah.h
index 8f257c1..5e758c2 100644
--- a/include/net/ah.h
+++ b/include/net/ah.h
@@ -9,8 +9,6 @@
 
 struct ah_data
 {
-	u8			*key;
-	int			key_len;
 	u8			*work_icv;
 	int			icv_full_len;
 	int			icv_trunc_len;
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 39f6211..dc1d8e8 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -219,10 +219,6 @@ static int ah_init_state(struct xfrm_state *x)
 	if (!x->aalg)
 		goto error;
 
-	/* null auth can use a zero length key */
-	if (x->aalg->alg_key_len > 512)
-		goto error;
-
 	if (x->encap)
 		goto error;
 
@@ -230,14 +226,13 @@ static int ah_init_state(struct xfrm_state *x)
 	if (ahp == NULL)
 		return -ENOMEM;
 
-	ahp->key = x->aalg->alg_key;
-	ahp->key_len = (x->aalg->alg_key_len+7)/8;
 	tfm = crypto_alloc_hash(x->aalg->alg_name, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm))
 		goto error;
 
 	ahp->tfm = tfm;
-	if (crypto_hash_setkey(tfm, ahp->key, ahp->key_len))
+	if (crypto_hash_setkey(tfm, x->aalg->alg_key,
+			       (x->aalg->alg_key_len + 7) / 8))
 		goto error;
 
 	/*
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 53f46ab..69a2030 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -429,10 +429,6 @@ static int ah6_init_state(struct xfrm_state *x)
 	if (!x->aalg)
 		goto error;
 
-	/* null auth can use a zero length key */
-	if (x->aalg->alg_key_len > 512)
-		goto error;
-
 	if (x->encap)
 		goto error;
 
@@ -440,14 +436,13 @@ static int ah6_init_state(struct xfrm_state *x)
 	if (ahp == NULL)
 		return -ENOMEM;
 
-	ahp->key = x->aalg->alg_key;
-	ahp->key_len = (x->aalg->alg_key_len+7)/8;
 	tfm = crypto_alloc_hash(x->aalg->alg_name, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm))
 		goto error;
 
 	ahp->tfm = tfm;
-	if (crypto_hash_setkey(tfm, ahp->key, ahp->key_len))
+	if (crypto_hash_setkey(tfm, x->aalg->alg_key,
+			       (x->aalg->alg_key_len + 7) / 8))
 		goto error;
 
 	/*
