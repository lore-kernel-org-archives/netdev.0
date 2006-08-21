From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/7] [CRYPTO] digest: Added user API for new hash type
Date: Tue, 22 Aug 2006 00:26:11 +1000
Message-ID: <E1GFAjD-000748-00@gondolin.me.apana.org.au>
References: <20060821142407.GA26988@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] digest: Added user API for new hash type

The existing digest user interface is inadequate for support asynchronous
operations.  For one it doesn't return a value to indicate success or
failure, nor does it take a per-operation descriptor which is essential
for the issuing of requests while other requests are still outstanding.

This patch is the first in a series of steps to remodel the interface
for asynchronous operations.

For the ease of transition the new interface will be known as "hash"
while the old one will remain as "digest".

This patch also changes sg_next to allow chaining.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/Kconfig          |    4 +
 crypto/Makefile         |    3 
 crypto/digest.c         |  129 ++++++++++++++++++++++++++++--------
 crypto/hash.c           |   61 +++++++++++++++++
 crypto/hmac.c           |   12 +--
 crypto/scatterwalk.h    |    4 -
 include/crypto/algapi.h |    6 +
 include/linux/crypto.h  |  172 ++++++++++++++++++++++++++++++++++++++----------
 8 files changed, 321 insertions(+), 70 deletions(-)

diff --git a/crypto/Kconfig b/crypto/Kconfig
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -20,6 +20,10 @@ config CRYPTO_BLKCIPHER
 	tristate
 	select CRYPTO_ALGAPI
 
+config CRYPTO_HASH
+	tristate
+	select CRYPTO_ALGAPI
+
 config CRYPTO_MANAGER
 	tristate "Cryptographic algorithm manager"
 	select CRYPTO_ALGAPI
diff --git a/crypto/Makefile b/crypto/Makefile
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -10,6 +10,9 @@ obj-$(CONFIG_CRYPTO_ALGAPI) += crypto_al
 
 obj-$(CONFIG_CRYPTO_BLKCIPHER) += blkcipher.o
 
+crypto_hash-objs := hash.o
+obj-$(CONFIG_CRYPTO_HASH) += crypto_hash.o
+
 obj-$(CONFIG_CRYPTO_MANAGER) += cryptomgr.o
 obj-$(CONFIG_CRYPTO_HMAC) += hmac.o
 obj-$(CONFIG_CRYPTO_NULL) += crypto_null.o
diff --git a/crypto/digest.c b/crypto/digest.c
--- a/crypto/digest.c
+++ b/crypto/digest.c
@@ -11,29 +11,89 @@
  * any later version.
  *
  */
-#include <linux/crypto.h>
+
 #include <linux/mm.h>
 #include <linux/errno.h>
 #include <linux/highmem.h>
-#include <asm/scatterlist.h>
+#include <linux/module.h>
+#include <linux/scatterlist.h>
+
 #include "internal.h"
+#include "scatterwalk.h"
 
-static void init(struct crypto_tfm *tfm)
+void crypto_digest_init(struct crypto_tfm *tfm)
 {
-	tfm->__crt_alg->cra_digest.dia_init(tfm);
+	struct crypto_hash *hash = crypto_hash_cast(tfm);
+	struct hash_desc desc = { .tfm = hash, .flags = tfm->crt_flags };
+
+	crypto_hash_init(&desc);
 }
+EXPORT_SYMBOL_GPL(crypto_digest_init);
 
-static void update(struct crypto_tfm *tfm,
-                   struct scatterlist *sg, unsigned int nsg)
+void crypto_digest_update(struct crypto_tfm *tfm,
+			  struct scatterlist *sg, unsigned int nsg)
 {
+	struct crypto_hash *hash = crypto_hash_cast(tfm);
+	struct hash_desc desc = { .tfm = hash, .flags = tfm->crt_flags };
+	unsigned int nbytes = 0;
 	unsigned int i;
+
+	for (i = 0; i < nsg; i++)
+		nbytes += sg[i].length;
+
+	crypto_hash_update(&desc, sg, nbytes);
+}
+EXPORT_SYMBOL_GPL(crypto_digest_update);
+
+void crypto_digest_final(struct crypto_tfm *tfm, u8 *out)
+{
+	struct crypto_hash *hash = crypto_hash_cast(tfm);
+	struct hash_desc desc = { .tfm = hash, .flags = tfm->crt_flags };
+
+	crypto_hash_final(&desc, out);
+}
+EXPORT_SYMBOL_GPL(crypto_digest_final);
+
+void crypto_digest_digest(struct crypto_tfm *tfm,
+			  struct scatterlist *sg, unsigned int nsg, u8 *out)
+{
+	struct crypto_hash *hash = crypto_hash_cast(tfm);
+	struct hash_desc desc = { .tfm = hash, .flags = tfm->crt_flags };
+	unsigned int nbytes = 0;
+	unsigned int i;
+
+	for (i = 0; i < nsg; i++)
+		nbytes += sg[i].length;
+
+	crypto_hash_digest(&desc, sg, nbytes, out);
+}
+EXPORT_SYMBOL_GPL(crypto_digest_digest);
+
+static int init(struct hash_desc *desc)
+{
+	struct crypto_tfm *tfm = crypto_hash_tfm(desc->tfm);
+
+	tfm->__crt_alg->cra_digest.dia_init(tfm);
+	return 0;
+}
+
+static int update(struct hash_desc *desc,
+		  struct scatterlist *sg, unsigned int nbytes)
+{
+	struct crypto_tfm *tfm = crypto_hash_tfm(desc->tfm);
 	unsigned int alignmask = crypto_tfm_alg_alignmask(tfm);
 
-	for (i = 0; i < nsg; i++) {
+	if (!nbytes)
+		return 0;
 
-		struct page *pg = sg[i].page;
-		unsigned int offset = sg[i].offset;
-		unsigned int l = sg[i].length;
+	for (;;) {
+		struct page *pg = sg->page;
+		unsigned int offset = sg->offset;
+		unsigned int l = sg->length;
+
+		if (unlikely(l > nbytes))
+			l = nbytes;
+		nbytes -= l;
 
 		do {
 			unsigned int bytes_from_page = min(l, ((unsigned int)
@@ -55,16 +115,23 @@ static void update(struct crypto_tfm *tf
 			tfm->__crt_alg->cra_digest.dia_update(tfm, p,
 							      bytes_from_page);
 			crypto_kunmap(src, 0);
-			crypto_yield(tfm->crt_flags);
+			crypto_yield(desc->flags);
 			offset = 0;
 			pg++;
 			l -= bytes_from_page;
 		} while (l > 0);
+
+		if (!nbytes)
+			break;
+		sg = sg_next(sg);
 	}
+
+	return 0;
 }
 
-static void final(struct crypto_tfm *tfm, u8 *out)
+static int final(struct hash_desc *desc, u8 *out)
 {
+	struct crypto_tfm *tfm = crypto_hash_tfm(desc->tfm);
 	unsigned long alignmask = crypto_tfm_alg_alignmask(tfm);
 	struct digest_alg *digest = &tfm->__crt_alg->cra_digest;
 
@@ -78,26 +145,30 @@ static void final(struct crypto_tfm *tfm
 		memcpy(out, dst, digest->dia_digestsize);
 	} else
 		digest->dia_final(tfm, out);
+
+	return 0;
 }
 
-static int nosetkey(struct crypto_tfm *tfm, const u8 *key, unsigned int keylen)
+static int nosetkey(struct crypto_hash *tfm, const u8 *key, unsigned int keylen)
 {
-	tfm->crt_flags &= ~CRYPTO_TFM_RES_MASK;
+	crypto_hash_clear_flags(tfm, CRYPTO_TFM_RES_MASK);
 	return -ENOSYS;
 }
 
-static int setkey(struct crypto_tfm *tfm, const u8 *key, unsigned int keylen)
+static int setkey(struct crypto_hash *hash, const u8 *key, unsigned int keylen)
 {
-	tfm->crt_flags &= ~CRYPTO_TFM_RES_MASK;
+	struct crypto_tfm *tfm = crypto_hash_tfm(hash);
+
+	crypto_hash_clear_flags(hash, CRYPTO_TFM_RES_MASK);
 	return tfm->__crt_alg->cra_digest.dia_setkey(tfm, key, keylen);
 }
 
-static void digest(struct crypto_tfm *tfm,
-                   struct scatterlist *sg, unsigned int nsg, u8 *out)
+static int digest(struct hash_desc *desc,
+		  struct scatterlist *sg, unsigned int nbytes, u8 *out)
 {
-	init(tfm);
-	update(tfm, sg, nsg);
-	final(tfm, out);
+	init(desc);
+	update(desc, sg, nbytes);
+	return final(desc, out);
 }
 
 int crypto_init_digest_flags(struct crypto_tfm *tfm, u32 flags)
@@ -107,14 +178,18 @@ int crypto_init_digest_flags(struct cryp
 
 int crypto_init_digest_ops(struct crypto_tfm *tfm)
 {
-	struct digest_tfm *ops = &tfm->crt_digest;
+	struct hash_tfm *ops = &tfm->crt_hash;
 	struct digest_alg *dalg = &tfm->__crt_alg->cra_digest;
+
+	if (dalg->dia_digestsize > crypto_tfm_alg_blocksize(tfm))
+		return -EINVAL;
 	
-	ops->dit_init	= init;
-	ops->dit_update	= update;
-	ops->dit_final	= final;
-	ops->dit_digest	= digest;
-	ops->dit_setkey	= dalg->dia_setkey ? setkey : nosetkey;
+	ops->init	= init;
+	ops->update	= update;
+	ops->final	= final;
+	ops->digest	= digest;
+	ops->setkey	= dalg->dia_setkey ? setkey : nosetkey;
+	ops->digestsize	= dalg->dia_digestsize;
 	
 	return crypto_alloc_hmac_block(tfm);
 }
diff --git a/crypto/hash.c b/crypto/hash.c
new file mode 100644
--- /dev/null
+++ b/crypto/hash.c
@@ -0,0 +1,61 @@
+/*
+ * Cryptographic Hash operations.
+ * 
+ * Copyright (c) 2006 Herbert Xu <herbert@gondor.apana.org.au>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option) 
+ * any later version.
+ */
+
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/seq_file.h>
+
+#include "internal.h"
+
+static unsigned int crypto_hash_ctxsize(struct crypto_alg *alg)
+{
+	return alg->cra_ctxsize;
+}
+
+static int crypto_init_hash_ops(struct crypto_tfm *tfm)
+{
+	struct hash_tfm *crt = &tfm->crt_hash;
+	struct hash_alg *alg = &tfm->__crt_alg->cra_hash;
+
+	if (alg->digestsize > crypto_tfm_alg_blocksize(tfm))
+		return -EINVAL;
+
+	crt->init = alg->init;
+	crt->update = alg->update;
+	crt->final = alg->final;
+	crt->digest = alg->digest;
+	crt->setkey = alg->setkey;
+	crt->digestsize = alg->digestsize;
+
+	return 0;
+}
+
+static void crypto_hash_show(struct seq_file *m, struct crypto_alg *alg)
+	__attribute_used__;
+static void crypto_hash_show(struct seq_file *m, struct crypto_alg *alg)
+{
+	seq_printf(m, "type         : hash\n");
+	seq_printf(m, "blocksize    : %u\n", alg->cra_blocksize);
+	seq_printf(m, "digestsize   : %u\n", alg->cra_hash.digestsize);
+}
+
+const struct crypto_type crypto_hash_type = {
+	.ctxsize = crypto_hash_ctxsize,
+	.init = crypto_init_hash_ops,
+#ifdef CONFIG_PROC_FS
+	.show = crypto_hash_show,
+#endif
+};
+EXPORT_SYMBOL_GPL(crypto_hash_type);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Generic cryptographic hash type");
diff --git a/crypto/hmac.c b/crypto/hmac.c
--- a/crypto/hmac.c
+++ b/crypto/hmac.c
@@ -35,9 +35,9 @@ int crypto_alloc_hmac_block(struct crypt
 
 	BUG_ON(!crypto_tfm_alg_blocksize(tfm));
 	
-	tfm->crt_digest.dit_hmac_block = kmalloc(crypto_tfm_alg_blocksize(tfm),
-	                                         GFP_KERNEL);
-	if (tfm->crt_digest.dit_hmac_block == NULL)
+	tfm->crt_hash.hmac_block = kmalloc(crypto_tfm_alg_blocksize(tfm),
+					   GFP_KERNEL);
+	if (tfm->crt_hash.hmac_block == NULL)
 		ret = -ENOMEM;
 
 	return ret;
@@ -46,14 +46,14 @@ int crypto_alloc_hmac_block(struct crypt
 
 void crypto_free_hmac_block(struct crypto_tfm *tfm)
 {
-	kfree(tfm->crt_digest.dit_hmac_block);
+	kfree(tfm->crt_hash.hmac_block);
 }
 
 void crypto_hmac_init(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen)
 {
 	unsigned int i;
 	struct scatterlist tmp;
-	char *ipad = tfm->crt_digest.dit_hmac_block;
+	char *ipad = tfm->crt_hash.hmac_block;
 	
 	if (*keylen > crypto_tfm_alg_blocksize(tfm)) {
 		hash_key(tfm, key, *keylen);
@@ -83,7 +83,7 @@ void crypto_hmac_final(struct crypto_tfm
 {
 	unsigned int i;
 	struct scatterlist tmp;
-	char *opad = tfm->crt_digest.dit_hmac_block;
+	char *opad = tfm->crt_hash.hmac_block;
 	
 	if (*keylen > crypto_tfm_alg_blocksize(tfm)) {
 		hash_key(tfm, key, *keylen);
diff --git a/crypto/scatterwalk.h b/crypto/scatterwalk.h
--- a/crypto/scatterwalk.h
+++ b/crypto/scatterwalk.h
@@ -20,11 +20,9 @@
 
 #include "internal.h"
 
-/* Define sg_next is an inline routine now in case we want to change
-   scatterlist to a linked list later. */
 static inline struct scatterlist *sg_next(struct scatterlist *sg)
 {
-	return sg + 1;
+	return (++sg)->length ? sg : (void *)sg->page;
 }
 
 static inline unsigned long scatterwalk_samebuf(struct scatter_walk *walk_in,
diff --git a/include/crypto/algapi.h b/include/crypto/algapi.h
--- a/include/crypto/algapi.h
+++ b/include/crypto/algapi.h
@@ -82,6 +82,7 @@ struct blkcipher_walk {
 };
 
 extern const struct crypto_type crypto_blkcipher_type;
+extern const struct crypto_type crypto_hash_type;
 
 void crypto_mod_put(struct crypto_alg *alg);
 
@@ -136,6 +137,11 @@ static inline struct cipher_alg *crypto_
 	return &crypto_cipher_tfm(tfm)->__crt_alg->cra_cipher;
 }
 
+static inline void *crypto_hash_ctx_aligned(struct crypto_hash *tfm)
+{
+	return crypto_tfm_ctx_aligned(&tfm->base);
+}
+
 static inline void blkcipher_walk_init(struct blkcipher_walk *walk,
 				       struct scatterlist *dst,
 				       struct scatterlist *src,
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -31,8 +31,11 @@
 #define CRYPTO_ALG_TYPE_MASK		0x0000000f
 #define CRYPTO_ALG_TYPE_CIPHER		0x00000001
 #define CRYPTO_ALG_TYPE_DIGEST		0x00000002
-#define CRYPTO_ALG_TYPE_BLKCIPHER	0x00000003
-#define CRYPTO_ALG_TYPE_COMPRESS	0x00000004
+#define CRYPTO_ALG_TYPE_HASH		0x00000003
+#define CRYPTO_ALG_TYPE_BLKCIPHER	0x00000004
+#define CRYPTO_ALG_TYPE_COMPRESS	0x00000005
+
+#define CRYPTO_ALG_TYPE_HASH_MASK	0x0000000e
 
 #define CRYPTO_ALG_LARVAL		0x00000010
 #define CRYPTO_ALG_DEAD			0x00000020
@@ -90,6 +93,7 @@
 
 struct scatterlist;
 struct crypto_blkcipher;
+struct crypto_hash;
 struct crypto_tfm;
 struct crypto_type;
 
@@ -107,6 +111,11 @@ struct cipher_desc {
 	void *info;
 };
 
+struct hash_desc {
+	struct crypto_hash *tfm;
+	u32 flags;
+};
+
 /*
  * Algorithms: modular crypto algorithm implementations, managed
  * via crypto_register_alg() and crypto_unregister_alg().
@@ -158,6 +167,19 @@ struct digest_alg {
 	                  unsigned int keylen);
 };
 
+struct hash_alg {
+	int (*init)(struct hash_desc *desc);
+	int (*update)(struct hash_desc *desc, struct scatterlist *sg,
+		      unsigned int nbytes);
+	int (*final)(struct hash_desc *desc, u8 *out);
+	int (*digest)(struct hash_desc *desc, struct scatterlist *sg,
+		      unsigned int nbytes, u8 *out);
+	int (*setkey)(struct crypto_hash *tfm, const u8 *key,
+		      unsigned int keylen);
+
+	unsigned int digestsize;
+};
+
 struct compress_alg {
 	int (*coa_compress)(struct crypto_tfm *tfm, const u8 *src,
 			    unsigned int slen, u8 *dst, unsigned int *dlen);
@@ -168,6 +190,7 @@ struct compress_alg {
 #define cra_blkcipher	cra_u.blkcipher
 #define cra_cipher	cra_u.cipher
 #define cra_digest	cra_u.digest
+#define cra_hash	cra_u.hash
 #define cra_compress	cra_u.compress
 
 struct crypto_alg {
@@ -191,6 +214,7 @@ struct crypto_alg {
 		struct blkcipher_alg blkcipher;
 		struct cipher_alg cipher;
 		struct digest_alg digest;
+		struct hash_alg hash;
 		struct compress_alg compress;
 	} cra_u;
 
@@ -262,18 +286,19 @@ struct cipher_tfm {
 	void (*cit_decrypt_one)(struct crypto_tfm *tfm, u8 *dst, const u8 *src);
 };
 
-struct digest_tfm {
-	void (*dit_init)(struct crypto_tfm *tfm);
-	void (*dit_update)(struct crypto_tfm *tfm,
-	                   struct scatterlist *sg, unsigned int nsg);
-	void (*dit_final)(struct crypto_tfm *tfm, u8 *out);
-	void (*dit_digest)(struct crypto_tfm *tfm, struct scatterlist *sg,
-	                   unsigned int nsg, u8 *out);
-	int (*dit_setkey)(struct crypto_tfm *tfm,
-	                  const u8 *key, unsigned int keylen);
+struct hash_tfm {
+	int (*init)(struct hash_desc *desc);
+	int (*update)(struct hash_desc *desc,
+		      struct scatterlist *sg, unsigned int nsg);
+	int (*final)(struct hash_desc *desc, u8 *out);
+	int (*digest)(struct hash_desc *desc, struct scatterlist *sg,
+		      unsigned int nsg, u8 *out);
+	int (*setkey)(struct crypto_hash *tfm, const u8 *key,
+		      unsigned int keylen);
 #ifdef CONFIG_CRYPTO_HMAC
-	void *dit_hmac_block;
+	void *hmac_block;
 #endif
+	unsigned int digestsize;
 };
 
 struct compress_tfm {
@@ -287,7 +312,7 @@ struct compress_tfm {
 
 #define crt_blkcipher	crt_u.blkcipher
 #define crt_cipher	crt_u.cipher
-#define crt_digest	crt_u.digest
+#define crt_hash	crt_u.hash
 #define crt_compress	crt_u.compress
 
 struct crypto_tfm {
@@ -297,7 +322,7 @@ struct crypto_tfm {
 	union {
 		struct blkcipher_tfm blkcipher;
 		struct cipher_tfm cipher;
-		struct digest_tfm digest;
+		struct hash_tfm hash;
 		struct compress_tfm compress;
 	} crt_u;
 	
@@ -312,6 +337,10 @@ struct crypto_blkcipher {
 	struct crypto_tfm base;
 };
 
+struct crypto_hash {
+	struct crypto_tfm base;
+};
+
 enum {
 	CRYPTOA_UNSPEC,
 	CRYPTOA_ALG,
@@ -647,39 +676,114 @@ static inline void crypto_cipher_decrypt
 						dst, src);
 }
 
-static inline void crypto_digest_init(struct crypto_tfm *tfm)
+void crypto_digest_init(struct crypto_tfm *tfm);
+void crypto_digest_update(struct crypto_tfm *tfm,
+			  struct scatterlist *sg, unsigned int nsg);
+void crypto_digest_final(struct crypto_tfm *tfm, u8 *out);
+void crypto_digest_digest(struct crypto_tfm *tfm,
+			  struct scatterlist *sg, unsigned int nsg, u8 *out);
+
+static inline struct crypto_hash *__crypto_hash_cast(struct crypto_tfm *tfm)
 {
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_DIGEST);
-	tfm->crt_digest.dit_init(tfm);
+	return (struct crypto_hash *)tfm;
 }
 
-static inline void crypto_digest_update(struct crypto_tfm *tfm,
-                                        struct scatterlist *sg,
-                                        unsigned int nsg)
+static inline struct crypto_hash *crypto_hash_cast(struct crypto_tfm *tfm)
 {
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_DIGEST);
-	tfm->crt_digest.dit_update(tfm, sg, nsg);
+	BUG_ON((crypto_tfm_alg_type(tfm) ^ CRYPTO_ALG_TYPE_HASH) &
+	       CRYPTO_ALG_TYPE_HASH_MASK);
+	return __crypto_hash_cast(tfm);
 }
 
-static inline void crypto_digest_final(struct crypto_tfm *tfm, u8 *out)
+static inline int crypto_digest_setkey(struct crypto_tfm *tfm,
+                                       const u8 *key, unsigned int keylen)
 {
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_DIGEST);
-	tfm->crt_digest.dit_final(tfm, out);
+	return tfm->crt_hash.setkey(crypto_hash_cast(tfm), key, keylen);
 }
 
-static inline void crypto_digest_digest(struct crypto_tfm *tfm,
-                                        struct scatterlist *sg,
-                                        unsigned int nsg, u8 *out)
+static inline struct crypto_hash *crypto_alloc_hash(const char *alg_name,
+						    u32 type, u32 mask)
 {
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_DIGEST);
-	tfm->crt_digest.dit_digest(tfm, sg, nsg, out);
+	type &= ~CRYPTO_ALG_TYPE_MASK;
+	type |= CRYPTO_ALG_TYPE_HASH;
+	mask |= CRYPTO_ALG_TYPE_HASH_MASK;
+
+	return __crypto_hash_cast(crypto_alloc_base(alg_name, type, mask));
 }
 
-static inline int crypto_digest_setkey(struct crypto_tfm *tfm,
-                                       const u8 *key, unsigned int keylen)
+static inline struct crypto_tfm *crypto_hash_tfm(struct crypto_hash *tfm)
 {
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_DIGEST);
-	return tfm->crt_digest.dit_setkey(tfm, key, keylen);
+	return &tfm->base;
+}
+
+static inline void crypto_free_hash(struct crypto_hash *tfm)
+{
+	crypto_free_tfm(crypto_hash_tfm(tfm));
+}
+
+static inline struct hash_tfm *crypto_hash_crt(struct crypto_hash *tfm)
+{
+	return &crypto_hash_tfm(tfm)->crt_hash;
+}
+
+static inline unsigned int crypto_hash_blocksize(struct crypto_hash *tfm)
+{
+	return crypto_tfm_alg_blocksize(crypto_hash_tfm(tfm));
+}
+
+static inline unsigned int crypto_hash_alignmask(struct crypto_hash *tfm)
+{
+	return crypto_tfm_alg_alignmask(crypto_hash_tfm(tfm));
+}
+
+static inline unsigned int crypto_hash_digestsize(struct crypto_hash *tfm)
+{
+	return crypto_hash_crt(tfm)->digestsize;
+}
+
+static inline u32 crypto_hash_get_flags(struct crypto_hash *tfm)
+{
+	return crypto_tfm_get_flags(crypto_hash_tfm(tfm));
+}
+
+static inline void crypto_hash_set_flags(struct crypto_hash *tfm, u32 flags)
+{
+	crypto_tfm_set_flags(crypto_hash_tfm(tfm), flags);
+}
+
+static inline void crypto_hash_clear_flags(struct crypto_hash *tfm, u32 flags)
+{
+	crypto_tfm_clear_flags(crypto_hash_tfm(tfm), flags);
+}
+
+static inline int crypto_hash_init(struct hash_desc *desc)
+{
+	return crypto_hash_crt(desc->tfm)->init(desc);
+}
+
+static inline int crypto_hash_update(struct hash_desc *desc,
+				     struct scatterlist *sg,
+				     unsigned int nbytes)
+{
+	return crypto_hash_crt(desc->tfm)->update(desc, sg, nbytes);
+}
+
+static inline int crypto_hash_final(struct hash_desc *desc, u8 *out)
+{
+	return crypto_hash_crt(desc->tfm)->final(desc, out);
+}
+
+static inline int crypto_hash_digest(struct hash_desc *desc,
+				     struct scatterlist *sg,
+				     unsigned int nbytes, u8 *out)
+{
+	return crypto_hash_crt(desc->tfm)->digest(desc, sg, nbytes, out);
+}
+
+static inline int crypto_hash_setkey(struct crypto_hash *hash,
+				     const u8 *key, unsigned int keylen)
+{
+	return crypto_hash_crt(hash)->setkey(hash, key, keylen);
 }
 
 static int crypto_cipher_encrypt(struct crypto_tfm *tfm,
