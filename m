From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Thu, 06 Sep 2007 15:36:55 +0200
Message-ID: <1189085815.28781.78.camel@johannes.berg>
References: <E1ITGb2-0006Be-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, flo-BCn6idZOOBwdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1ITGb2-0006Be-00-XQvu0L+U/CjiRBuR/1fSEKKkPtS2pBon@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-09-06 at 20:36 +0800, Herbert Xu wrote:

> Yeah I think they're all under RTNL too.  So you don't need to
> take the lock here at all since you should already have the RTNL.

Ok, this patch gets rid of the lock. I'd appreciate if you could give it
a quick look for obvious RCU abuse as I haven't tested it. It also
doesn't apply against net-2.6.24 because I based it after the patches I
have queued with John for net-2.6.24.

johannes

--- netdev-2.6.orig/net/mac80211/ieee80211.c	2007-09-06 15:35:23.324447686 +0200
+++ netdev-2.6/net/mac80211/ieee80211.c	2007-09-06 15:35:23.394447686 +0200
@@ -90,8 +90,9 @@ static struct dev_mc_list *ieee80211_get
 
 	/* start of iteration, both unassigned */
 	if (!mcd->cur && !mcd->sdata) {
-		mcd->sdata = list_entry(local->sub_if_list.next,
-					struct ieee80211_sub_if_data, list);
+		mcd->sdata = list_entry(
+				rcu_dereference(local->interfaces.next),
+				struct ieee80211_sub_if_data, list);
 		mcd->cur = mcd->sdata->dev->mc_list;
 	}
 
@@ -100,10 +101,11 @@ static struct dev_mc_list *ieee80211_get
 
 	while (!mcd->cur) {
 		/* reached end of interface list? */
-		if (mcd->sdata->list.next == &local->sub_if_list)
+		if (rcu_dereference(mcd->sdata->list.next) ==
+		    &local->interfaces)
 			break;
 		/* otherwise try next interface */
-		mcd->sdata = list_entry(mcd->sdata->list.next,
+		mcd->sdata = list_entry(rcu_dereference(mcd->sdata->list.next),
 					struct ieee80211_sub_if_data, list);
 		mcd->cur = mcd->sdata->dev->mc_list;
 	}
@@ -145,9 +147,10 @@ static void ieee80211_configure_filter(s
 
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
@@ -163,7 +166,7 @@ static void ieee80211_configure_filter(s
 	WARN_ON(mcd.cur);
 
 	local->filter_flags = new_flags & ~(1<<31);
-	read_unlock(&local->sub_if_lock);
+	rcu_read_unlock();
 
 	netif_tx_unlock(local->mdev);
 }
@@ -176,14 +179,13 @@ static int ieee80211_master_open(struct 
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
 
@@ -192,11 +194,10 @@ static int ieee80211_master_stop(struct 
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
@@ -430,8 +431,8 @@ static int ieee80211_open(struct net_dev
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(nsdata, &local->sub_if_list, list) {
+	/* we hold the RTNL here so can safely walk the list */
+	list_for_each_entry(nsdata, &local->interfaces, list) {
 		struct net_device *ndev = nsdata->dev;
 
 		if (ndev != dev && ndev != local->mdev && netif_running(ndev) &&
@@ -440,10 +441,8 @@ static int ieee80211_open(struct net_dev
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
@@ -454,7 +453,6 @@ static int ieee80211_open(struct net_dev
 				sdata->u.vlan.ap = nsdata;
 		}
 	}
-	read_unlock(&local->sub_if_lock);
 
 	switch (sdata->type) {
 	case IEEE80211_IF_TYPE_WDS:
@@ -575,14 +573,13 @@ static int ieee80211_stop(struct net_dev
 		sdata->u.sta.state = IEEE80211_DISABLED;
 		del_timer_sync(&sdata->u.sta.timer);
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
@@ -1134,9 +1131,9 @@ void ieee80211_tx_status(struct ieee8021
 
 	rthdr->data_retries = status->retry_count;
 
-	read_lock(&local->sub_if_lock);
+	rcu_read_lock();
 	monitors = local->monitors;
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 		/*
 		 * Using the monitors counter is possibly racy, but
 		 * if the value is wrong we simply either clone the skb
@@ -1152,7 +1149,7 @@ void ieee80211_tx_status(struct ieee8021
 				continue;
 			monitors--;
 			if (monitors)
-				skb2 = skb_clone(skb, GFP_KERNEL);
+				skb2 = skb_clone(skb, GFP_ATOMIC);
 			else
 				skb2 = NULL;
 			skb->dev = sdata->dev;
@@ -1167,7 +1164,7 @@ void ieee80211_tx_status(struct ieee8021
 		}
 	}
  out:
-	read_unlock(&local->sub_if_lock);
+	rcu_read_unlock();
 	if (skb)
 		dev_kfree_skb(skb);
 }
@@ -1255,8 +1252,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 
 	INIT_LIST_HEAD(&local->modes_list);
 
-	rwlock_init(&local->sub_if_lock);
-	INIT_LIST_HEAD(&local->sub_if_list);
+	INIT_LIST_HEAD(&local->interfaces);
 
 	INIT_DELAYED_WORK(&local->scan_work, ieee80211_sta_scan_work);
 	ieee80211_rx_bss_list_init(mdev);
@@ -1275,7 +1271,8 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 	sdata->u.ap.force_unicast_rateidx = -1;
 	sdata->u.ap.max_ratectrl_rateidx = -1;
 	ieee80211_if_sdata_init(sdata);
-	list_add_tail(&sdata->list, &local->sub_if_list);
+	/* no RCU needed since we're still during init phase */
+	list_add_tail(&sdata->list, &local->interfaces);
 
 	tasklet_init(&local->tx_pending_tasklet, ieee80211_tx_pending,
 		     (unsigned long)local);
@@ -1434,7 +1431,6 @@ void ieee80211_unregister_hw(struct ieee
 {
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_sub_if_data *sdata, *tmp;
-	struct list_head tmp_list;
 	int i;
 
 	tasklet_kill(&local->tx_pending_tasklet);
@@ -1448,11 +1444,12 @@ void ieee80211_unregister_hw(struct ieee
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
--- netdev-2.6.orig/net/mac80211/ieee80211_i.h	2007-09-06 15:35:23.334447686 +0200
+++ netdev-2.6/net/mac80211/ieee80211_i.h	2007-09-06 15:35:23.404447686 +0200
@@ -481,9 +481,8 @@ struct ieee80211_local {
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
--- netdev-2.6.orig/net/mac80211/ieee80211_iface.c	2007-09-06 15:35:23.334447686 +0200
+++ netdev-2.6/net/mac80211/ieee80211_iface.c	2007-09-06 15:35:23.404447686 +0200
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
 
@@ -226,22 +225,22 @@ void ieee80211_if_reinit(struct net_devi
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
@@ -318,18 +317,16 @@ int ieee80211_if_remove(struct net_devic
 
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
 
--- netdev-2.6.orig/net/mac80211/ieee80211_sta.c	2007-09-06 15:35:23.224447686 +0200
+++ netdev-2.6/net/mac80211/ieee80211_sta.c	2007-09-06 15:35:23.414447686 +0200
@@ -2659,8 +2659,8 @@ void ieee80211_scan_completed(struct iee
 	memset(&wrqu, 0, sizeof(wrqu));
 	wireless_send_event(dev, SIOCGIWSCAN, &wrqu, NULL);
 
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 
 		/* No need to wake the master device. */
 		if (sdata->dev == local->mdev)
@@ -2674,7 +2674,7 @@ void ieee80211_scan_completed(struct iee
 
 		netif_wake_queue(sdata->dev);
 	}
-	read_unlock(&local->sub_if_lock);
+	rcu_read_unlock();
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
@@ -2811,8 +2811,8 @@ static int ieee80211_sta_start_scan(stru
 
 	local->sta_scanning = 1;
 
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 
 		/* Don't stop the master interface, otherwise we can't transmit
 		 * probes! */
@@ -2824,7 +2824,7 @@ static int ieee80211_sta_start_scan(stru
 		    (sdata->u.sta.flags & IEEE80211_STA_ASSOCIATED))
 			ieee80211_send_nullfunc(local, sdata, 1);
 	}
-	read_unlock(&local->sub_if_lock);
+	rcu_read_unlock();
 
 	if (ssid) {
 		local->scan_ssid_len = ssid_len;
--- netdev-2.6.orig/net/mac80211/rx.c	2007-09-06 15:35:23.214447686 +0200
+++ netdev-2.6/net/mac80211/rx.c	2007-09-06 15:35:23.414447686 +0200
@@ -1385,8 +1385,9 @@ void __ieee80211_rx(struct ieee80211_hw 
 	}
 
 	/*
-	 * key references are protected using RCU and this requires that
-	 * we are in a read-site RCU section during receive processing
+	 * key references and virtual interfaces are protected using RCU
+	 * and this requires that we are in a read-side RCU section during
+	 * receive processing
 	 */
 	rcu_read_lock();
 
@@ -1441,8 +1442,7 @@ void __ieee80211_rx(struct ieee80211_hw 
 
 	bssid = ieee80211_get_bssid(hdr, skb->len - radiotap_len);
 
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 		rx.flags |= IEEE80211_TXRXD_RXRA_MATCH;
 
 		if (!netif_running(sdata->dev))
@@ -1494,7 +1494,6 @@ void __ieee80211_rx(struct ieee80211_hw 
 					     &rx, sta);
 	} else
 		dev_kfree_skb(skb);
-	read_unlock(&local->sub_if_lock);
 
  end:
 	rcu_read_unlock();
--- netdev-2.6.orig/net/mac80211/tx.c	2007-09-06 15:35:23.074447686 +0200
+++ netdev-2.6/net/mac80211/tx.c	2007-09-06 15:35:23.424447686 +0200
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
