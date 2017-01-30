From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Avoid command timeouts during VF driver device shutdown
Date: Mon, 30 Jan 2017 15:11:45 +0200
Message-ID: <1485781905-1511-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34182 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752959AbdA3NNm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 08:13:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Some Hypervisors detach VFs from VMs by instantly causing an FLR event
to be generated for a VF.

In the mlx4 case, this will cause that VF's comm channel to be disabled
before the VM has an opportunity to invoke the VF device's "shutdown"
method.

The result is that the VF driver on the VM will experience a command
timeout during the shutdown process when the Hypervisor does not deliver
a command-completion event to the VM.

To avoid FW command timeouts on the VM when the driver's shutdown method
is invoked, we detect the absence of the VF's comm channel at the very
start of the shutdown process. If the comm-channel has already been
disabled, we cause all FW commands during the device shutdown process to
immediately return success (and thus avoid all command timeouts).

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/catas.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/intf.c  | 12 ++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h  |  1 +
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
index c7e939945259..53daa6ca5d83 100644
--- a/drivers/net/ethernet/mellanox/mlx4/catas.c
+++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
@@ -158,7 +158,7 @@ static int mlx4_reset_slave(struct mlx4_dev *dev)
 	return -ETIMEDOUT;
 }
 
-static int mlx4_comm_internal_err(u32 slave_read)
+int mlx4_comm_internal_err(u32 slave_read)
 {
 	return (u32)COMM_CHAN_EVENT_INTERNAL_ERR ==
 		(slave_read & (u32)COMM_CHAN_EVENT_INTERNAL_ERR) ? 1 : 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
index 0e8b7c44931f..8258d08acd8c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/intf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/intf.c
@@ -222,6 +222,18 @@ void mlx4_unregister_device(struct mlx4_dev *dev)
 		return;
 
 	mlx4_stop_catas_poll(dev);
+	if (dev->persist->interface_state & MLX4_INTERFACE_STATE_DELETION &&
+	    mlx4_is_slave(dev)) {
+		/* In mlx4_remove_one on a VF */
+		u32 slave_read =
+			swab32(readl(&mlx4_priv(dev)->mfunc.comm->slave_read));
+
+		if (mlx4_comm_internal_err(slave_read)) {
+			mlx4_dbg(dev, "%s: comm channel is down, entering error state.\n",
+				 __func__);
+			mlx4_enter_error_state(dev->persist);
+		}
+	}
 	mutex_lock(&intf_mutex);
 
 	list_for_each_entry(intf, &intf_list, list)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 88ee7d8a5923..086920b615af 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1220,6 +1220,7 @@ int mlx4_comm_cmd(struct mlx4_dev *dev, u8 cmd, u16 param,
 void mlx4_srq_event(struct mlx4_dev *dev, u32 srqn, int event_type);
 
 void mlx4_enter_error_state(struct mlx4_dev_persistent *persist);
+int mlx4_comm_internal_err(u32 slave_read);
 
 int mlx4_SENSE_PORT(struct mlx4_dev *dev, int port,
 		    enum mlx4_port_type *type);
-- 
1.8.3.1
