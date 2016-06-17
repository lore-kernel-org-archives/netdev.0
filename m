From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 01/18] net/mlx5: Refactor mlx5_add_flow_rule
Date: Fri, 17 Jun 2016 17:43:42 +0300
Message-ID: <1466174639-14576-2-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57406 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755290AbcFQOrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:47:19 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Reduce the set of arguments passed to mlx5_add_flow_rule to one
by introducing flow_attributes struct.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c                 | 10 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c | 26 ++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c   | 28 +++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   |  8 ++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 51 +++++++++--------------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 46 +++++++++-----------
 include/linux/mlx5/fs.h                           | 29 ++++++++++---
 7 files changed, 98 insertions(+), 100 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index b48ad85..573952b 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1528,6 +1528,7 @@ static struct mlx5_ib_flow_handler *create_flow_rule(struct mlx5_ib_dev *dev,
 {
 	struct mlx5_flow_table	*ft = ft_prio->flow_table;
 	struct mlx5_ib_flow_handler *handler;
+	struct mlx5_flow_attr flow_rule_attr;
 	void *ib_flow = flow_attr + 1;
 	u8 match_criteria_enable = 0;
 	unsigned int spec_index;
@@ -1561,11 +1562,10 @@ static struct mlx5_ib_flow_handler *create_flow_rule(struct mlx5_ib_dev *dev,
 	match_criteria_enable = (!outer_header_zero(match_c)) << 0;
 	action = dst ? MLX5_FLOW_CONTEXT_ACTION_FWD_DEST :
 		MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO;
-	handler->rule = mlx5_add_flow_rule(ft, match_criteria_enable,
-					   match_c, match_v,
-					   action,
-					   MLX5_FS_DEFAULT_FLOW_TAG,
-					   dst);
+
+	MLX5_RULE_ATTR(flow_rule_attr, match_criteria_enable, match_c,
+		       match_v, action, MLX5_FS_DEFAULT_FLOW_TAG, dst);
+	handler->rule = mlx5_add_flow_rule(ft, &flow_rule_attr);
 
 	if (IS_ERR(handler->rule)) {
 		err = PTR_ERR(handler->rule);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index 3515e78..f126043 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -174,15 +174,15 @@ static int arfs_add_default_rule(struct mlx5e_priv *priv,
 				 enum arfs_type type)
 {
 	struct arfs_table *arfs_t = &priv->fs.arfs.arfs_tables[type];
+	struct mlx5_flow_attr flow_attr;
 	struct mlx5_flow_destination dest;
-	u8 match_criteria_enable = 0;
 	u32 *tirn = priv->indir_tirn;
 	u32 *match_criteria;
 	u32 *match_value;
 	int err = 0;
 
 	match_value	= mlx5_vzalloc(MLX5_ST_SZ_BYTES(fte_match_param));
-	match_criteria	= mlx5_vzalloc(MLX5_ST_SZ_BYTES(fte_match_param));
+	match_criteria = mlx5_vzalloc(MLX5_ST_SZ_BYTES(fte_match_param));
 	if (!match_value || !match_criteria) {
 		netdev_err(priv->netdev, "%s: alloc failed\n", __func__);
 		err = -ENOMEM;
@@ -208,11 +208,10 @@ static int arfs_add_default_rule(struct mlx5e_priv *priv,
 		goto out;
 	}
 
-	arfs_t->default_rule = mlx5_add_flow_rule(arfs_t->ft.t, match_criteria_enable,
-						  match_criteria, match_value,
-						  MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-						  MLX5_FS_DEFAULT_FLOW_TAG,
-						  &dest);
+	MLX5_RULE_ATTR(flow_attr, 0, match_criteria,
+		       match_value, MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		       MLX5_FS_DEFAULT_FLOW_TAG, &dest);
+	arfs_t->default_rule = mlx5_add_flow_rule(arfs_t->ft.t, &flow_attr);
 	if (IS_ERR(arfs_t->default_rule)) {
 		err = PTR_ERR(arfs_t->default_rule);
 		arfs_t->default_rule = NULL;
@@ -474,21 +473,20 @@ static struct mlx5_flow_rule *arfs_add_rule(struct mlx5e_priv *priv,
 	struct arfs_tuple *tuple = &arfs_rule->tuple;
 	struct mlx5_flow_rule *rule = NULL;
 	struct mlx5_flow_destination dest;
+	struct mlx5_flow_attr flow_attr;
 	struct arfs_table *arfs_table;
-	u8 match_criteria_enable = 0;
 	struct mlx5_flow_table *ft;
 	u32 *match_criteria;
 	u32 *match_value;
 	int err = 0;
 
 	match_value	= mlx5_vzalloc(MLX5_ST_SZ_BYTES(fte_match_param));
-	match_criteria	= mlx5_vzalloc(MLX5_ST_SZ_BYTES(fte_match_param));
+	match_criteria = mlx5_vzalloc(MLX5_ST_SZ_BYTES(fte_match_param));
 	if (!match_value || !match_criteria) {
 		netdev_err(priv->netdev, "%s: alloc failed\n", __func__);
 		err = -ENOMEM;
 		goto out;
 	}
-	match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
 	MLX5_SET_TO_ONES(fte_match_param, match_criteria,
 			 outer_headers.ethertype);
 	MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
@@ -552,10 +550,10 @@ static struct mlx5_flow_rule *arfs_add_rule(struct mlx5e_priv *priv,
 	}
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_TIR;
 	dest.tir_num = priv->direct_tir[arfs_rule->rxq].tirn;
-	rule = mlx5_add_flow_rule(ft, match_criteria_enable, match_criteria,
-				  match_value, MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				  MLX5_FS_DEFAULT_FLOW_TAG,
-				  &dest);
+	MLX5_RULE_ATTR(flow_attr, MLX5_MATCH_OUTER_HEADERS, match_criteria,
+		       match_value, MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		       MLX5_FS_DEFAULT_FLOW_TAG, &dest);
+	rule = mlx5_add_flow_rule(ft, &flow_attr);
 	if (IS_ERR(rule)) {
 		err = PTR_ERR(rule);
 		netdev_err(priv->netdev, "%s: add rule(filter id=%d, rq idx=%d) failed, err=%d\n",
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index b327400..95e359f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -160,6 +160,7 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 {
 	struct mlx5_flow_table *ft = priv->fs.vlan.ft.t;
 	struct mlx5_flow_destination dest;
+	struct mlx5_flow_attr flow_attr;
 	u8 match_criteria_enable = 0;
 	struct mlx5_flow_rule **rule_p;
 	int err = 0;
@@ -186,10 +187,10 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 		break;
 	}
 
-	*rule_p = mlx5_add_flow_rule(ft, match_criteria_enable, mc, mv,
-				     MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				     MLX5_FS_DEFAULT_FLOW_TAG,
-				     &dest);
+	MLX5_RULE_ATTR(flow_attr, match_criteria_enable, mc, mv,
+		       MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		       MLX5_FS_DEFAULT_FLOW_TAG, &dest);
+	*rule_p = mlx5_add_flow_rule(ft, &flow_attr);
 
 	if (IS_ERR(*rule_p)) {
 		err = PTR_ERR(*rule_p);
@@ -597,6 +598,7 @@ static struct mlx5_flow_rule *mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
 						      u16 etype,
 						      u8 proto)
 {
+	struct mlx5_flow_attr flow_attr;
 	struct mlx5_flow_rule *rule;
 	u8 match_criteria_enable = 0;
 	u32 *match_criteria;
@@ -622,11 +624,10 @@ static struct mlx5_flow_rule *mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
 		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype, etype);
 	}
 
-	rule = mlx5_add_flow_rule(ft, match_criteria_enable,
-				  match_criteria, match_value,
-				  MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				  MLX5_FS_DEFAULT_FLOW_TAG,
-				  dest);
+	MLX5_RULE_ATTR(flow_attr, match_criteria_enable, match_criteria,
+		       match_value, MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		       MLX5_FS_DEFAULT_FLOW_TAG, dest);
+	rule = mlx5_add_flow_rule(ft, &flow_attr);
 	if (IS_ERR(rule)) {
 		err = PTR_ERR(rule);
 		netdev_err(priv->netdev, "%s: add rule failed\n", __func__);
@@ -792,6 +793,7 @@ static int mlx5e_add_l2_flow_rule(struct mlx5e_priv *priv,
 {
 	struct mlx5_flow_table *ft = priv->fs.l2.ft.t;
 	struct mlx5_flow_destination dest;
+	struct mlx5_flow_attr flow_attr;
 	u8 match_criteria_enable = 0;
 	u32 *match_criteria;
 	u32 *match_value;
@@ -832,10 +834,10 @@ static int mlx5e_add_l2_flow_rule(struct mlx5e_priv *priv,
 		break;
 	}
 
-	ai->rule = mlx5_add_flow_rule(ft, match_criteria_enable, match_criteria,
-				      match_value,
-				      MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				      MLX5_FS_DEFAULT_FLOW_TAG, &dest);
+	MLX5_RULE_ATTR(flow_attr, match_criteria_enable, match_criteria,
+		       match_value, MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		       MLX5_FS_DEFAULT_FLOW_TAG, &dest);
+	ai->rule = mlx5_add_flow_rule(ft, &flow_attr);
 	if (IS_ERR(ai->rule)) {
 		netdev_err(priv->netdev, "%s: add l2 rule(mac:%pM) failed\n",
 			   __func__, mv_dmac);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 704c3d3..0b634c6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -55,6 +55,7 @@ static struct mlx5_flow_rule *mlx5e_tc_add_flow(struct mlx5e_priv *priv,
 {
 	struct mlx5_core_dev *dev = priv->mdev;
 	struct mlx5_flow_destination dest = { 0 };
+	struct mlx5_flow_attr flow_attr;
 	struct mlx5_fc *counter = NULL;
 	struct mlx5_flow_rule *rule;
 	bool table_created = false;
@@ -88,10 +89,9 @@ static struct mlx5_flow_rule *mlx5e_tc_add_flow(struct mlx5e_priv *priv,
 		table_created = true;
 	}
 
-	rule = mlx5_add_flow_rule(priv->fs.tc.t, MLX5_MATCH_OUTER_HEADERS,
-				  match_c, match_v,
-				  action, flow_tag,
-				  &dest);
+	MLX5_RULE_ATTR(flow_attr, MLX5_MATCH_OUTER_HEADERS, match_c,
+		       match_v, action, flow_tag, &dest);
+	rule = mlx5_add_flow_rule(priv->fs.tc.t, &flow_attr);
 
 	if (IS_ERR(rule))
 		goto err_add_rule;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index aebbd6c..b8b17b5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -337,6 +337,7 @@ __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
 			    MLX5_MATCH_OUTER_HEADERS);
 	struct mlx5_flow_rule *flow_rule = NULL;
 	struct mlx5_flow_destination dest;
+	struct mlx5_flow_attr flow_attr;
 	void *mv_misc = NULL;
 	void *mc_misc = NULL;
 	u8 *dmac_v = NULL;
@@ -376,13 +377,10 @@ __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
 	esw_debug(esw->dev,
 		  "\tFDB add rule dmac_v(%pM) dmac_c(%pM) -> vport(%d)\n",
 		  dmac_v, dmac_c, vport);
-	flow_rule =
-		mlx5_add_flow_rule(esw->fdb_table.fdb,
-				   match_header,
-				   match_c,
-				   match_v,
-				   MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				   0, &dest);
+	MLX5_RULE_ATTR(flow_attr, match_header, match_c, match_v,
+		       MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		       0, &dest);
+	flow_rule = mlx5_add_flow_rule(esw->fdb_table.fdb, &flow_attr);
 	if (IS_ERR(flow_rule)) {
 		pr_warn(
 			"FDB: Failed to add flow rule: dmac_v(%pM) dmac_c(%pM) -> vport(%d), err(%ld)\n",
@@ -1300,6 +1298,7 @@ static void esw_vport_disable_ingress_acl(struct mlx5_eswitch *esw,
 static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 				    struct mlx5_vport *vport)
 {
+	struct mlx5_flow_attr flow_attr;
 	u8 smac[ETH_ALEN];
 	u32 *match_v;
 	u32 *match_c;
@@ -1357,13 +1356,11 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 		ether_addr_copy(smac_v, smac);
 	}
 
+	MLX5_RULE_ATTR(flow_attr, MLX5_MATCH_OUTER_HEADERS, match_c, match_v,
+		       MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+		       0, NULL);
 	vport->ingress.allow_rule =
-		mlx5_add_flow_rule(vport->ingress.acl,
-				   MLX5_MATCH_OUTER_HEADERS,
-				   match_c,
-				   match_v,
-				   MLX5_FLOW_CONTEXT_ACTION_ALLOW,
-				   0, NULL);
+		mlx5_add_flow_rule(vport->ingress.acl, &flow_attr);
 	if (IS_ERR(vport->ingress.allow_rule)) {
 		err = PTR_ERR(vport->ingress.allow_rule);
 		pr_warn("vport[%d] configure ingress allow rule, err(%d)\n",
@@ -1374,13 +1371,10 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 
 	memset(match_c, 0, MLX5_ST_SZ_BYTES(fte_match_param));
 	memset(match_v, 0, MLX5_ST_SZ_BYTES(fte_match_param));
+	flow_attr.flow_match.match_criteria_enable = 0;
+	flow_attr.action = MLX5_FLOW_CONTEXT_ACTION_DROP;
 	vport->ingress.drop_rule =
-		mlx5_add_flow_rule(vport->ingress.acl,
-				   0,
-				   match_c,
-				   match_v,
-				   MLX5_FLOW_CONTEXT_ACTION_DROP,
-				   0, NULL);
+		mlx5_add_flow_rule(vport->ingress.acl, &flow_attr);
 	if (IS_ERR(vport->ingress.drop_rule)) {
 		err = PTR_ERR(vport->ingress.drop_rule);
 		pr_warn("vport[%d] configure ingress drop rule, err(%d)\n",
@@ -1401,6 +1395,7 @@ out:
 static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 				   struct mlx5_vport *vport)
 {
+	struct mlx5_flow_attr flow_attr;
 	u32 *match_v;
 	u32 *match_c;
 	int err = 0;
@@ -1433,13 +1428,11 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 	MLX5_SET_TO_ONES(fte_match_param, match_c, outer_headers.first_vid);
 	MLX5_SET(fte_match_param, match_v, outer_headers.first_vid, vport->vlan);
 
+	MLX5_RULE_ATTR(flow_attr, MLX5_MATCH_OUTER_HEADERS, match_c, match_v,
+		       MLX5_FLOW_CONTEXT_ACTION_ALLOW,
+		       0, NULL);
 	vport->egress.allowed_vlan =
-		mlx5_add_flow_rule(vport->egress.acl,
-				   MLX5_MATCH_OUTER_HEADERS,
-				   match_c,
-				   match_v,
-				   MLX5_FLOW_CONTEXT_ACTION_ALLOW,
-				   0, NULL);
+		mlx5_add_flow_rule(vport->egress.acl, &flow_attr);
 	if (IS_ERR(vport->egress.allowed_vlan)) {
 		err = PTR_ERR(vport->egress.allowed_vlan);
 		pr_warn("vport[%d] configure egress allowed vlan rule failed, err(%d)\n",
@@ -1451,13 +1444,9 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 	/* Drop others rule (star rule) */
 	memset(match_c, 0, MLX5_ST_SZ_BYTES(fte_match_param));
 	memset(match_v, 0, MLX5_ST_SZ_BYTES(fte_match_param));
+	flow_attr.flow_match.match_criteria_enable = 0;
 	vport->egress.drop_rule =
-		mlx5_add_flow_rule(vport->egress.acl,
-				   0,
-				   match_c,
-				   match_v,
-				   MLX5_FLOW_CONTEXT_ACTION_DROP,
-				   0, NULL);
+		mlx5_add_flow_rule(vport->egress.acl, &flow_attr);
 	if (IS_ERR(vport->egress.drop_rule)) {
 		err = PTR_ERR(vport->egress.drop_rule);
 		pr_warn("vport[%d] configure egress drop rule failed, err(%d)\n",
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index e912a3d..9f613aa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1152,39 +1152,37 @@ static bool dest_is_valid(struct mlx5_flow_destination *dest,
 
 static struct mlx5_flow_rule *
 _mlx5_add_flow_rule(struct mlx5_flow_table *ft,
-		    u8 match_criteria_enable,
-		    u32 *match_criteria,
-		    u32 *match_value,
-		    u32 action,
-		    u32 flow_tag,
-		    struct mlx5_flow_destination *dest)
+		    struct mlx5_flow_attr *attr)
 {
+	struct mlx5_flow_match *match = &attr->flow_match;
 	struct mlx5_flow_group *g;
 	struct mlx5_flow_rule *rule;
 
-	if (!dest_is_valid(dest, action, ft))
+	if (!dest_is_valid(attr->dest, attr->action, ft))
 		return ERR_PTR(-EINVAL);
 
 	nested_lock_ref_node(&ft->node, FS_MUTEX_GRANDPARENT);
 	fs_for_each_fg(g, ft)
 		if (compare_match_criteria(g->mask.match_criteria_enable,
-					   match_criteria_enable,
+					   match->match_criteria_enable,
 					   g->mask.match_criteria,
-					   match_criteria)) {
-			rule = add_rule_fg(g, match_value,
-					   action, flow_tag, dest);
+					   match->match_criteria)) {
+			rule = add_rule_fg(g, match->match_value,
+					   attr->action, attr->flow_tag,
+					   attr->dest);
 			if (!IS_ERR(rule) || PTR_ERR(rule) != -ENOSPC)
 				goto unlock;
 		}
 
-	g = create_autogroup(ft, match_criteria_enable, match_criteria);
+	g = create_autogroup(ft, match->match_criteria_enable,
+			     match->match_criteria);
 	if (IS_ERR(g)) {
 		rule = (void *)g;
 		goto unlock;
 	}
 
-	rule = add_rule_fg(g, match_value,
-			   action, flow_tag, dest);
+	rule = add_rule_fg(g, match->match_value,
+			   attr->action, attr->flow_tag, attr->dest);
 	if (IS_ERR(rule)) {
 		/* Remove assumes refcount > 0 and autogroup creates a group
 		 * with a refcount = 0.
@@ -1207,41 +1205,35 @@ static bool fwd_next_prio_supported(struct mlx5_flow_table *ft)
 
 struct mlx5_flow_rule *
 mlx5_add_flow_rule(struct mlx5_flow_table *ft,
-		   u8 match_criteria_enable,
-		   u32 *match_criteria,
-		   u32 *match_value,
-		   u32 action,
-		   u32 flow_tag,
-		   struct mlx5_flow_destination *dest)
+		   struct mlx5_flow_attr *attr)
 {
 	struct mlx5_flow_root_namespace *root = find_root(&ft->node);
 	struct mlx5_flow_destination gen_dest;
 	struct mlx5_flow_table *next_ft = NULL;
 	struct mlx5_flow_rule *rule = NULL;
-	u32 sw_action = action;
+	u32 sw_action = attr->action;
 	struct fs_prio *prio;
 
 	fs_get_obj(prio, ft->node.parent);
-	if (action == MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO) {
+	if (attr->action == MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO) {
 		if (!fwd_next_prio_supported(ft))
 			return ERR_PTR(-EOPNOTSUPP);
-		if (dest)
+		if (attr->dest)
 			return ERR_PTR(-EINVAL);
 		mutex_lock(&root->chain_lock);
 		next_ft = find_next_chained_ft(prio);
 		if (next_ft) {
 			gen_dest.type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE;
 			gen_dest.ft = next_ft;
-			dest = &gen_dest;
-			action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+			attr->dest = &gen_dest;
+			attr->action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 		} else {
 			mutex_unlock(&root->chain_lock);
 			return ERR_PTR(-EOPNOTSUPP);
 		}
 	}
 
-	rule =	_mlx5_add_flow_rule(ft, match_criteria_enable, match_criteria,
-				    match_value, action, flow_tag, dest);
+	rule =	_mlx5_add_flow_rule(ft, attr);
 
 	if (sw_action == MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO) {
 		if (!IS_ERR_OR_NULL(rule) &&
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 4b7a107..b300d43 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -67,6 +67,28 @@ struct mlx5_flow_group;
 struct mlx5_flow_rule;
 struct mlx5_flow_namespace;
 
+#define MLX5_RULE_ATTR(attr, mc_e, mc, mv, action_v, flow_tag_v, dest_v)  {\
+	attr.flow_match.match_criteria_enable = mc_e;		\
+	attr.flow_match.match_criteria = mc;			\
+	attr.flow_match.match_value = mv;			\
+	attr.action = action_v;					\
+	attr.flow_tag = flow_tag_v;				\
+	attr.dest = dest_v;					\
+}
+
+struct mlx5_flow_match {
+	   u8 match_criteria_enable;
+	   u32 *match_criteria;
+	   u32 *match_value;
+};
+
+struct mlx5_flow_attr {
+	struct mlx5_flow_match flow_match;
+	u32 action;
+	u32 flow_tag;
+	struct mlx5_flow_destination *dest;
+};
+
 struct mlx5_flow_destination {
 	enum mlx5_flow_destination_type	type;
 	union {
@@ -115,12 +137,7 @@ void mlx5_destroy_flow_group(struct mlx5_flow_group *fg);
  */
 struct mlx5_flow_rule *
 mlx5_add_flow_rule(struct mlx5_flow_table *ft,
-		   u8 match_criteria_enable,
-		   u32 *match_criteria,
-		   u32 *match_value,
-		   u32 action,
-		   u32 flow_tag,
-		   struct mlx5_flow_destination *dest);
+		   struct mlx5_flow_attr *attr);
 void mlx5_del_flow_rule(struct mlx5_flow_rule *fr);
 
 int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
-- 
2.8.0
