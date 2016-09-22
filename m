From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 8/9] net/mlx5e: Add TC vlan action for SRIOV offloads
Date: Thu, 22 Sep 2016 20:01:48 +0300
Message-ID: <1474563709-17943-9-git-send-email-saeedm@mellanox.com>
References: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirv@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49019 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S964995AbcIVRCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:02:16 -0400
In-Reply-To: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Parse TC vlan actions and set the required elements to allow offloading.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 43 ++++++++++++++++++-------
 1 file changed, 32 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 3eb319b..e61bd52 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -119,17 +119,27 @@ static struct mlx5_flow_rule *mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 						    struct mlx5_esw_flow_attr *attr)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	int err;
+
+	err = mlx5_eswitch_add_vlan_action(esw, attr);
+	if (err)
+		return ERR_PTR(err);
 
 	return mlx5_eswitch_add_offloaded_rule(esw, spec, attr);
 }
 
 static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
-			      struct mlx5_flow_rule *rule)
+			      struct mlx5_flow_rule *rule,
+			      struct mlx5_esw_flow_attr *attr)
 {
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	struct mlx5_fc *counter = NULL;
 
 	counter = mlx5_flow_rule_counter(rule);
 
+	if (esw && esw->mode == SRIOV_OFFLOADS)
+		mlx5_eswitch_del_vlan_action(esw, attr);
+
 	mlx5_del_flow_rule(rule);
 
 	mlx5_fc_destroy(priv->mdev, counter);
@@ -369,13 +379,9 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 
 	tcf_exts_to_list(exts, &actions);
 	list_for_each_entry(a, &actions, list) {
-		/* Only support a single action per rule */
-		if (attr->action)
-			return -EINVAL;
-
 		if (is_tcf_gact_shot(a)) {
-			attr->action = MLX5_FLOW_CONTEXT_ACTION_DROP |
-				       MLX5_FLOW_CONTEXT_ACTION_COUNT;
+			attr->action |= MLX5_FLOW_CONTEXT_ACTION_DROP |
+					MLX5_FLOW_CONTEXT_ACTION_COUNT;
 			continue;
 		}
 
@@ -392,12 +398,25 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				return -EINVAL;
 			}
 
-			attr->action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+			attr->action |= MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 			out_priv = netdev_priv(out_dev);
 			attr->out_rep = out_priv->ppriv;
 			continue;
 		}
 
+		if (is_tcf_vlan(a)) {
+			if (tcf_vlan_action(a) == VLAN_F_POP) {
+				attr->action |= MLX5_FLOW_CONTEXT_ACTION_VLAN_POP;
+			} else if (tcf_vlan_action(a) == VLAN_F_PUSH) {
+				if (tcf_vlan_push_proto(a) != htons(ETH_P_8021Q))
+					return -EOPNOTSUPP;
+
+				attr->action |= MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH;
+				attr->vlan = tcf_vlan_push_vid(a);
+			}
+			continue;
+		}
+
 		return -EINVAL;
 	}
 	return 0;
@@ -413,6 +432,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	struct mlx5e_tc_flow *flow;
 	struct mlx5_flow_spec *spec;
 	struct mlx5_flow_rule *old = NULL;
+	struct mlx5_esw_flow_attr *old_attr;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 
 	if (esw && esw->mode == SRIOV_OFFLOADS)
@@ -422,6 +442,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 				      tc->ht_params);
 	if (flow) {
 		old = flow->rule;
+		old_attr = flow->attr;
 	} else {
 		if (fdb_flow)
 			flow = kzalloc(sizeof(*flow) + sizeof(struct mlx5_esw_flow_attr),
@@ -466,7 +487,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 		goto err_del_rule;
 
 	if (old)
-		mlx5e_tc_del_flow(priv, old);
+		mlx5e_tc_del_flow(priv, old, old_attr);
 
 	goto out;
 
@@ -494,7 +515,7 @@ int mlx5e_delete_flower(struct mlx5e_priv *priv,
 
 	rhashtable_remove_fast(&tc->ht, &flow->node, tc->ht_params);
 
-	mlx5e_tc_del_flow(priv, flow->rule);
+	mlx5e_tc_del_flow(priv, flow->rule, flow->attr);
 
 	kfree(flow);
 
@@ -551,7 +572,7 @@ static void _mlx5e_tc_del_flow(void *ptr, void *arg)
 	struct mlx5e_tc_flow *flow = ptr;
 	struct mlx5e_priv *priv = arg;
 
-	mlx5e_tc_del_flow(priv, flow->rule);
+	mlx5e_tc_del_flow(priv, flow->rule, flow->attr);
 	kfree(flow);
 }
 
-- 
2.7.4
