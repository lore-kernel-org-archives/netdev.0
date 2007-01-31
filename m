From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 1/2] d80211: Add software RTS support
Date: Wed, 31 Jan 2007 20:16:50 +0100
Message-ID: <200701312016.50524.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@suse.cz>, "John Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:56486 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030191AbXAaTRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 14:17:08 -0500
Received: by ug-out-1314.google.com with SMTP id 44so260381uga
        for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 11:17:07 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not all hardware are capable of generating their own RTS frames.
This patch will add support for creating the RTS frame in software,
when the driver requests this through the flag
IEEE80211_HW_SOFTWARE_RTS

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/include/net/d80211.h b/include/net/d80211.h
index 65a5d36..17e0530 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -531,6 +531,9 @@ struct ieee80211_hw {
 	 * per-packet RC4 key with each TX frame when doing hwcrypto */
 #define IEEE80211_HW_TKIP_REQ_PHASE2_KEY (1<<14)
 
+	/* Does the device need the stack to create a RTS frame */
+#define IEEE80211_HW_SOFTWARE_RTS (1<<15)
+
 	u32 flags;			/* hardware flags defined above */
 
 	/* Set to the size of a needed device specific skb headroom for TX skbs. */
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 7353ed3..43d91bf 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -760,8 +760,7 @@ ieee80211_tx_h_misc(struct ieee80211_txrx_data *tx)
 	struct ieee80211_tx_control *control = tx->u.tx.control;
 
 	if (!is_multicast_ether_addr(hdr->addr1)) {
-		if (tx->skb->len + FCS_LEN > tx->local->rts_threshold &&
-		    tx->local->rts_threshold < IEEE80211_MAX_RTS_THRESHOLD) {
+		if (tx->u.tx.rts_required) {
 			control->flags |= IEEE80211_TXCTL_USE_RTS_CTS;
 			control->retry_limit =
 				tx->local->long_retry_limit;
@@ -843,6 +842,35 @@ ieee80211_tx_h_misc(struct ieee80211_txrx_data *tx)
 	return TXRX_CONTINUE;
 }
 
+static ieee80211_txrx_result
+ieee80211_tx_h_rts(struct ieee80211_txrx_data *tx)
+{
+	struct ieee80211_tx_control *control = tx->u.tx.control;
+	struct ieee80211_hdr *old_hdr = (struct ieee80211_hdr *) tx->skb->data;
+	struct ieee80211_hdr *new_hdr;
+	int hdr_len;
+
+	if (!tx->u.tx.rts_required ||
+	    !(tx->local->hw.flags & IEEE80211_HW_SOFTWARE_RTS))
+		return TXRX_CONTINUE;
+
+	hdr_len = ieee80211_get_hdrlen(old_hdr->frame_control);
+
+	tx->u.tx.rts_frame = dev_alloc_skb(hdr_len);
+	if (!tx->u.tx.rts_frame)
+		return TXRX_DROP;
+
+	new_hdr = (struct ieee80211_hdr*)skb_put(tx->u.tx.rts_frame, hdr_len);
+
+	memcpy(new_hdr, old_hdr, hdr_len);
+
+	new_hdr->frame_control = cpu_to_le16(
+		IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS);
+	new_hdr->duration_id = cpu_to_le16(control->rts_cts_duration);
+	new_hdr->seq_ctrl = 0;
+
+	return TXRX_CONTINUE;
+}
 
 static ieee80211_txrx_result
 ieee80211_tx_h_check_assoc(struct ieee80211_txrx_data *tx)
@@ -1072,8 +1100,12 @@ __ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
         tx->u.tx.unicast = !is_multicast_ether_addr(hdr->addr1);
 	if (is_multicast_ether_addr(hdr->addr1))
 		control->flags |= IEEE80211_TXCTL_NO_ACK;
-	else
+	else {
 		control->flags &= ~IEEE80211_TXCTL_NO_ACK;
+		if (tx->skb->len + FCS_LEN > tx->local->rts_threshold &&
+		    tx->local->rts_threshold < IEEE80211_MAX_RTS_THRESHOLD)
+			tx->u.tx.rts_required = 1;
+	}
 	tx->fragmented = local->fragmentation_threshold <
 		IEEE80211_MAX_FRAG_THRESHOLD && tx->u.tx.unicast &&
 		skb->len + FCS_LEN > local->fragmentation_threshold &&
@@ -1149,7 +1181,21 @@ static int __ieee80211_tx(struct ieee80211_local *local, struct sk_buff *skb,
 	struct ieee80211_tx_control *control = tx->u.tx.control;
 	int ret, i;
 
+	if (tx->u.tx.rts_frame) {
+		ieee80211_dump_frame(local->mdev->name,
+				     "RTS to low-level driver",
+				     tx->u.tx.rts_frame);
+		ret = local->ops->tx(local_to_hw(local), tx->u.tx.rts_frame, control);
+		if (ret)
+			return IEEE80211_TX_AGAIN;
+		ieee80211_led_tx(local, 1);
+
+		control->flags &= ~IEEE80211_TXCTL_USE_RTS_CTS;
+		tx->u.tx.rts_frame = NULL;
+	}
 	if (skb) {
+		if (__ieee80211_queue_stopped(local, control->queue))
+			return IEEE80211_TX_FRAG_AGAIN;
 		ieee80211_dump_frame(local->mdev->name, "TX to low-level driver", skb);
 		ret = local->ops->tx(local_to_hw(local), skb, control);
 		if (ret)
@@ -1287,6 +1333,7 @@ retry:
 		store->last_frag_hwrate = tx.u.tx.last_frag_hwrate;
 		store->last_frag_rateidx = tx.u.tx.last_frag_rateidx;
 		store->last_frag_rate_ctrl_probe = tx.u.tx.probe_last_frag;
+		store->rts_frame = tx.u.tx.rts_frame;
 	}
 	return 0;
 
@@ -1296,7 +1343,9 @@ retry:
 	for (i = 0; i < tx.u.tx.num_extra_frag; i++)
 		if (tx.u.tx.extra_frag[i])
 			dev_kfree_skb(tx.u.tx.extra_frag[i]);
-        kfree(tx.u.tx.extra_frag);
+	if (tx.u.tx.rts_frame)
+		dev_kfree_skb(tx.u.tx.rts_frame);
+	kfree(tx.u.tx.extra_frag);
 	return 0;
 }
 
@@ -1323,6 +1372,7 @@ static void ieee80211_tx_pending(unsigned long data)
 		tx.u.tx.last_frag_hwrate = store->last_frag_hwrate;
 		tx.u.tx.last_frag_rateidx = store->last_frag_rateidx;
 		tx.u.tx.probe_last_frag = store->last_frag_rate_ctrl_probe;
+		tx.u.tx.rts_frame = store->rts_frame;
 		ret = __ieee80211_tx(local, store->skb, &tx);
 		if (ret) {
 			if (ret == IEEE80211_TX_FRAG_AGAIN)
@@ -1350,6 +1400,8 @@ static void ieee80211_clear_tx_pending(struct ieee80211_local *local)
 		kfree_skb(store->skb);
 		for (j = 0; j < store->num_extra_frag; j++)
 			kfree_skb(store->extra_frag[j]);
+		if (store->rts_frame)
+			dev_kfree_skb(store->rts_frame);
 		kfree(store->extra_frag);
 		clear_bit(IEEE80211_LINK_STATE_PENDING, &local->state[i]);
 	}
@@ -4280,6 +4332,7 @@ static ieee80211_tx_handler ieee80211_tx_handlers[] =
 	ieee80211_tx_h_wep_encrypt,
 	ieee80211_tx_h_rate_ctrl,
 	ieee80211_tx_h_misc,
+	ieee80211_tx_h_rts,
 	ieee80211_tx_h_load_stats,
 	NULL
 };
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index aa4aa81..3ab910c 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -119,6 +119,7 @@ struct ieee80211_txrx_data {
 			unsigned int ps_buffered:1;
 			unsigned int short_preamble:1;
 			unsigned int probe_last_frag:1;
+			unsigned int rts_required:1;
 			struct ieee80211_rate *rate;
 			/* use this rate (if set) for last fragment; rate can
 			 * be set to lower rate for the first fragments, e.g.,
@@ -132,6 +133,10 @@ struct ieee80211_txrx_data {
 			 * in skb) */
 			int num_extra_frag;
 			struct sk_buff **extra_frag;
+
+			/* Extra RTS frame, this should be send out
+			 * before any of the other fragments. */
+			struct sk_buff *rts_frame;
 		} tx;
 		struct {
 			struct ieee80211_rx_status *status;
@@ -168,6 +173,7 @@ struct ieee80211_tx_stored_packet {
 	int last_frag_rateidx;
 	int last_frag_hwrate;
 	unsigned int last_frag_rate_ctrl_probe:1;
+	struct sk_buff *rts_frame;
 };
 
 struct ieee80211_passive_scan {
