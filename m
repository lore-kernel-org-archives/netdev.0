From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 09/13] net/mlx5_core: Use port number when querying port ptys
Date: Thu,  4 Jun 2015 19:30:44 +0300
Message-ID: <1433435448-4937-10-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47782 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752616AbbFDQbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:40 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Until now, mlx5_query_port_ptys always queried port number one.

Added new argument in the function's prototype so we can also query
the second port. This will be needed  when thr helper will be invoked
from the IB driver on non FPP (Function-Per-Port) devices.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |    8 ++++----
 include/linux/mlx5/driver.h                        |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index de7aec8..3889384 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -543,7 +543,7 @@ static int mlx5e_get_settings(struct net_device *netdev,
 	u32 eth_proto_oper;
 	int err;
 
-	err = mlx5_query_port_ptys(mdev, out, sizeof(out), MLX5_PTYS_EN);
+	err = mlx5_query_port_ptys(mdev, out, sizeof(out), MLX5_PTYS_EN, 1);
 
 	if (err) {
 		netdev_err(netdev, "%s: query port ptys failed: %d\n",
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index d9498aa..cbbce40 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -104,13 +104,13 @@ int mlx5_set_port_caps(struct mlx5_core_dev *dev, u8 port_num, u32 caps)
 EXPORT_SYMBOL_GPL(mlx5_set_port_caps);
 
 int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
-			 int ptys_size, int proto_mask)
+			 int ptys_size, int proto_mask, u8 local_port)
 {
 	u32 in[MLX5_ST_SZ_DW(ptys_reg)];
 	int err;
 
 	memset(in, 0, sizeof(in));
-	MLX5_SET(ptys_reg, in, local_port, 1);
+	MLX5_SET(ptys_reg, in, local_port, local_port);
 	MLX5_SET(ptys_reg, in, proto_mask, proto_mask);
 
 	err = mlx5_core_access_reg(dev, in, sizeof(in), ptys,
@@ -126,7 +126,7 @@ int mlx5_query_port_proto_cap(struct mlx5_core_dev *dev,
 	u32 out[MLX5_ST_SZ_DW(ptys_reg)];
 	int err;
 
-	err = mlx5_query_port_ptys(dev, out, sizeof(out), proto_mask);
+	err = mlx5_query_port_ptys(dev, out, sizeof(out), proto_mask, 1);
 	if (err)
 		return err;
 
@@ -145,7 +145,7 @@ int mlx5_query_port_proto_admin(struct mlx5_core_dev *dev,
 	u32 out[MLX5_ST_SZ_DW(ptys_reg)];
 	int err;
 
-	err = mlx5_query_port_ptys(dev, out, sizeof(out), proto_mask);
+	err = mlx5_query_port_ptys(dev, out, sizeof(out), proto_mask, 1);
 	if (err)
 		return err;
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index cd09784..e4b814f 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -739,7 +739,7 @@ int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
 
 int mlx5_set_port_caps(struct mlx5_core_dev *dev, u8 port_num, u32 caps);
 int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
-			 int ptys_size, int proto_mask);
+			 int ptys_size, int proto_mask, u8 local_port);
 int mlx5_query_port_proto_cap(struct mlx5_core_dev *dev,
 			      u32 *proto_cap, int proto_mask);
 int mlx5_query_port_proto_admin(struct mlx5_core_dev *dev,
-- 
1.7.1
