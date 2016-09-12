From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 4/5] net/mlx4_core: Fix deadlock when switching between polling and event fw commands
Date: Mon, 12 Sep 2016 16:20:15 +0300
Message-ID: <1473686416-11779-5-git-send-email-tariqt@mellanox.com>
References: <1473686416-11779-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Matan Barak <matanb@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53498 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932639AbcILNVF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 09:21:05 -0400
In-Reply-To: <1473686416-11779-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

When switching from polling-based fw commands to event-based fw
commands, there is a race condition which could cause a fw command
in another task to hang: that task will keep waiting for the polling
sempahore, but may never be able to acquire it. This is due to
mlx4_cmd_use_events, which "down"s the sempahore back to 0.

During driver initialization, this is not a problem, since no other
tasks which invoke FW commands are active.

However, there is a problem if the driver switches to polling mode
and then back to event mode during normal operation.

The "test_interrupts" feature does exactly that.
Running "ethtool -t <eth device> offline" causes the PF driver to
temporarily switch to polling mode, and then back to event mode.
(Note that for VF drivers, such switching is not performed).

Fix this by adding a read-write semaphore for protection when
switching between modes.

Fixes: 225c7b1feef1 ("IB/mlx4: Add a driver Mellanox ConnectX InfiniBand adapters")
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c  | 23 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |  2 ++
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index f04a423ff79d..a58d96cf1ed1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -785,17 +785,23 @@ int __mlx4_cmd(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 		return mlx4_cmd_reset_flow(dev, op, op_modifier, -EIO);
 
 	if (!mlx4_is_mfunc(dev) || (native && mlx4_is_master(dev))) {
+		int ret;
+
 		if (dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR)
 			return mlx4_internal_err_ret_value(dev, op,
 							  op_modifier);
+		down_read(&mlx4_priv(dev)->cmd.switch_sem);
 		if (mlx4_priv(dev)->cmd.use_events)
-			return mlx4_cmd_wait(dev, in_param, out_param,
-					     out_is_imm, in_modifier,
-					     op_modifier, op, timeout);
+			ret = mlx4_cmd_wait(dev, in_param, out_param,
+					    out_is_imm, in_modifier,
+					    op_modifier, op, timeout);
 		else
-			return mlx4_cmd_poll(dev, in_param, out_param,
-					     out_is_imm, in_modifier,
-					     op_modifier, op, timeout);
+			ret = mlx4_cmd_poll(dev, in_param, out_param,
+					    out_is_imm, in_modifier,
+					    op_modifier, op, timeout);
+
+		up_read(&mlx4_priv(dev)->cmd.switch_sem);
+		return ret;
 	}
 	return mlx4_slave_cmd(dev, in_param, out_param, out_is_imm,
 			      in_modifier, op_modifier, op, timeout);
@@ -2454,6 +2460,7 @@ int mlx4_cmd_init(struct mlx4_dev *dev)
 	int flags = 0;
 
 	if (!priv->cmd.initialized) {
+		init_rwsem(&priv->cmd.switch_sem);
 		mutex_init(&priv->cmd.slave_cmd_mutex);
 		sema_init(&priv->cmd.poll_sem, 1);
 		priv->cmd.use_events = 0;
@@ -2583,6 +2590,7 @@ int mlx4_cmd_use_events(struct mlx4_dev *dev)
 	if (!priv->cmd.context)
 		return -ENOMEM;
 
+	down_write(&priv->cmd.switch_sem);
 	for (i = 0; i < priv->cmd.max_cmds; ++i) {
 		priv->cmd.context[i].token = i;
 		priv->cmd.context[i].next  = i + 1;
@@ -2606,6 +2614,7 @@ int mlx4_cmd_use_events(struct mlx4_dev *dev)
 
 	down(&priv->cmd.poll_sem);
 	priv->cmd.use_events = 1;
+	up_write(&priv->cmd.switch_sem);
 
 	return err;
 }
@@ -2618,6 +2627,7 @@ void mlx4_cmd_use_polling(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int i;
 
+	down_write(&priv->cmd.switch_sem);
 	priv->cmd.use_events = 0;
 
 	for (i = 0; i < priv->cmd.max_cmds; ++i)
@@ -2626,6 +2636,7 @@ void mlx4_cmd_use_polling(struct mlx4_dev *dev)
 	kfree(priv->cmd.context);
 
 	up(&priv->cmd.poll_sem);
+	up_write(&priv->cmd.switch_sem);
 }
 
 struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index c9d7fc5159f2..c128ba3ef014 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -46,6 +46,7 @@
 #include <linux/interrupt.h>
 #include <linux/spinlock.h>
 #include <net/devlink.h>
+#include <linux/rwsem.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/driver.h>
@@ -627,6 +628,7 @@ struct mlx4_cmd {
 	struct mutex		slave_cmd_mutex;
 	struct semaphore	poll_sem;
 	struct semaphore	event_sem;
+	struct rw_semaphore	switch_sem;
 	int			max_cmds;
 	spinlock_t		context_lock;
 	int			free_head;
-- 
1.8.3.1
