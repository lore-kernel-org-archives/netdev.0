From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 05/11] net/mlx5_core: Implement get and set functions of ptys register fields
Date: Mon, 13 Apr 2015 14:44:55 +0300
Message-ID: <1428925501-2373-6-git-send-email-amirv@mellanox.com>
References: <1428925501-2373-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:60819 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932252AbbDMLqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 07:46:06 -0400
In-Reply-To: <1428925501-2373-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Preparation for ethernet driver:
	- PTYS register will be used in ethernet ethtool set/get settings

Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/port.c | 77 ++++++++++++++++++++++++++
 include/linux/mlx5/driver.h                    | 14 +++++
 2 files changed, 91 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 49e90f2..6e2d99c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -102,3 +102,80 @@ int mlx5_set_port_caps(struct mlx5_core_dev *dev, u8 port_num, u32 caps)
 	return err;
 }
 EXPORT_SYMBOL_GPL(mlx5_set_port_caps);
+
+int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
+			 int ptys_size, int proto_mask)
+{
+	u32 in[MLX5_ST_SZ_DW(ptys_reg)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+	MLX5_SET(ptys_reg, in, local_port, 1);
+	MLX5_SET(ptys_reg, in, proto_mask, proto_mask);
+
+	err = mlx5_core_access_reg(dev, in, sizeof(in), ptys,
+				   ptys_size, MLX5_REG_PTYS, 0, 0);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_port_ptys);
+
+int mlx5_query_port_proto_cap(struct mlx5_core_dev *dev,
+			      u32 *proto_cap, int proto_mask)
+{
+	u32 out[MLX5_ST_SZ_DW(ptys_reg)];
+	int err;
+
+	err = mlx5_query_port_ptys(dev, out, sizeof(out), proto_mask);
+	if (err)
+		return err;
+
+	if (proto_mask == MLX5_PTYS_EN)
+		*proto_cap = MLX5_GET(ptys_reg, out, eth_proto_capability);
+	else
+		*proto_cap = MLX5_GET(ptys_reg, out, ib_proto_capability);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_port_proto_cap);
+
+int mlx5_query_port_proto_admin(struct mlx5_core_dev *dev,
+				u32 *proto_admin, int proto_mask)
+{
+	u32 out[MLX5_ST_SZ_DW(ptys_reg)];
+	int err;
+
+	err = mlx5_query_port_ptys(dev, out, sizeof(out), proto_mask);
+	if (err)
+		return err;
+
+	if (proto_mask == MLX5_PTYS_EN)
+		*proto_admin = MLX5_GET(ptys_reg, out, eth_proto_admin);
+	else
+		*proto_admin = MLX5_GET(ptys_reg, out, ib_proto_admin);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_port_proto_admin);
+
+int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
+			int proto_mask)
+{
+	u32 in[MLX5_ST_SZ_DW(ptys_reg)];
+	u32 out[MLX5_ST_SZ_DW(ptys_reg)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(ptys_reg, in, local_port, 1);
+	MLX5_SET(ptys_reg, in, proto_mask, proto_mask);
+	if (proto_mask == MLX5_PTYS_EN)
+		MLX5_SET(ptys_reg, in, eth_proto_admin, proto_admin);
+	else
+		MLX5_SET(ptys_reg, in, ib_proto_admin, proto_admin);
+
+	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
+				   sizeof(out), MLX5_REG_PTYS, 0, 1);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_set_port_proto);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 2999c6d..e897ba1 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -506,6 +506,11 @@ enum {
 	MLX5_COMP_EQ_SIZE = 1024,
 };
 
+enum {
+	MLX5_PTYS_IB = 1 << 0,
+	MLX5_PTYS_EN = 1 << 2,
+};
+
 struct mlx5_db_pgdir {
 	struct list_head	list;
 	DECLARE_BITMAP(bitmap, MLX5_DB_PER_PAGE);
@@ -693,7 +698,16 @@ void mlx5_qp_debugfs_cleanup(struct mlx5_core_dev *dev);
 int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
 			 int size_in, void *data_out, int size_out,
 			 u16 reg_num, int arg, int write);
+
 int mlx5_set_port_caps(struct mlx5_core_dev *dev, u8 port_num, u32 caps);
+int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
+			 int ptys_size, int proto_mask);
+int mlx5_query_port_proto_cap(struct mlx5_core_dev *dev,
+			      u32 *proto_cap, int proto_mask);
+int mlx5_query_port_proto_admin(struct mlx5_core_dev *dev,
+				u32 *proto_admin, int proto_mask);
+int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
+			int proto_mask);
 
 int mlx5_debug_eq_add(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 void mlx5_debug_eq_remove(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
-- 
1.9.3
