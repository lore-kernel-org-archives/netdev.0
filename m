From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 2/4] Net: mac80211, remove bitfields from struct ieee80211_txrx_data
Date: Sun, 12 Aug 2007 15:08:57 +0200 (CEST)
Message-ID: <2653412025907217317@wsc.cz>
References: <32694265142306417777@wsc.cz>
Cc: <netdev@vger.kernel.org>
To: <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cacti.profiwh.com ([85.93.165.66]:56981 "EHLO smtp.wsc.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763083AbXHLNHw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 09:07:52 -0400
In-reply-to: <32694265142306417777@wsc.cz>
Cc: <jbenc@suse.cz>
Cc: <flamingice@sourmilk.net>
Cc: <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mac80211, remove bitfields from struct ieee80211_txrx_data

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

---
commit 37d65bd9e26732c7ec33a58eab6bda750b3be113
tree ac8e2b83c426b03007ea0bd7c5092e351598053c
parent 10e9252a35d42fb92e65dfaaef136d81dbb71c4f
author Jiri Slaby <jirislaby@gmail.com> Sun, 12 Aug 2007 11:50:05 +0200
committer Jiri Slaby <jirislaby@gmail.com> Sun, 12 Aug 2007 11:50:05 +0200

 net/mac80211/ieee80211_i.h |   22 ++++++++-------
 net/mac80211/rx.c          |   64 +++++++++++++++++++++++++-------------------
 net/mac80211/tx.c          |   61 +++++++++++++++++++++++++-----------------
 net/mac80211/wpa.c         |   14 +++++-----
 4 files changed, 91 insertions(+), 70 deletions(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 265893a..c48c896 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -127,13 +127,20 @@ struct ieee80211_txrx_data {
 	struct sta_info *sta;
 	u16 fc, ethertype;
 	struct ieee80211_key *key;
-	unsigned int fragmented:1; /* whether the MSDU was fragmented */
+	/* whether the MSDU was fragmented */
+#define IEEE80211_TXRXD_FRAGMENTED		BIT(0)
+#define IEEE80211_TXRXD_TXUNICAST		BIT(1)
+#define IEEE80211_TXRXD_TXPS_BUFFERED		BIT(2)
+#define IEEE80211_TXRXD_TXPROBE_LAST_FRAG	BIT(3)
+#define IEEE80211_TXRXD_RXIN_SCAN		BIT(4)
+	/* frame is destined to interface currently processed
+	 * (including multicast frames) */
+#define IEEE80211_TXRXD_RXRA_MATCH		BIT(5)
+#define IEEE80211_TXRXD_RXIS_AGG_FRAME		BIT(6)
+	unsigned int flags;
 	union {
 		struct {
 			struct ieee80211_tx_control *control;
-			unsigned int unicast:1;
-			unsigned int ps_buffered:1;
-			unsigned int probe_last_frag:1;
 			struct ieee80211_hw_mode *mode;
 			struct ieee80211_rate *rate;
 			/* use this rate (if set) for last fragment; rate can
@@ -154,11 +161,6 @@ struct ieee80211_txrx_data {
 			int queue;
 			int load;
 			u16 qos_control;
-			unsigned int in_scan:1;
-			/* frame is destined to interface currently processed
-			 * (including multicast frames) */
-			unsigned int ra_match:1;
-			unsigned int is_agg_frame:1;
 		} rx;
 	} u;
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
@@ -186,7 +188,7 @@ struct ieee80211_tx_stored_packet {
 	int last_frag_rateidx;
 	int last_frag_hwrate;
 	struct ieee80211_rate *last_frag_rate;
-	unsigned int last_frag_rate_ctrl_probe:1;
+	unsigned int last_frag_rate_ctrl_probe;
 };
 
 struct sta_ts_data {
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 948eb2f..8dd7488 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -65,7 +65,10 @@ ieee80211_rx_h_parse_qos(struct ieee80211_txrx_data *rx)
 		I802_DEBUG_INC(rx->sta->wme_rx_queue[tid]);
 
 	rx->u.rx.queue = tid;
-	rx->u.rx.is_agg_frame = is_agg_frame;
+	if (is_agg_frame)
+		rx->flags |= IEEE80211_TXRXD_RXIS_AGG_FRAME;
+	else
+		rx->flags &= ~IEEE80211_TXRXD_RXIS_AGG_FRAME;
 	/* Set skb->priority to 1d tag if highest order bit of TID is not set.
 	 * For now, set skb->priority to 0 for other cases. */
 	rx->skb->priority = (tid > 7) ? 0 : tid;
@@ -229,7 +232,7 @@ ieee80211_rx_h_passive_scan(struct ieee80211_txrx_data *rx)
 		return TXRX_QUEUED;
 	}
 
-	if (unlikely(rx->u.rx.in_scan)) {
+	if (unlikely(rx->flags & IEEE80211_TXRXD_RXIN_SCAN)) {
 		/* scanning finished during invoking of handlers */
 		I802_DEBUG_INC(local->rx_handlers_drop_passive_scan);
 		return TXRX_DROP;
@@ -249,7 +252,7 @@ ieee80211_rx_h_check(struct ieee80211_txrx_data *rx)
 		if (unlikely(rx->fc & IEEE80211_FCTL_RETRY &&
 			     rx->sta->last_seq_ctrl[rx->u.rx.queue] ==
 			     hdr->seq_ctrl)) {
-			if (rx->u.rx.ra_match) {
+			if (rx->flags & IEEE80211_TXRXD_RXRA_MATCH) {
 				rx->local->dot11FrameDuplicateCount++;
 				rx->sta->num_duplicates++;
 			}
@@ -267,7 +270,7 @@ ieee80211_rx_h_check(struct ieee80211_txrx_data *rx)
 		return TXRX_DROP;
 	}
 
-	if (!rx->u.rx.ra_match)
+	if (!(rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
 		rx->skb->pkt_type = PACKET_OTHERHOST;
 	else if (compare_ether_addr(rx->dev->dev_addr, hdr->addr1) == 0)
 		rx->skb->pkt_type = PACKET_HOST;
@@ -295,7 +298,7 @@ ieee80211_rx_h_check(struct ieee80211_txrx_data *rx)
 		if ((!(rx->fc & IEEE80211_FCTL_FROMDS) &&
 		     !(rx->fc & IEEE80211_FCTL_TODS) &&
 		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA)
-		    || !rx->u.rx.ra_match) {
+		    || !(rx->flags & IEEE80211_TXRXD_RXRA_MATCH)) {
 			/* Drop IBSS frames and frames for other hosts
 			 * silently. */
 			return TXRX_DROP;
@@ -341,7 +344,7 @@ ieee80211_rx_h_load_key(struct ieee80211_txrx_data *rx)
 				rx->key = rx->sdata->keys[keyidx];
 
 			if (!rx->key) {
-				if (!rx->u.rx.ra_match)
+				if (!(rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
 					return TXRX_DROP;
 				printk(KERN_DEBUG "%s: RX WEP frame with "
 				       "unknown keyidx %d (A1=" MAC_FMT " A2="
@@ -360,7 +363,8 @@ ieee80211_rx_h_load_key(struct ieee80211_txrx_data *rx)
 		}
 	}
 
-	if (rx->fc & IEEE80211_FCTL_PROTECTED && rx->key && rx->u.rx.ra_match) {
+	if (rx->fc & IEEE80211_FCTL_PROTECTED && rx->key &&
+	    (rx->flags & IEEE80211_TXRXD_RXRA_MATCH)) {
 		rx->key->tx_rx_count++;
 		if (unlikely(rx->local->key_tx_rx_threshold &&
 			     rx->key->tx_rx_count >
@@ -461,7 +465,7 @@ ieee80211_rx_h_sta_process(struct ieee80211_txrx_data *rx)
 		sta->last_rx = jiffies;
 	}
 
-	if (!rx->u.rx.ra_match)
+	if (!(rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
 		return TXRX_CONTINUE;
 
 	sta->rx_fragments++;
@@ -500,7 +504,8 @@ ieee80211_rx_h_wep_weak_iv_detection(struct ieee80211_txrx_data *rx)
 {
 	if (!rx->sta || !(rx->fc & IEEE80211_FCTL_PROTECTED) ||
 	    (rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA ||
-	    !rx->key || rx->key->alg != ALG_WEP || !rx->u.rx.ra_match)
+	    !rx->key || rx->key->alg != ALG_WEP ||
+	    !(rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
 		return TXRX_CONTINUE;
 
 	/* Check for weak IVs, if hwaccel did not remove IV from the frame */
@@ -732,7 +737,7 @@ ieee80211_rx_h_defragment(struct ieee80211_txrx_data *rx)
 	}
 
 	/* Complete frame has been reassembled - process it now */
-	rx->fragmented = 1;
+	rx->flags |= IEEE80211_TXRXD_FRAGMENTED;
 
  out:
 	if (rx->sta)
@@ -753,7 +758,7 @@ ieee80211_rx_h_ps_poll(struct ieee80211_txrx_data *rx)
 	if (likely(!rx->sta ||
 		   (rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_CTL ||
 		   (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_PSPOLL ||
-		   !rx->u.rx.ra_match))
+		   !(rx->flags & IEEE80211_TXRXD_RXRA_MATCH)))
 		return TXRX_CONTINUE;
 
 	skb = skb_dequeue(&rx->sta->tx_filtered);
@@ -837,7 +842,8 @@ static ieee80211_txrx_result
 ieee80211_rx_h_802_1x_pae(struct ieee80211_txrx_data *rx)
 {
 	if (rx->sdata->eapol && ieee80211_is_eapol(rx->skb) &&
-	    rx->sdata->type != IEEE80211_IF_TYPE_STA && rx->u.rx.ra_match) {
+	    rx->sdata->type != IEEE80211_IF_TYPE_STA &&
+	    (rx->flags & IEEE80211_TXRXD_RXRA_MATCH)) {
 		/* Pass both encrypted and unencrypted EAPOL frames to user
 		 * space for processing. */
 		if (!rx->local->apdev)
@@ -910,7 +916,7 @@ ieee80211_rx_h_data_agg(struct ieee80211_txrx_data *rx)
 	if (unlikely(!WLAN_FC_DATA_PRESENT(fc)))
 		return TXRX_DROP;
 
-	if (!rx->u.rx.is_agg_frame)
+	if (!(rx->flags & IEEE80211_TXRXD_RXIS_AGG_FRAME))
 		return TXRX_CONTINUE;
 
 	hdrlen = ieee80211_get_hdrlen(fc);
@@ -965,7 +971,7 @@ ieee80211_rx_h_data_agg(struct ieee80211_txrx_data *rx)
 		if (local->bridge_packets &&
 		    (sdata->type == IEEE80211_IF_TYPE_AP ||
 		     sdata->type == IEEE80211_IF_TYPE_VLAN) &&
-		     rx->u.rx.ra_match) {
+		     (rx->flags & IEEE80211_TXRXD_RXRA_MATCH)) {
 			if (is_multicast_ether_addr(frame->data)) {
 				/* send multicast frames both to higher layers
 				* in local net stack and back to the wireless
@@ -1149,7 +1155,8 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 	sdata->stats.rx_bytes += skb->len;
 
 	if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP
-	    || sdata->type == IEEE80211_IF_TYPE_VLAN) && rx->u.rx.ra_match) {
+	    || sdata->type == IEEE80211_IF_TYPE_VLAN) &&
+	    (rx->flags & IEEE80211_TXRXD_RXRA_MATCH)) {
 		if (is_multicast_ether_addr(skb->data)) {
 			/* send multicast frames both to higher layers in
 			 * local net stack and back to the wireless media */
@@ -1199,7 +1206,7 @@ ieee80211_rx_h_mgmt(struct ieee80211_txrx_data *rx)
 {
 	struct ieee80211_sub_if_data *sdata;
 
-	if (!rx->u.rx.ra_match)
+	if (!(rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
 		return TXRX_DROP;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(rx->dev);
@@ -1392,30 +1399,30 @@ static int prepare_for_handlers(struct ieee80211_sub_if_data *sdata,
 		if (!bssid)
 			return 0;
 		if (!ieee80211_bssid_match(bssid, sdata->u.sta.bssid)) {
-			if (!rx->u.rx.in_scan)
+			if (!(rx->flags & IEEE80211_TXRXD_RXIN_SCAN))
 				return 0;
-			rx->u.rx.ra_match = 0;
+			rx->flags &= ~IEEE80211_TXRXD_RXRA_MATCH;
 		} else if (!multicast &&
 			   compare_ether_addr(sdata->dev->dev_addr,
 					      hdr->addr1) != 0) {
 			if (!sdata->promisc)
 				return 0;
-			rx->u.rx.ra_match = 0;
+			rx->flags &= ~IEEE80211_TXRXD_RXRA_MATCH;
 		}
 		break;
 	case IEEE80211_IF_TYPE_IBSS:
 		if (!bssid)
 			return 0;
 		if (!ieee80211_bssid_match(bssid, sdata->u.sta.bssid)) {
-			if (!rx->u.rx.in_scan)
+			if (!(rx->flags & IEEE80211_TXRXD_RXIN_SCAN))
 				return 0;
-			rx->u.rx.ra_match = 0;
+			rx->flags &= ~IEEE80211_TXRXD_RXRA_MATCH;
 		} else if (!multicast &&
 			   compare_ether_addr(sdata->dev->dev_addr,
 					      hdr->addr1) != 0) {
 			if (!sdata->promisc)
 				return 0;
-			rx->u.rx.ra_match = 0;
+			rx->flags &= ~IEEE80211_TXRXD_RXRA_MATCH;
 		} else if (!rx->sta)
 			rx->sta = ieee80211_ibss_add_sta(sdata->dev, rx->skb,
 							 bssid, hdr->addr2);
@@ -1427,11 +1434,12 @@ static int prepare_for_handlers(struct ieee80211_sub_if_data *sdata,
 				return 0;
 		} else if (!ieee80211_bssid_match(bssid,
 					sdata->dev->dev_addr)) {
-			if (!rx->u.rx.in_scan)
+			if (!(rx->flags & IEEE80211_TXRXD_RXIN_SCAN))
 				return 0;
-			rx->u.rx.ra_match = 0;
+			rx->flags &= ~IEEE80211_TXRXD_RXRA_MATCH;
 		}
-		if (sdata->dev == sdata->local->mdev && !rx->u.rx.in_scan)
+		if (sdata->dev == sdata->local->mdev &&
+		    !(rx->flags & IEEE80211_TXRXD_RXIN_SCAN))
 			/* do not receive anything via
 			 * master device when not scanning */
 			return 0;
@@ -1497,7 +1505,7 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	}
 
 	if (unlikely(local->sta_scanning))
-		rx.u.rx.in_scan = 1;
+		rx.flags |= IEEE80211_TXRXD_RXIN_SCAN;
 
 	if (__ieee80211_invoke_rx_handlers(local, local->rx_pre_handlers, &rx,
 					   sta) != TXRX_CONTINUE)
@@ -1507,7 +1515,7 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	skb_push(skb, radiotap_len);
 	if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS) &&
 	    !local->iff_promiscs && !is_multicast_ether_addr(hdr->addr1)) {
-		rx.u.rx.ra_match = 1;
+		rx.flags |= IEEE80211_TXRXD_RXRA_MATCH;
 		ieee80211_invoke_rx_handlers(local, local->rx_handlers, &rx,
 					     rx.sta);
 		sta_info_put(sta);
@@ -1518,7 +1526,7 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 
 	read_lock(&local->sub_if_lock);
 	list_for_each_entry(sdata, &local->sub_if_list, list) {
-		rx.u.rx.ra_match = 1;
+		rx.flags |= IEEE80211_TXRXD_RXRA_MATCH;
 
 		prepres = prepare_for_handlers(sdata, bssid, &rx, hdr);
 		/* prepare_for_handlers can change sta */
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 3d05f8f..bc4a3c7 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -223,12 +223,12 @@ ieee80211_tx_h_check_assoc(struct ieee80211_txrx_data *tx)
 	     (tx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_PROBE_REQ))
 		return TXRX_DROP;
 
-	if (tx->u.tx.ps_buffered)
+	if (tx->flags & IEEE80211_TXRXD_TXPS_BUFFERED)
 		return TXRX_CONTINUE;
 
 	sta_flags = tx->sta ? tx->sta->flags : 0;
 
-	if (likely(tx->u.tx.unicast)) {
+	if (likely(tx->flags & IEEE80211_TXRXD_TXUNICAST)) {
 		if (unlikely(!(sta_flags & WLAN_STA_ASSOC) &&
 			     tx->sdata->type != IEEE80211_IF_TYPE_IBSS &&
 			     (tx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA)) {
@@ -411,10 +411,10 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_txrx_data *tx)
 static ieee80211_txrx_result
 ieee80211_tx_h_ps_buf(struct ieee80211_txrx_data *tx)
 {
-	if (unlikely(tx->u.tx.ps_buffered))
+	if (unlikely(tx->flags & IEEE80211_TXRXD_TXPS_BUFFERED))
 		return TXRX_CONTINUE;
 
-	if (tx->u.tx.unicast)
+	if (tx->flags & IEEE80211_TXRXD_TXUNICAST)
 		return ieee80211_tx_h_unicast_ps_buf(tx);
 	else
 		return ieee80211_tx_h_multicast_ps_buf(tx);
@@ -468,7 +468,7 @@ ieee80211_tx_h_fragment(struct ieee80211_txrx_data *tx)
 	u8 *pos;
 	int frag_threshold = tx->local->fragmentation_threshold;
 
-	if (!tx->fragmented)
+	if (!(tx->flags & IEEE80211_TXRXD_FRAGMENTED))
 		return TXRX_CONTINUE;
 
 	first = tx->skb;
@@ -605,7 +605,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee80211_txrx_data *tx)
 					      &extra);
 	if (unlikely(extra.probe != NULL)) {
 		tx->u.tx.control->flags |= IEEE80211_TXCTL_RATE_CTRL_PROBE;
-		tx->u.tx.probe_last_frag = 1;
+		tx->flags |= IEEE80211_TXRXD_TXPROBE_LAST_FRAG;
 		tx->u.tx.control->alt_retry_rate = tx->u.tx.rate->val;
 		tx->u.tx.rate = extra.probe;
 	} else {
@@ -614,11 +614,13 @@ ieee80211_tx_h_rate_ctrl(struct ieee80211_txrx_data *tx)
 	if (!tx->u.tx.rate)
 		return TXRX_DROP;
 	if (tx->u.tx.mode->mode == MODE_IEEE80211G &&
-	    tx->sdata->use_protection && tx->fragmented &&
-	    extra.nonerp) {
+	    tx->sdata->use_protection &&
+	    (tx->flags & IEEE80211_TXRXD_FRAGMENTED) && extra.nonerp) {
 		tx->u.tx.last_frag_rate = tx->u.tx.rate;
-		tx->u.tx.probe_last_frag = extra.probe ? 1 : 0;
-
+		if (extra.probe)
+			tx->flags &= ~IEEE80211_TXRXD_TXPROBE_LAST_FRAG;
+		else
+			tx->flags |= IEEE80211_TXRXD_TXPROBE_LAST_FRAG;
 		tx->u.tx.rate = extra.nonerp;
 		tx->u.tx.control->rate = extra.nonerp;
 		tx->u.tx.control->flags &= ~IEEE80211_TXCTL_RATE_CTRL_PROBE;
@@ -655,7 +657,7 @@ ieee80211_tx_h_misc(struct ieee80211_txrx_data *tx)
 		control->retry_limit = 1;
 	}
 
-	if (tx->fragmented) {
+	if (tx->flags & IEEE80211_TXRXD_FRAGMENTED) {
 		/* Do not use multiple retry rates when sending fragmented
 		 * frames.
 		 * TODO: The last fragment could still use multiple retry
@@ -668,7 +670,8 @@ ieee80211_tx_h_misc(struct ieee80211_txrx_data *tx)
 	 * for the frame. */
 	if (mode->mode == MODE_IEEE80211G &&
 	    (tx->u.tx.rate->flags & IEEE80211_RATE_ERP) &&
-	    tx->u.tx.unicast && tx->sdata->use_protection &&
+	    (tx->flags & IEEE80211_TXRXD_TXUNICAST) &&
+	    tx->sdata->use_protection &&
 	    !(control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		control->flags |= IEEE80211_TXCTL_USE_CTS_PROTECT;
 
@@ -686,8 +689,8 @@ ieee80211_tx_h_misc(struct ieee80211_txrx_data *tx)
 	 * for remaining fragments will be updated when they are being sent
 	 * to low-level driver in ieee80211_tx(). */
 	dur = ieee80211_duration(tx, is_multicast_ether_addr(hdr->addr1),
-				 tx->fragmented ? tx->u.tx.extra_frag[0]->len :
-				 0);
+				 (tx->flags & IEEE80211_TXRXD_FRAGMENTED) ?
+				 tx->u.tx.extra_frag[0]->len : 0);
 	hdr->duration_id = cpu_to_le16(dur);
 
 	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) ||
@@ -979,15 +982,20 @@ __ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
 	}
 
 	tx->u.tx.control = control;
-	tx->u.tx.unicast = !is_multicast_ether_addr(hdr->addr1);
-	if (is_multicast_ether_addr(hdr->addr1))
+	if (is_multicast_ether_addr(hdr->addr1)) {
+		tx->flags &= ~IEEE80211_TXRXD_TXUNICAST;
 		control->flags |= IEEE80211_TXCTL_NO_ACK;
-	else
+	} else {
+		tx->flags |= IEEE80211_TXRXD_TXUNICAST;
 		control->flags &= ~IEEE80211_TXCTL_NO_ACK;
-	tx->fragmented = local->fragmentation_threshold <
-		IEEE80211_MAX_FRAG_THRESHOLD && tx->u.tx.unicast &&
-		skb->len + FCS_LEN > local->fragmentation_threshold &&
-		(!local->ops->set_frag_threshold);
+	}
+	if (local->fragmentation_threshold < IEEE80211_MAX_FRAG_THRESHOLD &&
+	    (tx->flags & IEEE80211_TXRXD_TXUNICAST) &&
+	    skb->len + FCS_LEN > local->fragmentation_threshold &&
+	    !local->ops->set_frag_threshold)
+		tx->flags |= IEEE80211_TXRXD_FRAGMENTED;
+	else
+		tx->flags &= ~IEEE80211_TXRXD_FRAGMENTED;
 	if (!tx->sta)
 		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 	else if (tx->sta->clear_dst_mask) {
@@ -1058,7 +1066,7 @@ static int __ieee80211_tx(struct ieee80211_local *local, struct sk_buff *skb,
 			if (i == tx->u.tx.num_extra_frag) {
 				control->tx_rate = tx->u.tx.last_frag_hwrate;
 				control->rate = tx->u.tx.last_frag_rate;
-				if (tx->u.tx.probe_last_frag)
+				if (tx->flags & IEEE80211_TXRXD_TXPROBE_LAST_FRAG)
 					control->flags |=
 						IEEE80211_TXCTL_RATE_CTRL_PROBE;
 				else
@@ -1189,7 +1197,8 @@ retry:
 		store->num_extra_frag = tx.u.tx.num_extra_frag;
 		store->last_frag_hwrate = tx.u.tx.last_frag_hwrate;
 		store->last_frag_rate = tx.u.tx.last_frag_rate;
-		store->last_frag_rate_ctrl_probe = tx.u.tx.probe_last_frag;
+		store->last_frag_rate_ctrl_probe =
+			!!(tx.flags & IEEE80211_TXRXD_TXPROBE_LAST_FRAG);
 	}
 	return 0;
 
@@ -1618,7 +1627,9 @@ void ieee80211_tx_pending(unsigned long data)
 		tx.u.tx.num_extra_frag = store->num_extra_frag;
 		tx.u.tx.last_frag_hwrate = store->last_frag_hwrate;
 		tx.u.tx.last_frag_rate = store->last_frag_rate;
-		tx.u.tx.probe_last_frag = store->last_frag_rate_ctrl_probe;
+		tx.flags = 0;
+		if (store->last_frag_rate_ctrl_probe)
+			tx.flags |= IEEE80211_TXRXD_TXPROBE_LAST_FRAG;
 		ret = __ieee80211_tx(local, store->skb, &tx);
 		if (ret) {
 			if (ret == IEEE80211_TX_FRAG_AGAIN)
@@ -1864,7 +1875,7 @@ ieee80211_get_buffered_bc(struct ieee80211_hw *hw, int if_id,
 		dev_kfree_skb_any(skb);
 	}
 	sta = tx.sta;
-	tx.u.tx.ps_buffered = 1;
+	tx.flags |= IEEE80211_TXRXD_TXPS_BUFFERED;
 
 	for (handler = local->tx_handlers; *handler != NULL; handler++) {
 		res = (*handler)(&tx);
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 2806886..e0d735a 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -97,14 +97,14 @@ ieee80211_tx_h_michael_mic_add(struct ieee80211_txrx_data *tx)
 
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	if ((tx->sta && tx->sta->wpa_trigger & WPA_TRIGGER_FAIL_TX_MIC) ||
-	    (!tx->u.tx.unicast &&
+	    (!(tx->flags & IEEE80211_TXRXD_TXUNICAST) &&
 	     tx->local->wpa_trigger & WPA_TRIGGER_FAIL_TX_MIC)) {
 		wpa_test = 1;
 	}
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if (!tx->key->force_sw_encrypt &&
-	    !tx->fragmented &&
+	    !(tx->flags & IEEE80211_TXRXD_FRAGMENTED) &&
 	    !(tx->local->hw.flags & IEEE80211_HW_TKIP_INCLUDE_MMIC) &&
 	    !wpa_test) {
 		/* hwaccel - with no need for preallocated room for Michael MIC
@@ -142,7 +142,7 @@ ieee80211_tx_h_michael_mic_add(struct ieee80211_txrx_data *tx)
 		tx->sta->wpa_trigger &= ~WPA_TRIGGER_FAIL_TX_MIC;
 		tx->wpa_test = 1;
 		mic[0]++;
-	} else if (!tx->u.tx.unicast &&
+	} else if (!(tx->flags & IEEE80211_TXRXD_TXUNICAST) &&
 		   tx->local->wpa_trigger & WPA_TRIGGER_FAIL_TX_MIC) {
 		printk(KERN_INFO "%s: WPA testing - corrupting TX Michael MIC "
 		       "for Group Key\n", tx->dev->name);
@@ -193,7 +193,7 @@ ieee80211_rx_h_michael_mic_verify(struct ieee80211_txrx_data *rx)
 		/* Need to verify Michael MIC sometimes in software even when
 		 * hwaccel is used. Atheros ar5212: fragmented frames and QoS
 		 * frames. */
-		if (!rx->fragmented && !wpa_test)
+		if (!(rx->flags & IEEE80211_TXRXD_FRAGMENTED) && !wpa_test)
 			goto remove_mic;
 	}
 
@@ -225,7 +225,7 @@ ieee80211_rx_h_michael_mic_verify(struct ieee80211_txrx_data *rx)
 		int i;
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
-		if (!rx->u.rx.ra_match)
+		if (!(rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
 			return TXRX_DROP;
 
 		printk(KERN_DEBUG "%s: invalid Michael MIC in data frame from "
@@ -392,7 +392,7 @@ ieee80211_tx_h_tkip_encrypt(struct ieee80211_txrx_data *tx)
 
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	if ((tx->sta && tx->sta->wpa_trigger & WPA_TRIGGER_FAIL_TX_ICV) ||
-	    (!tx->u.tx.unicast &&
+	    (!(tx->flags & IEEE80211_TXRXD_TXUNICAST) &&
 	     tx->local->wpa_trigger & WPA_TRIGGER_FAIL_TX_ICV)) {
 		wpa_test = 1;
 	}
@@ -453,7 +453,7 @@ ieee80211_tx_h_tkip_encrypt(struct ieee80211_txrx_data *tx)
 		tx->u.tx.control->key_idx = HW_KEY_IDX_INVALID;
 		tx->sta->wpa_trigger &= ~WPA_TRIGGER_FAIL_TX_ICV;
 		skb->data[skb->len - 1]++;
-	} else if (!tx->u.tx.unicast &&
+	} else if (!(tx->flags & IEEE80211_TXRXD_TXUNICAST) &&
 		   tx->local->wpa_trigger & WPA_TRIGGER_FAIL_TX_ICV) {
 		printk(KERN_INFO "%s: WPA testing - corrupting TX TKIP ICV "
 		       "for Group Key\n",
