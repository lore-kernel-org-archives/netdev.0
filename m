From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [RFC PATCH 2/3] crypto: ctr - make rfc3686 asynchronous block cipher
Date: Fri, 28 Dec 2012 12:04:58 +0200
Message-ID: <20121228100458.11073.45987.stgit@localhost6.localdomain6>
References: <20121228100448.11073.25546.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20121228100448.11073.25546.stgit@localhost6.localdomain6>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some hardware crypto drivers register asynchronous ctr(aes), which is left
unused in IPSEC because rfc3686 template only supports synchronous block
ciphers. Some other drivers register rfc3686(ctr(aes)) to workaround this
limitation but not all.

This patch changes rfc3686 to use asynchronous block ciphers, to allow async
ctr(aes) algorithms to be utilized automatically by IPSEC.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---
 crypto/ctr.c    |  173 +++++++++++++++++++++++++++++++++++--------------------
 crypto/tcrypt.c |    4 +
 crypto/tcrypt.h |    1 
 3 files changed, 115 insertions(+), 63 deletions(-)

diff --git a/crypto/ctr.c b/crypto/ctr.c
index 4ca7222..1f2997c 100644
--- a/crypto/ctr.c
+++ b/crypto/ctr.c
@@ -12,6 +12,7 @@
 
 #include <crypto/algapi.h>
 #include <crypto/ctr.h>
+#include <crypto/internal/skcipher.h>
 #include <linux/err.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
@@ -25,10 +26,15 @@ struct crypto_ctr_ctx {
 };
 
 struct crypto_rfc3686_ctx {
-	struct crypto_blkcipher *child;
+	struct crypto_ablkcipher *child;
 	u8 nonce[CTR_RFC3686_NONCE_SIZE];
 };
 
+struct crypto_rfc3686_req_ctx {
+	u8 iv[CTR_RFC3686_BLOCK_SIZE];
+	struct ablkcipher_request subreq CRYPTO_MINALIGN_ATTR;
+};
+
 static int crypto_ctr_setkey(struct crypto_tfm *parent, const u8 *key,
 			     unsigned int keylen)
 {
@@ -243,11 +249,11 @@ static struct crypto_template crypto_ctr_tmpl = {
 	.module = THIS_MODULE,
 };
 
-static int crypto_rfc3686_setkey(struct crypto_tfm *parent, const u8 *key,
-				 unsigned int keylen)
+static int crypto_rfc3686_setkey(struct crypto_ablkcipher *parent,
+				 const u8 *key, unsigned int keylen)
 {
-	struct crypto_rfc3686_ctx *ctx = crypto_tfm_ctx(parent);
-	struct crypto_blkcipher *child = ctx->child;
+	struct crypto_rfc3686_ctx *ctx = crypto_ablkcipher_ctx(parent);
+	struct crypto_ablkcipher *child = ctx->child;
 	int err;
 
 	/* the nonce is stored in bytes at end of key */
@@ -259,59 +265,64 @@ static int crypto_rfc3686_setkey(struct crypto_tfm *parent, const u8 *key,
 
 	keylen -= CTR_RFC3686_NONCE_SIZE;
 
-	crypto_blkcipher_clear_flags(child, CRYPTO_TFM_REQ_MASK);
-	crypto_blkcipher_set_flags(child, crypto_tfm_get_flags(parent) &
-					  CRYPTO_TFM_REQ_MASK);
-	err = crypto_blkcipher_setkey(child, key, keylen);
-	crypto_tfm_set_flags(parent, crypto_blkcipher_get_flags(child) &
-				     CRYPTO_TFM_RES_MASK);
+	crypto_ablkcipher_clear_flags(child, CRYPTO_TFM_REQ_MASK);
+	crypto_ablkcipher_set_flags(child, crypto_ablkcipher_get_flags(parent) &
+				    CRYPTO_TFM_REQ_MASK);
+	err = crypto_ablkcipher_setkey(child, key, keylen);
+	crypto_ablkcipher_set_flags(parent, crypto_ablkcipher_get_flags(child) &
+				    CRYPTO_TFM_RES_MASK);
 
 	return err;
 }
 
-static int crypto_rfc3686_crypt(struct blkcipher_desc *desc,
-				struct scatterlist *dst,
-				struct scatterlist *src, unsigned int nbytes)
+static int crypto_rfc3686_crypt(struct ablkcipher_request *req)
 {
-	struct crypto_blkcipher *tfm = desc->tfm;
-	struct crypto_rfc3686_ctx *ctx = crypto_blkcipher_ctx(tfm);
-	struct crypto_blkcipher *child = ctx->child;
-	unsigned long alignmask = crypto_blkcipher_alignmask(tfm);
-	u8 ivblk[CTR_RFC3686_BLOCK_SIZE + alignmask];
-	u8 *iv = PTR_ALIGN(ivblk + 0, alignmask + 1);
-	u8 *info = desc->info;
-	int err;
+	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
+	struct crypto_rfc3686_ctx *ctx = crypto_ablkcipher_ctx(tfm);
+	struct crypto_ablkcipher *child = ctx->child;
+	unsigned long align = crypto_ablkcipher_alignmask(tfm);
+	struct crypto_rfc3686_req_ctx *rctx =
+		(void *)PTR_ALIGN((u8 *)ablkcipher_request_ctx(req), align + 1);
+	struct ablkcipher_request *subreq = &rctx->subreq;
+	u8 *iv = rctx->iv;
 
 	/* set up counter block */
 	memcpy(iv, ctx->nonce, CTR_RFC3686_NONCE_SIZE);
-	memcpy(iv + CTR_RFC3686_NONCE_SIZE, info, CTR_RFC3686_IV_SIZE);
+	memcpy(iv + CTR_RFC3686_NONCE_SIZE, req->info, CTR_RFC3686_IV_SIZE);
 
 	/* initialize counter portion of counter block */
 	*(__be32 *)(iv + CTR_RFC3686_NONCE_SIZE + CTR_RFC3686_IV_SIZE) =
 		cpu_to_be32(1);
 
-	desc->tfm = child;
-	desc->info = iv;
-	err = crypto_blkcipher_encrypt_iv(desc, dst, src, nbytes);
-	desc->tfm = tfm;
-	desc->info = info;
+	ablkcipher_request_set_tfm(subreq, child);
+	ablkcipher_request_set_callback(subreq, req->base.flags,
+					req->base.complete, req->base.data);
+	ablkcipher_request_set_crypt(subreq, req->src, req->dst, req->nbytes,
+				     iv);
 
-	return err;
+	return crypto_ablkcipher_encrypt(subreq);
 }
 
 static int crypto_rfc3686_init_tfm(struct crypto_tfm *tfm)
 {
 	struct crypto_instance *inst = (void *)tfm->__crt_alg;
-	struct crypto_spawn *spawn = crypto_instance_ctx(inst);
+	struct crypto_skcipher_spawn *spawn = crypto_instance_ctx(inst);
 	struct crypto_rfc3686_ctx *ctx = crypto_tfm_ctx(tfm);
-	struct crypto_blkcipher *cipher;
+	struct crypto_ablkcipher *cipher;
+	unsigned long align;
 
-	cipher = crypto_spawn_blkcipher(spawn);
+	cipher = crypto_spawn_skcipher(spawn);
 	if (IS_ERR(cipher))
 		return PTR_ERR(cipher);
 
 	ctx->child = cipher;
 
+	align = crypto_tfm_alg_alignmask(tfm);
+	align &= ~(crypto_tfm_ctx_alignment() - 1);
+	tfm->crt_ablkcipher.reqsize = align +
+		sizeof(struct crypto_rfc3686_req_ctx) +
+		crypto_ablkcipher_reqsize(cipher);
+
 	return 0;
 }
 
@@ -319,74 +330,110 @@ static void crypto_rfc3686_exit_tfm(struct crypto_tfm *tfm)
 {
 	struct crypto_rfc3686_ctx *ctx = crypto_tfm_ctx(tfm);
 
-	crypto_free_blkcipher(ctx->child);
+	crypto_free_ablkcipher(ctx->child);
 }
 
 static struct crypto_instance *crypto_rfc3686_alloc(struct rtattr **tb)
 {
+	struct crypto_attr_type *algt;
 	struct crypto_instance *inst;
 	struct crypto_alg *alg;
+	struct crypto_skcipher_spawn *spawn;
+	const char *cipher_name;
 	int err;
 
-	err = crypto_check_attr_type(tb, CRYPTO_ALG_TYPE_BLKCIPHER);
-	if (err)
+	algt = crypto_get_attr_type(tb);
+	err = PTR_ERR(algt);
+	if (IS_ERR(algt))
 		return ERR_PTR(err);
 
-	alg = crypto_attr_alg(tb[1], CRYPTO_ALG_TYPE_BLKCIPHER,
-				  CRYPTO_ALG_TYPE_MASK);
-	err = PTR_ERR(alg);
-	if (IS_ERR(alg))
+	if ((algt->type ^ CRYPTO_ALG_TYPE_BLKCIPHER) & algt->mask)
+		return ERR_PTR(-EINVAL);
+
+	cipher_name = crypto_attr_alg_name(tb[1]);
+	err = PTR_ERR(cipher_name);
+	if (IS_ERR(cipher_name))
 		return ERR_PTR(err);
 
+	inst = kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL);
+	if (!inst)
+		return ERR_PTR(-ENOMEM);
+
+	spawn = crypto_instance_ctx(inst);
+
+	crypto_set_skcipher_spawn(spawn, inst);
+	err = crypto_grab_skcipher(spawn, cipher_name, 0,
+				   crypto_requires_sync(algt->type,
+							algt->mask));
+	if (err)
+		goto err_free_inst;
+
+	alg = crypto_skcipher_spawn_alg(spawn);
+
 	/* We only support 16-byte blocks. */
 	err = -EINVAL;
-	if (alg->cra_blkcipher.ivsize != CTR_RFC3686_BLOCK_SIZE)
-		goto out_put_alg;
+	if (alg->cra_ablkcipher.ivsize != CTR_RFC3686_BLOCK_SIZE)
+		goto err_drop_spawn;
 
 	/* Not a stream cipher? */
 	if (alg->cra_blocksize != 1)
-		goto out_put_alg;
+		goto err_drop_spawn;
 
-	inst = crypto_alloc_instance("rfc3686", alg);
-	if (IS_ERR(inst))
-		goto out;
+	err = -ENAMETOOLONG;
+	if (snprintf(inst->alg.cra_name, CRYPTO_MAX_ALG_NAME, "rfc3686(%s)",
+		     alg->cra_name) >= CRYPTO_MAX_ALG_NAME)
+		goto err_drop_spawn;
+	if (snprintf(inst->alg.cra_driver_name, CRYPTO_MAX_ALG_NAME,
+		     "rfc3686(%s)", alg->cra_driver_name) >=
+			CRYPTO_MAX_ALG_NAME)
+		goto err_drop_spawn;
 
-	inst->alg.cra_flags = CRYPTO_ALG_TYPE_BLKCIPHER;
 	inst->alg.cra_priority = alg->cra_priority;
 	inst->alg.cra_blocksize = 1;
 	inst->alg.cra_alignmask = alg->cra_alignmask;
-	inst->alg.cra_type = &crypto_blkcipher_type;
 
-	inst->alg.cra_blkcipher.ivsize = CTR_RFC3686_IV_SIZE;
-	inst->alg.cra_blkcipher.min_keysize = alg->cra_blkcipher.min_keysize
-					      + CTR_RFC3686_NONCE_SIZE;
-	inst->alg.cra_blkcipher.max_keysize = alg->cra_blkcipher.max_keysize
-					      + CTR_RFC3686_NONCE_SIZE;
+	inst->alg.cra_flags = CRYPTO_ALG_TYPE_ABLKCIPHER |
+			      (alg->cra_flags & CRYPTO_ALG_ASYNC);
+	inst->alg.cra_type = &crypto_ablkcipher_type;
+
+	inst->alg.cra_ablkcipher.ivsize = CTR_RFC3686_IV_SIZE;
+	inst->alg.cra_ablkcipher.min_keysize =
+		alg->cra_ablkcipher.min_keysize + CTR_RFC3686_NONCE_SIZE;
+	inst->alg.cra_ablkcipher.max_keysize =
+		alg->cra_ablkcipher.max_keysize + CTR_RFC3686_NONCE_SIZE;
 
-	inst->alg.cra_blkcipher.geniv = "seqiv";
+	inst->alg.cra_ablkcipher.geniv = "seqiv";
+
+	inst->alg.cra_ablkcipher.setkey = crypto_rfc3686_setkey;
+	inst->alg.cra_ablkcipher.encrypt = crypto_rfc3686_crypt;
+	inst->alg.cra_ablkcipher.decrypt = crypto_rfc3686_crypt;
 
 	inst->alg.cra_ctxsize = sizeof(struct crypto_rfc3686_ctx);
 
 	inst->alg.cra_init = crypto_rfc3686_init_tfm;
 	inst->alg.cra_exit = crypto_rfc3686_exit_tfm;
 
-	inst->alg.cra_blkcipher.setkey = crypto_rfc3686_setkey;
-	inst->alg.cra_blkcipher.encrypt = crypto_rfc3686_crypt;
-	inst->alg.cra_blkcipher.decrypt = crypto_rfc3686_crypt;
-
-out:
-	crypto_mod_put(alg);
 	return inst;
 
-out_put_alg:
-	inst = ERR_PTR(err);
-	goto out;
+err_drop_spawn:
+	crypto_drop_skcipher(spawn);
+err_free_inst:
+	kfree(inst);
+	return ERR_PTR(err);
+}
+
+static void crypto_rfc3686_free(struct crypto_instance *inst)
+{
+	struct crypto_skcipher_spawn *spawn = crypto_instance_ctx(inst);
+
+	crypto_drop_skcipher(spawn);
+	kfree(inst);
 }
 
 static struct crypto_template crypto_rfc3686_tmpl = {
 	.name = "rfc3686",
 	.alloc = crypto_rfc3686_alloc,
-	.free = crypto_ctr_free,
+	.free = crypto_rfc3686_free,
 	.module = THIS_MODULE,
 };
 
diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 7ae2130..87ef7d6 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -1591,6 +1591,10 @@ static int do_test(int m)
 				   speed_template_16_24_32);
 		test_acipher_speed("ofb(aes)", DECRYPT, sec, NULL, 0,
 				   speed_template_16_24_32);
+		test_acipher_speed("rfc3686(ctr(aes))", ENCRYPT, sec, NULL, 0,
+				   speed_template_20_28_36);
+		test_acipher_speed("rfc3686(ctr(aes))", DECRYPT, sec, NULL, 0,
+				   speed_template_20_28_36);
 		break;
 
 	case 501:
diff --git a/crypto/tcrypt.h b/crypto/tcrypt.h
index cd20685..ecdeeb1 100644
--- a/crypto/tcrypt.h
+++ b/crypto/tcrypt.h
@@ -51,6 +51,7 @@ static u8 speed_template_8_16[] = {8, 16, 0};
 static u8 speed_template_8_32[] = {8, 32, 0};
 static u8 speed_template_16_32[] = {16, 32, 0};
 static u8 speed_template_16_24_32[] = {16, 24, 32, 0};
+static u8 speed_template_20_28_36[] = {20, 28, 36, 0};
 static u8 speed_template_32_40_48[] = {32, 40, 48, 0};
 static u8 speed_template_32_48[] = {32, 48, 0};
 static u8 speed_template_32_48_64[] = {32, 48, 64, 0};
