From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 8/9] net/mlx5e: Introduce MLX5_FLOW_NAMESPACE_OFFLOADS
Date: Mon,  1 Feb 2016 08:34:44 +0000
Message-ID: <1454315685-32202-9-git-send-email-amir@vadai.me>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:32971 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751319AbcBAIha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 03:37:30 -0500
In-Reply-To: <1454315685-32202-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new namespace to be populated with flow steering rules that deal with
offloading rules (matching and/or actions) set for higher level entities
such as the TC subsystem.
This namespace is located after the bypass namespace and before the
kernel.
Therefore, it precedes the HW processing done for rules set for the
kernel NIC name-space.
This would allow to conduct actions such as HW drop or HW setting of
flow tag which will later become skb->mark for packets, before matching
by the kernel name space rules used by the EN NIC.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 7 +++++++
 include/linux/mlx5/fs.h                           | 1 +
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index fb3717a..ffe1397 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -77,6 +77,10 @@
 #define KERNEL_NUM_PRIOS 1
 #define KENREL_MIN_LEVEL 2
 
+#define OFFLOADS_MAX_FT 1
+#define OFFLOADS_NUM_PRIOS 1
+#define OFFLOADS_MIN_LEVEL (BY_PASS_MIN_LEVEL + 1)
+
 struct node_caps {
 	size_t	arr_sz;
 	long	*caps;
@@ -100,6 +104,8 @@ static struct init_tree_node {
 					  FS_CAP(flow_table_properties_nic_receive.identified_miss_table_mode),
 					  FS_CAP(flow_table_properties_nic_receive.flow_table_modify)),
 			 ADD_NS(ADD_MULTIPLE_PRIO(MLX5_BY_PASS_NUM_PRIOS, BY_PASS_PRIO_MAX_FT))),
+		ADD_PRIO(0, OFFLOADS_MIN_LEVEL, 0, {},
+			 ADD_NS(ADD_MULTIPLE_PRIO(OFFLOADS_NUM_PRIOS, OFFLOADS_MAX_FT))),
 		ADD_PRIO(0, KENREL_MIN_LEVEL, 0, {},
 			 ADD_NS(ADD_MULTIPLE_PRIO(KERNEL_NUM_PRIOS, KERNEL_MAX_FT))),
 		ADD_PRIO(0, BY_PASS_MIN_LEVEL, 0,
@@ -1143,6 +1149,7 @@ struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
 
 	switch (type) {
 	case MLX5_FLOW_NAMESPACE_BYPASS:
+	case MLX5_FLOW_NAMESPACE_OFFLOADS:
 	case MLX5_FLOW_NAMESPACE_KERNEL:
 	case MLX5_FLOW_NAMESPACE_LEFTOVERS:
 		prio = type;
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 8230caa..40e79e2 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -50,6 +50,7 @@ static inline void build_leftovers_ft_param(int *priority,
 
 enum mlx5_flow_namespace_type {
 	MLX5_FLOW_NAMESPACE_BYPASS,
+	MLX5_FLOW_NAMESPACE_OFFLOADS,
 	MLX5_FLOW_NAMESPACE_KERNEL,
 	MLX5_FLOW_NAMESPACE_LEFTOVERS,
 	MLX5_FLOW_NAMESPACE_FDB,
-- 
2.7.0
