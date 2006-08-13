From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 16/16] [CRYPTO] cipher: Remove obsolete block cipher operations
Date: Sun, 13 Aug 2006 22:20:30 +1000
Message-ID: <E1GCExC-0004gb-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:23305 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751103AbWHMMW1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:22:27 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] cipher: Remove obsolete block cipher operations

This patch removes obsolete block operations from the simple cipher type.
All block operations are now performed through the new block cipher type.

It also changes crypto_cipher into a proper type so that type checking
is done at compile time.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/api.c           |    4 
 crypto/cipher.c        |  430 -------------------------------------------------
 crypto/internal.h      |   13 -
 crypto/scatterwalk.h   |    7 
 include/linux/crypto.h |  134 +--------------
 5 files changed, 15 insertions(+), 573 deletions(-)

diff --git a/crypto/api.c b/crypto/api.c
--- a/crypto/api.c
+++ b/crypto/api.c
@@ -218,9 +218,6 @@ static int crypto_init_flags(struct cryp
 	flags &= ~CRYPTO_TFM_REQ_MASK;
 	
 	switch (crypto_tfm_alg_type(tfm)) {
-	case CRYPTO_ALG_TYPE_CIPHER:
-		return crypto_init_cipher_flags(tfm, flags);
-		
 	case CRYPTO_ALG_TYPE_DIGEST:
 		return crypto_init_digest_flags(tfm, flags);
 		
@@ -268,7 +265,6 @@ static void crypto_exit_ops(struct crypt
 
 	switch (crypto_tfm_alg_type(tfm)) {
 	case CRYPTO_ALG_TYPE_CIPHER:
-		crypto_exit_cipher_ops(tfm);
 		break;
 		
 	case CRYPTO_ALG_TYPE_DIGEST:
diff --git a/crypto/cipher.c b/crypto/cipher.c
--- a/crypto/cipher.c
+++ b/crypto/cipher.c
@@ -12,252 +12,12 @@
  * any later version.
  *
  */
-#include <linux/compiler.h>
+
 #include <linux/kernel.h>
 #include <linux/crypto.h>
 #include <linux/errno.h>
-#include <linux/mm.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <asm/scatterlist.h>
-#include "internal.h"
-#include "scatterwalk.h"
-
-static inline void xor_64(u8 *a, const u8 *b)
-{
-	((u32 *)a)[0] ^= ((u32 *)b)[0];
-	((u32 *)a)[1] ^= ((u32 *)b)[1];
-}
-
-static inline void xor_128(u8 *a, const u8 *b)
-{
-	((u32 *)a)[0] ^= ((u32 *)b)[0];
-	((u32 *)a)[1] ^= ((u32 *)b)[1];
-	((u32 *)a)[2] ^= ((u32 *)b)[2];
-	((u32 *)a)[3] ^= ((u32 *)b)[3];
-}
-
-static unsigned int crypt_slow(const struct cipher_desc *desc,
-			       struct scatter_walk *in,
-			       struct scatter_walk *out, unsigned int bsize)
-{
-	unsigned long alignmask = crypto_tfm_alg_alignmask(desc->tfm);
-	u8 buffer[bsize * 2 + alignmask];
-	u8 *src = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
-	u8 *dst = src + bsize;
-
-	scatterwalk_copychunks(src, in, bsize, 0);
-	desc->prfn(desc, dst, src, bsize);
-	scatterwalk_copychunks(dst, out, bsize, 1);
-
-	return bsize;
-}
-
-static inline unsigned int crypt_fast(const struct cipher_desc *desc,
-				      struct scatter_walk *in,
-				      struct scatter_walk *out,
-				      unsigned int nbytes, u8 *tmp)
-{
-	u8 *src, *dst;
-	u8 *real_src, *real_dst;
-
-	real_src = scatterwalk_map(in, 0);
-	real_dst = scatterwalk_map(out, 1);
-
-	src = real_src;
-	dst = scatterwalk_samebuf(in, out) ? src : real_dst;
-
-	if (tmp) {
-		memcpy(tmp, src, nbytes);
-		src = tmp;
-		dst = tmp;
-	}
-
-	nbytes = desc->prfn(desc, dst, src, nbytes);
-
-	if (tmp)
-		memcpy(real_dst, tmp, nbytes);
-
-	scatterwalk_unmap(real_src, 0);
-	scatterwalk_unmap(real_dst, 1);
-
-	scatterwalk_advance(in, nbytes);
-	scatterwalk_advance(out, nbytes);
-
-	return nbytes;
-}
-
-/* 
- * Generic encrypt/decrypt wrapper for ciphers, handles operations across
- * multiple page boundaries by using temporary blocks.  In user context,
- * the kernel is given a chance to schedule us once per page.
- */
-static int crypt(const struct cipher_desc *desc,
-		 struct scatterlist *dst,
-		 struct scatterlist *src,
-		 unsigned int nbytes)
-{
-	struct scatter_walk walk_in, walk_out;
-	struct crypto_tfm *tfm = desc->tfm;
-	const unsigned int bsize = crypto_tfm_alg_blocksize(tfm);
-	unsigned int alignmask = crypto_tfm_alg_alignmask(tfm);
-	unsigned long buffer = 0;
-
-	if (!nbytes)
-		return 0;
-
-	if (nbytes % bsize) {
-		tfm->crt_flags |= CRYPTO_TFM_RES_BAD_BLOCK_LEN;
-		return -EINVAL;
-	}
-
-	scatterwalk_start(&walk_in, src);
-	scatterwalk_start(&walk_out, dst);
-
-	for(;;) {
-		unsigned int n = nbytes;
-		u8 *tmp = NULL;
-
-		if (!scatterwalk_aligned(&walk_in, alignmask) ||
-		    !scatterwalk_aligned(&walk_out, alignmask)) {
-			if (!buffer) {
-				buffer = __get_free_page(GFP_ATOMIC);
-				if (!buffer)
-					n = 0;
-			}
-			tmp = (u8 *)buffer;
-		}
-
-		n = scatterwalk_clamp(&walk_in, n);
-		n = scatterwalk_clamp(&walk_out, n);
-
-		if (likely(n >= bsize))
-			n = crypt_fast(desc, &walk_in, &walk_out, n, tmp);
-		else
-			n = crypt_slow(desc, &walk_in, &walk_out, bsize);
-
-		nbytes -= n;
-
-		scatterwalk_done(&walk_in, 0, nbytes);
-		scatterwalk_done(&walk_out, 1, nbytes);
-
-		if (!nbytes)
-			break;
-
-		crypto_yield(tfm->crt_flags);
-	}
-
-	if (buffer)
-		free_page(buffer);
-
-	return 0;
-}
-
-static int crypt_iv_unaligned(struct cipher_desc *desc,
-			      struct scatterlist *dst,
-			      struct scatterlist *src,
-			      unsigned int nbytes)
-{
-	struct crypto_tfm *tfm = desc->tfm;
-	unsigned long alignmask = crypto_tfm_alg_alignmask(tfm);
-	u8 *iv = desc->info;
-
-	if (unlikely(((unsigned long)iv & alignmask))) {
-		unsigned int ivsize = tfm->crt_cipher.cit_ivsize;
-		u8 buffer[ivsize + alignmask];
-		u8 *tmp = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
-		int err;
-
-		desc->info = memcpy(tmp, iv, ivsize);
-		err = crypt(desc, dst, src, nbytes);
-		memcpy(iv, tmp, ivsize);
-
-		return err;
-	}
-
-	return crypt(desc, dst, src, nbytes);
-}
-
-static unsigned int cbc_process_encrypt(const struct cipher_desc *desc,
-					u8 *dst, const u8 *src,
-					unsigned int nbytes)
-{
-	struct crypto_tfm *tfm = desc->tfm;
-	void (*xor)(u8 *, const u8 *) = tfm->crt_u.cipher.cit_xor_block;
-	int bsize = crypto_tfm_alg_blocksize(tfm);
-
-	void (*fn)(struct crypto_tfm *, u8 *, const u8 *) = desc->crfn;
-	u8 *iv = desc->info;
-	unsigned int done = 0;
-
-	nbytes -= bsize;
-
-	do {
-		xor(iv, src);
-		fn(tfm, dst, iv);
-		memcpy(iv, dst, bsize);
-
-		src += bsize;
-		dst += bsize;
-	} while ((done += bsize) <= nbytes);
-
-	return done;
-}
-
-static unsigned int cbc_process_decrypt(const struct cipher_desc *desc,
-					u8 *dst, const u8 *src,
-					unsigned int nbytes)
-{
-	struct crypto_tfm *tfm = desc->tfm;
-	void (*xor)(u8 *, const u8 *) = tfm->crt_u.cipher.cit_xor_block;
-	int bsize = crypto_tfm_alg_blocksize(tfm);
-	unsigned long alignmask = crypto_tfm_alg_alignmask(desc->tfm);
-
-	u8 stack[src == dst ? bsize + alignmask : 0];
-	u8 *buf = (u8 *)ALIGN((unsigned long)stack, alignmask + 1);
-	u8 **dst_p = src == dst ? &buf : &dst;
-
-	void (*fn)(struct crypto_tfm *, u8 *, const u8 *) = desc->crfn;
-	u8 *iv = desc->info;
-	unsigned int done = 0;
-
-	nbytes -= bsize;
-
-	do {
-		u8 *tmp_dst = *dst_p;
-
-		fn(tfm, tmp_dst, src);
-		xor(tmp_dst, iv);
-		memcpy(iv, src, bsize);
-		if (tmp_dst != dst)
-			memcpy(dst, tmp_dst, bsize);
-
-		src += bsize;
-		dst += bsize;
-	} while ((done += bsize) <= nbytes);
-
-	return done;
-}
-
-static unsigned int ecb_process(const struct cipher_desc *desc, u8 *dst,
-				const u8 *src, unsigned int nbytes)
-{
-	struct crypto_tfm *tfm = desc->tfm;
-	int bsize = crypto_tfm_alg_blocksize(tfm);
-	void (*fn)(struct crypto_tfm *, u8 *, const u8 *) = desc->crfn;
-	unsigned int done = 0;
-
-	nbytes -= bsize;
 
-	do {
-		fn(tfm, dst, src);
-
-		src += bsize;
-		dst += bsize;
-	} while ((done += bsize) <= nbytes);
-
-	return done;
-}
+#include "internal.h"
 
 static int setkey(struct crypto_tfm *tfm, const u8 *key, unsigned int keylen)
 {
@@ -271,122 +31,6 @@ static int setkey(struct crypto_tfm *tfm
 		return cia->cia_setkey(tfm, key, keylen);
 }
 
-static int ecb_encrypt(struct crypto_tfm *tfm,
-		       struct scatterlist *dst,
-                       struct scatterlist *src, unsigned int nbytes)
-{
-	struct cipher_desc desc;
-	struct cipher_alg *cipher = &tfm->__crt_alg->cra_cipher;
-
-	desc.tfm = tfm;
-	desc.crfn = cipher->cia_encrypt;
-	desc.prfn = cipher->cia_encrypt_ecb ?: ecb_process;
-
-	return crypt(&desc, dst, src, nbytes);
-}
-
-static int ecb_decrypt(struct crypto_tfm *tfm,
-                       struct scatterlist *dst,
-                       struct scatterlist *src,
-		       unsigned int nbytes)
-{
-	struct cipher_desc desc;
-	struct cipher_alg *cipher = &tfm->__crt_alg->cra_cipher;
-
-	desc.tfm = tfm;
-	desc.crfn = cipher->cia_decrypt;
-	desc.prfn = cipher->cia_decrypt_ecb ?: ecb_process;
-
-	return crypt(&desc, dst, src, nbytes);
-}
-
-static int cbc_encrypt(struct crypto_tfm *tfm,
-                       struct scatterlist *dst,
-                       struct scatterlist *src,
-		       unsigned int nbytes)
-{
-	struct cipher_desc desc;
-	struct cipher_alg *cipher = &tfm->__crt_alg->cra_cipher;
-
-	desc.tfm = tfm;
-	desc.crfn = cipher->cia_encrypt;
-	desc.prfn = cipher->cia_encrypt_cbc ?: cbc_process_encrypt;
-	desc.info = tfm->crt_cipher.cit_iv;
-
-	return crypt(&desc, dst, src, nbytes);
-}
-
-static int cbc_encrypt_iv(struct crypto_tfm *tfm,
-                          struct scatterlist *dst,
-                          struct scatterlist *src,
-                          unsigned int nbytes, u8 *iv)
-{
-	struct cipher_desc desc;
-	struct cipher_alg *cipher = &tfm->__crt_alg->cra_cipher;
-
-	desc.tfm = tfm;
-	desc.crfn = cipher->cia_encrypt;
-	desc.prfn = cipher->cia_encrypt_cbc ?: cbc_process_encrypt;
-	desc.info = iv;
-
-	return crypt_iv_unaligned(&desc, dst, src, nbytes);
-}
-
-static int cbc_decrypt(struct crypto_tfm *tfm,
-                       struct scatterlist *dst,
-                       struct scatterlist *src,
-		       unsigned int nbytes)
-{
-	struct cipher_desc desc;
-	struct cipher_alg *cipher = &tfm->__crt_alg->cra_cipher;
-
-	desc.tfm = tfm;
-	desc.crfn = cipher->cia_decrypt;
-	desc.prfn = cipher->cia_decrypt_cbc ?: cbc_process_decrypt;
-	desc.info = tfm->crt_cipher.cit_iv;
-
-	return crypt(&desc, dst, src, nbytes);
-}
-
-static int cbc_decrypt_iv(struct crypto_tfm *tfm,
-                          struct scatterlist *dst,
-                          struct scatterlist *src,
-                          unsigned int nbytes, u8 *iv)
-{
-	struct cipher_desc desc;
-	struct cipher_alg *cipher = &tfm->__crt_alg->cra_cipher;
-
-	desc.tfm = tfm;
-	desc.crfn = cipher->cia_decrypt;
-	desc.prfn = cipher->cia_decrypt_cbc ?: cbc_process_decrypt;
-	desc.info = iv;
-
-	return crypt_iv_unaligned(&desc, dst, src, nbytes);
-}
-
-static int nocrypt(struct crypto_tfm *tfm,
-                   struct scatterlist *dst,
-                   struct scatterlist *src,
-		   unsigned int nbytes)
-{
-	return -ENOSYS;
-}
-
-static int nocrypt_iv(struct crypto_tfm *tfm,
-                      struct scatterlist *dst,
-                      struct scatterlist *src,
-                      unsigned int nbytes, u8 *iv)
-{
-	return -ENOSYS;
-}
-
-int crypto_init_cipher_flags(struct crypto_tfm *tfm, u32 flags)
-{
-	u32 mode = flags & CRYPTO_TFM_MODE_MASK;
-	tfm->crt_cipher.cit_mode = mode ? mode : CRYPTO_TFM_MODE_ECB;
-	return 0;
-}
-
 static void cipher_crypt_unaligned(void (*fn)(struct crypto_tfm *, u8 *,
 					      const u8 *),
 				   struct crypto_tfm *tfm,
@@ -432,7 +76,6 @@ static void cipher_decrypt_unaligned(str
 
 int crypto_init_cipher_ops(struct crypto_tfm *tfm)
 {
-	int ret = 0;
 	struct cipher_tfm *ops = &tfm->crt_cipher;
 	struct cipher_alg *cipher = &tfm->__crt_alg->cra_cipher;
 
@@ -442,72 +85,5 @@ int crypto_init_cipher_ops(struct crypto
 	ops->cit_decrypt_one = crypto_tfm_alg_alignmask(tfm) ?
 		cipher_decrypt_unaligned : cipher->cia_decrypt;
 
-	switch (tfm->crt_cipher.cit_mode) {
-	case CRYPTO_TFM_MODE_ECB:
-		ops->cit_encrypt = ecb_encrypt;
-		ops->cit_decrypt = ecb_decrypt;
-		ops->cit_encrypt_iv = nocrypt_iv;
-		ops->cit_decrypt_iv = nocrypt_iv;
-		break;
-		
-	case CRYPTO_TFM_MODE_CBC:
-		ops->cit_encrypt = cbc_encrypt;
-		ops->cit_decrypt = cbc_decrypt;
-		ops->cit_encrypt_iv = cbc_encrypt_iv;
-		ops->cit_decrypt_iv = cbc_decrypt_iv;
-		break;
-		
-	case CRYPTO_TFM_MODE_CFB:
-		ops->cit_encrypt = nocrypt;
-		ops->cit_decrypt = nocrypt;
-		ops->cit_encrypt_iv = nocrypt_iv;
-		ops->cit_decrypt_iv = nocrypt_iv;
-		break;
-	
-	case CRYPTO_TFM_MODE_CTR:
-		ops->cit_encrypt = nocrypt;
-		ops->cit_decrypt = nocrypt;
-		ops->cit_encrypt_iv = nocrypt_iv;
-		ops->cit_decrypt_iv = nocrypt_iv;
-		break;
-
-	default:
-		BUG();
-	}
-	
-	if (ops->cit_mode == CRYPTO_TFM_MODE_CBC) {
-		unsigned long align;
-		unsigned long addr;
-	    	
-	    	switch (crypto_tfm_alg_blocksize(tfm)) {
-	    	case 8:
-	    		ops->cit_xor_block = xor_64;
-	    		break;
-	    		
-	    	case 16:
-	    		ops->cit_xor_block = xor_128;
-	    		break;
-	    		
-	    	default:
-	    		printk(KERN_WARNING "%s: block size %u not supported\n",
-	    		       crypto_tfm_alg_name(tfm),
-	    		       crypto_tfm_alg_blocksize(tfm));
-	    		ret = -EINVAL;
-	    		goto out;
-	    	}
-	    	
-		ops->cit_ivsize = crypto_tfm_alg_blocksize(tfm);
-		align = crypto_tfm_alg_alignmask(tfm) + 1;
-		addr = (unsigned long)crypto_tfm_ctx(tfm);
-		addr = ALIGN(addr, align);
-		addr += ALIGN(tfm->__crt_alg->cra_ctxsize, align);
-		ops->cit_iv = (void *)addr;
-	}
-
-out:	
-	return ret;
-}
-
-void crypto_exit_cipher_ops(struct crypto_tfm *tfm)
-{
+	return 0;
 }
diff --git a/crypto/internal.h b/crypto/internal.h
--- a/crypto/internal.h
+++ b/crypto/internal.h
@@ -112,16 +112,7 @@ static inline unsigned int crypto_digest
 static inline unsigned int crypto_cipher_ctxsize(struct crypto_alg *alg,
 						 int flags)
 {
-	unsigned int len = alg->cra_ctxsize;
-	
-	switch (flags & CRYPTO_TFM_MODE_MASK) {
-	case CRYPTO_TFM_MODE_CBC:
-		len = ALIGN(len, (unsigned long)alg->cra_alignmask + 1);
-		len += alg->cra_blocksize;
-		break;
-	}
-
-	return len;
+	return alg->cra_ctxsize;
 }
 
 static inline unsigned int crypto_compress_ctxsize(struct crypto_alg *alg,
@@ -135,7 +126,6 @@ struct crypto_alg *__crypto_alg_lookup(c
 struct crypto_alg *crypto_alg_mod_lookup(const char *name, u32 type, u32 mask);
 
 int crypto_init_digest_flags(struct crypto_tfm *tfm, u32 flags);
-int crypto_init_cipher_flags(struct crypto_tfm *tfm, u32 flags);
 int crypto_init_compress_flags(struct crypto_tfm *tfm, u32 flags);
 
 int crypto_init_digest_ops(struct crypto_tfm *tfm);
@@ -143,7 +133,6 @@ int crypto_init_cipher_ops(struct crypto
 int crypto_init_compress_ops(struct crypto_tfm *tfm);
 
 void crypto_exit_digest_ops(struct crypto_tfm *tfm);
-void crypto_exit_cipher_ops(struct crypto_tfm *tfm);
 void crypto_exit_compress_ops(struct crypto_tfm *tfm);
 
 void crypto_larval_error(const char *name, u32 type, u32 mask);
diff --git a/crypto/scatterwalk.h b/crypto/scatterwalk.h
--- a/crypto/scatterwalk.h
+++ b/crypto/scatterwalk.h
@@ -27,13 +27,6 @@ static inline struct scatterlist *sg_nex
 	return sg + 1;
 }
 
-static inline unsigned long scatterwalk_samebuf(struct scatter_walk *walk_in,
-						struct scatter_walk *walk_out)
-{
-	return !(((walk_in->sg->page - walk_out->sg->page) << PAGE_SHIFT) +
-		 (int)(walk_in->offset - walk_out->offset));
-}
-
 static inline unsigned int scatterwalk_pagelen(struct scatter_walk *walk)
 {
 	unsigned int len = walk->sg->offset + walk->sg->length - walk->offset;
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -47,11 +47,6 @@
 #define CRYPTO_TFM_REQ_MASK		0x000fff00
 #define CRYPTO_TFM_RES_MASK		0xfff00000
 
-#define CRYPTO_TFM_MODE_ECB		0x00000001
-#define CRYPTO_TFM_MODE_CBC		0x00000002
-#define CRYPTO_TFM_MODE_CFB		0x00000004
-#define CRYPTO_TFM_MODE_CTR		0x00000008
-
 #define CRYPTO_TFM_REQ_WEAK_KEY		0x00000100
 #define CRYPTO_TFM_REQ_MAY_SLEEP	0x00000200
 #define CRYPTO_TFM_RES_WEAK_KEY		0x00100000
@@ -88,14 +83,6 @@ struct blkcipher_desc {
 	u32 flags;
 };
 
-struct cipher_desc {
-	struct crypto_tfm *tfm;
-	void (*crfn)(struct crypto_tfm *tfm, u8 *dst, const u8 *src);
-	unsigned int (*prfn)(const struct cipher_desc *desc, u8 *dst,
-			     const u8 *src, unsigned int nbytes);
-	void *info;
-};
-
 /*
  * Algorithms: modular crypto algorithm implementations, managed
  * via crypto_register_alg() and crypto_unregister_alg().
@@ -122,19 +109,6 @@ struct cipher_alg {
 	                  unsigned int keylen);
 	void (*cia_encrypt)(struct crypto_tfm *tfm, u8 *dst, const u8 *src);
 	void (*cia_decrypt)(struct crypto_tfm *tfm, u8 *dst, const u8 *src);
-
-	unsigned int (*cia_encrypt_ecb)(const struct cipher_desc *desc,
-					u8 *dst, const u8 *src,
-					unsigned int nbytes);
-	unsigned int (*cia_decrypt_ecb)(const struct cipher_desc *desc,
-					u8 *dst, const u8 *src,
-					unsigned int nbytes);
-	unsigned int (*cia_encrypt_cbc)(const struct cipher_desc *desc,
-					u8 *dst, const u8 *src,
-					unsigned int nbytes);
-	unsigned int (*cia_decrypt_cbc)(const struct cipher_desc *desc,
-					u8 *dst, const u8 *src,
-					unsigned int nbytes);
 };
 
 struct digest_alg {
@@ -225,28 +199,8 @@ struct blkcipher_tfm {
 };
 
 struct cipher_tfm {
-	void *cit_iv;
-	unsigned int cit_ivsize;
-	u32 cit_mode;
 	int (*cit_setkey)(struct crypto_tfm *tfm,
 	                  const u8 *key, unsigned int keylen);
-	int (*cit_encrypt)(struct crypto_tfm *tfm,
-			   struct scatterlist *dst,
-			   struct scatterlist *src,
-			   unsigned int nbytes);
-	int (*cit_encrypt_iv)(struct crypto_tfm *tfm,
-	                      struct scatterlist *dst,
-	                      struct scatterlist *src,
-	                      unsigned int nbytes, u8 *iv);
-	int (*cit_decrypt)(struct crypto_tfm *tfm,
-			   struct scatterlist *dst,
-			   struct scatterlist *src,
-			   unsigned int nbytes);
-	int (*cit_decrypt_iv)(struct crypto_tfm *tfm,
-			   struct scatterlist *dst,
-			   struct scatterlist *src,
-			   unsigned int nbytes, u8 *iv);
-	void (*cit_xor_block)(u8 *dst, const u8 *src);
 	void (*cit_encrypt_one)(struct crypto_tfm *tfm, u8 *dst, const u8 *src);
 	void (*cit_decrypt_one)(struct crypto_tfm *tfm, u8 *dst, const u8 *src);
 };
@@ -295,7 +249,9 @@ struct crypto_tfm {
 	void *__crt_ctx[] CRYPTO_MINALIGN_ATTR;
 };
 
-#define crypto_cipher crypto_tfm
+struct crypto_cipher {
+	struct crypto_tfm base;
+};
 
 struct crypto_blkcipher {
 	struct crypto_tfm base;
@@ -346,24 +302,6 @@ static inline u32 crypto_tfm_alg_type(st
 	return tfm->__crt_alg->cra_flags & CRYPTO_ALG_TYPE_MASK;
 }
 
-static inline unsigned int crypto_tfm_alg_min_keysize(struct crypto_tfm *tfm)
-{
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_CIPHER);
-	return tfm->__crt_alg->cra_cipher.cia_min_keysize;
-}
-
-static inline unsigned int crypto_tfm_alg_max_keysize(struct crypto_tfm *tfm)
-{
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_CIPHER);
-	return tfm->__crt_alg->cra_cipher.cia_max_keysize;
-}
-
-static inline unsigned int crypto_tfm_alg_ivsize(struct crypto_tfm *tfm)
-{
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_CIPHER);
-	return tfm->crt_cipher.cit_ivsize;
-}
-
 static inline unsigned int crypto_tfm_alg_blocksize(struct crypto_tfm *tfm)
 {
 	return tfm->__crt_alg->cra_blocksize;
@@ -570,7 +508,7 @@ static inline struct crypto_cipher *cryp
 
 static inline struct crypto_tfm *crypto_cipher_tfm(struct crypto_cipher *tfm)
 {
-	return tfm;
+	return &tfm->base;
 }
 
 static inline void crypto_free_cipher(struct crypto_cipher *tfm)
@@ -610,6 +548,13 @@ static inline void crypto_cipher_clear_f
 	crypto_tfm_clear_flags(crypto_cipher_tfm(tfm), flags);
 }
 
+static inline int crypto_cipher_setkey(struct crypto_cipher *tfm,
+				       const u8 *key, unsigned int keylen)
+{
+	return crypto_cipher_crt(tfm)->cit_setkey(crypto_cipher_tfm(tfm),
+						  key, keylen);
+}
+
 static inline void crypto_cipher_encrypt_one(struct crypto_cipher *tfm,
 					     u8 *dst, const u8 *src)
 {
@@ -659,63 +604,6 @@ static inline int crypto_digest_setkey(s
 	return tfm->crt_digest.dit_setkey(tfm, key, keylen);
 }
 
-static inline int crypto_cipher_setkey(struct crypto_tfm *tfm,
-                                       const u8 *key, unsigned int keylen)
-{
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_CIPHER);
-	return tfm->crt_cipher.cit_setkey(tfm, key, keylen);
-}
-
-static inline int crypto_cipher_encrypt(struct crypto_tfm *tfm,
-                                        struct scatterlist *dst,
-                                        struct scatterlist *src,
-                                        unsigned int nbytes)
-{
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_CIPHER);
-	return tfm->crt_cipher.cit_encrypt(tfm, dst, src, nbytes);
-}                                        
-
-static inline int crypto_cipher_encrypt_iv(struct crypto_tfm *tfm,
-                                           struct scatterlist *dst,
-                                           struct scatterlist *src,
-                                           unsigned int nbytes, u8 *iv)
-{
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_CIPHER);
-	return tfm->crt_cipher.cit_encrypt_iv(tfm, dst, src, nbytes, iv);
-}                                        
-
-static inline int crypto_cipher_decrypt(struct crypto_tfm *tfm,
-                                        struct scatterlist *dst,
-                                        struct scatterlist *src,
-                                        unsigned int nbytes)
-{
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_CIPHER);
-	return tfm->crt_cipher.cit_decrypt(tfm, dst, src, nbytes);
-}
-
-static inline int crypto_cipher_decrypt_iv(struct crypto_tfm *tfm,
-                                           struct scatterlist *dst,
-                                           struct scatterlist *src,
-                                           unsigned int nbytes, u8 *iv)
-{
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_CIPHER);
-	return tfm->crt_cipher.cit_decrypt_iv(tfm, dst, src, nbytes, iv);
-}
-
-static inline void crypto_cipher_set_iv(struct crypto_tfm *tfm,
-                                        const u8 *src, unsigned int len)
-{
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_CIPHER);
-	memcpy(tfm->crt_cipher.cit_iv, src, len);
-}
-
-static inline void crypto_cipher_get_iv(struct crypto_tfm *tfm,
-                                        u8 *dst, unsigned int len)
-{
-	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_CIPHER);
-	memcpy(dst, tfm->crt_cipher.cit_iv, len);
-}
-
 static inline int crypto_comp_compress(struct crypto_tfm *tfm,
                                        const u8 *src, unsigned int slen,
                                        u8 *dst, unsigned int *dlen)
