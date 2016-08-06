From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 07/14] net: ethernet: ti: cpsw: replace pdev on dev
Date: Sat,  6 Aug 2016 13:48:37 +0300
Message-ID: <1470480524-6851-8-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to hold pdev link when only dev is needed.
This allows to simplify a bunch of cpsw->pdev->dev now and farther.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 65 ++++++++++++++++++++++--------------------
 1 file changed, 34 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index ac875b3..a813bac 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -364,7 +364,7 @@ static inline void slave_write(struct cpsw_slave *slave, u32 val, u32 offset)
 }
 
 struct cpsw_common {
-	struct platform_device		*pdev;
+	struct device			*dev;
 };
 
 struct cpsw_priv {
@@ -1159,7 +1159,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	phy_start(slave->phy);
 
 	/* Configure GMII_SEL register */
-	cpsw_phy_sel(&cpsw->pdev->dev, slave->phy->interface, slave->slave_num);
+	cpsw_phy_sel(cpsw->dev, slave->phy->interface, slave->slave_num);
 }
 
 static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
@@ -1245,9 +1245,9 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	int i, ret;
 	u32 reg;
 
-	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
+	ret = pm_runtime_get_sync(cpsw->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&cpsw->pdev->dev);
+		pm_runtime_put_noidle(cpsw->dev);
 		return ret;
 	}
 
@@ -1324,7 +1324,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		 */
 		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 
-		if (cpts_register(&cpsw->pdev->dev, priv->cpts,
+		if (cpts_register(cpsw->dev, priv->cpts,
 				  priv->data.cpts_clock_mult,
 				  priv->data.cpts_clock_shift))
 			dev_err(priv->dev, "error registering cpts device\n");
@@ -1349,7 +1349,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 err_cleanup:
 	cpdma_ctlr_stop(priv->dma);
 	for_each_slave(priv, cpsw_slave_stop, priv);
-	pm_runtime_put_sync(&cpsw->pdev->dev);
+	pm_runtime_put_sync(cpsw->dev);
 	netif_carrier_off(priv->ndev);
 	return ret;
 }
@@ -1374,7 +1374,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 		cpsw_ale_stop(priv->ale);
 	}
 	for_each_slave(priv, cpsw_slave_stop, priv);
-	pm_runtime_put_sync(&cpsw->pdev->dev);
+	pm_runtime_put_sync(cpsw->dev);
 	if (priv->data.dual_emac)
 		priv->slaves[priv->emac_port].open_stat = false;
 	return 0;
@@ -1614,9 +1614,9 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
+	ret = pm_runtime_get_sync(cpsw->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&cpsw->pdev->dev);
+		pm_runtime_put_noidle(cpsw->dev);
 		return ret;
 	}
 
@@ -1634,7 +1634,7 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
 	for_each_slave(priv, cpsw_set_slave_mac, priv);
 
-	pm_runtime_put(&cpsw->pdev->dev);
+	pm_runtime_put(cpsw->dev);
 
 	return 0;
 }
@@ -1706,9 +1706,9 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 	if (vid == priv->data.default_vlan)
 		return 0;
 
-	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
+	ret = pm_runtime_get_sync(cpsw->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&cpsw->pdev->dev);
+		pm_runtime_put_noidle(cpsw->dev);
 		return ret;
 	}
 
@@ -1728,7 +1728,7 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 	dev_info(priv->dev, "Adding vlanid %d to vlan filter\n", vid);
 	ret = cpsw_add_vlan_ale_entry(priv, vid);
 
-	pm_runtime_put(&cpsw->pdev->dev);
+	pm_runtime_put(cpsw->dev);
 	return ret;
 }
 
@@ -1742,9 +1742,9 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 	if (vid == priv->data.default_vlan)
 		return 0;
 
-	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
+	ret = pm_runtime_get_sync(cpsw->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&cpsw->pdev->dev);
+		pm_runtime_put_noidle(cpsw->dev);
 		return ret;
 	}
 
@@ -1769,7 +1769,7 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 
 	ret = cpsw_ale_del_mcast(priv->ale, priv->ndev->broadcast,
 				 0, ALE_VLAN, vid);
-	pm_runtime_put(&cpsw->pdev->dev);
+	pm_runtime_put(cpsw->dev);
 	return ret;
 }
 
@@ -1813,10 +1813,11 @@ static void cpsw_get_drvinfo(struct net_device *ndev,
 			     struct ethtool_drvinfo *info)
 {
 	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
+	struct platform_device	*pdev = to_platform_device(cpsw->dev);
 
 	strlcpy(info->driver, "cpsw", sizeof(info->driver));
 	strlcpy(info->version, "1.0", sizeof(info->version));
-	strlcpy(info->bus_info, cpsw->pdev->name, sizeof(info->bus_info));
+	strlcpy(info->bus_info, pdev->name, sizeof(info->bus_info));
 }
 
 static u32 cpsw_get_msglevel(struct net_device *ndev)
@@ -1938,10 +1939,10 @@ static int cpsw_ethtool_op_begin(struct net_device *ndev)
 	struct cpsw_common *cpsw = priv->cpsw;
 	int ret;
 
-	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
+	ret = pm_runtime_get_sync(cpsw->dev);
 	if (ret < 0) {
 		cpsw_err(priv, drv, "ethtool begin failed %d\n", ret);
-		pm_runtime_put_noidle(&cpsw->pdev->dev);
+		pm_runtime_put_noidle(cpsw->dev);
 	}
 
 	return ret;
@@ -1952,7 +1953,7 @@ static void cpsw_ethtool_op_complete(struct net_device *ndev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int ret;
 
-	ret = pm_runtime_put(&priv->cpsw->pdev->dev);
+	ret = pm_runtime_put(priv->cpsw->dev);
 	if (ret < 0)
 		cpsw_err(priv, drv, "ethtool complete failed %d\n", ret);
 }
@@ -2156,17 +2157,17 @@ no_phy_slave:
 	return 0;
 }
 
-static int cpsw_probe_dual_emac(struct platform_device *pdev,
-				struct cpsw_priv *priv)
+static int cpsw_probe_dual_emac(struct cpsw_priv *priv)
 {
 	struct cpsw_platform_data	*data = &priv->data;
 	struct net_device		*ndev;
 	struct cpsw_priv		*priv_sl2;
 	int ret = 0, i;
+	struct cpsw_common		*cpsw = priv->cpsw;
 
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
 	if (!ndev) {
-		dev_err(&pdev->dev, "cpsw: error allocating net_device\n");
+		dev_err(cpsw->dev, "cpsw: error allocating net_device\n");
 		return -ENOMEM;
 	}
 
@@ -2181,10 +2182,12 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	if (is_valid_ether_addr(data->slave_data[1].mac_addr)) {
 		memcpy(priv_sl2->mac_addr, data->slave_data[1].mac_addr,
 			ETH_ALEN);
-		dev_info(&pdev->dev, "cpsw: Detected MACID = %pM\n", priv_sl2->mac_addr);
+		dev_info(cpsw->dev, "cpsw: Detected MACID = %pM\n",
+			 priv_sl2->mac_addr);
 	} else {
 		random_ether_addr(priv_sl2->mac_addr);
-		dev_info(&pdev->dev, "cpsw: Random MACID = %pM\n", priv_sl2->mac_addr);
+		dev_info(cpsw->dev, "cpsw: Random MACID = %pM\n",
+			 priv_sl2->mac_addr);
 	}
 	memcpy(ndev->dev_addr, priv_sl2->mac_addr, ETH_ALEN);
 
@@ -2215,10 +2218,10 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	ndev->ethtool_ops = &cpsw_ethtool_ops;
 
 	/* register the network device */
-	SET_NETDEV_DEV(ndev, &pdev->dev);
+	SET_NETDEV_DEV(ndev, cpsw->dev);
 	ret = register_netdev(ndev);
 	if (ret) {
-		dev_err(&pdev->dev, "cpsw: error registering net device\n");
+		dev_err(cpsw->dev, "cpsw: error registering net device\n");
 		free_netdev(ndev);
 		ret = -ENODEV;
 	}
@@ -2282,7 +2285,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	int irq;
 
 	cpsw = devm_kzalloc(&pdev->dev, sizeof(struct cpsw_common), GFP_KERNEL);
-	cpsw->pdev = pdev;
+	cpsw->dev = &pdev->dev;
 
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
 	if (!ndev) {
@@ -2545,7 +2548,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		    &ss_res->start, ndev->irq);
 
 	if (priv->data.dual_emac) {
-		ret = cpsw_probe_dual_emac(pdev, priv);
+		ret = cpsw_probe_dual_emac(priv);
 		if (ret) {
 			cpsw_err(priv, probe, "error probe slave 2 emac interface\n");
 			goto clean_ale_ret;
@@ -2612,7 +2615,7 @@ static int cpsw_suspend(struct device *dev)
 	}
 
 	/* Select sleep pin state */
-	pinctrl_pm_select_sleep_state(&pdev->dev);
+	pinctrl_pm_select_sleep_state(dev);
 
 	return 0;
 }
@@ -2624,7 +2627,7 @@ static int cpsw_resume(struct device *dev)
 	struct cpsw_priv	*priv = netdev_priv(ndev);
 
 	/* Select default pin state */
-	pinctrl_pm_select_default_state(&pdev->dev);
+	pinctrl_pm_select_default_state(dev);
 
 	if (priv->data.dual_emac) {
 		int i;
-- 
1.9.1
