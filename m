From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: [PATCH net-next] Revert "fast_hash: avoid indirect function calls"
Date: Fri, 14 Nov 2014 11:05:06 -0800
Message-ID: <16481.1415991906@famine>
References: <1415978022.15154.31.camel@localhost> <1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com> <1415979978.15154.41.camel@localhost> <20141114.133829.1437047454714311242.davem@davemloft.net>
Cc: hannes@stressinduktion.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, discuss@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:50617 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161184AbaKNTFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 14:05:17 -0500
In-reply-to: <20141114.133829.1437047454714311242.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This reverts commit e5a2c899957659cd1a9f789bc462f9c0b35f5150.

	Commit e5a2c899 introduced an alternative_call, arch_fast_hash2,
that selects between __jhash2 and __intel_crc4_2_hash based on the
X86_FEATURE_XMM4_2.

	Unfortunately, the alternative_call system does not appear to be
suitable for use with C functions, as register usage is not handled
properly for the called functions.  The __jhash2 function in particular
clobbers registers that are not preserved when called via
alternative_call, resulting in a panic for direct callers of
arch_fast_hash2 on older CPUs lacking sse4_2.  It is possible that
__intel_crc4_2_hash works merely by chance because it uses fewer
registers.

	This commit was suggested as the source of the problem by Jesse
Gross <jesse@nicira.com>.

Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

---
 arch/x86/include/asm/hash.h | 51 +++++----------------------------------------
 arch/x86/lib/hash.c         | 29 +++++++++++---------------
 include/asm-generic/hash.h  | 36 ++------------------------------
 include/linux/hash.h        | 34 ++++++++++++++++++++++++++++++
 lib/Makefile                |  2 +-
 lib/hash.c                  | 39 ++++++++++++++++++++++++++++++++++
 6 files changed, 93 insertions(+), 98 deletions(-)
 create mode 100644 lib/hash.c

diff --git a/arch/x86/include/asm/hash.h b/arch/x86/include/asm/hash.h
index a881d78..e8c58f8 100644
--- a/arch/x86/include/asm/hash.h
+++ b/arch/x86/include/asm/hash.h
@@ -1,48 +1,7 @@
-#ifndef __ASM_X86_HASH_H
-#define __ASM_X86_HASH_H
+#ifndef _ASM_X86_HASH_H
+#define _ASM_X86_HASH_H
 
-#include <linux/cpufeature.h>
-#include <asm/alternative.h>
+struct fast_hash_ops;
+extern void setup_arch_fast_hash(struct fast_hash_ops *ops);
 
-u32 __intel_crc4_2_hash(const void *data, u32 len, u32 seed);
-u32 __intel_crc4_2_hash2(const u32 *data, u32 len, u32 seed);
-
-/*
- * non-inline versions of jhash so gcc does not need to generate
- * duplicate code in every object file
- */
-u32 __jhash(const void *data, u32 len, u32 seed);
-u32 __jhash2(const u32 *data, u32 len, u32 seed);
-
-/*
- * for documentation of these functions please look into
- * <include/asm-generic/hash.h>
- */
-
-static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
-{
-	u32 hash;
-
-	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
-#ifdef CONFIG_X86_64
-			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
-#else
-			 "=a" (hash), "a" (data), "d" (len), "c" (seed));
-#endif
-	return hash;
-}
-
-static inline u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
-{
-	u32 hash;
-
-	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
-#ifdef CONFIG_X86_64
-			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
-#else
-			 "=a" (hash), "a" (data), "d" (len), "c" (seed));
-#endif
-	return hash;
-}
-
-#endif /* __ASM_X86_HASH_H */
+#endif /* _ASM_X86_HASH_H */
diff --git a/arch/x86/lib/hash.c b/arch/x86/lib/hash.c
index e143271..ff4fa51 100644
--- a/arch/x86/lib/hash.c
+++ b/arch/x86/lib/hash.c
@@ -31,13 +31,13 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <linux/hash.h>
+#include <linux/init.h>
+
 #include <asm/processor.h>
 #include <asm/cpufeature.h>
 #include <asm/hash.h>
 
-#include <linux/hash.h>
-#include <linux/jhash.h>
-
 static inline u32 crc32_u32(u32 crc, u32 val)
 {
 #ifdef CONFIG_AS_CRC32
@@ -48,7 +48,7 @@ static inline u32 crc32_u32(u32 crc, u32 val)
 	return crc;
 }
 
-u32 __intel_crc4_2_hash(const void *data, u32 len, u32 seed)
+static u32 intel_crc4_2_hash(const void *data, u32 len, u32 seed)
 {
 	const u32 *p32 = (const u32 *) data;
 	u32 i, tmp = 0;
@@ -71,27 +71,22 @@ u32 __intel_crc4_2_hash(const void *data, u32 len, u32 seed)
 
 	return seed;
 }
-EXPORT_SYMBOL(__intel_crc4_2_hash);
 
-u32 __intel_crc4_2_hash2(const u32 *data, u32 len, u32 seed)
+static u32 intel_crc4_2_hash2(const u32 *data, u32 len, u32 seed)
 {
+	const u32 *p32 = (const u32 *) data;
 	u32 i;
 
 	for (i = 0; i < len; i++)
-		seed = crc32_u32(seed, *data++);
+		seed = crc32_u32(seed, *p32++);
 
 	return seed;
 }
-EXPORT_SYMBOL(__intel_crc4_2_hash2);
 
-u32 __jhash(const void *data, u32 len, u32 seed)
+void __init setup_arch_fast_hash(struct fast_hash_ops *ops)
 {
-	return jhash(data, len, seed);
-}
-EXPORT_SYMBOL(__jhash);
-
-u32 __jhash2(const u32 *data, u32 len, u32 seed)
-{
-	return jhash2(data, len, seed);
+	if (cpu_has_xmm4_2) {
+		ops->hash  = intel_crc4_2_hash;
+		ops->hash2 = intel_crc4_2_hash2;
+	}
 }
-EXPORT_SYMBOL(__jhash2);
diff --git a/include/asm-generic/hash.h b/include/asm-generic/hash.h
index 3c82760..b631284 100644
--- a/include/asm-generic/hash.h
+++ b/include/asm-generic/hash.h
@@ -1,41 +1,9 @@
 #ifndef __ASM_GENERIC_HASH_H
 #define __ASM_GENERIC_HASH_H
 
-#include <linux/jhash.h>
-
-/**
- *	arch_fast_hash - Caclulates a hash over a given buffer that can have
- *			 arbitrary size. This function will eventually use an
- *			 architecture-optimized hashing implementation if
- *			 available, and trades off distribution for speed.
- *
- *	@data: buffer to hash
- *	@len: length of buffer in bytes
- *	@seed: start seed
- *
- *	Returns 32bit hash.
- */
-static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
-{
-	return jhash(data, len, seed);
-}
-
-/**
- *	arch_fast_hash2 - Caclulates a hash over a given buffer that has a
- *			  size that is of a multiple of 32bit words. This
- *			  function will eventually use an architecture-
- *			  optimized hashing implementation if available,
- *			  and trades off distribution for speed.
- *
- *	@data: buffer to hash (must be 32bit padded)
- *	@len: number of 32bit words
- *	@seed: start seed
- *
- *	Returns 32bit hash.
- */
-static inline u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
+struct fast_hash_ops;
+static inline void setup_arch_fast_hash(struct fast_hash_ops *ops)
 {
-	return jhash2(data, len, seed);
 }
 
 #endif /* __ASM_GENERIC_HASH_H */
diff --git a/include/linux/hash.h b/include/linux/hash.h
index 6e8fb02..d0494c3 100644
--- a/include/linux/hash.h
+++ b/include/linux/hash.h
@@ -84,4 +84,38 @@ static inline u32 hash32_ptr(const void *ptr)
 	return (u32)val;
 }
 
+struct fast_hash_ops {
+	u32 (*hash)(const void *data, u32 len, u32 seed);
+	u32 (*hash2)(const u32 *data, u32 len, u32 seed);
+};
+
+/**
+ *	arch_fast_hash - Caclulates a hash over a given buffer that can have
+ *			 arbitrary size. This function will eventually use an
+ *			 architecture-optimized hashing implementation if
+ *			 available, and trades off distribution for speed.
+ *
+ *	@data: buffer to hash
+ *	@len: length of buffer in bytes
+ *	@seed: start seed
+ *
+ *	Returns 32bit hash.
+ */
+extern u32 arch_fast_hash(const void *data, u32 len, u32 seed);
+
+/**
+ *	arch_fast_hash2 - Caclulates a hash over a given buffer that has a
+ *			  size that is of a multiple of 32bit words. This
+ *			  function will eventually use an architecture-
+ *			  optimized hashing implementation if available,
+ *			  and trades off distribution for speed.
+ *
+ *	@data: buffer to hash (must be 32bit padded)
+ *	@len: number of 32bit words
+ *	@seed: start seed
+ *
+ *	Returns 32bit hash.
+ */
+extern u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed);
+
 #endif /* _LINUX_HASH_H */
diff --git a/lib/Makefile b/lib/Makefile
index 04e53dd..7512dc9 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -26,7 +26,7 @@ obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
 	 bust_spinlocks.o hexdump.o kasprintf.o bitmap.o scatterlist.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iovec.o clz_ctz.o \
 	 bsearch.o find_last_bit.o find_next_bit.o llist.o memweight.o kfifo.o \
-	 percpu-refcount.o percpu_ida.o rhashtable.o
+	 percpu-refcount.o percpu_ida.o hash.o rhashtable.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
 obj-y += kstrtox.o
diff --git a/lib/hash.c b/lib/hash.c
new file mode 100644
index 0000000..fea973f
--- /dev/null
+++ b/lib/hash.c
@@ -0,0 +1,39 @@
+/* General purpose hashing library
+ *
+ * That's a start of a kernel hashing library, which can be extended
+ * with further algorithms in future. arch_fast_hash{2,}() will
+ * eventually resolve to an architecture optimized implementation.
+ *
+ * Copyright 2013 Francesco Fusco <ffusco@redhat.com>
+ * Copyright 2013 Daniel Borkmann <dborkman@redhat.com>
+ * Copyright 2013 Thomas Graf <tgraf@redhat.com>
+ * Licensed under the GNU General Public License, version 2.0 (GPLv2)
+ */
+
+#include <linux/jhash.h>
+#include <linux/hash.h>
+#include <linux/cache.h>
+
+static struct fast_hash_ops arch_hash_ops __read_mostly = {
+	.hash  = jhash,
+	.hash2 = jhash2,
+};
+
+u32 arch_fast_hash(const void *data, u32 len, u32 seed)
+{
+	return arch_hash_ops.hash(data, len, seed);
+}
+EXPORT_SYMBOL_GPL(arch_fast_hash);
+
+u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
+{
+	return arch_hash_ops.hash2(data, len, seed);
+}
+EXPORT_SYMBOL_GPL(arch_fast_hash2);
+
+static int __init hashlib_init(void)
+{
+	setup_arch_fast_hash(&arch_hash_ops);
+	return 0;
+}
+early_initcall(hashlib_init);
-- 
1.9.1
