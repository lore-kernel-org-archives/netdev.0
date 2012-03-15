From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 22/34] sunhme: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:19 +0100
Message-ID: <e8b3465856499347b5e223cdc82d724308ce99b1.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51861 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752752Ab2CON7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:46 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/sun/sunhme.c |   20 +++++++++-----------
 drivers/net/ethernet/sun/sunhme.h |    1 +
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 8b627e2..a470f38 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2183,13 +2183,14 @@ static int happy_meal_open(struct net_device *dev)
 	 * into a single source which we register handling at probe time.
 	 */
 	if ((hp->happy_flags & (HFLAG_QUATTRO|HFLAG_PCI)) != HFLAG_QUATTRO) {
-		if (request_irq(dev->irq, happy_meal_interrupt,
-				IRQF_SHARED, dev->name, (void *)dev)) {
+		res = request_irq(hp->irq, happy_meal_interrupt, IRQF_SHARED,
+				  dev->name, dev);
+		if (res < 0) {
 			HMD(("EAGAIN\n"));
 			printk(KERN_ERR "happy_meal(SBUS): Can't order irq %d to go.\n",
-			       dev->irq);
+			       hp->irq);
 
-			return -EAGAIN;
+			return res;
 		}
 	}
 
@@ -2200,7 +2201,7 @@ static int happy_meal_open(struct net_device *dev)
 	spin_unlock_irq(&hp->happy_lock);
 
 	if (res && ((hp->happy_flags & (HFLAG_QUATTRO|HFLAG_PCI)) != HFLAG_QUATTRO))
-		free_irq(dev->irq, dev);
+		free_irq(hp->irq, dev);
 	return res;
 }
 
@@ -2222,7 +2223,7 @@ static int happy_meal_close(struct net_device *dev)
 	 * time and never unregister.
 	 */
 	if ((hp->happy_flags & (HFLAG_QUATTRO|HFLAG_PCI)) != HFLAG_QUATTRO)
-		free_irq(dev->irq, dev);
+		free_irq(hp->irq, dev);
 
 	return 0;
 }
@@ -2778,7 +2779,7 @@ static int __devinit happy_meal_sbus_probe_one(struct platform_device *op, int i
 	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
 	dev->features |= dev->hw_features | NETIF_F_RXCSUM;
 
-	dev->irq = op->archdata.irqs[0];
+	hp->irq = op->archdata.irqs[0];
 
 #if defined(CONFIG_SBUS) && defined(CONFIG_PCI)
 	/* Hook up SBUS register/descriptor accessors. */
@@ -2982,8 +2983,6 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 	if (hme_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
 
-	dev->base_addr = (long) pdev;
-
 	hp = netdev_priv(dev);
 
 	hp->happy_dev = pdev;
@@ -3088,12 +3087,11 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 
 	init_timer(&hp->happy_timer);
 
+	hp->irq = pdev->irq;
 	hp->dev = dev;
 	dev->netdev_ops = &hme_netdev_ops;
 	dev->watchdog_timeo = 5*HZ;
 	dev->ethtool_ops = &hme_ethtool_ops;
-	dev->irq = pdev->irq;
-	dev->dma = 0;
 
 	/* Happy Meal can do it all... */
 	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
diff --git a/drivers/net/ethernet/sun/sunhme.h b/drivers/net/ethernet/sun/sunhme.h
index 64f2783..f430765 100644
--- a/drivers/net/ethernet/sun/sunhme.h
+++ b/drivers/net/ethernet/sun/sunhme.h
@@ -432,6 +432,7 @@ struct happy_meal {
 
 	dma_addr_t                hblock_dvma;    /* DVMA visible address happy block  */
 	unsigned int              happy_flags;    /* Driver state flags                */
+	int                       irq;
 	enum happy_transceiver    tcvr_type;      /* Kind of transceiver in use        */
 	unsigned int              happy_bursts;   /* Get your mind out of the gutter   */
 	unsigned int              paddr;          /* PHY address for transceiver       */
-- 
1.7.7.6
