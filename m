From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 4/8] net/mlx4_core: Fix smatch error - possible access to a null variable
Date: Wed, 14 May 2014 12:15:13 +0300
Message-ID: <1400058917-26313-5-git-send-email-ogerlitz@mellanox.com>
References: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, saeedm@mellanox.com,
	eyalpe@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44573 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753656AbaENJYN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 05:24:13 -0400
In-Reply-To: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
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
 drivers/net/ethernet/mellanox/mlx4/cmd.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

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
1.7.1
