From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 07/12] net/mlx5_core: Initialize namespaces only when supported by device
Date: Wed,  6 Jan 2016 23:52:26 +0200
Message-ID: <1452117151-28572-8-git-send-email-saeedm@mellanox.com>
References: <1452117151-28572-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Moni Shoua <monis@mellanox.com>, saeedm@dev.mellanox.co.il,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:43835 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752249AbcAFVxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 16:53:34 -0500
In-Reply-To: <1452117151-28572-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Before we create the sub tree of a steering namespaces(kernel, bypass,
leftovers) we check that the device has the required capabilities
in order to create this subtree.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |   70 ++++++++++++++------
 1 files changed, 49 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index e1282e8..96e287a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -40,20 +40,17 @@
 #define INIT_TREE_NODE_ARRAY_SIZE(...)	(sizeof((struct init_tree_node[]){__VA_ARGS__}) /\
 					 sizeof(struct init_tree_node))
 
-#define INIT_PRIO(min_level_val, max_ft_val,\
-		  ...) {.type = FS_TYPE_PRIO,\
+#define ADD_PRIO(min_level_val, max_ft_val, caps_val,\
+		 ...) {.type = FS_TYPE_PRIO,\
 	.min_ft_level = min_level_val,\
 	.max_ft = max_ft_val,\
+	.caps = caps_val,\
 	.children = (struct init_tree_node[]) {__VA_ARGS__},\
 	.ar_size = INIT_TREE_NODE_ARRAY_SIZE(__VA_ARGS__) \
 }
 
-#define ADD_PRIO(min_level_val, max_ft_val, ...)\
-	INIT_PRIO(min_level_val, max_ft_val,\
-		  __VA_ARGS__)\
-
 #define ADD_FT_PRIO(max_ft_val, ...)\
-	INIT_PRIO(0, max_ft_val,\
+	ADD_PRIO(0, max_ft_val, {},\
 		  __VA_ARGS__)\
 
 #define ADD_NS(...) {.type = FS_TYPE_NAMESPACE,\
@@ -61,12 +58,26 @@
 	.ar_size = INIT_TREE_NODE_ARRAY_SIZE(__VA_ARGS__) \
 }
 
+#define INIT_CAPS_ARRAY_SIZE(...) (sizeof((long[]){__VA_ARGS__}) /\
+				   sizeof(long))
+
+#define FS_CAP(cap) (__mlx5_bit_off(flow_table_nic_cap, cap))
+
+#define FS_REQUIRED_CAPS(...) {.arr_sz = INIT_CAPS_ARRAY_SIZE(__VA_ARGS__), \
+			       .caps = (long[]) {__VA_ARGS__} }
+
 #define KERNEL_MAX_FT 2
 #define KENREL_MIN_LEVEL 2
+
+struct node_caps {
+	size_t	arr_sz;
+	long	*caps;
+};
 static struct init_tree_node {
 	enum fs_node_type	type;
 	struct init_tree_node *children;
 	int ar_size;
+	struct node_caps caps;
 	int min_ft_level;
 	int prio;
 	int max_ft;
@@ -74,7 +85,7 @@ static struct init_tree_node {
 	.type = FS_TYPE_NAMESPACE,
 	.ar_size = 1,
 	.children = (struct init_tree_node[]) {
-		ADD_PRIO(KENREL_MIN_LEVEL, 0,
+		ADD_PRIO(KENREL_MIN_LEVEL, 0, {},
 			 ADD_NS(ADD_FT_PRIO(KERNEL_MAX_FT))),
 	}
 };
@@ -1153,11 +1164,31 @@ static struct mlx5_flow_namespace *fs_create_namespace(struct fs_prio *prio)
 	return ns;
 }
 
-static int init_root_tree_recursive(int max_ft_level, struct init_tree_node *init_node,
+#define FLOW_TABLE_BIT_SZ 1
+#define GET_FLOW_TABLE_CAP(dev, offset) \
+	((be32_to_cpu(*((__be32 *)(dev->hca_caps_cur[MLX5_CAP_FLOW_TABLE]) +	\
+			offset / 32)) >>					\
+	  (32 - FLOW_TABLE_BIT_SZ - (offset & 0x1f))) & FLOW_TABLE_BIT_SZ)
+static bool has_required_caps(struct mlx5_core_dev *dev, struct node_caps *caps)
+{
+	int i;
+
+	for (i = 0; i < caps->arr_sz; i++) {
+		if (!GET_FLOW_TABLE_CAP(dev, caps->caps[i]))
+			return false;
+	}
+	return true;
+}
+
+static int init_root_tree_recursive(struct mlx5_core_dev *dev,
+				    struct init_tree_node *init_node,
 				    struct fs_node *fs_parent_node,
 				    struct init_tree_node *init_parent_node,
 				    int index)
 {
+	int max_ft_level = MLX5_CAP_FLOWTABLE(dev,
+					      flow_table_properties_nic_receive.
+					      max_ft_level);
 	struct mlx5_flow_namespace *fs_ns;
 	struct fs_prio *fs_prio;
 	struct fs_node *base;
@@ -1165,8 +1196,9 @@ static int init_root_tree_recursive(int max_ft_level, struct init_tree_node *ini
 	int err;
 
 	if (init_node->type == FS_TYPE_PRIO) {
-		if (init_node->min_ft_level > max_ft_level)
-			return -ENOTSUPP;
+		if ((init_node->min_ft_level > max_ft_level) ||
+		    !has_required_caps(dev, &init_node->caps))
+			return 0;
 
 		fs_get_obj(fs_ns, fs_parent_node);
 		fs_prio = fs_create_prio(fs_ns, index, init_node->max_ft);
@@ -1183,9 +1215,8 @@ static int init_root_tree_recursive(int max_ft_level, struct init_tree_node *ini
 		return -EINVAL;
 	}
 	for (i = 0; i < init_node->ar_size; i++) {
-		err = init_root_tree_recursive(max_ft_level,
-					       &init_node->children[i], base,
-					       init_node, i);
+		err = init_root_tree_recursive(dev, &init_node->children[i],
+					       base, init_node, i);
 		if (err)
 			return err;
 	}
@@ -1193,7 +1224,8 @@ static int init_root_tree_recursive(int max_ft_level, struct init_tree_node *ini
 	return 0;
 }
 
-static int init_root_tree(int max_ft_level, struct init_tree_node *init_node,
+static int init_root_tree(struct mlx5_core_dev *dev,
+			  struct init_tree_node *init_node,
 			  struct fs_node *fs_parent_node)
 {
 	int i;
@@ -1202,8 +1234,7 @@ static int init_root_tree(int max_ft_level, struct init_tree_node *init_node,
 
 	fs_get_obj(fs_ns, fs_parent_node);
 	for (i = 0; i < init_node->ar_size; i++) {
-		err = init_root_tree_recursive(max_ft_level,
-					       &init_node->children[i],
+		err = init_root_tree_recursive(dev, &init_node->children[i],
 					       &fs_ns->node,
 					       init_node, i);
 		if (err)
@@ -1278,15 +1309,12 @@ static void set_prio_attrs(struct mlx5_flow_root_namespace *root_ns)
 
 static int init_root_ns(struct mlx5_core_dev *dev)
 {
-	int max_ft_level = MLX5_CAP_FLOWTABLE(dev,
-					      flow_table_properties_nic_receive.
-					      max_ft_level);
 
 	dev->priv.root_ns = create_root_ns(dev, FS_FT_NIC_RX);
 	if (IS_ERR_OR_NULL(dev->priv.root_ns))
 		goto cleanup;
 
-	if (init_root_tree(max_ft_level, &root_fs, &dev->priv.root_ns->ns.node))
+	if (init_root_tree(dev, &root_fs, &dev->priv.root_ns->ns.node))
 		goto cleanup;
 
 	set_prio_attrs(dev->priv.root_ns);
-- 
1.7.1
