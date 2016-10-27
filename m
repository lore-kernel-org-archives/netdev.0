From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 09/10] net/mlx4_en: Fix potential deadlock in port statistics flow
Date: Thu, 27 Oct 2016 16:27:21 +0300
Message-ID: <1477574842-29688-10-git-send-email-tariqt@mellanox.com>
References: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57536 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941341AbcJ0NyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:54:22 -0400
In-Reply-To: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

mlx4_en_DUMP_ETH_STATS took the *counter mutex* and then
called the FW command, with WRAPPED attribute. As a result, the fw command
is wrapped on the Hypervisor when it calls mlx4_en_DUMP_ETH_STATS.
The FW command wrapper flow on the hypervisor takes the *slave_cmd_mutex*
during processing.

At the same time, a VF could be in the process of coming up, and could
call mlx4_QUERY_FUNC_CAP.  On the hypervisor, the command flow takes the
*slave_cmd_mutex*, then executes mlx4_QUERY_FUNC_CAP_wrapper.
mlx4_QUERY_FUNC_CAP wrapper calls mlx4_get_default_counter_index(),
which takes the *counter mutex*. DEADLOCK.

The fix is that the DUMP_ETH_STATS fw command should be called with
the NATIVE attribute, so that on the hypervisor, this command does not
enter the wrapper flow.

Since the Hypervisor no longer goes through the wrapper code, we also
simply return 0 in mlx4_DUMP_ETH_STATS_wrapper (i.e.the function succeeds,
but the returned data will be all zeroes).
No need to test if it is the Hypervisor going through the wrapper.

Fixes: f9baff509f8a ("mlx4_core: Add "native" argument to mlx4_cmd ...")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.c |  4 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4.h    |  2 --
 drivers/net/ethernet/mellanox/mlx4/port.c    | 13 +------------
 3 files changed, 3 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 5aa8b751f417..59473a0ebcdf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -166,7 +166,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 		return PTR_ERR(mailbox);
 	err = mlx4_cmd_box(mdev->dev, 0, mailbox->dma, in_mod, 0,
 			   MLX4_CMD_DUMP_ETH_STATS, MLX4_CMD_TIME_CLASS_B,
-			   MLX4_CMD_WRAPPED);
+			   MLX4_CMD_NATIVE);
 	if (err)
 		goto out;
 
@@ -322,7 +322,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 		err = mlx4_cmd_box(mdev->dev, 0, mailbox->dma,
 				   in_mod | MLX4_DUMP_ETH_STATS_FLOW_CONTROL,
 				   0, MLX4_CMD_DUMP_ETH_STATS,
-				   MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
+				   MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 		if (err)
 			goto out;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 7aad07644289..88ee7d8a5923 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1330,8 +1330,6 @@ int mlx4_SET_VLAN_FLTR_wrapper(struct mlx4_dev *dev, int slave,
 			       struct mlx4_cmd_info *cmd);
 int mlx4_common_set_vlan_fltr(struct mlx4_dev *dev, int function,
 				     int port, void *buf);
-int mlx4_common_dump_eth_stats(struct mlx4_dev *dev, int slave, u32 in_mod,
-				struct mlx4_cmd_mailbox *outbox);
 int mlx4_DUMP_ETH_STATS_wrapper(struct mlx4_dev *dev, int slave,
 				   struct mlx4_vhcr *vhcr,
 				   struct mlx4_cmd_mailbox *inbox,
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index c5b2064297a1..b656dd5772e5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -1728,24 +1728,13 @@ int mlx4_SET_VLAN_FLTR_wrapper(struct mlx4_dev *dev, int slave,
 	return err;
 }
 
-int mlx4_common_dump_eth_stats(struct mlx4_dev *dev, int slave,
-			       u32 in_mod, struct mlx4_cmd_mailbox *outbox)
-{
-	return mlx4_cmd_box(dev, 0, outbox->dma, in_mod, 0,
-			    MLX4_CMD_DUMP_ETH_STATS, MLX4_CMD_TIME_CLASS_B,
-			    MLX4_CMD_NATIVE);
-}
-
 int mlx4_DUMP_ETH_STATS_wrapper(struct mlx4_dev *dev, int slave,
 				struct mlx4_vhcr *vhcr,
 				struct mlx4_cmd_mailbox *inbox,
 				struct mlx4_cmd_mailbox *outbox,
 				struct mlx4_cmd_info *cmd)
 {
-	if (slave != dev->caps.function)
-		return 0;
-	return mlx4_common_dump_eth_stats(dev, slave,
-					  vhcr->in_modifier, outbox);
+	return 0;
 }
 
 int mlx4_get_slave_from_roce_gid(struct mlx4_dev *dev, int port, u8 *gid,
-- 
1.8.3.1
