From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 01/10] net/mlx5e: Set port MTU on netdev creation rather on open
Date: Thu, 18 Aug 2016 21:09:02 +0300
Message-ID: <1471543751-24164-2-git-send-email-saeedm@mellanox.com>
References: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41781 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755343AbcHSBnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:43:09 -0400
In-Reply-To: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port mtu shouldn't be written to hardware on every single interface
open.
Here we set it only when needed, on change_mtu and netdevice creation.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 870bea3..0fc3a2b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1826,10 +1826,6 @@ int mlx5e_open_locked(struct net_device *netdev)
 	netif_set_real_num_tx_queues(netdev, num_txqs);
 	netif_set_real_num_rx_queues(netdev, priv->params.num_channels);
 
-	err = mlx5e_set_dev_port_mtu(netdev);
-	if (err)
-		goto err_clear_state_opened_flag;
-
 	err = mlx5e_open_channels(priv);
 	if (err) {
 		netdev_err(netdev, "%s: mlx5e_open_channels failed, %d\n",
@@ -2593,6 +2589,7 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 		mlx5e_close_locked(netdev);
 
 	netdev->mtu = new_mtu;
+	mlx5e_set_dev_port_mtu(netdev);
 
 	if (was_opened)
 		err = mlx5e_open_locked(netdev);
@@ -3463,6 +3460,8 @@ void *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
 
 	mlx5e_init_l2_addr(priv);
 
+	mlx5e_set_dev_port_mtu(netdev);
+
 	err = register_netdev(netdev);
 	if (err) {
 		mlx5_core_err(mdev, "register_netdev failed, %d\n", err);
-- 
2.7.4
