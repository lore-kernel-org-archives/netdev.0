From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/7] net/mlx5_core: Prepare cmd interface to system errors handling
Date: Thu,  8 Oct 2015 17:13:58 +0300
Message-ID: <1444313643-15284-3-git-send-email-ogerlitz@mellanox.com>
References: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45233 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755598AbbJHOO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 10:14:28 -0400
In-Reply-To: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

In preparation to handling system errors at the mlx5_core level, change the
interface of cmd_work_handler to accept a 64 bit argument for the vector.

This allows to encode a flag that signifies when the handler is called
as a result of a driver logic that wishes to terminate commands that
the hardware may not be able to terminate. Such command completions
are detected at the handler and proper return status is encoded.

To be able to terminate page handler commands, we make sure to set
the corresponding bit in the bitmask.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 20 ++++++++++++++++++--
 include/linux/mlx5/driver.h                   |  6 +++++-
 2 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 84838c2..c3e54b7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -254,6 +254,10 @@ static void dump_buf(void *buf, int size, int data_only, int offset)
 		pr_debug("\n");
 }
 
+enum {
+	MLX5_DRIVER_STATUS_ABORTED = 0xfe,
+};
+
 const char *mlx5_command_str(int command)
 {
 	switch (command) {
@@ -473,6 +477,7 @@ static void cmd_work_handler(struct work_struct *work)
 	struct mlx5_core_dev *dev = container_of(cmd, struct mlx5_core_dev, cmd);
 	struct mlx5_cmd_layout *lay;
 	struct semaphore *sem;
+	unsigned long flags;
 
 	sem = ent->page_queue ? &cmd->pages_sem : &cmd->sem;
 	down(sem);
@@ -485,6 +490,9 @@ static void cmd_work_handler(struct work_struct *work)
 		}
 	} else {
 		ent->idx = cmd->max_reg_cmds;
+		spin_lock_irqsave(&cmd->alloc_lock, flags);
+		clear_bit(ent->idx, &cmd->bitmask);
+		spin_unlock_irqrestore(&cmd->alloc_lock, flags);
 	}
 
 	ent->token = alloc_token(cmd);
@@ -1081,7 +1089,7 @@ static void free_msg(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *msg)
 	}
 }
 
-void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, unsigned long vector)
+void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec)
 {
 	struct mlx5_cmd *cmd = &dev->cmd;
 	struct mlx5_cmd_work_ent *ent;
@@ -1092,7 +1100,10 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, unsigned long vector)
 	s64 ds;
 	struct mlx5_cmd_stats *stats;
 	unsigned long flags;
+	unsigned long vector;
 
+	/* there can be at most 32 command queues */
+	vector = vec & 0xffffffff;
 	for (i = 0; i < (1 << cmd->log_sz); i++) {
 		if (test_bit(i, &vector)) {
 			struct semaphore *sem;
@@ -1110,11 +1121,16 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, unsigned long vector)
 					ent->ret = verify_signature(ent);
 				else
 					ent->ret = 0;
-				ent->status = ent->lay->status_own >> 1;
+				if (vec & MLX5_TRIGGERED_CMD_COMP)
+					ent->status = MLX5_DRIVER_STATUS_ABORTED;
+				else
+					ent->status = ent->lay->status_own >> 1;
+
 				mlx5_core_dbg(dev, "command completed. ret 0x%x, delivery status %s(0x%x)\n",
 					      ent->ret, deliv_status_to_str(ent->status), ent->status);
 			}
 			free_ent(cmd, ent->idx);
+
 			if (ent->callback) {
 				ds = ent->ts2 - ent->ts1;
 				if (ent->op < ARRAY_SIZE(cmd->stats)) {
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 8b6d6f2..aa89955 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -731,7 +731,7 @@ void mlx5_eq_pagefault(struct mlx5_core_dev *dev, struct mlx5_eqe *eqe);
 #endif
 void mlx5_srq_event(struct mlx5_core_dev *dev, u32 srqn, int event_type);
 struct mlx5_core_srq *mlx5_core_get_srq(struct mlx5_core_dev *dev, u32 srqn);
-void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, unsigned long vector);
+void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec);
 void mlx5_cq_event(struct mlx5_core_dev *dev, u32 cqn, int event_type);
 int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 		       int nent, u64 mask, const char *name, struct mlx5_uar *uar);
@@ -865,4 +865,8 @@ static inline int mlx5_get_gid_table_len(u16 param)
 	return 8 * (1 << param);
 }
 
+enum {
+	MLX5_TRIGGERED_CMD_COMP = (u64)1 << 32,
+};
+
 #endif /* MLX5_DRIVER_H */
-- 
2.3.7
