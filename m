From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/4] net/mlx4_core: Demote simple multicast and broadcast flow steering rules
Date: Thu, 28 May 2015 18:41:13 +0300
Message-ID: <1432827676-5599-2-git-send-email-ogerlitz@mellanox.com>
References: <1432827676-5599-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:57602 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754067AbbE1Plk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 11:41:40 -0400
In-Reply-To: <1432827676-5599-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

In SRIOV, when simple (i.e - Ethernet L2 only) flow steering rules are
created, always create them at MLX4_DOMAIN_NIC priority (instead of
the real priority the function created them at). This is done in order
to let multiple functions add broadcast/multicast rules without
affecting other functions, which is necessary for DPDK in SRIOV.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c                  |    4 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   23 ++++++++++++++++++++
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index cc64400..8c96c71 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1090,7 +1090,7 @@ static int __mlx4_ib_create_flow(struct ib_qp *qp, struct ib_flow_attr *flow_att
 
 	ret = mlx4_cmd_imm(mdev->dev, mailbox->dma, reg_id, size >> 2, 0,
 			   MLX4_QP_FLOW_STEERING_ATTACH, MLX4_CMD_TIME_CLASS_A,
-			   MLX4_CMD_NATIVE);
+			   MLX4_CMD_WRAPPED);
 	if (ret == -ENOMEM)
 		pr_err("mcg table is full. Fail to register network rule.\n");
 	else if (ret == -ENXIO)
@@ -1107,7 +1107,7 @@ static int __mlx4_ib_destroy_flow(struct mlx4_dev *dev, u64 reg_id)
 	int err;
 	err = mlx4_cmd(dev, reg_id, 0, 0,
 		       MLX4_QP_FLOW_STEERING_DETACH, MLX4_CMD_TIME_CLASS_A,
-		       MLX4_CMD_NATIVE);
+		       MLX4_CMD_WRAPPED);
 	if (err)
 		pr_err("Fail to detach network rule. registration id = 0x%llx\n",
 		       reg_id);
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 15ec081..ab48386 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3973,6 +3973,22 @@ static int validate_eth_header_mac(int slave, struct _rule_hw *eth_header,
 	return 0;
 }
 
+static void handle_eth_header_mcast_prio(struct mlx4_net_trans_rule_hw_ctrl *ctrl,
+					 struct _rule_hw *eth_header)
+{
+	if (is_multicast_ether_addr(eth_header->eth.dst_mac) ||
+	    is_broadcast_ether_addr(eth_header->eth.dst_mac)) {
+		struct mlx4_net_trans_rule_hw_eth *eth =
+			(struct mlx4_net_trans_rule_hw_eth *)eth_header;
+		struct _rule_hw *next_rule = (struct _rule_hw *)(eth + 1);
+		bool last_rule = next_rule->size == 0 && next_rule->id == 0 &&
+			next_rule->rsvd == 0;
+
+		if (last_rule)
+			ctrl->prio = cpu_to_be16(MLX4_DOMAIN_NIC);
+	}
+}
+
 /*
  * In case of missing eth header, append eth header with a MAC address
  * assigned to the VF.
@@ -4125,6 +4141,12 @@ int mlx4_QP_FLOW_STEERING_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 	rule_header = (struct _rule_hw *)(ctrl + 1);
 	header_id = map_hw_to_sw_id(be16_to_cpu(rule_header->id));
 
+	if (header_id == MLX4_NET_TRANS_RULE_ID_ETH)
+		handle_eth_header_mcast_prio(ctrl, rule_header);
+
+	if (slave == dev->caps.function)
+		goto execute;
+
 	switch (header_id) {
 	case MLX4_NET_TRANS_RULE_ID_ETH:
 		if (validate_eth_header_mac(slave, rule_header, rlist)) {
@@ -4151,6 +4173,7 @@ int mlx4_QP_FLOW_STEERING_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 		goto err_put;
 	}
 
+execute:
 	err = mlx4_cmd_imm(dev, inbox->dma, &vhcr->out_param,
 			   vhcr->in_modifier, 0,
 			   MLX4_QP_FLOW_STEERING_ATTACH, MLX4_CMD_TIME_CLASS_A,
-- 
1.7.1
