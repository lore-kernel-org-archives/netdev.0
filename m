From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: [PATCH 1/6] bcm63xx_enet: correct clock usage
Date: Sun,  1 Oct 2017 13:02:15 +0200
Message-ID: <20171001110220.27668-2-jonas.gorski@gmail.com>
References: <20171001110220.27668-1-jonas.gorski@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.or
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36720 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdJALCN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 07:02:13 -0400
Received: by mail-wm0-f67.google.com with SMTP id 63so678469wmn.3
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 04:02:12 -0700 (PDT)
In-Reply-To: <20171001110220.27668-1-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check the return code of prepare_enable and change one last instance of
enable only to prepare_enable. Also properly disable and release the
clock in error paths and on remove for enetsw.

Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 31 +++++++++++++++++++++-------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index c6221f04a748..a45ec97b5b1e 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1773,7 +1773,9 @@ static int bcm_enet_probe(struct platform_device *pdev)
 		ret = PTR_ERR(priv->mac_clk);
 		goto out;
 	}
-	clk_prepare_enable(priv->mac_clk);
+	ret = clk_prepare_enable(priv->mac_clk);
+	if (ret)
+		goto out_put_clk_mac;
 
 	/* initialize default and fetch platform data */
 	priv->rx_ring_size = BCMENET_DEF_RX_DESC;
@@ -1805,9 +1807,11 @@ static int bcm_enet_probe(struct platform_device *pdev)
 		if (IS_ERR(priv->phy_clk)) {
 			ret = PTR_ERR(priv->phy_clk);
 			priv->phy_clk = NULL;
-			goto out_put_clk_mac;
+			goto out_disable_clk_mac;
 		}
-		clk_prepare_enable(priv->phy_clk);
+		ret = clk_prepare_enable(priv->phy_clk);
+		if (ret)
+			goto out_put_clk_phy;
 	}
 
 	/* do minimal hardware init to be able to probe mii bus */
@@ -1900,13 +1904,16 @@ static int bcm_enet_probe(struct platform_device *pdev)
 out_uninit_hw:
 	/* turn off mdc clock */
 	enet_writel(priv, 0, ENET_MIISC_REG);
-	if (priv->phy_clk) {
+	if (priv->phy_clk)
 		clk_disable_unprepare(priv->phy_clk);
+
+out_put_clk_phy:
+	if (priv->phy_clk)
 		clk_put(priv->phy_clk);
-	}
 
-out_put_clk_mac:
+out_disable_clk_mac:
 	clk_disable_unprepare(priv->mac_clk);
+out_put_clk_mac:
 	clk_put(priv->mac_clk);
 out:
 	free_netdev(dev);
@@ -2748,7 +2755,9 @@ static int bcm_enetsw_probe(struct platform_device *pdev)
 		ret = PTR_ERR(priv->mac_clk);
 		goto out_unmap;
 	}
-	clk_enable(priv->mac_clk);
+	ret = clk_prepare_enable(priv->mac_clk);
+	if (ret)
+		goto out_put_clk;
 
 	priv->rx_chan = 0;
 	priv->tx_chan = 1;
@@ -2769,7 +2778,7 @@ static int bcm_enetsw_probe(struct platform_device *pdev)
 
 	ret = register_netdev(dev);
 	if (ret)
-		goto out_put_clk;
+		goto out_disable_clk;
 
 	netif_carrier_off(dev);
 	platform_set_drvdata(pdev, dev);
@@ -2778,6 +2787,9 @@ static int bcm_enetsw_probe(struct platform_device *pdev)
 
 	return 0;
 
+out_disable_clk:
+	clk_disable_unprepare(priv->mac_clk);
+
 out_put_clk:
 	clk_put(priv->mac_clk);
 
@@ -2809,6 +2821,9 @@ static int bcm_enetsw_remove(struct platform_device *pdev)
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, resource_size(res));
 
+	clk_disable_unprepare(priv->mac_clk);
+	clk_put(priv->mac_clk);
+
 	free_netdev(dev);
 	return 0;
 }
-- 
2.13.2
