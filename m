From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net] dwc_eth_qos: do not register semi-initialized device
Date: Thu,  8 Sep 2016 13:24:21 +0200
Message-ID: <1473333861-1319-1-git-send-email-larper@axis.com>
Cc: linux-kernel@vger.kernel.org, andrianov@ispras.ru,
        Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We move register_netdev() to the end of dwceqos_probe() to close any
races where the netdev callbacks are called before the initialization
has finished.

Reported-by: Pavel Andrianov <andrianov@ispras.ru>
Signed-off-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 38 ++++++++++++++---------------
 1 file changed, 18 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 5a3941b..4490eba 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -1246,7 +1246,7 @@ static int dwceqos_mii_init(struct net_local *lp)
 	lp->mii_bus->read  = &dwceqos_mdio_read;
 	lp->mii_bus->write = &dwceqos_mdio_write;
 	lp->mii_bus->priv = lp;
-	lp->mii_bus->parent = &lp->ndev->dev;
+	lp->mii_bus->parent = &lp->pdev->dev;
 
 	of_address_to_resource(lp->pdev->dev.of_node, 0, &res);
 	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "%.8llx",
@@ -2853,25 +2853,17 @@ static int dwceqos_probe(struct platform_device *pdev)
 
 	ndev->features = ndev->hw_features;
 
-	netif_napi_add(ndev, &lp->napi, dwceqos_rx_poll, NAPI_POLL_WEIGHT);
-
-	ret = register_netdev(ndev);
-	if (ret) {
-		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-		goto err_out_clk_dis_aper;
-	}
-
 	lp->phy_ref_clk = devm_clk_get(&pdev->dev, "phy_ref_clk");
 	if (IS_ERR(lp->phy_ref_clk)) {
 		dev_err(&pdev->dev, "phy_ref_clk clock not found.\n");
 		ret = PTR_ERR(lp->phy_ref_clk);
-		goto err_out_unregister_netdev;
+		goto err_out_clk_dis_aper;
 	}
 
 	ret = clk_prepare_enable(lp->phy_ref_clk);
 	if (ret) {
 		dev_err(&pdev->dev, "Unable to enable device clock.\n");
-		goto err_out_unregister_netdev;
+		goto err_out_clk_dis_aper;
 	}
 
 	lp->phy_node = of_parse_phandle(lp->pdev->dev.of_node,
@@ -2880,7 +2872,7 @@ static int dwceqos_probe(struct platform_device *pdev)
 		ret = of_phy_register_fixed_link(lp->pdev->dev.of_node);
 		if (ret < 0) {
 			dev_err(&pdev->dev, "invalid fixed-link");
-			goto err_out_unregister_clk_notifier;
+			goto err_out_clk_dis_phy;
 		}
 
 		lp->phy_node = of_node_get(lp->pdev->dev.of_node);
@@ -2889,7 +2881,7 @@ static int dwceqos_probe(struct platform_device *pdev)
 	ret = of_get_phy_mode(lp->pdev->dev.of_node);
 	if (ret < 0) {
 		dev_err(&lp->pdev->dev, "error in getting phy i/f\n");
-		goto err_out_unregister_clk_notifier;
+		goto err_out_clk_dis_phy;
 	}
 
 	lp->phy_interface = ret;
@@ -2897,14 +2889,14 @@ static int dwceqos_probe(struct platform_device *pdev)
 	ret = dwceqos_mii_init(lp);
 	if (ret) {
 		dev_err(&lp->pdev->dev, "error in dwceqos_mii_init\n");
-		goto err_out_unregister_clk_notifier;
+		goto err_out_clk_dis_phy;
 	}
 
 	ret = dwceqos_mii_probe(ndev);
 	if (ret != 0) {
 		netdev_err(ndev, "mii_probe fail.\n");
 		ret = -ENXIO;
-		goto err_out_unregister_clk_notifier;
+		goto err_out_clk_dis_phy;
 	}
 
 	dwceqos_set_umac_addr(lp, lp->ndev->dev_addr, 0);
@@ -2922,7 +2914,7 @@ static int dwceqos_probe(struct platform_device *pdev)
 	if (ret) {
 		dev_err(&lp->pdev->dev, "Unable to retrieve DT, error %d\n",
 			ret);
-		goto err_out_unregister_clk_notifier;
+		goto err_out_clk_dis_phy;
 	}
 	dev_info(&lp->pdev->dev, "pdev->id %d, baseaddr 0x%08lx, irq %d\n",
 		 pdev->id, ndev->base_addr, ndev->irq);
@@ -2932,18 +2924,24 @@ static int dwceqos_probe(struct platform_device *pdev)
 	if (ret) {
 		dev_err(&lp->pdev->dev, "Unable to request IRQ %d, error %d\n",
 			ndev->irq, ret);
-		goto err_out_unregister_clk_notifier;
+		goto err_out_clk_dis_phy;
 	}
 
 	if (netif_msg_probe(lp))
 		netdev_dbg(ndev, "net_local@%p\n", lp);
 
+	netif_napi_add(ndev, &lp->napi, dwceqos_rx_poll, NAPI_POLL_WEIGHT);
+
+	ret = register_netdev(ndev);
+	if (ret) {
+		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
+			goto err_out_clk_dis_phy;
+	}
+
 	return 0;
 
-err_out_unregister_clk_notifier:
+err_out_clk_dis_phy:
 	clk_disable_unprepare(lp->phy_ref_clk);
-err_out_unregister_netdev:
-	unregister_netdev(ndev);
 err_out_clk_dis_aper:
 	clk_disable_unprepare(lp->apb_pclk);
 err_out_free_netdev:
-- 
2.1.4
