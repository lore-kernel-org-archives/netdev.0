From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net V1] mlx4_core: fix race on comm channel
Date: Sun, 18 Mar 2012 16:32:08 +0200
Message-ID: <4F65F1E8.9000505@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:39533 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753680Ab2CROcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 10:32:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>


Prevent race condition between commands on comm channel.
Happened while unloading the driver when switching from
event to polling mode. VF got completion on the last command
before switching to polling mode, but toggle was not changed.
After the fix - VF will not write the next command before
toggle is updated.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
---
Diff from V0:
 Fixed comments style

 drivers/net/ethernet/mellanox/mlx4/cmd.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index eaf09d4..6037d36 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -239,6 +239,7 @@ static int mlx4_comm_cmd_wait(struct mlx4_dev *dev, u8 op,
 {
 	struct mlx4_cmd *cmd = &mlx4_priv(dev)->cmd;
 	struct mlx4_cmd_context *context;
+	unsigned long end;
 	int err = 0;
 
 	down(&cmd->event_sem);
@@ -268,6 +269,14 @@ static int mlx4_comm_cmd_wait(struct mlx4_dev *dev, u8 op,
 	}
 
 out:
+	/* wait for comm channel ready
+	 * this is necessary for prevention the race
+	 * when switching between event to polling mode
+	 */
+	end = msecs_to_jiffies(timeout) + jiffies;
+	while (comm_pending(dev) && time_before(jiffies, end))
+		cond_resched();
+
 	spin_lock(&cmd->context_lock);
 	context->next = cmd->free_head;
 	cmd->free_head = context - cmd->context;
-- 
1.7.7
