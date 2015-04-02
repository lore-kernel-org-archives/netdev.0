From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 16/18] net/mlx4_en: Add RX-FCS support
Date: Thu,  2 Apr 2015 16:31:21 +0300
Message-ID: <1427981483-19317-17-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Muhammad Mahajna <muhammadm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45736 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752934AbbDBNcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:07 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Muhammad Mahajna <muhammadm@mellanox.com>

Enabled when device supports KEEP FCS. When the flag is set, Ethernet FCS
is appended to the end of the frame, controlled by ethtool.

Signed-off-by: Muhammad Mahajna <muhammadm@mellanox.com>
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   33 +++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |    5 +++-
 2 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b02a2e8..2cf8af7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2195,15 +2195,19 @@ static int mlx4_en_set_features(struct net_device *netdev,
 		netdev_features_t features)
 {
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
+	bool reset = false;
 	int ret = 0;
 
+	if (DEV_FEATURE_CHANGED(netdev, features, NETIF_F_RXFCS)) {
+		en_info(priv, "Turn %s RX-FCS\n",
+			(features & NETIF_F_RXFCS) ? "ON" : "OFF");
+		reset = true;
+	}
+
 	if (DEV_FEATURE_CHANGED(netdev, features, NETIF_F_HW_VLAN_CTAG_RX)) {
 		en_info(priv, "Turn %s RX vlan strip offload\n",
 			(features & NETIF_F_HW_VLAN_CTAG_RX) ? "ON" : "OFF");
-		ret = mlx4_en_reset_config(netdev, priv->hwtstamp_config,
-					   features);
-		if (ret)
-			return ret;
+		reset = true;
 	}
 
 	if (DEV_FEATURE_CHANGED(netdev, features, NETIF_F_HW_VLAN_CTAG_TX))
@@ -2216,8 +2220,14 @@ static int mlx4_en_set_features(struct net_device *netdev,
 		mlx4_en_update_loopback_state(netdev, features);
 	}
 
-	return 0;
+	if (reset) {
+		ret = mlx4_en_reset_config(netdev, priv->hwtstamp_config,
+					   features);
+		if (ret)
+			return ret;
+	}
 
+	return 0;
 }
 
 static int mlx4_en_set_vf_mac(struct net_device *dev, int queue, u8 *mac)
@@ -2901,6 +2911,9 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	dev->hw_features |= NETIF_F_LOOPBACK |
 			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 
+	if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_FCS_KEEP)
+		dev->hw_features |= NETIF_F_RXFCS;
+
 	if (mdev->dev->caps.steering_mode ==
 	    MLX4_STEERING_MODE_DEVICE_MANAGED &&
 	    mdev->dev->caps.dmfs_high_steer_mode != MLX4_STEERING_DMFS_A0_STATIC)
@@ -2996,7 +3009,8 @@ int mlx4_en_reset_config(struct net_device *dev,
 
 	if (priv->hwtstamp_config.tx_type == ts_config.tx_type &&
 	    priv->hwtstamp_config.rx_filter == ts_config.rx_filter &&
-	    !DEV_FEATURE_CHANGED(dev, features, NETIF_F_HW_VLAN_CTAG_RX))
+	    !DEV_FEATURE_CHANGED(dev, features, NETIF_F_HW_VLAN_CTAG_RX) &&
+	    !DEV_FEATURE_CHANGED(dev, features, NETIF_F_RXFCS))
 		return 0; /* Nothing to change */
 
 	if (DEV_FEATURE_CHANGED(dev, features, NETIF_F_HW_VLAN_CTAG_RX) &&
@@ -3035,6 +3049,13 @@ int mlx4_en_reset_config(struct net_device *dev,
 			dev->features &= ~NETIF_F_HW_VLAN_CTAG_RX;
 	}
 
+	if (DEV_FEATURE_CHANGED(dev, features, NETIF_F_RXFCS)) {
+		if (features & NETIF_F_RXFCS)
+			dev->features |= NETIF_F_RXFCS;
+		else
+			dev->features &= ~NETIF_F_RXFCS;
+	}
+
 	/* RX vlan offload and RX time-stamping can't co-exist !
 	 * Regardless of the caller's choice,
 	 * Turn Off RX vlan offload in case of time-stamping is ON
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 698d60d..79b1501 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1116,7 +1116,10 @@ static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv, int qpn,
 	/* Cancel FCS removal if FW allows */
 	if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_FCS_KEEP) {
 		context->param3 |= cpu_to_be32(1 << 29);
-		ring->fcs_del = ETH_FCS_LEN;
+		if (priv->dev->features & NETIF_F_RXFCS)
+			ring->fcs_del = 0;
+		else
+			ring->fcs_del = ETH_FCS_LEN;
 	} else
 		ring->fcs_del = 0;
 
-- 
1.7.1
