From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3]: netdev: Do not use TX lock to protect address lists.
Date: Mon, 23 Jun 2008 20:54:23 -0700 (PDT)
Message-ID: <20080623.205423.267604223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41043
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754094AbYFXDyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 23:54:23 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 300B0C8C1B6
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 20:54:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


netdev: Do not use TX lock to protect address lists.

Now that we have a specific lock to protect the network
device unicast and multicast lists, remove extraneous
grabs of the TX lock in cases where the code only needs
address list protection.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    2 -
 drivers/media/dvb/dvb-core/dvb_net.c           |    6 +--
 drivers/net/bonding/bond_main.c                |   24 +++++----------
 drivers/net/sfc/efx.c                          |    6 +--
 drivers/net/tun.c                              |   12 ++-----
 drivers/net/wireless/libertas/main.c           |    6 +--
 net/core/dev.c                                 |   38 +++++++----------------
 net/core/dev_mcast.c                           |   32 ++++++--------------
 net/mac80211/main.c                            |   12 ++-----
 net/mac80211/mlme.c                            |    6 +--
 10 files changed, 46 insertions(+), 98 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 261ab71..cd2fb95 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -774,7 +774,6 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 	ipoib_mcast_stop_thread(dev, 0);
 
 	local_irq_save(flags);
-	netif_tx_lock(dev);
 	netif_addr_lock(dev);
 	spin_lock(&priv->lock);
 
@@ -853,7 +852,6 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 
 	spin_unlock(&priv->lock);
 	netif_addr_unlock(dev);
-	netif_tx_unlock(dev);
 	local_irq_restore(flags);
 
 	/* We have to cancel outside of the spinlock */
diff --git a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
index 809d18c..c2c0337 100644
--- a/drivers/media/dvb/dvb-core/dvb_net.c
+++ b/drivers/media/dvb/dvb-core/dvb_net.c
@@ -1133,8 +1133,7 @@ static void wq_set_multicast_list (struct work_struct *work)
 
 	dvb_net_feed_stop(dev);
 	priv->rx_mode = RX_MODE_UNI;
-	netif_tx_lock_bh(dev);
-	netif_addr_lock(dev);
+	netif_addr_lock_bh(dev);
 
 	if (dev->flags & IFF_PROMISC) {
 		dprintk("%s: promiscuous mode\n", dev->name);
@@ -1159,8 +1158,7 @@ static void wq_set_multicast_list (struct work_struct *work)
 		}
 	}
 
-	netif_addr_unlock(dev);
-	netif_tx_unlock_bh(dev);
+	netif_addr_unlock_bh(dev);
 	dvb_net_feed_start(dev);
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6601ffc..f92fa58 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1552,14 +1552,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			dev_set_allmulti(slave_dev, 1);
 		}
 
-		netif_tx_lock_bh(bond_dev);
-		netif_addr_lock(bond_dev);
+		netif_addr_lock_bh(bond_dev);
 		/* upload master's mc_list to new slave */
 		for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
 			dev_mc_add (slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		}
-		netif_addr_unlock(bond_dev);
-		netif_tx_unlock_bh(bond_dev);
+		netif_addr_unlock_bh(bond_dev);
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
@@ -1923,11 +1921,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 
 		/* flush master's mc_list from slave */
-		netif_tx_lock_bh(bond_dev);
-		netif_addr_lock(bond_dev);
+		netif_addr_lock_bh(bond_dev);
 		bond_mc_list_flush(bond_dev, slave_dev);
-		netif_addr_unlock(bond_dev);
-		netif_tx_unlock_bh(bond_dev);
+		netif_addr_unlock_bh(bond_dev);
 	}
 
 	netdev_set_master(slave_dev, NULL);
@@ -2048,11 +2044,9 @@ static int bond_release_all(struct net_device *bond_dev)
 			}
 
 			/* flush master's mc_list from slave */
-			netif_tx_lock_bh(bond_dev);
-			netif_addr_lock(bond_dev);
+			netif_addr_lock_bh(bond_dev);
 			bond_mc_list_flush(bond_dev, slave_dev);
-			netif_addr_unlock(bond_dev);
-			netif_tx_unlock_bh(bond_dev);
+			netif_addr_unlock_bh(bond_dev);
 		}
 
 		netdev_set_master(slave_dev, NULL);
@@ -4656,11 +4650,9 @@ static void bond_free_all(void)
 		struct net_device *bond_dev = bond->dev;
 
 		bond_work_cancel_all(bond);
-		netif_tx_lock_bh(bond_dev);
-		netif_addr_lock(bond_dev);
+		netif_addr_lock_bh(bond_dev);
 		bond_mc_list_destroy(bond);
-		netif_addr_unlock(bond_dev);
-		netif_tx_unlock_bh(bond_dev);
+		netif_addr_unlock_bh(bond_dev);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
 		bond_destroy(bond);
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index e1257e5..7b2015f 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -696,10 +696,8 @@ static void efx_stop_port(struct efx_nic *efx)
 
 	/* Serialise against efx_set_multicast_list() */
 	if (efx_dev_registered(efx)) {
-		netif_tx_lock_bh(efx->net_dev);
-		netif_addr_lock(efx->net_dev);
-		netif_addr_unlock(efx->net_dev);
-		netif_tx_unlock_bh(efx->net_dev);
+		netif_addr_lock_bh(efx->net_dev);
+		netif_addr_unlock_bh(efx->net_dev);
 	}
 }
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 87eb4e1..00238fd 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -757,11 +757,9 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 		/** Add the specified group to the character device's multicast filter
 		 * list. */
 		rtnl_lock();
-		netif_tx_lock_bh(tun->dev);
-		netif_addr_lock(tun->dev);
+		netif_addr_lock_bh(tun->dev);
 		add_multi(tun->chr_filter, ifr.ifr_hwaddr.sa_data);
-		netif_addr_unlock(tun->dev);
-		netif_tx_unlock_bh(tun->dev);
+		netif_addr_unlock_bh(tun->dev);
 		rtnl_unlock();
 
 		DBG(KERN_DEBUG "%s: add multi: %s\n",
@@ -772,11 +770,9 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 		/** Remove the specified group from the character device's multicast
 		 * filter list. */
 		rtnl_lock();
-		netif_tx_lock_bh(tun->dev);
-		netif_addr_lock(tun->dev);
+		netif_addr_lock_bh(tun->dev);
 		del_multi(tun->chr_filter, ifr.ifr_hwaddr.sa_data);
-		netif_addr_unlock(tun->dev);
-		netif_tx_unlock_bh(tun->dev);
+		netif_addr_unlock_bh(tun->dev);
 		rtnl_unlock();
 
 		DBG(KERN_DEBUG "%s: del multi: %s\n",
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 42e9b27..14d5d61 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -593,8 +593,7 @@ static int lbs_add_mcast_addrs(struct cmd_ds_mac_multicast_adr *cmd,
 	if ((dev->flags & (IFF_UP|IFF_MULTICAST)) != (IFF_UP|IFF_MULTICAST))
 		return nr_addrs;
 
-	netif_tx_lock_bh(dev);
-	netif_addr_lock(dev);
+	netif_addr_lock_bh(dev);
 	for (mc_list = dev->mc_list; mc_list; mc_list = mc_list->next) {
 		if (mac_in_list(cmd->maclist, nr_addrs, mc_list->dmi_addr)) {
 			lbs_deb_net("mcast address %s:%s skipped\n", dev->name,
@@ -609,8 +608,7 @@ static int lbs_add_mcast_addrs(struct cmd_ds_mac_multicast_adr *cmd,
 			    print_mac(mac, mc_list->dmi_addr));
 		i++;
 	}
-	netif_addr_unlock(dev);
-	netif_tx_unlock_bh(dev);
+	netif_addr_unlock_bh(dev);
 	if (mc_list)
 		return -EOVERFLOW;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 5f43ae0..1c54e39 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2942,11 +2942,9 @@ void __dev_set_rx_mode(struct net_device *dev)
 
 void dev_set_rx_mode(struct net_device *dev)
 {
-	netif_tx_lock_bh(dev);
-	netif_addr_lock(dev);
+	netif_addr_lock_bh(dev);
 	__dev_set_rx_mode(dev);
-	netif_addr_unlock(dev);
-	netif_tx_unlock_bh(dev);
+	netif_addr_unlock_bh(dev);
 }
 
 int __dev_addr_delete(struct dev_addr_list **list, int *count,
@@ -3024,13 +3022,11 @@ int dev_unicast_delete(struct net_device *dev, void *addr, int alen)
 
 	ASSERT_RTNL();
 
-	netif_tx_lock_bh(dev);
-	netif_addr_lock(dev);
+	netif_addr_lock_bh(dev);
 	err = __dev_addr_delete(&dev->uc_list, &dev->uc_count, addr, alen, 0);
 	if (!err)
 		__dev_set_rx_mode(dev);
-	netif_addr_unlock(dev);
-	netif_tx_unlock_bh(dev);
+	netif_addr_unlock_bh(dev);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_delete);
@@ -3052,13 +3048,11 @@ int dev_unicast_add(struct net_device *dev, void *addr, int alen)
 
 	ASSERT_RTNL();
 
-	netif_tx_lock_bh(dev);
-	netif_addr_lock(dev);
+	netif_addr_lock_bh(dev);
 	err = __dev_addr_add(&dev->uc_list, &dev->uc_count, addr, alen, 0);
 	if (!err)
 		__dev_set_rx_mode(dev);
-	netif_addr_unlock(dev);
-	netif_tx_unlock_bh(dev);
+	netif_addr_unlock_bh(dev);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_add);
@@ -3125,14 +3119,12 @@ int dev_unicast_sync(struct net_device *to, struct net_device *from)
 {
 	int err = 0;
 
-	netif_tx_lock_bh(to);
-	netif_addr_lock(to);
+	netif_addr_lock_bh(to);
 	err = __dev_addr_sync(&to->uc_list, &to->uc_count,
 			      &from->uc_list, &from->uc_count);
 	if (!err)
 		__dev_set_rx_mode(to);
-	netif_addr_unlock(to);
-	netif_tx_unlock_bh(to);
+	netif_addr_unlock_bh(to);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_sync);
@@ -3148,9 +3140,7 @@ EXPORT_SYMBOL(dev_unicast_sync);
  */
 void dev_unicast_unsync(struct net_device *to, struct net_device *from)
 {
-	netif_tx_lock_bh(from);
-	netif_addr_lock(from);
-	netif_tx_lock_bh(to);
+	netif_addr_lock_bh(from);
 	netif_addr_lock(to);
 
 	__dev_addr_unsync(&to->uc_list, &to->uc_count,
@@ -3158,9 +3148,7 @@ void dev_unicast_unsync(struct net_device *to, struct net_device *from)
 	__dev_set_rx_mode(to);
 
 	netif_addr_unlock(to);
-	netif_tx_unlock_bh(to);
-	netif_addr_unlock(from);
-	netif_tx_unlock_bh(from);
+	netif_addr_unlock_bh(from);
 }
 EXPORT_SYMBOL(dev_unicast_unsync);
 
@@ -3180,8 +3168,7 @@ static void __dev_addr_discard(struct dev_addr_list **list)
 
 static void dev_addr_discard(struct net_device *dev)
 {
-	netif_tx_lock_bh(dev);
-	netif_addr_lock(dev);
+	netif_addr_lock_bh(dev);
 
 	__dev_addr_discard(&dev->uc_list);
 	dev->uc_count = 0;
@@ -3189,8 +3176,7 @@ static void dev_addr_discard(struct net_device *dev)
 	__dev_addr_discard(&dev->mc_list);
 	dev->mc_count = 0;
 
-	netif_addr_unlock(dev);
-	netif_tx_unlock_bh(dev);
+	netif_addr_unlock_bh(dev);
 }
 
 unsigned dev_get_flags(const struct net_device *dev)
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index b6b2a12..5402b3b 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -72,8 +72,7 @@ int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 {
 	int err;
 
-	netif_tx_lock_bh(dev);
-	netif_addr_lock(dev);
+	netif_addr_lock_bh(dev);
 	err = __dev_addr_delete(&dev->mc_list, &dev->mc_count,
 				addr, alen, glbl);
 	if (!err) {
@@ -84,8 +83,7 @@ int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 
 		__dev_set_rx_mode(dev);
 	}
-	netif_addr_unlock(dev);
-	netif_tx_unlock_bh(dev);
+	netif_addr_unlock_bh(dev);
 	return err;
 }
 
@@ -97,13 +95,11 @@ int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
 {
 	int err;
 
-	netif_tx_lock_bh(dev);
-	netif_addr_lock(dev);
+	netif_addr_lock_bh(dev);
 	err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
 	if (!err)
 		__dev_set_rx_mode(dev);
-	netif_addr_unlock(dev);
-	netif_tx_unlock_bh(dev);
+	netif_addr_unlock_bh(dev);
 	return err;
 }
 
@@ -123,14 +119,12 @@ int dev_mc_sync(struct net_device *to, struct net_device *from)
 {
 	int err = 0;
 
-	netif_tx_lock_bh(to);
-	netif_addr_lock(to);
+	netif_addr_lock_bh(to);
 	err = __dev_addr_sync(&to->mc_list, &to->mc_count,
 			      &from->mc_list, &from->mc_count);
 	if (!err)
 		__dev_set_rx_mode(to);
-	netif_addr_unlock(to);
-	netif_tx_unlock_bh(to);
+	netif_addr_unlock_bh(to);
 
 	return err;
 }
@@ -149,9 +143,7 @@ EXPORT_SYMBOL(dev_mc_sync);
  */
 void dev_mc_unsync(struct net_device *to, struct net_device *from)
 {
-	netif_tx_lock_bh(from);
-	netif_addr_lock(from);
-	netif_tx_lock_bh(to);
+	netif_addr_lock_bh(from);
 	netif_addr_lock(to);
 
 	__dev_addr_unsync(&to->mc_list, &to->mc_count,
@@ -159,9 +151,7 @@ void dev_mc_unsync(struct net_device *to, struct net_device *from)
 	__dev_set_rx_mode(to);
 
 	netif_addr_unlock(to);
-	netif_tx_unlock_bh(to);
-	netif_addr_unlock(from);
-	netif_tx_unlock_bh(from);
+	netif_addr_unlock_bh(from);
 }
 EXPORT_SYMBOL(dev_mc_unsync);
 
@@ -174,8 +164,7 @@ static int dev_mc_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN)
 		return 0;
 
-	netif_tx_lock_bh(dev);
-	netif_addr_lock(dev);
+	netif_addr_lock_bh(dev);
 	for (m = dev->mc_list; m; m = m->next) {
 		int i;
 
@@ -187,8 +176,7 @@ static int dev_mc_seq_show(struct seq_file *seq, void *v)
 
 		seq_putc(seq, '\n');
 	}
-	netif_addr_unlock(dev);
-	netif_tx_unlock_bh(dev);
+	netif_addr_unlock_bh(dev);
 	return 0;
 }
 
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 59fec7e..3041924 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -314,11 +314,9 @@ static int ieee80211_open(struct net_device *dev)
 		if (sdata->u.mntr_flags & MONITOR_FLAG_OTHER_BSS)
 			local->fif_other_bss++;
 
-		netif_tx_lock_bh(local->mdev);
-		netif_addr_lock(local->mdev);
+		netif_addr_lock_bh(local->mdev);
 		ieee80211_configure_filter(local);
-		netif_addr_unlock(local->mdev);
-		netif_tx_unlock_bh(local->mdev);
+		netif_addr_unlock_bh(local->mdev);
 		break;
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS:
@@ -510,11 +508,9 @@ static int ieee80211_stop(struct net_device *dev)
 		if (sdata->u.mntr_flags & MONITOR_FLAG_OTHER_BSS)
 			local->fif_other_bss--;
 
-		netif_tx_lock_bh(local->mdev);
-		netif_addr_lock(local->mdev);
+		netif_addr_lock_bh(local->mdev);
 		ieee80211_configure_filter(local);
-		netif_addr_unlock(local->mdev);
-		netif_tx_unlock_bh(local->mdev);
+		netif_addr_unlock_bh(local->mdev);
 		break;
 	case IEEE80211_IF_TYPE_MESH_POINT:
 	case IEEE80211_IF_TYPE_STA:
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 92d7b46..4817330 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -4047,16 +4047,14 @@ static int ieee80211_sta_start_scan(struct net_device *dev,
 	local->scan_band = IEEE80211_BAND_2GHZ;
 	local->scan_dev = dev;
 
-	netif_tx_lock_bh(local->mdev);
-	netif_addr_lock(local->mdev);
+	netif_addr_lock_bh(local->mdev);
 	local->filter_flags |= FIF_BCN_PRBRESP_PROMISC;
 	local->ops->configure_filter(local_to_hw(local),
 				     FIF_BCN_PRBRESP_PROMISC,
 				     &local->filter_flags,
 				     local->mdev->mc_count,
 				     local->mdev->mc_list);
-	netif_addr_unlock(local->mdev);
-	netif_tx_unlock_bh(local->mdev);
+	netif_addr_unlock_bh(local->mdev);
 
 	/* TODO: start scan as soon as all nullfunc frames are ACKed */
 	queue_delayed_work(local->hw.workqueue, &local->scan_work,
-- 
1.5.6

