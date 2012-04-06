From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 38/39] ipw2100: stop using net_device.base_addr.
Date: Fri,  6 Apr 2012 12:06:52 +0200
Message-ID: <a37b4503ec92e71e5bba6f64ffd2b524deab1b84.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43483 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756031Ab2DFKKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:40 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No net_device.irq removal yet. The driver probe, remove and failure
paths need some care beforehand.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>
---
 drivers/net/wireless/ipw2x00/ipw2100.c |   77 ++++++++++++++++----------------
 drivers/net/wireless/ipw2x00/ipw2100.h |    1 +
 2 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index f0551f8..3352993 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -343,38 +343,50 @@ static struct iw_handler_def ipw2100_wx_handler_def;
 
 static inline void read_register(struct net_device *dev, u32 reg, u32 * val)
 {
-	*val = readl((void __iomem *)(dev->base_addr + reg));
+	struct ipw2100_priv *priv = libipw_priv(dev);
+
+	*val = ioread32(priv->ioaddr + reg);
 	IPW_DEBUG_IO("r: 0x%08X => 0x%08X\n", reg, *val);
 }
 
 static inline void write_register(struct net_device *dev, u32 reg, u32 val)
 {
-	writel(val, (void __iomem *)(dev->base_addr + reg));
+	struct ipw2100_priv *priv = libipw_priv(dev);
+
+	iowrite32(val, priv->ioaddr + reg);
 	IPW_DEBUG_IO("w: 0x%08X <= 0x%08X\n", reg, val);
 }
 
 static inline void read_register_word(struct net_device *dev, u32 reg,
 				      u16 * val)
 {
-	*val = readw((void __iomem *)(dev->base_addr + reg));
+	struct ipw2100_priv *priv = libipw_priv(dev);
+
+	*val = ioread16(priv->ioaddr + reg);
 	IPW_DEBUG_IO("r: 0x%08X => %04X\n", reg, *val);
 }
 
 static inline void read_register_byte(struct net_device *dev, u32 reg, u8 * val)
 {
-	*val = readb((void __iomem *)(dev->base_addr + reg));
+	struct ipw2100_priv *priv = libipw_priv(dev);
+
+	*val = ioread8(priv->ioaddr + reg);
 	IPW_DEBUG_IO("r: 0x%08X => %02X\n", reg, *val);
 }
 
 static inline void write_register_word(struct net_device *dev, u32 reg, u16 val)
 {
-	writew(val, (void __iomem *)(dev->base_addr + reg));
+	struct ipw2100_priv *priv = libipw_priv(dev);
+
+	iowrite16(val, priv->ioaddr + reg);
 	IPW_DEBUG_IO("w: 0x%08X <= %04X\n", reg, val);
 }
 
 static inline void write_register_byte(struct net_device *dev, u32 reg, u8 val)
 {
-	writeb(val, (void __iomem *)(dev->base_addr + reg));
+	struct ipw2100_priv *priv = libipw_priv(dev);
+
+	iowrite8(val, priv->ioaddr + reg);
 	IPW_DEBUG_IO("w: 0x%08X =< %02X\n", reg, val);
 }
 
@@ -506,13 +518,13 @@ static void read_nic_memory(struct net_device *dev, u32 addr, u32 len,
 		read_register_byte(dev, IPW_REG_INDIRECT_ACCESS_DATA + i, buf);
 }
 
-static inline int ipw2100_hw_is_adapter_in_system(struct net_device *dev)
+static bool ipw2100_hw_is_adapter_in_system(struct net_device *dev)
 {
-	return (dev->base_addr &&
-		(readl
-		 ((void __iomem *)(dev->base_addr +
-				   IPW_REG_DOA_DEBUG_AREA_START))
-		 == IPW_DATA_DOA_DEBUG_VALUE));
+	u32 dbg;
+
+	read_register(dev, IPW_REG_DOA_DEBUG_AREA_START, &dbg);
+
+	return dbg == IPW_DATA_DOA_DEBUG_VALUE;
 }
 
 static int ipw2100_get_ordinal(struct ipw2100_priv *priv, u32 ord,
@@ -6082,9 +6094,7 @@ static const struct net_device_ops ipw2100_netdev_ops = {
 /* Look into using netdev destructor to shutdown libipw? */
 
 static struct net_device *ipw2100_alloc_device(struct pci_dev *pci_dev,
-					       void __iomem * base_addr,
-					       unsigned long mem_start,
-					       unsigned long mem_len)
+					       void __iomem * ioaddr)
 {
 	struct ipw2100_priv *priv;
 	struct net_device *dev;
@@ -6096,6 +6106,7 @@ static struct net_device *ipw2100_alloc_device(struct pci_dev *pci_dev,
 	priv->ieee = netdev_priv(dev);
 	priv->pci_dev = pci_dev;
 	priv->net_dev = dev;
+	priv->ioaddr = ioaddr;
 
 	priv->ieee->hard_start_xmit = ipw2100_tx;
 	priv->ieee->set_security = shim__set_security;
@@ -6111,10 +6122,6 @@ static struct net_device *ipw2100_alloc_device(struct pci_dev *pci_dev,
 	dev->watchdog_timeo = 3 * HZ;
 	dev->irq = 0;
 
-	dev->base_addr = (unsigned long)base_addr;
-	dev->mem_start = mem_start;
-	dev->mem_end = dev->mem_start + mem_len - 1;
-
 	/* NOTE: We don't use the wireless_handlers hook
 	 * in dev as the system will start throwing WX requests
 	 * to us before we're actually initialized and it just
@@ -6215,8 +6222,7 @@ static struct net_device *ipw2100_alloc_device(struct pci_dev *pci_dev,
 static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 				const struct pci_device_id *ent)
 {
-	unsigned long mem_start, mem_len, mem_flags;
-	void __iomem *base_addr = NULL;
+	void __iomem *ioaddr;
 	struct net_device *dev = NULL;
 	struct ipw2100_priv *priv = NULL;
 	int err = 0;
@@ -6225,18 +6231,14 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 
 	IPW_DEBUG_INFO("enter\n");
 
-	mem_start = pci_resource_start(pci_dev, 0);
-	mem_len = pci_resource_len(pci_dev, 0);
-	mem_flags = pci_resource_flags(pci_dev, 0);
-
-	if ((mem_flags & IORESOURCE_MEM) != IORESOURCE_MEM) {
+	if (!(pci_resource_flags(pci_dev, 0) & IORESOURCE_MEM)) {
 		IPW_DEBUG_INFO("weird - resource type is not memory\n");
 		err = -ENODEV;
-		goto fail;
+		goto out;
 	}
 
-	base_addr = ioremap_nocache(mem_start, mem_len);
-	if (!base_addr) {
+	ioaddr = pci_iomap(pci_dev, 0, 0);
+	if (!ioaddr) {
 		printk(KERN_WARNING DRV_NAME
 		       "Error calling ioremap_nocache.\n");
 		err = -EIO;
@@ -6244,7 +6246,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 	}
 
 	/* allocate and initialize our net_device */
-	dev = ipw2100_alloc_device(pci_dev, base_addr, mem_start, mem_len);
+	dev = ipw2100_alloc_device(pci_dev, ioaddr);
 	if (!dev) {
 		printk(KERN_WARNING DRV_NAME
 		       "Error calling ipw2100_alloc_device.\n");
@@ -6379,8 +6381,8 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 	priv->status |= STATUS_INITIALIZED;
 
 	mutex_unlock(&priv->action_mutex);
-
-	return 0;
+out:
+	return err;
 
       fail_unlock:
 	mutex_unlock(&priv->action_mutex);
@@ -6409,13 +6411,11 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 		pci_set_drvdata(pci_dev, NULL);
 	}
 
-	if (base_addr)
-		iounmap(base_addr);
+	pci_iounmap(pci_dev, ioaddr);
 
 	pci_release_regions(pci_dev);
 	pci_disable_device(pci_dev);
-
-	return err;
+	goto out;
 }
 
 static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
@@ -6458,8 +6458,7 @@ static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
 		if (dev->irq)
 			free_irq(dev->irq, priv);
 
-		if (dev->base_addr)
-			iounmap((void __iomem *)dev->base_addr);
+		pci_iounmap(pci_dev, priv->ioaddr);
 
 		/* wiphy_unregister needs to be here, before free_libipw */
 		wiphy_unregister(priv->ieee->wdev.wiphy);
@@ -8609,7 +8608,7 @@ static int ipw2100_ucode_download(struct ipw2100_priv *priv,
 	struct net_device *dev = priv->net_dev;
 	const unsigned char *microcode_data = fw->uc.data;
 	unsigned int microcode_data_left = fw->uc.size;
-	void __iomem *reg = (void __iomem *)dev->base_addr;
+	void __iomem *reg = priv->ioaddr;
 
 	struct symbol_alive_response response;
 	int i, j;
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.h b/drivers/net/wireless/ipw2x00/ipw2100.h
index 99cba96..e5b1c77 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.h
+++ b/drivers/net/wireless/ipw2x00/ipw2100.h
@@ -488,6 +488,7 @@ enum {
 #define CAP_PRIVACY_ON          (1<<1)	/* Off = No privacy */
 
 struct ipw2100_priv {
+	void __iomem *ioaddr;
 
 	int stop_hang_check;	/* Set 1 when shutting down to kill hang_check */
 	int stop_rf_kill;	/* Set 1 when shutting down to kill rf_kill */
-- 
1.7.7.6
