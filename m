From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] smc91x: remove ARM hack for unaligned 16-bit writes
Date: Thu, 25 Aug 2016 16:43:04 +0200
Message-ID: <20160825144314.1850730-1-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
        Arnd Bergmann <arnd@arndb.de>,
        Nicolas Pitre <nico@fluxnic.net>,
        "David S. Miller" <davem@davemloft.net>,
        Robert Jarzmik <robert.jarzmik@free.fr>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Russell King <linux@armlinux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ARM specific I/O operations are almost the same as the generic
ones, with the exception of the SMC_outw macro that works around
a problem of some platforms that cannot write to 16-bit registers
at an address that is not 32-bit aligned.

By inspection, I found that this is handled already in the
register abstractions for almost all cases, the exceptions being
SMC_SET_MAC_ADDR() and SMC_SET_MCAST(). I assume that all
platforms that require the hack for the other registers also
need it here, so the ones listed explictly here are the only
ones that work correctly, while the other ones either don't
need the hack at all, or they will set an incorrect MAC
address (which can often go unnoticed).

This changes the two macros that set the unaligned registers
to use 32-bit writes if possible, which should do the right
thing in all combinations. The ARM specific SMC_outw gets removed
as a consequence.

The only difference between the ARM behavior and the default is
the selection of the LED settings. The fact that we have different
defaults based on the CPU architectures here is a bit suspicious,
but probably harmless, and I have no plan of touching that.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/smsc/smc91x.h | 50 +++++++++++++++++++++++---------------
 1 file changed, 30 insertions(+), 20 deletions(-)

While this patch fixes one bug on Neponset, it probably doesn't address
the one that Russell ran into first, so this is for review only for now,
until the remaining problem(s) have been worked out.


diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 22333477d0b5..908473d9ede0 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -58,6 +58,7 @@
 #define SMC_inw(a, r)		readw((a) + (r))
 #define SMC_inl(a, r)		readl((a) + (r))
 #define SMC_outb(v, a, r)	writeb(v, (a) + (r))
+#define SMC_outw(v, a, r)	writew(v, (a) + (r))
 #define SMC_outl(v, a, r)	writel(v, (a) + (r))
 #define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
@@ -65,19 +66,6 @@
 #define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
 #define SMC_IRQ_FLAGS		(-1)	/* from resource */
 
-/* We actually can't write halfwords properly if not word aligned */
-static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
-{
-	if ((machine_is_mainstone() || machine_is_stargate2() ||
-	     machine_is_pxa_idp()) && reg & 2) {
-		unsigned int v = val << 16;
-		v |= readl(ioaddr + (reg & ~2)) & 0xffff;
-		writel(v, ioaddr + (reg & ~2));
-	} else {
-		writew(val, ioaddr + reg);
-	}
-}
-
 #elif	defined(CONFIG_SH_SH4202_MICRODEV)
 
 #define SMC_CAN_USE_8BIT	0
@@ -1029,18 +1017,40 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_SET_MAC_ADDR(lp, addr)					\
 	do {								\
-		SMC_out16(addr[0]|(addr[1] << 8), ioaddr, ADDR0_REG(lp)); \
-		SMC_out16(addr[2]|(addr[3] << 8), ioaddr, ADDR1_REG(lp)); \
-		SMC_out16(addr[4]|(addr[5] << 8), ioaddr, ADDR2_REG(lp)); \
+		if (SMC_32BIT(lp)) {					\
+			SMC_outl((addr[0]      )|(addr[1] <<  8) |	\
+				 (addr[2] << 16)|(addr[3] << 24),	\
+				 ioaddr, ADDR0_REG(lp));		\
+		} else {						\
+			SMC_out16(addr[0]|(addr[1] << 8), ioaddr,	\
+				  ADDR0_REG(lp));			\
+			SMC_out16(addr[2]|(addr[3] << 8), ioaddr,	\
+				  ADDR1_REG(lp));			\
+		}							\
+		SMC_out16(addr[4]|(addr[5] << 8), ioaddr,		\
+			  ADDR2_REG(lp)); \
 	} while (0)
 
 #define SMC_SET_MCAST(lp, x)						\
 	do {								\
 		const unsigned char *mt = (x);				\
-		SMC_out16(mt[0] | (mt[1] << 8), ioaddr, MCAST_REG1(lp)); \
-		SMC_out16(mt[2] | (mt[3] << 8), ioaddr, MCAST_REG2(lp)); \
-		SMC_out16(mt[4] | (mt[5] << 8), ioaddr, MCAST_REG3(lp)); \
-		SMC_out16(mt[6] | (mt[7] << 8), ioaddr, MCAST_REG4(lp)); \
+		if (SMC_32BIT(lp)) {					\
+			SMC_outl((mt[0]      ) | (mt[1] <<  8) |	\
+				 (mt[2] << 16) | (mt[3] << 24),		\
+				 ioaddr, MCAST_REG1(lp));		\
+			SMC_outl((mt[4]      ) | (mt[5] <<  8) |	\
+				 (mt[6] << 16) | (mt[7] << 24),		\
+				 ioaddr, MCAST_REG3(lp));		\
+		} else {						\
+			SMC_out16(mt[0] | (mt[1] << 8),			\
+				  ioaddr, MCAST_REG1(lp));		\
+			SMC_out16(mt[2] | (mt[3] << 8),			\
+				  ioaddr, MCAST_REG2(lp));		\
+			SMC_out16(mt[4] | (mt[5] << 8),			\
+				  ioaddr, MCAST_REG3(lp));		\
+			SMC_out16(mt[6] | (mt[7] << 8),			\
+				  ioaddr, MCAST_REG4(lp));		\
+		}							\
 	} while (0)
 
 #define SMC_PUT_PKT_HDR(lp, status, length)				\
-- 
2.9.0
