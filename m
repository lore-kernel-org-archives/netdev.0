From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 2/13] crypto: seqiv - Use aead_register_instance
Date: Fri, 22 May 2015 16:30:50 +0800
Message-ID: <E1YviLy-0000x5-2I@gondolin.me.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New style AEAD instances must use aead_register_instance.  This
worked by chance because aead_geniv_alloc is still setting things
the old way.

This patch converts the template over to the create model where
we are responsible for instance registration so that we can call
the correct function.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/seqiv.c |  135 +++++++++++++++++++++++++++++++++------------------------
 1 file changed, 79 insertions(+), 56 deletions(-)

diff --git a/crypto/seqiv.c b/crypto/seqiv.c
index a9bfbda..2680e94 100644
--- a/crypto/seqiv.c
+++ b/crypto/seqiv.c
@@ -38,6 +38,8 @@ struct seqiv_aead_ctx {
 	u8 salt[] __attribute__ ((aligned(__alignof__(u32))));
 };
 
+static void seqiv_free(struct crypto_instance *inst);
+
 static int seqiv_aead_setkey(struct crypto_aead *tfm,
 			     const u8 *key, unsigned int keylen)
 {
@@ -583,23 +585,20 @@ static void seqiv_aead_exit(struct crypto_tfm *tfm)
 	crypto_put_default_null_skcipher();
 }
 
-static struct crypto_template seqiv_tmpl;
-static struct crypto_template seqniv_tmpl;
-
-static struct crypto_instance *seqiv_ablkcipher_alloc(struct rtattr **tb)
+static int seqiv_ablkcipher_create(struct crypto_template *tmpl,
+				   struct rtattr **tb)
 {
 	struct crypto_instance *inst;
+	int err;
 
-	inst = skcipher_geniv_alloc(&seqiv_tmpl, tb, 0, 0);
+	inst = skcipher_geniv_alloc(tmpl, tb, 0, 0);
 
 	if (IS_ERR(inst))
-		goto out;
+		return PTR_ERR(inst);
 
-	if (inst->alg.cra_ablkcipher.ivsize < sizeof(u64)) {
-		skcipher_geniv_free(inst);
-		inst = ERR_PTR(-EINVAL);
-		goto out;
-	}
+	err = -EINVAL;
+	if (inst->alg.cra_ablkcipher.ivsize < sizeof(u64))
+		goto free_inst;
 
 	inst->alg.cra_ablkcipher.givencrypt = seqiv_givencrypt_first;
 
@@ -609,18 +608,28 @@ static struct crypto_instance *seqiv_ablkcipher_alloc(struct rtattr **tb)
 	inst->alg.cra_ctxsize += inst->alg.cra_ablkcipher.ivsize;
 	inst->alg.cra_ctxsize += sizeof(struct seqiv_ctx);
 
+	inst->alg.cra_alignmask |= __alignof__(u32) - 1;
+
+	err = crypto_register_instance(tmpl, inst);
+	if (err)
+		goto free_inst;
+
 out:
-	return inst;
+	return err;
+
+free_inst:
+	skcipher_geniv_free(inst);
+	goto out;
 }
 
-static struct crypto_instance *seqiv_old_aead_alloc(struct aead_instance *aead)
+static int seqiv_old_aead_create(struct crypto_template *tmpl,
+				 struct aead_instance *aead)
 {
 	struct crypto_instance *inst = aead_crypto_instance(aead);
+	int err = -EINVAL;
 
-	if (inst->alg.cra_aead.ivsize < sizeof(u64)) {
-		aead_geniv_free(aead);
-		return ERR_PTR(-EINVAL);
-	}
+	if (inst->alg.cra_aead.ivsize < sizeof(u64))
+		goto free_inst;
 
 	inst->alg.cra_aead.givencrypt = seqiv_aead_givencrypt_first;
 
@@ -630,28 +639,38 @@ static struct crypto_instance *seqiv_old_aead_alloc(struct aead_instance *aead)
 	inst->alg.cra_ctxsize = inst->alg.cra_aead.ivsize;
 	inst->alg.cra_ctxsize += sizeof(struct seqiv_ctx);
 
-	return inst;
+	err = crypto_register_instance(tmpl, inst);
+	if (err)
+		goto free_inst;
+
+out:
+	return err;
+
+free_inst:
+	aead_geniv_free(aead);
+	goto out;
 }
 
-static struct crypto_instance *seqiv_aead_alloc(struct rtattr **tb)
+static int seqiv_aead_create(struct crypto_template *tmpl, struct rtattr **tb)
 {
 	struct aead_instance *inst;
 	struct crypto_aead_spawn *spawn;
 	struct aead_alg *alg;
+	int err;
 
-	inst = aead_geniv_alloc(&seqiv_tmpl, tb, 0, 0);
+	inst = aead_geniv_alloc(tmpl, tb, 0, 0);
 
 	if (IS_ERR(inst))
-		goto out;
+		return PTR_ERR(inst);
+
+	inst->alg.base.cra_alignmask |= __alignof__(u32) - 1;
 
 	if (inst->alg.base.cra_aead.encrypt)
-		return seqiv_old_aead_alloc(inst);
+		return seqiv_old_aead_create(tmpl, inst);
 
-	if (inst->alg.ivsize < sizeof(u64)) {
-		aead_geniv_free(inst);
-		inst = ERR_PTR(-EINVAL);
-		goto out;
-	}
+	err = -EINVAL;
+	if (inst->alg.ivsize < sizeof(u64))
+		goto free_inst;
 
 	spawn = aead_instance_ctx(inst);
 	alg = crypto_spawn_aead_alg(spawn);
@@ -675,43 +694,43 @@ static struct crypto_instance *seqiv_aead_alloc(struct rtattr **tb)
 		inst->alg.base.cra_exit = seqiv_aead_compat_exit;
 	}
 
+	err = aead_register_instance(tmpl, inst);
+	if (err)
+		goto free_inst;
+
 out:
-	return aead_crypto_instance(inst);
+	return err;
+
+free_inst:
+	aead_geniv_free(inst);
+	goto out;
 }
 
-static struct crypto_instance *seqiv_alloc(struct rtattr **tb)
+static int seqiv_create(struct crypto_template *tmpl, struct rtattr **tb)
 {
 	struct crypto_attr_type *algt;
-	struct crypto_instance *inst;
 	int err;
 
 	algt = crypto_get_attr_type(tb);
 	if (IS_ERR(algt))
-		return ERR_CAST(algt);
+		return PTR_ERR(algt);
 
 	err = crypto_get_default_rng();
 	if (err)
-		return ERR_PTR(err);
+		return err;
 
 	if ((algt->type ^ CRYPTO_ALG_TYPE_AEAD) & CRYPTO_ALG_TYPE_MASK)
-		inst = seqiv_ablkcipher_alloc(tb);
+		err = seqiv_ablkcipher_create(tmpl, tb);
 	else
-		inst = seqiv_aead_alloc(tb);
-
-	if (IS_ERR(inst))
-		goto put_rng;
-
-	inst->alg.cra_alignmask |= __alignof__(u32) - 1;
+		err = seqiv_aead_create(tmpl, tb);
 
-out:
-	return inst;
+	if (err)
+		crypto_put_default_rng();
 
-put_rng:
-	crypto_put_default_rng();
-	goto out;
+	return err;
 }
 
-static struct crypto_instance *seqniv_alloc(struct rtattr **tb)
+static int seqniv_create(struct crypto_template *tmpl, struct rtattr **tb)
 {
 	struct aead_instance *inst;
 	struct crypto_aead_spawn *spawn;
@@ -720,18 +739,16 @@ static struct crypto_instance *seqniv_alloc(struct rtattr **tb)
 
 	err = crypto_get_default_rng();
 	if (err)
-		return ERR_PTR(err);
-
-	inst = aead_geniv_alloc(&seqniv_tmpl, tb, 0, 0);
+		return err;
 
+	inst = aead_geniv_alloc(tmpl, tb, 0, 0);
+	err = PTR_ERR(inst);
 	if (IS_ERR(inst))
 		goto put_rng;
 
-	if (inst->alg.ivsize < sizeof(u64)) {
-		aead_geniv_free(inst);
-		inst = ERR_PTR(-EINVAL);
-		goto put_rng;
-	}
+	err = -EINVAL;
+	if (inst->alg.ivsize < sizeof(u64))
+		goto free_inst;
 
 	spawn = aead_instance_ctx(inst);
 	alg = crypto_spawn_aead_alg(spawn);
@@ -748,9 +765,15 @@ static struct crypto_instance *seqniv_alloc(struct rtattr **tb)
 	inst->alg.base.cra_ctxsize = sizeof(struct seqiv_aead_ctx);
 	inst->alg.base.cra_ctxsize += inst->alg.base.cra_aead.ivsize;
 
+	err = aead_register_instance(tmpl, inst);
+	if (err)
+		goto free_inst;
+
 out:
-	return aead_crypto_instance(inst);
+	return err;
 
+free_inst:
+	aead_geniv_free(inst);
 put_rng:
 	crypto_put_default_rng();
 	goto out;
@@ -767,14 +790,14 @@ static void seqiv_free(struct crypto_instance *inst)
 
 static struct crypto_template seqiv_tmpl = {
 	.name = "seqiv",
-	.alloc = seqiv_alloc,
+	.create = seqiv_create,
 	.free = seqiv_free,
 	.module = THIS_MODULE,
 };
 
 static struct crypto_template seqniv_tmpl = {
 	.name = "seqniv",
-	.alloc = seqniv_alloc,
+	.create = seqniv_create,
 	.free = seqiv_free,
 	.module = THIS_MODULE,
 };
