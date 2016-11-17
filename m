From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 1/8] net/mlx5: Make the command interface cache more flexible
Date: Thu, 17 Nov 2016 13:45:55 +0200
Message-ID: <1479383162-3432-2-git-send-email-saeedm@mellanox.com>
References: <1479383162-3432-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57828 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941466AbcKQLqT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 06:46:19 -0500
In-Reply-To: <1479383162-3432-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Add more cache command size sets and more entries for each set based on
the current commands set different sizes and commands frequency.

Fixes: e126ba97dba9 ('mlx5: Add driver for Mellanox Connect-IB adapters')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 145 ++++++++++++--------------
 include/linux/mlx5/driver.h                   |  14 +--
 2 files changed, 76 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 8561102..0fe7a60 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -54,14 +54,6 @@ enum {
 };
 
 enum {
-	NUM_LONG_LISTS	  = 2,
-	NUM_MED_LISTS	  = 64,
-	LONG_LIST_SIZE	  = (2ULL * 1024 * 1024 * 1024 / PAGE_SIZE) * 8 + 16 +
-				MLX5_CMD_DATA_BLOCK_SIZE,
-	MED_LIST_SIZE	  = 16 + MLX5_CMD_DATA_BLOCK_SIZE,
-};
-
-enum {
 	MLX5_CMD_DELIVERY_STAT_OK			= 0x0,
 	MLX5_CMD_DELIVERY_STAT_SIGNAT_ERR		= 0x1,
 	MLX5_CMD_DELIVERY_STAT_TOK_ERR			= 0x2,
@@ -1372,10 +1364,10 @@ static void free_msg(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *msg)
 {
 	unsigned long flags;
 
-	if (msg->cache) {
-		spin_lock_irqsave(&msg->cache->lock, flags);
-		list_add_tail(&msg->list, &msg->cache->head);
-		spin_unlock_irqrestore(&msg->cache->lock, flags);
+	if (msg->parent) {
+		spin_lock_irqsave(&msg->parent->lock, flags);
+		list_add_tail(&msg->list, &msg->parent->head);
+		spin_unlock_irqrestore(&msg->parent->lock, flags);
 	} else {
 		mlx5_free_cmd_msg(dev, msg);
 	}
@@ -1472,30 +1464,37 @@ static struct mlx5_cmd_msg *alloc_msg(struct mlx5_core_dev *dev, int in_size,
 				      gfp_t gfp)
 {
 	struct mlx5_cmd_msg *msg = ERR_PTR(-ENOMEM);
+	struct cmd_msg_cache *ch = NULL;
 	struct mlx5_cmd *cmd = &dev->cmd;
-	struct cache_ent *ent = NULL;
-
-	if (in_size > MED_LIST_SIZE && in_size <= LONG_LIST_SIZE)
-		ent = &cmd->cache.large;
-	else if (in_size > 16 && in_size <= MED_LIST_SIZE)
-		ent = &cmd->cache.med;
-
-	if (ent) {
-		spin_lock_irq(&ent->lock);
-		if (!list_empty(&ent->head)) {
-			msg = list_entry(ent->head.next, typeof(*msg), list);
-			/* For cached lists, we must explicitly state what is
-			 * the real size
-			 */
-			msg->len = in_size;
-			list_del(&msg->list);
+	int i;
+
+	if (in_size <= 16)
+		goto cache_miss;
+
+	for (i = 0; i < MLX5_NUM_COMMAND_CACHES; i++) {
+		ch = &cmd->cache[i];
+		if (in_size > ch->max_inbox_size)
+			continue;
+		spin_lock_irq(&ch->lock);
+		if (list_empty(&ch->head)) {
+			spin_unlock_irq(&ch->lock);
+			continue;
 		}
-		spin_unlock_irq(&ent->lock);
+		msg = list_entry(ch->head.next, typeof(*msg), list);
+		/* For cached lists, we must explicitly state what is
+		 * the real size
+		 */
+		msg->len = in_size;
+		list_del(&msg->list);
+		spin_unlock_irq(&ch->lock);
+		break;
 	}
 
-	if (IS_ERR(msg))
-		msg = mlx5_alloc_cmd_msg(dev, gfp, in_size, 0);
+	if (!IS_ERR(msg))
+		return msg;
 
+cache_miss:
+	msg = mlx5_alloc_cmd_msg(dev, gfp, in_size, 0);
 	return msg;
 }
 
@@ -1593,58 +1592,56 @@ EXPORT_SYMBOL(mlx5_cmd_exec_cb);
 
 static void destroy_msg_cache(struct mlx5_core_dev *dev)
 {
-	struct mlx5_cmd *cmd = &dev->cmd;
+	struct cmd_msg_cache *ch;
 	struct mlx5_cmd_msg *msg;
 	struct mlx5_cmd_msg *n;
+	int i;
 
-	list_for_each_entry_safe(msg, n, &cmd->cache.large.head, list) {
-		list_del(&msg->list);
-		mlx5_free_cmd_msg(dev, msg);
-	}
-
-	list_for_each_entry_safe(msg, n, &cmd->cache.med.head, list) {
-		list_del(&msg->list);
-		mlx5_free_cmd_msg(dev, msg);
+	for (i = 0; i < MLX5_NUM_COMMAND_CACHES; i++) {
+		ch = &dev->cmd.cache[i];
+		list_for_each_entry_safe(msg, n, &ch->head, list) {
+			list_del(&msg->list);
+			mlx5_free_cmd_msg(dev, msg);
+		}
 	}
 }
 
-static int create_msg_cache(struct mlx5_core_dev *dev)
+static unsigned cmd_cache_num_ent[MLX5_NUM_COMMAND_CACHES] = {
+	512, 32, 16, 8, 2
+};
+
+static unsigned cmd_cache_ent_size[MLX5_NUM_COMMAND_CACHES] = {
+	16 + MLX5_CMD_DATA_BLOCK_SIZE,
+	16 + MLX5_CMD_DATA_BLOCK_SIZE * 2,
+	16 + MLX5_CMD_DATA_BLOCK_SIZE * 16,
+	16 + MLX5_CMD_DATA_BLOCK_SIZE * 256,
+	16 + MLX5_CMD_DATA_BLOCK_SIZE * 512,
+};
+
+static void create_msg_cache(struct mlx5_core_dev *dev)
 {
 	struct mlx5_cmd *cmd = &dev->cmd;
+	struct cmd_msg_cache *ch;
 	struct mlx5_cmd_msg *msg;
-	int err;
 	int i;
-
-	spin_lock_init(&cmd->cache.large.lock);
-	INIT_LIST_HEAD(&cmd->cache.large.head);
-	spin_lock_init(&cmd->cache.med.lock);
-	INIT_LIST_HEAD(&cmd->cache.med.head);
-
-	for (i = 0; i < NUM_LONG_LISTS; i++) {
-		msg = mlx5_alloc_cmd_msg(dev, GFP_KERNEL, LONG_LIST_SIZE, 0);
-		if (IS_ERR(msg)) {
-			err = PTR_ERR(msg);
-			goto ex_err;
-		}
-		msg->cache = &cmd->cache.large;
-		list_add_tail(&msg->list, &cmd->cache.large.head);
-	}
-
-	for (i = 0; i < NUM_MED_LISTS; i++) {
-		msg = mlx5_alloc_cmd_msg(dev, GFP_KERNEL, MED_LIST_SIZE, 0);
-		if (IS_ERR(msg)) {
-			err = PTR_ERR(msg);
-			goto ex_err;
+	int k;
+
+	/* Initialize and fill the caches with initial entries */
+	for (k = 0; k < MLX5_NUM_COMMAND_CACHES; k++) {
+		ch = &cmd->cache[k];
+		spin_lock_init(&ch->lock);
+		INIT_LIST_HEAD(&ch->head);
+		ch->num_ent = cmd_cache_num_ent[k];
+		ch->max_inbox_size = cmd_cache_ent_size[k];
+		for (i = 0; i < ch->num_ent; i++) {
+			msg = mlx5_alloc_cmd_msg(dev, GFP_KERNEL | __GFP_NOWARN,
+						 ch->max_inbox_size, 0);
+			if (IS_ERR(msg))
+				break;
+			msg->parent = ch;
+			list_add_tail(&msg->list, &ch->head);
 		}
-		msg->cache = &cmd->cache.med;
-		list_add_tail(&msg->list, &cmd->cache.med.head);
 	}
-
-	return 0;
-
-ex_err:
-	destroy_msg_cache(dev);
-	return err;
 }
 
 static int alloc_cmd_page(struct mlx5_core_dev *dev, struct mlx5_cmd *cmd)
@@ -1767,11 +1764,7 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 
 	cmd->mode = CMD_MODE_POLLING;
 
-	err = create_msg_cache(dev);
-	if (err) {
-		dev_err(&dev->pdev->dev, "failed to create command cache\n");
-		goto err_free_page;
-	}
+	create_msg_cache(dev);
 
 	set_wqname(dev);
 	cmd->wq = create_singlethread_workqueue(cmd->wq_name);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index ecc451d..5e7dbbc 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -208,7 +208,7 @@ struct mlx5_cmd_first {
 
 struct mlx5_cmd_msg {
 	struct list_head		list;
-	struct cache_ent	       *cache;
+	struct cmd_msg_cache	       *parent;
 	u32				len;
 	struct mlx5_cmd_first		first;
 	struct mlx5_cmd_mailbox	       *next;
@@ -228,17 +228,17 @@ struct mlx5_cmd_debug {
 	u16			outlen;
 };
 
-struct cache_ent {
+struct cmd_msg_cache {
 	/* protect block chain allocations
 	 */
 	spinlock_t		lock;
 	struct list_head	head;
+	unsigned int		max_inbox_size;
+	unsigned int		num_ent;
 };
 
-struct cmd_msg_cache {
-	struct cache_ent	large;
-	struct cache_ent	med;
-
+enum {
+	MLX5_NUM_COMMAND_CACHES = 5,
 };
 
 struct mlx5_cmd_stats {
@@ -281,7 +281,7 @@ struct mlx5_cmd {
 	struct mlx5_cmd_work_ent *ent_arr[MLX5_MAX_COMMANDS];
 	struct pci_pool *pool;
 	struct mlx5_cmd_debug dbg;
-	struct cmd_msg_cache cache;
+	struct cmd_msg_cache cache[MLX5_NUM_COMMAND_CACHES];
 	int checksum_disabled;
 	struct mlx5_cmd_stats stats[MLX5_CMD_OP_MAX];
 };
-- 
2.7.4
