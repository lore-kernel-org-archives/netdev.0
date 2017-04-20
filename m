From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 11/16] esp: Use a synchronous crypto algorithm on offloading.
Date: Thu, 20 Apr 2017 10:55:10 +0200
Message-ID: <1492678515-14347-12-git-send-email-steffen.klassert@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51652 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S970097AbdDTI5q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:57:46 -0400
In-Reply-To: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need a fallback algorithm for crypto offloading to a NIC.
This is because packets can be rerouted to other NICs that
don't support crypto offloading. The fallback is going to be
implemented at layer2 where we know the final output device
but can't handle asynchronous returns fron the crypto layer.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c | 12 ++++++++++--
 net/ipv6/esp6.c | 12 ++++++++++--
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 4382f30..7e501ad 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -783,13 +783,17 @@ static int esp_init_aead(struct xfrm_state *x)
 	char aead_name[CRYPTO_MAX_ALG_NAME];
 	struct crypto_aead *aead;
 	int err;
+	u32 mask = 0;
 
 	err = -ENAMETOOLONG;
 	if (snprintf(aead_name, CRYPTO_MAX_ALG_NAME, "%s(%s)",
 		     x->geniv, x->aead->alg_name) >= CRYPTO_MAX_ALG_NAME)
 		goto error;
 
-	aead = crypto_alloc_aead(aead_name, 0, 0);
+	if (x->xso.offload_handle)
+		mask |= CRYPTO_ALG_ASYNC;
+
+	aead = crypto_alloc_aead(aead_name, 0, mask);
 	err = PTR_ERR(aead);
 	if (IS_ERR(aead))
 		goto error;
@@ -819,6 +823,7 @@ static int esp_init_authenc(struct xfrm_state *x)
 	char authenc_name[CRYPTO_MAX_ALG_NAME];
 	unsigned int keylen;
 	int err;
+	u32 mask = 0;
 
 	err = -EINVAL;
 	if (!x->ealg)
@@ -844,7 +849,10 @@ static int esp_init_authenc(struct xfrm_state *x)
 			goto error;
 	}
 
-	aead = crypto_alloc_aead(authenc_name, 0, 0);
+	if (x->xso.offload_handle)
+		mask |= CRYPTO_ALG_ASYNC;
+
+	aead = crypto_alloc_aead(authenc_name, 0, mask);
 	err = PTR_ERR(aead);
 	if (IS_ERR(aead))
 		goto error;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 82d3da8..8b55abf 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -704,13 +704,17 @@ static int esp_init_aead(struct xfrm_state *x)
 	char aead_name[CRYPTO_MAX_ALG_NAME];
 	struct crypto_aead *aead;
 	int err;
+	u32 mask = 0;
 
 	err = -ENAMETOOLONG;
 	if (snprintf(aead_name, CRYPTO_MAX_ALG_NAME, "%s(%s)",
 		     x->geniv, x->aead->alg_name) >= CRYPTO_MAX_ALG_NAME)
 		goto error;
 
-	aead = crypto_alloc_aead(aead_name, 0, 0);
+	if (x->xso.offload_handle)
+		mask |= CRYPTO_ALG_ASYNC;
+
+	aead = crypto_alloc_aead(aead_name, 0, mask);
 	err = PTR_ERR(aead);
 	if (IS_ERR(aead))
 		goto error;
@@ -740,6 +744,7 @@ static int esp_init_authenc(struct xfrm_state *x)
 	char authenc_name[CRYPTO_MAX_ALG_NAME];
 	unsigned int keylen;
 	int err;
+	u32 mask = 0;
 
 	err = -EINVAL;
 	if (!x->ealg)
@@ -765,7 +770,10 @@ static int esp_init_authenc(struct xfrm_state *x)
 			goto error;
 	}
 
-	aead = crypto_alloc_aead(authenc_name, 0, 0);
+	if (x->xso.offload_handle)
+		mask |= CRYPTO_ALG_ASYNC;
+
+	aead = crypto_alloc_aead(authenc_name, 0, mask);
 	err = PTR_ERR(aead);
 	if (IS_ERR(aead))
 		goto error;
-- 
2.7.4
