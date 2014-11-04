From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] fast_hash: avoid indirect function calls
Date: Wed,  5 Nov 2014 00:23:04 +0100
Message-ID: <8214a3fdc8b7f97bb782c8722e9f1e65037553fe.1415142006.git.hannes@stressinduktion.org>
Cc: kernel@vger.kernel.org, dborkman@redhat.com,
	Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:41622 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752039AbaKDXXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 18:23:14 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 12A6A20338
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 18:23:12 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default the arch_fast_hash hashing function pointers are initialized
to jhash(2). If during boot-up a CPU with SSE4.2 is detected they get
updated to the CRC32 ones. This dispatching scheme incurs a function
pointer lookup and indirect call for every hashing operation.

rhashtable as a user of arch_fast_hash e.g. stores pointers to hashing
functions in its structure, too, causing two indirect branches per
hashing operation.

Using alternative_call we can get away with one of those indirect branches.

Acked-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
Hi,

I targetted net-next because original implementation went in over netdev@
and networking is the main user.

Would it make sense to start suppressing the generation of local
functions for static inline functions which address is taken?

E.g. we could use extern inline in a few cases (dst_output is often used
as a function pointer but marked static inline).  We could mark it as
extern inline and copy&paste the code to a .c file to prevent multiple
copies of machine code for this function. But because of the copy&paste I
did not in this case.

Bye,
Hannes

 arch/x86/include/asm/hash.h | 51 ++++++++++++++++++++++++++++++++++++++++-----
 arch/x86/lib/hash.c         | 29 +++++++++++++++-----------
 include/asm-generic/hash.h  | 36 ++++++++++++++++++++++++++++++--
 include/linux/hash.h        | 34 ------------------------------
 lib/Makefile                |  2 +-
 lib/hash.c                  | 39 ----------------------------------
 6 files changed, 98 insertions(+), 93 deletions(-)
 delete mode 100644 lib/hash.c

diff --git a/arch/x86/include/asm/hash.h b/arch/x86/include/asm/hash.h
index e8c58f8..a881d78 100644
--- a/arch/x86/include/asm/hash.h
+++ b/arch/x86/include/asm/hash.h
@@ -1,7 +1,48 @@
-#ifndef _ASM_X86_HASH_H
-#define _ASM_X86_HASH_H
+#ifndef __ASM_X86_HASH_H
+#define __ASM_X86_HASH_H
 
-struct fast_hash_ops;
-extern void setup_arch_fast_hash(struct fast_hash_ops *ops);
+#include <linux/cpufeature.h>
+#include <asm/alternative.h>
 
-#endif /* _ASM_X86_HASH_H */
+u32 __intel_crc4_2_hash(const void *data, u32 len, u32 seed);
+u32 __intel_crc4_2_hash2(const u32 *data, u32 len, u32 seed);
+
+/*
+ * non-inline versions of jhash so gcc does not need to generate
+ * duplicate code in every object file
+ */
+u32 __jhash(const void *data, u32 len, u32 seed);
+u32 __jhash2(const u32 *data, u32 len, u32 seed);
+
+/*
+ * for documentation of these functions please look into
+ * <include/asm-generic/hash.h>
+ */
+
+static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
+{
+	u32 hash;
+
+	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
+#ifdef CONFIG_X86_64
+			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
+#else
+			 "=a" (hash), "a" (data), "d" (len), "c" (seed));
+#endif
+	return hash;
+}
+
+static inline u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
+{
+	u32 hash;
+
+	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
+#ifdef CONFIG_X86_64
+			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
+#else
+			 "=a" (hash), "a" (data), "d" (len), "c" (seed));
+#endif
+	return hash;
+}
+
+#endif /* __ASM_X86_HASH_H */
diff --git a/arch/x86/lib/hash.c b/arch/x86/lib/hash.c
index ff4fa51..e143271 100644
--- a/arch/x86/lib/hash.c
+++ b/arch/x86/lib/hash.c
@@ -31,13 +31,13 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <linux/hash.h>
-#include <linux/init.h>
-
 #include <asm/processor.h>
 #include <asm/cpufeature.h>
 #include <asm/hash.h>
 
+#include <linux/hash.h>
+#include <linux/jhash.h>
+
 static inline u32 crc32_u32(u32 crc, u32 val)
 {
 #ifdef CONFIG_AS_CRC32
@@ -48,7 +48,7 @@ static inline u32 crc32_u32(u32 crc, u32 val)
 	return crc;
 }
 
-static u32 intel_crc4_2_hash(const void *data, u32 len, u32 seed)
+u32 __intel_crc4_2_hash(const void *data, u32 len, u32 seed)
 {
 	const u32 *p32 = (const u32 *) data;
 	u32 i, tmp = 0;
@@ -71,22 +71,27 @@ static u32 intel_crc4_2_hash(const void *data, u32 len, u32 seed)
 
 	return seed;
 }
+EXPORT_SYMBOL(__intel_crc4_2_hash);
 
-static u32 intel_crc4_2_hash2(const u32 *data, u32 len, u32 seed)
+u32 __intel_crc4_2_hash2(const u32 *data, u32 len, u32 seed)
 {
-	const u32 *p32 = (const u32 *) data;
 	u32 i;
 
 	for (i = 0; i < len; i++)
-		seed = crc32_u32(seed, *p32++);
+		seed = crc32_u32(seed, *data++);
 
 	return seed;
 }
+EXPORT_SYMBOL(__intel_crc4_2_hash2);
 
-void __init setup_arch_fast_hash(struct fast_hash_ops *ops)
+u32 __jhash(const void *data, u32 len, u32 seed)
 {
-	if (cpu_has_xmm4_2) {
-		ops->hash  = intel_crc4_2_hash;
-		ops->hash2 = intel_crc4_2_hash2;
-	}
+	return jhash(data, len, seed);
+}
+EXPORT_SYMBOL(__jhash);
+
+u32 __jhash2(const u32 *data, u32 len, u32 seed)
+{
+	return jhash2(data, len, seed);
 }
+EXPORT_SYMBOL(__jhash2);
diff --git a/include/asm-generic/hash.h b/include/asm-generic/hash.h
index b631284..3c82760 100644
--- a/include/asm-generic/hash.h
+++ b/include/asm-generic/hash.h
@@ -1,9 +1,41 @@
 #ifndef __ASM_GENERIC_HASH_H
 #define __ASM_GENERIC_HASH_H
 
-struct fast_hash_ops;
-static inline void setup_arch_fast_hash(struct fast_hash_ops *ops)
+#include <linux/jhash.h>
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
+static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
+{
+	return jhash(data, len, seed);
+}
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
+static inline u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
 {
+	return jhash2(data, len, seed);
 }
 
 #endif /* __ASM_GENERIC_HASH_H */
diff --git a/include/linux/hash.h b/include/linux/hash.h
index d0494c3..6e8fb02 100644
--- a/include/linux/hash.h
+++ b/include/linux/hash.h
@@ -84,38 +84,4 @@ static inline u32 hash32_ptr(const void *ptr)
 	return (u32)val;
 }
 
-struct fast_hash_ops {
-	u32 (*hash)(const void *data, u32 len, u32 seed);
-	u32 (*hash2)(const u32 *data, u32 len, u32 seed);
-};
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
-extern u32 arch_fast_hash(const void *data, u32 len, u32 seed);
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
-extern u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed);
-
 #endif /* _LINUX_HASH_H */
diff --git a/lib/Makefile b/lib/Makefile
index 7512dc9..04e53dd 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -26,7 +26,7 @@ obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
 	 bust_spinlocks.o hexdump.o kasprintf.o bitmap.o scatterlist.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iovec.o clz_ctz.o \
 	 bsearch.o find_last_bit.o find_next_bit.o llist.o memweight.o kfifo.o \
-	 percpu-refcount.o percpu_ida.o hash.o rhashtable.o
+	 percpu-refcount.o percpu_ida.o rhashtable.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
 obj-y += kstrtox.o
diff --git a/lib/hash.c b/lib/hash.c
deleted file mode 100644
index fea973f..0000000
--- a/lib/hash.c
+++ /dev/null
@@ -1,39 +0,0 @@
-/* General purpose hashing library
- *
- * That's a start of a kernel hashing library, which can be extended
- * with further algorithms in future. arch_fast_hash{2,}() will
- * eventually resolve to an architecture optimized implementation.
- *
- * Copyright 2013 Francesco Fusco <ffusco@redhat.com>
- * Copyright 2013 Daniel Borkmann <dborkman@redhat.com>
- * Copyright 2013 Thomas Graf <tgraf@redhat.com>
- * Licensed under the GNU General Public License, version 2.0 (GPLv2)
- */
-
-#include <linux/jhash.h>
-#include <linux/hash.h>
-#include <linux/cache.h>
-
-static struct fast_hash_ops arch_hash_ops __read_mostly = {
-	.hash  = jhash,
-	.hash2 = jhash2,
-};
-
-u32 arch_fast_hash(const void *data, u32 len, u32 seed)
-{
-	return arch_hash_ops.hash(data, len, seed);
-}
-EXPORT_SYMBOL_GPL(arch_fast_hash);
-
-u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
-{
-	return arch_hash_ops.hash2(data, len, seed);
-}
-EXPORT_SYMBOL_GPL(arch_fast_hash2);
-
-static int __init hashlib_init(void)
-{
-	setup_arch_fast_hash(&arch_hash_ops);
-	return 0;
-}
-early_initcall(hashlib_init);
-- 
1.9.3
