From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 08/13] net/mlx4_en: Add support for setting rxvlan offload OFF/ON
Date: Mon, 27 Oct 2014 11:37:42 +0200
Message-ID: <1414402667-8841-9-git-send-email-amirv@mellanox.com>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:32859 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752260AbaJ0Jia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:38:30 -0400
In-Reply-To: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Rename mlx4_en_timestamp_config to mlx4_en_reset_config and extend it to support
choosing RX vlan offload configuration.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c  | 53 ++++++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 10 +++--
 3 files changed, 50 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 57dda95..285fccf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -35,16 +35,26 @@
 
 #include "mlx4_en.h"
 
-int mlx4_en_timestamp_config(struct net_device *dev, int tx_type, int rx_filter)
+int mlx4_en_reset_config(struct net_device *dev,
+			 struct hwtstamp_config ts_config,
+			 netdev_features_t features)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int port_up = 0;
 	int err = 0;
 
-	if (priv->hwtstamp_config.tx_type == tx_type &&
-	    priv->hwtstamp_config.rx_filter == rx_filter)
-		return 0;
+	if (priv->hwtstamp_config.tx_type == ts_config.tx_type &&
+	    priv->hwtstamp_config.rx_filter == ts_config.rx_filter &&
+	    !DEV_FEATURE_CHANGED(dev, features, NETIF_F_HW_VLAN_CTAG_RX))
+		return 0; /* Nothing to change */
+
+	if (DEV_FEATURE_CHANGED(dev, features, NETIF_F_HW_VLAN_CTAG_RX) &&
+	    (features & NETIF_F_HW_VLAN_CTAG_RX) &&
+	    (priv->hwtstamp_config.rx_filter != HWTSTAMP_FILTER_NONE)) {
+		en_warn(priv, "Can't turn ON rx vlan offload while time-stamping rx filter is ON\n");
+		return -EINVAL;
+	}
 
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
@@ -54,15 +64,36 @@ int mlx4_en_timestamp_config(struct net_device *dev, int tx_type, int rx_filter)
 
 	mlx4_en_free_resources(priv);
 
-	en_warn(priv, "Changing Time Stamp configuration\n");
-
-	priv->hwtstamp_config.tx_type = tx_type;
-	priv->hwtstamp_config.rx_filter = rx_filter;
+	en_warn(priv, "Changing device configuration rx filter(%x) rx vlan(%x)\n",
+		ts_config.rx_filter, !!(features & NETIF_F_HW_VLAN_CTAG_RX));
+
+	priv->hwtstamp_config.tx_type = ts_config.tx_type;
+	priv->hwtstamp_config.rx_filter = ts_config.rx_filter;
+
+	if (DEV_FEATURE_CHANGED(dev, features, NETIF_F_HW_VLAN_CTAG_RX)) {
+		if (features & NETIF_F_HW_VLAN_CTAG_RX)
+			dev->features |= NETIF_F_HW_VLAN_CTAG_RX;
+		else
+			dev->features &= ~NETIF_F_HW_VLAN_CTAG_RX;
+	} else if (ts_config.rx_filter == HWTSTAMP_FILTER_NONE) {
+		/* RX time-stamping is OFF, update the RX vlan offload
+		 * to the latest wanted state
+		 */
+		if (dev->wanted_features & NETIF_F_HW_VLAN_CTAG_RX)
+			dev->features |= NETIF_F_HW_VLAN_CTAG_RX;
+		else
+			dev->features &= ~NETIF_F_HW_VLAN_CTAG_RX;
+	}
 
-	if (rx_filter != HWTSTAMP_FILTER_NONE)
+	/* RX vlan offload and RX time-stamping can't co-exist !
+	 * Regardless of the caller's choice,
+	 * Turn Off RX vlan offload in case of time-stamping is ON
+	 */
+	if (ts_config.rx_filter != HWTSTAMP_FILTER_NONE) {
+		if (dev->features & NETIF_F_HW_VLAN_CTAG_RX)
+			en_warn(priv, "Turning off RX vlan offload since RX time-stamping is ON\n");
 		dev->features &= ~NETIF_F_HW_VLAN_CTAG_RX;
-	else
-		dev->features |= NETIF_F_HW_VLAN_CTAG_RX;
+	}
 
 	err = mlx4_en_alloc_resources(priv);
 	if (err) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f3032fe..c4bd2c7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2157,7 +2157,7 @@ static int mlx4_en_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 		return -ERANGE;
 	}
 
-	if (mlx4_en_timestamp_config(dev, config.tx_type, config.rx_filter)) {
+	if (mlx4_en_reset_config(dev, config, dev->features)) {
 		config.tx_type = HWTSTAMP_TX_OFF;
 		config.rx_filter = HWTSTAMP_FILTER_NONE;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 946754e..6beb4d3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -835,6 +835,13 @@ void mlx4_en_cleanup_filters(struct mlx4_en_priv *priv);
 void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf);
 void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev);
 
+#define DEV_FEATURE_CHANGED(dev, new_features, feature) \
+	((dev->features & feature) ^ (new_features & feature))
+
+int mlx4_en_reset_config(struct net_device *dev,
+			 struct hwtstamp_config ts_config,
+			 netdev_features_t new_features);
+
 /*
  * Functions for time stamping
  */
@@ -844,9 +851,6 @@ void mlx4_en_fill_hwtstamps(struct mlx4_en_dev *mdev,
 			    u64 timestamp);
 void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev);
 void mlx4_en_remove_timestamp(struct mlx4_en_dev *mdev);
-int mlx4_en_timestamp_config(struct net_device *dev,
-			     int tx_type,
-			     int rx_filter);
 
 /* Globals
  */
-- 
1.8.3.4
