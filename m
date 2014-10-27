From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 09/13] net/mlx4_en: Add ethtool support for [rx|tx]vlan offload set to OFF/ON
Date: Mon, 27 Oct 2014 11:37:43 +0200
Message-ID: <1414402667-8841-10-git-send-email-amirv@mellanox.com>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40636 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752408AbaJ0Jis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:38:48 -0400
In-Reply-To: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Move mlx4_en_reset_config to en_netdev.c as it now serves more general purpose.
Add support for turning OFF/ON the rx/tx vlan offlad.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c  | 77 ----------------------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 90 +++++++++++++++++++++++++-
 2 files changed, 89 insertions(+), 78 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 285fccf..9990144 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -35,83 +35,6 @@
 
 #include "mlx4_en.h"
 
-int mlx4_en_reset_config(struct net_device *dev,
-			 struct hwtstamp_config ts_config,
-			 netdev_features_t features)
-{
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
-	int port_up = 0;
-	int err = 0;
-
-	if (priv->hwtstamp_config.tx_type == ts_config.tx_type &&
-	    priv->hwtstamp_config.rx_filter == ts_config.rx_filter &&
-	    !DEV_FEATURE_CHANGED(dev, features, NETIF_F_HW_VLAN_CTAG_RX))
-		return 0; /* Nothing to change */
-
-	if (DEV_FEATURE_CHANGED(dev, features, NETIF_F_HW_VLAN_CTAG_RX) &&
-	    (features & NETIF_F_HW_VLAN_CTAG_RX) &&
-	    (priv->hwtstamp_config.rx_filter != HWTSTAMP_FILTER_NONE)) {
-		en_warn(priv, "Can't turn ON rx vlan offload while time-stamping rx filter is ON\n");
-		return -EINVAL;
-	}
-
-	mutex_lock(&mdev->state_lock);
-	if (priv->port_up) {
-		port_up = 1;
-		mlx4_en_stop_port(dev, 1);
-	}
-
-	mlx4_en_free_resources(priv);
-
-	en_warn(priv, "Changing device configuration rx filter(%x) rx vlan(%x)\n",
-		ts_config.rx_filter, !!(features & NETIF_F_HW_VLAN_CTAG_RX));
-
-	priv->hwtstamp_config.tx_type = ts_config.tx_type;
-	priv->hwtstamp_config.rx_filter = ts_config.rx_filter;
-
-	if (DEV_FEATURE_CHANGED(dev, features, NETIF_F_HW_VLAN_CTAG_RX)) {
-		if (features & NETIF_F_HW_VLAN_CTAG_RX)
-			dev->features |= NETIF_F_HW_VLAN_CTAG_RX;
-		else
-			dev->features &= ~NETIF_F_HW_VLAN_CTAG_RX;
-	} else if (ts_config.rx_filter == HWTSTAMP_FILTER_NONE) {
-		/* RX time-stamping is OFF, update the RX vlan offload
-		 * to the latest wanted state
-		 */
-		if (dev->wanted_features & NETIF_F_HW_VLAN_CTAG_RX)
-			dev->features |= NETIF_F_HW_VLAN_CTAG_RX;
-		else
-			dev->features &= ~NETIF_F_HW_VLAN_CTAG_RX;
-	}
-
-	/* RX vlan offload and RX time-stamping can't co-exist !
-	 * Regardless of the caller's choice,
-	 * Turn Off RX vlan offload in case of time-stamping is ON
-	 */
-	if (ts_config.rx_filter != HWTSTAMP_FILTER_NONE) {
-		if (dev->features & NETIF_F_HW_VLAN_CTAG_RX)
-			en_warn(priv, "Turning off RX vlan offload since RX time-stamping is ON\n");
-		dev->features &= ~NETIF_F_HW_VLAN_CTAG_RX;
-	}
-
-	err = mlx4_en_alloc_resources(priv);
-	if (err) {
-		en_err(priv, "Failed reallocating port resources\n");
-		goto out;
-	}
-	if (port_up) {
-		err = mlx4_en_start_port(dev);
-		if (err)
-			en_err(priv, "Failed starting port\n");
-	}
-
-out:
-	mutex_unlock(&mdev->state_lock);
-	netdev_features_change(dev);
-	return err;
-}
-
 /* mlx4_en_read_clock - read raw cycle counter (to be used by time counter)
  */
 static cycle_t mlx4_en_read_clock(const struct cyclecounter *tc)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index c4bd2c7..5d60882 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2190,6 +2190,16 @@ static int mlx4_en_set_features(struct net_device *netdev,
 		netdev_features_t features)
 {
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
+	int ret = 0;
+
+	if (DEV_FEATURE_CHANGED(netdev, features, NETIF_F_HW_VLAN_CTAG_RX)) {
+		en_info(priv, "Turn %s RX vlan strip offload\n",
+			(features & NETIF_F_HW_VLAN_CTAG_RX) ? "ON" : "OFF");
+		ret = mlx4_en_reset_config(netdev, priv->hwtstamp_config,
+					   features);
+		if (ret)
+			return ret;
+	}
 
 	if (features & NETIF_F_LOOPBACK)
 		priv->ctrl_flags |= cpu_to_be32(MLX4_WQE_CTRL_FORCE_LOOPBACK);
@@ -2559,7 +2569,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	dev->features = dev->hw_features | NETIF_F_HIGHDMA |
 			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
 			NETIF_F_HW_VLAN_CTAG_FILTER;
-	dev->hw_features |= NETIF_F_LOOPBACK;
+	dev->hw_features |= NETIF_F_LOOPBACK |
+			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 
 	if (mdev->dev->caps.steering_mode ==
 	    MLX4_STEERING_MODE_DEVICE_MANAGED)
@@ -2633,3 +2644,80 @@ out:
 	return err;
 }
 
+int mlx4_en_reset_config(struct net_device *dev,
+			 struct hwtstamp_config ts_config,
+			 netdev_features_t features)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int port_up = 0;
+	int err = 0;
+
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
+
+	mutex_lock(&mdev->state_lock);
+	if (priv->port_up) {
+		port_up = 1;
+		mlx4_en_stop_port(dev, 1);
+	}
+
+	mlx4_en_free_resources(priv);
+
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
+
+	/* RX vlan offload and RX time-stamping can't co-exist !
+	 * Regardless of the caller's choice,
+	 * Turn Off RX vlan offload in case of time-stamping is ON
+	 */
+	if (ts_config.rx_filter != HWTSTAMP_FILTER_NONE) {
+		if (dev->features & NETIF_F_HW_VLAN_CTAG_RX)
+			en_warn(priv, "Turning off RX vlan offload since RX time-stamping is ON\n");
+		dev->features &= ~NETIF_F_HW_VLAN_CTAG_RX;
+	}
+
+	err = mlx4_en_alloc_resources(priv);
+	if (err) {
+		en_err(priv, "Failed reallocating port resources\n");
+		goto out;
+	}
+	if (port_up) {
+		err = mlx4_en_start_port(dev);
+		if (err)
+			en_err(priv, "Failed starting port\n");
+	}
+
+out:
+	mutex_unlock(&mdev->state_lock);
+	netdev_features_change(dev);
+	return err;
+}
+
-- 
1.8.3.4
