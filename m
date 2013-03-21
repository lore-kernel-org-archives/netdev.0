From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/5] net/mlx4_en: Remove ethtool flow steering rules before releasing QPs
Date: Thu, 21 Mar 2013 17:55:53 +0200
Message-ID: <1363881355-21137-4-git-send-email-ogerlitz@mellanox.com>
References: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, hadarh@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:48758 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755979Ab3CUP4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 11:56:05 -0400
In-Reply-To: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Fix the ethtool flow steering rules cleanup to be carried out before
releasing the RX QPs.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 995d4b6..f278b10 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1637,6 +1637,17 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 	/* Flush multicast filter */
 	mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0, 1, MLX4_MCAST_CONFIG);
 
+	/* Remove flow steering rules for the port*/
+	if (mdev->dev->caps.steering_mode ==
+	    MLX4_STEERING_MODE_DEVICE_MANAGED) {
+		ASSERT_RTNL();
+		list_for_each_entry_safe(flow, tmp_flow,
+					 &priv->ethtool_list, list) {
+			mlx4_flow_detach(mdev->dev, flow->id);
+			list_del(&flow->list);
+		}
+	}
+
 	mlx4_en_destroy_drop_qp(priv);
 
 	/* Free TX Rings */
@@ -1657,17 +1668,6 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 	if (!(mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAGS2_REASSIGN_MAC_EN))
 		mdev->mac_removed[priv->port] = 1;
 
-	/* Remove flow steering rules for the port*/
-	if (mdev->dev->caps.steering_mode ==
-	    MLX4_STEERING_MODE_DEVICE_MANAGED) {
-		ASSERT_RTNL();
-		list_for_each_entry_safe(flow, tmp_flow,
-					 &priv->ethtool_list, list) {
-			mlx4_flow_detach(mdev->dev, flow->id);
-			list_del(&flow->list);
-		}
-	}
-
 	/* Free RX Rings */
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[i]);
-- 
1.7.1
