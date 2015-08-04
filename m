From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 7/8] net/mlx5e: Take advantage of the light-weight netdev open/stop
Date: Tue,  4 Aug 2015 14:05:46 +0300
Message-ID: <1438686347-17370-8-git-send-email-amirv@mellanox.com>
References: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36468 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933424AbbHDLGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 07:06:24 -0400
In-Reply-To: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Now that TIRs, TISs and flow tables are kept alive while the netdev is
stopped (after executing ndo_stop()) we can do the following
improvements:

- Obsolete the active_vlans SW shadow.
- Do not delete/add flow table rules upon ndo_stop/open.
  In addition to simplifying the flow, this change also fastens
  the ndo_open/close operations.
- Obsolete synchronization of threads accessing the flow tables
  with the netdev stop/open threads.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   5 +-
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    | 109 +++++----------------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  24 ++---
 3 files changed, 32 insertions(+), 106 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index a6c4bd3..35c3390 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -374,10 +374,10 @@ struct mlx5e_eth_addr_db {
 enum {
 	MLX5E_STATE_ASYNC_EVENTS_ENABLE,
 	MLX5E_STATE_OPENED,
+	MLX5E_STATE_DESTROYING,
 };
 
 struct mlx5e_vlan_db {
-	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u32           active_vlans_ft_ix[VLAN_N_VID];
 	u32           untagged_rule_ft_ix;
 	u32           any_vlan_rule_ft_ix;
@@ -485,7 +485,6 @@ void mlx5e_update_stats(struct mlx5e_priv *priv);
 int mlx5e_create_flow_tables(struct mlx5e_priv *priv);
 void mlx5e_destroy_flow_tables(struct mlx5e_priv *priv);
 void mlx5e_init_eth_addr(struct mlx5e_priv *priv);
-void mlx5e_set_rx_mode_core(struct mlx5e_priv *priv);
 void mlx5e_set_rx_mode_work(struct work_struct *work);
 
 int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
@@ -494,8 +493,6 @@ int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
 			   u16 vid);
 void mlx5e_enable_vlan_filter(struct mlx5e_priv *priv);
 void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv);
-int mlx5e_add_all_vlan_rules(struct mlx5e_priv *priv);
-void mlx5e_del_all_vlan_rules(struct mlx5e_priv *priv);
 
 int mlx5e_open_locked(struct net_device *netdev);
 int mlx5e_close_locked(struct net_device *netdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
index d99be78..e71563c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
@@ -594,44 +594,28 @@ static void mlx5e_del_vlan_rule(struct mlx5e_priv *priv,
 
 void mlx5e_enable_vlan_filter(struct mlx5e_priv *priv)
 {
-	WARN_ON(!mutex_is_locked(&priv->state_lock));
+	if (!priv->vlan.filter_disabled)
+		return;
 
-	if (priv->vlan.filter_disabled) {
-		priv->vlan.filter_disabled = false;
-		if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-			mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID,
-					    0);
-	}
+	priv->vlan.filter_disabled = false;
+	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID, 0);
 }
 
 void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv)
 {
-	WARN_ON(!mutex_is_locked(&priv->state_lock));
+	if (priv->vlan.filter_disabled)
+		return;
 
-	if (!priv->vlan.filter_disabled) {
-		priv->vlan.filter_disabled = true;
-		if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-			mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID,
-					    0);
-	}
+	priv->vlan.filter_disabled = true;
+	mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID, 0);
 }
 
 int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
 			  u16 vid)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	int err = 0;
-
-	mutex_lock(&priv->state_lock);
-
-	set_bit(vid, priv->vlan.active_vlans);
-	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-		err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID,
-					  vid);
 
-	mutex_unlock(&priv->state_lock);
-
-	return err;
+	return mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID, vid);
 }
 
 int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
@@ -639,56 +623,11 @@ int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	mutex_lock(&priv->state_lock);
-
-	clear_bit(vid, priv->vlan.active_vlans);
-	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-		mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID, vid);
-
-	mutex_unlock(&priv->state_lock);
-
-	return 0;
-}
-
-int mlx5e_add_all_vlan_rules(struct mlx5e_priv *priv)
-{
-	u16 vid;
-	int err;
-
-	for_each_set_bit(vid, priv->vlan.active_vlans, VLAN_N_VID) {
-		err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID,
-					  vid);
-		if (err)
-			return err;
-	}
-
-	err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
-	if (err)
-		return err;
-
-	if (priv->vlan.filter_disabled) {
-		err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID,
-					  0);
-		if (err)
-			return err;
-	}
+	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID, vid);
 
 	return 0;
 }
 
-void mlx5e_del_all_vlan_rules(struct mlx5e_priv *priv)
-{
-	u16 vid;
-
-	if (priv->vlan.filter_disabled)
-		mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID, 0);
-
-	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
-
-	for_each_set_bit(vid, priv->vlan.active_vlans, VLAN_N_VID)
-		mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID, vid);
-}
-
 #define mlx5e_for_each_hash_node(hn, tmp, hash, i) \
 	for (i = 0; i < MLX5E_ETH_ADDR_HASH_SIZE; i++) \
 		hlist_for_each_entry_safe(hn, tmp, &hash[i], hlist)
@@ -752,18 +691,21 @@ static void mlx5e_handle_netdev_addr(struct mlx5e_priv *priv)
 	mlx5e_for_each_hash_node(hn, tmp, priv->eth_addr.netdev_mc, i)
 		hn->action = MLX5E_ACTION_DEL;
 
-	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+	if (!test_bit(MLX5E_STATE_DESTROYING, &priv->state))
 		mlx5e_sync_netdev_addr(priv);
 
 	mlx5e_apply_netdev_addr(priv);
 }
 
-void mlx5e_set_rx_mode_core(struct mlx5e_priv *priv)
+void mlx5e_set_rx_mode_work(struct work_struct *work)
 {
+	struct mlx5e_priv *priv = container_of(work, struct mlx5e_priv,
+					       set_rx_mode_work);
+
 	struct mlx5e_eth_addr_db *ea = &priv->eth_addr;
 	struct net_device *ndev = priv->netdev;
 
-	bool rx_mode_enable   = test_bit(MLX5E_STATE_OPENED, &priv->state);
+	bool rx_mode_enable   = !test_bit(MLX5E_STATE_DESTROYING, &priv->state);
 	bool promisc_enabled   = rx_mode_enable && (ndev->flags & IFF_PROMISC);
 	bool allmulti_enabled  = rx_mode_enable && (ndev->flags & IFF_ALLMULTI);
 	bool broadcast_enabled = rx_mode_enable;
@@ -796,17 +738,6 @@ void mlx5e_set_rx_mode_core(struct mlx5e_priv *priv)
 	ea->broadcast_enabled = broadcast_enabled;
 }
 
-void mlx5e_set_rx_mode_work(struct work_struct *work)
-{
-	struct mlx5e_priv *priv = container_of(work, struct mlx5e_priv,
-					       set_rx_mode_work);
-
-	mutex_lock(&priv->state_lock);
-	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-		mlx5e_set_rx_mode_core(priv);
-	mutex_unlock(&priv->state_lock);
-}
-
 void mlx5e_init_eth_addr(struct mlx5e_priv *priv)
 {
 	ether_addr_copy(priv->eth_addr.broadcast.addr, priv->netdev->broadcast);
@@ -941,8 +872,15 @@ int mlx5e_create_flow_tables(struct mlx5e_priv *priv)
 	if (err)
 		goto err_destroy_main_flow_table;
 
+	err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
+	if (err)
+		goto err_destroy_vlan_flow_table;
+
 	return 0;
 
+err_destroy_vlan_flow_table:
+	mlx5e_destroy_vlan_flow_table(priv);
+
 err_destroy_main_flow_table:
 	mlx5e_destroy_main_flow_table(priv);
 
@@ -951,6 +889,7 @@ err_destroy_main_flow_table:
 
 void mlx5e_destroy_flow_tables(struct mlx5e_priv *priv)
 {
+	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
 	mlx5e_destroy_vlan_flow_table(priv);
 	mlx5e_destroy_main_flow_table(priv);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 4369688..b8023a7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1332,24 +1332,12 @@ int mlx5e_open_locked(struct net_device *netdev)
 		return err;
 	}
 
-	err = mlx5e_add_all_vlan_rules(priv);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5e_add_all_vlan_rules failed, %d\n",
-			   __func__, err);
-		goto err_close_channels;
-	}
-
 	mlx5e_update_carrier(priv);
 	mlx5e_redirect_rqts(priv);
-	mlx5e_set_rx_mode_core(priv);
 
 	schedule_delayed_work(&priv->update_stats_work, 0);
-	return 0;
 
-err_close_channels:
-	mlx5e_close_channels(priv);
-
-	return err;
+	return 0;
 }
 
 static int mlx5e_open(struct net_device *netdev)
@@ -1371,8 +1359,6 @@ int mlx5e_close_locked(struct net_device *netdev)
 	clear_bit(MLX5E_STATE_OPENED, &priv->state);
 
 	mlx5e_redirect_rqts(priv);
-	mlx5e_set_rx_mode_core(priv);
-	mlx5e_del_all_vlan_rules(priv);
 	netif_carrier_off(priv->netdev);
 	mlx5e_close_channels(priv);
 
@@ -1794,6 +1780,8 @@ static int mlx5e_set_features(struct net_device *netdev,
 			err = mlx5e_open_locked(priv->netdev);
 	}
 
+	mutex_unlock(&priv->state_lock);
+
 	if (changes & NETIF_F_HW_VLAN_CTAG_FILTER) {
 		if (features & NETIF_F_HW_VLAN_CTAG_FILTER)
 			mlx5e_enable_vlan_filter(priv);
@@ -1801,8 +1789,6 @@ static int mlx5e_set_features(struct net_device *netdev,
 			mlx5e_disable_vlan_filter(priv);
 	}
 
-	mutex_unlock(&priv->state_lock);
-
 	return 0;
 }
 
@@ -2094,6 +2080,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 	}
 
 	mlx5e_enable_async_events(priv);
+	schedule_work(&priv->set_rx_mode_work);
 
 	return priv;
 
@@ -2138,6 +2125,9 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	struct mlx5e_priv *priv = vpriv;
 	struct net_device *netdev = priv->netdev;
 
+	set_bit(MLX5E_STATE_DESTROYING, &priv->state);
+
+	schedule_work(&priv->set_rx_mode_work);
 	mlx5e_disable_async_events(priv);
 	flush_scheduled_work();
 	unregister_netdev(netdev);
-- 
2.4.3.413.ga5fe668
