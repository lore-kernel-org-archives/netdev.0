From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Thu, 15 Dec 2016 21:30:00 +0100
Message-ID: <20161215203003.31989-2-Jason@zx2c4.com>
References: <20161215203003.31989-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
	"Daniel J . Bernstein" <djb@cr.yp.to>
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
Return-path: <kernel-hardening-return-5592-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161215203003.31989-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

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
it is likely a tiny bit slower than the insecure jhash, and so replacements
will be evaluated on a case-by-case basis based on whether or not the
difference in speed is negligible and whether or not the current jhash usage
poses a real security risk.

For the second usage:

A few places in the kernel are using MD5 for creating secure sequence
numbers, port numbers, or fast random numbers. SipHash is a faster, more
fitting, and more secure replacement for MD5 in those situations.
Replacing MD5 with SipHash for these uses is obvious and straight-
forward, and so is submitted along with this patch series. There
shouldn't be much of a debate over its efficacy.

Dozens of languages are already using this internally for their hash
tables and PRFs. Some of the BSDs already use this in their kernels.
SipHash is a widely known high-speed solution to a widely known set of
problems, and it's time we catch-up.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Cc: Daniel J. Bernstein <djb@cr.yp.to>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Eric Biggers <ebiggers3@gmail.com>
Cc: David Laight <David.Laight@aculab.com>
---
 include/linux/siphash.h |  32 +++++++++++
 lib/Kconfig.debug       |   6 +--
 lib/Makefile            |   5 +-
 lib/siphash.c           | 138 ++++++++++++++++++++++++++++++++++++++++++++++++
 lib/test_siphash.c      |  83 +++++++++++++++++++++++++++++
 5 files changed, 259 insertions(+), 5 deletions(-)
 create mode 100644 include/linux/siphash.h
 create mode 100644 lib/siphash.c
 create mode 100644 lib/test_siphash.c

diff --git a/include/linux/siphash.h b/include/linux/siphash.h
new file mode 100644
index 000000000000..145cf5667078
--- /dev/null
+++ b/include/linux/siphash.h
@@ -0,0 +1,32 @@
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
+
+#define SIPHASH_ALIGNMENT 8
+
+typedef u64 siphash_key_t[2];
+
+u64 siphash(const void *data, size_t len, const siphash_key_t key);
+
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+static inline u64 siphash_unaligned(const void *data, size_t len,
+				    const siphash_key_t key)
+{
+	return siphash(data, len, key);
+}
+#else
+u64 siphash_unaligned(const void *data, size_t len, const siphash_key_t key);
+#endif
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
index 000000000000..afc13cbb1b78
--- /dev/null
+++ b/lib/siphash.c
@@ -0,0 +1,138 @@
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
+#include <linux/kernel.h>
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
+/**
+ * siphash - compute 64-bit siphash PRF value
+ * @data: buffer to hash, must be aligned to SIPHASH_ALIGNMENT
+ * @size: size of @data
+ * @key: the siphash key
+ */
+u64 siphash(const void *data, size_t len, const siphash_key_t key)
+{
+	u64 v0 = 0x736f6d6570736575ULL;
+	u64 v1 = 0x646f72616e646f6dULL;
+	u64 v2 = 0x6c7967656e657261ULL;
+	u64 v3 = 0x7465646279746573ULL;
+	u64 b = ((u64)len) << 56;
+	u64 m;
+	const u8 *end = data + len - (len % sizeof(u64));
+	const u8 left = len & (sizeof(u64) - 1);
+	v3 ^= key[1];
+	v2 ^= key[0];
+	v1 ^= key[1];
+	v0 ^= key[0];
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
+	v3 ^= b;
+	SIPROUND;
+	SIPROUND;
+	v0 ^= b;
+	v2 ^= 0xff;
+	SIPROUND;
+	SIPROUND;
+	SIPROUND;
+	SIPROUND;
+	return (v0 ^ v1) ^ (v2 ^ v3);
+}
+EXPORT_SYMBOL(siphash);
+
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+/**
+ * siphash - compute 64-bit siphash PRF value, without alignment requirements
+ * @data: buffer to hash
+ * @size: size of @data
+ * @key: the siphash key
+ */
+u64 siphash_unaligned(const void *data, size_t len, const siphash_key_t key)
+{
+	u64 v0 = 0x736f6d6570736575ULL;
+	u64 v1 = 0x646f72616e646f6dULL;
+	u64 v2 = 0x6c7967656e657261ULL;
+	u64 v3 = 0x7465646279746573ULL;
+	u64 b = ((u64)len) << 56;
+	u64 m;
+	const u8 *end = data + len - (len % sizeof(u64));
+	const u8 left = len & (sizeof(u64) - 1);
+	v3 ^= key[1];
+	v2 ^= key[0];
+	v1 ^= key[1];
+	v0 ^= key[0];
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
+	case 1: b |= bytes[0];
+	}
+#endif
+	v3 ^= b;
+	SIPROUND;
+	SIPROUND;
+	v0 ^= b;
+	v2 ^= 0xff;
+	SIPROUND;
+	SIPROUND;
+	SIPROUND;
+	SIPROUND;
+	return (v0 ^ v1) ^ (v2 ^ v3);
+}
+EXPORT_SYMBOL(siphash_unaligned);
+#endif
diff --git a/lib/test_siphash.c b/lib/test_siphash.c
new file mode 100644
index 000000000000..93549e4e22c5
--- /dev/null
+++ b/lib/test_siphash.c
@@ -0,0 +1,83 @@
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
+		if (siphash_unaligned(in_unaligned + 1, i, test_key) != test_vectors[i]) {
+			pr_info("self-test unaligned %u: FAIL\n", i + 1);
+			ret = -EINVAL;
+		}
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
