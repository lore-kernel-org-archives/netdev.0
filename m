From: Aaron Wu <Aaron.wu@analog.com>
Subject: [PATCH V7 2/3] bfin_can: introduce ioremap to comply to archs with MMU
Date: Fri, 6 Feb 2015 18:14:18 +0800
Message-ID: <1423217659-27820-2-git-send-email-Aaron.wu@analog.com>
References: <1423217659-27820-1-git-send-email-Aaron.wu@analog.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Aaron Wu <Aaron.wu@analog.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-devel@analog.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1423217659-27820-1-git-send-email-Aaron.wu@analog.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Blackfin was built without MMU, old driver code access the IO space by
physical address, introduce the ioremap approach to be compitable with
the common style supporting MMU enabled arch.

Signed-off-by: Aaron Wu <Aaron.wu@analog.com>
---
 drivers/net/can/bfin_can.c |   22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 0a5eff4..259d09a 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -551,16 +551,10 @@ static int bfin_can_probe(struct platform_device *pdev)
 		goto exit;
 	}
 
-	if (!request_mem_region(res_mem->start, resource_size(res_mem),
-				dev_name(&pdev->dev))) {
-		err = -EBUSY;
-		goto exit;
-	}
-
 	/* request peripheral pins */
 	err = peripheral_request_list(pdata, dev_name(&pdev->dev));
 	if (err)
-		goto exit_mem_release;
+		goto exit;
 
 	dev = alloc_bfin_candev();
 	if (!dev) {
@@ -569,7 +563,13 @@ static int bfin_can_probe(struct platform_device *pdev)
 	}
 
 	priv = netdev_priv(dev);
-	priv->membase = (void __iomem *)res_mem->start;
+
+	priv->membase = devm_ioremap_resource(&pdev->dev, res_mem);
+	if (IS_ERR(priv->membase)) {
+		err = PTR_ERR(priv->membase);
+		goto exit_peri_pin_free;
+	}
+
 	priv->rx_irq = rx_irq->start;
 	priv->tx_irq = tx_irq->start;
 	priv->err_irq = err_irq->start;
@@ -601,8 +601,6 @@ exit_candev_free:
 	free_candev(dev);
 exit_peri_pin_free:
 	peripheral_free_list(pdata);
-exit_mem_release:
-	release_mem_region(res_mem->start, resource_size(res_mem));
 exit:
 	return err;
 }
@@ -611,15 +609,11 @@ static int bfin_can_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct bfin_can_priv *priv = netdev_priv(dev);
-	struct resource *res;
 
 	bfin_can_set_reset_mode(dev);
 
 	unregister_candev(dev);
 
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(res->start, resource_size(res));
-
 	peripheral_free_list(priv->pin_list);
 
 	free_candev(dev);
-- 
1.7.9.5

