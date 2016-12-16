From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v6 1/5] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 04:03:24 +0100
Message-ID: <20161216030328.11602-2-Jason@zx2c4.com>
References: <20161215203003.31989-1-Jason@zx2c4.com>
 <20161216030328.11602-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
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
        Vegard Nossum <vegard.nossum@gmail.com>, ak@linux.intel.com,
        davem@davemloft.net, luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:57662 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759356AbcLPDDv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 22:03:51 -0500
In-Reply-To: <20161216030328.11602-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SipHash is a 64-bit keyed hash function that is actually a
cryptographically secure PRF, like HMAC. Except SipHash is super fast,
and is meant to be used as a hashtable keyed lookup function, or as a
general PRF for short input use cases, such as sequence numbers or RNG
chaining.

For the first usage:

There are a variety of attacks known as "hashtable poisoning" in which an
attacker forms some data such that the hash of that data will be the
same, and then preceeds to fill up all entries of a hashbucket. This is
a realistic and well-known denial-of-service vector. Currently
hashtables use jhash, which is fast but not secure, and some kind of
rotating key scheme (or none at all, which isn't good). SipHash is meant
as a replacement for jhash in these cases.

There are a modicum of places in the kernel that are vulnerable to
hashtable poisoning attacks, either via userspace vectors or network
vectors, and there's not a reliable mechanism inside the kernel at the
moment to fix it. The first step toward fixing these issues is actually
getting a secure primitive into the kernel for developers to use. Then
we can, bit by bit, port things over to it as deemed appropriate.

While SipHash is extremely fast for a cryptographically secure function,
it is likely a bit slower than the insecure jhash, and so replacements
will be evaluated on a case-by-case basis based on whether or not the
difference in speed is negligible and whether or not the current jhash usage
poses a real security risk.

For the second usage:

A few places in the kernel are using MD5 or SHA1 for creating secure
sequence numbers, syn cookies, port numbers, or fast random numbers.
SipHash is a faster and more fitting, and more secure replacement for MD5
in those situations. Replacing MD5 and SHA1 with SipHash for these uses is
obvious and straight-forward, and so is submitted along with this patch
series. There shouldn't be much of a debate over its efficacy.

Dozens of languages are already using this internally for their hash
tables and PRFs. Some of the BSDs already use this in their kernels.
SipHash is a widely known high-speed solution to a widely known set of
problems, and it's time we catch-up.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Eric Biggers <ebiggers3@gmail.com>
Cc: David Laight <David.Laight@aculab.com>
---
 MAINTAINERS             |   7 ++
 include/linux/siphash.h |  86 ++++++++++++++++++++
 lib/Kconfig.debug       |   6 +-
 lib/Makefile            |   5 +-
 lib/siphash.c           | 210 ++++++++++++++++++++++++++++++++++++++++++++++++
 lib/test_siphash.c      | 101 +++++++++++++++++++++++
 6 files changed, 410 insertions(+), 5 deletions(-)
 create mode 100644 include/linux/siphash.h
 create mode 100644 lib/siphash.c
 create mode 100644 lib/test_siphash.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 59c9895d73d5..5d87a8c1056a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11231,6 +11231,13 @@ F:	arch/arm/mach-s3c24xx/mach-bast.c
 F:	arch/arm/mach-s3c24xx/bast-ide.c
 F:	arch/arm/mach-s3c24xx/bast-irq.c
 
+SIPHASH PRF ROUTINES
+M:	Jason A. Donenfeld <Jason@zx2c4.com>
+S:	Maintained
+F:	lib/siphash.c
+F:	lib/test_siphash.c
+F:	include/linux/siphash.h
+
 TI DAVINCI MACHINE SUPPORT
 M:	Sekhar Nori <nsekhar@ti.com>
 M:	Kevin Hilman <khilman@kernel.org>
diff --git a/include/linux/siphash.h b/include/linux/siphash.h
new file mode 100644
index 000000000000..e82fce48a0f6
--- /dev/null
+++ b/include/linux/siphash.h
@@ -0,0 +1,86 @@
+/* Copyright (C) 2016 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.
+ *
+ * SipHash: a fast short-input PRF
+ * https://131002.net/siphash/
+ *
+ * This implementation is specifically for SipHash2-4.
+ */
+
+#ifndef _LINUX_SIPHASH_H
+#define _LINUX_SIPHASH_H
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+
+#define SIPHASH_ALIGNMENT 8
+typedef u64 siphash_key_t[2];
+
+u64 __siphash_aligned(const void *data, size_t len, const siphash_key_t key);
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+u64 __siphash_unaligned(const void *data, size_t len, const siphash_key_t key);
+#endif
+
+u64 siphash_1u64(const u64 a, const siphash_key_t key);
+u64 siphash_2u64(const u64 a, const u64 b, const siphash_key_t key);
+u64 siphash_3u64(const u64 a, const u64 b, const u64 c,
+		 const siphash_key_t key);
+u64 siphash_4u64(const u64 a, const u64 b, const u64 c, const u64 d,
+		 const siphash_key_t key);
+
+static inline u64 ___siphash_aligned(const u64 *data, size_t len, const siphash_key_t key)
+{
+	if (__builtin_constant_p(len) && len == 8)
+		return siphash_1u64(data[0], key);
+	if (__builtin_constant_p(len) && len == 16)
+		return siphash_2u64(data[0], data[1], key);
+	if (__builtin_constant_p(len) && len == 24)
+		return siphash_3u64(data[0], data[1], data[2], key);
+	if (__builtin_constant_p(len) && len == 32)
+		return siphash_4u64(data[0], data[1], data[2], data[3], key);
+	return __siphash_aligned(data, len, key);
+}
+
+/**
+ * siphash - compute 64-bit siphash PRF value
+ * @data: buffer to hash
+ * @size: size of @data
+ * @key: the siphash key
+ */
+static inline u64 siphash(const void *data, size_t len, const siphash_key_t key)
+{
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	if (!IS_ALIGNED((unsigned long)data, SIPHASH_ALIGNMENT))
+		return __siphash_unaligned(data, len, key);
+#endif
+	return ___siphash_aligned(data, len, key);
+}
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
+#endif /* _LINUX_SIPHASH_H */
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 7446097f72bd..86254ea99b45 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1843,9 +1843,9 @@ config TEST_HASH
 	tristate "Perform selftest on hash functions"
 	default n
 	help
-	  Enable this option to test the kernel's integer (<linux/hash,h>)
-	  and string (<linux/stringhash.h>) hash functions on boot
-	  (or module load).
+	  Enable this option to test the kernel's integer (<linux/hash.h>),
+	  string (<linux/stringhash.h>), and siphash (<linux/siphash.h>)
+	  hash functions on boot (or module load).
 
 	  This is intended to help people writing architecture-specific
 	  optimized versions.  If unsure, say N.
diff --git a/lib/Makefile b/lib/Makefile
index 50144a3aeebd..71d398b04a74 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -22,7 +22,8 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 sha1.o chacha20.o md5.o irq_regs.o argv_split.o \
 	 flex_proportions.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
-	 earlycpio.o seq_buf.o nmi_backtrace.o nodemask.o win_minmax.o
+	 earlycpio.o seq_buf.o siphash.o \
+	 nmi_backtrace.o nodemask.o win_minmax.o
 
 lib-$(CONFIG_MMU) += ioremap.o
 lib-$(CONFIG_SMP) += cpumask.o
@@ -44,7 +45,7 @@ obj-$(CONFIG_TEST_HEXDUMP) += test_hexdump.o
 obj-y += kstrtox.o
 obj-$(CONFIG_TEST_BPF) += test_bpf.o
 obj-$(CONFIG_TEST_FIRMWARE) += test_firmware.o
-obj-$(CONFIG_TEST_HASH) += test_hash.o
+obj-$(CONFIG_TEST_HASH) += test_hash.o test_siphash.o
 obj-$(CONFIG_TEST_KASAN) += test_kasan.o
 obj-$(CONFIG_TEST_KSTRTOX) += test-kstrtox.o
 obj-$(CONFIG_TEST_LKM) += test_module.o
diff --git a/lib/siphash.c b/lib/siphash.c
new file mode 100644
index 000000000000..7efc273de5d0
--- /dev/null
+++ b/lib/siphash.c
@@ -0,0 +1,210 @@
+/* Copyright (C) 2016 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.
+ *
+ * SipHash: a fast short-input PRF
+ * https://131002.net/siphash/
+ *
+ * This implementation is specifically for SipHash2-4.
+ */
+
+#include <linux/siphash.h>
+#include <asm/unaligned.h>
+
+#if defined(CONFIG_DCACHE_WORD_ACCESS) && BITS_PER_LONG == 64
+#include <linux/dcache.h>
+#include <asm/word-at-a-time.h>
+#endif
+
+#define SIPROUND \
+	do { \
+	v0 += v1; v1 = rol64(v1, 13); v1 ^= v0; v0 = rol64(v0, 32); \
+	v2 += v3; v3 = rol64(v3, 16); v3 ^= v2; \
+	v0 += v3; v3 = rol64(v3, 21); v3 ^= v0; \
+	v2 += v1; v1 = rol64(v1, 17); v1 ^= v2; v2 = rol64(v2, 32); \
+	} while(0)
+
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
+u64 __siphash_aligned(const void *data, size_t len, const siphash_key_t key)
+{
+	const u8 *end = data + len - (len % sizeof(u64));
+	const u8 left = len & (sizeof(u64) - 1);
+	u64 m;
+	PREAMBLE(len)
+	for (; data != end; data += sizeof(u64)) {
+		m = le64_to_cpup(data);
+		v3 ^= m;
+		SIPROUND;
+		SIPROUND;
+		v0 ^= m;
+	}
+#if defined(CONFIG_DCACHE_WORD_ACCESS) && BITS_PER_LONG == 64
+	if (left)
+		b |= le64_to_cpu((__force __le64)(load_unaligned_zeropad(data) &
+						  bytemask_from_count(left)));
+#else
+	switch (left) {
+	case 7: b |= ((u64)end[6]) << 48;
+	case 6: b |= ((u64)end[5]) << 40;
+	case 5: b |= ((u64)end[4]) << 32;
+	case 4: b |= le32_to_cpup(data); break;
+	case 3: b |= ((u64)end[2]) << 16;
+	case 2: b |= le16_to_cpup(data); break;
+	case 1: b |= end[0];
+	}
+#endif
+	POSTAMBLE
+}
+EXPORT_SYMBOL(__siphash_aligned);
+
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+u64 __siphash_unaligned(const void *data, size_t len, const siphash_key_t key)
+{
+	const u8 *end = data + len - (len % sizeof(u64));
+	const u8 left = len & (sizeof(u64) - 1);
+	u64 m;
+	PREAMBLE(len)
+	for (; data != end; data += sizeof(u64)) {
+		m = get_unaligned_le64(data);
+		v3 ^= m;
+		SIPROUND;
+		SIPROUND;
+		v0 ^= m;
+	}
+#if defined(CONFIG_DCACHE_WORD_ACCESS) && BITS_PER_LONG == 64
+	if (left)
+		b |= le64_to_cpu((__force __le64)(load_unaligned_zeropad(data) &
+						  bytemask_from_count(left)));
+#else
+	switch (left) {
+	case 7: b |= ((u64)end[6]) << 48;
+	case 6: b |= ((u64)end[5]) << 40;
+	case 5: b |= ((u64)end[4]) << 32;
+	case 4: b |= get_unaligned_le32(end); break;
+	case 3: b |= ((u64)end[2]) << 16;
+	case 2: b |= get_unaligned_le16(end); break;
+	case 1: b |= end[0];
+	}
+#endif
+	POSTAMBLE
+}
+EXPORT_SYMBOL(__siphash_unaligned);
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
+	SIPROUND;
+	SIPROUND;
+	v0 ^= first;
+	v3 ^= second;
+	SIPROUND;
+	SIPROUND;
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
+	POSTAMBLE
+}
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
new file mode 100644
index 000000000000..906e58a2c946
--- /dev/null
+++ b/lib/test_siphash.c
@@ -0,0 +1,101 @@
+/* Test cases for siphash.c
+ *
+ * Copyright (C) 2016 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.
+ *
+ * SipHash: a fast short-input PRF
+ * https://131002.net/siphash/
+ *
+ * This implementation is specifically for SipHash2-4.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/siphash.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/module.h>
+
+/* Test vectors taken from official reference source available at:
+ *     https://131002.net/siphash/siphash24.c
+ */
+static const u64 test_vectors[64] = {
+	0x726fdb47dd0e0e31ULL, 0x74f839c593dc67fdULL, 0x0d6c8009d9a94f5aULL,
+	0x85676696d7fb7e2dULL, 0xcf2794e0277187b7ULL, 0x18765564cd99a68dULL,
+	0xcbc9466e58fee3ceULL, 0xab0200f58b01d137ULL, 0x93f5f5799a932462ULL,
+	0x9e0082df0ba9e4b0ULL, 0x7a5dbbc594ddb9f3ULL, 0xf4b32f46226bada7ULL,
+	0x751e8fbc860ee5fbULL, 0x14ea5627c0843d90ULL, 0xf723ca908e7af2eeULL,
+	0xa129ca6149be45e5ULL, 0x3f2acc7f57c29bdbULL, 0x699ae9f52cbe4794ULL,
+	0x4bc1b3f0968dd39cULL, 0xbb6dc91da77961bdULL, 0xbed65cf21aa2ee98ULL,
+	0xd0f2cbb02e3b67c7ULL, 0x93536795e3a33e88ULL, 0xa80c038ccd5ccec8ULL,
+	0xb8ad50c6f649af94ULL, 0xbce192de8a85b8eaULL, 0x17d835b85bbb15f3ULL,
+	0x2f2e6163076bcfadULL, 0xde4daaaca71dc9a5ULL, 0xa6a2506687956571ULL,
+	0xad87a3535c49ef28ULL, 0x32d892fad841c342ULL, 0x7127512f72f27cceULL,
+	0xa7f32346f95978e3ULL, 0x12e0b01abb051238ULL, 0x15e034d40fa197aeULL,
+	0x314dffbe0815a3b4ULL, 0x027990f029623981ULL, 0xcadcd4e59ef40c4dULL,
+	0x9abfd8766a33735cULL, 0x0e3ea96b5304a7d0ULL, 0xad0c42d6fc585992ULL,
+	0x187306c89bc215a9ULL, 0xd4a60abcf3792b95ULL, 0xf935451de4f21df2ULL,
+	0xa9538f0419755787ULL, 0xdb9acddff56ca510ULL, 0xd06c98cd5c0975ebULL,
+	0xe612a3cb9ecba951ULL, 0xc766e62cfcadaf96ULL, 0xee64435a9752fe72ULL,
+	0xa192d576b245165aULL, 0x0a8787bf8ecb74b2ULL, 0x81b3e73d20b49b6fULL,
+	0x7fa8220ba3b2eceaULL, 0x245731c13ca42499ULL, 0xb78dbfaf3a8d83bdULL,
+	0xea1ad565322a1a0bULL, 0x60e61c23a3795013ULL, 0x6606d7e446282b93ULL,
+	0x6ca4ecb15c5f91e1ULL, 0x9f626da15c9625f3ULL, 0xe51b38608ef25f57ULL,
+	0x958a324ceb064572ULL
+};
+static const siphash_key_t test_key =
+	{ 0x0706050403020100ULL , 0x0f0e0d0c0b0a0908ULL };
+
+static int __init siphash_test_init(void)
+{
+	u8 in[64] __aligned(SIPHASH_ALIGNMENT);
+	u8 in_unaligned[65];
+	u8 i;
+	int ret = 0;
+
+	for (i = 0; i < 64; ++i) {
+		in[i] = i;
+		in_unaligned[i + 1] = i;
+		if (siphash(in, i, test_key) != test_vectors[i]) {
+			pr_info("self-test aligned %u: FAIL\n", i + 1);
+			ret = -EINVAL;
+		}
+		if (siphash(in_unaligned + 1, i, test_key) != test_vectors[i]) {
+			pr_info("self-test unaligned %u: FAIL\n", i + 1);
+			ret = -EINVAL;
+		}
+	}
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
+	if (!ret)
+		pr_info("self-tests: pass\n");
+	return ret;
+}
+
+static void __exit siphash_test_exit(void)
+{
+}
+
+module_init(siphash_test_init);
+module_exit(siphash_test_exit);
+
+MODULE_AUTHOR("Jason A. Donenfeld <Jason@zx2c4.com>");
+MODULE_LICENSE("Dual BSD/GPL");
-- 
2.11.0
