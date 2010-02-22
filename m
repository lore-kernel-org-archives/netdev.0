From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 1/2] can:ti_hecc: Add pm hook-up
Date: Mon, 22 Feb 2010 19:05:36 +0530
Message-ID: <1266845736-7161-1-git-send-email-srk@ti.com>
Cc: anantgole@ti.com, Sriramakrishnan <srk@ti.com>,
	K R Baalaaji <krbaalaaji@ti.com>
To: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:46220 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861Ab0BVNfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 08:35:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added the suspend and resume implementation in the HECC (CAN)
driver.

Signed-off-by: K R Baalaaji <krbaalaaji@ti.com>
Signed-off-by: Sriramakrishnan <srk@ti.com>
Acked-by: Anant Gole <anantgole@ti.com>
---
 drivers/net/can/ti_hecc.c |   51 ++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 48 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 5c993c2..df27d82 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -824,7 +824,6 @@ static int ti_hecc_open(struct net_device *ndev)
 		return err;
 	}
 
-	clk_enable(priv->clk);
 	ti_hecc_start(ndev);
 	napi_enable(&priv->napi);
 	netif_start_queue(ndev);
@@ -840,7 +839,6 @@ static int ti_hecc_close(struct net_device *ndev)
 	napi_disable(&priv->napi);
 	ti_hecc_stop(ndev);
 	free_irq(ndev->irq, ndev);
-	clk_disable(priv->clk);
 	close_candev(ndev);
 
 	return 0;
@@ -925,6 +923,7 @@ static int ti_hecc_probe(struct platform_device *pdev)
 	netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
 		HECC_DEF_NAPI_WEIGHT);
 
+	clk_enable(priv->clk);
 	err = register_candev(ndev);
 	if (err) {
 		dev_err(&pdev->dev, "register_candev() failed\n");
@@ -953,6 +952,7 @@ static int __devexit ti_hecc_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct ti_hecc_priv *priv = netdev_priv(ndev);
 
+	clk_disable(priv->clk);
 	clk_put(priv->clk);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	iounmap(priv->base);
@@ -964,6 +964,48 @@ static int __devexit ti_hecc_remove(struct platform_device *pdev)
 	return 0;
 }
 
+
+#ifdef CONFIG_PM
+static int ti_hecc_suspend(struct platform_device *pdev, pm_message_t state)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct ti_hecc_priv *priv = netdev_priv(dev);
+
+	if (netif_running(dev)) {
+		netif_stop_queue(dev);
+		netif_device_detach(dev);
+	}
+
+	hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
+	priv->can.state = CAN_STATE_SLEEPING;
+
+	clk_disable(priv->clk);
+
+	return 0;
+}
+
+static int ti_hecc_resume(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct ti_hecc_priv *priv = netdev_priv(dev);
+
+	clk_enable(priv->clk);
+
+	hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
+	priv->can.state = CAN_STATE_ERROR_ACTIVE;
+
+	if (netif_running(dev)) {
+		netif_device_attach(dev);
+		netif_start_queue(dev);
+	}
+
+	return 0;
+}
+#else
+#define ti_hecc_suspend NULL
+#define ti_hecc_resume NULL
+#endif
+
 /* TI HECC netdevice driver: platform driver structure */
 static struct platform_driver ti_hecc_driver = {
 	.driver = {
@@ -972,6 +1014,8 @@ static struct platform_driver ti_hecc_driver = {
 	},
 	.probe = ti_hecc_probe,
 	.remove = __devexit_p(ti_hecc_remove),
+	.suspend = ti_hecc_suspend,
+	.resume = ti_hecc_resume,
 };
 
 static int __init ti_hecc_init_driver(void)
@@ -979,14 +1023,15 @@ static int __init ti_hecc_init_driver(void)
 	printk(KERN_INFO DRV_DESC "\n");
 	return platform_driver_register(&ti_hecc_driver);
 }
-module_init(ti_hecc_init_driver);
 
 static void __exit ti_hecc_exit_driver(void)
 {
 	printk(KERN_INFO DRV_DESC " unloaded\n");
 	platform_driver_unregister(&ti_hecc_driver);
 }
+
 module_exit(ti_hecc_exit_driver);
+module_init(ti_hecc_init_driver);
 
 MODULE_AUTHOR("Anant Gole <anantgole@ti.com>");
 MODULE_LICENSE("GPL v2");
-- 
1.6.2.4

