From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 5/17] d80211: non-shared interface types
Date: Fri, 21 Apr 2006 22:11:36 +0200 (CEST)
Message-ID: <20060421201136.4D9F8482C6@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:11911 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932403AbWDUULJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:09 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes "iwmode" variable (local->conf.mode) shared by all
interfaces. Instead, every interface has its own type (STA/IBSS/AP/WDS).

Please note, that
- Actual SIOCSIWMODE ioctl is disabled by this patch and is implemented by
  one of subsequent patches.
- There is no way to ask the driver if given combination of interfaces is
  possible. Again, it is implemented by one of subsequent patches.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h         |   18 ------
 net/d80211/ieee80211.c       |  120 +++++++++++++++++++-----------------------
 net/d80211/ieee80211_ioctl.c |  103 +++++++++++++++++++++++-------------
 net/d80211/ieee80211_proc.c  |   12 +++-
 net/d80211/ieee80211_sta.c   |   43 ++++++++-------
 5 files changed, 150 insertions(+), 146 deletions(-)

16aa733f49d78c481269c79ad8de190b40665da2
diff --git a/include/net/d80211.h b/include/net/d80211.h
index e4c5ed2..75e8e24 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -242,8 +242,6 @@ struct ieee80211_conf {
 	int freq;			/* MHz */
 	int channel_val;		/* hw specific value for the channel */
 
-	int mode;			/* IW_MODE_ */
-
 	int phymode;			/* MODE_IEEE80211A, .. */
         unsigned int regulatory_domain;
         int adm_status;
@@ -359,22 +357,6 @@ struct ieee80211_scan_conf {
 
 };
 
-#ifndef IW_MODE_ADHOC
-#define IW_MODE_ADHOC 1
-#endif
-
-#ifndef IW_MODE_INFRA
-#define IW_MODE_INFRA 2
-#endif
-
-#ifndef IW_MODE_MASTER
-#define IW_MODE_MASTER 3
-#endif
-
-#ifndef IW_MODE_MONITOR
-#define IW_MODE_MONITOR 6
-#endif
-
 #define IEEE80211_SEQ_COUNTER_RX	0
 #define IEEE80211_SEQ_COUNTER_TX	1
 
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index f80dffa..10c4792 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -868,7 +868,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	if (likely(tx->u.tx.unicast)) {
 		if (unlikely(!(sta_flags & WLAN_STA_ASSOC) &&
-			     tx->local->conf.mode != IW_MODE_ADHOC &&
+			     tx->sdata->type != IEEE80211_SUB_IF_TYPE_IBSS &&
 			     WLAN_FC_GET_TYPE(tx->fc) == WLAN_FC_TYPE_DATA)) {
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
 			printk(KERN_DEBUG "%s: dropped data frame to not "
@@ -882,7 +882,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		if (unlikely(WLAN_FC_GET_TYPE(tx->fc) == WLAN_FC_TYPE_DATA &&
 			     tx->local->num_sta == 0 &&
 			     !tx->local->allow_broadcast_always &&
-			     tx->local->conf.mode != IW_MODE_ADHOC)) {
+			     tx->sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)) {
 			/*
 			 * No associated STAs - no need to send multicast
 			 * frames.
@@ -1285,24 +1285,11 @@ static int ieee80211_subif_start_xmit(st
 
 	if (likely(sdata->type == IEEE80211_SUB_IF_TYPE_AP ||
 		   sdata->type == IEEE80211_SUB_IF_TYPE_VLAN)) {
-		if (local->conf.mode == IW_MODE_MASTER) {
-			fc |= WLAN_FC_FROMDS;
-			/* DA BSSID SA */
-			memcpy(hdr.addr1, skb->data, ETH_ALEN);
-			memcpy(hdr.addr2, dev->dev_addr, ETH_ALEN);
-			memcpy(hdr.addr3, skb->data + ETH_ALEN, ETH_ALEN);
-		} else if (local->conf.mode == IW_MODE_INFRA) {
-			fc |= WLAN_FC_TODS;
-			/* BSSID SA DA */
-			memcpy(hdr.addr1, local->bssid, ETH_ALEN);
-			memcpy(hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
-			memcpy(hdr.addr3, skb->data, ETH_ALEN);
-		} else if (local->conf.mode == IW_MODE_ADHOC) {
-			/* DA SA BSSID */
-			memcpy(hdr.addr1, skb->data, ETH_ALEN);
-			memcpy(hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
-			memcpy(hdr.addr3, local->bssid, ETH_ALEN);
-		}
+		fc |= WLAN_FC_FROMDS;
+		/* DA BSSID SA */
+		memcpy(hdr.addr1, skb->data, ETH_ALEN);
+		memcpy(hdr.addr2, dev->dev_addr, ETH_ALEN);
+		memcpy(hdr.addr3, skb->data + ETH_ALEN, ETH_ALEN);
                 hdrlen = 24;
         } else if (sdata->type == IEEE80211_SUB_IF_TYPE_WDS) {
                 fc |= WLAN_FC_FROMDS | WLAN_FC_TODS;
@@ -1313,18 +1300,17 @@ static int ieee80211_subif_start_xmit(st
                 memcpy(hdr.addr4, skb->data + ETH_ALEN, ETH_ALEN);
                 hdrlen = 30;
         } else if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
-		if (local->conf.mode == IW_MODE_INFRA) {
-			fc |= WLAN_FC_TODS;
-			/* BSSID SA DA */
-			memcpy(hdr.addr1, sdata->u.sta.bssid, ETH_ALEN);
-			memcpy(hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
-			memcpy(hdr.addr3, skb->data, ETH_ALEN);
-		} else {
-			/* DA SA BSSID */
-			memcpy(hdr.addr1, skb->data, ETH_ALEN);
-			memcpy(hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
-			memcpy(hdr.addr3, sdata->u.sta.bssid, ETH_ALEN);
-		}
+		fc |= WLAN_FC_TODS;
+		/* BSSID SA DA */
+		memcpy(hdr.addr1, sdata->u.sta.bssid, ETH_ALEN);
+		memcpy(hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
+		memcpy(hdr.addr3, skb->data, ETH_ALEN);
+		hdrlen = 24;
+	} else if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
+		/* DA SA BSSID */
+		memcpy(hdr.addr1, skb->data, ETH_ALEN);
+		memcpy(hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
+		memcpy(hdr.addr3, sdata->u.sta.bssid, ETH_ALEN);
 		hdrlen = 24;
         } else {
                 ret = 0;
@@ -1722,9 +1708,9 @@ int ieee80211_hw_config(struct net_devic
 	int i, ret = 0;
 
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "HW CONFIG: channel=%d freq=%d mode=%d "
+	printk(KERN_DEBUG "HW CONFIG: channel=%d freq=%d "
 	       "phymode=%d\n", local->conf.channel, local->conf.freq,
-	       local->conf.mode, local->conf.phymode);
+	       local->conf.phymode);
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	if (local->hw->config)
@@ -1957,7 +1943,8 @@ static struct net_device * ieee80211_sta
 	list_for_each(ptr, &local->sub_if_list) {
 		struct ieee80211_sub_if_data *sdata =
 			list_entry(ptr, struct ieee80211_sub_if_data, list);
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA &&
+		    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
 			continue;
 		if (!multicast &&
 		    memcmp(a1, sdata->dev->dev_addr, ETH_ALEN) != 0)
@@ -1965,7 +1952,7 @@ static struct net_device * ieee80211_sta
 
 		if (memcmp(addr, sdata->u.sta.bssid, ETH_ALEN) == 0 ||
 		    (memcmp(addr, "\xff\xff\xff\xff\xff\xff", ETH_ALEN) == 0 &&
-		     local->conf.mode == IW_MODE_ADHOC)) {
+		     sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)) {
 			*sta_multicast = multicast;
 			return sdata->dev;
 		}
@@ -2007,7 +1994,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 	u8 dst[ETH_ALEN];
 	u8 src[ETH_ALEN];
         struct sk_buff *skb = rx->skb, *skb2;
-        struct ieee80211_sub_if_data *sdata;
+        struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	fc = rx->fc;
 	if (unlikely(WLAN_FC_GET_TYPE(fc) != WLAN_FC_TYPE_DATA))
@@ -2034,7 +2021,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 
-		if (unlikely(local->conf.mode != IW_MODE_MASTER ||
+		if (unlikely(sdata->type != IEEE80211_SUB_IF_TYPE_AP ||
 			     !ieee80211_own_bssid(local, hdr->addr1))) {
 			printk(KERN_DEBUG "%s: dropped ToDS frame (BSSID="
 			       MACSTR " SA=" MACSTR " DA=" MACSTR ")\n",
@@ -2064,7 +2051,6 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr1, ETH_ALEN);
 		memcpy(src, hdr->addr3, ETH_ALEN);
 
-		sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
 		    memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN) == 0 ||
 		    memcmp(hdr->addr2, sdata->u.sta.bssid, ETH_ALEN) != 0) {
@@ -2076,7 +2062,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr1, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 
-		if (local->conf.mode != IW_MODE_ADHOC ||
+		if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS ||
 		    memcmp(hdr->addr3, local->bssid, ETH_ALEN) != 0) {
 			if (net_ratelimit()) {
 				printk(KERN_DEBUG "%s: dropped IBSS frame (DA="
@@ -2140,8 +2126,8 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		sdata->stats.rx_bytes += skb->len;
         }
 
-	if (local->bridge_packets && sdata->type != IEEE80211_SUB_IF_TYPE_WDS
-	    && sdata->type != IEEE80211_SUB_IF_TYPE_STA) {
+	if (local->bridge_packets && (sdata->type == IEEE80211_SUB_IF_TYPE_AP
+	    || sdata->type == IEEE80211_SUB_IF_TYPE_VLAN)) {
 		if (MULTICAST_ADDR(skb->data)) {
 			/* send multicast frames both to higher layers in
 			 * local net stack and back to the wireless media */
@@ -2672,7 +2658,7 @@ #endif /* IEEE80211_LEDS */
 static ieee80211_txrx_result
 ieee80211_rx_h_monitor(struct ieee80211_txrx_data *rx)
 {
-	if (rx->local->conf.mode == IW_MODE_MONITOR) {
+	if (rx->sdata->type == IEEE80211_SUB_IF_TYPE_MNTR) {
 		ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
                                   ieee80211_msg_monitor);
 		return TXRX_QUEUED;
@@ -2711,7 +2697,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 
 	/* Filter out foreign unicast packets when in promiscuous mode.
 	 * FIX: Filter out multicast to foreign BSSID. */
-	if (rx->local->conf.mode == IW_MODE_INFRA &&
+	if (rx->sdata->type == IEEE80211_SUB_IF_TYPE_STA &&
 	    !MULTICAST_ADDR(hdr->addr1) &&
 	    !ieee80211_own_addr(rx->dev, hdr->addr1))
 		return TXRX_DROP;
@@ -2727,7 +2713,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 	if (unlikely((WLAN_FC_GET_TYPE(rx->fc) == WLAN_FC_TYPE_DATA ||
 		      (WLAN_FC_GET_TYPE(rx->fc) == WLAN_FC_TYPE_CTRL &&
 		       WLAN_FC_GET_STYPE(rx->fc) == WLAN_FC_STYPE_PSPOLL)) &&
-		     rx->local->conf.mode != IW_MODE_ADHOC &&
+		     rx->sdata->type != IEEE80211_SUB_IF_TYPE_IBSS &&
 		     (!rx->sta || !(rx->sta->flags & WLAN_STA_ASSOC)))) {
 		if (!(rx->fc & WLAN_FC_FROMDS) && !(rx->fc & WLAN_FC_TODS)) {
 			/* Drop IBSS frames silently. */
@@ -2739,7 +2725,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		return TXRX_QUEUED;
 	}
 
-	if (rx->local->conf.mode == IW_MODE_INFRA)
+	if (rx->sdata->type == IEEE80211_SUB_IF_TYPE_STA)
 		always_sta_key = 0;
 	else
 		always_sta_key = 1;
@@ -2815,13 +2801,13 @@ ieee80211_rx_h_sta_process(struct ieee80
 	/* Update last_rx only for IBSS packets which are for the current
 	 * BSSID to avoid keeping the current IBSS network alive in cases where
 	 * other STAs are using different BSSID. */
-	if (rx->local->conf.mode == IW_MODE_ADHOC) {
+	if (rx->sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
 		u8 *bssid = ieee80211_get_bssid(hdr, rx->skb->len);
 		if (memcmp(bssid, rx->local->bssid, ETH_ALEN) == 0)
 			sta->last_rx = jiffies;
 	} else
 	if (!MULTICAST_ADDR(hdr->addr1) ||
-	    rx->local->conf.mode == IW_MODE_INFRA) {
+	    rx->sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
 		/* Update last_rx only for unicast frames in order to prevent
 		 * the Probe Request frames (the only broadcast frames from a
 		 * STA in infrastructure mode) from keeping a connection alive.
@@ -2920,7 +2906,7 @@ static ieee80211_txrx_result
 ieee80211_rx_h_802_1x_pae(struct ieee80211_txrx_data *rx)
 {
 	if (rx->sdata->eapol && ieee80211_is_eapol(rx->skb) &&
-	    rx->local->conf.mode != IW_MODE_INFRA) {
+	    rx->sdata->type != IEEE80211_SUB_IF_TYPE_STA) {
 		/* Pass both encrypted and unencrypted EAPOL frames to user
 		 * space for processing. */
 		ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
@@ -2974,7 +2960,8 @@ ieee80211_rx_h_mgmt(struct ieee80211_txr
 {
         struct ieee80211_sub_if_data *sdata;
 	sdata = IEEE80211_DEV_TO_SUB_IF(rx->dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
 		ieee80211_sta_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status);
 	} else {
 		/* Management frames are sent to hostapd for processing */
@@ -3076,8 +3063,7 @@ static struct net_device * ieee80211_get
 	bssid = ieee80211_get_bssid(hdr, len);
 	if (bssid) {
 		dev = ieee80211_own_bssid(local, bssid);
-		if (!dev && (local->conf.mode == IW_MODE_INFRA ||
-			     local->conf.mode == IW_MODE_ADHOC))
+		if (!dev)
 			dev = ieee80211_sta_bssid(local, bssid, hdr->addr1,
 						  sta_broadcast);
 		if (dev)
@@ -3137,7 +3123,7 @@ static void ieee80211_rx_michael_mic_rep
 	}
 
 	if (rx->local->hw->wep_include_iv &&
-	    rx->local->conf.mode == IW_MODE_MASTER) {
+	    rx->sdata->type == IEEE80211_SUB_IF_TYPE_AP) {
 		int keyidx = ieee80211_wep_get_keyidx(rx->skb);
 		/* AP with Pairwise keys support should never receive Michael
 		 * MIC errors for non-zero keyidx because these are reserved
@@ -3268,26 +3254,27 @@ void __ieee80211_rx(struct net_device *d
 	memset(&rx, 0, sizeof(rx));
 	rx.skb = skb;
 	rx.local = local;
-	if (skb->len >= 16) {
+	if (skb->len >= 16)
 		sta = rx.sta = sta_info_get(local, hdr->addr2);
-		if (unlikely(sta == NULL &&
-			     local->conf.mode == IW_MODE_ADHOC)) {
+	else
+		sta = rx.sta = NULL;
+	if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS)) {
+		rx.dev = sta->dev;
+		rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
+	} else {
+		rx.dev = ieee80211_get_rx_dev(local, hdr, skb->len,
+					      &sta_broadcast);
+		rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
+		if (sta == NULL &&
+		    rx.sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
 			u8 *bssid = ieee80211_get_bssid(hdr, skb->len);
-			if (bssid &&
-			    memcmp(bssid, local->bssid, ETH_ALEN) == 0)
+			if (bssid)
 				sta = rx.sta =
 					ieee80211_ibss_add_sta(dev, skb, bssid,
 							       hdr->addr2);
 		}
-	} else
-		sta = rx.sta = NULL;
-        if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS))
-		rx.dev = sta->dev;
-	else
-		rx.dev = ieee80211_get_rx_dev(local, hdr, skb->len,
-					      &sta_broadcast);
+	}
 
-	rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
 	rx.u.rx.status = status;
 	rx.fc = skb->len >= 2 ? le16_to_cpu(hdr->frame_control) : 0;
 	type = WLAN_FC_GET_TYPE(rx.fc);
@@ -4550,7 +4537,6 @@ int ieee80211_register_hw(struct net_dev
 	if (result < 0)
 		goto fail_sysfs;
 
-	local->conf.mode = IW_MODE_MASTER;
 	local->conf.beacon_int = 1000;
 
 	ieee80211_update_hw(dev, hw);	/* Don't care about the result. */
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 71b72fe..8f0aad5 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -541,8 +541,8 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	 * optimized by using non-default keys (at least with Atheros ar521x).
 	 */
 	if (!sta && alg == ALG_WEP && !local->default_wep_only &&
-	    local->conf.mode != IW_MODE_ADHOC &&
-	    local->conf.mode != IW_MODE_INFRA) {
+	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS &&
+	    sdata->type != IEEE80211_SUB_IF_TYPE_AP) {
 		try_hwaccel = 0;
 	}
 
@@ -1052,7 +1052,8 @@ static int ieee80211_ioctl_sta_get_state
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA &&
+	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
 		return -EINVAL;
 	param->u.sta_get_state.state = sdata->u.sta.state;
 	return 0;
@@ -1065,15 +1066,14 @@ static int ieee80211_ioctl_mlme(struct n
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA &&
+	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
 		return -EINVAL;
 	switch (param->u.mlme.cmd) {
 	case MLME_STA_DEAUTH:
-		ieee80211_sta_deauthenticate(dev, param->u.mlme.reason_code);
-		break;
+		return ieee80211_sta_deauthenticate(dev, param->u.mlme.reason_code);
 	case MLME_STA_DISASSOC:
-		ieee80211_sta_disassociate(dev, param->u.mlme.reason_code);
-		break;
+		return ieee80211_sta_disassociate(dev, param->u.mlme.reason_code);
 	}
 	return 0;
 }
@@ -1126,7 +1126,8 @@ static int ieee80211_set_gen_ie(struct n
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA)
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)
 		return ieee80211_sta_set_extra_ie(dev, ie, len);
 
 	kfree(local->conf.generic_elem);
@@ -1654,16 +1655,11 @@ static int ieee80211_init_client(struct 
 }
 
 
-static int ieee80211_is_client_mode(int iw_mode)
-{
-	return (iw_mode == IW_MODE_INFRA || iw_mode == IW_MODE_ADHOC);
-}
-
-
 static int ieee80211_ioctl_siwmode(struct net_device *dev,
 				   struct iw_request_info *info,
 				   __u32 *mode, char *extra)
 {
+#if 0
 	struct ieee80211_local *local = dev->priv;
 
 	if (!ieee80211_is_client_mode(local->conf.mode) &&
@@ -1689,6 +1685,9 @@ static int ieee80211_ioctl_siwmode(struc
 	}
 	local->conf.mode = *mode;
 	return ieee80211_hw_config(dev);
+#else
+	return -EOPNOTSUPP;
+#endif
 }
 
 
@@ -1696,17 +1695,32 @@ static int ieee80211_ioctl_giwmode(struc
 				   struct iw_request_info *info,
 				   __u32 *mode, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
-		if (local->conf.mode == IW_MODE_ADHOC)
-			*mode = IW_MODE_ADHOC;
-		else
-			*mode = IW_MODE_INFRA;
-	} else
-		*mode = local->conf.mode;
+	switch (sdata->type) {
+	case IEEE80211_SUB_IF_TYPE_AP:
+		*mode = IW_MODE_MASTER;
+		break;
+	case IEEE80211_SUB_IF_TYPE_STA:
+		*mode = IW_MODE_INFRA;
+		break;
+	case IEEE80211_SUB_IF_TYPE_IBSS:
+		*mode = IW_MODE_ADHOC;
+		break;
+	case IEEE80211_SUB_IF_TYPE_MNTR:
+		*mode = IW_MODE_MONITOR;
+		break;
+	case IEEE80211_SUB_IF_TYPE_WDS:
+		*mode = IW_MODE_REPEAT;
+		break;
+	case IEEE80211_SUB_IF_TYPE_VLAN:
+		*mode = IW_MODE_SECOND;		/* FIXME */
+		break;
+	default:
+		*mode = IW_MODE_AUTO;
+		break;
+	}
 	return 0;
 }
 
@@ -1793,7 +1807,8 @@ static int ieee80211_ioctl_siwessid(stru
 		len--;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA)
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)
 		return ieee80211_sta_set_ssid(dev, ssid, len);
 
 	kfree(local->conf.ssid);
@@ -1816,7 +1831,8 @@ static int ieee80211_ioctl_giwessid(stru
 
 	struct ieee80211_sub_if_data *sdata;
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
 		int res = ieee80211_sta_get_ssid(dev, ssid, &len);
 		if (res == 0)
 			data->length = len;
@@ -1840,7 +1856,8 @@ static int ieee80211_ioctl_siwap(struct 
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
 		int changed_bssid = 0;
 		if (memcmp(local->conf.client_bssid, (u8 *) &ap_addr->sa_data,
 			   ETH_ALEN) != 0)
@@ -1870,7 +1887,8 @@ static int ieee80211_ioctl_giwap(struct 
         struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
+	    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
 		ap_addr->sa_family = ARPHRD_ETHER;
 		memcpy(&ap_addr->sa_data, sdata->u.sta.bssid, ETH_ALEN);
 		return 0;
@@ -2288,7 +2306,8 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_AP_AUTH_ALGS:
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
+		    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
 			sdata->u.sta.auth_algs = value;
 		} else
 			ret = -EOPNOTSUPP;
@@ -2464,7 +2483,8 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_MIXED_CELL:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
+		    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			sdata->u.sta.mixed_cell = !!value;
@@ -2482,13 +2502,14 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			sdata->u.sta.create_ibss = !!value;
 		break;
 	case PRISM2_PARAM_WMM_ENABLED:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
+		    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			sdata->u.sta.wmm_enabled = !!value;
@@ -2529,7 +2550,8 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_AP_AUTH_ALGS:
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
+		    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
 			*param = sdata->u.sta.auth_algs;
 		} else
 			ret = -EOPNOTSUPP;
@@ -2653,14 +2675,15 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			*param = !!sdata->u.sta.create_ibss;
 		break;
 
 	case PRISM2_PARAM_MIXED_CELL:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
+		    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			*param = !!sdata->u.sta.mixed_cell;
@@ -2673,7 +2696,8 @@ static int ieee80211_ioctl_get_prism2_pa
 			*param = sdata->u.sta.key_mgmt;
 		break;
 	case PRISM2_PARAM_WMM_ENABLED:
-		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
+		    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
 			*param = !!sdata->u.sta.wmm_enabled;
@@ -2715,7 +2739,8 @@ static int ieee80211_ioctl_siwmlme(struc
 	struct iw_mlme *mlme = (struct iw_mlme *) extra;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA ||
+	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
 		return -EINVAL;
 
 	switch (mlme->cmd) {
@@ -2859,7 +2884,8 @@ static int ieee80211_ioctl_siwauth(struc
 		}
 		break;
 	case IW_AUTH_80211_AUTH_ALG:
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
+		    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)
 			sdata->u.sta.auth_algs = data->value;
 		else
 			ret = -EOPNOTSUPP;
@@ -2885,7 +2911,8 @@ static int ieee80211_ioctl_giwauth(struc
 
 	switch (data->flags & IW_AUTH_INDEX) {
 	case IW_AUTH_80211_AUTH_ALG:
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA)
+		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA ||
+		    sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)
 			data->value = sdata->u.sta.auth_algs;
 		else
 			ret = -EOPNOTSUPP;
diff --git a/net/d80211/ieee80211_proc.c b/net/d80211/ieee80211_proc.c
index 5d77c2a..3709494 100644
--- a/net/d80211/ieee80211_proc.c
+++ b/net/d80211/ieee80211_proc.c
@@ -110,10 +110,13 @@ static char * ieee80211_proc_sub_if_ap(c
 }
 
 
-static char * ieee80211_proc_sub_if_sta(char *p,
+static char * ieee80211_proc_sub_if_sta(char *p, int ibss,
 					struct ieee80211_if_sta *ifsta)
 {
-	p += sprintf(p, "type=sta\n");
+	if (ibss)
+		p += sprintf(p, "type=ibss\n");
+	else
+		p += sprintf(p, "type=sta\n");
 	p += sprintf(p,
 		     "state=%d\n"
 		     "bssid=" MACSTR "\n"
@@ -176,7 +179,10 @@ static char * ieee80211_proc_sub_if(char
 		p += sprintf(p, "vlan.id=%d\n", sdata->u.vlan.id);
 		break;
 	case IEEE80211_SUB_IF_TYPE_STA:
-		p = ieee80211_proc_sub_if_sta(p, &sdata->u.sta);
+		p = ieee80211_proc_sub_if_sta(p, 0, &sdata->u.sta);
+		break;
+	case IEEE80211_SUB_IF_TYPE_IBSS:
+		p = ieee80211_proc_sub_if_sta(p, 1, &sdata->u.sta);
 		break;
 	}
 	p += sprintf(p, "channel_use=%d\n", sdata->channel_use);
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 5a59750..9972b98 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -859,11 +859,11 @@ static void ieee80211_rx_mgmt_auth(struc
 				   size_t len,
 				   struct ieee80211_rx_status *rx_status)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	u16 auth_alg, auth_transaction, status_code;
 
 	if (ifsta->state != IEEE80211_AUTHENTICATE &&
-	    local->conf.mode != IW_MODE_ADHOC) {
+	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS) {
 		printk(KERN_DEBUG "%s: authentication frame received from "
 		       MACSTR ", but not in authenticate state - ignored\n",
 		       dev->name, MAC2STR(mgmt->sa));
@@ -877,7 +877,7 @@ static void ieee80211_rx_mgmt_auth(struc
 		return;
 	}
 
-	if (local->conf.mode != IW_MODE_ADHOC &&
+	if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS &&
 	    memcmp(ifsta->bssid, mgmt->sa, ETH_ALEN) != 0) {
 		printk(KERN_DEBUG "%s: authentication frame received from "
 		       "unknown AP (SA=" MACSTR " BSSID=" MACSTR ") - "
@@ -886,7 +886,7 @@ static void ieee80211_rx_mgmt_auth(struc
 		return;
 	}
 
-	if (local->conf.mode == IW_MODE_ADHOC &&
+	if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS &&
 	    memcmp(ifsta->bssid, mgmt->bssid, ETH_ALEN) != 0) {
 		printk(KERN_DEBUG "%s: authentication frame received from "
 		       "unknown BSSID (SA=" MACSTR " BSSID=" MACSTR ") - "
@@ -904,7 +904,7 @@ static void ieee80211_rx_mgmt_auth(struc
 	       dev->name, MAC2STR(mgmt->sa), auth_alg,
 	       auth_transaction, status_code);
 
-	if (local->conf.mode == IW_MODE_ADHOC) {
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
 		/* IEEE 802.11 standard does not require authentication in IBSS
 		 * networks and most implementations do not seem to use it.
 		 * However, try to reply to authentication attempts if someone
@@ -1341,7 +1341,7 @@ static void ieee80211_rx_bss_info(struct
 	int channel, invalid = 0, clen;
 	struct ieee80211_sta_bss *bss;
 	struct sta_info *sta;
-	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	u64 timestamp;
 	u8 *pos;
 
@@ -1364,7 +1364,7 @@ #endif
 		((u64) pos[3] << 24) | ((u64) pos[2] << 16) |
 		((u64) pos[1] << 8) | ((u64) pos[0]);
 
-	if (local->conf.mode == IW_MODE_ADHOC && beacon &&
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS && beacon &&
 	    memcmp(mgmt->bssid, local->bssid, ETH_ALEN) == 0) {
 #ifdef IEEE80211_IBSS_DEBUG
 		static unsigned long last_tsf_debug = 0;
@@ -1388,11 +1388,9 @@ #endif /* IEEE80211_IBSS_DEBUG */
 				   &elems) == ParseFailed)
 		invalid = 1;
 
-	if (local->conf.mode == IW_MODE_ADHOC && elems.supp_rates &&
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS && elems.supp_rates &&
 	    memcmp(mgmt->bssid, local->bssid, ETH_ALEN) == 0 &&
-	    (sta = sta_info_get(local, mgmt->sa)) &&
-	    (sdata = IEEE80211_DEV_TO_SUB_IF(dev)) &&
-	    sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+	    (sta = sta_info_get(local, mgmt->sa))) {
 		struct ieee80211_rate *rates;
 		size_t num_rates;
 		u32 supp_rates, prev_rates;
@@ -1647,12 +1645,13 @@ static void ieee80211_rx_mgmt_probe_req(
 					struct ieee80211_rx_status *rx_status)
 {
 	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	int tx_last_beacon;
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *resp;
 	u8 *pos, *end;
 
-	if (local->conf.mode != IW_MODE_ADHOC ||
+	if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS ||
 	    ifsta->state != IEEE80211_IBSS_JOINED ||
 	    len < 24 + 2 || ifsta->probe_resp == NULL)
 		return;
@@ -1866,7 +1865,8 @@ void ieee80211_sta_timer(unsigned long p
 
 	dev = (struct net_device *) ptr;
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA) {
+	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA &&
+	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS) {
 		printk(KERN_DEBUG "%s: ieee80211_sta_timer: non-STA interface "
 		       "(type=%d)\n", dev->name, sdata->type);
 		return;
@@ -1911,8 +1911,9 @@ static void ieee80211_sta_new_auth(struc
 				   struct ieee80211_if_sta *ifsta)
 {
 	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
-	if (local->conf.mode != IW_MODE_INFRA)
+	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
 		return;
 
 	if (local->hw->reset_tsf) {
@@ -2318,7 +2319,7 @@ int ieee80211_sta_set_ssid(struct net_de
 	ifsta->ssid_len = len;
 
 	ifsta->ssid_set = 1;
-	if (local->conf.mode == IW_MODE_ADHOC && !ifsta->bssid_set) {
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS && !ifsta->bssid_set) {
 		ifsta->ibss_join_req = jiffies;
 		ifsta->state = IEEE80211_IBSS_SEARCH;
 		return ieee80211_sta_find_ibss(dev, ifsta);
@@ -2351,7 +2352,7 @@ int ieee80211_sta_set_bssid(struct net_d
 	ifsta = &sdata->u.sta;
 
 	memcpy(ifsta->bssid, bssid, ETH_ALEN);
-	if (local->conf.mode == IW_MODE_ADHOC)
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)
 		memcpy(local->bssid, bssid, ETH_ALEN);
 
 	if (memcmp(bssid, "\x00\x00\x00\x00\x00\x00", ETH_ALEN) == 0)
@@ -2417,6 +2418,7 @@ static void ieee80211_sta_scan_timer(uns
 {
 	struct net_device *dev = (struct net_device *) ptr;
 	struct ieee80211_local *local = dev->priv;
+        struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
 	int skip;
@@ -2441,7 +2443,7 @@ static void ieee80211_sta_scan_timer(uns
 			local->last_scan_completed = jiffies;
 			memset(&wrqu, 0, sizeof(wrqu));
 			wireless_send_event(dev, SIOCGIWSCAN, &wrqu, NULL);
-			if (local->conf.mode == IW_MODE_ADHOC) {
+			if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
 				struct ieee80211_sub_if_data *sdata =
 					IEEE80211_DEV_TO_SUB_IF(dev);
 				struct ieee80211_if_sta *ifsta = &sdata->u.sta;
@@ -2455,7 +2457,7 @@ static void ieee80211_sta_scan_timer(uns
 		skip = !(local->hw_modes & (1 << mode->mode));
 		chan = &mode->channels[local->scan_channel_idx];
 		if (!(chan->flag & IEEE80211_CHAN_W_SCAN) ||
-		    (local->conf.mode == IW_MODE_ADHOC &&
+		    (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS &&
 		     !(chan->flag & IEEE80211_CHAN_W_IBSS)) ||
 		    (local->hw_modes & (1 << MODE_IEEE80211G) &&
 		     mode->mode == MODE_IEEE80211B && local->scan_skip_11b))
@@ -2801,7 +2803,7 @@ struct sta_info * ieee80211_ibss_add_sta
 	spin_lock_bh(&local->sub_if_lock);
 	list_for_each(ptr, &local->sub_if_list) {
 		sdata = list_entry(ptr, struct ieee80211_sub_if_data, list);
-		if (sdata->type == IEEE80211_SUB_IF_TYPE_STA &&
+		if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS &&
 		    memcmp(bssid, sdata->u.sta.bssid, ETH_ALEN) == 0) {
 			sta_dev = sdata->dev;
 			break;
@@ -2837,7 +2839,8 @@ int ieee80211_sta_deauthenticate(struct 
 	printk(KERN_DEBUG "%s: deauthenticate(reason=%d)\n",
 	       dev->name, reason);
 
-	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
+	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA &&
+	    sdata->type != IEEE80211_SUB_IF_TYPE_IBSS)
 		return -EINVAL;
 
 	ieee80211_send_deauth(dev, ifsta, reason);
-- 
1.3.0

