From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: am79c961a: avoid %? in inline assembly
Date: Mon,  8 Feb 2016 15:33:42 +0100
Message-ID: <1454942025-2779812-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The am79c961a.c driver fails to build with clang because of an
unusual inline assembly construct:

drivers/net/ethernet/amd/am79c961a.c:53:7: error: invalid % escape in inline assembly string
 "str%?h        %1, [%2]        @ NET_RAP\n\t"

The same change has been done a decade ago in arch/arm as of
6a39dd6222dd ("[ARM] 3759/2: Remove uses of %?"), but apparently
some drivers were missed.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/amd/am79c961a.c | 64 ++++++++++++++++++------------------
 1 file changed, 32 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index 87e727b921dc..fcdf5dda448f 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -50,8 +50,8 @@ static const char version[] =
 static void write_rreg(u_long base, u_int reg, u_int val)
 {
 	asm volatile(
-	"str%?h	%1, [%2]	@ NET_RAP\n\t"
-	"str%?h	%0, [%2, #-4]	@ NET_RDP"
+	"strh	%1, [%2]	@ NET_RAP\n\t"
+	"strh	%0, [%2, #-4]	@ NET_RDP"
 	:
 	: "r" (val), "r" (reg), "r" (ISAIO_BASE + 0x0464));
 }
@@ -60,8 +60,8 @@ static inline unsigned short read_rreg(u_long base_addr, u_int reg)
 {
 	unsigned short v;
 	asm volatile(
-	"str%?h	%1, [%2]	@ NET_RAP\n\t"
-	"ldr%?h	%0, [%2, #-4]	@ NET_RDP"
+	"strh	%1, [%2]	@ NET_RAP\n\t"
+	"ldrh	%0, [%2, #-4]	@ NET_RDP"
 	: "=r" (v)
 	: "r" (reg), "r" (ISAIO_BASE + 0x0464));
 	return v;
@@ -70,8 +70,8 @@ static inline unsigned short read_rreg(u_long base_addr, u_int reg)
 static inline void write_ireg(u_long base, u_int reg, u_int val)
 {
 	asm volatile(
-	"str%?h	%1, [%2]	@ NET_RAP\n\t"
-	"str%?h	%0, [%2, #8]	@ NET_IDP"
+	"strh	%1, [%2]	@ NET_RAP\n\t"
+	"strh	%0, [%2, #8]	@ NET_IDP"
 	:
 	: "r" (val), "r" (reg), "r" (ISAIO_BASE + 0x0464));
 }
@@ -80,8 +80,8 @@ static inline unsigned short read_ireg(u_long base_addr, u_int reg)
 {
 	u_short v;
 	asm volatile(
-	"str%?h	%1, [%2]	@ NAT_RAP\n\t"
-	"ldr%?h	%0, [%2, #8]	@ NET_IDP\n\t"
+	"strh	%1, [%2]	@ NAT_RAP\n\t"
+	"ldrh	%0, [%2, #8]	@ NET_IDP\n\t"
 	: "=r" (v)
 	: "r" (reg), "r" (ISAIO_BASE + 0x0464));
 	return v;
@@ -96,7 +96,7 @@ am_writebuffer(struct net_device *dev, u_int offset, unsigned char *buf, unsigne
 	offset = ISAMEM_BASE + (offset << 1);
 	length = (length + 1) & ~1;
 	if ((int)buf & 2) {
-		asm volatile("str%?h	%2, [%0], #4"
+		asm volatile("strh	%2, [%0], #4"
 		 : "=&r" (offset) : "0" (offset), "r" (buf[0] | (buf[1] << 8)));
 		buf += 2;
 		length -= 2;
@@ -104,20 +104,20 @@ am_writebuffer(struct net_device *dev, u_int offset, unsigned char *buf, unsigne
 	while (length > 8) {
 		register unsigned int tmp asm("r2"), tmp2 asm("r3");
 		asm volatile(
-			"ldm%?ia	%0!, {%1, %2}"
+			"ldmia	%0!, {%1, %2}"
 			: "+r" (buf), "=&r" (tmp), "=&r" (tmp2));
 		length -= 8;
 		asm volatile(
-			"str%?h	%1, [%0], #4\n\t"
-			"mov%?	%1, %1, lsr #16\n\t"
-			"str%?h	%1, [%0], #4\n\t"
-			"str%?h	%2, [%0], #4\n\t"
-			"mov%?	%2, %2, lsr #16\n\t"
-			"str%?h	%2, [%0], #4"
+			"strh	%1, [%0], #4\n\t"
+			"mov	%1, %1, lsr #16\n\t"
+			"strh	%1, [%0], #4\n\t"
+			"strh	%2, [%0], #4\n\t"
+			"mov	%2, %2, lsr #16\n\t"
+			"strh	%2, [%0], #4"
 		: "+r" (offset), "=&r" (tmp), "=&r" (tmp2));
 	}
 	while (length > 0) {
-		asm volatile("str%?h	%2, [%0], #4"
+		asm volatile("strh	%2, [%0], #4"
 		 : "=&r" (offset) : "0" (offset), "r" (buf[0] | (buf[1] << 8)));
 		buf += 2;
 		length -= 2;
@@ -132,23 +132,23 @@ am_readbuffer(struct net_device *dev, u_int offset, unsigned char *buf, unsigned
 	if ((int)buf & 2) {
 		unsigned int tmp;
 		asm volatile(
-			"ldr%?h	%2, [%0], #4\n\t"
-			"str%?b	%2, [%1], #1\n\t"
-			"mov%?	%2, %2, lsr #8\n\t"
-			"str%?b	%2, [%1], #1"
+			"ldrh	%2, [%0], #4\n\t"
+			"strb	%2, [%1], #1\n\t"
+			"mov	%2, %2, lsr #8\n\t"
+			"strb	%2, [%1], #1"
 		: "=&r" (offset), "=&r" (buf), "=r" (tmp): "0" (offset), "1" (buf));
 		length -= 2;
 	}
 	while (length > 8) {
 		register unsigned int tmp asm("r2"), tmp2 asm("r3"), tmp3;
 		asm volatile(
-			"ldr%?h	%2, [%0], #4\n\t"
-			"ldr%?h	%4, [%0], #4\n\t"
-			"ldr%?h	%3, [%0], #4\n\t"
-			"orr%?	%2, %2, %4, lsl #16\n\t"
-			"ldr%?h	%4, [%0], #4\n\t"
-			"orr%?	%3, %3, %4, lsl #16\n\t"
-			"stm%?ia	%1!, {%2, %3}"
+			"ldrh	%2, [%0], #4\n\t"
+			"ldrh	%4, [%0], #4\n\t"
+			"ldrh	%3, [%0], #4\n\t"
+			"orr	%2, %2, %4, lsl #16\n\t"
+			"ldrh	%4, [%0], #4\n\t"
+			"orr	%3, %3, %4, lsl #16\n\t"
+			"stmia	%1!, {%2, %3}"
 		: "=&r" (offset), "=&r" (buf), "=r" (tmp), "=r" (tmp2), "=r" (tmp3)
 		: "0" (offset), "1" (buf));
 		length -= 8;
@@ -156,10 +156,10 @@ am_readbuffer(struct net_device *dev, u_int offset, unsigned char *buf, unsigned
 	while (length > 0) {
 		unsigned int tmp;
 		asm volatile(
-			"ldr%?h	%2, [%0], #4\n\t"
-			"str%?b	%2, [%1], #1\n\t"
-			"mov%?	%2, %2, lsr #8\n\t"
-			"str%?b	%2, [%1], #1"
+			"ldrh	%2, [%0], #4\n\t"
+			"strb	%2, [%1], #1\n\t"
+			"mov	%2, %2, lsr #8\n\t"
+			"strb	%2, [%1], #1"
 		: "=&r" (offset), "=&r" (buf), "=r" (tmp) : "0" (offset), "1" (buf));
 		length -= 2;
 	}
-- 
2.7.0
