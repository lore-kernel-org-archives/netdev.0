From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net V2 3/4] net/mlx4_en: Fixes for DCBX
Date: Sun, 11 Sep 2016 10:56:19 +0300
Message-ID: <1473580580-2323-4-git-send-email-tariqt@mellanox.com>
References: <1473580580-2323-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41825 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754335AbcIKH5D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 03:57:03 -0400
In-Reply-To: <1473580580-2323-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a capability check before enabling DCBX.
In addition, it re-organizes the relevant data structures,
and fixes a typo in a define.

Fixes: af7d51852631 ("net/mlx4_en: Add DCB PFC support through CEE netlink commands")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 31 +++++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 21 +++++++----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 15 +++----------
 drivers/net/ethernet/mellanox/mlx4/port.c      |  4 ++--
 4 files changed, 28 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 316a70714434..b04760a5034b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -94,7 +94,7 @@ static u8 mlx4_en_dcbnl_getcap(struct net_device *dev, int capid, u8 *cap)
 		*cap = true;
 		break;
 	case DCB_CAP_ATTR_DCBX:
-		*cap = priv->cee_params.dcbx_cap;
+		*cap = priv->dcbx_cap;
 		break;
 	case DCB_CAP_ATTR_PFC_TCS:
 		*cap = 1 <<  mlx4_max_tc(priv->mdev->dev);
@@ -111,14 +111,14 @@ static u8 mlx4_en_dcbnl_getpfcstate(struct net_device *netdev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
 
-	return priv->cee_params.dcb_cfg.pfc_state;
+	return priv->cee_config.pfc_state;
 }
 
 static void mlx4_en_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
 {
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
 
-	priv->cee_params.dcb_cfg.pfc_state = state;
+	priv->cee_config.pfc_state = state;
 }
 
 static void mlx4_en_dcbnl_get_pfc_cfg(struct net_device *netdev, int priority,
@@ -126,7 +126,7 @@ static void mlx4_en_dcbnl_get_pfc_cfg(struct net_device *netdev, int priority,
 {
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
 
-	*setting = priv->cee_params.dcb_cfg.tc_config[priority].dcb_pfc;
+	*setting = priv->cee_config.dcb_pfc[priority];
 }
 
 static void mlx4_en_dcbnl_set_pfc_cfg(struct net_device *netdev, int priority,
@@ -134,8 +134,8 @@ static void mlx4_en_dcbnl_set_pfc_cfg(struct net_device *netdev, int priority,
 {
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
 
-	priv->cee_params.dcb_cfg.tc_config[priority].dcb_pfc = setting;
-	priv->cee_params.dcb_cfg.pfc_state = true;
+	priv->cee_config.dcb_pfc[priority] = setting;
+	priv->cee_config.pfc_state = true;
 }
 
 static int mlx4_en_dcbnl_getnumtcs(struct net_device *netdev, int tcid, u8 *num)
@@ -157,12 +157,11 @@ static u8 mlx4_en_dcbnl_set_all(struct net_device *netdev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
 	struct mlx4_en_dev *mdev = priv->mdev;
-	struct mlx4_en_cee_config *dcb_cfg = &priv->cee_params.dcb_cfg;
 
-	if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
+	if (!(priv->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
 		return 1;
 
-	if (dcb_cfg->pfc_state) {
+	if (priv->cee_config.pfc_state) {
 		int tc;
 
 		priv->prof->rx_pause = 0;
@@ -170,7 +169,7 @@ static u8 mlx4_en_dcbnl_set_all(struct net_device *netdev)
 		for (tc = 0; tc < CEE_DCBX_MAX_PRIO; tc++) {
 			u8 tc_mask = 1 << tc;
 
-			switch (dcb_cfg->tc_config[tc].dcb_pfc) {
+			switch (priv->cee_config.dcb_pfc[tc]) {
 			case pfc_disabled:
 				priv->prof->tx_ppp &= ~tc_mask;
 				priv->prof->rx_ppp &= ~tc_mask;
@@ -226,7 +225,7 @@ static u8 mlx4_en_dcbnl_set_state(struct net_device *dev, u8 state)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int num_tcs = 0;
 
-	if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
+	if (!(priv->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
 		return 1;
 
 	if (!!(state) == !!(priv->flags & MLX4_EN_FLAG_DCB_ENABLED))
@@ -256,7 +255,7 @@ static int mlx4_en_dcbnl_getapp(struct net_device *netdev, u8 idtype, u16 id)
 				.selector = idtype,
 				.protocol = id,
 			     };
-	if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
+	if (!(priv->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
 		return 0;
 
 	return dcb_getapp(netdev, &app);
@@ -268,7 +267,7 @@ static int mlx4_en_dcbnl_setapp(struct net_device *netdev, u8 idtype,
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
 	struct dcb_app app;
 
-	if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
+	if (!(priv->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
 		return -EINVAL;
 
 	memset(&app, 0, sizeof(struct dcb_app));
@@ -437,7 +436,7 @@ static u8 mlx4_en_dcbnl_getdcbx(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
-	return priv->cee_params.dcbx_cap;
+	return priv->dcbx_cap;
 }
 
 static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
@@ -446,7 +445,7 @@ static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 	struct ieee_ets ets = {0};
 	struct ieee_pfc pfc = {0};
 
-	if (mode == priv->cee_params.dcbx_cap)
+	if (mode == priv->dcbx_cap)
 		return 0;
 
 	if ((mode & DCB_CAP_DCBX_LLD_MANAGED) ||
@@ -455,7 +454,7 @@ static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 	    !(mode & DCB_CAP_DCBX_HOST))
 		goto err;
 
-	priv->cee_params.dcbx_cap = mode;
+	priv->dcbx_cap = mode;
 
 	ets.ets_cap = IEEE_8021QAZ_MAX_TCS;
 	pfc.pfc_cap = IEEE_8021QAZ_MAX_TCS;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4198e9bf89d0..fedb829276f4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -71,10 +71,11 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 #ifdef CONFIG_MLX4_EN_DCB
 	if (!mlx4_is_slave(priv->mdev->dev)) {
 		if (up) {
-			priv->flags |= MLX4_EN_FLAG_DCB_ENABLED;
+			if (priv->dcbx_cap)
+				priv->flags |= MLX4_EN_FLAG_DCB_ENABLED;
 		} else {
 			priv->flags &= ~MLX4_EN_FLAG_DCB_ENABLED;
-			priv->cee_params.dcb_cfg.pfc_state = false;
+			priv->cee_config.pfc_state = false;
 		}
 	}
 #endif /* CONFIG_MLX4_EN_DCB */
@@ -3048,9 +3049,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	struct mlx4_en_priv *priv;
 	int i;
 	int err;
-#ifdef CONFIG_MLX4_EN_DCB
-	struct tc_configuration *tc;
-#endif
 
 	dev = alloc_etherdev_mqs(sizeof(struct mlx4_en_priv),
 				 MAX_TX_RINGS, MAX_RX_RINGS);
@@ -3117,16 +3115,13 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->msg_enable = MLX4_EN_MSG_LEVEL;
 #ifdef CONFIG_MLX4_EN_DCB
 	if (!mlx4_is_slave(priv->mdev->dev)) {
-		priv->cee_params.dcbx_cap = DCB_CAP_DCBX_VER_CEE |
-					    DCB_CAP_DCBX_HOST |
-					    DCB_CAP_DCBX_VER_IEEE;
+		priv->dcbx_cap = DCB_CAP_DCBX_VER_CEE | DCB_CAP_DCBX_HOST |
+			DCB_CAP_DCBX_VER_IEEE;
 		priv->flags |= MLX4_EN_DCB_ENABLED;
-		priv->cee_params.dcb_cfg.pfc_state = false;
+		priv->cee_config.pfc_state = false;
 
-		for (i = 0; i < MLX4_EN_NUM_UP; i++) {
-			tc = &priv->cee_params.dcb_cfg.tc_config[i];
-			tc->dcb_pfc = pfc_disabled;
-		}
+		for (i = 0; i < MLX4_EN_NUM_UP; i++)
+			priv->cee_config.dcb_pfc[i] = pfc_disabled;
 
 		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_ETS_CFG) {
 			dev->dcbnl_ops = &mlx4_en_dcbnl_ops;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 2c2913dcae98..9099dbd04951 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -482,20 +482,10 @@ enum dcb_pfc_type {
 	pfc_enabled_rx
 };
 
-struct tc_configuration {
-	enum dcb_pfc_type  dcb_pfc;
-};
-
 struct mlx4_en_cee_config {
 	bool	pfc_state;
-	struct	tc_configuration tc_config[MLX4_EN_NUM_UP];
+	enum	dcb_pfc_type dcb_pfc[MLX4_EN_NUM_UP];
 };
-
-struct mlx4_en_cee_params {
-	u8 dcbx_cap;
-	struct mlx4_en_cee_config dcb_cfg;
-};
-
 #endif
 
 struct ethtool_flow_id {
@@ -624,7 +614,8 @@ struct mlx4_en_priv {
 	struct ieee_ets ets;
 	u16 maxrate[IEEE_8021QAZ_MAX_TCS];
 	enum dcbnl_cndd_states cndd_state[IEEE_8021QAZ_MAX_TCS];
-	struct mlx4_en_cee_params cee_params;
+	struct mlx4_en_cee_config cee_config;
+	u8 dcbx_cap;
 #endif
 #ifdef CONFIG_RFS_ACCEL
 	spinlock_t filters_lock;
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 3d2095e5c61c..c5b2064297a1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -52,7 +52,7 @@
 
 #define MLX4_FLAG_V_IGNORE_FCS_MASK		0x2
 #define MLX4_IGNORE_FCS_MASK			0x1
-#define MLNX4_TX_MAX_NUMBER			8
+#define MLX4_TC_MAX_NUMBER			8
 
 void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table)
 {
@@ -2022,7 +2022,7 @@ int mlx4_max_tc(struct mlx4_dev *dev)
 	u8 num_tc = dev->caps.max_tc_eth;
 
 	if (!num_tc)
-		num_tc = MLNX4_TX_MAX_NUMBER;
+		num_tc = MLX4_TC_MAX_NUMBER;
 
 	return num_tc;
 }
-- 
1.8.3.1
