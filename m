From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -next-2.6] ns83820: Use helper to disable chip interrupts
Date: Tue, 31 Aug 2010 07:19:15 +0000
Message-ID: <20100831071915.GA20970@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:58935 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932172Ab0HaHTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 03:19:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use helper routine to disable chip interrupts.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 5a3488f..447c2c4 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1405,6 +1405,13 @@ static const struct ethtool_ops ops = {
 	.get_link        = ns83820_get_link
 };
 
+static inline void ns83820_disable_interrupts(struct ns83820 *dev)
+{
+	writel(0, dev->base + IMR);
+	writel(0, dev->base + IER);
+	readl(dev->base + IER);
+}
+
 /* this function is called in irq context from the ISR */
 static void ns83820_mib_isr(struct ns83820 *dev)
 {
@@ -1557,10 +1564,7 @@ static int ns83820_stop(struct net_device *ndev)
 	/* FIXME: protect against interrupt handler? */
 	del_timer_sync(&dev->tx_watchdog);
 
-	/* disable interrupts */
-	writel(0, dev->base + IMR);
-	writel(0, dev->base + IER);
-	readl(dev->base + IER);
+	ns83820_disable_interrupts(dev);
 
 	dev->rx_info.up = 0;
 	synchronize_irq(dev->pci_dev->irq);
@@ -2023,10 +2027,7 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
 		dev->tx_descs, (long)dev->tx_phy_descs,
 		dev->rx_info.descs, (long)dev->rx_info.phy_descs);
 
-	/* disable interrupts */
-	writel(0, dev->base + IMR);
-	writel(0, dev->base + IER);
-	readl(dev->base + IER);
+	ns83820_disable_interrupts(dev);
 
 	dev->IMR_cache = 0;
 
@@ -2250,9 +2251,7 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
 	return 0;
 
 out_cleanup:
-	writel(0, dev->base + IMR);	/* paranoia */
-	writel(0, dev->base + IER);
-	readl(dev->base + IER);
+	ns83820_disable_interrupts(dev); /* paranoia */
 out_free_irq:
 	rtnl_unlock();
 	free_irq(pci_dev->irq, ndev);
@@ -2277,9 +2276,7 @@ static void __devexit ns83820_remove_one(struct pci_dev *pci_dev)
 	if (!ndev)			/* paranoia */
 		return;
 
-	writel(0, dev->base + IMR);	/* paranoia */
-	writel(0, dev->base + IER);
-	readl(dev->base + IER);
+	ns83820_disable_interrupts(dev); /* paranoia */
 
 	unregister_netdev(ndev);
 	free_irq(dev->pci_dev->irq, ndev);
