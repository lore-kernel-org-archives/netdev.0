From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 7/7] crypto: aesni: add generic gcm(aes)
Date: Fri, 28 Apr 2017 18:12:02 +0200
Message-ID: <ec98d94298de0f09e0e3dedc14bc275fa7fa776f.1493395785.git.sd@queasysnail.net>
References: <cover.1493395785.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
        linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
References: <cover.1493395785.git.sd@queasysnail.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the asm side of things can support all the valid lengths of ICV
and all lengths of associated data, provide the glue code to expose a
generic gcm(aes) crypto algorithm.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 arch/x86/crypto/aesni-intel_glue.c | 208 ++++++++++++++++++++++++++++---------
 1 file changed, 158 insertions(+), 50 deletions(-)

diff --git a/arch/x86/crypto/aesni-intel_glue.c b/arch/x86/crypto/aesni-intel_glue.c
index 93de8ea51548..4a55cdcdc008 100644
--- a/arch/x86/crypto/aesni-intel_glue.c
+++ b/arch/x86/crypto/aesni-intel_glue.c
@@ -61,6 +61,11 @@ struct aesni_rfc4106_gcm_ctx {
 	u8 nonce[4];
 };
 
+struct generic_gcmaes_ctx {
+	u8 hash_subkey[16] AESNI_ALIGN_ATTR;
+	struct crypto_aes_ctx aes_key_expanded AESNI_ALIGN_ATTR;
+};
+
 struct aesni_xts_ctx {
 	u8 raw_tweak_ctx[sizeof(struct crypto_aes_ctx)] AESNI_ALIGN_ATTR;
 	u8 raw_crypt_ctx[sizeof(struct crypto_aes_ctx)] AESNI_ALIGN_ATTR;
@@ -102,13 +107,11 @@ asmlinkage void aesni_xts_crypt8(struct crypto_aes_ctx *ctx, u8 *out,
  * u8 *out, Ciphertext output. Encrypt in-place is allowed.
  * const u8 *in, Plaintext input
  * unsigned long plaintext_len, Length of data in bytes for encryption.
- * u8 *iv, Pre-counter block j0: 4 byte salt (from Security Association)
- *         concatenated with 8 byte Initialisation Vector (from IPSec ESP
- *         Payload) concatenated with 0x00000001. 16-byte aligned pointer.
+ * u8 *iv, Pre-counter block j0: 12 byte IV concatenated with 0x00000001.
+ *         16-byte aligned pointer.
  * u8 *hash_subkey, the Hash sub key input. Data starts on a 16-byte boundary.
  * const u8 *aad, Additional Authentication Data (AAD)
- * unsigned long aad_len, Length of AAD in bytes. With RFC4106 this
- *          is going to be 8 or 12 bytes
+ * unsigned long aad_len, Length of AAD in bytes.
  * u8 *auth_tag, Authenticated Tag output.
  * unsigned long auth_tag_len), Authenticated Tag Length in bytes.
  *          Valid values are 16 (most likely), 12 or 8.
@@ -123,9 +126,8 @@ asmlinkage void aesni_gcm_enc(void *ctx, u8 *out,
  * u8 *out, Plaintext output. Decrypt in-place is allowed.
  * const u8 *in, Ciphertext input
  * unsigned long ciphertext_len, Length of data in bytes for decryption.
- * u8 *iv, Pre-counter block j0: 4 byte salt (from Security Association)
- *         concatenated with 8 byte Initialisation Vector (from IPSec ESP
- *         Payload) concatenated with 0x00000001. 16-byte aligned pointer.
+ * u8 *iv, Pre-counter block j0: 12 byte IV concatenated with 0x00000001.
+ *         16-byte aligned pointer.
  * u8 *hash_subkey, the Hash sub key input. Data starts on a 16-byte boundary.
  * const u8 *aad, Additional Authentication Data (AAD)
  * unsigned long aad_len, Length of AAD in bytes. With RFC4106 this is going
@@ -275,6 +277,16 @@ aesni_rfc4106_gcm_ctx *aesni_rfc4106_gcm_ctx_get(struct crypto_aead *tfm)
 		align = 1;
 	return PTR_ALIGN(crypto_aead_ctx(tfm), align);
 }
+
+static inline struct
+generic_gcmaes_ctx *generic_gcmaes_ctx_get(struct crypto_aead *tfm)
+{
+	unsigned long align = AESNI_ALIGN;
+
+	if (align <= crypto_tfm_ctx_alignment())
+		align = 1;
+	return PTR_ALIGN(crypto_aead_ctx(tfm), align);
+}
 #endif
 
 static inline struct crypto_aes_ctx *aes_ctx(void *raw_ctx)
@@ -712,32 +724,34 @@ static int rfc4106_set_authsize(struct crypto_aead *parent,
 	return crypto_aead_setauthsize(&cryptd_tfm->base, authsize);
 }
 
-static int helper_rfc4106_encrypt(struct aead_request *req)
+static int generic_gcmaes_set_authsize(struct crypto_aead *tfm,
+				       unsigned int authsize)
+{
+	switch (authsize) {
+	case 4:
+	case 8:
+	case 12:
+	case 13:
+	case 14:
+	case 15:
+	case 16:
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int gcmaes_encrypt(struct aead_request *req, unsigned int assoclen,
+			  u8 *hash_subkey, u8 *iv, void *aes_ctx)
 {
 	u8 one_entry_in_sg = 0;
 	u8 *src, *dst, *assoc;
-	__be32 counter = cpu_to_be32(1);
 	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
-	struct aesni_rfc4106_gcm_ctx *ctx = aesni_rfc4106_gcm_ctx_get(tfm);
-	void *aes_ctx = &(ctx->aes_key_expanded);
 	unsigned long auth_tag_len = crypto_aead_authsize(tfm);
-	u8 iv[16] __attribute__ ((__aligned__(AESNI_ALIGN)));
 	struct scatter_walk src_sg_walk;
 	struct scatter_walk dst_sg_walk = {};
-	unsigned int i;
-
-	/* Assuming we are supporting rfc4106 64-bit extended */
-	/* sequence numbers We need to have the AAD length equal */
-	/* to 16 or 20 bytes */
-	if (unlikely(req->assoclen != 16 && req->assoclen != 20))
-		return -EINVAL;
-
-	/* IV below built */
-	for (i = 0; i < 4; i++)
-		*(iv+i) = ctx->nonce[i];
-	for (i = 0; i < 8; i++)
-		*(iv+4+i) = req->iv[i];
-	*((__be32 *)(iv+12)) = counter;
 
 	if (sg_is_last(req->src) &&
 	    (!PageHighMem(sg_page(req->src)) ||
@@ -768,7 +782,7 @@ static int helper_rfc4106_encrypt(struct aead_request *req)
 
 	kernel_fpu_begin();
 	aesni_gcm_enc_tfm(aes_ctx, dst, src, req->cryptlen, iv,
-			  ctx->hash_subkey, assoc, req->assoclen - 8,
+			  hash_subkey, assoc, assoclen,
 			  dst + req->cryptlen, auth_tag_len);
 	kernel_fpu_end();
 
@@ -791,37 +805,20 @@ static int helper_rfc4106_encrypt(struct aead_request *req)
 	return 0;
 }
 
-static int helper_rfc4106_decrypt(struct aead_request *req)
+static int gcmaes_decrypt(struct aead_request *req, unsigned int assoclen,
+			  u8 *hash_subkey, u8 *iv, void *aes_ctx)
 {
 	u8 one_entry_in_sg = 0;
 	u8 *src, *dst, *assoc;
 	unsigned long tempCipherLen = 0;
-	__be32 counter = cpu_to_be32(1);
-	int retval = 0;
 	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
-	struct aesni_rfc4106_gcm_ctx *ctx = aesni_rfc4106_gcm_ctx_get(tfm);
-	void *aes_ctx = &(ctx->aes_key_expanded);
 	unsigned long auth_tag_len = crypto_aead_authsize(tfm);
-	u8 iv[16] __attribute__ ((__aligned__(AESNI_ALIGN)));
 	u8 authTag[16];
 	struct scatter_walk src_sg_walk;
 	struct scatter_walk dst_sg_walk = {};
-	unsigned int i;
-
-	if (unlikely(req->assoclen != 16 && req->assoclen != 20))
-		return -EINVAL;
-
-	/* Assuming we are supporting rfc4106 64-bit extended */
-	/* sequence numbers We need to have the AAD length */
-	/* equal to 16 or 20 bytes */
+	int retval = 0;
 
 	tempCipherLen = (unsigned long)(req->cryptlen - auth_tag_len);
-	/* IV below built */
-	for (i = 0; i < 4; i++)
-		*(iv+i) = ctx->nonce[i];
-	for (i = 0; i < 8; i++)
-		*(iv+4+i) = req->iv[i];
-	*((__be32 *)(iv+12)) = counter;
 
 	if (sg_is_last(req->src) &&
 	    (!PageHighMem(sg_page(req->src)) ||
@@ -838,7 +835,6 @@ static int helper_rfc4106_decrypt(struct aead_request *req)
 			scatterwalk_start(&dst_sg_walk, req->dst);
 			dst = scatterwalk_map(&dst_sg_walk) + req->assoclen;
 		}
-
 	} else {
 		/* Allocate memory for src, dst, assoc */
 		assoc = kmalloc(req->cryptlen + req->assoclen, GFP_ATOMIC);
@@ -850,9 +846,10 @@ static int helper_rfc4106_decrypt(struct aead_request *req)
 		dst = src;
 	}
 
+
 	kernel_fpu_begin();
 	aesni_gcm_dec_tfm(aes_ctx, dst, src, tempCipherLen, iv,
-			  ctx->hash_subkey, assoc, req->assoclen - 8,
+			  hash_subkey, assoc, assoclen,
 			  authTag, auth_tag_len);
 	kernel_fpu_end();
 
@@ -875,6 +872,60 @@ static int helper_rfc4106_decrypt(struct aead_request *req)
 		kfree(assoc);
 	}
 	return retval;
+
+}
+
+static int helper_rfc4106_encrypt(struct aead_request *req)
+{
+	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
+	struct aesni_rfc4106_gcm_ctx *ctx = aesni_rfc4106_gcm_ctx_get(tfm);
+	void *aes_ctx = &(ctx->aes_key_expanded);
+	u8 iv[16] __attribute__ ((__aligned__(AESNI_ALIGN)));
+	unsigned int i;
+	__be32 counter = cpu_to_be32(1);
+
+	/* Assuming we are supporting rfc4106 64-bit extended */
+	/* sequence numbers We need to have the AAD length equal */
+	/* to 16 or 20 bytes */
+	if (unlikely(req->assoclen != 16 && req->assoclen != 20))
+		return -EINVAL;
+
+	/* IV below built */
+	for (i = 0; i < 4; i++)
+		*(iv+i) = ctx->nonce[i];
+	for (i = 0; i < 8; i++)
+		*(iv+4+i) = req->iv[i];
+	*((__be32 *)(iv+12)) = counter;
+
+	return gcmaes_encrypt(req, req->assoclen - 8, ctx->hash_subkey, iv,
+			      aes_ctx);
+}
+
+static int helper_rfc4106_decrypt(struct aead_request *req)
+{
+	__be32 counter = cpu_to_be32(1);
+	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
+	struct aesni_rfc4106_gcm_ctx *ctx = aesni_rfc4106_gcm_ctx_get(tfm);
+	void *aes_ctx = &(ctx->aes_key_expanded);
+	u8 iv[16] __attribute__ ((__aligned__(AESNI_ALIGN)));
+	unsigned int i;
+
+	if (unlikely(req->assoclen != 16 && req->assoclen != 20))
+		return -EINVAL;
+
+	/* Assuming we are supporting rfc4106 64-bit extended */
+	/* sequence numbers We need to have the AAD length */
+	/* equal to 16 or 20 bytes */
+
+	/* IV below built */
+	for (i = 0; i < 4; i++)
+		*(iv+i) = ctx->nonce[i];
+	for (i = 0; i < 8; i++)
+		*(iv+4+i) = req->iv[i];
+	*((__be32 *)(iv+12)) = counter;
+
+	return gcmaes_decrypt(req, req->assoclen - 8, ctx->hash_subkey, iv,
+			      aes_ctx);
 }
 
 static int rfc4106_encrypt(struct aead_request *req)
@@ -1035,6 +1086,46 @@ struct {
 };
 
 #ifdef CONFIG_X86_64
+static int generic_gcmaes_set_key(struct crypto_aead *aead, const u8 *key,
+				  unsigned int key_len)
+{
+	struct generic_gcmaes_ctx *ctx = generic_gcmaes_ctx_get(aead);
+
+	return aes_set_key_common(crypto_aead_tfm(aead),
+				  &ctx->aes_key_expanded, key, key_len) ?:
+	       rfc4106_set_hash_subkey(ctx->hash_subkey, key, key_len);
+}
+
+static int generic_gcmaes_encrypt(struct aead_request *req)
+{
+	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
+	struct generic_gcmaes_ctx *ctx = generic_gcmaes_ctx_get(tfm);
+	void *aes_ctx = &(ctx->aes_key_expanded);
+	u8 iv[16] __attribute__ ((__aligned__(AESNI_ALIGN)));
+	__be32 counter = cpu_to_be32(1);
+
+	memcpy(iv, req->iv, 12);
+	*((__be32 *)(iv+12)) = counter;
+
+	return gcmaes_encrypt(req, req->assoclen, ctx->hash_subkey, iv,
+			      aes_ctx);
+}
+
+static int generic_gcmaes_decrypt(struct aead_request *req)
+{
+	__be32 counter = cpu_to_be32(1);
+	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
+	struct aesni_rfc4106_gcm_ctx *ctx = aesni_rfc4106_gcm_ctx_get(tfm);
+	void *aes_ctx = &(ctx->aes_key_expanded);
+	u8 iv[16] __attribute__ ((__aligned__(AESNI_ALIGN)));
+
+	memcpy(iv, req->iv, 12);
+	*((__be32 *)(iv+12)) = counter;
+
+	return gcmaes_decrypt(req, req->assoclen, ctx->hash_subkey, iv,
+			      aes_ctx);
+}
+
 static struct aead_alg aesni_aead_algs[] = { {
 	.setkey			= common_rfc4106_set_key,
 	.setauthsize		= common_rfc4106_set_authsize,
@@ -1069,6 +1160,23 @@ static struct aead_alg aesni_aead_algs[] = { {
 		.cra_ctxsize		= sizeof(struct cryptd_aead *),
 		.cra_module		= THIS_MODULE,
 	},
+}, {
+	.setkey			= generic_gcmaes_set_key,
+	.setauthsize		= generic_gcmaes_set_authsize,
+	.encrypt		= generic_gcmaes_encrypt,
+	.decrypt		= generic_gcmaes_decrypt,
+	.ivsize			= 12,
+	.maxauthsize		= 16,
+	.base = {
+		.cra_name		= "gcm(aes)",
+		.cra_driver_name	= "generic-gcm-aesni",
+		.cra_priority		= 400,
+		.cra_flags		= CRYPTO_ALG_ASYNC,
+		.cra_blocksize		= 1,
+		.cra_ctxsize		= sizeof(struct generic_gcmaes_ctx),
+		.cra_alignmask		= AESNI_ALIGN - 1,
+		.cra_module		= THIS_MODULE,
+	},
 } };
 #else
 static struct aead_alg aesni_aead_algs[0];
-- 
2.12.2
