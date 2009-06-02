From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 1/8] mlx4_en: Giving interface name in debug messages
Date: Tue, 02 Jun 2009 09:27:13 +0300
Message-ID: <4A24C641.6060506@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il> <4A0AB34A.10100@mellanox.co.il> <4A1948D7.8010504@mellanox.co.il> <4A1A57AA.1080209@mellanox.co.il> <4A1B92D1.8070907@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:43883 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755866AbZFBG0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 02:26:30 -0400
In-Reply-To: <4A1B92D1.8070907@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For each debug message, the message will show interface name in case
that the net device was registered, and PCI bus ID with port number
if we were not registered yet. Messages that are not port/netdev specific
stayed in the old format

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |  162 ++++++++++++++++++++----------------------
 drivers/net/mlx4/en_params.c |    6 +-
 drivers/net/mlx4/en_rx.c     |   78 ++++++++++-----------
 drivers/net/mlx4/en_tx.c     |   39 +++++-----
 drivers/net/mlx4/mlx4_en.h   |   30 ++++++--
 5 files changed, 159 insertions(+), 156 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 0cd185a..fea65e7 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -51,14 +51,14 @@ static void mlx4_en_vlan_rx_register(struct net_device *dev, struct vlan_group *
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err;

-	mlx4_dbg(HW, priv, "Registering VLAN group:%p\n", grp);
+	en_dbg(HW, priv, "Registering VLAN group:%p\n", grp);
 	priv->vlgrp = grp;

 	mutex_lock(&mdev->state_lock);
 	if (mdev->device_up && priv->port_up) {
 		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, grp);
 		if (err)
-			mlx4_err(mdev, "Failed configuring VLAN filter\n");
+			en_err(priv, "Failed configuring VLAN filter\n");
 	}
 	mutex_unlock(&mdev->state_lock);
 }
@@ -72,15 +72,15 @@ static void mlx4_en_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 	if (!priv->vlgrp)
 		return;

-	mlx4_dbg(HW, priv, "adding VLAN:%d (vlgrp entry:%p)\n",
-		 vid, vlan_group_get_device(priv->vlgrp, vid));
+	en_dbg(HW, priv, "adding VLAN:%d (vlgrp entry:%p)\n",
+	       vid, vlan_group_get_device(priv->vlgrp, vid));

 	/* Add VID to port VLAN filter */
 	mutex_lock(&mdev->state_lock);
 	if (mdev->device_up && priv->port_up) {
 		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, priv->vlgrp);
 		if (err)
-			mlx4_err(mdev, "Failed configuring VLAN filter\n");
+			en_err(priv, "Failed configuring VLAN filter\n");
 	}
 	mutex_unlock(&mdev->state_lock);
 }
@@ -94,9 +94,8 @@ static void mlx4_en_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	if (!priv->vlgrp)
 		return;

-	mlx4_dbg(HW, priv, "Killing VID:%d (vlgrp:%p vlgrp "
-		 "entry:%p)\n", vid, priv->vlgrp,
-		 vlan_group_get_device(priv->vlgrp, vid));
+	en_dbg(HW, priv, "Killing VID:%d (vlgrp:%p vlgrp entry:%p)\n",
+	       vid, priv->vlgrp, vlan_group_get_device(priv->vlgrp, vid));
 	vlan_group_set_device(priv->vlgrp, vid, NULL);

 	/* Remove VID from port VLAN filter */
@@ -104,7 +103,7 @@ static void mlx4_en_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	if (mdev->device_up && priv->port_up) {
 		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, priv->vlgrp);
 		if (err)
-			mlx4_err(mdev, "Failed configuring VLAN filter\n");
+			en_err(priv, "Failed configuring VLAN filter\n");
 	}
 	mutex_unlock(&mdev->state_lock);
 }
@@ -150,9 +149,10 @@ static void mlx4_en_do_set_mac(struct work_struct *work)
 		err = mlx4_register_mac(mdev->dev, priv->port,
 					priv->mac, &priv->mac_index);
 		if (err)
-			mlx4_err(mdev, "Failed changing HW MAC address\n");
+			en_err(priv, "Failed changing HW MAC address\n");
 	} else
-		mlx4_dbg(HW, priv, "Port is down, exiting...\n");
+		en_dbg(HW, priv, "Port is down while "
+				 "registering mac, exiting...\n");

 	mutex_unlock(&mdev->state_lock);
 }
@@ -174,7 +174,6 @@ static void mlx4_en_clear_list(struct net_device *dev)
 static void mlx4_en_cache_mclist(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
 	struct dev_mc_list *mclist;
 	struct dev_mc_list *tmp;
 	struct dev_mc_list *plist = NULL;
@@ -182,7 +181,7 @@ static void mlx4_en_cache_mclist(struct net_device *dev)
 	for (mclist = dev->mc_list; mclist; mclist = mclist->next) {
 		tmp = kmalloc(sizeof(struct dev_mc_list), GFP_ATOMIC);
 		if (!tmp) {
-			mlx4_err(mdev, "failed to allocate multicast list\n");
+			en_err(priv, "failed to allocate multicast list\n");
 			mlx4_en_clear_list(dev);
 			return;
 		}
@@ -219,13 +218,13 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)

 	mutex_lock(&mdev->state_lock);
 	if (!mdev->device_up) {
-		mlx4_dbg(HW, priv, "Card is not up, ignoring "
-				   "multicast change.\n");
+		en_dbg(HW, priv, "Card is not up, "
+				 "ignoring multicast change.\n");
 		goto out;
 	}
 	if (!priv->port_up) {
-		mlx4_dbg(HW, priv, "Port is down, ignoring "
-				   "multicast change.\n");
+		en_dbg(HW, priv, "Port is down, "
+				 "ignoring  multicast change.\n");
 		goto out;
 	}

@@ -236,29 +235,27 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 	if (dev->flags & IFF_PROMISC) {
 		if (!(priv->flags & MLX4_EN_FLAG_PROMISC)) {
 			if (netif_msg_rx_status(priv))
-				mlx4_warn(mdev, "Port:%d entering promiscuous mode\n",
-					  priv->port);
+				en_warn(priv, "Entering promiscuous mode\n");
 			priv->flags |= MLX4_EN_FLAG_PROMISC;

 			/* Enable promiscouos mode */
 			err = mlx4_SET_PORT_qpn_calc(mdev->dev, priv->port,
 						     priv->base_qpn, 1);
 			if (err)
-				mlx4_err(mdev, "Failed enabling "
-					 "promiscous mode\n");
+				en_err(priv, "Failed enabling "
+					     "promiscous mode\n");

 			/* Disable port multicast filter (unconditionally) */
 			err = mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0,
 						  0, MLX4_MCAST_DISABLE);
 			if (err)
-				mlx4_err(mdev, "Failed disabling "
-					 "multicast filter\n");
+				en_err(priv, "Failed disabling "
+					     "multicast filter\n");

 			/* Disable port VLAN filter */
 			err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, NULL);
 			if (err)
-				mlx4_err(mdev, "Failed disabling "
-					 "VLAN filter\n");
+				en_err(priv, "Failed disabling VLAN filter\n");
 		}
 		goto out;
 	}
@@ -269,20 +266,19 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)

 	if (priv->flags & MLX4_EN_FLAG_PROMISC) {
 		if (netif_msg_rx_status(priv))
-			mlx4_warn(mdev, "Port:%d leaving promiscuous mode\n",
-				  priv->port);
+			en_warn(priv, "Leaving promiscuous mode\n");
 		priv->flags &= ~MLX4_EN_FLAG_PROMISC;

 		/* Disable promiscouos mode */
 		err = mlx4_SET_PORT_qpn_calc(mdev->dev, priv->port,
 					     priv->base_qpn, 0);
 		if (err)
-			mlx4_err(mdev, "Failed disabling promiscous mode\n");
+			en_err(priv, "Failed disabling promiscous mode\n");

 		/* Enable port VLAN filter */
 		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, priv->vlgrp);
 		if (err)
-			mlx4_err(mdev, "Failed enabling VLAN filter\n");
+			en_err(priv, "Failed enabling VLAN filter\n");
 	}

 	/* Enable/disable the multicast filter according to IFF_ALLMULTI */
@@ -290,12 +286,12 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		err = mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0,
 					  0, MLX4_MCAST_DISABLE);
 		if (err)
-			mlx4_err(mdev, "Failed disabling multicast filter\n");
+			en_err(priv, "Failed disabling multicast filter\n");
 	} else {
 		err = mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0,
 					  0, MLX4_MCAST_DISABLE);
 		if (err)
-			mlx4_err(mdev, "Failed disabling multicast filter\n");
+			en_err(priv, "Failed disabling multicast filter\n");

 		/* Flush mcast filter and init it with broadcast address */
 		mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, ETH_BCAST,
@@ -314,7 +310,7 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		err = mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0,
 					  0, MLX4_MCAST_ENABLE);
 		if (err)
-			mlx4_err(mdev, "Failed enabling multicast filter\n");
+			en_err(priv, "Failed enabling multicast filter\n");

 		mlx4_en_clear_list(dev);
 	}
@@ -346,10 +342,10 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
 	struct mlx4_en_dev *mdev = priv->mdev;

 	if (netif_msg_timer(priv))
-		mlx4_warn(mdev, "Tx timeout called on port:%d\n", priv->port);
+		en_warn(priv, "Tx timeout called on port:%d\n", priv->port);

 	priv->port_stats.tx_timeout++;
-	mlx4_dbg(DRV, priv, "Scheduling watchdog\n");
+	en_dbg(DRV, priv, "Scheduling watchdog\n");
 	queue_work(mdev->workqueue, &priv->watchdog_task);
 }

@@ -378,8 +374,8 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 	 */
 	priv->rx_frames = MLX4_EN_RX_COAL_TARGET / priv->dev->mtu + 1;
 	priv->rx_usecs = MLX4_EN_RX_COAL_TIME;
-	mlx4_dbg(INTR, priv, "Default coalesing params for mtu:%d - "
-			     "rx_frames:%d rx_usecs:%d\n",
+	en_dbg(INTR, priv, "Default coalesing params for mtu:%d - "
+			   "rx_frames:%d rx_usecs:%d\n",
 		 priv->dev->mtu, priv->rx_frames, priv->rx_usecs);

 	/* Setup cq moderation params */
@@ -412,7 +408,6 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 {
 	unsigned long period = (unsigned long) (jiffies - priv->last_moder_jiffies);
-	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_cq *cq;
 	unsigned long packets;
 	unsigned long rate;
@@ -472,11 +467,11 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 		moder_time = priv->rx_usecs;
 	}

-	mlx4_dbg(INTR, priv, "tx rate:%lu rx_rate:%lu\n",
-		 tx_pkt_diff * HZ / period, rx_pkt_diff * HZ / period);
+	en_dbg(INTR, priv, "tx rate:%lu rx_rate:%lu\n",
+	       tx_pkt_diff * HZ / period, rx_pkt_diff * HZ / period);

-	mlx4_dbg(INTR, priv, "Rx moder_time changed from:%d to %d period:%lu "
-		 "[jiff] packets:%lu avg_pkt_size:%lu rate:%lu [p/s])\n",
+	en_dbg(INTR, priv, "Rx moder_time changed from:%d to %d period:%lu "
+	       "[jiff] packets:%lu avg_pkt_size:%lu rate:%lu [p/s])\n",
 		 priv->last_moder_time, moder_time, period, packets,
 		 avg_pkt_size, rate);

@@ -487,8 +482,7 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 			cq->moder_time = moder_time;
 			err = mlx4_en_set_cq_moder(priv, cq);
 			if (err) {
-				mlx4_err(mdev, "Failed modifying moderation for cq:%d "
-					 "on port:%d\n", i, priv->port);
+				en_err(priv, "Failed modifying moderation for cq:%d\n", i);
 				break;
 			}
 		}
@@ -511,8 +505,7 @@ static void mlx4_en_do_get_stats(struct work_struct *work)

 	err = mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 0);
 	if (err)
-		mlx4_dbg(HW, priv, "Could not update stats for "
-				   "port:%d\n", priv->port);
+		en_dbg(HW, priv, "Could not update stats \n");

 	mutex_lock(&mdev->state_lock);
 	if (mdev->device_up) {
@@ -536,12 +529,10 @@ static void mlx4_en_linkstate(struct work_struct *work)
 	 * report to system log */
 	if (priv->last_link_state != linkstate) {
 		if (linkstate == MLX4_DEV_EVENT_PORT_DOWN) {
-			if (netif_msg_link(priv))
-				mlx4_info(mdev, "Port %d - link down\n", priv->port);
+			en_dbg(LINK, priv, "Link Down\n");
 			netif_carrier_off(priv->dev);
 		} else {
-			if (netif_msg_link(priv))
-				mlx4_info(mdev, "Port %d - link up\n", priv->port);
+			en_dbg(LINK, priv, "Link Up\n");
 			netif_carrier_on(priv->dev);
 		}
 	}
@@ -563,19 +554,19 @@ int mlx4_en_start_port(struct net_device *dev)
 	int j;

 	if (priv->port_up) {
-		mlx4_dbg(DRV, priv, "start port called while port already up\n");
+		en_dbg(DRV, priv, "start port called while port already up\n");
 		return 0;
 	}

 	/* Calculate Rx buf size */
 	dev->mtu = min(dev->mtu, priv->max_mtu);
 	mlx4_en_calc_rx_buf(dev);
-	mlx4_dbg(DRV, priv, "Rx buf size:%d\n", priv->rx_skb_size);
+	en_dbg(DRV, priv, "Rx buf size:%d\n", priv->rx_skb_size);

 	/* Configure rx cq's and rings */
 	err = mlx4_en_activate_rx_rings(priv);
 	if (err) {
-		mlx4_err(mdev, "Failed to activate RX rings\n");
+		en_err(priv, "Failed to activate RX rings\n");
 		return err;
 	}
 	for (i = 0; i < priv->rx_ring_num; i++) {
@@ -583,14 +574,14 @@ int mlx4_en_start_port(struct net_device *dev)

 		err = mlx4_en_activate_cq(priv, cq);
 		if (err) {
-			mlx4_err(mdev, "Failed activating Rx CQ\n");
+			en_err(priv, "Failed activating Rx CQ\n");
 			goto cq_err;
 		}
 		for (j = 0; j < cq->size; j++)
 			cq->buf[j].owner_sr_opcode = MLX4_CQE_OWNER_MASK;
 		err = mlx4_en_set_cq_moder(priv, cq);
 		if (err) {
-			mlx4_err(mdev, "Failed setting cq moderation parameters");
+			en_err(priv, "Failed setting cq moderation parameters");
 			mlx4_en_deactivate_cq(priv, cq);
 			goto cq_err;
 		}
@@ -601,7 +592,7 @@ int mlx4_en_start_port(struct net_device *dev)

 	err = mlx4_en_config_rss_steer(priv);
 	if (err) {
-		mlx4_err(mdev, "Failed configuring rss steering\n");
+		en_err(priv, "Failed configuring rss steering\n");
 		goto cq_err;
 	}

@@ -611,16 +602,16 @@ int mlx4_en_start_port(struct net_device *dev)
 		cq = &priv->tx_cq[i];
 		err = mlx4_en_activate_cq(priv, cq);
 		if (err) {
-			mlx4_err(mdev, "Failed allocating Tx CQ\n");
+			en_err(priv, "Failed allocating Tx CQ\n");
 			goto tx_err;
 		}
 		err = mlx4_en_set_cq_moder(priv, cq);
 		if (err) {
-			mlx4_err(mdev, "Failed setting cq moderation parameters");
+			en_err(priv, "Failed setting cq moderation parameters");
 			mlx4_en_deactivate_cq(priv, cq);
 			goto tx_err;
 		}
-		mlx4_dbg(DRV, priv, "Resetting index of collapsed CQ:%d to -1\n", i);
+		en_dbg(DRV, priv, "Resetting index of collapsed CQ:%d to -1\n", i);
 		cq->buf->wqe_index = cpu_to_be16(0xffff);

 		/* Configure ring */
@@ -628,7 +619,7 @@ int mlx4_en_start_port(struct net_device *dev)
 		err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn,
 					       priv->rx_ring[0].srq.srqn);
 		if (err) {
-			mlx4_err(mdev, "Failed allocating Tx ring\n");
+			en_err(priv, "Failed allocating Tx ring\n");
 			mlx4_en_deactivate_cq(priv, cq);
 			goto tx_err;
 		}
@@ -646,30 +637,30 @@ int mlx4_en_start_port(struct net_device *dev)
 				    priv->prof->rx_pause,
 				    priv->prof->rx_ppp);
 	if (err) {
-		mlx4_err(mdev, "Failed setting port general configurations"
-			       " for port %d, with error %d\n", priv->port, err);
+		en_err(priv, "Failed setting port general configurations "
+			     "for port %d, with error %d\n", priv->port, err);
 		goto tx_err;
 	}
 	/* Set default qp number */
 	err = mlx4_SET_PORT_qpn_calc(mdev->dev, priv->port, priv->base_qpn, 0);
 	if (err) {
-		mlx4_err(mdev, "Failed setting default qp numbers\n");
+		en_err(priv, "Failed setting default qp numbers\n");
 		goto tx_err;
 	}
 	/* Set port mac number */
-	mlx4_dbg(DRV, priv, "Setting mac for port %d\n", priv->port);
+	en_dbg(DRV, priv, "Setting mac for port %d\n", priv->port);
 	err = mlx4_register_mac(mdev->dev, priv->port,
 				priv->mac, &priv->mac_index);
 	if (err) {
-		mlx4_err(mdev, "Failed setting port mac\n");
+		en_err(priv, "Failed setting port mac\n");
 		goto tx_err;
 	}

 	/* Init port */
-	mlx4_dbg(HW, priv, "Initializing port\n");
+	en_dbg(HW, priv, "Initializing port\n");
 	err = mlx4_INIT_PORT(mdev->dev, priv->port);
 	if (err) {
-		mlx4_err(mdev, "Failed Initializing port\n");
+		en_err(priv, "Failed Initializing port\n");
 		goto mac_err;
 	}

@@ -706,8 +697,7 @@ void mlx4_en_stop_port(struct net_device *dev)
 	int i;

 	if (!priv->port_up) {
-		mlx4_dbg(DRV, priv, "stop port (%d) called while port already down\n",
-			 priv->port);
+		en_dbg(DRV, priv, "stop port called while port already down\n");
 		return;
 	}
 	netif_stop_queue(dev);
@@ -752,13 +742,13 @@ static void mlx4_en_restart(struct work_struct *work)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct net_device *dev = priv->dev;

-	mlx4_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);
+	en_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);

 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		mlx4_en_stop_port(dev);
 		if (mlx4_en_start_port(dev))
-			mlx4_err(mdev, "Failed restarting port %d\n", priv->port);
+			en_err(priv, "Failed restarting port %d\n", priv->port);
 	}
 	mutex_unlock(&mdev->state_lock);
 }
@@ -774,14 +764,14 @@ static int mlx4_en_open(struct net_device *dev)
 	mutex_lock(&mdev->state_lock);

 	if (!mdev->device_up) {
-		mlx4_err(mdev, "Cannot open - device down/disabled\n");
+		en_err(priv, "Cannot open - device down/disabled\n");
 		err = -EBUSY;
 		goto out;
 	}

 	/* Reset HW statistics and performance counters */
 	if (mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 1))
-		mlx4_dbg(HW, priv, "Failed dumping statistics\n");
+		en_dbg(HW, priv, "Failed dumping statistics\n");

 	memset(&priv->stats, 0, sizeof(priv->stats));
 	memset(&priv->pstats, 0, sizeof(priv->pstats));
@@ -798,7 +788,7 @@ static int mlx4_en_open(struct net_device *dev)
 	mlx4_en_set_default_moderation(priv);
 	err = mlx4_en_start_port(dev);
 	if (err)
-		mlx4_err(mdev, "Failed starting port:%d\n", priv->port);
+		en_err(priv, "Failed starting port:%d\n", priv->port);

 out:
 	mutex_unlock(&mdev->state_lock);
@@ -811,8 +801,7 @@ static int mlx4_en_close(struct net_device *dev)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;

-	if (netif_msg_ifdown(priv))
-		mlx4_info(mdev, "Close called for port:%d\n", priv->port);
+	en_dbg(IFDOWN, priv, "Close port called\n");

 	mutex_lock(&mdev->state_lock);

@@ -844,7 +833,6 @@ void mlx4_en_free_resources(struct mlx4_en_priv *priv)

 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 {
-	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_port_profile *prof = priv->prof;
 	int i;

@@ -873,7 +861,7 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 	return 0;

 err:
-	mlx4_err(mdev, "Failed to allocate NIC resources\n");
+	en_err(priv, "Failed to allocate NIC resources\n");
 	return -ENOMEM;
 }

@@ -883,7 +871,7 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;

-	mlx4_dbg(DRV, priv, "Destroying netdev on port:%d\n", priv->port);
+	en_dbg(DRV, priv, "Destroying netdev on port:%d\n", priv->port);

 	/* Unregister device - this will close the port if it was up */
 	if (priv->registered)
@@ -912,11 +900,11 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err = 0;

-	mlx4_dbg(DRV, priv, "Change MTU called - current:%d new:%d\n",
+	en_dbg(DRV, priv, "Change MTU called - current:%d new:%d\n",
 		 dev->mtu, new_mtu);

 	if ((new_mtu < MLX4_EN_MIN_MTU) || (new_mtu > priv->max_mtu)) {
-		mlx4_err(mdev, "Bad MTU size:%d.\n", new_mtu);
+		en_err(priv, "Bad MTU size:%d.\n", new_mtu);
 		return -EPERM;
 	}
 	dev->mtu = new_mtu;
@@ -926,13 +914,13 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 		if (!mdev->device_up) {
 			/* NIC is probably restarting - let watchdog task reset
 			 * the port */
-			mlx4_dbg(DRV, priv, "Change MTU called with card down!?\n");
+			en_dbg(DRV, priv, "Change MTU called with card down!?\n");
 		} else {
 			mlx4_en_stop_port(dev);
 			mlx4_en_set_default_moderation(priv);
 			err = mlx4_en_start_port(dev);
 			if (err) {
-				mlx4_err(mdev, "Failed restarting port:%d\n",
+				en_err(priv, "Failed restarting port:%d\n",
 					 priv->port);
 				queue_work(mdev->workqueue, &priv->watchdog_task);
 			}
@@ -1006,7 +994,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->max_mtu = mdev->dev->caps.eth_mtu_cap[priv->port];
 	priv->mac = mdev->dev->caps.def_mac[priv->port];
 	if (ILLEGAL_MAC(priv->mac)) {
-		mlx4_err(mdev, "Port: %d, invalid mac burned: 0x%llx, quiting\n",
+		en_err(priv, "Port: %d, invalid mac burned: 0x%llx, quiting\n",
 			 priv->port, priv->mac);
 		err = -EINVAL;
 		goto out;
@@ -1025,7 +1013,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	err = mlx4_alloc_hwq_res(mdev->dev, &priv->res,
 				MLX4_EN_PAGE_SIZE, MLX4_EN_PAGE_SIZE);
 	if (err) {
-		mlx4_err(mdev, "Failed to allocate page for rx qps\n");
+		en_err(priv, "Failed to allocate page for rx qps\n");
 		goto out;
 	}
 	priv->allocated = 1;
@@ -1068,9 +1056,13 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	netif_carrier_off(dev);
 	err = register_netdev(dev);
 	if (err) {
-		mlx4_err(mdev, "Netdev registration failed\n");
+		en_err(priv, "Netdev registration failed for port %d\n", port);
 		goto out;
 	}
+
+	en_warn(priv, "Using %d TX rings\n", prof->tx_ring_num);
+	en_warn(priv, "Using %d RX rings\n", prof->rx_ring_num);
+
 	priv->registered = 1;
 	queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
 	return 0;
diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
index c1bd040..3290fec 100644
--- a/drivers/net/mlx4/en_params.c
+++ b/drivers/net/mlx4/en_params.c
@@ -371,7 +371,7 @@ static int mlx4_en_set_pauseparam(struct net_device *dev,
 				    priv->prof->rx_pause,
 				    priv->prof->rx_ppp);
 	if (err)
-		mlx4_err(mdev, "Failed setting pause params to\n");
+		en_err(priv, "Failed setting pause params\n");

 	return err;
 }
@@ -421,13 +421,13 @@ static int mlx4_en_set_ringparam(struct net_device *dev,

 	err = mlx4_en_alloc_resources(priv);
 	if (err) {
-		mlx4_err(mdev, "Failed reallocating port resources\n");
+		en_err(priv, "Failed reallocating port resources\n");
 		goto out;
 	}
 	if (port_up) {
 		err = mlx4_en_start_port(dev);
 		if (err)
-			mlx4_err(mdev, "Failed starting port\n");
+			en_err(priv, "Failed starting port\n");
 	}

 out:
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 6bfab6e..5a14899 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -114,8 +114,8 @@ static int mlx4_en_init_allocator(struct mlx4_en_priv *priv,
 			goto out;

 		page_alloc->offset = priv->frag_info[i].frag_align;
-		mlx4_dbg(DRV, priv, "Initialized allocator:%d with page:%p\n",
-			 i, page_alloc->page);
+		en_dbg(DRV, priv, "Initialized allocator:%d with page:%p\n",
+		       i, page_alloc->page);
 	}
 	return 0;

@@ -136,8 +136,8 @@ static void mlx4_en_destroy_allocator(struct mlx4_en_priv *priv,

 	for (i = 0; i < priv->num_frags; i++) {
 		page_alloc = &ring->page_alloc[i];
-		mlx4_dbg(DRV, priv, "Freeing allocator:%d count:%d\n",
-			 i, page_count(page_alloc->page));
+		en_dbg(DRV, priv, "Freeing allocator:%d count:%d\n",
+		       i, page_count(page_alloc->page));

 		put_page(page_alloc->page);
 		page_alloc->page = NULL;
@@ -214,10 +214,10 @@ static void mlx4_en_free_rx_desc(struct mlx4_en_priv *priv,

 	skb_frags = ring->rx_info + (index << priv->log_rx_info);
 	for (nr = 0; nr < priv->num_frags; nr++) {
-		mlx4_dbg(DRV, priv, "Freeing fragment:%d\n", nr);
+		en_dbg(DRV, priv, "Freeing fragment:%d\n", nr);
 		dma = be64_to_cpu(rx_desc->data[nr].addr);

-		mlx4_dbg(DRV, priv, "Unmaping buffer at dma:0x%llx\n", (u64) dma);
+		en_dbg(DRV, priv, "Unmaping buffer at dma:0x%llx\n", (u64) dma);
 		pci_unmap_single(mdev->pdev, dma, skb_frags[nr].size,
 				 PCI_DMA_FROMDEVICE);
 		put_page(skb_frags[nr].page);
@@ -226,7 +226,6 @@ static void mlx4_en_free_rx_desc(struct mlx4_en_priv *priv,

 static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
 {
-	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_rx_ring *ring;
 	int ring_ind;
 	int buf_ind;
@@ -239,14 +238,14 @@ static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
 			if (mlx4_en_prepare_rx_desc(priv, ring,
 						    ring->actual_size)) {
 				if (ring->actual_size < MLX4_EN_MIN_RX_SIZE) {
-					mlx4_err(mdev, "Failed to allocate "
-						       "enough rx buffers\n");
+					en_err(priv, "Failed to allocate "
+						     "enough rx buffers\n");
 					return -ENOMEM;
 				} else {
 					new_size = rounddown_pow_of_two(ring->actual_size);
-					mlx4_warn(mdev, "Only %d buffers allocated "
-							"reducing ring size to %d",
-						  ring->actual_size, new_size);
+					en_warn(priv, "Only %d buffers allocated "
+						      "reducing ring size to %d",
+						ring->actual_size, new_size);
 					goto reduce_rings;
 				}
 			}
@@ -282,8 +281,7 @@ static int mlx4_en_fill_rx_buf(struct net_device *dev,
 					      ring->size_mask);
 		if (err) {
 			if (netif_msg_rx_err(priv))
-				mlx4_warn(priv->mdev,
-					  "Failed preparing rx descriptor\n");
+				en_warn(priv, "Failed preparing rx descriptor\n");
 			priv->port_stats.rx_alloc_failed++;
 			break;
 		}
@@ -301,14 +299,14 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
 {
 	int index;

-	mlx4_dbg(DRV, priv, "Freeing Rx buf - cons:%d prod:%d\n",
-			ring->cons, ring->prod);
+	en_dbg(DRV, priv, "Freeing Rx buf - cons:%d prod:%d\n",
+	       ring->cons, ring->prod);

 	/* Unmap and free Rx buffers */
 	BUG_ON((u32) (ring->prod - ring->cons) > ring->actual_size);
 	while (ring->cons != ring->prod) {
 		index = ring->cons & ring->size_mask;
-		mlx4_dbg(DRV, priv, "Processing descriptor:%d\n", index);
+		en_dbg(DRV, priv, "Processing descriptor:%d\n", index);
 		mlx4_en_free_rx_desc(priv, ring, index);
 		++ring->cons;
 	}
@@ -373,10 +371,10 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 					sizeof(struct skb_frag_struct));
 	ring->rx_info = vmalloc(tmp);
 	if (!ring->rx_info) {
-		mlx4_err(mdev, "Failed allocating rx_info ring\n");
+		en_err(priv, "Failed allocating rx_info ring\n");
 		return -ENOMEM;
 	}
-	mlx4_dbg(DRV, priv, "Allocated rx_info ring at addr:%p size:%d\n",
+	en_dbg(DRV, priv, "Allocated rx_info ring at addr:%p size:%d\n",
 		 ring->rx_info, tmp);

 	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres,
@@ -386,7 +384,7 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,

 	err = mlx4_en_map_buffer(&ring->wqres.buf);
 	if (err) {
-		mlx4_err(mdev, "Failed to map RX buffer\n");
+		en_err(priv, "Failed to map RX buffer\n");
 		goto err_hwq;
 	}
 	ring->buf = ring->wqres.buf.direct.buf;
@@ -404,7 +402,7 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 				    sizeof(struct net_lro_desc),
 				    GFP_KERNEL);
 	if (!ring->lro.lro_arr) {
-		mlx4_err(mdev, "Failed to allocate lro array\n");
+		en_err(priv, "Failed to allocate lro array\n");
 		goto err_map;
 	}
 	ring->lro.get_frag_header = mlx4_en_get_frag_header;
@@ -455,7 +453,7 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		/* Initialize page allocators */
 		err = mlx4_en_init_allocator(priv, ring);
 		if (err) {
-			mlx4_err(mdev, "Failed initializing ring allocator\n");
+			en_err(priv, "Failed initializing ring allocator\n");
 			ring_ind--;
 			goto err_allocator;
 		}
@@ -486,7 +484,7 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		err = mlx4_srq_alloc(mdev->dev, mdev->priv_pdn, &ring->wqres.mtt,
 				     ring->wqres.db.dma, &ring->srq);
 		if (err){
-			mlx4_err(mdev, "Failed to allocate srq\n");
+			en_err(priv, "Failed to allocate srq\n");
 			ring_ind--;
 			goto err_srq;
 		}
@@ -601,7 +599,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,

 	skb = dev_alloc_skb(SMALL_PACKET_SIZE + NET_IP_ALIGN);
 	if (!skb) {
-		mlx4_dbg(RX_ERR, priv, "Failed allocating skb\n");
+		en_dbg(RX_ERR, priv, "Failed allocating skb\n");
 		return NULL;
 	}
 	skb->dev = priv->dev;
@@ -680,7 +678,6 @@ static void mlx4_en_copy_desc(struct mlx4_en_priv *priv,
 int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int budget)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_cqe *cqe;
 	struct mlx4_en_rx_ring *ring = &priv->rx_ring[cq->ring];
 	struct skb_frag_struct *skb_frags;
@@ -717,14 +714,14 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		/* Drop packet on bad receive or bad checksum */
 		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
 						MLX4_CQE_OPCODE_ERROR)) {
-			mlx4_err(mdev, "CQE completed in error - vendor "
+			en_err(priv, "CQE completed in error - vendor "
 				  "syndrom:%d syndrom:%d\n",
 				  ((struct mlx4_err_cqe *) cqe)->vendor_err_syndrome,
 				  ((struct mlx4_err_cqe *) cqe)->syndrome);
 			goto next;
 		}
 		if (unlikely(cqe->badfcs_enc & MLX4_CQE_BAD_FCS)) {
-			mlx4_dbg(RX_ERR, priv, "Accepted frame with bad FCS\n");
+			en_dbg(RX_ERR, priv, "Accepted frame with bad FCS\n");
 			goto next;
 		}

@@ -874,7 +871,7 @@ static int mlx4_en_last_alloc_offset(struct mlx4_en_priv *priv, u16 stride, u16
 	u16 res = MLX4_EN_ALLOC_SIZE % stride;
 	u16 offset = MLX4_EN_ALLOC_SIZE - stride - res + align;

-	mlx4_dbg(DRV, priv, "Calculated last offset for stride:%d align:%d "
+	en_dbg(DRV, priv, "Calculated last offset for stride:%d align:%d "
 			    "res:%d offset:%d\n", stride, align, res, offset);
 	return offset;
 }
@@ -919,10 +916,10 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 	priv->rx_skb_size = eff_mtu;
 	priv->log_rx_info = ROUNDUP_LOG2(i * sizeof(struct skb_frag_struct));

-	mlx4_dbg(DRV, priv, "Rx buffer scatter-list (effective-mtu:%d "
+	en_dbg(DRV, priv, "Rx buffer scatter-list (effective-mtu:%d "
 		  "num_frags:%d):\n", eff_mtu, priv->num_frags);
 	for (i = 0; i < priv->num_frags; i++) {
-		mlx4_dbg(DRV, priv, "  frag:%d - size:%d prefix:%d align:%d "
+		en_dbg(DRV, priv, "  frag:%d - size:%d prefix:%d align:%d "
 				"stride:%d last_offset:%d\n", i,
 				priv->frag_info[i].frag_size,
 				priv->frag_info[i].frag_prefix_size,
@@ -942,12 +939,12 @@ void mlx4_en_set_default_rss_map(struct mlx4_en_priv *priv,
 	int i;

 	rss_map->size = roundup_pow_of_two(num_entries);
-	mlx4_dbg(DRV, priv, "Setting default RSS map of %d entires\n",
-		 rss_map->size);
+	en_dbg(DRV, priv, "Setting default RSS map of %d entires\n",
+	       rss_map->size);

 	for (i = 0; i < rss_map->size; i++) {
 		rss_map->map[i] = i % num_rings;
-		mlx4_dbg(DRV, priv, "Entry %d ---> ring %d\n", i, rss_map->map[i]);
+		en_dbg(DRV, priv, "Entry %d ---> ring %d\n", i, rss_map->map[i]);
 	}
 }

@@ -962,13 +959,13 @@ static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv,

 	context = kmalloc(sizeof *context , GFP_KERNEL);
 	if (!context) {
-		mlx4_err(mdev, "Failed to allocate qp context\n");
+		en_err(priv, "Failed to allocate qp context\n");
 		return -ENOMEM;
 	}

 	err = mlx4_qp_alloc(mdev->dev, qpn, qp);
 	if (err) {
-		mlx4_err(mdev, "Failed to allocate qp #%d\n", qpn);
+		en_err(priv, "Failed to allocate qp #%x\n", qpn);
 		goto out;
 	}
 	qp->event = mlx4_en_sqp_event;
@@ -1000,12 +997,11 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	int err = 0;
 	int good_qps = 0;

-	mlx4_dbg(DRV, priv, "Configuring rss steering for port %u\n", priv->port);
+	en_dbg(DRV, priv, "Configuring rss steering\n");
 	err = mlx4_qp_reserve_range(mdev->dev, rss_map->size,
 				    rss_map->size, &rss_map->base_qpn);
 	if (err) {
-		mlx4_err(mdev, "Failed reserving %d qps for port %u\n",
-			 rss_map->size, priv->port);
+		en_err(priv, "Failed reserving %d qps\n", rss_map->size);
 		return err;
 	}

@@ -1025,13 +1021,13 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	/* Configure RSS indirection qp */
 	err = mlx4_qp_reserve_range(mdev->dev, 1, 1, &priv->base_qpn);
 	if (err) {
-		mlx4_err(mdev, "Failed to reserve range for RSS "
-			       "indirection qp\n");
+		en_err(priv, "Failed to reserve range for RSS "
+			     "indirection qp\n");
 		goto rss_err;
 	}
 	err = mlx4_qp_alloc(mdev->dev, priv->base_qpn, &rss_map->indir_qp);
 	if (err) {
-		mlx4_err(mdev, "Failed to allocate RSS indirection QP\n");
+		en_err(priv, "Failed to allocate RSS indirection QP\n");
 		goto reserve_err;
 	}
 	rss_map->indir_qp.event = mlx4_en_sqp_event;
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index aeeb334..e32e869 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -68,15 +68,15 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	tmp = size * sizeof(struct mlx4_en_tx_info);
 	ring->tx_info = vmalloc(tmp);
 	if (!ring->tx_info) {
-		mlx4_err(mdev, "Failed allocating tx_info ring\n");
+		en_err(priv, "Failed allocating tx_info ring\n");
 		return -ENOMEM;
 	}
-	mlx4_dbg(DRV, priv, "Allocated tx_info ring at addr:%p size:%d\n",
+	en_dbg(DRV, priv, "Allocated tx_info ring at addr:%p size:%d\n",
 		 ring->tx_info, tmp);

 	ring->bounce_buf = kmalloc(MAX_DESC_SIZE, GFP_KERNEL);
 	if (!ring->bounce_buf) {
-		mlx4_err(mdev, "Failed allocating bounce buffer\n");
+		en_err(priv, "Failed allocating bounce buffer\n");
 		err = -ENOMEM;
 		goto err_tx;
 	}
@@ -85,31 +85,31 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres, ring->buf_size,
 				 2 * PAGE_SIZE);
 	if (err) {
-		mlx4_err(mdev, "Failed allocating hwq resources\n");
+		en_err(priv, "Failed allocating hwq resources\n");
 		goto err_bounce;
 	}

 	err = mlx4_en_map_buffer(&ring->wqres.buf);
 	if (err) {
-		mlx4_err(mdev, "Failed to map TX buffer\n");
+		en_err(priv, "Failed to map TX buffer\n");
 		goto err_hwq_res;
 	}

 	ring->buf = ring->wqres.buf.direct.buf;

-	mlx4_dbg(DRV, priv, "Allocated TX ring (addr:%p) - buf:%p size:%d "
-		 "buf_size:%d dma:%llx\n", ring, ring->buf, ring->size,
-		 ring->buf_size, (unsigned long long) ring->wqres.buf.direct.map);
+	en_dbg(DRV, priv, "Allocated TX ring (addr:%p) - buf:%p size:%d "
+	       "buf_size:%d dma:%llx\n", ring, ring->buf, ring->size,
+	       ring->buf_size, (unsigned long long) ring->wqres.buf.direct.map);

 	err = mlx4_qp_reserve_range(mdev->dev, 1, 1, &ring->qpn);
 	if (err) {
-		mlx4_err(mdev, "Failed reserving qp for tx ring.\n");
+		en_err(priv, "Failed reserving qp for tx ring.\n");
 		goto err_map;
 	}

 	err = mlx4_qp_alloc(mdev->dev, ring->qpn, &ring->qp);
 	if (err) {
-		mlx4_err(mdev, "Failed allocating qp %d\n", ring->qpn);
+		en_err(priv, "Failed allocating qp %d\n", ring->qpn);
 		goto err_reserve;
 	}
 	ring->qp.event = mlx4_en_sqp_event;
@@ -135,7 +135,7 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring *ring)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
-	mlx4_dbg(DRV, priv, "Destroying tx ring, qpn: %d\n", ring->qpn);
+	en_dbg(DRV, priv, "Destroying tx ring, qpn: %d\n", ring->qpn);

 	mlx4_qp_remove(mdev->dev, &ring->qp);
 	mlx4_qp_free(mdev->dev, &ring->qp);
@@ -274,12 +274,12 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)

 	/* Skip last polled descriptor */
 	ring->cons += ring->last_nr_txbb;
-	mlx4_dbg(DRV, priv, "Freeing Tx buf - cons:0x%x prod:0x%x\n",
+	en_dbg(DRV, priv, "Freeing Tx buf - cons:0x%x prod:0x%x\n",
 		 ring->cons, ring->prod);

 	if ((u32) (ring->prod - ring->cons) > ring->size) {
 		if (netif_msg_tx_err(priv))
-			mlx4_warn(priv->mdev, "Tx consumer passed producer!\n");
+			en_warn(priv, "Tx consumer passed producer!\n");
 		return 0;
 	}

@@ -292,7 +292,7 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 	}

 	if (cnt)
-		mlx4_dbg(DRV, priv, "Freed %d uncompleted tx descriptors\n", cnt);
+		en_dbg(DRV, priv, "Freed %d uncompleted tx descriptors\n", cnt);

 	return cnt;
 }
@@ -321,7 +321,7 @@ void mlx4_en_set_prio_map(struct mlx4_en_priv *priv, u16 *prio_map, u32 ring_num
 			num = 0;
 		}
 		prio_map[prio] = ring;
-		mlx4_dbg(DRV, priv, " prio:%d --> ring:%d\n", prio, ring);
+		en_dbg(DRV, priv, " prio:%d --> ring:%d\n", prio, ring);
 		num++;
 	}
 }
@@ -539,7 +539,6 @@ static int get_real_size(struct sk_buff *skb, struct net_device *dev,
 			 int *lso_header_size)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
 	int real_size;

 	if (skb_is_gso(skb)) {
@@ -553,14 +552,14 @@ static int get_real_size(struct sk_buff *skb, struct net_device *dev,
 				real_size += DS_SIZE;
 			else {
 				if (netif_msg_tx_err(priv))
-					mlx4_warn(mdev, "Non-linear headers\n");
+					en_warn(priv, "Non-linear headers\n");
 				dev_kfree_skb_any(skb);
 				return 0;
 			}
 		}
 		if (unlikely(*lso_header_size > MAX_LSO_HDR_SIZE)) {
 			if (netif_msg_tx_err(priv))
-				mlx4_warn(mdev, "LSO header size too big\n");
+				en_warn(priv, "LSO header size too big\n");
 			dev_kfree_skb_any(skb);
 			return 0;
 		}
@@ -669,7 +668,7 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	nr_txbb = desc_size / TXBB_SIZE;
 	if (unlikely(nr_txbb > MAX_DESC_TXBBS)) {
 		if (netif_msg_tx_err(priv))
-			mlx4_warn(mdev, "Oversized header or SG list\n");
+			en_warn(priv, "Oversized header or SG list\n");
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
@@ -695,7 +694,7 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Now that we know what Tx ring to use */
 	if (unlikely(!priv->port_up)) {
 		if (netif_msg_tx_err(priv))
-			mlx4_warn(mdev, "xmit: port down!\n");
+			en_warn(priv, "xmit: port down!\n");
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index ef840ab..c92b382 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -55,20 +55,36 @@

 #define MLX4_EN_MSG_LEVEL	(NETIF_MSG_LINK | NETIF_MSG_IFDOWN)

-#define mlx4_dbg(mlevel, priv, format, arg...)	\
-	if (NETIF_MSG_##mlevel & priv->msg_enable) \
-	printk(KERN_DEBUG "%s %s: " format , DRV_NAME ,\
-		(dev_name(&priv->mdev->pdev->dev)) , ## arg)
+#define en_print(level, priv, format, arg...)			\
+	{							\
+	if ((priv)->registered)					\
+		printk(level "%s: %s: " format, DRV_NAME,	\
+			(priv->dev)->name, ## arg);		\
+	else							\
+		printk(level "%s: %s: Port %d: " format,	\
+			DRV_NAME, dev_name(&priv->mdev->pdev->dev), \
+			(priv)->port, ## arg);			\
+	}
+
+#define en_dbg(mlevel, priv, format, arg...)			\
+	{							\
+	if (NETIF_MSG_##mlevel & priv->msg_enable)		\
+		en_print(KERN_DEBUG, priv, format, ## arg)	\
+	}
+#define en_warn(priv, format, arg...)				\
+	en_print(KERN_WARNING, priv, format, ## arg)
+#define en_err(priv, format, arg...)				\
+	en_print(KERN_ERR, priv, format, ## arg)

 #define mlx4_err(mdev, format, arg...) \
 	printk(KERN_ERR "%s %s: " format , DRV_NAME ,\
-		(dev_name(&mdev->pdev->dev)) , ## arg)
+		dev_name(&mdev->pdev->dev) , ## arg)
 #define mlx4_info(mdev, format, arg...) \
 	printk(KERN_INFO "%s %s: " format , DRV_NAME ,\
-		(dev_name(&mdev->pdev->dev)) , ## arg)
+		dev_name(&mdev->pdev->dev) , ## arg)
 #define mlx4_warn(mdev, format, arg...) \
 	printk(KERN_WARNING "%s %s: " format , DRV_NAME ,\
-		(dev_name(&mdev->pdev->dev)) , ## arg)
+		dev_name(&mdev->pdev->dev) , ## arg)

 /*
  * Device constants
-- 
1.6.0


