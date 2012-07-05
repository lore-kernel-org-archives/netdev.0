From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 05/10] net/mlx4_core: Add firmware commands to support device managed flow steering
Date: Thu,  5 Jul 2012 17:03:45 +0300
Message-ID: <1341497030-1818-6-git-send-email-ogerlitz@mellanox.com>
References: <1341497030-1818-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, amirv@mellanox.com,
	Hadar Hen Zion <hadarh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:53850 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756174Ab2GEOEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 10:04:05 -0400
In-Reply-To: <1341497030-1818-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.co.il>

Add support for firmware commands to attach/detach a new device managed
steering mode. Such network steering rules allow the user to provide an
L2/L3/L4 flow specification to the firmware and have the device to steer
traffic that matches that specification to the provided QP.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   19 +++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |   29 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   10 +++++++
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   24 ++++++++++++++++
 include/linux/mlx4/cmd.h                           |    4 +++
 5 files changed, 86 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 842c8ce..7e94987 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1080,6 +1080,25 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.verify = NULL,
 		.wrapper = NULL
 	},
+	/* flow steering commands */
+	{
+		.opcode = MLX4_QP_FLOW_STEERING_ATTACH,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = true,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = mlx4_QP_FLOW_STEERING_ATTACH_wrapper
+	},
+	{
+		.opcode = MLX4_QP_FLOW_STEERING_DETACH,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = mlx4_QP_FLOW_STEERING_DETACH_wrapper
+	},
 };
 
 static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 319c9d4..3c59a33 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -62,6 +62,35 @@ int mlx4_get_qp_per_mgm(struct mlx4_dev *dev)
 	return 4 * (mlx4_get_mgm_entry_size(dev) / 16 - 2);
 }
 
+static int mlx4_QP_FLOW_STEERING_ATTACH(struct mlx4_dev *dev,
+					struct mlx4_cmd_mailbox *mailbox,
+					u32 size,
+					u64 *reg_id)
+{
+	u64 imm;
+	int err = 0;
+
+	err = mlx4_cmd_imm(dev, mailbox->dma, &imm, size, 0,
+			   MLX4_QP_FLOW_STEERING_ATTACH, MLX4_CMD_TIME_CLASS_A,
+			   MLX4_CMD_NATIVE);
+	if (err)
+		return err;
+	*reg_id = imm;
+
+	return err;
+}
+
+static int mlx4_QP_FLOW_STEERING_DETACH(struct mlx4_dev *dev, u64 regid)
+{
+	int err = 0;
+
+	err = mlx4_cmd(dev, regid, 0, 0,
+		       MLX4_QP_FLOW_STEERING_DETACH, MLX4_CMD_TIME_CLASS_A,
+		       MLX4_CMD_NATIVE);
+
+	return err;
+}
+
 static int mlx4_READ_ENTRY(struct mlx4_dev *dev, int index,
 			   struct mlx4_cmd_mailbox *mailbox)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index a425a98..c07e882 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1118,6 +1118,16 @@ int mlx4_QUERY_IF_STAT_wrapper(struct mlx4_dev *dev, int slave,
 			       struct mlx4_cmd_mailbox *inbox,
 			       struct mlx4_cmd_mailbox *outbox,
 			       struct mlx4_cmd_info *cmd);
+int mlx4_QP_FLOW_STEERING_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
+					 struct mlx4_vhcr *vhcr,
+					 struct mlx4_cmd_mailbox *inbox,
+					 struct mlx4_cmd_mailbox *outbox,
+					 struct mlx4_cmd_info *cmd);
+int mlx4_QP_FLOW_STEERING_DETACH_wrapper(struct mlx4_dev *dev, int slave,
+					 struct mlx4_vhcr *vhcr,
+					 struct mlx4_cmd_mailbox *inbox,
+					 struct mlx4_cmd_mailbox *outbox,
+					 struct mlx4_cmd_info *cmd);
 
 int mlx4_get_mgm_entry_size(struct mlx4_dev *dev);
 int mlx4_get_qp_per_mgm(struct mlx4_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 6bdac29..a8ca960 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2738,6 +2738,30 @@ ex_put:
 	return err;
 }
 
+int mlx4_QP_FLOW_STEERING_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
+					 struct mlx4_vhcr *vhcr,
+					 struct mlx4_cmd_mailbox *inbox,
+					 struct mlx4_cmd_mailbox *outbox,
+					 struct mlx4_cmd_info *cmd)
+{
+	return mlx4_cmd_imm(dev, inbox->dma, &vhcr->out_param,
+			    vhcr->in_modifier, 0,
+			    MLX4_QP_FLOW_STEERING_ATTACH,
+			    MLX4_CMD_TIME_CLASS_A,
+			    MLX4_CMD_NATIVE);
+}
+
+int mlx4_QP_FLOW_STEERING_DETACH_wrapper(struct mlx4_dev *dev, int slave,
+					 struct mlx4_vhcr *vhcr,
+					 struct mlx4_cmd_mailbox *inbox,
+					 struct mlx4_cmd_mailbox *outbox,
+					 struct mlx4_cmd_info *cmd)
+{
+	return mlx4_cmd(dev, vhcr->in_param, 0, 0,
+			MLX4_QP_FLOW_STEERING_DETACH, MLX4_CMD_TIME_CLASS_A,
+			MLX4_CMD_NATIVE);
+}
+
 enum {
 	BUSY_MAX_RETRIES = 10
 };
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 1f3860a..2606951 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -154,6 +154,10 @@ enum {
 	/* set port opcode modifiers */
 	MLX4_SET_PORT_PRIO2TC = 0x8,
 	MLX4_SET_PORT_SCHEDULER  = 0x9,
+
+	/* register/delete flow steering network rules */
+	MLX4_QP_FLOW_STEERING_ATTACH = 0x65,
+	MLX4_QP_FLOW_STEERING_DETACH = 0x66,
 };
 
 enum {
-- 
1.7.1
