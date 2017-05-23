From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 7/8] net/mlx5: Avoid using pending command interface slots
Date: Tue, 23 May 2017 17:16:09 +0300
Message-ID: <20170523141610.27833-8-saeedm@mellanox.com>
References: <20170523141610.27833-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Mohamad Haj Yahia <mohamad@mellanox.com>,
        kernel-team@fb.com, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44685 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S968064AbdEWOQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:16:50 -0400
In-Reply-To: <20170523141610.27833-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Currently when firmware command gets stuck or it takes long time to
complete, the driver command will get timeout and the command slot is
freed and can be used for new commands, and if the firmware receive new
command on the old busy slot its behavior is unexpected and this could
be harmful.
To fix this when the driver command gets timeout we return failure,
but we don't free the command slot and we wait for the firmware to
explicitly respond to that command.
Once all the entries are busy we will stop processing new firmware
commands.

Fixes: 9cba4ebcf374 ('net/mlx5: Fix potential deadlock in command mode change')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c    | 41 +++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c     |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/health.c |  2 +-
 include/linux/mlx5/driver.h                      |  7 +++-
 4 files changed, 44 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 5bdaf3d545b2..10d282841f5b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -774,7 +774,7 @@ static void cb_timeout_handler(struct work_struct *work)
 	mlx5_core_warn(dev, "%s(0x%x) timeout. Will cause a leak of a command resource\n",
 		       mlx5_command_str(msg_to_opcode(ent->in)),
 		       msg_to_opcode(ent->in));
-	mlx5_cmd_comp_handler(dev, 1UL << ent->idx);
+	mlx5_cmd_comp_handler(dev, 1UL << ent->idx, true);
 }
 
 static void cmd_work_handler(struct work_struct *work)
@@ -804,6 +804,7 @@ static void cmd_work_handler(struct work_struct *work)
 	}
 
 	cmd->ent_arr[ent->idx] = ent;
+	set_bit(MLX5_CMD_ENT_STATE_PENDING_COMP, &ent->state);
 	lay = get_inst(cmd, ent->idx);
 	ent->lay = lay;
 	memset(lay, 0, sizeof(*lay));
@@ -825,6 +826,20 @@ static void cmd_work_handler(struct work_struct *work)
 	if (ent->callback)
 		schedule_delayed_work(&ent->cb_timeout_work, cb_timeout);
 
+	/* Skip sending command to fw if internal error */
+	if (pci_channel_offline(dev->pdev) ||
+	    dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR) {
+		u8 status = 0;
+		u32 drv_synd;
+
+		ent->ret = mlx5_internal_err_ret_value(dev, msg_to_opcode(ent->in), &drv_synd, &status);
+		MLX5_SET(mbox_out, ent->out, status, status);
+		MLX5_SET(mbox_out, ent->out, syndrome, drv_synd);
+
+		mlx5_cmd_comp_handler(dev, 1UL << ent->idx, true);
+		return;
+	}
+
 	/* ring doorbell after the descriptor is valid */
 	mlx5_core_dbg(dev, "writing 0x%x to command doorbell\n", 1 << ent->idx);
 	wmb();
@@ -835,7 +850,7 @@ static void cmd_work_handler(struct work_struct *work)
 		poll_timeout(ent);
 		/* make sure we read the descriptor after ownership is SW */
 		rmb();
-		mlx5_cmd_comp_handler(dev, 1UL << ent->idx);
+		mlx5_cmd_comp_handler(dev, 1UL << ent->idx, (ent->ret == -ETIMEDOUT));
 	}
 }
 
@@ -879,7 +894,7 @@ static int wait_func(struct mlx5_core_dev *dev, struct mlx5_cmd_work_ent *ent)
 		wait_for_completion(&ent->done);
 	} else if (!wait_for_completion_timeout(&ent->done, timeout)) {
 		ent->ret = -ETIMEDOUT;
-		mlx5_cmd_comp_handler(dev, 1UL << ent->idx);
+		mlx5_cmd_comp_handler(dev, 1UL << ent->idx, true);
 	}
 
 	err = ent->ret;
@@ -1375,7 +1390,7 @@ static void free_msg(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *msg)
 	}
 }
 
-void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec)
+void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec, bool forced)
 {
 	struct mlx5_cmd *cmd = &dev->cmd;
 	struct mlx5_cmd_work_ent *ent;
@@ -1395,6 +1410,19 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec)
 			struct semaphore *sem;
 
 			ent = cmd->ent_arr[i];
+
+			/* if we already completed the command, ignore it */
+			if (!test_and_clear_bit(MLX5_CMD_ENT_STATE_PENDING_COMP,
+						&ent->state)) {
+				/* only real completion can free the cmd slot */
+				if (!forced) {
+					mlx5_core_err(dev, "Command completion arrived after timeout (entry idx = %d).\n",
+						      ent->idx);
+					free_ent(cmd, ent->idx);
+				}
+				continue;
+			}
+
 			if (ent->callback)
 				cancel_delayed_work(&ent->cb_timeout_work);
 			if (ent->page_queue)
@@ -1417,7 +1445,10 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec)
 				mlx5_core_dbg(dev, "command completed. ret 0x%x, delivery status %s(0x%x)\n",
 					      ent->ret, deliv_status_to_str(ent->status), ent->status);
 			}
-			free_ent(cmd, ent->idx);
+
+			/* only real completion will free the entry slot */
+			if (!forced)
+				free_ent(cmd, ent->idx);
 
 			if (ent->callback) {
 				ds = ent->ts2 - ent->ts1;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index ea5d8d37a75c..33eae5ad2fb0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -422,7 +422,7 @@ static irqreturn_t mlx5_eq_int(int irq, void *eq_ptr)
 			break;
 
 		case MLX5_EVENT_TYPE_CMD:
-			mlx5_cmd_comp_handler(dev, be32_to_cpu(eqe->data.cmd.vector));
+			mlx5_cmd_comp_handler(dev, be32_to_cpu(eqe->data.cmd.vector), false);
 			break;
 
 		case MLX5_EVENT_TYPE_PORT_CHANGE:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index d0515391d33b..44f59b1d6f0f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -90,7 +90,7 @@ static void trigger_cmd_completions(struct mlx5_core_dev *dev)
 	spin_unlock_irqrestore(&dev->cmd.alloc_lock, flags);
 
 	mlx5_core_dbg(dev, "vector 0x%llx\n", vector);
-	mlx5_cmd_comp_handler(dev, vector);
+	mlx5_cmd_comp_handler(dev, vector, true);
 	return;
 
 no_trig:
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index bcdf739ee41a..93273d9ea4d1 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -787,7 +787,12 @@ enum {
 
 typedef void (*mlx5_cmd_cbk_t)(int status, void *context);
 
+enum {
+	MLX5_CMD_ENT_STATE_PENDING_COMP,
+};
+
 struct mlx5_cmd_work_ent {
+	unsigned long		state;
 	struct mlx5_cmd_msg    *in;
 	struct mlx5_cmd_msg    *out;
 	void		       *uout;
@@ -976,7 +981,7 @@ void mlx5_cq_completion(struct mlx5_core_dev *dev, u32 cqn);
 void mlx5_rsc_event(struct mlx5_core_dev *dev, u32 rsn, int event_type);
 void mlx5_srq_event(struct mlx5_core_dev *dev, u32 srqn, int event_type);
 struct mlx5_core_srq *mlx5_core_get_srq(struct mlx5_core_dev *dev, u32 srqn);
-void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec);
+void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec, bool forced);
 void mlx5_cq_event(struct mlx5_core_dev *dev, u32 cqn, int event_type);
 int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 		       int nent, u64 mask, const char *name,
-- 
2.11.0
