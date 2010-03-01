From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] net: convert multiple drivers to use
 netdev_for_each_mc_addr, part7
Date: Mon, 1 Mar 2010 16:09:14 +0100
Message-ID: <20100301150913.GE2799@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48236 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293Ab0CAPJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 10:09:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In mlx4, using char * to store mc address in private structure instead.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/media/dvb/dvb-core/dvb_net.c |    6 +---
 drivers/net/mlx4/en_netdev.c         |   49 ++++++++++++++--------------------
 drivers/net/mlx4/mlx4_en.h           |    3 +-
 drivers/s390/net/qeth_l2_main.c      |    2 +-
 net/bluetooth/bnep/netdev.c          |   10 +++---
 5 files changed, 29 insertions(+), 41 deletions(-)

diff --git a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
index 441c064..dba1c84 100644
--- a/drivers/media/dvb/dvb-core/dvb_net.c
+++ b/drivers/media/dvb/dvb-core/dvb_net.c
@@ -1140,7 +1140,6 @@ static void wq_set_multicast_list (struct work_struct *work)
 		dprintk("%s: allmulti mode\n", dev->name);
 		priv->rx_mode = RX_MODE_ALL_MULTI;
 	} else if (!netdev_mc_empty(dev)) {
-		int mci;
 		struct dev_mc_list *mc;
 
 		dprintk("%s: set_mc_list, %d entries\n",
@@ -1149,11 +1148,8 @@ static void wq_set_multicast_list (struct work_struct *work)
 		priv->rx_mode = RX_MODE_MULTI;
 		priv->multi_num = 0;
 
-		for (mci = 0, mc=dev->mc_list;
-		     mci < netdev_mc_count(dev);
-		     mc = mc->next, mci++) {
+		netdev_for_each_mc_addr(mc, dev)
 			dvb_set_mc_filter(dev, mc);
-		}
 	}
 
 	netif_addr_unlock_bh(dev);
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index c48b0f4..7cd0933 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -160,39 +160,29 @@ static void mlx4_en_do_set_mac(struct work_struct *work)
 static void mlx4_en_clear_list(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct dev_mc_list *plist = priv->mc_list;
-	struct dev_mc_list *next;
 
-	while (plist) {
-		next = plist->next;
-		kfree(plist);
-		plist = next;
-	}
-	priv->mc_list = NULL;
+	kfree(priv->mc_addrs);
+	priv->mc_addrs_cnt = 0;
 }
 
 static void mlx4_en_cache_mclist(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct dev_mc_list *mclist;
-	struct dev_mc_list *tmp;
-	struct dev_mc_list *plist = NULL;
-
-	for (mclist = dev->mc_list; mclist; mclist = mclist->next) {
-		tmp = kmalloc(sizeof(struct dev_mc_list), GFP_ATOMIC);
-		if (!tmp) {
-			en_err(priv, "failed to allocate multicast list\n");
-			mlx4_en_clear_list(dev);
-			return;
-		}
-		memcpy(tmp, mclist, sizeof(struct dev_mc_list));
-		tmp->next = NULL;
-		if (plist)
-			plist->next = tmp;
-		else
-			priv->mc_list = tmp;
-		plist = tmp;
+	char *mc_addrs;
+	int mc_addrs_cnt = netdev_mc_count(dev);
+	int i;
+
+	mc_addrs = kmalloc(mc_addrs_cnt * ETH_ALEN, GFP_ATOMIC);
+	if (!mc_addrs) {
+		en_err(priv, "failed to allocate multicast list\n");
+		return;
 	}
+	i = 0;
+	netdev_for_each_mc_addr(mclist, dev)
+		memcpy(mc_addrs + i++ * ETH_ALEN, mclist->dmi_addr, ETH_ALEN);
+	priv->mc_addrs = mc_addrs;
+	priv->mc_addrs_cnt = mc_addrs_cnt;
 }
 
 
@@ -212,7 +202,6 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 						 mcast_task);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct net_device *dev = priv->dev;
-	struct dev_mc_list *mclist;
 	u64 mcast_addr = 0;
 	int err;
 
@@ -288,6 +277,8 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		if (err)
 			en_err(priv, "Failed disabling multicast filter\n");
 	} else {
+		int i;
+
 		err = mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0,
 					  0, MLX4_MCAST_DISABLE);
 		if (err)
@@ -302,8 +293,9 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		netif_tx_lock_bh(dev);
 		mlx4_en_cache_mclist(dev);
 		netif_tx_unlock_bh(dev);
-		for (mclist = priv->mc_list; mclist; mclist = mclist->next) {
-			mcast_addr = mlx4_en_mac_to_u64(mclist->dmi_addr);
+		for (i = 0; i < priv->mc_addrs_cnt; i++) {
+			mcast_addr =
+			      mlx4_en_mac_to_u64(priv->mc_addrs + i * ETH_ALEN);
 			mlx4_SET_MCAST_FLTR(mdev->dev, priv->port,
 					    mcast_addr, 0, MLX4_MCAST_CONFIG);
 		}
@@ -984,7 +976,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->flags = prof->flags;
 	priv->tx_ring_num = prof->tx_ring_num;
 	priv->rx_ring_num = prof->rx_ring_num;
-	priv->mc_list = NULL;
 	priv->mac_index = -1;
 	priv->msg_enable = MLX4_EN_MSG_LEVEL;
 	spin_lock_init(&priv->stats_lock);
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 82c3ebc..b55e46c 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -492,7 +492,8 @@ struct mlx4_en_priv {
 	struct mlx4_en_perf_stats pstats;
 	struct mlx4_en_pkt_stats pkstats;
 	struct mlx4_en_port_stats port_stats;
-	struct dev_mc_list *mc_list;
+	char *mc_addrs;
+	int mc_addrs_cnt;
 	struct mlx4_en_stat_out_mbox hw_stats;
 };
 
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 51fde6f..d5bef49 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -619,7 +619,7 @@ static void qeth_l2_set_multicast_list(struct net_device *dev)
 		return;
 	qeth_l2_del_all_mc(card);
 	spin_lock_bh(&card->mclock);
-	for (dm = dev->mc_list; dm; dm = dm->next)
+	netdev_for_each_mc_addr(dm, dev)
 		qeth_l2_add_mc(card, dm->da_addr, 0);
 
 	netdev_for_each_uc_addr(ha, dev)
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index b6234b7..326ab45 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -87,7 +87,7 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 		memcpy(__skb_put(skb, ETH_ALEN), dev->broadcast, ETH_ALEN);
 		r->len = htons(ETH_ALEN * 2);
 	} else {
-		struct dev_mc_list *dmi = dev->mc_list;
+		struct dev_mc_list *dmi;
 		int i, len = skb->len;
 
 		if (dev->flags & IFF_BROADCAST) {
@@ -97,12 +97,12 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 
 		/* FIXME: We should group addresses here. */
 
-		for (i = 0;
-		     i < netdev_mc_count(dev) && i < BNEP_MAX_MULTICAST_FILTERS;
-		     i++) {
+		i = 0;
+		netdev_for_each_mc_addr(dmi, dev) {
+			if (i == BNEP_MAX_MULTICAST_FILTERS)
+				break;
 			memcpy(__skb_put(skb, ETH_ALEN), dmi->dmi_addr, ETH_ALEN);
 			memcpy(__skb_put(skb, ETH_ALEN), dmi->dmi_addr, ETH_ALEN);
-			dmi = dmi->next;
 		}
 		r->len = htons(skb->len - len);
 	}
-- 
1.6.6

