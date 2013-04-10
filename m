From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH] net: mv643xx_eth: add shared clk and cleanup existing clk handling
Date: Wed, 10 Apr 2013 19:37:44 +0200
Message-ID: <1365615464-26279-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Florian Fainelli <florian@openwrt.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds an optional shared block clock to avoid lockups on
clock gated controllers. Besides the new clock, clock handling for
existing clocks is cleaned up and moved to devm_clk_get. Device
tree binding documentation is updated for the new clocks property.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: Rob Landley <rob@landley.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Florian Fainelli <florian@openwrt.org>
Cc: devicetree-discuss@lists.ozlabs.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 Documentation/devicetree/bindings/marvell.txt |    3 +++
 drivers/net/ethernet/marvell/mv643xx_eth.c    |   27 ++++++++++---------------
 2 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/Documentation/devicetree/bindings/marvell.txt b/Documentation/devicetree/bindings/marvell.txt
index f1533d9..f7a0da6 100644
--- a/Documentation/devicetree/bindings/marvell.txt
+++ b/Documentation/devicetree/bindings/marvell.txt
@@ -115,6 +115,9 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
      - compatible : "marvell,mv64360-eth-block"
      - reg : Offset and length of the register set for this block
 
+   Optional properties:
+     - clocks : Phandle to the clock control device and gate bit
+
    Example Discovery Ethernet block node:
      ethernet-block@2000 {
 	     #address-cells = <1>;
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index aedbd82..bbe6104 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -268,7 +268,7 @@ struct mv643xx_eth_shared_private {
 	int extended_rx_coal_limit;
 	int tx_bw_control;
 	int tx_csum_limit;
-
+	struct clk *clk;
 };
 
 #define TX_BW_CONTROL_ABSENT		0
@@ -410,9 +410,7 @@ struct mv643xx_eth_private {
 	/*
 	 * Hardware-specific parameters.
 	 */
-#if defined(CONFIG_HAVE_CLK)
 	struct clk *clk;
-#endif
 	unsigned int t_clk;
 };
 
@@ -2569,6 +2567,10 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (msp->base == NULL)
 		goto out_free;
 
+	msp->clk = devm_clk_get(&pdev->dev, NULL);
+	if (!IS_ERR(msp->clk))
+		clk_prepare_enable(msp->clk);
+
 	/*
 	 * (Re-)program MBUS remapping windows if we are asked to.
 	 */
@@ -2595,6 +2597,8 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 	struct mv643xx_eth_shared_private *msp = platform_get_drvdata(pdev);
 
 	iounmap(msp->base);
+	if (!IS_ERR(msp->clk))
+		clk_disable_unprepare(msp->clk);
 	kfree(msp);
 
 	return 0;
@@ -2801,13 +2805,12 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	 * it to override the default.
 	 */
 	mp->t_clk = 133000000;
-#if defined(CONFIG_HAVE_CLK)
-	mp->clk = clk_get(&pdev->dev, (pdev->id ? "1" : "0"));
+	mp->clk = devm_clk_get(&pdev->dev, NULL);
 	if (!IS_ERR(mp->clk)) {
 		clk_prepare_enable(mp->clk);
 		mp->t_clk = clk_get_rate(mp->clk);
 	}
-#endif
+
 	set_params(mp, pd);
 	netif_set_real_num_tx_queues(dev, mp->txq_count);
 	netif_set_real_num_rx_queues(dev, mp->rxq_count);
@@ -2889,12 +2892,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	return 0;
 
 out:
-#if defined(CONFIG_HAVE_CLK)
-	if (!IS_ERR(mp->clk)) {
+	if (!IS_ERR(mp->clk))
 		clk_disable_unprepare(mp->clk);
-		clk_put(mp->clk);
-	}
-#endif
 	free_netdev(dev);
 
 	return err;
@@ -2909,12 +2908,8 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 		phy_detach(mp->phy);
 	cancel_work_sync(&mp->tx_timeout_task);
 
-#if defined(CONFIG_HAVE_CLK)
-	if (!IS_ERR(mp->clk)) {
+	if (!IS_ERR(mp->clk))
 		clk_disable_unprepare(mp->clk);
-		clk_put(mp->clk);
-	}
-#endif
 
 	free_netdev(mp->dev);
 
-- 
1.7.10.4
