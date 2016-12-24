From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC PATCH 4.10 1/6] crypto/sha256: Refactor the API so it can be used without shash
Date: Fri, 23 Dec 2016 18:22:27 -0800
Message-ID: <942b91f25a63b22ec4946378a1fffe78d655cf18.1482545792.git.luto@kernel.org>
References: <cover.1482545792.git.luto@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andy Lutomirski <luto@kernel.org>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1482545792.git.luto@kernel.org>
In-Reply-To: <cover.1482545792.git.luto@kernel.org>
References: <cover.1482545792.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are some pieecs of kernel code that want to compute SHA256
directly without going through the crypto core.  Adjust the exported
API to decouple it from the crypto core.

I suspect this will very slightly speed up the SHA256 shash operations
as well by reducing the amount of indirection involved.

Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/arm/crypto/sha2-ce-glue.c      | 10 ++++---
 arch/arm/crypto/sha256_glue.c       | 23 ++++++++++-----
 arch/arm/crypto/sha256_neon_glue.c  | 34 +++++++++++----------
 arch/arm64/crypto/sha2-ce-glue.c    | 13 ++++----
 arch/arm64/crypto/sha256-glue.c     | 59 +++++++++++++++++++++----------------
 arch/x86/crypto/sha256_ssse3_glue.c | 46 +++++++++++++++++------------
 arch/x86/purgatory/purgatory.c      |  2 +-
 arch/x86/purgatory/sha256.c         | 25 ++--------------
 arch/x86/purgatory/sha256.h         | 22 --------------
 crypto/sha256_generic.c             | 50 +++++++++++++++++++++++--------
 include/crypto/sha.h                | 29 ++++++++++++++----
 include/crypto/sha256_base.h        | 40 ++++++++-----------------
 12 files changed, 184 insertions(+), 169 deletions(-)
 delete mode 100644 arch/x86/purgatory/sha256.h

diff --git a/arch/arm/crypto/sha2-ce-glue.c b/arch/arm/crypto/sha2-ce-glue.c
index 0755b2d657f3..8832c2f85591 100644
--- a/arch/arm/crypto/sha2-ce-glue.c
+++ b/arch/arm/crypto/sha2-ce-glue.c
@@ -38,7 +38,7 @@ static int sha2_ce_update(struct shash_desc *desc, const u8 *data,
 		return crypto_sha256_arm_update(desc, data, len);
 
 	kernel_neon_begin();
-	sha256_base_do_update(desc, data, len,
+	sha256_base_do_update(sctx, data, len,
 			      (sha256_block_fn *)sha2_ce_transform);
 	kernel_neon_end();
 
@@ -48,17 +48,19 @@ static int sha2_ce_update(struct shash_desc *desc, const u8 *data,
 static int sha2_ce_finup(struct shash_desc *desc, const u8 *data,
 			 unsigned int len, u8 *out)
 {
+	struct sha256_state *sctx = shash_desc_ctx(desc);
+
 	if (!may_use_simd())
 		return crypto_sha256_arm_finup(desc, data, len, out);
 
 	kernel_neon_begin();
 	if (len)
-		sha256_base_do_update(desc, data, len,
+		sha256_base_do_update(sctx, data, len,
 				      (sha256_block_fn *)sha2_ce_transform);
-	sha256_base_do_finalize(desc, (sha256_block_fn *)sha2_ce_transform);
+	sha256_base_do_finalize(sctx, (sha256_block_fn *)sha2_ce_transform);
 	kernel_neon_end();
 
-	return sha256_base_finish(desc, out);
+	return crypto_sha2_final(desc, out);
 }
 
 static int sha2_ce_final(struct shash_desc *desc, u8 *out)
diff --git a/arch/arm/crypto/sha256_glue.c b/arch/arm/crypto/sha256_glue.c
index a84e869ef900..405a29a9a9d3 100644
--- a/arch/arm/crypto/sha256_glue.c
+++ b/arch/arm/crypto/sha256_glue.c
@@ -36,27 +36,34 @@ asmlinkage void sha256_block_data_order(u32 *digest, const void *data,
 int crypto_sha256_arm_update(struct shash_desc *desc, const u8 *data,
 			     unsigned int len)
 {
+	struct sha256_state *sctx = shash_desc_ctx(desc);
+
 	/* make sure casting to sha256_block_fn() is safe */
 	BUILD_BUG_ON(offsetof(struct sha256_state, state) != 0);
 
-	return sha256_base_do_update(desc, data, len,
+	sha256_base_do_update(sctx, data, len,
 				(sha256_block_fn *)sha256_block_data_order);
+	return 0;
 }
 EXPORT_SYMBOL(crypto_sha256_arm_update);
 
-static int sha256_final(struct shash_desc *desc, u8 *out)
+static int sha256_arm_final(struct shash_desc *desc, u8 *out)
 {
-	sha256_base_do_finalize(desc,
+	struct sha256_state *sctx = shash_desc_ctx(desc);
+
+	sha256_base_do_finalize(sctx,
 				(sha256_block_fn *)sha256_block_data_order);
-	return sha256_base_finish(desc, out);
+	return crypto_sha2_final(desc, out);
 }
 
 int crypto_sha256_arm_finup(struct shash_desc *desc, const u8 *data,
 			    unsigned int len, u8 *out)
 {
-	sha256_base_do_update(desc, data, len,
+	struct sha256_state *sctx = shash_desc_ctx(desc);
+
+	sha256_base_do_update(sctx, data, len,
 			      (sha256_block_fn *)sha256_block_data_order);
-	return sha256_final(desc, out);
+	return crypto_sha2_final(desc, out);
 }
 EXPORT_SYMBOL(crypto_sha256_arm_finup);
 
@@ -64,7 +71,7 @@ static struct shash_alg algs[] = { {
 	.digestsize	=	SHA256_DIGEST_SIZE,
 	.init		=	sha256_base_init,
 	.update		=	crypto_sha256_arm_update,
-	.final		=	sha256_final,
+	.final		=	sha256_arm_final,
 	.finup		=	crypto_sha256_arm_finup,
 	.descsize	=	sizeof(struct sha256_state),
 	.base		=	{
@@ -79,7 +86,7 @@ static struct shash_alg algs[] = { {
 	.digestsize	=	SHA224_DIGEST_SIZE,
 	.init		=	sha224_base_init,
 	.update		=	crypto_sha256_arm_update,
-	.final		=	sha256_final,
+	.final		=	sha256_arm_final,
 	.finup		=	crypto_sha256_arm_finup,
 	.descsize	=	sizeof(struct sha256_state),
 	.base		=	{
diff --git a/arch/arm/crypto/sha256_neon_glue.c b/arch/arm/crypto/sha256_neon_glue.c
index 39ccd658817e..40c85d1d4c1e 100644
--- a/arch/arm/crypto/sha256_neon_glue.c
+++ b/arch/arm/crypto/sha256_neon_glue.c
@@ -29,8 +29,8 @@
 asmlinkage void sha256_block_data_order_neon(u32 *digest, const void *data,
 					     unsigned int num_blks);
 
-static int sha256_update(struct shash_desc *desc, const u8 *data,
-			 unsigned int len)
+static int sha256_neon_update(struct shash_desc *desc, const u8 *data,
+			      unsigned int len)
 {
 	struct sha256_state *sctx = shash_desc_ctx(desc);
 
@@ -39,41 +39,43 @@ static int sha256_update(struct shash_desc *desc, const u8 *data,
 		return crypto_sha256_arm_update(desc, data, len);
 
 	kernel_neon_begin();
-	sha256_base_do_update(desc, data, len,
+	sha256_base_do_update(sctx, data, len,
 			(sha256_block_fn *)sha256_block_data_order_neon);
 	kernel_neon_end();
 
 	return 0;
 }
 
-static int sha256_finup(struct shash_desc *desc, const u8 *data,
-			unsigned int len, u8 *out)
+static int sha256_neon_finup(struct shash_desc *desc, const u8 *data,
+			     unsigned int len, u8 *out)
 {
+	struct sha256_state *sctx = shash_desc_ctx(desc);
+
 	if (!may_use_simd())
 		return crypto_sha256_arm_finup(desc, data, len, out);
 
 	kernel_neon_begin();
 	if (len)
-		sha256_base_do_update(desc, data, len,
+		sha256_base_do_update(sctx, data, len,
 			(sha256_block_fn *)sha256_block_data_order_neon);
-	sha256_base_do_finalize(desc,
+	sha256_base_do_finalize(sctx,
 			(sha256_block_fn *)sha256_block_data_order_neon);
 	kernel_neon_end();
 
-	return sha256_base_finish(desc, out);
+	return crypto_sha2_final(desc, out);
 }
 
-static int sha256_final(struct shash_desc *desc, u8 *out)
+static int sha256_neon_final(struct shash_desc *desc, u8 *out)
 {
-	return sha256_finup(desc, NULL, 0, out);
+	return sha256_neon_finup(desc, NULL, 0, out);
 }
 
 struct shash_alg sha256_neon_algs[] = { {
 	.digestsize	=	SHA256_DIGEST_SIZE,
 	.init		=	sha256_base_init,
-	.update		=	sha256_update,
-	.final		=	sha256_final,
-	.finup		=	sha256_finup,
+	.update		=	sha256_neon_update,
+	.final		=	sha256_neon_final,
+	.finup		=	sha256_neon_finup,
 	.descsize	=	sizeof(struct sha256_state),
 	.base		=	{
 		.cra_name	=	"sha256",
@@ -86,9 +88,9 @@ struct shash_alg sha256_neon_algs[] = { {
 }, {
 	.digestsize	=	SHA224_DIGEST_SIZE,
 	.init		=	sha224_base_init,
-	.update		=	sha256_update,
-	.final		=	sha256_final,
-	.finup		=	sha256_finup,
+	.update		=	sha256_neon_update,
+	.final		=	sha256_neon_final,
+	.finup		=	sha256_neon_finup,
 	.descsize	=	sizeof(struct sha256_state),
 	.base		=	{
 		.cra_name	=	"sha224",
diff --git a/arch/arm64/crypto/sha2-ce-glue.c b/arch/arm64/crypto/sha2-ce-glue.c
index 7cd587564a41..e38dd301abce 100644
--- a/arch/arm64/crypto/sha2-ce-glue.c
+++ b/arch/arm64/crypto/sha2-ce-glue.c
@@ -39,7 +39,7 @@ static int sha256_ce_update(struct shash_desc *desc, const u8 *data,
 
 	sctx->finalize = 0;
 	kernel_neon_begin_partial(28);
-	sha256_base_do_update(desc, data, len,
+	sha256_base_do_update(&sctx->sst, data, len,
 			      (sha256_block_fn *)sha2_ce_transform);
 	kernel_neon_end();
 
@@ -64,13 +64,13 @@ static int sha256_ce_finup(struct shash_desc *desc, const u8 *data,
 	sctx->finalize = finalize;
 
 	kernel_neon_begin_partial(28);
-	sha256_base_do_update(desc, data, len,
+	sha256_base_do_update(&sctx->sst, data, len,
 			      (sha256_block_fn *)sha2_ce_transform);
 	if (!finalize)
-		sha256_base_do_finalize(desc,
+		sha256_base_do_finalize(&sctx->sst,
 					(sha256_block_fn *)sha2_ce_transform);
 	kernel_neon_end();
-	return sha256_base_finish(desc, out);
+	return crypto_sha2_final(desc, out);
 }
 
 static int sha256_ce_final(struct shash_desc *desc, u8 *out)
@@ -79,9 +79,10 @@ static int sha256_ce_final(struct shash_desc *desc, u8 *out)
 
 	sctx->finalize = 0;
 	kernel_neon_begin_partial(28);
-	sha256_base_do_finalize(desc, (sha256_block_fn *)sha2_ce_transform);
+	sha256_base_do_finalize(&sctx->sst,
+				(sha256_block_fn *)sha2_ce_transform);
 	kernel_neon_end();
-	return sha256_base_finish(desc, out);
+	return crypto_sha2_final(desc, out);
 }
 
 static struct shash_alg algs[] = { {
diff --git a/arch/arm64/crypto/sha256-glue.c b/arch/arm64/crypto/sha256-glue.c
index a2226f841960..132a1ef89a71 100644
--- a/arch/arm64/crypto/sha256-glue.c
+++ b/arch/arm64/crypto/sha256-glue.c
@@ -33,36 +33,39 @@ asmlinkage void sha256_block_data_order(u32 *digest, const void *data,
 asmlinkage void sha256_block_neon(u32 *digest, const void *data,
 				  unsigned int num_blks);
 
-static int sha256_update(struct shash_desc *desc, const u8 *data,
-			 unsigned int len)
+static int sha256_update_arm64(struct shash_desc *desc, const u8 *data,
+			       unsigned int len)
 {
-	return sha256_base_do_update(desc, data, len,
-				(sha256_block_fn *)sha256_block_data_order);
+	sha256_base_do_update(shash_desc_ctx(desc), data, len,
+			      (sha256_block_fn *)sha256_block_data_order);
+	return 0;
 }
 
-static int sha256_finup(struct shash_desc *desc, const u8 *data,
-			unsigned int len, u8 *out)
+static int sha256_finup_arm64(struct shash_desc *desc, const u8 *data,
+			      unsigned int len, u8 *out)
 {
+	struct sha256_state *sctx = shash_desc_ctx(desc);
+
 	if (len)
-		sha256_base_do_update(desc, data, len,
+		sha256_base_do_update(sctx, data, len,
 				(sha256_block_fn *)sha256_block_data_order);
-	sha256_base_do_finalize(desc,
+	sha256_base_do_finalize(sctx,
 				(sha256_block_fn *)sha256_block_data_order);
 
-	return sha256_base_finish(desc, out);
+	return crypto_sha2_final(desc, out);
 }
 
-static int sha256_final(struct shash_desc *desc, u8 *out)
+static int sha256_final_arm64(struct shash_desc *desc, u8 *out)
 {
-	return sha256_finup(desc, NULL, 0, out);
+	return sha256_finup_arm64(desc, NULL, 0, out);
 }
 
 static struct shash_alg algs[] = { {
 	.digestsize		= SHA256_DIGEST_SIZE,
 	.init			= sha256_base_init,
-	.update			= sha256_update,
-	.final			= sha256_final,
-	.finup			= sha256_finup,
+	.update			= sha256_update_arm64,
+	.final			= sha256_final_arm64,
+	.finup			= sha256_finup_arm64,
 	.descsize		= sizeof(struct sha256_state),
 	.base.cra_name		= "sha256",
 	.base.cra_driver_name	= "sha256-arm64",
@@ -73,9 +76,9 @@ static struct shash_alg algs[] = { {
 }, {
 	.digestsize		= SHA224_DIGEST_SIZE,
 	.init			= sha224_base_init,
-	.update			= sha256_update,
-	.final			= sha256_final,
-	.finup			= sha256_finup,
+	.update			= sha256_update_arm64,
+	.final			= sha256_final_arm64,
+	.finup			= sha256_finup_arm64,
 	.descsize		= sizeof(struct sha256_state),
 	.base.cra_name		= "sha224",
 	.base.cra_driver_name	= "sha224-arm64",
@@ -88,18 +91,22 @@ static struct shash_alg algs[] = { {
 static int sha256_update_neon(struct shash_desc *desc, const u8 *data,
 			      unsigned int len)
 {
+	struct sha256_state *sctx = shash_desc_ctx(desc);
+
 	/*
 	 * Stacking and unstacking a substantial slice of the NEON register
 	 * file may significantly affect performance for small updates when
 	 * executing in interrupt context, so fall back to the scalar code
 	 * in that case.
 	 */
-	if (!may_use_simd())
-		return sha256_base_do_update(desc, data, len,
+	if (!may_use_simd()) {
+		sha256_base_do_update(sctx, data, len,
 				(sha256_block_fn *)sha256_block_data_order);
+		return 0;
+	}
 
 	kernel_neon_begin();
-	sha256_base_do_update(desc, data, len,
+	sha256_base_do_update(sctx, data, len,
 				(sha256_block_fn *)sha256_block_neon);
 	kernel_neon_end();
 
@@ -109,22 +116,24 @@ static int sha256_update_neon(struct shash_desc *desc, const u8 *data,
 static int sha256_finup_neon(struct shash_desc *desc, const u8 *data,
 			     unsigned int len, u8 *out)
 {
+	struct sha256_state *sctx = shash_desc_ctx(desc);
+
 	if (!may_use_simd()) {
 		if (len)
-			sha256_base_do_update(desc, data, len,
+			sha256_base_do_update(sctx, data, len,
 				(sha256_block_fn *)sha256_block_data_order);
-		sha256_base_do_finalize(desc,
+		sha256_base_do_finalize(sctx,
 				(sha256_block_fn *)sha256_block_data_order);
 	} else {
 		kernel_neon_begin();
 		if (len)
-			sha256_base_do_update(desc, data, len,
+			sha256_base_do_update(sctx, data, len,
 				(sha256_block_fn *)sha256_block_neon);
-		sha256_base_do_finalize(desc,
+		sha256_base_do_finalize(sctx,
 				(sha256_block_fn *)sha256_block_neon);
 		kernel_neon_end();
 	}
-	return sha256_base_finish(desc, out);
+	return crypto_sha2_final(desc, out);
 }
 
 static int sha256_final_neon(struct shash_desc *desc, u8 *out)
diff --git a/arch/x86/crypto/sha256_ssse3_glue.c b/arch/x86/crypto/sha256_ssse3_glue.c
index 9e79baf03a4b..e722fbaf0558 100644
--- a/arch/x86/crypto/sha256_ssse3_glue.c
+++ b/arch/x86/crypto/sha256_ssse3_glue.c
@@ -44,52 +44,60 @@ asmlinkage void sha256_transform_ssse3(u32 *digest, const char *data,
 				       u64 rounds);
 typedef void (sha256_transform_fn)(u32 *digest, const char *data, u64 rounds);
 
-static int sha256_update(struct shash_desc *desc, const u8 *data,
-			 unsigned int len, sha256_transform_fn *sha256_xform)
+static int sha256_fpu_update(struct shash_desc *desc, const u8 *data,
+			       unsigned int len,
+			       sha256_transform_fn *sha256_xform)
 {
 	struct sha256_state *sctx = shash_desc_ctx(desc);
 
 	if (!irq_fpu_usable() ||
-	    (sctx->count % SHA256_BLOCK_SIZE) + len < SHA256_BLOCK_SIZE)
-		return crypto_sha256_update(desc, data, len);
+	    (sctx->count % SHA256_BLOCK_SIZE) + len < SHA256_BLOCK_SIZE) {
+		sha256_update(sctx, data, len);
+		return 0;
+	}
 
 	/* make sure casting to sha256_block_fn() is safe */
 	BUILD_BUG_ON(offsetof(struct sha256_state, state) != 0);
 
 	kernel_fpu_begin();
-	sha256_base_do_update(desc, data, len,
+	sha256_base_do_update(sctx, data, len,
 			      (sha256_block_fn *)sha256_xform);
 	kernel_fpu_end();
 
 	return 0;
 }
 
-static int sha256_finup(struct shash_desc *desc, const u8 *data,
+static int sha256_fpu_finup(struct shash_desc *desc, const u8 *data,
 	      unsigned int len, u8 *out, sha256_transform_fn *sha256_xform)
 {
-	if (!irq_fpu_usable())
-		return crypto_sha256_finup(desc, data, len, out);
+	struct sha256_state *sctx = shash_desc_ctx(desc);
+
+	if (!irq_fpu_usable()) {
+		sha256_finup(sctx, data, len, out);
+		return 0;
+	}
 
 	kernel_fpu_begin();
 	if (len)
-		sha256_base_do_update(desc, data, len,
+		sha256_base_do_update(sctx, data, len,
 				      (sha256_block_fn *)sha256_xform);
-	sha256_base_do_finalize(desc, (sha256_block_fn *)sha256_xform);
+	sha256_base_do_finalize(sctx, (sha256_block_fn *)sha256_xform);
 	kernel_fpu_end();
 
-	return sha256_base_finish(desc, out);
+	crypto_sha2_final(desc, out);
+	return 0;
 }
 
 static int sha256_ssse3_update(struct shash_desc *desc, const u8 *data,
 			 unsigned int len)
 {
-	return sha256_update(desc, data, len, sha256_transform_ssse3);
+	return sha256_fpu_update(desc, data, len, sha256_transform_ssse3);
 }
 
 static int sha256_ssse3_finup(struct shash_desc *desc, const u8 *data,
 	      unsigned int len, u8 *out)
 {
-	return sha256_finup(desc, data, len, out, sha256_transform_ssse3);
+	return sha256_fpu_finup(desc, data, len, out, sha256_transform_ssse3);
 }
 
 /* Add padding and return the message digest. */
@@ -152,13 +160,13 @@ asmlinkage void sha256_transform_avx(u32 *digest, const char *data,
 static int sha256_avx_update(struct shash_desc *desc, const u8 *data,
 			 unsigned int len)
 {
-	return sha256_update(desc, data, len, sha256_transform_avx);
+	return sha256_fpu_update(desc, data, len, sha256_transform_avx);
 }
 
 static int sha256_avx_finup(struct shash_desc *desc, const u8 *data,
 		      unsigned int len, u8 *out)
 {
-	return sha256_finup(desc, data, len, out, sha256_transform_avx);
+	return sha256_fpu_finup(desc, data, len, out, sha256_transform_avx);
 }
 
 static int sha256_avx_final(struct shash_desc *desc, u8 *out)
@@ -236,13 +244,13 @@ asmlinkage void sha256_transform_rorx(u32 *digest, const char *data,
 static int sha256_avx2_update(struct shash_desc *desc, const u8 *data,
 			 unsigned int len)
 {
-	return sha256_update(desc, data, len, sha256_transform_rorx);
+	return sha256_fpu_update(desc, data, len, sha256_transform_rorx);
 }
 
 static int sha256_avx2_finup(struct shash_desc *desc, const u8 *data,
 		      unsigned int len, u8 *out)
 {
-	return sha256_finup(desc, data, len, out, sha256_transform_rorx);
+	return sha256_fpu_finup(desc, data, len, out, sha256_transform_rorx);
 }
 
 static int sha256_avx2_final(struct shash_desc *desc, u8 *out)
@@ -318,13 +326,13 @@ asmlinkage void sha256_ni_transform(u32 *digest, const char *data,
 static int sha256_ni_update(struct shash_desc *desc, const u8 *data,
 			 unsigned int len)
 {
-	return sha256_update(desc, data, len, sha256_ni_transform);
+	return sha256_fpu_update(desc, data, len, sha256_ni_transform);
 }
 
 static int sha256_ni_finup(struct shash_desc *desc, const u8 *data,
 		      unsigned int len, u8 *out)
 {
-	return sha256_finup(desc, data, len, out, sha256_ni_transform);
+	return sha256_fpu_finup(desc, data, len, out, sha256_ni_transform);
 }
 
 static int sha256_ni_final(struct shash_desc *desc, u8 *out)
diff --git a/arch/x86/purgatory/purgatory.c b/arch/x86/purgatory/purgatory.c
index 25e068ba3382..ed6e80b844cf 100644
--- a/arch/x86/purgatory/purgatory.c
+++ b/arch/x86/purgatory/purgatory.c
@@ -10,7 +10,7 @@
  * Version 2.  See the file COPYING for more details.
  */
 
-#include "sha256.h"
+#include <crypto/sha.h>
 #include "../boot/string.h"
 
 struct sha_region {
diff --git a/arch/x86/purgatory/sha256.c b/arch/x86/purgatory/sha256.c
index 548ca675a14a..724925d5da61 100644
--- a/arch/x86/purgatory/sha256.c
+++ b/arch/x86/purgatory/sha256.c
@@ -17,7 +17,7 @@
 
 #include <linux/bitops.h>
 #include <asm/byteorder.h>
-#include "sha256.h"
+#include <crypto/sha.h>
 #include "../boot/string.h"
 
 static inline u32 Ch(u32 x, u32 y, u32 z)
@@ -208,22 +208,7 @@ static void sha256_transform(u32 *state, const u8 *input)
 	memset(W, 0, 64 * sizeof(u32));
 }
 
-int sha256_init(struct sha256_state *sctx)
-{
-	sctx->state[0] = SHA256_H0;
-	sctx->state[1] = SHA256_H1;
-	sctx->state[2] = SHA256_H2;
-	sctx->state[3] = SHA256_H3;
-	sctx->state[4] = SHA256_H4;
-	sctx->state[5] = SHA256_H5;
-	sctx->state[6] = SHA256_H6;
-	sctx->state[7] = SHA256_H7;
-	sctx->count = 0;
-
-	return 0;
-}
-
-int sha256_update(struct sha256_state *sctx, const u8 *data, unsigned int len)
+void sha256_update(struct sha256_state *sctx, const u8 *data, unsigned int len)
 {
 	unsigned int partial, done;
 	const u8 *src;
@@ -249,11 +234,9 @@ int sha256_update(struct sha256_state *sctx, const u8 *data, unsigned int len)
 		partial = 0;
 	}
 	memcpy(sctx->buf + partial, src, len - done);
-
-	return 0;
 }
 
-int sha256_final(struct sha256_state *sctx, u8 *out)
+void sha256_final(struct sha256_state *sctx, u8 *out)
 {
 	__be32 *dst = (__be32 *)out;
 	__be64 bits;
@@ -278,6 +261,4 @@ int sha256_final(struct sha256_state *sctx, u8 *out)
 
 	/* Zeroize sensitive information. */
 	memset(sctx, 0, sizeof(*sctx));
-
-	return 0;
 }
diff --git a/arch/x86/purgatory/sha256.h b/arch/x86/purgatory/sha256.h
deleted file mode 100644
index bd15a4127735..000000000000
--- a/arch/x86/purgatory/sha256.h
+++ /dev/null
@@ -1,22 +0,0 @@
-/*
- *  Copyright (C) 2014 Red Hat Inc.
- *
- *  Author: Vivek Goyal <vgoyal@redhat.com>
- *
- * This source code is licensed under the GNU General Public License,
- * Version 2.  See the file COPYING for more details.
- */
-
-#ifndef SHA256_H
-#define SHA256_H
-
-
-#include <linux/types.h>
-#include <crypto/sha.h>
-
-extern int sha256_init(struct sha256_state *sctx);
-extern int sha256_update(struct sha256_state *sctx, const u8 *input,
-				unsigned int length);
-extern int sha256_final(struct sha256_state *sctx, u8 *hash);
-
-#endif /* SHA256_H */
diff --git a/crypto/sha256_generic.c b/crypto/sha256_generic.c
index 8f9c47e1a96e..f2747893402c 100644
--- a/crypto/sha256_generic.c
+++ b/crypto/sha256_generic.c
@@ -231,6 +231,13 @@ static void sha256_transform(u32 *state, const u8 *input)
 	memzero_explicit(W, 64 * sizeof(u32));
 }
 
+int sha256_base_init(struct shash_desc *desc)
+{
+	sha256_init(shash_desc_ctx(desc));
+	return 0;
+}
+EXPORT_SYMBOL(sha256_base_init);
+
 static void sha256_generic_block_fn(struct sha256_state *sst, u8 const *src,
 				    int blocks)
 {
@@ -240,32 +247,49 @@ static void sha256_generic_block_fn(struct sha256_state *sst, u8 const *src,
 	}
 }
 
-int crypto_sha256_update(struct shash_desc *desc, const u8 *data,
+void sha256_update(struct sha256_state *sctx, const u8 *data,
 			  unsigned int len)
 {
-	return sha256_base_do_update(desc, data, len, sha256_generic_block_fn);
+	sha256_base_do_update(sctx, data, len, sha256_generic_block_fn);
+}
+EXPORT_SYMBOL(sha256_update);
+
+void sha256_final(struct sha256_state *sctx, u8 *out)
+{
+	sha256_base_do_finalize(sctx, sha256_generic_block_fn);
+	sha256_base_finish(sctx, out);
 }
-EXPORT_SYMBOL(crypto_sha256_update);
+EXPORT_SYMBOL(sha256_final);
 
-static int sha256_final(struct shash_desc *desc, u8 *out)
+static int crypto_sha256_update(struct shash_desc *desc, const u8 *data,
+				unsigned int len)
 {
-	sha256_base_do_finalize(desc, sha256_generic_block_fn);
-	return sha256_base_finish(desc, out);
+	sha256_update(shash_desc_ctx(desc), data, len);
+	return 0;
+}
+
+int crypto_sha2_final(struct shash_desc *desc, u8 *out)
+{
+	struct sha256_state *sctx = shash_desc_ctx(desc);
+
+	sha256_base_do_finalize(sctx, sha256_generic_block_fn);
+	sha2_base_finish(sctx, crypto_shash_digestsize(desc->tfm), out);
+	return 0;
 }
+EXPORT_SYMBOL(crypto_sha2_final);
 
-int crypto_sha256_finup(struct shash_desc *desc, const u8 *data,
-			unsigned int len, u8 *hash)
+static int crypto_sha256_finup(struct shash_desc *desc, const u8 *data,
+			       unsigned int len, u8 *hash)
 {
-	sha256_base_do_update(desc, data, len, sha256_generic_block_fn);
-	return sha256_final(desc, hash);
+	sha256_finup(shash_desc_ctx(desc), data, len, hash);
+	return 0;
 }
-EXPORT_SYMBOL(crypto_sha256_finup);
 
 static struct shash_alg sha256_algs[2] = { {
 	.digestsize	=	SHA256_DIGEST_SIZE,
 	.init		=	sha256_base_init,
 	.update		=	crypto_sha256_update,
-	.final		=	sha256_final,
+	.final		=	crypto_sha2_final,
 	.finup		=	crypto_sha256_finup,
 	.descsize	=	sizeof(struct sha256_state),
 	.base		=	{
@@ -279,7 +303,7 @@ static struct shash_alg sha256_algs[2] = { {
 	.digestsize	=	SHA224_DIGEST_SIZE,
 	.init		=	sha224_base_init,
 	.update		=	crypto_sha256_update,
-	.final		=	sha256_final,
+	.final		=	crypto_sha2_final,
 	.finup		=	crypto_sha256_finup,
 	.descsize	=	sizeof(struct sha256_state),
 	.base		=	{
diff --git a/include/crypto/sha.h b/include/crypto/sha.h
index c94d3eb1cefd..2b6978471605 100644
--- a/include/crypto/sha.h
+++ b/include/crypto/sha.h
@@ -96,11 +96,30 @@ extern int crypto_sha1_update(struct shash_desc *desc, const u8 *data,
 extern int crypto_sha1_finup(struct shash_desc *desc, const u8 *data,
 			     unsigned int len, u8 *hash);
 
-extern int crypto_sha256_update(struct shash_desc *desc, const u8 *data,
-			      unsigned int len);
-
-extern int crypto_sha256_finup(struct shash_desc *desc, const u8 *data,
-			       unsigned int len, u8 *hash);
+static inline void sha256_init(struct sha256_state *sctx)
+{
+	sctx->state[0] = SHA256_H0;
+	sctx->state[1] = SHA256_H1;
+	sctx->state[2] = SHA256_H2;
+	sctx->state[3] = SHA256_H3;
+	sctx->state[4] = SHA256_H4;
+	sctx->state[5] = SHA256_H5;
+	sctx->state[6] = SHA256_H6;
+	sctx->state[7] = SHA256_H7;
+	sctx->count = 0;
+}
+
+extern void sha256_update(struct sha256_state *sctx, const u8 *data,
+			  unsigned int len);
+
+extern void sha256_final(struct sha256_state *sctx, u8 *out);
+
+static inline void sha256_finup(struct sha256_state *sctx, const u8 *data,
+				unsigned int len, u8 *hash)
+{
+	sha256_update(sctx, data, len);
+	sha256_final(sctx, hash);
+}
 
 extern int crypto_sha512_update(struct shash_desc *desc, const u8 *data,
 			      unsigned int len);
diff --git a/include/crypto/sha256_base.h b/include/crypto/sha256_base.h
index d1f2195bb7de..f65d9a516b36 100644
--- a/include/crypto/sha256_base.h
+++ b/include/crypto/sha256_base.h
@@ -35,29 +35,13 @@ static inline int sha224_base_init(struct shash_desc *desc)
 	return 0;
 }
 
-static inline int sha256_base_init(struct shash_desc *desc)
-{
-	struct sha256_state *sctx = shash_desc_ctx(desc);
-
-	sctx->state[0] = SHA256_H0;
-	sctx->state[1] = SHA256_H1;
-	sctx->state[2] = SHA256_H2;
-	sctx->state[3] = SHA256_H3;
-	sctx->state[4] = SHA256_H4;
-	sctx->state[5] = SHA256_H5;
-	sctx->state[6] = SHA256_H6;
-	sctx->state[7] = SHA256_H7;
-	sctx->count = 0;
-
-	return 0;
-}
+extern int sha256_base_init(struct shash_desc *desc);
 
-static inline int sha256_base_do_update(struct shash_desc *desc,
+static inline void sha256_base_do_update(struct sha256_state *sctx,
 					const u8 *data,
 					unsigned int len,
 					sha256_block_fn *block_fn)
 {
-	struct sha256_state *sctx = shash_desc_ctx(desc);
 	unsigned int partial = sctx->count % SHA256_BLOCK_SIZE;
 
 	sctx->count += len;
@@ -86,15 +70,12 @@ static inline int sha256_base_do_update(struct shash_desc *desc,
 	}
 	if (len)
 		memcpy(sctx->buf + partial, data, len);
-
-	return 0;
 }
 
-static inline int sha256_base_do_finalize(struct shash_desc *desc,
+static inline void sha256_base_do_finalize(struct sha256_state *sctx,
 					  sha256_block_fn *block_fn)
 {
 	const int bit_offset = SHA256_BLOCK_SIZE - sizeof(__be64);
-	struct sha256_state *sctx = shash_desc_ctx(desc);
 	__be64 *bits = (__be64 *)(sctx->buf + bit_offset);
 	unsigned int partial = sctx->count % SHA256_BLOCK_SIZE;
 
@@ -109,14 +90,11 @@ static inline int sha256_base_do_finalize(struct shash_desc *desc,
 	memset(sctx->buf + partial, 0x0, bit_offset - partial);
 	*bits = cpu_to_be64(sctx->count << 3);
 	block_fn(sctx, sctx->buf, 1);
-
-	return 0;
 }
 
-static inline int sha256_base_finish(struct shash_desc *desc, u8 *out)
+static inline void sha2_base_finish(struct sha256_state *sctx,
+				    unsigned int digest_size, u8 *out)
 {
-	unsigned int digest_size = crypto_shash_digestsize(desc->tfm);
-	struct sha256_state *sctx = shash_desc_ctx(desc);
 	__be32 *digest = (__be32 *)out;
 	int i;
 
@@ -124,5 +102,11 @@ static inline int sha256_base_finish(struct shash_desc *desc, u8 *out)
 		put_unaligned_be32(sctx->state[i], digest++);
 
 	*sctx = (struct sha256_state){};
-	return 0;
 }
+
+static inline void sha256_base_finish(struct sha256_state *sctx, u8 *out)
+{
+	sha2_base_finish(sctx, SHA256_DIGEST_SIZE, out);
+}
+
+extern int crypto_sha2_final(struct shash_desc *desc, u8 *out);
-- 
2.9.3
