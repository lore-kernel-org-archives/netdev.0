From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 14/34] yellowfin: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:11 +0100
Message-ID: <63922b8838b7905c42491d8aa93edeb6d9297633.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51843 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760929Ab2CON7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:44 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/packetengines/yellowfin.c |   32 ++++++++++-------------
 1 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index 7757b80..cf5f54b 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -427,9 +427,6 @@ static int __devinit yellowfin_init_one(struct pci_dev *pdev,
 	/* Reset the chip. */
 	iowrite32(0x80000000, ioaddr + DMACtrl);
 
-	dev->base_addr = (unsigned long)ioaddr;
-	dev->irq = irq;
-
 	pci_set_drvdata(pdev, dev);
 	spin_lock_init(&np->lock);
 
@@ -569,25 +566,20 @@ static void mdio_write(void __iomem *ioaddr, int phy_id, int location, int value
 static int yellowfin_open(struct net_device *dev)
 {
 	struct yellowfin_private *yp = netdev_priv(dev);
+	const int irq = yp->pci_dev->irq;
 	void __iomem *ioaddr = yp->base;
-	int i, ret;
+	int i, rc;
 
 	/* Reset the chip. */
 	iowrite32(0x80000000, ioaddr + DMACtrl);
 
-	ret = request_irq(dev->irq, yellowfin_interrupt, IRQF_SHARED, dev->name, dev);
-	if (ret)
-		return ret;
-
-	if (yellowfin_debug > 1)
-		netdev_printk(KERN_DEBUG, dev, "%s() irq %d\n",
-			      __func__, dev->irq);
+	rc = request_irq(irq, yellowfin_interrupt, IRQF_SHARED, dev->name, dev);
+	if (rc < 0)
+		goto out;
 
-	ret = yellowfin_init_ring(dev);
-	if (ret) {
-		free_irq(dev->irq, dev);
-		return ret;
-	}
+	rc = yellowfin_init_ring(dev);
+	if (rc < 0)
+		goto err_free_irq;
 
 	iowrite32(yp->rx_ring_dma, ioaddr + RxPtr);
 	iowrite32(yp->tx_ring_dma, ioaddr + TxPtr);
@@ -647,8 +639,12 @@ static int yellowfin_open(struct net_device *dev)
 	yp->timer.data = (unsigned long)dev;
 	yp->timer.function = yellowfin_timer;				/* timer handler */
 	add_timer(&yp->timer);
+out:
+	return rc;
 
-	return 0;
+err_free_irq:
+	free_irq(irq, dev);
+	goto out;
 }
 
 static void yellowfin_timer(unsigned long data)
@@ -1251,7 +1247,7 @@ static int yellowfin_close(struct net_device *dev)
 	}
 #endif /* __i386__ debugging only */
 
-	free_irq(dev->irq, dev);
+	free_irq(yp->pci_dev->irq, dev);
 
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-- 
1.7.7.6
