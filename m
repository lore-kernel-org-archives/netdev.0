From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/16] [CRYPTO] cipher: Added block cipher type
Date: Sun, 13 Aug 2006 22:20:07 +1000
Message-ID: <E1GCEwp-0004g0-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:7945 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751077AbWHMMUL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:20:11 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] cipher: Added block cipher type

This patch adds the new type of block ciphers.  Unlike current cipher
algorithms which operate on a single block at a time, block ciphers
operate on an arbitrarily long linear area of data.  As it is block-based,
it will skip any data remaining at the end which cannot form a block.

The block cipher has one major difference when compared to the existing
block cipher implementation.  The sg walking is now performed by the
algorithm rather than the cipher mid-layer.  This is needed for drivers
that directly support sg lists.  It also improves performance for all
algorithms as it reduces the total number of indirect calls by one.

In future the existing cipher algorithm will be converted to only have
a single-block interface.  This will be done after all existing users
have switched over to the new block cipher type.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/Kconfig          |    4 
 crypto/Makefile         |    2 
 crypto/blkcipher.c      |  390 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/crypto/algapi.h |   65 ++++++++
 include/linux/crypto.h  |  179 ++++++++++++++++++++++
 5 files changed, 640 insertions(+)

diff --git a/crypto/Kconfig b/crypto/Kconfig
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -16,6 +16,10 @@ config CRYPTO_ALGAPI
 	help
 	  This option provides the API for cryptographic algorithms.
 
+config CRYPTO_BLKCIPHER
+	tristate
+	select CRYPTO_ALGAPI
+
 config CRYPTO_MANAGER
 	tristate "Cryptographic algorithm manager"
 	select CRYPTO_ALGAPI
diff --git a/crypto/Makefile b/crypto/Makefile
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -8,6 +8,8 @@ crypto_algapi-$(CONFIG_PROC_FS) += proc.
 crypto_algapi-objs := algapi.o $(crypto_algapi-y)
 obj-$(CONFIG_CRYPTO_ALGAPI) += crypto_algapi.o
 
+obj-$(CONFIG_CRYPTO_BLKCIPHER) += blkcipher.o
+
 obj-$(CONFIG_CRYPTO_MANAGER) += cryptomgr.o
 obj-$(CONFIG_CRYPTO_HMAC) += hmac.o
 obj-$(CONFIG_CRYPTO_NULL) += crypto_null.o
diff --git a/crypto/blkcipher.c b/crypto/blkcipher.c
new file mode 100644
--- /dev/null
+++ b/crypto/blkcipher.c
@@ -0,0 +1,390 @@
+/*
+ * Block chaining cipher operations.
+ * 
+ * Generic encrypt/decrypt wrapper for ciphers, handles operations across
+ * multiple page boundaries by using temporary blocks.  In user context,
+ * the kernel is given a chance to schedule us once per page.
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
+#include <linux/crypto.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/scatterlist.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+
+#include "internal.h"
+#include "scatterwalk.h"
+
+enum {
+	BLKCIPHER_WALK_PHYS = 1 << 0,
+	BLKCIPHER_WALK_SLOW = 1 << 1,
+	BLKCIPHER_WALK_COPY = 1 << 2,
+	BLKCIPHER_WALK_DIFF = 1 << 3,
+};
+
+static int blkcipher_walk_next(struct blkcipher_desc *desc,
+			       struct blkcipher_walk *walk);
+static int blkcipher_walk_first(struct blkcipher_desc *desc,
+				struct blkcipher_walk *walk);
+
+static inline void blkcipher_map_src(struct blkcipher_walk *walk)
+{
+	walk->src.virt.addr = scatterwalk_map(&walk->in, 0);
+}
+
+static inline void blkcipher_map_dst(struct blkcipher_walk *walk)
+{
+	walk->dst.virt.addr = scatterwalk_map(&walk->out, 1);
+}
+
+static inline void blkcipher_unmap_src(struct blkcipher_walk *walk)
+{
+	scatterwalk_unmap(walk->src.virt.addr, 0);
+}
+
+static inline void blkcipher_unmap_dst(struct blkcipher_walk *walk)
+{
+	scatterwalk_unmap(walk->dst.virt.addr, 1);
+}
+
+static inline u8 *blkcipher_get_spot(u8 *start, unsigned int len)
+{
+	if (offset_in_page(start + len) < len)
+		return (u8 *)((unsigned long)(start + len) & PAGE_MASK);
+	return start;
+}
+
+static inline unsigned int blkcipher_done_slow(struct crypto_blkcipher *tfm,
+					       struct blkcipher_walk *walk,
+					       unsigned int bsize)
+{
+	u8 *addr;
+	unsigned int alignmask = crypto_blkcipher_alignmask(tfm);
+
+	addr = (u8 *)ALIGN((unsigned long)walk->buffer, alignmask + 1);
+	addr = blkcipher_get_spot(addr, bsize);
+	scatterwalk_copychunks(addr, &walk->out, bsize, 1);
+	return bsize;
+}
+
+static inline unsigned int blkcipher_done_fast(struct blkcipher_walk *walk,
+					       unsigned int n)
+{
+	n = walk->nbytes - n;
+
+	if (walk->flags & BLKCIPHER_WALK_COPY) {
+		blkcipher_map_dst(walk);
+		memcpy(walk->dst.virt.addr, walk->page, n);
+		blkcipher_unmap_dst(walk);
+	} else if (!(walk->flags & BLKCIPHER_WALK_PHYS)) {
+		blkcipher_unmap_src(walk);
+		if (walk->flags & BLKCIPHER_WALK_DIFF)
+			blkcipher_unmap_dst(walk);
+	}
+
+	scatterwalk_advance(&walk->in, n);
+	scatterwalk_advance(&walk->out, n);
+
+	return n;
+}
+
+int blkcipher_walk_done(struct blkcipher_desc *desc,
+			struct blkcipher_walk *walk, int err)
+{
+	struct crypto_blkcipher *tfm = desc->tfm;
+	unsigned int nbytes = 0;
+
+	if (likely(err >= 0)) {
+		unsigned int bsize = crypto_blkcipher_blocksize(tfm);
+		unsigned int n;
+
+		if (likely(!(walk->flags & BLKCIPHER_WALK_SLOW)))
+			n = blkcipher_done_fast(walk, err);
+		else
+			n = blkcipher_done_slow(tfm, walk, bsize);
+
+		nbytes = walk->total - n;
+		err = 0;
+	}
+
+	scatterwalk_done(&walk->in, 0, nbytes);
+	scatterwalk_done(&walk->out, 1, nbytes);
+
+	walk->total = nbytes;
+	walk->nbytes = nbytes;
+
+	if (nbytes) {
+		crypto_yield(desc->flags);
+		return blkcipher_walk_next(desc, walk);
+	}
+
+	if (walk->iv != desc->info)
+		memcpy(desc->info, walk->iv, crypto_blkcipher_ivsize(tfm));
+	if (walk->buffer != walk->page)
+		kfree(walk->buffer);
+	if (walk->page)
+		free_page((unsigned long)walk->page);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(blkcipher_walk_done);
+
+static inline int blkcipher_next_slow(struct blkcipher_desc *desc,
+				      struct blkcipher_walk *walk,
+				      unsigned int bsize,
+				      unsigned int alignmask)
+{
+	unsigned int n;
+
+	if (walk->buffer)
+		goto ok;
+
+	walk->buffer = walk->page;
+	if (walk->buffer)
+		goto ok;
+
+	n = bsize * 2 + (alignmask & ~(crypto_tfm_ctx_alignment() - 1));
+	walk->buffer = kmalloc(n, GFP_ATOMIC);
+	if (!walk->buffer)
+		return blkcipher_walk_done(desc, walk, -ENOMEM);
+
+ok:
+	walk->dst.virt.addr = (u8 *)ALIGN((unsigned long)walk->buffer,
+					  alignmask + 1);
+	walk->dst.virt.addr = blkcipher_get_spot(walk->dst.virt.addr, bsize);
+	walk->src.virt.addr = blkcipher_get_spot(walk->dst.virt.addr + bsize,
+						 bsize);
+
+	scatterwalk_copychunks(walk->src.virt.addr, &walk->in, bsize, 0);
+
+	walk->nbytes = bsize;
+	walk->flags |= BLKCIPHER_WALK_SLOW;
+
+	return 0;
+}
+
+static inline int blkcipher_next_copy(struct blkcipher_walk *walk)
+{
+	u8 *tmp = walk->page;
+
+	blkcipher_map_src(walk);
+	memcpy(tmp, walk->src.virt.addr, walk->nbytes);
+	blkcipher_unmap_src(walk);
+
+	walk->src.virt.addr = tmp;
+	walk->dst.virt.addr = tmp;
+
+	return 0;
+}
+
+static inline int blkcipher_next_fast(struct blkcipher_desc *desc,
+				      struct blkcipher_walk *walk)
+{
+	unsigned long diff;
+
+	walk->src.phys.page = scatterwalk_page(&walk->in);
+	walk->src.phys.offset = offset_in_page(walk->in.offset);
+	walk->dst.phys.page = scatterwalk_page(&walk->out);
+	walk->dst.phys.offset = offset_in_page(walk->out.offset);
+
+	if (walk->flags & BLKCIPHER_WALK_PHYS)
+		return 0;
+
+	diff = walk->src.phys.offset - walk->dst.phys.offset;
+	diff |= walk->src.virt.page - walk->dst.virt.page;
+
+	blkcipher_map_src(walk);
+	walk->dst.virt.addr = walk->src.virt.addr;
+
+	if (diff) {
+		walk->flags |= BLKCIPHER_WALK_DIFF;
+		blkcipher_map_dst(walk);
+	}
+
+	return 0;
+}
+
+static int blkcipher_walk_next(struct blkcipher_desc *desc,
+			       struct blkcipher_walk *walk)
+{
+	struct crypto_blkcipher *tfm = desc->tfm;
+	unsigned int alignmask = crypto_blkcipher_alignmask(tfm);
+	unsigned int bsize = crypto_blkcipher_blocksize(tfm);
+	unsigned int n;
+	int err;
+
+	n = walk->total;
+	if (unlikely(n < bsize)) {
+		desc->flags |= CRYPTO_TFM_RES_BAD_BLOCK_LEN;
+		return blkcipher_walk_done(desc, walk, -EINVAL);
+	}
+
+	walk->flags &= ~(BLKCIPHER_WALK_SLOW | BLKCIPHER_WALK_COPY |
+			 BLKCIPHER_WALK_DIFF);
+	if (!scatterwalk_aligned(&walk->in, alignmask) ||
+	    !scatterwalk_aligned(&walk->out, alignmask)) {
+		walk->flags |= BLKCIPHER_WALK_COPY;
+		if (!walk->page) {
+			walk->page = (void *)__get_free_page(GFP_ATOMIC);
+			if (!walk->page)
+				n = 0;
+		}
+	}
+
+	n = scatterwalk_clamp(&walk->in, n);
+	n = scatterwalk_clamp(&walk->out, n);
+
+	if (unlikely(n < bsize)) {
+		err = blkcipher_next_slow(desc, walk, bsize, alignmask);
+		goto set_phys_lowmem;
+	}
+
+	walk->nbytes = n;
+	if (walk->flags & BLKCIPHER_WALK_COPY) {
+		err = blkcipher_next_copy(walk);
+		goto set_phys_lowmem;
+	}
+
+	return blkcipher_next_fast(desc, walk);
+
+set_phys_lowmem:
+	if (walk->flags & BLKCIPHER_WALK_PHYS) {
+		walk->src.phys.page = virt_to_page(walk->src.virt.addr);
+		walk->dst.phys.page = virt_to_page(walk->dst.virt.addr);
+		walk->src.phys.offset &= PAGE_SIZE - 1;
+		walk->dst.phys.offset &= PAGE_SIZE - 1;
+	}
+	return err;
+}
+
+static inline int blkcipher_copy_iv(struct blkcipher_walk *walk,
+				    struct crypto_blkcipher *tfm,
+				    unsigned int alignmask)
+{
+	unsigned bs = crypto_blkcipher_blocksize(tfm);
+	unsigned int ivsize = crypto_blkcipher_ivsize(tfm);
+	unsigned int size = bs * 2 + ivsize + max(bs, ivsize) - (alignmask + 1);
+	u8 *iv;
+
+	size += alignmask & ~(crypto_tfm_ctx_alignment() - 1);
+	walk->buffer = kmalloc(size, GFP_ATOMIC);
+	if (!walk->buffer)
+		return -ENOMEM;
+
+	iv = (u8 *)ALIGN((unsigned long)walk->buffer, alignmask + 1);
+	iv = blkcipher_get_spot(iv, bs) + bs;
+	iv = blkcipher_get_spot(iv, bs) + bs;
+	iv = blkcipher_get_spot(iv, ivsize);
+
+	walk->iv = memcpy(iv, walk->iv, ivsize);
+	return 0;
+}
+
+int blkcipher_walk_virt(struct blkcipher_desc *desc,
+			struct blkcipher_walk *walk)
+{
+	walk->flags &= ~BLKCIPHER_WALK_PHYS;
+	return blkcipher_walk_first(desc, walk);
+}
+EXPORT_SYMBOL_GPL(blkcipher_walk_virt);
+
+int blkcipher_walk_phys(struct blkcipher_desc *desc,
+			struct blkcipher_walk *walk)
+{
+	walk->flags |= BLKCIPHER_WALK_PHYS;
+	return blkcipher_walk_first(desc, walk);
+}
+EXPORT_SYMBOL_GPL(blkcipher_walk_phys);
+
+static int blkcipher_walk_first(struct blkcipher_desc *desc,
+				struct blkcipher_walk *walk)
+{
+	struct crypto_blkcipher *tfm = desc->tfm;
+	unsigned int alignmask = crypto_blkcipher_alignmask(tfm);
+
+	walk->nbytes = walk->total;
+	if (unlikely(!walk->total))
+		return 0;
+
+	walk->buffer = NULL;
+	walk->iv = desc->info;
+	if (unlikely(((unsigned long)walk->iv & alignmask))) {
+		int err = blkcipher_copy_iv(walk, tfm, alignmask);
+		if (err)
+			return err;
+	}
+
+	scatterwalk_start(&walk->in, walk->in.sg);
+	scatterwalk_start(&walk->out, walk->out.sg);
+	walk->page = NULL;
+
+	return blkcipher_walk_next(desc, walk);
+}
+
+static int setkey(struct crypto_tfm *tfm, const u8 *key,
+		  unsigned int keylen)
+{
+	struct blkcipher_alg *cipher = &tfm->__crt_alg->cra_blkcipher;
+
+	if (keylen < cipher->min_keysize || keylen > cipher->max_keysize) {
+		tfm->crt_flags |= CRYPTO_TFM_RES_BAD_KEY_LEN;
+		return -EINVAL;
+	}
+
+	return cipher->setkey(tfm, key, keylen);
+}
+
+static unsigned int crypto_blkcipher_ctxsize(struct crypto_alg *alg)
+{
+	struct blkcipher_alg *cipher = &alg->cra_blkcipher;
+	unsigned int len = alg->cra_ctxsize;
+
+	if (cipher->ivsize) {
+		len = ALIGN(len, (unsigned long)alg->cra_alignmask + 1);
+		len += cipher->ivsize;
+	}
+
+	return len;
+}
+
+static int crypto_init_blkcipher_ops(struct crypto_tfm *tfm)
+{
+	struct blkcipher_tfm *crt = &tfm->crt_blkcipher;
+	struct blkcipher_alg *alg = &tfm->__crt_alg->cra_blkcipher;
+	unsigned long align = crypto_tfm_alg_alignmask(tfm) + 1;
+	unsigned long addr;
+
+	if (alg->ivsize > PAGE_SIZE / 8)
+		return -EINVAL;
+
+	crt->setkey = setkey;
+	crt->encrypt = alg->encrypt;
+	crt->decrypt = alg->decrypt;
+
+	addr = (unsigned long)crypto_tfm_ctx(tfm);
+	addr = ALIGN(addr, align);
+	addr += ALIGN(tfm->__crt_alg->cra_ctxsize, align);
+	crt->iv = (void *)addr;
+
+	return 0;
+}
+
+const struct crypto_type crypto_blkcipher_type = {
+	.ctxsize = crypto_blkcipher_ctxsize,
+	.init = crypto_init_blkcipher_ops,
+};
+EXPORT_SYMBOL_GPL(crypto_blkcipher_type);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Generic block chaining cipher type");
diff --git a/include/crypto/algapi.h b/include/crypto/algapi.h
--- a/include/crypto/algapi.h
+++ b/include/crypto/algapi.h
@@ -53,6 +53,34 @@ struct scatter_walk {
 	unsigned int offset;
 };
 
+struct blkcipher_walk {
+	union {
+		struct {
+			struct page *page;
+			unsigned long offset;
+		} phys;
+
+		struct {
+			u8 *page;
+			u8 *addr;
+		} virt;
+	} src, dst;
+
+	struct scatter_walk in;
+	unsigned int nbytes;
+
+	struct scatter_walk out;
+	unsigned int total;
+
+	void *page;
+	u8 *buffer;
+	u8 *iv;
+
+	int flags;
+};
+
+extern const struct crypto_type crypto_blkcipher_type;
+
 int crypto_register_template(struct crypto_template *tmpl);
 void crypto_unregister_template(struct crypto_template *tmpl);
 struct crypto_template *crypto_lookup_template(const char *name);
@@ -67,15 +95,52 @@ struct crypto_alg *crypto_get_attr_alg(v
 struct crypto_instance *crypto_alloc_instance(const char *name,
 					      struct crypto_alg *alg);
 
+int blkcipher_walk_done(struct blkcipher_desc *desc,
+			struct blkcipher_walk *walk, int err);
+int blkcipher_walk_virt(struct blkcipher_desc *desc,
+			struct blkcipher_walk *walk);
+int blkcipher_walk_phys(struct blkcipher_desc *desc,
+			struct blkcipher_walk *walk);
+
+static inline void *crypto_tfm_ctx_aligned(struct crypto_tfm *tfm)
+{
+	unsigned long addr = (unsigned long)crypto_tfm_ctx(tfm);
+	unsigned long align = crypto_tfm_alg_alignmask(tfm);
+
+	if (align <= crypto_tfm_ctx_alignment())
+		align = 1;
+	return (void *)ALIGN(addr, align);
+}
+
 static inline void *crypto_instance_ctx(struct crypto_instance *inst)
 {
 	return inst->__ctx;
 }
 
+static inline void *crypto_blkcipher_ctx(struct crypto_blkcipher *tfm)
+{
+	return crypto_tfm_ctx(&tfm->base);
+}
+
+static inline void *crypto_blkcipher_ctx_aligned(struct crypto_blkcipher *tfm)
+{
+	return crypto_tfm_ctx_aligned(&tfm->base);
+}
+
 static inline struct cipher_alg *crypto_cipher_alg(struct crypto_cipher *tfm)
 {
 	return &crypto_cipher_tfm(tfm)->__crt_alg->cra_cipher;
 }
 
+static inline void blkcipher_walk_init(struct blkcipher_walk *walk,
+				       struct scatterlist *dst,
+				       struct scatterlist *src,
+				       unsigned int nbytes)
+{
+	walk->in.sg = src;
+	walk->out.sg = dst;
+	walk->total = nbytes;
+}
+
 #endif	/* _CRYPTO_ALGAPI_H */
 
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -32,6 +32,7 @@
 #define CRYPTO_ALG_TYPE_MASK		0x0000000f
 #define CRYPTO_ALG_TYPE_CIPHER		0x00000001
 #define CRYPTO_ALG_TYPE_DIGEST		0x00000002
+#define CRYPTO_ALG_TYPE_BLKCIPHER	0x00000003
 #define CRYPTO_ALG_TYPE_COMPRESS	0x00000004
 
 #define CRYPTO_ALG_LARVAL		0x00000010
@@ -77,9 +78,16 @@
 #endif
 
 struct scatterlist;
+struct crypto_blkcipher;
 struct crypto_tfm;
 struct crypto_type;
 
+struct blkcipher_desc {
+	struct crypto_blkcipher *tfm;
+	void *info;
+	u32 flags;
+};
+
 struct cipher_desc {
 	struct crypto_tfm *tfm;
 	void (*crfn)(struct crypto_tfm *tfm, u8 *dst, const u8 *src);
@@ -92,6 +100,21 @@ struct cipher_desc {
  * Algorithms: modular crypto algorithm implementations, managed
  * via crypto_register_alg() and crypto_unregister_alg().
  */
+struct blkcipher_alg {
+	int (*setkey)(struct crypto_tfm *tfm, const u8 *key,
+	              unsigned int keylen);
+	int (*encrypt)(struct blkcipher_desc *desc,
+		       struct scatterlist *dst, struct scatterlist *src,
+		       unsigned int nbytes);
+	int (*decrypt)(struct blkcipher_desc *desc,
+		       struct scatterlist *dst, struct scatterlist *src,
+		       unsigned int nbytes);
+
+	unsigned int min_keysize;
+	unsigned int max_keysize;
+	unsigned int ivsize;
+};
+
 struct cipher_alg {
 	unsigned int cia_min_keysize;
 	unsigned int cia_max_keysize;
@@ -131,6 +154,7 @@ struct compress_alg {
 			      unsigned int slen, u8 *dst, unsigned int *dlen);
 };
 
+#define cra_blkcipher	cra_u.blkcipher
 #define cra_cipher	cra_u.cipher
 #define cra_digest	cra_u.digest
 #define cra_compress	cra_u.compress
@@ -153,6 +177,7 @@ struct crypto_alg {
 	const struct crypto_type *cra_type;
 
 	union {
+		struct blkcipher_alg blkcipher;
 		struct cipher_alg cipher;
 		struct digest_alg digest;
 		struct compress_alg compress;
@@ -189,6 +214,16 @@ static inline int crypto_alg_available(c
  * crypto_free_*(), as well as the various helpers below.
  */
 
+struct blkcipher_tfm {
+	void *iv;
+	int (*setkey)(struct crypto_tfm *tfm, const u8 *key,
+		      unsigned int keylen);
+	int (*encrypt)(struct blkcipher_desc *desc, struct scatterlist *dst,
+		       struct scatterlist *src, unsigned int nbytes);
+	int (*decrypt)(struct blkcipher_desc *desc, struct scatterlist *dst,
+		       struct scatterlist *src, unsigned int nbytes);
+};
+
 struct cipher_tfm {
 	void *cit_iv;
 	unsigned int cit_ivsize;
@@ -239,6 +274,7 @@ struct compress_tfm {
 	                      u8 *dst, unsigned int *dlen);
 };
 
+#define crt_blkcipher	crt_u.blkcipher
 #define crt_cipher	crt_u.cipher
 #define crt_digest	crt_u.digest
 #define crt_compress	crt_u.compress
@@ -248,6 +284,7 @@ struct crypto_tfm {
 	u32 crt_flags;
 	
 	union {
+		struct blkcipher_tfm blkcipher;
 		struct cipher_tfm cipher;
 		struct digest_tfm digest;
 		struct compress_tfm compress;
@@ -260,6 +297,10 @@ struct crypto_tfm {
 
 #define crypto_cipher crypto_tfm
 
+struct crypto_blkcipher {
+	struct crypto_tfm base;
+};
+
 enum {
 	CRYPTOA_UNSPEC,
 	CRYPTOA_ALG,
@@ -368,6 +409,144 @@ static inline unsigned int crypto_tfm_ct
 /*
  * API wrappers.
  */
+static inline struct crypto_blkcipher *__crypto_blkcipher_cast(
+	struct crypto_tfm *tfm)
+{
+	return (struct crypto_blkcipher *)tfm;
+}
+
+static inline struct crypto_blkcipher *crypto_blkcipher_cast(
+	struct crypto_tfm *tfm)
+{
+	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_BLKCIPHER);
+	return __crypto_blkcipher_cast(tfm);
+}
+
+static inline struct crypto_blkcipher *crypto_alloc_blkcipher(
+	const char *alg_name, u32 type, u32 mask)
+{
+	type &= ~CRYPTO_ALG_TYPE_MASK;
+	type |= CRYPTO_ALG_TYPE_BLKCIPHER;
+	mask |= CRYPTO_ALG_TYPE_MASK;
+
+	return __crypto_blkcipher_cast(crypto_alloc_base(alg_name, type, mask));
+}
+
+static inline struct crypto_tfm *crypto_blkcipher_tfm(
+	struct crypto_blkcipher *tfm)
+{
+	return &tfm->base;
+}
+
+static inline void crypto_free_blkcipher(struct crypto_blkcipher *tfm)
+{
+	crypto_free_tfm(crypto_blkcipher_tfm(tfm));
+}
+
+static inline const char *crypto_blkcipher_name(struct crypto_blkcipher *tfm)
+{
+	return crypto_tfm_alg_name(crypto_blkcipher_tfm(tfm));
+}
+
+static inline struct blkcipher_tfm *crypto_blkcipher_crt(
+	struct crypto_blkcipher *tfm)
+{
+	return &crypto_blkcipher_tfm(tfm)->crt_blkcipher;
+}
+
+static inline struct blkcipher_alg *crypto_blkcipher_alg(
+	struct crypto_blkcipher *tfm)
+{
+	return &crypto_blkcipher_tfm(tfm)->__crt_alg->cra_blkcipher;
+}
+
+static inline unsigned int crypto_blkcipher_ivsize(struct crypto_blkcipher *tfm)
+{
+	return crypto_blkcipher_alg(tfm)->ivsize;
+}
+
+static inline unsigned int crypto_blkcipher_blocksize(
+	struct crypto_blkcipher *tfm)
+{
+	return crypto_tfm_alg_blocksize(crypto_blkcipher_tfm(tfm));
+}
+
+static inline unsigned int crypto_blkcipher_alignmask(
+	struct crypto_blkcipher *tfm)
+{
+	return crypto_tfm_alg_alignmask(crypto_blkcipher_tfm(tfm));
+}
+
+static inline u32 crypto_blkcipher_get_flags(struct crypto_blkcipher *tfm)
+{
+	return crypto_tfm_get_flags(crypto_blkcipher_tfm(tfm));
+}
+
+static inline void crypto_blkcipher_set_flags(struct crypto_blkcipher *tfm,
+					      u32 flags)
+{
+	crypto_tfm_set_flags(crypto_blkcipher_tfm(tfm), flags);
+}
+
+static inline void crypto_blkcipher_clear_flags(struct crypto_blkcipher *tfm,
+						u32 flags)
+{
+	crypto_tfm_clear_flags(crypto_blkcipher_tfm(tfm), flags);
+}
+
+static inline int crypto_blkcipher_setkey(struct crypto_blkcipher *tfm,
+					  const u8 *key, unsigned int keylen)
+{
+	return crypto_blkcipher_crt(tfm)->setkey(crypto_blkcipher_tfm(tfm),
+						 key, keylen);
+}
+
+static inline int crypto_blkcipher_encrypt(struct blkcipher_desc *desc,
+					   struct scatterlist *dst,
+					   struct scatterlist *src,
+					   unsigned int nbytes)
+{
+	desc->info = crypto_blkcipher_crt(desc->tfm)->iv;
+	return crypto_blkcipher_crt(desc->tfm)->encrypt(desc, dst, src, nbytes);
+}
+
+static inline int crypto_blkcipher_encrypt_iv(struct blkcipher_desc *desc,
+					      struct scatterlist *dst,
+					      struct scatterlist *src,
+					      unsigned int nbytes)
+{
+	return crypto_blkcipher_crt(desc->tfm)->encrypt(desc, dst, src, nbytes);
+}
+
+static inline int crypto_blkcipher_decrypt(struct blkcipher_desc *desc,
+					   struct scatterlist *dst,
+					   struct scatterlist *src,
+					   unsigned int nbytes)
+{
+	desc->info = crypto_blkcipher_crt(desc->tfm)->iv;
+	return crypto_blkcipher_crt(desc->tfm)->decrypt(desc, dst, src, nbytes);
+}
+
+static inline int crypto_blkcipher_decrypt_iv(struct blkcipher_desc *desc,
+					      struct scatterlist *dst,
+					      struct scatterlist *src,
+					      unsigned int nbytes)
+{
+	return crypto_blkcipher_crt(desc->tfm)->decrypt(desc, dst, src, nbytes);
+}
+
+static inline void crypto_blkcipher_set_iv(struct crypto_blkcipher *tfm,
+					   const u8 *src, unsigned int len)
+{
+	memcpy(crypto_blkcipher_crt(tfm)->iv, src, len);
+}
+
+static inline void crypto_blkcipher_get_iv(struct crypto_blkcipher *tfm,
+					   u8 *dst, unsigned int len)
+{
+	memcpy(dst, crypto_blkcipher_crt(tfm)->iv, len);
+}
+
 static inline struct crypto_cipher *__crypto_cipher_cast(struct crypto_tfm *tfm)
 {
 	return (struct crypto_cipher *)tfm;
