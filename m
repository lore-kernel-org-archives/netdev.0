From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH  V3 02/11] net/mlx5_core: Add utilities to find next and prev flow-tables
Date: Mon, 11 Jan 2016 10:25:58 +0200
Message-ID: <1452500767-3628-3-git-send-email-ogerlitz@mellanox.com>
References: <1452500767-3628-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Matan Barak <matanb@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Moni Shoua <monis@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59618 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758227AbcAKI0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 03:26:50 -0500
In-Reply-To: <1452500767-3628-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Add two utility functions for find next and prev flow table.
Find next flow table function gets priority and return the
first flow table of the next priority in the tree.
Find prev flow table return the last flow table of
the previous priority in the tree.

These utility functions are used for chaining flow table from different
priorities.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 67 +++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 7d24bbb..c5a96e6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -443,6 +443,73 @@ static struct mlx5_flow_table *alloc_flow_table(int level, int max_fte,
 	return ft;
 }
 
+/* If reverse is false, then we search for the first flow table in the
+ * root sub-tree from start(closest from right), else we search for the
+ * last flow table in the root sub-tree till start(closest from left).
+ */
+static struct mlx5_flow_table *find_closest_ft_recursive(struct fs_node  *root,
+							 struct list_head *start,
+							 bool reverse)
+{
+#define list_advance_entry(pos, reverse)		\
+	((reverse) ? list_prev_entry(pos, list) : list_next_entry(pos, list))
+
+#define list_for_each_advance_continue(pos, head, reverse)	\
+	for (pos = list_advance_entry(pos, reverse);		\
+	     &pos->list != (head);				\
+	     pos = list_advance_entry(pos, reverse))
+
+	struct fs_node *iter = list_entry(start, struct fs_node, list);
+	struct mlx5_flow_table *ft = NULL;
+
+	if (!root)
+		return NULL;
+
+	list_for_each_advance_continue(iter, &root->children, reverse) {
+		if (iter->type == FS_TYPE_FLOW_TABLE) {
+			fs_get_obj(ft, iter);
+			return ft;
+		}
+		ft = find_closest_ft_recursive(iter, &iter->children, reverse);
+		if (ft)
+			return ft;
+	}
+
+	return ft;
+}
+
+/* If reverse if false then return the first flow table in next priority of
+ * prio in the tree, else return the last flow table in the previous priority
+ * of prio in the tree.
+ */
+static struct mlx5_flow_table *find_closest_ft(struct fs_prio *prio, bool reverse)
+{
+	struct mlx5_flow_table *ft = NULL;
+	struct fs_node *curr_node;
+	struct fs_node *parent;
+
+	parent = prio->node.parent;
+	curr_node = &prio->node;
+	while (!ft && parent) {
+		ft = find_closest_ft_recursive(parent, &curr_node->list, reverse);
+		curr_node = parent;
+		parent = curr_node->parent;
+	}
+	return ft;
+}
+
+/* Assuming all the tree is locked by mutex chain lock */
+static struct mlx5_flow_table *find_next_chained_ft(struct fs_prio *prio)
+{
+	return find_closest_ft(prio, false);
+}
+
+/* Assuming all the tree is locked by mutex chain lock */
+static struct mlx5_flow_table *find_prev_chained_ft(struct fs_prio *prio)
+{
+	return find_closest_ft(prio, true);
+}
+
 struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
 					       int prio,
 					       int max_fte)
-- 
2.3.7
