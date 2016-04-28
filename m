From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 06/12] net/mlx5: Support different attributes for priorities in namespace
Date: Fri, 29 Apr 2016 01:36:36 +0300
Message-ID: <1461883002-8912-7-git-send-email-saeedm@mellanox.com>
References: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33173 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752378AbcD1WiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 18:38:21 -0400
In-Reply-To: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Currently, namespace could be initialized only
with priorities with the same attributes.
Add support to initialize namespace with priorities
with different attributes(e.g. different number of levels).

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |   31 +++++++++++++--------
 1 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index ca55d7e..2b82293 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -74,9 +74,10 @@
 #define BY_PASS_MIN_LEVEL (KERNEL_MIN_LEVEL + MLX5_BY_PASS_NUM_PRIOS +\
 			   LEFTOVERS_NUM_PRIOS)
 
-#define KERNEL_NUM_LEVELS 3
-#define KERNEL_NUM_PRIOS 2
-#define KERNEL_MIN_LEVEL 2
+#define KERNEL_NIC_PRIO_NUM_LEVELS 2
+#define KERNEL_NIC_NUM_PRIOS 1
+/* One more level for tc */
+#define KERNEL_MIN_LEVEL (KERNEL_NIC_PRIO_NUM_LEVELS + 1)
 
 #define ANCHOR_NUM_LEVELS 1
 #define ANCHOR_NUM_PRIOS 1
@@ -106,8 +107,9 @@ static struct init_tree_node {
 			 ADD_NS(ADD_MULTIPLE_PRIO(MLX5_BY_PASS_NUM_PRIOS,
 						  BY_PASS_PRIO_NUM_LEVELS))),
 		ADD_PRIO(0, KERNEL_MIN_LEVEL, 0, {},
-			 ADD_NS(ADD_MULTIPLE_PRIO(KERNEL_NUM_PRIOS,
-						  KERNEL_NUM_LEVELS))),
+			 ADD_NS(ADD_MULTIPLE_PRIO(1, 1),
+				ADD_MULTIPLE_PRIO(KERNEL_NIC_NUM_PRIOS,
+						  KERNEL_NIC_PRIO_NUM_LEVELS))),
 		ADD_PRIO(0, BY_PASS_MIN_LEVEL, 0,
 			 FS_REQUIRED_CAPS(FS_CAP(flow_table_properties_nic_receive.flow_modify_en),
 					  FS_CAP(flow_table_properties_nic_receive.modify_root),
@@ -1375,14 +1377,14 @@ static struct mlx5_flow_namespace *fs_create_namespace(struct fs_prio *prio)
 	return ns;
 }
 
-static int create_leaf_prios(struct mlx5_flow_namespace *ns, struct init_tree_node
-			     *prio_metadata)
+static int create_leaf_prios(struct mlx5_flow_namespace *ns, int prio,
+			     struct init_tree_node *prio_metadata)
 {
 	struct fs_prio *fs_prio;
 	int i;
 
 	for (i = 0; i < prio_metadata->num_leaf_prios; i++) {
-		fs_prio = fs_create_prio(ns, i, prio_metadata->num_levels);
+		fs_prio = fs_create_prio(ns, prio++, prio_metadata->num_levels);
 		if (IS_ERR(fs_prio))
 			return PTR_ERR(fs_prio);
 	}
@@ -1409,7 +1411,7 @@ static int init_root_tree_recursive(struct mlx5_core_dev *dev,
 				    struct init_tree_node *init_node,
 				    struct fs_node *fs_parent_node,
 				    struct init_tree_node *init_parent_node,
-				    int index)
+				    int prio)
 {
 	int max_ft_level = MLX5_CAP_FLOWTABLE(dev,
 					      flow_table_properties_nic_receive.
@@ -1427,8 +1429,8 @@ static int init_root_tree_recursive(struct mlx5_core_dev *dev,
 
 		fs_get_obj(fs_ns, fs_parent_node);
 		if (init_node->num_leaf_prios)
-			return create_leaf_prios(fs_ns, init_node);
-		fs_prio = fs_create_prio(fs_ns, index, init_node->num_levels);
+			return create_leaf_prios(fs_ns, prio, init_node);
+		fs_prio = fs_create_prio(fs_ns, prio, init_node->num_levels);
 		if (IS_ERR(fs_prio))
 			return PTR_ERR(fs_prio);
 		base = &fs_prio->node;
@@ -1441,11 +1443,16 @@ static int init_root_tree_recursive(struct mlx5_core_dev *dev,
 	} else {
 		return -EINVAL;
 	}
+	prio = 0;
 	for (i = 0; i < init_node->ar_size; i++) {
 		err = init_root_tree_recursive(dev, &init_node->children[i],
-					       base, init_node, i);
+					       base, init_node, prio);
 		if (err)
 			return err;
+		if (init_node->children[i].type == FS_TYPE_PRIO &&
+		    init_node->children[i].num_leaf_prios) {
+			prio += init_node->children[i].num_leaf_prios;
+		}
 	}
 
 	return 0;
-- 
1.7.1
