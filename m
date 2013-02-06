From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2] mlx4_en: Fix BQL reset TX queue call point
Date: Wed, 6 Feb 2013 09:58:41 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1302060955490.26438@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, yevgenyp@mellanox.com, netdev@vger.kernel.org,
	amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:47001 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932067Ab3BFR6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 12:58:43 -0500
Received: by mail-vc0-f202.google.com with SMTP id m8so174853vcd.1
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 09:58:42 -0800 (PST)
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
index ac1c14f..94042f6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1323,15 +1323,12 @@ static void mlx4_en_restart(struct work_struct *work)
 						 watchdog_task);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct net_device *dev = priv->dev;
-	int i;
 
 	en_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);
 
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		mlx4_en_stop_port(dev, 1);
-		for (i = 0; i < priv->tx_ring_num; i++)
-			netdev_tx_reset_queue(priv->tx_ring[i].tx_queue);
 		if (mlx4_en_start_port(dev))
 			en_err(priv, "Failed restarting port %d\n", priv->port);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 30724d8..e06fce7 100644
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
