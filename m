From: Florian Vaussard <florian.vaussard@epfl.ch>
Subject: [PATCH v3 2/5] can: sja1000: platform: use devm_* APIs
Date: Fri, 31 Jan 2014 14:34:34 +0100
Message-ID: <1391175277-19833-3-git-send-email-florian.vaussard@epfl.ch>
References: <1391175277-19833-1-git-send-email-florian.vaussard@epfl.ch>
Cc: Andreas Larsson <andreas@gaisler.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-kernel@vger.kernel.org, florian.vaussard@epfl.ch
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391175277-19833-1-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify probe and remove functions by converting most of the resources
to use devm_* APIs.

Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>
---
 drivers/net/can/sja1000/sja1000_platform.c | 46 ++++++++----------------------
 1 file changed, 12 insertions(+), 34 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 29f9b63..779679a 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -79,34 +79,26 @@ static int sp_probe(struct platform_device *pdev)
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
@@ -151,28 +143,14 @@ static int sp_probe(struct platform_device *pdev)
 
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
1.8.1.2
