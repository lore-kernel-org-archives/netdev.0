From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v4 2/5] can: sja1000: platform: use devm_* APIs
Date: Thu,  6 Feb 2014 12:09:53 +0100
Message-ID: <1391684996-612-3-git-send-email-mkl@pengutronix.de>
References: <1391684996-612-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org,
	Florian Vaussard <florian.vaussard@epfl.ch>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1391684996-612-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Vaussard <florian.vaussard@epfl.ch>

Simplify probe and remove functions by converting most of the resources
to use devm_* APIs.

Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>
Tested-by: Andreas Larsson <andreas@gaisler.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/sja1000_platform.c | 46 ++++++++----------------------
 1 file changed, 12 insertions(+), 34 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 943df64..50ca273 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -78,34 +78,26 @@ static int sp_probe(struct platform_device *pdev)
 	pdata = dev_get_platdata(&pdev->dev);
 	if (!pdata) {
 		dev_err(&pdev->dev, "No platform data provided!\n");
-		err = -ENODEV;
-		goto exit;
+		return -ENODEV;
 	}
 
 	res_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	res_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (!res_mem || !res_irq) {
-		err = -ENODEV;
-		goto exit;
-	}
+	if (!res_mem || !res_irq)
+		return -ENODEV;
 
-	if (!request_mem_region(res_mem->start, resource_size(res_mem),
-				DRV_NAME)) {
-		err = -EBUSY;
-		goto exit;
-	}
+	if (!devm_request_mem_region(&pdev->dev, res_mem->start,
+				     resource_size(res_mem), DRV_NAME))
+		return -EBUSY;
 
-	addr = ioremap_nocache(res_mem->start, resource_size(res_mem));
-	if (!addr) {
-		err = -ENOMEM;
-		goto exit_release;
-	}
+	addr = devm_ioremap_nocache(&pdev->dev, res_mem->start,
+				    resource_size(res_mem));
+	if (!addr)
+		return -ENOMEM;
 
 	dev = alloc_sja1000dev(0);
-	if (!dev) {
-		err = -ENOMEM;
-		goto exit_iounmap;
-	}
+	if (!dev)
+		return -ENOMEM;
 	priv = netdev_priv(dev);
 
 	dev->irq = res_irq->start;
@@ -150,28 +142,14 @@ static int sp_probe(struct platform_device *pdev)
 
  exit_free:
 	free_sja1000dev(dev);
- exit_iounmap:
-	iounmap(addr);
- exit_release:
-	release_mem_region(res_mem->start, resource_size(res_mem));
- exit:
 	return err;
 }
 
 static int sp_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
-	struct sja1000_priv *priv = netdev_priv(dev);
-	struct resource *res;
 
 	unregister_sja1000dev(dev);
-
-	if (priv->reg_base)
-		iounmap(priv->reg_base);
-
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(res->start, resource_size(res));
-
 	free_sja1000dev(dev);
 
 	return 0;
-- 
1.8.5.3

