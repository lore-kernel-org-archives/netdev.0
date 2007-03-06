From: akpm@linux-foundation.org
Subject: [patch 2/2] div64_64: common code
Date: Tue, 06 Mar 2007 02:42:28 -0800
Message-ID: <200703061042.l26AgS0U019809@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	shemminger@linux-foundation.org, chris@zankel.net,
	geert@linux-m68k.org, jdike@addtoit.com, ralf@linux-mips.org,
	rmk@arm.linux.org.uk, zippel@linux-m68k.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34951 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964791AbXCFKqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:46:54 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>

Implement div64_64(): 64-bit by 64-bit division.  Needed by networking (at
least).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Russell King <rmk@arm.linux.org.uk>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Roman Zippel <zippel@linux-m68k.org>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Chris Zankel <chris@zankel.net>
Cc: Jeff Dike <jdike@addtoit.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/asm-arm/div64.h      |    3 +++
 include/asm-generic/div64.h  |    7 +++++++
 include/asm-i386/div64.h     |    4 ++++
 include/asm-m68k/div64.h     |    3 +++
 include/asm-mips/div64.h     |    4 ++++
 include/asm-um/div64.h       |    1 +
 include/asm-xtensa/div64.h   |    6 ++++++
 lib/Makefile                 |    5 +++--
 lib/div64.c                  |   22 ++++++++++++++++++++++
 net/ipv4/tcp_cubic.c         |   21 ---------------------
 net/netfilter/xt_connbytes.c |   16 ----------------
 11 files changed, 53 insertions(+), 39 deletions(-)

diff -puN include/asm-arm/div64.h~div64_64-common-code include/asm-arm/div64.h
--- a/include/asm-arm/div64.h~div64_64-common-code
+++ a/include/asm-arm/div64.h
@@ -2,6 +2,7 @@
 #define __ASM_ARM_DIV64
 
 #include <asm/system.h>
+#include <linux/types.h>
 
 /*
  * The semantics of do_div() are:
@@ -223,4 +224,6 @@
 
 #endif
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
+
 #endif
diff -puN include/asm-generic/div64.h~div64_64-common-code include/asm-generic/div64.h
--- a/include/asm-generic/div64.h~div64_64-common-code
+++ a/include/asm-generic/div64.h
@@ -30,6 +30,11 @@
 	__rem;							\
  })
 
+static inline uint64_t div64_64(uint64_t dividend, uint64_t divisor)
+{
+	return dividend / divisor;
+}
+
 #elif BITS_PER_LONG == 32
 
 extern uint32_t __div64_32(uint64_t *dividend, uint32_t divisor);
@@ -49,6 +54,8 @@ extern uint32_t __div64_32(uint64_t *div
 	__rem;						\
  })
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
+
 #else /* BITS_PER_LONG == ?? */
 
 # error do_div() does not yet support the C64
diff -puN include/asm-i386/div64.h~div64_64-common-code include/asm-i386/div64.h
--- a/include/asm-i386/div64.h~div64_64-common-code
+++ a/include/asm-i386/div64.h
@@ -1,6 +1,8 @@
 #ifndef __I386_DIV64
 #define __I386_DIV64
 
+#include <linux/types.h>
+
 /*
  * do_div() is NOT a C function. It wants to return
  * two values (the quotient and the remainder), but
@@ -45,4 +47,6 @@ div_ll_X_l_rem(long long divs, long div,
 	return dum2;
 
 }
+
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
 #endif
diff -puN include/asm-m68k/div64.h~div64_64-common-code include/asm-m68k/div64.h
--- a/include/asm-m68k/div64.h~div64_64-common-code
+++ a/include/asm-m68k/div64.h
@@ -1,6 +1,8 @@
 #ifndef _M68K_DIV64_H
 #define _M68K_DIV64_H
 
+#include <linux/types.h>
+
 /* n = n / base; return rem; */
 
 #define do_div(n, base) ({					\
@@ -23,4 +25,5 @@
 	__rem;							\
 })
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
 #endif /* _M68K_DIV64_H */
diff -puN include/asm-mips/div64.h~div64_64-common-code include/asm-mips/div64.h
--- a/include/asm-mips/div64.h~div64_64-common-code
+++ a/include/asm-mips/div64.h
@@ -9,6 +9,8 @@
 #ifndef _ASM_DIV64_H
 #define _ASM_DIV64_H
 
+#include <linux/types.h>
+
 #if (_MIPS_SZLONG == 32)
 
 #include <asm/compiler.h>
@@ -78,6 +80,8 @@
 	__quot = __quot << 32 | __low; \
 	(n) = __quot; \
 	__mod; })
+
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
 #endif /* (_MIPS_SZLONG == 32) */
 
 #if (_MIPS_SZLONG == 64)
diff -puN include/asm-um/div64.h~div64_64-common-code include/asm-um/div64.h
--- a/include/asm-um/div64.h~div64_64-common-code
+++ a/include/asm-um/div64.h
@@ -3,4 +3,5 @@
 
 #include "asm/arch/div64.h"
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
 #endif
diff -puN include/asm-xtensa/div64.h~div64_64-common-code include/asm-xtensa/div64.h
--- a/include/asm-xtensa/div64.h~div64_64-common-code
+++ a/include/asm-xtensa/div64.h
@@ -11,9 +11,15 @@
 #ifndef _XTENSA_DIV64_H
 #define _XTENSA_DIV64_H
 
+#include <linux/types.h>
+
 #define do_div(n,base) ({ \
 	int __res = n % ((unsigned int) base); \
 	n /= (unsigned int) base; \
 	__res; })
 
+static inline uint64_t div64_64(uint64_t dividend, uint64_t divisor)
+{
+	return dividend / divisor;
+}
 #endif
diff -puN lib/Makefile~div64_64-common-code lib/Makefile
--- a/lib/Makefile~div64_64-common-code
+++ a/lib/Makefile
@@ -4,7 +4,7 @@
 
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o dump_stack.o \
-	 idr.o div64.o int_sqrt.o bitmap.o extable.o prio_tree.o \
+	 idr.o int_sqrt.o bitmap.o extable.o prio_tree.o \
 	 sha1.o irq_regs.o reciprocal_div.o
 
 lib-$(CONFIG_MMU) += ioremap.o
@@ -12,7 +12,8 @@ lib-$(CONFIG_SMP) += cpumask.o
 
 lib-y	+= kobject.o kref.o kobject_uevent.o klist.o
 
-obj-y += sort.o parser.o halfmd4.o debug_locks.o random32.o bust_spinlocks.o
+obj-y += div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
+	 bust_spinlocks.o
 
 ifeq ($(CONFIG_DEBUG_KOBJECT),y)
 CFLAGS_kobject.o += -DDEBUG
diff -puN lib/div64.c~div64_64-common-code lib/div64.c
--- a/lib/div64.c~div64_64-common-code
+++ a/lib/div64.c
@@ -58,4 +58,26 @@ uint32_t __div64_32(uint64_t *n, uint32_
 
 EXPORT_SYMBOL(__div64_32);
 
+/* 64bit divisor, dividend and result. dynamic precision */
+uint64_t div64_64(uint64_t dividend, uint64_t divisor)
+{
+	uint32_t d = divisor;
+
+	if (divisor > 0xffffffffULL) {
+		unsigned int shift = fls(divisor >> 32);
+
+		d = divisor >> shift;
+		dividend >>= shift;
+	}
+
+	/* avoid 64 bit division if possible */
+	if (dividend >> 32)
+		do_div(dividend, d);
+	else
+		dividend = (uint32_t) dividend / d;
+
+	return dividend;
+}
+EXPORT_SYMBOL(div64_64);
+
 #endif /* BITS_PER_LONG == 32 */
diff -puN net/ipv4/tcp_cubic.c~div64_64-common-code net/ipv4/tcp_cubic.c
--- a/net/ipv4/tcp_cubic.c~div64_64-common-code
+++ a/net/ipv4/tcp_cubic.c
@@ -93,27 +93,6 @@ static void bictcp_init(struct sock *sk)
 		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
 }
 
-/* 64bit divisor, dividend and result. dynamic precision */
-static inline u_int64_t div64_64(u_int64_t dividend, u_int64_t divisor)
-{
-	u_int32_t d = divisor;
-
-	if (divisor > 0xffffffffULL) {
-		unsigned int shift = fls(divisor >> 32);
-
-		d = divisor >> shift;
-		dividend >>= shift;
-	}
-
-	/* avoid 64 bit division if possible */
-	if (dividend >> 32)
-		do_div(dividend, d);
-	else
-		dividend = (uint32_t) dividend / d;
-
-	return dividend;
-}
-
 /*
  * calculate the cubic root of x using Newton-Raphson
  */
diff -puN net/netfilter/xt_connbytes.c~div64_64-common-code net/netfilter/xt_connbytes.c
--- a/net/netfilter/xt_connbytes.c~div64_64-common-code
+++ a/net/netfilter/xt_connbytes.c
@@ -24,22 +24,6 @@ MODULE_AUTHOR("Harald Welte <laforge@net
 MODULE_DESCRIPTION("iptables match for matching number of pkts/bytes per connection");
 MODULE_ALIAS("ipt_connbytes");
 
-/* 64bit divisor, dividend and result. dynamic precision */
-static u_int64_t div64_64(u_int64_t dividend, u_int64_t divisor)
-{
-	u_int32_t d = divisor;
-
-	if (divisor > 0xffffffffULL) {
-		unsigned int shift = fls(divisor >> 32);
-
-		d = divisor >> shift;
-		dividend >>= shift;
-	}
-
-	do_div(dividend, d);
-	return dividend;
-}
-
 static int
 match(const struct sk_buff *skb,
       const struct net_device *in,
_
