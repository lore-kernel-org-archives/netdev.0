From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next v2 5/9] net/mlx4_en: Re-arrange ndo_set_rx_mode related code
Date: Thu,  7 Feb 2013 14:25:23 +0200
Message-ID: <1360239927-758-6-git-send-email-amirv@mellanox.com>
References: <1360239927-758-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yan Burman <yanb@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:56389 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757345Ab3BGMZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 07:25:49 -0500
In-Reply-To: <1360239927-758-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>

Currently, mlx4_en_do_set_multicast serves as the ndo_set_rx_mode entry for mlx4_en,
doing all related work. Split it to few calls, one per required functionality
(e.g multicast, promiscuous, etc) and rename some structures and calls
to use rx_mode notation instead of multicast.

Signed-off-by: Yan Burman <yanb@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  271 +++++++++++++-----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    2 +-
 2 files changed, 145 insertions(+), 128 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 63a1ef3..80067d5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -747,165 +747,142 @@ static void update_mclist_flags(struct mlx4_en_priv *priv,
 	}
 }
 
-static void mlx4_en_set_multicast(struct net_device *dev)
+static void mlx4_en_set_rx_mode(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
 	if (!priv->port_up)
 		return;
 
-	queue_work(priv->mdev->workqueue, &priv->mcast_task);
+	queue_work(priv->mdev->workqueue, &priv->rx_mode_task);
 }
 
-static void mlx4_en_do_set_multicast(struct work_struct *work)
+static void mlx4_en_set_promisc_mode(struct mlx4_en_priv *priv,
+				     struct mlx4_en_dev *mdev)
 {
-	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
-						 mcast_task);
-	struct mlx4_en_dev *mdev = priv->mdev;
-	struct net_device *dev = priv->dev;
-	struct mlx4_en_mc_list *mclist, *tmp;
-	u64 mcast_addr = 0;
-	u8 mc_list[16] = {0};
 	int err = 0;
 
-	mutex_lock(&mdev->state_lock);
-	if (!mdev->device_up) {
-		en_dbg(HW, priv, "Card is not up, ignoring multicast change.\n");
-		goto out;
-	}
-	if (!priv->port_up) {
-		en_dbg(HW, priv, "Port is down, ignoring  multicast change.\n");
-		goto out;
-	}
-
-	if (!netif_carrier_ok(dev)) {
-		if (!mlx4_en_QUERY_PORT(mdev, priv->port)) {
-			if (priv->port_state.link_state) {
-				priv->last_link_state = MLX4_DEV_EVENT_PORT_UP;
-				netif_carrier_on(dev);
-				en_dbg(LINK, priv, "Link Up\n");
-			}
-		}
-	}
-
-	/*
-	 * Promsicuous mode: disable all filters
-	 */
-
-	if (dev->flags & IFF_PROMISC) {
-		if (!(priv->flags & MLX4_EN_FLAG_PROMISC)) {
-			if (netif_msg_rx_status(priv))
-				en_warn(priv, "Entering promiscuous mode\n");
-			priv->flags |= MLX4_EN_FLAG_PROMISC;
-
-			/* Enable promiscouos mode */
-			switch (mdev->dev->caps.steering_mode) {
-			case MLX4_STEERING_MODE_DEVICE_MANAGED:
-				err = mlx4_flow_steer_promisc_add(mdev->dev,
-								  priv->port,
-								  priv->base_qpn,
-								  MLX4_FS_PROMISC_UPLINK);
-				if (err)
-					en_err(priv, "Failed enabling promiscuous mode\n");
-				priv->flags |= MLX4_EN_FLAG_MC_PROMISC;
-				break;
-
-			case MLX4_STEERING_MODE_B0:
-				err = mlx4_unicast_promisc_add(mdev->dev,
-							       priv->base_qpn,
-							       priv->port);
-				if (err)
-					en_err(priv, "Failed enabling unicast promiscuous mode\n");
-
-				/* Add the default qp number as multicast
-				 * promisc
-				 */
-				if (!(priv->flags & MLX4_EN_FLAG_MC_PROMISC)) {
-					err = mlx4_multicast_promisc_add(mdev->dev,
-									 priv->base_qpn,
-									 priv->port);
-					if (err)
-						en_err(priv, "Failed enabling multicast promiscuous mode\n");
-					priv->flags |= MLX4_EN_FLAG_MC_PROMISC;
-				}
-				break;
-
-			case MLX4_STEERING_MODE_A0:
-				err = mlx4_SET_PORT_qpn_calc(mdev->dev,
-							     priv->port,
-							     priv->base_qpn,
-							     1);
-				if (err)
-					en_err(priv, "Failed enabling promiscuous mode\n");
-				break;
-			}
-
-			/* Disable port multicast filter (unconditionally) */
-			err = mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0,
-						  0, MLX4_MCAST_DISABLE);
-			if (err)
-				en_err(priv, "Failed disabling multicast filter\n");
-
-			/* Disable port VLAN filter */
-			err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
-			if (err)
-				en_err(priv, "Failed disabling VLAN filter\n");
-		}
-		goto out;
-	}
-
-	/*
-	 * Not in promiscuous mode
-	 */
-
-	if (priv->flags & MLX4_EN_FLAG_PROMISC) {
+	if (!(priv->flags & MLX4_EN_FLAG_PROMISC)) {
 		if (netif_msg_rx_status(priv))
-			en_warn(priv, "Leaving promiscuous mode\n");
-		priv->flags &= ~MLX4_EN_FLAG_PROMISC;
+			en_warn(priv, "Entering promiscuous mode\n");
+		priv->flags |= MLX4_EN_FLAG_PROMISC;
 
-		/* Disable promiscouos mode */
+		/* Enable promiscouos mode */
 		switch (mdev->dev->caps.steering_mode) {
 		case MLX4_STEERING_MODE_DEVICE_MANAGED:
-			err = mlx4_flow_steer_promisc_remove(mdev->dev,
-							     priv->port,
-							     MLX4_FS_PROMISC_UPLINK);
+			err = mlx4_flow_steer_promisc_add(mdev->dev,
+							  priv->port,
+							  priv->base_qpn,
+							  MLX4_FS_PROMISC_UPLINK);
 			if (err)
-				en_err(priv, "Failed disabling promiscuous mode\n");
-			priv->flags &= ~MLX4_EN_FLAG_MC_PROMISC;
+				en_err(priv, "Failed enabling promiscuous mode\n");
+			priv->flags |= MLX4_EN_FLAG_MC_PROMISC;
 			break;
 
 		case MLX4_STEERING_MODE_B0:
-			err = mlx4_unicast_promisc_remove(mdev->dev,
-							  priv->base_qpn,
-							  priv->port);
+			err = mlx4_unicast_promisc_add(mdev->dev,
+						       priv->base_qpn,
+						       priv->port);
 			if (err)
-				en_err(priv, "Failed disabling unicast promiscuous mode\n");
-			/* Disable Multicast promisc */
-			if (priv->flags & MLX4_EN_FLAG_MC_PROMISC) {
-				err = mlx4_multicast_promisc_remove(mdev->dev,
-								    priv->base_qpn,
-								    priv->port);
+				en_err(priv, "Failed enabling unicast promiscuous mode\n");
+
+			/* Add the default qp number as multicast
+			 * promisc
+			 */
+			if (!(priv->flags & MLX4_EN_FLAG_MC_PROMISC)) {
+				err = mlx4_multicast_promisc_add(mdev->dev,
+								 priv->base_qpn,
+								 priv->port);
 				if (err)
-					en_err(priv, "Failed disabling multicast promiscuous mode\n");
-				priv->flags &= ~MLX4_EN_FLAG_MC_PROMISC;
+					en_err(priv, "Failed enabling multicast promiscuous mode\n");
+				priv->flags |= MLX4_EN_FLAG_MC_PROMISC;
 			}
 			break;
 
 		case MLX4_STEERING_MODE_A0:
 			err = mlx4_SET_PORT_qpn_calc(mdev->dev,
 						     priv->port,
-						     priv->base_qpn, 0);
+						     priv->base_qpn,
+						     1);
 			if (err)
-				en_err(priv, "Failed disabling promiscuous mode\n");
+				en_err(priv, "Failed enabling promiscuous mode\n");
 			break;
 		}
 
-		/* Enable port VLAN filter */
+		/* Disable port multicast filter (unconditionally) */
+		err = mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0,
+					  0, MLX4_MCAST_DISABLE);
+		if (err)
+			en_err(priv, "Failed disabling multicast filter\n");
+
+		/* Disable port VLAN filter */
 		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
 		if (err)
-			en_err(priv, "Failed enabling VLAN filter\n");
+			en_err(priv, "Failed disabling VLAN filter\n");
+	}
+}
+
+static void mlx4_en_clear_promisc_mode(struct mlx4_en_priv *priv,
+				       struct mlx4_en_dev *mdev)
+{
+	int err = 0;
+
+	if (netif_msg_rx_status(priv))
+		en_warn(priv, "Leaving promiscuous mode\n");
+	priv->flags &= ~MLX4_EN_FLAG_PROMISC;
+
+	/* Disable promiscouos mode */
+	switch (mdev->dev->caps.steering_mode) {
+	case MLX4_STEERING_MODE_DEVICE_MANAGED:
+		err = mlx4_flow_steer_promisc_remove(mdev->dev,
+						     priv->port,
+						     MLX4_FS_PROMISC_UPLINK);
+		if (err)
+			en_err(priv, "Failed disabling promiscuous mode\n");
+		priv->flags &= ~MLX4_EN_FLAG_MC_PROMISC;
+		break;
+
+	case MLX4_STEERING_MODE_B0:
+		err = mlx4_unicast_promisc_remove(mdev->dev,
+						  priv->base_qpn,
+						  priv->port);
+		if (err)
+			en_err(priv, "Failed disabling unicast promiscuous mode\n");
+		/* Disable Multicast promisc */
+		if (priv->flags & MLX4_EN_FLAG_MC_PROMISC) {
+			err = mlx4_multicast_promisc_remove(mdev->dev,
+							    priv->base_qpn,
+							    priv->port);
+			if (err)
+				en_err(priv, "Failed disabling multicast promiscuous mode\n");
+			priv->flags &= ~MLX4_EN_FLAG_MC_PROMISC;
+		}
+		break;
+
+	case MLX4_STEERING_MODE_A0:
+		err = mlx4_SET_PORT_qpn_calc(mdev->dev,
+					     priv->port,
+					     priv->base_qpn, 0);
+		if (err)
+			en_err(priv, "Failed disabling promiscuous mode\n");
+		break;
 	}
 
+	/* Enable port VLAN filter */
+	err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
+	if (err)
+		en_err(priv, "Failed enabling VLAN filter\n");
+}
+
+static void mlx4_en_do_multicast(struct mlx4_en_priv *priv,
+				 struct net_device *dev,
+				 struct mlx4_en_dev *mdev)
+{
+	struct mlx4_en_mc_list *mclist, *tmp;
+	u64 mcast_addr = 0;
+	u8 mc_list[16] = {0};
+	int err = 0;
+
 	/* Enable/disable the multicast filter according to IFF_ALLMULTI */
 	if (dev->flags & IFF_ALLMULTI) {
 		err = mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0,
@@ -1018,6 +995,46 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 			}
 		}
 	}
+}
+
+static void mlx4_en_do_set_rx_mode(struct work_struct *work)
+{
+	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
+						 rx_mode_task);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	struct net_device *dev = priv->dev;
+
+	mutex_lock(&mdev->state_lock);
+	if (!mdev->device_up) {
+		en_dbg(HW, priv, "Card is not up, ignoring rx mode change.\n");
+		goto out;
+	}
+	if (!priv->port_up) {
+		en_dbg(HW, priv, "Port is down, ignoring rx mode change.\n");
+		goto out;
+	}
+
+	if (!netif_carrier_ok(dev)) {
+		if (!mlx4_en_QUERY_PORT(mdev, priv->port)) {
+			if (priv->port_state.link_state) {
+				priv->last_link_state = MLX4_DEV_EVENT_PORT_UP;
+				netif_carrier_on(dev);
+				en_dbg(LINK, priv, "Link Up\n");
+			}
+		}
+	}
+
+	/* Promsicuous mode: disable all filters */
+	if (dev->flags & IFF_PROMISC) {
+		mlx4_en_set_promisc_mode(priv, mdev);
+		goto out;
+	}
+
+	/* Not in promiscuous mode */
+	if (priv->flags & MLX4_EN_FLAG_PROMISC)
+		mlx4_en_clear_promisc_mode(priv, mdev);
+
+	mlx4_en_do_multicast(priv, dev, mdev);
 out:
 	mutex_unlock(&mdev->state_lock);
 }
@@ -1374,7 +1391,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	priv->flags &= ~(MLX4_EN_FLAG_PROMISC | MLX4_EN_FLAG_MC_PROMISC);
 
 	/* Schedule multicast task to populate multicast list */
-	queue_work(mdev->workqueue, &priv->mcast_task);
+	queue_work(mdev->workqueue, &priv->rx_mode_task);
 
 	mlx4_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
 
@@ -1777,7 +1794,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_start_xmit		= mlx4_en_xmit,
 	.ndo_select_queue	= mlx4_en_select_queue,
 	.ndo_get_stats		= mlx4_en_get_stats,
-	.ndo_set_rx_mode	= mlx4_en_set_multicast,
+	.ndo_set_rx_mode	= mlx4_en_set_rx_mode,
 	.ndo_set_mac_address	= mlx4_en_set_mac,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= mlx4_en_change_mtu,
@@ -1847,7 +1864,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->mac_index = -1;
 	priv->msg_enable = MLX4_EN_MSG_LEVEL;
 	spin_lock_init(&priv->stats_lock);
-	INIT_WORK(&priv->mcast_task, mlx4_en_do_set_multicast);
+	INIT_WORK(&priv->rx_mode_task, mlx4_en_do_set_rx_mode);
 	INIT_WORK(&priv->mac_task, mlx4_en_do_set_mac);
 	INIT_WORK(&priv->watchdog_task, mlx4_en_restart);
 	INIT_WORK(&priv->linkstate_task, mlx4_en_linkstate);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 84ed3285..47c9876 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -504,7 +504,7 @@ struct mlx4_en_priv {
 	struct mlx4_en_cq *tx_cq;
 	struct mlx4_en_cq rx_cq[MAX_RX_RINGS];
 	struct mlx4_qp drop_qp;
-	struct work_struct mcast_task;
+	struct work_struct rx_mode_task;
 	struct work_struct mac_task;
 	struct work_struct watchdog_task;
 	struct work_struct linkstate_task;
-- 
1.7.8.2
