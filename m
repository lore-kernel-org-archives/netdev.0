From: akpm@linux-foundation.org
Subject: [patch 06/17] smc91x: introduce platform data flags
Date: Tue, 04 Mar 2008 15:19:25 -0800
Message-ID: <200803042319.m24NJQjI002687@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	magnus.damm@gmail.com, damm@igel.co.jp, lethal@linux-sh.org,
	nico@cam.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46000 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935117AbYCDXTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <magnus.damm@gmail.com>

This patch introduces struct smc91x_platdata and modifies the driver so bus
width is checked during run time using SMC_nBIT() instead of SMC_CAN_USE_nBIT.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
Acked-by: Nicolas Pitre <nico@cam.org>
Cc: Paul Mundt <lethal@linux-sh.org>,
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc91x.c   |   34 +++++++++++++++++++----
 drivers/net/smc91x.h   |   57 +++++++++++++++++++++++----------------
 include/linux/smc91x.h |   13 ++++++++
 3 files changed, 77 insertions(+), 27 deletions(-)

diff -puN drivers/net/smc91x.c~smc91x-introduce-platform-data-flags-v2 drivers/net/smc91x.c
--- a/drivers/net/smc91x.c~smc91x-introduce-platform-data-flags-v2
+++ a/drivers/net/smc91x.c
@@ -1997,6 +1997,8 @@ err_out:
 
 static int smc_enable_device(struct platform_device *pdev)
 {
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct smc_local *lp = netdev_priv(ndev);
 	unsigned long flags;
 	unsigned char ecor, ecsr;
 	void __iomem *addr;
@@ -2039,7 +2041,7 @@ static int smc_enable_device(struct plat
 	 * Set the appropriate byte/word mode.
 	 */
 	ecsr = readb(addr + (ECSR << SMC_IO_SHIFT)) & ~ECSR_IOIS8;
-	if (!SMC_CAN_USE_16BIT)
+	if (!SMC_16BIT(lp))
 		ecsr |= ECSR_IOIS8;
 	writeb(ecsr, addr + (ECSR << SMC_IO_SHIFT));
 	local_irq_restore(flags);
@@ -2124,10 +2126,11 @@ static void smc_release_datacs(struct pl
  */
 static int smc_drv_probe(struct platform_device *pdev)
 {
+	struct smc91x_platdata *pd = pdev->dev.platform_data;
+	struct smc_local *lp;
 	struct net_device *ndev;
 	struct resource *res, *ires;
 	unsigned int __iomem *addr;
-	unsigned long irq_flags = SMC_IRQ_FLAGS;
 	int ret;
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-regs");
@@ -2152,6 +2155,27 @@ static int smc_drv_probe(struct platform
 	}
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
+	/* get configuration from platform data, only allow use of
+	 * bus width if both SMC_CAN_USE_xxx and SMC91X_USE_xxx are set.
+	 */
+
+	lp = netdev_priv(ndev);
+	lp->cfg.irq_flags = SMC_IRQ_FLAGS;
+
+#ifdef SMC_DYNAMIC_BUS_CONFIG
+	if (pd)
+		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
+	else {
+		lp->cfg.flags = SMC91X_USE_8BIT;
+		lp->cfg.flags |= SMC91X_USE_16BIT;
+		lp->cfg.flags |= SMC91X_USE_32BIT;
+	}
+
+	lp->cfg.flags &= ~(SMC_CAN_USE_8BIT ? 0 : SMC91X_USE_8BIT);
+	lp->cfg.flags &= ~(SMC_CAN_USE_16BIT ? 0 : SMC91X_USE_16BIT);
+	lp->cfg.flags &= ~(SMC_CAN_USE_32BIT ? 0 : SMC91X_USE_32BIT);
+#endif
+
 	ndev->dma = (unsigned char)-1;
 
 	ires = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
@@ -2162,7 +2186,7 @@ static int smc_drv_probe(struct platform
 
 	ndev->irq = ires->start;
 	if (SMC_IRQ_FLAGS == -1)
-		irq_flags = ires->flags & IRQF_TRIGGER_MASK;
+		lp->cfg.irq_flags = ires->flags & IRQF_TRIGGER_MASK;
 
 	ret = smc_request_attrib(pdev);
 	if (ret)
@@ -2170,6 +2194,7 @@ static int smc_drv_probe(struct platform
 #if defined(CONFIG_SA1100_ASSABET)
 	NCR_0 |= NCR_ENET_OSC_EN;
 #endif
+	platform_set_drvdata(pdev, ndev);
 	ret = smc_enable_device(pdev);
 	if (ret)
 		goto out_release_attrib;
@@ -2188,8 +2213,7 @@ static int smc_drv_probe(struct platform
 	}
 #endif
 
-	platform_set_drvdata(pdev, ndev);
-	ret = smc_probe(ndev, addr, irq_flags);
+	ret = smc_probe(ndev, addr, lp->cfg.irq_flags);
 	if (ret != 0)
 		goto out_iounmap;
 
diff -puN drivers/net/smc91x.h~smc91x-introduce-platform-data-flags-v2 drivers/net/smc91x.h
--- a/drivers/net/smc91x.h~smc91x-introduce-platform-data-flags-v2
+++ a/drivers/net/smc91x.h
@@ -34,6 +34,7 @@
 #ifndef _SMC91X_H_
 #define _SMC91X_H_
 
+#include <linux/smc91x.h>
 
 /*
  * Define your architecture specific bus configuration parameters here.
@@ -481,6 +482,7 @@ static inline void LPD7_SMC_outsw (unsig
 #define RPC_LSA_DEFAULT		RPC_LED_100_10
 #define RPC_LSB_DEFAULT		RPC_LED_TX_RX
 
+#define SMC_DYNAMIC_BUS_CONFIG
 #endif
 
 
@@ -526,8 +528,19 @@ struct smc_local {
 #endif
 	void __iomem *base;
 	void __iomem *datacs;
+
+	struct smc91x_platdata cfg;
 };
 
+#ifdef SMC_DYNAMIC_BUS_CONFIG
+#define SMC_8BIT(p) (((p)->cfg.flags & SMC91X_USE_8BIT) && SMC_CAN_USE_8BIT)
+#define SMC_16BIT(p) (((p)->cfg.flags & SMC91X_USE_16BIT) && SMC_CAN_USE_16BIT)
+#define SMC_32BIT(p) (((p)->cfg.flags & SMC91X_USE_32BIT) && SMC_CAN_USE_32BIT)
+#else
+#define SMC_8BIT(p) SMC_CAN_USE_8BIT
+#define SMC_16BIT(p) SMC_CAN_USE_16BIT
+#define SMC_32BIT(p) SMC_CAN_USE_32BIT
+#endif
 
 #ifdef SMC_USE_PXA_DMA
 /*
@@ -1108,41 +1121,41 @@ static const char * chip_ids[ 16 ] =  {
  *
  * Enforce it on any 32-bit capable setup for now.
  */
-#define SMC_MUST_ALIGN_WRITE	SMC_CAN_USE_32BIT
+#define SMC_MUST_ALIGN_WRITE(lp)	SMC_32BIT(lp)
 
 #define SMC_GET_PN(lp)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, PN_REG(lp)))	\
+	(SMC_8BIT(lp)	? (SMC_inb(ioaddr, PN_REG(lp)))	\
 				: (SMC_inw(ioaddr, PN_REG(lp)) & 0xFF))
 
 #define SMC_SET_PN(lp, x)						\
 	do {								\
-		if (SMC_MUST_ALIGN_WRITE)				\
+		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 0, 2));	\
-		else if (SMC_CAN_USE_8BIT)				\
+		else if (SMC_8BIT(lp))				\
 			SMC_outb(x, ioaddr, PN_REG(lp));		\
 		else							\
 			SMC_outw(x, ioaddr, PN_REG(lp));		\
 	} while (0)
 
 #define SMC_GET_AR(lp)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, AR_REG(lp)))	\
+	(SMC_8BIT(lp)	? (SMC_inb(ioaddr, AR_REG(lp)))	\
 				: (SMC_inw(ioaddr, PN_REG(lp)) >> 8))
 
 #define SMC_GET_TXFIFO(lp)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, TXFIFO_REG(lp)))	\
+	(SMC_8BIT(lp)	? (SMC_inb(ioaddr, TXFIFO_REG(lp)))	\
 				: (SMC_inw(ioaddr, TXFIFO_REG(lp)) & 0xFF))
 
 #define SMC_GET_RXFIFO(lp)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, RXFIFO_REG(lp)))	\
+	(SMC_8BIT(lp)	? (SMC_inb(ioaddr, RXFIFO_REG(lp)))	\
 				: (SMC_inw(ioaddr, TXFIFO_REG(lp)) >> 8))
 
 #define SMC_GET_INT(lp)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, INT_REG(lp)))	\
+	(SMC_8BIT(lp)	? (SMC_inb(ioaddr, INT_REG(lp)))	\
 				: (SMC_inw(ioaddr, INT_REG(lp)) & 0xFF))
 
 #define SMC_ACK_INT(lp, x)						\
 	do {								\
-		if (SMC_CAN_USE_8BIT)					\
+		if (SMC_8BIT(lp))					\
 			SMC_outb(x, ioaddr, INT_REG(lp));		\
 		else {							\
 			unsigned long __flags;				\
@@ -1155,12 +1168,12 @@ static const char * chip_ids[ 16 ] =  {
 	} while (0)
 
 #define SMC_GET_INT_MASK(lp)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, IM_REG(lp)))	\
+	(SMC_8BIT(lp)	? (SMC_inb(ioaddr, IM_REG(lp)))	\
 				: (SMC_inw(ioaddr, INT_REG(lp)) >> 8))
 
 #define SMC_SET_INT_MASK(lp, x)					\
 	do {								\
-		if (SMC_CAN_USE_8BIT)					\
+		if (SMC_8BIT(lp))					\
 			SMC_outb(x, ioaddr, IM_REG(lp));		\
 		else							\
 			SMC_outw((x) << 8, ioaddr, INT_REG(lp));	\
@@ -1170,7 +1183,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_SELECT_BANK(lp, x)					\
 	do {								\
-		if (SMC_MUST_ALIGN_WRITE)				\
+		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, 12<<SMC_IO_SHIFT);	\
 		else							\
 			SMC_outw(x, ioaddr, BANK_SELECT);		\
@@ -1208,7 +1221,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_SET_PTR(lp, x)						\
 	do {								\
-		if (SMC_MUST_ALIGN_WRITE)				\
+		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 4, 2));	\
 		else							\
 			SMC_outw(x, ioaddr, PTR_REG(lp));		\
@@ -1226,7 +1239,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_SET_RPC(lp, x)						\
 	do {								\
-		if (SMC_MUST_ALIGN_WRITE)				\
+		if (SMC_MUST_ALIGN_WRITE(lp))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 8, 0));	\
 		else							\
 			SMC_outw(x, ioaddr, RPC_REG(lp));		\
@@ -1267,7 +1280,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_PUT_PKT_HDR(lp, status, length)				\
 	do {								\
-		if (SMC_CAN_USE_32BIT)					\
+		if (SMC_32BIT(lp))					\
 			SMC_outl((status) | (length)<<16, ioaddr,	\
 				 DATA_REG(lp));			\
 		else {							\
@@ -1278,7 +1291,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_GET_PKT_HDR(lp, status, length)				\
 	do {								\
-		if (SMC_CAN_USE_32BIT) {				\
+		if (SMC_32BIT(lp)) {				\
 			unsigned int __val = SMC_inl(ioaddr, DATA_REG(lp)); \
 			(status) = __val & 0xffff;			\
 			(length) = __val >> 16;				\
@@ -1290,7 +1303,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_PUSH_DATA(lp, p, l)					\
 	do {								\
-		if (SMC_CAN_USE_32BIT) {				\
+		if (SMC_32BIT(lp)) {				\
 			void *__ptr = (p);				\
 			int __len = (l);				\
 			void __iomem *__ioaddr = ioaddr;		\
@@ -1308,15 +1321,15 @@ static const char * chip_ids[ 16 ] =  {
 				SMC_outw(*((u16 *)__ptr), ioaddr,	\
 					 DATA_REG(lp));		\
 			}						\
-		} else if (SMC_CAN_USE_16BIT)				\
+		} else if (SMC_16BIT(lp))				\
 			SMC_outsw(ioaddr, DATA_REG(lp), p, (l) >> 1);	\
-		else if (SMC_CAN_USE_8BIT)				\
+		else if (SMC_8BIT(lp))				\
 			SMC_outsb(ioaddr, DATA_REG(lp), p, l);	\
 	} while (0)
 
 #define SMC_PULL_DATA(lp, p, l)					\
 	do {								\
-		if (SMC_CAN_USE_32BIT) {				\
+		if (SMC_32BIT(lp)) {				\
 			void *__ptr = (p);				\
 			int __len = (l);				\
 			void __iomem *__ioaddr = ioaddr;		\
@@ -1343,9 +1356,9 @@ static const char * chip_ids[ 16 ] =  {
 				__ioaddr = lp->datacs;			\
 			__len += 2;					\
 			SMC_insl(__ioaddr, DATA_REG(lp), __ptr, __len>>2); \
-		} else if (SMC_CAN_USE_16BIT)				\
+		} else if (SMC_16BIT(lp))				\
 			SMC_insw(ioaddr, DATA_REG(lp), p, (l) >> 1);	\
-		else if (SMC_CAN_USE_8BIT)				\
+		else if (SMC_8BIT(lp))				\
 			SMC_insb(ioaddr, DATA_REG(lp), p, l);		\
 	} while (0)
 
diff -puN /dev/null include/linux/smc91x.h
--- /dev/null
+++ a/include/linux/smc91x.h
@@ -0,0 +1,13 @@
+#ifndef __SMC91X_H__
+#define __SMC91X_H__
+
+#define SMC91X_USE_8BIT (1 << 0)
+#define SMC91X_USE_16BIT (1 << 1)
+#define SMC91X_USE_32BIT (1 << 2)
+
+struct smc91x_platdata {
+	unsigned long flags;
+	unsigned long irq_flags; /* IRQF_... */
+};
+
+#endif /* __SMC91X_H__ */
_
