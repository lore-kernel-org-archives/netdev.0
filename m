From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 19/39] sc92031: stop using net_device.{base_addr, irq}
Date: Fri,  6 Apr 2012 12:06:33 +0200
Message-ID: <2f236cba12a738e3ba82bf49e43047013d1f913e.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43444 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755841Ab2DFKKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:37 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/silan/sc92031.c |   34 +++++++++++-----------------------
 1 files changed, 11 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
index a284d64..32e5566 100644
--- a/drivers/net/ethernet/silan/sc92031.c
+++ b/drivers/net/ethernet/silan/sc92031.c
@@ -39,9 +39,7 @@
 #define SC92031_NAME "sc92031"
 
 /* BAR 0 is MMIO, BAR 1 is PIO */
-#ifndef SC92031_USE_BAR
-#define SC92031_USE_BAR 0
-#endif
+#define SC92031_USE_PIO	0
 
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast). */
 static int multicast_filter_limit = 64;
@@ -366,7 +364,7 @@ static void sc92031_disable_interrupts(struct net_device *dev)
 	mmiowb();
 
 	/* wait for any concurrent interrupt/tasklet to finish */
-	synchronize_irq(dev->irq);
+	synchronize_irq(priv->pdev->irq);
 	tasklet_disable(&priv->tasklet);
 }
 
@@ -1114,10 +1112,13 @@ static void sc92031_tx_timeout(struct net_device *dev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void sc92031_poll_controller(struct net_device *dev)
 {
-	disable_irq(dev->irq);
-	if (sc92031_interrupt(dev->irq, dev) != IRQ_NONE)
+	struct sc92031_priv *priv = netdev_priv(dev);
+	const int irq = priv->pdev->irq;
+
+	disable_irq(irq);
+	if (sc92031_interrupt(irq, dev) != IRQ_NONE)
 		sc92031_tasklet((unsigned long)dev);
-	enable_irq(dev->irq);
+	enable_irq(irq);
 }
 #endif
 
@@ -1402,7 +1403,6 @@ static int __devinit sc92031_probe(struct pci_dev *pdev,
 	struct net_device *dev;
 	struct sc92031_priv *priv;
 	u32 mac0, mac1;
-	unsigned long base_addr;
 
 	err = pci_enable_device(pdev);
 	if (unlikely(err < 0))
@@ -1422,7 +1422,7 @@ static int __devinit sc92031_probe(struct pci_dev *pdev,
 	if (unlikely(err < 0))
 		goto out_request_regions;
 
-	port_base = pci_iomap(pdev, SC92031_USE_BAR, 0);
+	port_base = pci_iomap(pdev, SC92031_USE_PIO, 0);
 	if (unlikely(!port_base)) {
 		err = -EIO;
 		goto out_iomap;
@@ -1437,14 +1437,6 @@ static int __devinit sc92031_probe(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-#if SC92031_USE_BAR == 0
-	dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);
-	dev->mem_end = pci_resource_end(pdev, SC92031_USE_BAR);
-#elif SC92031_USE_BAR == 1
-	dev->base_addr = pci_resource_start(pdev, SC92031_USE_BAR);
-#endif
-	dev->irq = pdev->irq;
-
 	/* faked with skb_copy_and_csum_dev */
 	dev->features = NETIF_F_SG | NETIF_F_HIGHDMA |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
@@ -1478,13 +1470,9 @@ static int __devinit sc92031_probe(struct pci_dev *pdev,
 	if (err < 0)
 		goto out_register_netdev;
 
-#if SC92031_USE_BAR == 0
-	base_addr = dev->mem_start;
-#elif SC92031_USE_BAR == 1
-	base_addr = dev->base_addr;
-#endif
 	printk(KERN_INFO "%s: SC92031 at 0x%lx, %pM, IRQ %d\n", dev->name,
-			base_addr, dev->dev_addr, dev->irq);
+	       (long)pci_resource_start(pdev, SC92031_USE_PIO), dev->dev_addr,
+	       pdev->irq);
 
 	return 0;
 
-- 
1.7.7.6
