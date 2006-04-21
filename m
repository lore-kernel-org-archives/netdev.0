From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 12/17] d80211: interface types changeable by SIOCSIWMODE
Date: Fri, 21 Apr 2006 22:11:43 +0200 (CEST)
Message-ID: <20060421201143.AC1B5482CB@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:13447 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932419AbWDUULQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:16 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow type of interface to be set by SIOCSIWMODE. All of functions
responsible for adding/removing/initialization of interfaces were moved to
a new file ieee80211_iface.c. Function for removing interface was split into
two parts: one for deinitialization of the interface and one for
deallocation of the interface. That way, it is possible to change the type
of interface just by deinitializing and initializing it.

Also, remove set_mac_address callback to a driver, as it is not needed
anymore (drivers are notified about MAC addresses through add_interface
callback).

Please note, that although after this patch interfaces are fully independent
and driver can correctly control which combination is allowed, not all
multicast frames are received correctly by all respective interfaces. This
is addressed by subsequent patches.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h         |    3 
 net/d80211/Makefile          |    1 
 net/d80211/ieee80211.c       |  458 +++++-------------------------------------
 net/d80211/ieee80211_i.h     |   30 +--
 net/d80211/ieee80211_iface.c |  289 +++++++++++++++++++++++++++
 net/d80211/ieee80211_ioctl.c |  125 +++++++----
 net/d80211/ieee80211_sysfs.c |   12 +
 7 files changed, 435 insertions(+), 483 deletions(-)
 create mode 100644 net/d80211/ieee80211_iface.c

ef162ee22ef1564f76a9d67b8df647993806e72d
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 2ec31db..6894745 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -585,9 +585,6 @@ struct ieee80211_hw {
 	/* Configuration of test parameters */
 	int (*test_param)(struct net_device *dev, int param, int value);
 
-	/* Change MAC address. addr is pointer to struct sockaddr. */
-	int (*set_mac_address)(struct net_device *dev, void *addr);
-
         /* For devices that generate their own beacons and probe response
          * or association responses this updates the state of privacy_invoked
          * returns 0 for success or an error number */
diff --git a/net/d80211/Makefile b/net/d80211/Makefile
index 59d1d65..66bfcff 100644
--- a/net/d80211/Makefile
+++ b/net/d80211/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_D80211) += 80211.o rate_con
 	ieee80211_scan.o \
 	ieee80211_sta.o \
 	ieee80211_dev.o \
+	ieee80211_iface.o \
 	ieee80211_sysfs.o \
 	michael.o \
 	tkip.o \
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 16a07d0..c20cb00 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1803,24 +1803,12 @@ static void ieee80211_tx_timeout(struct 
 
 static int ieee80211_set_mac_address(struct net_device *dev, void *addr)
 {
-	struct ieee80211_local *local = dev->priv;
 	struct sockaddr *a = addr;
-	struct list_head *ptr;
-	int res;
 
-	if (!local->hw->set_mac_address)
-		return -EOPNOTSUPP;
-
-	res = local->hw->set_mac_address(dev, addr);
-	if (res)
-		return res;
-
-	list_for_each(ptr, &local->sub_if_list)	{
-		struct ieee80211_sub_if_data *sdata =
-			list_entry(ptr, struct ieee80211_sub_if_data, list);
-		memcpy(sdata->dev->dev_addr, a->sa_data, ETH_ALEN);
-	}
+	if (netif_running(dev))
+		return -EBUSY;
 
+	memcpy(dev->dev_addr, a->sa_data, ETH_ALEN);
 	return 0;
 }
 
@@ -1832,14 +1820,37 @@ static struct net_device_stats *ieee8021
 	return &(sdata->stats);
 }
 
+static inline int identical_mac_addr_allowed(int type1, int type2)
+{
+	return ((type1 == IEEE80211_IF_TYPE_AP &&
+		 type2 == IEEE80211_IF_TYPE_WDS) ||
+		(type1 == IEEE80211_IF_TYPE_WDS &&
+		 (type2 == IEEE80211_IF_TYPE_WDS ||
+		  type2 == IEEE80211_IF_TYPE_AP)));
+}
 
 static int ieee80211_open(struct net_device *dev)
 {
-	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_sub_if_data *sdata, *nsdata;
 	struct ieee80211_local *local = dev->priv;
 	int res;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	list_for_each_entry(nsdata, &local->sub_if_list, list) {
+		struct net_device *ndev = nsdata->dev;
+
+		if (ndev != dev && ndev != local->mdev &&
+		    ndev != local->wdev && ndev != local->apdev &&
+		    netif_running(ndev) &&
+		    memcmp(dev->dev_addr, ndev->dev_addr, ETH_ALEN) == 0 &&
+		    !identical_mac_addr_allowed(sdata->type, nsdata->type)) {
+			return -ENOTUNIQ;
+		}
+	}
+	if (sdata->type == IEEE80211_IF_TYPE_WDS &&
+	    memcmp(sdata->u.wds.remote_addr, "\0\0\0\0\0\0", ETH_ALEN) == 0)
+		return -ENOLINK;
+
 	if (local->hw->add_interface) {
 		struct ieee80211_if_init_conf conf;
 
@@ -1849,6 +1860,11 @@ static int ieee80211_open(struct net_dev
 		res = local->hw->add_interface(sdata->master, &conf);
 		if (res)
 			return res;
+	} else {
+		if (sdata->type != IEEE80211_IF_TYPE_STA)
+			return -EOPNOTSUPP;
+		if (local->open_count > 0)
+			return -ENOBUFS;
 	}
 
         if (local->open_count == 0) {
@@ -3800,128 +3816,6 @@ static ieee80211_tx_handler ieee80211_tx
 };
 
 
-static void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata)
-{
-	/* Default values for sub-interface parameters */
-	sdata->drop_unencrypted = 0;
-	sdata->eapol = 1;
-}
-
-
-static struct net_device *ieee80211_if_add(struct net_device *dev,
-					   const char *name, int locked)
-{
-	struct net_device *wds_dev = NULL, *tmp_dev;
-        struct ieee80211_local *local = dev->priv;
-	struct ieee80211_sub_if_data *sdata = NULL, *sdata_parent;
-        int alloc_size;
-	int ret;
-	int i;
-
-	/* ensure 32-bit alignment of our private data and hw private data */
-	alloc_size = sizeof(struct net_device) + 3 +
-		sizeof(struct ieee80211_sub_if_data) + 3;
-
-        wds_dev = (struct net_device *) kmalloc(alloc_size, GFP_KERNEL);
-        if (wds_dev == NULL)
-		return NULL;
-
-	memset(wds_dev, 0, alloc_size);
-	wds_dev->priv = local;
-	ether_setup(wds_dev);
-	if (strlen(name) == 0) {
-		i = 0;
-		do {
-			sprintf(wds_dev->name, "%s.%d", dev->name, i++);
-			tmp_dev = dev_get_by_name(wds_dev->name);
-			if (tmp_dev == NULL)
-				break;
-			dev_put(tmp_dev);
-		} while (i < 10000);
-	} else {
-                snprintf(wds_dev->name, IFNAMSIZ, "%s", name);
-	}
-
-	memcpy(wds_dev->dev_addr, dev->dev_addr, ETH_ALEN);
-	wds_dev->hard_start_xmit = ieee80211_subif_start_xmit;
-	wds_dev->wireless_handlers =
-		(struct iw_handler_def *) &ieee80211_iw_handler_def;
-        wds_dev->do_ioctl = ieee80211_ioctl;
-	wds_dev->change_mtu = ieee80211_change_mtu;
-        wds_dev->tx_timeout = ieee80211_tx_timeout;
-        wds_dev->get_stats = ieee80211_get_stats;
-        wds_dev->open = ieee80211_open;
-	wds_dev->stop = ieee80211_stop;
-	wds_dev->base_addr = dev->base_addr;
-	wds_dev->irq = dev->irq;
-	wds_dev->mem_start = dev->mem_start;
-	wds_dev->mem_end = dev->mem_end;
-	wds_dev->tx_queue_len = 0;
-
-	sdata = IEEE80211_DEV_TO_SUB_IF(wds_dev);
-	sdata->type = IEEE80211_IF_TYPE_AP;
-        sdata->master = local->mdev;
-        sdata->dev = wds_dev;
-	sdata->local = local;
-	memset(&sdata->stats, 0, sizeof(struct net_device_stats));
-	sdata_parent = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata_parent->type == IEEE80211_IF_TYPE_AP)
-		sdata->bss = &sdata_parent->u.ap;
-	else {
-		printk(KERN_DEBUG "%s: could not set BSS pointer for new "
-		       "interface %s\n", dev->name, wds_dev->name);
-	}
-	ieee80211_if_sdata_init(sdata);
-
-        if (locked)
-		ret = register_netdevice(wds_dev);
-	else
-		ret = register_netdev(wds_dev);
-	if (ret) {
-		kfree(wds_dev);
-		return NULL;
-	}
-
-        list_add(&sdata->list, &local->sub_if_list);
-
-        return wds_dev;
-}
-
-
-int ieee80211_if_add_wds(struct net_device *dev, const char *name,
-                         struct ieee80211_if_wds *wds, int locked)
-{
-        struct net_device *wds_dev = NULL;
-	struct ieee80211_sub_if_data *sdata = NULL;
-
-        if (strlen(name) != 0) {
-                wds_dev = dev_get_by_name(name);
-                if (wds_dev) {
-                        dev_put(wds_dev);
-                        return -EEXIST;
-                }
-        }
-
-        wds_dev = ieee80211_if_add(dev, name, locked);
-        if (wds_dev == NULL)
-                return -ENOANO;
-
-	sdata = IEEE80211_DEV_TO_SUB_IF(wds_dev);
-        sdata->type = IEEE80211_IF_TYPE_WDS;
-        memcpy(&sdata->u.wds, wds, sizeof(struct ieee80211_if_wds));
-
-#ifdef CONFIG_D80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG
-	       "%s: Added WDS Link to " MACSTR "\n",
-	       wds_dev->name, MAC2STR(sdata->u.wds.remote_addr));
-#endif /* CONFIG_D80211_VERBOSE_DEBUG */
-
-	ieee80211_proc_init_virtual(wds_dev);
-
-        return 0;
-}
-
-
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr)
 {
 	struct ieee80211_local *local = dev->priv;
@@ -3955,274 +3849,22 @@ static void ieee80211_if_init(struct net
 }
 
 
-int ieee80211_if_add_vlan(struct net_device *dev, const char *name,
-			  struct ieee80211_if_vlan *vlan, int locked)
-{
-        struct net_device *vlan_dev = NULL;
-        struct ieee80211_sub_if_data *sdata = NULL;
-
-        if (strlen(name) != 0) {
-                vlan_dev = dev_get_by_name(name);
-                if (vlan_dev) {
-                        dev_put(vlan_dev);
-                        return -EEXIST;
-                }
-        }
-
-        vlan_dev = ieee80211_if_add(dev, name, locked);
-        if (vlan_dev == NULL)
-                return -ENOANO;
-
-	sdata = IEEE80211_DEV_TO_SUB_IF(vlan_dev);
-        sdata->type = IEEE80211_IF_TYPE_VLAN;
-	ieee80211_proc_init_virtual(vlan_dev);
-        return 0;
-}
-
-
-static void ieee80211_if_ap_init(struct ieee80211_sub_if_data *sdata)
-{
-	sdata->type = IEEE80211_IF_TYPE_AP;
-	sdata->u.ap.dtim_period = 2;
-	sdata->u.ap.force_unicast_rateidx = -1;
-	sdata->u.ap.max_ratectrl_rateidx = -1;
-	skb_queue_head_init(&sdata->u.ap.ps_bc_buf);
-	sdata->bss = &sdata->u.ap;
-}
-
-
-int ieee80211_if_add_ap(struct net_device *dev, const char *name, u8 *bssid,
-			  int locked)
-{
-	struct net_device *ap_dev = NULL;
-        struct ieee80211_sub_if_data *sdata = NULL;
-
-        if (strlen(name) != 0) {
-		ap_dev = dev_get_by_name(name);
-		if (ap_dev) {
-			dev_put(ap_dev);
-                        return -EEXIST;
-                }
-        }
-
-	ap_dev = ieee80211_if_add(dev, name, locked);
-	if (ap_dev == NULL)
-                return -ENOANO;
-
-	memcpy(ap_dev->dev_addr, bssid, ETH_ALEN);
-	sdata = IEEE80211_DEV_TO_SUB_IF(ap_dev);
-	ieee80211_if_ap_init(sdata);
-	ieee80211_proc_init_virtual(ap_dev);
-
-        return 0;
-}
-
-
-int ieee80211_if_add_sta(struct net_device *dev, const char *name, int locked)
-{
-	struct net_device *sta_dev;
-	struct ieee80211_sub_if_data *sdata;
-	struct ieee80211_if_sta *ifsta;
-
-	if (strlen(name) != 0) {
-		sta_dev = dev_get_by_name(name);
-		if (sta_dev) {
-			dev_put(sta_dev);
-			return -EEXIST;
-		}
-	}
-
-	sta_dev = ieee80211_if_add(dev, name, locked);
-	if (sta_dev == NULL)
-		return -ENOANO;
-
-	sdata = IEEE80211_DEV_TO_SUB_IF(sta_dev);
-	ifsta = &sdata->u.sta;
-	sdata->type = IEEE80211_IF_TYPE_STA;
-	ieee80211_proc_init_virtual(sta_dev);
-
-	init_timer(&ifsta->timer);
-	ifsta->timer.data = (unsigned long) sta_dev;
-	ifsta->timer.function = ieee80211_sta_timer;
-
-	ifsta->capab = WLAN_CAPABILITY_ESS;
-	ifsta->auth_algs = IEEE80211_AUTH_ALG_OPEN |
-		IEEE80211_AUTH_ALG_SHARED_KEY;
-	ifsta->create_ibss = 1;
-	ifsta->wmm_enabled = 1;
-
-	return 0;
-}
-
-
-static void ieee80211_if_del(struct ieee80211_local *local,
-			     struct ieee80211_sub_if_data *sdata, int locked)
-{
-        struct sta_info *sta;
-	u8 addr[ETH_ALEN];
-	int i;
-        struct list_head *ptr, *n;
-
-	memset(addr, 0xff, ETH_ALEN);
-	for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-		if (!sdata->keys[i])
-			continue;
-#if 0
-		/* Low-level driver has probably disabled hw
-		 * already, so there is not really much point
-		 * in disabling the keys at this point. */
-		if (local->hw->set_key)
-			local->hw->set_key(dev, DISABLE_KEY, addr,
-					   local->keys[i], 0);
-#endif
-		ieee80211_key_free(sdata->keys[i]);
-	}
-
-	switch (sdata->type) {
-	case IEEE80211_IF_TYPE_AP:
-		/* Remove all virtual interfaces that use this BSS
-		 * as their sdata->bss */
-		list_for_each_safe(ptr, n, &local->sub_if_list) {
-			struct ieee80211_sub_if_data *tsdata =
-				list_entry(ptr, struct ieee80211_sub_if_data,
-					   list);
-
-			if (tsdata != sdata && tsdata->bss == &sdata->u.ap) {
-				printk(KERN_DEBUG "%s: removing virtual "
-				       "interface %s because its BSS interface"
-				       " is being removed\n",
-				       sdata->dev->name, tsdata->dev->name);
-				ieee80211_if_del(local, tsdata, locked);
-			}
-		}
-
-		kfree(sdata->u.ap.beacon_head);
-		kfree(sdata->u.ap.beacon_tail);
-
-		if (sdata->dev != local->mdev) {
-			struct sk_buff *skb;
-			while ((skb = skb_dequeue(&sdata->u.ap.ps_bc_buf))) {
-				local->total_ps_buffered--;
-				dev_kfree_skb(skb);
-			}
-		}
-
-		break;
-	case IEEE80211_IF_TYPE_WDS:
-		sta = sta_info_get(local, sdata->u.wds.remote_addr);
-		if (sta) {
-			sta_info_release(local, sta);
-			sta_info_free(local, sta, 0);
-		} else {
-#ifdef CONFIG_D80211_VERBOSE_DEBUG
-			printk(KERN_DEBUG "%s: Someone had deleted my STA "
-			       "entry for the WDS link\n", local->mdev->name);
-#endif /* CONFIG_D80211_VERBOSE_DEBUG */
-		}
-		break;
-	case IEEE80211_IF_TYPE_STA:
-		del_timer_sync(&sdata->u.sta.timer);
-		if (local->scan_timer.data == (unsigned long) sdata->dev)
-			del_timer_sync(&local->scan_timer);
-		kfree(sdata->u.sta.extra_ie);
-		sdata->u.sta.extra_ie = NULL;
-		kfree(sdata->u.sta.assocreq_ies);
-		sdata->u.sta.assocreq_ies = NULL;
-		kfree(sdata->u.sta.assocresp_ies);
-		sdata->u.sta.assocresp_ies = NULL;
-		if (sdata->u.sta.probe_resp) {
-			dev_kfree_skb(sdata->u.sta.probe_resp);
-			sdata->u.sta.probe_resp = NULL;
-		}
-
-		break;
-	}
-
-	/* remove all STAs that are bound to this virtual interface */
-	sta_info_flush(local, sdata->dev);
-
-	list_del(&sdata->list);
-	ieee80211_proc_deinit_virtual(sdata->dev);
-	if (locked)
-		unregister_netdevice(sdata->dev);
-	else
-		unregister_netdev(sdata->dev);
-	/* Default data device and management device are allocated with the
-	 * master device. All other devices are separately allocated and will
-	 * be freed here. */
-	if (sdata->dev != local->mdev && sdata->dev != local->wdev &&
-	    sdata->dev != local->apdev)
-		kfree(sdata->dev);
-}
-
-
-static int ieee80211_if_remove(struct net_device *dev, const char *name,
-			       int id, int locked)
+/* Must not be called for wdev, mdev and apdev */
+void ieee80211_if_setup(struct net_device *dev)
 {
-        struct ieee80211_local *local = dev->priv;
-        struct list_head *ptr, *n;
-
-	/* Make sure not to touch sdata->master since it may
-	 * have already been deleted, etc. */
-
-	list_for_each_safe(ptr, n, &local->sub_if_list) {
-		struct ieee80211_sub_if_data *sdata =
-			list_entry(ptr, struct ieee80211_sub_if_data, list);
-
-		if (sdata->type == id && strcmp(name, sdata->dev->name) == 0) {
-			ieee80211_if_del(local, sdata, locked);
-			break;
-		}
-	}
-
-        return 0;
-}
-
-
-int ieee80211_if_remove_wds(struct net_device *dev, const char *name,
-			    int locked)
-{
-        return ieee80211_if_remove(dev, name, IEEE80211_IF_TYPE_WDS, locked);
-}
-
-
-int ieee80211_if_remove_vlan(struct net_device *dev, const char *name,
-			     int locked)
-{
-        return ieee80211_if_remove(dev, name, IEEE80211_IF_TYPE_VLAN, locked);
-}
-
-
-int ieee80211_if_remove_ap(struct net_device *dev, const char *name,
-			   int locked)
-{
-	return ieee80211_if_remove(dev, name, IEEE80211_IF_TYPE_AP, locked);
-}
-
-
-int ieee80211_if_remove_sta(struct net_device *dev, const char *name,
-			    int locked)
-{
-	return ieee80211_if_remove(dev, name, IEEE80211_IF_TYPE_STA, locked);
-}
-
-
-int ieee80211_if_flush(struct net_device *dev, int locked)
-{
-        struct ieee80211_local *local = dev->priv;
-        struct list_head *ptr, *n;
-
-	list_for_each_safe(ptr, n, &local->sub_if_list) {
-		struct ieee80211_sub_if_data *sdata =
-			list_entry(ptr, struct ieee80211_sub_if_data, list);
-
-		if (sdata->dev != local->mdev &&
-		    sdata->dev != local->wdev &&
-		    sdata->dev != local->apdev)
-			ieee80211_if_del(local, sdata, locked);
-	}
-
-        return 0;
+	ether_setup(dev);
+	dev->hard_start_xmit = ieee80211_subif_start_xmit;
+	dev->wireless_handlers =
+		(struct iw_handler_def *) &ieee80211_iw_handler_def;
+	dev->do_ioctl = ieee80211_ioctl;
+	dev->set_mac_address = ieee80211_set_mac_address;
+	dev->change_mtu = ieee80211_change_mtu;
+	dev->tx_timeout = ieee80211_tx_timeout;
+	dev->get_stats = ieee80211_get_stats;
+	dev->open = ieee80211_open;
+	dev->stop = ieee80211_stop;
+	dev->tx_queue_len = 0;
+	dev->destructor = ieee80211_if_free;
 }
 
 
@@ -4357,7 +3999,7 @@ struct net_device *ieee80211_alloc_hw(si
         sdata->master = mdev;
         sdata->local = local;
 	ieee80211_if_sdata_init(sdata);
-	ieee80211_if_ap_init(sdata);
+	ieee80211_if_set_type(dev, IEEE80211_IF_TYPE_AP);
 	list_add_tail(&sdata->list, &local->sub_if_list);
 
 	if (strlen(dev->name) + 2 >= sizeof(dev->name))
@@ -4530,6 +4172,8 @@ int ieee80211_update_hw(struct net_devic
 	local->conf.freq = local->hw->modes[0].channels[0].freq;
 	local->conf.channel = local->hw->modes[0].channels[0].chan;
 	local->conf.channel_val = local->hw->modes[0].channels[0].val;
+
+	ieee80211_init_client(dev);
 	/* FIXME: Invoke config to allow driver to set the channel. */
 
 	return 0;
@@ -4556,7 +4200,7 @@ void ieee80211_unregister_hw(struct net_
 	list_for_each_safe(ptr, n, &local->sub_if_list) {
 		struct ieee80211_sub_if_data *sdata =
 			list_entry(ptr, struct ieee80211_sub_if_data, list);
-		ieee80211_if_del(local, sdata, 0);
+		ieee80211_if_del(sdata->dev);
 	}
 
 	sta_info_stop(local);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 8fd0ac4..5116a88 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -493,18 +493,8 @@ void ieee80211_rx_mgmt(struct net_device
 		       struct ieee80211_rx_status *status, u32 msg_type);
 void ieee80211_prepare_rates(struct net_device *dev);
 void ieee80211_tx_set_iswep(struct ieee80211_txrx_data *tx);
-int ieee80211_if_add_wds(struct net_device *dev, const char *name,
-			 struct ieee80211_if_wds *wds, int locked);
-int ieee80211_if_add_vlan(struct net_device *dev, const char *name,
-			  struct ieee80211_if_vlan *vlan, int locked);
-int ieee80211_if_add_ap(struct net_device *dev, const char *name, u8 *bssid,
-			int locked);
-
-int ieee80211_if_remove_wds(struct net_device *dev, const char *name, int locked);
-int ieee80211_if_remove_vlan(struct net_device *dev, const char *name, int locked);
-int ieee80211_if_remove_ap(struct net_device *dev, const char *name, int locked);
-int ieee80211_if_flush(struct net_device *dev, int locked);
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
+void ieee80211_if_setup(struct net_device *dev);
 
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -540,13 +530,10 @@ #define CHAN_UTIL_HDR_LONG (202 * CHAN_U
 #define CHAN_UTIL_HDR_SHORT (40 * CHAN_UTIL_PER_USEC)
 
 
-
-/* ieee80211.c */
-int ieee80211_if_add_sta(struct net_device *dev, const char *name, int locked);
-int ieee80211_if_remove_sta(struct net_device *dev, const char *name, int locked);
 /* ieee80211_ioctl.c */
 int ieee80211_set_compression(struct ieee80211_local *local,
 			      struct net_device *dev, struct sta_info *sta);
+int ieee80211_init_client(struct net_device *dev);
 /* ieee80211_sta.c */
 void ieee80211_sta_timer(unsigned long ptr);
 void ieee80211_sta_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
@@ -573,6 +560,19 @@ void ieee80211_dev_free_index(struct iee
 struct ieee80211_local *ieee80211_dev_find(int index);
 int ieee80211_dev_find_index(struct ieee80211_local *local);
 
+/* ieee80211_iface.c */
+int ieee80211_if_add(struct net_device *dev, const char *name,
+		     struct net_device **new_dev);
+void ieee80211_if_set_type(struct net_device *dev, int type);
+void ieee80211_if_reinit(struct net_device *dev);
+void __ieee80211_if_del(struct ieee80211_local *local,
+			struct ieee80211_sub_if_data *sdata);
+void ieee80211_if_del(struct net_device *dev);
+int ieee80211_if_remove(struct net_device *dev, const char *name, int id);
+void ieee80211_if_free(struct net_device *dev);
+void ieee80211_if_flush(struct net_device *dev);
+void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata);
+
 /* ieee80211_sysfs.c */
 int ieee80211_register_sysfs(struct ieee80211_local *local);
 void ieee80211_unregister_sysfs(struct ieee80211_local *local);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
new file mode 100644
index 0000000..917428e
--- /dev/null
+++ b/net/d80211/ieee80211_iface.c
@@ -0,0 +1,289 @@
+/*
+ * Copyright 2002-2005, Instant802 Networks, Inc.
+ * Copyright 2005-2006, Devicescape Software, Inc.
+ * Copyright (c) 2006 Jiri Benc <jbenc@suse.cz>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <net/d80211.h>
+#include <net/d80211_mgmt.h>
+#include "ieee80211_i.h"
+#include "ieee80211_proc.h"
+#include "sta_info.h"
+
+void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata)
+{
+	/* Default values for sub-interface parameters */
+	sdata->drop_unencrypted = 0;
+	sdata->eapol = 1;
+}
+
+/* Must be called with rtnl lock held. */
+int ieee80211_if_add(struct net_device *dev, const char *name,
+		     struct net_device **new_dev)
+{
+	struct net_device *ndev, *tmp_dev;
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata = NULL, *sdata_parent;
+	int alloc_size;
+	int ret;
+	int i;
+
+	ASSERT_RTNL();
+	/* ensure 32-bit alignment of our private data and hw private data */
+	alloc_size = sizeof(struct net_device) + 3 +
+		sizeof(struct ieee80211_sub_if_data) + 3;
+
+	ndev = *new_dev = (struct net_device *) kzalloc(alloc_size, GFP_KERNEL);
+	if (ndev == NULL)
+		return -ENOMEM;
+
+	ndev->priv = local;
+	if (strlen(name) == 0) {
+		i = 0;
+		do {
+			sprintf(ndev->name, "%s.%d", dev->name, i++);
+			tmp_dev = dev_get_by_name(ndev->name);
+			if (tmp_dev == NULL)
+				break;
+			dev_put(tmp_dev);
+		} while (i < 10000);
+	} else {
+		snprintf(ndev->name, IFNAMSIZ, "%s", name);
+	}
+
+	memcpy(ndev->dev_addr, dev->dev_addr, ETH_ALEN);
+	ndev->base_addr = dev->base_addr;
+	ndev->irq = dev->irq;
+	ndev->mem_start = dev->mem_start;
+	ndev->mem_end = dev->mem_end;
+	ieee80211_if_setup(ndev);
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(ndev);
+	sdata->type = IEEE80211_IF_TYPE_AP;
+	sdata->master = local->mdev;
+	sdata->dev = ndev;
+	sdata->local = local;
+	sdata_parent = IEEE80211_DEV_TO_SUB_IF(dev);
+	ieee80211_if_sdata_init(sdata);
+
+	ret = register_netdevice(ndev);
+	if (ret) {
+		kfree(ndev);
+		*new_dev = NULL;
+		return ret;
+	}
+
+	list_add(&sdata->list, &local->sub_if_list);
+	ieee80211_proc_init_virtual(ndev);
+
+	return 0;
+}
+
+void ieee80211_if_set_type(struct net_device *dev, int type)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	sdata->type = type;
+	switch (type) {
+	case IEEE80211_IF_TYPE_WDS:
+		sdata->bss = NULL;
+		break;
+	case IEEE80211_IF_TYPE_VLAN:
+		break;
+	case IEEE80211_IF_TYPE_AP:
+		sdata->u.ap.dtim_period = 2;
+		sdata->u.ap.force_unicast_rateidx = -1;
+		sdata->u.ap.max_ratectrl_rateidx = -1;
+		skb_queue_head_init(&sdata->u.ap.ps_bc_buf);
+		sdata->bss = &sdata->u.ap;
+		break;
+	case IEEE80211_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_IBSS: {
+		struct ieee80211_sub_if_data *msdata;
+		struct ieee80211_if_sta *ifsta;
+
+		ifsta = &sdata->u.sta;
+		init_timer(&ifsta->timer);
+		ifsta->timer.data = (unsigned long) dev;
+		ifsta->timer.function = ieee80211_sta_timer;
+
+		ifsta->capab = WLAN_CAPABILITY_ESS;
+		ifsta->auth_algs = IEEE80211_AUTH_ALG_OPEN |
+			IEEE80211_AUTH_ALG_SHARED_KEY;
+		ifsta->create_ibss = 1;
+		ifsta->wmm_enabled = 1;
+
+		msdata = IEEE80211_DEV_TO_SUB_IF(sdata->master);
+		sdata->bss = &msdata->u.ap;
+		break;
+	}
+	default:
+		printk(KERN_WARNING "%s: %s: Unknown interface type 0x%x",
+		       dev->name, __FUNCTION__, type);
+	}
+}
+
+/* Must be called with rtnl lock held. */
+void ieee80211_if_reinit(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct sta_info *sta;
+	int i;
+
+	ASSERT_RTNL();
+	for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
+		if (!sdata->keys[i])
+			continue;
+#if 0
+		/* The interface is down at the moment, so there is not
+		 * really much point in disabling the keys at this point. */
+		memset(addr, 0xff, ETH_ALEN);
+		if (local->hw->set_key)
+			local->hw->set_key(dev, DISABLE_KEY, addr,
+					   local->keys[i], 0);
+#endif
+		ieee80211_key_free(sdata->keys[i]);
+	}
+
+	switch (sdata->type) {
+	case IEEE80211_IF_TYPE_AP: {
+		/* Remove all virtual interfaces that use this BSS
+		 * as their sdata->bss */
+		struct ieee80211_sub_if_data *tsdata, *n;
+
+		list_for_each_entry_safe(tsdata, n, &local->sub_if_list, list) {
+			if (tsdata != sdata && tsdata->bss == &sdata->u.ap) {
+				printk(KERN_DEBUG "%s: removing virtual "
+				       "interface %s because its BSS interface"
+				       " is being removed\n",
+				       sdata->dev->name, tsdata->dev->name);
+				__ieee80211_if_del(local, tsdata);
+			}
+		}
+
+		kfree(sdata->u.ap.beacon_head);
+		kfree(sdata->u.ap.beacon_tail);
+
+		if (dev != local->mdev) {
+			struct sk_buff *skb;
+			while ((skb = skb_dequeue(&sdata->u.ap.ps_bc_buf))) {
+				local->total_ps_buffered--;
+				dev_kfree_skb(skb);
+			}
+		}
+
+		break;
+	}
+	case IEEE80211_IF_TYPE_WDS:
+		sta = sta_info_get(local, sdata->u.wds.remote_addr);
+		if (sta) {
+			sta_info_release(local, sta);
+			sta_info_free(local, sta, 0);
+		} else {
+#ifdef CONFIG_D80211_VERBOSE_DEBUG
+			printk(KERN_DEBUG "%s: Someone had deleted my STA "
+			       "entry for the WDS link\n", dev->name);
+#endif /* CONFIG_D80211_VERBOSE_DEBUG */
+		}
+		break;
+	case IEEE80211_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_IBSS:
+		del_timer_sync(&sdata->u.sta.timer);
+		if (local->scan_timer.data == (unsigned long) sdata->dev)
+			del_timer_sync(&local->scan_timer);
+		kfree(sdata->u.sta.extra_ie);
+		sdata->u.sta.extra_ie = NULL;
+		kfree(sdata->u.sta.assocreq_ies);
+		sdata->u.sta.assocreq_ies = NULL;
+		kfree(sdata->u.sta.assocresp_ies);
+		sdata->u.sta.assocresp_ies = NULL;
+		if (sdata->u.sta.probe_resp) {
+			dev_kfree_skb(sdata->u.sta.probe_resp);
+			sdata->u.sta.probe_resp = NULL;
+		}
+
+		break;
+	}
+
+	/* remove all STAs that are bound to this virtual interface */
+	sta_info_flush(local, dev);
+
+	memset(&sdata->u, 0, sizeof(sdata->u));
+	ieee80211_if_sdata_init(sdata);
+}
+
+/* Must be called with rtnl lock held. */
+void __ieee80211_if_del(struct ieee80211_local *local,
+			struct ieee80211_sub_if_data *sdata)
+{
+	struct net_device *dev = sdata->dev;
+
+	ieee80211_if_reinit(dev);
+	list_del(&sdata->list);
+	ieee80211_proc_deinit_virtual(dev);
+	unregister_netdevice(dev);
+	/* Default data device and management device are allocated with the
+	 * master device. All other devices are separately allocated and will
+	 * be freed by net_device->destructor (i. e. ieee80211_if_free). */
+}
+
+/* Must be called with rtnl lock held. */
+int ieee80211_if_remove(struct net_device *dev, const char *name, int id)
+{
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata, *n;
+
+	ASSERT_RTNL();
+
+	/* Make sure not to touch sdata->master since it may
+	 * have already been deleted, etc. */
+
+	list_for_each_entry_safe(sdata, n, &local->sub_if_list, list) {
+		if ((sdata->type == id || id == -1) &&
+		    strcmp(name, sdata->dev->name) == 0 &&
+		    sdata->dev != local->mdev &&
+		    sdata->dev != local->wdev &&
+		    sdata->dev != local->apdev) {
+			__ieee80211_if_del(local, sdata);
+			return 0;
+		}
+	}
+	return -ENODEV;
+}
+
+void ieee80211_if_free(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+
+	BUG_ON(dev == local->mdev || dev == local->wdev || dev == local->apdev);
+	kfree(dev);
+}
+
+/* Must be called with rtnl lock held. */
+void ieee80211_if_flush(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata, *n;
+
+	ASSERT_RTNL();
+	list_for_each_entry_safe(sdata, n, &local->sub_if_list, list) {
+		__ieee80211_if_del(local, sdata);
+	}
+}
+
+void ieee80211_if_del(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	rtnl_lock();
+	__ieee80211_if_del(local, sdata);
+	rtnl_unlock();
+}
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 6279a7a..dfa0ef7 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -922,30 +922,39 @@ static int ieee80211_ioctl_add_if(struct
 {
 	u8 *pos = param->u.if_info.data;
         int left = param_len - ((u8 *) pos - (u8 *) param);
+	struct net_device *new_dev;
+	int res;
 
+	printk(KERN_WARNING "PRISM2_HOSTAPD_ADD_IF ioctl is deprecated!");
         if (param->u.if_info.type == HOSTAP_IF_WDS) {
-                struct ieee80211_if_wds iwds;
                 struct hostapd_if_wds *wds =
 			(struct hostapd_if_wds *) param->u.if_info.data;
 
-                if (left < sizeof(struct ieee80211_if_wds))
+                if (left < sizeof(struct hostapd_if_wds))
                         return -EPROTO;
 
-		memcpy(iwds.remote_addr, wds->remote_addr, ETH_ALEN);
-
-		return ieee80211_if_add_wds(dev, param->u.if_info.name,
-					    &iwds, 1);
+		res = ieee80211_if_add(dev, param->u.if_info.name, &new_dev);
+		if (res)
+			return res;
+		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_WDS);
+		res = ieee80211_if_update_wds(new_dev, wds->remote_addr);
+		if (res)
+			ieee80211_if_del(new_dev);
+		return res;
 	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
-		struct hostapd_if_vlan *vlan = (struct hostapd_if_vlan *) pos;
-		struct ieee80211_if_vlan ivlan;
-
 		if (left < sizeof(struct hostapd_if_vlan))
 			return -EPROTO;
 
-                ivlan.id = vlan->id;
-
-		return ieee80211_if_add_vlan(dev, param->u.if_info.name,
-					     &ivlan, 1);
+		res = ieee80211_if_add(dev, param->u.if_info.name, &new_dev);
+		if (res)
+			return res;
+		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_VLAN);
+#if 0
+		res = ieee80211_if_update_vlan(new_dev, vlan->id);
+		if (res)
+			ieee80211_if_del(new_dev);
+#endif
+		return res;
         } else if (param->u.if_info.type == HOSTAP_IF_BSS) {
                 struct hostapd_if_bss *bss =
 			(struct hostapd_if_bss *) param->u.if_info.data;
@@ -953,8 +962,12 @@ static int ieee80211_ioctl_add_if(struct
                 if (left < sizeof(struct hostapd_if_bss))
                         return -EPROTO;
 
-		return ieee80211_if_add_ap(dev, param->u.if_info.name,
-					     bss->bssid, 1);
+		res = ieee80211_if_add(dev, param->u.if_info.name, &new_dev);
+		if (res)
+			return res;
+		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_AP);
+		memcpy(new_dev->dev_addr, bss->bssid, ETH_ALEN);
+		return 0;
         } else if (param->u.if_info.type == HOSTAP_IF_STA) {
 #if 0
                 struct hostapd_if_sta *sta =
@@ -964,7 +977,11 @@ #endif
                 if (left < sizeof(struct hostapd_if_sta))
                         return -EPROTO;
 
-		return ieee80211_if_add_sta(dev, param->u.if_info.name, 1);
+		res = ieee80211_if_add(dev, param->u.if_info.name, &new_dev);
+		if (res)
+			return res;
+		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_STA);
+		return 0;
 	} else
                 return -EINVAL;
 
@@ -975,17 +992,14 @@ #endif
 static int ieee80211_ioctl_remove_if(struct net_device *dev,
 				     struct prism2_hostapd_param *param)
 {
-	if (param->u.if_info.type == HOSTAP_IF_WDS) {
-		return ieee80211_if_remove_wds(dev, param->u.if_info.name, 1);
-	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
-		return ieee80211_if_remove_vlan(dev, param->u.if_info.name, 1);
-	} else if (param->u.if_info.type == HOSTAP_IF_BSS) {
-		return ieee80211_if_remove_ap(dev, param->u.if_info.name, 1);
-	} else if (param->u.if_info.type == HOSTAP_IF_STA) {
-		return ieee80211_if_remove_sta(dev, param->u.if_info.name, 1);
-	} else {
+	if (param->u.if_info.type != HOSTAP_IF_WDS &&
+	    param->u.if_info.type != HOSTAP_IF_VLAN &&
+	    param->u.if_info.type != HOSTAP_IF_BSS &&
+	    param->u.if_info.type != HOSTAP_IF_STA) {
                 return -EINVAL;
 	}
+	return ieee80211_if_remove(dev, param->u.if_info.name,
+				   param->u.if_info.type);
 }
 
 
@@ -1027,7 +1041,8 @@ static int ieee80211_ioctl_update_if(str
 static int ieee80211_ioctl_flush_ifs(struct net_device *dev,
 				     struct prism2_hostapd_param *param)
 {
-	return ieee80211_if_flush(dev, 1);
+	ieee80211_if_flush(dev);
+	return 0;
 }
 
 
@@ -1575,7 +1590,7 @@ static int ieee80211_unmask_channels(str
 }
 
 
-static int ieee80211_init_client(struct net_device *dev)
+int ieee80211_init_client(struct net_device *dev)
 {
 	if (ieee80211_regdom == 0x40)
 		channel_range = ieee80211_mkk_channels;
@@ -1588,35 +1603,39 @@ static int ieee80211_ioctl_siwmode(struc
 				   struct iw_request_info *info,
 				   __u32 *mode, char *extra)
 {
-#if 0
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	int type;
 
-	if (!ieee80211_is_client_mode(local->conf.mode) &&
-	    ieee80211_is_client_mode(*mode)) {
-		ieee80211_init_client(dev);
+	if (sdata->type == IEEE80211_IF_TYPE_VLAN)
+		return -EOPNOTSUPP;
+	if (netif_running(dev))
+		return -EBUSY;
+
+	switch (*mode) {
+	case IW_MODE_MASTER:
+		type = IEEE80211_IF_TYPE_AP;
+		break;
+	case IW_MODE_INFRA:
+		type = IEEE80211_IF_TYPE_STA;
+		break;
+	case IW_MODE_ADHOC:
+		type = IEEE80211_IF_TYPE_IBSS;
+		break;
+	case IW_MODE_MONITOR:
+		type = IEEE80211_IF_TYPE_MNTR;
+		break;
+	case IW_MODE_REPEAT:
+		type = IEEE80211_IF_TYPE_WDS;
+		break;
+	default:
+		return -EINVAL;
 	}
-	if (local->conf.mode != *mode) {
-		struct ieee80211_sub_if_data *sdata =
-			IEEE80211_DEV_TO_SUB_IF(dev);
-		sta_info_flush(local, NULL);
-		if (local->conf.mode == IW_MODE_ADHOC &&
-		    sdata->type == IEEE80211_IF_TYPE_STA) {
-			/* Clear drop_unencrypted when leaving adhoc mode since
-			 * only adhoc mode is using automatic setting for this
-			 * in 80211.o. */
-			sdata->drop_unencrypted = 0;
-		}
-		if (*mode == IW_MODE_MASTER) {
-			/* AP mode does not currently use ACM bits to limit
-			 * TX, so clear the bitfield here. */
-			local->wmm_acm = 0;
-		}
+
+	if (type != sdata->type) {
+		ieee80211_if_reinit(dev);
+		ieee80211_if_set_type(dev, type);
 	}
-	local->conf.mode = *mode;
-	return ieee80211_hw_config(dev);
-#else
-	return -EOPNOTSUPP;
-#endif
+	return 0;
 }
 
 
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 082404f..546e2b7 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -22,17 +22,17 @@ static ssize_t store_add_iface(struct cl
 			       const char *buf, size_t len)
 {
 	struct ieee80211_local *local = to_ieee80211_local(dev);
+	struct net_device *new_dev;
 	int res;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 	if (len > IFNAMSIZ)
 		return -EINVAL;
-	/* Cannot call ieee80211_if_add_sta() with 'locked' parameter equal
-	 * to zero as it would lead to call to register_netdev() and
-	 * interpreting '%d' character in an interface name. */
 	rtnl_lock();
-	res = ieee80211_if_add_sta(local->mdev, buf, 1);
+	res = ieee80211_if_add(local->mdev, buf, &new_dev);
+	if (res == 0)
+		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_STA);
 	rtnl_unlock();
 	return res < 0 ? res : len;
 }
@@ -47,7 +47,9 @@ static ssize_t store_remove_iface(struct
 		return -EPERM;
 	if (len > IFNAMSIZ)
 		return -EINVAL;
-	res = ieee80211_if_remove_sta(local->mdev, buf, 0);
+	rtnl_lock();
+	res = ieee80211_if_remove(local->mdev, buf, -1);
+	rtnl_unlock();
 	return res < 0 ? res : len;
 }
 
-- 
1.3.0

