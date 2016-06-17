From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 12/18] IB/mlx5: Add kernel offload flow-tag
Date: Fri, 17 Jun 2016 17:43:53 +0300
Message-ID: <1466174639-14576-13-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57511 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161193AbcFQOsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:48:03 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Add kernel offload flow tag for packets that will bypass the kernel
stack, e.g (RoCE/RDMA/RAW ETH (DPDK), etc ..).

User leftover FTEs are shared with sniffer, therefore leftover rules
should be added with the bypass flow-tag.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c | 10 ++++++++--
 include/linux/mlx5/fs.h           |  1 +
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 60330c9..5af7c5f 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1534,6 +1534,7 @@ static struct mlx5_ib_flow_handler *create_flow_rule(struct mlx5_ib_dev *dev,
 	unsigned int spec_index;
 	u32 *match_c;
 	u32 *match_v;
+	u32 flow_tag;
 	u32 action;
 	int err = 0;
 
@@ -1562,9 +1563,12 @@ static struct mlx5_ib_flow_handler *create_flow_rule(struct mlx5_ib_dev *dev,
 	match_criteria_enable = (!outer_header_zero(match_c)) << 0;
 	action = dst ? MLX5_FLOW_CONTEXT_ACTION_FWD_DEST :
 		MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO;
+	flow_tag = (flow_attr->type == IB_FLOW_ATTR_ALL_DEFAULT ||
+		    flow_attr->type == IB_FLOW_ATTR_MC_DEFAULT) ?
+		MLX5_FS_OFFLOAD_FLOW_TAG : MLX5_FS_DEFAULT_FLOW_TAG;
 
 	MLX5_RULE_ATTR(flow_rule_attr, match_criteria_enable, match_c,
-		       match_v, action, MLX5_FS_DEFAULT_FLOW_TAG, dst);
+		       match_v, action, flow_tag, dst);
 	handler->rule = mlx5_add_flow_rule(ft, &flow_rule_attr);
 
 	if (IS_ERR(handler->rule)) {
@@ -1619,12 +1623,13 @@ static struct mlx5_ib_flow_handler *create_leftovers_rule(struct mlx5_ib_dev *de
 	struct mlx5_ib_flow_handler *handler_ucast = NULL;
 	struct mlx5_ib_flow_handler *handler = NULL;
 
-	static struct {
+	struct {
 		struct ib_flow_attr	flow_attr;
 		struct ib_flow_spec_eth eth_flow;
 	} leftovers_specs[] = {
 		[LEFTOVERS_MC] = {
 			.flow_attr = {
+				.type = flow_attr->type,
 				.num_of_specs = 1,
 				.size = sizeof(leftovers_specs[0])
 			},
@@ -1637,6 +1642,7 @@ static struct mlx5_ib_flow_handler *create_leftovers_rule(struct mlx5_ib_dev *de
 		},
 		[LEFTOVERS_UC] = {
 			.flow_attr = {
+				.type = flow_attr->type,
 				.num_of_specs = 1,
 				.size = sizeof(leftovers_specs[0])
 			},
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index f3715eb..123b901 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -37,6 +37,7 @@
 #include <linux/mlx5/mlx5_ifc.h>
 
 #define MLX5_FS_DEFAULT_FLOW_TAG 0x0
+#define MLX5_FS_OFFLOAD_FLOW_TAG 0x800000
 
 enum {
 	MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO	= 1 << 16,
-- 
2.8.0
