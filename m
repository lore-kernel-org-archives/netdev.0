From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 8/8] net/mlx5e: Hardware offloaded flower filter statistics support
Date: Fri, 13 May 2016 12:55:42 +0000
Message-ID: <1463144142-13810-9-git-send-email-amir@vadai.me>
References: <1463144142-13810-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41834 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752689AbcEMM6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 08:58:23 -0400
In-Reply-To: <1463144142-13810-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>

Introduce support in updating statistics of offloaded TC flower
classifiers. Currently only the DROP action is supported.

Signed-off-by: Amir Vadai <amirva@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 71 ++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |  3 +
 3 files changed, 69 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 0804070..fd43929 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2154,6 +2154,8 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 			return mlx5e_configure_flower(priv, proto, tc->cls_flower);
 		case TC_CLSFLOWER_DESTROY:
 			return mlx5e_delete_flower(priv, tc->cls_flower);
+		case TC_CLSFLOWER_STATS:
+			return mlx5e_stats_flower(priv, tc->cls_flower);
 		}
 	default:
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index ef017c0..704c3d3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -53,13 +53,24 @@ static struct mlx5_flow_rule *mlx5e_tc_add_flow(struct mlx5e_priv *priv,
 						u32 *match_c, u32 *match_v,
 						u32 action, u32 flow_tag)
 {
-	struct mlx5_flow_destination dest = {
-		.type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE,
-		{.ft = priv->fs.vlan.ft.t},
-	};
+	struct mlx5_core_dev *dev = priv->mdev;
+	struct mlx5_flow_destination dest = { 0 };
+	struct mlx5_fc *counter = NULL;
 	struct mlx5_flow_rule *rule;
 	bool table_created = false;
 
+	if (action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
+		dest.type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE;
+		dest.ft = priv->fs.vlan.ft.t;
+	} else {
+		counter = mlx5_fc_create(dev, true);
+		if (IS_ERR(counter))
+			return ERR_CAST(counter);
+
+		dest.type = MLX5_FLOW_DESTINATION_TYPE_COUNTER;
+		dest.counter = counter;
+	}
+
 	if (IS_ERR_OR_NULL(priv->fs.tc.t)) {
 		priv->fs.tc.t =
 			mlx5_create_auto_grouped_flow_table(priv->fs.ns,
@@ -70,7 +81,8 @@ static struct mlx5_flow_rule *mlx5e_tc_add_flow(struct mlx5e_priv *priv,
 		if (IS_ERR(priv->fs.tc.t)) {
 			netdev_err(priv->netdev,
 				   "Failed to create tc offload table\n");
-			return ERR_CAST(priv->fs.tc.t);
+			rule = ERR_CAST(priv->fs.tc.t);
+			goto err_create_ft;
 		}
 
 		table_created = true;
@@ -79,12 +91,20 @@ static struct mlx5_flow_rule *mlx5e_tc_add_flow(struct mlx5e_priv *priv,
 	rule = mlx5_add_flow_rule(priv->fs.tc.t, MLX5_MATCH_OUTER_HEADERS,
 				  match_c, match_v,
 				  action, flow_tag,
-				  action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST ? &dest : NULL);
+				  &dest);
+
+	if (IS_ERR(rule))
+		goto err_add_rule;
+
+	return rule;
 
-	if (IS_ERR(rule) && table_created) {
+err_add_rule:
+	if (table_created) {
 		mlx5_destroy_flow_table(priv->fs.tc.t);
 		priv->fs.tc.t = NULL;
 	}
+err_create_ft:
+	mlx5_fc_destroy(dev, counter);
 
 	return rule;
 }
@@ -92,8 +112,14 @@ static struct mlx5_flow_rule *mlx5e_tc_add_flow(struct mlx5e_priv *priv,
 static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 			      struct mlx5_flow_rule *rule)
 {
+	struct mlx5_fc *counter = NULL;
+
+	counter = mlx5_flow_rule_counter(rule);
+
 	mlx5_del_flow_rule(rule);
 
+	mlx5_fc_destroy(priv->mdev, counter);
+
 	if (!mlx5e_tc_num_filters(priv)) {
 		mlx5_destroy_flow_table(priv->fs.tc.t);
 		priv->fs.tc.t = NULL;
@@ -286,6 +312,9 @@ static int parse_tc_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 
 		if (is_tcf_gact_shot(a)) {
 			*action |= MLX5_FLOW_CONTEXT_ACTION_DROP;
+			if (MLX5_CAP_FLOWTABLE(priv->mdev,
+					       flow_table_properties_nic_receive.flow_counter))
+				*action |= MLX5_FLOW_CONTEXT_ACTION_COUNT;
 			continue;
 		}
 
@@ -394,6 +423,34 @@ int mlx5e_delete_flower(struct mlx5e_priv *priv,
 	return 0;
 }
 
+int mlx5e_stats_flower(struct mlx5e_priv *priv,
+		       struct tc_cls_flower_offload *f)
+{
+	struct mlx5e_tc_table *tc = &priv->fs.tc;
+	struct mlx5e_tc_flow *flow;
+	struct tc_action *a;
+	struct mlx5_fc *counter;
+	u64 bytes;
+	u64 packets;
+	u64 lastuse;
+
+	flow = rhashtable_lookup_fast(&tc->ht, &f->cookie,
+				      tc->ht_params);
+	if (!flow)
+		return -EINVAL;
+
+	counter = mlx5_flow_rule_counter(flow->rule);
+	if (!counter)
+		return 0;
+
+	mlx5_fc_query_cached(counter, &bytes, &packets, &lastuse);
+
+	tc_for_each_action(a, f->exts)
+		tcf_action_stats_update(a, bytes, packets, lastuse);
+
+	return 0;
+}
+
 static const struct rhashtable_params mlx5e_tc_flow_ht_params = {
 	.head_offset = offsetof(struct mlx5e_tc_flow, node),
 	.key_offset = offsetof(struct mlx5e_tc_flow, cookie),
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
index a4f17b9..34bf903 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
@@ -43,6 +43,9 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 int mlx5e_delete_flower(struct mlx5e_priv *priv,
 			struct tc_cls_flower_offload *f);
 
+int mlx5e_stats_flower(struct mlx5e_priv *priv,
+		       struct tc_cls_flower_offload *f);
+
 static inline int mlx5e_tc_num_filters(struct mlx5e_priv *priv)
 {
 	return atomic_read(&priv->fs.tc.ht.nelems);
-- 
2.8.0
