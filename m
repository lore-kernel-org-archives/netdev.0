From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] b44-ssb: Powerup the bus before using the device.
Date: Tue, 14 Aug 2007 20:15:53 +0200
Message-ID: <200708142015.53926.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:37477
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561AbXHNSPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 14:15:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We must turn on buspower before poking with the device

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev-new/drivers/net/b44.c
===================================================================
--- wireless-dev-new.orig/drivers/net/b44.c	2007-08-11 00:45:55.000000000 +0200
+++ wireless-dev-new/drivers/net/b44.c	2007-08-12 22:18:34.000000000 +0200
@@ -2154,17 +2154,23 @@ static int __devinit b44_init_one(struct
 
 	netif_carrier_off(dev);
 
+	err = ssb_bus_powerup(sdev->bus, 0);
+	if (err) {
+		dev_err(sdev->dev,
+			"Failed to powerup the bus\n");
+		goto err_out_free_dev;
+	}
 	err = ssb_dma_set_mask(sdev, DMA_30BIT_MASK);
 	if (err) {
 		dev_err(sdev->dev,
 			"Required 30BIT DMA mask unsupported by the system.\n");
-		goto err_out_free_dev;
+		goto err_out_powerdown;
 	}
 	err = b44_get_invariants(bp);
 	if (err) {
 		dev_err(sdev->dev,
 			"Problem fetching invariants of chip, aborting.\n");
-		goto err_out_free_dev;
+		goto err_out_powerdown;
 	}
 
 	bp->mii_if.dev = dev;
@@ -2184,7 +2190,7 @@ static int __devinit b44_init_one(struct
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(sdev->dev, "Cannot register net device, aborting.\n");
-		goto out;
+		goto err_out_powerdown;
 	}
 
 	ssb_set_drvdata(sdev, dev);
@@ -2201,6 +2207,9 @@ static int __devinit b44_init_one(struct
 
 	return 0;
 
+err_out_powerdown:
+	ssb_bus_may_powerdown(sdev->bus);
+
 err_out_free_dev:
 	free_netdev(dev);
 
@@ -2208,13 +2217,14 @@ out:
 	return err;
 }
 
-static void __devexit b44_remove_one(struct ssb_device *pdev)
+static void __devexit b44_remove_one(struct ssb_device *sdev)
 {
-	struct net_device *dev = ssb_get_drvdata(pdev);
+	struct net_device *dev = ssb_get_drvdata(sdev);
 
 	unregister_netdev(dev);
+	ssb_bus_may_powerdown(sdev->bus);
 	free_netdev(dev);
-	ssb_set_drvdata(pdev, NULL);
+	ssb_set_drvdata(sdev, NULL);
 }
 
 static int b44_suspend(struct ssb_device *sdev, pm_message_t state)
@@ -2251,6 +2261,13 @@ static int b44_resume(struct ssb_device 
 	struct b44 *bp = netdev_priv(dev);
 	int rc = 0;
 
+	rc = ssb_bus_powerup(sdev->bus, 0);
+	if (rc) {
+		dev_err(sdev->dev,
+			"Failed to powerup the bus\n");
+		return rc;
+	}
+
 	if (!netif_running(dev))
 		return 0;
 
