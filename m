From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 3/7] net/mlx5_core: Add flow steering lookup algorithms
Date: Wed,  9 Dec 2015 00:03:41 +0200
Message-ID: <1449612225-30789-4-git-send-email-saeedm@mellanox.com>
References: <1449612225-30789-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Matan Barak <matanb@mellanox.com>, saeedm@dev.mellanox.co.il,
	Moni Shoua <monis@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41085 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750862AbbLHWEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 17:04:11 -0500
In-Reply-To: <1449612225-30789-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Introduce the flow steering mlx5_flow_namespace (Namespace)
and fs_prio (Flow Steering Priority) tree nodes.

Namespaces are used in order to isolate different usages or types
of steering (for example, downstream patches will add a different
namespaces for the NIC driver and for E-Switch FDB usages).

Flow Steering Priorities are objects that describes priorities
ranges between different flow objects under the same namespace.

Example, entries in priority i are matched before entries
in priority i+1.

This patch adds the following algorithms:

1) Calculate level:
Each flow table has level(the priority between the flow tables).
When we initialize the flow steering tree, we assign range of levels
to each priority, therefore the level for new flow table is
the location within the priority related to the range of the priority.

2) Match between match criteria. This function is used
for searching flow group when new flow rule is added.

3) Match between match values. This function is used
for searching flow table entry  when new flow rule is added.

4) Add essential macros for traversing on a node's children.
E.g. traversing on all the flow table of some priority

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |   93 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |   41 +++++++++
 2 files changed, 134 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 3c54d7b..cac0d15 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -114,3 +114,96 @@ static int tree_remove_node(struct fs_node *node)
 	tree_put_node(node);
 	return 0;
 }
+
+static struct fs_prio *find_prio(struct mlx5_flow_namespace *ns,
+				 unsigned int prio)
+{
+	struct fs_prio *iter_prio;
+
+	fs_for_each_prio(iter_prio, ns) {
+		if (iter_prio->prio == prio)
+			return iter_prio;
+	}
+
+	return NULL;
+}
+
+static unsigned int find_next_free_level(struct fs_prio *prio)
+{
+	if (!list_empty(&prio->node.children)) {
+		struct mlx5_flow_table *ft;
+
+		ft = list_last_entry(&prio->node.children,
+				     struct mlx5_flow_table,
+				     node.list);
+		return ft->level + 1;
+	}
+	return prio->start_level;
+}
+
+static bool masked_memcmp(void *mask, void *val1, void *val2, size_t size)
+{
+	unsigned int i;
+
+	for (i = 0; i < size; i++, mask++, val1++, val2++)
+		if ((*((u8 *)val1) & (*(u8 *)mask)) !=
+		    ((*(u8 *)val2) & (*(u8 *)mask)))
+			return false;
+
+	return true;
+}
+
+static bool compare_match_value(struct mlx5_flow_group_mask *mask,
+				void *fte_param1, void *fte_param2)
+{
+	if (mask->match_criteria_enable &
+	    1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_OUTER_HEADERS) {
+		void *fte_match1 = MLX5_ADDR_OF(fte_match_param,
+						fte_param1, outer_headers);
+		void *fte_match2 = MLX5_ADDR_OF(fte_match_param,
+						fte_param2, outer_headers);
+		void *fte_mask = MLX5_ADDR_OF(fte_match_param,
+					      mask->match_criteria, outer_headers);
+
+		if (!masked_memcmp(fte_mask, fte_match1, fte_match2,
+				   MLX5_ST_SZ_BYTES(fte_match_set_lyr_2_4)))
+			return false;
+	}
+
+	if (mask->match_criteria_enable &
+	    1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_MISC_PARAMETERS) {
+		void *fte_match1 = MLX5_ADDR_OF(fte_match_param,
+						fte_param1, misc_parameters);
+		void *fte_match2 = MLX5_ADDR_OF(fte_match_param,
+						fte_param2, misc_parameters);
+		void *fte_mask = MLX5_ADDR_OF(fte_match_param,
+					  mask->match_criteria, misc_parameters);
+
+		if (!masked_memcmp(fte_mask, fte_match1, fte_match2,
+				   MLX5_ST_SZ_BYTES(fte_match_set_misc)))
+			return false;
+	}
+
+	if (mask->match_criteria_enable &
+	    1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_INNER_HEADERS) {
+		void *fte_match1 = MLX5_ADDR_OF(fte_match_param,
+						fte_param1, inner_headers);
+		void *fte_match2 = MLX5_ADDR_OF(fte_match_param,
+						fte_param2, inner_headers);
+		void *fte_mask = MLX5_ADDR_OF(fte_match_param,
+					  mask->match_criteria, inner_headers);
+
+		if (!masked_memcmp(fte_mask, fte_match1, fte_match2,
+				   MLX5_ST_SZ_BYTES(fte_match_set_lyr_2_4)))
+			return false;
+	}
+	return true;
+}
+
+static bool compare_match_criteria(u8 match_criteria_enable1,
+				   u8 match_criteria_enable2,
+				   void *mask1, void *mask2)
+{
+	return match_criteria_enable1 == match_criteria_enable2 &&
+		!memcmp(mask1, mask2, MLX5_ST_SZ_BYTES(fte_match_param));
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index ae03ae4..b033714 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -72,6 +72,7 @@ struct mlx5_flow_rule {
 struct mlx5_flow_table {
 	struct fs_node			node;
 	u32				id;
+	unsigned int			level;
 	enum fs_flow_table_type		type;
 };
 
@@ -84,4 +85,44 @@ struct fs_fte {
 	u32				action;
 };
 
+struct fs_prio {
+	struct fs_node			node;
+	unsigned int			max_ft;
+	unsigned int			start_level;
+	unsigned int			prio;
+};
+
+struct mlx5_flow_namespace {
+	/* parent == NULL => root ns */
+	struct	fs_node			node;
+};
+
+struct mlx5_flow_group_mask {
+	u8	match_criteria_enable;
+	u32	match_criteria[MLX5_ST_SZ_DW(fte_match_param)];
+};
+
+#define fs_get_obj(v, _node)  {v = container_of((_node), typeof(*v), node); }
+
+#define fs_list_for_each_entry(pos, root)		\
+	list_for_each_entry(pos, root, node.list)
+
+#define fs_for_each_ns_or_ft_reverse(pos, prio)				\
+	list_for_each_entry_reverse(pos, &(prio)->node.children, list)
+
+#define fs_for_each_ns_or_ft(pos, prio)					\
+	list_for_each_entry(pos, (&(prio)->node.children), list)
+
+#define fs_for_each_prio(pos, ns)			\
+	fs_list_for_each_entry(pos, &(ns)->node.children)
+
+#define fs_for_each_fg(pos, ft)			\
+	fs_list_for_each_entry(pos, &(ft)->node.children)
+
+#define fs_for_each_fte(pos, fg)			\
+	fs_list_for_each_entry(pos, &(fg)->node.children)
+
+#define fs_for_each_dst(pos, fte)			\
+	fs_list_for_each_entry(pos, &(fte)->node.children)
+
 #endif
-- 
1.7.1
