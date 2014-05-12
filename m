From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/9] net/mlx4_core: Fix smatch error - possible access to a null variable
Date: Mon, 12 May 2014 10:43:20 +0300
Message-ID: <1399880605-28772-5-git-send-email-amirv@mellanox.com>
References: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37749 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752404AbaELHnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2014 03:43:49 -0400
In-Reply-To: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

Fix the "error: we previously assumed 'out_param' could be null" found
by smatch semantic checker on:
drivers/net/ethernet/mellanox/mlx4/cmd.c:506 mlx4_cmd_poll()
drivers/net/ethernet/mellanox/mlx4/cmd.c:578 mlx4_cmd_wait()


Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 2420103..357dcb0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -473,6 +473,13 @@ static int mlx4_cmd_poll(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 		goto out;
 	}
 
+	if (out_is_imm && !out_param) {
+		mlx4_err(dev, "response expected while output mailbox is NULL for command 0x%x\n",
+			 op);
+		err = -EINVAL;
+		goto out;
+	}
+
 	err = mlx4_cmd_post(dev, in_param, out_param ? *out_param : 0,
 			    in_modifier, op_modifier, op, CMD_POLL_TOKEN, 0);
 	if (err)
@@ -551,6 +558,13 @@ static int mlx4_cmd_wait(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 	cmd->free_head = context->next;
 	spin_unlock(&cmd->context_lock);
 
+	if (out_is_imm && !out_param) {
+		mlx4_err(dev, "response expected while output mailbox is NULL for command 0x%x\n",
+			 op);
+		err = -EINVAL;
+		goto out;
+	}
+
 	init_completion(&context->done);
 
 	mlx4_cmd_post(dev, in_param, out_param ? *out_param : 0,
-- 
1.8.3.4
