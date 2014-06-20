From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Subject: [PATCH] can: c_can: convert to use devm * api
Date: Fri, 20 Jun 2014 12:59:34 +0100
Message-ID: <1403265574-12923-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch uses devm_* APIs as they are device managed
and make code simpler.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Note: This patch is compile tested only.
 
 drivers/net/can/c_can/c_can_platform.c | 41 ++++++++--------------------------
 1 file changed, 9 insertions(+), 32 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 1df0b32..e0dcbcf 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -157,40 +157,31 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	}
 
 	/* get the appropriate clk */
-	clk = clk_get(&pdev->dev, NULL);
+	clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(clk)) {
-		dev_err(&pdev->dev, "no clock defined\n");
-		ret = -ENODEV;
+		ret = PTR_ERR(clk);
 		goto exit;
 	}
 
 	/* get the platform data */
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	irq = platform_get_irq(pdev, 0);
-	if (!mem || irq <= 0) {
-		ret = -ENODEV;
-		goto exit_free_clk;
-	}
-
-	if (!request_mem_region(mem->start, resource_size(mem),
-				KBUILD_MODNAME)) {
-		dev_err(&pdev->dev, "resource unavailable\n");
+	if (irq <= 0) {
 		ret = -ENODEV;
-		goto exit_free_clk;
+		goto exit;
 	}
 
-	addr = ioremap(mem->start, resource_size(mem));
-	if (!addr) {
-		dev_err(&pdev->dev, "failed to map can port\n");
-		ret = -ENOMEM;
-		goto exit_release_mem;
+	addr = devm_ioremap_resource(&pdev->dev, mem);
+	if (IS_ERR(addr)) {
+		ret =  PTR_ERR(addr);
+		goto exit;
 	}
 
 	/* allocate the c_can device */
 	dev = alloc_c_can_dev();
 	if (!dev) {
 		ret = -ENOMEM;
-		goto exit_iounmap;
+		goto exit;
 	}
 
 	priv = netdev_priv(dev);
@@ -255,12 +246,6 @@ static int c_can_plat_probe(struct platform_device *pdev)
 
 exit_free_device:
 	free_c_can_dev(dev);
-exit_iounmap:
-	iounmap(addr);
-exit_release_mem:
-	release_mem_region(mem->start, resource_size(mem));
-exit_free_clk:
-	clk_put(clk);
 exit:
 	dev_err(&pdev->dev, "probe failed\n");
 
@@ -270,18 +255,10 @@ exit:
 static int c_can_plat_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
-	struct c_can_priv *priv = netdev_priv(dev);
-	struct resource *mem;
 
 	unregister_c_can_dev(dev);
 
 	free_c_can_dev(dev);
-	iounmap(priv->base);
-
-	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(mem->start, resource_size(mem));
-
-	clk_put(priv->priv);
 
 	return 0;
 }
-- 
1.9.1

