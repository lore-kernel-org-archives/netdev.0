From: Paul Chavent <paul.chavent@fnac.net>
Subject: [PATCH] arm driver net macb
Date: Thu, 02 Sep 2010 22:40:15 +0200
Message-ID: <4C800BAF.2090003@fnac.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030408010308020702050500"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, jkosina@suse.cz,
	richard.cochran@omicron.at, jpirko@redhat.com, davem@davemloft.net,
	nicolas.ferre@atmel.com
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:41355 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752832Ab0IBUcm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Sep 2010 16:32:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030408010308020702050500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

When listing processes on a system with SOFT/HARD_IRQ enabled, the name of the ethernet device is [irq/eth%d] (instead of [irq/eth0] for example).

This patch call the request_irq function after having initialized the name of the device.

Signed-off-by: Paul Chavent <paul.chavent@fnac.net>


--------------030408010308020702050500
Content-Type: text/plain;
 name="linux-2.6.35.4-arm_at91_ethname.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.35.4-arm_at91_ethname.patch"

diff -abBruN linux-2.6.35.4.orig/drivers/net/macb.c linux-2.6.35.4.mod/drivers/net/macb.c
--- linux-2.6.35.4.orig/drivers/net/macb.c	2010-09-02 17:35:18.422000143 +0200
+++ linux-2.6.35.4.mod/drivers/net/macb.c	2010-09-02 18:02:37.078000147 +0200
@@ -1165,16 +1242,6 @@
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
@@ -1214,13 +1281,23 @@
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-		goto err_out_free_irq;
+		goto err_out_iounmap;
 	}
 
 	if (macb_mii_init(bp) != 0) {
 		goto err_out_unregister_netdev;
 	}
 
+	dev->irq = platform_get_irq(pdev, 0);
+	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
+			  dev->name, dev);
+	if (err) {
+		printk(KERN_ERR
+		       "%s: Unable to request IRQ %d (error %d)\n",
+		       dev->name, dev->irq, err);
+		goto err_out_unregister_netdev;
+	}
+
 	platform_set_drvdata(pdev, dev);
 
 	printk(KERN_INFO "%s: Atmel MACB at 0x%08lx irq %d (%pM)\n",
@@ -1233,10 +1310,10 @@
 
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
@@ -1270,8 +1347,8 @@
 		mdiobus_unregister(bp->mii_bus);
 		kfree(bp->mii_bus->irq);
 		mdiobus_free(bp->mii_bus);
-		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
+		unregister_netdev(dev);
 		iounmap(bp->regs);
 #ifndef CONFIG_ARCH_AT91
 		clk_disable(bp->hclk);

--------------030408010308020702050500--
