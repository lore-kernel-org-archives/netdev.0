From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next] mlx4_en: Change BQL reset TX queue call point
Date: Fri, 1 Feb 2013 17:02:50 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1302011659200.14247@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: yevgenyp@mellanox.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:65360 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756771Ab3BBBCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 20:02:52 -0500
Received: by mail-qa0-f73.google.com with SMTP id g10so143273qah.0
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 17:02:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix issue in Mellanox driver related to BQL.  netdev_tx_reset_queue
was not being called in certain situations where the device was
being start and stopped.  Moved netdev_tx_reset_queue from the reset
device path to mlx4_en_free_tx_buf which is where the rings are
cleaned in a reset (specifically from device being stopped).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 3 ---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 2 ++
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b467513..075fdff 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1284,15 +1284,12 @@ static void mlx4_en_restart(struct work_struct *work)
 						 watchdog_task);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct net_device *dev = priv->dev;
-	int i;
 
 	en_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);
 
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		mlx4_en_stop_port(dev);
-		for (i = 0; i < priv->tx_ring_num; i++)
-			netdev_tx_reset_queue(priv->tx_ring[i].tx_queue);
 		if (mlx4_en_start_port(dev))
 			en_err(priv, "Failed restarting port %d\n", priv->port);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index c579311..3c17732 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -294,6 +294,8 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 		cnt++;
 	}
 
+	netdev_tx_reset_queue(ring->tx_queue);
+
 	if (cnt)
 		en_dbg(DRV, priv, "Freed %d uncompleted tx descriptors\n", cnt);
 
-- 
1.8.1
