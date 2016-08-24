From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 04/15] net/mlx5: Separate query_port_proto_oper for IB and EN
Date: Wed, 24 Aug 2016 13:39:03 +0300
Message-ID: <1472035154-14517-5-git-send-email-saeedm@mellanox.com>
References: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Noa Osherovich <noaos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eran Ben Elisha <eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472035154-14517-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Noa Osherovich <noaos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Replaced mlx5_query_port_proto_oper with separate functions per link
type. The functions should take different arguments so no point in
trying to unite them.

Signed-off-by: Noa Osherovich <noaos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Eran Ben Elisha <eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/main.c              |  3 +--
 drivers/net/ethernet/mellanox/mlx5/core/port.c | 32 ++++++++++++++++++--------
 include/linux/mlx5/port.h                      |  7 +++---
 3 files changed, 28 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 6fb77d7..f02a975 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -748,8 +748,7 @@ static int mlx5_query_hca_port(struct ib_device *ibdev, u8 port,
 				     &props->active_width);
 	if (err)
 		goto out;
-	err = mlx5_query_port_proto_oper(mdev, &props->active_speed, MLX5_PTYS_IB,
-					 port);
+	err = mlx5_query_port_ib_proto_oper(mdev, &props->active_speed, port);
 	if (err)
 		goto out;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 2ee28ad..34e7184 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -175,25 +175,39 @@ int mlx5_query_port_link_width_oper(struct mlx5_core_dev *dev,
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_link_width_oper);
 
-int mlx5_query_port_proto_oper(struct mlx5_core_dev *dev,
-			       u8 *proto_oper, int proto_mask,
-			       u8 local_port)
+int mlx5_query_port_eth_proto_oper(struct mlx5_core_dev *dev,
+				   u32 *proto_oper, u8 local_port)
 {
 	u32 out[MLX5_ST_SZ_DW(ptys_reg)];
 	int err;
 
-	err = mlx5_query_port_ptys(dev, out, sizeof(out), proto_mask, local_port);
+	err = mlx5_query_port_ptys(dev, out, sizeof(out), MLX5_PTYS_EN,
+				   local_port);
 	if (err)
 		return err;
 
-	if (proto_mask == MLX5_PTYS_EN)
-		*proto_oper = MLX5_GET(ptys_reg, out, eth_proto_oper);
-	else
-		*proto_oper = MLX5_GET(ptys_reg, out, ib_proto_oper);
+	*proto_oper = MLX5_GET(ptys_reg, out, eth_proto_oper);
+
+	return 0;
+}
+EXPORT_SYMBOL(mlx5_query_port_eth_proto_oper);
+
+int mlx5_query_port_ib_proto_oper(struct mlx5_core_dev *dev,
+				  u8 *proto_oper, u8 local_port)
+{
+	u32 out[MLX5_ST_SZ_DW(ptys_reg)];
+	int err;
+
+	err = mlx5_query_port_ptys(dev, out, sizeof(out), MLX5_PTYS_IB,
+				   local_port);
+	if (err)
+		return err;
+
+	*proto_oper = MLX5_GET(ptys_reg, out, ib_proto_oper);
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(mlx5_query_port_proto_oper);
+EXPORT_SYMBOL(mlx5_query_port_ib_proto_oper);
 
 int mlx5_set_port_ptys(struct mlx5_core_dev *dev, bool an_disable,
 		       u32 proto_admin, int proto_mask)
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index 6f876a4..b3065ac 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -103,9 +103,10 @@ int mlx5_query_port_proto_admin(struct mlx5_core_dev *dev,
 				u32 *proto_admin, int proto_mask);
 int mlx5_query_port_link_width_oper(struct mlx5_core_dev *dev,
 				    u8 *link_width_oper, u8 local_port);
-int mlx5_query_port_proto_oper(struct mlx5_core_dev *dev,
-			       u8 *proto_oper, int proto_mask,
-			       u8 local_port);
+int mlx5_query_port_ib_proto_oper(struct mlx5_core_dev *dev,
+				  u8 *proto_oper, u8 local_port);
+int mlx5_query_port_eth_proto_oper(struct mlx5_core_dev *dev,
+				   u32 *proto_oper, u8 local_port);
 int mlx5_set_port_ptys(struct mlx5_core_dev *dev, bool an_disable,
 		       u32 proto_admin, int proto_mask);
 void mlx5_toggle_port_link(struct mlx5_core_dev *dev);
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
