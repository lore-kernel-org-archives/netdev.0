From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 06/12] net/mlx5_core: Set priority attributes
Date: Wed,  6 Jan 2016 23:52:25 +0200
Message-ID: <1452117151-28572-7-git-send-email-saeedm@mellanox.com>
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
Received: from [193.47.165.129] ([193.47.165.129]:43907 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752375AbcAFVxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 16:53:55 -0500
In-Reply-To: <1452117151-28572-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Each priority has two attributes:
1. max_ft - maximum allowed flow tables under this priority.
2. start_level - start level range of the flow tables
in the priority.

These attributes are set by traversing the tree nodes by
DFS and set start level and max flow tables to each priority.
Start level depends on the max flow tables of the prior priorities
in the tree.

The leaves of the trees have max_ft set in them. Each node accumulates
the max_ft of its children and set it accordingly.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |   71 +++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |    3 +
 2 files changed, 55 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index c6f864d..e1282e8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -41,20 +41,19 @@
 					 sizeof(struct init_tree_node))
 
 #define INIT_PRIO(min_level_val, max_ft_val,\
-		  start_level_val, ...) {.type = FS_TYPE_PRIO,\
+		  ...) {.type = FS_TYPE_PRIO,\
 	.min_ft_level = min_level_val,\
-	.start_level = start_level_val,\
 	.max_ft = max_ft_val,\
 	.children = (struct init_tree_node[]) {__VA_ARGS__},\
 	.ar_size = INIT_TREE_NODE_ARRAY_SIZE(__VA_ARGS__) \
 }
 
-#define ADD_PRIO(min_level_val, max_ft_val, start_level_val, ...)\
-	INIT_PRIO(min_level_val, max_ft_val, start_level_val,\
+#define ADD_PRIO(min_level_val, max_ft_val, ...)\
+	INIT_PRIO(min_level_val, max_ft_val,\
 		  __VA_ARGS__)\
 
-#define ADD_FT_PRIO(max_ft_val, start_level_val, ...)\
-	INIT_PRIO(0, max_ft_val, start_level_val,\
+#define ADD_FT_PRIO(max_ft_val, ...)\
+	INIT_PRIO(0, max_ft_val,\
 		  __VA_ARGS__)\
 
 #define ADD_NS(...) {.type = FS_TYPE_NAMESPACE,\
@@ -62,8 +61,6 @@
 	.ar_size = INIT_TREE_NODE_ARRAY_SIZE(__VA_ARGS__) \
 }
 
-#define KERNEL_START_LEVEL 0
-#define KERNEL_P0_START_LEVEL KERNEL_START_LEVEL
 #define KERNEL_MAX_FT 2
 #define KENREL_MIN_LEVEL 2
 static struct init_tree_node {
@@ -73,15 +70,12 @@ static struct init_tree_node {
 	int min_ft_level;
 	int prio;
 	int max_ft;
-	int start_level;
 } root_fs = {
 	.type = FS_TYPE_NAMESPACE,
 	.ar_size = 1,
 	.children = (struct init_tree_node[]) {
-		ADD_PRIO(KENREL_MIN_LEVEL, KERNEL_MAX_FT,
-			 KERNEL_START_LEVEL,
-			 ADD_NS(ADD_FT_PRIO(KERNEL_MAX_FT,
-					    KERNEL_P0_START_LEVEL))),
+		ADD_PRIO(KENREL_MIN_LEVEL, 0,
+			 ADD_NS(ADD_FT_PRIO(KERNEL_MAX_FT))),
 	}
 };
 
@@ -1117,8 +1111,7 @@ struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
 }
 
 static struct fs_prio *fs_create_prio(struct mlx5_flow_namespace *ns,
-				      unsigned prio, int max_ft,
-				      int start_level)
+				      unsigned prio, int max_ft)
 {
 	struct fs_prio *fs_prio;
 
@@ -1131,7 +1124,6 @@ static struct fs_prio *fs_create_prio(struct mlx5_flow_namespace *ns,
 	tree_add_node(&fs_prio->node, &ns->node);
 	fs_prio->max_ft = max_ft;
 	fs_prio->prio = prio;
-	fs_prio->start_level = start_level;
 	list_add_tail(&fs_prio->node.list, &ns->node.children);
 
 	return fs_prio;
@@ -1177,8 +1169,7 @@ static int init_root_tree_recursive(int max_ft_level, struct init_tree_node *ini
 			return -ENOTSUPP;
 
 		fs_get_obj(fs_ns, fs_parent_node);
-		fs_prio = fs_create_prio(fs_ns, index, init_node->max_ft,
-					 init_node->start_level);
+		fs_prio = fs_create_prio(fs_ns, index, init_node->max_ft);
 		if (IS_ERR(fs_prio))
 			return PTR_ERR(fs_prio);
 		base = &fs_prio->node;
@@ -1245,6 +1236,46 @@ static struct mlx5_flow_root_namespace *create_root_ns(struct mlx5_core_dev *dev
 	return root_ns;
 }
 
+static void set_prio_attrs_in_prio(struct fs_prio *prio, int acc_level);
+
+static int set_prio_attrs_in_ns(struct mlx5_flow_namespace *ns, int acc_level)
+{
+	struct fs_prio *prio;
+
+	fs_for_each_prio(prio, ns) {
+		 /* This updates prio start_level and max_ft */
+		set_prio_attrs_in_prio(prio, acc_level);
+		acc_level += prio->max_ft;
+	}
+	return acc_level;
+}
+
+static void set_prio_attrs_in_prio(struct fs_prio *prio, int acc_level)
+{
+	struct mlx5_flow_namespace *ns;
+	int acc_level_ns = acc_level;
+
+	prio->start_level = acc_level;
+	fs_for_each_ns(ns, prio)
+		/* This updates start_level and max_ft of ns's priority descendants */
+		acc_level_ns = set_prio_attrs_in_ns(ns, acc_level);
+	if (!prio->max_ft)
+		prio->max_ft = acc_level_ns - prio->start_level;
+	WARN_ON(prio->max_ft < acc_level_ns - prio->start_level);
+}
+
+static void set_prio_attrs(struct mlx5_flow_root_namespace *root_ns)
+{
+	struct mlx5_flow_namespace *ns = &root_ns->ns;
+	struct fs_prio *prio;
+	int start_level = 0;
+
+	fs_for_each_prio(prio, ns) {
+		set_prio_attrs_in_prio(prio, start_level);
+		start_level += prio->max_ft;
+	}
+}
+
 static int init_root_ns(struct mlx5_core_dev *dev)
 {
 	int max_ft_level = MLX5_CAP_FLOWTABLE(dev,
@@ -1258,6 +1289,8 @@ static int init_root_ns(struct mlx5_core_dev *dev)
 	if (init_root_tree(max_ft_level, &root_fs, &dev->priv.root_ns->ns.node))
 		goto cleanup;
 
+	set_prio_attrs(dev->priv.root_ns);
+
 	return 0;
 
 cleanup:
@@ -1381,7 +1414,7 @@ static int init_fdb_root_ns(struct mlx5_core_dev *dev)
 		return -ENOMEM;
 
 	/* Create single prio */
-	prio = fs_create_prio(&dev->priv.fdb_root_ns->ns, 0, 1, 0);
+	prio = fs_create_prio(&dev->priv.fdb_root_ns->ns, 0, 1);
 	if (IS_ERR(prio)) {
 		cleanup_single_prio_root_ns(dev, dev->priv.fdb_root_ns);
 		return PTR_ERR(prio);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 1a2e08b..00245fd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -151,6 +151,9 @@ void mlx5_cleanup_fs(struct mlx5_core_dev *dev);
 #define fs_for_each_prio(pos, ns)			\
 	fs_list_for_each_entry(pos, &(ns)->node.children)
 
+#define fs_for_each_ns(pos, prio)			\
+	fs_list_for_each_entry(pos, &(prio)->node.children)
+
 #define fs_for_each_ft(pos, prio)			\
 	fs_list_for_each_entry(pos, &(prio)->node.children)
 
-- 
1.7.1
