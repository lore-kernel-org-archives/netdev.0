From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next V2 12/15] net/mlx5: Group similer rules under the same fte
Date: Sun, 30 Oct 2016 23:22:05 +0200
Message-ID: <1477862528-4328-13-git-send-email-saeedm@mellanox.com>
References: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477862528-4328-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

When adding a new rule, if we can match it with compare_match_value and
flow tag we might be able to insert the rule to the same fte.
In order to do that, there must be an overlap between the actions of the
fte and the new rule.

When updating the action of an existing fte, we must tell the firmware
we are doing so.

Signed-off-by: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index fca6937..43d7052 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -920,7 +920,8 @@ static struct mlx5_flow_rule *alloc_rule(struct mlx5_flow_destination *dest)
 /* fte should not be deleted while calling this function */
 static struct mlx5_flow_rule *add_rule_fte(struct fs_fte *fte,
 					   struct mlx5_flow_group *fg,
-					   struct mlx5_flow_destination *dest)
+					   struct mlx5_flow_destination *dest,
+					   bool update_action)
 {
 	struct mlx5_flow_table *ft;
 	struct mlx5_flow_rule *rule;
@@ -931,6 +932,9 @@ static struct mlx5_flow_rule *add_rule_fte(struct fs_fte *fte,
 	if (!rule)
 		return ERR_PTR(-ENOMEM);
 
+	if (update_action)
+		modify_mask |= BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_ACTION);
+
 	fs_get_obj(ft, fg->node.parent);
 	/* Add dest to dests list- we need flow tables to be in the
 	 * end of the list for forward to next prio rules.
@@ -1109,7 +1113,9 @@ static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
 	fs_for_each_fte(fte, fg) {
 		nested_lock_ref_node(&fte->node, FS_MUTEX_CHILD);
 		if (compare_match_value(&fg->mask, match_value, &fte->val) &&
-		    action == fte->action && flow_tag == fte->flow_tag) {
+		    (action & fte->action) && flow_tag == fte->flow_tag) {
+			int old_action = fte->action;
+
 			rule = find_flow_rule(fte, dest);
 			if (rule) {
 				atomic_inc(&rule->node.refcount);
@@ -1117,11 +1123,15 @@ static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
 				unlock_ref_node(&fg->node);
 				return rule;
 			}
-			rule = add_rule_fte(fte, fg, dest);
-			if (IS_ERR(rule))
+			fte->action |= action;
+			rule = add_rule_fte(fte, fg, dest,
+					    old_action != action);
+			if (IS_ERR(rule)) {
+				fte->action = old_action;
 				goto unlock_fte;
-			else
+			} else {
 				goto add_rule;
+			}
 		}
 		unlock_ref_node(&fte->node);
 	}
@@ -1138,7 +1148,7 @@ static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
 	}
 	tree_init_node(&fte->node, 0, del_fte);
 	nested_lock_ref_node(&fte->node, FS_MUTEX_CHILD);
-	rule = add_rule_fte(fte, fg, dest);
+	rule = add_rule_fte(fte, fg, dest, false);
 	if (IS_ERR(rule)) {
 		kfree(fte);
 		goto unlock_fg;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
