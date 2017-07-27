From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 04/14] net/mlx5: Fix command bad flow on command entry allocation failure
Date: Thu, 27 Jul 2017 16:56:07 +0300
Message-ID: <20170727135617.18559-5-saeedm@mellanox.com>
References: <20170727135617.18559-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Moshe Shemesh <moshe@mellanox.com>,
        kernel-team@fb.com, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40318 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751534AbdG0N51 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 09:57:27 -0400
In-Reply-To: <20170727135617.18559-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

When driver fail to allocate an entry to send command to FW, it must
notify the calling function and release the memory allocated for
this command.

Fixes: e126ba97dba9e ('mlx5: Add driver for Mellanox Connect-IB adapters')
Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 25fd32fcdf79..31cbe5e86a01 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -786,6 +786,10 @@ static void cb_timeout_handler(struct work_struct *work)
 	mlx5_cmd_comp_handler(dev, 1UL << ent->idx, true);
 }
 
+static void free_msg(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *msg);
+static void mlx5_free_cmd_msg(struct mlx5_core_dev *dev,
+			      struct mlx5_cmd_msg *msg);
+
 static void cmd_work_handler(struct work_struct *work)
 {
 	struct mlx5_cmd_work_ent *ent = container_of(work, struct mlx5_cmd_work_ent, work);
@@ -796,17 +800,28 @@ static void cmd_work_handler(struct work_struct *work)
 	struct semaphore *sem;
 	unsigned long flags;
 	bool poll_cmd = ent->polling;
+	int alloc_ret;
 
 
 	sem = ent->page_queue ? &cmd->pages_sem : &cmd->sem;
 	down(sem);
 	if (!ent->page_queue) {
-		ent->idx = alloc_ent(cmd);
-		if (ent->idx < 0) {
+		alloc_ret = alloc_ent(cmd);
+		if (alloc_ret < 0) {
 			mlx5_core_err(dev, "failed to allocate command entry\n");
+			if (ent->callback) {
+				ent->callback(-EAGAIN, ent->context);
+				mlx5_free_cmd_msg(dev, ent->out);
+				free_msg(dev, ent->in);
+				free_cmd(ent);
+			} else {
+				ent->ret = -EAGAIN;
+				complete(&ent->done);
+			}
 			up(sem);
 			return;
 		}
+		ent->idx = alloc_ret;
 	} else {
 		ent->idx = cmd->max_reg_cmds;
 		spin_lock_irqsave(&cmd->alloc_lock, flags);
-- 
2.13.0
