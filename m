From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 12/12] net/mlx5e: Add offloading of E-Switch TC pedit (header re-write) actions
Date: Wed, 29 Mar 2017 02:27:13 +0300
Message-ID: <20170328232713.29894-13-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42863 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932606AbdC1X2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:02 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

This includes calling the parsing code that translates from pedit
speak to the HW API, allocation (deallocation) of a modify header
context and setting the modify header id associated with this
context to the FTE of that flow.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 37 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  1 +
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  5 ++-
 3 files changed, 39 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 4045b4768294..9dec11c00a49 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -98,7 +98,6 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 		.action = attr->action,
 		.flow_tag = attr->flow_tag,
 		.encap_id = 0,
-		.modify_id = attr->mod_hdr_id,
 	};
 	struct mlx5_fc *counter = NULL;
 	struct mlx5_flow_handle *rule;
@@ -122,6 +121,7 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 					       parse_attr->num_mod_hdr_actions,
 					       parse_attr->mod_hdr_actions,
 					       &attr->mod_hdr_id);
+		flow_act.modify_id = attr->mod_hdr_id;
 		kfree(parse_attr->mod_hdr_actions);
 		if (err) {
 			rule = ERR_PTR(err);
@@ -208,6 +208,18 @@ mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 		goto err_add_vlan;
 	}
 
+	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR) {
+		err = mlx5_modify_header_alloc(priv->mdev, MLX5_FLOW_NAMESPACE_FDB,
+					       parse_attr->num_mod_hdr_actions,
+					       parse_attr->mod_hdr_actions,
+					       &attr->mod_hdr_id);
+		kfree(parse_attr->mod_hdr_actions);
+		if (err) {
+			rule = ERR_PTR(err);
+			goto err_mod_hdr;
+		}
+	}
+
 	rule = mlx5_eswitch_add_offloaded_rule(esw, &parse_attr->spec, attr);
 	if (IS_ERR(rule))
 		goto err_add_rule;
@@ -215,11 +227,14 @@ mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 	return rule;
 
 err_add_rule:
+	if (flow->esw_attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
+		mlx5_modify_header_dealloc(priv->mdev,
+					   attr->mod_hdr_id);
+err_mod_hdr:
 	mlx5_eswitch_del_vlan_action(esw, attr);
 err_add_vlan:
 	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
 		mlx5e_detach_encap(priv, flow);
-
 	return rule;
 }
 
@@ -227,6 +242,7 @@ static void mlx5e_tc_del_fdb_flow(struct mlx5e_priv *priv,
 				  struct mlx5e_tc_flow *flow)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	struct mlx5_esw_flow_attr *attr = flow->esw_attr;
 
 	mlx5_eswitch_del_offloaded_rule(esw, flow->rule, flow->esw_attr);
 
@@ -234,6 +250,10 @@ static void mlx5e_tc_del_fdb_flow(struct mlx5e_priv *priv,
 
 	if (flow->esw_attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
 		mlx5e_detach_encap(priv, flow);
+
+	if (flow->esw_attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
+		mlx5_modify_header_dealloc(priv->mdev,
+					   attr->mod_hdr_id);
 }
 
 static void mlx5e_detach_encap(struct mlx5e_priv *priv,
@@ -1406,6 +1426,7 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 }
 
 static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
+				struct mlx5e_tc_flow_parse_attr *parse_attr,
 				struct mlx5e_tc_flow *flow)
 {
 	struct mlx5_esw_flow_attr *attr = flow->esw_attr;
@@ -1429,6 +1450,16 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 			continue;
 		}
 
+		if (is_tcf_pedit(a)) {
+			err = parse_tc_pedit_action(priv, a, MLX5_FLOW_NAMESPACE_FDB,
+						    parse_attr);
+			if (err)
+				return err;
+
+			attr->action |= MLX5_FLOW_CONTEXT_ACTION_MOD_HDR;
+			continue;
+		}
+
 		if (is_tcf_mirred_egress_redirect(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
 			struct net_device *out_dev;
@@ -1528,7 +1559,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 		goto err_free;
 
 	if (flow->flags & MLX5E_TC_FLOW_ESWITCH) {
-		err = parse_tc_fdb_actions(priv, f->exts, flow);
+		err = parse_tc_fdb_actions(priv, f->exts, parse_attr, flow);
 		if (err < 0)
 			goto err_free;
 		flow->rule = mlx5e_tc_add_fdb_flow(priv, parse_attr, flow);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index cd9240c3a7f0..1f56ed9f5a6f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -308,6 +308,7 @@ struct mlx5_esw_flow_attr {
 	u16	vlan;
 	bool	vlan_handled;
 	struct mlx5_encap_entry *encap;
+	u32	mod_hdr_id;
 };
 
 int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 415a50150763..fff962dac8e3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -88,7 +88,10 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 	if (flow_act.action & MLX5_FLOW_CONTEXT_ACTION_DECAP)
 		spec->match_criteria_enable |= MLX5_MATCH_INNER_HEADERS;
 
-	if (attr->encap)
+	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
+		flow_act.modify_id = attr->mod_hdr_id;
+
+	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
 		flow_act.encap_id = attr->encap->encap_id;
 
 	rule = mlx5_add_flow_rules((struct mlx5_flow_table *)esw->fdb_table.fdb,
-- 
2.11.0
