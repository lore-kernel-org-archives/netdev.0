From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 1/8] crypto/sha256: Factor out the parts of base API that don't use shash_desc
Date: Tue, 10 Jan 2017 15:24:39 -0800
Message-ID: <7e5fbc02972b03727b71bc71f84175c36cbf01f5.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
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
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I want to expose a minimal SHA256 API that can be used without the
depending on the crypto core.  To prepare for this, factor out the
meat of the sha256_base_*() helpers.

Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 include/crypto/sha256_base.h | 53 ++++++++++++++++++++++++++++++--------------
 1 file changed, 36 insertions(+), 17 deletions(-)

diff --git a/include/crypto/sha256_base.h b/include/crypto/sha256_base.h
index d1f2195bb7de..fc77b8e099a7 100644
--- a/include/crypto/sha256_base.h
+++ b/include/crypto/sha256_base.h
@@ -18,10 +18,8 @@
 typedef void (sha256_block_fn)(struct sha256_state *sst, u8 const *src,
 			       int blocks);
 
-static inline int sha224_base_init(struct shash_desc *desc)
+static inline void sha224_init_direct(struct sha256_state *sctx)
 {
-	struct sha256_state *sctx = shash_desc_ctx(desc);
-
 	sctx->state[0] = SHA224_H0;
 	sctx->state[1] = SHA224_H1;
 	sctx->state[2] = SHA224_H2;
@@ -31,14 +29,16 @@ static inline int sha224_base_init(struct shash_desc *desc)
 	sctx->state[6] = SHA224_H6;
 	sctx->state[7] = SHA224_H7;
 	sctx->count = 0;
+}
 
+static inline int sha224_base_init(struct shash_desc *desc)
+{
+	sha224_init_direct(shash_desc_ctx(desc));
 	return 0;
 }
 
-static inline int sha256_base_init(struct shash_desc *desc)
+static inline void sha256_init_direct(struct sha256_state *sctx)
 {
-	struct sha256_state *sctx = shash_desc_ctx(desc);
-
 	sctx->state[0] = SHA256_H0;
 	sctx->state[1] = SHA256_H1;
 	sctx->state[2] = SHA256_H2;
@@ -48,16 +48,19 @@ static inline int sha256_base_init(struct shash_desc *desc)
 	sctx->state[6] = SHA256_H6;
 	sctx->state[7] = SHA256_H7;
 	sctx->count = 0;
+}
 
+static inline int sha256_base_init(struct shash_desc *desc)
+{
+	sha256_init_direct(shash_desc_ctx(desc));
 	return 0;
 }
 
-static inline int sha256_base_do_update(struct shash_desc *desc,
-					const u8 *data,
-					unsigned int len,
-					sha256_block_fn *block_fn)
+static inline void __sha256_base_do_update(struct sha256_state *sctx,
+					   const u8 *data,
+					   unsigned int len,
+					   sha256_block_fn *block_fn)
 {
-	struct sha256_state *sctx = shash_desc_ctx(desc);
 	unsigned int partial = sctx->count % SHA256_BLOCK_SIZE;
 
 	sctx->count += len;
@@ -86,15 +89,21 @@ static inline int sha256_base_do_update(struct shash_desc *desc,
 	}
 	if (len)
 		memcpy(sctx->buf + partial, data, len);
+}
 
+static inline int sha256_base_do_update(struct shash_desc *desc,
+					const u8 *data,
+					unsigned int len,
+					sha256_block_fn *block_fn)
+{
+	__sha256_base_do_update(shash_desc_ctx(desc), data, len, block_fn);
 	return 0;
 }
 
-static inline int sha256_base_do_finalize(struct shash_desc *desc,
-					  sha256_block_fn *block_fn)
+static inline void sha256_do_finalize_direct(struct sha256_state *sctx,
+					     sha256_block_fn *block_fn)
 {
 	const int bit_offset = SHA256_BLOCK_SIZE - sizeof(__be64);
-	struct sha256_state *sctx = shash_desc_ctx(desc);
 	__be64 *bits = (__be64 *)(sctx->buf + bit_offset);
 	unsigned int partial = sctx->count % SHA256_BLOCK_SIZE;
 
@@ -109,14 +118,18 @@ static inline int sha256_base_do_finalize(struct shash_desc *desc,
 	memset(sctx->buf + partial, 0x0, bit_offset - partial);
 	*bits = cpu_to_be64(sctx->count << 3);
 	block_fn(sctx, sctx->buf, 1);
+}
 
+static inline int sha256_base_do_finalize(struct shash_desc *desc,
+					  sha256_block_fn *block_fn)
+{
+	sha256_do_finalize_direct(shash_desc_ctx(desc), block_fn);
 	return 0;
 }
 
-static inline int sha256_base_finish(struct shash_desc *desc, u8 *out)
+static inline void __sha256_base_finish(struct sha256_state *sctx,
+					unsigned int digest_size, u8 *out)
 {
-	unsigned int digest_size = crypto_shash_digestsize(desc->tfm);
-	struct sha256_state *sctx = shash_desc_ctx(desc);
 	__be32 *digest = (__be32 *)out;
 	int i;
 
@@ -124,5 +137,11 @@ static inline int sha256_base_finish(struct shash_desc *desc, u8 *out)
 		put_unaligned_be32(sctx->state[i], digest++);
 
 	*sctx = (struct sha256_state){};
+}
+
+static inline int sha256_base_finish(struct shash_desc *desc, u8 *out)
+{
+	__sha256_base_finish(shash_desc_ctx(desc),
+			     crypto_shash_digestsize(desc->tfm), out);
 	return 0;
 }
-- 
2.9.3
