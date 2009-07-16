From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 2/7] crypto: authenc - convert to ahash
Date: Thu, 16 Jul 2009 13:17:47 +0200
Message-ID: <20090716111747.GR20288@secunet.com>
References: <20090716111548.GP20288@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090716111548.GP20288@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch converts authenc to the new ahash interface.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 crypto/authenc.c |  215 +++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 150 insertions(+), 65 deletions(-)

diff --git a/crypto/authenc.c b/crypto/authenc.c
index 2e16ce0..bd456e3 100644
--- a/crypto/authenc.c
+++ b/crypto/authenc.c
@@ -24,23 +24,29 @@
 #include <linux/spinlock.h>
 
 struct authenc_instance_ctx {
-	struct crypto_spawn auth;
+	struct crypto_ahash_spawn auth;
 	struct crypto_skcipher_spawn enc;
 };
 
 struct crypto_authenc_ctx {
-	spinlock_t auth_lock;
-	struct crypto_hash *auth;
+	unsigned int reqoff;
+	struct crypto_ahash *auth;
 	struct crypto_ablkcipher *enc;
 };
 
+struct authenc_ahash_request_ctx {
+	struct scatterlist sg[2];
+	crypto_completion_t complete;
+	char tail[];
+};
+
 static int crypto_authenc_setkey(struct crypto_aead *authenc, const u8 *key,
 				 unsigned int keylen)
 {
 	unsigned int authkeylen;
 	unsigned int enckeylen;
 	struct crypto_authenc_ctx *ctx = crypto_aead_ctx(authenc);
-	struct crypto_hash *auth = ctx->auth;
+	struct crypto_ahash *auth = ctx->auth;
 	struct crypto_ablkcipher *enc = ctx->enc;
 	struct rtattr *rta = (void *)key;
 	struct crypto_authenc_key_param *param;
@@ -64,11 +70,11 @@ static int crypto_authenc_setkey(struct crypto_aead *authenc, const u8 *key,
 
 	authkeylen = keylen - enckeylen;
 
-	crypto_hash_clear_flags(auth, CRYPTO_TFM_REQ_MASK);
-	crypto_hash_set_flags(auth, crypto_aead_get_flags(authenc) &
+	crypto_ahash_clear_flags(auth, CRYPTO_TFM_REQ_MASK);
+	crypto_ahash_set_flags(auth, crypto_aead_get_flags(authenc) &
 				    CRYPTO_TFM_REQ_MASK);
-	err = crypto_hash_setkey(auth, key, authkeylen);
-	crypto_aead_set_flags(authenc, crypto_hash_get_flags(auth) &
+	err = crypto_ahash_setkey(auth, key, authkeylen);
+	crypto_aead_set_flags(authenc, crypto_ahash_get_flags(auth) &
 				       CRYPTO_TFM_RES_MASK);
 
 	if (err)
@@ -92,6 +98,13 @@ badkey:
 static void authenc_chain(struct scatterlist *head, struct scatterlist *sg,
 			  int chain)
 {
+	/* 
+	 * head must be a scatterlist with two entries.
+	 * We remove a potentially set termination bit
+	 * on the first enty.
+	 */
+	head->page_link &= ~0x02;
+
 	if (chain) {
 		head->length += sg->length;
 		sg = scatterwalk_sg_next(sg);
@@ -103,40 +116,85 @@ static void authenc_chain(struct scatterlist *head, struct scatterlist *sg,
 		sg_mark_end(head);
 }
 
-static u8 *crypto_authenc_hash(struct aead_request *req, unsigned int flags,
-			       struct scatterlist *cipher,
-			       unsigned int cryptlen)
+static void crypto_authenc_ahash_geniv_done(
+			struct crypto_async_request *areq, int err)
 {
+	struct aead_request *req = areq->data;
 	struct crypto_aead *authenc = crypto_aead_reqtfm(req);
 	struct crypto_authenc_ctx *ctx = crypto_aead_ctx(authenc);
-	struct crypto_hash *auth = ctx->auth;
-	struct hash_desc desc = {
-		.tfm = auth,
-		.flags = aead_request_flags(req) & flags,
-	};
-	u8 *hash = aead_request_ctx(req);
-	int err;
-
-	hash = (u8 *)ALIGN((unsigned long)hash + crypto_hash_alignmask(auth), 
-			   crypto_hash_alignmask(auth) + 1);
+	struct authenc_ahash_request_ctx *ahreq_ctx = aead_request_ctx(req);
+	struct ahash_request *ahreq = (void *)(ahreq_ctx->tail + ctx->reqoff);
 
-	spin_lock_bh(&ctx->auth_lock);
-	err = crypto_hash_init(&desc);
 	if (err)
-		goto auth_unlock;
+		goto out;
+
+	scatterwalk_map_and_copy(ahreq->result, ahreq->src, ahreq->nbytes,
+				 crypto_aead_authsize(authenc), 1);
+
+out:
+	aead_request_complete(req, err);
+}
+
+static void crypto_authenc_ahash_verify_done(
+			struct crypto_async_request *areq, int err)
+{
+	u8 *ihash;
+	unsigned int authsize;
+	struct ablkcipher_request *abreq;
+	struct aead_request *req = areq->data;
+	struct crypto_aead *authenc = crypto_aead_reqtfm(req);
+	struct crypto_authenc_ctx *ctx = crypto_aead_ctx(authenc);
+	struct authenc_ahash_request_ctx *ahreq_ctx = aead_request_ctx(req);
+	struct ahash_request *ahreq = (void *)(ahreq_ctx->tail + ctx->reqoff);
 
-	err = crypto_hash_update(&desc, req->assoc, req->assoclen);
 	if (err)
-		goto auth_unlock;
+		goto out;
+
+	authsize = crypto_aead_authsize(authenc);
+	ihash = ahreq->result + authsize;
+	scatterwalk_map_and_copy(ihash, ahreq->src, ahreq->nbytes, authsize, 0);
+	err = memcmp(ihash, ahreq->result, authsize) ? -EBADMSG: 0;
 
-	err = crypto_hash_update(&desc, cipher, cryptlen);
 	if (err)
-		goto auth_unlock;
+		goto out;
 
-	err = crypto_hash_final(&desc, hash);
-auth_unlock:
-	spin_unlock_bh(&ctx->auth_lock);
+	abreq = aead_request_ctx(req);
+	ablkcipher_request_set_tfm(abreq, ctx->enc);
+	ablkcipher_request_set_callback(abreq, aead_request_flags(req),
+					req->base.complete, req->base.data);
+	ablkcipher_request_set_crypt(abreq, req->src, req->dst,
+						req->cryptlen, req->iv);
+
+	err = crypto_ablkcipher_decrypt(abreq);
+
+	if (err == -EINPROGRESS)
+		return;
+
+out:
+	aead_request_complete(req, err);
+}
+
+static u8 *crypto_authenc_ahash(struct aead_request *req, unsigned int flags,
+			       struct scatterlist *cipher,
+			       unsigned int cryptlen)
+{
+	struct crypto_aead *authenc = crypto_aead_reqtfm(req);
+	struct crypto_authenc_ctx *ctx = crypto_aead_ctx(authenc);
+	struct crypto_ahash *auth = ctx->auth;
+	struct authenc_ahash_request_ctx *ahreq_ctx = aead_request_ctx(req);
+	struct ahash_request *ahreq = (void *)(ahreq_ctx->tail + ctx->reqoff);
+	u8 *hash = ahreq_ctx->tail;
+	int err;
+
+	hash = (u8 *)ALIGN((unsigned long)hash + crypto_ahash_alignmask(auth),
+			   crypto_ahash_alignmask(auth) + 1);
+
+	ahash_request_set_tfm(ahreq, auth);
+	ahash_request_set_crypt(ahreq, cipher, hash, cryptlen);
+	ahash_request_set_callback(ahreq, aead_request_flags(req) & flags,
+				   ahreq_ctx->complete, req);
 
+	err = crypto_ahash_digest(ahreq);
 	if (err)
 		return ERR_PTR(err);
 
@@ -147,8 +205,9 @@ static int crypto_authenc_genicv(struct aead_request *req, u8 *iv,
 				 unsigned int flags)
 {
 	struct crypto_aead *authenc = crypto_aead_reqtfm(req);
+	struct authenc_ahash_request_ctx *ahreq_ctx = aead_request_ctx(req);
 	struct scatterlist *dst = req->dst;
-	struct scatterlist cipher[2];
+	struct scatterlist *cipher = ahreq_ctx->sg;
 	struct page *dstp;
 	unsigned int ivsize = crypto_aead_ivsize(authenc);
 	unsigned int cryptlen;
@@ -165,8 +224,13 @@ static int crypto_authenc_genicv(struct aead_request *req, u8 *iv,
 		dst = cipher;
 	}
 
-	cryptlen = req->cryptlen + ivsize;
-	hash = crypto_authenc_hash(req, flags, dst, cryptlen);
+	authenc_chain(req->assoc, dst, 0);
+	dst = req->assoc;
+
+	cryptlen = req->cryptlen + ivsize + req->assoclen;
+	ahreq_ctx->complete = crypto_authenc_ahash_geniv_done;
+
+	hash = crypto_authenc_ahash(req, flags, dst, cryptlen);
 	if (IS_ERR(hash))
 		return PTR_ERR(hash);
 
@@ -188,6 +252,9 @@ static void crypto_authenc_encrypt_done(struct crypto_async_request *req,
 			 crypto_ablkcipher_reqsize(ctx->enc);
 
 		err = crypto_authenc_genicv(areq, iv, 0);
+
+		if (err == -EINPROGRESS)
+			return;
 	}
 
 	aead_request_complete(areq, err);
@@ -227,6 +294,9 @@ static void crypto_authenc_givencrypt_done(struct crypto_async_request *req,
 		struct skcipher_givcrypt_request *greq = aead_request_ctx(areq);
 
 		err = crypto_authenc_genicv(areq, greq->giv, 0);
+
+		if (err == -EINPROGRESS)
+			return;
 	}
 
 	aead_request_complete(areq, err);
@@ -260,12 +330,15 @@ static int crypto_authenc_verify(struct aead_request *req,
 				 unsigned int cryptlen)
 {
 	struct crypto_aead *authenc = crypto_aead_reqtfm(req);
+	struct authenc_ahash_request_ctx *ahreq_ctx = aead_request_ctx(req);
 	u8 *ohash;
 	u8 *ihash;
 	unsigned int authsize;
 
-	ohash = crypto_authenc_hash(req, CRYPTO_TFM_REQ_MAY_SLEEP, cipher,
-				    cryptlen);
+	ahreq_ctx->complete = crypto_authenc_ahash_verify_done;
+
+	ohash = crypto_authenc_ahash(req, CRYPTO_TFM_REQ_MAY_SLEEP, cipher,
+				     cryptlen);
 	if (IS_ERR(ohash))
 		return PTR_ERR(ohash);
 
@@ -279,8 +352,9 @@ static int crypto_authenc_iverify(struct aead_request *req, u8 *iv,
 				  unsigned int cryptlen)
 {
 	struct crypto_aead *authenc = crypto_aead_reqtfm(req);
+	struct authenc_ahash_request_ctx *ahreq_ctx = aead_request_ctx(req);
 	struct scatterlist *src = req->src;
-	struct scatterlist cipher[2];
+	struct scatterlist *cipher = ahreq_ctx->sg;
 	struct page *srcp;
 	unsigned int ivsize = crypto_aead_ivsize(authenc);
 	u8 *vsrc;
@@ -295,7 +369,11 @@ static int crypto_authenc_iverify(struct aead_request *req, u8 *iv,
 		src = cipher;
 	}
 
-	return crypto_authenc_verify(req, src, cryptlen + ivsize);
+	authenc_chain(req->assoc, src, 0);
+	src = req->assoc;
+
+	cryptlen += ivsize + req->assoclen;
+	return crypto_authenc_verify(req, src, cryptlen);
 }
 
 static int crypto_authenc_decrypt(struct aead_request *req)
@@ -326,38 +404,41 @@ static int crypto_authenc_decrypt(struct aead_request *req)
 
 static int crypto_authenc_init_tfm(struct crypto_tfm *tfm)
 {
-	struct crypto_instance *inst = (void *)tfm->__crt_alg;
+	struct crypto_instance *inst = crypto_tfm_alg_instance(tfm);
 	struct authenc_instance_ctx *ictx = crypto_instance_ctx(inst);
 	struct crypto_authenc_ctx *ctx = crypto_tfm_ctx(tfm);
-	struct crypto_hash *auth;
+	struct crypto_ahash *auth;
 	struct crypto_ablkcipher *enc;
 	int err;
 
-	auth = crypto_spawn_hash(&ictx->auth);
+	auth = crypto_spawn_ahash(&ictx->auth);
 	if (IS_ERR(auth))
 		return PTR_ERR(auth);
 
+	ctx->reqoff = ALIGN(2 * crypto_ahash_digestsize(auth) +
+			    crypto_ahash_alignmask(auth),
+			    crypto_ahash_alignmask(auth) + 1);
+
 	enc = crypto_spawn_skcipher(&ictx->enc);
 	err = PTR_ERR(enc);
 	if (IS_ERR(enc))
-		goto err_free_hash;
+		goto err_free_ahash;
 
 	ctx->auth = auth;
 	ctx->enc = enc;
+	
 	tfm->crt_aead.reqsize = max_t(unsigned int,
-				      (crypto_hash_alignmask(auth) &
-				       ~(crypto_tfm_ctx_alignment() - 1)) +
-				      crypto_hash_digestsize(auth) * 2,
-				      sizeof(struct skcipher_givcrypt_request) +
-				      crypto_ablkcipher_reqsize(enc) +
-				      crypto_ablkcipher_ivsize(enc));
-
-	spin_lock_init(&ctx->auth_lock);
+				crypto_ahash_reqsize(auth) + ctx->reqoff +
+				sizeof(struct authenc_ahash_request_ctx) +
+				sizeof(struct ahash_request), 
+				sizeof(struct skcipher_givcrypt_request) +
+				crypto_ablkcipher_reqsize(enc) +
+				crypto_ablkcipher_ivsize(enc));
 
 	return 0;
 
-err_free_hash:
-	crypto_free_hash(auth);
+err_free_ahash:
+	crypto_free_ahash(auth);
 	return err;
 }
 
@@ -365,7 +446,7 @@ static void crypto_authenc_exit_tfm(struct crypto_tfm *tfm)
 {
 	struct crypto_authenc_ctx *ctx = crypto_tfm_ctx(tfm);
 
-	crypto_free_hash(ctx->auth);
+	crypto_free_ahash(ctx->auth);
 	crypto_free_ablkcipher(ctx->enc);
 }
 
@@ -373,7 +454,8 @@ static struct crypto_instance *crypto_authenc_alloc(struct rtattr **tb)
 {
 	struct crypto_attr_type *algt;
 	struct crypto_instance *inst;
-	struct crypto_alg *auth;
+	struct hash_alg_common *auth;
+	struct crypto_alg *auth_base;
 	struct crypto_alg *enc;
 	struct authenc_instance_ctx *ctx;
 	const char *enc_name;
@@ -387,11 +469,13 @@ static struct crypto_instance *crypto_authenc_alloc(struct rtattr **tb)
 	if ((algt->type ^ CRYPTO_ALG_TYPE_AEAD) & algt->mask)
 		return ERR_PTR(-EINVAL);
 
-	auth = crypto_attr_alg(tb[1], CRYPTO_ALG_TYPE_HASH,
-			       CRYPTO_ALG_TYPE_HASH_MASK);
+	auth = ahash_attr_alg(tb[1], CRYPTO_ALG_TYPE_HASH,
+			       CRYPTO_ALG_TYPE_AHASH_MASK);
 	if (IS_ERR(auth))
 		return ERR_PTR(PTR_ERR(auth));
 
+	auth_base = &auth->base;
+
 	enc_name = crypto_attr_alg_name(tb[2]);
 	err = PTR_ERR(enc_name);
 	if (IS_ERR(enc_name))
@@ -404,7 +488,7 @@ static struct crypto_instance *crypto_authenc_alloc(struct rtattr **tb)
 
 	ctx = crypto_instance_ctx(inst);
 
-	err = crypto_init_spawn(&ctx->auth, auth, inst, CRYPTO_ALG_TYPE_MASK);
+	err = crypto_init_ahash_spawn(&ctx->auth, auth, inst);
 	if (err)
 		goto err_free_inst;
 
@@ -419,24 +503,25 @@ static struct crypto_instance *crypto_authenc_alloc(struct rtattr **tb)
 
 	err = -ENAMETOOLONG;
 	if (snprintf(inst->alg.cra_name, CRYPTO_MAX_ALG_NAME,
-		     "authenc(%s,%s)", auth->cra_name, enc->cra_name) >=
+		     "authenc(%s,%s)", auth_base->cra_name, enc->cra_name) >=
 	    CRYPTO_MAX_ALG_NAME)
 		goto err_drop_enc;
 
 	if (snprintf(inst->alg.cra_driver_name, CRYPTO_MAX_ALG_NAME,
-		     "authenc(%s,%s)", auth->cra_driver_name,
+		     "authenc(%s,%s)", auth_base->cra_driver_name,
 		     enc->cra_driver_name) >= CRYPTO_MAX_ALG_NAME)
 		goto err_drop_enc;
 
 	inst->alg.cra_flags = CRYPTO_ALG_TYPE_AEAD;
 	inst->alg.cra_flags |= enc->cra_flags & CRYPTO_ALG_ASYNC;
-	inst->alg.cra_priority = enc->cra_priority * 10 + auth->cra_priority;
+	inst->alg.cra_priority = enc->cra_priority *
+				 10 + auth_base->cra_priority;
 	inst->alg.cra_blocksize = enc->cra_blocksize;
-	inst->alg.cra_alignmask = auth->cra_alignmask | enc->cra_alignmask;
+	inst->alg.cra_alignmask = auth_base->cra_alignmask | enc->cra_alignmask;
 	inst->alg.cra_type = &crypto_aead_type;
 
 	inst->alg.cra_aead.ivsize = enc->cra_ablkcipher.ivsize;
-	inst->alg.cra_aead.maxauthsize = __crypto_shash_alg(auth)->digestsize;
+	inst->alg.cra_aead.maxauthsize = auth->digestsize;
 
 	inst->alg.cra_ctxsize = sizeof(struct crypto_authenc_ctx);
 
@@ -449,13 +534,13 @@ static struct crypto_instance *crypto_authenc_alloc(struct rtattr **tb)
 	inst->alg.cra_aead.givencrypt = crypto_authenc_givencrypt;
 
 out:
-	crypto_mod_put(auth);
+	crypto_mod_put(auth_base);
 	return inst;
 
 err_drop_enc:
 	crypto_drop_skcipher(&ctx->enc);
 err_drop_auth:
-	crypto_drop_spawn(&ctx->auth);
+	crypto_drop_ahash(&ctx->auth);
 err_free_inst:
 	kfree(inst);
 out_put_auth:
@@ -468,7 +553,7 @@ static void crypto_authenc_free(struct crypto_instance *inst)
 	struct authenc_instance_ctx *ctx = crypto_instance_ctx(inst);
 
 	crypto_drop_skcipher(&ctx->enc);
-	crypto_drop_spawn(&ctx->auth);
+	crypto_drop_ahash(&ctx->auth);
 	kfree(inst);
 }
 
-- 
1.5.4.2

