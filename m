From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] div64_64 support
Date: Fri, 23 Feb 2007 17:05:27 -0800
Message-ID: <20070223170527.4ca695b2@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45154 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933302AbXBXBFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 20:05:30 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since there already two users of full 64 bit division in the kernel,
and other places maybe hiding out as well. Add a full 64/64 bit divide.

Yes this expensive, but there are places where it is necessary.
It is not clear if doing the scaling buys any advantage on 64 bit platforms,
so for them a full divide is done.

---
 include/asm-arm/div64.h      |    2 ++
 include/asm-generic/div64.h  |    8 ++++++++
 include/asm-m68k/div64.h     |    2 ++
 include/asm-mips/div64.h     |    8 ++++++++
 include/asm-um/div64.h       |    1 +
 include/asm-xtensa/div64.h   |    1 +
 lib/div64.c                  |   22 ++++++++++++++++++++++
 net/ipv4/tcp_cubic.c         |   22 ----------------------
 net/netfilter/xt_connbytes.c |   16 ----------------
 9 files changed, 44 insertions(+), 38 deletions(-)

--- linux-2.6.21-rc1.orig/include/asm-arm/div64.h	2007-02-23 16:44:41.000000000 -0800
+++ linux-2.6.21-rc1/include/asm-arm/div64.h	2007-02-23 16:57:36.000000000 -0800
@@ -221,6 +221,8 @@
 	__nr;								\
 })
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
+
 #endif
 
 #endif
--- linux-2.6.21-rc1.orig/include/asm-generic/div64.h	2007-02-23 16:35:27.000000000 -0800
+++ linux-2.6.21-rc1/include/asm-generic/div64.h	2007-02-23 16:56:40.000000000 -0800
@@ -30,9 +30,17 @@
 	__rem;							\
  })
 
+/*
+ * div64_64 - Divide two 64 bit numbers
+ */
+static inline uint64_t div64_64(uint64_t dividend, uint64_t divisor)
+{
+	return dividend / divisor;
+}
 #elif BITS_PER_LONG == 32
 
 extern uint32_t __div64_32(uint64_t *dividend, uint32_t divisor);
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
 
 /* The unnecessary pointer compare is there
  * to check for type safety (n must be 64bit)
--- linux-2.6.21-rc1.orig/include/asm-m68k/div64.h	2007-02-23 16:45:20.000000000 -0800
+++ linux-2.6.21-rc1/include/asm-m68k/div64.h	2007-02-23 16:56:27.000000000 -0800
@@ -23,4 +23,6 @@
 	__rem;							\
 })
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
+
 #endif /* _M68K_DIV64_H */
--- linux-2.6.21-rc1.orig/include/asm-mips/div64.h	2007-02-23 16:45:25.000000000 -0800
+++ linux-2.6.21-rc1/include/asm-mips/div64.h	2007-02-23 16:59:52.000000000 -0800
@@ -78,6 +78,9 @@
 	__quot = __quot << 32 | __low; \
 	(n) = __quot; \
 	__mod; })
+
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
+
 #endif /* (_MIPS_SZLONG == 32) */
 
 #if (_MIPS_SZLONG == 64)
@@ -101,6 +104,11 @@
 	(n) = __quot; \
 	__mod; })
 
+static inline uint64_t div64_64(uint64_t dividend, uint64_t divisor)
+{
+	return dividend / divisor;
+}
+
 #endif /* (_MIPS_SZLONG == 64) */
 
 #endif /* _ASM_DIV64_H */
--- linux-2.6.21-rc1.orig/include/asm-um/div64.h	2007-02-23 16:45:37.000000000 -0800
+++ linux-2.6.21-rc1/include/asm-um/div64.h	2007-02-23 16:58:29.000000000 -0800
@@ -3,4 +3,5 @@
 
 #include "asm/arch/div64.h"
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
 #endif
--- linux-2.6.21-rc1.orig/include/asm-xtensa/div64.h	2007-02-23 16:45:43.000000000 -0800
+++ linux-2.6.21-rc1/include/asm-xtensa/div64.h	2007-02-23 16:58:04.000000000 -0800
@@ -16,4 +16,5 @@
 	n /= (unsigned int) base; \
 	__res; })
 
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
 #endif
--- linux-2.6.21-rc1.orig/lib/div64.c	2007-02-23 16:50:40.000000000 -0800
+++ linux-2.6.21-rc1/lib/div64.c	2007-02-23 16:54:56.000000000 -0800
@@ -18,6 +18,7 @@
 
 #include <linux/types.h>
 #include <linux/module.h>
+#include <asm/bitops.h>
 #include <asm/div64.h>
 
 /* Not needed on 64bit architectures */
@@ -58,4 +59,25 @@
 
 EXPORT_SYMBOL(__div64_32);
 
+/* Use scaling to do a full 64 bit division  */
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
+
 #endif /* BITS_PER_LONG == 32 */
--- linux-2.6.21-rc1.orig/net/ipv4/tcp_cubic.c	2007-02-23 16:33:52.000000000 -0800
+++ linux-2.6.21-rc1/net/ipv4/tcp_cubic.c	2007-02-23 16:45:50.000000000 -0800
@@ -51,7 +51,6 @@
 module_param(tcp_friendliness, int, 0644);
 MODULE_PARM_DESC(tcp_friendliness, "turn on/off tcp friendliness");
 
-#include <asm/div64.h>
 
 /* BIC TCP Parameters */
 struct bictcp {
@@ -93,27 +92,6 @@
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
--- linux-2.6.21-rc1.orig/net/netfilter/xt_connbytes.c	2007-02-23 16:40:57.000000000 -0800
+++ linux-2.6.21-rc1/net/netfilter/xt_connbytes.c	2007-02-23 16:41:09.000000000 -0800
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
