From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/2] smc91x: always use 8-bit access if necessary
Date: Thu, 25 Aug 2016 16:46:20 +0200
Message-ID: <20160825144633.1850889-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Yoshinori Sato <ysato@users.sourceforge.jp>,
 Nicolas Pitre <nico@fluxnic.net>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Robert Jarzmik <robert.jarzmik@free.fr>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Russell King <linux@armlinux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

As Russell King found out the hard way, a change I did to fix multiplatform
builds with this driver broke the old Assabet/Neponset platform: It turns
out that while the driver is runtime configurable in principle, the
runtime configuration does not cover the specific case of machines that
can not do any 16-bit I/O on the smc91x registers.

The driver currently provides helpers to access 16-bit registers for
architectures that are known at compile-time to only have 8-bit I/O,
but my patch changed it to a runtime flag that never gets consulted
most register accesses.

This introduces new SMC_out16()/SMC_in16 helpers (if anyone can suggest
a better name, I'm glad to modify this) that behaves like SMC_outw()/SMC_inw()
most of the time, but uses a pair of 8-bit accesses on platforms that
have no support for wider register accesses.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Reported-by: Russell King <linux@armlinux.org.uk>
Fixes: b70661c70830d ("net: smc91x: use run-time configuration on all ARM machines")
---
 drivers/net/ethernet/smsc/smc91x.h | 125 ++++++++++++++++++++-----------------
 1 file changed, 66 insertions(+), 59 deletions(-)


While this patch fixes one bug on Neponset, it probably doesn't address
the one that Russell ran into first, so this is for review only for now,
until the remaining problem(s) have been worked out.

Please ignore the first submission, I accidentally only sent out patch 2/2,
which does not actually fix a bug.

diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 1a55c7976df0..22333477d0b5 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -414,25 +414,32 @@ smc_pxa_dma_insw(void __iomem *ioaddr, struct smc_local *lp, int reg, int dma,
 #define SMC_outsl(a, r, p, l)		BUG()
 #endif
 
-#if ! SMC_CAN_USE_16BIT
-
 /*
- * Any 16-bit access is performed with two 8-bit accesses if the hardware
- * can't do it directly. Most registers are 16-bit so those are mandatory.
+ * Any 16-bit register access is performed with two 8-bit accesses if the
+ * hardware can't do it directly.
  */
-#define SMC_outw(x, ioaddr, reg)					\
-	do {								\
-		unsigned int __val16 = (x);				\
-		SMC_outb( __val16, ioaddr, reg );			\
-		SMC_outb( __val16 >> 8, ioaddr, reg + (1 << SMC_IO_SHIFT));\
-	} while (0)
-#define SMC_inw(ioaddr, reg)						\
-	({								\
-		unsigned int __val16;					\
-		__val16 =  SMC_inb( ioaddr, reg );			\
+#define SMC_out16(x, ioaddr, reg)					     \
+do {									     \
+	if (SMC_CAN_USE_8BIT && !SMC_16BIT(lp)) {			     \
+		unsigned int __val16 = (x);				     \
+		SMC_outb(__val16, ioaddr, reg );			     \
+		SMC_outb(__val16 >> 8, ioaddr, reg + (1 << SMC_IO_SHIFT));   \
+	} else {							     \
+		SMC_outw(x, ioaddr, reg);				     \
+	}								     \
+} while (0)
+
+#define SMC_in16(ioaddr, reg)						     \
+({									     \
+	unsigned int __val16;					   	     \
+	if (SMC_CAN_USE_8BIT && !SMC_16BIT(lp)) {			     \
+		__val16 =  SMC_inb( ioaddr, reg );			     \
 		__val16 |= SMC_inb( ioaddr, reg + (1 << SMC_IO_SHIFT)) << 8; \
-		__val16;						\
-	})
+	} else {							     \
+		__val16 = SMC_inw(ioaddr, reg);				     \
+	}								     \
+	__val16;							     \
+})
 
 #define SMC_insw(a, r, p, l)		BUG()
 #define SMC_outsw(a, r, p, l)		BUG()
@@ -927,113 +934,113 @@ static const char * chip_ids[ 16 ] =  {
 			SMC_outw((x) << 8, ioaddr, INT_REG(lp));	\
 	} while (0)
 
-#define SMC_CURRENT_BANK(lp)	SMC_inw(ioaddr, BANK_SELECT)
+#define SMC_CURRENT_BANK(lp)	SMC_in16(ioaddr, BANK_SELECT)
 
 #define SMC_SELECT_BANK(lp, x)					\
 	do {								\
 		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, 12<<SMC_IO_SHIFT);	\
 		else							\
-			SMC_outw(x, ioaddr, BANK_SELECT);		\
+			SMC_out16(x, ioaddr, BANK_SELECT);		\
 	} while (0)
 
-#define SMC_GET_BASE(lp)		SMC_inw(ioaddr, BASE_REG(lp))
+#define SMC_GET_BASE(lp)	SMC_in16(ioaddr, BASE_REG(lp))
 
-#define SMC_SET_BASE(lp, x)		SMC_outw(x, ioaddr, BASE_REG(lp))
+#define SMC_SET_BASE(lp, x)	SMC_out16(x, ioaddr, BASE_REG(lp))
 
-#define SMC_GET_CONFIG(lp)	SMC_inw(ioaddr, CONFIG_REG(lp))
+#define SMC_GET_CONFIG(lp)	SMC_in16(ioaddr, CONFIG_REG(lp))
 
-#define SMC_SET_CONFIG(lp, x)	SMC_outw(x, ioaddr, CONFIG_REG(lp))
+#define SMC_SET_CONFIG(lp, x)	SMC_out16(x, ioaddr, CONFIG_REG(lp))
 
-#define SMC_GET_COUNTER(lp)	SMC_inw(ioaddr, COUNTER_REG(lp))
+#define SMC_GET_COUNTER(lp)	SMC_in16(ioaddr, COUNTER_REG(lp))
 
-#define SMC_GET_CTL(lp)		SMC_inw(ioaddr, CTL_REG(lp))
+#define SMC_GET_CTL(lp)		SMC_in16(ioaddr, CTL_REG(lp))
 
-#define SMC_SET_CTL(lp, x)		SMC_outw(x, ioaddr, CTL_REG(lp))
+#define SMC_SET_CTL(lp, x)	SMC_out16(x, ioaddr, CTL_REG(lp))
 
-#define SMC_GET_MII(lp)		SMC_inw(ioaddr, MII_REG(lp))
+#define SMC_GET_MII(lp)		SMC_in16(ioaddr, MII_REG(lp))
 
-#define SMC_GET_GP(lp)		SMC_inw(ioaddr, GP_REG(lp))
+#define SMC_GET_GP(lp)		SMC_in16(ioaddr, GP_REG(lp))
 
 #define SMC_SET_GP(lp, x)						\
 	do {								\
 		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 8, 1));	\
 		else							\
-			SMC_outw(x, ioaddr, GP_REG(lp));		\
+			SMC_out16(x, ioaddr, GP_REG(lp));		\
 	} while (0)
 
-#define SMC_SET_MII(lp, x)		SMC_outw(x, ioaddr, MII_REG(lp))
+#define SMC_SET_MII(lp, x)	SMC_out16(x, ioaddr, MII_REG(lp))
 
-#define SMC_GET_MIR(lp)		SMC_inw(ioaddr, MIR_REG(lp))
+#define SMC_GET_MIR(lp)		SMC_in16(ioaddr, MIR_REG(lp))
 
-#define SMC_SET_MIR(lp, x)		SMC_outw(x, ioaddr, MIR_REG(lp))
+#define SMC_SET_MIR(lp, x)	SMC_out16(x, ioaddr, MIR_REG(lp))
 
-#define SMC_GET_MMU_CMD(lp)	SMC_inw(ioaddr, MMU_CMD_REG(lp))
+#define SMC_GET_MMU_CMD(lp)	SMC_in16(ioaddr, MMU_CMD_REG(lp))
 
-#define SMC_SET_MMU_CMD(lp, x)	SMC_outw(x, ioaddr, MMU_CMD_REG(lp))
+#define SMC_SET_MMU_CMD(lp, x)	SMC_out16(x, ioaddr, MMU_CMD_REG(lp))
 
-#define SMC_GET_FIFO(lp)		SMC_inw(ioaddr, FIFO_REG(lp))
+#define SMC_GET_FIFO(lp)	SMC_in16(ioaddr, FIFO_REG(lp))
 
-#define SMC_GET_PTR(lp)		SMC_inw(ioaddr, PTR_REG(lp))
+#define SMC_GET_PTR(lp)		SMC_in16(ioaddr, PTR_REG(lp))
 
 #define SMC_SET_PTR(lp, x)						\
 	do {								\
 		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 4, 2));	\
 		else							\
-			SMC_outw(x, ioaddr, PTR_REG(lp));		\
+			SMC_out16(x, ioaddr, PTR_REG(lp));		\
 	} while (0)
 
-#define SMC_GET_EPH_STATUS(lp)	SMC_inw(ioaddr, EPH_STATUS_REG(lp))
+#define SMC_GET_EPH_STATUS(lp)	SMC_in16(ioaddr, EPH_STATUS_REG(lp))
 
-#define SMC_GET_RCR(lp)		SMC_inw(ioaddr, RCR_REG(lp))
+#define SMC_GET_RCR(lp)		SMC_in16(ioaddr, RCR_REG(lp))
 
-#define SMC_SET_RCR(lp, x)		SMC_outw(x, ioaddr, RCR_REG(lp))
+#define SMC_SET_RCR(lp, x)	SMC_out16(x, ioaddr, RCR_REG(lp))
 
-#define SMC_GET_REV(lp)		SMC_inw(ioaddr, REV_REG(lp))
+#define SMC_GET_REV(lp)		SMC_in16(ioaddr, REV_REG(lp))
 
-#define SMC_GET_RPC(lp)		SMC_inw(ioaddr, RPC_REG(lp))
+#define SMC_GET_RPC(lp)		SMC_in16(ioaddr, RPC_REG(lp))
 
 #define SMC_SET_RPC(lp, x)						\
 	do {								\
 		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 8, 0));	\
 		else							\
-			SMC_outw(x, ioaddr, RPC_REG(lp));		\
+			SMC_out16(x, ioaddr, RPC_REG(lp));		\
 	} while (0)
 
-#define SMC_GET_TCR(lp)		SMC_inw(ioaddr, TCR_REG(lp))
+#define SMC_GET_TCR(lp)		SMC_in16(ioaddr, TCR_REG(lp))
 
-#define SMC_SET_TCR(lp, x)		SMC_outw(x, ioaddr, TCR_REG(lp))
+#define SMC_SET_TCR(lp, x)	SMC_out16(x, ioaddr, TCR_REG(lp))
 
 #ifndef SMC_GET_MAC_ADDR
 #define SMC_GET_MAC_ADDR(lp, addr)					\
 	do {								\
 		unsigned int __v;					\
-		__v = SMC_inw(ioaddr, ADDR0_REG(lp));			\
+		__v = SMC_in16(ioaddr, ADDR0_REG(lp));			\
 		addr[0] = __v; addr[1] = __v >> 8;			\
-		__v = SMC_inw(ioaddr, ADDR1_REG(lp));			\
+		__v = SMC_in16(ioaddr, ADDR1_REG(lp));			\
 		addr[2] = __v; addr[3] = __v >> 8;			\
-		__v = SMC_inw(ioaddr, ADDR2_REG(lp));			\
+		__v = SMC_in16(ioaddr, ADDR2_REG(lp));			\
 		addr[4] = __v; addr[5] = __v >> 8;			\
 	} while (0)
 #endif
 
 #define SMC_SET_MAC_ADDR(lp, addr)					\
 	do {								\
-		SMC_outw(addr[0]|(addr[1] << 8), ioaddr, ADDR0_REG(lp)); \
-		SMC_outw(addr[2]|(addr[3] << 8), ioaddr, ADDR1_REG(lp)); \
-		SMC_outw(addr[4]|(addr[5] << 8), ioaddr, ADDR2_REG(lp)); \
+		SMC_out16(addr[0]|(addr[1] << 8), ioaddr, ADDR0_REG(lp)); \
+		SMC_out16(addr[2]|(addr[3] << 8), ioaddr, ADDR1_REG(lp)); \
+		SMC_out16(addr[4]|(addr[5] << 8), ioaddr, ADDR2_REG(lp)); \
 	} while (0)
 
 #define SMC_SET_MCAST(lp, x)						\
 	do {								\
 		const unsigned char *mt = (x);				\
-		SMC_outw(mt[0] | (mt[1] << 8), ioaddr, MCAST_REG1(lp)); \
-		SMC_outw(mt[2] | (mt[3] << 8), ioaddr, MCAST_REG2(lp)); \
-		SMC_outw(mt[4] | (mt[5] << 8), ioaddr, MCAST_REG3(lp)); \
-		SMC_outw(mt[6] | (mt[7] << 8), ioaddr, MCAST_REG4(lp)); \
+		SMC_out16(mt[0] | (mt[1] << 8), ioaddr, MCAST_REG1(lp)); \
+		SMC_out16(mt[2] | (mt[3] << 8), ioaddr, MCAST_REG2(lp)); \
+		SMC_out16(mt[4] | (mt[5] << 8), ioaddr, MCAST_REG3(lp)); \
+		SMC_out16(mt[6] | (mt[7] << 8), ioaddr, MCAST_REG4(lp)); \
 	} while (0)
 
 #define SMC_PUT_PKT_HDR(lp, status, length)				\
@@ -1042,8 +1049,8 @@ static const char * chip_ids[ 16 ] =  {
 			SMC_outl((status) | (length)<<16, ioaddr,	\
 				 DATA_REG(lp));			\
 		else {							\
-			SMC_outw(status, ioaddr, DATA_REG(lp));	\
-			SMC_outw(length, ioaddr, DATA_REG(lp));	\
+			SMC_out16(status, ioaddr, DATA_REG(lp));	\
+			SMC_out16(length, ioaddr, DATA_REG(lp));	\
 		}							\
 	} while (0)
 
@@ -1053,9 +1060,9 @@ static const char * chip_ids[ 16 ] =  {
 			unsigned int __val = SMC_inl(ioaddr, DATA_REG(lp)); \
 			(status) = __val & 0xffff;			\
 			(length) = __val >> 16;				\
-		} else {						\
-			(status) = SMC_inw(ioaddr, DATA_REG(lp));	\
-			(length) = SMC_inw(ioaddr, DATA_REG(lp));	\
+		} else if (SMC_16BIT(lp) {						\
+			(status) = SMC_in16(ioaddr, DATA_REG(lp));	\
+			(length) = SMC_in16(ioaddr, DATA_REG(lp));	\
 		}							\
 	} while (0)
 
-- 
2.9.0
