From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/4] d80211: fix receiving through virtual interfaces
Date: Mon,  3 Jul 2006 19:24:08 +0200 (CEST)
Message-ID: <20060703172408.C9183483BB@silver.suse.cz>
References: <20060703192335.935001000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:2735 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751205AbWGCRWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 13:22:35 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060703192335.935001000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes several problems with receiving when multiple interfaces are
present or when some interface is in promiscious mode:

- Packet type (PACKET_HOST and PACKET_OTHER_HOST) is set correctly now.
- Failed decryption of a frame is reported only once for each frame.
- Failed decryption of a frame not destined to the interface (e.g. when the
  interface is in promisc mode) is not reported.
- Channel utilization is counted correctly (i.e. once for each frame only,
  independently on number of active virtual interfaces). To achieve this,
  ieee80211_rx_handlers needed to be separated into new
  ieee80211_rx_handlers and ieee80211_rx_pre_handlers structures.

Defragmentation still doesn't work correctly in promisc mode. This is fixed
by subsequent patches.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c   |  171 +++++++++++++++++++++++++++++++---------------
 net/d80211/ieee80211_i.h |    5 +
 net/d80211/wpa.c         |    4 +
 3 files changed, 124 insertions(+), 56 deletions(-)

6cc76c3c2c5de4e1ad40a8b82201eff5eab81939
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index fe1003b..52316f9 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2463,27 +2463,15 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(ehdr->h_source, src, ETH_ALEN);
                 ehdr->h_proto = len;
 	}
-
-        if (rx->sta && !rx->sta->assoc_ap &&
-	    !(rx->sta && (rx->sta->flags & WLAN_STA_WDS)))
-                skb->dev = rx->sta->dev;
-        else
-                skb->dev = dev;
+	skb->dev = dev;
 
         skb2 = NULL;
-        sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
-        /*
-         * don't count the master since the low level code
-         * counts it already for us.
-         */
-        if (skb->dev != sdata->master) {
-		sdata->stats.rx_packets++;
-		sdata->stats.rx_bytes += skb->len;
-        }
+	sdata->stats.rx_packets++;
+	sdata->stats.rx_bytes += skb->len;
 
 	if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP
-	    || sdata->type == IEEE80211_IF_TYPE_VLAN)) {
+	    || sdata->type == IEEE80211_IF_TYPE_VLAN) && rx->u.rx.ra_match) {
 		if (is_multicast_ether_addr(skb->data)) {
 			/* send multicast frames both to higher layers in
 			 * local net stack and back to the wireless media */
@@ -2760,13 +2748,14 @@ #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 
 
 static ieee80211_txrx_result
-ieee80211_rx_h_ieee80211_rx_h_ps_poll(struct ieee80211_txrx_data *rx)
+ieee80211_rx_h_ps_poll(struct ieee80211_txrx_data *rx)
 {
 	struct sk_buff *skb;
 	int no_pending_pkts;
 
 	if (likely(!rx->sta || WLAN_FC_GET_TYPE(rx->fc) != WLAN_FC_TYPE_CTRL ||
-		   WLAN_FC_GET_STYPE(rx->fc) != WLAN_FC_STYPE_PSPOLL))
+		   WLAN_FC_GET_STYPE(rx->fc) != WLAN_FC_STYPE_PSPOLL ||
+		   !rx->u.rx.ra_match))
 		return TXRX_CONTINUE;
 
 	skb = skb_dequeue(&rx->sta->tx_filtered);
@@ -3042,8 +3031,10 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		if (unlikely(rx->fc & WLAN_FC_RETRY &&
 			     rx->sta->last_seq_ctrl[rx->u.rx.queue] ==
 			     hdr->seq_ctrl)) {
-			rx->local->dot11FrameDuplicateCount++;
-			rx->sta->num_duplicates++;
+			if (rx->u.rx.ra_match) {
+				rx->local->dot11FrameDuplicateCount++;
+				rx->sta->num_duplicates++;
+			}
 			return TXRX_DROP;
 		} else
 			rx->sta->last_seq_ctrl[rx->u.rx.queue] = hdr->seq_ctrl;
@@ -3057,7 +3048,9 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		return TXRX_DROP;
 	}
 
-	if (memcmp(rx->dev->dev_addr, hdr->addr1, ETH_ALEN) == 0)
+	if (rx->fc & WLAN_FC_TODS)
+		rx->skb->pkt_type = PACKET_OTHERHOST;
+	else if (memcmp(rx->dev->dev_addr, hdr->addr1, ETH_ALEN) == 0)
 		rx->skb->pkt_type = PACKET_HOST;
 	else if (is_multicast_ether_addr(hdr->addr1)) {
 		if (is_broadcast_ether_addr(hdr->addr1))
@@ -3080,8 +3073,10 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		       WLAN_FC_GET_STYPE(rx->fc) == WLAN_FC_STYPE_PSPOLL)) &&
 		     rx->sdata->type != IEEE80211_IF_TYPE_IBSS &&
 		     (!rx->sta || !(rx->sta->flags & WLAN_STA_ASSOC)))) {
-		if (!(rx->fc & WLAN_FC_FROMDS) && !(rx->fc & WLAN_FC_TODS)) {
-			/* Drop IBSS frames silently. */
+		if ((!(rx->fc & WLAN_FC_FROMDS) && !(rx->fc & WLAN_FC_TODS)) ||
+		    !rx->u.rx.ra_match) {
+			/* Drop IBSS frames and frames for other hosts
+			 * silently. */
 			return TXRX_DROP;
 		}
 
@@ -3113,6 +3108,8 @@ ieee80211_rx_h_check(struct ieee80211_tx
 				rx->key = rx->sdata->keys[keyidx];
 			}
 			if (!rx->key) {
+				if (!rx->u.rx.ra_match)
+					return TXRX_DROP;
 				printk(KERN_DEBUG "%s: RX WEP frame with "
 				       "unknown keyidx %d (A1=" MACSTR " A2="
 				       MACSTR " A3=" MACSTR ")\n",
@@ -3128,7 +3125,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		}
         }
 
-	if (rx->fc & WLAN_FC_ISWEP && rx->key) {
+	if (rx->fc & WLAN_FC_ISWEP && rx->key && rx->u.rx.ra_match) {
 		rx->key->tx_rx_count++;
 		if (unlikely(rx->local->key_tx_rx_threshold &&
 			     rx->key->tx_rx_count >
@@ -3168,6 +3165,10 @@ ieee80211_rx_h_sta_process(struct ieee80
 		 */
 		sta->last_rx = jiffies;
 	}
+
+	if (!rx->u.rx.ra_match)
+		return TXRX_CONTINUE;
+
 	sta->rx_fragments++;
 	sta->rx_bytes += rx->skb->len;
 	sta->last_rssi = rx->u.rx.status->ssi;
@@ -3203,7 +3204,7 @@ ieee80211_rx_h_wep_weak_iv_detection(str
 {
 	if (!rx->sta || !(rx->fc & WLAN_FC_ISWEP) ||
 	    WLAN_FC_GET_TYPE(rx->fc) != WLAN_FC_TYPE_DATA || !rx->key ||
-	    rx->key->alg != ALG_WEP)
+	    rx->key->alg != ALG_WEP || !rx->u.rx.ra_match)
 		return TXRX_CONTINUE;
 
 	/* Check for weak IVs, if hwaccel did not remove IV from the frame */
@@ -3260,7 +3261,7 @@ static ieee80211_txrx_result
 ieee80211_rx_h_802_1x_pae(struct ieee80211_txrx_data *rx)
 {
 	if (rx->sdata->eapol && ieee80211_is_eapol(rx->skb) &&
-	    rx->sdata->type != IEEE80211_IF_TYPE_STA) {
+	    rx->sdata->type != IEEE80211_IF_TYPE_STA && rx->u.rx.ra_match) {
 		/* Pass both encrypted and unencrypted EAPOL frames to user
 		 * space for processing. */
 		ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
@@ -3313,6 +3314,10 @@ static ieee80211_txrx_result
 ieee80211_rx_h_mgmt(struct ieee80211_txrx_data *rx)
 {
         struct ieee80211_sub_if_data *sdata;
+
+	if (!rx->u.rx.ra_match)
+		return TXRX_DROP;
+
 	sdata = IEEE80211_DEV_TO_SUB_IF(rx->dev);
 	if ((sdata->type == IEEE80211_IF_TYPE_STA ||
 	     sdata->type == IEEE80211_IF_TYPE_IBSS) &&
@@ -3351,7 +3356,8 @@ ieee80211_rx_h_passive_scan(struct ieee8
                 fc = le16_to_cpu(hdr->frame_control);
 
                 if (WLAN_FC_GET_TYPE(fc) == WLAN_FC_TYPE_MGMT &&
-		    WLAN_FC_GET_STYPE(fc) == WLAN_FC_STYPE_BEACON) {
+		    WLAN_FC_GET_STYPE(fc) == WLAN_FC_STYPE_BEACON &&
+		    rx->dev == local->mdev) {
 			local->scan.rx_beacon++;
 			/* Need to trim FCS here because it is normally
 			 * removed only after this passive scan handler. */
@@ -3502,14 +3508,16 @@ static void ieee80211_rx_michael_mic_rep
 	rx->skb = NULL;
 }
 
-static inline void ieee80211_invoke_rx_handlers(struct ieee80211_local *local,
-						struct ieee80211_txrx_data *rx,
-						struct sta_info *sta)
+static inline ieee80211_txrx_result __ieee80211_invoke_rx_handlers(
+				struct ieee80211_local *local,
+				ieee80211_rx_handler *handlers,
+				struct ieee80211_txrx_data *rx,
+				struct sta_info *sta)
 {
 	ieee80211_rx_handler *handler;
         ieee80211_txrx_result res = TXRX_DROP;
 
-	for (handler = local->rx_handlers; *handler != NULL; handler++) {
+	for (handler = handlers; *handler != NULL; handler++) {
 		res = (*handler)(rx);
 		if (res != TXRX_CONTINUE) {
 			if (res == TXRX_DROP) {
@@ -3523,8 +3531,19 @@ static inline void ieee80211_invoke_rx_h
 		}
 	}
 
+	if (res == TXRX_DROP) {
+		dev_kfree_skb(rx->skb);
+	}
+	return res;
+}
 
-	if (res == TXRX_DROP || *handler == NULL)
+static inline void ieee80211_invoke_rx_handlers(struct ieee80211_local *local,
+						ieee80211_rx_handler *handlers,
+						struct ieee80211_txrx_data *rx,
+						struct sta_info *sta)
+{
+	if (__ieee80211_invoke_rx_handlers(local, handlers, rx, sta) ==
+	    TXRX_CONTINUE)
 		dev_kfree_skb(rx->skb);
 }
 
@@ -3568,37 +3587,57 @@ void __ieee80211_rx(struct net_device *d
 	if (unlikely(local->sta_scanning || local->scan.in_scan))
 		rx.u.rx.in_scan = 1;
 
+	if (__ieee80211_invoke_rx_handlers(local, local->rx_pre_handlers, &rx,
+					   sta) != TXRX_CONTINUE)
+		goto end;
+	skb = rx.skb;
+
 	if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS) &&
 	    !local->iff_promiscs && !multicast) {
 		rx.dev = sta->dev;
 		rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
-		ieee80211_invoke_rx_handlers(local, &rx, sta);
+		rx.u.rx.ra_match = 1;
+		ieee80211_invoke_rx_handlers(local, local->rx_handlers, &rx,
+					     sta);
 	} else {
 		struct ieee80211_sub_if_data *prev = NULL;
 		struct sk_buff *skb_new;
 		u8 *bssid = ieee80211_get_bssid(hdr, skb->len);
 
 		list_for_each_entry(sdata, &local->sub_if_list, list) {
+			rx.u.rx.ra_match = 1;
 			switch (sdata->type) {
 			case IEEE80211_IF_TYPE_STA:
-				if (!bssid || memcmp(sdata->u.sta.bssid,
-						     bssid, ETH_ALEN) != 0)
-					continue;
-				if (!multicast && !sdata->promisc &&
-				    memcmp(sdata->dev->dev_addr, hdr->addr1,
-					   ETH_ALEN) != 0)
+				if (!bssid)
 					continue;
+				if (!ieee80211_bssid_match(bssid,
+							sdata->u.sta.bssid)) {
+					if (!rx.u.rx.in_scan)
+						continue;
+					rx.u.rx.ra_match = 0;
+				} else if (!multicast &&
+					   memcmp(sdata->dev->dev_addr,
+						  hdr->addr1, ETH_ALEN) != 0) {
+					if (!sdata->promisc)
+						continue;
+					rx.u.rx.ra_match = 0;
+				}
 				break;
 			case IEEE80211_IF_TYPE_IBSS:
-				if (!bssid ||
-				    !ieee80211_bssid_match(bssid,
-							   sdata->u.sta.bssid))
-					continue;
-				if (!multicast && !sdata->promisc &&
-				    memcmp(sdata->dev->dev_addr, hdr->addr1,
-					   ETH_ALEN) != 0)
+				if (!bssid)
 					continue;
-				if (sta == NULL) {
+				if (!ieee80211_bssid_match(bssid,
+							sdata->u.sta.bssid)) {
+					if (!rx.u.rx.in_scan)
+						continue;
+					rx.u.rx.ra_match = 0;
+				} else if (!multicast &&
+					   memcmp(sdata->dev->dev_addr,
+						  hdr->addr1, ETH_ALEN) != 0) {
+					if (!sdata->promisc)
+						continue;
+					rx.u.rx.ra_match = 0;
+				} else if (sta == NULL) {
 					sta = rx.sta =
 						ieee80211_ibss_add_sta(dev, skb, bssid,
 								       hdr->addr2);
@@ -3610,10 +3649,12 @@ void __ieee80211_rx(struct net_device *d
 					if (memcmp(sdata->dev->dev_addr,
 						   hdr->addr1, ETH_ALEN) != 0)
 						continue;
-				} else if (!rx.u.rx.in_scan &&
-					   !ieee80211_bssid_match(bssid,
-							sdata->dev->dev_addr))
-					continue;
+				} else if (!ieee80211_bssid_match(bssid,
+							sdata->dev->dev_addr)) {
+					if (!rx.u.rx.in_scan)
+						continue;
+					rx.u.rx.ra_match = 0;
+				}
 				if (sdata->dev == sdata->master &&
 				    !rx.u.rx.in_scan)
 					/* do not receive anything via
@@ -3643,7 +3684,9 @@ void __ieee80211_rx(struct net_device *d
 				rx.skb = skb_new;
 				rx.dev = prev->dev;
 				rx.sdata = prev;
-				ieee80211_invoke_rx_handlers(local, &rx, sta);
+				ieee80211_invoke_rx_handlers(local,
+							     local->rx_handlers,
+							     &rx, sta);
 			}
 			prev = sdata;
 		}
@@ -3651,7 +3694,8 @@ void __ieee80211_rx(struct net_device *d
 			rx.skb = skb;
 			rx.dev = prev->dev;
 			rx.sdata = prev;
-			ieee80211_invoke_rx_handlers(local, &rx, sta);
+			ieee80211_invoke_rx_handlers(local, local->rx_handlers,
+						     &rx, sta);
 		} else
 			dev_kfree_skb(skb);
 	}
@@ -3765,11 +3809,17 @@ ieee80211_rx_h_load_stats(struct ieee802
         local->channel_use_raw += load;
 	if (rx->sta)
 		rx->sta->channel_use_raw += load;
-        rx->sdata->channel_use_raw += load;
+	rx->u.rx.load = load;
 
 	return TXRX_CONTINUE;
 }
 
+static ieee80211_txrx_result
+ieee80211_rx_h_if_stats(struct ieee80211_txrx_data *rx)
+{
+	rx->sdata->channel_use_raw += rx->u.rx.load;
+	return TXRX_CONTINUE;
+}
 
 static void ieee80211_stat_refresh(unsigned long data)
 {
@@ -4113,10 +4163,18 @@ #endif /* IEEE80211_LEDS */
 /* TODO: implement register/unregister functions for adding TX/RX handlers
  * into ordered list */
 
-static ieee80211_rx_handler ieee80211_rx_handlers[] =
+/* rx_pre handlers don't have dev and sdata fields available in
+ * ieee80211_txrx_data */
+static ieee80211_rx_handler ieee80211_rx_pre_handlers[] =
 {
 	ieee80211_rx_h_parse_qos,
 	ieee80211_rx_h_load_stats,
+	NULL
+};
+
+static ieee80211_rx_handler ieee80211_rx_handlers[] =
+{
+	ieee80211_rx_h_if_stats,
 	ieee80211_rx_h_monitor,
 	ieee80211_rx_h_passive_scan,
 	ieee80211_rx_h_check,
@@ -4126,7 +4184,7 @@ static ieee80211_rx_handler ieee80211_rx
 	ieee80211_rx_h_wep_weak_iv_detection,
 	ieee80211_rx_h_wep_decrypt,
 	ieee80211_rx_h_defragment,
-	ieee80211_rx_h_ieee80211_rx_h_ps_poll,
+	ieee80211_rx_h_ps_poll,
 	ieee80211_rx_h_michael_mic_verify,
 	/* this must be after decryption - so header is counted in MPDU mic
 	 * must be before pae and data, so QOS_DATA format frames
@@ -4284,6 +4342,7 @@ struct net_device *ieee80211_alloc_hw(si
 			   NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 
 	local->mdev = mdev;
+	local->rx_pre_handlers = ieee80211_rx_pre_handlers;
         local->rx_handlers = ieee80211_rx_handlers;
         local->tx_handlers = ieee80211_tx_handlers;
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 7ffeae2..3f4d00e 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -137,7 +137,11 @@ struct ieee80211_txrx_data {
 			struct ieee80211_rx_status *status;
 			int sent_ps_buffered;
 			int queue;
+			int load;
 			int in_scan:1;
+			int ra_match:1; /* frame is destined to interface
+					 * currently processed (including
+					 * multicast frames) */
 		} rx;
 	} u;
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
@@ -413,6 +417,7 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	struct ieee80211_passive_scan scan;
 
 
+	ieee80211_rx_handler *rx_pre_handlers;
 	ieee80211_rx_handler *rx_handlers;
         ieee80211_tx_handler *tx_handlers;
 
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index 04856a9..37f5af4 100644
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -235,6 +235,10 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 		int i;
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
+
+		if (!rx->u.rx.ra_match)
+			return TXRX_DROP;
+
 		printk(KERN_DEBUG "%s: invalid Michael MIC in data frame from "
 		       MACSTR "\n", rx->dev->name, MAC2STR(sa));
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
-- 
1.3.0

