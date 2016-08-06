From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 06/14] net: ethernet: ti: cpsw: create common struct to hold shared driver data
Date: Sat,  6 Aug 2016 13:48:36 +0300
Message-ID: <1470480524-6851-7-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:32999 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbcHFUKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2016 16:10:19 -0400
Received: by mail-lf0-f43.google.com with SMTP id b199so224355900lfe.0
        for <netdev@vger.kernel.org>; Sat, 06 Aug 2016 13:10:18 -0700 (PDT)
In-Reply-To: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch simply create holder for common data and as a start moves
pdev var to it.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 62 ++++++++++++++++++++++++++----------------
 1 file changed, 39 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 19aa4bb..ac875b3 100644
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
@@ -1095,6 +1100,7 @@ static void soft_reset_slave(struct cpsw_slave *slave)
 static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 {
 	u32 slave_port;
+	struct cpsw_common *cpsw = priv->cpsw;
 
 	soft_reset_slave(slave);
 
@@ -1153,7 +1159,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	phy_start(slave->phy);
 
 	/* Configure GMII_SEL register */
-	cpsw_phy_sel(&priv->pdev->dev, slave->phy->interface, slave->slave_num);
+	cpsw_phy_sel(&cpsw->pdev->dev, slave->phy->interface, slave->slave_num);
 }
 
 static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
@@ -1235,12 +1241,13 @@ static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
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
 
@@ -1317,7 +1324,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		 */
 		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 
-		if (cpts_register(&priv->pdev->dev, priv->cpts,
+		if (cpts_register(&cpsw->pdev->dev, priv->cpts,
 				  priv->data.cpts_clock_mult,
 				  priv->data.cpts_clock_shift))
 			dev_err(priv->dev, "error registering cpts device\n");
@@ -1342,7 +1349,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 err_cleanup:
 	cpdma_ctlr_stop(priv->dma);
 	for_each_slave(priv, cpsw_slave_stop, priv);
-	pm_runtime_put_sync(&priv->pdev->dev);
+	pm_runtime_put_sync(&cpsw->pdev->dev);
 	netif_carrier_off(priv->ndev);
 	return ret;
 }
@@ -1350,6 +1357,7 @@ err_cleanup:
 static int cpsw_ndo_stop(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
 
 	cpsw_info(priv, ifdown, "shutting down cpsw device\n");
 	netif_stop_queue(priv->ndev);
@@ -1366,7 +1374,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 		cpsw_ale_stop(priv->ale);
 	}
 	for_each_slave(priv, cpsw_slave_stop, priv);
-	pm_runtime_put_sync(&priv->pdev->dev);
+	pm_runtime_put_sync(&cpsw->pdev->dev);
 	if (priv->data.dual_emac)
 		priv->slaves[priv->emac_port].open_stat = false;
 	return 0;
@@ -1598,6 +1606,7 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct sockaddr *addr = (struct sockaddr *)p;
+	struct cpsw_common *cpsw = priv->cpsw;
 	int flags = 0;
 	u16 vid = 0;
 	int ret;
@@ -1605,9 +1614,9 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&priv->pdev->dev);
+		pm_runtime_put_noidle(&cpsw->pdev->dev);
 		return ret;
 	}
 
@@ -1625,7 +1634,7 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
 	for_each_slave(priv, cpsw_set_slave_mac, priv);
 
-	pm_runtime_put(&priv->pdev->dev);
+	pm_runtime_put(&cpsw->pdev->dev);
 
 	return 0;
 }
@@ -1691,14 +1700,15 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
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
 
@@ -1718,7 +1728,7 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 	dev_info(priv->dev, "Adding vlanid %d to vlan filter\n", vid);
 	ret = cpsw_add_vlan_ale_entry(priv, vid);
 
-	pm_runtime_put(&priv->pdev->dev);
+	pm_runtime_put(&cpsw->pdev->dev);
 	return ret;
 }
 
@@ -1726,14 +1736,15 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
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
 
@@ -1758,7 +1769,7 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 
 	ret = cpsw_ale_del_mcast(priv->ale, priv->ndev->broadcast,
 				 0, ALE_VLAN, vid);
-	pm_runtime_put(&priv->pdev->dev);
+	pm_runtime_put(&cpsw->pdev->dev);
 	return ret;
 }
 
@@ -1801,11 +1812,11 @@ static void cpsw_get_regs(struct net_device *ndev,
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
@@ -1924,12 +1935,13 @@ static int cpsw_set_pauseparam(struct net_device *ndev,
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
@@ -1940,7 +1952,7 @@ static void cpsw_ethtool_op_complete(struct net_device *ndev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int ret;
 
-	ret = pm_runtime_put(&priv->pdev->dev);
+	ret = pm_runtime_put(&priv->cpsw->pdev->dev);
 	if (ret < 0)
 		cpsw_err(priv, drv, "ethtool complete failed %d\n", ret);
 }
@@ -2159,8 +2171,8 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	}
 
 	priv_sl2 = netdev_priv(ndev);
+	priv_sl2->cpsw = priv->cpsw;
 	priv_sl2->data = *data;
-	priv_sl2->pdev = pdev;
 	priv_sl2->ndev = ndev;
 	priv_sl2->dev  = &ndev->dev;
 	priv_sl2->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
@@ -2265,9 +2277,13 @@ static int cpsw_probe(struct platform_device *pdev)
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
@@ -2276,7 +2292,7 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 	priv = netdev_priv(ndev);
-	priv->pdev = pdev;
+	priv->cpsw = cpsw;
 	priv->ndev = ndev;
 	priv->dev  = &ndev->dev;
 	priv->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
-- 
1.9.1
