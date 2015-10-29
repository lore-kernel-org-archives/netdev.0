From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH 02/25] IB/mthca, net/mlx4: remove counting semaphores
Date: Thu, 29 Oct 2015 09:41:00 +0200
Message-ID: <20151029094100.4575e0c6@jpm-OptiPlex-GX620>
References: <1446000373-1823620-1-git-send-email-arnd@arndb.de>
	<1446000373-1823620-3-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, Roland Dreier <roland@purestorage.com>,
	Eli Cohen <eli@mellanox.co.il>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	matanb@mellanox.com, yishaih@mellanox.com, ogerlitz@mellanox.com,
	eranbe@mellanox.com, talal@mellanox.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33708 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbbJ2Hru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 03:47:50 -0400
Received: by wmeg8 with SMTP id g8so19344825wme.0
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 00:47:48 -0700 (PDT)
In-Reply-To: <1446000373-1823620-3-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Oct 2015 03:45:50 +0100
Arnd Bergmann <arnd@arndb.de> wrote:

> As far as I can tell, there is a preexisting race condition
> regarding the cmd->use_events flag, which is not protected
> by any lock. When this flag is toggled while another command
> is being started, that command gets stuck until the mode is
> toggled back.

We fixed this issue in mellanox ofed in a manner that allowed keeping
the same counting mechanism.  IMHO, this is preferable, rather than
totally changing the mechanism.

We will submit a similar patch to the upstream kernel shortly.

-Jack

net/mlx4: Switching between sending commands via polling and events may results in hung tasks

When switching between those methonds of sending commands, it's possbile that a
task will keep waiting for the polling sempahore, but may never be able to acquire it.
This is due to mlx4_cmd_use_events which "down"s the sempahore back to 0.

Reproducing it involves in sending commands while chaning between mlx4_cmd_use_polling
and mlx4_cmd_use_events.

Solving it by adding a read-write semaphore when switching between modes.

issue: 402565
Change-Id: I19f0d40dbb327c49b39a9abbcb2bb002b0279b0b
Signed-off-by: Matan Barak <matanb@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c  | 23 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |  2 ++
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index def1338..f94a960 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -766,17 +766,23 @@ int __mlx4_cmd(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
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
@@ -2437,6 +2443,7 @@ int mlx4_cmd_init(struct mlx4_dev *dev)
 	int flags = 0;
 
 	if (!priv->cmd.initialized) {
+		init_rwsem(&priv->cmd.switch_sem);
 		mutex_init(&priv->cmd.slave_cmd_mutex);
 		sema_init(&priv->cmd.poll_sem, 1);
 		priv->cmd.use_events = 0;
@@ -2566,6 +2573,7 @@ int mlx4_cmd_use_events(struct mlx4_dev *dev)
 	if (!priv->cmd.context)
 		return -ENOMEM;
 
+	down_write(&priv->cmd.switch_sem);
 	for (i = 0; i < priv->cmd.max_cmds; ++i) {
 		priv->cmd.context[i].token = i;
 		priv->cmd.context[i].next  = i + 1;
@@ -2590,6 +2598,7 @@ int mlx4_cmd_use_events(struct mlx4_dev *dev)
 
 	down(&priv->cmd.poll_sem);
 	priv->cmd.use_events = 1;
+	up_write(&priv->cmd.switch_sem);
 
 	return err;
 }
@@ -2602,6 +2611,7 @@ void mlx4_cmd_use_polling(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int i;
 
+	down_write(&priv->cmd.switch_sem);
 	priv->cmd.use_events = 0;
 
 	for (i = 0; i < priv->cmd.max_cmds; ++i)
@@ -2610,6 +2620,7 @@ void mlx4_cmd_use_polling(struct mlx4_dev *dev)
 	kfree(priv->cmd.context);
 
 	up(&priv->cmd.poll_sem);
+	up_write(&priv->cmd.switch_sem);
 }
 
 struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 6c58021..2f03e6e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -45,6 +45,7 @@
 #include <linux/workqueue.h>
 #include <linux/interrupt.h>
 #include <linux/spinlock.h>
+#include <linux/rwsem.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/driver.h>
@@ -626,6 +627,7 @@ struct mlx4_cmd {
 	struct mutex		slave_cmd_mutex;
 	struct semaphore	poll_sem;
 	struct semaphore	event_sem;
+	struct rw_semaphore	switch_sem;
 	int			max_cmds;
 	spinlock_t		context_lock;
 	int			free_head;
-- 
1.8.1.2
