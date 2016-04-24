From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 06/11] net/mlx5e: Improve set features ndo resiliency
Date: Sun, 24 Apr 2016 22:51:51 +0300
Message-ID: <1461527516-29290-7-git-send-email-saeedm@mellanox.com>
References: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53275 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753001AbcDXTyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2016 15:54:39 -0400
In-Reply-To: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

In current mlx5e ndo_set_features implementation, setting some features
can success while others can fail. Today, we return one error code which
doesn't reflect the current features status of the netdev at the end of
the ndo callback.

Set netdev->features with features which were successfully set in order
to keep the current status in case of failure. For this purpose, define
new Macro to set/unset specific feature in netdev->features.

This patch introduces a mechanism that uses feature handlers for each
feature.
Set features will call a generic handler, which will then call a specific
handler in his turn and update netdev->features according to it's return
value. Each specific handler is responsible to perform driver specific
actions, and updating params if needed.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  110 +++++++++++++++-----
 1 files changed, 82 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 61e261c..d82bc6b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2078,50 +2078,104 @@ static int mlx5e_set_mac(struct net_device *netdev, void *addr)
 	return 0;
 }
 
-static int mlx5e_set_features(struct net_device *netdev,
-			      netdev_features_t features)
+#define MLX5E_SET_FEATURE(netdev, feature, enable)	\
+	do {						\
+		if (enable)				\
+			netdev->features |= feature;	\
+		else					\
+			netdev->features &= ~feature;	\
+	} while (0)
+
+typedef int (*mlx5e_feature_handler)(struct net_device *netdev, bool enable);
+
+static int set_feature_lro(struct net_device *netdev, bool enable)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	int err = 0;
-	netdev_features_t changes = features ^ netdev->features;
+	bool was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
+	int err;
 
 	mutex_lock(&priv->state_lock);
 
-	if (changes & NETIF_F_LRO) {
-		bool was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-
-		if (was_opened && (priv->params.rq_wq_type ==
-				   MLX5_WQ_TYPE_LINKED_LIST))
-			mlx5e_close_locked(priv->netdev);
-
-		priv->params.lro_en = !!(features & NETIF_F_LRO);
-		err = mlx5e_modify_tirs_lro(priv);
-		if (err)
-			mlx5_core_warn(priv->mdev, "lro modify failed, %d\n",
-				       err);
+	if (was_opened && (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
+		mlx5e_close_locked(priv->netdev);
 
-		if (was_opened && (priv->params.rq_wq_type ==
-				   MLX5_WQ_TYPE_LINKED_LIST))
-			err = mlx5e_open_locked(priv->netdev);
+	priv->params.lro_en = enable;
+	err = mlx5e_modify_tirs_lro(priv);
+	if (err) {
+		netdev_err(netdev, "lro modify failed, %d\n", err);
+		priv->params.lro_en = !enable;
 	}
 
+	if (was_opened && (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
+		mlx5e_open_locked(priv->netdev);
+
 	mutex_unlock(&priv->state_lock);
 
-	if (changes & NETIF_F_HW_VLAN_CTAG_FILTER) {
-		if (features & NETIF_F_HW_VLAN_CTAG_FILTER)
-			mlx5e_enable_vlan_filter(priv);
-		else
-			mlx5e_disable_vlan_filter(priv);
-	}
+	return err;
+}
+
+static int set_feature_vlan_filter(struct net_device *netdev, bool enable)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	if (enable)
+		mlx5e_enable_vlan_filter(priv);
+	else
+		mlx5e_disable_vlan_filter(priv);
+
+	return 0;
+}
+
+static int set_feature_tc_num_filters(struct net_device *netdev, bool enable)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
 
-	if ((changes & NETIF_F_HW_TC) && !(features & NETIF_F_HW_TC) &&
-	    mlx5e_tc_num_filters(priv)) {
+	if (!enable && mlx5e_tc_num_filters(priv)) {
 		netdev_err(netdev,
 			   "Active offloaded tc filters, can't turn hw_tc_offload off\n");
 		return -EINVAL;
 	}
 
-	return err;
+	return 0;
+}
+
+static int mlx5e_handle_feature(struct net_device *netdev,
+				netdev_features_t wanted_features,
+				netdev_features_t feature,
+				mlx5e_feature_handler feature_handler)
+{
+	netdev_features_t changes = wanted_features ^ netdev->features;
+	bool enable = !!(wanted_features & feature);
+	int err;
+
+	if (!(changes & feature))
+		return 0;
+
+	err = feature_handler(netdev, enable);
+	if (err) {
+		netdev_err(netdev, "%s feature 0x%llx failed err %d\n",
+			   enable ? "Enable" : "Disable", feature, err);
+		return err;
+	}
+
+	MLX5E_SET_FEATURE(netdev, feature, enable);
+	return 0;
+}
+
+static int mlx5e_set_features(struct net_device *netdev,
+			      netdev_features_t features)
+{
+	int err;
+
+	err  = mlx5e_handle_feature(netdev, features, NETIF_F_LRO,
+				    set_feature_lro);
+	err |= mlx5e_handle_feature(netdev, features,
+				    NETIF_F_HW_VLAN_CTAG_FILTER,
+				    set_feature_vlan_filter);
+	err |= mlx5e_handle_feature(netdev, features, NETIF_F_HW_TC,
+				    set_feature_tc_num_filters);
+
+	return err ? -EINVAL : 0;
 }
 
 static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
-- 
1.7.1
