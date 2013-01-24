From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 2/6] net/mlx4_en: Fix traffic loss under promiscuous mode
Date: Thu, 24 Jan 2013 13:54:15 +0200
Message-ID: <1359028459-30961-3-git-send-email-amirv@mellanox.com>
References: <1359028459-30961-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Aviad Yehezkel <aviadye@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:58413 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753006Ab3AXLyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 06:54:39 -0500
In-Reply-To: <1359028459-30961-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviad Yehezkel <aviadye@mellanox.com>

When port is stopped and flow steering mode is not device managed: promisc QP
rule wasn't removed from MCG table.
Added code to remove it in all flow steering modes.
In addition, promsic rule removal should be in stop port and not in start
port - moved it accordingly.

Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   35 +++++++++++++++++------
 1 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b6c645f..bab8cec 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1167,15 +1167,6 @@ int mlx4_en_start_port(struct net_device *dev)
 
 	/* Must redo promiscuous mode setup. */
 	priv->flags &= ~(MLX4_EN_FLAG_PROMISC | MLX4_EN_FLAG_MC_PROMISC);
-	if (mdev->dev->caps.steering_mode ==
-	    MLX4_STEERING_MODE_DEVICE_MANAGED) {
-		mlx4_flow_steer_promisc_remove(mdev->dev,
-					       priv->port,
-					       MLX4_FS_PROMISC_UPLINK);
-		mlx4_flow_steer_promisc_remove(mdev->dev,
-					       priv->port,
-					       MLX4_FS_PROMISC_ALL_MULTI);
-	}
 
 	/* Schedule multicast task to populate multicast list */
 	queue_work(mdev->workqueue, &priv->mcast_task);
@@ -1227,6 +1218,32 @@ void mlx4_en_stop_port(struct net_device *dev)
 	/* Set port as not active */
 	priv->port_up = false;
 
+	/* Promsicuous mode */
+	if (mdev->dev->caps.steering_mode ==
+	    MLX4_STEERING_MODE_DEVICE_MANAGED) {
+		priv->flags &= ~(MLX4_EN_FLAG_PROMISC |
+				 MLX4_EN_FLAG_MC_PROMISC);
+		mlx4_flow_steer_promisc_remove(mdev->dev,
+					       priv->port,
+					       MLX4_FS_PROMISC_UPLINK);
+		mlx4_flow_steer_promisc_remove(mdev->dev,
+					       priv->port,
+					       MLX4_FS_PROMISC_ALL_MULTI);
+	} else if (priv->flags & MLX4_EN_FLAG_PROMISC) {
+		priv->flags &= ~MLX4_EN_FLAG_PROMISC;
+
+		/* Disable promiscouos mode */
+		mlx4_unicast_promisc_remove(mdev->dev, priv->base_qpn,
+					    priv->port);
+
+		/* Disable Multicast promisc */
+		if (priv->flags & MLX4_EN_FLAG_MC_PROMISC) {
+			mlx4_multicast_promisc_remove(mdev->dev, priv->base_qpn,
+						      priv->port);
+			priv->flags &= ~MLX4_EN_FLAG_MC_PROMISC;
+		}
+	}
+
 	/* Detach All multicasts */
 	memset(&mc_list[10], 0xff, ETH_ALEN);
 	mc_list[5] = priv->port; /* needed for B0 steering support */
-- 
1.7.8.2
