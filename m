From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH 3/3] NET: am79c961: fix assembler warnings
Date: Fri, 10 Jun 2011 11:52:35 +0100
Message-ID: <E1QUzKN-0004BE-2a@rmk-PC.arm.linux.org.uk>
References: <20110610105122.GA27087@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:35114 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755444Ab1FJKwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 06:52:39 -0400
Received: from e0022681537dd.dyn.arm.linux.org.uk ([2002:4e20:1eda:1:222:68ff:fe15:37dd] helo=rmk-PC.arm.linux.org.uk)
	by caramon.arm.linux.org.uk with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.72)
	(envelope-from <rmk@arm.linux.org.uk>)
	id 1QUzKO-0006QA-A1
	for netdev@vger.kernel.org; Fri, 10 Jun 2011 11:52:36 +0100
Received: from rmk by rmk-PC.arm.linux.org.uk with local (Exim 4.76)
	(envelope-from <rmk@arm.linux.org.uk>)
	id 1QUzKN-0004BE-2a
	for netdev@vger.kernel.org; Fri, 10 Jun 2011 11:52:35 +0100
In-Reply-To: <20110610105122.GA27087@flint.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix:
/tmp/ccvoZ6h8.s: Assembler messages:
/tmp/ccvoZ6h8.s:284: Warning: register range not in ascending order
/tmp/ccvoZ6h8.s:881: Warning: register range not in ascending order
/tmp/ccvoZ6h8.s:1087: Warning: register range not in ascending order

by ensuring that we have temporary variables placed into specific
registers.  Reorder the code a bit to allow the resulting assembly
to be slightly more optimal.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/arm/am79c961a.c |   35 ++++++++++++++++++-----------------
 1 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 79d88a0..7b3e23f 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -91,40 +91,41 @@ static inline unsigned short read_ireg(u_long base_addr, u_int reg)
 #define am_writeword(dev,off,val) __raw_writew(val, ISAMEM_BASE + ((off) << 1))
 #define am_readword(dev,off)      __raw_readw(ISAMEM_BASE + ((off) << 1))
 
-static inline void
+static void
 am_writebuffer(struct net_device *dev, u_int offset, unsigned char *buf, unsigned int length)
 {
 	offset = ISAMEM_BASE + (offset << 1);
 	length = (length + 1) & ~1;
 	if ((int)buf & 2) {
-		__asm__ __volatile__("str%?h	%2, [%0], #4"
+		asm volatile("str%?h	%2, [%0], #4"
 		 : "=&r" (offset) : "0" (offset), "r" (buf[0] | (buf[1] << 8)));
 		buf += 2;
 		length -= 2;
 	}
 	while (length > 8) {
-		unsigned int tmp, tmp2;
-		__asm__ __volatile__(
-			"ldm%?ia	%1!, {%2, %3}\n\t"
+		register unsigned int tmp asm("r2"), tmp2 asm("r3");
+		asm volatile(
+			"ldm%?ia	%0!, {%1, %2}"
+			: "+r" (buf), "=&r" (tmp), "=&r" (tmp2));
+		length -= 8;
+		asm volatile(
+			"str%?h	%1, [%0], #4\n\t"
+			"mov%?	%1, %1, lsr #16\n\t"
+			"str%?h	%1, [%0], #4\n\t"
 			"str%?h	%2, [%0], #4\n\t"
 			"mov%?	%2, %2, lsr #16\n\t"
-			"str%?h	%2, [%0], #4\n\t"
-			"str%?h	%3, [%0], #4\n\t"
-			"mov%?	%3, %3, lsr #16\n\t"
-			"str%?h	%3, [%0], #4"
-		: "=&r" (offset), "=&r" (buf), "=r" (tmp), "=r" (tmp2)
-		: "0" (offset), "1" (buf));
-		length -= 8;
+			"str%?h	%2, [%0], #4"
+		: "+r" (offset), "=&r" (tmp), "=&r" (tmp2));
 	}
 	while (length > 0) {
-		__asm__ __volatile__("str%?h	%2, [%0], #4"
+		asm volatile("str%?h	%2, [%0], #4"
 		 : "=&r" (offset) : "0" (offset), "r" (buf[0] | (buf[1] << 8)));
 		buf += 2;
 		length -= 2;
 	}
 }
 
-static inline void
+static void
 am_readbuffer(struct net_device *dev, u_int offset, unsigned char *buf, unsigned int length)
 {
 	offset = ISAMEM_BASE + (offset << 1);
@@ -140,12 +141,12 @@ am_readbuffer(struct net_device *dev, u_int offset, unsigned char *buf, unsigned
 		length -= 2;
 	}
 	while (length > 8) {
-		unsigned int tmp, tmp2, tmp3;
+		register unsigned int tmp asm("r2"), tmp2 asm("r3"), tmp3;
 		asm volatile(
 			"ldr%?h	%2, [%0], #4\n\t"
+			"ldr%?h	%4, [%0], #4\n\t"
 			"ldr%?h	%3, [%0], #4\n\t"
-			"orr%?	%2, %2, %3, lsl #16\n\t"
-			"ldr%?h	%3, [%0], #4\n\t"
+			"orr%?	%2, %2, %4, lsl #16\n\t"
 			"ldr%?h	%4, [%0], #4\n\t"
 			"orr%?	%3, %3, %4, lsl #16\n\t"
 			"stm%?ia	%1!, {%2, %3}"
-- 
1.7.4.4

