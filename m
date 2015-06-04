From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 08/13] net/mlx5_core: Use port number in the query port mtu helpers
Date: Thu,  4 Jun 2015 19:30:43 +0300
Message-ID: <1433435448-4937-9-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47791 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751677AbbFDQbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:40 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Extend the function prototypes for max and operational mtu to take the
local port number. In the Ethernet driver is this hard coded to one,
since ConnectX4 Ethernet devices are always function-per-port.
The IB driver also serves older devices (ConnectIB) which isn't such,
and hence the part can vary.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/port.c    |   15 +++++++++------
 include/linux/mlx5/driver.h                       |    6 ++++--
 3 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f71f947..0ab3bdb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1367,7 +1367,7 @@ int mlx5e_open_locked(struct net_device *netdev)
 		return err;
 	}
 
-	err = mlx5_query_port_oper_mtu(mdev, &actual_mtu);
+	err = mlx5_query_port_oper_mtu(mdev, &actual_mtu, 1);
 	if (err) {
 		netdev_err(netdev, "%s: mlx5_query_port_oper_mtu failed %d\n",
 			   __func__, err);
@@ -1595,7 +1595,7 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 	int max_mtu;
 	int err = 0;
 
-	err = mlx5_query_port_max_mtu(mdev, &max_mtu);
+	err = mlx5_query_port_max_mtu(mdev, &max_mtu, 1);
 	if (err)
 		return err;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 7d3d0f9..d9498aa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -213,7 +213,8 @@ int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status)
 }
 
 static int mlx5_query_port_mtu(struct mlx5_core_dev *dev,
-			       int *admin_mtu, int *max_mtu, int *oper_mtu)
+			       int *admin_mtu, int *max_mtu, int *oper_mtu,
+			       u8 local_port)
 {
 	u32 in[MLX5_ST_SZ_DW(pmtu_reg)];
 	u32 out[MLX5_ST_SZ_DW(pmtu_reg)];
@@ -221,7 +222,7 @@ static int mlx5_query_port_mtu(struct mlx5_core_dev *dev,
 
 	memset(in, 0, sizeof(in));
 
-	MLX5_SET(pmtu_reg, in, local_port, 1);
+	MLX5_SET(pmtu_reg, in, local_port, local_port);
 
 	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
 				   sizeof(out), MLX5_REG_PMTU, 0, 0);
@@ -253,14 +254,16 @@ int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu)
 }
 EXPORT_SYMBOL_GPL(mlx5_set_port_mtu);
 
-int mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu)
+int mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu,
+			    u8 local_port)
 {
-	return mlx5_query_port_mtu(dev, NULL, max_mtu, NULL);
+	return mlx5_query_port_mtu(dev, NULL, max_mtu, NULL, local_port);
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_max_mtu);
 
-int mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu)
+int mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
+			     u8 local_port)
 {
-	return mlx5_query_port_mtu(dev, NULL, NULL, oper_mtu);
+	return mlx5_query_port_mtu(dev, NULL, NULL, oper_mtu, local_port);
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_oper_mtu);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index b90fb93..cd09784 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -751,8 +751,10 @@ int mlx5_set_port_status(struct mlx5_core_dev *dev,
 int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status);
 
 int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu);
-int mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu);
-int mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu);
+int mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu,
+			    u8 local_port);
+int mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
+			     u8 local_port);
 
 int mlx5_debug_eq_add(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 void mlx5_debug_eq_remove(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
-- 
1.7.1
