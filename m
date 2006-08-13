From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/16] [CRYPTO] cipher: Added encrypt_one/decrypt_one
Date: Sun, 13 Aug 2006 22:20:03 +1000
Message-ID: <E1GCEwk-0004fu-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:5641 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751041AbWHMMUF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:20:05 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] cipher: Added encrypt_one/decrypt_one

This patch adds two new operations for the simple cipher that encrypts or
decrypts a single block at a time.  This will be the main interface after
the existing block operations have moved over to the new block ciphers.

It also adds the crypto_cipher type which is currently only used on the
new operations but will be extended to setkey as well once existing users
have been converted to use block ciphers where applicable.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/cipher.c         |   48 ++++++++++++++++++++++++
 include/crypto/algapi.h |    5 ++
 include/linux/crypto.h  |   96 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 149 insertions(+)

diff --git a/crypto/cipher.c b/crypto/cipher.c
--- a/crypto/cipher.c
+++ b/crypto/cipher.c
@@ -388,12 +388,60 @@ int crypto_init_cipher_flags(struct cryp
 	return 0;
 }
 
+static void cipher_crypt_unaligned(void (*fn)(struct crypto_tfm *, u8 *,
+					      const u8 *),
+				   struct crypto_tfm *tfm,
+				   u8 *dst, const u8 *src)
+{
+	unsigned long alignmask = crypto_tfm_alg_alignmask(tfm);
+	unsigned int size = crypto_tfm_alg_blocksize(tfm);
+	u8 buffer[size + alignmask];
+	u8 *tmp = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
+
+	memcpy(tmp, src, size);
+	fn(tfm, tmp, tmp);
+	memcpy(dst, tmp, size);
+}
+
+static void cipher_encrypt_unaligned(struct crypto_tfm *tfm,
+				     u8 *dst, const u8 *src)
+{
+	unsigned long alignmask = crypto_tfm_alg_alignmask(tfm);
+	struct cipher_alg *cipher = &tfm->__crt_alg->cra_cipher;
+
+	if (unlikely(((unsigned long)dst | (unsigned long)src) & alignmask)) {
+		cipher_crypt_unaligned(cipher->cia_encrypt, tfm, dst, src);
+		return;
+	}
+
+	cipher->cia_encrypt(tfm, dst, src);
+}
+
+static void cipher_decrypt_unaligned(struct crypto_tfm *tfm,
+				     u8 *dst, const u8 *src)
+{
+	unsigned long alignmask = crypto_tfm_alg_alignmask(tfm);
+	struct cipher_alg *cipher = &tfm->__crt_alg->cra_cipher;
+
+	if (unlikely(((unsigned long)dst | (unsigned long)src) & alignmask)) {
+		cipher_crypt_unaligned(cipher->cia_decrypt, tfm, dst, src);
+		return;
+	}
+
+	cipher->cia_decrypt(tfm, dst, src);
+}
+
 int crypto_init_cipher_ops(struct crypto_tfm *tfm)
 {
 	int ret = 0;
 	struct cipher_tfm *ops = &tfm->crt_cipher;
+	struct cipher_alg *cipher = &tfm->__crt_alg->cra_cipher;
 
 	ops->cit_setkey = setkey;
+	ops->cit_encrypt_one = crypto_tfm_alg_alignmask(tfm) ?
+		cipher_encrypt_unaligned : cipher->cia_encrypt;
+	ops->cit_decrypt_one = crypto_tfm_alg_alignmask(tfm) ?
+		cipher_decrypt_unaligned : cipher->cia_decrypt;
 
 	switch (tfm->crt_cipher.cit_mode) {
 	case CRYPTO_TFM_MODE_ECB:
diff --git a/include/crypto/algapi.h b/include/crypto/algapi.h
--- a/include/crypto/algapi.h
+++ b/include/crypto/algapi.h
@@ -67,5 +67,10 @@ static inline void *crypto_instance_ctx(
 	return inst->__ctx;
 }
 
+static inline struct cipher_alg *crypto_cipher_alg(struct crypto_cipher *tfm)
+{
+	return &crypto_cipher_tfm(tfm)->__crt_alg->cra_cipher;
+}
+
 #endif	/* _CRYPTO_ALGAPI_H */
 
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -212,6 +212,8 @@ struct cipher_tfm {
 			   struct scatterlist *src,
 			   unsigned int nbytes, u8 *iv);
 	void (*cit_xor_block)(u8 *dst, const u8 *src);
+	void (*cit_encrypt_one)(struct crypto_tfm *tfm, u8 *dst, const u8 *src);
+	void (*cit_decrypt_one)(struct crypto_tfm *tfm, u8 *dst, const u8 *src);
 };
 
 struct digest_tfm {
@@ -256,6 +258,8 @@ struct crypto_tfm {
 	void *__crt_ctx[] CRYPTO_MINALIGN_ATTR;
 };
 
+#define crypto_cipher crypto_tfm
+
 enum {
 	CRYPTOA_UNSPEC,
 	CRYPTOA_ALG,
@@ -335,6 +339,21 @@ static inline unsigned int crypto_tfm_al
 	return tfm->__crt_alg->cra_alignmask;
 }
 
+static inline u32 crypto_tfm_get_flags(struct crypto_tfm *tfm)
+{
+	return tfm->crt_flags;
+}
+
+static inline void crypto_tfm_set_flags(struct crypto_tfm *tfm, u32 flags)
+{
+	tfm->crt_flags |= flags;
+}
+
+static inline void crypto_tfm_clear_flags(struct crypto_tfm *tfm, u32 flags)
+{
+	tfm->crt_flags &= ~flags;
+}
+
 static inline void *crypto_tfm_ctx(struct crypto_tfm *tfm)
 {
 	return tfm->__crt_ctx;
@@ -349,6 +368,83 @@ static inline unsigned int crypto_tfm_ct
 /*
  * API wrappers.
  */
+static inline struct crypto_cipher *__crypto_cipher_cast(struct crypto_tfm *tfm)
+{
+	return (struct crypto_cipher *)tfm;
+}
+
+static inline struct crypto_cipher *crypto_cipher_cast(struct crypto_tfm *tfm)
+{
+	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_CIPHER);
+	return __crypto_cipher_cast(tfm);
+}
+
+static inline struct crypto_cipher *crypto_alloc_cipher(const char *alg_name,
+							u32 type, u32 mask)
+{
+	type &= ~CRYPTO_ALG_TYPE_MASK;
+	type |= CRYPTO_ALG_TYPE_CIPHER;
+	mask |= CRYPTO_ALG_TYPE_MASK;
+
+	return __crypto_cipher_cast(crypto_alloc_base(alg_name, type, mask));
+}
+
+static inline struct crypto_tfm *crypto_cipher_tfm(struct crypto_cipher *tfm)
+{
+	return tfm;
+}
+
+static inline void crypto_free_cipher(struct crypto_cipher *tfm)
+{
+	crypto_free_tfm(crypto_cipher_tfm(tfm));
+}
+
+static inline struct cipher_tfm *crypto_cipher_crt(struct crypto_cipher *tfm)
+{
+	return &crypto_cipher_tfm(tfm)->crt_cipher;
+}
+
+static inline unsigned int crypto_cipher_blocksize(struct crypto_cipher *tfm)
+{
+	return crypto_tfm_alg_blocksize(crypto_cipher_tfm(tfm));
+}
+
+static inline unsigned int crypto_cipher_alignmask(struct crypto_cipher *tfm)
+{
+	return crypto_tfm_alg_alignmask(crypto_cipher_tfm(tfm));
+}
+
+static inline u32 crypto_cipher_get_flags(struct crypto_cipher *tfm)
+{
+	return crypto_tfm_get_flags(crypto_cipher_tfm(tfm));
+}
+
+static inline void crypto_cipher_set_flags(struct crypto_cipher *tfm,
+					   u32 flags)
+{
+	crypto_tfm_set_flags(crypto_cipher_tfm(tfm), flags);
+}
+
+static inline void crypto_cipher_clear_flags(struct crypto_cipher *tfm,
+					     u32 flags)
+{
+	crypto_tfm_clear_flags(crypto_cipher_tfm(tfm), flags);
+}
+
+static inline void crypto_cipher_encrypt_one(struct crypto_cipher *tfm,
+					     u8 *dst, const u8 *src)
+{
+	crypto_cipher_crt(tfm)->cit_encrypt_one(crypto_cipher_tfm(tfm),
+						dst, src);
+}
+
+static inline void crypto_cipher_decrypt_one(struct crypto_cipher *tfm,
+					     u8 *dst, const u8 *src)
+{
+	crypto_cipher_crt(tfm)->cit_decrypt_one(crypto_cipher_tfm(tfm),
+						dst, src);
+}
+
 static inline void crypto_digest_init(struct crypto_tfm *tfm)
 {
 	BUG_ON(crypto_tfm_alg_type(tfm) != CRYPTO_ALG_TYPE_DIGEST);
