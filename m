From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V1 1/8] net/mlx5_core: Fix soft lockup in steering error flow
Date: Fri, 22 Apr 2016 00:33:00 +0300
Message-ID: <1461274387-10653-2-git-send-email-saeedm@mellanox.com>
References: <1461274387-10653-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60170 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752215AbcDUVeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 17:34:03 -0400
In-Reply-To: <1461274387-10653-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

In the error flow of adding flow rule to auto-grouped flow
table, we call to tree_remove_node.

tree_remove_node locks the node's parent, however the node's parent
is already locked by mlx5_add_flow_rule and this causes a deadlock.
After this patch, if we failed to add the flow rule, we unlock the
flow table before calling to tree_remove_node.

fixes: f0d22d187473 ('net/mlx5_core: Introduce flow steering autogrouped
flow table')
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Reported-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |   46 ++++++++-------------
 1 files changed, 17 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 5121be4..3c7e3e5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1065,33 +1065,6 @@ unlock_fg:
 	return rule;
 }
 
-static struct mlx5_flow_rule *add_rule_to_auto_fg(struct mlx5_flow_table *ft,
-						  u8 match_criteria_enable,
-						  u32 *match_criteria,
-						  u32 *match_value,
-						  u8 action,
-						  u32 flow_tag,
-						  struct mlx5_flow_destination *dest)
-{
-	struct mlx5_flow_rule *rule;
-	struct mlx5_flow_group *g;
-
-	g = create_autogroup(ft, match_criteria_enable, match_criteria);
-	if (IS_ERR(g))
-		return (void *)g;
-
-	rule = add_rule_fg(g, match_value,
-			   action, flow_tag, dest);
-	if (IS_ERR(rule)) {
-		/* Remove assumes refcount > 0 and autogroup creates a group
-		 * with a refcount = 0.
-		 */
-		tree_get_node(&g->node);
-		tree_remove_node(&g->node);
-	}
-	return rule;
-}
-
 static struct mlx5_flow_rule *
 _mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 		    u8 match_criteria_enable,
@@ -1119,8 +1092,23 @@ _mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 				goto unlock;
 		}
 
-	rule = add_rule_to_auto_fg(ft, match_criteria_enable, match_criteria,
-				   match_value, action, flow_tag, dest);
+	g = create_autogroup(ft, match_criteria_enable, match_criteria);
+	if (IS_ERR(g)) {
+		rule = (void *)g;
+		goto unlock;
+	}
+
+	rule = add_rule_fg(g, match_value,
+			   action, flow_tag, dest);
+	if (IS_ERR(rule)) {
+		/* Remove assumes refcount > 0 and autogroup creates a group
+		 * with a refcount = 0.
+		 */
+		unlock_ref_node(&ft->node);
+		tree_get_node(&g->node);
+		tree_remove_node(&g->node);
+		return rule;
+	}
 unlock:
 	unlock_ref_node(&ft->node);
 	return rule;
-- 
1.7.1
