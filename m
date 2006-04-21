From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 9/17] d80211: remove obsolete stuff
Date: Fri, 21 Apr 2006 22:11:40 +0200 (CEST)
Message-ID: <20060421201140.82A42482C9@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:13191 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932418AbWDUULN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:13 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because any number of interfaces may be added, bss_devs and sta_devs arrays
cannot be fixed-size arrays. We can make them linked lists, but they are
needed for optimalization only (and even that is questionable with
subsequent patches). Let's remove them; we will probably want something
similar later to speed up packet receiving, but let's not bother ourselves
now.

Also, ieee80211_addr_inc is removed. Choosing of MAC address of a new STA
should be matter of userspace. It's responsibility of the stack not to allow
two STAs with the same MAC address to be up - this feature is introduced in
one of subsequent patches.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h         |    3 -
 net/d80211/hostapd_ioctl.h   |    1 
 net/d80211/ieee80211.c       |  164 ++++--------------------------------------
 net/d80211/ieee80211_i.h     |    9 --
 net/d80211/ieee80211_ioctl.c |   70 ------------------
 net/d80211/ieee80211_proc.c  |   12 ---
 net/d80211/ieee80211_sysfs.c |   29 -------
 7 files changed, 16 insertions(+), 272 deletions(-)

3180a84e9351200900e932690feb613d1f799068
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 44417fc..5dff49a 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -277,9 +277,6 @@ struct ieee80211_conf {
         int antenna_def;
         int antenna_mode;
 
-	u8 bssid_mask[ETH_ALEN];	/* ff:ff:ff:ff:ff:ff = 1 BSSID */
-	int bss_count;
-
 	int atheros_super_ag_compression;
 	int atheros_super_ag_fast_frame;
 	int atheros_super_ag_burst;
diff --git a/net/d80211/hostapd_ioctl.h b/net/d80211/hostapd_ioctl.h
index 42c2bc5..028caf1 100644
--- a/net/d80211/hostapd_ioctl.h
+++ b/net/d80211/hostapd_ioctl.h
@@ -129,7 +129,6 @@ enum {
 	PRISM2_HOSTAPD_SET_CHANNEL_FLAG = 1012,
 	PRISM2_HOSTAPD_SET_REGULATORY_DOMAIN = 1013,
 	PRISM2_HOSTAPD_SET_TX_QUEUE_PARAMS = 1014,
-	PRISM2_HOSTAPD_SET_BSS = 1015,
 	PRISM2_HOSTAPD_GET_TX_STATS = 1016,
 	PRISM2_HOSTAPD_UPDATE_IF = 1017,
 	PRISM2_HOSTAPD_SCAN_REQ = 1019,
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 271c4d9..e3e155e 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1569,17 +1569,14 @@ struct sk_buff * ieee80211_beacon_get(st
 	u8 *b_head, *b_tail;
 	int bh_len, bt_len;
 
-	spin_lock_bh(&local->sub_if_lock);
-	if (bss_idx < 0 || bss_idx >= local->bss_dev_count)
-		bdev = NULL;
-	else {
-		bdev = local->bss_devs[bss_idx];
+	bdev = dev_get_by_index(bss_idx);
+	if (bdev) {
 		sdata = IEEE80211_DEV_TO_SUB_IF(bdev);
 		ap = &sdata->u.ap;
+		dev_put(bdev);
 	}
-	spin_unlock_bh(&local->sub_if_lock);
 
-	if (bdev == NULL || ap == NULL || ap->beacon_head == NULL) {
+	if (ap == NULL || ap->beacon_head == NULL) {
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
 		if (net_ratelimit())
 			printk(KERN_DEBUG "no beacon data avail for idx=%d "
@@ -1646,19 +1643,15 @@ ieee80211_get_buffered_bc(struct net_dev
 	ieee80211_txrx_result res = TXRX_DROP;
 	struct net_device *bdev;
 	struct ieee80211_sub_if_data *sdata;
-	struct ieee80211_if_ap *bss;
+	struct ieee80211_if_ap *bss = NULL;
 
-	spin_lock_bh(&local->sub_if_lock);
-	if (bss_idx < 0 || bss_idx >= local->bss_dev_count) {
-		bdev = NULL;
-		bss = NULL;
-	} else {
-		bdev = local->bss_devs[bss_idx];
+	bdev = dev_get_by_index(bss_idx);
+	if (bdev) {
 		sdata = IEEE80211_DEV_TO_SUB_IF(bdev);
 		bss = &sdata->u.ap;
+		dev_put(bdev);
 	}
-	spin_unlock_bh(&local->sub_if_lock);
-	if (bdev == NULL || bss == NULL || bss->beacon_head == NULL)
+	if (bss == NULL || bss->beacon_head == NULL)
 		return NULL;
 
 	if (bss->dtim_count != 0)
@@ -1911,14 +1904,14 @@ ieee80211_get_wds_dev(struct ieee80211_l
 static struct net_device * ieee80211_own_bssid(struct ieee80211_local *local,
 					       u8 *addr)
 {
-	int i;
 	struct net_device *dev = NULL;
+	struct ieee80211_sub_if_data *sdata;
 
 	spin_lock_bh(&local->sub_if_lock);
-	for (i = 0; i < local->bss_dev_count; i++) {
-		if ((memcmp(local->bss_devs[i]->dev_addr, addr, ETH_ALEN) == 0)
-		) {
-			dev = local->bss_devs[i];
+	list_for_each_entry(sdata, &local->sub_if_list, list) {
+		if (sdata->type == IEEE80211_IF_TYPE_AP &&
+		    memcmp(addr, sdata->dev->dev_addr, ETH_ALEN) == 0) {
+			dev = sdata->dev;
 			break;
 		}
 	}
@@ -1934,31 +1927,9 @@ static struct net_device * ieee80211_sta
 {
 	struct list_head *ptr;
 	int multicast;
-	u8 *own_addr = local->mdev->dev_addr;
 
 	multicast = a1[0] & 0x01;
 
-	/* Try O(1) lookup for a common case of only one AP being used. */
-	if (own_addr[0] == a1[0] && own_addr[1] == a1[1] &&
-	    own_addr[2] == a1[2]) {
-		int index = (((int) a1[3] << 16) | ((int) a1[4] << 8) | a1[5])
-			- (((int) own_addr[3] << 16) |
-			   ((int) own_addr[4] << 8) | own_addr[5]);
-		if (index >= 0 && index < local->conf.bss_count &&
-		    local->sta_devs[index]) {
-			struct net_device *dev = local->sta_devs[index];
-			struct ieee80211_sub_if_data *sdata;
-			sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-			if (memcmp(addr, sdata->u.sta.bssid, ETH_ALEN) == 0) {
-				*sta_multicast = multicast;
-				return dev;
-			}
-		}
-	}
-
-	if (!multicast)
-		return NULL;
-
 	/* Could not find station interface, resort to O(n) lookup. */
 	list_for_each(ptr, &local->sub_if_list) {
 		struct ieee80211_sub_if_data *sdata =
@@ -1982,27 +1953,6 @@ static struct net_device * ieee80211_sta
 }
 
 
-static int ieee80211_own_addr(struct net_device *dev, u8 *addr)
-{
-	struct ieee80211_local *local = dev->priv;
-	u8 *own = dev->dev_addr;
-	int index;
-
-	/* Optimization: assume that BSSID mask does not change for first
-	 * three octets. */
-	if (own[0] != addr[0] || own[1] != addr[1] || own[2] != addr[2])
-		return 0;
-
-	index = (((int) addr[3] << 16) | ((int) addr[4] << 8) | addr[5]) -
-		(((int) own[3] << 16) | ((int) own[4] << 8) | own[5]);
-	if (index >= 0 && index < local->conf.bss_count &&
-	    local->sta_devs[index])
-		return 1;
-
-	return 0;
-}
-
-
 static ieee80211_txrx_result
 ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 {
@@ -2719,7 +2669,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 	 * FIX: Filter out multicast to foreign BSSID. */
 	if (rx->sdata->type == IEEE80211_IF_TYPE_STA &&
 	    !MULTICAST_ADDR(hdr->addr1) &&
-	    !ieee80211_own_addr(rx->dev, hdr->addr1))
+	    memcmp(rx->dev->dev_addr, hdr->addr1, ETH_ALEN) != 0)
 		return TXRX_DROP;
 
 	/* Drop disallowed frame classes based on STA auth/assoc state;
@@ -4023,13 +3973,9 @@ static void ieee80211_if_ap_init(struct 
 int ieee80211_if_add_ap(struct net_device *dev, const char *name, u8 *bssid,
 			  int locked)
 {
-        struct ieee80211_local *local = dev->priv;
 	struct net_device *ap_dev = NULL;
         struct ieee80211_sub_if_data *sdata = NULL;
 
-	if (local->bss_dev_count >= local->conf.bss_count)
-		return -ENOBUFS;
-
         if (strlen(name) != 0) {
 		ap_dev = dev_get_by_name(name);
 		if (ap_dev) {
@@ -4046,37 +3992,16 @@ int ieee80211_if_add_ap(struct net_devic
 	sdata = IEEE80211_DEV_TO_SUB_IF(ap_dev);
 	ieee80211_if_ap_init(sdata);
 	ieee80211_proc_init_virtual(ap_dev);
-	spin_lock_bh(&local->sub_if_lock);
-	local->bss_devs[local->bss_dev_count] = ap_dev;
-	local->bss_dev_count++;
-	spin_unlock_bh(&local->sub_if_lock);
 
         return 0;
 }
 
 
-static void ieee80211_addr_inc(u8 *addr)
-{
-	int pos = 5;
-	while (pos >= 0) {
-		addr[pos]++;
-		if (addr[pos] != 0)
-			break;
-		pos--;
-	}
-}
-
-
 int ieee80211_if_add_sta(struct net_device *dev, const char *name, int locked)
 {
-	struct ieee80211_local *local = dev->priv;
 	struct net_device *sta_dev;
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_if_sta *ifsta;
-	int i;
-
-	if (local->sta_dev_count >= local->conf.bss_count)
-		return -ENOBUFS;
 
 	if (strlen(name) != 0) {
 		sta_dev = dev_get_by_name(name);
@@ -4095,24 +4020,6 @@ int ieee80211_if_add_sta(struct net_devi
 	sdata->type = IEEE80211_IF_TYPE_STA;
 	ieee80211_proc_init_virtual(sta_dev);
 
-	spin_lock_bh(&local->sub_if_lock);
-	for (i = 0; i < local->conf.bss_count; i++) {
-		if (local->sta_devs[i] == NULL) {
-			local->sta_devs[i] = sta_dev;
-			local->sta_dev_count++;
-			printk(KERN_DEBUG "%s: using STA entry %d\n",
-			       sta_dev->name, i);
-			while (i > 0) {
-				ieee80211_addr_inc(sta_dev->dev_addr);
-				i--;
-			}
-			printk(KERN_DEBUG "%s: MAC address " MACSTR "\n",
-			       sta_dev->name, MAC2STR(sta_dev->dev_addr));
-			break;
-		}
-	}
-	spin_unlock_bh(&local->sub_if_lock);
-
 	init_timer(&ifsta->timer);
 	ifsta->timer.data = (unsigned long) sta_dev;
 	ifsta->timer.function = ieee80211_sta_timer;
@@ -4132,7 +4039,7 @@ static void ieee80211_if_del(struct ieee
 {
         struct sta_info *sta;
 	u8 addr[ETH_ALEN];
-	int i, j;
+	int i;
         struct list_head *ptr, *n;
 
 	memset(addr, 0xff, ETH_ALEN);
@@ -4170,23 +4077,6 @@ #endif
 
 		kfree(sdata->u.ap.beacon_head);
 		kfree(sdata->u.ap.beacon_tail);
-		spin_lock_bh(&local->sub_if_lock);
-		for (j = 0; j < local->bss_dev_count; j++) {
-			if (sdata->dev == local->bss_devs[j]) {
-				if (j + 1 < local->bss_dev_count) {
-					memcpy(&local->bss_devs[j],
-					       &local->bss_devs[j + 1],
-					       (local->bss_dev_count - j - 1) *
-					       sizeof(local->bss_devs[0]));
-					local->bss_devs[local->bss_dev_count -
-							1] = NULL;
-				} else
-					local->bss_devs[j] = NULL;
-				local->bss_dev_count--;
-				break;
-			}
-		}
-		spin_unlock_bh(&local->sub_if_lock);
 
 		if (sdata->dev != local->mdev) {
 			struct sk_buff *skb;
@@ -4223,13 +4113,6 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 			dev_kfree_skb(sdata->u.sta.probe_resp);
 			sdata->u.sta.probe_resp = NULL;
 		}
-		for (i = 0; i < local->conf.bss_count; i++) {
-			if (local->sta_devs[i] == sdata->dev) {
-				local->sta_devs[i] = NULL;
-				local->sta_dev_count--;
-				break;
-			}
-		}
 
 		break;
 	}
@@ -4428,17 +4311,6 @@ struct net_device *ieee80211_alloc_hw(si
 	local->conf.calib_int = 60;
 	local->rate_ctrl_num_up = RATE_CONTROL_NUM_UP;
 	local->rate_ctrl_num_down = RATE_CONTROL_NUM_DOWN;
-	local->conf.bss_count = 1;
-	memset(local->conf.bssid_mask, 0xff, ETH_ALEN);
-	local->bss_devs = kmalloc(sizeof(struct net_device *), GFP_KERNEL);
-	if (local->bss_devs == NULL)
-		goto fail;
-	local->bss_devs[0] = local->wdev;
-	local->bss_dev_count = 1;
-	local->sta_devs = kmalloc(sizeof(struct net_device *), GFP_KERNEL);
-	if (local->sta_devs == NULL)
-		goto fail;
-	local->sta_devs[0] = NULL;
 
         local->scan.in_scan = 0;
 	local->hw_modes = (unsigned int) -1;
@@ -4694,10 +4566,6 @@ void ieee80211_unregister_hw(struct net_
 
 void ieee80211_free_hw(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
-
-	kfree(local->sta_devs);
-	kfree(local->bss_devs);
 	kfree(dev);
 }
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index d42b6fe..3766232 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -372,13 +372,6 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 
         spinlock_t sub_if_lock; /* mutex for STA data structures */
         struct list_head sub_if_list;
-	struct net_device **bss_devs; /* pointer to IF_TYPE_AP devices for
-				       * quick access to BSS data */
-	int bss_dev_count; /* number of used entries in bss_devs; note: the
-			    * total size of bss_devs array is stored in
-			    * conf.bss_count */
-	struct net_device **sta_devs; /* pointer to IF_TYPE_STA devices */
-	int sta_dev_count; /* number of used entries in sta_devs */
 	int sta_scanning;
 	int scan_hw_mode_idx;
 	int scan_channel_idx;
@@ -553,8 +546,6 @@ int ieee80211_if_remove_sta(struct net_d
 /* ieee80211_ioctl.c */
 int ieee80211_set_compression(struct ieee80211_local *local,
 			      struct net_device *dev, struct sta_info *sta);
-int ieee80211_set_bss_count(struct net_device *dev, int new_count,
-			    u8 *bssid_mask);
 /* ieee80211_sta.c */
 void ieee80211_sta_timer(unsigned long ptr);
 void ieee80211_sta_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 2fd910d..461e2d9 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1223,73 +1223,6 @@ static int ieee80211_ioctl_get_tx_stats(
 }
 
 
-int ieee80211_set_bss_count(struct net_device *dev, int new_count,
-			    u8 *bssid_mask)
-{
-	struct ieee80211_local *local = dev->priv;
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
-	int i, bss_count;
-	struct net_device **bss_devs, **prev;
-	struct net_device **sta_devs, **prev_sta_devs;
-
-	bss_count = 0;
-	for (i = 0; i < conf->bss_count; i++) {
-		if (local->bss_devs[i])
-			bss_count++;
-	}
-
-	if (new_count < bss_count) {
-		printk(KERN_DEBUG "%s: invalid BSS count %d (in use: %d)\n",
-		       dev->name, new_count, bss_count);
-		return -EINVAL;
-	}
-
-	bss_devs = kmalloc(new_count * sizeof(struct net_device *),
-			   GFP_KERNEL);
-	if (bss_devs == NULL)
-		return -ENOMEM;
-	sta_devs = kmalloc(new_count * sizeof(struct net_device *),
-			   GFP_KERNEL);
-	if (sta_devs == NULL) {
-		kfree(bss_devs);
-		return -ENOMEM;
-	}
-
-	spin_lock_bh(&local->sub_if_lock);
-	memcpy(bss_devs, local->bss_devs,
-	       bss_count * sizeof(struct net_device *));
-	memset(&bss_devs[bss_count], 0,
-	       (new_count - bss_count) * sizeof(struct net_device *));
-
-	if (bssid_mask)
-		memcpy(conf->bssid_mask, bssid_mask, ETH_ALEN);
-
-	prev = local->bss_devs;
-	local->bss_devs = bss_devs;
-	conf->bss_count = new_count;
-
-	memcpy(sta_devs, local->sta_devs,
-	       bss_count * sizeof(struct net_device *));
-	memset(&sta_devs[bss_count], 0,
-	       (new_count - bss_count) * sizeof(struct net_device *));
-	prev_sta_devs = local->sta_devs;
-	local->sta_devs = sta_devs;
-
-	spin_unlock_bh(&local->sub_if_lock);
-	kfree(prev);
-	kfree(prev_sta_devs);
-
-	return ieee80211_hw_config(dev);
-}
-
-static int ieee80211_ioctl_set_bss(struct net_device *dev,
-				   struct prism2_hostapd_param *param)
-{
-	return ieee80211_set_bss_count(dev, param->u.set_bss.bss_count,
-				       param->u.set_bss.bssid_mask);
-}
-
-
 static int ieee80211_ioctl_set_channel_flag(struct net_device *dev,
 					    struct prism2_hostapd_param *param)
 {
@@ -1441,9 +1374,6 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 	case PRISM2_HOSTAPD_SET_TX_QUEUE_PARAMS:
 		ret = ieee80211_ioctl_set_tx_queue_params(dev, param);
 		break;
-	case PRISM2_HOSTAPD_SET_BSS:
-		ret = ieee80211_ioctl_set_bss(dev, param);
-		break;
 	case PRISM2_HOSTAPD_GET_TX_STATS:
 		ret = ieee80211_ioctl_get_tx_stats(dev, param);
 		break;
diff --git a/net/d80211/ieee80211_proc.c b/net/d80211/ieee80211_proc.c
index 098599a..a886280 100644
--- a/net/d80211/ieee80211_proc.c
+++ b/net/d80211/ieee80211_proc.c
@@ -374,7 +374,6 @@ static int ieee80211_proc_debug_read(cha
 {
 	char *p = page;
 	struct ieee80211_local *local = (struct ieee80211_local *) data;
-	int i;
 
 	if (off != 0) {
 		*eof = 1;
@@ -439,17 +438,6 @@ #endif /* CONFIG_D80211_DEBUG_COUNTERS *
 
 	p += sprintf(p, "num_scans=%u\n", local->scan.num_scans);
 
-	p += sprintf(p,
-		     "conf.bss_count=%d\n"
-		     "bss_dev_count=%u\n",
-		     local->conf.bss_count, local->bss_dev_count);
-	for (i = 0; i < local->conf.bss_count; i++) {
-		p += sprintf(p, "bss_dev[%d]=%p (%s)\n",
-			     i, local->bss_devs[i],
-			     (i < local->bss_dev_count && local->bss_devs[i]) ?
-			     local->bss_devs[i]->name : "N/A");
-	}
-
 	return (p - page);
 }
 
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 32fb380..082404f 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -51,33 +51,6 @@ static ssize_t store_remove_iface(struct
 	return res < 0 ? res : len;
 }
 
-static ssize_t show_max_iface_count(struct class_device *dev,
-				    char *buf)
-{
-	struct ieee80211_local *local = to_ieee80211_local(dev);
-
-	return sprintf(buf, "%d\n", local->conf.bss_count);
-}
-
-static ssize_t store_max_iface_count(struct class_device *dev,
-				     const char *buf, size_t len)
-{
-	struct ieee80211_local *local = to_ieee80211_local(dev);
-	unsigned long new_count;
-	char *endp;
-	int res;
-
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-	new_count = simple_strtoul(buf, &endp, 0);
-	if (endp == buf)
-		return -EINVAL;
-	rtnl_lock();
-	res = ieee80211_set_bss_count(local->mdev, new_count, NULL);
-	rtnl_unlock();
-	return res < 0 ? res : len;
-}
-
 #ifdef CONFIG_HOTPLUG
 static int ieee80211_uevent(struct class_device *cd, char **envp,
 			    int num_envp, char *buf, int size)
@@ -98,8 +71,6 @@ #endif
 static struct class_device_attribute ieee80211_class_dev_attrs[] = {
 	__ATTR(add_iface, S_IWUSR, NULL, store_add_iface),
 	__ATTR(remove_iface, S_IWUSR, NULL, store_remove_iface),
-	__ATTR(max_iface_count, S_IRUGO | S_IWUSR,
-	       show_max_iface_count, store_max_iface_count),
 	{}
 };
 
-- 
1.3.0

