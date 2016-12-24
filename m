From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC PATCH 4.10 2/6] crypto/sha256: Make the sha256 library functions selectable
Date: Fri, 23 Dec 2016 18:22:28 -0800
Message-ID: <dc10dd24cb5c2ef8a2f206dea06413e7d18bd2f5.1482545792.git.luto@kernel.org>
References: <cover.1482545792.git.luto@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andy Lutomirski <luto@kernel.org>
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

This will let other kernel code call into sha256_init(), etc. without
pulling in the core crypto code.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 crypto/Kconfig          | 8 ++++++++
 crypto/Makefile         | 2 +-
 crypto/sha256_generic.c | 4 ++++
 include/crypto/sha.h    | 4 ++++
 4 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/crypto/Kconfig b/crypto/Kconfig
index 160f08e721cc..85a2b3440c2b 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -10,6 +10,13 @@ config XOR_BLOCKS
 source "crypto/async_tx/Kconfig"
 
 #
+# Cryptographic algorithms that are usable without the Crypto API.
+# None of these should have visible config options.
+#
+config CRYPTO_SHA256_LIB
+	bool
+
+#
 # Cryptographic API Configuration
 #
 menuconfig CRYPTO
@@ -763,6 +770,7 @@ config CRYPTO_SHA512_MB
 
 config CRYPTO_SHA256
 	tristate "SHA224 and SHA256 digest algorithm"
+	select CRYPTO_SHA256_LIB
 	select CRYPTO_HASH
 	help
 	  SHA256 secure hash standard (DFIPS 180-2).
diff --git a/crypto/Makefile b/crypto/Makefile
index b8f0e3eb0791..d147d4c911f5 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -71,7 +71,7 @@ obj-$(CONFIG_CRYPTO_RMD160) += rmd160.o
 obj-$(CONFIG_CRYPTO_RMD256) += rmd256.o
 obj-$(CONFIG_CRYPTO_RMD320) += rmd320.o
 obj-$(CONFIG_CRYPTO_SHA1) += sha1_generic.o
-obj-$(CONFIG_CRYPTO_SHA256) += sha256_generic.o
+obj-$(CONFIG_CRYPTO_SHA256_LIB) += sha256_generic.o
 obj-$(CONFIG_CRYPTO_SHA512) += sha512_generic.o
 obj-$(CONFIG_CRYPTO_SHA3) += sha3_generic.o
 obj-$(CONFIG_CRYPTO_WP512) += wp512.o
diff --git a/crypto/sha256_generic.c b/crypto/sha256_generic.c
index f2747893402c..9df71ac66dc4 100644
--- a/crypto/sha256_generic.c
+++ b/crypto/sha256_generic.c
@@ -261,6 +261,8 @@ void sha256_final(struct sha256_state *sctx, u8 *out)
 }
 EXPORT_SYMBOL(sha256_final);
 
+#ifdef CONFIG_CRYPTO_HASH
+
 static int crypto_sha256_update(struct shash_desc *desc, const u8 *data,
 				unsigned int len)
 {
@@ -328,6 +330,8 @@ static void __exit sha256_generic_mod_fini(void)
 module_init(sha256_generic_mod_init);
 module_exit(sha256_generic_mod_fini);
 
+#endif /* CONFIG_CRYPTO_HASH */
+
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("SHA-224 and SHA-256 Secure Hash Algorithm");
 
diff --git a/include/crypto/sha.h b/include/crypto/sha.h
index 2b6978471605..381ba7fa5e3f 100644
--- a/include/crypto/sha.h
+++ b/include/crypto/sha.h
@@ -96,6 +96,8 @@ extern int crypto_sha1_update(struct shash_desc *desc, const u8 *data,
 extern int crypto_sha1_finup(struct shash_desc *desc, const u8 *data,
 			     unsigned int len, u8 *hash);
 
+#ifdef CONFIG_CRYPTO_SHA256_LIB
+
 static inline void sha256_init(struct sha256_state *sctx)
 {
 	sctx->state[0] = SHA256_H0;
@@ -121,6 +123,8 @@ static inline void sha256_finup(struct sha256_state *sctx, const u8 *data,
 	sha256_final(sctx, hash);
 }
 
+#endif /* CONFIG_CRYPTO_SHA256_LIB */
+
 extern int crypto_sha512_update(struct shash_desc *desc, const u8 *data,
 			      unsigned int len);
 
-- 
2.9.3
