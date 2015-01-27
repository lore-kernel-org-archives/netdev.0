From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 05/11] net/mlx4_core: Fix HW2SW_EQ to conform to the firmware spec
Date: Tue, 27 Jan 2015 15:58:03 +0200
Message-ID: <1422367089-13419-6-git-send-email-amirv@mellanox.com>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46311 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752630AbbA0N67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 08:58:59 -0500
In-Reply-To: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The driver incorrectly assigned an out-mailbox to this command,
and used an opcode modifier = 0, which is a reserved value (it
should use opcode modifier = 1).

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  2 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            | 26 ++++------------------
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 16 ++++---------
 3 files changed, 9 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 2b48932..928b706 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1221,7 +1221,7 @@ static struct mlx4_cmd_info cmd_info[] = {
 	{
 		.opcode = MLX4_CMD_HW2SW_EQ,
 		.has_inbox = false,
-		.has_outbox = true,
+		.has_outbox = false,
 		.out_is_imm = false,
 		.encode_slave_id = true,
 		.verify = NULL,
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 4df006d..264bc15 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -868,12 +868,10 @@ static int mlx4_SW2HW_EQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			MLX4_CMD_WRAPPED);
 }
 
-static int mlx4_HW2SW_EQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
-			 int eq_num)
+static int mlx4_HW2SW_EQ(struct mlx4_dev *dev,  int eq_num)
 {
-	return mlx4_cmd_box(dev, 0, mailbox->dma, eq_num,
-			    0, MLX4_CMD_HW2SW_EQ, MLX4_CMD_TIME_CLASS_A,
-			    MLX4_CMD_WRAPPED);
+	return mlx4_cmd(dev, 0, eq_num, 1, MLX4_CMD_HW2SW_EQ,
+			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_num_eq_uar(struct mlx4_dev *dev)
@@ -1046,7 +1044,6 @@ static void mlx4_free_eq(struct mlx4_dev *dev,
 			 struct mlx4_eq *eq)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	struct mlx4_cmd_mailbox *mailbox;
 	int err;
 	int i;
 	/* CX3 is capable of extending the CQE/EQE from 32 to 64 bytes, with
@@ -1054,24 +1051,10 @@ static void mlx4_free_eq(struct mlx4_dev *dev,
 	 */
 	int npages = PAGE_ALIGN(dev->caps.eqe_size  * eq->nent) / PAGE_SIZE;
 
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return;
-
-	err = mlx4_HW2SW_EQ(dev, mailbox, eq->eqn);
+	err = mlx4_HW2SW_EQ(dev, eq->eqn);
 	if (err)
 		mlx4_warn(dev, "HW2SW_EQ failed (%d)\n", err);
 
-	if (0) {
-		mlx4_dbg(dev, "Dumping EQ context %02x:\n", eq->eqn);
-		for (i = 0; i < sizeof (struct mlx4_eq_context) / 4; ++i) {
-			if (i % 4 == 0)
-				pr_cont("[%02x] ", i * 4);
-			pr_cont(" %08x", be32_to_cpup(mailbox->buf + i * 4));
-			if ((i + 1) % 4 == 0)
-				pr_cont("\n");
-		}
-	}
 	synchronize_irq(eq->irq);
 	tasklet_disable(&eq->tasklet_ctx.task);
 
@@ -1083,7 +1066,6 @@ static void mlx4_free_eq(struct mlx4_dev *dev,
 
 	kfree(eq->page_list);
 	mlx4_bitmap_free(&priv->eq_table.bitmap, eq->eqn, MLX4_USE_RR);
-	mlx4_free_cmd_mailbox(dev, mailbox);
 }
 
 static void mlx4_free_irqs(struct mlx4_dev *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 3e93879..79feeb6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -4677,7 +4677,6 @@ static void rem_slave_eqs(struct mlx4_dev *dev, int slave)
 	int state;
 	LIST_HEAD(tlist);
 	int eqn;
-	struct mlx4_cmd_mailbox *mailbox;
 
 	err = move_all_busy(dev, slave, RES_EQ);
 	if (err)
@@ -4703,20 +4702,13 @@ static void rem_slave_eqs(struct mlx4_dev *dev, int slave)
 					break;
 
 				case RES_EQ_HW:
-					mailbox = mlx4_alloc_cmd_mailbox(dev);
-					if (IS_ERR(mailbox)) {
-						cond_resched();
-						continue;
-					}
-					err = mlx4_cmd_box(dev, slave, 0,
-							   eqn & 0xff, 0,
-							   MLX4_CMD_HW2SW_EQ,
-							   MLX4_CMD_TIME_CLASS_A,
-							   MLX4_CMD_NATIVE);
+					err = mlx4_cmd(dev, slave, eqn & 0xff,
+						       1, MLX4_CMD_HW2SW_EQ,
+						       MLX4_CMD_TIME_CLASS_A,
+						       MLX4_CMD_NATIVE);
 					if (err)
 						mlx4_dbg(dev, "rem_slave_eqs: failed to move slave %d eqs %d to SW ownership\n",
 							 slave, eqn);
-					mlx4_free_cmd_mailbox(dev, mailbox);
 					atomic_dec(&eq->mtt->ref_count);
 					state = RES_EQ_RESERVED;
 					break;
-- 
1.9.3
