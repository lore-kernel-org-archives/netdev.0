From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 36/39] rrunner: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:50 +0200
Message-ID: <61deffedec0c150a7c09085ca91146d881a3e48e.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43464 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755967Ab2DFKKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:38 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/hippi/rrunner.c |   82 ++++++++++++++++++------------------------
 1 files changed, 35 insertions(+), 47 deletions(-)

diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 2a51363..248c4f1 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -114,10 +114,9 @@ static int __devinit rr_init_one(struct pci_dev *pdev,
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	if (pci_request_regions(pdev, "rrunner")) {
-		ret = -EIO;
+	ret = pci_request_regions(pdev, "rrunner");
+	if (ret < 0)
 		goto out;
-	}
 
 	pci_set_drvdata(pdev, dev);
 
@@ -125,11 +124,8 @@ static int __devinit rr_init_one(struct pci_dev *pdev,
 
 	spin_lock_init(&rrpriv->lock);
 
-	dev->irq = pdev->irq;
 	dev->netdev_ops = &rr_netdev_ops;
 
-	dev->base_addr = pci_resource_start(pdev, 0);
-
 	/* display version info if adapter is found */
 	if (!version_disp) {
 		/* set display flag to TRUE so that */
@@ -147,16 +143,14 @@ static int __devinit rr_init_one(struct pci_dev *pdev,
 	pci_set_master(pdev);
 
 	printk(KERN_INFO "%s: Essential RoadRunner serial HIPPI "
-	       "at 0x%08lx, irq %i, PCI latency %i\n", dev->name,
-	       dev->base_addr, dev->irq, pci_latency);
+	       "at 0x%08llx, irq %i, PCI latency %i\n", dev->name,
+	       pci_resource_start(pdev, 0), pdev->irq, pci_latency);
 
 	/*
-	 * Remap the regs into kernel space.
+	 * Remap the MMIO regs into kernel space.
 	 */
-
-	rrpriv->regs = ioremap(dev->base_addr, 0x1000);
-
-	if (!rrpriv->regs){
+	rrpriv->regs = pci_iomap(pdev, 0, 0x1000);
+	if (!rrpriv->regs) {
 		printk(KERN_ERR "%s:  Unable to map I/O register, "
 			"RoadRunner will be disabled.\n", dev->name);
 		ret = -EIO;
@@ -203,8 +197,6 @@ static int __devinit rr_init_one(struct pci_dev *pdev,
 
 	rr_init(dev);
 
-	dev->base_addr = 0;
-
 	ret = register_netdev(dev);
 	if (ret)
 		goto out;
@@ -218,7 +210,7 @@ static int __devinit rr_init_one(struct pci_dev *pdev,
 		pci_free_consistent(pdev, TX_TOTAL_SIZE, rrpriv->tx_ring,
 				    rrpriv->tx_ring_dma);
 	if (rrpriv->regs)
-		iounmap(rrpriv->regs);
+		pci_iounmap(pdev, rrpriv->regs);
 	if (pdev) {
 		pci_release_regions(pdev);
 		pci_set_drvdata(pdev, NULL);
@@ -232,29 +224,26 @@ static int __devinit rr_init_one(struct pci_dev *pdev,
 static void __devexit rr_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct rr_private *rr = netdev_priv(dev);
 
-	if (dev) {
-		struct rr_private *rr = netdev_priv(dev);
-
-		if (!(readl(&rr->regs->HostCtrl) & NIC_HALTED)){
-			printk(KERN_ERR "%s: trying to unload running NIC\n",
-			       dev->name);
-			writel(HALT_NIC, &rr->regs->HostCtrl);
-		}
-
-		pci_free_consistent(pdev, EVT_RING_SIZE, rr->evt_ring,
-				    rr->evt_ring_dma);
-		pci_free_consistent(pdev, RX_TOTAL_SIZE, rr->rx_ring,
-				    rr->rx_ring_dma);
-		pci_free_consistent(pdev, TX_TOTAL_SIZE, rr->tx_ring,
-				    rr->tx_ring_dma);
-		unregister_netdev(dev);
-		iounmap(rr->regs);
-		free_netdev(dev);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
+	if (!(readl(&rr->regs->HostCtrl) & NIC_HALTED)) {
+		printk(KERN_ERR "%s: trying to unload running NIC\n",
+		       dev->name);
+		writel(HALT_NIC, &rr->regs->HostCtrl);
 	}
+
+	unregister_netdev(dev);
+	pci_free_consistent(pdev, EVT_RING_SIZE, rr->evt_ring,
+			    rr->evt_ring_dma);
+	pci_free_consistent(pdev, RX_TOTAL_SIZE, rr->rx_ring,
+			    rr->rx_ring_dma);
+	pci_free_consistent(pdev, TX_TOTAL_SIZE, rr->tx_ring,
+			    rr->tx_ring_dma);
+	pci_iounmap(pdev, rr->regs);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(dev);
 }
 
 
@@ -1230,9 +1219,9 @@ static int rr_open(struct net_device *dev)
 	readl(&regs->HostCtrl);
 	spin_unlock_irqrestore(&rrpriv->lock, flags);
 
-	if (request_irq(dev->irq, rr_interrupt, IRQF_SHARED, dev->name, dev)) {
+	if (request_irq(pdev->irq, rr_interrupt, IRQF_SHARED, dev->name, dev)) {
 		printk(KERN_WARNING "%s: Requested IRQ %d is busy\n",
-		       dev->name, dev->irq);
+		       dev->name, pdev->irq);
 		ecode = -EAGAIN;
 		goto error;
 	}
@@ -1339,16 +1328,15 @@ static void rr_dump(struct net_device *dev)
 
 static int rr_close(struct net_device *dev)
 {
-	struct rr_private *rrpriv;
-	struct rr_regs __iomem *regs;
+	struct rr_private *rrpriv = netdev_priv(dev);
+	struct rr_regs __iomem *regs = rrpriv->regs;
+	struct pci_dev *pdev = rrpriv->pci_dev;
 	unsigned long flags;
 	u32 tmp;
 	short i;
 
 	netif_stop_queue(dev);
 
-	rrpriv = netdev_priv(dev);
-	regs = rrpriv->regs;
 
 	/*
 	 * Lock to make sure we are not cleaning up while another CPU
@@ -1387,15 +1375,15 @@ static int rr_close(struct net_device *dev)
 	rr_raz_tx(rrpriv, dev);
 	rr_raz_rx(rrpriv, dev);
 
-	pci_free_consistent(rrpriv->pci_dev, 256 * sizeof(struct ring_ctrl),
+	pci_free_consistent(pdev, 256 * sizeof(struct ring_ctrl),
 			    rrpriv->rx_ctrl, rrpriv->rx_ctrl_dma);
 	rrpriv->rx_ctrl = NULL;
 
-	pci_free_consistent(rrpriv->pci_dev, sizeof(struct rr_info),
-			    rrpriv->info, rrpriv->info_dma);
+	pci_free_consistent(pdev, sizeof(struct rr_info), rrpriv->info,
+			    rrpriv->info_dma);
 	rrpriv->info = NULL;
 
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 	spin_unlock_irqrestore(&rrpriv->lock, flags);
 
 	return 0;
-- 
1.7.7.6
