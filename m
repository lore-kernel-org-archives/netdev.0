From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] AES-XCBC-MAC
Date: Wed, 14 Jun 2006 08:40:58 +1000
Message-ID: <20060613224058.GA18331@gondor.apana.org.au>
References: <1150213440.4200.36.camel@hookipa>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:19469 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932366AbWFMWls
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 18:41:48 -0400
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <1150213440.4200.36.camel@hookipa>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 14, 2006 at 12:44:00AM +0900, Kazunori MIYAZAWA wrote:
> This is preparation to introduce AES-XCBC-MAC.
> - introducing common interface "keyed hash"
> - making HMAC use the interface

I'm sorry guys, but this seems to duplicate what I've been doing as
generic parameterised algorithms.  I wish we'd discussed this more
so time didn't had to be wasted.

I've attached a sample HMAC implementation.  Things are still fluid
so it may not even compile (Actually, it definitely wouldn't compile
without the template stuff which I'll post soon :)

In any case, this is the model AES-XCBC-MAC should look like.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="hmac.patch"

diff --git a/crypto/Kconfig b/crypto/Kconfig
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -18,7 +18,7 @@ config CRYPTO_MANAGER
 	  cbc(aes).
 
 config CRYPTO_HMAC
-	bool "HMAC support"
+	tristate "HMAC support"
 	depends on CRYPTO
 	help
 	  HMAC: Keyed-Hashing for Message Authentication (RFC2104).
diff --git a/crypto/Makefile b/crypto/Makefile
diff --git a/crypto/hmac.c b/crypto/hmac.c
--- a/crypto/hmac.c
+++ b/crypto/hmac.c
@@ -4,6 +4,7 @@
  * HMAC: Keyed-Hashing for Message Authentication (RFC2104).
  *
  * Copyright (c) 2002 James Morris <jmorris@intercode.com.au>
+ * Copyright (c) 2006 Herbert Xu <herbert@gondor.apana.org.au>
  *
  * The HMAC implementation is derived from USAGI.
  * Copyright (c) 2002 Kazunori Miyazawa <miyazawa@linux-ipv6.org> / USAGI
@@ -21,84 +22,80 @@
 #include <linux/scatterlist.h>
 #include "internal.h"
 
-static void hash_key(struct crypto_tfm *tfm, u8 *key, unsigned int keylen)
-{
-	struct scatterlist tmp;
-	
-	sg_set_buf(&tmp, key, keylen);
-	crypto_digest_digest(tfm, &tmp, 1, key);
-}
-
-int crypto_alloc_hmac_block(struct crypto_tfm *tfm)
-{
-	int ret = 0;
-
-	BUG_ON(!crypto_tfm_alg_blocksize(tfm));
-	
-	tfm->crt_digest.dit_hmac_block = kmalloc(crypto_tfm_alg_blocksize(tfm),
-	                                         GFP_KERNEL);
-	if (tfm->crt_digest.dit_hmac_block == NULL)
-		ret = -ENOMEM;
+struct hmac_ctx {
+	struct crypto_tfm *child;
+};
+
+static void crypto_hmac_setkey(struct crypto_tfm *parent, u8 *inkey,
+			       unsigned int keylen, u32 *flags)
+{
+	int bs = crypto_tfm_alg_blocksize(parent);
+	char *key = crypto_tfm_ctx(parent);
+	char *pad = ctx_arg + bs;
+	struct hmac_ctx *ctx = pad + bs;
+	struct crypto_tfm *tfm = ctx->child;
+	
+	if (keylen > bs) {
+		struct scatterlist tmp;
+		sg_set_buf(&tmp, inkey, keylen);
+		crypto_digest_digest(child, &tmp, 1, pad);
+		inkey = pad;
+		keylen = crypto_tfm_alg_digestsize(tfm);
+	}
 
-	return ret;
-		
+	memcpy(key, inkey, keylen);
+	memset(key + keylen, 0, bs - keylen);
 }
 
-void crypto_free_hmac_block(struct crypto_tfm *tfm)
-{
-	kfree(tfm->crt_digest.dit_hmac_block);
-}
-
-void crypto_hmac_init(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen)
+static void crypto_hmac_init(struct crypto_tfm *parent)
 {
+	int bs = crypto_tfm_alg_blocksize(parent);
+	char *key = crypto_tfm_ctx(parent);
+	char *ipad = ctx_arg + bs;
+	struct hmac_ctx *ctx = ipad + bs;
+	struct crypto_tfm *tfm = ctx->child;
 	unsigned int i;
 	struct scatterlist tmp;
-	char *ipad = tfm->crt_digest.dit_hmac_block;
-	
-	if (*keylen > crypto_tfm_alg_blocksize(tfm)) {
-		hash_key(tfm, key, *keylen);
-		*keylen = crypto_tfm_alg_digestsize(tfm);
-	}
 
-	memset(ipad, 0, crypto_tfm_alg_blocksize(tfm));
-	memcpy(ipad, key, *keylen);
+	memcpy(ipad, key, bs);
 
-	for (i = 0; i < crypto_tfm_alg_blocksize(tfm); i++)
+	for (i = 0; i < bs; i++)
 		ipad[i] ^= 0x36;
 
-	sg_set_buf(&tmp, ipad, crypto_tfm_alg_blocksize(tfm));
+	sg_set_buf(&tmp, ipad, bs);
 	
 	crypto_digest_init(tfm);
 	crypto_digest_update(tfm, &tmp, 1);
 }
 
-void crypto_hmac_update(struct crypto_tfm *tfm,
-                        struct scatterlist *sg, unsigned int nsg)
+static void crypto_hmac_update(struct crypto_tfm *parent,
+			       struct scatterlist *sg, unsigned int nsg)
 {
+	int bs = crypto_tfm_alg_blocksize(parent);
+	struct hmac_ctx *ctx = crypto_tfm_ctx(parent) + bs * 2;
+	struct crypto_tfm *tfm = ctx->child;
 	crypto_digest_update(tfm, sg, nsg);
 }
 
-void crypto_hmac_final(struct crypto_tfm *tfm, u8 *key,
-                       unsigned int *keylen, u8 *out)
+static void crypto_hmac_final(struct crypto_tfm *parent, u8 *key,
+			      unsigned int *keylen, u8 *out)
 {
+	int bs = crypto_tfm_alg_blocksize(parent);
+	char *key = crypto_tfm_ctx(parent);
+	char *opad = ctx_arg + bs;
+	struct hmac_ctx *ctx = opad + bs;
+	struct crypto_tfm *tfm = ctx->child;
 	unsigned int i;
 	struct scatterlist tmp;
-	char *opad = tfm->crt_digest.dit_hmac_block;
 	
-	if (*keylen > crypto_tfm_alg_blocksize(tfm)) {
-		hash_key(tfm, key, *keylen);
-		*keylen = crypto_tfm_alg_digestsize(tfm);
-	}
-
 	crypto_digest_final(tfm, out);
 
-	memset(opad, 0, crypto_tfm_alg_blocksize(tfm));
-	memcpy(opad, key, *keylen);
+	memcpy(opad, key, bs);
 		
-	for (i = 0; i < crypto_tfm_alg_blocksize(tfm); i++)
+	for (i = 0; i < bs; i++)
 		opad[i] ^= 0x5c;
 
-	sg_set_buf(&tmp, opad, crypto_tfm_alg_blocksize(tfm));
+	sg_set_buf(&tmp, opad, bs);
 
 	crypto_digest_init(tfm);
 	crypto_digest_update(tfm, &tmp, 1);
@@ -109,16 +106,109 @@ void crypto_hmac_final(struct crypto_tfm
 	crypto_digest_final(tfm, out);
 }
 
-void crypto_hmac(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen,
-                 struct scatterlist *sg, unsigned int nsg, u8 *out)
+static int hmac_init_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_instance *inst = (void *)tfm->__crt_alg;
+	struct crypto_spawn **spawn = crypto_instance_param(inst);
+	struct hmac_ctx *ctx = crypto_tfm_ctx(tfm);
+
+	ctx->child = crypto_spawn_tfm(*spawn, 0);
+	if (!ctx->child)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static struct crypto_instance *hmac_init_alg(void *param, unsigned int len)
+{
+	struct rtattr *rta = param;
+	struct crypto_attr_base *base;
+	struct crypto_attr_alg *alg;
+	struct crypto_instance *inst;
+	struct crypto_spawn *spawn;
+	struct crypto_spawn **inst_param;
+	int err;
+
+	if (!RTA_OK(rta, len))
+		return ERR_PTR(-EBADR);
+	if (rta->rta_type != CRYPTOA_BASE || RTA_PAYLOAD(rta) < sizeof(*base))
+		return ERR_PTR(-EINVAL);
+
+	base = RTA_DATA(rta);
+
+	rta = RTA_NEXT(rta, len);
+	if (!RTA_OK(rta, len))
+		return ERR_PTR(-EBADR);
+	if (rta->rta_type != CRYPTOA_ALG || RTA_PAYLOAD(rta) < sizeof(*alg))
+		return ERR_PTR(-EINVAL);
+
+	alg = RTA_DATA(rta);
+
+	inst = kzalloc(sizeof(*inst) + sizeof(spawn));
+	if (!inst)
+		return ERR_PTR(-ENOMEM);
+
+	spawn = crypto_alloc_spawn(alg->name);
+	if (IS_ERR(spawn)) {
+		err = PTR_ERR(spawn);
+		goto err_spawn;
+	}
+
+	strlcpy(inst->alg.cra_name, base->type.name, CRYPTO_MAX_ALG_NAME);
+	strlcpy(inst->alg.cra_driver_name, base->driver.name,
+		CRYPTO_MAX_ALG_NAME);
+
+	inst_param = crypto_instance_param(inst);
+	*inst_param = spawn;
+
+	inst->alg.cra_priority = base->priority;
+	inst->alg.cra_flags = CRYPTO_ALG_TYPE_DIGEST;
+	inst->alg.cra_blocksize = spawn->alg->cra_blocksize;
+
+	/* XXX Check alignment once we have drivers with alignmask > 16. */
+	inst->alg.cra_ctxsize = sizeof(struct hmac_ctx) +
+				inst->alg.cra_blocksize * 2;
+
+	inst->alg.cra_module = THIS_MODULE;
+	inst->alg.cra_init = hmac_init_tfm;
+
+	inst->alg.cra_u.digest.dia_init = crypto_hmac_init;
+	inst->alg.cra_u.digest.dia_update = crypto_hmac_update;
+	inst->alg.cra_u.digest.dia_final = crypto_hmac_final;
+	inst->alg.cra_u.digest.dia_setkey = crypto_hmac_setkey;
+	return inst;
+
+err_spawn:
+	kfree(inst);
+	return ERR_PTR(err);
+}
+
+static void hmac_destroy_alg(struct crypto_instance *inst)
+{
+	struct crypto_spawn **spawn = crypto_instance_param(inst);
+	crypto_free_spawn(*spawn);
+	kfree(inst);
+}
+
+static struct crypto_template hmac_tmpl = {
+	.name = "hmac",
+	.base_type = CRYPTO_ALG_TYPE_DIGEST,
+	.init = hmac_init_alg,
+	.destroy = hmac_destroy_alg,
+};
+
+static int __init hmac_init(void)
+{
+	return crypto_register_template(&hmac_tmpl);
+}
+
+static void __exit hmac_exit(void)
 {
-	crypto_hmac_init(tfm, key, keylen);
-	crypto_hmac_update(tfm, sg, nsg);
-	crypto_hmac_final(tfm, key, keylen, out);
+	crypto_unregister_template(&hmac_tmpl);
 }
 
-EXPORT_SYMBOL_GPL(crypto_hmac_init);
-EXPORT_SYMBOL_GPL(crypto_hmac_update);
-EXPORT_SYMBOL_GPL(crypto_hmac_final);
-EXPORT_SYMBOL_GPL(crypto_hmac);
+module_init(hmac_init);
+module_exit(hmac_exit);
 
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("HMAC digest algorithm");
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -209,9 +209,6 @@ struct digest_tfm {
 	                   unsigned int nsg, u8 *out);
 	int (*dit_setkey)(struct crypto_tfm *tfm,
 	                  const u8 *key, unsigned int keylen);
-#ifdef CONFIG_CRYPTO_HMAC
-	void *dit_hmac_block;
-#endif
 };
 
 struct compress_tfm {
@@ -452,18 +449,5 @@ static inline int crypto_comp_decompress
 	return tfm->crt_compress.cot_decompress(tfm, src, slen, dst, dlen);
 }
 
-/*
- * HMAC support.
- */
-#ifdef CONFIG_CRYPTO_HMAC
-void crypto_hmac_init(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen);
-void crypto_hmac_update(struct crypto_tfm *tfm,
-                        struct scatterlist *sg, unsigned int nsg);
-void crypto_hmac_final(struct crypto_tfm *tfm, u8 *key,
-                       unsigned int *keylen, u8 *out);
-void crypto_hmac(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen,
-                 struct scatterlist *sg, unsigned int nsg, u8 *out);
-#endif	/* CONFIG_CRYPTO_HMAC */
-
 #endif	/* _LINUX_CRYPTO_H */
 

--bg08WKrSYDhXBjb5--
