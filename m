From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 14/15] net/mlx5: Expose command polling interface
Date: Fri, 16 Jun 2017 00:42:51 +0300
Message-ID: <20170615214252.30140-15-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
        Maor Gottlieb <maorg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32948 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751812AbdFOVnQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:16 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Add a new interface for commands execution that allows the
caller to wait for the command's completion in a busy-wait
loop (polling mode).

This is useful if we want to execute a command in a polling mode
while the driver is working in events mode for the rest of
the commands.
This interface will be used in the downstream patches.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 30 ++++++++++++++++++++-------
 include/linux/mlx5/driver.h                   |  3 +++
 2 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index c1d8b0bcde75..4d5bd01f1ebb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -785,6 +785,8 @@ static void cmd_work_handler(struct work_struct *work)
 	struct mlx5_cmd_layout *lay;
 	struct semaphore *sem;
 	unsigned long flags;
+	bool poll_cmd = ent->polling;
+
 
 	sem = ent->page_queue ? &cmd->pages_sem : &cmd->sem;
 	down(sem);
@@ -845,7 +847,7 @@ static void cmd_work_handler(struct work_struct *work)
 	iowrite32be(1 << ent->idx, &dev->iseg->cmd_dbell);
 	mmiowb();
 	/* if not in polling don't use ent after this point */
-	if (cmd->mode == CMD_MODE_POLLING) {
+	if (cmd->mode == CMD_MODE_POLLING || poll_cmd) {
 		poll_timeout(ent);
 		/* make sure we read the descriptor after ownership is SW */
 		rmb();
@@ -889,7 +891,7 @@ static int wait_func(struct mlx5_core_dev *dev, struct mlx5_cmd_work_ent *ent)
 	struct mlx5_cmd *cmd = &dev->cmd;
 	int err;
 
-	if (cmd->mode == CMD_MODE_POLLING) {
+	if (cmd->mode == CMD_MODE_POLLING || ent->polling) {
 		wait_for_completion(&ent->done);
 	} else if (!wait_for_completion_timeout(&ent->done, timeout)) {
 		ent->ret = -ETIMEDOUT;
@@ -917,7 +919,7 @@ static int mlx5_cmd_invoke(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *in,
 			   struct mlx5_cmd_msg *out, void *uout, int uout_size,
 			   mlx5_cmd_cbk_t callback,
 			   void *context, int page_queue, u8 *status,
-			   u8 token)
+			   u8 token, bool force_polling)
 {
 	struct mlx5_cmd *cmd = &dev->cmd;
 	struct mlx5_cmd_work_ent *ent;
@@ -935,6 +937,7 @@ static int mlx5_cmd_invoke(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *in,
 		return PTR_ERR(ent);
 
 	ent->token = token;
+	ent->polling = force_polling;
 
 	if (!callback)
 		init_completion(&ent->done);
@@ -1535,7 +1538,8 @@ static int is_manage_pages(void *in)
 }
 
 static int cmd_exec(struct mlx5_core_dev *dev, void *in, int in_size, void *out,
-		    int out_size, mlx5_cmd_cbk_t callback, void *context)
+		    int out_size, mlx5_cmd_cbk_t callback, void *context,
+		    bool force_polling)
 {
 	struct mlx5_cmd_msg *inb;
 	struct mlx5_cmd_msg *outb;
@@ -1580,7 +1584,7 @@ static int cmd_exec(struct mlx5_core_dev *dev, void *in, int in_size, void *out,
 	}
 
 	err = mlx5_cmd_invoke(dev, inb, outb, out, out_size, callback, context,
-			      pages_queue, &status, token);
+			      pages_queue, &status, token, force_polling);
 	if (err)
 		goto out_out;
 
@@ -1608,7 +1612,7 @@ int mlx5_cmd_exec(struct mlx5_core_dev *dev, void *in, int in_size, void *out,
 {
 	int err;
 
-	err = cmd_exec(dev, in, in_size, out, out_size, NULL, NULL);
+	err = cmd_exec(dev, in, in_size, out, out_size, NULL, NULL, false);
 	return err ? : mlx5_cmd_check(dev, in, out);
 }
 EXPORT_SYMBOL(mlx5_cmd_exec);
@@ -1617,10 +1621,22 @@ int mlx5_cmd_exec_cb(struct mlx5_core_dev *dev, void *in, int in_size,
 		     void *out, int out_size, mlx5_cmd_cbk_t callback,
 		     void *context)
 {
-	return cmd_exec(dev, in, in_size, out, out_size, callback, context);
+	return cmd_exec(dev, in, in_size, out, out_size, callback, context,
+			false);
 }
 EXPORT_SYMBOL(mlx5_cmd_exec_cb);
 
+int mlx5_cmd_exec_polling(struct mlx5_core_dev *dev, void *in, int in_size,
+			  void *out, int out_size)
+{
+	int err;
+
+	err = cmd_exec(dev, in, in_size, out, out_size, NULL, NULL, true);
+
+	return err ? : mlx5_cmd_check(dev, in, out);
+}
+EXPORT_SYMBOL(mlx5_cmd_exec_polling);
+
 static void destroy_msg_cache(struct mlx5_core_dev *dev)
 {
 	struct cmd_msg_cache *ch;
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 6ea2f5734e37..bf15e87da8fa 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -817,6 +817,7 @@ struct mlx5_cmd_work_ent {
 	u64			ts1;
 	u64			ts2;
 	u16			op;
+	bool			polling;
 };
 
 struct mlx5_pas {
@@ -915,6 +916,8 @@ int mlx5_cmd_exec(struct mlx5_core_dev *dev, void *in, int in_size, void *out,
 int mlx5_cmd_exec_cb(struct mlx5_core_dev *dev, void *in, int in_size,
 		     void *out, int out_size, mlx5_cmd_cbk_t callback,
 		     void *context);
+int mlx5_cmd_exec_polling(struct mlx5_core_dev *dev, void *in, int in_size,
+			  void *out, int out_size);
 void mlx5_cmd_mbox_status(void *out, u8 *status, u32 *syndrome);
 
 int mlx5_core_get_caps(struct mlx5_core_dev *dev, enum mlx5_cap_type cap_type);
-- 
2.11.0
