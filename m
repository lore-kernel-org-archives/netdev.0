From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next V2 11/15] net/mlx5: Refactor find_flow_rule
Date: Sun, 30 Oct 2016 23:22:04 +0200
Message-ID: <1477862528-4328-12-git-send-email-saeedm@mellanox.com>
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

The way we compare between two dests will need to be used in other
places in the future, so we factor out the comparison logic
between two dests into a separate function.

Signed-off-by: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 29 ++++++++++++++++-------
 1 file changed, 20 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index e2bab9d..fca6937 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -153,6 +153,8 @@ static void del_rule(struct fs_node *node);
 static void del_flow_table(struct fs_node *node);
 static void del_flow_group(struct fs_node *node);
 static void del_fte(struct fs_node *node);
+static bool mlx5_flow_dests_cmp(struct mlx5_flow_destination *d1,
+				struct mlx5_flow_destination *d2);
 
 static void tree_init_node(struct fs_node *node,
 			   unsigned int refcount,
@@ -1064,21 +1066,30 @@ static struct mlx5_flow_group *create_autogroup(struct mlx5_flow_table *ft,
 	return fg;
 }
 
+static bool mlx5_flow_dests_cmp(struct mlx5_flow_destination *d1,
+				struct mlx5_flow_destination *d2)
+{
+	if (d1->type == d2->type) {
+		if ((d1->type == MLX5_FLOW_DESTINATION_TYPE_VPORT &&
+		     d1->vport_num == d2->vport_num) ||
+		    (d1->type == MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE &&
+		     d1->ft == d2->ft) ||
+		    (d1->type == MLX5_FLOW_DESTINATION_TYPE_TIR &&
+		     d1->tir_num == d2->tir_num))
+			return true;
+	}
+
+	return false;
+}
+
 static struct mlx5_flow_rule *find_flow_rule(struct fs_fte *fte,
 					     struct mlx5_flow_destination *dest)
 {
 	struct mlx5_flow_rule *rule;
 
 	list_for_each_entry(rule, &fte->node.children, node.list) {
-		if (rule->dest_attr.type == dest->type) {
-			if ((dest->type == MLX5_FLOW_DESTINATION_TYPE_VPORT &&
-			     dest->vport_num == rule->dest_attr.vport_num) ||
-			    (dest->type == MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE &&
-			     dest->ft == rule->dest_attr.ft) ||
-			    (dest->type == MLX5_FLOW_DESTINATION_TYPE_TIR &&
-			     dest->tir_num == rule->dest_attr.tir_num))
-				return rule;
-		}
+		if (mlx5_flow_dests_cmp(&rule->dest_attr, dest))
+			return rule;
 	}
 	return NULL;
 }
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
