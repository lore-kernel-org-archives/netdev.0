From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/4] net/mlx4_core: Relieve cpu load average on the port sending flow
Date: Wed, 22 Jul 2015 16:53:48 +0300
Message-ID: <1437573229-13127-4-git-send-email-ogerlitz@mellanox.com>
References: <1437573229-13127-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54936 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934191AbbGVNyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 09:54:16 -0400
In-Reply-To: <1437573229-13127-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

When a port is not attached, the FW requires a longer than usual time to
execute the SENSE_PORT command. In the command flow, the
wait_for_completion_timeout call used in mlx4_cmd_wait puts the kernel
thread into the uninterruptible state during this time. This, in turn,
due to the computation method, causes the CPU load average to increase.

Fix this by using wait_for_completion_interruptible_timeout() for the
SENSE_PORT command, which puts the thread in the interruptible state.
In this state, the thread does not contribute to the CPU load average.

Treat the interrupted case as if the SENSE_PORT command returned
port_type = NONE.

Fix suggested by Gideon Naim <gideonn@mellanox.com> and
Bart Van Assche <bart.vanassche@sandisk.com>.


Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 8204013..0a32020 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -686,6 +686,7 @@ static int mlx4_cmd_wait(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 {
 	struct mlx4_cmd *cmd = &mlx4_priv(dev)->cmd;
 	struct mlx4_cmd_context *context;
+	long ret_wait;
 	int err = 0;
 
 	down(&cmd->event_sem);
@@ -711,8 +712,20 @@ static int mlx4_cmd_wait(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 	if (err)
 		goto out_reset;
 
-	if (!wait_for_completion_timeout(&context->done,
-					 msecs_to_jiffies(timeout))) {
+	if (op == MLX4_CMD_SENSE_PORT) {
+		ret_wait =
+			wait_for_completion_interruptible_timeout(&context->done,
+								  msecs_to_jiffies(timeout));
+		if (ret_wait < 0) {
+			context->fw_status = 0;
+			context->out_param = 0;
+			context->result = 0;
+		}
+	} else {
+		ret_wait = (long)wait_for_completion_timeout(&context->done,
+							     msecs_to_jiffies(timeout));
+	}
+	if (!ret_wait) {
 		mlx4_warn(dev, "command 0x%x timed out (go bit not cleared)\n",
 			  op);
 		if (op == MLX4_CMD_NOP) {
-- 
2.3.7
