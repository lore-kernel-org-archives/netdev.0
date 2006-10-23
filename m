From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Mon, 23 Oct 2006 18:31:13 +0200
Message-ID: <20061023183113.68027359@griffin.suse.cz>
References: <1161335976.21402.11.camel@devlinux-hong>
	<20061023144028.629dc5d8@griffin.suse.cz>
	<20061023152931.GB22485@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hong Liu <hong.liu@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:62601 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751994AbWJWQbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2006 12:31:16 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061023152931.GB22485@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Oct 2006 08:29:31 -0700, David Kimdon wrote:
> We could be more selective about what the driver is required to return
> in ieee80211_tx_status, the rc4key isn't particularily interesting to
> ieee80211_tx_status().  I expect there are other uninteresting fields
> (tx_rate, rts_cts_rate, come to mind, for example).  We could put the
> fields we are interested in directly in ieee80211_tx_status, or have a
> new structure rather than re-using ieee80211_tx_control inside
> ieee80211_tx_status.

Something like this?

 Jiri

---
 drivers/net/wireless/d80211/adm8211/adm8211.c |    7 +
 include/net/d80211.h                          |   28 ++++---
 net/d80211/ieee80211.c                        |   98 +++++++++++++-------------
 net/d80211/ieee80211_scan.c                   |    4 -
 net/d80211/ieee80211_sta.c                    |    4 -
 5 files changed, 73 insertions(+), 68 deletions(-)

--- dscape.orig/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ dscape/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -439,7 +439,7 @@ static void adm8211_interrupt_tci(struct
 		pci_unmap_single(priv->pdev, priv->tx_buffers[entry].mapping,
 				 priv->tx_buffers[entry].skb->len, PCI_DMA_TODEVICE);
 
-		if ((priv->tx_buffers[entry].tx_status.control.flags &
+		if ((priv->tx_buffers[entry].tx_status.common.flags &
 		     IEEE80211_TXCTL_REQ_TX_STATUS) ||
 		    !is_multicast_ether_addr(ieee80211_get_DA(&priv->tx_buffers[entry].hdr))) {
 			struct ieee80211_hdr *hdr;
@@ -1780,7 +1780,8 @@ static void adm8211_tx_raw(struct net_de
 
 	priv->tx_buffers[entry].skb = skb;
 	priv->tx_buffers[entry].mapping = mapping;
-	memcpy(&priv->tx_buffers[entry].tx_status.control, control, sizeof(*control));
+	memcpy(&priv->tx_buffers[entry].tx_status.common, &control->common,
+	       sizeof(control->common));
 	memcpy(&priv->tx_buffers[entry].hdr, hdr, sizeof(*hdr));
 	priv->tx_ring[entry].buffer1 = cpu_to_le32(mapping);
 
@@ -1862,7 +1863,7 @@ static int adm8211_tx(struct net_device 
 	if (short_preamble)
 		txhdr->header_control |= cpu_to_le16(ADM8211_TXHDRCTL_SHORT_PREAMBLE);
 
-	if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS)
+	if (control->common.flags & IEEE80211_TXCTL_USE_RTS_CTS)
 		txhdr->header_control |= cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_RTS);
 
 	if (fc & IEEE80211_FCTL_PROTECTED)
--- dscape.orig/include/net/d80211.h
+++ dscape/include/net/d80211.h
@@ -134,13 +134,7 @@ struct ieee80211_low_level_stats {
  * the hardware to use given values (depending on what is supported). */
 #define HW_KEY_IDX_INVALID -1
 
-struct ieee80211_tx_control {
-	enum { PKT_NORMAL = 0, PKT_PROBE_RESP } pkt_type;
-	int tx_rate; /* Transmit rate, given as the hw specific value for the
-		      * rate (from struct ieee80211_rate) */
-	int rts_cts_rate; /* Transmit rate for RTS/CTS frame, given as the hw
-			   * specific value for the rate (from
-			   * struct ieee80211_rate) */
+struct ieee80211_tx_ctrl_common {
 
 #define IEEE80211_TXCTL_REQ_TX_STATUS	(1<<0)/* request TX status callback for
 						* this frame */
@@ -161,6 +155,20 @@ struct ieee80211_tx_control {
 						* the frame */
 	u16 flags;			       /* tx control flags defined
 						* above */
+	enum { PKT_NORMAL = 0, PKT_PROBE_RESP } pkt_type;
+	u8 queue;		/* hardware queue to use for this frame;
+				 * 0 = highest, hw->queues-1 = lowest */
+	int type;	/* internal */
+	int ifindex;	/* internal */
+};
+
+struct ieee80211_tx_control {
+	struct ieee80211_tx_ctrl_common common;
+	int tx_rate; /* Transmit rate, given as the hw specific value for the
+		      * rate (from struct ieee80211_rate) */
+	int rts_cts_rate; /* Transmit rate for RTS/CTS frame, given as the hw
+			   * specific value for the rate (from
+			   * struct ieee80211_rate) */
 	u16 rts_cts_duration;	/* duration field for RTS/CTS frame */
 	u8 retry_limit;		/* 1 = only first attempt, 2 = one retry, .. */
 	u8 power_level;		/* per-packet transmit power level, in dBm */
@@ -169,8 +177,6 @@ struct ieee80211_tx_control {
 				 * hw->set_key() */
 	u8 icv_len;		/* length of the ICV/MIC field in octets */
 	u8 iv_len;		/* length of the IV field in octets */
-	u8 queue;		/* hardware queue to use for this frame;
-				 * 0 = highest, hw->queues-1 = lowest */
 	u8 sw_retry_attempt;	/* number of times hw has tried to
 				 * transmit frame (not incl. hw retries) */
 
@@ -180,8 +186,6 @@ struct ieee80211_tx_control {
 			     * struct ieee80211_rate). To be used to limit
 			     * packet dropping when probing higher rates, if hw
 			     * supports multiple retry rates. -1 = not used */
-	int type;	/* internal */
-	int ifindex;	/* internal */
 };
 
 #define RX_FLAG_MMIC_ERROR       0x1
@@ -207,7 +211,7 @@ struct ieee80211_rx_status {
  * frame. */
 struct ieee80211_tx_status {
 	/* copied ieee80211_tx_control structure */
-	struct ieee80211_tx_control control;
+	struct ieee80211_tx_ctrl_common common;
 
 #define IEEE80211_TX_STATUS_TX_FILTERED	(1<<0)
 #define IEEE80211_TX_STATUS_ACK		(1<<1) /* whether the TX frame was ACKed */
--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -358,7 +358,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
 	tx->u.tx.rate = rate_control_get_rate(tx->local, tx->dev, tx->skb,
 					      &extra);
 	if (unlikely(extra.probe != NULL)) {
-		tx->u.tx.control->flags |= IEEE80211_TXCTL_RATE_CTRL_PROBE;
+		tx->u.tx.control->common.flags |= IEEE80211_TXCTL_RATE_CTRL_PROBE;
 		tx->u.tx.probe_last_frag = 1;
 		tx->u.tx.control->alt_retry_rate = tx->u.tx.rate->val;
 		tx->u.tx.rate = extra.probe;
@@ -376,7 +376,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
 
 		tx->u.tx.rate = extra.nonerp;
 		tx->u.tx.control->rateidx = extra.nonerp_idx;
-		tx->u.tx.control->flags &= ~IEEE80211_TXCTL_RATE_CTRL_PROBE;
+		tx->u.tx.control->common.flags &= ~IEEE80211_TXCTL_RATE_CTRL_PROBE;
 	} else {
 		tx->u.tx.last_frag_rate = tx->u.tx.rate;
 		tx->u.tx.last_frag_rateidx = extra.rateidx;
@@ -402,7 +402,7 @@ ieee80211_tx_h_select_key(struct ieee802
 	else
 		tx->u.tx.control->key_idx = HW_KEY_IDX_INVALID;
 
-	if (unlikely(tx->u.tx.control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT))
+	if (unlikely(tx->u.tx.control->common.flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT))
 		tx->key = NULL;
 	else if (tx->sta && tx->sta->key)
 		tx->key = tx->sta->key;
@@ -758,7 +758,7 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 	if (!is_multicast_ether_addr(hdr->addr1)) {
 		if (tx->skb->len + FCS_LEN > tx->local->rts_threshold &&
 		    tx->local->rts_threshold < IEEE80211_MAX_RTS_THRESHOLD) {
-			control->flags |= IEEE80211_TXCTL_USE_RTS_CTS;
+			control->common.flags |= IEEE80211_TXCTL_USE_RTS_CTS;
 			control->retry_limit =
 				tx->local->long_retry_limit;
 		} else {
@@ -784,8 +784,8 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 	    (tx->u.tx.rate->flags & IEEE80211_RATE_ERP) &&
 	    tx->u.tx.unicast &&
 	    tx->local->cts_protect_erp_frames &&
-	    !(control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
-		control->flags |= IEEE80211_TXCTL_USE_CTS_PROTECT;
+	    !(control->common.flags & IEEE80211_TXCTL_USE_RTS_CTS))
+		control->common.flags |= IEEE80211_TXCTL_USE_CTS_PROTECT;
 
 	/* Setup duration field for the first fragment of the frame. Duration
 	 * for remaining fragments will be updated when they are being sent
@@ -795,8 +795,8 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 				 0);
 	hdr->duration_id = cpu_to_le16(dur);
 
-	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) ||
-	    (control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT)) {
+	if ((control->common.flags & IEEE80211_TXCTL_USE_RTS_CTS) ||
+	    (control->common.flags & IEEE80211_TXCTL_USE_CTS_PROTECT)) {
 		struct ieee80211_rate *rate;
 		int erp = tx->u.tx.rate->flags & IEEE80211_RATE_ERP;
 
@@ -809,7 +809,7 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 		       !(rate->flags & IEEE80211_RATE_BASIC))
 			rate--;
 
-		if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS)
+		if (control->common.flags & IEEE80211_TXCTL_USE_RTS_CTS)
 			dur += ieee80211_frame_duration(tx->local, 10,
 							rate->rate, erp,
 							tx->local->
@@ -1066,17 +1066,17 @@ __ieee80211_tx_prepare(struct ieee80211_
 	tx->u.tx.control = control;
         tx->u.tx.unicast = !is_multicast_ether_addr(hdr->addr1);
 	if (is_multicast_ether_addr(hdr->addr1))
-		control->flags |= IEEE80211_TXCTL_NO_ACK;
+		control->common.flags |= IEEE80211_TXCTL_NO_ACK;
 	else
-		control->flags &= ~IEEE80211_TXCTL_NO_ACK;
+		control->common.flags &= ~IEEE80211_TXCTL_NO_ACK;
 	tx->fragmented = local->fragmentation_threshold <
 		IEEE80211_MAX_FRAG_THRESHOLD && tx->u.tx.unicast &&
 		skb->len + FCS_LEN > local->fragmentation_threshold &&
 		(!local->hw->set_frag_threshold);
 	if (!tx->sta)
-		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
+		control->common.flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 	else if (tx->sta->clear_dst_mask) {
-		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
+		control->common.flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 		tx->sta->clear_dst_mask = 0;
 	}
 	control->antenna_sel = local->conf.antenna_sel;
@@ -1087,7 +1087,7 @@ __ieee80211_tx_prepare(struct ieee80211_
 		u8 *pos = &skb->data[hdrlen + sizeof(rfc1042_header)];
 		tx->ethertype = (pos[0] << 8) | pos[1];
 	}
-	control->flags |= IEEE80211_TXCTL_FIRST_FRAGMENT;
+	control->common.flags |= IEEE80211_TXCTL_FIRST_FRAGMENT;
 
 }
 
@@ -1152,23 +1152,23 @@ static int __ieee80211_tx(struct ieee802
 		ieee80211_led_tx(local, 1);
 	}
 	if (tx->u.tx.extra_frag) {
-		control->flags &= ~(IEEE80211_TXCTL_USE_RTS_CTS |
+		control->common.flags &= ~(IEEE80211_TXCTL_USE_RTS_CTS |
 				    IEEE80211_TXCTL_USE_CTS_PROTECT |
 				    IEEE80211_TXCTL_CLEAR_DST_MASK |
 				    IEEE80211_TXCTL_FIRST_FRAGMENT);
 		for (i = 0; i < tx->u.tx.num_extra_frag; i++) {
 			if (!tx->u.tx.extra_frag[i])
 				continue;
-			if (__ieee80211_queue_stopped(local, control->queue))
+			if (__ieee80211_queue_stopped(local, control->common.queue))
 				return IEEE80211_TX_FRAG_AGAIN;
 			if (i == tx->u.tx.num_extra_frag) {
 				control->tx_rate = tx->u.tx.last_frag_hwrate;
 				control->rateidx = tx->u.tx.last_frag_rateidx;
 				if (tx->u.tx.probe_last_frag)
-					control->flags |=
+					control->common.flags |=
 						IEEE80211_TXCTL_RATE_CTRL_PROBE;
 				else
-					control->flags &=
+					control->common.flags &=
 						~IEEE80211_TXCTL_RATE_CTRL_PROBE;
 			}
 
@@ -1197,7 +1197,7 @@ static int ieee80211_tx(struct net_devic
 	ieee80211_txrx_result res = TXRX_DROP;
         int ret, i;
 
-	WARN_ON(__ieee80211_queue_pending(local, control->queue));
+	WARN_ON(__ieee80211_queue_pending(local, control->common.queue));
 
 	if (unlikely(skb->len < 10)) {
 		dev_kfree_skb(skb);
@@ -1252,12 +1252,12 @@ retry:
 	ret = __ieee80211_tx(local, skb, &tx);
 	if (ret) {
 		struct ieee80211_tx_stored_packet *store =
-			&local->pending_packet[control->queue];
+			&local->pending_packet[control->common.queue];
 
 		if (ret == IEEE80211_TX_FRAG_AGAIN)
 			skb = NULL;
 		set_bit(IEEE80211_LINK_STATE_PENDING,
-			&local->state[control->queue]);
+			&local->state[control->common.queue]);
 		smp_mb();
 		/* When the driver gets out of buffers during sending of
 		 * fragments and calls ieee80211_stop_queue, there is
@@ -1268,9 +1268,9 @@ retry:
 		 * called with IEEE80211_LINK_STATE_PENDING. Prevent this by
 		 * continuing transmitting here when that situation is
 		 * possible to have happened. */
-		if (!__ieee80211_queue_stopped(local, control->queue)) {
+		if (!__ieee80211_queue_stopped(local, control->common.queue)) {
 			clear_bit(IEEE80211_LINK_STATE_PENDING,
-				  &local->state[control->queue]);
+				  &local->state[control->common.queue]);
 			goto retry;
 		}
 		memcpy(&store->control, control,
@@ -1382,20 +1382,20 @@ static int ieee80211_master_start_xmit(s
 	}
 	osdata = IEEE80211_DEV_TO_SUB_IF(odev);
 
-	control.ifindex = odev->ifindex;
-	control.type = osdata->type;
+	control.common.ifindex = odev->ifindex;
+	control.common.type = osdata->type;
 	if (pkt_data->req_tx_status)
-		control.flags |= IEEE80211_TXCTL_REQ_TX_STATUS;
+		control.common.flags |= IEEE80211_TXCTL_REQ_TX_STATUS;
 	if (pkt_data->do_not_encrypt)
-		control.flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
-	control.pkt_type =
+		control.common.flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
+	control.common.pkt_type =
 		pkt_data->pkt_probe_resp ? PKT_PROBE_RESP : PKT_NORMAL;
 	if (pkt_data->requeue)
-		control.flags |= IEEE80211_TXCTL_REQUEUE;
-	control.queue = pkt_data->queue;
+		control.common.flags |= IEEE80211_TXCTL_REQUEUE;
+	control.common.queue = pkt_data->queue;
 
 	ret = ieee80211_tx(odev, skb, &control,
-			   control.type == IEEE80211_IF_TYPE_MGMT);
+			   control.common.type == IEEE80211_IF_TYPE_MGMT);
 	dev_put(odev);
 
         return ret;
@@ -1781,10 +1781,10 @@ struct sk_buff * ieee80211_beacon_get(st
 			rate->val2 : rate->val;
 		control->antenna_sel = local->conf.antenna_sel;
 		control->power_level = local->conf.power_level;
-		control->flags |= IEEE80211_TXCTL_NO_ACK;
+		control->common.flags |= IEEE80211_TXCTL_NO_ACK;
 		control->retry_limit = 1;
 		control->rts_cts_duration = 0;
-		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
+		control->common.flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 	}
 
 	ap->num_beacons++;
@@ -3740,9 +3740,9 @@ ieee80211_tx_h_load_stats(struct ieee802
 	if (!is_multicast_ether_addr(hdr->addr1))
 		load += hdrtime;
 
-	if (tx->u.tx.control->flags & IEEE80211_TXCTL_USE_RTS_CTS)
+	if (tx->u.tx.control->common.flags & IEEE80211_TXCTL_USE_RTS_CTS)
 		load += 2 * hdrtime;
-	else if (tx->u.tx.control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT)
+	else if (tx->u.tx.control->common.flags & IEEE80211_TXCTL_USE_CTS_PROTECT)
 		load += hdrtime;
 
 	load += skb->len * tx->u.tx.rate->rate_inv;
@@ -3892,7 +3892,7 @@ void ieee80211_tx_status_irqsafe(struct 
 		memcpy(saved, status, sizeof(struct ieee80211_tx_status));
 	memcpy(skb->cb, &saved, sizeof(saved));
         skb->pkt_type = ieee80211_tx_status_msg;
-	skb_queue_tail(status->control.flags & IEEE80211_TXCTL_REQ_TX_STATUS ?
+	skb_queue_tail(status->common.flags & IEEE80211_TXCTL_REQ_TX_STATUS ?
 		       &local->skb_queue : &local->skb_queue_unreliable, skb);
 	tmp = skb_queue_len(&local->skb_queue) +
 		skb_queue_len(&local->skb_queue_unreliable);
@@ -3961,19 +3961,19 @@ static void ieee80211_tasklet_handler(un
 static void ieee80211_remove_tx_extra(struct ieee80211_local *local,
 				      struct ieee80211_key *key,
 				      struct sk_buff *skb,
-				      struct ieee80211_tx_control *control)
+				      struct ieee80211_tx_ctrl_common *common)
 {
 	int hdrlen, iv_len, mic_len;
 	struct ieee80211_tx_packet_data *pkt_data;
 
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
-	pkt_data->ifindex = control->ifindex;
-	pkt_data->mgmt_iface = (control->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->req_tx_status = !!(control->flags & IEEE80211_TXCTL_REQ_TX_STATUS);
-	pkt_data->do_not_encrypt = !!(control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT);
-	pkt_data->pkt_probe_resp = (control->pkt_type == PKT_PROBE_RESP);
-	pkt_data->requeue = !!(control->flags & IEEE80211_TXCTL_REQUEUE);
-	pkt_data->queue = control->queue;
+	pkt_data->ifindex = common->ifindex;
+	pkt_data->mgmt_iface = (common->type == IEEE80211_IF_TYPE_MGMT);
+	pkt_data->req_tx_status = !!(common->flags & IEEE80211_TXCTL_REQ_TX_STATUS);
+	pkt_data->do_not_encrypt = !!(common->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT);
+	pkt_data->pkt_probe_resp = (common->pkt_type == PKT_PROBE_RESP);
+	pkt_data->requeue = !!(common->flags & IEEE80211_TXCTL_REQUEUE);
+	pkt_data->queue = common->queue;
 
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
 
@@ -4072,15 +4072,15 @@ void ieee80211_tx_status(struct net_devi
 			    STA_MAX_TX_BUFFER) {
 				ieee80211_remove_tx_extra(local, sta->key,
 							  skb,
-							  &status->control);
+							  &status->common);
 				skb_queue_tail(&sta->tx_filtered, skb);
 			} else if (!(sta->flags & WLAN_STA_PS) &&
-				   !(status->control.flags & IEEE80211_TXCTL_REQUEUE)) {
+				   !(status->common.flags & IEEE80211_TXCTL_REQUEUE)) {
 				/* Software retry the packet once */
-				status->control.flags |= IEEE80211_TXCTL_REQUEUE;
+				status->common.flags |= IEEE80211_TXCTL_REQUEUE;
 				ieee80211_remove_tx_extra(local, sta->key,
 							  skb,
-							  &status->control);
+							  &status->common);
 				dev_queue_xmit(skb);
 			} else {
 				if (net_ratelimit()) {
@@ -4136,7 +4136,7 @@ void ieee80211_tx_status(struct net_devi
 			local->dot11FailedCount++;
         }
 
-        if (!(status->control.flags & IEEE80211_TXCTL_REQ_TX_STATUS)) {
+        if (!(status->common.flags & IEEE80211_TXCTL_REQ_TX_STATUS)) {
 		dev_kfree_skb(skb);
 		return;
 	}
--- dscape.orig/net/d80211/ieee80211_scan.c
+++ dscape/net/d80211/ieee80211_scan.c
@@ -329,12 +329,12 @@ void ieee80211_init_scan(struct net_devi
 
 	memset(&local->scan.tx_control, 0, sizeof(local->scan.tx_control));
 	local->scan.tx_control.key_idx = HW_KEY_IDX_INVALID;
-	local->scan.tx_control.flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
+	local->scan.tx_control.common.flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
 	memset(&extra, 0, sizeof(extra));
 	extra.endidx = local->num_curr_rates;
 	local->scan.tx_control.tx_rate =
 		rate_control_get_rate(local, dev, local->scan.skb, &extra)->val;
-	local->scan.tx_control.flags |= IEEE80211_TXCTL_NO_ACK;
+	local->scan.tx_control.common.flags |= IEEE80211_TXCTL_NO_ACK;
 }
 
 
--- dscape.orig/net/d80211/ieee80211_sta.c
+++ dscape/net/d80211/ieee80211_sta.c
@@ -2050,7 +2050,7 @@ static int ieee80211_sta_join_ibss(struc
 		}
 
 		memset(&control, 0, sizeof(control));
-		control.pkt_type = PKT_PROBE_RESP;
+		control.common.pkt_type = PKT_PROBE_RESP;
 		memset(&extra, 0, sizeof(extra));
 		extra.endidx = local->num_curr_rates;
 		rate = rate_control_get_rate(local, dev, skb, &extra);
@@ -2064,7 +2064,7 @@ static int ieee80211_sta_join_ibss(struc
 			rate->val2 : rate->val;
 		control.antenna_sel = local->conf.antenna_sel;
 		control.power_level = local->conf.power_level;
-		control.flags |= IEEE80211_TXCTL_NO_ACK;
+		control.common.flags |= IEEE80211_TXCTL_NO_ACK;
 		control.retry_limit = 1;
 		control.rts_cts_duration = 0;
 



-- 
Jiri Benc
SUSE Labs
