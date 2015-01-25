From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 9/9] net/mlx4_core: Reset flow activation upon SRIOV fatal command cases
Date: Sun, 25 Jan 2015 16:59:43 +0200
Message-ID: <1422197983-16048-10-git-send-email-ogerlitz@mellanox.com>
References: <1422197983-16048-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Roland Dreier <roland@kernel.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33822 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753977AbbAYPBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jan 2015 10:01:00 -0500
In-Reply-To: <1422197983-16048-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yishai Hadas <yishaih@mellanox.com>

When SRIOV commands are executed over the comm-channel and get
a fatal error (e.g. timeout, closing command failure) the VF enters
into error state and reset flow is activated.

To be able to recognize whether the failure was on a closing command, the
operational code for the given VHCR command is used. Once the device entered
into an error state we prevent redundant error messages from being printed.

Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c  |  125 +++++++++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/main.c |   16 ++--
 drivers/net/ethernet/mellanox/mlx4/mcg.c  |    3 +
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    4 +-
 4 files changed, 107 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 7652eed..2b48932 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -257,16 +257,30 @@ static int comm_pending(struct mlx4_dev *dev)
 	return (swab32(status) >> 31) != priv->cmd.comm_toggle;
 }
 
-static void mlx4_comm_cmd_post(struct mlx4_dev *dev, u8 cmd, u16 param)
+static int mlx4_comm_cmd_post(struct mlx4_dev *dev, u8 cmd, u16 param)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	u32 val;
 
+	/* To avoid writing to unknown addresses after the device state was
+	 * changed to internal error and the function was rest,
+	 * check the INTERNAL_ERROR flag which is updated under
+	 * device_state_mutex lock.
+	 */
+	mutex_lock(&dev->persist->device_state_mutex);
+
+	if (dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR) {
+		mutex_unlock(&dev->persist->device_state_mutex);
+		return -EIO;
+	}
+
 	priv->cmd.comm_toggle ^= 1;
 	val = param | (cmd << 16) | (priv->cmd.comm_toggle << 31);
 	__raw_writel((__force u32) cpu_to_be32(val),
 		     &priv->mfunc.comm->slave_write);
 	mmiowb();
+	mutex_unlock(&dev->persist->device_state_mutex);
+	return 0;
 }
 
 static int mlx4_comm_cmd_poll(struct mlx4_dev *dev, u8 cmd, u16 param,
@@ -286,7 +300,13 @@ static int mlx4_comm_cmd_poll(struct mlx4_dev *dev, u8 cmd, u16 param,
 
 	/* Write command */
 	down(&priv->cmd.poll_sem);
-	mlx4_comm_cmd_post(dev, cmd, param);
+	if (mlx4_comm_cmd_post(dev, cmd, param)) {
+		/* Only in case the device state is INTERNAL_ERROR,
+		 * mlx4_comm_cmd_post returns with an error
+		 */
+		err = mlx4_status_to_errno(CMD_STAT_INTERNAL_ERR);
+		goto out;
+	}
 
 	end = msecs_to_jiffies(timeout) + jiffies;
 	while (comm_pending(dev) && time_before(jiffies, end))
@@ -298,18 +318,23 @@ static int mlx4_comm_cmd_poll(struct mlx4_dev *dev, u8 cmd, u16 param,
 		 * is MLX4_DELAY_RESET_SLAVE*/
 		if ((MLX4_COMM_CMD_RESET == cmd)) {
 			err = MLX4_DELAY_RESET_SLAVE;
+			goto out;
 		} else {
-			mlx4_warn(dev, "Communication channel timed out\n");
-			err = -ETIMEDOUT;
+			mlx4_warn(dev, "Communication channel command 0x%x timed out\n",
+				  cmd);
+			err = mlx4_status_to_errno(CMD_STAT_INTERNAL_ERR);
 		}
 	}
 
+	if (err)
+		mlx4_enter_error_state(dev->persist);
+out:
 	up(&priv->cmd.poll_sem);
 	return err;
 }
 
-static int mlx4_comm_cmd_wait(struct mlx4_dev *dev, u8 op,
-			      u16 param, unsigned long timeout)
+static int mlx4_comm_cmd_wait(struct mlx4_dev *dev, u8 vhcr_cmd,
+			      u16 param, u16 op, unsigned long timeout)
 {
 	struct mlx4_cmd *cmd = &mlx4_priv(dev)->cmd;
 	struct mlx4_cmd_context *context;
@@ -327,32 +352,47 @@ static int mlx4_comm_cmd_wait(struct mlx4_dev *dev, u8 op,
 
 	reinit_completion(&context->done);
 
-	mlx4_comm_cmd_post(dev, op, param);
+	if (mlx4_comm_cmd_post(dev, vhcr_cmd, param)) {
+		/* Only in case the device state is INTERNAL_ERROR,
+		 * mlx4_comm_cmd_post returns with an error
+		 */
+		err = mlx4_status_to_errno(CMD_STAT_INTERNAL_ERR);
+		goto out;
+	}
 
 	if (!wait_for_completion_timeout(&context->done,
 					 msecs_to_jiffies(timeout))) {
-		mlx4_warn(dev, "communication channel command 0x%x timed out\n",
-			  op);
-		err = -EBUSY;
-		goto out;
+		mlx4_warn(dev, "communication channel command 0x%x (op=0x%x) timed out\n",
+			  vhcr_cmd, op);
+		goto out_reset;
 	}
 
 	err = context->result;
 	if (err && context->fw_status != CMD_STAT_MULTI_FUNC_REQ) {
 		mlx4_err(dev, "command 0x%x failed: fw status = 0x%x\n",
-			 op, context->fw_status);
-		goto out;
+			 vhcr_cmd, context->fw_status);
+		if (mlx4_closing_cmd_fatal_error(op, context->fw_status))
+			goto out_reset;
 	}
 
-out:
 	/* wait for comm channel ready
 	 * this is necessary for prevention the race
 	 * when switching between event to polling mode
+	 * Skipping this section in case the device is in FATAL_ERROR state,
+	 * In this state, no commands are sent via the comm channel until
+	 * the device has returned from reset.
 	 */
-	end = msecs_to_jiffies(timeout) + jiffies;
-	while (comm_pending(dev) && time_before(jiffies, end))
-		cond_resched();
+	if (!(dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR)) {
+		end = msecs_to_jiffies(timeout) + jiffies;
+		while (comm_pending(dev) && time_before(jiffies, end))
+			cond_resched();
+	}
+	goto out;
 
+out_reset:
+	err = mlx4_status_to_errno(CMD_STAT_INTERNAL_ERR);
+	mlx4_enter_error_state(dev->persist);
+out:
 	spin_lock(&cmd->context_lock);
 	context->next = cmd->free_head;
 	cmd->free_head = context - cmd->context;
@@ -363,10 +403,13 @@ out:
 }
 
 int mlx4_comm_cmd(struct mlx4_dev *dev, u8 cmd, u16 param,
-		  unsigned long timeout)
+		  u16 op, unsigned long timeout)
 {
+	if (dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR)
+		return mlx4_status_to_errno(CMD_STAT_INTERNAL_ERR);
+
 	if (mlx4_priv(dev)->cmd.use_events)
-		return mlx4_comm_cmd_wait(dev, cmd, param, timeout);
+		return mlx4_comm_cmd_wait(dev, cmd, param, op, timeout);
 	return mlx4_comm_cmd_poll(dev, cmd, param, timeout);
 }
 
@@ -502,8 +545,11 @@ static int mlx4_slave_cmd(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 			}
 			ret = mlx4_status_to_errno(vhcr->status);
 		}
+		if (ret &&
+		    dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR)
+			ret = mlx4_internal_err_ret_value(dev, op, op_modifier);
 	} else {
-		ret = mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR_POST, 0,
+		ret = mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR_POST, 0, op,
 				    MLX4_COMM_TIME + timeout);
 		if (!ret) {
 			if (out_is_imm) {
@@ -517,9 +563,14 @@ static int mlx4_slave_cmd(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 				}
 			}
 			ret = mlx4_status_to_errno(vhcr->status);
-		} else
-			mlx4_err(dev, "failed execution of VHCR_POST command opcode 0x%x\n",
-				 op);
+		} else {
+			if (dev->persist->state &
+			    MLX4_DEVICE_STATE_INTERNAL_ERROR)
+				ret = mlx4_internal_err_ret_value(dev, op,
+								  op_modifier);
+			else
+				mlx4_err(dev, "failed execution of VHCR_POST command opcode 0x%x\n", op);
+		}
 	}
 
 	mutex_unlock(&priv->cmd.slave_cmd_mutex);
@@ -1559,8 +1610,10 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 				      ALIGN(sizeof(struct mlx4_vhcr_cmd),
 					    MLX4_ACCESS_MEM_ALIGN), 1);
 		if (ret) {
-			mlx4_err(dev, "%s: Failed reading vhcr ret: 0x%x\n",
-				 __func__, ret);
+			if (!(dev->persist->state &
+			    MLX4_DEVICE_STATE_INTERNAL_ERROR))
+				mlx4_err(dev, "%s: Failed reading vhcr ret: 0x%x\n",
+					 __func__, ret);
 			kfree(vhcr);
 			return ret;
 		}
@@ -1599,11 +1652,14 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 			goto out_status;
 		}
 
-		if (mlx4_ACCESS_MEM(dev, inbox->dma, slave,
-				    vhcr->in_param,
-				    MLX4_MAILBOX_SIZE, 1)) {
-			mlx4_err(dev, "%s: Failed reading inbox (cmd:0x%x)\n",
-				 __func__, cmd->opcode);
+		ret = mlx4_ACCESS_MEM(dev, inbox->dma, slave,
+				      vhcr->in_param,
+				      MLX4_MAILBOX_SIZE, 1);
+		if (ret) {
+			if (!(dev->persist->state &
+			    MLX4_DEVICE_STATE_INTERNAL_ERROR))
+				mlx4_err(dev, "%s: Failed reading inbox (cmd:0x%x)\n",
+					 __func__, cmd->opcode);
 			vhcr_cmd->status = CMD_STAT_INTERNAL_ERR;
 			goto out_status;
 		}
@@ -1651,8 +1707,9 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 	}
 
 	if (err) {
-		mlx4_warn(dev, "vhcr command:0x%x slave:%d failed with error:%d, status %d\n",
-			  vhcr->op, slave, vhcr->errno, err);
+		if (!(dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR))
+			mlx4_warn(dev, "vhcr command:0x%x slave:%d failed with error:%d, status %d\n",
+				  vhcr->op, slave, vhcr->errno, err);
 		vhcr_cmd->status = mlx4_errno_to_status(err);
 		goto out_status;
 	}
@@ -1667,7 +1724,9 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 			/* If we failed to write back the outbox after the
 			 *command was successfully executed, we must fail this
 			 * slave, as it is now in undefined state */
-			mlx4_err(dev, "%s:Failed writing outbox\n", __func__);
+			if (!(dev->persist->state &
+			    MLX4_DEVICE_STATE_INTERNAL_ERROR))
+				mlx4_err(dev, "%s:Failed writing outbox\n", __func__);
 			goto out;
 		}
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 1baf1f1..9c7ef0b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1484,7 +1484,8 @@ static void mlx4_slave_exit(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
 	mutex_lock(&priv->cmd.slave_cmd_mutex);
-	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_RESET, 0, MLX4_COMM_TIME))
+	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_RESET, 0, MLX4_COMM_CMD_NA_OP,
+			  MLX4_COMM_TIME))
 		mlx4_warn(dev, "Failed to close slave function\n");
 	mutex_unlock(&priv->cmd.slave_cmd_mutex);
 }
@@ -1648,7 +1649,7 @@ static int mlx4_init_slave(struct mlx4_dev *dev)
 	mlx4_reset_vf_support(dev);
 	mlx4_warn(dev, "Sending reset\n");
 	ret_from_reset = mlx4_comm_cmd(dev, MLX4_COMM_CMD_RESET, 0,
-				       MLX4_COMM_TIME);
+				       MLX4_COMM_CMD_NA_OP, MLX4_COMM_TIME);
 	/* if we are in the middle of flr the slave will try
 	 * NUM_OF_RESET_RETRIES times before leaving.*/
 	if (ret_from_reset) {
@@ -1673,22 +1674,23 @@ static int mlx4_init_slave(struct mlx4_dev *dev)
 
 	mlx4_warn(dev, "Sending vhcr0\n");
 	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR0, dma >> 48,
-						    MLX4_COMM_TIME))
+			     MLX4_COMM_CMD_NA_OP, MLX4_COMM_TIME))
 		goto err;
 	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR1, dma >> 32,
-						    MLX4_COMM_TIME))
+			     MLX4_COMM_CMD_NA_OP, MLX4_COMM_TIME))
 		goto err;
 	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR2, dma >> 16,
-						    MLX4_COMM_TIME))
+			     MLX4_COMM_CMD_NA_OP, MLX4_COMM_TIME))
 		goto err;
-	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR_EN, dma, MLX4_COMM_TIME))
+	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR_EN, dma,
+			  MLX4_COMM_CMD_NA_OP, MLX4_COMM_TIME))
 		goto err;
 
 	mutex_unlock(&priv->cmd.slave_cmd_mutex);
 	return 0;
 
 err:
-	mlx4_comm_cmd(dev, MLX4_COMM_CMD_RESET, 0, 0);
+	mlx4_comm_cmd(dev, MLX4_COMM_CMD_RESET, 0, MLX4_COMM_CMD_NA_OP, 0);
 err_offline:
 	mutex_unlock(&priv->cmd.slave_cmd_mutex);
 	return -EIO;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index d22d928..bd9ea0d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -1350,6 +1350,9 @@ static int mlx4_QP_ATTACH(struct mlx4_dev *dev, struct mlx4_qp *qp,
 		       MLX4_CMD_WRAPPED);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
+	if (err && !attach &&
+	    dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR)
+		err = 0;
 	return err;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 2a15b82..096a81c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -123,6 +123,8 @@ enum mlx4_mpt_state {
 
 #define MLX4_COMM_TIME		10000
 #define MLX4_COMM_OFFLINE_TIME_OUT 30000
+#define MLX4_COMM_CMD_NA_OP    0x0
+
 
 enum {
 	MLX4_COMM_CMD_RESET,
@@ -1173,7 +1175,7 @@ int mlx4_cmd_use_events(struct mlx4_dev *dev);
 void mlx4_cmd_use_polling(struct mlx4_dev *dev);
 
 int mlx4_comm_cmd(struct mlx4_dev *dev, u8 cmd, u16 param,
-		  unsigned long timeout);
+		  u16 op, unsigned long timeout);
 
 void mlx4_cq_tasklet_cb(unsigned long data);
 void mlx4_cq_completion(struct mlx4_dev *dev, u32 cqn);
-- 
1.7.1
