From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/7] [CRYPTO] digest: Remove old HMAC implementation
Date: Tue, 22 Aug 2006 00:27:59 +1000
Message-ID: <E1GFAkx-00074Z-00@gondolin.me.apana.org.au>
References: <20060821142407.GA26988@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43782 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751888AbWHUO2D
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 10:28:03 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] digest: Remove old HMAC implementation

This patch removes the old HMAC implementation now that nobody uses it
anymore.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---

 crypto/Kconfig         |    2 
 crypto/digest.c        |    3 -
 crypto/hmac.c          |  101 -------------------------------------------------
 crypto/internal.h      |   13 ------
 include/linux/crypto.h |   16 -------
 5 files changed, 2 insertions(+), 133 deletions(-)

diff --git a/crypto/Kconfig b/crypto/Kconfig
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -33,7 +33,7 @@ config CRYPTO_MANAGER
 	  cbc(aes).
 
 config CRYPTO_HMAC
-	bool "HMAC support"
+	tristate "HMAC support"
 	select CRYPTO_HASH
 	help
 	  HMAC: Keyed-Hashing for Message Authentication (RFC2104).
diff --git a/crypto/digest.c b/crypto/digest.c
--- a/crypto/digest.c
+++ b/crypto/digest.c
@@ -191,10 +191,9 @@ int crypto_init_digest_ops(struct crypto
 	ops->setkey	= dalg->dia_setkey ? setkey : nosetkey;
 	ops->digestsize	= dalg->dia_digestsize;
 	
-	return crypto_alloc_hmac_block(tfm);
+	return 0;
 }
 
 void crypto_exit_digest_ops(struct crypto_tfm *tfm)
 {
-	crypto_free_hmac_block(tfm);
 }
diff --git a/crypto/hmac.c b/crypto/hmac.c
--- a/crypto/hmac.c
+++ b/crypto/hmac.c
@@ -29,107 +29,6 @@ struct hmac_ctx {
 	struct crypto_hash *child;
 };
 
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
-	tfm->crt_hash.hmac_block = kmalloc(crypto_tfm_alg_blocksize(tfm),
-					   GFP_KERNEL);
-	if (tfm->crt_hash.hmac_block == NULL)
-		ret = -ENOMEM;
-
-	return ret;
-		
-}
-
-void crypto_free_hmac_block(struct crypto_tfm *tfm)
-{
-	kfree(tfm->crt_hash.hmac_block);
-}
-
-void crypto_hmac_init(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen)
-{
-	unsigned int i;
-	struct scatterlist tmp;
-	char *ipad = tfm->crt_hash.hmac_block;
-	
-	if (*keylen > crypto_tfm_alg_blocksize(tfm)) {
-		hash_key(tfm, key, *keylen);
-		*keylen = crypto_tfm_alg_digestsize(tfm);
-	}
-
-	memset(ipad, 0, crypto_tfm_alg_blocksize(tfm));
-	memcpy(ipad, key, *keylen);
-
-	for (i = 0; i < crypto_tfm_alg_blocksize(tfm); i++)
-		ipad[i] ^= 0x36;
-
-	sg_set_buf(&tmp, ipad, crypto_tfm_alg_blocksize(tfm));
-	
-	crypto_digest_init(tfm);
-	crypto_digest_update(tfm, &tmp, 1);
-}
-
-void crypto_hmac_update(struct crypto_tfm *tfm,
-                        struct scatterlist *sg, unsigned int nsg)
-{
-	crypto_digest_update(tfm, sg, nsg);
-}
-
-void crypto_hmac_final(struct crypto_tfm *tfm, u8 *key,
-                       unsigned int *keylen, u8 *out)
-{
-	unsigned int i;
-	struct scatterlist tmp;
-	char *opad = tfm->crt_hash.hmac_block;
-	
-	if (*keylen > crypto_tfm_alg_blocksize(tfm)) {
-		hash_key(tfm, key, *keylen);
-		*keylen = crypto_tfm_alg_digestsize(tfm);
-	}
-
-	crypto_digest_final(tfm, out);
-
-	memset(opad, 0, crypto_tfm_alg_blocksize(tfm));
-	memcpy(opad, key, *keylen);
-		
-	for (i = 0; i < crypto_tfm_alg_blocksize(tfm); i++)
-		opad[i] ^= 0x5c;
-
-	sg_set_buf(&tmp, opad, crypto_tfm_alg_blocksize(tfm));
-
-	crypto_digest_init(tfm);
-	crypto_digest_update(tfm, &tmp, 1);
-	
-	sg_set_buf(&tmp, out, crypto_tfm_alg_digestsize(tfm));
-	
-	crypto_digest_update(tfm, &tmp, 1);
-	crypto_digest_final(tfm, out);
-}
-
-void crypto_hmac(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen,
-                 struct scatterlist *sg, unsigned int nsg, u8 *out)
-{
-	crypto_hmac_init(tfm, key, keylen);
-	crypto_hmac_update(tfm, sg, nsg);
-	crypto_hmac_final(tfm, key, keylen, out);
-}
-
-EXPORT_SYMBOL_GPL(crypto_hmac_init);
-EXPORT_SYMBOL_GPL(crypto_hmac_update);
-EXPORT_SYMBOL_GPL(crypto_hmac_final);
-EXPORT_SYMBOL_GPL(crypto_hmac);
-
 static inline void *align_ptr(void *p, unsigned int align)
 {
 	return (void *)ALIGN((unsigned long)p, align);
diff --git a/crypto/internal.h b/crypto/internal.h
--- a/crypto/internal.h
+++ b/crypto/internal.h
@@ -73,19 +73,6 @@ static inline void crypto_yield(u32 flag
 		cond_resched();
 }
 
-#ifdef CONFIG_CRYPTO_HMAC
-int crypto_alloc_hmac_block(struct crypto_tfm *tfm);
-void crypto_free_hmac_block(struct crypto_tfm *tfm);
-#else
-static inline int crypto_alloc_hmac_block(struct crypto_tfm *tfm)
-{
-	return 0;
-}
-
-static inline void crypto_free_hmac_block(struct crypto_tfm *tfm)
-{ }
-#endif
-
 #ifdef CONFIG_PROC_FS
 void __init crypto_init_proc(void);
 void __exit crypto_exit_proc(void);
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -295,9 +295,6 @@ struct hash_tfm {
 		      unsigned int nsg, u8 *out);
 	int (*setkey)(struct crypto_hash *tfm, const u8 *key,
 		      unsigned int keylen);
-#ifdef CONFIG_CRYPTO_HMAC
-	void *hmac_block;
-#endif
 	unsigned int digestsize;
 };
 
@@ -872,18 +869,5 @@ static inline int crypto_comp_decompress
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
 
