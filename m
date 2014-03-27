From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/3] net/mlx4: USe one wrapper that returns -EPERM
Date: Thu, 27 Mar 2014 14:02:02 +0200
Message-ID: <1395921724-2244-2-git-send-email-ogerlitz@mellanox.com>
References: <1395921724-2244-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49791 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756498AbaC0MDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 08:03:00 -0400
In-Reply-To: <1395921724-2244-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a VF issues a firmware command which is disallowed for them, the PF
rerturns -EPERM from that command wrapper. Move to use one such wrapper
instance, instead of repeating the same code on such commands.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   17 ++++-------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    5 -----
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   10 ----------
 3 files changed, 4 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 516c1dd..2fd61b6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -800,16 +800,7 @@ static int mlx4_MAD_IFC_wrapper(struct mlx4_dev *dev, int slave,
 				    vhcr->op, MLX4_CMD_TIME_CLASS_C, MLX4_CMD_NATIVE);
 }
 
-static int MLX4_CMD_UPDATE_QP_wrapper(struct mlx4_dev *dev, int slave,
-		     struct mlx4_vhcr *vhcr,
-		     struct mlx4_cmd_mailbox *inbox,
-		     struct mlx4_cmd_mailbox *outbox,
-		     struct mlx4_cmd_info *cmd)
-{
-	return -EPERM;
-}
-
-static int MLX4_CMD_GET_OP_REQ_wrapper(struct mlx4_dev *dev, int slave,
+static int mlx4_CMD_EPERM_wrapper(struct mlx4_dev *dev, int slave,
 		     struct mlx4_vhcr *vhcr,
 		     struct mlx4_cmd_mailbox *inbox,
 		     struct mlx4_cmd_mailbox *outbox,
@@ -1258,7 +1249,7 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.out_is_imm = false,
 		.encode_slave_id = false,
 		.verify = NULL,
-		.wrapper = MLX4_CMD_UPDATE_QP_wrapper
+		.wrapper = mlx4_CMD_EPERM_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_GET_OP_REQ,
@@ -1267,7 +1258,7 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.out_is_imm = false,
 		.encode_slave_id = false,
 		.verify = NULL,
-		.wrapper = MLX4_CMD_GET_OP_REQ_wrapper,
+		.wrapper = mlx4_CMD_EPERM_wrapper,
 	},
 	{
 		.opcode = MLX4_CMD_CONF_SPECIAL_QP,
@@ -1378,7 +1369,7 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.out_is_imm = false,
 		.encode_slave_id = false,
 		.verify = NULL,
-		.wrapper = mlx4_FLOW_STEERING_IB_UC_QP_RANGE_wrapper
+		.wrapper = mlx4_CMD_EPERM_wrapper
 	},
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 9fca6c1..cf8be41 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1247,11 +1247,6 @@ int mlx4_QP_FLOW_STEERING_DETACH_wrapper(struct mlx4_dev *dev, int slave,
 					 struct mlx4_cmd_mailbox *inbox,
 					 struct mlx4_cmd_mailbox *outbox,
 					 struct mlx4_cmd_info *cmd);
-int mlx4_FLOW_STEERING_IB_UC_QP_RANGE_wrapper(struct mlx4_dev *dev, int slave,
-					      struct mlx4_vhcr *vhcr,
-					      struct mlx4_cmd_mailbox *inbox,
-					      struct mlx4_cmd_mailbox *outbox,
-					      struct mlx4_cmd_info *cmd);
 
 int mlx4_get_mgm_entry_size(struct mlx4_dev *dev);
 int mlx4_get_qp_per_mgm(struct mlx4_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 2a33513..3b5f53e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -4015,16 +4015,6 @@ int mlx4_QUERY_IF_STAT_wrapper(struct mlx4_dev *dev, int slave,
 	return err;
 }
 
-int mlx4_FLOW_STEERING_IB_UC_QP_RANGE_wrapper(struct mlx4_dev *dev, int slave,
-					      struct mlx4_vhcr *vhcr,
-					      struct mlx4_cmd_mailbox *inbox,
-					      struct mlx4_cmd_mailbox *outbox,
-					      struct mlx4_cmd_info *cmd)
-{
-	return -EPERM;
-}
-
-
 static void detach_qp(struct mlx4_dev *dev, int slave, struct res_qp *rqp)
 {
 	struct res_gid *rgid;
-- 
1.7.1
