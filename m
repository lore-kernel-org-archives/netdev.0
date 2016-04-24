From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 08/11] net/mlx5e: Add ethtool support for interface identify (LED blinking)
Date: Sun, 24 Apr 2016 22:51:53 +0300
Message-ID: <1461527516-29290-9-git-send-email-saeedm@mellanox.com>
References: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53344 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752017AbcDXTzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2016 15:55:06 -0400
In-Reply-To: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add the needed hardware command and mlx5_ifc structs for managing LED
control.
Add set_phys_id ethtool callback to support ethtool -p flag.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   25 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |   13 ++++++++++
 include/linux/mlx5/driver.h                        |    1 +
 include/linux/mlx5/port.h                          |    6 ++++
 4 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 522d584..a2c444e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1135,6 +1135,30 @@ static int mlx5e_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	return mlx5_set_port_wol(mdev, mlx5_wol_mode);
 }
 
+static int mlx5e_set_phys_id(struct net_device *dev,
+			     enum ethtool_phys_id_state state)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u16 beacon_duration;
+
+	if (!MLX5_CAP_GEN(mdev, beacon_led))
+		return -EOPNOTSUPP;
+
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		beacon_duration = MLX5_BEACON_DURATION_INF;
+		break;
+	case ETHTOOL_ID_INACTIVE:
+		beacon_duration = MLX5_BEACON_DURATION_OFF;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return mlx5_set_port_beacon(mdev, beacon_duration);
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
@@ -1159,6 +1183,7 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_pauseparam    = mlx5e_get_pauseparam,
 	.set_pauseparam    = mlx5e_set_pauseparam,
 	.get_ts_info       = mlx5e_get_ts_info,
+	.set_phys_id       = mlx5e_set_phys_id,
 	.get_wol	   = mlx5e_get_wol,
 	.set_wol	   = mlx5e_set_wol,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index c37740f..446549f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -115,6 +115,19 @@ int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_ptys);
 
+int mlx5_set_port_beacon(struct mlx5_core_dev *dev, u16 beacon_duration)
+{
+	u32 out[MLX5_ST_SZ_DW(mlcr_reg)];
+	u32 in[MLX5_ST_SZ_DW(mlcr_reg)];
+
+	memset(in, 0, sizeof(in));
+	MLX5_SET(mlcr_reg, in, local_port, 1);
+	MLX5_SET(mlcr_reg, in, beacon_duration, beacon_duration);
+
+	return mlx5_core_access_reg(dev, in, sizeof(in), out,
+				    sizeof(out), MLX5_REG_MLCR, 0, 1);
+}
+
 int mlx5_query_port_proto_cap(struct mlx5_core_dev *dev,
 			      u32 *proto_cap, int proto_mask)
 {
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 497a4db..2e8758d 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -116,6 +116,7 @@ enum {
 	MLX5_REG_PMLP		 = 0, /* TBD */
 	MLX5_REG_NODE_DESC	 = 0x6001,
 	MLX5_REG_HOST_ENDIANNESS = 0x7004,
+	MLX5_REG_MLCR		 = 0x902b,
 };
 
 enum {
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index 577e953..a364ab1 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -35,6 +35,11 @@
 
 #include <linux/mlx5/driver.h>
 
+enum mlx5_beacon_duration {
+	MLX5_BEACON_DURATION_OFF = 0x0,
+	MLX5_BEACON_DURATION_INF = 0xffff,
+};
+
 int mlx5_set_port_caps(struct mlx5_core_dev *dev, u8 port_num, u32 caps);
 int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
 			 int ptys_size, int proto_mask, u8 local_port);
@@ -53,6 +58,7 @@ int mlx5_set_port_admin_status(struct mlx5_core_dev *dev,
 			       enum mlx5_port_status status);
 int mlx5_query_port_admin_status(struct mlx5_core_dev *dev,
 				 enum mlx5_port_status *status);
+int mlx5_set_port_beacon(struct mlx5_core_dev *dev, u16 beacon_duration);
 
 int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu, u8 port);
 void mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu, u8 port);
-- 
1.7.1
