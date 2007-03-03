From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] div64_64 consolidate (rev3)
Date: Fri, 2 Mar 2007 17:29:20 -0800
Message-ID: <20070302172920.201fe5af@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:50879 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992873AbXCCB3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:29:25 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is the current version of the 64 bit divide common code.
Since it is used by three times by networking code, can we put it net-2.6.22 tree?

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 include/asm-arm/div64.h      |    2 ++
 include/asm-generic/div64.h  |    7 +++++++
 include/asm-i386/div64.h     |    2 ++
 include/asm-m68k/div64.h     |    1 +
 include/asm-mips/div64.h     |    2 ++
 include/asm-um/div64.h       |    1 +
 include/asm-xtensa/div64.h   |    4 ++++
 lib/Makefile                 |    5 +++--
 lib/div64.c                  |   22 ++++++++++++++++++++++
 net/ipv4/tcp_cubic.c         |   23 -----------------------
 net/ipv4/tcp_yeah.c          |   21 ---------------------
 net/ipv4/tcp_yeah.h          |    1 +
 net/netfilter/xt_connbytes.c |   16 ----------------
 13 files changed, 45 insertions(+), 62 deletions(-)

--- tcp-2.6.orig/include/asm-arm/div64.h	2007-03-02 17:21:27.000000000 -0800
+++ tcp-2.6/include/asm-arm/div64.h	2007-03-02 17:22:38.000000000 -0800
@@ -223,4 +223,6 @@
 
 #endif
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
+
 #endif
--- tcp-2.6.orig/include/asm-generic/div64.h	2007-03-02 17:21:27.000000000 -0800
+++ tcp-2.6/include/asm-generic/div64.h	2007-03-02 17:22:38.000000000 -0800
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
@@ -49,6 +54,8 @@
 	__rem;						\
  })
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
+
 #else /* BITS_PER_LONG == ?? */
 
 # error do_div() does not yet support the C64
--- tcp-2.6.orig/include/asm-i386/div64.h	2007-03-02 17:21:27.000000000 -0800
+++ tcp-2.6/include/asm-i386/div64.h	2007-03-02 17:22:38.000000000 -0800
@@ -45,4 +45,6 @@
 	return dum2;
 
 }
+
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
 #endif
--- tcp-2.6.orig/include/asm-m68k/div64.h	2007-03-02 17:21:27.000000000 -0800
+++ tcp-2.6/include/asm-m68k/div64.h	2007-03-02 17:22:38.000000000 -0800
@@ -23,4 +23,5 @@
 	__rem;							\
 })
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
 #endif /* _M68K_DIV64_H */
--- tcp-2.6.orig/include/asm-mips/div64.h	2007-03-02 17:21:27.000000000 -0800
+++ tcp-2.6/include/asm-mips/div64.h	2007-03-02 17:22:38.000000000 -0800
@@ -78,6 +78,8 @@
 	__quot = __quot << 32 | __low; \
 	(n) = __quot; \
 	__mod; })
+
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
 #endif /* (_MIPS_SZLONG == 32) */
 
 #if (_MIPS_SZLONG == 64)
--- tcp-2.6.orig/include/asm-um/div64.h	2007-03-02 17:21:27.000000000 -0800
+++ tcp-2.6/include/asm-um/div64.h	2007-03-02 17:22:38.000000000 -0800
@@ -3,4 +3,5 @@
 
 #include "asm/arch/div64.h"
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
 #endif
--- tcp-2.6.orig/include/asm-xtensa/div64.h	2007-03-02 17:21:27.000000000 -0800
+++ tcp-2.6/include/asm-xtensa/div64.h	2007-03-02 17:22:38.000000000 -0800
@@ -16,4 +16,8 @@
 	n /= (unsigned int) base; \
 	__res; })
 
+static inline uint64_t div64_64(uint64_t dividend, uint64_t divisor)
+{
+	return dividend / divisor;
+}
 #endif
--- tcp-2.6.orig/lib/Makefile	2007-03-02 17:21:27.000000000 -0800
+++ tcp-2.6/lib/Makefile	2007-03-02 17:22:38.000000000 -0800
@@ -4,7 +4,7 @@
 
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o dump_stack.o \
-	 idr.o div64.o int_sqrt.o bitmap.o extable.o prio_tree.o \
+	 idr.o int_sqrt.o bitmap.o extable.o prio_tree.o \
 	 sha1.o irq_regs.o reciprocal_div.o
 
 lib-$(CONFIG_MMU) += ioremap.o
@@ -12,7 +12,8 @@
 
 lib-y	+= kobject.o kref.o kobject_uevent.o klist.o
 
-obj-y += sort.o parser.o halfmd4.o debug_locks.o random32.o bust_spinlocks.o
+obj-y += div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
+	 bust_spinlocks.o
 
 ifeq ($(CONFIG_DEBUG_KOBJECT),y)
 CFLAGS_kobject.o += -DDEBUG
--- tcp-2.6.orig/lib/div64.c	2007-03-02 17:21:27.000000000 -0800
+++ tcp-2.6/lib/div64.c	2007-03-02 17:22:38.000000000 -0800
@@ -58,4 +58,26 @@
 
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
--- tcp-2.6.orig/net/ipv4/tcp_cubic.c	2007-03-02 17:22:33.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_cubic.c	2007-03-02 17:23:32.000000000 -0800
@@ -51,8 +51,6 @@
 module_param(tcp_friendliness, int, 0644);
 MODULE_PARM_DESC(tcp_friendliness, "turn on/off tcp friendliness");
 
-#include <asm/div64.h>
-
 /* BIC TCP Parameters */
 struct bictcp {
 	u32	cnt;		/* increase cwnd by 1 after ACKs */
@@ -93,27 +91,6 @@
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
--- tcp-2.6.orig/net/netfilter/xt_connbytes.c	2007-03-02 17:21:27.000000000 -0800
+++ tcp-2.6/net/netfilter/xt_connbytes.c	2007-03-02 17:22:38.000000000 -0800
@@ -24,22 +24,6 @@
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
--- tcp-2.6.orig/net/ipv4/tcp_yeah.c	2007-03-02 17:24:06.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_yeah.c	2007-03-02 17:24:36.000000000 -0800
@@ -73,27 +73,6 @@
 		yeah->pkts_acked = pkts_acked;
 }
 
-/* 64bit divisor, dividend and result. dynamic precision */
-static inline u64 div64_64(u64 dividend, u64 divisor)
-{
-	u32 d = divisor;
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
-		dividend = (u32) dividend / d;
-
-	return dividend;
-}
-
 static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack,
 				 u32 seq_rtt, u32 in_flight, int flag)
 {
--- tcp-2.6.orig/net/ipv4/tcp_yeah.h	2007-03-02 17:24:06.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_yeah.h	2007-03-02 17:24:18.000000000 -0800
@@ -2,6 +2,7 @@
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/inet_diag.h>
+#include <asm/div64.h>
 
 #include <net/tcp.h>
 
