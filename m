From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] dl2k: Implement suspend
Date: Mon, 16 Nov 2015 23:41:51 +0100
Message-ID: <1447713711-32471-1-git-send-email-linux@rainbow-software.org>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.gsystem.sk ([62.176.172.50]:52733 "EHLO gsystem.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413AbbKPWmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2015 17:42:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add suspend/resume support to dl2k driver.
Tested on Asus NX1101 (IP1000A) and D-Link DGE-550T (DL-2000).

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/dlink/dl2k.c |  189 +++++++++++++++++++++++++------------
 1 file changed, 128 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index ccca479..23d13c5 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -253,19 +253,6 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_out_unmap_rx;
 
-	if (np->chip_id == CHIP_IP1000A &&
-	    (np->pdev->revision == 0x40 || np->pdev->revision == 0x41)) {
-		/* PHY magic taken from ipg driver, undocumented registers */
-		mii_write(dev, np->phy_addr, 31, 0x0001);
-		mii_write(dev, np->phy_addr, 27, 0x01e0);
-		mii_write(dev, np->phy_addr, 31, 0x0002);
-		mii_write(dev, np->phy_addr, 27, 0xeb8e);
-		mii_write(dev, np->phy_addr, 31, 0x0000);
-		mii_write(dev, np->phy_addr, 30, 0x005e);
-		/* advertise 1000BASE-T half & full duplex, prefer MASTER */
-		mii_write(dev, np->phy_addr, MII_CTRL1000, 0x0700);
-	}
-
 	/* Fiber device? */
 	np->phy_media = (dr16(ASICCtrl) & PhyMedia) ? 1 : 0;
 	np->link_status = 0;
@@ -275,13 +262,11 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	 	if (np->an_enable == 2) {
 			np->an_enable = 1;
 		}
-		mii_set_media_pcs (dev);
 	} else {
 		/* Auto-Negotiation is mandatory for 1000BASE-T,
 		   IEEE 802.3ab Annex 28D page 14 */
 		if (np->speed == 1000)
 			np->an_enable = 1;
-		mii_set_media (dev);
 	}
 
 	err = register_netdev (dev);
@@ -446,19 +431,13 @@ static void rio_set_led_mode(struct net_device *dev)
 	dw32(ASICCtrl, mode);
 }
 
-static int
-rio_open (struct net_device *dev)
+static void rio_hw_init(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
-	const int irq = np->pdev->irq;
 	int i;
 	u16 macctrl;
 
-	i = request_irq(irq, rio_interrupt, IRQF_SHARED, dev->name, dev);
-	if (i)
-		return i;
-
 	/* Reset all logic functions */
 	dw16(ASICCtrl + 2,
 	     GlobalReset | DMAReset | FIFOReset | NetworkReset | HostReset);
@@ -469,11 +448,31 @@ rio_open (struct net_device *dev)
 	/* DebugCtrl bit 4, 5, 9 must set */
 	dw32(DebugCtrl, dr32(DebugCtrl) | 0x0230);
 
+	if (np->chip_id == CHIP_IP1000A &&
+	    (np->pdev->revision == 0x40 || np->pdev->revision == 0x41)) {
+		/* PHY magic taken from ipg driver, undocumented registers */
+		mii_write(dev, np->phy_addr, 31, 0x0001);
+		mii_write(dev, np->phy_addr, 27, 0x01e0);
+		mii_write(dev, np->phy_addr, 31, 0x0002);
+		mii_write(dev, np->phy_addr, 27, 0xeb8e);
+		mii_write(dev, np->phy_addr, 31, 0x0000);
+		mii_write(dev, np->phy_addr, 30, 0x005e);
+		/* advertise 1000BASE-T half & full duplex, prefer MASTER */
+		mii_write(dev, np->phy_addr, MII_CTRL1000, 0x0700);
+	}
+
+	if (np->phy_media)
+		mii_set_media_pcs(dev);
+	else
+		mii_set_media(dev);
+
 	/* Jumbo frame */
 	if (np->jumbo != 0)
 		dw16(MaxFrameSize, MAX_JUMBO+14);
 
-	alloc_list (dev);
+	/* Set RFDListPtr */
+	dw32(RFDListPtr0, np->rx_ring_dma);
+	dw32(RFDListPtr1, 0);
 
 	/* Set station address */
 	/* 16 or 32-bit access is required by TC9020 datasheet but 8-bit works
@@ -493,8 +492,6 @@ rio_open (struct net_device *dev)
 	dw8(RxDMABurstThresh, 0x30);
 	dw8(RxDMAUrgentThresh, 0x30);
 	dw32(RmonStatMask, 0x0007ffff);
-	/* clear statistics */
-	clear_stats (dev);
 
 	/* VLAN supported */
 	if (np->vlan) {
@@ -509,10 +506,6 @@ rio_open (struct net_device *dev)
 		dw32(MACCtrl, dr32(MACCtrl) | AutoVLANuntagging);
 	}
 
-	setup_timer(&np->timer, rio_timer, (unsigned long)dev);
-	np->timer.expires = jiffies + 1*HZ;
-	add_timer (&np->timer);
-
 	/* Start Tx/Rx */
 	dw32(MACCtrl, dr32(MACCtrl) | StatsEnable | RxEnable | TxEnable);
 
@@ -522,6 +515,28 @@ rio_open (struct net_device *dev)
 	macctrl |= (np->tx_flow) ? TxFlowControlEnable : 0;
 	macctrl |= (np->rx_flow) ? RxFlowControlEnable : 0;
 	dw16(MACCtrl, macctrl);
+}
+
+static int rio_open(struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	const int irq = np->pdev->irq;
+	int i;
+
+	i = request_irq(irq, rio_interrupt, IRQF_SHARED, dev->name, dev);
+	if (i)
+		return i;
+
+	alloc_list(dev);
+
+	rio_hw_init(dev);
+
+	/* clear statistics */
+	clear_stats(dev);
+
+	setup_timer(&np->timer, rio_timer, (unsigned long)dev);
+	np->timer.expires = jiffies + 1 * HZ;
+	add_timer(&np->timer);
 
 	netif_start_queue (dev);
 
@@ -591,7 +606,6 @@ static void
 alloc_list (struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
-	void __iomem *ioaddr = np->ioaddr;
 	int i;
 
 	np->cur_rx = np->cur_tx = 0;
@@ -634,10 +648,40 @@ alloc_list (struct net_device *dev)
 				  PCI_DMA_FROMDEVICE));
 		np->rx_ring[i].fraginfo |= cpu_to_le64((u64)np->rx_buf_sz << 48);
 	}
+}
 
-	/* Set RFDListPtr */
-	dw32(RFDListPtr0, np->rx_ring_dma);
-	dw32(RFDListPtr1, 0);
+static inline dma_addr_t desc_to_dma(struct netdev_desc *desc)
+{
+	return le64_to_cpu(desc->fraginfo) & DMA_BIT_MASK(48);
+}
+
+static void free_list(struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	struct sk_buff *skb;
+	int i;
+
+	/* Free all the skbuffs in the queue. */
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		skb = np->rx_skbuff[i];
+		if (skb) {
+			pci_unmap_single(np->pdev, desc_to_dma(&np->rx_ring[i]),
+					 skb->len, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(skb);
+			np->rx_skbuff[i] = NULL;
+		}
+		np->rx_ring[i].status = 0;
+		np->rx_ring[i].fraginfo = 0;
+	}
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		skb = np->tx_skbuff[i];
+		if (skb) {
+			pci_unmap_single(np->pdev, desc_to_dma(&np->tx_ring[i]),
+					 skb->len, PCI_DMA_TODEVICE);
+			dev_kfree_skb(skb);
+			np->tx_skbuff[i] = NULL;
+		}
+	}
 }
 
 static netdev_tx_t
@@ -748,11 +792,6 @@ rio_interrupt (int irq, void *dev_instance)
 	return IRQ_RETVAL(handled);
 }
 
-static inline dma_addr_t desc_to_dma(struct netdev_desc *desc)
-{
-	return le64_to_cpu(desc->fraginfo) & DMA_BIT_MASK(48);
-}
-
 static void
 rio_free_tx (struct net_device *dev, int irq)
 {
@@ -1733,8 +1772,6 @@ rio_close (struct net_device *dev)
 	void __iomem *ioaddr = np->ioaddr;
 
 	struct pci_dev *pdev = np->pdev;
-	struct sk_buff *skb;
-	int i;
 
 	netif_stop_queue (dev);
 
@@ -1747,27 +1784,7 @@ rio_close (struct net_device *dev)
 	free_irq(pdev->irq, dev);
 	del_timer_sync (&np->timer);
 
-	/* Free all the skbuffs in the queue. */
-	for (i = 0; i < RX_RING_SIZE; i++) {
-		skb = np->rx_skbuff[i];
-		if (skb) {
-			pci_unmap_single(pdev, desc_to_dma(&np->rx_ring[i]),
-					 skb->len, PCI_DMA_FROMDEVICE);
-			dev_kfree_skb (skb);
-			np->rx_skbuff[i] = NULL;
-		}
-		np->rx_ring[i].status = 0;
-		np->rx_ring[i].fraginfo = 0;
-	}
-	for (i = 0; i < TX_RING_SIZE; i++) {
-		skb = np->tx_skbuff[i];
-		if (skb) {
-			pci_unmap_single(pdev, desc_to_dma(&np->tx_ring[i]),
-					 skb->len, PCI_DMA_TODEVICE);
-			dev_kfree_skb (skb);
-			np->tx_skbuff[i] = NULL;
-		}
-	}
+	free_list(dev);
 
 	return 0;
 }
@@ -1795,11 +1812,61 @@ rio_remove1 (struct pci_dev *pdev)
 	}
 }
 
+#ifdef CONFIG_PM
+static int rio_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
+
+	pci_save_state(pdev);
+
+	if (netif_running(dev)) {
+		netif_device_detach(dev);
+		del_timer_sync(&np->timer);
+		/* Disable interrupts */
+		dw16(IntEnable, 0);
+		/* Stop Tx and Rx logics */
+		dw32(MACCtrl, TxDisable | RxDisable | StatsDisable);
+		free_list(dev);
+	}
+
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
+}
+
+static int rio_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct netdev_private *np = netdev_priv(dev);
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+
+	if (netif_running(dev)) {
+		alloc_list(dev);
+		rio_hw_init(dev);
+		np->timer.expires = jiffies + 1 * HZ;
+		add_timer(&np->timer);
+		netif_device_attach(dev);
+		dl2k_enable_int(np);
+	}
+
+	return 0;
+}
+
+#endif /* CONFIG_PM */
+
 static struct pci_driver rio_driver = {
 	.name		= "dl2k",
 	.id_table	= rio_pci_tbl,
 	.probe		= rio_probe1,
 	.remove		= rio_remove1,
+#ifdef CONFIG_PM
+	.suspend	= rio_suspend,
+	.resume		= rio_resume,
+#endif /* CONFIG_PM */
 };
 
 module_pci_driver(rio_driver);
-- 
Ondrej Zary
