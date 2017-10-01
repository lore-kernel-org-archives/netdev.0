From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: [PATCH 4/6] bcm63xx_enet: use managed functions for clock/ioremap
Date: Sun,  1 Oct 2017 13:02:18 +0200
Message-ID: <20171001110220.27668-5-jonas.gorski@gmail.com>
References: <20171001110220.27668-1-jonas.gorski@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.or
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35372 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbdJALCR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 07:02:17 -0400
Received: by mail-wm0-f68.google.com with SMTP id b189so1874376wmd.2
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 04:02:16 -0700 (PDT)
In-Reply-To: <20171001110220.27668-1-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use managed functions where possible to reduce the amount of resource
handling on error and remove paths.

Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 54 +++++++---------------------
 1 file changed, 12 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 8caf6abab3a6..059ef4f1d137 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1767,14 +1767,14 @@ static int bcm_enet_probe(struct platform_device *pdev)
 		clk_name = "enet1";
 	}
 
-	priv->mac_clk = clk_get(&pdev->dev, clk_name);
+	priv->mac_clk = devm_clk_get(&pdev->dev, clk_name);
 	if (IS_ERR(priv->mac_clk)) {
 		ret = PTR_ERR(priv->mac_clk);
 		goto out;
 	}
 	ret = clk_prepare_enable(priv->mac_clk);
 	if (ret)
-		goto out_put_clk_mac;
+		goto out;
 
 	/* initialize default and fetch platform data */
 	priv->rx_ring_size = BCMENET_DEF_RX_DESC;
@@ -1802,7 +1802,7 @@ static int bcm_enet_probe(struct platform_device *pdev)
 
 	if (priv->mac_id == 0 && priv->has_phy && !priv->use_external_mii) {
 		/* using internal PHY, enable clock */
-		priv->phy_clk = clk_get(&pdev->dev, "ephy");
+		priv->phy_clk = devm_clk_get(&pdev->dev, "ephy");
 		if (IS_ERR(priv->phy_clk)) {
 			ret = PTR_ERR(priv->phy_clk);
 			priv->phy_clk = NULL;
@@ -1810,7 +1810,7 @@ static int bcm_enet_probe(struct platform_device *pdev)
 		}
 		ret = clk_prepare_enable(priv->phy_clk);
 		if (ret)
-			goto out_put_clk_phy;
+			goto out_disable_clk_mac;
 	}
 
 	/* do minimal hardware init to be able to probe mii bus */
@@ -1906,14 +1906,8 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	if (priv->phy_clk)
 		clk_disable_unprepare(priv->phy_clk);
 
-out_put_clk_phy:
-	if (priv->phy_clk)
-		clk_put(priv->phy_clk);
-
 out_disable_clk_mac:
 	clk_disable_unprepare(priv->mac_clk);
-out_put_clk_mac:
-	clk_put(priv->mac_clk);
 out:
 	free_netdev(dev);
 	return ret;
@@ -1949,12 +1943,10 @@ static int bcm_enet_remove(struct platform_device *pdev)
 	}
 
 	/* disable hw block clocks */
-	if (priv->phy_clk) {
+	if (priv->phy_clk)
 		clk_disable_unprepare(priv->phy_clk);
-		clk_put(priv->phy_clk);
-	}
+
 	clk_disable_unprepare(priv->mac_clk);
-	clk_put(priv->mac_clk);
 
 	free_netdev(dev);
 	return 0;
@@ -2734,26 +2726,20 @@ static int bcm_enetsw_probe(struct platform_device *pdev)
 	if (ret)
 		goto out;
 
-	if (!request_mem_region(res_mem->start, resource_size(res_mem),
-				"bcm63xx_enetsw")) {
-		ret = -EBUSY;
+	priv->base = devm_ioremap_resource(&pdev->dev, res_mem);
+	if (IS_ERR(priv->base)) {
+		ret = PTR_ERR(priv->base);
 		goto out;
 	}
 
-	priv->base = ioremap(res_mem->start, resource_size(res_mem));
-	if (priv->base == NULL) {
-		ret = -ENOMEM;
-		goto out_release_mem;
-	}
-
-	priv->mac_clk = clk_get(&pdev->dev, "enetsw");
+	priv->mac_clk = devm_clk_get(&pdev->dev, "enetsw");
 	if (IS_ERR(priv->mac_clk)) {
 		ret = PTR_ERR(priv->mac_clk);
-		goto out_unmap;
+		goto out;
 	}
 	ret = clk_prepare_enable(priv->mac_clk);
 	if (ret)
-		goto out_put_clk;
+		goto out;
 
 	priv->rx_chan = 0;
 	priv->tx_chan = 1;
@@ -2785,15 +2771,6 @@ static int bcm_enetsw_probe(struct platform_device *pdev)
 
 out_disable_clk:
 	clk_disable_unprepare(priv->mac_clk);
-
-out_put_clk:
-	clk_put(priv->mac_clk);
-
-out_unmap:
-	iounmap(priv->base);
-
-out_release_mem:
-	release_mem_region(res_mem->start, resource_size(res_mem));
 out:
 	free_netdev(dev);
 	return ret;
@@ -2805,20 +2782,13 @@ static int bcm_enetsw_remove(struct platform_device *pdev)
 {
 	struct bcm_enet_priv *priv;
 	struct net_device *dev;
-	struct resource *res;
 
 	/* stop netdevice */
 	dev = platform_get_drvdata(pdev);
 	priv = netdev_priv(dev);
 	unregister_netdev(dev);
 
-	/* release device resources */
-	iounmap(priv->base);
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(res->start, resource_size(res));
-
 	clk_disable_unprepare(priv->mac_clk);
-	clk_put(priv->mac_clk);
 
 	free_netdev(dev);
 	return 0;
-- 
2.13.2
