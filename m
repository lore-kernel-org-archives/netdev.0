From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 2/8] crypto/sha256: Export a sha256_{init,update,final}_direct() API
Date: Tue, 10 Jan 2017 15:24:40 -0800
Message-ID: <8c59a4dd8b7ba4f2e5a6461132bbd16c83ff7c1f.1484090585.git.luto@kernel.org>
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

This provides a very simple interface for kernel code to use to do
synchronous, unaccelerated, virtual-address-based SHA256 hashing
without needing to create a crypto context.

Subsequent patches will make this work without building the crypto
core and will use to avoid making BPF-based tracing depend on
crypto.

Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 crypto/sha256_generic.c      | 31 ++++++++++++++++++++++++++-----
 include/crypto/sha.h         | 24 ++++++++++++++++++++++++
 include/crypto/sha256_base.h | 13 -------------
 3 files changed, 50 insertions(+), 18 deletions(-)

diff --git a/crypto/sha256_generic.c b/crypto/sha256_generic.c
index 8f9c47e1a96e..573e114382f9 100644
--- a/crypto/sha256_generic.c
+++ b/crypto/sha256_generic.c
@@ -240,24 +240,45 @@ static void sha256_generic_block_fn(struct sha256_state *sst, u8 const *src,
 	}
 }
 
+void sha256_update_direct(struct sha256_state *sctx, const u8 *data,
+			  unsigned int len)
+{
+	__sha256_base_do_update(sctx, data, len, sha256_generic_block_fn);
+}
+EXPORT_SYMBOL(sha256_update_direct);
+
 int crypto_sha256_update(struct shash_desc *desc, const u8 *data,
 			  unsigned int len)
 {
-	return sha256_base_do_update(desc, data, len, sha256_generic_block_fn);
+	sha256_update_direct(shash_desc_ctx(desc), data, len);
+	return 0;
 }
 EXPORT_SYMBOL(crypto_sha256_update);
 
 static int sha256_final(struct shash_desc *desc, u8 *out)
 {
-	sha256_base_do_finalize(desc, sha256_generic_block_fn);
-	return sha256_base_finish(desc, out);
+	__sha256_final_direct(shash_desc_ctx(desc),
+			      crypto_shash_digestsize(desc->tfm), out);
+	return 0;
 }
 
+void __sha256_final_direct(struct sha256_state *sctx, unsigned int digest_size,
+			   u8 *out)
+{
+	sha256_do_finalize_direct(sctx, sha256_generic_block_fn);
+	__sha256_base_finish(sctx, digest_size, out);
+}
+EXPORT_SYMBOL(sha256_final_direct);
+
 int crypto_sha256_finup(struct shash_desc *desc, const u8 *data,
 			unsigned int len, u8 *hash)
 {
-	sha256_base_do_update(desc, data, len, sha256_generic_block_fn);
-	return sha256_final(desc, hash);
+	struct sha256_state *sctx = shash_desc_ctx(desc);
+	unsigned int digest_size = crypto_shash_digestsize(desc->tfm);
+
+	sha256_update_direct(sctx, data, len);
+	__sha256_final_direct(sctx, digest_size, hash);
+	return 0;
 }
 EXPORT_SYMBOL(crypto_sha256_finup);
 
diff --git a/include/crypto/sha.h b/include/crypto/sha.h
index c94d3eb1cefd..0df1a0e42c95 100644
--- a/include/crypto/sha.h
+++ b/include/crypto/sha.h
@@ -88,6 +88,30 @@ struct sha512_state {
 	u8 buf[SHA512_BLOCK_SIZE];
 };
 
+static inline void sha256_init_direct(struct sha256_state *sctx)
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
+extern void sha256_update_direct(struct sha256_state *sctx, const u8 *data,
+				 unsigned int len);
+
+extern void __sha256_final_direct(struct sha256_state *sctx,
+				  unsigned int digest_size, u8 *out);
+
+static inline void sha256_final_direct(struct sha256_state *sctx, u8 *out)
+{
+	__sha256_final_direct(sctx, SHA256_DIGEST_SIZE, out);
+}
+
 struct shash_desc;
 
 extern int crypto_sha1_update(struct shash_desc *desc, const u8 *data,
diff --git a/include/crypto/sha256_base.h b/include/crypto/sha256_base.h
index fc77b8e099a7..9bbe73ce458f 100644
--- a/include/crypto/sha256_base.h
+++ b/include/crypto/sha256_base.h
@@ -37,19 +37,6 @@ static inline int sha224_base_init(struct shash_desc *desc)
 	return 0;
 }
 
-static inline void sha256_init_direct(struct sha256_state *sctx)
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
-}
-
 static inline int sha256_base_init(struct shash_desc *desc)
 {
 	sha256_init_direct(shash_desc_ctx(desc));
-- 
2.9.3
