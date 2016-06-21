From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next] net/mlx4_en: Add DCB PFC support through CEE netlink commands
Date: Tue, 21 Jun 2016 12:43:59 +0300
Message-ID: <1466502239-8784-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Rana Shahout <ranas@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51093 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752354AbcFVOAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 10:00:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rana Shahout <ranas@mellanox.com>

This patch adds support for reading and updating priority flow
control (PFC) attributes in the driver via netlink.

Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 277 +++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  25 +++
 drivers/net/ethernet/mellanox/mlx4/fw.c        |   1 +
 drivers/net/ethernet/mellanox/mlx4/fw.h        |   1 +
 drivers/net/ethernet/mellanox/mlx4/main.c      |   1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  26 +++
 drivers/net/ethernet/mellanox/mlx4/port.c      |  12 ++
 include/linux/mlx4/device.h                    |   2 +
 8 files changed, 331 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index f01918c..99c6bbd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -37,6 +37,11 @@
 #include "mlx4_en.h"
 #include "fw_qos.h"
 
+enum {
+	MLX4_CEE_STATE_DOWN   = 0,
+	MLX4_CEE_STATE_UP     = 1,
+};
+
 /* Definitions for QCN
  */
 
@@ -80,13 +85,202 @@ struct mlx4_congestion_control_mb_prio_802_1_qau_statistics {
 	__be32 reserved3[4];
 };
 
+static u8 mlx4_en_dcbnl_getcap(struct net_device *dev, int capid, u8 *cap)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	switch (capid) {
+	case DCB_CAP_ATTR_PFC:
+		*cap = true;
+		break;
+	case DCB_CAP_ATTR_DCBX:
+		*cap = priv->cee_params.dcbx_cap;
+		break;
+	case DCB_CAP_ATTR_PFC_TCS:
+		*cap = 1 <<  mlx4_max_tc(priv->mdev->dev);
+		break;
+	default:
+		*cap = false;
+		break;
+	}
+
+	return 0;
+}
+
+static u8 mlx4_en_dcbnl_getpfcstate(struct net_device *netdev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(netdev);
+
+	return priv->cee_params.dcb_cfg.pfc_state;
+}
+
+static void mlx4_en_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
+{
+	struct mlx4_en_priv *priv = netdev_priv(netdev);
+
+	priv->cee_params.dcb_cfg.pfc_state = state;
+}
+
+static void mlx4_en_dcbnl_get_pfc_cfg(struct net_device *netdev, int priority,
+				      u8 *setting)
+{
+	struct mlx4_en_priv *priv = netdev_priv(netdev);
+
+	*setting = priv->cee_params.dcb_cfg.tc_config[priority].dcb_pfc;
+}
+
+static void mlx4_en_dcbnl_set_pfc_cfg(struct net_device *netdev, int priority,
+				      u8 setting)
+{
+	struct mlx4_en_priv *priv = netdev_priv(netdev);
+
+	priv->cee_params.dcb_cfg.tc_config[priority].dcb_pfc = setting;
+	priv->cee_params.dcb_cfg.pfc_state = true;
+}
+
+static int mlx4_en_dcbnl_getnumtcs(struct net_device *netdev, int tcid, u8 *num)
+{
+	struct mlx4_en_priv *priv = netdev_priv(netdev);
+
+	if (!(priv->flags & MLX4_EN_FLAG_DCB_ENABLED))
+		return -EINVAL;
+
+	if (tcid == DCB_NUMTCS_ATTR_PFC)
+		*num = mlx4_max_tc(priv->mdev->dev);
+	else
+		*num = 0;
+
+	return 0;
+}
+
+static u8 mlx4_en_dcbnl_set_all(struct net_device *netdev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(netdev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_cee_config *dcb_cfg = &priv->cee_params.dcb_cfg;
+	int err = 0;
+
+	if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
+		return -EINVAL;
+
+	if (dcb_cfg->pfc_state) {
+		int tc;
+
+		priv->prof->rx_pause = 0;
+		priv->prof->tx_pause = 0;
+		for (tc = 0; tc < CEE_DCBX_MAX_PRIO; tc++) {
+			u8 tc_mask = 1 << tc;
+
+			switch (dcb_cfg->tc_config[tc].dcb_pfc) {
+			case pfc_disabled:
+				priv->prof->tx_ppp &= ~tc_mask;
+				priv->prof->rx_ppp &= ~tc_mask;
+				break;
+			case pfc_enabled_full:
+				priv->prof->tx_ppp |= tc_mask;
+				priv->prof->rx_ppp |= tc_mask;
+				break;
+			case pfc_enabled_tx:
+				priv->prof->tx_ppp |= tc_mask;
+				priv->prof->rx_ppp &= ~tc_mask;
+				break;
+			case pfc_enabled_rx:
+				priv->prof->tx_ppp &= ~tc_mask;
+				priv->prof->rx_ppp |= tc_mask;
+				break;
+			default:
+				break;
+			}
+		}
+		en_dbg(DRV, priv, "Set pfc on\n");
+	} else {
+		priv->prof->rx_pause = 1;
+		priv->prof->tx_pause = 1;
+		en_dbg(DRV, priv, "Set pfc off\n");
+	}
+
+	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
+				    priv->rx_skb_size + ETH_FCS_LEN,
+				    priv->prof->tx_pause,
+				    priv->prof->tx_ppp,
+				    priv->prof->rx_pause,
+				    priv->prof->rx_ppp);
+	if (err)
+		en_err(priv, "Failed setting pause params\n");
+	return err;
+}
+
+static u8 mlx4_en_dcbnl_get_state(struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	if (priv->flags & MLX4_EN_FLAG_DCB_ENABLED)
+		return MLX4_CEE_STATE_UP;
+
+	return MLX4_CEE_STATE_DOWN;
+}
+
+static u8 mlx4_en_dcbnl_set_state(struct net_device *dev, u8 state)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int num_tcs = 0;
+
+	if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
+		return 1;
+
+	if (!!(state) == !!(priv->flags & MLX4_EN_FLAG_DCB_ENABLED))
+		return 0;
+
+	if (state) {
+		priv->flags |= MLX4_EN_FLAG_DCB_ENABLED;
+		num_tcs = IEEE_8021QAZ_MAX_TCS;
+	} else {
+		priv->flags &= ~MLX4_EN_FLAG_DCB_ENABLED;
+	}
+
+	return mlx4_en_setup_tc(dev, num_tcs);
+}
+
+/* On success returns a non-zero 802.1p user priority bitmap
+ * otherwise returns 0 as the invalid user priority bitmap to
+ * indicate an error.
+ */
+static int mlx4_en_dcbnl_getapp(struct net_device *netdev, u8 idtype, u16 id)
+{
+	struct mlx4_en_priv *priv = netdev_priv(netdev);
+	struct dcb_app app = {
+				.selector = idtype,
+				.protocol = id,
+			     };
+	if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
+		return 0;
+
+	return dcb_getapp(netdev, &app);
+}
+
+static int mlx4_en_dcbnl_setapp(struct net_device *netdev, u8 idtype,
+				u16 id, u8 up)
+{
+	struct mlx4_en_priv *priv = netdev_priv(netdev);
+	struct dcb_app app;
+
+	if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
+		return -EINVAL;
+
+	memset(&app, 0, sizeof(struct dcb_app));
+	app.selector = idtype;
+	app.protocol = id;
+	app.priority = up;
+
+	return dcb_setapp(netdev, &app);
+}
+
 static int mlx4_en_dcbnl_ieee_getets(struct net_device *dev,
 				   struct ieee_ets *ets)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct ieee_ets *my_ets = &priv->ets;
 
-	/* No IEEE PFC settings available */
 	if (!my_ets)
 		return -EINVAL;
 
@@ -237,18 +431,51 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
 
 static u8 mlx4_en_dcbnl_getdcbx(struct net_device *dev)
 {
-	return DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE;
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	return priv->cee_params.dcbx_cap;
 }
 
 static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 {
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct ieee_ets ets = {0};
+	struct ieee_pfc pfc = {0};
+
+	if (mode == priv->cee_params.dcbx_cap)
+		return 0;
+
 	if ((mode & DCB_CAP_DCBX_LLD_MANAGED) ||
-	    (mode & DCB_CAP_DCBX_VER_CEE) ||
-	    !(mode & DCB_CAP_DCBX_VER_IEEE) ||
+	    ((mode & DCB_CAP_DCBX_VER_IEEE) &&
+	     (mode & DCB_CAP_DCBX_VER_CEE)) ||
 	    !(mode & DCB_CAP_DCBX_HOST))
-		return 1;
+		goto err;
+
+	priv->cee_params.dcbx_cap = mode;
+
+	ets.ets_cap = IEEE_8021QAZ_MAX_TCS;
+	pfc.pfc_cap = IEEE_8021QAZ_MAX_TCS;
+
+	if (mode & DCB_CAP_DCBX_VER_IEEE) {
+		if (mlx4_en_dcbnl_ieee_setets(dev, &ets))
+			goto err;
+		if (mlx4_en_dcbnl_ieee_setpfc(dev, &pfc))
+			goto err;
+	} else if (mode & DCB_CAP_DCBX_VER_CEE) {
+		if (mlx4_en_dcbnl_set_all(dev))
+			goto err;
+	} else {
+		if (mlx4_en_dcbnl_ieee_setets(dev, &ets))
+			goto err;
+		if (mlx4_en_dcbnl_ieee_setpfc(dev, &pfc))
+			goto err;
+		if (mlx4_en_setup_tc(dev, 0))
+			goto err;
+	}
 
 	return 0;
+err:
+	return 1;
 }
 
 #define MLX4_RATELIMIT_UNITS_IN_KB 100000 /* rate-limit HW unit in Kbps */
@@ -463,24 +690,46 @@ static int mlx4_en_dcbnl_ieee_getqcnstats(struct net_device *dev,
 }
 
 const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops = {
-	.ieee_getets	= mlx4_en_dcbnl_ieee_getets,
-	.ieee_setets	= mlx4_en_dcbnl_ieee_setets,
-	.ieee_getmaxrate = mlx4_en_dcbnl_ieee_getmaxrate,
-	.ieee_setmaxrate = mlx4_en_dcbnl_ieee_setmaxrate,
-	.ieee_getpfc	= mlx4_en_dcbnl_ieee_getpfc,
-	.ieee_setpfc	= mlx4_en_dcbnl_ieee_setpfc,
+	.ieee_getets		= mlx4_en_dcbnl_ieee_getets,
+	.ieee_setets		= mlx4_en_dcbnl_ieee_setets,
+	.ieee_getmaxrate	= mlx4_en_dcbnl_ieee_getmaxrate,
+	.ieee_setmaxrate	= mlx4_en_dcbnl_ieee_setmaxrate,
+	.ieee_getqcn		= mlx4_en_dcbnl_ieee_getqcn,
+	.ieee_setqcn		= mlx4_en_dcbnl_ieee_setqcn,
+	.ieee_getqcnstats	= mlx4_en_dcbnl_ieee_getqcnstats,
+	.ieee_getpfc		= mlx4_en_dcbnl_ieee_getpfc,
+	.ieee_setpfc		= mlx4_en_dcbnl_ieee_setpfc,
+
+	.getstate	= mlx4_en_dcbnl_get_state,
+	.setstate	= mlx4_en_dcbnl_set_state,
+	.getpfccfg	= mlx4_en_dcbnl_get_pfc_cfg,
+	.setpfccfg	= mlx4_en_dcbnl_set_pfc_cfg,
+	.setall		= mlx4_en_dcbnl_set_all,
+	.getcap		= mlx4_en_dcbnl_getcap,
+	.getnumtcs	= mlx4_en_dcbnl_getnumtcs,
+	.getpfcstate	= mlx4_en_dcbnl_getpfcstate,
+	.setpfcstate	= mlx4_en_dcbnl_setpfcstate,
+	.getapp		= mlx4_en_dcbnl_getapp,
+	.setapp		= mlx4_en_dcbnl_setapp,
 
 	.getdcbx	= mlx4_en_dcbnl_getdcbx,
 	.setdcbx	= mlx4_en_dcbnl_setdcbx,
-	.ieee_getqcn	= mlx4_en_dcbnl_ieee_getqcn,
-	.ieee_setqcn	= mlx4_en_dcbnl_ieee_setqcn,
-	.ieee_getqcnstats = mlx4_en_dcbnl_ieee_getqcnstats,
 };
 
 const struct dcbnl_rtnl_ops mlx4_en_dcbnl_pfc_ops = {
 	.ieee_getpfc	= mlx4_en_dcbnl_ieee_getpfc,
 	.ieee_setpfc	= mlx4_en_dcbnl_ieee_setpfc,
 
+	.setstate	= mlx4_en_dcbnl_set_state,
+	.getpfccfg	= mlx4_en_dcbnl_get_pfc_cfg,
+	.setpfccfg	= mlx4_en_dcbnl_set_pfc_cfg,
+	.setall		= mlx4_en_dcbnl_set_all,
+	.getnumtcs	= mlx4_en_dcbnl_getnumtcs,
+	.getpfcstate	= mlx4_en_dcbnl_getpfcstate,
+	.setpfcstate	= mlx4_en_dcbnl_setpfcstate,
+	.getapp		= mlx4_en_dcbnl_getapp,
+	.setapp		= mlx4_en_dcbnl_setapp,
+
 	.getdcbx	= mlx4_en_dcbnl_getdcbx,
 	.setdcbx	= mlx4_en_dcbnl_setdcbx,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 8e318d2..d42083a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -67,6 +67,17 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 		offset += priv->num_tx_rings_p_up;
 	}
 
+#ifdef CONFIG_MLX4_EN_DCB
+	if (!mlx4_is_slave(priv->mdev->dev)) {
+		if (up) {
+			priv->flags |= MLX4_EN_FLAG_DCB_ENABLED;
+		} else {
+			priv->flags &= ~MLX4_EN_FLAG_DCB_ENABLED;
+			priv->cee_params.dcb_cfg.pfc_state = false;
+		}
+	}
+#endif /* CONFIG_MLX4_EN_DCB */
+
 	return 0;
 }
 
@@ -2815,6 +2826,9 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	struct mlx4_en_priv *priv;
 	int i;
 	int err;
+#ifdef CONFIG_MLX4_EN_DCB
+	struct tc_configuration *tc;
+#endif
 
 	dev = alloc_etherdev_mqs(sizeof(struct mlx4_en_priv),
 				 MAX_TX_RINGS, MAX_RX_RINGS);
@@ -2881,6 +2895,17 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->msg_enable = MLX4_EN_MSG_LEVEL;
 #ifdef CONFIG_MLX4_EN_DCB
 	if (!mlx4_is_slave(priv->mdev->dev)) {
+		priv->cee_params.dcbx_cap = DCB_CAP_DCBX_VER_CEE |
+					    DCB_CAP_DCBX_HOST |
+					    DCB_CAP_DCBX_VER_IEEE;
+		priv->flags |= MLX4_EN_DCB_ENABLED;
+		priv->cee_params.dcb_cfg.pfc_state = false;
+
+		for (i = 0; i < MLX4_EN_NUM_UP; i++) {
+			tc = &priv->cee_params.dcb_cfg.tc_config[i];
+			tc->dcb_pfc = pfc_disabled;
+		}
+
 		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_ETS_CFG) {
 			dev->dcbnl_ops = &mlx4_en_dcbnl_ops;
 		} else {
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index e970945..f4497cf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1128,6 +1128,7 @@ int mlx4_QUERY_PORT(struct mlx4_dev *dev, int port, struct mlx4_port_cap *port_c
 		port_cap->max_pkeys	   = 1 << (field & 0xf);
 		MLX4_GET(field, outbox, QUERY_PORT_MAX_VL_OFFSET);
 		port_cap->max_vl	   = field & 0xf;
+		port_cap->max_tc_eth	   = field >> 4;
 		MLX4_GET(field, outbox, QUERY_PORT_MAX_MACVLAN_OFFSET);
 		port_cap->log_max_macs  = field & 0xf;
 		port_cap->log_max_vlans = field >> 4;
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 7ea258a..cdbd76f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -53,6 +53,7 @@ struct mlx4_port_cap {
 	int ib_mtu;
 	int max_port_width;
 	int max_vl;
+	int max_tc_eth;
 	int max_gids;
 	int max_pkeys;
 	u64 def_mac;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 12c77a7..3564aad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -292,6 +292,7 @@ static int _mlx4_dev_port(struct mlx4_dev *dev, int port,
 	dev->caps.pkey_table_len[port] = port_cap->max_pkeys;
 	dev->caps.port_width_cap[port] = port_cap->max_port_width;
 	dev->caps.eth_mtu_cap[port]    = port_cap->eth_mtu;
+	dev->caps.max_tc_eth	       = port_cap->max_tc_eth;
 	dev->caps.def_mac[port]        = port_cap->def_mac;
 	dev->caps.supported_type[port] = port_cap->supported_port_types;
 	dev->caps.suggested_type[port] = port_cap->suggested_type;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 6b3b0fe..d39bf59 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -448,6 +448,27 @@ struct mlx4_en_frag_info {
 
 #define MLX4_EN_TC_ETS 7
 
+enum dcb_pfc_type {
+	pfc_disabled = 0,
+	pfc_enabled_full,
+	pfc_enabled_tx,
+	pfc_enabled_rx
+};
+
+struct tc_configuration {
+	enum dcb_pfc_type  dcb_pfc;
+};
+
+struct mlx4_en_cee_config {
+	bool	pfc_state;
+	struct	tc_configuration tc_config[MLX4_EN_NUM_UP];
+};
+
+struct mlx4_en_cee_params {
+	u8 dcbx_cap;
+	struct mlx4_en_cee_config dcb_cfg;
+};
+
 #endif
 
 struct ethtool_flow_id {
@@ -467,6 +488,9 @@ enum {
 	MLX4_EN_FLAG_RX_FILTER_NEEDED	= (1 << 3),
 	MLX4_EN_FLAG_FORCE_PROMISC	= (1 << 4),
 	MLX4_EN_FLAG_RX_CSUM_NON_TCP_UDP	= (1 << 5),
+#ifdef CONFIG_MLX4_EN_DCB
+	MLX4_EN_FLAG_DCB_ENABLED        = (1 << 6),
+#endif
 };
 
 #define PORT_BEACON_MAX_LIMIT (65535)
@@ -568,9 +592,11 @@ struct mlx4_en_priv {
 	u32 counter_index;
 
 #ifdef CONFIG_MLX4_EN_DCB
+#define MLX4_EN_DCB_ENABLED	0x3
 	struct ieee_ets ets;
 	u16 maxrate[IEEE_8021QAZ_MAX_TCS];
 	enum dcbnl_cndd_states cndd_state[IEEE_8021QAZ_MAX_TCS];
+	struct mlx4_en_cee_params cee_params;
 #endif
 #ifdef CONFIG_RFS_ACCEL
 	spinlock_t filters_lock;
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 087b23b..3d2095e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -52,6 +52,7 @@
 
 #define MLX4_FLAG_V_IGNORE_FCS_MASK		0x2
 #define MLX4_IGNORE_FCS_MASK			0x1
+#define MLNX4_TX_MAX_NUMBER			8
 
 void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table)
 {
@@ -2015,3 +2016,14 @@ out:
 	return ret;
 }
 EXPORT_SYMBOL(mlx4_get_module_info);
+
+int mlx4_max_tc(struct mlx4_dev *dev)
+{
+	u8 num_tc = dev->caps.max_tc_eth;
+
+	if (!num_tc)
+		num_tc = MLNX4_TX_MAX_NUMBER;
+
+	return num_tc;
+}
+EXPORT_SYMBOL(mlx4_max_tc);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 80dec87..4dbc145 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -535,6 +535,7 @@ struct mlx4_caps {
 	int			max_rq_desc_sz;
 	int			max_qp_init_rdma;
 	int			max_qp_dest_rdma;
+	int			max_tc_eth;
 	u32			*qp0_qkey;
 	u32			*qp0_proxy;
 	u32			*qp1_proxy;
@@ -1494,6 +1495,7 @@ int mlx4_mr_rereg_mem_write(struct mlx4_dev *dev, struct mlx4_mr *mr,
 
 int mlx4_get_module_info(struct mlx4_dev *dev, u8 port,
 			 u16 offset, u16 size, u8 *data);
+int mlx4_max_tc(struct mlx4_dev *dev);
 
 /* Returns true if running in low memory profile (kdump kernel) */
 static inline bool mlx4_low_memory_profile(void)
-- 
1.8.3.1
