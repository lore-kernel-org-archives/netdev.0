From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 02/25] IB/mthca, net/mlx4: remove counting semaphores
Date: Wed, 28 Oct 2015 03:45:50 +0100
Message-ID: <1446000373-1823620-3-git-send-email-arnd@arndb.de>
References: <1446000373-1823620-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Roland Dreier <roland@purestorage.com>,
	Eli Cohen <eli@mellanox.co.il>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:63667 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755235AbbJ1Cq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:46:29 -0400
In-Reply-To: <1446000373-1823620-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mthca and mlx4 device drivers use the same method
to switch between polling and event-driven command mode,
abusing two semaphores to create a mutual exclusion between
one polled command or multiple concurrent event driven
commands.

Since we want to make counting semaphores go away, this
patch replaces the semaphore counting the event-driven
commands with an open-coded wait-queue, which should
be an equivalent transformation of the code, although
it does not make it any nicer.

As far as I can tell, there is a preexisting race condition
regarding the cmd->use_events flag, which is not protected
by any lock. When this flag is toggled while another command
is being started, that command gets stuck until the mode is
toggled back.

A better solution that would solve the race condition and
at the same time improve the code readability would create
a new locking primitive that replaces both semaphores, like

static int mlx4_use_events(struct mlx4_cmd *cmd)
{
	int ret = -EAGAIN;
	spin_lock(&cmd->lock);
	if (cmd->use_events && cmd->commands < cmd->max_commands) {
		cmd->commands++;
		ret = 1;
	} else if (!cmd->use_events && cmd->commands == 0) {
		cmd->commands = 1;
		ret = 0;
	}
	spin_unlock(&cmd->lock);
	return ret;
}

static bool mlx4_use_events(struct mlx4_cmd *cmd)
{
	int ret;
	wait_event(cmd->events_wq, ret = __mlx4_use_events(cmd) >= 0);
	return ret;
}

Cc: Roland Dreier <roland@purestorage.com>
Cc: Eli Cohen <eli@mellanox.co.il>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org
Cc: linux-rdma@vger.kernel.org
Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Conflicts:

	drivers/net/mlx4/cmd.c
	drivers/net/mlx4/mlx4.h
---
 drivers/infiniband/hw/mthca/mthca_cmd.c   | 12 ++++++++----
 drivers/infiniband/hw/mthca/mthca_dev.h   |  3 ++-
 drivers/net/ethernet/mellanox/mlx4/cmd.c  | 12 ++++++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |  3 ++-
 4 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/hw/mthca/mthca_cmd.c b/drivers/infiniband/hw/mthca/mthca_cmd.c
index 9d3e5c1ac60e..aad1852e8e10 100644
--- a/drivers/infiniband/hw/mthca/mthca_cmd.c
+++ b/drivers/infiniband/hw/mthca/mthca_cmd.c
@@ -417,7 +417,8 @@ static int mthca_cmd_wait(struct mthca_dev *dev,
 	int err = 0;
 	struct mthca_cmd_context *context;
 
-	down(&dev->cmd.event_sem);
+	wait_event(dev->cmd.event_wait,
+		   atomic_add_unless(&dev->cmd.commands, -1, 0));
 
 	spin_lock(&dev->cmd.context_lock);
 	BUG_ON(dev->cmd.free_head < 0);
@@ -459,7 +460,8 @@ out:
 	dev->cmd.free_head = context - dev->cmd.context;
 	spin_unlock(&dev->cmd.context_lock);
 
-	up(&dev->cmd.event_sem);
+	atomic_inc(&dev->cmd.commands);
+	wake_up(&dev->cmd.event_wait);
 	return err;
 }
 
@@ -571,7 +573,8 @@ int mthca_cmd_use_events(struct mthca_dev *dev)
 	dev->cmd.context[dev->cmd.max_cmds - 1].next = -1;
 	dev->cmd.free_head = 0;
 
-	sema_init(&dev->cmd.event_sem, dev->cmd.max_cmds);
+	init_waitqueue_head(&dev->cmd.event_wait);
+	atomic_set(&dev->cmd.commands, dev->cmd.max_cmds);
 	spin_lock_init(&dev->cmd.context_lock);
 
 	for (dev->cmd.token_mask = 1;
@@ -597,7 +600,8 @@ void mthca_cmd_use_polling(struct mthca_dev *dev)
 	dev->cmd.flags &= ~MTHCA_CMD_USE_EVENTS;
 
 	for (i = 0; i < dev->cmd.max_cmds; ++i)
-		down(&dev->cmd.event_sem);
+		wait_event(dev->cmd.event_wait,
+			   atomic_add_unless(&dev->cmd.commands, -1, 0));
 
 	kfree(dev->cmd.context);
 
diff --git a/drivers/infiniband/hw/mthca/mthca_dev.h b/drivers/infiniband/hw/mthca/mthca_dev.h
index 7e6a6d64ad4e..3055f5c12ac8 100644
--- a/drivers/infiniband/hw/mthca/mthca_dev.h
+++ b/drivers/infiniband/hw/mthca/mthca_dev.h
@@ -121,7 +121,8 @@ struct mthca_cmd {
 	struct pci_pool          *pool;
 	struct mutex              hcr_mutex;
 	struct semaphore 	  poll_sem;
-	struct semaphore 	  event_sem;
+	wait_queue_head_t 	  event_wait;
+	atomic_t	 	  commands;
 	int              	  max_cmds;
 	spinlock_t                context_lock;
 	int                       free_head;
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 78f5a1a0b8c8..60134a4245ef 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -273,7 +273,8 @@ static int mlx4_cmd_wait(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 	struct mlx4_cmd_context *context;
 	int err = 0;
 
-	down(&cmd->event_sem);
+	wait_event(cmd->event_wait,
+		   atomic_add_unless(&cmd->commands, -1, 0));
 
 	spin_lock(&cmd->context_lock);
 	BUG_ON(cmd->free_head < 0);
@@ -305,7 +306,8 @@ out:
 	cmd->free_head = context - cmd->context;
 	spin_unlock(&cmd->context_lock);
 
-	up(&cmd->event_sem);
+	atomic_inc(&cmd->commands);
+	wake_up(&cmd->event_wait);
 	return err;
 }
 
@@ -380,7 +382,8 @@ int mlx4_cmd_use_events(struct mlx4_dev *dev)
 	priv->cmd.context[priv->cmd.max_cmds - 1].next = -1;
 	priv->cmd.free_head = 0;
 
-	sema_init(&priv->cmd.event_sem, priv->cmd.max_cmds);
+	init_waitqueue_head(&priv->cmd.event_wait);
+	atomic_set(&priv->cmd.commands, priv->cmd.max_cmds);
 	spin_lock_init(&priv->cmd.context_lock);
 
 	for (priv->cmd.token_mask = 1;
@@ -407,7 +410,8 @@ void mlx4_cmd_use_polling(struct mlx4_dev *dev)
 	priv->cmd.use_events = 0;
 
 	for (i = 0; i < priv->cmd.max_cmds; ++i)
-		down(&priv->cmd.event_sem);
+		wait_event(priv->cmd.event_wait,
+			   atomic_add_unless(&priv->cmd.commands, -1, 0));
 
 	kfree(priv->cmd.context);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 5dfa68ffc11c..5a2c55d8ccfd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -189,7 +189,8 @@ struct mlx4_cmd {
 	void __iomem	       *hcr;
 	struct mutex		hcr_mutex;
 	struct semaphore	poll_sem;
-	struct semaphore	event_sem;
+	wait_queue_head_t 	event_wait;
+	atomic_t	 	commands;
 	int			max_cmds;
 	spinlock_t		context_lock;
 	int			free_head;
-- 
2.1.0.rc2
