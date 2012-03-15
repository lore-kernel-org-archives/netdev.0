From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 32/34] epic100: stop using net_device.{base_addr, irq} and convert to __iomem.
Date: Thu, 15 Mar 2012 14:57:29 +0100
Message-ID: <3d526697eb55c30b9eaa8e003519ae22cbb97f59.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51875 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761123Ab2CON7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:51 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/smsc/epic100.c |  145 ++++++++++++++++++-----------------
 1 files changed, 73 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 2a662e6..408fd0c 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -146,6 +146,12 @@ enum chip_capability_flags { MII_PWRDWN=1, TYPE2_INTR=2, NO_MII=4 };
 #define EPIC_TOTAL_SIZE 0x100
 #define USE_IO_OPS 1
 
+#ifdef USE_IO_OPS
+#define EPIC_BAR	0
+#else
+#define EPIC_BAR	1
+#endif
+
 typedef enum {
 	SMSC_83C170_0,
 	SMSC_83C170,
@@ -177,20 +183,12 @@ static DEFINE_PCI_DEVICE_TABLE(epic_pci_tbl) = {
 MODULE_DEVICE_TABLE (pci, epic_pci_tbl);
 
 
-#ifndef USE_IO_OPS
-#undef inb
-#undef inw
-#undef inl
-#undef outb
-#undef outw
-#undef outl
 #define inb readb
 #define inw readw
 #define inl readl
 #define outb writeb
 #define outw writew
 #define outl writel
-#endif
 
 /* Offsets to registers, using the (ugh) SMC names. */
 enum epic_registers {
@@ -275,6 +273,7 @@ struct epic_private {
 	u32 irq_mask;
 	unsigned int rx_buf_sz;				/* Based on MTU+slack. */
 
+	void __iomem *ioaddr;
 	struct pci_dev *pci_dev;			/* PCI bus location. */
 	int chip_id, chip_flags;
 
@@ -290,7 +289,7 @@ struct epic_private {
 };
 
 static int epic_open(struct net_device *dev);
-static int read_eeprom(long ioaddr, int location);
+static int read_eeprom(void __iomem *, int location);
 static int mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int loc, int val);
 static void epic_restart(struct net_device *dev);
@@ -322,10 +321,10 @@ static const struct net_device_ops epic_netdev_ops = {
 };
 
 static int __devinit epic_init_one (struct pci_dev *pdev,
-				    const struct pci_device_id *ent)
+			    const struct pci_device_id *ent)
 {
 	static int card_idx = -1;
-	long ioaddr;
+	void __iomem *ioaddr;
 	int chip_idx = (int) ent->driver_data;
 	int irq;
 	struct net_device *dev;
@@ -368,19 +367,15 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-#ifdef USE_IO_OPS
-	ioaddr = pci_resource_start (pdev, 0);
-#else
-	ioaddr = pci_resource_start (pdev, 1);
-	ioaddr = (long) pci_ioremap_bar(pdev, 1);
+	ioaddr = pci_iomap(pdev, EPIC_BAR, 0);
 	if (!ioaddr) {
 		dev_err(&pdev->dev, "ioremap failed\n");
 		goto err_out_free_netdev;
 	}
-#endif
 
 	pci_set_drvdata(pdev, dev);
 	ep = netdev_priv(dev);
+	ep->ioaddr = ioaddr;
 	ep->mii.dev = dev;
 	ep->mii.mdio_read = mdio_read;
 	ep->mii.mdio_write = mdio_write;
@@ -409,9 +404,6 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 			duplex = full_duplex[card_idx];
 	}
 
-	dev->base_addr = ioaddr;
-	dev->irq = irq;
-
 	spin_lock_init(&ep->lock);
 	spin_lock_init(&ep->napi_lock);
 	ep->reschedule_in_poll = 0;
@@ -501,8 +493,8 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 	if (ret < 0)
 		goto err_out_unmap_rx;
 
-	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, %pM\n",
-	       dev->name, pci_id_tbl[chip_idx].name, ioaddr, dev->irq,
+	printk(KERN_INFO "%s: %s at %p, IRQ %d, %pM\n",
+	       dev->name, pci_id_tbl[chip_idx].name, ioaddr, pdev->irq,
 	       dev->dev_addr);
 
 out:
@@ -513,10 +505,8 @@ err_out_unmap_rx:
 err_out_unmap_tx:
 	pci_free_consistent(pdev, TX_TOTAL_SIZE, ep->tx_ring, ep->tx_ring_dma);
 err_out_iounmap:
-#ifndef USE_IO_OPS
-	iounmap(ioaddr);
+	pci_iounmap(pdev, ioaddr);
 err_out_free_netdev:
-#endif
 	free_netdev(dev);
 err_out_free_res:
 	pci_release_regions(pdev);
@@ -550,12 +540,12 @@ err_out_disable:
 
 static void epic_disable_int(struct net_device *dev, struct epic_private *ep)
 {
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 
 	outl(0x00000000, ioaddr + INTMASK);
 }
 
-static inline void __epic_pci_commit(long ioaddr)
+static inline void __epic_pci_commit(void __iomem *ioaddr)
 {
 #ifndef USE_IO_OPS
 	inl(ioaddr + INTMASK);
@@ -565,7 +555,7 @@ static inline void __epic_pci_commit(long ioaddr)
 static inline void epic_napi_irq_off(struct net_device *dev,
 				     struct epic_private *ep)
 {
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 
 	outl(ep->irq_mask & ~EpicNapiEvent, ioaddr + INTMASK);
 	__epic_pci_commit(ioaddr);
@@ -574,17 +564,17 @@ static inline void epic_napi_irq_off(struct net_device *dev,
 static inline void epic_napi_irq_on(struct net_device *dev,
 				    struct epic_private *ep)
 {
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 
 	/* No need to commit possible posted write */
 	outl(ep->irq_mask | EpicNapiEvent, ioaddr + INTMASK);
 }
 
-static int __devinit read_eeprom(long ioaddr, int location)
+static int __devinit read_eeprom(void __iomem *ioaddr, int location)
 {
+	void __iomem *ee_addr = ioaddr + EECTL;
 	int i;
 	int retval = 0;
-	long ee_addr = ioaddr + EECTL;
 	int read_cmd = location |
 		(inl(ee_addr) & 0x40 ? EE_READ64_CMD : EE_READ256_CMD);
 
@@ -618,7 +608,8 @@ static int __devinit read_eeprom(long ioaddr, int location)
 #define MII_WRITEOP		2
 static int mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 	int read_cmd = (phy_id << 9) | (location << 4) | MII_READOP;
 	int i;
 
@@ -641,7 +632,8 @@ static int mdio_read(struct net_device *dev, int phy_id, int location)
 
 static void mdio_write(struct net_device *dev, int phy_id, int loc, int value)
 {
-	long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 	int i;
 
 	outw(value, ioaddr + MIIData);
@@ -657,17 +649,18 @@ static void mdio_write(struct net_device *dev, int phy_id, int loc, int value)
 static int epic_open(struct net_device *dev)
 {
 	struct epic_private *ep = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
-	int i;
-	int retval;
+	void __iomem *ioaddr = ep->ioaddr;
+	const int irq = ep->pci_dev->irq;
+	int rc, i;
 
 	/* Soft reset the chip. */
 	outl(0x4001, ioaddr + GENCTL);
 
 	napi_enable(&ep->napi);
-	if ((retval = request_irq(dev->irq, epic_interrupt, IRQF_SHARED, dev->name, dev))) {
+	rc = request_irq(irq, epic_interrupt, IRQF_SHARED, dev->name, dev);
+	if (rc < 0) {
 		napi_disable(&ep->napi);
-		return retval;
+		return rc;
 	}
 
 	epic_init_ring(dev);
@@ -746,11 +739,12 @@ static int epic_open(struct net_device *dev)
 		 | CntFull | TxUnderrun
 		 | RxError | RxHeader | EpicNapiEvent, ioaddr + INTMASK);
 
-	if (debug > 1)
-		printk(KERN_DEBUG "%s: epic_open() ioaddr %lx IRQ %d status %4.4x "
-			   "%s-duplex.\n",
-			   dev->name, ioaddr, dev->irq, (int)inl(ioaddr + GENCTL),
-			   ep->mii.full_duplex ? "full" : "half");
+	if (debug > 1) {
+		printk(KERN_DEBUG "%s: epic_open() ioaddr %p IRQ %d "
+		       "status %4.4x %s-duplex.\n",
+		       dev->name, ioaddr, irq, (int)inl(ioaddr + GENCTL),
+		       ep->mii.full_duplex ? "full" : "half");
+	}
 
 	/* Set the timer to switch to check for link beat and perhaps switch
 	   to an alternate media type. */
@@ -760,14 +754,15 @@ static int epic_open(struct net_device *dev)
 	ep->timer.function = epic_timer;				/* timer handler */
 	add_timer(&ep->timer);
 
-	return 0;
+	return rc;
 }
 
 /* Reset the chip to recover from a PCI transaction error.
    This may occur at interrupt time. */
 static void epic_pause(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 
 	netif_stop_queue (dev);
 
@@ -789,8 +784,8 @@ static void epic_pause(struct net_device *dev)
 
 static void epic_restart(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 	int i;
 
 	/* Soft reset the chip. */
@@ -842,7 +837,7 @@ static void epic_restart(struct net_device *dev)
 static void check_media(struct net_device *dev)
 {
 	struct epic_private *ep = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 	int mii_lpa = ep->mii_phy_cnt ? mdio_read(dev, ep->phys[0], MII_LPA) : 0;
 	int negotiated = mii_lpa & ep->mii.advertising;
 	int duplex = (negotiated & 0x0100) || (negotiated & 0x01C0) == 0x0040;
@@ -864,7 +859,7 @@ static void epic_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
 	struct epic_private *ep = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 	int next_tick = 5*HZ;
 
 	if (debug > 3) {
@@ -885,7 +880,7 @@ static void epic_timer(unsigned long data)
 static void epic_tx_timeout(struct net_device *dev)
 {
 	struct epic_private *ep = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 
 	if (debug > 0) {
 		printk(KERN_WARNING "%s: Transmit timeout using MII device, "
@@ -901,7 +896,7 @@ static void epic_tx_timeout(struct net_device *dev)
 		outl(RestartTx, ioaddr + COMMAND);
 	} else {
 		epic_restart(dev);
-		outl(TxQueued, dev->base_addr + COMMAND);
+		outl(TxQueued, ioaddr + COMMAND);
 	}
 
 	dev->trans_start = jiffies; /* prevent tx timeout */
@@ -959,6 +954,7 @@ static void epic_init_ring(struct net_device *dev)
 static netdev_tx_t epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 	int entry, free_count;
 	u32 ctrl_word;
 	unsigned long flags;
@@ -999,13 +995,13 @@ static netdev_tx_t epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&ep->lock, flags);
 	/* Trigger an immediate transmit demand. */
-	outl(TxQueued, dev->base_addr + COMMAND);
+	outl(TxQueued, ioaddr + COMMAND);
 
 	if (debug > 4)
 		printk(KERN_DEBUG "%s: Queued Tx packet size %d to slot %d, "
 			   "flag %2.2x Tx status %8.8x.\n",
 			   dev->name, (int)skb->len, entry, ctrl_word,
-			   (int)inl(dev->base_addr + TxSTAT));
+			   (int)inl(ioaddr + TxSTAT));
 
 	return NETDEV_TX_OK;
 }
@@ -1086,7 +1082,7 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct epic_private *ep = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 	unsigned int handled = 0;
 	int status;
 
@@ -1248,7 +1244,7 @@ static int epic_rx(struct net_device *dev, int budget)
 
 static void epic_rx_err(struct net_device *dev, struct epic_private *ep)
 {
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 	int status;
 
 	status = inl(ioaddr + INTSTAT);
@@ -1266,7 +1262,7 @@ static int epic_poll(struct napi_struct *napi, int budget)
 	struct epic_private *ep = container_of(napi, struct epic_private, napi);
 	struct net_device *dev = ep->mii.dev;
 	int work_done = 0;
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 
 rx_action:
 
@@ -1303,8 +1299,9 @@ rx_action:
 
 static int epic_close(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct epic_private *ep = netdev_priv(dev);
+	struct pci_dev *pdev = ep->pci_dev;
+	void __iomem *ioaddr = ep->ioaddr;
 	struct sk_buff *skb;
 	int i;
 
@@ -1319,7 +1316,7 @@ static int epic_close(struct net_device *dev)
 
 	epic_disable_int(dev, ep);
 
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 
 	epic_pause(dev);
 
@@ -1330,7 +1327,7 @@ static int epic_close(struct net_device *dev)
 		ep->rx_ring[i].rxstatus = 0;		/* Not owned by Epic chip. */
 		ep->rx_ring[i].buflength = 0;
 		if (skb) {
-			pci_unmap_single(ep->pci_dev, ep->rx_ring[i].bufaddr,
+			pci_unmap_single(pdev, ep->rx_ring[i].bufaddr,
 				 	 ep->rx_buf_sz, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(skb);
 		}
@@ -1341,8 +1338,8 @@ static int epic_close(struct net_device *dev)
 		ep->tx_skbuff[i] = NULL;
 		if (!skb)
 			continue;
-		pci_unmap_single(ep->pci_dev, ep->tx_ring[i].bufaddr,
-				 skb->len, PCI_DMA_TODEVICE);
+		pci_unmap_single(pdev, ep->tx_ring[i].bufaddr, skb->len,
+				 PCI_DMA_TODEVICE);
 		dev_kfree_skb(skb);
 	}
 
@@ -1354,7 +1351,8 @@ static int epic_close(struct net_device *dev)
 
 static struct net_device_stats *epic_get_stats(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 
 	if (netif_running(dev)) {
 		/* Update the error counts. */
@@ -1373,8 +1371,8 @@ static struct net_device_stats *epic_get_stats(struct net_device *dev)
 
 static void set_rx_mode(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 	unsigned char mc_filter[8];		 /* Multicast hash filter */
 	int i;
 
@@ -1466,9 +1464,11 @@ static void netdev_set_msglevel(struct net_device *dev, u32 value)
 
 static int ethtool_begin(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
+
 	/* power-up, if interface is down */
-	if (! netif_running(dev)) {
+	if (!netif_running(dev)) {
 		outl(0x0200, ioaddr + GENCTL);
 		outl((inl(ioaddr + NVCTL) & ~0x003C) | 0x4800, ioaddr + NVCTL);
 	}
@@ -1477,9 +1477,11 @@ static int ethtool_begin(struct net_device *dev)
 
 static void ethtool_complete(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
+
 	/* power-down, if interface is down */
-	if (! netif_running(dev)) {
+	if (!netif_running(dev)) {
 		outl(0x0008, ioaddr + GENCTL);
 		outl((inl(ioaddr + NVCTL) & ~0x483C) | 0x0000, ioaddr + NVCTL);
 	}
@@ -1500,7 +1502,7 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct epic_private *np = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = np->ioaddr;
 	struct mii_ioctl_data *data = if_mii(rq);
 	int rc;
 
@@ -1524,7 +1526,7 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 }
 
 
-static void __devexit epic_remove_one (struct pci_dev *pdev)
+static void __devexit epic_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct epic_private *ep = netdev_priv(dev);
@@ -1532,9 +1534,7 @@ static void __devexit epic_remove_one (struct pci_dev *pdev)
 	pci_free_consistent(pdev, TX_TOTAL_SIZE, ep->tx_ring, ep->tx_ring_dma);
 	pci_free_consistent(pdev, RX_TOTAL_SIZE, ep->rx_ring, ep->rx_ring_dma);
 	unregister_netdev(dev);
-#ifndef USE_IO_OPS
-	iounmap((void*) dev->base_addr);
-#endif
+	pci_iounmap(pdev, ep->ioaddr);
 	pci_release_regions(pdev);
 	free_netdev(dev);
 	pci_disable_device(pdev);
@@ -1548,7 +1548,8 @@ static void __devexit epic_remove_one (struct pci_dev *pdev)
 static int epic_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 
 	if (!netif_running(dev))
 		return 0;
-- 
1.7.7.6
