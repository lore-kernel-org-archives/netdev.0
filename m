From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 10/13] net/mlx5_core: Add more query port helpers
Date: Thu,  4 Jun 2015 19:30:45 +0300
Message-ID: <1433435448-4937-11-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47673 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932134AbbFDQbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:25 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Add the following helpers:

1. mlx5_query_port_proto_oper -- queries the port speed port mask
2. mlx5_query_port_link_width_oper - queries the port link with bitmask
3. mlx5_query_port_vl_hw_cap - queries the Virtual Lanes supported on this port

These helpers will be used from the IB driver when working in ISSI > 0 mode.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/port.c |   67 ++++++++++++++++++++++++
 include/linux/mlx5/driver.h                    |    8 +++
 2 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index cbbce40..619d3ba 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -158,6 +158,42 @@ int mlx5_query_port_proto_admin(struct mlx5_core_dev *dev,
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_proto_admin);
 
+int mlx5_query_port_link_width_oper(struct mlx5_core_dev *dev,
+				    u8 *link_width_oper, u8 local_port)
+{
+	u32 out[MLX5_ST_SZ_DW(ptys_reg)];
+	int err;
+
+	err = mlx5_query_port_ptys(dev, out, sizeof(out), MLX5_PTYS_IB, local_port);
+	if (err)
+		return err;
+
+	*link_width_oper = MLX5_GET(ptys_reg, out, ib_link_width_oper);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_port_link_width_oper);
+
+int mlx5_query_port_proto_oper(struct mlx5_core_dev *dev,
+			       u8 *proto_oper, int proto_mask,
+			       u8 local_port)
+{
+	u32 out[MLX5_ST_SZ_DW(ptys_reg)];
+	int err;
+
+	err = mlx5_query_port_ptys(dev, out, sizeof(out), proto_mask, local_port);
+	if (err)
+		return err;
+
+	if (proto_mask == MLX5_PTYS_EN)
+		*proto_oper = MLX5_GET(ptys_reg, out, eth_proto_oper);
+	else
+		*proto_oper = MLX5_GET(ptys_reg, out, ib_proto_oper);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_port_proto_oper);
+
 int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 			int proto_mask)
 {
@@ -267,3 +303,34 @@ int mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
 	return mlx5_query_port_mtu(dev, NULL, NULL, oper_mtu, local_port);
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_oper_mtu);
+
+static int mlx5_query_port_pvlc(struct mlx5_core_dev *dev, u32 *pvlc,
+				int pvlc_size,  u8 local_port)
+{
+	u32 in[MLX5_ST_SZ_DW(pvlc_reg)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+	MLX5_SET(ptys_reg, in, local_port, local_port);
+
+	err = mlx5_core_access_reg(dev, in, sizeof(in), pvlc,
+				   pvlc_size, MLX5_REG_PVLC, 0, 0);
+
+	return err;
+}
+
+int mlx5_query_port_vl_hw_cap(struct mlx5_core_dev *dev,
+			      u8 *vl_hw_cap, u8 local_port)
+{
+	u32 out[MLX5_ST_SZ_DW(pvlc_reg)];
+	int err;
+
+	err = mlx5_query_port_pvlc(dev, out, sizeof(out), local_port);
+	if (err)
+		return err;
+
+	*vl_hw_cap = MLX5_GET(pvlc_reg, out, vl_hw_cap);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_port_vl_hw_cap);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index e4b814f..6093bde 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -107,6 +107,7 @@ enum {
 	MLX5_REG_PUDE		 = 0x5009,
 	MLX5_REG_PMPE		 = 0x5010,
 	MLX5_REG_PELC		 = 0x500e,
+	MLX5_REG_PVLC		 = 0x500f,
 	MLX5_REG_PMLP		 = 0, /* TBD */
 	MLX5_REG_NODE_DESC	 = 0x6001,
 	MLX5_REG_HOST_ENDIANNESS = 0x7004,
@@ -744,6 +745,11 @@ int mlx5_query_port_proto_cap(struct mlx5_core_dev *dev,
 			      u32 *proto_cap, int proto_mask);
 int mlx5_query_port_proto_admin(struct mlx5_core_dev *dev,
 				u32 *proto_admin, int proto_mask);
+int mlx5_query_port_link_width_oper(struct mlx5_core_dev *dev,
+				    u8 *link_width_oper, u8 local_port);
+int mlx5_query_port_proto_oper(struct mlx5_core_dev *dev,
+			       u8 *proto_oper, int proto_mask,
+			       u8 local_port);
 int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 			int proto_mask);
 int mlx5_set_port_status(struct mlx5_core_dev *dev,
@@ -755,6 +761,8 @@ int mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu,
 			    u8 local_port);
 int mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
 			     u8 local_port);
+int mlx5_query_port_vl_hw_cap(struct mlx5_core_dev *dev,
+			      u8 *vl_hw_cap, u8 local_port);
 
 int mlx5_debug_eq_add(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 void mlx5_debug_eq_remove(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
-- 
1.7.1
