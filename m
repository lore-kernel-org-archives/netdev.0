From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 06/13] net/mlx5: Add timeout handle to commands with callback
Date: Thu, 30 Jun 2016 17:34:43 +0300
Message-ID: <1467297290-11443-7-git-send-email-saeedm@mellanox.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37687 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751845AbcF3OhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:37:20 -0400
In-Reply-To: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

The current implementation does not handle timeout in case of command
with callback request, and this can lead to deadlock if the command
doesn't get fw response.
Add delayed callback timeout work before posting the command to fw.
In case of real fw command completion we will cancel the delayed work.
In case of fw command timeout the callback timeout handler will be
called and it will simulate fw completion with timeout error.

Fixes: e126ba97dba9 ('mlx5: Add driver for Mellanox Connect-IB adapters')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 38 ++++++++++++++++++++++-----
 include/linux/mlx5/driver.h                   |  1 +
 2 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 74067f5..d6e2a1c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -606,11 +606,36 @@ static void dump_command(struct mlx5_core_dev *dev,
 		pr_debug("\n");
 }
 
+static u16 msg_to_opcode(struct mlx5_cmd_msg *in)
+{
+	struct mlx5_inbox_hdr *hdr = (struct mlx5_inbox_hdr *)(in->first.data);
+
+	return be16_to_cpu(hdr->opcode);
+}
+
+static void cb_timeout_handler(struct work_struct *work)
+{
+	struct delayed_work *dwork = container_of(work, struct delayed_work,
+						  work);
+	struct mlx5_cmd_work_ent *ent = container_of(dwork,
+						     struct mlx5_cmd_work_ent,
+						     cb_timeout_work);
+	struct mlx5_core_dev *dev = container_of(ent->cmd, struct mlx5_core_dev,
+						 cmd);
+
+	ent->ret = -ETIMEDOUT;
+	mlx5_core_warn(dev, "%s(0x%x) timeout. Will cause a leak of a command resource\n",
+		       mlx5_command_str(msg_to_opcode(ent->in)),
+		       msg_to_opcode(ent->in));
+	mlx5_cmd_comp_handler(dev, 1UL << ent->idx);
+}
+
 static void cmd_work_handler(struct work_struct *work)
 {
 	struct mlx5_cmd_work_ent *ent = container_of(work, struct mlx5_cmd_work_ent, work);
 	struct mlx5_cmd *cmd = ent->cmd;
 	struct mlx5_core_dev *dev = container_of(cmd, struct mlx5_core_dev, cmd);
+	unsigned long cb_timeout = msecs_to_jiffies(MLX5_CMD_TIMEOUT_MSEC);
 	struct mlx5_cmd_layout *lay;
 	struct semaphore *sem;
 	unsigned long flags;
@@ -651,6 +676,9 @@ static void cmd_work_handler(struct work_struct *work)
 	dump_command(dev, ent, 1);
 	ent->ts1 = ktime_get_ns();
 
+	if (ent->callback)
+		schedule_delayed_work(&ent->cb_timeout_work, cb_timeout);
+
 	/* ring doorbell after the descriptor is valid */
 	mlx5_core_dbg(dev, "writing 0x%x to command doorbell\n", 1 << ent->idx);
 	wmb();
@@ -695,13 +723,6 @@ static const char *deliv_status_to_str(u8 status)
 	}
 }
 
-static u16 msg_to_opcode(struct mlx5_cmd_msg *in)
-{
-	struct mlx5_inbox_hdr *hdr = (struct mlx5_inbox_hdr *)(in->first.data);
-
-	return be16_to_cpu(hdr->opcode);
-}
-
 static int wait_func(struct mlx5_core_dev *dev, struct mlx5_cmd_work_ent *ent)
 {
 	unsigned long timeout = msecs_to_jiffies(MLX5_CMD_TIMEOUT_MSEC);
@@ -765,6 +786,7 @@ static int mlx5_cmd_invoke(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *in,
 	if (!callback)
 		init_completion(&ent->done);
 
+	INIT_DELAYED_WORK(&ent->cb_timeout_work, cb_timeout_handler);
 	INIT_WORK(&ent->work, cmd_work_handler);
 	if (page_queue) {
 		cmd_work_handler(&ent->work);
@@ -1242,6 +1264,8 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec)
 			struct semaphore *sem;
 
 			ent = cmd->ent_arr[i];
+			if (ent->callback)
+				cancel_delayed_work(&ent->cb_timeout_work);
 			if (ent->page_queue)
 				sem = &cmd->pages_sem;
 			else
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 80776d0..fd72ecf 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -629,6 +629,7 @@ struct mlx5_cmd_work_ent {
 	void		       *uout;
 	int			uout_size;
 	mlx5_cmd_cbk_t		callback;
+	struct delayed_work	cb_timeout_work;
 	void		       *context;
 	int			idx;
 	struct completion	done;
-- 
2.8.0
