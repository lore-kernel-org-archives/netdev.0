From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] arch_fast_hash: avoid indirect function calls and implement hash in asm
Date: Thu,  4 Dec 2014 14:08:50 +0100
Message-ID: <e77237174e1b8d743ef5171e05abde82bc54af37.1417696901.git.hannes@stressinduktion.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:59424 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753402AbaLDNI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 08:08:58 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 28C092083F
	for <netdev@vger.kernel.org>; Thu,  4 Dec 2014 08:08:57 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default the arch_fast_hash hashing function pointers are initialized
to jhash(2). If during boot-up a CPU with SSE4.2 is detected they get
updated to the CRC32 ones. This dispatching scheme incurs a function
pointer lookup and indirect call for every hashing operation.

To keep the number of clobbered registers short the hashing primitives
are implemented in assembler. This makes it easier to do the dispatch
by alternative_call.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 arch/x86/include/asm/hash.h      |  53 ++++++++++-
 arch/x86/kernel/i386_ksyms_32.c  |   6 ++
 arch/x86/kernel/x8664_ksyms_64.c |   6 ++
 arch/x86/lib/Makefile            |   2 +-
 arch/x86/lib/arch_hash.S         | 192 +++++++++++++++++++++++++++++++++++++++
 arch/x86/lib/hash.c              |  92 -------------------
 arch/x86/lib/jhash.c             |   6 ++
 include/asm-generic/hash.h       |  18 +++-
 include/linux/hash.h             |  34 -------
 lib/Makefile                     |   2 +-
 lib/hash.c                       |  39 --------
 net/openvswitch/flow_table.c     |   2 +-
 12 files changed, 280 insertions(+), 172 deletions(-)
 create mode 100644 arch/x86/lib/arch_hash.S
 delete mode 100644 arch/x86/lib/hash.c
 create mode 100644 arch/x86/lib/jhash.c
 delete mode 100644 lib/hash.c

diff --git a/arch/x86/include/asm/hash.h b/arch/x86/include/asm/hash.h
index e8c58f8..620081b 100644
--- a/arch/x86/include/asm/hash.h
+++ b/arch/x86/include/asm/hash.h
@@ -1,7 +1,56 @@
 #ifndef _ASM_X86_HASH_H
 #define _ASM_X86_HASH_H
 
-struct fast_hash_ops;
-extern void setup_arch_fast_hash(struct fast_hash_ops *ops);
+#include <linux/cpufeature.h>
+#include <asm/alternative.h>
+
+#include <linux/jhash.h>
+
+#ifdef CONFIG_AS_CRC32
+
+u32 __jhash_trampoline(const void *data, u32 len, u32 seed);
+u32 __sse42_crc32(const void *data, u32 len, u32 seed);
+
+#ifdef CONFIG_X86_64
+
+static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
+{
+	u32 hash;
+
+	alternative_call(__jhash_trampoline, __sse42_crc32, X86_FEATURE_XMM4_2,
+			 ASM_OUTPUT2("=a" (hash), "=D" (data), "=S" (len),
+				     "=d" (seed)),
+			 "1" (data), "2" (len), "3" (seed)
+			 : "memory", "cc");
+
+	return hash;
+}
+
+#else /* CONFIG_X86_64 */
+
+static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
+{
+	u32 hash;
+
+	alternative_call(__jhash_trampoline, __sse42_crc32, X86_FEATURE_XMM4_2,
+			 ASM_OUTPUT2("=a" (hash), "=d" (len), "=c" (seed)),
+			 "0" (data), "1" (len), "2" (seed)
+			 : "memory", "cc");
+
+	return hash;
+}
+
+#endif /* CONFIG_x86_64 */
+
+#else /* CONFIG_AS_CRC32 */
+
+u32 __jhash(const void *data, u32 len, u32 seed);
+
+static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
+{
+	return __jhash(data, len, seed);
+}
+
+#endif
 
 #endif /* _ASM_X86_HASH_H */
diff --git a/arch/x86/kernel/i386_ksyms_32.c b/arch/x86/kernel/i386_ksyms_32.c
index 05fd74f..afb98da 100644
--- a/arch/x86/kernel/i386_ksyms_32.c
+++ b/arch/x86/kernel/i386_ksyms_32.c
@@ -1,4 +1,5 @@
 #include <linux/module.h>
+#include <linux/hash.h>
 
 #include <asm/checksum.h>
 #include <asm/pgtable.h>
@@ -38,6 +39,11 @@ EXPORT_SYMBOL(strstr);
 EXPORT_SYMBOL(csum_partial);
 EXPORT_SYMBOL(empty_zero_page);
 
+#ifdef CONFIG_AS_CRC32
+EXPORT_SYMBOL(__sse42_crc32);
+EXPORT_SYMBOL(__jhash_trampoline);
+#endif
+
 #ifdef CONFIG_PREEMPT
 EXPORT_SYMBOL(___preempt_schedule);
 #ifdef CONFIG_CONTEXT_TRACKING
diff --git a/arch/x86/kernel/x8664_ksyms_64.c b/arch/x86/kernel/x8664_ksyms_64.c
index 0406819..1094c13 100644
--- a/arch/x86/kernel/x8664_ksyms_64.c
+++ b/arch/x86/kernel/x8664_ksyms_64.c
@@ -3,6 +3,7 @@
 
 #include <linux/module.h>
 #include <linux/smp.h>
+#include <linux/hash.h>
 
 #include <net/checksum.h>
 
@@ -42,6 +43,11 @@ EXPORT_SYMBOL(clear_page);
 
 EXPORT_SYMBOL(csum_partial);
 
+#ifdef CONFIG_AS_CRC32
+EXPORT_SYMBOL(__sse42_crc32);
+EXPORT_SYMBOL(__jhash_trampoline);
+#endif
+
 /*
  * Export string functions. We normally rely on gcc builtin for most of these,
  * but gcc sometimes decides not to inline them.
diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
index db92793..168bbef 100644
--- a/arch/x86/lib/Makefile
+++ b/arch/x86/lib/Makefile
@@ -23,7 +23,7 @@ lib-y += memcpy_$(BITS).o
 lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem.o
 lib-$(CONFIG_INSTRUCTION_DECODER) += insn.o inat.o
 
-obj-y += msr.o msr-reg.o msr-reg-export.o hash.o
+obj-y += msr.o msr-reg.o msr-reg-export.o jhash.o arch_hash.o
 
 ifeq ($(CONFIG_X86_32),y)
         obj-y += atomic64_32.o
diff --git a/arch/x86/lib/arch_hash.S b/arch/x86/lib/arch_hash.S
new file mode 100644
index 0000000..ff526a4
--- /dev/null
+++ b/arch/x86/lib/arch_hash.S
@@ -0,0 +1,192 @@
+#include <linux/linkage.h>
+#include <asm/dwarf2.h>
+#include <asm/calling.h>
+
+#ifdef CONFIG_AS_CRC32
+
+#ifdef CONFIG_X86_64
+
+ENTRY(__jhash_trampoline)
+	CFI_STARTPROC
+
+	pushq_cfi %rcx
+	pushq_cfi %r8
+	pushq_cfi %r9
+	pushq_cfi %r10
+	pushq_cfi %r11
+
+	call __jhash
+
+	popq_cfi %r11
+	popq_cfi %r10
+	popq_cfi %r9
+	popq_cfi %r8
+	popq_cfi %rcx
+
+	retq
+
+	CFI_ENDPROC
+ENDPROC(__jhash_trampoline)
+
+ENTRY(__sse42_crc32)
+	CFI_STARTPROC
+
+	movq %rdx, %rax
+	cmpq $0x40, %rsi
+	jb .Lcrc_32bytes
+	subq $0x40, %rsi
+
+.Lcrc_64bytes:
+	subq $0x40, %rsi
+	crc32q 0*8(%rdi), %rax
+	crc32q 1*8(%rdi), %rax
+	crc32q 2*8(%rdi), %rax
+	crc32q 3*8(%rdi), %rax
+	crc32q 4*8(%rdi), %rax
+	crc32q 5*8(%rdi), %rax
+	crc32q 6*8(%rdi), %rax
+	crc32q 7*8(%rdi), %rax
+	leaq   8*8(%rdi), %rdi
+	jae .Lcrc_64bytes
+	addq $0x40, %rsi
+
+.Lcrc_32bytes:
+	cmpq $0x20, %rsi
+	jb .Lcrc_16bytes
+
+	subq $0x20, %rsi
+	crc32q 0*8(%rdi), %rax
+	crc32q 1*8(%rdi), %rax
+	crc32q 2*8(%rdi), %rax
+	crc32q 3*8(%rdi), %rax
+	leaq   4*8(%rdi), %rdi
+
+.Lcrc_16bytes:
+	cmpq $0x10, %rsi
+	jb .Lcrc_8bytes
+
+	subq $0x10, %rsi
+	crc32q 0*8(%rdi), %rax
+	crc32q 1*8(%rdi), %rax
+	leaq   2*8(%rdi), %rdi
+
+.Lcrc_8bytes:
+	cmpq $0x8, %rsi
+	jb .Lcrc_4bytes
+
+	subq $0x8, %rsi
+	crc32q (%rdi), %rax
+	leaq 1*8(%rdi), %rdi
+
+.Lcrc_4bytes:
+	cmpq $0x4, %rsi
+	jb .Lcrc_2bytes
+
+	subq $0x4, %rsi
+	crc32l (%rdi), %eax
+	leaq   1*4(%rdi), %rdi
+
+.Lcrc_2bytes:
+	cmpq $0x2, %rsi
+	jb .Lcrc_1bytes
+
+	subq $0x2, %rsi
+	crc32w (%rdi), %eax
+	leaq 1*2(%rdi), %rdi
+
+.Lcrc_1bytes:
+	cmpq $0x1, %rsi
+	jb .Lend
+
+	crc32b (%rdi), %eax
+.Lend:
+	retq
+	CFI_ENDPROC
+ENDPROC(__sse42_crc32)
+
+#else /* CONFIG_X86_32 */
+
+ENTRY(__jhash_trampoline)
+	CFI_STARTPROC
+
+	call __jhash
+
+	retl
+	CFI_ENDPROC
+ENDPROC(__jhash_trampoline)
+
+ENTRY(__sse42_crc32)
+	CFI_STARTPROC
+
+	xchgl %eax,%ecx
+	xchgl %edx,%ecx
+
+	cmpl $0x20, %ecx
+	jb .Lcrc_16bytes
+	subl $0x20, %ecx
+
+.Lcrc_32bytes:
+	subl $0x20, %ecx
+	crc32l 0*4(%edx), %eax
+	crc32l 1*4(%edx), %eax
+	crc32l 2*4(%edx), %eax
+	crc32l 3*4(%edx), %eax
+	crc32l 4*4(%edx), %eax
+	crc32l 5*4(%edx), %eax
+	crc32l 6*4(%edx), %eax
+	crc32l 7*4(%edx), %eax
+	leal   8*4(%edx), %edx
+	jae .Lcrc_32bytes
+	addl $0x20, %ecx
+
+.Lcrc_16bytes:
+	cmpl $0x10, %ecx
+	jb .Lcrc_8bytes
+
+	subl $0x10, %ecx
+	crc32l 0*4(%edx), %eax
+	crc32l 1*4(%edx), %eax
+	crc32l 2*4(%edx), %eax
+	crc32l 3*4(%edx), %eax
+	leal   4*4(%edx), %edx
+
+.Lcrc_8bytes:
+	cmpl $0x8, %ecx
+	jb .Lcrc_4bytes
+
+	subl $0x8, %ecx
+	crc32l 0*4(%edx), %eax
+	crc32l 1*4(%edx), %eax
+	leal   2*4(%edx), %edx
+
+.Lcrc_4bytes:
+	cmpl $0x4, %ecx
+	jb .Lcrc_2bytes
+
+	subl $0x4, %ecx
+	crc32l 0*4(%edx), %eax
+	leal   1*4(%edx), %edx
+
+.Lcrc_2bytes:
+	cmpl $0x2, %ecx
+	jb .Lcrc_1bytes
+
+	subl $0x2, %ecx
+	crc32w (%edx), %eax
+	leal   1*2(%edx), %edx
+
+.Lcrc_1bytes:
+	cmpl $0x1, %ecx
+	jb .Lend
+
+	crc32b (%edx), %eax
+
+.Lend:
+	retl
+
+	CFI_ENDPROC
+ENDPROC(__sse42_crc32)
+
+#endif
+
+#endif /* CONFIG_AS_CRC32 */
diff --git a/arch/x86/lib/hash.c b/arch/x86/lib/hash.c
deleted file mode 100644
index ff4fa51..0000000
--- a/arch/x86/lib/hash.c
+++ /dev/null
@@ -1,92 +0,0 @@
-/*
- * Some portions derived from code covered by the following notice:
- *
- * Copyright (c) 2010-2013 Intel Corporation. All rights reserved.
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- *
- *   * Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *   * Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in
- *     the documentation and/or other materials provided with the
- *     distribution.
- *   * Neither the name of Intel Corporation nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-
-#include <linux/hash.h>
-#include <linux/init.h>
-
-#include <asm/processor.h>
-#include <asm/cpufeature.h>
-#include <asm/hash.h>
-
-static inline u32 crc32_u32(u32 crc, u32 val)
-{
-#ifdef CONFIG_AS_CRC32
-	asm ("crc32l %1,%0\n" : "+r" (crc) : "rm" (val));
-#else
-	asm (".byte 0xf2, 0x0f, 0x38, 0xf1, 0xc1" : "+a" (crc) : "c" (val));
-#endif
-	return crc;
-}
-
-static u32 intel_crc4_2_hash(const void *data, u32 len, u32 seed)
-{
-	const u32 *p32 = (const u32 *) data;
-	u32 i, tmp = 0;
-
-	for (i = 0; i < len / 4; i++)
-		seed = crc32_u32(seed, *p32++);
-
-	switch (len & 3) {
-	case 3:
-		tmp |= *((const u8 *) p32 + 2) << 16;
-		/* fallthrough */
-	case 2:
-		tmp |= *((const u8 *) p32 + 1) << 8;
-		/* fallthrough */
-	case 1:
-		tmp |= *((const u8 *) p32);
-		seed = crc32_u32(seed, tmp);
-		break;
-	}
-
-	return seed;
-}
-
-static u32 intel_crc4_2_hash2(const u32 *data, u32 len, u32 seed)
-{
-	const u32 *p32 = (const u32 *) data;
-	u32 i;
-
-	for (i = 0; i < len; i++)
-		seed = crc32_u32(seed, *p32++);
-
-	return seed;
-}
-
-void __init setup_arch_fast_hash(struct fast_hash_ops *ops)
-{
-	if (cpu_has_xmm4_2) {
-		ops->hash  = intel_crc4_2_hash;
-		ops->hash2 = intel_crc4_2_hash2;
-	}
-}
diff --git a/arch/x86/lib/jhash.c b/arch/x86/lib/jhash.c
new file mode 100644
index 0000000..ab4b408
--- /dev/null
+++ b/arch/x86/lib/jhash.c
@@ -0,0 +1,6 @@
+#include <linux/jhash.h>
+
+u32 __jhash(const void *data, u32 len, u32 seed)
+{
+	return jhash(data, len, seed);
+}
diff --git a/include/asm-generic/hash.h b/include/asm-generic/hash.h
index b631284..07b8892 100644
--- a/include/asm-generic/hash.h
+++ b/include/asm-generic/hash.h
@@ -1,9 +1,23 @@
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
+u32 arch_fast_hash(const void *data, u32 len, u32 seed)
 {
+	return jhash(data, len, seed);
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
index 0211d2b..4b9baa4 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -26,7 +26,7 @@ obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
 	 bust_spinlocks.o hexdump.o kasprintf.o bitmap.o scatterlist.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iovec.o clz_ctz.o \
 	 bsearch.o find_last_bit.o find_next_bit.o llist.o memweight.o kfifo.o \
-	 percpu-refcount.o percpu_ida.o hash.o rhashtable.o reciprocal_div.o
+	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o
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
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index e0a7fef..79bc65d 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -366,7 +366,7 @@ static u32 flow_hash(const struct sw_flow_key *key, int key_start,
 	/* Make sure number of hash bytes are multiple of u32. */
 	BUILD_BUG_ON(sizeof(long) % sizeof(u32));
 
-	return arch_fast_hash2(hash_key, hash_u32s, 0);
+	return arch_fast_hash(hash_key, hash_u32s, 0);
 }
 
 static int flow_key_start(const struct sw_flow_key *key)
-- 
1.9.3
