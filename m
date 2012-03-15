From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 21/34] tulip_core: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:18 +0100
Message-ID: <62c6b5fe7ebcbc0d4b5c5ecdc92b9d82e4405b4c.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51887 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753775Ab2CON7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:54 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Grant Grundler <grundler@parisc-linux.org>
---
 drivers/net/ethernet/dec/tulip/tulip_core.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index fea3641..25fe117 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -328,7 +328,7 @@ static void tulip_up(struct net_device *dev)
 	udelay(100);
 
 	if (tulip_debug > 1)
-		netdev_dbg(dev, "tulip_up(), irq==%d\n", dev->irq);
+		netdev_dbg(dev, "tulip_up(), irq==%d\n", tp->pdev->irq);
 
 	iowrite32(tp->rx_ring_dma, ioaddr + CSR3);
 	iowrite32(tp->tx_ring_dma, ioaddr + CSR4);
@@ -515,11 +515,13 @@ media_picked:
 static int
 tulip_open(struct net_device *dev)
 {
+	struct tulip_private *tp = netdev_priv(dev);
 	int retval;
 
 	tulip_init_ring (dev);
 
-	retval = request_irq(dev->irq, tulip_interrupt, IRQF_SHARED, dev->name, dev);
+	retval = request_irq(tp->pdev->irq, tulip_interrupt, IRQF_SHARED,
+			     dev->name, dev);
 	if (retval)
 		goto free_ring;
 
@@ -841,7 +843,7 @@ static int tulip_close (struct net_device *dev)
 		netdev_dbg(dev, "Shutting down ethercard, status was %02x\n",
 			   ioread32 (ioaddr + CSR5));
 
-	free_irq (dev->irq, dev);
+	free_irq (tp->pdev->irq, dev);
 
 	tulip_free_ring (dev);
 
@@ -1489,8 +1491,6 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 
 	INIT_WORK(&tp->media_work, tulip_tbl[tp->chip_id].media_task);
 
-	dev->base_addr = (unsigned long)ioaddr;
-
 #ifdef CONFIG_TULIP_MWI
 	if (!force_csr0 && (tp->flags & HAS_PCI_MWI))
 		tulip_mwi_config (pdev, dev);
@@ -1650,7 +1650,6 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	for (i = 0; i < 6; i++)
 		last_phys_addr[i] = dev->dev_addr[i];
 	last_irq = irq;
-	dev->irq = irq;
 
 	/* The lower four bits are the media type. */
 	if (board_idx >= 0  &&  board_idx < MAX_UNITS) {
@@ -1858,7 +1857,8 @@ static int tulip_suspend (struct pci_dev *pdev, pm_message_t state)
 	tulip_down(dev);
 
 	netif_device_detach(dev);
-	free_irq(dev->irq, dev);
+	/* FIXME: it needlessly adds an error path. */
+	free_irq(tp->pdev->irq, dev);
 
 save_state:
 	pci_save_state(pdev);
@@ -1900,7 +1900,9 @@ static int tulip_resume(struct pci_dev *pdev)
 		return retval;
 	}
 
-	if ((retval = request_irq(dev->irq, tulip_interrupt, IRQF_SHARED, dev->name, dev))) {
+	retval = request_irq(pdev->irq, tulip_interrupt, IRQF_SHARED,
+			     dev->name, dev);
+	if (retval < 0) {
 		pr_err("request_irq failed in resume\n");
 		return retval;
 	}
@@ -1960,11 +1962,14 @@ static void __devexit tulip_remove_one (struct pci_dev *pdev)
 
 static void poll_tulip (struct net_device *dev)
 {
+	struct tulip_private *tp = netdev_priv(dev);
+	const int irq = tp->pdev->irq;
+
 	/* disable_irq here is not very nice, but with the lockless
 	   interrupt handler we have no other choice. */
-	disable_irq(dev->irq);
-	tulip_interrupt (dev->irq, dev);
-	enable_irq(dev->irq);
+	disable_irq(irq);
+	tulip_interrupt (irq, dev);
+	enable_irq(irq);
 }
 #endif
 
-- 
1.7.7.6
