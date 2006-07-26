From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 7/24] RT2x00: Add RTS frame creation
Date: Wed, 26 Jul 2006 19:04:56 +0200
Message-ID: <200607261904.56562.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:5025 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030292AbWGZRHa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:30 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812601nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:29 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Support RTS.
When rts is required, create the frame and send it out
before the rest of the frames.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-23 17:24:56.000000000 +0200
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 
18:16:35.000000000 +0200
@@ -863,6 +863,36 @@
 }
 
 /*
+ * RTS frame creation.
+ */
+static struct sk_buff* rt2400pci_create_rts(struct rt2x00_dev *rt2x00dev,
+	struct ieee80211_hdr *hdr, unsigned short duration)
+{
+	struct ieee80211_hdr *ieee80211hdr;
+	struct sk_buff *skb;
+	u16 temp;
+
+	skb = dev_alloc_skb(IEEE80211_HEADER);
+	if (!skb)
+		return NULL;
+
+	/*
+	 * Copy the entire header over to RTS frame.
+	 */
+	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
+	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
+
+	temp = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	ieee80211hdr->frame_control = cpu_to_le16(temp);
+
+	ieee80211hdr->duration_id += cpu_to_le16(duration);
+
+	ieee80211hdr->seq_ctrl = 0;
+
+	return skb;
+}
+
+/*
  * TX descriptor initialization
  */
 static void rt2400pci_write_tx_desc(struct rt2x00_dev *rt2x00dev,
@@ -876,15 +906,32 @@
 	u16 length_low;
 	u16 signal;
 	u16 service;
+	u16 frame_control;
+	u8 bitrate;
+	int tx_rate;
+
+	/*
+	 * Check which rate should be used for this frame.
+	 */
+	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS &&
+	    control->rts_cts_rate)
+		tx_rate = control->rts_cts_rate;
+	else
+		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
 	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
 
 	/*
-	 * TODO: IFS can be various values, where can we find
-	 * which one we want to use?
+	 * Set IFS to IFS_SIFS when the this is not the first fragment,
+	 * or this fragment came after RTS/CTS.
 	 */
-	rt2x00_set_field32(&txd->word0, TXD_W0_IFS, 0);
+	if ((WLAN_GET_SEQ_FRAG(le16_to_cpu(ieee80211hdr->seq_ctrl)) > 0) ||
+	    control->use_rts_cts)
+		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
+	else
+		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
 
 	if (control->queue == IEEE80211_TX_QUEUE_BEACON)
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 1);
@@ -896,16 +943,15 @@
 	 */
 	rt2x00_set_field32(&txd->word0, TXD_W0_RETRY_MODE, 0);
 
-	if (ieee80211hdr->frame_control & WLAN_FC_MOREFRAG)
+	if (frame_control & WLAN_FC_MOREFRAG)
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
 
-	/*
-	 * TODO: Does this field mean device will send RTS, or that this
-	 * frame is an RTS frame?
-	 */
-	rt2x00_set_field32(&txd->word0, TXD_W0_RTS, control->use_rts_cts);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+		rt2x00_set_field32(&txd->word10, TXD_W10_RTS, 1);
+	else
+		rt2x00_set_field32(&txd->word10, TXD_W10_RTS, 0);
 
 	rt2x00_set_field32(&txd->word2, TXD_W2_DATABYTE_COUNT, skb->len);
 
@@ -918,9 +964,9 @@
 	 * Convert length to microseconds.
 	 */
 	residual = get_duration_res(length,
-		DEVICE_GET_RATE_FIELD(control->tx_rate, RATE));
+		DEVICE_GET_RATE_FIELD(tx_rate, RATE));
 	length = get_duration(length,
-		DEVICE_GET_RATE_FIELD(control->tx_rate, RATE));
+		DEVICE_GET_RATE_FIELD(tx_rate, RATE));
 
 	if (residual)
 		length++;
@@ -938,8 +984,8 @@
 	length_high = 0x8000 | 0x0700 | (length >> 8);
 	length_low = 0x8000 | 0x0800 | (length & 0xff);
 
-	signal = 0x8500 | DEVICE_GET_RATE_FIELD(control->tx_rate, PLCP);
-	if (DEVICE_GET_RATE_FIELD(control->tx_rate, PREAMBLE))
+	signal = 0x8500 | DEVICE_GET_RATE_FIELD(tx_rate, PLCP);
+	if (DEVICE_GET_RATE_FIELD(tx_rate, PREAMBLE))
 		signal |= 0x0008;
 
 	service = 0x0600 | 0x0004;
@@ -1089,8 +1135,9 @@
 		entry->tx_status.retry_count = rt2x00_get_field32(
 			txd->word0, TXD_W0_RETRY_COUNT);
 
-		ieee80211_tx_status(ring->net_dev,
-			entry->skb, &entry->tx_status);
+		if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
+			ieee80211_tx_status(ring->net_dev,
+				entry->skb, &entry->tx_status);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		entry->skb = NULL;
@@ -1574,10 +1621,14 @@
 	struct ieee80211_tx_control *control)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct ieee80211_hdr *ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 	struct data_ring *ring;
 	struct data_entry *entry;
 	struct txd *txd;
+	struct sk_buff *skb_rts;
+	u16 frame_control;
 	u32 reg;
+	int res;
 
 	/*
 	 * Determine which ring to put packet on.
@@ -1596,6 +1647,27 @@
 		return NETDEV_TX_BUSY;
 	}
 
+	/*
+	 * If RTS is required. and this frame is not RTS,
+	 * create and queue that frame first.
+	 */
+	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
+	if (control->use_rts_cts &&
+	    WLAN_FC_GET_STYPE(frame_control) != WLAN_FC_STYPE_RTS) {
+		skb_rts = rt2400pci_create_rts(rt2x00dev,
+				ieee80211hdr, control->rts_cts_duration);
+		if (!skb_rts) {
+			WARNING("Failed to create RTS frame.\n");
+			return NETDEV_TX_BUSY;
+		}
+
+		res = rt2400pci_tx(net_dev, skb_rts, control);
+		if (res) {
+			WARNING("Failed to send RTS frame.\n");
+			return res;
+		}
+	}
+
 	entry = rt2x00_get_data_entry(ring);
 	txd = entry->desc_addr;
 
@@ -1610,6 +1682,8 @@
 
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00dev, txd, skb, control);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
 	rt2x00_ring_index_inc(ring);
diff -rU3 wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-23 17:31:27.000000000 +0200
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 
18:16:41.000000000 +0200
@@ -936,6 +936,36 @@
 }
 
 /*
+ * RTS frame creation.
+ */
+static struct sk_buff* rt2500pci_create_rts(struct rt2x00_dev *rt2x00dev,
+	struct ieee80211_hdr *hdr, unsigned short duration)
+{
+	struct ieee80211_hdr *ieee80211hdr;
+	struct sk_buff *skb;
+	u16 temp;
+
+	skb = dev_alloc_skb(IEEE80211_HEADER);
+	if (!skb)
+		return NULL;
+
+	/*
+	 * Copy the entire header over to RTS frame.
+	 */
+	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
+	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
+
+	temp = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	ieee80211hdr->frame_control = cpu_to_le16(temp);
+
+	ieee80211hdr->duration_id += cpu_to_le16(duration);
+
+	ieee80211hdr->seq_ctrl = 0;
+
+	return skb;
+}
+
+/*
  * TX descriptor initialization
  */
 static void rt2500pci_write_tx_desc(struct rt2x00_dev *rt2x00dev,
@@ -951,6 +981,19 @@
 	u16 signal;
 	u16 service;
 	u8 rate;
+	u16 frame_control;
+	u8 bitrate;
+	int tx_rate;
+
+	/*
+	 * Check which rate should be used for this frame.
+	 */
+	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS &&
+	    control->rts_cts_rate)
+		tx_rate = control->rts_cts_rate;
+	else
+		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
 	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
@@ -965,26 +1008,29 @@
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 0);
 
 	/*
-	 * TODO: IFS can be various values, where can we find
-	 * which one we want to use?
+	 * Set IFS to IFS_SIFS when the this is not the first fragment,
+	 * or this fragment came after RTS/CTS.
 	 */
-	rt2x00_set_field32(&txd->word0, TXD_W0_IFS, 0);
+	if ((WLAN_GET_SEQ_FRAG(le16_to_cpu(ieee80211hdr->seq_ctrl)) > 0) ||
+	    control->use_rts_cts)
+		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
+	else
+		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
 
 	/*
 	 * TODO: How can we determine if we want long retry or short retry?
 	 */
 	rt2x00_set_field32(&txd->word0, TXD_W0_RETRY_MODE, 0);
 
-	if (ieee80211hdr->frame_control & WLAN_FC_MOREFRAG)
+	if (frame_control & WLAN_FC_MOREFRAG)
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
 
-	/*
-	 * TODO: Does this field mean device will send RTS, or that this
-	 * frame is an RTS frame?
-	 */
-	rt2x00_set_field32(&txd->word10, TXD_W10_RTS, control->use_rts_cts);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+		rt2x00_set_field32(&txd->word10, TXD_W10_RTS, 1);
+	else
+		rt2x00_set_field32(&txd->word10, TXD_W10_RTS, 0);
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_DATABYTE_COUNT, skb->len);
 
@@ -1002,7 +1048,7 @@
 	 * this can be done by checking if bit 4 or higher
 	 * is set in the ratemask.
 	 */
-	if (DEVICE_GET_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 		residual = 0;
 
@@ -1013,7 +1059,7 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_GET_RATE_FIELD(control->tx_rate, RATE);
+		rate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
@@ -1027,8 +1073,8 @@
 		length_low = length & 0xff;
 	}
 
-	signal = 0x8500 | DEVICE_GET_RATE_FIELD(control->tx_rate, PLCP);
-	if (DEVICE_GET_RATE_FIELD(control->tx_rate, PREAMBLE))
+	signal = 0x8500 | DEVICE_GET_RATE_FIELD(tx_rate, PLCP);
+	if (DEVICE_GET_RATE_FIELD(tx_rate, PREAMBLE))
 		signal |= 0x0008;
 
 	service = 0x0600 | 0x0004;
@@ -1189,8 +1235,9 @@
 		entry->tx_status.retry_count = rt2x00_get_field32(
 			txd->word0, TXD_W0_RETRY_COUNT);
 
-		ieee80211_tx_status(ring->net_dev,
-			entry->skb, &entry->tx_status);
+		if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
+			ieee80211_tx_status(ring->net_dev,
+				entry->skb, &entry->tx_status);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		entry->skb = NULL;
@@ -1709,10 +1756,14 @@
 	struct ieee80211_tx_control *control)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct ieee80211_hdr *ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 	struct data_ring *ring;
 	struct data_entry *entry;
 	struct txd *txd;
+	struct sk_buff *skb_rts;
+	u16 frame_control;
 	u32 reg;
+	int res;
 
 	/*
 	 * Determine which ring to put packet on.
@@ -1731,6 +1782,27 @@
 		return NETDEV_TX_BUSY;
 	}
 
+	/*
+	 * If RTS is required. and this frame is not RTS,
+	 * create and queue that frame first.
+	 */
+	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
+	if (control->use_rts_cts &&
+	    WLAN_FC_GET_STYPE(frame_control) != WLAN_FC_STYPE_RTS) {
+		skb_rts = rt2500pci_create_rts(rt2x00dev,
+				ieee80211hdr, control->rts_cts_duration);
+		if (!skb_rts) {
+			WARNING("Failed to create RTS frame.\n");
+			return NETDEV_TX_BUSY;
+		}
+
+		res = rt2500pci_tx(net_dev, skb_rts, control);
+		if (res) {
+			WARNING("Failed to send RTS frame.\n");
+			return res;
+		}
+	}
+
 	entry = rt2x00_get_data_entry(ring);
 	txd = entry->desc_addr;
 
@@ -1745,6 +1817,8 @@
 
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00dev, txd, skb, control);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
 	rt2x00_ring_index_inc(ring);
diff -rU3 wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-23 17:31:13.000000000 +0200
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 
18:15:52.000000000 +0200
@@ -766,6 +766,36 @@
 }
 
 /*
+ * RTS frame creation.
+ */
+static struct sk_buff* rt2500usb_create_rts(struct rt2x00_dev *rt2x00dev,
+	struct ieee80211_hdr *hdr, unsigned short duration)
+{
+	struct ieee80211_hdr *ieee80211hdr;
+	struct sk_buff *skb;
+	u16 temp;
+
+	skb = dev_alloc_skb(IEEE80211_HEADER);
+	if (!skb)
+		return NULL;
+
+	/*
+	 * Copy the entire header over to RTS frame.
+	 */
+	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
+	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
+
+	temp = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	ieee80211hdr->frame_control = cpu_to_le16(temp);
+
+	ieee80211hdr->duration_id += cpu_to_le16(duration);
+
+	ieee80211hdr->seq_ctrl = 0;
+
+	return skb;
+}
+
+/*
  * TX descriptor initialization
  */
 static void rt2500usb_write_tx_desc(struct rt2x00_dev *rt2x00dev,
@@ -780,7 +810,19 @@
 	u8 length_low;
 	u8 signal;
 	u8 service;
-	u8 rate;
+	u16 frame_control;
+	u8 bitrate;
+	int tx_rate;
+
+	/*
+	 * Check which rate should be used for this frame.
+	 */
+	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS &&
+	    control->rts_cts_rate)
+		tx_rate = control->rts_cts_rate;
+	else
+		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
 
@@ -794,15 +836,19 @@
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 0);
 
 	/*
-	 * TODO: IFS can be various values, where can we find
-	 * which one we want to use?
+	 * Set IFS to IFS_SIFS when the this is not the first fragment,
+	 * or this fragment came after RTS/CTS.
 	 */
-	rt2x00_set_field32(&txd->word0, TXD_W0_IFS, 0);
+	if ((WLAN_GET_SEQ_FRAG(le16_to_cpu(ieee80211hdr->seq_ctrl)) > 0) ||
+	    control->use_rts_cts)
+		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
+	else
+		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_RETRY_LIMIT,
 		control->retry_limit);
 
-	if (ieee80211hdr->frame_control & WLAN_FC_MOREFRAG)
+	if (frame_control & WLAN_FC_MOREFRAG)
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
@@ -828,7 +874,7 @@
 	 * this can be done by checking if bit 4 or higher
 	 * is set in the ratemask.
 	 */
-	if (DEVICE_GET_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 		residual = 0;
 
@@ -839,7 +885,7 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_GET_RATE_FIELD(control->tx_rate, RATE);
+		rate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
@@ -853,8 +899,8 @@
 		length_low = length & 0xff;
 	}
 
-	signal = DEVICE_GET_RATE_FIELD(control->tx_rate, PLCP);
-	if (DEVICE_GET_RATE_FIELD(control->tx_rate, PREAMBLE))
+	signal = DEVICE_GET_RATE_FIELD(tx_rate, PLCP);
+	if (DEVICE_GET_RATE_FIELD(tx_rate, PREAMBLE))
 		signal |= 0x08;
 
 	service = 0x04;
@@ -1017,9 +1063,10 @@
 
 		rt2x00_bbp_read(rt2x00dev, 0,
 			(u8*)&entry->tx_status.ack_signal);
-	
-		ieee80211_tx_status(ring->net_dev,
-			entry->skb, &entry->tx_status);
+
+		if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
+			ieee80211_tx_status(ring->net_dev,
+				entry->skb, &entry->tx_status);
 
 		entry->skb = NULL;
 
@@ -1415,11 +1462,15 @@
 	struct sk_buff *skb, struct ieee80211_tx_control *control)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct ieee80211_hdr *ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 	struct usb_device *usb_dev =
 		interface_to_usbdev(rt2x00dev_usb(rt2x00dev));
 	struct data_ring *ring;
 	struct data_entry *entry;
 	struct txd *txd;
+	struct sk_buff *skb_rts;
+	u16 frame_control;
+	int res;
 
 	/*
 	 * Determine which ring to put packet on.
@@ -1438,6 +1489,27 @@
 		return NETDEV_TX_BUSY;
 	}
 
+	/*
+	 * If RTS is required. and this frame is not RTS,
+	 * create and queue that frame first.
+	 */
+	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
+	if (control->use_rts_cts &&
+	    WLAN_FC_GET_STYPE(frame_control) != WLAN_FC_STYPE_RTS) {
+		skb_rts = rt2500usb_create_rts(rt2x00dev,
+				ieee80211hdr, control->rts_cts_duration);
+		if (!skb_rts) {
+			WARNING("Failed to create RTS frame.\n");
+			return NETDEV_TX_BUSY;
+		}
+
+		res = rt2500usb_tx(net_dev, skb_rts, control);
+		if (res) {
+			WARNING("Failed to send RTS frame.\n");
+			return res;
+		}
+	}
+
 	entry = rt2x00_get_data_entry(ring);
 	txd = rt2x00usb_txdesc_addr(entry);
 
@@ -1451,6 +1523,8 @@
 
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt2500usb_write_tx_desc(rt2x00dev, txd, skb, control);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
 	SET_FLAG(entry, ENTRY_OWNER_NIC);
diff -rU3 wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2x00.h 
wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2x00.h	
2006-07-23 16:59:40.000000000 +0200
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-07-23 
18:09:00.000000000 +0200
@@ -139,6 +139,16 @@
 };
 
 /*
+ * IFS backoff values
+ */
+enum ifs {
+	IFS_BACKOFF = 0,
+	IFS_SIFS = 1,
+	IFS_NEW_BACKOFF = 2,
+	IFS_NONE = 3,
+};
+
+/*
  * Macros for determining which is the lowest or highest bit
  * set in a 16 or 32 bit variable.
  */
diff -rU3 wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h 
wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h
--- wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	
2006-07-23 15:53:34.000000000 +0200
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	2006-07-23 
17:59:04.000000000 +0200
@@ -84,6 +84,12 @@
  */
 struct data_entry {
 	/*
+	 * Status flag.
+	 */
+	unsigned int flags;
+#define ENTRY_RTS_FRAME		0x00000001
+
+	/*
 	 * sk_buff for the packet which is being transmitted
 	 * in this entry (Only used with TX related rings).
 	 */
diff -rU3 wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h 
wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h
--- wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	
2006-07-23 15:23:15.000000000 +0200
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	2006-07-23 
17:58:43.000000000 +0200
@@ -56,6 +56,7 @@
 	unsigned int flags;
 #define ENTRY_OWNER_NIC		0x00000001
 #define ENTRY_TYPE_RX		0x00000002
+#define ENTRY_RTS_FRAME		0x00000004
 
 	/*
 	 * Ring we belong to.
diff -rU3 wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt61pci.c	
2006-07-23 17:31:05.000000000 +0200
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 
18:16:51.000000000 +0200
@@ -1202,6 +1202,36 @@
 }
 
 /*
+ * RTS frame creation.
+ */
+static struct sk_buff* rt61pci_create_rts(struct rt2x00_dev *rt2x00dev,
+	struct ieee80211_hdr *hdr, unsigned short duration)
+{
+	struct ieee80211_hdr *ieee80211hdr;
+	struct sk_buff *skb;
+	u16 temp;
+
+	skb = dev_alloc_skb(IEEE80211_HEADER);
+	if (!skb)
+		return NULL;
+
+	/*
+	 * Copy the entire header over to RTS frame.
+	 */
+	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
+	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
+
+	temp = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	ieee80211hdr->frame_control = cpu_to_le16(temp);
+
+	ieee80211hdr->duration_id += cpu_to_le16(duration);
+
+	ieee80211hdr->seq_ctrl = 0;
+
+	return skb;
+}
+
+/*
  * TX descriptor initialization
  */
 static void rt61pci_write_tx_desc(struct rt2x00_dev *rt2x00dev,
@@ -1217,6 +1247,19 @@
 	u16 signal;
 	u16 service;
 	u8 rate;
+	u16 frame_control;
+	u8 bitrate;
+	int tx_rate;
+
+	/*
+	 * Check which rate should be used for this frame.
+	 */
+	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS &&
+	    control->rts_cts_rate)
+		tx_rate = control->rts_cts_rate;
+	else
+		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
 	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
@@ -1231,17 +1274,21 @@
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 0);
 
 	/*
-	 * TODO: IFS can be various values, where can we find
-	 * which one we want to use?
+	 * Set IFS to IFS_SIFS when the this is not the first fragment,
+	 * or this fragment came after RTS/CTS.
 	 */
-	rt2x00_set_field32(&txd->word0, TXD_W0_IFS, 0);
+	if ((WLAN_GET_SEQ_FRAG(le16_to_cpu(ieee80211hdr->seq_ctrl)) > 0) ||
+	    control->use_rts_cts)
+		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
+	else
+		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
 
 	/*
 	 * TODO: How can we determine if we want long retry or short retry?
 	 */
 	rt2x00_set_field32(&txd->word0, TXD_W0_RETRY_MODE, 0);
 
-	if (ieee80211hdr->frame_control & WLAN_FC_MOREFRAG)
+	if (frame_control & WLAN_FC_MOREFRAG)
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
@@ -1277,7 +1324,7 @@
 	 * this can be done by checking if bit 4 or higher
 	 * is set in the ratemask.
 	 */
-	if (DEVICE_GET_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 
 		/*
@@ -1288,7 +1335,7 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_GET_RATE_FIELD(control->tx_rate, RATE);
+		rate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
@@ -1302,8 +1349,8 @@
 		length_low = length & 0xff;
 	}
 
-	signal = 0x8500 | DEVICE_GET_RATE_FIELD(control->tx_rate, PLCP);
-	if (DEVICE_GET_RATE_FIELD(control->tx_rate, PREAMBLE))
+	signal = 0x8500 | DEVICE_GET_RATE_FIELD(tx_rate, PLCP);
+	if (DEVICE_GET_RATE_FIELD(tx_rate, PREAMBLE))
 		signal |= 0x0008;
 
 	service = 0x04;
@@ -1470,8 +1517,9 @@
 		entry->tx_status.retry_count = rt2x00_get_field32(
 			reg, STA_CSR4_RETRY_COUNT);
 
-		ieee80211_tx_status(ring->net_dev,
-			entry->skb, &entry->tx_status);
+		if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
+			ieee80211_tx_status(ring->net_dev,
+				entry->skb, &entry->tx_status);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		entry->skb = NULL;
@@ -2158,10 +2206,14 @@
 	struct ieee80211_tx_control *control)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct ieee80211_hdr *ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 	struct data_ring *ring;
 	struct data_entry *entry;
 	struct txd *txd;
+	struct sk_buff *skb_rts;
+	u16 frame_control;
 	u32 reg;
+	int res;
 
 	/*
 	 * Determine which ring to put packet on.
@@ -2180,6 +2232,27 @@
 		return NETDEV_TX_BUSY;
 	}
 
+	/*
+	 * If RTS is required. and this frame is not RTS,
+	 * create and queue that frame first.
+	 */
+	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
+	if (control->use_rts_cts &&
+	    WLAN_FC_GET_STYPE(frame_control) != WLAN_FC_STYPE_RTS) {
+		skb_rts = rt61pci_create_rts(rt2x00dev,
+				ieee80211hdr, control->rts_cts_duration);
+		if (!skb_rts) {
+			WARNING("Failed to create RTS frame.\n");
+			return NETDEV_TX_BUSY;
+		}
+
+		res = rt61pci_tx(net_dev, skb_rts, control);
+		if (res) {
+			WARNING("Failed to send RTS frame.\n");
+			return res;
+		}
+	}
+
 	entry = rt2x00_get_data_entry(ring);
 	txd = entry->desc_addr;
 
@@ -2194,6 +2267,8 @@
 
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt61pci_write_tx_desc(rt2x00dev, txd, skb, control);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
 	rt2x00_ring_index_inc(ring);
diff -rU3 wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-23 17:30:57.000000000 +0200
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 
18:17:01.000000000 +0200
@@ -932,6 +932,36 @@
 }
 
 /*
+ * RTS frame creation.
+ */
+static struct sk_buff* rt73usb_create_rts(struct rt2x00_dev *rt2x00dev,
+	struct ieee80211_hdr *hdr, unsigned short duration)
+{
+	struct ieee80211_hdr *ieee80211hdr;
+	struct sk_buff *skb;
+	u16 temp;
+
+	skb = dev_alloc_skb(IEEE80211_HEADER);
+	if (!skb)
+		return NULL;
+
+	/*
+	 * Copy the entire header over to RTS frame.
+	 */
+	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
+	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
+
+	temp = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	ieee80211hdr->frame_control = cpu_to_le16(temp);
+
+	ieee80211hdr->duration_id += cpu_to_le16(duration);
+
+	ieee80211hdr->seq_ctrl = 0;
+
+	return skb;
+}
+
+/*
  * TX descriptor initialization
  */
 static void rt73usb_write_tx_desc(struct rt2x00_dev *rt2x00dev,
@@ -947,6 +977,19 @@
 	u16 signal;
 	u16 service;
 	u8 rate;
+	u16 frame_control;
+	u8 bitrate;
+	int tx_rate;
+
+	/*
+	 * Check which rate should be used for this frame.
+	 */
+	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS &&
+	    control->rts_cts_rate)
+		tx_rate = control->rts_cts_rate;
+	else
+		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
 	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
@@ -961,17 +1004,21 @@
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 0);
 
 	/*
-	 * TODO: IFS can be various values, where can we find
-	 * which one we want to use?
+	 * Set IFS to IFS_SIFS when the this is not the first fragment,
+	 * or this fragment came after RTS/CTS.
 	 */
-	rt2x00_set_field32(&txd->word0, TXD_W0_IFS, 0);
+	if ((WLAN_GET_SEQ_FRAG(le16_to_cpu(ieee80211hdr->seq_ctrl)) > 0) ||
+	    control->use_rts_cts)
+		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
+	else
+		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
 
 	/*
 	 * TODO: How can we determine if we want long retry or short retry?
 	 */
 	rt2x00_set_field32(&txd->word0, TXD_W0_RETRY_MODE, 0);
 
-	if (ieee80211hdr->frame_control & WLAN_FC_MOREFRAG)
+	if (frame_control & WLAN_FC_MOREFRAG)
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
@@ -1007,7 +1054,7 @@
 	 * this can be done by checking if bit 4 or higher
 	 * is set in the ratemask.
 	 */
-	if (DEVICE_GET_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 
 		/*
@@ -1018,7 +1065,7 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_GET_RATE_FIELD(control->tx_rate, RATE);
+		rate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
@@ -1032,8 +1079,8 @@
 		length_low = length & 0xff;
 	}
 
-	signal = 0x8500 | DEVICE_GET_RATE_FIELD(control->tx_rate, PLCP);
-	if (DEVICE_GET_RATE_FIELD(control->tx_rate, PREAMBLE))
+	signal = 0x8500 | DEVICE_GET_RATE_FIELD(tx_rate, PLCP);
+	if (DEVICE_GET_RATE_FIELD(tx_rate, PREAMBLE))
 		signal |= 0x0008;
 
 	service = 0x04;
@@ -1205,8 +1252,9 @@
 		rt2x00_bbp_read(rt2x00dev, 32,
 			(u8*)&entry->tx_status.ack_signal);
 
-		ieee80211_tx_status(ring->net_dev,
-			entry->skb, &entry->tx_status);
+		if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
+			ieee80211_tx_status(ring->net_dev,
+				entry->skb, &entry->tx_status);
 
 		entry->skb = NULL;
 
@@ -1728,11 +1776,15 @@
 	struct sk_buff *skb, struct ieee80211_tx_control *control)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct ieee80211_hdr *ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 	struct usb_device *usb_dev =
 		interface_to_usbdev(rt2x00dev_usb(rt2x00dev));
 	struct data_ring *ring;
 	struct data_entry *entry;
 	struct txd *txd;
+	struct sk_buff *skb_rts;
+	u16 frame_control;
+	int res;
 
 	/*
 	 * Determine which ring to put packet on.
@@ -1751,6 +1803,27 @@
 		return NETDEV_TX_BUSY;
 	}
 
+	/*
+	 * If RTS is required. and this frame is not RTS,
+	 * create and queue that frame first.
+	 */
+	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
+	if (control->use_rts_cts &&
+	    WLAN_FC_GET_STYPE(frame_control) != WLAN_FC_STYPE_RTS) {
+		skb_rts = rt73usb_create_rts(rt2x00dev,
+				ieee80211hdr, control->rts_cts_duration);
+		if (!skb_rts) {
+			WARNING("Failed to create RTS frame.\n");
+			return NETDEV_TX_BUSY;
+		}
+
+		res = rt73usb_tx(net_dev, skb_rts, control);
+		if (res) {
+			WARNING("Failed to send RTS frame.\n");
+			return res;
+		}
+	}
+
 	entry = rt2x00_get_data_entry(ring);
 	txd = rt2x00usb_txdesc_addr(entry);
 
@@ -1764,6 +1837,8 @@
 
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt73usb_write_tx_desc(rt2x00dev, txd, skb, control);
+	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
 	SET_FLAG(entry, ENTRY_OWNER_NIC);
