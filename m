From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 2/6] smsc911x: add dynamic bus configuration
Date: Wed,  5 Nov 2008 10:35:38 +0000
Message-ID: <1225881342-3485-3-git-send-email-steve.glendinning@smsc.com>
References: <1225881342-3485-1-git-send-email-steve.glendinning@smsc.com>
 <1225881342-3485-2-git-send-email-steve.glendinning@smsc.com>
Cc: catalin.marinas@arm.com, Bahadir.Balban@arm.com,
	dustin@sensoria.com, bgat@billgatliff.com,
	Ian Saturley <ian.saturley@smsc.com>, g.liakhovetski@gmx.de,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:57483 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754247AbYKEKfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 05:35:51 -0500
In-Reply-To: <1225881342-3485-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the driver to select 16-bit or 32-bit bus access at runtime,
at a small performance cost.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c   |  158 +++++++++++++++++++++++-----------------------
 drivers/net/smsc911x.h   |    1 -
 include/linux/smsc911x.h |    5 ++
 3 files changed, 84 insertions(+), 80 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index fe51788..4b8ff84 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -77,19 +77,16 @@ struct smsc911x_data {
 	unsigned int generation;
 
 	/* device configuration (copied from platform_data during probe) */
-	unsigned int irq_polarity;
-	unsigned int irq_type;
-	phy_interface_t phy_interface;
+	struct smsc911x_platform_config config;
 
 	/* This needs to be acquired before calling any of below:
 	 * smsc911x_mac_read(), smsc911x_mac_write()
 	 */
 	spinlock_t mac_lock;
 
-#if (!SMSC_CAN_USE_32BIT)
-	/* spinlock to ensure 16-bit accesses are serialised */
+	/* spinlock to ensure 16-bit accesses are serialised.
+	 * unused with a 32-bit bus */
 	spinlock_t dev_lock;
-#endif
 
 	struct phy_device *phy_dev;
 	struct mii_bus *mii_bus;
@@ -121,70 +118,56 @@ struct smsc911x_data {
 	unsigned int hashlo;
 };
 
-#if SMSC_CAN_USE_32BIT
-
-static inline u32 smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
-{
-	return readl(pdata->ioaddr + reg);
-}
-
-static inline void smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
-				      u32 val)
-{
-	writel(val, pdata->ioaddr + reg);
-}
-
-/* Writes a packet to the TX_DATA_FIFO */
-static inline void
-smsc911x_tx_writefifo(struct smsc911x_data *pdata, unsigned int *buf,
-		      unsigned int wordcount)
-{
-	writesl(pdata->ioaddr + TX_DATA_FIFO, buf, wordcount);
-}
-
-/* Reads a packet out of the RX_DATA_FIFO */
-static inline void
-smsc911x_rx_readfifo(struct smsc911x_data *pdata, unsigned int *buf,
-		     unsigned int wordcount)
-{
-	readsl(pdata->ioaddr + RX_DATA_FIFO, buf, wordcount);
-}
-
-#else				/* SMSC_CAN_USE_32BIT */
-
-/* These 16-bit access functions are significantly slower, due to the locking
+/* The 16-bit access functions are significantly slower, due to the locking
  * necessary.  If your bus hardware can be configured to do this for you
  * (in response to a single 32-bit operation from software), you should use
  * the 32-bit access functions instead. */
 
 static inline u32 smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
 {
-	unsigned long flags;
-	u32 data;
-
-	/* these two 16-bit reads must be performed consecutively, so must
-	 * not be interrupted by our own ISR (which would start another
-	 * read operation) */
-	spin_lock_irqsave(&pdata->dev_lock, flags);
-	data = ((readw(pdata->ioaddr + reg) & 0xFFFF) |
-		((readw(pdata->ioaddr + reg + 2) & 0xFFFF) << 16));
-	spin_unlock_irqrestore(&pdata->dev_lock, flags);
+	if (pdata->config.flags & SMSC911X_USE_32BIT)
+		return readl(pdata->ioaddr + reg);
+
+	if (pdata->config.flags & SMSC911X_USE_16BIT) {
+		u32 data;
+		unsigned long flags;
+
+		/* these two 16-bit reads must be performed consecutively, so
+		 * must not be interrupted by our own ISR (which would start
+		 * another read operation) */
+		spin_lock_irqsave(&pdata->dev_lock, flags);
+		data = ((readw(pdata->ioaddr + reg) & 0xFFFF) |
+			((readw(pdata->ioaddr + reg + 2) & 0xFFFF) << 16));
+		spin_unlock_irqrestore(&pdata->dev_lock, flags);
+
+		return data;
+	}
 
-	return data;
+	BUG();
 }
 
 static inline void smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
 				      u32 val)
 {
-	unsigned long flags;
+	if (pdata->config.flags & SMSC911X_USE_32BIT) {
+		writel(val, pdata->ioaddr + reg);
+		return;
+	}
+
+	if (pdata->config.flags & SMSC911X_USE_16BIT) {
+		unsigned long flags;
+
+		/* these two 16-bit writes must be performed consecutively, so
+		 * must not be interrupted by our own ISR (which would start
+		 * another read operation) */
+		spin_lock_irqsave(&pdata->dev_lock, flags);
+		writew(val & 0xFFFF, pdata->ioaddr + reg);
+		writew((val >> 16) & 0xFFFF, pdata->ioaddr + reg + 2);
+		spin_unlock_irqrestore(&pdata->dev_lock, flags);
+		return;
+	}
 
-	/* these two 16-bit writes must be performed consecutively, so must
-	 * not be interrupted by our own ISR (which would start another
-	 * read operation) */
-	spin_lock_irqsave(&pdata->dev_lock, flags);
-	writew(val & 0xFFFF, pdata->ioaddr + reg);
-	writew((val >> 16) & 0xFFFF, pdata->ioaddr + reg + 2);
-	spin_unlock_irqrestore(&pdata->dev_lock, flags);
+	BUG();
 }
 
 /* Writes a packet to the TX_DATA_FIFO */
@@ -192,8 +175,18 @@ static inline void
 smsc911x_tx_writefifo(struct smsc911x_data *pdata, unsigned int *buf,
 		      unsigned int wordcount)
 {
-	while (wordcount--)
-		smsc911x_reg_write(pdata, TX_DATA_FIFO, *buf++);
+	if (pdata->config.flags & SMSC911X_USE_32BIT) {
+		writesl(pdata->ioaddr + TX_DATA_FIFO, buf, wordcount);
+		return;
+	}
+
+	if (pdata->config.flags & SMSC911X_USE_16BIT) {
+		while (wordcount--)
+			smsc911x_reg_write(pdata, TX_DATA_FIFO, *buf++);
+		return;
+	}
+
+	BUG();
 }
 
 /* Reads a packet out of the RX_DATA_FIFO */
@@ -201,11 +194,19 @@ static inline void
 smsc911x_rx_readfifo(struct smsc911x_data *pdata, unsigned int *buf,
 		     unsigned int wordcount)
 {
-	while (wordcount--)
-		*buf++ = smsc911x_reg_read(pdata, RX_DATA_FIFO);
-}
+	if (pdata->config.flags & SMSC911X_USE_32BIT) {
+		readsl(pdata->ioaddr + RX_DATA_FIFO, buf, wordcount);
+		return;
+	}
 
-#endif				/* SMSC_CAN_USE_32BIT */
+	if (pdata->config.flags & SMSC911X_USE_16BIT) {
+		while (wordcount--)
+			*buf++ = smsc911x_reg_read(pdata, RX_DATA_FIFO);
+		return;
+	}
+
+	BUG();
+}
 
 /* waits for MAC not busy, with timeout.  Only called by smsc911x_mac_read
  * and smsc911x_mac_write, so assumes mac_lock is held */
@@ -790,7 +791,7 @@ static int smsc911x_mii_probe(struct net_device *dev)
 	}
 
 	phydev = phy_connect(dev, phydev->dev.bus_id,
-		&smsc911x_phy_adjust_link, 0, pdata->phy_interface);
+		&smsc911x_phy_adjust_link, 0, pdata->config.phy_interface);
 
 	if (IS_ERR(phydev)) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
@@ -1205,14 +1206,14 @@ static int smsc911x_open(struct net_device *dev)
 	/* Set interrupt deassertion to 100uS */
 	intcfg = ((10 << 24) | INT_CFG_IRQ_EN_);
 
-	if (pdata->irq_polarity) {
+	if (pdata->config.irq_polarity) {
 		SMSC_TRACE(IFUP, "irq polarity: active high");
 		intcfg |= INT_CFG_IRQ_POL_;
 	} else {
 		SMSC_TRACE(IFUP, "irq polarity: active low");
 	}
 
-	if (pdata->irq_type) {
+	if (pdata->config.irq_type) {
 		SMSC_TRACE(IFUP, "irq type: push-pull");
 		intcfg |= INT_CFG_IRQ_TYPE_;
 	} else {
@@ -1767,9 +1768,7 @@ static int __devinit smsc911x_init(struct net_device *dev)
 	SMSC_TRACE(PROBE, "IRQ: %d", dev->irq);
 	SMSC_TRACE(PROBE, "PHY will be autodetected.");
 
-#if (!SMSC_CAN_USE_32BIT)
 	spin_lock_init(&pdata->dev_lock);
-#endif
 
 	if (pdata->ioaddr == 0) {
 		SMSC_WARNING(PROBE, "pdata->ioaddr: 0x00000000");
@@ -1910,6 +1909,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct smsc911x_data *pdata;
+	struct smsc911x_platform_config *config = pdev->dev.platform_data;
 	struct resource *res;
 	unsigned int intcfg = 0;
 	int res_size;
@@ -1918,6 +1918,13 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	pr_info("%s: Driver version %s.\n", SMSC_CHIPNAME, SMSC_DRV_VERSION);
 
+	/* platform data specifies irq & dynamic bus configuration */
+	if (!pdev->dev.platform_data) {
+		pr_warning("%s: platform_data not provided\n", SMSC_CHIPNAME);
+		retval = -ENODEV;
+		goto out_0;
+	}
+
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
 					   "smsc911x-memory");
 	if (!res)
@@ -1949,15 +1956,8 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	dev->irq = platform_get_irq(pdev, 0);
 	pdata->ioaddr = ioremap_nocache(res->start, res_size);
 
-	/* copy config parameters across if present, otherwise pdata
-	 * defaults to zeros */
-	if (pdev->dev.platform_data) {
-		struct smsc911x_platform_config *config =
-			pdev->dev.platform_data;
-		pdata->irq_polarity = config->irq_polarity;
-		pdata->irq_type  = config->irq_type;
-		pdata->phy_interface = config->phy_interface;
-	}
+	/* copy config parameters across to pdata */
+	memcpy(&pdata->config, config, sizeof(pdata->config));
 
 	pdata->dev = dev;
 	pdata->msg_enable = ((1 << debug) - 1);
@@ -1974,10 +1974,10 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 		goto out_unmap_io_3;
 
 	/* configure irq polarity and type before connecting isr */
-	if (pdata->irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
+	if (pdata->config.irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
 		intcfg |= INT_CFG_IRQ_POL_;
 
-	if (pdata->irq_type == SMSC911X_IRQ_TYPE_PUSH_PULL)
+	if (pdata->config.irq_type == SMSC911X_IRQ_TYPE_PUSH_PULL)
 		intcfg |= INT_CFG_IRQ_TYPE_;
 
 	smsc911x_reg_write(pdata, INT_CFG, intcfg);
diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
index feb36de..f818cf0 100644
--- a/drivers/net/smsc911x.h
+++ b/drivers/net/smsc911x.h
@@ -21,7 +21,6 @@
 #ifndef __SMSC911X_H__
 #define __SMSC911X_H__
 
-#define SMSC_CAN_USE_32BIT	1
 #define TX_FIFO_LOW_THRESHOLD	((u32)1600)
 #define SMSC911X_EEPROM_SIZE	((u32)7)
 #define USE_DEBUG		0
diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
index 47c4ffd..1cbf031 100644
--- a/include/linux/smsc911x.h
+++ b/include/linux/smsc911x.h
@@ -28,6 +28,7 @@
 struct smsc911x_platform_config {
 	unsigned int irq_polarity;
 	unsigned int irq_type;
+	unsigned int flags;
 	phy_interface_t phy_interface;
 };
 
@@ -39,4 +40,8 @@ struct smsc911x_platform_config {
 #define SMSC911X_IRQ_TYPE_OPEN_DRAIN		0
 #define SMSC911X_IRQ_TYPE_PUSH_PULL		1
 
+/* Constants for flags */
+#define SMSC911X_USE_16BIT 			(BIT(0))
+#define SMSC911X_USE_32BIT 			(BIT(1))
+
 #endif /* __LINUX_SMSC911X_H__ */
-- 
1.5.6.5

