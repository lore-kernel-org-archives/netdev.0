From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 10/13] net/mlx5: Support encap id when setting new steering entry
Date: Mon,  7 Nov 2016 15:14:45 +0200
Message-ID: <1478524488-1377-11-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39595 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753430AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

In order to support steering rules which add encapsulation headers,
encap_id parameter is needed.

Add new mlx5_flow_act struct which holds action related parameter:
action, flow_tag and encap_id. Use mlx5_flow_act struct when adding a new
steering rule.
This patch doesn't change any functionality.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c                  | 10 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  | 17 +++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    | 29 ++++++++-----
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    | 10 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  9 ++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 23 ++++++-----
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 25 ++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 48 ++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  1 +
 include/linux/mlx5/fs.h                            |  9 +++-
 11 files changed, 104 insertions(+), 78 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 9b16431..76ed57f 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1877,10 +1877,10 @@ static struct mlx5_ib_flow_handler *create_flow_rule(struct mlx5_ib_dev *dev,
 {
 	struct mlx5_flow_table	*ft = ft_prio->flow_table;
 	struct mlx5_ib_flow_handler *handler;
+	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_spec *spec;
 	const void *ib_flow = (const void *)flow_attr + sizeof(*flow_attr);
 	unsigned int spec_index;
-	u32 action;
 	int err = 0;
 
 	if (!is_valid_attr(flow_attr))
@@ -1905,12 +1905,12 @@ static struct mlx5_ib_flow_handler *create_flow_rule(struct mlx5_ib_dev *dev,
 	}
 
 	spec->match_criteria_enable = get_match_criteria_enable(spec->match_criteria);
-	action = dst ? MLX5_FLOW_CONTEXT_ACTION_FWD_DEST :
+	flow_act.action = dst ? MLX5_FLOW_CONTEXT_ACTION_FWD_DEST :
 		MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO;
+	flow_act.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG;
 	handler->rule = mlx5_add_flow_rules(ft, spec,
-					   action,
-					   MLX5_FS_DEFAULT_FLOW_TAG,
-					   dst, 1);
+					    &flow_act,
+					    dst, 1);
 
 	if (IS_ERR(handler->rule)) {
 		err = PTR_ERR(handler->rule);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index 677b238..68419a0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -174,6 +174,11 @@ static int arfs_add_default_rule(struct mlx5e_priv *priv,
 				 enum arfs_type type)
 {
 	struct arfs_table *arfs_t = &priv->fs.arfs.arfs_tables[type];
+	struct mlx5_flow_act flow_act = {
+		.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG,
+		.encap_id = 0,
+	};
 	struct mlx5_flow_destination dest;
 	struct mlx5e_tir *tir = priv->indir_tir;
 	struct mlx5_flow_spec *spec;
@@ -206,8 +211,7 @@ static int arfs_add_default_rule(struct mlx5e_priv *priv,
 	}
 
 	arfs_t->default_rule = mlx5_add_flow_rules(arfs_t->ft.t, spec,
-						   MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-						   MLX5_FS_DEFAULT_FLOW_TAG,
+						   &flow_act,
 						   &dest, 1);
 	if (IS_ERR(arfs_t->default_rule)) {
 		err = PTR_ERR(arfs_t->default_rule);
@@ -465,6 +469,11 @@ static struct arfs_table *arfs_get_table(struct mlx5e_arfs_tables *arfs,
 static struct mlx5_flow_handle *arfs_add_rule(struct mlx5e_priv *priv,
 					      struct arfs_rule *arfs_rule)
 {
+	struct mlx5_flow_act flow_act = {
+		.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG,
+		.encap_id = 0,
+	};
 	struct mlx5e_arfs_tables *arfs = &priv->fs.arfs;
 	struct arfs_tuple *tuple = &arfs_rule->tuple;
 	struct mlx5_flow_handle *rule = NULL;
@@ -544,9 +553,7 @@ static struct mlx5_flow_handle *arfs_add_rule(struct mlx5e_priv *priv,
 	}
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_TIR;
 	dest.tir_num = priv->direct_tir[arfs_rule->rxq].tirn;
-	rule = mlx5_add_flow_rules(ft, spec, MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				   MLX5_FS_DEFAULT_FLOW_TAG,
-				   &dest, 1);
+	rule = mlx5_add_flow_rules(ft, spec, &flow_act, &dest, 1);
 	if (IS_ERR(rule)) {
 		err = PTR_ERR(rule);
 		netdev_err(priv->netdev, "%s: add rule(filter id=%d, rq idx=%d) failed, err=%d\n",
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 9617892..1fe80de 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -158,6 +158,11 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 				 enum mlx5e_vlan_rule_type rule_type,
 				 u16 vid, struct mlx5_flow_spec *spec)
 {
+	struct mlx5_flow_act flow_act = {
+		.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG,
+		.encap_id = 0,
+	};
 	struct mlx5_flow_table *ft = priv->fs.vlan.ft.t;
 	struct mlx5_flow_destination dest;
 	struct mlx5_flow_handle **rule_p;
@@ -187,10 +192,7 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 		break;
 	}
 
-	*rule_p = mlx5_add_flow_rules(ft, spec,
-				      MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				      MLX5_FS_DEFAULT_FLOW_TAG,
-				      &dest, 1);
+	*rule_p = mlx5_add_flow_rules(ft, spec, &flow_act, &dest, 1);
 
 	if (IS_ERR(*rule_p)) {
 		err = PTR_ERR(*rule_p);
@@ -623,6 +625,11 @@ mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
 			u16 etype,
 			u8 proto)
 {
+	struct mlx5_flow_act flow_act = {
+		.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG,
+		.encap_id = 0,
+	};
 	struct mlx5_flow_handle *rule;
 	struct mlx5_flow_spec *spec;
 	int err = 0;
@@ -644,10 +651,7 @@ mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
 		MLX5_SET(fte_match_param, spec->match_value, outer_headers.ethertype, etype);
 	}
 
-	rule = mlx5_add_flow_rules(ft, spec,
-				   MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				   MLX5_FS_DEFAULT_FLOW_TAG,
-				   dest, 1);
+	rule = mlx5_add_flow_rules(ft, spec, &flow_act, dest, 1);
 	if (IS_ERR(rule)) {
 		err = PTR_ERR(rule);
 		netdev_err(priv->netdev, "%s: add rule failed\n", __func__);
@@ -810,6 +814,11 @@ static void mlx5e_del_l2_flow_rule(struct mlx5e_priv *priv,
 static int mlx5e_add_l2_flow_rule(struct mlx5e_priv *priv,
 				  struct mlx5e_l2_rule *ai, int type)
 {
+	struct mlx5_flow_act flow_act = {
+		.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG,
+		.encap_id = 0,
+	};
 	struct mlx5_flow_table *ft = priv->fs.l2.ft.t;
 	struct mlx5_flow_destination dest;
 	struct mlx5_flow_spec *spec;
@@ -848,9 +857,7 @@ static int mlx5e_add_l2_flow_rule(struct mlx5e_priv *priv,
 		break;
 	}
 
-	ai->rule = mlx5_add_flow_rules(ft, spec,
-				       MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				       MLX5_FS_DEFAULT_FLOW_TAG, &dest, 1);
+	ai->rule = mlx5_add_flow_rules(ft, spec, &flow_act, &dest, 1);
 	if (IS_ERR(ai->rule)) {
 		netdev_err(priv->netdev, "%s: add l2 rule(mac:%pM) failed\n",
 			   __func__, mv_dmac);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index 87bb3db..3691451 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -290,10 +290,10 @@ add_ethtool_flow_rule(struct mlx5e_priv *priv,
 		      struct ethtool_rx_flow_spec *fs)
 {
 	struct mlx5_flow_destination *dst = NULL;
+	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_spec *spec;
 	struct mlx5_flow_handle *rule;
 	int err = 0;
-	u32 action;
 
 	spec = mlx5_vzalloc(sizeof(*spec));
 	if (!spec)
@@ -304,7 +304,7 @@ add_ethtool_flow_rule(struct mlx5e_priv *priv,
 		goto free;
 
 	if (fs->ring_cookie == RX_CLS_FLOW_DISC) {
-		action = MLX5_FLOW_CONTEXT_ACTION_DROP;
+		flow_act.action = MLX5_FLOW_CONTEXT_ACTION_DROP;
 	} else {
 		dst = kzalloc(sizeof(*dst), GFP_KERNEL);
 		if (!dst) {
@@ -314,12 +314,12 @@ add_ethtool_flow_rule(struct mlx5e_priv *priv,
 
 		dst->type = MLX5_FLOW_DESTINATION_TYPE_TIR;
 		dst->tir_num = priv->direct_tir[fs->ring_cookie].tirn;
-		action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+		flow_act.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 	}
 
 	spec->match_criteria_enable = (!outer_header_zero(spec->match_criteria));
-	rule = mlx5_add_flow_rules(ft, spec, action,
-				   MLX5_FS_DEFAULT_FLOW_TAG, dst, 1);
+	flow_act.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG;
+	rule = mlx5_add_flow_rules(ft, spec, &flow_act, dst, 1);
 	if (IS_ERR(rule)) {
 		err = PTR_ERR(rule);
 		netdev_err(priv->netdev, "%s: failed to add ethtool steering rule: %d\n",
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index cdd4303..35e38d1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -61,6 +61,11 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 {
 	struct mlx5_core_dev *dev = priv->mdev;
 	struct mlx5_flow_destination dest = { 0 };
+	struct mlx5_flow_act flow_act = {
+		.action = action,
+		.flow_tag = flow_tag,
+		.encap_id = 0,
+	};
 	struct mlx5_fc *counter = NULL;
 	struct mlx5_flow_handle *rule;
 	bool table_created = false;
@@ -95,9 +100,7 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 	}
 
 	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
-	rule = mlx5_add_flow_rules(priv->fs.tc.t, spec,
-				   action, flow_tag,
-				   &dest, 1);
+	rule = mlx5_add_flow_rules(priv->fs.tc.t, spec, &flow_act, &dest, 1);
 
 	if (IS_ERR(rule))
 		goto err_add_rule;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 27f21ac..ae05d27 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -244,6 +244,7 @@ __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
 	int match_header = (is_zero_ether_addr(mac_c) ? 0 :
 			    MLX5_MATCH_OUTER_HEADERS);
 	struct mlx5_flow_handle *flow_rule = NULL;
+	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_destination dest;
 	struct mlx5_flow_spec *spec;
 	void *mv_misc = NULL;
@@ -285,10 +286,10 @@ __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
 		  "\tFDB add rule dmac_v(%pM) dmac_c(%pM) -> vport(%d)\n",
 		  dmac_v, dmac_c, vport);
 	spec->match_criteria_enable = match_header;
+	flow_act.action =  MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 	flow_rule =
 		mlx5_add_flow_rules(esw->fdb_table.fdb, spec,
-				    MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				    0, &dest, 1);
+				    &flow_act, &dest, 1);
 	if (IS_ERR(flow_rule)) {
 		esw_warn(esw->dev,
 			 "FDB: Failed to add flow rule: dmac_v(%pM) dmac_c(%pM) -> vport(%d), err(%ld)\n",
@@ -1212,6 +1213,7 @@ static void esw_vport_disable_ingress_acl(struct mlx5_eswitch *esw,
 static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 				    struct mlx5_vport *vport)
 {
+	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_spec *spec;
 	int err = 0;
 	u8 *smac_v;
@@ -1264,10 +1266,10 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 	}
 
 	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_ALLOW;
 	vport->ingress.allow_rule =
 		mlx5_add_flow_rules(vport->ingress.acl, spec,
-				    MLX5_FLOW_CONTEXT_ACTION_ALLOW,
-				    0, NULL, 0);
+				    &flow_act, NULL, 0);
 	if (IS_ERR(vport->ingress.allow_rule)) {
 		err = PTR_ERR(vport->ingress.allow_rule);
 		esw_warn(esw->dev,
@@ -1278,10 +1280,10 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 	}
 
 	memset(spec, 0, sizeof(*spec));
+	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_DROP;
 	vport->ingress.drop_rule =
 		mlx5_add_flow_rules(vport->ingress.acl, spec,
-				    MLX5_FLOW_CONTEXT_ACTION_DROP,
-				    0, NULL, 0);
+				    &flow_act, NULL, 0);
 	if (IS_ERR(vport->ingress.drop_rule)) {
 		err = PTR_ERR(vport->ingress.drop_rule);
 		esw_warn(esw->dev,
@@ -1301,6 +1303,7 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 				   struct mlx5_vport *vport)
 {
+	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_spec *spec;
 	int err = 0;
 
@@ -1338,10 +1341,10 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 	MLX5_SET(fte_match_param, spec->match_value, outer_headers.first_vid, vport->info.vlan);
 
 	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_ALLOW;
 	vport->egress.allowed_vlan =
 		mlx5_add_flow_rules(vport->egress.acl, spec,
-				    MLX5_FLOW_CONTEXT_ACTION_ALLOW,
-				    0, NULL, 0);
+				    &flow_act, NULL, 0);
 	if (IS_ERR(vport->egress.allowed_vlan)) {
 		err = PTR_ERR(vport->egress.allowed_vlan);
 		esw_warn(esw->dev,
@@ -1353,10 +1356,10 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 
 	/* Drop others rule (star rule) */
 	memset(spec, 0, sizeof(*spec));
+	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_DROP;
 	vport->egress.drop_rule =
 		mlx5_add_flow_rules(vport->egress.acl, spec,
-				    MLX5_FLOW_CONTEXT_ACTION_DROP,
-				    0, NULL, 0);
+				    &flow_act, NULL, 0);
 	if (IS_ERR(vport->egress.drop_rule)) {
 		err = PTR_ERR(vport->egress.drop_rule);
 		esw_warn(esw->dev,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index b18f951..a390117 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -49,23 +49,23 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_esw_flow_attr *attr)
 {
 	struct mlx5_flow_destination dest[2] = {};
+	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_fc *counter = NULL;
 	struct mlx5_flow_handle *rule;
 	void *misc;
-	int action;
 	int i = 0;
 
 	if (esw->mode != SRIOV_OFFLOADS)
 		return ERR_PTR(-EOPNOTSUPP);
 
-	action = attr->action;
+	flow_act.action = attr->action;
 
-	if (action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
+	if (flow_act.action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
 		dest[i].type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
 		dest[i].vport_num = attr->out_rep->vport;
 		i++;
 	}
-	if (action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
+	if (flow_act.action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
 		counter = mlx5_fc_create(esw->dev, true);
 		if (IS_ERR(counter))
 			return ERR_CAST(counter);
@@ -84,7 +84,7 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				      MLX5_MATCH_MISC_PARAMETERS;
 
 	rule = mlx5_add_flow_rules((struct mlx5_flow_table *)esw->fdb_table.fdb,
-				   spec, action, 0, dest, i);
+				   spec, &flow_act, dest, i);
 	if (IS_ERR(rule))
 		mlx5_fc_destroy(esw->dev, counter);
 
@@ -274,6 +274,7 @@ int mlx5_eswitch_del_vlan_action(struct mlx5_eswitch *esw,
 static struct mlx5_flow_handle *
 mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn)
 {
+	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_destination dest;
 	struct mlx5_flow_handle *flow_rule;
 	struct mlx5_flow_spec *spec;
@@ -297,10 +298,10 @@ mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn
 	spec->match_criteria_enable = MLX5_MATCH_MISC_PARAMETERS;
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
 	dest.vport_num = vport;
+	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 
 	flow_rule = mlx5_add_flow_rules(esw->fdb_table.offloads.fdb, spec,
-					MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-					0, &dest, 1);
+					&flow_act, &dest, 1);
 	if (IS_ERR(flow_rule))
 		esw_warn(esw->dev, "FDB: Failed to add send to vport rule err %ld\n", PTR_ERR(flow_rule));
 out:
@@ -363,6 +364,7 @@ int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
 
 static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 {
+	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_destination dest;
 	struct mlx5_flow_handle *flow_rule = NULL;
 	struct mlx5_flow_spec *spec;
@@ -377,10 +379,10 @@ static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
 	dest.vport_num = 0;
+	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 
 	flow_rule = mlx5_add_flow_rules(esw->fdb_table.offloads.fdb, spec,
-					MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-					0, &dest, 1);
+					&flow_act, &dest, 1);
 	if (IS_ERR(flow_rule)) {
 		err = PTR_ERR(flow_rule);
 		esw_warn(esw->dev,  "FDB: Failed to add miss flow rule err %d\n", err);
@@ -591,6 +593,7 @@ static void esw_destroy_vport_rx_group(struct mlx5_eswitch *esw)
 struct mlx5_flow_handle *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn)
 {
+	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_destination dest;
 	struct mlx5_flow_handle *flow_rule;
 	struct mlx5_flow_spec *spec;
@@ -613,9 +616,9 @@ mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn)
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_TIR;
 	dest.tir_num = tirn;
 
+	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 	flow_rule = mlx5_add_flow_rules(esw->offloads.ft_offloads, spec,
-					MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-					0, &dest, 1);
+				       &flow_act, &dest, 1);
 	if (IS_ERR(flow_rule)) {
 		esw_warn(esw->dev, "fs offloads: Failed to add vport rx rule err %ld\n", PTR_ERR(flow_rule));
 		goto out;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index cc97bb2..c4478ec 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -248,6 +248,7 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 	MLX5_SET(flow_context, in_flow_context, group_id, group_id);
 	MLX5_SET(flow_context, in_flow_context, flow_tag, fte->flow_tag);
 	MLX5_SET(flow_context, in_flow_context, action, fte->action);
+	MLX5_SET(flow_context, in_flow_context, encap_id, fte->encap_id);
 	in_match_value = MLX5_ADDR_OF(flow_context, in_flow_context,
 				      match_value);
 	memcpy(in_match_value, &fte->val, MLX5_ST_SZ_BYTES(fte_match_param));
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 4d28c8d..9adc766 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -460,8 +460,7 @@ static void del_flow_group(struct fs_node *node)
 			       fg->id, ft->id);
 }
 
-static struct fs_fte *alloc_fte(u8 action,
-				u32 flow_tag,
+static struct fs_fte *alloc_fte(struct mlx5_flow_act *flow_act,
 				u32 *match_value,
 				unsigned int index)
 {
@@ -473,9 +472,10 @@ static struct fs_fte *alloc_fte(u8 action,
 
 	memcpy(fte->val, match_value, sizeof(fte->val));
 	fte->node.type =  FS_TYPE_FLOW_ENTRY;
-	fte->flow_tag = flow_tag;
+	fte->flow_tag = flow_act->flow_tag;
 	fte->index = index;
-	fte->action = action;
+	fte->action = flow_act->action;
+	fte->encap_id = flow_act->encap_id;
 
 	return fte;
 }
@@ -1117,15 +1117,14 @@ static unsigned int get_free_fte_index(struct mlx5_flow_group *fg,
 /* prev is output, prev->next = new_fte */
 static struct fs_fte *create_fte(struct mlx5_flow_group *fg,
 				 u32 *match_value,
-				 u8 action,
-				 u32 flow_tag,
+				 struct mlx5_flow_act *flow_act,
 				 struct list_head **prev)
 {
 	struct fs_fte *fte;
 	int index;
 
 	index = get_free_fte_index(fg, prev);
-	fte = alloc_fte(action, flow_tag, match_value, index);
+	fte = alloc_fte(flow_act, match_value, index);
 	if (IS_ERR(fte))
 		return fte;
 
@@ -1219,8 +1218,7 @@ static struct mlx5_flow_rule *find_flow_rule(struct fs_fte *fte,
 
 static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 					    u32 *match_value,
-					    u8 action,
-					    u32 flow_tag,
+					    struct mlx5_flow_act *flow_act,
 					    struct mlx5_flow_destination *dest,
 					    int dest_num)
 {
@@ -1234,12 +1232,13 @@ static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 	fs_for_each_fte(fte, fg) {
 		nested_lock_ref_node(&fte->node, FS_MUTEX_CHILD);
 		if (compare_match_value(&fg->mask, match_value, &fte->val) &&
-		    (action & fte->action) && flow_tag == fte->flow_tag) {
+		    (flow_act->action & fte->action) &&
+		    flow_act->flow_tag == fte->flow_tag) {
 			int old_action = fte->action;
 
-			fte->action |= action;
+			fte->action |= flow_act->action;
 			handle = add_rule_fte(fte, fg, dest, dest_num,
-					      old_action != action);
+					      old_action != flow_act->action);
 			if (IS_ERR(handle)) {
 				fte->action = old_action;
 				goto unlock_fte;
@@ -1255,7 +1254,7 @@ static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 		goto unlock_fg;
 	}
 
-	fte = create_fte(fg, match_value, action, flow_tag, &prev);
+	fte = create_fte(fg, match_value, flow_act, &prev);
 	if (IS_ERR(fte)) {
 		handle = (void *)fte;
 		goto unlock_fg;
@@ -1332,17 +1331,17 @@ static bool dest_is_valid(struct mlx5_flow_destination *dest,
 static struct mlx5_flow_handle *
 _mlx5_add_flow_rules(struct mlx5_flow_table *ft,
 		     struct mlx5_flow_spec *spec,
-		     u32 action,
-		     u32 flow_tag,
+		     struct mlx5_flow_act *flow_act,
 		     struct mlx5_flow_destination *dest,
 		     int dest_num)
+
 {
 	struct mlx5_flow_group *g;
 	struct mlx5_flow_handle *rule;
 	int i;
 
 	for (i = 0; i < dest_num; i++) {
-		if (!dest_is_valid(&dest[i], action, ft))
+		if (!dest_is_valid(&dest[i], flow_act->action, ft))
 			return ERR_PTR(-EINVAL);
 	}
 
@@ -1353,7 +1352,7 @@ _mlx5_add_flow_rules(struct mlx5_flow_table *ft,
 					   g->mask.match_criteria,
 					   spec->match_criteria)) {
 			rule = add_rule_fg(g, spec->match_value,
-					   action, flow_tag, dest, dest_num);
+					   flow_act, dest, dest_num);
 			if (!IS_ERR(rule) || PTR_ERR(rule) != -ENOSPC)
 				goto unlock;
 		}
@@ -1365,8 +1364,7 @@ _mlx5_add_flow_rules(struct mlx5_flow_table *ft,
 		goto unlock;
 	}
 
-	rule = add_rule_fg(g, spec->match_value,
-			   action, flow_tag, dest, dest_num);
+	rule = add_rule_fg(g, spec->match_value, flow_act, dest, dest_num);
 	if (IS_ERR(rule)) {
 		/* Remove assumes refcount > 0 and autogroup creates a group
 		 * with a refcount = 0.
@@ -1390,8 +1388,7 @@ static bool fwd_next_prio_supported(struct mlx5_flow_table *ft)
 struct mlx5_flow_handle *
 mlx5_add_flow_rules(struct mlx5_flow_table *ft,
 		    struct mlx5_flow_spec *spec,
-		    u32 action,
-		    u32 flow_tag,
+		    struct mlx5_flow_act *flow_act,
 		    struct mlx5_flow_destination *dest,
 		    int dest_num)
 {
@@ -1399,11 +1396,11 @@ mlx5_add_flow_rules(struct mlx5_flow_table *ft,
 	struct mlx5_flow_destination gen_dest;
 	struct mlx5_flow_table *next_ft = NULL;
 	struct mlx5_flow_handle *handle = NULL;
-	u32 sw_action = action;
+	u32 sw_action = flow_act->action;
 	struct fs_prio *prio;
 
 	fs_get_obj(prio, ft->node.parent);
-	if (action == MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO) {
+	if (flow_act->action == MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO) {
 		if (!fwd_next_prio_supported(ft))
 			return ERR_PTR(-EOPNOTSUPP);
 		if (dest)
@@ -1415,15 +1412,14 @@ mlx5_add_flow_rules(struct mlx5_flow_table *ft,
 			gen_dest.ft = next_ft;
 			dest = &gen_dest;
 			dest_num = 1;
-			action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+			flow_act->action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 		} else {
 			mutex_unlock(&root->chain_lock);
 			return ERR_PTR(-EOPNOTSUPP);
 		}
 	}
 
-	handle = _mlx5_add_flow_rules(ft, spec, action, flow_tag, dest,
-				      dest_num);
+	handle = _mlx5_add_flow_rules(ft, spec, flow_act, dest, dest_num);
 
 	if (sw_action == MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO) {
 		if (!IS_ERR_OR_NULL(handle) &&
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 9f616ed..8e668c6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -151,6 +151,7 @@ struct fs_fte {
 	u32				flow_tag;
 	u32				index;
 	u32				action;
+	u32				encap_id;
 	enum fs_fte_status		status;
 	struct mlx5_fc			*counter;
 };
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index ab1a5fd..949b24b 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -130,14 +130,19 @@ struct mlx5_flow_group *
 mlx5_create_flow_group(struct mlx5_flow_table *ft, u32 *in);
 void mlx5_destroy_flow_group(struct mlx5_flow_group *fg);
 
+struct mlx5_flow_act {
+	u32 action;
+	u32 flow_tag;
+	u32 encap_id;
+};
+
 /* Single destination per rule.
  * Group ID is implied by the match criteria.
  */
 struct mlx5_flow_handle *
 mlx5_add_flow_rules(struct mlx5_flow_table *ft,
 		    struct mlx5_flow_spec *spec,
-		    u32 action,
-		    u32 flow_tag,
+		    struct mlx5_flow_act *flow_act,
 		    struct mlx5_flow_destination *dest,
 		    int dest_num);
 void mlx5_del_flow_rules(struct mlx5_flow_handle *fr);
-- 
2.7.4
