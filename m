From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v3 06/13] net: ethernet: ti: cpsw: create common struct to hold shared driver data
Date: Wed, 10 Aug 2016 02:22:37 +0300
Message-ID: <1470784964-26440-7-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch simply create holder for common data and as a start moves
pdev var to it.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 62 ++++++++++++++++++++++++++----------------
 1 file changed, 39 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index cfbb1f2..3ccf577 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -363,8 +363,11 @@ static inline void slave_write(struct cpsw_slave *slave, u32 val, u32 offset)
 	__raw_writel(val, slave->regs + offset);
 }
 
-struct cpsw_priv {
+struct cpsw_common {
 	struct platform_device		*pdev;
+};
+
+struct cpsw_priv {
 	struct net_device		*ndev;
 	struct napi_struct		napi_rx;
 	struct napi_struct		napi_tx;
@@ -394,6 +397,7 @@ struct cpsw_priv {
 	u32 num_irqs;
 	struct cpts *cpts;
 	u32 emac_port;
+	struct cpsw_common *cpsw;
 };
 
 struct cpsw_stats {
@@ -484,6 +488,7 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 
 #define CPSW_STATS_LEN	ARRAY_SIZE(cpsw_gstrings_stats)
 
+#define ndev_to_cpsw(ndev) (((struct cpsw_priv *)netdev_priv(ndev))->cpsw)
 #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
 #define for_each_slave(priv, func, arg...)				\
 	do {								\
@@ -1091,6 +1096,7 @@ static void soft_reset_slave(struct cpsw_slave *slave)
 static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 {
 	u32 slave_port;
+	struct cpsw_common *cpsw = priv->cpsw;
 
 	soft_reset_slave(slave);
 
@@ -1149,7 +1155,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	phy_start(slave->phy);
 
 	/* Configure GMII_SEL register */
-	cpsw_phy_sel(&priv->pdev->dev, slave->phy->interface, slave->slave_num);
+	cpsw_phy_sel(&cpsw->pdev->dev, slave->phy->interface, slave->slave_num);
 }
 
 static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
@@ -1231,12 +1237,13 @@ static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
 static int cpsw_ndo_open(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
 	int i, ret;
 	u32 reg;
 
-	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&priv->pdev->dev);
+		pm_runtime_put_noidle(&cpsw->pdev->dev);
 		return ret;
 	}
 
@@ -1313,7 +1320,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		 */
 		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 
-		if (cpts_register(&priv->pdev->dev, priv->cpts,
+		if (cpts_register(&cpsw->pdev->dev, priv->cpts,
 				  priv->data.cpts_clock_mult,
 				  priv->data.cpts_clock_shift))
 			dev_err(priv->dev, "error registering cpts device\n");
@@ -1338,7 +1345,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 err_cleanup:
 	cpdma_ctlr_stop(priv->dma);
 	for_each_slave(priv, cpsw_slave_stop, priv);
-	pm_runtime_put_sync(&priv->pdev->dev);
+	pm_runtime_put_sync(&cpsw->pdev->dev);
 	netif_carrier_off(priv->ndev);
 	return ret;
 }
@@ -1346,6 +1353,7 @@ err_cleanup:
 static int cpsw_ndo_stop(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
 
 	cpsw_info(priv, ifdown, "shutting down cpsw device\n");
 	netif_stop_queue(priv->ndev);
@@ -1362,7 +1370,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 		cpsw_ale_stop(priv->ale);
 	}
 	for_each_slave(priv, cpsw_slave_stop, priv);
-	pm_runtime_put_sync(&priv->pdev->dev);
+	pm_runtime_put_sync(&cpsw->pdev->dev);
 	if (priv->data.dual_emac)
 		priv->slaves[priv->emac_port].open_stat = false;
 	return 0;
@@ -1594,6 +1602,7 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct sockaddr *addr = (struct sockaddr *)p;
+	struct cpsw_common *cpsw = priv->cpsw;
 	int flags = 0;
 	u16 vid = 0;
 	int ret;
@@ -1601,9 +1610,9 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&priv->pdev->dev);
+		pm_runtime_put_noidle(&cpsw->pdev->dev);
 		return ret;
 	}
 
@@ -1621,7 +1630,7 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
 	for_each_slave(priv, cpsw_set_slave_mac, priv);
 
-	pm_runtime_put(&priv->pdev->dev);
+	pm_runtime_put(&cpsw->pdev->dev);
 
 	return 0;
 }
@@ -1687,14 +1696,15 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 				    __be16 proto, u16 vid)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
 	int ret;
 
 	if (vid == priv->data.default_vlan)
 		return 0;
 
-	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&priv->pdev->dev);
+		pm_runtime_put_noidle(&cpsw->pdev->dev);
 		return ret;
 	}
 
@@ -1714,7 +1724,7 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 	dev_info(priv->dev, "Adding vlanid %d to vlan filter\n", vid);
 	ret = cpsw_add_vlan_ale_entry(priv, vid);
 
-	pm_runtime_put(&priv->pdev->dev);
+	pm_runtime_put(&cpsw->pdev->dev);
 	return ret;
 }
 
@@ -1722,14 +1732,15 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 				     __be16 proto, u16 vid)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
 	int ret;
 
 	if (vid == priv->data.default_vlan)
 		return 0;
 
-	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&priv->pdev->dev);
+		pm_runtime_put_noidle(&cpsw->pdev->dev);
 		return ret;
 	}
 
@@ -1754,7 +1765,7 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 
 	ret = cpsw_ale_del_mcast(priv->ale, priv->ndev->broadcast,
 				 0, ALE_VLAN, vid);
-	pm_runtime_put(&priv->pdev->dev);
+	pm_runtime_put(&cpsw->pdev->dev);
 	return ret;
 }
 
@@ -1797,11 +1808,11 @@ static void cpsw_get_regs(struct net_device *ndev,
 static void cpsw_get_drvinfo(struct net_device *ndev,
 			     struct ethtool_drvinfo *info)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
 
 	strlcpy(info->driver, "cpsw", sizeof(info->driver));
 	strlcpy(info->version, "1.0", sizeof(info->version));
-	strlcpy(info->bus_info, priv->pdev->name, sizeof(info->bus_info));
+	strlcpy(info->bus_info, cpsw->pdev->name, sizeof(info->bus_info));
 }
 
 static u32 cpsw_get_msglevel(struct net_device *ndev)
@@ -1920,12 +1931,13 @@ static int cpsw_set_pauseparam(struct net_device *ndev,
 static int cpsw_ethtool_op_begin(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
 	int ret;
 
-	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
 	if (ret < 0) {
 		cpsw_err(priv, drv, "ethtool begin failed %d\n", ret);
-		pm_runtime_put_noidle(&priv->pdev->dev);
+		pm_runtime_put_noidle(&cpsw->pdev->dev);
 	}
 
 	return ret;
@@ -1936,7 +1948,7 @@ static void cpsw_ethtool_op_complete(struct net_device *ndev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int ret;
 
-	ret = pm_runtime_put(&priv->pdev->dev);
+	ret = pm_runtime_put(&priv->cpsw->pdev->dev);
 	if (ret < 0)
 		cpsw_err(priv, drv, "ethtool complete failed %d\n", ret);
 }
@@ -2155,8 +2167,8 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	}
 
 	priv_sl2 = netdev_priv(ndev);
+	priv_sl2->cpsw = priv->cpsw;
 	priv_sl2->data = *data;
-	priv_sl2->pdev = pdev;
 	priv_sl2->ndev = ndev;
 	priv_sl2->dev  = &ndev->dev;
 	priv_sl2->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
@@ -2261,9 +2273,13 @@ static int cpsw_probe(struct platform_device *pdev)
 	const struct of_device_id	*of_id;
 	struct gpio_descs		*mode;
 	u32 slave_offset, sliver_offset, slave_size;
+	struct cpsw_common		*cpsw;
 	int ret = 0, i;
 	int irq;
 
+	cpsw = devm_kzalloc(&pdev->dev, sizeof(struct cpsw_common), GFP_KERNEL);
+	cpsw->pdev = pdev;
+
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
 	if (!ndev) {
 		dev_err(&pdev->dev, "error allocating net_device\n");
@@ -2272,7 +2288,7 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 	priv = netdev_priv(ndev);
-	priv->pdev = pdev;
+	priv->cpsw = cpsw;
 	priv->ndev = ndev;
 	priv->dev  = &ndev->dev;
 	priv->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
-- 
1.9.1
