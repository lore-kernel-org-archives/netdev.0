From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 11/18] net/mlx5: Add sniffer namespaces
Date: Fri, 17 Jun 2016 17:43:52 +0300
Message-ID: <1466174639-14576-12-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57503 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161131AbcFQOr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:47:59 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Sniffer RX namespace: used for catching RoCE and
bypass traffic.
Sniffer TX namespace: used for catching all the TX traffic.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 56 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  4 ++
 include/linux/mlx5/fs.h                           |  2 +
 3 files changed, 62 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index b7ddcd2..e52da43 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1502,6 +1502,16 @@ struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
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
 	case MLX5_FLOW_NAMESPACE_ROCE:
 		if (steering->roce_root_ns)
 			return &steering->roce_root_ns->ns;
@@ -1812,6 +1822,8 @@ void mlx5_cleanup_fs(struct mlx5_core_dev *dev)
 	cleanup_root_ns(steering->esw_ingress_root_ns);
 	cleanup_root_ns(steering->fdb_root_ns);
 	cleanup_root_ns(steering->roce_root_ns);
+	cleanup_root_ns(steering->sniffer_rx_root_ns);
+	cleanup_root_ns(steering->sniffer_tx_root_ns);
 	mlx5_cleanup_fc_stats(dev);
 	kfree(steering);
 }
@@ -1836,6 +1848,44 @@ static int init_roce_root_ns(struct mlx5_flow_steering *steering)
 	return 0;
 }
 
+static int init_sniffer_rx_root_ns(struct mlx5_flow_steering *steering)
+{
+	struct fs_prio *prio;
+
+	steering->sniffer_rx_root_ns = create_root_ns(steering, FS_FT_SNIFFER_RX,
+						      mlx5_get_phys_fs_cmds());
+	if (!steering->sniffer_rx_root_ns)
+		return -ENOMEM;
+
+	/* Create single prio */
+	prio = fs_create_prio(&steering->sniffer_rx_root_ns->ns, 0, 1);
+	if (IS_ERR(prio)) {
+		cleanup_root_ns(steering->sniffer_rx_root_ns);
+		steering->sniffer_rx_root_ns = NULL;
+		return PTR_ERR(prio);
+	}
+	return 0;
+}
+
+static int init_sniffer_tx_root_ns(struct mlx5_flow_steering *steering)
+{
+	struct fs_prio *prio;
+
+	steering->sniffer_tx_root_ns = create_root_ns(steering, FS_FT_SNIFFER_TX,
+						      mlx5_get_phys_fs_cmds());
+	if (!steering->sniffer_tx_root_ns)
+		return -ENOMEM;
+
+	/* Create single prio */
+	prio = fs_create_prio(&steering->sniffer_tx_root_ns->ns, 0, 1);
+	if (IS_ERR(prio)) {
+		cleanup_root_ns(steering->sniffer_tx_root_ns);
+		steering->sniffer_tx_root_ns = NULL;
+		return PTR_ERR(prio);
+	}
+	return 0;
+}
+
 static int init_fdb_root_ns(struct mlx5_flow_steering *steering)
 {
 	struct fs_prio *prio;
@@ -1915,6 +1965,12 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 		err = init_root_ns(steering);
 		if (err)
 			goto err;
+		err = init_sniffer_tx_root_ns(steering);
+		if (err)
+			goto err;
+		err = init_sniffer_rx_root_ns(steering);
+		if (err)
+			goto err;
 	}
 
 	if (MLX5_CAP_GEN(dev, eswitch_flow_table)) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index f758b1e..a869302 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -49,6 +49,8 @@ enum fs_flow_table_type {
 	FS_FT_ESW_EGRESS_ACL  = 0x2,
 	FS_FT_ESW_INGRESS_ACL = 0x3,
 	FS_FT_FDB             = 0X4,
+	FS_FT_SNIFFER_RX	= 0X5,
+	FS_FT_SNIFFER_TX	= 0X6,
 };
 
 enum fs_fte_status {
@@ -62,6 +64,8 @@ struct mlx5_flow_steering {
 	struct mlx5_flow_root_namespace *esw_egress_root_ns;
 	struct mlx5_flow_root_namespace *esw_ingress_root_ns;
 	struct mlx5_flow_root_namespace *roce_root_ns;
+	struct mlx5_flow_root_namespace	*sniffer_tx_root_ns;
+	struct mlx5_flow_root_namespace	*sniffer_rx_root_ns;
 };
 
 struct fs_node {
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index db1f06e..f3715eb 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -60,6 +60,8 @@ enum mlx5_flow_namespace_type {
 	MLX5_FLOW_NAMESPACE_FDB,
 	MLX5_FLOW_NAMESPACE_ESW_EGRESS,
 	MLX5_FLOW_NAMESPACE_ESW_INGRESS,
+	MLX5_FLOW_NAMESPACE_SNIFFER_RX,
+	MLX5_FLOW_NAMESPACE_SNIFFER_TX,
 	MLX5_FLOW_NAMESPACE_ROCE,
 };
 
-- 
2.8.0
