From: David Kimdon <david.kimdon@devicescape.com>
Subject: [take1 1/5] d80211: remove bitfields from ieee80211_tx_control
Date: Tue, 17 Oct 2006 10:17:17 -0700
Message-ID: <20061017171717.GB13669@devicescape.com>
References: <20061017171624.299590000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:46272 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751335AbWJQRRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 13:17:18 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="tx_control_bitfields.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All one-bit bitfields have been subsumed into the new 'flags'
structure member and the new IEEE80211_TXCTL_* definitions.  The
multiple bit members were converted to u8, s8 or u16 as appropriate.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
@@ -141,36 +141,38 @@ struct ieee80211_tx_control {
 	int rts_cts_rate; /* Transmit rate for RTS/CTS frame, given as the hw
 			   * specific value for the rate (from
 			   * struct ieee80211_rate) */
-	/* 1 = only first attempt, 2 = one retry, .. */
-	unsigned int retry_limit:8;
-	/* duration field for RTS/CTS frame */
-	unsigned int rts_cts_duration:16;
-	unsigned int req_tx_status:1; /* request TX status callback for this
-				       * frame */
-	unsigned int do_not_encrypt:1; /* send this frame without encryption;
-			       * e.g., for EAPOL frames */
-	unsigned int use_rts_cts:1; /* Use RTS-CTS before sending frame. */
-	unsigned int use_cts_protect:1; /* Use CTS protection for the frame
-					 * (e.g., for combined 802.11g /
-					 * 802.11b networks) */
-        unsigned int no_ack:1; /* Tell the low level not to wait for an ack */
-	unsigned int rate_ctrl_probe:1;
-	unsigned int clear_dst_mask:1;
-	unsigned int requeue:1;
-	unsigned int first_fragment:1;	/* This is a first fragment of the
-					 * frame */
-        unsigned int power_level:8; /* per-packet transmit power level, in dBm
-				     */
-	unsigned int antenna_sel:4; /* 0 = default/diversity,
-				     * 1 = Ant0, 2 = Ant1 */
-	int key_idx:8; /* -1 = do not encrypt, >= 0 keyidx from hw->set_key()
-			*/
-	int icv_len:8; /* Length of the ICV/MIC field in octets */
-	int iv_len:8; /* Length of the IV field in octets */
-	unsigned int queue:4; /* hardware queue to use for this frame;
-		      * 0 = highest, hw->queues-1 = lowest */
-	unsigned int sw_retry_attempt:4; /* no. of times hw has tried to
-		      * transmit frame (not incl. hw retries) */
+
+#define IEEE80211_TXCTL_REQ_TX_STATUS	(1<<0)/* request TX status callback for
+						* this frame */
+#define IEEE80211_TXCTL_DO_NOT_ENCRYPT	(1<<1) /* send this frame without
+						* encryption; e.g., for EAPOL
+						* frames */
+#define IEEE80211_TXCTL_USE_RTS_CTS	(1<<2) /* use RTS-CTS before sending
+						* frame */
+#define IEEE80211_TXCTL_USE_CTS_PROTECT	(1<<3) /* use CTS protection for the
+						* frame (e.g., for combined
+						* 802.11g / 802.11b networks) */
+#define IEEE80211_TXCTL_NO_ACK		(1<<4) /* tell the low level not to
+						* wait for an ack */
+#define IEEE80211_TXCTL_RATE_CTRL_PROBE	(1<<5)
+#define IEEE80211_TXCTL_CLEAR_DST_MASK	(1<<6)
+#define IEEE80211_TXCTL_REQUEUE		(1<<7)
+#define IEEE80211_TXCTL_FIRST_FRAGMENT	(1<<8) /* this is a first fragment of
+						* the frame */
+	u16 flags;			       /* tx control flags defined
+						* above */
+	u16 rts_cts_duration;	/* duration field for RTS/CTS frame */
+	u8 retry_limit;		/* 1 = only first attempt, 2 = one retry, .. */
+	u8 power_level;		/* per-packet transmit power level, in dBm */
+	u8 antenna_sel; 	/* 0 = default/diversity, 1 = Ant0, 2 = Ant1 */
+	s8 key_idx;		/* -1 = do not encrypt, >= 0 keyidx from
+				 * hw->set_key() */
+	u8 icv_len;		/* length of the ICV/MIC field in octets */
+	u8 iv_len;		/* length of the IV field in octets */
+	u8 queue;		/* hardware queue to use for this frame;
+				 * 0 = highest, hw->queues-1 = lowest */
+	u8 sw_retry_attempt;	/* number of times hw has tried to
+				 * transmit frame (not incl. hw retries) */
 
 	int rateidx; /* internal 80211.o rateidx */
 	int alt_retry_rate; /* retry rate for the last retries, given as the
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -363,7 +363,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
 
 	tx->u.tx.rate = rate_control_get_rate(tx->dev, tx->skb, &extra);
 	if (unlikely(extra.probe != NULL)) {
-		tx->u.tx.control->rate_ctrl_probe = 1;
+		tx->u.tx.control->flags |= IEEE80211_TXCTL_RATE_CTRL_PROBE;
 		tx->u.tx.probe_last_frag = 1;
 		tx->u.tx.control->alt_retry_rate = tx->u.tx.rate->val;
 		tx->u.tx.rate = extra.probe;
@@ -381,7 +381,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
 
 		tx->u.tx.rate = extra.nonerp;
 		tx->u.tx.control->rateidx = extra.nonerp_idx;
-		tx->u.tx.control->rate_ctrl_probe = 0;
+		tx->u.tx.control->flags &= ~IEEE80211_TXCTL_RATE_CTRL_PROBE;
 	} else {
 		tx->u.tx.last_frag_rate = tx->u.tx.rate;
 		tx->u.tx.last_frag_rateidx = extra.rateidx;
@@ -407,7 +407,7 @@ ieee80211_tx_h_select_key(struct ieee802
 	else
 		tx->u.tx.control->key_idx = HW_KEY_IDX_INVALID;
 
-	if (unlikely(tx->u.tx.control->do_not_encrypt))
+	if (unlikely(tx->u.tx.control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT))
 		tx->key = NULL;
 	else if (tx->sta && tx->sta->key)
 		tx->key = tx->sta->key;
@@ -762,7 +762,7 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 	if (!is_multicast_ether_addr(hdr->addr1)) {
 		if (tx->skb->len + FCS_LEN > tx->local->rts_threshold &&
 		    tx->local->rts_threshold < IEEE80211_MAX_RTS_THRESHOLD) {
-			control->use_rts_cts = 1;
+			control->flags |= IEEE80211_TXCTL_USE_RTS_CTS;
 			control->retry_limit =
 				tx->local->long_retry_limit;
 		} else {
@@ -788,8 +788,8 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 	    (tx->u.tx.rate->flags & IEEE80211_RATE_ERP) &&
 	    tx->u.tx.unicast &&
 	    tx->local->cts_protect_erp_frames &&
-	    !control->use_rts_cts)
-		control->use_cts_protect = 1;
+	    !(control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
+		control->flags |= IEEE80211_TXCTL_USE_CTS_PROTECT;
 
 	/* Setup duration field for the first fragment of the frame. Duration
 	 * for remaining fragments will be updated when they are being sent
@@ -799,7 +799,8 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 				 0);
 	hdr->duration_id = cpu_to_le16(dur);
 
-	if (control->use_rts_cts || control->use_cts_protect) {
+	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) ||
+	    (control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT)) {
 		struct ieee80211_rate *rate;
 		int erp = tx->u.tx.rate->flags & IEEE80211_RATE_ERP;
 
@@ -812,7 +813,7 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 		       !(rate->flags & IEEE80211_RATE_BASIC))
 			rate--;
 
-		if (control->use_rts_cts)
+		if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS)
 			dur += ieee80211_frame_duration(tx->local, 10,
 							rate->rate, erp,
 							tx->local->
@@ -1100,15 +1101,18 @@ __ieee80211_tx_prepare(struct ieee80211_
         control->power_level = local->conf.power_level;
 	tx->u.tx.control = control;
         tx->u.tx.unicast = !is_multicast_ether_addr(hdr->addr1);
-        control->no_ack = is_multicast_ether_addr(hdr->addr1);
+	if (is_multicast_ether_addr(hdr->addr1))
+		control->flags |= IEEE80211_TXCTL_NO_ACK;
+	else
+		control->flags &= ~IEEE80211_TXCTL_NO_ACK;
 	tx->fragmented = local->fragmentation_threshold <
 		IEEE80211_MAX_FRAG_THRESHOLD && tx->u.tx.unicast &&
 		skb->len + 4 /* FCS */ > local->fragmentation_threshold &&
 		(!local->hw->set_frag_threshold);
 	if (!tx->sta)
-		control->clear_dst_mask = 1;
+		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 	else if (tx->sta->clear_dst_mask) {
-		control->clear_dst_mask = 1;
+		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 		tx->sta->clear_dst_mask = 0;
 	}
 	control->antenna_sel = local->conf.antenna_sel;
@@ -1119,7 +1123,7 @@ __ieee80211_tx_prepare(struct ieee80211_
 		u8 *pos = &skb->data[hdrlen + sizeof(rfc1042_header)];
 		tx->ethertype = (pos[0] << 8) | pos[1];
 	}
-	control->first_fragment = 1;
+	control->flags |= IEEE80211_TXCTL_FIRST_FRAGMENT;
 
 }
 
@@ -1183,10 +1187,10 @@ static int __ieee80211_tx(struct ieee802
 		ieee80211_led_tx(local, 1);
 	}
 	if (tx->u.tx.extra_frag) {
-		control->use_rts_cts = 0;
-		control->use_cts_protect = 0;
-		control->clear_dst_mask = 0;
-		control->first_fragment = 0;
+		control->flags &= ~(IEEE80211_TXCTL_USE_RTS_CTS |
+				    IEEE80211_TXCTL_USE_CTS_PROTECT |
+				    IEEE80211_TXCTL_CLEAR_DST_MASK |
+				    IEEE80211_TXCTL_FIRST_FRAGMENT);
 		for (i = 0; i < tx->u.tx.num_extra_frag; i++) {
 			if (!tx->u.tx.extra_frag[i])
 				continue;
@@ -1195,8 +1199,12 @@ static int __ieee80211_tx(struct ieee802
 			if (i == tx->u.tx.num_extra_frag) {
 				control->tx_rate = tx->u.tx.last_frag_hwrate;
 				control->rateidx = tx->u.tx.last_frag_rateidx;
-				control->rate_ctrl_probe =
-					tx->u.tx.probe_last_frag;
+				if (tx->u.tx.probe_last_frag)
+					control->flags |=
+						IEEE80211_TXCTL_RATE_CTRL_PROBE;
+				else
+					control->flags &=
+						~IEEE80211_TXCTL_RATE_CTRL_PROBE;
 			}
 
 			ieee80211_dump_frame(local->mdev->name,
@@ -1411,11 +1419,14 @@ static int ieee80211_master_start_xmit(s
 
 	control.ifindex = odev->ifindex;
 	control.type = osdata->type;
-	control.req_tx_status = pkt_data->req_tx_status;
-	control.do_not_encrypt = pkt_data->do_not_encrypt;
+	if (pkt_data->req_tx_status)
+		control.flags |= IEEE80211_TXCTL_REQ_TX_STATUS;
+	if (pkt_data->do_not_encrypt)
+		control.flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
 	control.pkt_type =
 		pkt_data->pkt_probe_resp ? PKT_PROBE_RESP : PKT_NORMAL;
-	control.requeue = pkt_data->requeue;
+	if (pkt_data->requeue)
+		control.flags |= IEEE80211_TXCTL_REQUEUE;
 	control.queue = pkt_data->queue;
 
 	ret = ieee80211_tx(odev, skb, &control,
@@ -1805,10 +1816,10 @@ struct sk_buff * ieee80211_beacon_get(st
 			rate->val2 : rate->val;
 		control->antenna_sel = local->conf.antenna_sel;
 		control->power_level = local->conf.power_level;
-		control->no_ack = 1;
+		control->flags |= IEEE80211_TXCTL_NO_ACK;
 		control->retry_limit = 1;
 		control->rts_cts_duration = 0;
-		control->clear_dst_mask = 1;
+		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 	}
 
 	ap->num_beacons++;
@@ -3728,9 +3739,9 @@ ieee80211_tx_h_load_stats(struct ieee802
 	if (!is_multicast_ether_addr(hdr->addr1))
 		load += hdrtime;
 
-	if (tx->u.tx.control->use_rts_cts)
+	if (tx->u.tx.control->flags & IEEE80211_TXCTL_USE_RTS_CTS)
 		load += 2 * hdrtime;
-	else if (tx->u.tx.control->use_cts_protect)
+	else if (tx->u.tx.control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT)
 		load += hdrtime;
 
 	load += skb->len * tx->u.tx.rate->rate_inv;
@@ -3880,7 +3891,7 @@ void ieee80211_tx_status_irqsafe(struct 
 		memcpy(saved, status, sizeof(struct ieee80211_tx_status));
 	memcpy(skb->cb, &saved, sizeof(saved));
         skb->pkt_type = ieee80211_tx_status_msg;
-	skb_queue_tail(status->control.req_tx_status ?
+	skb_queue_tail(status->control.flags & IEEE80211_TXCTL_REQ_TX_STATUS ?
 		       &local->skb_queue : &local->skb_queue_unreliable, skb);
 	tmp = skb_queue_len(&local->skb_queue) +
 		skb_queue_len(&local->skb_queue_unreliable);
@@ -3957,10 +3968,10 @@ static void ieee80211_remove_tx_extra(st
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
 	pkt_data->ifindex = control->ifindex;
 	pkt_data->mgmt_iface = (control->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->req_tx_status = control->req_tx_status;
-	pkt_data->do_not_encrypt = control->do_not_encrypt;
+	pkt_data->req_tx_status = !!(control->flags & IEEE80211_TXCTL_REQ_TX_STATUS);
+	pkt_data->do_not_encrypt = !!(control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT);
 	pkt_data->pkt_probe_resp = (control->pkt_type == PKT_PROBE_RESP);
-	pkt_data->requeue = control->requeue;
+	pkt_data->requeue = !!(control->flags & IEEE80211_TXCTL_REQUEUE);
 	pkt_data->queue = control->queue;
 
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
@@ -4063,9 +4074,9 @@ void ieee80211_tx_status(struct net_devi
 							  &status->control);
 				skb_queue_tail(&sta->tx_filtered, skb);
 			} else if (!(sta->flags & WLAN_STA_PS) &&
-				   !status->control.requeue) {
+				   !(status->control.flags & IEEE80211_TXCTL_REQUEUE)) {
 				/* Software retry the packet once */
-				status->control.requeue = 1;
+				status->control.flags |= IEEE80211_TXCTL_REQUEUE;
 				ieee80211_remove_tx_extra(local, sta->key,
 							  skb,
 							  &status->control);
@@ -4124,7 +4135,7 @@ void ieee80211_tx_status(struct net_devi
 			local->dot11FailedCount++;
         }
 
-        if (!status->control.req_tx_status) {
+        if (!(status->control.flags & IEEE80211_TXCTL_REQ_TX_STATUS)) {
 		dev_kfree_skb(skb);
 		return;
 	}
Index: wireless-dev/net/d80211/ieee80211_scan.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_scan.c
+++ wireless-dev/net/d80211/ieee80211_scan.c
@@ -329,12 +329,12 @@ void ieee80211_init_scan(struct net_devi
 
 	memset(&local->scan.tx_control, 0, sizeof(local->scan.tx_control));
 	local->scan.tx_control.key_idx = HW_KEY_IDX_INVALID;
-	local->scan.tx_control.do_not_encrypt = 1;
+	local->scan.tx_control.flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
 	memset(&extra, 0, sizeof(extra));
 	extra.endidx = local->num_curr_rates;
 	local->scan.tx_control.tx_rate =
 		rate_control_get_rate(dev, local->scan.skb, &extra)->val;
-	local->scan.tx_control.no_ack = 1;
+	local->scan.tx_control.flags |= IEEE80211_TXCTL_NO_ACK;
 }
 
 
Index: wireless-dev/net/d80211/ieee80211_sta.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_sta.c
+++ wireless-dev/net/d80211/ieee80211_sta.c
@@ -2062,7 +2062,7 @@ static int ieee80211_sta_join_ibss(struc
 			rate->val2 : rate->val;
 		control.antenna_sel = local->conf.antenna_sel;
 		control.power_level = local->conf.power_level;
-		control.no_ack = 1;
+		control.flags |= IEEE80211_TXCTL_NO_ACK;
 		control.retry_limit = 1;
 		control.rts_cts_duration = 0;
 
Index: wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -437,7 +437,8 @@ static void adm8211_interrupt_tci(struct
 		pci_unmap_single(priv->pdev, priv->tx_buffers[entry].mapping,
 				 priv->tx_buffers[entry].skb->len, PCI_DMA_TODEVICE);
 
-		if (priv->tx_buffers[entry].tx_status.control.req_tx_status ||
+		if ((priv->tx_buffers[entry].tx_status.control.flags &
+		     IEEE80211_TXCTL_REQ_TX_STATUS) ||
 		    !is_multicast_ether_addr(ieee80211_get_DA(&priv->tx_buffers[entry].hdr))) {
 			struct ieee80211_hdr *hdr;
 			size_t hdrlen = ieee80211_get_hdrlen(le16_to_cpu(priv->tx_buffers[entry].hdr.frame_control));
@@ -1859,7 +1860,7 @@ static int adm8211_tx(struct net_device 
 	if (short_preamble)
 		txhdr->header_control |= cpu_to_le16(ADM8211_TXHDRCTL_SHORT_PREAMBLE);
 
-	if (control->use_rts_cts)
+	if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS)
 		txhdr->header_control |= cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_RTS);
 
 	if (fc & IEEE80211_FCTL_PROTECTED)
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
@@ -280,7 +280,8 @@ void bcm43xx_generate_txhdr(struct bcm43
 {
 	const struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	const struct ieee80211_hdr *wireless_header = (const struct ieee80211_hdr *)fragment_data;
-	const int use_encryption = (!txctl->do_not_encrypt && txctl->key_idx >= 0);
+	const int use_encryption = (!(txctl->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT) &&
+				    txctl->key_idx >= 0);
 	u8 bitrate;
 	u8 fallback_bitrate;
 	int ofdm_modulation;
@@ -340,13 +341,13 @@ void bcm43xx_generate_txhdr(struct bcm43
 		   & BCM43xx_TXHDRCTL_ANTENNADIV_MASK;
 
 	/* Set the FLAGS field */
-	if (!txctl->no_ack)
+	if (!(txctl->flags & IEEE80211_TXCTL_NO_ACK))
 		flags |= BCM43xx_TXHDRFLAG_EXPECTACK;
 	if (1 /* FIXME: PS poll?? */)
 		flags |= 0x10; // FIXME: unknown meaning.
 	if (fallback_ofdm_modulation)
 		flags |= BCM43xx_TXHDRFLAG_FALLBACKOFDM;
-	if (txctl->first_fragment)
+	if (txctl->flags & IEEE80211_TXCTL_FIRST_FRAGMENT)
 		flags |= BCM43xx_TXHDRFLAG_FIRSTFRAGMENT;
 
 	/* Set WSEC/RATE field */
@@ -358,7 +359,7 @@ void bcm43xx_generate_txhdr(struct bcm43
 	 *        if we are on 80211g. If we get too many
 	 *        failures (hidden nodes), we should switch back to RTS/CTS.
 	 */
-	if (txctl->use_rts_cts) {
+	if (txctl->flags & IEEE80211_TXCTL_USE_RTS_CTS) {
 		bcm43xx_generate_rts(phy, txhdr, &flags,
 				     txctl->rts_cts_rate,
 				     wireless_header);
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1556,14 +1556,15 @@ static void rt2400pci_write_tx_desc(stru
 		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
-	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
+	rt2x00_set_field32(&txd->word0, TXD_W0_ACK,
+			   !(control->flags & IEEE80211_TXCTL_NO_ACK));
 
 	/*
 	 * Set IFS to IFS_SIFS when the this is not the first fragment,
 	 * or this fragment came after RTS/CTS.
 	 */
 	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
-	    control->use_rts_cts)
+	    (control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
@@ -1907,7 +1908,7 @@ static int rt2400pci_tx(struct net_devic
 	 * create and queue that frame first.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (control->use_rts_cts &&
+	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
 	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt2400pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1681,7 +1681,8 @@ static void rt2500pci_write_tx_desc(stru
 		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
-	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
+	rt2x00_set_field32(&txd->word0, TXD_W0_ACK,
+			   !(control->flags & IEEE80211_TXCTL_NO_ACK));
 
 	ring = rt2x00_get_ring(rt2x00dev, control->queue);
 	if (unlikely(!ring))
@@ -1697,7 +1698,7 @@ static void rt2500pci_write_tx_desc(stru
 	 * or this fragment came after RTS/CTS.
 	 */
 	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
-	    control->use_rts_cts)
+	    (control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
@@ -2056,7 +2057,7 @@ static int rt2500pci_tx(struct net_devic
 	 * create and queue that frame first.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (control->use_rts_cts &&
+	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
 	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt2500pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -2111,7 +2111,8 @@ static void rt61pci_write_tx_desc(struct
 		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
-	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
+	rt2x00_set_field32(&txd->word0, TXD_W0_ACK,
+		       	   !(control->flags & IEEE80211_TXCTL_NO_ACK));
 
 	ring = rt2x00_get_ring(rt2x00dev, control->queue);
 	if (unlikely(!ring))
@@ -2127,7 +2128,7 @@ static void rt61pci_write_tx_desc(struct
 	 * or this fragment came after RTS/CTS.
 	 */
 	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
-	    control->use_rts_cts)
+	    (control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
@@ -2532,7 +2533,7 @@ static int rt61pci_tx(struct net_device 
 	 * create and queue that frame first.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (control->use_rts_cts &&
+	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
 	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt61pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);

--
