From: Bryan Wu <bryan.wu@canonical.com>
Subject: [PATCH] netdev/fec: fix ifconfig eth0 down hang issue
Date: Fri, 28 May 2010 17:08:05 +0800
Message-ID: <1275037685-14555-1-git-send-email-bryan.wu@canonical.com>
Cc: s.hauer@pengutronix.de, gerg@uclinux.org,
	amit.kucheria@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net, afleming@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:48293 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001Ab0E1JIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 05:08:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BugLink: http://bugs.launchpad.net/bugs/559065

In fec open/close function, we need to use phy_connect and phy_disconnect
operation before we start/stop phy. Otherwise it will cause system hang.

Only call fec_enet_mii_probe() in open function, because the first open
action will cause NULL pointer error.

Signed-off-by: Bryan Wu <bryan.wu@canonical.com>
---
 drivers/net/fec.c |   28 ++++++++++++++++------------
 1 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 42d9ac9..cdc9376 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -679,6 +679,8 @@ static int fec_enet_mii_probe(struct net_device *dev)
 	struct phy_device *phy_dev = NULL;
 	int phy_addr;
 
+	fep->phy_dev = NULL;
+
 	/* find the first phy */
 	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
 		if (fep->mii_bus->phy_map[phy_addr]) {
@@ -709,6 +711,11 @@ static int fec_enet_mii_probe(struct net_device *dev)
 	fep->link = 0;
 	fep->full_duplex = 0;
 
+	printk(KERN_INFO "%s: Freescale FEC PHY driver [%s] "
+		"(mii_bus:phy_addr=%s, irq=%d)\n", dev->name,
+		fep->phy_dev->drv->name, dev_name(&fep->phy_dev->dev),
+		fep->phy_dev->irq);
+
 	return 0;
 }
 
@@ -754,13 +761,8 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	if (mdiobus_register(fep->mii_bus))
 		goto err_out_free_mdio_irq;
 
-	if (fec_enet_mii_probe(dev) != 0)
-		goto err_out_unregister_bus;
-
 	return 0;
 
-err_out_unregister_bus:
-	mdiobus_unregister(fep->mii_bus);
 err_out_free_mdio_irq:
 	kfree(fep->mii_bus->irq);
 err_out_free_mdiobus:
@@ -913,7 +915,12 @@ fec_enet_open(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	/* schedule a link state check */
+	/* Probe and connect to PHY when open the interface */
+	ret = fec_enet_mii_probe(dev);
+	if (ret) {
+		fec_enet_free_buffers(dev);
+		return ret;
+	}
 	phy_start(fep->phy_dev);
 	netif_start_queue(dev);
 	fep->opened = 1;
@@ -927,10 +934,12 @@ fec_enet_close(struct net_device *dev)
 
 	/* Don't know what to do yet. */
 	fep->opened = 0;
-	phy_stop(fep->phy_dev);
 	netif_stop_queue(dev);
 	fec_stop(dev);
 
+	if (fep->phy_dev)
+		phy_disconnect(fep->phy_dev);
+
         fec_enet_free_buffers(dev);
 
 	return 0;
@@ -1294,11 +1303,6 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_register;
 
-	printk(KERN_INFO "%s: Freescale FEC PHY driver [%s] "
-		"(mii_bus:phy_addr=%s, irq=%d)\n", ndev->name,
-		fep->phy_dev->drv->name, dev_name(&fep->phy_dev->dev),
-		fep->phy_dev->irq);
-
 	return 0;
 
 failed_register:
-- 
1.7.0.4

