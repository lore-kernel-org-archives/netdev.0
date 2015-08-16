From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 6/8] net/mlx5e: Ethtool link speed setting fixes
Date: Sun, 16 Aug 2015 16:04:50 +0300
Message-ID: <1439730292-29617-7-git-send-email-achiad@mellanox.com>
References: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38386 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751266AbbHPNHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 09:07:03 -0400
In-Reply-To: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Port speed settings are applied by the device only upon
  port admin status transition from DOWN to UP.
  So we enforce this transition regardless of the port's
  current operation state (which may be occasionally DOWN if
  for example the network cable is disconnected).
- Fix the PORT_UP/DOWN device interface enum
- Set the local_port bit in the device PAOS register
- EXPORT the PAOS (Port Administrative and Operational Status)
  register set/query access functions.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 25 ++++++----------------
 drivers/net/ethernet/mellanox/mlx5/core/port.c     | 14 ++++++++----
 include/linux/mlx5/driver.h                        | 11 +++++-----
 3 files changed, 23 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 9758285..77158b3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -628,7 +628,7 @@ static int mlx5e_set_settings(struct net_device *netdev,
 	u32 link_modes;
 	u32 speed;
 	u32 eth_proto_cap, eth_proto_admin;
-	u8 port_status;
+	enum mlx5_port_status ps;
 	int err;
 
 	speed = ethtool_cmd_speed(cmd);
@@ -662,24 +662,13 @@ static int mlx5e_set_settings(struct net_device *netdev,
 	if (link_modes == eth_proto_admin)
 		goto out;
 
-	err = mlx5_set_port_proto(mdev, link_modes, MLX5_PTYS_EN);
-	if (err) {
-		netdev_err(netdev, "%s: set port eth proto admin failed: %d\n",
-			   __func__, err);
-		goto out;
-	}
+	mlx5_query_port_admin_status(mdev, &ps);
+	if (ps == MLX5_PORT_UP)
+		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN);
+	mlx5_set_port_proto(mdev, link_modes, MLX5_PTYS_EN);
+	if (ps == MLX5_PORT_UP)
+		mlx5_set_port_admin_status(mdev, MLX5_PORT_UP);
 
-	err = mlx5_query_port_status(mdev, &port_status);
-	if (err)
-		goto out;
-
-	if (port_status == MLX5_PORT_DOWN)
-		return 0;
-
-	err = mlx5_set_port_status(mdev, MLX5_PORT_DOWN);
-	if (err)
-		goto out;
-	err = mlx5_set_port_status(mdev, MLX5_PORT_UP);
 out:
 	return err;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 7014799..f8db52b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -216,22 +216,25 @@ int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 }
 EXPORT_SYMBOL_GPL(mlx5_set_port_proto);
 
-int mlx5_set_port_status(struct mlx5_core_dev *dev,
-			 enum mlx5_port_status status)
+int mlx5_set_port_admin_status(struct mlx5_core_dev *dev,
+			       enum mlx5_port_status status)
 {
 	u32 in[MLX5_ST_SZ_DW(paos_reg)];
 	u32 out[MLX5_ST_SZ_DW(paos_reg)];
 
 	memset(in, 0, sizeof(in));
 
+	MLX5_SET(paos_reg, in, local_port, 1);
 	MLX5_SET(paos_reg, in, admin_status, status);
 	MLX5_SET(paos_reg, in, ase, 1);
 
 	return mlx5_core_access_reg(dev, in, sizeof(in), out,
 				    sizeof(out), MLX5_REG_PAOS, 0, 1);
 }
+EXPORT_SYMBOL_GPL(mlx5_set_port_admin_status);
 
-int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status)
+int mlx5_query_port_admin_status(struct mlx5_core_dev *dev,
+				 enum mlx5_port_status *status)
 {
 	u32 in[MLX5_ST_SZ_DW(paos_reg)];
 	u32 out[MLX5_ST_SZ_DW(paos_reg)];
@@ -239,14 +242,17 @@ int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status)
 
 	memset(in, 0, sizeof(in));
 
+	MLX5_SET(paos_reg, in, local_port, 1);
+
 	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
 				   sizeof(out), MLX5_REG_PAOS, 0, 0);
 	if (err)
 		return err;
 
-	*status = MLX5_GET(paos_reg, out, oper_status);
+	*status = MLX5_GET(paos_reg, out, admin_status);
 	return err;
 }
+EXPORT_SYMBOL_GPL(mlx5_query_port_admin_status);
 
 static void mlx5_query_port_mtu(struct mlx5_core_dev *dev, int *admin_mtu,
 				int *max_mtu, int *oper_mtu, u8 port)
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 2039546..4b5d7fc 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -152,8 +152,8 @@ enum mlx5_dev_event {
 };
 
 enum mlx5_port_status {
-	MLX5_PORT_UP        = 1 << 1,
-	MLX5_PORT_DOWN      = 1 << 2,
+	MLX5_PORT_UP        = 1,
+	MLX5_PORT_DOWN      = 2,
 };
 
 struct mlx5_uuar_info {
@@ -761,9 +761,10 @@ int mlx5_query_port_proto_oper(struct mlx5_core_dev *dev,
 			       u8 local_port);
 int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 			int proto_mask);
-int mlx5_set_port_status(struct mlx5_core_dev *dev,
-			 enum mlx5_port_status status);
-int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status);
+int mlx5_set_port_admin_status(struct mlx5_core_dev *dev,
+			       enum mlx5_port_status status);
+int mlx5_query_port_admin_status(struct mlx5_core_dev *dev,
+				 enum mlx5_port_status *status);
 
 int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu, u8 port);
 void mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu, u8 port);
-- 
1.8.3.1
