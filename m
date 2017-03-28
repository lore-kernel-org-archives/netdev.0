From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 04/12] net/mlx5e: Properly deal with resource cleanup when adding TC flow fails
Date: Wed, 29 Mar 2017 02:27:05 +0300
Message-ID: <20170328232713.29894-5-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42835 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932571AbdC1X2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:02 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The code for adding tc fdb flows leaves things half set when it fails
in the middle. Currently we are not leaking things (e.g eswitch
vlan reference, encap reference and HW resources) since the main
code to add flower rules does a cleanup by calling mlx5e_tc_del_flow().

This cleanup further works just b/c we're checking there if the HW rule
for the flow we are attempting to delete is valid before touching it, and
since under the current possible combinations of supported actions it's okay
to go and blidnly deref or delete all the action related resources (encap, vlan).

Instead, do things properly, namely make sure that if add flow fails we
clean all what was allocated or referenced. Now, the flow delete code can
blindly deref/deallocate both the rule and the actions related resources and
when more action combinations are introduced (such as the upcoming header
re-write) we are fine with clear and robust code.

While here, align all of nic/fdb parse actions/add flow functions to get
mlx5e_tc_flow struct param and pick the attributes or whatever else needed
from there.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 59 +++++++++++++---------
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 23 +++++----
 2 files changed, 50 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 9f900afcd7ea..af92d9c1a619 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -85,10 +85,11 @@ enum {
 static struct mlx5_flow_handle *
 mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 		      struct mlx5e_tc_flow_parse_attr *parse_attr,
-		      struct mlx5_nic_flow_attr *attr)
+		      struct mlx5e_tc_flow *flow)
 {
+	struct mlx5_nic_flow_attr *attr = flow->nic_attr;
 	struct mlx5_core_dev *dev = priv->mdev;
-	struct mlx5_flow_destination dest = { 0 };
+	struct mlx5_flow_destination dest = {};
 	struct mlx5_flow_act flow_act = {
 		.action = attr->action,
 		.flow_tag = attr->flow_tag,
@@ -152,11 +153,9 @@ static void mlx5e_tc_del_nic_flow(struct mlx5e_priv *priv,
 {
 	struct mlx5_fc *counter = NULL;
 
-	if (!IS_ERR(flow->rule)) {
-		counter = mlx5_flow_rule_counter(flow->rule);
-		mlx5_del_flow_rules(flow->rule);
-		mlx5_fc_destroy(priv->mdev, counter);
-	}
+	counter = mlx5_flow_rule_counter(flow->rule);
+	mlx5_del_flow_rules(flow->rule);
+	mlx5_fc_destroy(priv->mdev, counter);
 
 	if (!mlx5e_tc_num_filters(priv) && (priv->fs.tc.t)) {
 		mlx5_destroy_flow_table(priv->fs.tc.t);
@@ -164,23 +163,39 @@ static void mlx5e_tc_del_nic_flow(struct mlx5e_priv *priv,
 	}
 }
 
+static void mlx5e_detach_encap(struct mlx5e_priv *priv,
+			       struct mlx5e_tc_flow *flow);
+
 static struct mlx5_flow_handle *
 mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 		      struct mlx5e_tc_flow_parse_attr *parse_attr,
-		      struct mlx5_esw_flow_attr *attr)
+		      struct mlx5e_tc_flow *flow)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	struct mlx5_esw_flow_attr *attr = flow->esw_attr;
+	struct mlx5_flow_handle *rule;
 	int err;
 
 	err = mlx5_eswitch_add_vlan_action(esw, attr);
-	if (err)
-		return ERR_PTR(err);
+	if (err) {
+		rule = ERR_PTR(err);
+		goto err_add_vlan;
+	}
 
-	return mlx5_eswitch_add_offloaded_rule(esw, &parse_attr->spec, attr);
-}
+	rule = mlx5_eswitch_add_offloaded_rule(esw, &parse_attr->spec, attr);
+	if (IS_ERR(rule))
+		goto err_add_rule;
 
-static void mlx5e_detach_encap(struct mlx5e_priv *priv,
-			       struct mlx5e_tc_flow *flow);
+	return rule;
+
+err_add_rule:
+	mlx5_eswitch_del_vlan_action(esw, attr);
+err_add_vlan:
+	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
+		mlx5e_detach_encap(priv, flow);
+
+	return rule;
+}
 
 static void mlx5e_tc_del_fdb_flow(struct mlx5e_priv *priv,
 				  struct mlx5e_tc_flow *flow)
@@ -214,10 +229,6 @@ static void mlx5e_detach_encap(struct mlx5e_priv *priv,
 	}
 }
 
-/* we get here also when setting rule to the FW failed, etc. It means that the
- * flow rule itself might not exist, but some offloading related to the actions
- * should be cleaned.
- */
 static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 			      struct mlx5e_tc_flow *flow)
 {
@@ -665,8 +676,10 @@ static int parse_cls_flower(struct mlx5e_priv *priv,
 }
 
 static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
-				struct mlx5_nic_flow_attr *attr)
+				struct mlx5e_tc_flow_parse_attr *parse_attr,
+				struct mlx5e_tc_flow *flow)
 {
+	struct mlx5_nic_flow_attr *attr = flow->nic_attr;
 	const struct tc_action *a;
 	LIST_HEAD(actions);
 
@@ -1210,17 +1223,17 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 		err = parse_tc_fdb_actions(priv, f->exts, flow);
 		if (err < 0)
 			goto err_free;
-		flow->rule = mlx5e_tc_add_fdb_flow(priv, parse_attr, flow->esw_attr);
+		flow->rule = mlx5e_tc_add_fdb_flow(priv, parse_attr, flow);
 	} else {
-		err = parse_tc_nic_actions(priv, f->exts, flow->nic_attr);
+		err = parse_tc_nic_actions(priv, f->exts, parse_attr, flow);
 		if (err < 0)
 			goto err_free;
-		flow->rule = mlx5e_tc_add_nic_flow(priv, parse_attr, flow->nic_attr);
+		flow->rule = mlx5e_tc_add_nic_flow(priv, parse_attr, flow);
 	}
 
 	if (IS_ERR(flow->rule)) {
 		err = PTR_ERR(flow->rule);
-		goto err_del_rule;
+		goto err_free;
 	}
 
 	err = rhashtable_insert_fast(&tc->ht, &flow->node,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 307ec6c5fd3b..415a50150763 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -68,8 +68,10 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 	}
 	if (flow_act.action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
 		counter = mlx5_fc_create(esw->dev, true);
-		if (IS_ERR(counter))
-			return ERR_CAST(counter);
+		if (IS_ERR(counter)) {
+			rule = ERR_CAST(counter);
+			goto err_counter_alloc;
+		}
 		dest[i].type = MLX5_FLOW_DESTINATION_TYPE_COUNTER;
 		dest[i].counter = counter;
 		i++;
@@ -92,11 +94,16 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 	rule = mlx5_add_flow_rules((struct mlx5_flow_table *)esw->fdb_table.fdb,
 				   spec, &flow_act, dest, i);
 	if (IS_ERR(rule))
-		mlx5_fc_destroy(esw->dev, counter);
+		goto err_add_rule;
 	else
 		esw->offloads.num_flows++;
 
 	return rule;
+
+err_add_rule:
+	mlx5_fc_destroy(esw->dev, counter);
+err_counter_alloc:
+	return rule;
 }
 
 void
@@ -106,12 +113,10 @@ mlx5_eswitch_del_offloaded_rule(struct mlx5_eswitch *esw,
 {
 	struct mlx5_fc *counter = NULL;
 
-	if (!IS_ERR(rule)) {
-		counter = mlx5_flow_rule_counter(rule);
-		mlx5_del_flow_rules(rule);
-		mlx5_fc_destroy(esw->dev, counter);
-		esw->offloads.num_flows--;
-	}
+	counter = mlx5_flow_rule_counter(rule);
+	mlx5_del_flow_rules(rule);
+	mlx5_fc_destroy(esw->dev, counter);
+	esw->offloads.num_flows--;
 }
 
 static int esw_set_global_vlan_pop(struct mlx5_eswitch *esw, u8 val)
-- 
2.11.0
