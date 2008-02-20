From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH 02/04] smc91x: introduce platform data flags
Date: Wed, 20 Feb 2008 18:58:02 +0900
Message-ID: <20080220095802.22645.44691.sendpatchset@clockwork.opensource.se>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	nico@cam.org, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:48369 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbYBTKDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 05:03:21 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1895551rvb.1
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 02:03:18 -0800 (PST)
In-Reply-To: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces struct smc91x_platdata and modifies the driver so
bus width is checked during run time using SMC_nBIT() instead of
SMC_CAN_USE_nBIT.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc91x.c   |   31 ++++++++++++++++++++++++-----
 drivers/net/smc91x.h   |   50 ++++++++++++++++++++++++++----------------------
 include/linux/smc91x.h |   13 ++++++++++++
 3 files changed, 67 insertions(+), 27 deletions(-)

--- 0017/drivers/net/smc91x.c
+++ work/drivers/net/smc91x.c	2008-02-20 17:04:41.000000000 +0900
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
@@ -2152,6 +2155,24 @@ static int smc_drv_probe(struct platform
 	}
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
+	/* get configuration from platform data, only allow use of
+	 * bus width if both SMC_CAN_USE_xxx and SMC91X_USE_xxx are set.
+	 */
+
+	lp = netdev_priv(ndev);
+	if (pd)
+		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
+	else {
+		lp->cfg.flags = SMC91X_USE_8BIT;
+		lp->cfg.flags |= SMC91X_USE_16BIT;
+		lp->cfg.flags |= SMC91X_USE_32BIT;
+		lp->cfg.irq_flags = SMC_IRQ_FLAGS;
+	}
+
+	lp->cfg.flags &= ~(SMC_CAN_USE_8BIT ? 0 : SMC91X_USE_8BIT);
+	lp->cfg.flags &= ~(SMC_CAN_USE_16BIT ? 0 : SMC91X_USE_16BIT);
+	lp->cfg.flags &= ~(SMC_CAN_USE_32BIT ? 0 : SMC91X_USE_32BIT);
+
 	ndev->dma = (unsigned char)-1;
 
 	ires = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
@@ -2162,7 +2183,7 @@ static int smc_drv_probe(struct platform
 
 	ndev->irq = ires->start;
 	if (SMC_IRQ_FLAGS == -1)
-		irq_flags = ires->flags & IRQF_TRIGGER_MASK;
+		lp->cfg.irq_flags = ires->flags & IRQF_TRIGGER_MASK;
 
 	ret = smc_request_attrib(pdev);
 	if (ret)
@@ -2170,6 +2191,7 @@ static int smc_drv_probe(struct platform
 #if defined(CONFIG_SA1100_ASSABET)
 	NCR_0 |= NCR_ENET_OSC_EN;
 #endif
+	platform_set_drvdata(pdev, ndev);
 	ret = smc_enable_device(pdev);
 	if (ret)
 		goto out_release_attrib;
@@ -2188,8 +2210,7 @@ static int smc_drv_probe(struct platform
 	}
 #endif
 
-	platform_set_drvdata(pdev, ndev);
-	ret = smc_probe(ndev, addr, irq_flags);
+	ret = smc_probe(ndev, addr, lp->cfg.irq_flags);
 	if (ret != 0)
 		goto out_iounmap;
 
--- 0017/drivers/net/smc91x.h
+++ work/drivers/net/smc91x.h	2008-02-20 17:08:35.000000000 +0900
@@ -34,6 +34,7 @@
 #ifndef _SMC91X_H_
 #define _SMC91X_H_
 
+#include <linux/smc91x.h>
 
 /*
  * Define your architecture specific bus configuration parameters here.
@@ -526,8 +527,13 @@ struct smc_local {
 #endif
 	void __iomem *base;
 	void __iomem *datacs;
+
+	struct smc91x_platdata cfg;
 };
 
+#define SMC_8BIT(p) (((p)->cfg.flags & SMC91X_USE_8BIT) && SMC_CAN_USE_8BIT)
+#define SMC_16BIT(p) (((p)->cfg.flags & SMC91X_USE_16BIT) && SMC_CAN_USE_16BIT)
+#define SMC_32BIT(p) (((p)->cfg.flags & SMC91X_USE_32BIT) && SMC_CAN_USE_32BIT)
 
 #ifdef SMC_USE_PXA_DMA
 /*
@@ -1108,41 +1114,41 @@ static const char * chip_ids[ 16 ] =  {
  *
  * Enforce it on any 32-bit capable setup for now.
  */
-#define SMC_MUST_ALIGN_WRITE	SMC_CAN_USE_32BIT
+#define SMC_MUST_ALIGN_WRITE(priv)	SMC_32BIT(priv)
 
 #define SMC_GET_PN(priv)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, PN_REG(priv)))	\
+	(SMC_8BIT(priv)	? (SMC_inb(ioaddr, PN_REG(priv)))	\
 				: (SMC_inw(ioaddr, PN_REG(priv)) & 0xFF))
 
 #define SMC_SET_PN(priv, x)						\
 	do {								\
-		if (SMC_MUST_ALIGN_WRITE)				\
+		if (SMC_MUST_ALIGN_WRITE(priv))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(priv, 0, 2));	\
-		else if (SMC_CAN_USE_8BIT)				\
+		else if (SMC_8BIT(priv))				\
 			SMC_outb(x, ioaddr, PN_REG(priv));		\
 		else							\
 			SMC_outw(x, ioaddr, PN_REG(priv));		\
 	} while (0)
 
 #define SMC_GET_AR(priv)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, AR_REG(priv)))	\
+	(SMC_8BIT(priv)	? (SMC_inb(ioaddr, AR_REG(priv)))	\
 				: (SMC_inw(ioaddr, PN_REG(priv)) >> 8))
 
 #define SMC_GET_TXFIFO(priv)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, TXFIFO_REG(priv)))	\
+	(SMC_8BIT(priv)	? (SMC_inb(ioaddr, TXFIFO_REG(priv)))	\
 				: (SMC_inw(ioaddr, TXFIFO_REG(priv)) & 0xFF))
 
 #define SMC_GET_RXFIFO(priv)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, RXFIFO_REG(priv)))	\
+	(SMC_8BIT(priv)	? (SMC_inb(ioaddr, RXFIFO_REG(priv)))	\
 				: (SMC_inw(ioaddr, TXFIFO_REG(priv)) >> 8))
 
 #define SMC_GET_INT(priv)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, INT_REG(priv)))	\
+	(SMC_8BIT(priv)	? (SMC_inb(ioaddr, INT_REG(priv)))	\
 				: (SMC_inw(ioaddr, INT_REG(priv)) & 0xFF))
 
 #define SMC_ACK_INT(priv, x)						\
 	do {								\
-		if (SMC_CAN_USE_8BIT)					\
+		if (SMC_8BIT(priv))					\
 			SMC_outb(x, ioaddr, INT_REG(priv));		\
 		else {							\
 			unsigned long __flags;				\
@@ -1155,12 +1161,12 @@ static const char * chip_ids[ 16 ] =  {
 	} while (0)
 
 #define SMC_GET_INT_MASK(priv)						\
-	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, IM_REG(priv)))	\
+	(SMC_8BIT(priv)	? (SMC_inb(ioaddr, IM_REG(priv)))	\
 				: (SMC_inw(ioaddr, INT_REG(priv)) >> 8))
 
 #define SMC_SET_INT_MASK(priv, x)					\
 	do {								\
-		if (SMC_CAN_USE_8BIT)					\
+		if (SMC_8BIT(priv))					\
 			SMC_outb(x, ioaddr, IM_REG(priv));		\
 		else							\
 			SMC_outw((x) << 8, ioaddr, INT_REG(priv));	\
@@ -1170,7 +1176,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_SELECT_BANK(priv, x)					\
 	do {								\
-		if (SMC_MUST_ALIGN_WRITE)				\
+		if (SMC_MUST_ALIGN_WRITE(priv))				\
 			SMC_outl((x)<<16, ioaddr, 12<<SMC_IO_SHIFT);	\
 		else							\
 			SMC_outw(x, ioaddr, BANK_SELECT);		\
@@ -1208,7 +1214,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_SET_PTR(priv, x)						\
 	do {								\
-		if (SMC_MUST_ALIGN_WRITE)				\
+		if (SMC_MUST_ALIGN_WRITE(priv))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(priv, 4, 2));	\
 		else							\
 			SMC_outw(x, ioaddr, PTR_REG(priv));		\
@@ -1226,7 +1232,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_SET_RPC(priv, x)						\
 	do {								\
-		if (SMC_MUST_ALIGN_WRITE)				\
+		if (SMC_MUST_ALIGN_WRITE(priv))				\
 			SMC_outl((x)<<16, ioaddr, SMC_REG(priv, 8, 0));	\
 		else							\
 			SMC_outw(x, ioaddr, RPC_REG(priv));		\
@@ -1267,7 +1273,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_PUT_PKT_HDR(priv, status, length)				\
 	do {								\
-		if (SMC_CAN_USE_32BIT)					\
+		if (SMC_32BIT(priv))					\
 			SMC_outl((status) | (length)<<16, ioaddr,	\
 				 DATA_REG(priv));			\
 		else {							\
@@ -1278,7 +1284,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_GET_PKT_HDR(priv, status, length)				\
 	do {								\
-		if (SMC_CAN_USE_32BIT) {				\
+		if (SMC_32BIT(priv)) {				\
 			unsigned int __val = SMC_inl(ioaddr, DATA_REG(priv)); \
 			(status) = __val & 0xffff;			\
 			(length) = __val >> 16;				\
@@ -1290,7 +1296,7 @@ static const char * chip_ids[ 16 ] =  {
 
 #define SMC_PUSH_DATA(priv, p, l)					\
 	do {								\
-		if (SMC_CAN_USE_32BIT) {				\
+		if (SMC_32BIT(priv)) {				\
 			void *__ptr = (p);				\
 			int __len = (l);				\
 			void __iomem *__ioaddr = ioaddr;		\
@@ -1308,15 +1314,15 @@ static const char * chip_ids[ 16 ] =  {
 				SMC_outw(*((u16 *)__ptr), ioaddr,	\
 					 DATA_REG(priv));		\
 			}						\
-		} else if (SMC_CAN_USE_16BIT)				\
+		} else if (SMC_16BIT(priv))				\
 			SMC_outsw(ioaddr, DATA_REG(priv), p, (l) >> 1);	\
-		else if (SMC_CAN_USE_8BIT)				\
+		else if (SMC_8BIT(priv))				\
 			SMC_outsb(ioaddr, DATA_REG(priv), p, l);	\
 	} while (0)
 
 #define SMC_PULL_DATA(priv, p, l)					\
 	do {								\
-		if (SMC_CAN_USE_32BIT) {				\
+		if (SMC_32BIT(priv)) {				\
 			void *__ptr = (p);				\
 			int __len = (l);				\
 			void __iomem *__ioaddr = ioaddr;		\
@@ -1343,9 +1349,9 @@ static const char * chip_ids[ 16 ] =  {
 				__ioaddr = lp->datacs;			\
 			__len += 2;					\
 			SMC_insl(__ioaddr, DATA_REG(priv), __ptr, __len>>2); \
-		} else if (SMC_CAN_USE_16BIT)				\
+		} else if (SMC_16BIT(priv))				\
 			SMC_insw(ioaddr, DATA_REG(priv), p, (l) >> 1);	\
-		else if (SMC_CAN_USE_8BIT)				\
+		else if (SMC_8BIT(priv))				\
 			SMC_insb(ioaddr, DATA_REG(priv), p, l);		\
 	} while (0)
 
--- /dev/null
+++ work/include/linux/smc91x.h	2008-02-20 17:04:41.000000000 +0900
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
