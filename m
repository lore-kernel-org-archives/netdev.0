From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 1/2] Revert "net/mlx4_en: Avoid unregister_netdev at shutdown flow"
Date: Sun, 27 Nov 2016 19:20:51 +0200
Message-ID: <1480267252-26146-2-git-send-email-tariqt@mellanox.com>
References: <1480267252-26146-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34729 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751947AbcK0RVN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 12:21:13 -0500
In-Reply-To: <1480267252-26146-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 9d76931180557270796f9631e2c79b9c7bb3c9fb.

Using unregister_netdev at shutdown flow prevents calling
the netdev's ndos or trying to access its freed resources.

This fixes crashes like the following:
 Call Trace:
  [<ffffffff81587a6e>] dev_get_phys_port_id+0x1e/0x30
  [<ffffffff815a36ce>] rtnl_fill_ifinfo+0x4be/0xff0
  [<ffffffff815a53f3>] rtmsg_ifinfo_build_skb+0x73/0xe0
  [<ffffffff815a5476>] rtmsg_ifinfo.part.27+0x16/0x50
  [<ffffffff815a54c8>] rtmsg_ifinfo+0x18/0x20
  [<ffffffff8158a6c6>] netdev_state_change+0x46/0x50
  [<ffffffff815a5e78>] linkwatch_do_dev+0x38/0x50
  [<ffffffff815a6165>] __linkwatch_run_queue+0xf5/0x170
  [<ffffffff815a6205>] linkwatch_event+0x25/0x30
  [<ffffffff81099a82>] process_one_work+0x152/0x400
  [<ffffffff8109a325>] worker_thread+0x125/0x4b0
  [<ffffffff8109a200>] ? rescuer_thread+0x350/0x350
  [<ffffffff8109fc6a>] kthread+0xca/0xe0
  [<ffffffff8109fba0>] ? kthread_park+0x60/0x60
  [<ffffffff816a1285>] ret_from_fork+0x25/0x30

Fixes: 9d7693118055 ("net/mlx4_en: Avoid unregister_netdev at shutdown flow")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Reported-by: Steve Wise <swise@opengridcomputing.com>
Cc: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 17 ++---------------
 drivers/net/ethernet/mellanox/mlx4/main.c      |  5 +----
 include/linux/mlx4/device.h                    |  1 -
 3 files changed, 3 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index a60f635da78b..fb8bb027b69c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2079,13 +2079,6 @@ static int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 	return -ENOMEM;
 }
 
-static void mlx4_en_shutdown(struct net_device *dev)
-{
-	rtnl_lock();
-	netif_device_detach(dev);
-	mlx4_en_close(dev);
-	rtnl_unlock();
-}
 
 static int mlx4_en_copy_priv(struct mlx4_en_priv *dst,
 			     struct mlx4_en_priv *src,
@@ -2162,8 +2155,6 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
-	bool shutdown = mdev->dev->persist->interface_state &
-					    MLX4_INTERFACE_STATE_SHUTDOWN;
 
 	en_dbg(DRV, priv, "Destroying netdev on port:%d\n", priv->port);
 
@@ -2171,10 +2162,7 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	if (priv->registered) {
 		devlink_port_type_clear(mlx4_get_devlink_port(mdev->dev,
 							      priv->port));
-		if (shutdown)
-			mlx4_en_shutdown(dev);
-		else
-			unregister_netdev(dev);
+		unregister_netdev(dev);
 	}
 
 	if (priv->allocated)
@@ -2203,8 +2191,7 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	kfree(priv->tx_ring);
 	kfree(priv->tx_cq);
 
-	if (!shutdown)
-		free_netdev(dev);
+	free_netdev(dev);
 }
 
 static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 6f4e67bc3538..75d07fa9d0b1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -4147,11 +4147,8 @@ static void mlx4_shutdown(struct pci_dev *pdev)
 
 	mlx4_info(persist->dev, "mlx4_shutdown was called\n");
 	mutex_lock(&persist->interface_state_mutex);
-	if (persist->interface_state & MLX4_INTERFACE_STATE_UP) {
-		/* Notify mlx4 clients that the kernel is being shut down */
-		persist->interface_state |= MLX4_INTERFACE_STATE_SHUTDOWN;
+	if (persist->interface_state & MLX4_INTERFACE_STATE_UP)
 		mlx4_unload_one(pdev);
-	}
 	mutex_unlock(&persist->interface_state_mutex);
 }
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 3be7abd6e722..c9f379689dd0 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -476,7 +476,6 @@ enum {
 enum {
 	MLX4_INTERFACE_STATE_UP		= 1 << 0,
 	MLX4_INTERFACE_STATE_DELETION	= 1 << 1,
-	MLX4_INTERFACE_STATE_SHUTDOWN	= 1 << 2,
 };
 
 #define MSTR_SM_CHANGE_MASK (MLX4_EQ_PORT_INFO_MSTR_SM_SL_CHANGE_MASK | \
-- 
1.8.3.1
