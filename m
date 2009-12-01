From: Tobias Brunner <tobias@strongswan.org>
Subject: [PATCH] crypto: gmac - Add RFC4543 wrapper for GCM
Date: Tue, 01 Dec 2009 17:49:28 +0100
Message-ID: <4B154918.7070008@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the RFC4543 (GMAC) wrapper for GCM similar to the
existing RFC4106 wrapper. The main differences between GCM and GMAC are
the contents of the AAD and that the plaintext is empty for the latter.

Signed-off-by: Tobias Brunner <tobias@strongswan.org>
---
 crypto/gcm.c            |  275 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/pfkeyv2.h |    1 +
 net/xfrm/xfrm_algo.c    |   16 +++
 3 files changed, 292 insertions(+), 0 deletions(-)

diff --git a/crypto/gcm.c b/crypto/gcm.c
index 5fc3292..b097eb4 100644
--- a/crypto/gcm.c
+++ b/crypto/gcm.c
@@ -37,6 +37,15 @@ struct crypto_rfc4106_ctx {
 	u8 nonce[4];
 };
 
+struct crypto_rfc4543_ctx {
+	struct crypto_aead *child;
+	u8 nonce[4];
+	u8 auth_tag[16];
+	struct scatterlist cipher[1];
+	struct scatterlist payload[2];
+	struct scatterlist assoc[2];
+};
+
 struct crypto_gcm_ghash_ctx {
 	unsigned int cryptlen;
 	struct scatterlist *src;
@@ -1008,6 +1017,264 @@ static struct crypto_template crypto_rfc4106_tmpl = {
 	.module = THIS_MODULE,
 };
 
+static int crypto_rfc4543_setkey(struct crypto_aead *parent, const u8 *key,
+				 unsigned int keylen)
+{
+	struct crypto_rfc4543_ctx *ctx = crypto_aead_ctx(parent);
+	struct crypto_aead *child = ctx->child;
+	int err;
+
+	if (keylen < 4)
+		return -EINVAL;
+
+	keylen -= 4;
+	memcpy(ctx->nonce, key + keylen, 4);
+
+	crypto_aead_clear_flags(child, CRYPTO_TFM_REQ_MASK);
+	crypto_aead_set_flags(child, crypto_aead_get_flags(parent) &
+				     CRYPTO_TFM_REQ_MASK);
+	err = crypto_aead_setkey(child, key, keylen);
+	crypto_aead_set_flags(parent, crypto_aead_get_flags(child) &
+				      CRYPTO_TFM_RES_MASK);
+
+	return err;
+}
+
+static int crypto_rfc4543_setauthsize(struct crypto_aead *parent,
+				      unsigned int authsize)
+{
+	struct crypto_rfc4543_ctx *ctx = crypto_aead_ctx(parent);
+
+	if (authsize != 16)
+		return -EINVAL;
+
+	return crypto_aead_setauthsize(ctx->child, authsize);
+}
+
+/* this is the same as crypto_authenc_chain */
+static void crypto_rfc4543_chain(struct scatterlist *head,
+				 struct scatterlist *sg, int chain)
+{
+	if (chain) {
+		head->length += sg->length;
+		sg = scatterwalk_sg_next(sg);
+	}
+
+	if (sg)
+		scatterwalk_sg_chain(head, 2, sg);
+	else
+		sg_mark_end(head);
+}
+
+static struct aead_request *crypto_rfc4543_crypt(struct aead_request *req,
+						 int enc)
+{
+	struct aead_request *subreq = aead_request_ctx(req);
+	struct crypto_aead *aead = crypto_aead_reqtfm(req);
+	struct crypto_rfc4543_ctx *ctx = crypto_aead_ctx(aead);
+	struct crypto_aead *child = ctx->child;
+	struct scatterlist *dst = req->dst;
+	struct scatterlist *cipher = ctx->cipher;
+	struct scatterlist *payload = ctx->payload;
+	struct scatterlist *assoc = ctx->assoc;
+	unsigned int authsize = crypto_aead_authsize(aead);
+	unsigned int assoclen = req->assoclen;
+	struct page *dstp;
+	u8 *vdst;
+	u8 *iv = PTR_ALIGN((u8 *)(subreq + 1) + crypto_aead_reqsize(child),
+			   crypto_aead_alignmask(child) + 1);
+
+	memcpy(iv, ctx->nonce, 4);
+	memcpy(iv + 4, req->iv, 8);
+
+	/* construct cipher/plaintext */
+	if (enc)
+		memset(ctx->auth_tag, 0, authsize);
+	else
+		scatterwalk_map_and_copy(ctx->auth_tag, dst,
+					 req->cryptlen - authsize,
+					 authsize, 0);
+
+	sg_init_one(cipher, ctx->auth_tag, authsize);
+
+	/* construct the aad */
+	dstp = sg_page(dst);
+	vdst = PageHighMem(dstp) ? NULL : page_address(dstp) + dst->offset;
+
+	sg_init_table(payload, 2);
+	sg_set_buf(payload, req->iv, 8);
+	crypto_rfc4543_chain(payload, dst, vdst == req->iv + 8);
+	assoclen += 8 + req->cryptlen - (enc ? 0 : authsize);
+
+	sg_init_table(assoc, 2);
+	sg_set_page(assoc, sg_page(req->assoc), req->assoc->length,
+		    req->assoc->offset);
+	crypto_rfc4543_chain(assoc, payload, 0);
+
+	aead_request_set_tfm(subreq, child);
+	aead_request_set_callback(subreq, req->base.flags, req->base.complete,
+				  req->base.data);
+	aead_request_set_crypt(subreq, cipher, cipher, enc ? 0 : authsize, iv);
+	aead_request_set_assoc(subreq, assoc, assoclen);
+
+	return subreq;
+}
+
+static int crypto_rfc4543_encrypt(struct aead_request *req)
+{
+	struct crypto_aead *aead = crypto_aead_reqtfm(req);
+	struct crypto_rfc4543_ctx *ctx = crypto_aead_ctx(aead);
+	struct aead_request *subreq;
+	int err;
+
+	subreq = crypto_rfc4543_crypt(req, 1);
+	err = crypto_aead_encrypt(subreq);
+	if (err)
+		return err;
+
+	scatterwalk_map_and_copy(ctx->auth_tag, req->dst, req->cryptlen,
+				 crypto_aead_authsize(aead), 1);
+
+	return 0;
+}
+
+static int crypto_rfc4543_decrypt(struct aead_request *req)
+{
+	req = crypto_rfc4543_crypt(req, 0);
+
+	return crypto_aead_decrypt(req);
+}
+
+static int crypto_rfc4543_init_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_instance *inst = (void *)tfm->__crt_alg;
+	struct crypto_aead_spawn *spawn = crypto_instance_ctx(inst);
+	struct crypto_rfc4543_ctx *ctx = crypto_tfm_ctx(tfm);
+	struct crypto_aead *aead;
+	unsigned long align;
+
+	aead = crypto_spawn_aead(spawn);
+	if (IS_ERR(aead))
+		return PTR_ERR(aead);
+
+	ctx->child = aead;
+
+	align = crypto_aead_alignmask(aead);
+	align &= ~(crypto_tfm_ctx_alignment() - 1);
+	tfm->crt_aead.reqsize = sizeof(struct aead_request) +
+				ALIGN(crypto_aead_reqsize(aead),
+				      crypto_tfm_ctx_alignment()) +
+				align + 16;
+
+	return 0;
+}
+
+static void crypto_rfc4543_exit_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_rfc4543_ctx *ctx = crypto_tfm_ctx(tfm);
+
+	crypto_free_aead(ctx->child);
+}
+
+static struct crypto_instance *crypto_rfc4543_alloc(struct rtattr **tb)
+{
+	struct crypto_attr_type *algt;
+	struct crypto_instance *inst;
+	struct crypto_aead_spawn *spawn;
+	struct crypto_alg *alg;
+	const char *ccm_name;
+	int err;
+
+	algt = crypto_get_attr_type(tb);
+	err = PTR_ERR(algt);
+	if (IS_ERR(algt))
+		return ERR_PTR(err);
+
+	if ((algt->type ^ CRYPTO_ALG_TYPE_AEAD) & algt->mask)
+		return ERR_PTR(-EINVAL);
+
+	ccm_name = crypto_attr_alg_name(tb[1]);
+	err = PTR_ERR(ccm_name);
+	if (IS_ERR(ccm_name))
+		return ERR_PTR(err);
+
+	inst = kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL);
+	if (!inst)
+		return ERR_PTR(-ENOMEM);
+
+	spawn = crypto_instance_ctx(inst);
+	crypto_set_aead_spawn(spawn, inst);
+	err = crypto_grab_aead(spawn, ccm_name, 0,
+			       crypto_requires_sync(algt->type, algt->mask));
+	if (err)
+		goto out_free_inst;
+
+	alg = crypto_aead_spawn_alg(spawn);
+
+	err = -EINVAL;
+
+	/* We only support 16-byte blocks. */
+	if (alg->cra_aead.ivsize != 16)
+		goto out_drop_alg;
+
+	/* Not a stream cipher? */
+	if (alg->cra_blocksize != 1)
+		goto out_drop_alg;
+
+	err = -ENAMETOOLONG;
+	if (snprintf(inst->alg.cra_name, CRYPTO_MAX_ALG_NAME,
+		     "rfc4543(%s)", alg->cra_name) >= CRYPTO_MAX_ALG_NAME ||
+	    snprintf(inst->alg.cra_driver_name, CRYPTO_MAX_ALG_NAME,
+		     "rfc4543(%s)", alg->cra_driver_name) >=
+	    CRYPTO_MAX_ALG_NAME)
+		goto out_drop_alg;
+
+	inst->alg.cra_flags = CRYPTO_ALG_TYPE_AEAD;
+	inst->alg.cra_flags |= alg->cra_flags & CRYPTO_ALG_ASYNC;
+	inst->alg.cra_priority = alg->cra_priority;
+	inst->alg.cra_blocksize = 1;
+	inst->alg.cra_alignmask = alg->cra_alignmask;
+	inst->alg.cra_type = &crypto_nivaead_type;
+
+	inst->alg.cra_aead.ivsize = 8;
+	inst->alg.cra_aead.maxauthsize = 16;
+
+	inst->alg.cra_ctxsize = sizeof(struct crypto_rfc4543_ctx);
+
+	inst->alg.cra_init = crypto_rfc4543_init_tfm;
+	inst->alg.cra_exit = crypto_rfc4543_exit_tfm;
+
+	inst->alg.cra_aead.setkey = crypto_rfc4543_setkey;
+	inst->alg.cra_aead.setauthsize = crypto_rfc4543_setauthsize;
+	inst->alg.cra_aead.encrypt = crypto_rfc4543_encrypt;
+	inst->alg.cra_aead.decrypt = crypto_rfc4543_decrypt;
+
+	inst->alg.cra_aead.geniv = "seqiv";
+
+out:
+	return inst;
+
+out_drop_alg:
+	crypto_drop_aead(spawn);
+out_free_inst:
+	kfree(inst);
+	inst = ERR_PTR(err);
+	goto out;
+}
+
+static void crypto_rfc4543_free(struct crypto_instance *inst)
+{
+	crypto_drop_spawn(crypto_instance_ctx(inst));
+	kfree(inst);
+}
+
+static struct crypto_template crypto_rfc4543_tmpl = {
+	.name = "rfc4543",
+	.alloc = crypto_rfc4543_alloc,
+	.free = crypto_rfc4543_free,
+	.module = THIS_MODULE,
+};
+
 static int __init crypto_gcm_module_init(void)
 {
 	int err;
@@ -1028,8 +1295,14 @@ static int __init crypto_gcm_module_init(void)
 	if (err)
 		goto out_undo_gcm;
 
+	err = crypto_register_template(&crypto_rfc4543_tmpl);
+	if (err)
+		goto out_undo_rfc4106;
+
 	return 0;
 
+out_undo_rfc4106:
+	crypto_unregister_template(&crypto_rfc4106_tmpl);
 out_undo_gcm:
 	crypto_unregister_template(&crypto_gcm_tmpl);
 out_undo_base:
@@ -1042,6 +1315,7 @@ out:
 static void __exit crypto_gcm_module_exit(void)
 {
 	kfree(gcm_zeroes);
+	crypto_unregister_template(&crypto_rfc4543_tmpl);
 	crypto_unregister_template(&crypto_rfc4106_tmpl);
 	crypto_unregister_template(&crypto_gcm_tmpl);
 	crypto_unregister_template(&crypto_gcm_base_tmpl);
@@ -1055,3 +1329,4 @@ MODULE_DESCRIPTION("Galois/Counter Mode");
 MODULE_AUTHOR("Mikko Herranen <mh1@iki.fi>");
 MODULE_ALIAS("gcm_base");
 MODULE_ALIAS("rfc4106");
+MODULE_ALIAS("rfc4543");
diff --git a/include/linux/pfkeyv2.h b/include/linux/pfkeyv2.h
index 228b0b6..0b80c80 100644
--- a/include/linux/pfkeyv2.h
+++ b/include/linux/pfkeyv2.h
@@ -315,6 +315,7 @@ struct sadb_x_kmaddress {
 #define SADB_X_EALG_AES_GCM_ICV12	19
 #define SADB_X_EALG_AES_GCM_ICV16	20
 #define SADB_X_EALG_CAMELLIACBC		22
+#define SADB_X_EALG_NULL_AES_GMAC	23
 #define SADB_EALG_MAX                   253 /* last EALG */
 /* private allocations should use 249-255 (RFC2407) */
 #define SADB_X_EALG_SERPENTCBC  252     /* draft-ietf-ipsec-ciph-aes-cbc-00 */
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index ef8d61d..c9182fb 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -125,6 +125,22 @@ static struct xfrm_algo_desc aead_list[] = {
 		.sadb_alg_maxbits = 256
 	}
 },
+{
+	.name = "rfc4543(gcm(aes))",
+
+	.uinfo = {
+		.aead = {
+			.icv_truncbits = 128,
+		}
+	},
+
+	.desc = {
+		.sadb_alg_id = SADB_X_EALG_NULL_AES_GMAC,
+		.sadb_alg_ivlen = 8,
+		.sadb_alg_minbits = 128,
+		.sadb_alg_maxbits = 256
+	}
+},
 };
 
 static struct xfrm_algo_desc aalg_list[] = {
-- 
1.6.3.3

