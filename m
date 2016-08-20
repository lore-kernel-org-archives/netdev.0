From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 30/30] net/mlx5: Add sniffer namespaces
Date: Sat, 20 Aug 2016 23:12:13 +0300
Message-ID: <1471723933-5894-31-git-send-email-saeedm@mellanox.com>
References: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1471723933-5894-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add sniffer TX and RX namespaces to receive ingoing and outgoing
traffic.

Each outgoing/incoming packet is duplicated and steered to the sniffer
TX/RX namespace in addition to the regular flow.

Signed-off-by: Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 58 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  4 ++
 include/linux/mlx5/fs.h                           |  2 +
 3 files changed, 64 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index ac414b7..f5571a5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1427,6 +1427,16 @@ struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
 			return &steering->esw_ingress_root_ns->ns;
 		else
 			return NULL;
+	case MLX5_FLOW_NAMESPACE_SNIFFER_RX:
+		if (steering->sniffer_rx_root_ns)
+			return &steering->sniffer_rx_root_ns->ns;
+		else
+			return NULL;
+	case MLX5_FLOW_NAMESPACE_SNIFFER_TX:
+		if (steering->sniffer_tx_root_ns)
+			return &steering->sniffer_tx_root_ns->ns;
+		else
+			return NULL;
 	default:
 		return NULL;
 	}
@@ -1726,10 +1736,46 @@ void mlx5_cleanup_fs(struct mlx5_core_dev *dev)
 	cleanup_root_ns(steering->esw_egress_root_ns);
 	cleanup_root_ns(steering->esw_ingress_root_ns);
 	cleanup_root_ns(steering->fdb_root_ns);
+	cleanup_root_ns(steering->sniffer_rx_root_ns);
+	cleanup_root_ns(steering->sniffer_tx_root_ns);
 	mlx5_cleanup_fc_stats(dev);
 	kfree(steering);
 }
 
+static int init_sniffer_tx_root_ns(struct mlx5_flow_steering *steering)
+{
+	struct fs_prio *prio;
+
+	steering->sniffer_tx_root_ns = create_root_ns(steering, FS_FT_SNIFFER_TX);
+	if (!steering->sniffer_tx_root_ns)
+		return -ENOMEM;
+
+	/* Create single prio */
+	prio = fs_create_prio(&steering->sniffer_tx_root_ns->ns, 0, 1);
+	if (IS_ERR(prio)) {
+		cleanup_root_ns(steering->sniffer_tx_root_ns);
+		return PTR_ERR(prio);
+	}
+	return 0;
+}
+
+static int init_sniffer_rx_root_ns(struct mlx5_flow_steering *steering)
+{
+	struct fs_prio *prio;
+
+	steering->sniffer_rx_root_ns = create_root_ns(steering, FS_FT_SNIFFER_RX);
+	if (!steering->sniffer_rx_root_ns)
+		return -ENOMEM;
+
+	/* Create single prio */
+	prio = fs_create_prio(&steering->sniffer_rx_root_ns->ns, 0, 1);
+	if (IS_ERR(prio)) {
+		cleanup_root_ns(steering->sniffer_rx_root_ns);
+		return PTR_ERR(prio);
+	}
+	return 0;
+}
+
 static int init_fdb_root_ns(struct mlx5_flow_steering *steering)
 {
 	struct fs_prio *prio;
@@ -1826,6 +1872,18 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 		}
 	}
 
+	if (MLX5_CAP_FLOWTABLE_SNIFFER_RX(dev, ft_support)) {
+		err = init_sniffer_rx_root_ns(steering);
+		if (err)
+			goto err;
+	}
+
+	if (MLX5_CAP_FLOWTABLE_SNIFFER_TX(dev, ft_support)) {
+		err = init_sniffer_tx_root_ns(steering);
+		if (err)
+			goto err;
+	}
+
 	return 0;
 err:
 	mlx5_cleanup_fs(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 23e46e3..71ff03b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -49,6 +49,8 @@ enum fs_flow_table_type {
 	FS_FT_ESW_EGRESS_ACL  = 0x2,
 	FS_FT_ESW_INGRESS_ACL = 0x3,
 	FS_FT_FDB             = 0X4,
+	FS_FT_SNIFFER_RX	= 0X5,
+	FS_FT_SNIFFER_TX	= 0X6,
 };
 
 enum fs_flow_table_op_mod {
@@ -66,6 +68,8 @@ struct mlx5_flow_steering {
 	struct mlx5_flow_root_namespace *fdb_root_ns;
 	struct mlx5_flow_root_namespace *esw_egress_root_ns;
 	struct mlx5_flow_root_namespace *esw_ingress_root_ns;
+	struct mlx5_flow_root_namespace	*sniffer_tx_root_ns;
+	struct mlx5_flow_root_namespace	*sniffer_rx_root_ns;
 };
 
 struct fs_node {
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 8803212..93ebc5e 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -63,6 +63,8 @@ enum mlx5_flow_namespace_type {
 	MLX5_FLOW_NAMESPACE_FDB,
 	MLX5_FLOW_NAMESPACE_ESW_EGRESS,
 	MLX5_FLOW_NAMESPACE_ESW_INGRESS,
+	MLX5_FLOW_NAMESPACE_SNIFFER_RX,
+	MLX5_FLOW_NAMESPACE_SNIFFER_TX,
 };
 
 struct mlx5_flow_table;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
