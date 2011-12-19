From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 5/5] mlx4: Fixing wrong error codes in communication
 channel
Date: Mon, 19 Dec 2011 16:03:53 +0200
Message-ID: <4EEF4449.3050105@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:33675 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750987Ab1LSQR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 11:17:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

The communication channel is HW interface from PF point of view
So the command return status should be stored as HW error code
and only then translated to errno values.

Reporetd-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |   88 +++++++++++++++++++-----------
 1 files changed, 56 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index c4fef83..978f593 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -152,6 +152,26 @@ static int mlx4_status_to_errno(u8 status)
 	return trans_table[status];
 }
 
+static u8 mlx4_errno_to_status(int errno)
+{
+	switch (errno) {
+	case -EPERM:
+		return CMD_STAT_BAD_OP;
+	case -EINVAL:
+		return CMD_STAT_BAD_PARAM;
+	case -ENXIO:
+		return CMD_STAT_BAD_SYS_STATE;
+	case -EBUSY:
+		return CMD_STAT_RESOURCE_BUSY;
+	case -ENOMEM:
+		return CMD_STAT_EXCEED_LIM;
+	case -ENFILE:
+		return CMD_STAT_ICM_ERROR;
+	default:
+		return CMD_STAT_INTERNAL_ERR;
+	}
+}
+
 static int comm_pending(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -361,10 +381,10 @@ static int mlx4_slave_cmd(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 					mlx4_err(dev, "response expected while"
 						 "output mailbox is NULL for "
 						 "command 0x%x\n", op);
-					vhcr->status = -EINVAL;
+					vhcr->status = CMD_STAT_BAD_PARAM;
 				}
 			}
-			ret = vhcr->status;
+			ret = mlx4_status_to_errno(vhcr->status);
 		}
 	} else {
 		ret = mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR_POST, 0,
@@ -378,10 +398,10 @@ static int mlx4_slave_cmd(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 					mlx4_err(dev, "response expected while"
 						 "output mailbox is NULL for "
 						 "command 0x%x\n", op);
-					vhcr->status = -EINVAL;
+					vhcr->status = CMD_STAT_BAD_PARAM;
 				}
 			}
-			ret = vhcr->status;
+			ret = mlx4_status_to_errno(vhcr->status);
 		} else
 			mlx4_err(dev, "failed execution of VHCR_POST command"
 				 "opcode 0x%x\n", op);
@@ -1066,6 +1086,7 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 	u64 out_param;
 	int ret = 0;
 	int i;
+	int err = 0;
 
 	/* Create sw representation of Virtual HCR */
 	vhcr = kzalloc(sizeof(struct mlx4_vhcr), GFP_KERNEL);
@@ -1105,7 +1126,7 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 	if (!cmd) {
 		mlx4_err(dev, "Unknown command:0x%x accepted from slave:%d\n",
 			 vhcr->op, slave);
-		vhcr_cmd->status = -EINVAL;
+		vhcr_cmd->status = CMD_STAT_BAD_PARAM;
 		goto out_status;
 	}
 
@@ -1114,18 +1135,18 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 		vhcr->in_param &= INBOX_MASK;
 		inbox = mlx4_alloc_cmd_mailbox(dev);
 		if (IS_ERR(inbox)) {
-			ret = PTR_ERR(inbox);
+			vhcr_cmd->status = CMD_STAT_BAD_SIZE;
 			inbox = NULL;
-			goto out;
+			goto out_status;
 		}
 
-		ret = mlx4_ACCESS_MEM(dev, inbox->dma, slave,
-				      vhcr->in_param,
-				      MLX4_MAILBOX_SIZE, 1);
-		if (ret) {
+		if (mlx4_ACCESS_MEM(dev, inbox->dma, slave,
+				    vhcr->in_param,
+				    MLX4_MAILBOX_SIZE, 1)) {
 			mlx4_err(dev, "%s: Failed reading inbox (cmd:0x%x)\n",
 				 __func__, cmd->opcode);
-			goto out;
+			vhcr_cmd->status = CMD_STAT_INTERNAL_ERR;
+			goto out_status;
 		}
 	}
 
@@ -1134,7 +1155,7 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 		mlx4_warn(dev, "Command:0x%x from slave: %d failed protection "
 			  "checks for resource_id:%d\n", vhcr->op, slave,
 			  vhcr->in_modifier);
-		vhcr_cmd->status = -EPERM;
+		vhcr_cmd->status = CMD_STAT_BAD_OP;
 		goto out_status;
 	}
 
@@ -1142,16 +1163,16 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 	if (cmd->has_outbox) {
 		outbox = mlx4_alloc_cmd_mailbox(dev);
 		if (IS_ERR(outbox)) {
-			ret = PTR_ERR(outbox);
+			vhcr_cmd->status = CMD_STAT_BAD_SIZE;
 			outbox = NULL;
-			goto out;
+			goto out_status;
 		}
 	}
 
 	/* Execute the command! */
 	if (cmd->wrapper) {
-		vhcr_cmd->status = cmd->wrapper(dev, slave, vhcr, inbox, outbox,
-					   cmd);
+		err = cmd->wrapper(dev, slave, vhcr, inbox, outbox,
+				   cmd);
 		if (cmd->out_is_imm)
 			vhcr_cmd->out_param = cpu_to_be64(vhcr->out_param);
 	} else {
@@ -1159,20 +1180,11 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 			vhcr->in_param;
 		out_param = cmd->has_outbox ? (u64) outbox->dma :
 			vhcr->out_param;
-		vhcr_cmd->status = __mlx4_cmd(dev, in_param, &out_param,
-					 cmd->out_is_imm, vhcr->in_modifier,
-					 vhcr->op_modifier, vhcr->op,
-					 MLX4_CMD_TIME_CLASS_A,
-					 MLX4_CMD_NATIVE);
-
-		if (vhcr_cmd->status) {
-			mlx4_warn(dev, "vhcr command:0x%x slave:%d failed with"
-				  " error:%d, status %d\n",
-				  vhcr->op, slave, vhcr->errno,
-				  vhcr_cmd->status);
-			ret = vhcr_cmd->status;
-			goto out;
-		}
+		err = __mlx4_cmd(dev, in_param, &out_param,
+				 cmd->out_is_imm, vhcr->in_modifier,
+				 vhcr->op_modifier, vhcr->op,
+				 MLX4_CMD_TIME_CLASS_A,
+				 MLX4_CMD_NATIVE);
 
 		if (cmd->out_is_imm) {
 			vhcr->out_param = out_param;
@@ -1180,12 +1192,24 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 		}
 	}
 
+	if (err) {
+		mlx4_warn(dev, "vhcr command:0x%x slave:%d failed with"
+			  " error:%d, status %d\n",
+			  vhcr->op, slave, vhcr->errno, err);
+		vhcr_cmd->status = mlx4_errno_to_status(err);
+		goto out_status;
+	}
+
+
 	/* Write outbox if command completed successfully */
-	if (cmd->has_outbox && !vhcr->errno) {
+	if (cmd->has_outbox && !vhcr_cmd->status) {
 		ret = mlx4_ACCESS_MEM(dev, outbox->dma, slave,
 				      vhcr->out_param,
 				      MLX4_MAILBOX_SIZE, MLX4_CMD_WRAPPED);
 		if (ret) {
+			/* If we failed to write back the outbox after the
+			 *command was successfully executed, we must fail this
+			 * slave, as it is now in undefined state */
 			mlx4_err(dev, "%s:Failed writing outbox\n", __func__);
 			goto out;
 		}
-- 
1.7.7
