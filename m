From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 4/8] net/mlx5_core: Set flow steering dest only for forward rules
Date: Tue,  1 Mar 2016 16:24:46 +0200
Message-ID: <1456842290-7844-5-git-send-email-amir@vadai.me>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>, Amir Vadai <amir@vadai.me>,
	Maor Gottlieb <maorg@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34943 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859AbcCAOVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 09:21:45 -0500
Received: by mail-wm0-f65.google.com with SMTP id 1so4350614wmg.2
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 06:21:44 -0800 (PST)
In-Reply-To: <1456842290-7844-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to handle flow table entry destinations only if the action
associated with the rule is forwarding (MLX5_FLOW_CONTEXT_ACTION_FWD_DEST).

Fixes: 26a8145390b3 ('net/mlx5_core: Introduce flow steering firmware commands')
Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  | 29 +++++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 18 +++++++++-----
 2 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index a9894d2..f46f1db 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -218,19 +218,22 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 				      match_value);
 	memcpy(in_match_value, &fte->val, MLX5_ST_SZ_BYTES(fte_match_param));
 
-	in_dests = MLX5_ADDR_OF(flow_context, in_flow_context, destination);
-	list_for_each_entry(dst, &fte->node.children, node.list) {
-		unsigned int id;
-
-		MLX5_SET(dest_format_struct, in_dests, destination_type,
-			 dst->dest_attr.type);
-		if (dst->dest_attr.type ==
-		    MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE)
-			id = dst->dest_attr.ft->id;
-		else
-			id = dst->dest_attr.tir_num;
-		MLX5_SET(dest_format_struct, in_dests, destination_id, id);
-		in_dests += MLX5_ST_SZ_BYTES(dest_format_struct);
+	if (fte->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
+		in_dests = MLX5_ADDR_OF(flow_context, in_flow_context, destination);
+		list_for_each_entry(dst, &fte->node.children, node.list) {
+			unsigned int id;
+
+			MLX5_SET(dest_format_struct, in_dests, destination_type,
+				 dst->dest_attr.type);
+			if (dst->dest_attr.type ==
+			    MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE) {
+				id = dst->dest_attr.ft->id;
+			} else {
+				id = dst->dest_attr.tir_num;
+			}
+			MLX5_SET(dest_format_struct, in_dests, destination_id, id);
+			in_dests += MLX5_ST_SZ_BYTES(dest_format_struct);
+		}
 	}
 	memset(out, 0, sizeof(out));
 	err = mlx5_cmd_exec_check_status(dev, in, inlen, out,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 6f68dba..f0e67d2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -360,8 +360,8 @@ static void del_rule(struct fs_node *node)
 	memcpy(match_value, fte->val, sizeof(fte->val));
 	fs_get_obj(ft, fg->node.parent);
 	list_del(&rule->node.list);
-	fte->dests_size--;
-	if (fte->dests_size) {
+	if ((fte->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) &&
+	    --fte->dests_size) {
 		err = mlx5_cmd_update_fte(dev, ft,
 					  fg->id, fte);
 		if (err)
@@ -763,7 +763,8 @@ static struct mlx5_flow_rule *alloc_rule(struct mlx5_flow_destination *dest)
 		return NULL;
 
 	rule->node.type = FS_TYPE_FLOW_DEST;
-	memcpy(&rule->dest_attr, dest, sizeof(*dest));
+	if (dest)
+		memcpy(&rule->dest_attr, dest, sizeof(*dest));
 
 	return rule;
 }
@@ -785,8 +786,9 @@ static struct mlx5_flow_rule *add_rule_fte(struct fs_fte *fte,
 	/* Add dest to dests list- added as first element after the head */
 	tree_init_node(&rule->node, 1, del_rule);
 	list_add_tail(&rule->node.list, &fte->node.children);
-	fte->dests_size++;
-	if (fte->dests_size == 1)
+	if (dest)
+		fte->dests_size++;
+	if (fte->dests_size == 1 || !dest)
 		err = mlx5_cmd_create_fte(get_dev(&ft->node),
 					  ft, fg->id, fte);
 	else
@@ -802,7 +804,8 @@ static struct mlx5_flow_rule *add_rule_fte(struct fs_fte *fte,
 free_rule:
 	list_del(&rule->node.list);
 	kfree(rule);
-	fte->dests_size--;
+	if (dest)
+		fte->dests_size--;
 	return ERR_PTR(err);
 }
 
@@ -996,6 +999,9 @@ mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 	struct mlx5_flow_group *g;
 	struct mlx5_flow_rule *rule;
 
+	if ((action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) && !dest)
+		return ERR_PTR(-EINVAL);
+
 	nested_lock_ref_node(&ft->node, FS_MUTEX_GRANDPARENT);
 	fs_for_each_fg(g, ft)
 		if (compare_match_criteria(g->mask.match_criteria_enable,
-- 
2.7.0
