From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v4 2/4] siphash: add N[qd]word helpers
Date: Thu, 15 Dec 2016 02:46:47 +0100
Message-ID: <20161215014649.20068-2-Jason@zx2c4.com>
References: <20161214184605.24006-1-Jason@zx2c4.com>
 <20161215014649.20068-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Tom Herbert <tom@herbertland.com>
To: Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	linux-crypto@vger.kernel.org
Return-path: <kernel-hardening-return-5567-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161215014649.20068-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

These restore parity with the jhash interface by providing high
performance helpers for common input sizes.

Linus doesn't like the use of "qword" and "dword", but I haven't been
able to come up with another name for these that fits as well.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Tom Herbert <tom@herbertland.com>
---
Changes from v2->v4:

  - Rather than just wrapping siphash(), we actually implement the
    fully optimized and manually unrolled version, so that lengths
    don't need to be checked and loops don't need to branch.
  - We now provide both 32-bit and 64-bit versions, both of which
    are quite useful for different circumstances.

 include/linux/siphash.h |  31 ++++++++++
 lib/siphash.c           | 161 ++++++++++++++++++++++++++++++++++++------------
 lib/test_siphash.c      |  18 ++++++
 3 files changed, 170 insertions(+), 40 deletions(-)

diff --git a/include/linux/siphash.h b/include/linux/siphash.h
index d0bcca7b992b..6e7c2a421bd9 100644
--- a/include/linux/siphash.h
+++ b/include/linux/siphash.h
@@ -27,4 +27,35 @@ static inline u64 siphash_unaligned(const u8 *data, size_t len, const u8 key[SIP
 u64 siphash_unaligned(const u8 *data, size_t len, const u8 key[SIPHASH_KEY_LEN]);
 #endif
 
+u64 siphash_1qword(const u64 a, const u8 key[SIPHASH_KEY_LEN]);
+u64 siphash_2qwords(const u64 a, const u64 b, const u8 key[SIPHASH_KEY_LEN]);
+u64 siphash_3qwords(const u64 a, const u64 b, const u64 c, const u8 key[SIPHASH_KEY_LEN]);
+u64 siphash_4qwords(const u64 a, const u64 b, const u64 c, const u64 d, const u8 key[SIPHASH_KEY_LEN]);
+
+static inline u64 siphash_2dwords(const u32 a, const u32 b, const u8 key[SIPHASH_KEY_LEN])
+{
+	return siphash_1qword((u64)b << 32 | a, key);
+}
+
+static inline u64 siphash_4dwords(const u32 a, const u32 b, const u32 c, const u32 d,
+				  const u8 key[SIPHASH_KEY_LEN])
+{
+	return siphash_2qwords((u64)b << 32 | a, (u64)d << 32 | c, key);
+}
+
+static inline u64 siphash_6dwords(const u32 a, const u32 b, const u32 c, const u32 d,
+				  const u32 e, const u32 f, const u8 key[SIPHASH_KEY_LEN])
+{
+	return siphash_3qwords((u64)b << 32 | a, (u64)d << 32 | c, (u64)f << 32 | e,
+			       key);
+}
+
+static inline u64 siphash_8dwords(const u32 a, const u32 b, const u32 c, const u32 d,
+				  const u32 e, const u32 f, const u32 g, const u32 h,
+				  const u8 key[SIPHASH_KEY_LEN])
+{
+	return siphash_4qwords((u64)b << 32 | a, (u64)d << 32 | c, (u64)f << 32 | e,
+			       (u64)h << 32 | g, key);
+}
+
 #endif /* _LINUX_SIPHASH_H */
diff --git a/lib/siphash.c b/lib/siphash.c
index b500231f61cd..c13d2b2bb76e 100644
--- a/lib/siphash.c
+++ b/lib/siphash.c
@@ -38,6 +38,31 @@ static inline u64 le64_to_cpuvp(const void *p)
 	v2 += v1; v1 = rol64(v1, 17); v1 ^= v2; v2 = rol64(v2, 32); \
 	} while(0)
 
+#define PREAMBLE(len) \
+	u64 v0 = 0x736f6d6570736575ULL; \
+	u64 v1 = 0x646f72616e646f6dULL; \
+	u64 v2 = 0x6c7967656e657261ULL; \
+	u64 v3 = 0x7465646279746573ULL; \
+	u64 b = ((u64)len) << 56; \
+	u64 k0 = le64_to_cpuvp(key); \
+	u64 k1 = le64_to_cpuvp(key + sizeof(u64)); \
+	v3 ^= k1; \
+	v2 ^= k0; \
+	v1 ^= k1; \
+	v0 ^= k0;
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
@@ -46,20 +71,10 @@ static inline u64 le64_to_cpuvp(const void *p)
  */
 u64 siphash(const u8 *data, size_t len, const u8 key[SIPHASH_KEY_LEN])
 {
-	u64 v0 = 0x736f6d6570736575ULL;
-	u64 v1 = 0x646f72616e646f6dULL;
-	u64 v2 = 0x6c7967656e657261ULL;
-	u64 v3 = 0x7465646279746573ULL;
-	u64 b = ((u64)len) << 56;
-	u64 k0 = le64_to_cpuvp(key);
-	u64 k1 = le64_to_cpuvp(key + sizeof(u64));
-	u64 m;
 	const u8 *end = data + len - (len % sizeof(u64));
 	const u8 left = len & (sizeof(u64) - 1);
-	v3 ^= k1;
-	v2 ^= k0;
-	v1 ^= k1;
-	v0 ^= k0;
+	u64 m;
+	PREAMBLE(len)
 	for (; data != end; data += sizeof(u64)) {
 		m = le64_to_cpuvp(data);
 		v3 ^= m;
@@ -81,16 +96,7 @@ u64 siphash(const u8 *data, size_t len, const u8 key[SIPHASH_KEY_LEN])
 	case 1: b |= data[0];
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
 
@@ -103,20 +109,10 @@ EXPORT_SYMBOL(siphash);
  */
 u64 siphash_unaligned(const u8 *data, size_t len, const u8 key[SIPHASH_KEY_LEN])
 {
-	u64 v0 = 0x736f6d6570736575ULL;
-	u64 v1 = 0x646f72616e646f6dULL;
-	u64 v2 = 0x6c7967656e657261ULL;
-	u64 v3 = 0x7465646279746573ULL;
-	u64 b = ((u64)len) << 56;
-	u64 k0 = le64_to_cpuvp(key);
-	u64 k1 = le64_to_cpuvp(key + sizeof(u64));
-	u64 m;
 	const u8 *end = data + len - (len % sizeof(u64));
 	const u8 left = len & (sizeof(u64) - 1);
-	v3 ^= k1;
-	v2 ^= k0;
-	v1 ^= k1;
-	v0 ^= k0;
+	u64 m;
+	PREAMBLE(len)
 	for (; data != end; data += sizeof(u64)) {
 		m = get_unaligned_le64(data);
 		v3 ^= m;
@@ -138,16 +134,101 @@ u64 siphash_unaligned(const u8 *data, size_t len, const u8 key[SIPHASH_KEY_LEN])
 	case 1: b |= data[0];
 	}
 #endif
-	v3 ^= b;
+	POSTAMBLE
+}
+EXPORT_SYMBOL(siphash_unaligned);
+#endif
+
+/**
+ * siphash_1qword - compute 64-bit siphash PRF value of 1 quad-word
+ * @first: first quadword
+ * @key: key buffer of size SIPHASH_KEY_LEN, must be aligned to SIPHASH_ALIGNMENT
+ */
+u64 siphash_1qword(const u64 first, const u8 key[SIPHASH_KEY_LEN])
+{
+	PREAMBLE(8)
+	v3 ^= first;
+	SIPROUND;
+	SIPROUND;
+	v0 ^= first;
+	POSTAMBLE
+}
+EXPORT_SYMBOL(siphash_1qword);
+
+/**
+ * siphash_2qwords - compute 64-bit siphash PRF value of 2 quad-words
+ * @first: first quadword
+ * @second: second quadword
+ * @key: key buffer of size SIPHASH_KEY_LEN, must be aligned to SIPHASH_ALIGNMENT
+ */
+u64 siphash_2qwords(const u64 first, const u64 second, const u8 key[SIPHASH_KEY_LEN])
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
+EXPORT_SYMBOL(siphash_2qwords);
+
+/**
+ * siphash_3qwords - compute 64-bit siphash PRF value of 3 quad-words
+ * @first: first quadword
+ * @second: second quadword
+ * @third: third quadword
+ * @key: key buffer of size SIPHASH_KEY_LEN, must be aligned to SIPHASH_ALIGNMENT
+ */
+u64 siphash_3qwords(const u64 first, const u64 second, const u64 third, const u8 key[SIPHASH_KEY_LEN])
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
-EXPORT_SYMBOL(siphash24_unaligned);
-#endif
+EXPORT_SYMBOL(siphash_3qwords);
+
+/**
+ * siphash_4qwords - compute 64-bit siphash PRF value of 4 quad-words
+ * @first: first quadword
+ * @second: second quadword
+ * @third: third quadword
+ * @forth: forth quadword
+ * @key: key buffer of size SIPHASH_KEY_LEN, must be aligned to SIPHASH_ALIGNMENT
+ */
+u64 siphash_4qwords(const u64 first, const u64 second, const u64 third, const u64 forth, const u8 key[SIPHASH_KEY_LEN])
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
+EXPORT_SYMBOL(siphash_4qwords);
diff --git a/lib/test_siphash.c b/lib/test_siphash.c
index 444725c7834f..9925a325af35 100644
--- a/lib/test_siphash.c
+++ b/lib/test_siphash.c
@@ -68,6 +68,24 @@ static int __init siphash_test_init(void)
 			ret = -EINVAL;
 		}
 	}
+	if (siphash_1qword(0x0706050403020100ULL, k) != test_vectors[8]) {
+		pr_info("self-test 1qword: FAIL\n");
+		ret = -EINVAL;
+	}
+	if (siphash_2qwords(0x0706050403020100ULL, 0x0f0e0d0c0b0a0908ULL, k) != test_vectors[16]) {
+		pr_info("self-test 2qwords: FAIL\n");
+		ret = -EINVAL;
+	}
+	if (siphash_3qwords(0x0706050403020100ULL, 0x0f0e0d0c0b0a0908ULL,
+			    0x1716151413121110ULL, k) != test_vectors[24]) {
+		pr_info("self-test 3qwords: FAIL\n");
+		ret = -EINVAL;
+	}
+	if (siphash_4qwords(0x0706050403020100ULL, 0x0f0e0d0c0b0a0908ULL,
+			    0x1716151413121110ULL, 0x1f1e1d1c1b1a1918ULL, k) != test_vectors[32]) {
+		pr_info("self-test 4qwords: FAIL\n");
+		ret = -EINVAL;
+	}
 	if (!ret)
 		pr_info("self-tests: pass\n");
 	return ret;
-- 
2.11.0
