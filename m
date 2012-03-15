From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 18/34] winbond840: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:15 +0100
Message-ID: <0f2b180e691fa543beb6179a429d4efa59a791df.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51856 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761115Ab2CON7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:46 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/dec/tulip/winbond-840.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 2ac6fff..4d1ffca 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -400,9 +400,6 @@ static int __devinit w840_probe1 (struct pci_dev *pdev,
 	   No hold time required! */
 	iowrite32(0x00000001, ioaddr + PCIBusCfg);
 
-	dev->base_addr = (unsigned long)ioaddr;
-	dev->irq = irq;
-
 	np = netdev_priv(dev);
 	np->pci_dev = pdev;
 	np->chip_id = chip_idx;
@@ -635,17 +632,18 @@ static int netdev_open(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->base_addr;
+	const int irq = np->pci_dev->irq;
 	int i;
 
 	iowrite32(0x00000001, ioaddr + PCIBusCfg);		/* Reset */
 
 	netif_device_detach(dev);
-	i = request_irq(dev->irq, intr_handler, IRQF_SHARED, dev->name, dev);
+	i = request_irq(irq, intr_handler, IRQF_SHARED, dev->name, dev);
 	if (i)
 		goto out_err;
 
 	if (debug > 1)
-		netdev_dbg(dev, "w89c840_open() irq %d\n", dev->irq);
+		netdev_dbg(dev, "w89c840_open() irq %d\n", irq);
 
 	if((i=alloc_ringdesc(dev)))
 		goto out_err;
@@ -932,6 +930,7 @@ static void tx_timeout(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->base_addr;
+	const int irq = np->pci_dev->irq;
 
 	dev_warn(&dev->dev, "Transmit timed out, status %08x, resetting...\n",
 		 ioread32(ioaddr + IntrStatus));
@@ -951,7 +950,7 @@ static void tx_timeout(struct net_device *dev)
 	       np->cur_tx, np->dirty_tx, np->tx_full, np->tx_q_bytes);
 	printk(KERN_DEBUG "Tx Descriptor addr %xh\n", ioread32(ioaddr+0x4C));
 
-	disable_irq(dev->irq);
+	disable_irq(irq);
 	spin_lock_irq(&np->lock);
 	/*
 	 * Under high load dirty_tx and the internal tx descriptor pointer
@@ -966,7 +965,7 @@ static void tx_timeout(struct net_device *dev)
 	init_rxtx_rings(dev);
 	init_registers(dev);
 	spin_unlock_irq(&np->lock);
-	enable_irq(dev->irq);
+	enable_irq(irq);
 
 	netif_wake_queue(dev);
 	dev->trans_start = jiffies; /* prevent tx timeout */
@@ -1500,7 +1499,7 @@ static int netdev_close(struct net_device *dev)
 	iowrite32(0x0000, ioaddr + IntrEnable);
 	spin_unlock_irq(&np->lock);
 
-	free_irq(dev->irq, dev);
+	free_irq(np->pci_dev->irq, dev);
 	wmb();
 	netif_device_attach(dev);
 
@@ -1589,7 +1588,7 @@ static int w840_suspend (struct pci_dev *pdev, pm_message_t state)
 		iowrite32(0, ioaddr + IntrEnable);
 		spin_unlock_irq(&np->lock);
 
-		synchronize_irq(dev->irq);
+		synchronize_irq(np->pci_dev->irq);
 		netif_tx_disable(dev);
 
 		np->stats.rx_missed_errors += ioread32(ioaddr + RxMissed) & 0xffff;
-- 
1.7.7.6
