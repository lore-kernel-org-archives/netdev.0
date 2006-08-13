From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/16] [CRYPTO] cipher: Added block ciphers for CBC/ECB
Date: Sun, 13 Aug 2006 22:20:09 +1000
Message-ID: <E1GCEwr-0004g3-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:8713 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751063AbWHMMUM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:20:12 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] cipher: Added block ciphers for CBC/ECB

This patch adds two block cipher algorithms, CBC and ECB.  These
are implemented as templates on top of existing single-block cipher
algorithms.  They invoke the single-block cipher through the new
encrypt_one/decrypt_one interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/Kconfig          |   17 ++
 crypto/Makefile         |    2 
 crypto/cbc.c            |  337 ++++++++++++++++++++++++++++++++++++++++++++++++
 crypto/ecb.c            |  181 +++++++++++++++++++++++++
 crypto/internal.h       |    1 
 include/crypto/algapi.h |    2 
 6 files changed, 539 insertions(+), 1 deletion(-)

diff --git a/crypto/Kconfig b/crypto/Kconfig
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -123,6 +123,23 @@ config CRYPTO_TGR192
 	  See also:
 	  <http://www.cs.technion.ac.il/~biham/Reports/Tiger/>.
 
+config CRYPTO_ECB
+	tristate "ECB support"
+	select CRYPTO_BLKCIPHER
+	default m
+	help
+	  ECB: Electronic CodeBook mode
+	  This is the simplest block cipher algorithm.  It simply encrypts
+	  the input block by block.
+
+config CRYPTO_CBC
+	tristate "CBC support"
+	select CRYPTO_BLKCIPHER
+	default m
+	help
+	  CBC: Cipher Block Chaining mode
+	  This block cipher algorithm is required for IPSec.
+
 config CRYPTO_DES
 	tristate "DES and Triple DES EDE cipher algorithms"
 	select CRYPTO_ALGAPI
diff --git a/crypto/Makefile b/crypto/Makefile
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -20,6 +20,8 @@ obj-$(CONFIG_CRYPTO_SHA256) += sha256.o
 obj-$(CONFIG_CRYPTO_SHA512) += sha512.o
 obj-$(CONFIG_CRYPTO_WP512) += wp512.o
 obj-$(CONFIG_CRYPTO_TGR192) += tgr192.o
+obj-$(CONFIG_CRYPTO_ECB) += ecb.o
+obj-$(CONFIG_CRYPTO_CBC) += cbc.o
 obj-$(CONFIG_CRYPTO_DES) += des.o
 obj-$(CONFIG_CRYPTO_BLOWFISH) += blowfish.o
 obj-$(CONFIG_CRYPTO_TWOFISH) += twofish.o
diff --git a/crypto/cbc.c b/crypto/cbc.c
new file mode 100644
--- /dev/null
+++ b/crypto/cbc.c
@@ -0,0 +1,337 @@
+/*
+ * CBC: Cipher Block Chaining mode
+ *
+ * Copyright (c) 2006 Herbert Xu <herbert@gondor.apana.org.au>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ */
+
+#include <crypto/algapi.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/scatterlist.h>
+#include <linux/slab.h>
+
+struct crypto_cbc_ctx {
+	struct crypto_cipher *child;
+	void (*xor)(u8 *dst, const u8 *src, unsigned int bs);
+};
+
+static int crypto_cbc_setkey(struct crypto_tfm *parent, const u8 *key,
+			     unsigned int keylen)
+{
+	struct crypto_cbc_ctx *ctx = crypto_tfm_ctx(parent);
+	struct crypto_cipher *child = ctx->child;
+	int err;
+
+	crypto_cipher_clear_flags(child, CRYPTO_TFM_REQ_MASK);
+	crypto_cipher_set_flags(child, crypto_tfm_get_flags(parent) &
+				       CRYPTO_TFM_REQ_MASK);
+	err = crypto_cipher_setkey(child, key, keylen);
+	crypto_tfm_set_flags(parent, crypto_cipher_get_flags(child) &
+				     CRYPTO_TFM_RES_MASK);
+	return err;
+}
+
+static int crypto_cbc_encrypt_segment(struct blkcipher_desc *desc,
+				      struct blkcipher_walk *walk,
+				      struct crypto_cipher *tfm,
+				      void (*xor)(u8 *, const u8 *,
+						  unsigned int))
+{
+	void (*fn)(struct crypto_tfm *, u8 *, const u8 *) =
+		crypto_cipher_alg(tfm)->cia_encrypt;
+	int bsize = crypto_cipher_blocksize(tfm);
+	unsigned int nbytes = walk->nbytes;
+	u8 *src = walk->src.virt.addr;
+	u8 *dst = walk->dst.virt.addr;
+	u8 *iv = walk->iv;
+
+	do {
+		xor(iv, src, bsize);
+		fn(crypto_cipher_tfm(tfm), dst, iv);
+		memcpy(iv, dst, bsize);
+
+		src += bsize;
+		dst += bsize;
+	} while ((nbytes -= bsize) >= bsize);
+
+	return nbytes;
+}
+
+static int crypto_cbc_encrypt_inplace(struct blkcipher_desc *desc,
+				      struct blkcipher_walk *walk,
+				      struct crypto_cipher *tfm,
+				      void (*xor)(u8 *, const u8 *,
+						  unsigned int))
+{
+	void (*fn)(struct crypto_tfm *, u8 *, const u8 *) =
+		crypto_cipher_alg(tfm)->cia_encrypt;
+	int bsize = crypto_cipher_blocksize(tfm);
+	unsigned int nbytes = walk->nbytes;
+	u8 *src = walk->src.virt.addr;
+	u8 *iv = walk->iv;
+
+	do {
+		xor(src, iv, bsize);
+		fn(crypto_cipher_tfm(tfm), src, src);
+		iv = src;
+
+		src += bsize;
+	} while ((nbytes -= bsize) >= bsize);
+
+	memcpy(walk->iv, iv, bsize);
+
+	return nbytes;
+}
+
+static int crypto_cbc_encrypt(struct blkcipher_desc *desc,
+			      struct scatterlist *dst, struct scatterlist *src,
+			      unsigned int nbytes)
+{
+	struct blkcipher_walk walk;
+	struct crypto_blkcipher *tfm = desc->tfm;
+	struct crypto_cbc_ctx *ctx = crypto_blkcipher_ctx(tfm);
+	struct crypto_cipher *child = ctx->child;
+	void (*xor)(u8 *, const u8 *, unsigned int bs) = ctx->xor;
+	int err;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	err = blkcipher_walk_virt(desc, &walk);
+
+	while ((nbytes = walk.nbytes)) {
+		if (walk.src.virt.addr == walk.dst.virt.addr)
+			nbytes = crypto_cbc_encrypt_inplace(desc, &walk, child,
+							    xor);
+		else
+			nbytes = crypto_cbc_encrypt_segment(desc, &walk, child,
+							    xor);
+		err = blkcipher_walk_done(desc, &walk, nbytes);
+	}
+
+	return err;
+}
+
+static int crypto_cbc_decrypt_segment(struct blkcipher_desc *desc,
+				      struct blkcipher_walk *walk,
+				      struct crypto_cipher *tfm,
+				      void (*xor)(u8 *, const u8 *,
+						  unsigned int))
+{
+	void (*fn)(struct crypto_tfm *, u8 *, const u8 *) =
+		crypto_cipher_alg(tfm)->cia_decrypt;
+	int bsize = crypto_cipher_blocksize(tfm);
+	unsigned int nbytes = walk->nbytes;
+	u8 *src = walk->src.virt.addr;
+	u8 *dst = walk->dst.virt.addr;
+	u8 *iv = walk->iv;
+
+	do {
+		fn(crypto_cipher_tfm(tfm), dst, src);
+		xor(dst, iv, bsize);
+		iv = src;
+
+		src += bsize;
+		dst += bsize;
+	} while ((nbytes -= bsize) >= bsize);
+
+	memcpy(walk->iv, iv, bsize);
+
+	return nbytes;
+}
+
+static int crypto_cbc_decrypt_inplace(struct blkcipher_desc *desc,
+				      struct blkcipher_walk *walk,
+				      struct crypto_cipher *tfm,
+				      void (*xor)(u8 *, const u8 *,
+						  unsigned int))
+{
+	void (*fn)(struct crypto_tfm *, u8 *, const u8 *) =
+		crypto_cipher_alg(tfm)->cia_decrypt;
+	int bsize = crypto_cipher_blocksize(tfm);
+	unsigned long alignmask = crypto_cipher_alignmask(tfm);
+	unsigned int nbytes = walk->nbytes;
+	u8 *src = walk->src.virt.addr;
+	u8 stack[bsize + alignmask];
+	u8 *tmp = (u8 *)ALIGN((unsigned long)stack, alignmask + 1);
+
+	do {
+		fn(crypto_cipher_tfm(tfm), tmp, src);
+		xor(tmp, walk->iv, bsize);
+		memcpy(walk->iv, src, bsize);
+		memcpy(src, tmp, bsize);
+
+		src += bsize;
+	} while ((nbytes -= bsize) >= bsize);
+
+	return nbytes;
+}
+
+static int crypto_cbc_decrypt(struct blkcipher_desc *desc,
+			      struct scatterlist *dst, struct scatterlist *src,
+			      unsigned int nbytes)
+{
+	struct blkcipher_walk walk;
+	struct crypto_blkcipher *tfm = desc->tfm;
+	struct crypto_cbc_ctx *ctx = crypto_blkcipher_ctx(tfm);
+	struct crypto_cipher *child = ctx->child;
+	void (*xor)(u8 *, const u8 *, unsigned int bs) = ctx->xor;
+	int err;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	err = blkcipher_walk_virt(desc, &walk);
+
+	while ((nbytes = walk.nbytes)) {
+		if (walk.src.virt.addr == walk.dst.virt.addr)
+			nbytes = crypto_cbc_decrypt_inplace(desc, &walk, child,
+							    xor);
+		else
+			nbytes = crypto_cbc_decrypt_segment(desc, &walk, child,
+							    xor);
+		err = blkcipher_walk_done(desc, &walk, nbytes);
+	}
+
+	return err;
+}
+
+static void xor_byte(u8 *a, const u8 *b, unsigned int bs)
+{
+	do {
+		*a++ ^= *b++;
+	} while (--bs);
+}
+
+static void xor_quad(u8 *dst, const u8 *src, unsigned int bs)
+{
+	u32 *a = (u32 *)dst;
+	u32 *b = (u32 *)src;
+
+	do {
+		*a++ ^= *b++;
+	} while ((bs -= 4));
+}
+
+static void xor_64(u8 *a, const u8 *b, unsigned int bs)
+{
+	((u32 *)a)[0] ^= ((u32 *)b)[0];
+	((u32 *)a)[1] ^= ((u32 *)b)[1];
+}
+
+static void xor_128(u8 *a, const u8 *b, unsigned int bs)
+{
+	((u32 *)a)[0] ^= ((u32 *)b)[0];
+	((u32 *)a)[1] ^= ((u32 *)b)[1];
+	((u32 *)a)[2] ^= ((u32 *)b)[2];
+	((u32 *)a)[3] ^= ((u32 *)b)[3];
+}
+
+static int crypto_cbc_init_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_instance *inst = (void *)tfm->__crt_alg;
+	struct crypto_spawn *spawn = crypto_instance_ctx(inst);
+	struct crypto_cbc_ctx *ctx = crypto_tfm_ctx(tfm);
+
+	switch (crypto_tfm_alg_blocksize(tfm)) {
+	case 8:
+		ctx->xor = xor_64;
+		break;
+
+	case 16:
+		ctx->xor = xor_128;
+		break;
+
+	default:
+		if (crypto_tfm_alg_blocksize(tfm) % 4)
+			ctx->xor = xor_byte;
+		else
+			ctx->xor = xor_quad;
+	}
+
+	tfm = crypto_spawn_tfm(spawn);
+	if (IS_ERR(tfm))
+		return PTR_ERR(tfm);
+
+	ctx->child = crypto_cipher_cast(tfm);
+	return 0;
+}
+
+static void crypto_cbc_exit_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_cbc_ctx *ctx = crypto_tfm_ctx(tfm);
+	crypto_free_cipher(ctx->child);
+}
+
+static struct crypto_instance *crypto_cbc_alloc(void *param, unsigned int len)
+{
+	struct crypto_instance *inst;
+	struct crypto_alg *alg;
+
+	alg = crypto_get_attr_alg(param, len, CRYPTO_ALG_TYPE_CIPHER,
+				  CRYPTO_ALG_TYPE_MASK | CRYPTO_ALG_ASYNC);
+	if (IS_ERR(alg))
+		return ERR_PTR(PTR_ERR(alg));
+
+	inst = crypto_alloc_instance("cbc", alg);
+	if (IS_ERR(inst))
+		goto out_put_alg;
+
+	inst->alg.cra_flags = CRYPTO_ALG_TYPE_BLKCIPHER;
+	inst->alg.cra_priority = alg->cra_priority;
+	inst->alg.cra_blocksize = alg->cra_blocksize;
+	inst->alg.cra_alignmask = alg->cra_alignmask;
+	inst->alg.cra_type = &crypto_blkcipher_type;
+
+	if (!(alg->cra_blocksize % 4))
+		inst->alg.cra_alignmask |= 3;
+	inst->alg.cra_blkcipher.ivsize = alg->cra_blocksize;
+	inst->alg.cra_blkcipher.min_keysize = alg->cra_cipher.cia_min_keysize;
+	inst->alg.cra_blkcipher.max_keysize = alg->cra_cipher.cia_max_keysize;
+
+	inst->alg.cra_ctxsize = sizeof(struct crypto_cbc_ctx);
+
+	inst->alg.cra_init = crypto_cbc_init_tfm;
+	inst->alg.cra_exit = crypto_cbc_exit_tfm;
+
+	inst->alg.cra_blkcipher.setkey = crypto_cbc_setkey;
+	inst->alg.cra_blkcipher.encrypt = crypto_cbc_encrypt;
+	inst->alg.cra_blkcipher.decrypt = crypto_cbc_decrypt;
+
+out_put_alg:
+	crypto_mod_put(alg);
+	return inst;
+}
+
+static void crypto_cbc_free(struct crypto_instance *inst)
+{
+	crypto_drop_spawn(crypto_instance_ctx(inst));
+	kfree(inst);
+}
+
+static struct crypto_template crypto_cbc_tmpl = {
+	.name = "cbc",
+	.alloc = crypto_cbc_alloc,
+	.free = crypto_cbc_free,
+	.module = THIS_MODULE,
+};
+
+static int __init crypto_cbc_module_init(void)
+{
+	return crypto_register_template(&crypto_cbc_tmpl);
+}
+
+static void __exit crypto_cbc_module_exit(void)
+{
+	crypto_unregister_template(&crypto_cbc_tmpl);
+}
+
+module_init(crypto_cbc_module_init);
+module_exit(crypto_cbc_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("CBC block cipher algorithm");
diff --git a/crypto/ecb.c b/crypto/ecb.c
new file mode 100644
--- /dev/null
+++ b/crypto/ecb.c
@@ -0,0 +1,181 @@
+/*
+ * ECB: Electronic CodeBook mode
+ *
+ * Copyright (c) 2006 Herbert Xu <herbert@gondor.apana.org.au>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ */
+
+#include <crypto/algapi.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/scatterlist.h>
+#include <linux/slab.h>
+
+struct crypto_ecb_ctx {
+	struct crypto_cipher *child;
+};
+
+static int crypto_ecb_setkey(struct crypto_tfm *parent, const u8 *key,
+			     unsigned int keylen)
+{
+	struct crypto_ecb_ctx *ctx = crypto_tfm_ctx(parent);
+	struct crypto_cipher *child = ctx->child;
+	int err;
+
+	crypto_cipher_clear_flags(child, CRYPTO_TFM_REQ_MASK);
+	crypto_cipher_set_flags(child, crypto_tfm_get_flags(parent) &
+				       CRYPTO_TFM_REQ_MASK);
+	err = crypto_cipher_setkey(child, key, keylen);
+	crypto_tfm_set_flags(parent, crypto_cipher_get_flags(child) &
+				     CRYPTO_TFM_RES_MASK);
+	return err;
+}
+
+static int crypto_ecb_crypt(struct blkcipher_desc *desc,
+			    struct blkcipher_walk *walk,
+			    struct crypto_cipher *tfm,
+			    void (*fn)(struct crypto_tfm *, u8 *, const u8 *))
+{
+	int bsize = crypto_cipher_blocksize(tfm);
+	unsigned int nbytes;
+	int err;
+
+	err = blkcipher_walk_virt(desc, walk);
+
+	while ((nbytes = walk->nbytes)) {
+		u8 *wsrc = walk->src.virt.addr;
+		u8 *wdst = walk->dst.virt.addr;
+
+		do {
+			fn(crypto_cipher_tfm(tfm), wdst, wsrc);
+	
+			wsrc += bsize;
+			wdst += bsize;
+		} while ((nbytes -= bsize) >= bsize);
+
+		err = blkcipher_walk_done(desc, walk, nbytes);
+	}
+
+	return err;
+}
+
+static int crypto_ecb_encrypt(struct blkcipher_desc *desc,
+			      struct scatterlist *dst, struct scatterlist *src,
+			      unsigned int nbytes)
+{
+	struct blkcipher_walk walk;
+	struct crypto_blkcipher *tfm = desc->tfm;
+	struct crypto_ecb_ctx *ctx = crypto_blkcipher_ctx(tfm);
+	struct crypto_cipher *child = ctx->child;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return crypto_ecb_crypt(desc, &walk, child,
+				crypto_cipher_alg(child)->cia_encrypt);
+}
+
+static int crypto_ecb_decrypt(struct blkcipher_desc *desc,
+			      struct scatterlist *dst, struct scatterlist *src,
+			      unsigned int nbytes)
+{
+	struct blkcipher_walk walk;
+	struct crypto_blkcipher *tfm = desc->tfm;
+	struct crypto_ecb_ctx *ctx = crypto_blkcipher_ctx(tfm);
+	struct crypto_cipher *child = ctx->child;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return crypto_ecb_crypt(desc, &walk, child,
+				crypto_cipher_alg(child)->cia_decrypt);
+}
+
+static int crypto_ecb_init_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_instance *inst = (void *)tfm->__crt_alg;
+	struct crypto_spawn *spawn = crypto_instance_ctx(inst);
+	struct crypto_ecb_ctx *ctx = crypto_tfm_ctx(tfm);
+
+	tfm = crypto_spawn_tfm(spawn);
+	if (IS_ERR(tfm))
+		return PTR_ERR(tfm);
+
+	ctx->child = crypto_cipher_cast(tfm);
+	return 0;
+}
+
+static void crypto_ecb_exit_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_ecb_ctx *ctx = crypto_tfm_ctx(tfm);
+	crypto_free_cipher(ctx->child);
+}
+
+static struct crypto_instance *crypto_ecb_alloc(void *param, unsigned int len)
+{
+	struct crypto_instance *inst;
+	struct crypto_alg *alg;
+
+	alg = crypto_get_attr_alg(param, len, CRYPTO_ALG_TYPE_CIPHER,
+				  CRYPTO_ALG_TYPE_MASK | CRYPTO_ALG_ASYNC);
+	if (IS_ERR(alg))
+		return ERR_PTR(PTR_ERR(alg));
+
+	inst = crypto_alloc_instance("ecb", alg);
+	if (IS_ERR(inst))
+		goto out_put_alg;
+
+	inst->alg.cra_flags = CRYPTO_ALG_TYPE_BLKCIPHER;
+	inst->alg.cra_priority = alg->cra_priority;
+	inst->alg.cra_blocksize = alg->cra_blocksize;
+	inst->alg.cra_alignmask = alg->cra_alignmask;
+	inst->alg.cra_type = &crypto_blkcipher_type;
+
+	inst->alg.cra_blkcipher.min_keysize = alg->cra_cipher.cia_min_keysize;
+	inst->alg.cra_blkcipher.max_keysize = alg->cra_cipher.cia_max_keysize;
+
+	inst->alg.cra_ctxsize = sizeof(struct crypto_ecb_ctx);
+
+	inst->alg.cra_init = crypto_ecb_init_tfm;
+	inst->alg.cra_exit = crypto_ecb_exit_tfm;
+
+	inst->alg.cra_blkcipher.setkey = crypto_ecb_setkey;
+	inst->alg.cra_blkcipher.encrypt = crypto_ecb_encrypt;
+	inst->alg.cra_blkcipher.decrypt = crypto_ecb_decrypt;
+
+out_put_alg:
+	crypto_mod_put(alg);
+	return inst;
+}
+
+static void crypto_ecb_free(struct crypto_instance *inst)
+{
+	crypto_drop_spawn(crypto_instance_ctx(inst));
+	kfree(inst);
+}
+
+static struct crypto_template crypto_ecb_tmpl = {
+	.name = "ecb",
+	.alloc = crypto_ecb_alloc,
+	.free = crypto_ecb_free,
+	.module = THIS_MODULE,
+};
+
+static int __init crypto_ecb_module_init(void)
+{
+	return crypto_register_template(&crypto_ecb_tmpl);
+}
+
+static void __exit crypto_ecb_module_exit(void)
+{
+	crypto_unregister_template(&crypto_ecb_tmpl);
+}
+
+module_init(crypto_ecb_module_init);
+module_exit(crypto_ecb_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("ECB block cipher algorithm");
diff --git a/crypto/internal.h b/crypto/internal.h
--- a/crypto/internal.h
+++ b/crypto/internal.h
@@ -131,7 +131,6 @@ static inline unsigned int crypto_compre
 }
 
 struct crypto_alg *crypto_mod_get(struct crypto_alg *alg);
-void crypto_mod_put(struct crypto_alg *alg);
 struct crypto_alg *__crypto_alg_lookup(const char *name, u32 type, u32 mask);
 struct crypto_alg *crypto_alg_mod_lookup(const char *name, u32 type, u32 mask);
 
diff --git a/include/crypto/algapi.h b/include/crypto/algapi.h
--- a/include/crypto/algapi.h
+++ b/include/crypto/algapi.h
@@ -81,6 +81,8 @@ struct blkcipher_walk {
 
 extern const struct crypto_type crypto_blkcipher_type;
 
+void crypto_mod_put(struct crypto_alg *alg);
+
 int crypto_register_template(struct crypto_template *tmpl);
 void crypto_unregister_template(struct crypto_template *tmpl);
 struct crypto_template *crypto_lookup_template(const char *name);
