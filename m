From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 05/16] net/mlx5: Introduce offloads steering namespace
Date: Thu, 30 Jun 2016 18:23:24 +0300
Message-ID: <1467300215-14199-6-git-send-email-saeedm@mellanox.com>
References: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:43156 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932425AbcF3PY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 11:24:56 -0400
In-Reply-To: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Add a new namespace (MLX5_FLOW_NAMESPACE_OFFLOADS) to be populated
with flow steering rules that deal with rules that have have to
be executed before the EN NIC steering rules are matched.

The namespace is located after the bypass name-space and before the
kernel name-space. Therefore, it precedes the HW processing done for
rules set for the kernel NIC name-space.

Under SRIOV, it would allow us to match on e-switch missed packet
and forward them to the relevant VF representor TIR.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 11 ++++++++++-
 include/linux/mlx5/fs.h                           |  1 +
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index e912a3d..b040110 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -83,6 +83,11 @@
 #define ANCHOR_NUM_LEVELS 1
 #define ANCHOR_NUM_PRIOS 1
 #define ANCHOR_MIN_LEVEL (BY_PASS_MIN_LEVEL + 1)
+
+#define OFFLOADS_MAX_FT 1
+#define OFFLOADS_NUM_PRIOS 1
+#define OFFLOADS_MIN_LEVEL (ANCHOR_MIN_LEVEL + 1)
+
 struct node_caps {
 	size_t	arr_sz;
 	long	*caps;
@@ -98,7 +103,7 @@ static struct init_tree_node {
 	int num_levels;
 } root_fs = {
 	.type = FS_TYPE_NAMESPACE,
-	.ar_size = 4,
+	.ar_size = 5,
 	.children = (struct init_tree_node[]) {
 		ADD_PRIO(0, BY_PASS_MIN_LEVEL, 0,
 			 FS_REQUIRED_CAPS(FS_CAP(flow_table_properties_nic_receive.flow_modify_en),
@@ -107,6 +112,9 @@ static struct init_tree_node {
 					  FS_CAP(flow_table_properties_nic_receive.flow_table_modify)),
 			 ADD_NS(ADD_MULTIPLE_PRIO(MLX5_BY_PASS_NUM_PRIOS,
 						  BY_PASS_PRIO_NUM_LEVELS))),
+		ADD_PRIO(0, OFFLOADS_MIN_LEVEL, 0, {},
+			 ADD_NS(ADD_MULTIPLE_PRIO(OFFLOADS_NUM_PRIOS, OFFLOADS_MAX_FT))),
+
 		ADD_PRIO(0, KERNEL_MIN_LEVEL, 0, {},
 			 ADD_NS(ADD_MULTIPLE_PRIO(1, 1),
 				ADD_MULTIPLE_PRIO(KERNEL_NIC_NUM_PRIOS,
@@ -1369,6 +1377,7 @@ struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
 
 	switch (type) {
 	case MLX5_FLOW_NAMESPACE_BYPASS:
+	case MLX5_FLOW_NAMESPACE_OFFLOADS:
 	case MLX5_FLOW_NAMESPACE_KERNEL:
 	case MLX5_FLOW_NAMESPACE_LEFTOVERS:
 	case MLX5_FLOW_NAMESPACE_ANCHOR:
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 4b7a107..6ad1119 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -54,6 +54,7 @@ static inline void build_leftovers_ft_param(int *priority,
 
 enum mlx5_flow_namespace_type {
 	MLX5_FLOW_NAMESPACE_BYPASS,
+	MLX5_FLOW_NAMESPACE_OFFLOADS,
 	MLX5_FLOW_NAMESPACE_KERNEL,
 	MLX5_FLOW_NAMESPACE_LEFTOVERS,
 	MLX5_FLOW_NAMESPACE_ANCHOR,
-- 
2.8.0
