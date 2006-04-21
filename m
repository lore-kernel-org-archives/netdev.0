From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 7/17] d80211: rename IEEE80211_SUB_IF_TYPE_ constants
Date: Fri, 21 Apr 2006 22:11:38 +0200 (CEST)
Message-ID: <20060421201138.6A9E1482C1@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:12679 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932411AbWDUULL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:11 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As we're going to expose IEEE80211_SUB_IF_TYPE_* constants to drivers, the
prefix IEEE80211_SUB_IF_TYPE_ is no longer appropriate. The constants are
going to mean the type of 802.11 interface, not the type of sub-interface
structure (which is not visible to drivers at all).

This patch renames them to IEEE80211_IF_TYPE_*.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   98 +++++++++++++++++-------------------
 net/d80211/ieee80211_i.h     |   14 +++--
 net/d80211/ieee80211_ioctl.c |  114 +++++++++++++++++++++---------------------
 net/d80211/ieee80211_proc.c  |   10 ++--
 net/d80211/ieee80211_sta.c   |   40 +++++++--------
 net/d80211/wme.c             |    2 -
 6 files changed, 137 insertions(+), 141 deletions(-)

6369196531f5cb19227491f2497b043272e2ab88
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 362c231..fae9d64 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -326,7 +326,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
 
 	memset(&extra, 0, sizeof(extra));
 	extra.mgmt_data = tx->sdata &&
-		tx->sdata->type == IEEE80211_SUB_IF_TYPE_MGMT;
+		tx->sdata->type == IEEE80211_IF_TYPE_MGMT;
 	extra.ethertype = tx->ethertype;
 	extra.startidx  = 0;
 	extra.endidx    = tx->local->num_curr_rates;
@@ -868,7 +868,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	if (likely(tx->u.tx.unicast)) {
 		if (unlikely(!(sta_flags & WLAN_STA_ASSOC) &&
-			     tx->sdata->type != IEEE80211_SUB_IF_TYPE_IBSS &&
+			     tx->sdata->type != IEEE80211_IF_TYPE_IBSS &&
 			     WLAN_FC_GET_TYPE(tx->fc) == WLAN_FC_TYPE_DATA)) {
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
 			printk(KERN_DEBUG "%s: dropped data frame to not "
@@ -882,7 +882,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		if (unlikely(WLAN_FC_GET_TYPE(tx->fc) == WLAN_FC_TYPE_DATA &&
 			     tx->local->num_sta == 0 &&
 			     !tx->local->allow_broadcast_always &&
-			     tx->sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)) {
+			     tx->sdata->type != IEEE80211_IF_TYPE_IBSS)) {
 			/*
 			 * No associated STAs - no need to send multicast
 			 * frames.
@@ -925,7 +925,7 @@ static void purge_old_ps_buffers(struct 
 		struct ieee80211_sub_if_data *sdata =
 			list_entry(ptr, struct ieee80211_sub_if_data, list);
 		if (sdata->dev == local->mdev ||
-		    sdata->type != IEEE80211_SUB_IF_TYPE_AP)
+		    sdata->type != IEEE80211_IF_TYPE_AP)
 			continue;
 		ap = &sdata->u.ap;
 		skb = skb_dequeue(&ap->ps_bc_buf);
@@ -963,7 +963,7 @@ ieee80211_tx_h_multicast_ps_buf(struct i
 	/* If any of the associated stations is in power save mode,
 	 * the frame is buffered to be sent after DTIM beacon frame */
 	if (tx->local->hw->host_broadcast_ps_buffering &&
-	    tx->sdata->type != IEEE80211_SUB_IF_TYPE_WDS &&
+	    tx->sdata->type != IEEE80211_IF_TYPE_WDS &&
 	    tx->sdata->bss && atomic_read(&tx->sdata->bss->num_sta_ps) &&
 	    !(tx->fc & WLAN_FC_ORDER)) {
 		if (tx->local->total_ps_buffered >= TOTAL_MAX_TX_BUFFER)
@@ -1231,7 +1231,7 @@ static int ieee80211_master_start_xmit(s
 	control.queue = pkt_data->queue;
 
 	ret = ieee80211_tx(dev, skb, &control,
-			   control.sdata->type == IEEE80211_SUB_IF_TYPE_MGMT);
+			   control.sdata->type == IEEE80211_IF_TYPE_MGMT);
 
         return ret;
 }
@@ -1283,15 +1283,15 @@ static int ieee80211_subif_start_xmit(st
 	/* TODO: handling for 802.1x authorized/unauthorized port */
 	fc = (WLAN_FC_TYPE_DATA << 2) | (WLAN_FC_STYPE_DATA << 4);
 
-	if (likely(sdata->type == IEEE80211_SUB_IF_TYPE_AP ||
-		   sdata->type == IEEE80211_SUB_IF_TYPE_VLAN)) {
+	if (likely(sdata->type == IEEE80211_IF_TYPE_AP ||
+		   sdata->type == IEEE80211_IF_TYPE_VLAN)) {
 		fc |= WLAN_FC_FROMDS;
 		/* DA BSSID SA */
 		memcpy(hdr.addr1, skb->data, ETH_ALEN);
 		memcpy(hdr.addr2, dev->dev_addr, ETH_ALEN);
 		memcpy(hdr.addr3, skb->data + ETH_ALEN, ETH_ALEN);
                 hdrlen = 24;
-        } else if (sdata->type == IEEE80211_SUB_IF_TYPE_WDS) {
+        } else if (sdata->type == IEEE80211_IF_TYPE_WDS) {
                 fc |= WLAN_FC_FROMDS | WLAN_FC_TODS;
 		/* RA TA DA SA */
                 memcpy(hdr.addr1, sdata->u.wds.remote_addr, ETH_ALEN);
@@ -1299,14 +1299,14 @@ static int ieee80211_subif_start_xmit(st
                 memcpy(hdr.addr3, skb->data, ETH_ALEN);
                 memcpy(hdr.addr4, skb->data + ETH_ALEN, ETH_ALEN);
                 hdrlen = 30;
-        } else if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+        } else if (sdata->type == IEEE80211_IF_TYPE_STA) {
 		fc |= WLAN_FC_TODS;
 		/* BSSID SA DA */
 		memcpy(hdr.addr1, sdata->u.sta.bssid, ETH_ALEN);
 		memcpy(hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
 		memcpy(hdr.addr3, skb->data, ETH_ALEN);
 		hdrlen = 24;
-	} else if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+	} else if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		/* DA SA BSSID */
 		memcpy(hdr.addr1, skb->data, ETH_ALEN);
 		memcpy(hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
@@ -1879,7 +1879,7 @@ ieee80211_get_wds_dev(struct ieee80211_l
 	list_for_each(ptr, &local->sub_if_list)	{
 		struct ieee80211_sub_if_data *sdata =
 			list_entry(ptr, struct ieee80211_sub_if_data, list);
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_WDS &&
+		if (sdata->type == IEEE80211_IF_TYPE_WDS &&
 		    memcmp(addr, sdata->u.wds.remote_addr, ETH_ALEN) == 0)
 			return sdata->dev;
 	}
@@ -1943,8 +1943,8 @@ static struct net_device * ieee80211_sta
 	list_for_each(ptr, &local->sub_if_list) {
 		struct ieee80211_sub_if_data *sdata =
 			list_entry(ptr, struct ieee80211_sub_if_data, list);
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA &&
-		    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
+		if (sdata->type != IEEE80211_IF_TYPE_STA &&
+		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			continue;
 		if (!multicast &&
 		    memcmp(a1, sdata->dev->dev_addr, ETH_ALEN) != 0)
@@ -1952,7 +1952,7 @@ static struct net_device * ieee80211_sta
 
 		if (memcmp(addr, sdata->u.sta.bssid, ETH_ALEN) == 0 ||
 		    (memcmp(addr, "\xff\xff\xff\xff\xff\xff", ETH_ALEN) == 0 &&
-		     sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)) {
+		     sdata->type == IEEE80211_IF_TYPE_IBSS)) {
 			*sta_multicast = multicast;
 			return sdata->dev;
 		}
@@ -2021,7 +2021,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 
-		if (unlikely(sdata->type != IEEE80211_SUB_IF_TYPE_AP ||
+		if (unlikely(sdata->type != IEEE80211_IF_TYPE_AP ||
 			     !ieee80211_own_bssid(local, hdr->addr1))) {
 			printk(KERN_DEBUG "%s: dropped ToDS frame (BSSID="
 			       MACSTR " SA=" MACSTR " DA=" MACSTR ")\n",
@@ -2051,7 +2051,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr1, ETH_ALEN);
 		memcpy(src, hdr->addr3, ETH_ALEN);
 
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
+		if (sdata->type != IEEE80211_IF_TYPE_STA ||
 		    memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN) == 0 ||
 		    memcmp(hdr->addr2, sdata->u.sta.bssid, ETH_ALEN) != 0) {
 			return TXRX_DROP;
@@ -2062,7 +2062,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr1, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS ||
+		if (sdata->type != IEEE80211_IF_TYPE_IBSS ||
 		    memcmp(hdr->addr3, sdata->u.sta.bssid, ETH_ALEN) != 0) {
 			if (net_ratelimit()) {
 				printk(KERN_DEBUG "%s: dropped IBSS frame (DA="
@@ -2126,8 +2126,8 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		sdata->stats.rx_bytes += skb->len;
         }
 
-	if (local->bridge_packets && (sdata->type == IEEE80211_SUB_IF_TYPE_AP
-	    || sdata->type == IEEE80211_SUB_IF_TYPE_VLAN)) {
+	if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP
+	    || sdata->type == IEEE80211_IF_TYPE_VLAN)) {
 		if (MULTICAST_ADDR(skb->data)) {
 			/* send multicast frames both to higher layers in
 			 * local net stack and back to the wireless media */
@@ -2658,7 +2658,7 @@ #endif /* IEEE80211_LEDS */
 static ieee80211_txrx_result
 ieee80211_rx_h_monitor(struct ieee80211_txrx_data *rx)
 {
-	if (rx->sdata->type == IEEE80211_SUB_IF_TYPE_MNTR) {
+	if (rx->sdata->type == IEEE80211_IF_TYPE_MNTR) {
 		ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
                                   ieee80211_msg_monitor);
 		return TXRX_QUEUED;
@@ -2697,7 +2697,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 
 	/* Filter out foreign unicast packets when in promiscuous mode.
 	 * FIX: Filter out multicast to foreign BSSID. */
-	if (rx->sdata->type == IEEE80211_SUB_IF_TYPE_STA &&
+	if (rx->sdata->type == IEEE80211_IF_TYPE_STA &&
 	    !MULTICAST_ADDR(hdr->addr1) &&
 	    !ieee80211_own_addr(rx->dev, hdr->addr1))
 		return TXRX_DROP;
@@ -2713,7 +2713,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 	if (unlikely((WLAN_FC_GET_TYPE(rx->fc) == WLAN_FC_TYPE_DATA ||
 		      (WLAN_FC_GET_TYPE(rx->fc) == WLAN_FC_TYPE_CTRL &&
 		       WLAN_FC_GET_STYPE(rx->fc) == WLAN_FC_STYPE_PSPOLL)) &&
-		     rx->sdata->type != IEEE80211_SUB_IF_TYPE_IBSS &&
+		     rx->sdata->type != IEEE80211_IF_TYPE_IBSS &&
 		     (!rx->sta || !(rx->sta->flags & WLAN_STA_ASSOC)))) {
 		if (!(rx->fc & WLAN_FC_FROMDS) && !(rx->fc & WLAN_FC_TODS)) {
 			/* Drop IBSS frames silently. */
@@ -2725,7 +2725,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		return TXRX_QUEUED;
 	}
 
-	if (rx->sdata->type == IEEE80211_SUB_IF_TYPE_STA)
+	if (rx->sdata->type == IEEE80211_IF_TYPE_STA)
 		always_sta_key = 0;
 	else
 		always_sta_key = 1;
@@ -2801,13 +2801,13 @@ ieee80211_rx_h_sta_process(struct ieee80
 	/* Update last_rx only for IBSS packets which are for the current
 	 * BSSID to avoid keeping the current IBSS network alive in cases where
 	 * other STAs are using different BSSID. */
-	if (rx->sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+	if (rx->sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		u8 *bssid = ieee80211_get_bssid(hdr, rx->skb->len);
 		if (memcmp(bssid, rx->sdata->u.sta.bssid, ETH_ALEN) == 0)
 			sta->last_rx = jiffies;
 	} else
 	if (!MULTICAST_ADDR(hdr->addr1) ||
-	    rx->sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+	    rx->sdata->type == IEEE80211_IF_TYPE_STA) {
 		/* Update last_rx only for unicast frames in order to prevent
 		 * the Probe Request frames (the only broadcast frames from a
 		 * STA in infrastructure mode) from keeping a connection alive.
@@ -2906,7 +2906,7 @@ static ieee80211_txrx_result
 ieee80211_rx_h_802_1x_pae(struct ieee80211_txrx_data *rx)
 {
 	if (rx->sdata->eapol && ieee80211_is_eapol(rx->skb) &&
-	    rx->sdata->type != IEEE80211_SUB_IF_TYPE_STA) {
+	    rx->sdata->type != IEEE80211_IF_TYPE_STA) {
 		/* Pass both encrypted and unencrypted EAPOL frames to user
 		 * space for processing. */
 		ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
@@ -2960,8 +2960,8 @@ ieee80211_rx_h_mgmt(struct ieee80211_txr
 {
         struct ieee80211_sub_if_data *sdata;
 	sdata = IEEE80211_DEV_TO_SUB_IF(rx->dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+	if (sdata->type == IEEE80211_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		ieee80211_sta_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status);
 	} else {
 		/* Management frames are sent to hostapd for processing */
@@ -3123,7 +3123,7 @@ static void ieee80211_rx_michael_mic_rep
 	}
 
 	if (rx->local->hw->wep_include_iv &&
-	    rx->sdata->type == IEEE80211_SUB_IF_TYPE_AP) {
+	    rx->sdata->type == IEEE80211_IF_TYPE_AP) {
 		int keyidx = ieee80211_wep_get_keyidx(rx->skb);
 		/* AP with Pairwise keys support should never receive Michael
 		 * MIC errors for non-zero keyidx because these are reserved
@@ -3198,7 +3198,7 @@ static void ieee80211_sta_rx_broadcast(s
 	list_for_each(ptr, &local->sub_if_list) {
 		struct ieee80211_sub_if_data *sdata =
 			list_entry(ptr, struct ieee80211_sub_if_data, list);
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
+		if (sdata->type != IEEE80211_IF_TYPE_STA ||
 		    (memcmp(bssid, sdata->u.sta.bssid, ETH_ALEN) != 0 &&
 		     !(bssid[0] & 0x01)))
 			continue;
@@ -3266,7 +3266,7 @@ void __ieee80211_rx(struct net_device *d
 					      &sta_broadcast);
 		rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
 		if (sta == NULL &&
-		    rx.sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+		    rx.sdata->type == IEEE80211_IF_TYPE_IBSS) {
 			u8 *bssid = ieee80211_get_bssid(hdr, skb->len);
 			if (bssid)
 				sta = rx.sta =
@@ -3868,13 +3868,13 @@ static struct net_device *ieee80211_if_a
 	wds_dev->tx_queue_len = 0;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(wds_dev);
-	sdata->type = IEEE80211_SUB_IF_TYPE_AP;
+	sdata->type = IEEE80211_IF_TYPE_AP;
         sdata->master = local->mdev;
         sdata->dev = wds_dev;
 	sdata->local = local;
 	memset(&sdata->stats, 0, sizeof(struct net_device_stats));
 	sdata_parent = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata_parent->type == IEEE80211_SUB_IF_TYPE_AP)
+	if (sdata_parent->type == IEEE80211_IF_TYPE_AP)
 		sdata->bss = &sdata_parent->u.ap;
 	else {
 		printk(KERN_DEBUG "%s: could not set BSS pointer for new "
@@ -3916,7 +3916,7 @@ int ieee80211_if_add_wds(struct net_devi
                 return -ENOANO;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(wds_dev);
-        sdata->type = IEEE80211_SUB_IF_TYPE_WDS;
+        sdata->type = IEEE80211_IF_TYPE_WDS;
         memcpy(&sdata->u.wds, wds, sizeof(struct ieee80211_if_wds));
 
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
@@ -3983,7 +3983,7 @@ int ieee80211_if_add_vlan(struct net_dev
                 return -ENOANO;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(vlan_dev);
-        sdata->type = IEEE80211_SUB_IF_TYPE_VLAN;
+        sdata->type = IEEE80211_IF_TYPE_VLAN;
 	ieee80211_proc_init_virtual(vlan_dev);
         return 0;
 }
@@ -3991,7 +3991,7 @@ int ieee80211_if_add_vlan(struct net_dev
 
 static void ieee80211_if_ap_init(struct ieee80211_sub_if_data *sdata)
 {
-	sdata->type = IEEE80211_SUB_IF_TYPE_AP;
+	sdata->type = IEEE80211_IF_TYPE_AP;
 	sdata->u.ap.dtim_period = 2;
 	sdata->u.ap.force_unicast_rateidx = -1;
 	sdata->u.ap.max_ratectrl_rateidx = -1;
@@ -4072,7 +4072,7 @@ int ieee80211_if_add_sta(struct net_devi
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(sta_dev);
 	ifsta = &sdata->u.sta;
-	sdata->type = IEEE80211_SUB_IF_TYPE_STA;
+	sdata->type = IEEE80211_IF_TYPE_STA;
 	ieee80211_proc_init_virtual(sta_dev);
 
 	spin_lock_bh(&local->sub_if_lock);
@@ -4131,7 +4131,7 @@ #endif
 	}
 
 	switch (sdata->type) {
-	case IEEE80211_SUB_IF_TYPE_AP:
+	case IEEE80211_IF_TYPE_AP:
 		/* Remove all virtual interfaces that use this BSS
 		 * as their sdata->bss */
 		list_for_each_safe(ptr, n, &local->sub_if_list) {
@@ -4177,7 +4177,7 @@ #endif
 		}
 
 		break;
-	case IEEE80211_SUB_IF_TYPE_WDS:
+	case IEEE80211_IF_TYPE_WDS:
 		sta = sta_info_get(local, sdata->u.wds.remote_addr);
 		if (sta) {
 			sta_info_release(local, sta);
@@ -4189,7 +4189,7 @@ #ifdef CONFIG_D80211_VERBOSE_DEBUG
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		}
 		break;
-	case IEEE80211_SUB_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_STA:
 		del_timer_sync(&sdata->u.sta.timer);
 		if (local->scan_timer.data == (unsigned long) sdata->dev)
 			del_timer_sync(&local->scan_timer);
@@ -4258,32 +4258,28 @@ static int ieee80211_if_remove(struct ne
 int ieee80211_if_remove_wds(struct net_device *dev, const char *name,
 			    int locked)
 {
-        return ieee80211_if_remove(dev, name, IEEE80211_SUB_IF_TYPE_WDS,
-				   locked);
+        return ieee80211_if_remove(dev, name, IEEE80211_IF_TYPE_WDS, locked);
 }
 
 
 int ieee80211_if_remove_vlan(struct net_device *dev, const char *name,
 			     int locked)
 {
-        return ieee80211_if_remove(dev, name, IEEE80211_SUB_IF_TYPE_VLAN,
-				   locked);
+        return ieee80211_if_remove(dev, name, IEEE80211_IF_TYPE_VLAN, locked);
 }
 
 
 int ieee80211_if_remove_ap(struct net_device *dev, const char *name,
 			   int locked)
 {
-	return ieee80211_if_remove(dev, name, IEEE80211_SUB_IF_TYPE_AP,
-				   locked);
+	return ieee80211_if_remove(dev, name, IEEE80211_IF_TYPE_AP, locked);
 }
 
 
 int ieee80211_if_remove_sta(struct net_device *dev, const char *name,
 			    int locked)
 {
-	return ieee80211_if_remove(dev, name, IEEE80211_SUB_IF_TYPE_STA,
-				   locked);
+	return ieee80211_if_remove(dev, name, IEEE80211_IF_TYPE_STA, locked);
 }
 
 
@@ -4469,7 +4465,7 @@ struct net_device *ieee80211_alloc_hw(si
 	sprintf(apdev->name, "%sap", dev->name);
 
         sdata = IEEE80211_DEV_TO_SUB_IF(apdev);
-        sdata->type = IEEE80211_SUB_IF_TYPE_MGMT;
+        sdata->type = IEEE80211_IF_TYPE_MGMT;
         sdata->dev = apdev;
         sdata->master = mdev;
         sdata->local = local;
@@ -4490,7 +4486,7 @@ struct net_device *ieee80211_alloc_hw(si
 	sprintf(mdev->name, "%s.11", dev->name);
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(mdev);
-	sdata->type = IEEE80211_SUB_IF_TYPE_AP;
+	sdata->type = IEEE80211_IF_TYPE_AP;
         sdata->dev = mdev;
         sdata->master = mdev;
         sdata->local = local;
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 8fe1dd1..9d18c71 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -256,13 +256,13 @@ #define IEEE80211_AUTH_ALG_LEAP BIT(2)
 };
 
 
-#define IEEE80211_SUB_IF_TYPE_AP   0x00000000
-#define IEEE80211_SUB_IF_TYPE_MGMT 0x00000001
-#define IEEE80211_SUB_IF_TYPE_STA  0x00000002
-#define IEEE80211_SUB_IF_TYPE_IBSS 0x00000003
-#define IEEE80211_SUB_IF_TYPE_MNTR 0x00000004
-#define IEEE80211_SUB_IF_TYPE_WDS  0x5A580211
-#define IEEE80211_SUB_IF_TYPE_VLAN 0x00080211
+#define IEEE80211_IF_TYPE_AP   0x00000000
+#define IEEE80211_IF_TYPE_MGMT 0x00000001
+#define IEEE80211_IF_TYPE_STA  0x00000002
+#define IEEE80211_IF_TYPE_IBSS 0x00000003
+#define IEEE80211_IF_TYPE_MNTR 0x00000004
+#define IEEE80211_IF_TYPE_WDS  0x5A580211
+#define IEEE80211_IF_TYPE_VLAN 0x00080211
 
 struct ieee80211_sub_if_data {
         struct list_head list;
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 8f0aad5..2fd910d 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -64,7 +64,7 @@ static int ieee80211_ioctl_set_beacon(st
 		return -EINVAL;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_AP)
+	if (sdata->type != IEEE80211_IF_TYPE_AP)
 		return -EINVAL;
 	ap = &sdata->u.ap;
 
@@ -499,11 +499,11 @@ static int ieee80211_set_encryption(stru
 		 * must be used. This should be done automatically
 		 * based on configured station devices. For the time
 		 * being, this can be only set at compile time. */
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+		if (sdata->type == IEEE80211_IF_TYPE_STA) {
 			if (0 /* FIX: more than one STA per AP */)
 				try_hwaccel = 0;
 		} else
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_AP ||
+		if (sdata->type != IEEE80211_IF_TYPE_AP ||
 		    dev != local->wdev)
 			try_hwaccel = 0;
 	} else {
@@ -541,8 +541,8 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	 * optimized by using non-default keys (at least with Atheros ar521x).
 	 */
 	if (!sta && alg == ALG_WEP && !local->default_wep_only &&
-	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS &&
-	    sdata->type != IEEE80211_SUB_IF_TYPE_AP) {
+	    sdata->type != IEEE80211_IF_TYPE_IBSS &&
+	    sdata->type != IEEE80211_IF_TYPE_AP) {
 		try_hwaccel = 0;
 	}
 
@@ -559,7 +559,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		 */
 			try_hwaccel = 0;
 		}
-		else if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+		else if (sdata->type == IEEE80211_IF_TYPE_STA) {
 			sta = sta_info_get(local, sdata->u.sta.bssid);
 			if (sta) {
 				if (sta->flags & WLAN_STA_WME) {
@@ -1014,7 +1014,7 @@ static int ieee80211_ioctl_update_if(str
 			}
 		}
 
-		if (wds_dev == NULL || sdata->type != IEEE80211_SUB_IF_TYPE_WDS)
+		if (wds_dev == NULL || sdata->type != IEEE80211_IF_TYPE_WDS)
 			return -ENODEV;
 
 		return ieee80211_if_update_wds(wds_dev, wds->remote_addr);
@@ -1052,8 +1052,8 @@ static int ieee80211_ioctl_sta_get_state
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA &&
-	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
+	if (sdata->type != IEEE80211_IF_TYPE_STA &&
+	    sdata->type != IEEE80211_IF_TYPE_IBSS)
 		return -EINVAL;
 	param->u.sta_get_state.state = sdata->u.sta.state;
 	return 0;
@@ -1066,8 +1066,8 @@ static int ieee80211_ioctl_mlme(struct n
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA &&
-	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
+	if (sdata->type != IEEE80211_IF_TYPE_STA &&
+	    sdata->type != IEEE80211_IF_TYPE_IBSS)
 		return -EINVAL;
 	switch (param->u.mlme.cmd) {
 	case MLME_STA_DEAUTH:
@@ -1126,8 +1126,8 @@ static int ieee80211_set_gen_ie(struct n
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)
+	if (sdata->type == IEEE80211_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_IF_TYPE_IBSS)
 		return ieee80211_sta_set_extra_ie(dev, ie, len);
 
 	kfree(local->conf.generic_elem);
@@ -1671,7 +1671,7 @@ #if 0
 			IEEE80211_DEV_TO_SUB_IF(dev);
 		sta_info_flush(local, NULL);
 		if (local->conf.mode == IW_MODE_ADHOC &&
-		    sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+		    sdata->type == IEEE80211_IF_TYPE_STA) {
 			/* Clear drop_unencrypted when leaving adhoc mode since
 			 * only adhoc mode is using automatic setting for this
 			 * in 80211.o. */
@@ -1699,22 +1699,22 @@ static int ieee80211_ioctl_giwmode(struc
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	switch (sdata->type) {
-	case IEEE80211_SUB_IF_TYPE_AP:
+	case IEEE80211_IF_TYPE_AP:
 		*mode = IW_MODE_MASTER;
 		break;
-	case IEEE80211_SUB_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_STA:
 		*mode = IW_MODE_INFRA;
 		break;
-	case IEEE80211_SUB_IF_TYPE_IBSS:
+	case IEEE80211_IF_TYPE_IBSS:
 		*mode = IW_MODE_ADHOC;
 		break;
-	case IEEE80211_SUB_IF_TYPE_MNTR:
+	case IEEE80211_IF_TYPE_MNTR:
 		*mode = IW_MODE_MONITOR;
 		break;
-	case IEEE80211_SUB_IF_TYPE_WDS:
+	case IEEE80211_IF_TYPE_WDS:
 		*mode = IW_MODE_REPEAT;
 		break;
-	case IEEE80211_SUB_IF_TYPE_VLAN:
+	case IEEE80211_IF_TYPE_VLAN:
 		*mode = IW_MODE_SECOND;		/* FIXME */
 		break;
 	default:
@@ -1807,8 +1807,8 @@ static int ieee80211_ioctl_siwessid(stru
 		len--;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)
+	if (sdata->type == IEEE80211_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_IF_TYPE_IBSS)
 		return ieee80211_sta_set_ssid(dev, ssid, len);
 
 	kfree(local->conf.ssid);
@@ -1831,8 +1831,8 @@ static int ieee80211_ioctl_giwessid(stru
 
 	struct ieee80211_sub_if_data *sdata;
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+	if (sdata->type == IEEE80211_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		int res = ieee80211_sta_get_ssid(dev, ssid, &len);
 		if (res == 0)
 			data->length = len;
@@ -1856,8 +1856,8 @@ static int ieee80211_ioctl_siwap(struct 
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+	if (sdata->type == IEEE80211_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		int changed_bssid = 0;
 		if (memcmp(local->conf.client_bssid, (u8 *) &ap_addr->sa_data,
 			   ETH_ALEN) != 0)
@@ -1869,7 +1869,7 @@ static int ieee80211_ioctl_siwap(struct 
 			       "the low-level driver\n", dev->name);
 		}
 		return ieee80211_sta_set_bssid(dev, (u8 *) &ap_addr->sa_data);
-	} else if (sdata->type == IEEE80211_SUB_IF_TYPE_WDS) {
+	} else if (sdata->type == IEEE80211_IF_TYPE_WDS) {
 		if (memcmp(sdata->u.wds.remote_addr, (u8 *) &ap_addr->sa_data,
 			   ETH_ALEN) == 0)
 			return 0;
@@ -1887,12 +1887,12 @@ static int ieee80211_ioctl_giwap(struct 
         struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+	if (sdata->type == IEEE80211_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		ap_addr->sa_family = ARPHRD_ETHER;
 		memcpy(&ap_addr->sa_data, sdata->u.sta.bssid, ETH_ALEN);
 		return 0;
-	} else if (sdata->type == IEEE80211_SUB_IF_TYPE_WDS) {
+	} else if (sdata->type == IEEE80211_IF_TYPE_WDS) {
 		ap_addr->sa_family = ARPHRD_ETHER;
 		memcpy(&ap_addr->sa_data, sdata->u.wds.remote_addr, ETH_ALEN);
 		return 0;
@@ -2163,7 +2163,7 @@ ieee80211_ioctl_force_unicast_rate(struc
 	struct ieee80211_local *local = dev->priv;
 	int i;
 
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_AP)
+	if (sdata->type != IEEE80211_IF_TYPE_AP)
 		return -ENOENT;
 
 	if (rate == 0) {
@@ -2189,7 +2189,7 @@ ieee80211_ioctl_max_ratectrl_rate(struct
 	struct ieee80211_local *local = dev->priv;
 	int i;
 
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_AP)
+	if (sdata->type != IEEE80211_IF_TYPE_AP)
 		return -ENOENT;
 
 	if (rate == 0) {
@@ -2306,8 +2306,8 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_AP_AUTH_ALGS:
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
-		    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+		if (sdata->type == IEEE80211_IF_TYPE_STA ||
+		    sdata->type == IEEE80211_IF_TYPE_IBSS) {
 			sdata->u.sta.auth_algs = value;
 		} else
 			ret = -EOPNOTSUPP;
@@ -2316,7 +2316,7 @@ static int ieee80211_ioctl_prism2_param(
 	case PRISM2_PARAM_DTIM_PERIOD:
 		if (value < 1)
 			ret = -EINVAL;
-		else if (sdata->type != IEEE80211_SUB_IF_TYPE_AP)
+		else if (sdata->type != IEEE80211_IF_TYPE_AP)
 			ret = -ENOENT;
 		else
 			sdata->u.ap.dtim_period = value;
@@ -2483,15 +2483,15 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_MIXED_CELL:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
-		    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
+		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			sdata->u.sta.mixed_cell = !!value;
 		break;
 
 	case PRISM2_PARAM_KEY_MGMT:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type != IEEE80211_IF_TYPE_STA)
 			ret = -EINVAL;
 		else
 			sdata->u.sta.key_mgmt = value;
@@ -2502,14 +2502,14 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
+		if (sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			sdata->u.sta.create_ibss = !!value;
 		break;
 	case PRISM2_PARAM_WMM_ENABLED:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
-		    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
+		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			sdata->u.sta.wmm_enabled = !!value;
@@ -2550,15 +2550,15 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_AP_AUTH_ALGS:
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
-		    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+		if (sdata->type == IEEE80211_IF_TYPE_STA ||
+		    sdata->type == IEEE80211_IF_TYPE_IBSS) {
 			*param = sdata->u.sta.auth_algs;
 		} else
 			ret = -EOPNOTSUPP;
 		break;
 
 	case PRISM2_PARAM_DTIM_PERIOD:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_AP)
+		if (sdata->type != IEEE80211_IF_TYPE_AP)
 			ret = -ENOENT;
 		else
 			*param = sdata->u.ap.dtim_period;
@@ -2675,29 +2675,29 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
+		if (sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			*param = !!sdata->u.sta.create_ibss;
 		break;
 
 	case PRISM2_PARAM_MIXED_CELL:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
-		    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
+		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			*param = !!sdata->u.sta.mixed_cell;
 		break;
 
 	case PRISM2_PARAM_KEY_MGMT:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type != IEEE80211_IF_TYPE_STA)
 			ret = -EINVAL;
 		else
 			*param = sdata->u.sta.key_mgmt;
 		break;
 	case PRISM2_PARAM_WMM_ENABLED:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
-		    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
+		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			*param = !!sdata->u.sta.wmm_enabled;
@@ -2739,8 +2739,8 @@ static int ieee80211_ioctl_siwmlme(struc
 	struct iw_mlme *mlme = (struct iw_mlme *) extra;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
-	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
+	if (sdata->type != IEEE80211_IF_TYPE_STA ||
+	    sdata->type != IEEE80211_IF_TYPE_IBSS)
 		return -EINVAL;
 
 	switch (mlme->cmd) {
@@ -2861,7 +2861,7 @@ static int ieee80211_ioctl_siwauth(struc
 	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
 		break;
 	case IW_AUTH_KEY_MGMT:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type != IEEE80211_IF_TYPE_STA)
 			ret = -EINVAL;
 		else {
 			/*
@@ -2884,8 +2884,8 @@ static int ieee80211_ioctl_siwauth(struc
 		}
 		break;
 	case IW_AUTH_80211_AUTH_ALG:
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
-		    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)
+		if (sdata->type == IEEE80211_IF_TYPE_STA ||
+		    sdata->type == IEEE80211_IF_TYPE_IBSS)
 			sdata->u.sta.auth_algs = data->value;
 		else
 			ret = -EOPNOTSUPP;
@@ -2911,8 +2911,8 @@ static int ieee80211_ioctl_giwauth(struc
 
 	switch (data->flags & IW_AUTH_INDEX) {
 	case IW_AUTH_80211_AUTH_ALG:
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
-		    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)
+		if (sdata->type == IEEE80211_IF_TYPE_STA ||
+		    sdata->type == IEEE80211_IF_TYPE_IBSS)
 			data->value = sdata->u.sta.auth_algs;
 		else
 			ret = -EOPNOTSUPP;
diff --git a/net/d80211/ieee80211_proc.c b/net/d80211/ieee80211_proc.c
index 3709494..098599a 100644
--- a/net/d80211/ieee80211_proc.c
+++ b/net/d80211/ieee80211_proc.c
@@ -166,22 +166,22 @@ static char * ieee80211_proc_sub_if(char
 		p += sprintf(p, "bss=%p\n", sdata->bss);
 
 	switch (sdata->type) {
-	case IEEE80211_SUB_IF_TYPE_AP:
+	case IEEE80211_IF_TYPE_AP:
 		p = ieee80211_proc_sub_if_ap(p, &sdata->u.ap);
 		break;
-	case IEEE80211_SUB_IF_TYPE_WDS:
+	case IEEE80211_IF_TYPE_WDS:
 		p += sprintf(p, "type=wds\n");
 		p += sprintf(p, "wds.peer=" MACSTR "\n",
 			     MAC2STR(sdata->u.wds.remote_addr));
 		break;
-	case IEEE80211_SUB_IF_TYPE_VLAN:
+	case IEEE80211_IF_TYPE_VLAN:
 		p += sprintf(p, "type=vlan\n");
 		p += sprintf(p, "vlan.id=%d\n", sdata->u.vlan.id);
 		break;
-	case IEEE80211_SUB_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_STA:
 		p = ieee80211_proc_sub_if_sta(p, 0, &sdata->u.sta);
 		break;
-	case IEEE80211_SUB_IF_TYPE_IBSS:
+	case IEEE80211_IF_TYPE_IBSS:
 		p = ieee80211_proc_sub_if_sta(p, 1, &sdata->u.sta);
 		break;
 	}
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 5df6734..49c1b62 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -372,7 +372,7 @@ static void ieee80211_set_associated(str
 	if (assoc) {
 		struct ieee80211_sub_if_data *sdata;
 		sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type != IEEE80211_IF_TYPE_STA)
 			return;
 		ifsta->prev_bssid_set = 1;
 		memcpy(ifsta->prev_bssid, sdata->u.sta.bssid, ETH_ALEN);
@@ -863,7 +863,7 @@ static void ieee80211_rx_mgmt_auth(struc
 	u16 auth_alg, auth_transaction, status_code;
 
 	if (ifsta->state != IEEE80211_AUTHENTICATE &&
-	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS) {
+	    sdata->type != IEEE80211_IF_TYPE_IBSS) {
 		printk(KERN_DEBUG "%s: authentication frame received from "
 		       MACSTR ", but not in authenticate state - ignored\n",
 		       dev->name, MAC2STR(mgmt->sa));
@@ -877,7 +877,7 @@ static void ieee80211_rx_mgmt_auth(struc
 		return;
 	}
 
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS &&
+	if (sdata->type != IEEE80211_IF_TYPE_IBSS &&
 	    memcmp(ifsta->bssid, mgmt->sa, ETH_ALEN) != 0) {
 		printk(KERN_DEBUG "%s: authentication frame received from "
 		       "unknown AP (SA=" MACSTR " BSSID=" MACSTR ") - "
@@ -886,7 +886,7 @@ static void ieee80211_rx_mgmt_auth(struc
 		return;
 	}
 
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS &&
+	if (sdata->type != IEEE80211_IF_TYPE_IBSS &&
 	    memcmp(ifsta->bssid, mgmt->bssid, ETH_ALEN) != 0) {
 		printk(KERN_DEBUG "%s: authentication frame received from "
 		       "unknown BSSID (SA=" MACSTR " BSSID=" MACSTR ") - "
@@ -904,7 +904,7 @@ static void ieee80211_rx_mgmt_auth(struc
 	       dev->name, MAC2STR(mgmt->sa), auth_alg,
 	       auth_transaction, status_code);
 
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+	if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		/* IEEE 802.11 standard does not require authentication in IBSS
 		 * networks and most implementations do not seem to use it.
 		 * However, try to reply to authentication attempts if someone
@@ -1364,7 +1364,7 @@ #endif
 		((u64) pos[3] << 24) | ((u64) pos[2] << 16) |
 		((u64) pos[1] << 8) | ((u64) pos[0]);
 
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS && beacon &&
+	if (sdata->type == IEEE80211_IF_TYPE_IBSS && beacon &&
 	    memcmp(mgmt->bssid, sdata->u.sta.bssid, ETH_ALEN) == 0) {
 #ifdef IEEE80211_IBSS_DEBUG
 		static unsigned long last_tsf_debug = 0;
@@ -1388,7 +1388,7 @@ #endif /* IEEE80211_IBSS_DEBUG */
 				   &elems) == ParseFailed)
 		invalid = 1;
 
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS && elems.supp_rates &&
+	if (sdata->type == IEEE80211_IF_TYPE_IBSS && elems.supp_rates &&
 	    memcmp(mgmt->bssid, sdata->u.sta.bssid, ETH_ALEN) == 0 &&
 	    (sta = sta_info_get(local, mgmt->sa))) {
 		struct ieee80211_rate *rates;
@@ -1596,7 +1596,7 @@ static void ieee80211_rx_mgmt_beacon(str
 	ieee80211_rx_bss_info(dev, mgmt, len, rx_status, 1);
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+	if (sdata->type != IEEE80211_IF_TYPE_STA)
 		return;
 	ifsta = &sdata->u.sta;
 
@@ -1651,7 +1651,7 @@ static void ieee80211_rx_mgmt_probe_req(
 	struct ieee80211_mgmt *resp;
 	u8 *pos, *end;
 
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS ||
+	if (sdata->type != IEEE80211_IF_TYPE_IBSS ||
 	    ifsta->state != IEEE80211_IBSS_JOINED ||
 	    len < 24 + 2 || ifsta->probe_resp == NULL)
 		return;
@@ -1720,7 +1720,7 @@ void ieee80211_sta_rx_mgmt(struct net_de
 		goto fail;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA) {
+	if (sdata->type != IEEE80211_IF_TYPE_STA) {
 		printk(KERN_DEBUG "%s: ieee80211_sta_rx_mgmt: non-STA "
 		       "interface (type=%d)\n", dev->name, sdata->type);
 		goto fail;
@@ -1865,8 +1865,8 @@ void ieee80211_sta_timer(unsigned long p
 
 	dev = (struct net_device *) ptr;
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA &&
-	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS) {
+	if (sdata->type != IEEE80211_IF_TYPE_STA &&
+	    sdata->type != IEEE80211_IF_TYPE_IBSS) {
 		printk(KERN_DEBUG "%s: ieee80211_sta_timer: non-STA interface "
 		       "(type=%d)\n", dev->name, sdata->type);
 		return;
@@ -1913,7 +1913,7 @@ static void ieee80211_sta_new_auth(struc
 	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+	if (sdata->type != IEEE80211_IF_TYPE_STA)
 		return;
 
 	if (local->hw->reset_tsf) {
@@ -2318,7 +2318,7 @@ int ieee80211_sta_set_ssid(struct net_de
 	ifsta->ssid_len = len;
 
 	ifsta->ssid_set = 1;
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS && !ifsta->bssid_set) {
+	if (sdata->type == IEEE80211_IF_TYPE_IBSS && !ifsta->bssid_set) {
 		ifsta->ibss_join_req = jiffies;
 		ifsta->state = IEEE80211_IBSS_SEARCH;
 		return ieee80211_sta_find_ibss(dev, ifsta);
@@ -2439,7 +2439,7 @@ static void ieee80211_sta_scan_timer(uns
 			local->last_scan_completed = jiffies;
 			memset(&wrqu, 0, sizeof(wrqu));
 			wireless_send_event(dev, SIOCGIWSCAN, &wrqu, NULL);
-			if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+			if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
 				struct ieee80211_sub_if_data *sdata =
 					IEEE80211_DEV_TO_SUB_IF(dev);
 				struct ieee80211_if_sta *ifsta = &sdata->u.sta;
@@ -2453,7 +2453,7 @@ static void ieee80211_sta_scan_timer(uns
 		skip = !(local->hw_modes & (1 << mode->mode));
 		chan = &mode->channels[local->scan_channel_idx];
 		if (!(chan->flag & IEEE80211_CHAN_W_SCAN) ||
-		    (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS &&
+		    (sdata->type == IEEE80211_IF_TYPE_IBSS &&
 		     !(chan->flag & IEEE80211_CHAN_W_IBSS)) ||
 		    (local->hw_modes & (1 << MODE_IEEE80211G) &&
 		     mode->mode == MODE_IEEE80211B && local->scan_skip_11b))
@@ -2799,7 +2799,7 @@ struct sta_info * ieee80211_ibss_add_sta
 	spin_lock_bh(&local->sub_if_lock);
 	list_for_each(ptr, &local->sub_if_list) {
 		sdata = list_entry(ptr, struct ieee80211_sub_if_data, list);
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS &&
+		if (sdata->type == IEEE80211_IF_TYPE_IBSS &&
 		    memcmp(bssid, sdata->u.sta.bssid, ETH_ALEN) == 0) {
 			sta_dev = sdata->dev;
 			break;
@@ -2835,8 +2835,8 @@ int ieee80211_sta_deauthenticate(struct 
 	printk(KERN_DEBUG "%s: deauthenticate(reason=%d)\n",
 	       dev->name, reason);
 
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA &&
-	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
+	if (sdata->type != IEEE80211_IF_TYPE_STA &&
+	    sdata->type != IEEE80211_IF_TYPE_IBSS)
 		return -EINVAL;
 
 	ieee80211_send_deauth(dev, ifsta, reason);
@@ -2853,7 +2853,7 @@ int ieee80211_sta_disassociate(struct ne
 	printk(KERN_DEBUG "%s: disassociate(reason=%d)\n",
 	       dev->name, reason);
 
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+	if (sdata->type != IEEE80211_IF_TYPE_STA)
 		return -EINVAL;
 
 	if (!ifsta->associated)
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index 21689ed..51a197a 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -190,7 +190,7 @@ static inline int classify80211(struct s
 		return IEEE80211_TX_QUEUE_DATA0;
 	}
 
-	if (unlikely(pkt_data->sdata->type == IEEE80211_SUB_IF_TYPE_MGMT)) {
+	if (unlikely(pkt_data->sdata->type == IEEE80211_IF_TYPE_MGMT)) {
 		/* Data frames from hostapd (mainly, EAPOL) use AC_VO
 		* and they will include QoS control fields if
 		* the target STA is using WME. */
-- 
1.3.0

