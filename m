From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 7/8] net/mlx5e: Support ethtool get/set_pauseparam
Date: Sun, 16 Aug 2015 16:04:51 +0300
Message-ID: <1439730292-29617-8-git-send-email-achiad@mellanox.com>
References: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38395 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751420AbbHPNHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 09:07:04 -0400
In-Reply-To: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only rx/tx pause settings.
Autoneg setting is currently not supported.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 38 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/port.c     | 42 ++++++++++++++++++++++
 include/linux/mlx5/driver.h                        |  5 +++
 3 files changed, 85 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 77158b3..bce9126 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -820,6 +820,42 @@ static int mlx5e_set_tunable(struct net_device *dev,
 	return err;
 }
 
+static void mlx5e_get_pauseparam(struct net_device *netdev,
+				 struct ethtool_pauseparam *pauseparam)
+{
+	struct mlx5e_priv *priv    = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int err;
+
+	err = mlx5_query_port_pause(mdev, &pauseparam->rx_pause,
+				    &pauseparam->tx_pause);
+	if (err) {
+		netdev_err(netdev, "%s: mlx5_query_port_pause failed:0x%x\n",
+			   __func__, err);
+	}
+}
+
+static int mlx5e_set_pauseparam(struct net_device *netdev,
+				struct ethtool_pauseparam *pauseparam)
+{
+	struct mlx5e_priv *priv    = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int err;
+
+	if (pauseparam->autoneg)
+		return -EINVAL;
+
+	err = mlx5_set_port_pause(mdev,
+				  pauseparam->rx_pause ? 1 : 0,
+				  pauseparam->tx_pause ? 1 : 0);
+	if (err) {
+		netdev_err(netdev, "%s: mlx5_set_port_pause failed:0x%x\n",
+			   __func__, err);
+	}
+
+	return err;
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
@@ -841,4 +877,6 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_rxnfc         = mlx5e_get_rxnfc,
 	.get_tunable       = mlx5e_get_tunable,
 	.set_tunable       = mlx5e_set_tunable,
+	.get_pauseparam    = mlx5e_get_pauseparam,
+	.set_pauseparam    = mlx5e_set_pauseparam,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index f8db52b..821caaa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -334,3 +334,45 @@ int mlx5_query_port_vl_hw_cap(struct mlx5_core_dev *dev,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_vl_hw_cap);
+
+int mlx5_set_port_pause(struct mlx5_core_dev *dev, u32 rx_pause, u32 tx_pause)
+{
+	u32 in[MLX5_ST_SZ_DW(pfcc_reg)];
+	u32 out[MLX5_ST_SZ_DW(pfcc_reg)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+	MLX5_SET(pfcc_reg, in, local_port, 1);
+	MLX5_SET(pfcc_reg, in, pptx, tx_pause);
+	MLX5_SET(pfcc_reg, in, pprx, rx_pause);
+
+	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
+				   sizeof(out), MLX5_REG_PFCC, 0, 1);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_set_port_pause);
+
+int mlx5_query_port_pause(struct mlx5_core_dev *dev,
+			  u32 *rx_pause, u32 *tx_pause)
+{
+	u32 in[MLX5_ST_SZ_DW(pfcc_reg)];
+	u32 out[MLX5_ST_SZ_DW(pfcc_reg)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+	MLX5_SET(pfcc_reg, in, local_port, 1);
+
+	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
+				   sizeof(out), MLX5_REG_PFCC, 0, 0);
+	if (err)
+		return err;
+
+	if (rx_pause)
+		*rx_pause = MLX5_GET(pfcc_reg, out, pprx);
+
+	if (tx_pause)
+		*tx_pause = MLX5_GET(pfcc_reg, out, pptx);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_port_pause);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 4b5d7fc..8b6d6f2 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -103,6 +103,7 @@ enum {
 	MLX5_REG_PMTU		 = 0x5003,
 	MLX5_REG_PTYS		 = 0x5004,
 	MLX5_REG_PAOS		 = 0x5006,
+	MLX5_REG_PFCC            = 0x5007,
 	MLX5_REG_PPCNT		 = 0x5008,
 	MLX5_REG_PMAOS		 = 0x5012,
 	MLX5_REG_PUDE		 = 0x5009,
@@ -774,6 +775,10 @@ void mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
 int mlx5_query_port_vl_hw_cap(struct mlx5_core_dev *dev,
 			      u8 *vl_hw_cap, u8 local_port);
 
+int mlx5_set_port_pause(struct mlx5_core_dev *dev, u32 rx_pause, u32 tx_pause);
+int mlx5_query_port_pause(struct mlx5_core_dev *dev,
+			  u32 *rx_pause, u32 *tx_pause);
+
 int mlx5_debug_eq_add(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 void mlx5_debug_eq_remove(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 int mlx5_core_eq_query(struct mlx5_core_dev *dev, struct mlx5_eq *eq,
-- 
1.8.3.1
