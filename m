From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v5 2/4] siphash: add Nu{32,64} helpers
Date: Thu, 15 Dec 2016 21:30:01 +0100
Message-ID: <20161215203003.31989-3-Jason@zx2c4.com>
References: <20161215203003.31989-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	linux-crypto@vger.kernel.org,
	David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	George Spelvin <linux@sciencehorizons.net>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	ak@linux.intel.com,
	davem@davemloft.net,
	luto@amacapital.net
Return-path: <kernel-hardening-return-5593-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161215203003.31989-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

These restore parity with the jhash interface by providing high
performance helpers for common input sizes.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Tom Herbert <tom@herbertland.com>
---
 include/linux/siphash.h |  33 ++++++++++
 lib/siphash.c           | 157 +++++++++++++++++++++++++++++++++++++-----------
 lib/test_siphash.c      |  18 ++++++
 3 files changed, 172 insertions(+), 36 deletions(-)

diff --git a/include/linux/siphash.h b/include/linux/siphash.h
index 145cf5667078..6f5a08a0fc7e 100644
--- a/include/linux/siphash.h
+++ b/include/linux/siphash.h
@@ -29,4 +29,37 @@ static inline u64 siphash_unaligned(const void *data, size_t len,
 u64 siphash_unaligned(const void *data, size_t len, const siphash_key_t key);
 #endif
 
+u64 siphash_1u64(const u64 a, const siphash_key_t key);
+u64 siphash_2u64(const u64 a, const u64 b, const siphash_key_t key);
+u64 siphash_3u64(const u64 a, const u64 b, const u64 c,
+		 const siphash_key_t key);
+u64 siphash_4u64(const u64 a, const u64 b, const u64 c, const u64 d,
+		 const siphash_key_t key);
+
+static inline u64 siphash_2u32(const u32 a, const u32 b, const siphash_key_t key)
+{
+	return siphash_1u64((u64)b << 32 | a, key);
+}
+
+static inline u64 siphash_4u32(const u32 a, const u32 b, const u32 c, const u32 d,
+			       const siphash_key_t key)
+{
+	return siphash_2u64((u64)b << 32 | a, (u64)d << 32 | c, key);
+}
+
+static inline u64 siphash_6u32(const u32 a, const u32 b, const u32 c, const u32 d,
+			       const u32 e, const u32 f, const siphash_key_t key)
+{
+	return siphash_3u64((u64)b << 32 | a, (u64)d << 32 | c, (u64)f << 32 | e,
+			    key);
+}
+
+static inline u64 siphash_8u32(const u32 a, const u32 b, const u32 c, const u32 d,
+			       const u32 e, const u32 f, const u32 g, const u32 h,
+			       const siphash_key_t key)
+{
+	return siphash_4u64((u64)b << 32 | a, (u64)d << 32 | c, (u64)f << 32 | e,
+			    (u64)h << 32 | g, key);
+}
+
 #endif /* _LINUX_SIPHASH_H */
diff --git a/lib/siphash.c b/lib/siphash.c
index afc13cbb1b78..970c083ab06a 100644
--- a/lib/siphash.c
+++ b/lib/siphash.c
@@ -25,6 +25,29 @@
 	v2 += v1; v1 = rol64(v1, 17); v1 ^= v2; v2 = rol64(v2, 32); \
 	} while(0)
 
+#define PREAMBLE(len) \
+	u64 v0 = 0x736f6d6570736575ULL; \
+	u64 v1 = 0x646f72616e646f6dULL; \
+	u64 v2 = 0x6c7967656e657261ULL; \
+	u64 v3 = 0x7465646279746573ULL; \
+	u64 b = ((u64)len) << 56; \
+	v3 ^= key[1]; \
+	v2 ^= key[0]; \
+	v1 ^= key[1]; \
+	v0 ^= key[0];
+
+#define POSTAMBLE \
+	v3 ^= b; \
+	SIPROUND; \
+	SIPROUND; \
+	v0 ^= b; \
+	v2 ^= 0xff; \
+	SIPROUND; \
+	SIPROUND; \
+	SIPROUND; \
+	SIPROUND; \
+	return (v0 ^ v1) ^ (v2 ^ v3);
+
 /**
  * siphash - compute 64-bit siphash PRF value
  * @data: buffer to hash, must be aligned to SIPHASH_ALIGNMENT
@@ -33,18 +56,10 @@
  */
 u64 siphash(const void *data, size_t len, const siphash_key_t key)
 {
-	u64 v0 = 0x736f6d6570736575ULL;
-	u64 v1 = 0x646f72616e646f6dULL;
-	u64 v2 = 0x6c7967656e657261ULL;
-	u64 v3 = 0x7465646279746573ULL;
-	u64 b = ((u64)len) << 56;
-	u64 m;
 	const u8 *end = data + len - (len % sizeof(u64));
 	const u8 left = len & (sizeof(u64) - 1);
-	v3 ^= key[1];
-	v2 ^= key[0];
-	v1 ^= key[1];
-	v0 ^= key[0];
+	u64 m;
+	PREAMBLE(len)
 	for (; data != end; data += sizeof(u64)) {
 		m = le64_to_cpup(data);
 		v3 ^= m;
@@ -67,16 +82,7 @@ u64 siphash(const void *data, size_t len, const siphash_key_t key)
 	case 1: b |= end[0];
 	}
 #endif
-	v3 ^= b;
-	SIPROUND;
-	SIPROUND;
-	v0 ^= b;
-	v2 ^= 0xff;
-	SIPROUND;
-	SIPROUND;
-	SIPROUND;
-	SIPROUND;
-	return (v0 ^ v1) ^ (v2 ^ v3);
+	POSTAMBLE
 }
 EXPORT_SYMBOL(siphash);
 
@@ -89,18 +95,10 @@ EXPORT_SYMBOL(siphash);
  */
 u64 siphash_unaligned(const void *data, size_t len, const siphash_key_t key)
 {
-	u64 v0 = 0x736f6d6570736575ULL;
-	u64 v1 = 0x646f72616e646f6dULL;
-	u64 v2 = 0x6c7967656e657261ULL;
-	u64 v3 = 0x7465646279746573ULL;
-	u64 b = ((u64)len) << 56;
-	u64 m;
 	const u8 *end = data + len - (len % sizeof(u64));
 	const u8 left = len & (sizeof(u64) - 1);
-	v3 ^= key[1];
-	v2 ^= key[0];
-	v1 ^= key[1];
-	v0 ^= key[0];
+	u64 m;
+	PREAMBLE(len)
 	for (; data != end; data += sizeof(u64)) {
 		m = get_unaligned_le64(data);
 		v3 ^= m;
@@ -123,16 +121,103 @@ u64 siphash_unaligned(const void *data, size_t len, const siphash_key_t key)
 	case 1: b |= bytes[0];
 	}
 #endif
-	v3 ^= b;
+	POSTAMBLE
+}
+EXPORT_SYMBOL(siphash_unaligned);
+#endif
+
+/**
+ * siphash_1u64 - compute 64-bit siphash PRF value of a u64
+ * @first: first u64
+ * @key: the siphash key
+ */
+u64 siphash_1u64(const u64 first, const siphash_key_t key)
+{
+	PREAMBLE(8)
+	v3 ^= first;
+	SIPROUND;
+	SIPROUND;
+	v0 ^= first;
+	POSTAMBLE
+}
+EXPORT_SYMBOL(siphash_1u64);
+
+/**
+ * siphash_2u64 - compute 64-bit siphash PRF value of 2 u64
+ * @first: first u64
+ * @second: second u64
+ * @key: the siphash key
+ */
+u64 siphash_2u64(const u64 first, const u64 second, const siphash_key_t key)
+{
+	PREAMBLE(16)
+	v3 ^= first;
 	SIPROUND;
 	SIPROUND;
-	v0 ^= b;
-	v2 ^= 0xff;
+	v0 ^= first;
+	v3 ^= second;
 	SIPROUND;
 	SIPROUND;
+	v0 ^= second;
+	POSTAMBLE
+}
+EXPORT_SYMBOL(siphash_2u64);
+
+/**
+ * siphash_3u64 - compute 64-bit siphash PRF value of 3 u64
+ * @first: first u64
+ * @second: second u64
+ * @third: third u64
+ * @key: the siphash key
+ */
+u64 siphash_3u64(const u64 first, const u64 second, const u64 third,
+		 const siphash_key_t key)
+{
+	PREAMBLE(24)
+	v3 ^= first;
 	SIPROUND;
 	SIPROUND;
-	return (v0 ^ v1) ^ (v2 ^ v3);
+	v0 ^= first;
+	v3 ^= second;
+	SIPROUND;
+	SIPROUND;
+	v0 ^= second;
+	v3 ^= third;
+	SIPROUND;
+	SIPROUND;
+	v0 ^= third;
+	POSTAMBLE
 }
-EXPORT_SYMBOL(siphash_unaligned);
-#endif
+EXPORT_SYMBOL(siphash_3u64);
+
+/**
+ * siphash_4u64 - compute 64-bit siphash PRF value of 4 u64
+ * @first: first u64
+ * @second: second u64
+ * @third: third u64
+ * @forth: forth u64
+ * @key: the siphash key
+ */
+u64 siphash_4u64(const u64 first, const u64 second, const u64 third,
+		 const u64 forth, const siphash_key_t key)
+{
+	PREAMBLE(32)
+	v3 ^= first;
+	SIPROUND;
+	SIPROUND;
+	v0 ^= first;
+	v3 ^= second;
+	SIPROUND;
+	SIPROUND;
+	v0 ^= second;
+	v3 ^= third;
+	SIPROUND;
+	SIPROUND;
+	v0 ^= third;
+	v3 ^= forth;
+	SIPROUND;
+	SIPROUND;
+	v0 ^= forth;
+	POSTAMBLE
+}
+EXPORT_SYMBOL(siphash_4u64);
diff --git a/lib/test_siphash.c b/lib/test_siphash.c
index 93549e4e22c5..1635189c171f 100644
--- a/lib/test_siphash.c
+++ b/lib/test_siphash.c
@@ -67,6 +67,24 @@ static int __init siphash_test_init(void)
 			ret = -EINVAL;
 		}
 	}
+	if (siphash_1u64(0x0706050403020100ULL, test_key) != test_vectors[8]) {
+		pr_info("self-test 1u64: FAIL\n");
+		ret = -EINVAL;
+	}
+	if (siphash_2u64(0x0706050403020100ULL, 0x0f0e0d0c0b0a0908ULL, test_key) != test_vectors[16]) {
+		pr_info("self-test 2u64: FAIL\n");
+		ret = -EINVAL;
+	}
+	if (siphash_3u64(0x0706050403020100ULL, 0x0f0e0d0c0b0a0908ULL,
+			 0x1716151413121110ULL, test_key) != test_vectors[24]) {
+		pr_info("self-test 3u64: FAIL\n");
+		ret = -EINVAL;
+	}
+	if (siphash_4u64(0x0706050403020100ULL, 0x0f0e0d0c0b0a0908ULL,
+			 0x1716151413121110ULL, 0x1f1e1d1c1b1a1918ULL, test_key) != test_vectors[32]) {
+		pr_info("self-test 4u64: FAIL\n");
+		ret = -EINVAL;
+	}
 	if (!ret)
 		pr_info("self-tests: pass\n");
 	return ret;
-- 
2.11.0
