From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: [PATCH 1/2] atmel/macb: fix device name when SOFT/HARD_IRQ enabled
Date: Wed,  9 Feb 2011 13:43:36 +0100
Message-ID: <1297255416-6920-1-git-send-email-plagnioj@jcrosoft.com>
Cc: netdev@vger.kernel.org, Paul Chavent <paul.chavent@fnac.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 26.mail-out.ovh.net ([91.121.27.225]:40196 "HELO
	26.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752835Ab1BIMql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 07:46:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Chavent <paul.chavent@fnac.net>

When listing processes on a system with SOFT/HARD_IRQ enabled,
the name of the ethernet device is [irq/eth%d] (instead of [irq/eth0] for example).

This patch call the request_irq function after having initialized the name of the device.

Signed-off-by: Paul Chavent <paul.chavent@fnac.net>
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
---
 drivers/net/macb.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index f69e73e..d642e08 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1170,16 +1170,6 @@ static int __init macb_probe(struct platform_device *pdev)
 		goto err_out_disable_clocks;
 	}
 
-	dev->irq = platform_get_irq(pdev, 0);
-	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
-			  dev->name, dev);
-	if (err) {
-		printk(KERN_ERR
-		       "%s: Unable to request IRQ %d (error %d)\n",
-		       dev->name, dev->irq, err);
-		goto err_out_iounmap;
-	}
-
 	dev->netdev_ops = &macb_netdev_ops;
 	netif_napi_add(dev, &bp->napi, macb_poll, 64);
 	dev->ethtool_ops = &macb_ethtool_ops;
@@ -1219,13 +1209,23 @@ static int __init macb_probe(struct platform_device *pdev)
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-		goto err_out_free_irq;
+		goto err_out_iounmap;
 	}
 
-	if (macb_mii_init(bp) != 0) {
+	dev->irq = platform_get_irq(pdev, 0);
+	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
+			  dev->name, dev);
+	if (err) {
+		printk(KERN_ERR
+		       "%s: Unable to request IRQ %d (error %d)\n",
+		       dev->name, dev->irq, err);
 		goto err_out_unregister_netdev;
 	}
 
+	if (macb_mii_init(bp) != 0) {
+		goto err_out_free_irq;
+	}
+
 	platform_set_drvdata(pdev, dev);
 
 	printk(KERN_INFO "%s: Atmel MACB at 0x%08lx irq %d (%pM)\n",
@@ -1238,10 +1238,10 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	return 0;
 
-err_out_unregister_netdev:
-	unregister_netdev(dev);
 err_out_free_irq:
 	free_irq(dev->irq, dev);
+err_out_unregister_netdev:
+	unregister_netdev(dev);
 err_out_iounmap:
 	iounmap(bp->regs);
 err_out_disable_clocks:
-- 
1.7.2.3

