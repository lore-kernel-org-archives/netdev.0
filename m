From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 02/12] net/mlx5e: Add NIC attributes for offloaded TC flows
Date: Wed, 29 Mar 2017 02:27:03 +0300
Message-ID: <20170328232713.29894-3-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42823 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932301AbdC1X2B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:01 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Add structure that contains the attributes related to offloaded
NIC flows. Currently it has the actions and flow tag.

While here, do xmas tree cleanup of the TC configure function.

This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 51 +++++++++++++++----------
 1 file changed, 31 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index b2501987988b..2a9df0a0b859 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -48,8 +48,14 @@
 #include "eswitch.h"
 #include "vxlan.h"
 
+struct mlx5_nic_flow_attr {
+	u32 action;
+	u32 flow_tag;
+};
+
 enum {
 	MLX5E_TC_FLOW_ESWITCH	= BIT(0),
+	MLX5E_TC_FLOW_NIC	= BIT(1),
 };
 
 struct mlx5e_tc_flow {
@@ -58,7 +64,10 @@ struct mlx5e_tc_flow {
 	u8			flags;
 	struct mlx5_flow_handle *rule;
 	struct list_head	encap; /* flows sharing the same encap */
-	struct mlx5_esw_flow_attr esw_attr[0];
+	union {
+		struct mlx5_esw_flow_attr esw_attr[0];
+		struct mlx5_nic_flow_attr nic_attr[0];
+	};
 };
 
 enum {
@@ -72,23 +81,23 @@ enum {
 static struct mlx5_flow_handle *
 mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 		      struct mlx5_flow_spec *spec,
-		      u32 action, u32 flow_tag)
+		      struct mlx5_nic_flow_attr *attr)
 {
 	struct mlx5_core_dev *dev = priv->mdev;
 	struct mlx5_flow_destination dest = { 0 };
 	struct mlx5_flow_act flow_act = {
-		.action = action,
-		.flow_tag = flow_tag,
+		.action = attr->action,
+		.flow_tag = attr->flow_tag,
 		.encap_id = 0,
 	};
 	struct mlx5_fc *counter = NULL;
 	struct mlx5_flow_handle *rule;
 	bool table_created = false;
 
-	if (action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
+	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
 		dest.type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE;
 		dest.ft = priv->fs.vlan.ft.t;
-	} else if (action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
+	} else if (attr->action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
 		counter = mlx5_fc_create(dev, true);
 		if (IS_ERR(counter))
 			return ERR_CAST(counter);
@@ -651,7 +660,7 @@ static int parse_cls_flower(struct mlx5e_priv *priv,
 }
 
 static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
-				u32 *action, u32 *flow_tag)
+				struct mlx5_nic_flow_attr *attr)
 {
 	const struct tc_action *a;
 	LIST_HEAD(actions);
@@ -659,20 +668,20 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 	if (tc_no_actions(exts))
 		return -EINVAL;
 
-	*flow_tag = MLX5_FS_DEFAULT_FLOW_TAG;
-	*action = 0;
+	attr->flow_tag = MLX5_FS_DEFAULT_FLOW_TAG;
+	attr->action = 0;
 
 	tcf_exts_to_list(exts, &actions);
 	list_for_each_entry(a, &actions, list) {
 		/* Only support a single action per rule */
-		if (*action)
+		if (attr->action)
 			return -EINVAL;
 
 		if (is_tcf_gact_shot(a)) {
-			*action |= MLX5_FLOW_CONTEXT_ACTION_DROP;
+			attr->action |= MLX5_FLOW_CONTEXT_ACTION_DROP;
 			if (MLX5_CAP_FLOWTABLE(priv->mdev,
 					       flow_table_properties_nic_receive.flow_counter))
-				*action |= MLX5_FLOW_CONTEXT_ACTION_COUNT;
+				attr->action |= MLX5_FLOW_CONTEXT_ACTION_COUNT;
 			continue;
 		}
 
@@ -685,8 +694,8 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				return -EINVAL;
 			}
 
-			*flow_tag = mark;
-			*action |= MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+			attr->flow_tag = mark;
+			attr->action |= MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 			continue;
 		}
 
@@ -1163,17 +1172,19 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 			   struct tc_cls_flower_offload *f)
 {
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	struct mlx5e_tc_table *tc = &priv->fs.tc;
-	int err, attr_size = 0;
-	u32 flow_tag, action;
-	struct mlx5e_tc_flow *flow;
 	struct mlx5_flow_spec *spec;
-	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	struct mlx5e_tc_flow *flow;
+	int attr_size, err = 0;
 	u8 flow_flags = 0;
 
 	if (esw && esw->mode == SRIOV_OFFLOADS) {
 		flow_flags = MLX5E_TC_FLOW_ESWITCH;
 		attr_size  = sizeof(struct mlx5_esw_flow_attr);
+	} else {
+		flow_flags = MLX5E_TC_FLOW_NIC;
+		attr_size  = sizeof(struct mlx5_nic_flow_attr);
 	}
 
 	flow = kzalloc(sizeof(*flow) + attr_size, GFP_KERNEL);
@@ -1196,10 +1207,10 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 			goto err_free;
 		flow->rule = mlx5e_tc_add_fdb_flow(priv, spec, flow->esw_attr);
 	} else {
-		err = parse_tc_nic_actions(priv, f->exts, &action, &flow_tag);
+		err = parse_tc_nic_actions(priv, f->exts, flow->nic_attr);
 		if (err < 0)
 			goto err_free;
-		flow->rule = mlx5e_tc_add_nic_flow(priv, spec, action, flow_tag);
+		flow->rule = mlx5e_tc_add_nic_flow(priv, spec, flow->nic_attr);
 	}
 
 	if (IS_ERR(flow->rule)) {
-- 
2.11.0
