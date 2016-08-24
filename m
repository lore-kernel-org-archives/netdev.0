From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 11/15] net/mlx5: Add LAG flow steering namespace
Date: Wed, 24 Aug 2016 13:39:10 +0300
Message-ID: <1472035154-14517-12-git-send-email-saeedm@mellanox.com>
References: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Aviv Heller <avivh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59920 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754658AbcHXKl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:41:26 -0400
In-Reply-To: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviv Heller <avivh@mellanox.com>

This namespace is used for LAG demux flowtable.

The idea is to position the LAG demux ft between
bypass and kernel flowtables, allowing raw-eth
traffic from both ports to be received by the PF0
IB device.

Signed-off-by: Aviv Heller <avivh@mellanox.com>
Reviewed-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 11 ++++++++++-
 include/linux/mlx5/fs.h                           |  1 +
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index eabd734..ac414b7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -96,6 +96,10 @@
 #define OFFLOADS_NUM_PRIOS 1
 #define OFFLOADS_MIN_LEVEL (ANCHOR_MIN_LEVEL + 1)
 
+#define LAG_PRIO_NUM_LEVELS 1
+#define LAG_NUM_PRIOS 1
+#define LAG_MIN_LEVEL (OFFLOADS_MIN_LEVEL + 1)
+
 struct node_caps {
 	size_t	arr_sz;
 	long	*caps;
@@ -111,12 +115,16 @@ static struct init_tree_node {
 	int num_levels;
 } root_fs = {
 	.type = FS_TYPE_NAMESPACE,
-	.ar_size = 6,
+	.ar_size = 7,
 	.children = (struct init_tree_node[]) {
 		ADD_PRIO(0, BY_PASS_MIN_LEVEL, 0,
 			 FS_CHAINING_CAPS,
 			 ADD_NS(ADD_MULTIPLE_PRIO(MLX5_BY_PASS_NUM_PRIOS,
 						  BY_PASS_PRIO_NUM_LEVELS))),
+		ADD_PRIO(0, LAG_MIN_LEVEL, 0,
+			 FS_CHAINING_CAPS,
+			 ADD_NS(ADD_MULTIPLE_PRIO(LAG_NUM_PRIOS,
+						  LAG_PRIO_NUM_LEVELS))),
 		ADD_PRIO(0, OFFLOADS_MIN_LEVEL, 0, {},
 			 ADD_NS(ADD_MULTIPLE_PRIO(OFFLOADS_NUM_PRIOS, OFFLOADS_MAX_FT))),
 		ADD_PRIO(0, ETHTOOL_MIN_LEVEL, 0,
@@ -1396,6 +1404,7 @@ struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
 
 	switch (type) {
 	case MLX5_FLOW_NAMESPACE_BYPASS:
+	case MLX5_FLOW_NAMESPACE_LAG:
 	case MLX5_FLOW_NAMESPACE_OFFLOADS:
 	case MLX5_FLOW_NAMESPACE_ETHTOOL:
 	case MLX5_FLOW_NAMESPACE_KERNEL:
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 7edfe0b..8803212 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -54,6 +54,7 @@ static inline void build_leftovers_ft_param(int *priority,
 
 enum mlx5_flow_namespace_type {
 	MLX5_FLOW_NAMESPACE_BYPASS,
+	MLX5_FLOW_NAMESPACE_LAG,
 	MLX5_FLOW_NAMESPACE_OFFLOADS,
 	MLX5_FLOW_NAMESPACE_ETHTOOL,
 	MLX5_FLOW_NAMESPACE_KERNEL,
-- 
2.7.4
