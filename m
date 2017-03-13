From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Avoid delays during VF driver device shutdown
Date: Mon, 13 Mar 2017 19:29:08 +0200
Message-ID: <1489426148-7906-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42918 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751085AbdCMR3j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 13:29:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Some Hypervisors detach VFs from VMs by instantly causing an FLR event
to be generated for a VF.

In the mlx4 case, this will cause that VF's comm channel to be disabled
before the VM has an opportunity to invoke the VF device's "shutdown"
method.

For such Hypervisors, there is a race condition between the VF's
shutdown method and its internal-error detection/reset thread.

The internal-error detection/reset thread (which runs every 5 seconds) also
detects a disabled comm channel. If the internal-error detection/reset
flow wins the race, we still get delays (while that flow tries repeatedly
to detect comm-channel recovery).

The cited commit fixed the command timeout problem when the
internal-error detection/reset flow loses the race.

This commit avoids the unneeded delays when the internal-error
detection/reset flow wins.

Fixes: d585df1c5ccf ("net/mlx4_core: Avoid command timeouts during VF driver device shutdown")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Reported-by: Simon Xiao <sixiao@microsoft.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c  | 11 +++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c | 11 +++++++++++
 include/linux/mlx4/device.h               |  1 +
 3 files changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index e8c105164931..0e0fa7030565 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2305,6 +2305,17 @@ static int sync_toggles(struct mlx4_dev *dev)
 		rd_toggle = swab32(readl(&priv->mfunc.comm->slave_read));
 		if (wr_toggle == 0xffffffff || rd_toggle == 0xffffffff) {
 			/* PCI might be offline */
+
+			/* If device removal has been requested,
+			 * do not continue retrying.
+			 */
+			if (dev->persist->interface_state &
+			    MLX4_INTERFACE_STATE_NOWAIT) {
+				mlx4_warn(dev,
+					  "communication channel is offline\n");
+				return -EIO;
+			}
+
 			msleep(100);
 			wr_toggle = swab32(readl(&priv->mfunc.comm->
 					   slave_write));
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 21377c315083..703205475524 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1940,6 +1940,14 @@ static int mlx4_comm_check_offline(struct mlx4_dev *dev)
 			       (u32)(1 << COMM_CHAN_OFFLINE_OFFSET));
 		if (!offline_bit)
 			return 0;
+
+		/* If device removal has been requested,
+		 * do not continue retrying.
+		 */
+		if (dev->persist->interface_state &
+		    MLX4_INTERFACE_STATE_NOWAIT)
+			break;
+
 		/* There are cases as part of AER/Reset flow that PF needs
 		 * around 100 msec to load. We therefore sleep for 100 msec
 		 * to allow other tasks to make use of that CPU during this
@@ -3955,6 +3963,9 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	struct devlink *devlink = priv_to_devlink(priv);
 	int active_vfs = 0;
 
+	if (mlx4_is_slave(dev))
+		persist->interface_state |= MLX4_INTERFACE_STATE_NOWAIT;
+
 	mutex_lock(&persist->interface_state_mutex);
 	persist->interface_state |= MLX4_INTERFACE_STATE_DELETION;
 	mutex_unlock(&persist->interface_state_mutex);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 7e66e4f62858..1beb1ec2fbdf 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -476,6 +476,7 @@ enum {
 enum {
 	MLX4_INTERFACE_STATE_UP		= 1 << 0,
 	MLX4_INTERFACE_STATE_DELETION	= 1 << 1,
+	MLX4_INTERFACE_STATE_NOWAIT	= 1 << 2,
 };
 
 #define MSTR_SM_CHANGE_MASK (MLX4_EQ_PORT_INFO_MSTR_SM_SL_CHANGE_MASK | \
-- 
1.8.3.1
