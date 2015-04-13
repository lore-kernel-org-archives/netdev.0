From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 08/11] net/mlx5_core: Set/Query port MTU commands
Date: Mon, 13 Apr 2015 14:44:58 +0300
Message-ID: <1428925501-2373-9-git-send-email-amirv@mellanox.com>
References: <1428925501-2373-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:60762 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932260AbbDMLp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 07:45:57 -0400
In-Reply-To: <1428925501-2373-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/port.c | 56 ++++++++++++++++++++++++++
 include/linux/mlx5/driver.h                    |  4 ++
 2 files changed, 60 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 742a6fb..e56a0b6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -211,3 +211,59 @@ int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status)
 	*status = MLX5_GET(paos_reg, out, oper_status);
 	return err;
 }
+
+static int mlx5_query_port_mtu(struct mlx5_core_dev *dev,
+			       int *admin_mtu, int *max_mtu, int *oper_mtu)
+{
+	u32 in[MLX5_ST_SZ_DW(pmtu_reg)];
+	u32 out[MLX5_ST_SZ_DW(pmtu_reg)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(pmtu_reg, in, local_port, 1);
+
+	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
+				   sizeof(out), MLX5_REG_PMTU, 0, 0);
+	if (err)
+		return err;
+
+	if (max_mtu)
+		*max_mtu  = MLX5_GET(pmtu_reg, out, max_mtu);
+	if (oper_mtu)
+		*oper_mtu = MLX5_GET(pmtu_reg, out, oper_mtu);
+	if (admin_mtu)
+		*admin_mtu = MLX5_GET(pmtu_reg, out, admin_mtu);
+
+	return 0;
+}
+
+int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu)
+{
+	u32 in[MLX5_ST_SZ_DW(pmtu_reg)];
+	u32 out[MLX5_ST_SZ_DW(pmtu_reg)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(pmtu_reg, in, admin_mtu, mtu);
+	MLX5_SET(pmtu_reg, in, local_port, 1);
+
+	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
+				   sizeof(out), MLX5_REG_PMTU, 0, 1);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_set_port_mtu);
+
+int mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu)
+{
+	return mlx5_query_port_mtu(dev, NULL, max_mtu, NULL);
+}
+EXPORT_SYMBOL_GPL(mlx5_query_port_max_mtu);
+
+int mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu)
+{
+	return mlx5_query_port_mtu(dev, NULL, NULL, oper_mtu);
+}
+EXPORT_SYMBOL_GPL(mlx5_query_port_oper_mtu);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index a79a2f9..777565e 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -717,6 +717,10 @@ int mlx5_set_port_status(struct mlx5_core_dev *dev,
 			 enum mlx5_port_status status);
 int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status);
 
+int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu);
+int mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu);
+int mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu);
+
 int mlx5_debug_eq_add(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 void mlx5_debug_eq_remove(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 int mlx5_core_eq_query(struct mlx5_core_dev *dev, struct mlx5_eq *eq,
-- 
1.9.3
