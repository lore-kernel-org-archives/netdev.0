From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH v2 1/3] net: smc91x: isolate u16 writes alignment workaround
Date: Sun,  9 Oct 2016 22:33:45 +0200
Message-ID: <1476045227-2970-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Robert Jarzmik <robert.jarzmik@free.fr>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Pitre <nico@fluxnic.net>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp05.smtpout.orange.fr ([80.12.242.127]:50244 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751708AbcJIUeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 16:34:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Writes to u16 has a special handling on 3 PXA platforms, where the
hardware wiring forces these writes to be u32 aligned.

This patch isolates this handling for PXA platforms as before, but
enables this "workaround" to be set up dynamically, which will be the
case in device-tree build types.

This patch was tested on 2 PXA platforms : mainstone, which relies on
the workaround, and lubbock, which doesn't.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
 drivers/net/ethernet/smsc/smc91x.c |  6 ++-
 drivers/net/ethernet/smsc/smc91x.h | 80 ++++++++++++++++++++++----------------
 2 files changed, 52 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 77ad2a3f59db..b1f74e06d98e 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -602,7 +602,8 @@ static void smc_hardware_send_pkt(unsigned long data)
 	SMC_PUSH_DATA(lp, buf, len & ~1);
 
 	/* Send final ctl word with the last byte if there is one */
-	SMC_outw(((len & 1) ? (0x2000 | buf[len-1]) : 0), ioaddr, DATA_REG(lp));
+	SMC_outw(lp, ((len & 1) ? (0x2000 | buf[len-1]) : 0), ioaddr,
+		 DATA_REG(lp));
 
 	/*
 	 * If THROTTLE_TX_PKTS is set, we stop the queue here. This will
@@ -2276,6 +2277,9 @@ static int smc_drv_probe(struct platform_device *pdev)
 		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
 		lp->io_shift = SMC91X_IO_SHIFT(lp->cfg.flags);
 	}
+	lp->half_word_align4 =
+		machine_is_mainstone() || machine_is_stargate2() ||
+		machine_is_pxa_idp();
 
 #if IS_BUILTIN(CONFIG_OF)
 	match = of_match_device(of_match_ptr(smc91x_match), &pdev->dev);
diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 1a55c7976df0..2b7752db8635 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -66,10 +66,10 @@
 #define SMC_IRQ_FLAGS		(-1)	/* from resource */
 
 /* We actually can't write halfwords properly if not word aligned */
-static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
+static inline void _SMC_outw_align4(u16 val, void __iomem *ioaddr, int reg,
+				    bool use_align4_workaround)
 {
-	if ((machine_is_mainstone() || machine_is_stargate2() ||
-	     machine_is_pxa_idp()) && reg & 2) {
+	if (use_align4_workaround) {
 		unsigned int v = val << 16;
 		v |= readl(ioaddr + (reg & ~2)) & 0xffff;
 		writel(v, ioaddr + (reg & ~2));
@@ -78,6 +78,12 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 	}
 }
 
+#define SMC_outw(lp, v, a, r)						\
+	_SMC_outw_align4((v), (a), (r),					\
+			 IS_BUILTIN(CONFIG_ARCH_PXA) && ((r) & 2) &&	\
+			 lp->half_word_align4)
+
+
 #elif	defined(CONFIG_SH_SH4202_MICRODEV)
 
 #define SMC_CAN_USE_8BIT	0
@@ -88,7 +94,8 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_inw(a, r)		inw((a) + (r) - 0xa0000000)
 #define SMC_inl(a, r)		inl((a) + (r) - 0xa0000000)
 #define SMC_outb(v, a, r)	outb(v, (a) + (r) - 0xa0000000)
-#define SMC_outw(v, a, r)	outw(v, (a) + (r) - 0xa0000000)
+#define _SMC_outw(v, a, r)	outw(v, (a) + (r) - 0xa0000000)
+#define SMC_outw(lp, v, a, r)	_SMC_outw((v), (a), (r))
 #define SMC_outl(v, a, r)	outl(v, (a) + (r) - 0xa0000000)
 #define SMC_insl(a, r, p, l)	insl((a) + (r) - 0xa0000000, p, l)
 #define SMC_outsl(a, r, p, l)	outsl((a) + (r) - 0xa0000000, p, l)
@@ -106,7 +113,8 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_inb(a, r)		inb(((u32)a) + (r))
 #define SMC_inw(a, r)		inw(((u32)a) + (r))
 #define SMC_outb(v, a, r)	outb(v, ((u32)a) + (r))
-#define SMC_outw(v, a, r)	outw(v, ((u32)a) + (r))
+#define _SMC_outw(v, a, r)	outw(v, ((u32)a) + (r))
+#define SMC_outw(lp, v, a, r)	_SMC_outw((v), (a), (r))
 #define SMC_insw(a, r, p, l)	insw(((u32)a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	outsw(((u32)a) + (r), p, l)
 
@@ -134,7 +142,8 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_inw(a, r)           readw((a) + (r))
 #define SMC_inl(a, r)           readl((a) + (r))
 #define SMC_outb(v, a, r)       writeb(v, (a) + (r))
-#define SMC_outw(v, a, r)       writew(v, (a) + (r))
+#define _SMC_outw(v, a, r)       writew(v, (a) + (r))
+#define SMC_outw(lp, v, a, r)	_SMC_outw((v), (a), (r))
 #define SMC_outl(v, a, r)       writel(v, (a) + (r))
 #define SMC_insw(a, r, p, l)    readsw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)   writesw((a) + (r), p, l)
@@ -166,7 +175,8 @@ static inline void mcf_outsw(void *a, unsigned char *p, int l)
 }
 
 #define SMC_inw(a, r)		_swapw(readw((a) + (r)))
-#define SMC_outw(v, a, r)	writew(_swapw(v), (a) + (r))
+#define _SMC_outw(v, a, r)	writew(_swapw(v), (a) + (r))
+#define SMC_outw(lp, v, a, r)	_SMC_outw((v), (a), (r))
 #define SMC_insw(a, r, p, l)	mcf_insw(a + r, p, l)
 #define SMC_outsw(a, r, p, l)	mcf_outsw(a + r, p, l)
 
@@ -200,7 +210,8 @@ static inline void mcf_outsw(void *a, unsigned char *p, int l)
 #define SMC_inw(a, r)		ioread16((a) + (r))
 #define SMC_inl(a, r)		ioread32((a) + (r))
 #define SMC_outb(v, a, r)	iowrite8(v, (a) + (r))
-#define SMC_outw(v, a, r)	iowrite16(v, (a) + (r))
+#define _SMC_outw(v, a, r)	iowrite16(v, (a) + (r))
+#define SMC_outw(lp, v, a, r)	_SMC_outw((v), (a), (r))
 #define SMC_outl(v, a, r)	iowrite32(v, (a) + (r))
 #define SMC_insw(a, r, p, l)	ioread16_rep((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	iowrite16_rep((a) + (r), p, l)
@@ -262,6 +273,8 @@ struct smc_local {
 
 	/* the low address lines on some platforms aren't connected... */
 	int	io_shift;
+	/* on some platforms a u16 write must be 4-bytes aligned */
+	bool	half_word_align4;
 
 	struct smc91x_platdata cfg;
 };
@@ -420,12 +433,13 @@ smc_pxa_dma_insw(void __iomem *ioaddr, struct smc_local *lp, int reg, int dma,
  * Any 16-bit access is performed with two 8-bit accesses if the hardware
  * can't do it directly. Most registers are 16-bit so those are mandatory.
  */
-#define SMC_outw(x, ioaddr, reg)					\
+#define _SMC_outw(x, ioaddr, reg)					\
 	do {								\
 		unsigned int __val16 = (x);				\
 		SMC_outb( __val16, ioaddr, reg );			\
 		SMC_outb( __val16 >> 8, ioaddr, reg + (1 << SMC_IO_SHIFT));\
 	} while (0)
+#define SMC_outw(lp, v, a, r)	_SMC_outw((v), (a), (r))
 #define SMC_inw(ioaddr, reg)						\
 	({								\
 		unsigned int __val16;					\
@@ -882,7 +896,7 @@ static const char * chip_ids[ 16 ] =  {
 		else if (SMC_8BIT(lp))				\
 			SMC_outb(x, ioaddr, PN_REG(lp));		\
 		else							\
-			SMC_outw(x, ioaddr, PN_REG(lp));		\
+			SMC_outw(lp, x, ioaddr, PN_REG(lp));		\
 	} while (0)
 
 #define SMC_GET_AR(lp)						\
@@ -910,7 +924,7 @@ static const char * chip_ids[ 16 ] =  {
 			int __mask;					\
 			local_irq_save(__flags);			\
 			__mask = SMC_inw(ioaddr, INT_REG(lp)) & ~0xff; \
-			SMC_outw(__mask | (x), ioaddr, INT_REG(lp));	\
+			SMC_outw(lp, __mask | (x), ioaddr, INT_REG(lp)); \
 			local_irq_restore(__flags);			\
 		}							\
 	} while (0)
@@ -924,7 +938,7 @@ static const char * chip_ids[ 16 ] =  {
 		if (SMC_8BIT(lp))					\
 			SMC_outb(x, ioaddr, IM_REG(lp));		\
 		else							\
-			SMC_outw((x) << 8, ioaddr, INT_REG(lp));	\
+			SMC_outw(lp, (x) << 8, ioaddr, INT_REG(lp));	\
 	} while (0)
 
 #define SMC_CURRENT_BANK(lp)	SMC_inw(ioaddr, BANK_SELECT)
@@ -934,22 +948,22 @@ static const char * chip_ids[ 16 ] =  {
 		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, 12<<SMC_IO_SHIFT);	\
 		else							\
-			SMC_outw(x, ioaddr, BANK_SELECT);		\
+			SMC_outw(lp, x, ioaddr, BANK_SELECT);		\
 	} while (0)
 
 #define SMC_GET_BASE(lp)		SMC_inw(ioaddr, BASE_REG(lp))
 
-#define SMC_SET_BASE(lp, x)		SMC_outw(x, ioaddr, BASE_REG(lp))
+#define SMC_SET_BASE(lp, x)		SMC_outw(lp, x, ioaddr, BASE_REG(lp))
 
 #define SMC_GET_CONFIG(lp)	SMC_inw(ioaddr, CONFIG_REG(lp))
 
-#define SMC_SET_CONFIG(lp, x)	SMC_outw(x, ioaddr, CONFIG_REG(lp))
+#define SMC_SET_CONFIG(lp, x)	SMC_outw(lp, x, ioaddr, CONFIG_REG(lp))
 
 #define SMC_GET_COUNTER(lp)	SMC_inw(ioaddr, COUNTER_REG(lp))
 
 #define SMC_GET_CTL(lp)		SMC_inw(ioaddr, CTL_REG(lp))
 
-#define SMC_SET_CTL(lp, x)		SMC_outw(x, ioaddr, CTL_REG(lp))
+#define SMC_SET_CTL(lp, x)		SMC_outw(lp, x, ioaddr, CTL_REG(lp))
 
 #define SMC_GET_MII(lp)		SMC_inw(ioaddr, MII_REG(lp))
 
@@ -960,18 +974,18 @@ static const char * chip_ids[ 16 ] =  {
 		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 8, 1));	\
 		else							\
-			SMC_outw(x, ioaddr, GP_REG(lp));		\
+			SMC_outw(lp, x, ioaddr, GP_REG(lp));		\
 	} while (0)
 
-#define SMC_SET_MII(lp, x)		SMC_outw(x, ioaddr, MII_REG(lp))
+#define SMC_SET_MII(lp, x)		SMC_outw(lp, x, ioaddr, MII_REG(lp))
 
 #define SMC_GET_MIR(lp)		SMC_inw(ioaddr, MIR_REG(lp))
 
-#define SMC_SET_MIR(lp, x)		SMC_outw(x, ioaddr, MIR_REG(lp))
+#define SMC_SET_MIR(lp, x)		SMC_outw(lp, x, ioaddr, MIR_REG(lp))
 
 #define SMC_GET_MMU_CMD(lp)	SMC_inw(ioaddr, MMU_CMD_REG(lp))
 
-#define SMC_SET_MMU_CMD(lp, x)	SMC_outw(x, ioaddr, MMU_CMD_REG(lp))
+#define SMC_SET_MMU_CMD(lp, x)	SMC_outw(lp, x, ioaddr, MMU_CMD_REG(lp))
 
 #define SMC_GET_FIFO(lp)		SMC_inw(ioaddr, FIFO_REG(lp))
 
@@ -982,14 +996,14 @@ static const char * chip_ids[ 16 ] =  {
 		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 4, 2));	\
 		else							\
-			SMC_outw(x, ioaddr, PTR_REG(lp));		\
+			SMC_outw(lp, x, ioaddr, PTR_REG(lp));		\
 	} while (0)
 
 #define SMC_GET_EPH_STATUS(lp)	SMC_inw(ioaddr, EPH_STATUS_REG(lp))
 
 #define SMC_GET_RCR(lp)		SMC_inw(ioaddr, RCR_REG(lp))
 
-#define SMC_SET_RCR(lp, x)		SMC_outw(x, ioaddr, RCR_REG(lp))
+#define SMC_SET_RCR(lp, x)		SMC_outw(lp, x, ioaddr, RCR_REG(lp))
 
 #define SMC_GET_REV(lp)		SMC_inw(ioaddr, REV_REG(lp))
 
@@ -1000,12 +1014,12 @@ static const char * chip_ids[ 16 ] =  {
 		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 8, 0));	\
 		else							\
-			SMC_outw(x, ioaddr, RPC_REG(lp));		\
+			SMC_outw(lp, x, ioaddr, RPC_REG(lp));		\
 	} while (0)
 
 #define SMC_GET_TCR(lp)		SMC_inw(ioaddr, TCR_REG(lp))
 
-#define SMC_SET_TCR(lp, x)		SMC_outw(x, ioaddr, TCR_REG(lp))
+#define SMC_SET_TCR(lp, x)		SMC_outw(lp, x, ioaddr, TCR_REG(lp))
 
 #ifndef SMC_GET_MAC_ADDR
 #define SMC_GET_MAC_ADDR(lp, addr)					\
@@ -1022,18 +1036,18 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_SET_MAC_ADDR(lp, addr)					\
 	do {								\
-		SMC_outw(addr[0]|(addr[1] << 8), ioaddr, ADDR0_REG(lp)); \
-		SMC_outw(addr[2]|(addr[3] << 8), ioaddr, ADDR1_REG(lp)); \
-		SMC_outw(addr[4]|(addr[5] << 8), ioaddr, ADDR2_REG(lp)); \
+		SMC_outw(lp, addr[0]|(addr[1] << 8), ioaddr, ADDR0_REG(lp)); \
+		SMC_outw(lp, addr[2]|(addr[3] << 8), ioaddr, ADDR1_REG(lp)); \
+		SMC_outw(lp, addr[4]|(addr[5] << 8), ioaddr, ADDR2_REG(lp)); \
 	} while (0)
 
 #define SMC_SET_MCAST(lp, x)						\
 	do {								\
 		const unsigned char *mt = (x);				\
-		SMC_outw(mt[0] | (mt[1] << 8), ioaddr, MCAST_REG1(lp)); \
-		SMC_outw(mt[2] | (mt[3] << 8), ioaddr, MCAST_REG2(lp)); \
-		SMC_outw(mt[4] | (mt[5] << 8), ioaddr, MCAST_REG3(lp)); \
-		SMC_outw(mt[6] | (mt[7] << 8), ioaddr, MCAST_REG4(lp)); \
+		SMC_outw(lp, mt[0] | (mt[1] << 8), ioaddr, MCAST_REG1(lp)); \
+		SMC_outw(lp, mt[2] | (mt[3] << 8), ioaddr, MCAST_REG2(lp)); \
+		SMC_outw(lp, mt[4] | (mt[5] << 8), ioaddr, MCAST_REG3(lp)); \
+		SMC_outw(lp, mt[6] | (mt[7] << 8), ioaddr, MCAST_REG4(lp)); \
 	} while (0)
 
 #define SMC_PUT_PKT_HDR(lp, status, length)				\
@@ -1042,8 +1056,8 @@ static const char * chip_ids[ 16 ] =  {
 			SMC_outl((status) | (length)<<16, ioaddr,	\
 				 DATA_REG(lp));			\
 		else {							\
-			SMC_outw(status, ioaddr, DATA_REG(lp));	\
-			SMC_outw(length, ioaddr, DATA_REG(lp));	\
+			SMC_outw(lp, status, ioaddr, DATA_REG(lp));	\
+			SMC_outw(lp, length, ioaddr, DATA_REG(lp));	\
 		}							\
 	} while (0)
 
-- 
2.1.4
