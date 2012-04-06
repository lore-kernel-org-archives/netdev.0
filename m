From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 27/39] smsc9420: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:41 +0200
Message-ID: <722b2708e6b621a33fe8f778ea35e1f0ddb4636a.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43480 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756011Ab2DFKKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:39 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device private data pointer can not be NULL in smsc9420_open().

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/ethernet/smsc/smsc9420.c |   48 ++++++++++++++++-----------------
 1 files changed, 23 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index f80ec68..292753f 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -54,7 +54,7 @@ struct smsc9420_ring_info {
 };
 
 struct smsc9420_pdata {
-	void __iomem *base_addr;
+	void __iomem *ioaddr;
 	struct pci_dev *pdev;
 	struct net_device *dev;
 
@@ -114,13 +114,13 @@ do {	if ((pd)->msg_enable & NETIF_MSG_##TYPE) \
 
 static inline u32 smsc9420_reg_read(struct smsc9420_pdata *pd, u32 offset)
 {
-	return ioread32(pd->base_addr + offset);
+	return ioread32(pd->ioaddr + offset);
 }
 
 static inline void
 smsc9420_reg_write(struct smsc9420_pdata *pd, u32 offset, u32 value)
 {
-	iowrite32(value, pd->base_addr + offset);
+	iowrite32(value, pd->ioaddr + offset);
 }
 
 static inline void smsc9420_pci_flush_write(struct smsc9420_pdata *pd)
@@ -660,7 +660,7 @@ static irqreturn_t smsc9420_isr(int irq, void *dev_id)
 	ulong flags;
 
 	BUG_ON(!pd);
-	BUG_ON(!pd->base_addr);
+	BUG_ON(!pd->ioaddr);
 
 	int_cfg = smsc9420_reg_read(pd, INT_CFG);
 
@@ -721,9 +721,12 @@ static irqreturn_t smsc9420_isr(int irq, void *dev_id)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void smsc9420_poll_controller(struct net_device *dev)
 {
-	disable_irq(dev->irq);
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	const int irq = pd->pdev->irq;
+
+	disable_irq(irq);
 	smsc9420_isr(0, dev);
-	enable_irq(dev->irq);
+	enable_irq(irq);
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
@@ -760,7 +763,7 @@ static int smsc9420_stop(struct net_device *dev)
 	smsc9420_stop_rx(pd);
 	smsc9420_free_rx_ring(pd);
 
-	free_irq(dev->irq, pd);
+	free_irq(pd->pdev->irq, pd);
 
 	smsc9420_dmac_soft_reset(pd);
 
@@ -1332,15 +1335,12 @@ out:
 
 static int smsc9420_open(struct net_device *dev)
 {
-	struct smsc9420_pdata *pd;
+	struct smsc9420_pdata *pd = netdev_priv(dev);
 	u32 bus_mode, mac_cr, dmac_control, int_cfg, dma_intr_ena, int_ctl;
+	const int irq = pd->pdev->irq;
 	unsigned long flags;
 	int result = 0, timeout;
 
-	BUG_ON(!dev);
-	pd = netdev_priv(dev);
-	BUG_ON(!pd);
-
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		smsc_warn(IFUP, "dev_addr is not a valid MAC address");
 		result = -EADDRNOTAVAIL;
@@ -1359,10 +1359,10 @@ static int smsc9420_open(struct net_device *dev)
 	smsc9420_reg_write(pd, INT_STAT, 0xFFFFFFFF);
 	smsc9420_pci_flush_write(pd);
 
-	if (request_irq(dev->irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
-			DRV_NAME, pd)) {
-		smsc_warn(IFUP, "Unable to use IRQ = %d", dev->irq);
-		result = -ENODEV;
+	result = request_irq(irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
+			     DRV_NAME, pd);
+	if (result < 0) {
+		smsc_warn(IFUP, "Unable to use IRQ = %d", irq);
 		goto out_0;
 	}
 
@@ -1396,7 +1396,7 @@ static int smsc9420_open(struct net_device *dev)
 	smsc9420_pci_flush_write(pd);
 
 	/* test the IRQ connection to the ISR */
-	smsc_dbg(IFUP, "Testing ISR using IRQ %d", dev->irq);
+	smsc_dbg(IFUP, "Testing ISR using IRQ %d", irq);
 	pd->software_irq_signal = false;
 
 	spin_lock_irqsave(&pd->int_lock, flags);
@@ -1431,7 +1431,7 @@ static int smsc9420_open(struct net_device *dev)
 		goto out_free_irq_1;
 	}
 
-	smsc_dbg(IFUP, "ISR passed test using IRQ %d", dev->irq);
+	smsc_dbg(IFUP, "ISR passed test using IRQ %d", irq);
 
 	result = smsc9420_alloc_tx_ring(pd);
 	if (result) {
@@ -1491,7 +1491,7 @@ out_free_rx_ring_3:
 out_free_tx_ring_2:
 	smsc9420_free_tx_ring(pd);
 out_free_irq_1:
-	free_irq(dev->irq, pd);
+	free_irq(irq, pd);
 out_0:
 	return result;
 }
@@ -1520,7 +1520,7 @@ static int smsc9420_suspend(struct pci_dev *pdev, pm_message_t state)
 		smsc9420_stop_rx(pd);
 		smsc9420_free_rx_ring(pd);
 
-		free_irq(dev->irq, pd);
+		free_irq(pd->pdev->irq, pd);
 
 		netif_device_detach(dev);
 	}
@@ -1553,6 +1553,7 @@ static int smsc9420_resume(struct pci_dev *pdev)
 		smsc_warn(IFUP, "pci_enable_wake failed: %d", err);
 
 	if (netif_running(dev)) {
+		/* FIXME: gross. It looks like ancient PM relic.*/
 		err = smsc9420_open(dev);
 		netif_device_attach(dev);
 	}
@@ -1626,8 +1627,6 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	/* registers are double mapped with 0 offset for LE and 0x200 for BE */
 	virt_addr += LAN9420_CPSR_ENDIAN_OFFSET;
 
-	dev->base_addr = (ulong)virt_addr;
-
 	pd = netdev_priv(dev);
 
 	/* pci descriptors are created in the PCI consistent area */
@@ -1647,7 +1646,7 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	pd->pdev = pdev;
 	pd->dev = dev;
-	pd->base_addr = virt_addr;
+	pd->ioaddr = virt_addr;
 	pd->msg_enable = smsc_debug;
 	pd->rx_csum = true;
 
@@ -1670,7 +1669,6 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	dev->netdev_ops = &smsc9420_netdev_ops;
 	dev->ethtool_ops = &smsc9420_ethtool_ops;
-	dev->irq = pdev->irq;
 
 	netif_napi_add(dev, &pd->napi, smsc9420_rx_poll, NAPI_WEIGHT);
 
@@ -1728,7 +1726,7 @@ static void __devexit smsc9420_remove(struct pci_dev *pdev)
 	pci_free_consistent(pdev, sizeof(struct smsc9420_dma_desc) *
 		(RX_RING_SIZE + TX_RING_SIZE), pd->rx_ring, pd->rx_dma_addr);
 
-	iounmap(pd->base_addr - LAN9420_CPSR_ENDIAN_OFFSET);
+	iounmap(pd->ioaddr - LAN9420_CPSR_ENDIAN_OFFSET);
 	pci_release_regions(pdev);
 	free_netdev(dev);
 	pci_disable_device(pdev);
-- 
1.7.7.6
