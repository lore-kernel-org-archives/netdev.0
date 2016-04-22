From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 07/12] net/mlx5e: Add support for RXALL netdev feature
Date: Fri, 22 Apr 2016 22:00:42 +0300
Message-ID: <1461351647-27412-8-git-send-email-saeedm@mellanox.com>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36898 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751840AbcDVTCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 15:02:01 -0400
In-Reply-To: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Introduce new access register named Ports Check Mask Register (PCMR) to
control all HW checks on port. With this register, the driver can
enable/disable Hardware FCS validation.

When RXALL is enabled/disabled using ndo_set_features, enable/disable
fcs check at HW.
User can change HW configuration using rx-all flag at ethtool.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   20 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/port.c    |   49 +++++++++++++++++++++
 include/linux/mlx5/driver.h                       |    1 +
 include/linux/mlx5/port.h                         |    4 ++
 4 files changed, 74 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index d82bc6b..ad0cb4a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2139,6 +2139,14 @@ static int set_feature_tc_num_filters(struct net_device *netdev, bool enable)
 	return 0;
 }
 
+static int set_feature_rx_all(struct net_device *netdev, bool enable)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+
+	return mlx5_set_port_fcs(mdev, !enable);
+}
+
 static int mlx5e_handle_feature(struct net_device *netdev,
 				netdev_features_t wanted_features,
 				netdev_features_t feature,
@@ -2174,6 +2182,8 @@ static int mlx5e_set_features(struct net_device *netdev,
 				    set_feature_vlan_filter);
 	err |= mlx5e_handle_feature(netdev, features, NETIF_F_HW_TC,
 				    set_feature_tc_num_filters);
+	err |= mlx5e_handle_feature(netdev, features, NETIF_F_RXALL,
+				    set_feature_rx_all);
 
 	return err ? -EINVAL : 0;
 }
@@ -2564,6 +2574,8 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
+	bool fcs_supported;
+	bool fcs_enabled;
 
 	SET_NETDEV_DEV(netdev, &mdev->pdev->dev);
 
@@ -2607,10 +2619,18 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 		netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL;
 	}
 
+	mlx5_query_port_fcs(mdev, &fcs_supported, &fcs_enabled);
+
+	if (fcs_supported)
+		netdev->hw_features |= NETIF_F_RXALL;
+
 	netdev->features          = netdev->hw_features;
 	if (!priv->params.lro_en)
 		netdev->features  &= ~NETIF_F_LRO;
 
+	if (fcs_enabled)
+		netdev->features  &= ~NETIF_F_RXALL;
+
 #define FT_CAP(f) MLX5_CAP_FLOWTABLE(mdev, flow_table_properties_nic_receive.f)
 	if (FT_CAP(flow_modify_en) &&
 	    FT_CAP(modify_root) &&
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index ae378c5..c37740f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -607,3 +607,52 @@ int mlx5_query_port_wol(struct mlx5_core_dev *mdev, u8 *wol_mode)
 	return err;
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_wol);
+
+static int mlx5_query_ports_check(struct mlx5_core_dev *mdev, u32 *out,
+				  int outlen)
+{
+	u32 in[MLX5_ST_SZ_DW(pcmr_reg)];
+
+	memset(in, 0, sizeof(in));
+	MLX5_SET(pcmr_reg, in, local_port, 1);
+
+	return mlx5_core_access_reg(mdev, in, sizeof(in), out,
+				    outlen, MLX5_REG_PCMR, 0, 0);
+}
+
+static int mlx5_set_ports_check(struct mlx5_core_dev *mdev, u32 *in, int inlen)
+{
+	u32 out[MLX5_ST_SZ_DW(pcmr_reg)];
+
+	return mlx5_core_access_reg(mdev, in, inlen, out,
+				    sizeof(out), MLX5_REG_PCMR, 0, 1);
+}
+
+int mlx5_set_port_fcs(struct mlx5_core_dev *mdev, u8 enable)
+{
+	u32 in[MLX5_ST_SZ_DW(pcmr_reg)];
+
+	memset(in, 0, sizeof(in));
+	MLX5_SET(pcmr_reg, in, local_port, 1);
+	MLX5_SET(pcmr_reg, in, fcs_chk, enable);
+
+	return mlx5_set_ports_check(mdev, in, sizeof(in));
+}
+
+void mlx5_query_port_fcs(struct mlx5_core_dev *mdev, bool *supported,
+			 bool *enabled)
+{
+	u32 out[MLX5_ST_SZ_DW(pcmr_reg)];
+	/* Default values for FW which do not support MLX5_REG_PCMR */
+	*supported = false;
+	*enabled = true;
+
+	if (!MLX5_CAP_GEN(mdev, ports_check))
+		return;
+
+	if (mlx5_query_ports_check(mdev, out, sizeof(out)))
+		return;
+
+	*supported = !!(MLX5_GET(pcmr_reg, out, fcs_cap));
+	*enabled = !!(MLX5_GET(pcmr_reg, out, fcs_chk));
+}
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index dcd5ac8..497a4db 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -112,6 +112,7 @@ enum {
 	MLX5_REG_PMPE		 = 0x5010,
 	MLX5_REG_PELC		 = 0x500e,
 	MLX5_REG_PVLC		 = 0x500f,
+	MLX5_REG_PCMR		 = 0x5041,
 	MLX5_REG_PMLP		 = 0, /* TBD */
 	MLX5_REG_NODE_DESC	 = 0x6001,
 	MLX5_REG_HOST_ENDIANNESS = 0x7004,
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index a1d145a..577e953 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -84,4 +84,8 @@ int mlx5_query_port_ets_rate_limit(struct mlx5_core_dev *mdev,
 int mlx5_set_port_wol(struct mlx5_core_dev *mdev, u8 wol_mode);
 int mlx5_query_port_wol(struct mlx5_core_dev *mdev, u8 *wol_mode);
 
+int mlx5_set_port_fcs(struct mlx5_core_dev *mdev, u8 enable);
+void mlx5_query_port_fcs(struct mlx5_core_dev *mdev, bool *supported,
+			 bool *enabled);
+
 #endif /* __MLX5_PORT_H__ */
-- 
1.7.1
