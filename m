From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/4] net/mlx4_core: Return -EPROBE_DEFER when a VF is probed before PF is sufficiently initialized
Date: Tue,  4 Jun 2013 18:13:27 +0300
Message-ID: <1370358809-7484-3-git-send-email-ogerlitz@mellanox.com>
References: <1370358809-7484-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46763 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755632Ab3FDPTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 11:19:09 -0400
In-Reply-To: <1370358809-7484-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

In the PF initialization, SRIOV is enabled before the PF is fully initialized.
This allows the kernel to probe the newly-exposed VFs before the PF is ready
to handle them (nested probes).

Have the probe method return the -EPROBE_DEFER value in this situation (instead
of the VF probe method retrying its initialization in a loop, and returning -EIO
on failure). When -EPROBE_DEFER is returned by the VF probe method, the kernel
itself will retry the probe after a suitable delay.

Based upon a suggestion by Ben Hutchings <bhutchings@solarflare.com>

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c  |    2 --
 drivers/net/ethernet/mellanox/mlx4/main.c |   20 ++++++--------------
 2 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 1df56cc..0e572a5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -222,8 +222,6 @@ static int mlx4_comm_cmd_poll(struct mlx4_dev *dev, u8 cmd, u16 param,
 		 * FLR process. The only non-zero result in the RESET command
 		 * is MLX4_DELAY_RESET_SLAVE*/
 		if ((MLX4_COMM_CMD_RESET == cmd)) {
-			mlx4_warn(dev, "Got slave FLRed from Communication"
-				  " channel (ret:0x%x)\n", ret_from_pending);
 			err = MLX4_DELAY_RESET_SLAVE;
 		} else {
 			mlx4_warn(dev, "Communication channel timed out\n");
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 0d32a82..2f4a260 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1290,7 +1290,6 @@ static int mlx4_init_slave(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	u64 dma = (u64) priv->mfunc.vhcr_dma;
-	int num_of_reset_retries = NUM_OF_RESET_RETRIES;
 	int ret_from_reset = 0;
 	u32 slave_read;
 	u32 cmd_channel_ver;
@@ -1304,18 +1303,10 @@ static int mlx4_init_slave(struct mlx4_dev *dev)
 	 * NUM_OF_RESET_RETRIES times before leaving.*/
 	if (ret_from_reset) {
 		if (MLX4_DELAY_RESET_SLAVE == ret_from_reset) {
-			msleep(SLEEP_TIME_IN_RESET);
-			while (ret_from_reset && num_of_reset_retries) {
-				mlx4_warn(dev, "slave is currently in the"
-					  "middle of FLR. retrying..."
-					  "(try num:%d)\n",
-					  (NUM_OF_RESET_RETRIES -
-					   num_of_reset_retries  + 1));
-				ret_from_reset =
-					mlx4_comm_cmd(dev, MLX4_COMM_CMD_RESET,
-						      0, MLX4_COMM_TIME);
-				num_of_reset_retries = num_of_reset_retries - 1;
-			}
+			mlx4_warn(dev, "slave is currently in the "
+				  "middle of FLR. Deferring probe.\n");
+			mutex_unlock(&priv->cmd.slave_cmd_mutex);
+			return -EPROBE_DEFER;
 		} else
 			goto err;
 	}
@@ -1526,7 +1517,8 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 	} else {
 		err = mlx4_init_slave(dev);
 		if (err) {
-			mlx4_err(dev, "Failed to initialize slave\n");
+			if (err != -EPROBE_DEFER)
+				mlx4_err(dev, "Failed to initialize slave\n");
 			return err;
 		}
 
-- 
1.7.1
