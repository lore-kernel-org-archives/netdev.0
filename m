From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH] crypto: ccm - avoid scatterlist for MAC encryption
Date: Sat, 15 Oct 2016 18:16:16 +0100
Message-ID: <1476551776-8099-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: johannes@sipsolutions.net, luto@amacapital.net,
        sergey.senozhatsky.work@gmail.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, davem@davemloft.net,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        j@w1.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CCM code goes out of its way to perform the CTR encryption of the MAC
using the subordinate CTR driver. To this end, it tweaks the input and
output scatterlists so the aead_req 'odata' and/or 'auth_tag' fields [which
may live on the stack] are prepended to the CTR payload. This involves
calling sg_set_buf() on addresses which are not direct mapped, which is
not supported.

Since the calculation of the MAC keystream involves a single call into
the cipher, to which we have a handle already given that the CBC-MAC
calculation uses it as well, just calculate the MAC keystream directly,
and record it in the aead_req private context so we can apply it to the
MAC in cypto_ccm_auth_mac(). This greatly simplifies the scatterlist
manipulation, and no longer requires scatterlists to refer to buffers
that may live on the stack.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---

This is an alternative for the patch 'mac80211: aes_ccm: move struct
aead_req off the stack' that I sent out yesterday. IMO, this is a more
correct approach, since it addresses the problem directly in crypto/ccm.c,
which is the only CCM-AES driver that suffers from this issue.

 crypto/ccm.c | 55 +++++++++++---------
 1 file changed, 29 insertions(+), 26 deletions(-)

diff --git a/crypto/ccm.c b/crypto/ccm.c
index 006d8575ef5c..faa5efcf59e2 100644
--- a/crypto/ccm.c
+++ b/crypto/ccm.c
@@ -46,10 +46,13 @@ struct crypto_ccm_req_priv_ctx {
 	u8 odata[16];
 	u8 idata[16];
 	u8 auth_tag[16];
+	u8 cmac[16];
 	u32 ilen;
 	u32 flags;
-	struct scatterlist src[3];
-	struct scatterlist dst[3];
+	struct scatterlist *src;
+	struct scatterlist *dst;
+	struct scatterlist srcbuf[2];
+	struct scatterlist dstbuf[2];
 	struct skcipher_request skreq;
 };
 
@@ -280,6 +283,8 @@ static int crypto_ccm_auth(struct aead_request *req, struct scatterlist *plain,
 	if (cryptlen)
 		get_data_to_compute(cipher, pctx, plain, cryptlen);
 
+	crypto_xor(odata, pctx->cmac, 16);
+
 out:
 	return err;
 }
@@ -307,10 +312,12 @@ static inline int crypto_ccm_check_iv(const u8 *iv)
 	return 0;
 }
 
-static int crypto_ccm_init_crypt(struct aead_request *req, u8 *tag)
+static int crypto_ccm_init_crypt(struct aead_request *req)
 {
+	struct crypto_aead *aead = crypto_aead_reqtfm(req);
+	struct crypto_ccm_ctx *ctx = crypto_aead_ctx(aead);
 	struct crypto_ccm_req_priv_ctx *pctx = crypto_ccm_reqctx(req);
-	struct scatterlist *sg;
+	struct crypto_cipher *cipher = ctx->cipher;
 	u8 *iv = req->iv;
 	int err;
 
@@ -325,19 +332,16 @@ static int crypto_ccm_init_crypt(struct aead_request *req, u8 *tag)
 	 */
 	memset(iv + 15 - iv[0], 0, iv[0] + 1);
 
-	sg_init_table(pctx->src, 3);
-	sg_set_buf(pctx->src, tag, 16);
-	sg = scatterwalk_ffwd(pctx->src + 1, req->src, req->assoclen);
-	if (sg != pctx->src + 1)
-		sg_chain(pctx->src, 2, sg);
+	/* prepare the key stream for the auth tag  */
+	crypto_cipher_encrypt_one(cipher, pctx->cmac, iv);
 
-	if (req->src != req->dst) {
-		sg_init_table(pctx->dst, 3);
-		sg_set_buf(pctx->dst, tag, 16);
-		sg = scatterwalk_ffwd(pctx->dst + 1, req->dst, req->assoclen);
-		if (sg != pctx->dst + 1)
-			sg_chain(pctx->dst, 2, sg);
-	}
+	/* increment BE counter in IV[] for the actual payload */
+	iv[15] = 1;
+
+	pctx->src = scatterwalk_ffwd(pctx->srcbuf, req->src, req->assoclen);
+	if (req->src != req->dst)
+		pctx->dst = scatterwalk_ffwd(pctx->dstbuf, req->dst,
+					     req->assoclen);
 
 	return 0;
 }
@@ -354,11 +358,11 @@ static int crypto_ccm_encrypt(struct aead_request *req)
 	u8 *iv = req->iv;
 	int err;
 
-	err = crypto_ccm_init_crypt(req, odata);
+	err = crypto_ccm_init_crypt(req);
 	if (err)
 		return err;
 
-	err = crypto_ccm_auth(req, sg_next(pctx->src), cryptlen);
+	err = crypto_ccm_auth(req, pctx->src, cryptlen);
 	if (err)
 		return err;
 
@@ -369,13 +373,13 @@ static int crypto_ccm_encrypt(struct aead_request *req)
 	skcipher_request_set_tfm(skreq, ctx->ctr);
 	skcipher_request_set_callback(skreq, pctx->flags,
 				      crypto_ccm_encrypt_done, req);
-	skcipher_request_set_crypt(skreq, pctx->src, dst, cryptlen + 16, iv);
+	skcipher_request_set_crypt(skreq, pctx->src, dst, cryptlen, iv);
 	err = crypto_skcipher_encrypt(skreq);
 	if (err)
 		return err;
 
 	/* copy authtag to end of dst */
-	scatterwalk_map_and_copy(odata, sg_next(dst), cryptlen,
+	scatterwalk_map_and_copy(odata, dst, cryptlen,
 				 crypto_aead_authsize(aead), 1);
 	return err;
 }
@@ -392,7 +396,7 @@ static void crypto_ccm_decrypt_done(struct crypto_async_request *areq,
 
 	pctx->flags = 0;
 
-	dst = sg_next(req->src == req->dst ? pctx->src : pctx->dst);
+	dst = req->src == req->dst ? pctx->src : pctx->dst;
 
 	if (!err) {
 		err = crypto_ccm_auth(req, dst, cryptlen);
@@ -418,12 +422,11 @@ static int crypto_ccm_decrypt(struct aead_request *req)
 
 	cryptlen -= authsize;
 
-	err = crypto_ccm_init_crypt(req, authtag);
+	err = crypto_ccm_init_crypt(req);
 	if (err)
 		return err;
 
-	scatterwalk_map_and_copy(authtag, sg_next(pctx->src), cryptlen,
-				 authsize, 0);
+	scatterwalk_map_and_copy(authtag, pctx->src, cryptlen, authsize, 0);
 
 	dst = pctx->src;
 	if (req->src != req->dst)
@@ -432,12 +435,12 @@ static int crypto_ccm_decrypt(struct aead_request *req)
 	skcipher_request_set_tfm(skreq, ctx->ctr);
 	skcipher_request_set_callback(skreq, pctx->flags,
 				      crypto_ccm_decrypt_done, req);
-	skcipher_request_set_crypt(skreq, pctx->src, dst, cryptlen + 16, iv);
+	skcipher_request_set_crypt(skreq, pctx->src, dst, cryptlen, iv);
 	err = crypto_skcipher_decrypt(skreq);
 	if (err)
 		return err;
 
-	err = crypto_ccm_auth(req, sg_next(dst), cryptlen);
+	err = crypto_ccm_auth(req, dst, cryptlen);
 	if (err)
 		return err;
 
-- 
2.7.4
