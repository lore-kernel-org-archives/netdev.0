From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 7/10] d80211: get rid of default AP interface
Date: Fri, 21 Apr 2006 22:53:27 +0200 (CEST)
Message-ID: <20060421205327.2B160482C0@silver.suse.cz>
References: <20060421225314.048983000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:46977 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932441AbWDUUw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:52:59 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421225314.048983000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need for default non-removable AP interface (wlanX), it just
confuses users. This patch removes it and renames master interface from
wlanX.11 to wlanX.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   78 +++++++++---------------------------------
 net/d80211/ieee80211_i.h     |    3 +-
 net/d80211/ieee80211_iface.c |    3 +-
 net/d80211/ieee80211_ioctl.c |   12 +++---
 net/d80211/ieee80211_proc.c  |    8 ++--
 5 files changed, 27 insertions(+), 77 deletions(-)

11da4bbdb5dd3f83a991f9e8df2d2356606b87b4
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ad63bab..2386454 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2032,7 +2032,7 @@ static int ieee80211_open(struct net_dev
 		struct net_device *ndev = nsdata->dev;
 
 		if (ndev != dev && ndev != local->mdev &&
-		    ndev != local->wdev && ndev != local->apdev &&
+		    ndev != local->apdev &&
 		    netif_running(ndev) &&
 		    memcmp(dev->dev_addr, ndev->dev_addr, ETH_ALEN) == 0 &&
 		    !identical_mac_addr_allowed(sdata->type, nsdata->type)) {
@@ -3684,7 +3684,7 @@ static void ieee80211_tasklet_handler(un
 			break;
 		default: /* should never get here! */
 			printk(KERN_ERR "%s: Unknown message type (%d)\n",
-			       local->wdev->name, skb->pkt_type);
+			       local->mdev->name, skb->pkt_type);
 			dev_kfree_skb(skb);
 			break;
                 }
@@ -3979,7 +3979,7 @@ static void ieee80211_if_init(struct net
 }
 
 
-/* Must not be called for wdev, mdev and apdev */
+/* Must not be called for mdev and apdev */
 void ieee80211_if_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -4018,7 +4018,7 @@ static void ieee80211_precalc_rates(stru
 struct net_device *ieee80211_alloc_hw(size_t priv_data_len,
 				      void (*setup)(struct net_device *))
 {
-	struct net_device *dev, *apdev, *mdev;
+	struct net_device *apdev, *mdev;
         struct ieee80211_local *local;
         struct ieee80211_sub_if_data *sdata;
 	int alloc_size;
@@ -4042,10 +4042,6 @@ struct net_device *ieee80211_alloc_hw(si
          * 17c0 *****************
          *      * sub_if        *
 	 *      *****************
-	 *      * master net_dev*
-	 *      *****************
-	 *      * sub_if        *
-         *      *****************
          */
         alloc_size = sizeof(struct net_device) +
                 sizeof(struct ieee80211_sub_if_data) + 3 +
@@ -4053,8 +4049,6 @@ struct net_device *ieee80211_alloc_hw(si
                 priv_data_len + 3 +
                 sizeof(struct net_device) + 3 +
 		sizeof(struct ieee80211_sub_if_data) + 3 +
-                sizeof(struct net_device) + 3 +
-		sizeof(struct ieee80211_sub_if_data) + 3 +
 		4096;
         mdev = (struct net_device *) kzalloc(alloc_size, GFP_KERNEL);
 	if (mdev == NULL)
@@ -4069,29 +4063,14 @@ struct net_device *ieee80211_alloc_hw(si
 		((char *) local + ((sizeof(struct ieee80211_local) + 3) & ~3));
 	apdev = (struct net_device *)
 		((char *) local->hw_priv + ((priv_data_len + 3) & ~3));
-        dev = (struct net_device *)
-		((char *) apdev +
-		 ((sizeof(struct net_device) + 3) & ~3) +
-		 ((sizeof(struct ieee80211_sub_if_data) + 3) & ~3));
-        dev->priv = local;
 
-	ether_setup(dev);
-	memcpy(dev->name, "wlan%d", 7);
+	ether_setup(mdev);
+	memcpy(mdev->name, "wlan%d", 7);
 
-        dev->hard_start_xmit = ieee80211_subif_start_xmit;
-	dev->wireless_handlers =
-		(struct iw_handler_def *) &ieee80211_iw_handler_def;
-        dev->do_ioctl = ieee80211_ioctl;
-	dev->change_mtu = ieee80211_change_mtu;
-        dev->tx_timeout = ieee80211_tx_timeout;
-        dev->get_stats = ieee80211_get_stats;
-        dev->open = ieee80211_open;
-        dev->stop = ieee80211_stop;
-	dev->tx_queue_len = 0;
-	dev->set_mac_address = ieee80211_set_mac_address;
+	if (strlen(mdev->name) + 2 >= sizeof(mdev->name))
+		goto fail;
 
 	local->dev_index = -1;
-        local->wdev = dev;
 	local->mdev = mdev;
         local->rx_handlers = ieee80211_rx_handlers;
         local->tx_handlers = ieee80211_tx_handlers;
@@ -4119,22 +4098,11 @@ struct net_device *ieee80211_alloc_hw(si
 	init_timer(&local->stat_timer);
 	local->stat_timer.function = ieee80211_stat_refresh;
 	local->stat_timer.data = (unsigned long) local;
-	ieee80211_rx_bss_list_init(dev);
+	ieee80211_rx_bss_list_init(mdev);
 
         sta_info_init(local);
 
-        ieee80211_if_init(dev);
-
-        sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-        sdata->dev = dev;
-        sdata->master = mdev;
-        sdata->local = local;
-	ieee80211_if_sdata_init(sdata);
-	ieee80211_if_set_type(dev, IEEE80211_IF_TYPE_AP);
-	list_add_tail(&sdata->list, &local->sub_if_list);
-
-	if (strlen(dev->name) + 2 >= sizeof(dev->name))
-		goto fail;
+        ieee80211_if_init(mdev);
 
         apdev = (struct net_device *)
 		((char *) local->hw_priv + ((priv_data_len + 3) & ~3));
@@ -4149,7 +4117,7 @@ struct net_device *ieee80211_alloc_hw(si
 	apdev->type = ARPHRD_IEEE80211_PRISM;
         apdev->hard_header_parse = header_parse_80211;
 	apdev->tx_queue_len = 0;
-	sprintf(apdev->name, "%sap", dev->name);
+	sprintf(apdev->name, "%sap", mdev->name);
 
         sdata = IEEE80211_DEV_TO_SUB_IF(apdev);
         sdata->type = IEEE80211_IF_TYPE_MGMT;
@@ -4158,7 +4126,6 @@ struct net_device *ieee80211_alloc_hw(si
         sdata->local = local;
         list_add_tail(&sdata->list, &local->sub_if_list);
 
-	ether_setup(mdev);
 	mdev->hard_start_xmit = ieee80211_master_start_xmit;
 	mdev->wireless_handlers =
 		(struct iw_handler_def *) &ieee80211_iw_handler_def;
@@ -4170,7 +4137,6 @@ struct net_device *ieee80211_alloc_hw(si
 	mdev->stop = ieee80211_master_stop;
 	mdev->type = ARPHRD_IEEE80211;
         mdev->hard_header_parse = header_parse_80211;
-	sprintf(mdev->name, "%s.11", dev->name);
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(mdev);
 	sdata->type = IEEE80211_IF_TYPE_AP;
@@ -4226,19 +4192,15 @@ int ieee80211_register_hw(struct net_dev
 
 	sta_info_start(local);
 
-	result = register_netdev(local->wdev);
-	if (result < 0)
-		goto fail_1st_dev;
-
 	result = register_netdev(local->apdev);
 	if (result < 0)
-		goto fail_2nd_dev;
+		goto fail_1st_dev;
 
 	if (hw->fraglist)
 		dev->features |= NETIF_F_FRAGLIST;
 	result = register_netdev(dev);
 	if (result < 0)
-		goto fail_3rd_dev;
+		goto fail_2nd_dev;
 
 	if (rate_control_initialize(local) < 0) {
 		printk(KERN_DEBUG "%s: Failed to initialize rate control "
@@ -4255,10 +4217,8 @@ int ieee80211_register_hw(struct net_dev
 
 fail_rate:
 	unregister_netdev(dev);
-fail_3rd_dev:
-	unregister_netdev(local->apdev);
 fail_2nd_dev:
-	unregister_netdev(local->wdev);
+	unregister_netdev(local->apdev);
 fail_1st_dev:
 	sta_info_stop(local);
 	ieee80211_unregister_sysfs(local);
@@ -4284,12 +4244,6 @@ int ieee80211_update_hw(struct net_devic
 	local->apdev->mem_start = dev->mem_start;
 	local->apdev->mem_end = dev->mem_end;
 
-        memcpy(local->wdev->dev_addr, dev->dev_addr, ETH_ALEN);
-	local->wdev->base_addr = dev->base_addr;
-	local->wdev->irq = dev->irq;
-	local->wdev->mem_start = dev->mem_start;
-	local->wdev->mem_end = dev->mem_end;
-
 	if (!hw->modes || !hw->modes->channels || !hw->modes->rates ||
 	    !hw->modes->num_channels || !hw->modes->num_rates)
 		return -1;
@@ -4470,14 +4424,14 @@ static int rate_control_initialize(struc
 		local->rate_ctrl_priv = rate_control_alloc(local);
 		if (local->rate_ctrl_priv) {
 			printk(KERN_DEBUG "%s: Selected rate control "
-			       "algorithm '%s'\n", local->wdev->name,
+			       "algorithm '%s'\n", local->mdev->name,
 			       local->rate_ctrl->name);
 			return 0;
 		}
 	}
 
 	printk(KERN_WARNING "%s: Failed to select rate control algorithm\n",
-	       local->wdev->name);
+	       local->mdev->name);
 	return -1;
 }
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 98c30ff..77517c9 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -316,8 +316,7 @@ #define IEEE80211_SUB_IF_TO_DEV(sub_if) 
 struct ieee80211_local {
 	struct ieee80211_hw *hw;
 	void *hw_priv;
-	struct net_device *mdev; /* wlan#.11 - "master" 802.11 device */
-        struct net_device *wdev; /* wlan# - default Ethernet (data) devide */
+	struct net_device *mdev; /* wlan# - "master" 802.11 device */
 	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
 	int open_count;
 	int monitors;
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 42ea643..58fd946 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -258,7 +258,6 @@ int ieee80211_if_remove(struct net_devic
 		if ((sdata->type == id || id == -1) &&
 		    strcmp(name, sdata->dev->name) == 0 &&
 		    sdata->dev != local->mdev &&
-		    sdata->dev != local->wdev &&
 		    sdata->dev != local->apdev) {
 			__ieee80211_if_del(local, sdata);
 			return 0;
@@ -271,7 +270,7 @@ void ieee80211_if_free(struct net_device
 {
 	struct ieee80211_local *local = dev->priv;
 
-	BUG_ON(dev == local->mdev || dev == local->wdev || dev == local->apdev);
+	BUG_ON(dev == local->mdev || dev == local->apdev);
 	kfree(dev);
 }
 
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 3eaad0a..1d3f5cf 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -499,13 +499,11 @@ static int ieee80211_set_encryption(stru
 		 * must be used. This should be done automatically
 		 * based on configured station devices. For the time
 		 * being, this can be only set at compile time. */
-		if (sdata->type == IEEE80211_IF_TYPE_STA) {
-			if (0 /* FIX: more than one STA per AP */)
-				try_hwaccel = 0;
-		} else
-		if (sdata->type != IEEE80211_IF_TYPE_AP ||
-		    dev != local->wdev)
-			try_hwaccel = 0;
+		/* FIXME: There is no more anything like "default
+		 * interface". We should try hwaccel if there is just one
+		 * interface - for now, hwaccel is unconditionaly
+		 * disabled. */
+		try_hwaccel = 0;
 	} else {
 		set_tx_key = 0;
 		if (idx != 0) {
diff --git a/net/d80211/ieee80211_proc.c b/net/d80211/ieee80211_proc.c
index a886280..c9f5567 100644
--- a/net/d80211/ieee80211_proc.c
+++ b/net/d80211/ieee80211_proc.c
@@ -702,7 +702,7 @@ void ieee80211_proc_init_interface(struc
 	if (!ieee80211_proc)
 		return;
 
-	local->proc = proc_mkdir(local->wdev->name, ieee80211_proc);
+	local->proc = proc_mkdir(local->mdev->name, ieee80211_proc);
 	if (!local->proc)
 		return;
 
@@ -722,7 +722,7 @@ void ieee80211_proc_init_interface(struc
                                ieee80211_proc_debug_read, local);
 	create_proc_read_entry("info", 0, local->proc,
 			       ieee80211_proc_info_read, local);
-	ieee80211_proc_init_virtual(local->wdev);
+	ieee80211_proc_init_virtual(local->mdev);
 }
 
 
@@ -731,7 +731,7 @@ void ieee80211_proc_deinit_interface(str
 	if (!local->proc)
 		return;
 
-	ieee80211_proc_deinit_virtual(local->wdev);
+	ieee80211_proc_deinit_virtual(local->mdev);
 	remove_proc_entry("iface", local->proc);
 	remove_proc_entry("sta", local->proc);
         remove_proc_entry("counters", local->proc);
@@ -742,7 +742,7 @@ void ieee80211_proc_deinit_interface(str
 	remove_proc_entry("multicast", local->proc);
 	remove_proc_entry("info", local->proc);
 	local->proc = NULL;
-	remove_proc_entry(local->wdev->name, ieee80211_proc);
+	remove_proc_entry(local->mdev->name, ieee80211_proc);
 }
 
 
-- 
1.3.0

