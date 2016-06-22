From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 6/9] net/mlx5e: Toggle link only after modifying port parameters
Date: Wed, 22 Jun 2016 19:33:14 +0300
Message-ID: <1466613197-28726-7-git-send-email-saeedm@mellanox.com>
References: <1466613197-28726-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39091 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751899AbcFVQeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 12:34:03 -0400
In-Reply-To: <1466613197-28726-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add a dedicated function to toggle port link. It should be called only
after setting a port register.
Toggle will set port link to down and bring it back up in case that it's
admin status was up.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c   |  9 +--------
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c |  7 +------
 drivers/net/ethernet/mellanox/mlx5/core/port.c       | 12 ++++++++++++
 include/linux/mlx5/port.h                            |  1 +
 4 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index b2db180..e688313 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -191,7 +191,6 @@ static int mlx5e_dcbnl_ieee_setpfc(struct net_device *dev,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5_core_dev *mdev = priv->mdev;
-	enum mlx5_port_status ps;
 	u8 curr_pfc_en;
 	int ret;
 
@@ -200,14 +199,8 @@ static int mlx5e_dcbnl_ieee_setpfc(struct net_device *dev,
 	if (pfc->pfc_en == curr_pfc_en)
 		return 0;
 
-	mlx5_query_port_admin_status(mdev, &ps);
-	if (ps == MLX5_PORT_UP)
-		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN);
-
 	ret = mlx5_set_port_pfc(mdev, pfc->pfc_en, pfc->pfc_en);
-
-	if (ps == MLX5_PORT_UP)
-		mlx5_set_port_admin_status(mdev, MLX5_PORT_UP);
+	mlx5_toggle_port_link(mdev);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index c4be394..d0d3dcf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -795,7 +795,6 @@ static int mlx5e_set_settings(struct net_device *netdev,
 	u32 link_modes;
 	u32 speed;
 	u32 eth_proto_cap, eth_proto_admin;
-	enum mlx5_port_status ps;
 	int err;
 
 	speed = ethtool_cmd_speed(cmd);
@@ -829,12 +828,8 @@ static int mlx5e_set_settings(struct net_device *netdev,
 	if (link_modes == eth_proto_admin)
 		goto out;
 
-	mlx5_query_port_admin_status(mdev, &ps);
-	if (ps == MLX5_PORT_UP)
-		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN);
 	mlx5_set_port_proto(mdev, link_modes, MLX5_PTYS_EN);
-	if (ps == MLX5_PORT_UP)
-		mlx5_set_port_admin_status(mdev, MLX5_PORT_UP);
+	mlx5_toggle_port_link(mdev);
 
 out:
 	return err;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 3e35611..1562e73 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -222,6 +222,18 @@ int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 }
 EXPORT_SYMBOL_GPL(mlx5_set_port_proto);
 
+/* This function should be used after setting a port register only */
+void mlx5_toggle_port_link(struct mlx5_core_dev *dev)
+{
+	enum mlx5_port_status ps;
+
+	mlx5_query_port_admin_status(dev, &ps);
+	mlx5_set_port_admin_status(dev, MLX5_PORT_DOWN);
+	if (ps == MLX5_PORT_UP)
+		mlx5_set_port_admin_status(dev, MLX5_PORT_UP);
+}
+EXPORT_SYMBOL_GPL(mlx5_toggle_port_link);
+
 int mlx5_set_port_admin_status(struct mlx5_core_dev *dev,
 			       enum mlx5_port_status status)
 {
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index 9851862..4adfac1 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -67,6 +67,7 @@ int mlx5_query_port_proto_oper(struct mlx5_core_dev *dev,
 			       u8 local_port);
 int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 			int proto_mask);
+void mlx5_toggle_port_link(struct mlx5_core_dev *dev);
 int mlx5_set_port_admin_status(struct mlx5_core_dev *dev,
 			       enum mlx5_port_status status);
 int mlx5_query_port_admin_status(struct mlx5_core_dev *dev,
-- 
2.8.0
