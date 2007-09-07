From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] mac80211: fix virtual interface locking
Date: Fri, 07 Sep 2007 16:38:41 +0200
Message-ID: <1189175921.28781.173.camel@johannes.berg>
References: <E1ITGb2-0006Be-00@gondolin.me.apana.org.au>
	 <1189085815.28781.78.camel@johannes.berg>
	 <20070906154612.GD8030@linux.vnet.ibm.com>
	 <1189171635.28781.134.camel@johannes.berg>
	 <20070907142538.GC8864@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, satyam@infradead.org,
	flo@rfc822.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	michal.k.k.piotrowski@gmail.com,
	ipw3945-devel@lists.sourceforge.net, yi.zhu@intel.com,
	flamingice@sourmilk.net,
	"John W. Linville" <linville@tuxdriver.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:34411 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965352AbXIGOha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 10:37:30 -0400
In-Reply-To: <20070907142538.GC8864@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Lohoff noticed a bug in mac80211: when bringing the
master interface down while other virtual interfaces are up
we call dev_close() under a spinlock which is not allowed.
This patch removes the sub_if_lock used by mac80211 in favour
of using an RCU list. All list manipulations are already done
under rtnl so are well protected against each other, and the
read-side locks we took in the RX and TX code are already in
RCU read-side critical sections.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Cc: Florian Lohoff <flo@rfc822.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: Satyam Sharma <satyam@infradead.org>

---
If you want to test this you'll need to get the other pending patches,
as John is at KS he isn't pushing to Dave who is at KS too anyhow. Grab
from
http://johannes.sipsolutions.net/patches/net-2.6.24/all/2007-09-06-13:43/ patches 002-011, they are slated to go into net-2.6.24 if timing works out. I'll backport this fix to -stable when we actually get around to verifying it.

 net/mac80211/ieee80211.c       |  100 ++++++++++++++++++++---------------------
 net/mac80211/ieee80211_i.h     |    5 --
 net/mac80211/ieee80211_iface.c |   31 +++++-------
 net/mac80211/ieee80211_sta.c   |   12 ++--
 net/mac80211/rx.c              |    9 +--
 net/mac80211/tx.c              |   10 ++--
 6 files changed, 84 insertions(+), 83 deletions(-)

--- wireless-dev.orig/net/mac80211/ieee80211.c	2007-09-07 10:52:12.604441281 +0200
+++ wireless-dev/net/mac80211/ieee80211.c	2007-09-07 16:30:34.044429746 +0200
@@ -88,24 +88,31 @@ static struct dev_mc_list *ieee80211_get
 		return NULL;
 	}
 
-	/* start of iteration, both unassigned */
-	if (!mcd->cur && !mcd->sdata) {
-		mcd->sdata = list_entry(local->sub_if_list.next,
-					struct ieee80211_sub_if_data, list);
-		mcd->cur = mcd->sdata->dev->mc_list;
-	}
+	/*
+	 * Prepare for iteration if not done already.
+	 */
+	list_prepare_entry(mcd->sdata, &local->interfaces, list);
 
-	if (mcd->cur)
+	if (mcd->cur) {
+		/*
+		 * Iterate over the multicast addresses in
+		 * the current device (mcd->sdata).
+		 */
 		mcd->cur = mcd->cur->next;
+	}
 
-	while (!mcd->cur) {
-		/* reached end of interface list? */
-		if (mcd->sdata->list.next == &local->sub_if_list)
-			break;
-		/* otherwise try next interface */
-		mcd->sdata = list_entry(mcd->sdata->list.next,
-					struct ieee80211_sub_if_data, list);
-		mcd->cur = mcd->sdata->dev->mc_list;
+	if (!mcd->cur) {
+		/*
+		 * Iterate over the devices until finding one (the
+		 * first or the next) with multicast addresses.
+		 */
+		list_for_each_entry_continue_rcu(mcd->sdata,
+						 &local->interfaces,
+						 list) {
+			mcd->cur = mcd->sdata->dev->mc_list;
+			if (mcd->cur)
+				break;
+		}
 	}
 
 	return mcd->cur;
@@ -145,9 +152,10 @@ static void ieee80211_configure_filter(s
 
 	/*
 	 * We can iterate through the device list for the multicast
-	 * address list so need to lock it.
+	 * address list so need to be in a RCU read-side section,
+	 * the RTNL isn't held in this function.
 	 */
-	read_lock(&local->sub_if_lock);
+	rcu_read_lock();
 
 	/* be a bit nasty */
 	new_flags |= (1<<31);
@@ -163,7 +171,7 @@ static void ieee80211_configure_filter(s
 	WARN_ON(mcd.cur);
 
 	local->filter_flags = new_flags & ~(1<<31);
-	read_unlock(&local->sub_if_lock);
+	rcu_read_unlock();
 
 	netif_tx_unlock(local->mdev);
 }
@@ -176,14 +184,13 @@ static int ieee80211_master_open(struct 
 	struct ieee80211_sub_if_data *sdata;
 	int res = -EOPNOTSUPP;
 
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
+	/* we hold the RTNL here so can safely walk the list */
+	list_for_each_entry(sdata, &local->interfaces, list) {
 		if (sdata->dev != dev && netif_running(sdata->dev)) {
 			res = 0;
 			break;
 		}
 	}
-	read_unlock(&local->sub_if_lock);
 	return res;
 }
 
@@ -192,11 +199,10 @@ static int ieee80211_master_stop(struct 
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata;
 
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(sdata, &local->sub_if_list, list)
+	/* we hold the RTNL here so can safely walk the list */
+	list_for_each_entry(sdata, &local->interfaces, list)
 		if (sdata->dev != dev && netif_running(sdata->dev))
 			dev_close(sdata->dev);
-	read_unlock(&local->sub_if_lock);
 
 	return 0;
 }
@@ -395,8 +401,8 @@ static int ieee80211_open(struct net_dev
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(nsdata, &local->sub_if_list, list) {
+	/* we hold the RTNL here so can safely walk the list */
+	list_for_each_entry(nsdata, &local->interfaces, list) {
 		struct net_device *ndev = nsdata->dev;
 
 		if (ndev != dev && ndev != local->mdev && netif_running(ndev) &&
@@ -405,10 +411,8 @@ static int ieee80211_open(struct net_dev
 			 * check whether it may have the same address
 			 */
 			if (!identical_mac_addr_allowed(sdata->type,
-							nsdata->type)) {
-				read_unlock(&local->sub_if_lock);
+							nsdata->type))
 				return -ENOTUNIQ;
-			}
 
 			/*
 			 * can only add VLANs to enabled APs
@@ -419,7 +423,6 @@ static int ieee80211_open(struct net_dev
 				sdata->u.vlan.ap = nsdata;
 		}
 	}
-	read_unlock(&local->sub_if_lock);
 
 	switch (sdata->type) {
 	case IEEE80211_IF_TYPE_WDS:
@@ -541,14 +544,13 @@ static int ieee80211_stop(struct net_dev
 		del_timer_sync(&sdata->u.sta.timer);
 		del_timer_sync(&sdata->u.sta.admit_timer);
 		/*
-		 * Holding the sub_if_lock for writing here blocks
-		 * out the receive path and makes sure it's not
-		 * currently processing a packet that may get
-		 * added to the queue.
+		 * When we get here, the interface is marked down.
+		 * Call synchronize_rcu() to wait for the RX path
+		 * should it be using the interface and enqueuing
+		 * frames at this very time on another CPU.
 		 */
-		write_lock_bh(&local->sub_if_lock);
+		synchronize_rcu();
 		skb_queue_purge(&sdata->u.sta.skb_queue);
-		write_unlock_bh(&local->sub_if_lock);
 
 		if (!local->ops->hw_scan &&
 		    local->scan_dev == sdata->dev) {
@@ -1101,9 +1103,9 @@ void ieee80211_tx_status(struct ieee8021
 
 	rthdr->data_retries = status->retry_count;
 
-	read_lock(&local->sub_if_lock);
+	rcu_read_lock();
 	monitors = local->monitors;
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 		/*
 		 * Using the monitors counter is possibly racy, but
 		 * if the value is wrong we simply either clone the skb
@@ -1119,7 +1121,7 @@ void ieee80211_tx_status(struct ieee8021
 				continue;
 			monitors--;
 			if (monitors)
-				skb2 = skb_clone(skb, GFP_KERNEL);
+				skb2 = skb_clone(skb, GFP_ATOMIC);
 			else
 				skb2 = NULL;
 			skb->dev = sdata->dev;
@@ -1134,7 +1136,7 @@ void ieee80211_tx_status(struct ieee8021
 		}
 	}
  out:
-	read_unlock(&local->sub_if_lock);
+	rcu_read_unlock();
 	if (skb)
 		dev_kfree_skb(skb);
 }
@@ -1222,8 +1224,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 
 	INIT_LIST_HEAD(&local->modes_list);
 
-	rwlock_init(&local->sub_if_lock);
-	INIT_LIST_HEAD(&local->sub_if_list);
+	INIT_LIST_HEAD(&local->interfaces);
 
 	INIT_DELAYED_WORK(&local->scan_work, ieee80211_sta_scan_work);
 	ieee80211_rx_bss_list_init(mdev);
@@ -1242,7 +1243,8 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 	sdata->u.ap.force_unicast_rateidx = -1;
 	sdata->u.ap.max_ratectrl_rateidx = -1;
 	ieee80211_if_sdata_init(sdata);
-	list_add_tail(&sdata->list, &local->sub_if_list);
+	/* no RCU needed since we're still during init phase */
+	list_add_tail(&sdata->list, &local->interfaces);
 
 	tasklet_init(&local->tx_pending_tasklet, ieee80211_tx_pending,
 		     (unsigned long)local);
@@ -1401,7 +1403,6 @@ void ieee80211_unregister_hw(struct ieee
 {
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_sub_if_data *sdata, *tmp;
-	struct list_head tmp_list;
 	int i;
 
 	tasklet_kill(&local->tx_pending_tasklet);
@@ -1415,11 +1416,12 @@ void ieee80211_unregister_hw(struct ieee
 	if (local->apdev)
 		ieee80211_if_del_mgmt(local);
 
-	write_lock_bh(&local->sub_if_lock);
-	list_replace_init(&local->sub_if_list, &tmp_list);
-	write_unlock_bh(&local->sub_if_lock);
-
-	list_for_each_entry_safe(sdata, tmp, &tmp_list, list)
+	/*
+	 * At this point, interface list manipulations are fine
+	 * because the driver cannot be handing us frames any
+	 * more and the tasklet is killed.
+	 */
+	list_for_each_entry_safe(sdata, tmp, &local->interfaces, list)
 		__ieee80211_if_del(local, sdata);
 
 	rtnl_unlock();
--- wireless-dev.orig/net/mac80211/ieee80211_i.h	2007-09-07 10:52:12.604441281 +0200
+++ wireless-dev/net/mac80211/ieee80211_i.h	2007-09-07 16:30:33.974429746 +0200
@@ -548,9 +548,8 @@ struct ieee80211_local {
 	ieee80211_rx_handler *rx_handlers;
 	ieee80211_tx_handler *tx_handlers;
 
-	rwlock_t sub_if_lock; /* Protects sub_if_list. Cannot be taken under
-			       * sta_bss_lock or sta_lock. */
-	struct list_head sub_if_list;
+	struct list_head interfaces;
+
 	int sta_scanning;
 	int scan_channel_idx;
 	enum { SCAN_SET_CHANNEL, SCAN_SEND_PROBE } scan_state;
--- wireless-dev.orig/net/mac80211/ieee80211_iface.c	2007-09-07 10:52:12.604441281 +0200
+++ wireless-dev/net/mac80211/ieee80211_iface.c	2007-09-07 16:30:34.244429746 +0200
@@ -79,16 +79,15 @@ int ieee80211_if_add(struct net_device *
 	ieee80211_debugfs_add_netdev(sdata);
 	ieee80211_if_set_type(ndev, type);
 
-	write_lock_bh(&local->sub_if_lock);
+	/* we're under RTNL so all this is fine */
 	if (unlikely(local->reg_state == IEEE80211_DEV_UNREGISTERED)) {
-		write_unlock_bh(&local->sub_if_lock);
 		__ieee80211_if_del(local, sdata);
 		return -ENODEV;
 	}
-	list_add(&sdata->list, &local->sub_if_list);
+	list_add_tail_rcu(&sdata->list, &local->interfaces);
+
 	if (new_dev)
 		*new_dev = ndev;
-	write_unlock_bh(&local->sub_if_lock);
 
 	return 0;
 
@@ -242,22 +241,22 @@ void ieee80211_if_reinit(struct net_devi
 		/* Remove all virtual interfaces that use this BSS
 		 * as their sdata->bss */
 		struct ieee80211_sub_if_data *tsdata, *n;
-		LIST_HEAD(tmp_list);
 
-		write_lock_bh(&local->sub_if_lock);
-		list_for_each_entry_safe(tsdata, n, &local->sub_if_list, list) {
+		list_for_each_entry_safe(tsdata, n, &local->interfaces, list) {
 			if (tsdata != sdata && tsdata->bss == &sdata->u.ap) {
 				printk(KERN_DEBUG "%s: removing virtual "
 				       "interface %s because its BSS interface"
 				       " is being removed\n",
 				       sdata->dev->name, tsdata->dev->name);
-				list_move_tail(&tsdata->list, &tmp_list);
+				list_del_rcu(&tsdata->list);
+				/*
+				 * We have lots of time and can afford
+				 * to sync for each interface
+				 */
+				synchronize_rcu();
+				__ieee80211_if_del(local, tsdata);
 			}
 		}
-		write_unlock_bh(&local->sub_if_lock);
-
-		list_for_each_entry_safe(tsdata, n, &tmp_list, list)
-			__ieee80211_if_del(local, tsdata);
 
 		kfree(sdata->u.ap.beacon_head);
 		kfree(sdata->u.ap.beacon_tail);
@@ -334,18 +333,16 @@ int ieee80211_if_remove(struct net_devic
 
 	ASSERT_RTNL();
 
-	write_lock_bh(&local->sub_if_lock);
-	list_for_each_entry_safe(sdata, n, &local->sub_if_list, list) {
+	list_for_each_entry_safe(sdata, n, &local->interfaces, list) {
 		if ((sdata->type == id || id == -1) &&
 		    strcmp(name, sdata->dev->name) == 0 &&
 		    sdata->dev != local->mdev) {
-			list_del(&sdata->list);
-			write_unlock_bh(&local->sub_if_lock);
+			list_del_rcu(&sdata->list);
+			synchronize_rcu();
 			__ieee80211_if_del(local, sdata);
 			return 0;
 		}
 	}
-	write_unlock_bh(&local->sub_if_lock);
 	return -ENODEV;
 }
 
--- wireless-dev.orig/net/mac80211/ieee80211_sta.c	2007-09-07 10:52:12.634441281 +0200
+++ wireless-dev/net/mac80211/ieee80211_sta.c	2007-09-07 10:57:23.574441281 +0200
@@ -3597,8 +3597,8 @@ void ieee80211_scan_completed(struct iee
 	memset(&wrqu, 0, sizeof(wrqu));
 	wireless_send_event(dev, SIOCGIWSCAN, &wrqu, NULL);
 
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 
 		/* No need to wake the master device. */
 		if (sdata->dev == local->mdev)
@@ -3612,7 +3612,7 @@ void ieee80211_scan_completed(struct iee
 
 		netif_wake_queue(sdata->dev);
 	}
-	read_unlock(&local->sub_if_lock);
+	rcu_read_unlock();
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
@@ -3749,8 +3749,8 @@ static int ieee80211_sta_start_scan(stru
 
 	local->sta_scanning = 1;
 
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 
 		/* Don't stop the master interface, otherwise we can't transmit
 		 * probes! */
@@ -3762,7 +3762,7 @@ static int ieee80211_sta_start_scan(stru
 		    (sdata->u.sta.flags & IEEE80211_STA_ASSOCIATED))
 			ieee80211_send_nullfunc(local, sdata, 1);
 	}
-	read_unlock(&local->sub_if_lock);
+	rcu_read_unlock();
 
 	if (ssid) {
 		local->scan_ssid_len = ssid_len;
--- wireless-dev.orig/net/mac80211/rx.c	2007-09-07 10:52:12.654441281 +0200
+++ wireless-dev/net/mac80211/rx.c	2007-09-07 16:30:34.144429746 +0200
@@ -1522,8 +1522,9 @@ void __ieee80211_rx(struct ieee80211_hw 
 	}
 
 	/*
-	 * key references are protected using RCU and this requires that
-	 * we are in a read-site RCU section during receive processing
+	 * key references and virtual interfaces are protected using RCU
+	 * and this requires that we are in a read-side RCU section during
+	 * receive processing
 	 */
 	rcu_read_lock();
 
@@ -1578,8 +1579,7 @@ void __ieee80211_rx(struct ieee80211_hw 
 
 	bssid = ieee80211_get_bssid(hdr, skb->len - radiotap_len);
 
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 		rx.flags |= IEEE80211_TXRXD_RXRA_MATCH;
 
 		if (!netif_running(sdata->dev))
@@ -1632,7 +1632,6 @@ void __ieee80211_rx(struct ieee80211_hw 
 					     &rx, sta);
 	} else
 		dev_kfree_skb(skb);
-	read_unlock(&local->sub_if_lock);
 
  end:
 	rcu_read_unlock();
--- wireless-dev.orig/net/mac80211/tx.c	2007-09-07 10:52:12.674441281 +0200
+++ wireless-dev/net/mac80211/tx.c	2007-09-07 12:20:51.174437343 +0200
@@ -291,8 +291,12 @@ static void purge_old_ps_buffers(struct 
 	struct ieee80211_sub_if_data *sdata;
 	struct sta_info *sta;
 
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
+	/*
+	 * virtual interfaces are protected by RCU
+	 */
+	rcu_read_lock();
+
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 		struct ieee80211_if_ap *ap;
 		if (sdata->dev == local->mdev ||
 		    sdata->type != IEEE80211_IF_TYPE_AP)
@@ -305,7 +309,7 @@ static void purge_old_ps_buffers(struct 
 		}
 		total += skb_queue_len(&ap->ps_bc_buf);
 	}
-	read_unlock(&local->sub_if_lock);
+	rcu_read_unlock();
 
 	read_lock_bh(&local->sta_lock);
 	list_for_each_entry(sta, &local->sta_list, list) {


