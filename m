From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 5/9] net/mlx5: Put elements related to offloaded TC rule in one struct
Date: Thu, 22 Sep 2016 20:01:45 +0300
Message-ID: <1474563709-17943-6-git-send-email-saeedm@mellanox.com>
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
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49008 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S964982AbcIVRCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:02:16 -0400
In-Reply-To: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Put the representors related to the source and dest vports and the
action in struct mlx5_esw_flow_attr which is used while setting the FDB rule.

This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 51 ++++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  | 10 ++++-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  9 ++--
 3 files changed, 44 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 783e122..3eb319b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -39,6 +39,7 @@
 #include <linux/rhashtable.h>
 #include <net/switchdev.h>
 #include <net/tc_act/tc_mirred.h>
+#include <net/tc_act/tc_vlan.h>
 #include "en.h"
 #include "en_tc.h"
 #include "eswitch.h"
@@ -47,6 +48,7 @@ struct mlx5e_tc_flow {
 	struct rhash_head	node;
 	u64			cookie;
 	struct mlx5_flow_rule	*rule;
+	struct mlx5_esw_flow_attr *attr;
 };
 
 #define MLX5E_TC_TABLE_NUM_ENTRIES 1024
@@ -114,15 +116,11 @@ err_create_ft:
 
 static struct mlx5_flow_rule *mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 						    struct mlx5_flow_spec *spec,
-						    u32 action, u32 dst_vport)
+						    struct mlx5_esw_flow_attr *attr)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
-	u32 src_vport;
 
-	src_vport = rep->vport;
-
-	return mlx5_eswitch_add_offloaded_rule(esw, spec, action, src_vport, dst_vport);
+	return mlx5_eswitch_add_offloaded_rule(esw, spec, attr);
 }
 
 static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
@@ -358,7 +356,7 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 }
 
 static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
-				u32 *action, u32 *dest_vport)
+				struct mlx5_esw_flow_attr *attr)
 {
 	const struct tc_action *a;
 	LIST_HEAD(actions);
@@ -366,17 +364,18 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 	if (tc_no_actions(exts))
 		return -EINVAL;
 
-	*action = 0;
+	memset(attr, 0, sizeof(*attr));
+	attr->in_rep = priv->ppriv;
 
 	tcf_exts_to_list(exts, &actions);
 	list_for_each_entry(a, &actions, list) {
 		/* Only support a single action per rule */
-		if (*action)
+		if (attr->action)
 			return -EINVAL;
 
 		if (is_tcf_gact_shot(a)) {
-			*action = MLX5_FLOW_CONTEXT_ACTION_DROP |
-				  MLX5_FLOW_CONTEXT_ACTION_COUNT;
+			attr->action = MLX5_FLOW_CONTEXT_ACTION_DROP |
+				       MLX5_FLOW_CONTEXT_ACTION_COUNT;
 			continue;
 		}
 
@@ -384,7 +383,6 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 			int ifindex = tcf_mirred_ifindex(a);
 			struct net_device *out_dev;
 			struct mlx5e_priv *out_priv;
-			struct mlx5_eswitch_rep *out_rep;
 
 			out_dev = __dev_get_by_index(dev_net(priv->netdev), ifindex);
 
@@ -394,10 +392,9 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				return -EINVAL;
 			}
 
+			attr->action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 			out_priv = netdev_priv(out_dev);
-			out_rep  = out_priv->ppriv;
-			*dest_vport = out_rep->vport;
-			*action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+			attr->out_rep = out_priv->ppriv;
 			continue;
 		}
 
@@ -411,18 +408,27 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 {
 	struct mlx5e_tc_table *tc = &priv->fs.tc;
 	int err = 0;
-	u32 flow_tag, action, dest_vport = 0;
+	bool fdb_flow = false;
+	u32 flow_tag, action;
 	struct mlx5e_tc_flow *flow;
 	struct mlx5_flow_spec *spec;
 	struct mlx5_flow_rule *old = NULL;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 
+	if (esw && esw->mode == SRIOV_OFFLOADS)
+		fdb_flow = true;
+
 	flow = rhashtable_lookup_fast(&tc->ht, &f->cookie,
 				      tc->ht_params);
-	if (flow)
+	if (flow) {
 		old = flow->rule;
-	else
-		flow = kzalloc(sizeof(*flow), GFP_KERNEL);
+	} else {
+		if (fdb_flow)
+			flow = kzalloc(sizeof(*flow) + sizeof(struct mlx5_esw_flow_attr),
+				       GFP_KERNEL);
+		else
+			flow = kzalloc(sizeof(*flow), GFP_KERNEL);
+	}
 
 	spec = mlx5_vzalloc(sizeof(*spec));
 	if (!spec || !flow) {
@@ -436,11 +442,12 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	if (err < 0)
 		goto err_free;
 
-	if (esw && esw->mode == SRIOV_OFFLOADS) {
-		err = parse_tc_fdb_actions(priv, f->exts, &action, &dest_vport);
+	if (fdb_flow) {
+		flow->attr  = (struct mlx5_esw_flow_attr *)(flow + 1);
+		err = parse_tc_fdb_actions(priv, f->exts, flow->attr);
 		if (err < 0)
 			goto err_free;
-		flow->rule = mlx5e_tc_add_fdb_flow(priv, spec, action, dest_vport);
+		flow->rule = mlx5e_tc_add_fdb_flow(priv, spec, flow->attr);
 	} else {
 		err = parse_tc_nic_actions(priv, f->exts, &action, &flow_tag);
 		if (err < 0)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 4f5391a..eeeeadc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -238,11 +238,12 @@ int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 				 struct ifla_vf_stats *vf_stats);
 
 struct mlx5_flow_spec;
+struct mlx5_esw_flow_attr;
 
 struct mlx5_flow_rule *
 mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_flow_spec *spec,
-				u32 action, u32 src_vport, u32 dst_vport);
+				struct mlx5_esw_flow_attr *attr);
 struct mlx5_flow_rule *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn);
 
@@ -251,6 +252,13 @@ enum {
 	SET_VLAN_INSERT	= BIT(1)
 };
 
+struct mlx5_esw_flow_attr {
+	struct mlx5_eswitch_rep *in_rep;
+	struct mlx5_eswitch_rep *out_rep;
+
+	int	action;
+};
+
 int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
 				 struct mlx5_eswitch_rep *rep,
 				 u16 *sqns_array, int sqns_num);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index b901cd4..c0d9d1a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -46,19 +46,22 @@ enum {
 struct mlx5_flow_rule *
 mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_flow_spec *spec,
-				u32 action, u32 src_vport, u32 dst_vport)
+				struct mlx5_esw_flow_attr *attr)
 {
 	struct mlx5_flow_destination dest = { 0 };
 	struct mlx5_fc *counter = NULL;
 	struct mlx5_flow_rule *rule;
 	void *misc;
+	int action;
 
 	if (esw->mode != SRIOV_OFFLOADS)
 		return ERR_PTR(-EOPNOTSUPP);
 
+	action = attr->action;
+
 	if (action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
 		dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
-		dest.vport_num = dst_vport;
+		dest.vport_num = attr->out_rep->vport;
 		action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 	} else if (action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
 		counter = mlx5_fc_create(esw->dev, true);
@@ -69,7 +72,7 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 	}
 
 	misc = MLX5_ADDR_OF(fte_match_param, spec->match_value, misc_parameters);
-	MLX5_SET(fte_match_set_misc, misc, source_port, src_vport);
+	MLX5_SET(fte_match_set_misc, misc, source_port, attr->in_rep->vport);
 
 	misc = MLX5_ADDR_OF(fte_match_param, spec->match_criteria, misc_parameters);
 	MLX5_SET_TO_ONES(fte_match_set_misc, misc, source_port);
-- 
2.7.4
