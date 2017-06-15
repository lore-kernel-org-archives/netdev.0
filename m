From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 2/9] crypto: chcr - Fix fallback key setting
Date: Thu, 15 Jun 2017 12:43:40 +0530
Message-ID: <96ec20d1b920195aa9b6cc6d5956e4be0b9daa2d.1497506936.git.harsh@chelsio.com>
References: <cover.1497506936.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org, ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:6814 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750859AbdFOHOB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 03:14:01 -0400
In-Reply-To: <cover.1497506936.git.harsh@chelsio.com>
In-Reply-To: <cover.1497506936.git.harsh@chelsio.com>
References: <cover.1497506936.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set key of fallback tfm for rfc4309.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index e8ff505..14641c6 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -2210,7 +2210,8 @@ static int chcr_aead_rfc4309_setkey(struct crypto_aead *aead, const u8 *key,
 				    unsigned int keylen)
 {
 	struct chcr_context *ctx = crypto_aead_ctx(aead);
-	 struct chcr_aead_ctx *aeadctx = AEAD_CTX(ctx);
+	struct chcr_aead_ctx *aeadctx = AEAD_CTX(ctx);
+	int error;
 
 	if (keylen < 3) {
 		crypto_tfm_set_flags((struct crypto_tfm *)aead,
@@ -2218,6 +2219,15 @@ static int chcr_aead_rfc4309_setkey(struct crypto_aead *aead, const u8 *key,
 		aeadctx->enckey_len = 0;
 		return	-EINVAL;
 	}
+	crypto_aead_clear_flags(aeadctx->sw_cipher, CRYPTO_TFM_REQ_MASK);
+	crypto_aead_set_flags(aeadctx->sw_cipher, crypto_aead_get_flags(aead) &
+			      CRYPTO_TFM_REQ_MASK);
+	error = crypto_aead_setkey(aeadctx->sw_cipher, key, keylen);
+	crypto_aead_clear_flags(aead, CRYPTO_TFM_RES_MASK);
+	crypto_aead_set_flags(aead, crypto_aead_get_flags(aeadctx->sw_cipher) &
+			      CRYPTO_TFM_RES_MASK);
+	if (error)
+		return error;
 	keylen -= 3;
 	memcpy(aeadctx->salt, key + keylen, 3);
 	return chcr_ccm_common_setkey(aead, key, keylen);
-- 
1.8.3.1
