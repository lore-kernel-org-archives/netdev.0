From: Jonas Gorski <jogo@openwrt.org>
Subject: [PATCH 1/3] bcm63xx_enet: use managed io memory allocations
Date: Sun, 10 Mar 2013 14:57:47 +0100
Message-ID: <1362923869-21346-1-git-send-email-jogo@openwrt.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	Maxime Bizon <mbizon@freebox.fr>,
	Florian Fainelli <florian@openwrt.org>,
	Kevin Cernekee <cernekee@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:50573 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253Ab3CJN6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Mar 2013 09:58:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jonas Gorski <jogo@openwrt.org>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |   43 +++++---------------------
 1 file changed, 7 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 842f983..0a43188 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1634,7 +1634,6 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	struct resource *res_mem, *res_irq, *res_irq_rx, *res_irq_tx;
 	struct mii_bus *bus;
 	const char *clk_name;
-	unsigned int iomem_size;
 	int i, ret;
 
 	/* stop if shared driver failed, assume driver->probe will be
@@ -1659,17 +1658,12 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	if (ret)
 		goto out;
 
-	iomem_size = resource_size(res_mem);
-	if (!request_mem_region(res_mem->start, iomem_size, "bcm63xx_enet")) {
-		ret = -EBUSY;
-		goto out;
-	}
-
-	priv->base = ioremap(res_mem->start, iomem_size);
+	priv->base = devm_request_and_ioremap(&pdev->dev, res_mem);
 	if (priv->base == NULL) {
 		ret = -ENOMEM;
-		goto out_release_mem;
+		goto out;
 	}
+
 	dev->irq = priv->irq = res_irq->start;
 	priv->irq_rx = res_irq_rx->start;
 	priv->irq_tx = res_irq_tx->start;
@@ -1689,7 +1683,7 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	priv->mac_clk = clk_get(&pdev->dev, clk_name);
 	if (IS_ERR(priv->mac_clk)) {
 		ret = PTR_ERR(priv->mac_clk);
-		goto out_unmap;
+		goto out;
 	}
 	clk_enable(priv->mac_clk);
 
@@ -1829,12 +1823,6 @@ out_uninit_hw:
 out_put_clk_mac:
 	clk_disable(priv->mac_clk);
 	clk_put(priv->mac_clk);
-
-out_unmap:
-	iounmap(priv->base);
-
-out_release_mem:
-	release_mem_region(res_mem->start, iomem_size);
 out:
 	free_netdev(dev);
 	return ret;
@@ -1848,7 +1836,6 @@ static int bcm_enet_remove(struct platform_device *pdev)
 {
 	struct bcm_enet_priv *priv;
 	struct net_device *dev;
-	struct resource *res;
 
 	/* stop netdevice */
 	dev = platform_get_drvdata(pdev);
@@ -1871,11 +1858,6 @@ static int bcm_enet_remove(struct platform_device *pdev)
 				       bcm_enet_mdio_write_mii);
 	}
 
-	/* release device resources */
-	iounmap(priv->base);
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(res->start, resource_size(res));
-
 	/* disable hw block clocks */
 	if (priv->phy_clk) {
 		clk_disable(priv->phy_clk);
@@ -1904,31 +1886,20 @@ struct platform_driver bcm63xx_enet_driver = {
 static int bcm_enet_shared_probe(struct platform_device *pdev)
 {
 	struct resource *res;
-	unsigned int iomem_size;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!res)
 		return -ENODEV;
 
-	iomem_size = resource_size(res);
-	if (!request_mem_region(res->start, iomem_size, "bcm63xx_enet_dma"))
-		return -EBUSY;
-
-	bcm_enet_shared_base = ioremap(res->start, iomem_size);
-	if (!bcm_enet_shared_base) {
-		release_mem_region(res->start, iomem_size);
+	bcm_enet_shared_base = devm_request_and_ioremap(&pdev->dev, res);
+	if (!bcm_enet_shared_base)
 		return -ENOMEM;
-	}
+
 	return 0;
 }
 
 static int bcm_enet_shared_remove(struct platform_device *pdev)
 {
-	struct resource *res;
-
-	iounmap(bcm_enet_shared_base);
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(res->start, resource_size(res));
 	return 0;
 }
 
-- 
1.7.10.4
