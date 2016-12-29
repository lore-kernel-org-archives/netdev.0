From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 5/5] net/mlx4_core: Fix raw qp flow steering rules under SRIOV
Date: Thu, 29 Dec 2016 18:37:13 +0200
Message-ID: <1483029433-3624-6-git-send-email-tariqt@mellanox.com>
References: <1483029433-3624-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51874 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753144AbcL2QiA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 11:38:00 -0500
In-Reply-To: <1483029433-3624-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Demoting simple flow steering rule priority (for DPDK) was achieved by
wrapping FW commands MLX4_QP_FLOW_STEERING_ATTACH/DETACH for the PF
as well, and forcing the priority to MLX4_DOMAIN_NIC in the wrapper
function for the PF and all VFs.

In function mlx4_ib_create_flow(), this change caused the main rule
creation for the PF to be wrapped, while it left the associated
tunnel steering rule creation unwrapped for the PF.

This mismatch caused rule deletion failures in mlx4_ib_destroy_flow()
for the PF when the detach wrapper function did not find the associated
tunnel-steering rule (since creation of that rule for the PF did not
go through the wrapper function).

Fix this by setting MLX4_QP_FLOW_STEERING_ATTACH/DETACH to be "native"
(so that the PF invocation does not go through the wrapper), and perform
the required priority demotion for the PF in the mlx4_ib_create_flow()
code path.

Fixes: 48564135cba8 ("net/mlx4_core: Demote simple multicast and broadcast flow steering rules")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c                  | 14 ++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/main.c          | 18 ++++++++++++++++++
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 22 +---------------------
 include/linux/mlx4/device.h                        |  2 ++
 4 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index c8413fc120e6..7031a8dd4d14 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1682,9 +1682,19 @@ static int __mlx4_ib_create_flow(struct ib_qp *qp, struct ib_flow_attr *flow_att
 		size += ret;
 	}
 
+	if (mlx4_is_master(mdev->dev) && flow_type == MLX4_FS_REGULAR &&
+	    flow_attr->num_of_specs == 1) {
+		struct _rule_hw *rule_header = (struct _rule_hw *)(ctrl + 1);
+		enum ib_flow_spec_type header_spec =
+			((union ib_flow_spec *)(flow_attr + 1))->type;
+
+		if (header_spec == IB_FLOW_SPEC_ETH)
+			mlx4_handle_eth_header_mcast_prio(ctrl, rule_header);
+	}
+
 	ret = mlx4_cmd_imm(mdev->dev, mailbox->dma, reg_id, size >> 2, 0,
 			   MLX4_QP_FLOW_STEERING_ATTACH, MLX4_CMD_TIME_CLASS_A,
-			   MLX4_CMD_WRAPPED);
+			   MLX4_CMD_NATIVE);
 	if (ret == -ENOMEM)
 		pr_err("mcg table is full. Fail to register network rule.\n");
 	else if (ret == -ENXIO)
@@ -1701,7 +1711,7 @@ static int __mlx4_ib_destroy_flow(struct mlx4_dev *dev, u64 reg_id)
 	int err;
 	err = mlx4_cmd(dev, reg_id, 0, 0,
 		       MLX4_QP_FLOW_STEERING_DETACH, MLX4_CMD_TIME_CLASS_A,
-		       MLX4_CMD_WRAPPED);
+		       MLX4_CMD_NATIVE);
 	if (err)
 		pr_err("Fail to detach network rule. registration id = 0x%llx\n",
 		       reg_id);
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 5e7840a7a33b..bffa6f345f2f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -42,6 +42,7 @@
 #include <linux/io-mapping.h>
 #include <linux/delay.h>
 #include <linux/kmod.h>
+#include <linux/etherdevice.h>
 #include <net/devlink.h>
 
 #include <linux/mlx4/device.h>
@@ -782,6 +783,23 @@ int mlx4_is_slave_active(struct mlx4_dev *dev, int slave)
 }
 EXPORT_SYMBOL(mlx4_is_slave_active);
 
+void mlx4_handle_eth_header_mcast_prio(struct mlx4_net_trans_rule_hw_ctrl *ctrl,
+				       struct _rule_hw *eth_header)
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
+EXPORT_SYMBOL(mlx4_handle_eth_header_mcast_prio);
+
 static void slave_adjust_steering_mode(struct mlx4_dev *dev,
 				       struct mlx4_dev_cap *dev_cap,
 				       struct mlx4_init_hca_param *hca_param)
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 4b3e139e9c82..56185a0b827d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -4164,22 +4164,6 @@ static int validate_eth_header_mac(int slave, struct _rule_hw *eth_header,
 	return 0;
 }
 
-static void handle_eth_header_mcast_prio(struct mlx4_net_trans_rule_hw_ctrl *ctrl,
-					 struct _rule_hw *eth_header)
-{
-	if (is_multicast_ether_addr(eth_header->eth.dst_mac) ||
-	    is_broadcast_ether_addr(eth_header->eth.dst_mac)) {
-		struct mlx4_net_trans_rule_hw_eth *eth =
-			(struct mlx4_net_trans_rule_hw_eth *)eth_header;
-		struct _rule_hw *next_rule = (struct _rule_hw *)(eth + 1);
-		bool last_rule = next_rule->size == 0 && next_rule->id == 0 &&
-			next_rule->rsvd == 0;
-
-		if (last_rule)
-			ctrl->prio = cpu_to_be16(MLX4_DOMAIN_NIC);
-	}
-}
-
 /*
  * In case of missing eth header, append eth header with a MAC address
  * assigned to the VF.
@@ -4363,10 +4347,7 @@ int mlx4_QP_FLOW_STEERING_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 	header_id = map_hw_to_sw_id(be16_to_cpu(rule_header->id));
 
 	if (header_id == MLX4_NET_TRANS_RULE_ID_ETH)
-		handle_eth_header_mcast_prio(ctrl, rule_header);
-
-	if (slave == dev->caps.function)
-		goto execute;
+		mlx4_handle_eth_header_mcast_prio(ctrl, rule_header);
 
 	switch (header_id) {
 	case MLX4_NET_TRANS_RULE_ID_ETH:
@@ -4394,7 +4375,6 @@ int mlx4_QP_FLOW_STEERING_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 		goto err_put_qp;
 	}
 
-execute:
 	err = mlx4_cmd_imm(dev, inbox->dma, &vhcr->out_param,
 			   vhcr->in_modifier, 0,
 			   MLX4_QP_FLOW_STEERING_ATTACH, MLX4_CMD_TIME_CLASS_A,
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 93bdb3485192..6533c16e27ad 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1384,6 +1384,8 @@ int mlx4_SET_PORT_fcs_check(struct mlx4_dev *dev, u8 port,
 int get_phv_bit(struct mlx4_dev *dev, u8 port, int *phv);
 int mlx4_get_is_vlan_offload_disabled(struct mlx4_dev *dev, u8 port,
 				      bool *vlan_offload_disabled);
+void mlx4_handle_eth_header_mcast_prio(struct mlx4_net_trans_rule_hw_ctrl *ctrl,
+				       struct _rule_hw *eth_header);
 int mlx4_find_cached_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *idx);
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
-- 
1.8.3.1
