From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 09/18] IB/mlx5: Create RoCE root namespace
Date: Fri, 17 Jun 2016 17:43:50 +0300
Message-ID: <1466174639-14576-10-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57494 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933457AbcFQOrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:47:49 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Create virtual RoCE namespace. The flow table will
be populated with flow rules according to the RoCE state.
Sniffer will traverse on those rules in order to add them
to the sniffer flow table.

mlx5_ib should call to mlx5_init_roce_steering when RoCE
is enabled and to mlx5_cleanup_roce_steering when is
disabled.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c                 | 125 ++++++++++++++++++++++
 drivers/infiniband/hw/mlx5/mlx5_ib.h              |  15 ++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |  32 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |   1 +
 include/linux/mlx5/fs.h                           |   1 +
 5 files changed, 171 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 573952b..60330c9 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -2275,6 +2275,116 @@ static int mlx5_port_immutable(struct ib_device *ibdev, u8 port_num,
 	return 0;
 }
 
+static void del_roce_rules(struct mlx5_flow_roce_ns *ns)
+
+{
+	if (ns->rocev1_rule) {
+		mlx5_del_flow_rule(ns->rocev1_rule);
+		ns->rocev1_rule = NULL;
+	}
+
+	if (ns->rocev2_ipv4_rule) {
+		mlx5_del_flow_rule(ns->rocev2_ipv4_rule);
+		ns->rocev2_ipv4_rule = NULL;
+	}
+
+	if (ns->rocev2_ipv6_rule) {
+		mlx5_del_flow_rule(ns->rocev2_ipv6_rule);
+		ns->rocev2_ipv6_rule = NULL;
+	}
+}
+
+static int add_roce_rules(struct mlx5_flow_roce_ns *ns)
+{
+	struct mlx5_flow_attr flow_attr;
+	u8 match_criteria_enable;
+	int inlen = MLX5_ST_SZ_BYTES(fte_match_param);
+	u32 *mc;
+	u32 *mv;
+	int err = 0;
+
+	mv = mlx5_vzalloc(inlen);
+	mc = mlx5_vzalloc(inlen);
+	if (!mv || !mc) {
+		err = -ENOMEM;
+		goto add_roce_rules_out;
+	}
+
+	match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+
+	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.ethertype);
+	MLX5_SET(fte_match_param, mv, outer_headers.ethertype, ETH_P_ROCE);
+
+	MLX5_RULE_ATTR(flow_attr, match_criteria_enable, mc, mv,
+		       MLX5_FLOW_CONTEXT_ACTION_ALLOW,
+		       MLX5_FS_DEFAULT_FLOW_TAG, NULL);
+	ns->rocev1_rule = mlx5_add_flow_rule(ns->ft, &flow_attr);
+	if (IS_ERR(ns->rocev1_rule)) {
+		err = PTR_ERR(ns->rocev1_rule);
+		ns->rocev1_rule = NULL;
+		goto add_roce_rules_out;
+	}
+
+	MLX5_SET(fte_match_param, mv, outer_headers.ethertype, ETH_P_IP);
+	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.ip_protocol);
+	MLX5_SET(fte_match_param, mv, outer_headers.ip_protocol, IPPROTO_UDP);
+	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.udp_dport);
+	MLX5_SET(fte_match_param, mv, outer_headers.udp_dport,
+		 ROCE_V2_UDP_DPORT);
+	ns->rocev2_ipv4_rule = mlx5_add_flow_rule(ns->ft, &flow_attr);
+	if (IS_ERR(ns->rocev2_ipv4_rule)) {
+		err = PTR_ERR(ns->rocev2_ipv4_rule);
+		ns->rocev2_ipv4_rule = NULL;
+		goto add_roce_rules_out;
+	}
+
+	MLX5_SET(fte_match_param, mv, outer_headers.ethertype, ETH_P_IPV6);
+	ns->rocev2_ipv6_rule = mlx5_add_flow_rule(ns->ft, &flow_attr);
+	if (IS_ERR(ns->rocev2_ipv6_rule)) {
+		err = PTR_ERR(ns->rocev2_ipv6_rule);
+		ns->rocev2_ipv6_rule = NULL;
+		goto add_roce_rules_out;
+	}
+
+add_roce_rules_out:
+	kvfree(mc);
+	kvfree(mv);
+	if (err)
+		del_roce_rules(ns);
+	return err;
+}
+
+#define ROCE_TABLE_SIZE 3
+static int mlx5_init_roce_steering(struct mlx5_ib_dev *dev)
+{
+	struct mlx5_flow_roce_ns *roce_ns = &dev->roce.roce_ns;
+	int err;
+
+	roce_ns->ns = mlx5_get_flow_namespace(dev->mdev,
+					      MLX5_FLOW_NAMESPACE_ROCE);
+	if (!roce_ns->ns)
+		return -EINVAL;
+
+	roce_ns->ft = mlx5_create_auto_grouped_flow_table(roce_ns->ns, 0,
+							  ROCE_TABLE_SIZE, 1, 0);
+	if (IS_ERR(roce_ns->ft)) {
+		err = PTR_ERR(roce_ns->ft);
+		pr_warn("Failed to create roce flow table\n");
+		roce_ns->ft = NULL;
+		return err;
+	}
+
+	err = add_roce_rules(roce_ns);
+	if (err)
+		goto destroy_flow_table;
+
+	return 0;
+
+destroy_flow_table:
+	mlx5_destroy_flow_table(roce_ns->ft);
+	return err;
+}
+
 static int mlx5_enable_roce(struct mlx5_ib_dev *dev)
 {
 	int err;
@@ -2288,6 +2398,9 @@ static int mlx5_enable_roce(struct mlx5_ib_dev *dev)
 	if (err)
 		goto err_unregister_netdevice_notifier;
 
+	/* RoCE can be supported without flow steering*/
+	mlx5_init_roce_steering(dev);
+
 	return 0;
 
 err_unregister_netdevice_notifier:
@@ -2295,8 +2408,20 @@ err_unregister_netdevice_notifier:
 	return err;
 }
 
+static void mlx5_cleanup_roce_steering(struct mlx5_ib_dev *dev)
+{
+	struct mlx5_flow_roce_ns *roce_ns = &dev->roce.roce_ns;
+
+	if (!roce_ns->ns || !roce_ns->ft)
+		return;
+
+	del_roce_rules(roce_ns);
+	mlx5_destroy_flow_table(roce_ns->ft);
+}
+
 static void mlx5_disable_roce(struct mlx5_ib_dev *dev)
 {
+	mlx5_cleanup_roce_steering(dev);
 	mlx5_nic_vport_disable_roce(dev->mdev);
 	unregister_netdevice_notifier(&dev->roce.nb);
 }
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index c4a9825..32f65fe 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -148,6 +148,14 @@ struct mlx5_ib_flow_handler {
 	struct mlx5_flow_rule	*rule;
 };
 
+struct mlx5_flow_roce_ns {
+	struct mlx5_flow_namespace	*ns;
+	struct mlx5_flow_table		*ft;
+	struct mlx5_flow_rule		*rocev1_rule;
+	struct mlx5_flow_rule		*rocev2_ipv4_rule;
+	struct mlx5_flow_rule		*rocev2_ipv6_rule;
+};
+
 struct mlx5_ib_flow_db {
 	struct mlx5_ib_flow_prio	prios[MLX5_IB_NUM_FLOW_FT];
 	/* Protect flow steering bypass flow tables
@@ -550,9 +558,10 @@ struct mlx5_roce {
 	/* Protect mlx5_ib_get_netdev from invoking dev_hold() with a NULL
 	 * netdev pointer
 	 */
-	rwlock_t		netdev_lock;
-	struct net_device	*netdev;
-	struct notifier_block	nb;
+	rwlock_t			netdev_lock;
+	struct net_device		*netdev;
+	struct notifier_block		nb;
+	struct mlx5_flow_roce_ns	roce_ns;
 };
 
 struct mlx5_ib_dev {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index e762a9c..d60d578 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1502,6 +1502,11 @@ struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
 			return &steering->esw_ingress_root_ns->ns;
 		else
 			return NULL;
+	case MLX5_FLOW_NAMESPACE_ROCE:
+		if (steering->roce_root_ns)
+			return &steering->roce_root_ns->ns;
+		else
+			return NULL;
 	default:
 		return NULL;
 	}
@@ -1806,10 +1811,31 @@ void mlx5_cleanup_fs(struct mlx5_core_dev *dev)
 	cleanup_root_ns(steering->esw_egress_root_ns);
 	cleanup_root_ns(steering->esw_ingress_root_ns);
 	cleanup_root_ns(steering->fdb_root_ns);
+	cleanup_root_ns(steering->roce_root_ns);
 	mlx5_cleanup_fc_stats(dev);
 	kfree(steering);
 }
 
+static int init_roce_root_ns(struct mlx5_flow_steering *steering)
+{
+	struct fs_prio *prio;
+
+	steering->roce_root_ns = create_root_ns(steering, FS_FT_NIC_RX,
+						mlx5_get_virt_fs_cmds());
+	if (!steering->roce_root_ns)
+		return -ENOMEM;
+
+	/* Create single prio */
+	prio = fs_create_prio(&steering->roce_root_ns->ns, 0, 1);
+	if (IS_ERR(prio)) {
+		cleanup_root_ns(steering->roce_root_ns);
+		steering->roce_root_ns = NULL;
+		return PTR_ERR(prio);
+	}
+
+	return 0;
+}
+
 static int init_fdb_root_ns(struct mlx5_flow_steering *steering)
 {
 	struct fs_prio *prio;
@@ -1909,6 +1935,12 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 		}
 	}
 
+	if (MLX5_CAP_GEN(dev, roce)) {
+		err = init_roce_root_ns(steering);
+		if (err)
+			goto err;
+	}
+
 	return 0;
 err:
 	mlx5_cleanup_fs(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 1d963fd..f758b1e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -61,6 +61,7 @@ struct mlx5_flow_steering {
 	struct mlx5_flow_root_namespace *fdb_root_ns;
 	struct mlx5_flow_root_namespace *esw_egress_root_ns;
 	struct mlx5_flow_root_namespace *esw_ingress_root_ns;
+	struct mlx5_flow_root_namespace *roce_root_ns;
 };
 
 struct fs_node {
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 5ac0e8f..ae82e00 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -60,6 +60,7 @@ enum mlx5_flow_namespace_type {
 	MLX5_FLOW_NAMESPACE_FDB,
 	MLX5_FLOW_NAMESPACE_ESW_EGRESS,
 	MLX5_FLOW_NAMESPACE_ESW_INGRESS,
+	MLX5_FLOW_NAMESPACE_ROCE,
 };
 
 struct mlx5_flow_table;
-- 
2.8.0
