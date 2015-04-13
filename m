From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 06/11] net/mlx5_core: Implement get/set port status
Date: Mon, 13 Apr 2015 14:44:56 +0300
Message-ID: <1428925501-2373-7-git-send-email-amirv@mellanox.com>
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
Received: from ns1327.ztomy.com ([193.47.165.129]:60789 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932262AbbDMLp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 07:45:59 -0400
In-Reply-To: <1428925501-2373-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rana Shahout <ranas@mellanox.com>

Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/port.c | 32 ++++++++++++++++++++++++++
 include/linux/mlx5/driver.h                    |  8 +++++++
 2 files changed, 40 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 6e2d99c..742a6fb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -179,3 +179,35 @@ int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 	return err;
 }
 EXPORT_SYMBOL_GPL(mlx5_set_port_proto);
+
+int mlx5_set_port_status(struct mlx5_core_dev *dev,
+			 enum mlx5_port_status status)
+{
+	u32 in[MLX5_ST_SZ_DW(paos_reg)];
+	u32 out[MLX5_ST_SZ_DW(paos_reg)];
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(paos_reg, in, admin_status, status);
+	MLX5_SET(paos_reg, in, ase, 1);
+
+	return mlx5_core_access_reg(dev, in, sizeof(in), out,
+				    sizeof(out), MLX5_REG_PAOS, 0, 1);
+}
+
+int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status)
+{
+	u32 in[MLX5_ST_SZ_DW(paos_reg)];
+	u32 out[MLX5_ST_SZ_DW(paos_reg)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+
+	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
+				   sizeof(out), MLX5_REG_PAOS, 0, 0);
+	if (err)
+		return err;
+
+	*status = MLX5_GET(paos_reg, out, oper_status);
+	return err;
+}
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index e897ba1..a79a2f9 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -149,6 +149,11 @@ enum mlx5_dev_event {
 	MLX5_DEV_EVENT_CLIENT_REREG,
 };
 
+enum mlx5_port_status {
+	MLX5_PORT_UP        = 1 << 1,
+	MLX5_PORT_DOWN      = 1 << 2,
+};
+
 struct mlx5_uuar_info {
 	struct mlx5_uar	       *uars;
 	int			num_uars;
@@ -708,6 +713,9 @@ int mlx5_query_port_proto_admin(struct mlx5_core_dev *dev,
 				u32 *proto_admin, int proto_mask);
 int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 			int proto_mask);
+int mlx5_set_port_status(struct mlx5_core_dev *dev,
+			 enum mlx5_port_status status);
+int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status);
 
 int mlx5_debug_eq_add(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 void mlx5_debug_eq_remove(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
-- 
1.9.3
