From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 8/10] d80211: get rid of default management interface
Date: Fri, 21 Apr 2006 22:53:28 +0200 (CEST)
Message-ID: <20060421205328.39BE2482C1@silver.suse.cz>
References: <20060421225314.048983000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:47233 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932444AbWDUUxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:53:00 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421225314.048983000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Default management interface (wlanXap) confuses users. It is only needed for
AP mode (and only until interfaces are converted to use native 802.11
frames).

This patch removes default management interface. When a new interface is
switched to AP mode, a management interface is created automatically. This
also fixes some problems with multiple AP interfaces - now you have
different management interface for each AP interface.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |  204 +++++++++++++++++++++++++-----------------
 net/d80211/ieee80211_i.h     |    6 +
 net/d80211/ieee80211_iface.c |   73 ++++++++++++++-
 3 files changed, 193 insertions(+), 90 deletions(-)

726d59fb8b157daf368b097cef7d3d2ed8c61784
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 2386454..31f979c 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -59,6 +59,8 @@ static int rate_control_initialize(struc
 
 static u8 * ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len);
 
+static void ieee80211_rx_michael_mic_report(struct ieee80211_txrx_data *rx,
+					    struct ieee80211_hdr *hdr);
 
 struct ieee80211_key_conf *
 ieee80211_key_data2conf(struct ieee80211_local *local,
@@ -1954,8 +1956,6 @@ static inline int identical_mac_addr_all
 {
 	return (type1 == IEEE80211_IF_TYPE_MNTR ||
 		type2 == IEEE80211_IF_TYPE_MNTR ||
-		type1 == IEEE80211_IF_TYPE_MGMT ||
-		type2 == IEEE80211_IF_TYPE_MGMT ||
 		(type1 == IEEE80211_IF_TYPE_AP &&
 		 type2 == IEEE80211_IF_TYPE_WDS) ||
 		(type1 == IEEE80211_IF_TYPE_WDS &&
@@ -1990,6 +1990,20 @@ static int ieee80211_master_stop(struct 
 	return 0;
 }
 
+static int ieee80211_ap_open(struct net_device *dev)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	if (!netif_running(sdata->u.ap.apdev))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
+static int ieee80211_ap_stop(struct net_device *dev)
+{
+	return 0;
+}
+
 /* Check if running monitor interfaces should go to a "soft monitor" mode
  * and switch them if necessary. */
 static inline void ieee80211_start_soft_monitor(struct ieee80211_local *local)
@@ -2032,7 +2046,6 @@ static int ieee80211_open(struct net_dev
 		struct net_device *ndev = nsdata->dev;
 
 		if (ndev != dev && ndev != local->mdev &&
-		    ndev != local->apdev &&
 		    netif_running(ndev) &&
 		    memcmp(dev->dev_addr, ndev->dev_addr, ETH_ALEN) == 0 &&
 		    !identical_mac_addr_allowed(sdata->type, nsdata->type)) {
@@ -2087,7 +2100,9 @@ static int ieee80211_open(struct net_dev
 	}
         local->open_count++;
 
-	if (sdata->type == IEEE80211_IF_TYPE_MNTR)
+	if (sdata->type == IEEE80211_IF_TYPE_AP)
+		dev_open(sdata->u.ap.apdev);
+	else if (sdata->type == IEEE80211_IF_TYPE_MNTR)
 		local->monitors++;
 
 	netif_start_queue(dev);
@@ -2112,7 +2127,9 @@ static int ieee80211_stop(struct net_dev
 
         netif_stop_queue(dev);
 
-	if (sdata->type == IEEE80211_IF_TYPE_MNTR)
+	if (sdata->type == IEEE80211_IF_TYPE_AP)
+		dev_close(sdata->u.ap.apdev);
+	else if (sdata->type == IEEE80211_IF_TYPE_MNTR)
 		local->monitors--;
 
 	local->open_count--;
@@ -2356,6 +2373,7 @@ ieee80211_get_rate(struct ieee80211_loca
 }
 
 
+/* If dev is master device, skb will be sent to all AP interfaces. */
 void
 ieee80211_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
 		  struct ieee80211_rx_status *status, u32 msg_type)
@@ -2363,13 +2381,15 @@ ieee80211_rx_mgmt(struct net_device *dev
         struct ieee80211_local *local = dev->priv;
         struct ieee80211_frame_info *fi;
         size_t hlen;
-        struct ieee80211_sub_if_data *sdata;
+        struct ieee80211_sub_if_data *sdata, *apsdata, *prev = NULL;
 
-	if (msg_type != ieee80211_msg_monitor)
-		dev = local->apdev;
-        skb->dev = dev;
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
-        sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	if (msg_type != ieee80211_msg_monitor &&
+	    sdata->type != IEEE80211_IF_TYPE_AP && dev != local->mdev) {
+		dev_kfree_skb(skb);
+		return;
+	}
 
 	if (skb_headroom(skb) < sizeof(struct ieee80211_frame_info)) {
 		I802_DEBUG_INC(local->rx_expand_skb_head);
@@ -2443,15 +2463,56 @@ ieee80211_rx_mgmt(struct net_device *dev
                 fi->ssi_type = htonl(ieee80211_ssi_none);
         }
 
-        sdata->stats.rx_packets++;
-        sdata->stats.rx_bytes += skb->len;
-
         skb->mac.raw = skb->data;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->pkt_type = PACKET_OTHERHOST;
 	skb->protocol = __constant_htons(ETH_P_802_2);
 	memset(skb->cb, 0, sizeof(skb->cb));
-        netif_rx(skb);
+
+	if (msg_type == ieee80211_msg_monitor) {
+		skb->dev = dev;
+		sdata->stats.rx_packets++;
+		sdata->stats.rx_bytes += skb->len;
+		netif_rx(skb);
+		return;
+	}
+
+	if (dev == local->mdev) {
+		list_for_each_entry(sdata, &local->sub_if_list, list) {
+			if (sdata->type != IEEE80211_IF_TYPE_AP ||
+			    sdata->dev == local->mdev)
+				continue;
+			if (prev) {
+				struct sk_buff *skb_new;
+
+				skb_new = skb_copy(skb, GFP_ATOMIC);
+				if (skb_new == NULL) {
+					if (net_ratelimit()) {
+						printk(KERN_DEBUG "%s: failed "
+						       "to copy message for %s",
+						       dev->name,
+						       prev->u.ap.apdev->name);
+					}
+					continue;
+				}
+				skb_new->dev = prev->u.ap.apdev;
+				apsdata = IEEE80211_DEV_TO_SUB_IF(skb_new->dev);
+				apsdata->stats.rx_packets++;
+				apsdata->stats.rx_bytes += skb_new->len;
+				netif_rx(skb_new);
+			}
+			prev = sdata;
+		}
+		sdata = prev;
+	}
+	if (sdata) {
+		skb->dev = sdata->u.ap.apdev;
+		apsdata = IEEE80211_DEV_TO_SUB_IF(skb->dev);
+		apsdata->stats.rx_packets++;
+		apsdata->stats.rx_bytes += skb->len;
+		netif_rx(skb);
+	} else
+		dev_kfree_skb(skb);
 }
 
 
@@ -2839,6 +2900,11 @@ ieee80211_rx_h_check(struct ieee80211_tx
 	int always_sta_key;
 	hdr = (struct ieee80211_hdr *) rx->skb->data;
 
+        if ((rx->u.rx.status->flag & RX_FLAG_MMIC_ERROR)) {
+		ieee80211_rx_michael_mic_report(rx, hdr);
+		return TXRX_QUEUED;
+        }
+
 	/* Drop duplicate 802.11 retransmissions (IEEE 802.11 Chap. 9.2.9) */
 	if (rx->sta && !is_multicast_ether_addr(hdr->addr1)) {
 		if (unlikely(rx->fc & WLAN_FC_RETRY &&
@@ -3207,10 +3273,8 @@ static u8 * ieee80211_get_bssid(struct i
 	return NULL;
 }
 
-static void ieee80211_rx_michael_mic_report(struct net_device *dev,
-					    struct ieee80211_hdr *hdr,
-					    struct sta_info *sta,
-					    struct ieee80211_txrx_data *rx)
+static void ieee80211_rx_michael_mic_report(struct ieee80211_txrx_data *rx,
+					    struct ieee80211_hdr *hdr)
 {
 	int keyidx, hdrlen;
 
@@ -3224,22 +3288,22 @@ static void ieee80211_rx_michael_mic_rep
 	 * frames (hw does not verify MIC for them). */
 	printk(KERN_DEBUG "%s: TKIP hwaccel reported Michael MIC "
 	       "failure from " MACSTR " to " MACSTR " keyidx=%d\n",
-	       dev->name, MAC2STR(hdr->addr2), MAC2STR(hdr->addr1), keyidx);
+	       rx->dev->name, MAC2STR(hdr->addr2), MAC2STR(hdr->addr1), keyidx);
 
-	if (sta == NULL) {
+	if (rx->sta == NULL) {
 		/* Some hardware versions seem to generate incorrect
 		 * Michael MIC reports; ignore them to avoid triggering
 		 * countermeasures. */
 		printk(KERN_DEBUG "%s: ignored spurious Michael MIC "
 		       "error for unknown address " MACSTR "\n",
-		       dev->name, MAC2STR(hdr->addr2));
+		       rx->dev->name, MAC2STR(hdr->addr2));
 		goto ignore;
 	}
 
 	if (!(rx->fc & WLAN_FC_ISWEP)) {
 		printk(KERN_DEBUG "%s: ignored spurious Michael MIC "
 		       "error for a frame with no ISWEP flag (src "
-		       MACSTR ")\n", dev->name, MAC2STR(hdr->addr2));
+		       MACSTR ")\n", rx->dev->name, MAC2STR(hdr->addr2));
 		goto ignore;
 	}
 
@@ -3253,7 +3317,8 @@ static void ieee80211_rx_michael_mic_rep
 		if (keyidx) {
 			printk(KERN_DEBUG "%s: ignored Michael MIC error for "
 			       "a frame with non-zero keyidx (%d) (src " MACSTR
-			       ")\n", dev->name, keyidx, MAC2STR(hdr->addr2));
+			       ")\n", rx->dev->name, keyidx,
+			       MAC2STR(hdr->addr2));
 			goto ignore;
 		}
 	}
@@ -3264,7 +3329,7 @@ static void ieee80211_rx_michael_mic_rep
 		printk(KERN_DEBUG "%s: ignored spurious Michael MIC "
 		       "error for a frame that cannot be encrypted "
 		       "(fc=0x%04x) (src " MACSTR ")\n",
-		       dev->name, rx->fc, MAC2STR(hdr->addr2));
+		       rx->dev->name, rx->fc, MAC2STR(hdr->addr2));
 		goto ignore;
 	}
 
@@ -3355,11 +3420,6 @@ void __ieee80211_rx(struct net_device *d
 	else
 		sta = rx.sta = NULL;
 
-        if ((status->flag & RX_FLAG_MMIC_ERROR)) {
-		ieee80211_rx_michael_mic_report(dev, hdr, sta, &rx);
-		goto end;
-        }
-
 	if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS) &&
 	    !local->iff_promiscs && !multicast) {
 		rx.dev = sta->dev;
@@ -3444,7 +3504,6 @@ void __ieee80211_rx(struct net_device *d
 			dev_kfree_skb(skb);
 	}
 
-  end:
 	if (sta)
                 sta_info_release(local, sta);
 }
@@ -3761,6 +3820,7 @@ void ieee80211_tx_status(struct net_devi
 	struct sk_buff *skb2;
         struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
         struct ieee80211_local *local = dev->priv;
+	struct net_device *odev;
 	u16 frag, type;
 	u32 msg_type;
 
@@ -3894,7 +3954,21 @@ #endif /* IEEE80211_LEDS */
 	skb = skb2;
 
         /* Send frame to hostapd */
-        ieee80211_rx_mgmt(dev, skb, NULL, msg_type);
+	odev = dev_get_by_index(status->control.ifindex);
+	if (unlikely(odev && !is_ieee80211_device(odev))) {
+		dev_put(odev);
+		odev = NULL;
+	}
+	if (unlikely(!odev)) {
+#ifdef CONFIG_D80211_VERBOSE_DEBUG
+		printk(KERN_DEBUG "%s: Discarded tx_status from nonexistent "
+		       "device\n", dev->name);
+#endif
+		dev_kfree_skb(skb);
+		return;
+	}
+	ieee80211_rx_mgmt(odev, skb, NULL, msg_type);
+	dev_put(odev);
 }
 
 
@@ -3998,6 +4072,19 @@ void ieee80211_if_setup(struct net_devic
 	dev->destructor = ieee80211_if_free;
 }
 
+void ieee80211_if_ap_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+	dev->hard_start_xmit = ieee80211_mgmt_start_xmit;
+	dev->change_mtu = ieee80211_change_mtu_apdev;
+	dev->get_stats = ieee80211_get_stats;
+	dev->open = ieee80211_ap_open;
+	dev->stop = ieee80211_ap_stop;
+	dev->type = ARPHRD_IEEE80211_PRISM;
+	dev->hard_header_parse = header_parse_80211;
+	dev->tx_queue_len = 0;
+	dev->destructor = ieee80211_if_free;
+}
 
 static void ieee80211_precalc_rates(struct ieee80211_hw *hw)
 {
@@ -4018,7 +4105,7 @@ static void ieee80211_precalc_rates(stru
 struct net_device *ieee80211_alloc_hw(size_t priv_data_len,
 				      void (*setup)(struct net_device *))
 {
-	struct net_device *apdev, *mdev;
+	struct net_device *mdev;
         struct ieee80211_local *local;
         struct ieee80211_sub_if_data *sdata;
 	int alloc_size;
@@ -4038,17 +4125,11 @@ struct net_device *ieee80211_alloc_hw(si
          * 0b84 *****************
          *      * hw_priv       *
          * 1664 *****************
-         *      * ap net_dev    *
-         * 17c0 *****************
-         *      * sub_if        *
-	 *      *****************
          */
         alloc_size = sizeof(struct net_device) +
                 sizeof(struct ieee80211_sub_if_data) + 3 +
                 sizeof(struct ieee80211_local) + 3 +
                 priv_data_len + 3 +
-                sizeof(struct net_device) + 3 +
-		sizeof(struct ieee80211_sub_if_data) + 3 +
 		4096;
         mdev = (struct net_device *) kzalloc(alloc_size, GFP_KERNEL);
 	if (mdev == NULL)
@@ -4061,15 +4142,10 @@ struct net_device *ieee80211_alloc_hw(si
 	local = mdev->priv;
 	local->hw_priv = (void *)
 		((char *) local + ((sizeof(struct ieee80211_local) + 3) & ~3));
-	apdev = (struct net_device *)
-		((char *) local->hw_priv + ((priv_data_len + 3) & ~3));
 
 	ether_setup(mdev);
 	memcpy(mdev->name, "wlan%d", 7);
 
-	if (strlen(mdev->name) + 2 >= sizeof(mdev->name))
-		goto fail;
-
 	local->dev_index = -1;
 	local->mdev = mdev;
         local->rx_handlers = ieee80211_rx_handlers;
@@ -4104,28 +4180,6 @@ struct net_device *ieee80211_alloc_hw(si
 
         ieee80211_if_init(mdev);
 
-        apdev = (struct net_device *)
-		((char *) local->hw_priv + ((priv_data_len + 3) & ~3));
-        local->apdev = apdev;
-	ether_setup(apdev);
-	apdev->priv = local;
-	apdev->hard_start_xmit = ieee80211_mgmt_start_xmit;
-	apdev->change_mtu = ieee80211_change_mtu_apdev;
-	apdev->get_stats = ieee80211_get_stats;
-        apdev->open = ieee80211_open;
-        apdev->stop = ieee80211_stop;
-	apdev->type = ARPHRD_IEEE80211_PRISM;
-        apdev->hard_header_parse = header_parse_80211;
-	apdev->tx_queue_len = 0;
-	sprintf(apdev->name, "%sap", mdev->name);
-
-        sdata = IEEE80211_DEV_TO_SUB_IF(apdev);
-        sdata->type = IEEE80211_IF_TYPE_MGMT;
-        sdata->dev = apdev;
-        sdata->master = mdev;
-        sdata->local = local;
-        list_add_tail(&sdata->list, &local->sub_if_list);
-
 	mdev->hard_start_xmit = ieee80211_master_start_xmit;
 	mdev->wireless_handlers =
 		(struct iw_handler_def *) &ieee80211_iw_handler_def;
@@ -4155,10 +4209,6 @@ struct net_device *ieee80211_alloc_hw(si
 		setup(mdev);
 
 	return mdev;
-
- fail:
-	ieee80211_free_hw(mdev);
-	return NULL;
 }
 
 
@@ -4192,15 +4242,11 @@ int ieee80211_register_hw(struct net_dev
 
 	sta_info_start(local);
 
-	result = register_netdev(local->apdev);
-	if (result < 0)
-		goto fail_1st_dev;
-
 	if (hw->fraglist)
 		dev->features |= NETIF_F_FRAGLIST;
 	result = register_netdev(dev);
 	if (result < 0)
-		goto fail_2nd_dev;
+		goto fail_dev;
 
 	if (rate_control_initialize(local) < 0) {
 		printk(KERN_DEBUG "%s: Failed to initialize rate control "
@@ -4217,9 +4263,7 @@ int ieee80211_register_hw(struct net_dev
 
 fail_rate:
 	unregister_netdev(dev);
-fail_2nd_dev:
-	unregister_netdev(local->apdev);
-fail_1st_dev:
+fail_dev:
 	sta_info_stop(local);
 	ieee80211_unregister_sysfs(local);
 fail_sysfs:
@@ -4238,12 +4282,6 @@ int ieee80211_update_hw(struct net_devic
 	if (hw->queues == 0)
 		hw->queues = 1;
 
-	memcpy(local->apdev->dev_addr, dev->dev_addr, ETH_ALEN);
-	local->apdev->base_addr = dev->base_addr;
-	local->apdev->irq = dev->irq;
-	local->apdev->mem_start = dev->mem_start;
-	local->apdev->mem_end = dev->mem_end;
-
 	if (!hw->modes || !hw->modes->channels || !hw->modes->rates ||
 	    !hw->modes->num_channels || !hw->modes->num_rates)
 		return -1;
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 77517c9..ea1d9ab 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -189,6 +189,8 @@ typedef ieee80211_txrx_result (*ieee8021
 (struct ieee80211_txrx_data *rx);
 
 struct ieee80211_if_ap {
+	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
+
 	u8 *beacon_head, *beacon_tail;
 	int beacon_head_len, beacon_tail_len;
 
@@ -317,7 +319,6 @@ struct ieee80211_local {
 	struct ieee80211_hw *hw;
 	void *hw_priv;
 	struct net_device *mdev; /* wlan# - "master" 802.11 device */
-	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
 	int open_count;
 	int monitors;
 	struct ieee80211_conf conf;
@@ -518,6 +519,7 @@ void ieee80211_prepare_rates(struct net_
 void ieee80211_tx_set_iswep(struct ieee80211_txrx_data *tx);
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
 void ieee80211_if_setup(struct net_device *dev);
+void ieee80211_if_ap_setup(struct net_device *dev);
 
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -586,7 +588,7 @@ int ieee80211_dev_find_index(struct ieee
 /* ieee80211_iface.c */
 int ieee80211_if_add(struct net_device *dev, const char *name,
 		     struct net_device **new_dev);
-void ieee80211_if_set_type(struct net_device *dev, int type);
+int ieee80211_if_set_type(struct net_device *dev, int type);
 void ieee80211_if_reinit(struct net_device *dev);
 void __ieee80211_if_del(struct ieee80211_local *local,
 			struct ieee80211_sub_if_data *sdata);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 58fd946..d71d4f9 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -87,9 +87,65 @@ int ieee80211_if_add(struct net_device *
 	return 0;
 }
 
-void ieee80211_if_set_type(struct net_device *dev, int type)
+static int ieee80211_if_add_apdev(struct net_device *dev)
+{
+	struct net_device *ndev;
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata, *nsdata;
+	int alloc_size, ret;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	ASSERT_RTNL();
+	alloc_size = sizeof(struct net_device) + 3 +
+		sizeof(struct ieee80211_sub_if_data) + 3;
+
+	ndev = (struct net_device *) kzalloc(alloc_size, GFP_KERNEL);
+	if (ndev == NULL)
+		return -ENOMEM;
+	snprintf(ndev->name, IFNAMSIZ, "%sap", dev->name);
+
+	ndev->priv = local;
+	memcpy(ndev->dev_addr, dev->dev_addr, ETH_ALEN);
+	ndev->base_addr = dev->base_addr;
+	ndev->irq = dev->irq;
+	ndev->mem_start = dev->mem_start;
+	ndev->mem_end = dev->mem_end;
+	ieee80211_if_ap_setup(ndev);
+
+	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
+	nsdata->type = IEEE80211_IF_TYPE_AP;
+	nsdata->master = local->mdev;
+	nsdata->dev = ndev;
+	nsdata->local = local;
+	ieee80211_if_sdata_init(nsdata);
+
+	ret = register_netdevice(ndev);
+	if (ret) {
+		if (ret == -EEXIST)
+			printk(KERN_DEBUG "%s: apdev name %s already exists\n",
+			       dev->name, ndev->name);
+		kfree(ndev);
+		return ret;
+	}
+	sdata->u.ap.apdev = ndev;
+	nsdata->u.ap.apdev = dev;
+	return 0;
+}
+
+static void ieee80211_if_del_apdev(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct net_device *apdev;
+
+	ASSERT_RTNL();
+	apdev = sdata->u.ap.apdev;
+	unregister_netdevice(apdev);
+}
+
+int ieee80211_if_set_type(struct net_device *dev, int type)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	int res = 0;
 
 	sdata->type = type;
 	switch (type) {
@@ -104,7 +160,11 @@ void ieee80211_if_set_type(struct net_de
 		sdata->u.ap.max_ratectrl_rateidx = -1;
 		skb_queue_head_init(&sdata->u.ap.ps_bc_buf);
 		sdata->bss = &sdata->u.ap;
-		break;
+		res = ieee80211_if_add_apdev(dev);
+		if (!res)
+			break;
+		sdata->type = IEEE80211_IF_TYPE_STA;
+		/* fallback to STA, but keep error value in `res' */
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS: {
 		struct ieee80211_sub_if_data *msdata;
@@ -131,7 +191,9 @@ void ieee80211_if_set_type(struct net_de
 	default:
 		printk(KERN_WARNING "%s: %s: Unknown interface type 0x%x",
 		       dev->name, __FUNCTION__, type);
+		res = -EINVAL;
 	}
+	return res;
 }
 
 /* Must be called with rtnl lock held. */
@@ -183,6 +245,8 @@ #endif
 				local->total_ps_buffered--;
 				dev_kfree_skb(skb);
 			}
+
+			ieee80211_if_del_apdev(dev);
 		}
 
 		break;
@@ -257,8 +321,7 @@ int ieee80211_if_remove(struct net_devic
 	list_for_each_entry_safe(sdata, n, &local->sub_if_list, list) {
 		if ((sdata->type == id || id == -1) &&
 		    strcmp(name, sdata->dev->name) == 0 &&
-		    sdata->dev != local->mdev &&
-		    sdata->dev != local->apdev) {
+		    sdata->dev != local->mdev) {
 			__ieee80211_if_del(local, sdata);
 			return 0;
 		}
@@ -270,7 +333,7 @@ void ieee80211_if_free(struct net_device
 {
 	struct ieee80211_local *local = dev->priv;
 
-	BUG_ON(dev == local->mdev || dev == local->apdev);
+	BUG_ON(dev == local->mdev);
 	kfree(dev);
 }
 
-- 
1.3.0

