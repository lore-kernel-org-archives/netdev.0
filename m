From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 05/13] net/mlx5: Fix potential deadlock in command mode change
Date: Thu, 30 Jun 2016 17:34:42 +0300
Message-ID: <1467297290-11443-6-git-send-email-saeedm@mellanox.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37678 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751987AbcF3OhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:37:21 -0400
In-Reply-To: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Call command completion handler in case of timeout when working in
interrupts mode.
Avoid flushing the commands workqueue after acquiring the semaphores to
prevent a potential deadlock.

Fixes: e126ba97dba9 ('mlx5: Add driver for Mellanox Connect-IB adapters')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 79 +++++++++++----------------
 1 file changed, 33 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index fda43bc..74067f5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -710,13 +710,13 @@ static int wait_func(struct mlx5_core_dev *dev, struct mlx5_cmd_work_ent *ent)
 
 	if (cmd->mode == CMD_MODE_POLLING) {
 		wait_for_completion(&ent->done);
-		err = ent->ret;
-	} else {
-		if (!wait_for_completion_timeout(&ent->done, timeout))
-			err = -ETIMEDOUT;
-		else
-			err = 0;
+	} else if (!wait_for_completion_timeout(&ent->done, timeout)) {
+		ent->ret = -ETIMEDOUT;
+		mlx5_cmd_comp_handler(dev, 1UL << ent->idx);
 	}
+
+	err = ent->ret;
+
 	if (err == -ETIMEDOUT) {
 		mlx5_core_warn(dev, "%s(0x%x) timeout. Will cause a leak of a command resource\n",
 			       mlx5_command_str(msg_to_opcode(ent->in)),
@@ -774,28 +774,26 @@ static int mlx5_cmd_invoke(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *in,
 		goto out_free;
 	}
 
-	if (!callback) {
-		err = wait_func(dev, ent);
-		if (err == -ETIMEDOUT)
-			goto out;
-
-		ds = ent->ts2 - ent->ts1;
-		op = be16_to_cpu(((struct mlx5_inbox_hdr *)in->first.data)->opcode);
-		if (op < ARRAY_SIZE(cmd->stats)) {
-			stats = &cmd->stats[op];
-			spin_lock_irq(&stats->lock);
-			stats->sum += ds;
-			++stats->n;
-			spin_unlock_irq(&stats->lock);
-		}
-		mlx5_core_dbg_mask(dev, 1 << MLX5_CMD_TIME,
-				   "fw exec time for %s is %lld nsec\n",
-				   mlx5_command_str(op), ds);
-		*status = ent->status;
-		free_cmd(ent);
-	}
+	if (callback)
+		goto out;
 
-	return err;
+	err = wait_func(dev, ent);
+	if (err == -ETIMEDOUT)
+		goto out_free;
+
+	ds = ent->ts2 - ent->ts1;
+	op = be16_to_cpu(((struct mlx5_inbox_hdr *)in->first.data)->opcode);
+	if (op < ARRAY_SIZE(cmd->stats)) {
+		stats = &cmd->stats[op];
+		spin_lock_irq(&stats->lock);
+		stats->sum += ds;
+		++stats->n;
+		spin_unlock_irq(&stats->lock);
+	}
+	mlx5_core_dbg_mask(dev, 1 << MLX5_CMD_TIME,
+			   "fw exec time for %s is %lld nsec\n",
+			   mlx5_command_str(op), ds);
+	*status = ent->status;
 
 out_free:
 	free_cmd(ent);
@@ -1185,41 +1183,30 @@ err_dbg:
 	return err;
 }
 
-void mlx5_cmd_use_events(struct mlx5_core_dev *dev)
+static void mlx5_cmd_change_mod(struct mlx5_core_dev *dev, int mode)
 {
 	struct mlx5_cmd *cmd = &dev->cmd;
 	int i;
 
 	for (i = 0; i < cmd->max_reg_cmds; i++)
 		down(&cmd->sem);
-
 	down(&cmd->pages_sem);
 
-	flush_workqueue(cmd->wq);
-
-	cmd->mode = CMD_MODE_EVENTS;
+	cmd->mode = mode;
 
 	up(&cmd->pages_sem);
 	for (i = 0; i < cmd->max_reg_cmds; i++)
 		up(&cmd->sem);
 }
 
-void mlx5_cmd_use_polling(struct mlx5_core_dev *dev)
+void mlx5_cmd_use_events(struct mlx5_core_dev *dev)
 {
-	struct mlx5_cmd *cmd = &dev->cmd;
-	int i;
-
-	for (i = 0; i < cmd->max_reg_cmds; i++)
-		down(&cmd->sem);
-
-	down(&cmd->pages_sem);
-
-	flush_workqueue(cmd->wq);
-	cmd->mode = CMD_MODE_POLLING;
+	mlx5_cmd_change_mod(dev, CMD_MODE_EVENTS);
+}
 
-	up(&cmd->pages_sem);
-	for (i = 0; i < cmd->max_reg_cmds; i++)
-		up(&cmd->sem);
+void mlx5_cmd_use_polling(struct mlx5_core_dev *dev)
+{
+	mlx5_cmd_change_mod(dev, CMD_MODE_POLLING);
 }
 
 static void free_msg(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *msg)
-- 
2.8.0
