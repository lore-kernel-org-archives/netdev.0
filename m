From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] div64_64 support
Date: Mon, 26 Feb 2007 14:31:27 -0800
Message-ID: <20070226143127.5c74bec9@freekitty>
References: <20070223170527.4ca695b2@freekitty>
	<Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36355 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751123AbXBZWbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 17:31:33 -0500
In-Reply-To: <Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is another way to handle the 64 bit divide case.
It allows full 64 bit divide by adding the support routine
GCC needs.

---
 arch/alpha/Kconfig           |    4 ++++
 arch/arm/Kconfig             |    4 ++++
 arch/arm26/Kconfig           |    4 ++++
 arch/avr32/Kconfig           |    4 ++++
 arch/cris/Kconfig            |    4 ++++
 arch/frv/Kconfig             |    4 ++++
 arch/h8300/Kconfig           |    4 ++++
 arch/i386/Kconfig            |    4 ++++
 arch/m32r/Kconfig            |    4 ++++
 arch/m68k/Kconfig            |    4 ++++
 arch/m68knommu/Kconfig       |    4 ++++
 arch/mips/Kconfig            |    4 ++++
 arch/parisc/Kconfig          |    4 ++++
 arch/powerpc/Kconfig         |    4 ++++
 arch/ppc/Kconfig             |    4 ++++
 arch/s390/Kconfig            |    4 ++++
 arch/sh64/Kconfig            |    4 ++++
 arch/v850/Kconfig            |    3 +++
 arch/xtensa/Kconfig          |    4 ++++
 lib/Makefile                 |    1 +
 lib/udivdi3.c                |   37 +++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_cubic.c         |   26 ++------------------------
 net/netfilter/xt_connbytes.c |   19 +------------------
 23 files changed, 116 insertions(+), 42 deletions(-)

--- pktgen.orig/net/ipv4/tcp_cubic.c	2007-02-26 13:40:08.000000000 -0800
+++ pktgen/net/ipv4/tcp_cubic.c	2007-02-26 14:30:00.000000000 -0800
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
@@ -134,7 +112,7 @@
 	 */
 	do {
 		x1 = x;
-		x = (2 * x + (uint32_t) div64_64(a, x*x)) / 3;
+		x = (2 * x + (u32) (a / x*x)) / 3;
 	} while (abs(x1 - x) > 1);
 
 	return x;
--- pktgen.orig/net/netfilter/xt_connbytes.c	2007-02-26 13:40:08.000000000 -0800
+++ pktgen/net/netfilter/xt_connbytes.c	2007-02-26 14:29:13.000000000 -0800
@@ -16,7 +16,6 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_connbytes.h>
 
-#include <asm/div64.h>
 #include <asm/bitops.h>
 
 MODULE_LICENSE("GPL");
@@ -24,22 +23,6 @@
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
@@ -106,7 +89,7 @@
 			break;
 		}
 		if (pkts != 0)
-			what = div64_64(bytes, pkts);
+			what = bytes / pkts;
 		break;
 	}
 
--- pktgen.orig/lib/Makefile	2007-02-26 13:40:08.000000000 -0800
+++ pktgen/lib/Makefile	2007-02-26 14:17:31.000000000 -0800
@@ -28,6 +28,7 @@
 lib-$(CONFIG_SEMAPHORE_SLEEPERS) += semaphore-sleepers.o
 lib-$(CONFIG_GENERIC_FIND_NEXT_BIT) += find_next_bit.o
 obj-$(CONFIG_GENERIC_HWEIGHT) += hweight.o
+obj-$(CONFIG_GENERIC_UDIVDI3) += udivdi3.o
 obj-$(CONFIG_LOCK_KERNEL) += kernel_lock.o
 obj-$(CONFIG_PLIST) += plist.o
 obj-$(CONFIG_DEBUG_PREEMPT) += smp_processor_id.o
--- pktgen.orig/arch/alpha/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/alpha/Kconfig	2007-02-26 13:54:35.000000000 -0800
@@ -33,6 +33,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
--- pktgen.orig/arch/arm/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/arm/Kconfig	2007-02-26 13:54:57.000000000 -0800
@@ -90,6 +90,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_HWEIGHT
 	bool
 	default y
--- pktgen.orig/arch/arm26/Kconfig	2007-02-26 13:48:46.000000000 -0800
+++ pktgen/arch/arm26/Kconfig	2007-02-26 13:55:24.000000000 -0800
@@ -49,6 +49,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_HWEIGHT
 	bool
 	default y
--- pktgen.orig/arch/avr32/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/avr32/Kconfig	2007-02-26 13:55:39.000000000 -0800
@@ -53,6 +53,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_BUST_SPINLOCK
 	bool
 
--- pktgen.orig/arch/cris/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/cris/Kconfig	2007-02-26 13:55:53.000000000 -0800
@@ -28,6 +28,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
--- pktgen.orig/arch/frv/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/frv/Kconfig	2007-02-26 13:56:09.000000000 -0800
@@ -53,6 +53,10 @@
 	bool
 	default y
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 mainmenu "Fujitsu FR-V Kernel Configuration"
 
 source "init/Kconfig"
--- pktgen.orig/arch/h8300/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/h8300/Kconfig	2007-02-26 13:56:20.000000000 -0800
@@ -41,6 +41,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
--- pktgen.orig/arch/i386/Kconfig	2007-02-26 14:01:59.000000000 -0800
+++ pktgen/arch/i386/Kconfig	2007-02-26 14:02:28.000000000 -0800
@@ -75,6 +75,10 @@
 	bool
 	default y
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config ARCH_MAY_HAVE_PC_FDC
 	bool
 	default y
--- pktgen.orig/arch/m32r/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/m32r/Kconfig	2007-02-26 13:56:43.000000000 -0800
@@ -229,6 +229,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
--- pktgen.orig/arch/m68k/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/m68k/Kconfig	2007-02-26 13:56:56.000000000 -0800
@@ -25,6 +25,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_HWEIGHT
 	bool
 	default y
--- pktgen.orig/arch/m68knommu/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/m68knommu/Kconfig	2007-02-26 13:57:05.000000000 -0800
@@ -37,6 +37,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
--- pktgen.orig/arch/mips/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/mips/Kconfig	2007-02-26 13:57:13.000000000 -0800
@@ -843,6 +843,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
--- pktgen.orig/arch/parisc/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/parisc/Kconfig	2007-02-26 13:57:21.000000000 -0800
@@ -33,6 +33,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
--- pktgen.orig/arch/powerpc/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/powerpc/Kconfig	2007-02-26 13:57:31.000000000 -0800
@@ -49,6 +49,10 @@
 	bool
 	default y if 64BIT
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_HWEIGHT
 	bool
 	default y
--- pktgen.orig/arch/ppc/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/ppc/Kconfig	2007-02-26 13:57:44.000000000 -0800
@@ -27,6 +27,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_HWEIGHT
 	bool
 	default y
--- pktgen.orig/arch/s390/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/s390/Kconfig	2007-02-26 13:57:53.000000000 -0800
@@ -34,6 +34,10 @@
 	bool
 	default n
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_HWEIGHT
 	bool
 	default y
--- pktgen.orig/arch/sh64/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/sh64/Kconfig	2007-02-26 14:00:32.000000000 -0800
@@ -21,6 +21,10 @@
 	bool
 	default y
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
--- pktgen.orig/arch/v850/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/v850/Kconfig	2007-02-26 13:59:29.000000000 -0800
@@ -19,6 +19,9 @@
 config RWSEM_XCHGADD_ALGORITHM
 	bool
 	default n
+config GENERIC_UDIVDI3
+	bool
+	default y
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
--- pktgen.orig/arch/xtensa/Kconfig	2007-02-26 13:51:29.000000000 -0800
+++ pktgen/arch/xtensa/Kconfig	2007-02-26 13:59:45.000000000 -0800
@@ -26,6 +26,10 @@
 	bool
 	default y
 
+config GENERIC_UDIVDI3
+	bool
+	default y
+
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ pktgen/lib/udivdi3.c	2007-02-26 14:14:13.000000000 -0800
@@ -0,0 +1,37 @@
+/*
+ * Generic C  version of full 64 bit by 64 bit division
+ * Extracted from version used by netfilter connection tracking
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * Code generated for this function might be very inefficient
+ * for some CPUs, can be overridden by linking arch-specific
+ * assembly versions such as arch/sparc/lib/udivdi.S
+ */
+#include <linux/types.h>
+#include <linux/module.h>
+#include <asm/div64.h>
+
+uint64_t __udivdi3(uint64_t dividend, uint64_t divisor)
+{
+	uint32_t d = divisor;
+
+	/* Scale divisor to 32 bits */
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
+EXPORT_SYMBOL(__udivdi3);

