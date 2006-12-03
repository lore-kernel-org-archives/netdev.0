From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 16/26] rt2x00: Correctly handle RTS frames
Date: Sun, 3 Dec 2006 19:19:00 +0100
Message-ID: <200612031919.00529.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:19032 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758846AbWLCST1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:27 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144307nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:26 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correctly handle rts frames in txdone, by freeing the
packet. Also use the is_rts_frame to detect if the
frame was rts. This was done incorrectly previously.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 14:10:28.000000000 +0100
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 14:19:54.000000000 +0100
@@ -1597,6 +1597,7 @@
 	int tx_status;
 	int ack;
 	int ring_full;
+	int rts;
 
 	/*
 	 * Store the current status of the ring.
@@ -1634,9 +1635,16 @@
 		entry->tx_status.retry_count = rt2x00_get_field32(
 			word, TXD_W0_RETRY_COUNT);
 
-		if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
+		/*
+		 * If this is not an RTS frame send the tx_status to d80211,
+		 * that method also cleans up the skb structure. When this
+		 * is a RTS frame, that it is our job to clean this structure up.
+		 */
+		if (!rts)
 			ieee80211_tx_status(rt2x00dev->hw,
 				entry->skb, &entry->tx_status);
+		else
+			dev_kfree_skb(entry->skb);
 
 		rt2x00_set_field32(&word, TXD_W0_VALID, 0);
 		rt2x00_desc_write(txd, 0, word);
@@ -1772,7 +1780,7 @@
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
 	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
-	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
+	    !is_rts_frame(frame_control)) {
 		skb_rts = rt2400pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
 		if (!skb_rts) {
@@ -1808,8 +1816,7 @@
 	memcpy(rt2x00_data_addr(entry), skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
-	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
+	if (is_rts_frame(frame_control))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff -rU3 wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 14:10:52.000000000 +0100
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 14:21:13.000000000 +0100
@@ -1760,6 +1760,7 @@
 	int tx_status;
 	int ack;
 	int ring_full;
+	int rts;
 
 	/*
 	 * Store the current status of the ring.
@@ -1797,9 +1798,16 @@
 		entry->tx_status.retry_count = rt2x00_get_field32(
 			word, TXD_W0_RETRY_COUNT);
 
-		if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
+		/*
+		 * If this is not an RTS frame send the tx_status to d80211,
+		 * that method also cleans up the skb structure. When this
+		 * is a RTS frame, that it is our job to clean this structure up.
+		 */
+		if (!rts)
 			ieee80211_tx_status(rt2x00dev->hw,
 				entry->skb, &entry->tx_status);
+		else
+			dev_kfree_skb(entry->skb);
 
 		rt2x00_set_field32(&word, TXD_W0_VALID, 0);
 		rt2x00_desc_write(txd, 0, word);
@@ -1935,7 +1943,7 @@
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
 	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
-	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
+	    !is_rts_frame(frame_control)) {
 		skb_rts = rt2500pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
 		if (!skb_rts) {
@@ -1970,8 +1978,7 @@
 	memcpy(rt2x00_data_addr(entry), skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
-	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
+	if (is_rts_frame(frame_control))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff -rU3 wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:11:15.000000000 +0100
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:21:53.000000000 +0100
@@ -1722,6 +1722,7 @@
 	u32 word;
 	int ack;
 	int ring_full;
+	int rts;
 
 	/*
 	 * Store the current status of the ring.
@@ -1755,9 +1756,16 @@
 		rt2x00_bbp_read(rt2x00dev, 0,
 			(u8*)&entry->tx_status.ack_signal);
 
-		if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
+		/*
+		 * If this is not an RTS frame send the tx_status to d80211,
+		 * that method also cleans up the skb structure. When this
+		 * is a RTS frame, that it is our job to clean this structure up.
+		 */
+		if (!rts)
 			ieee80211_tx_status(rt2x00dev->hw,
 				entry->skb, &entry->tx_status);
+		else
+			dev_kfree_skb(entry->skb);
 
 		CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 		entry->skb = NULL;
@@ -1845,7 +1853,7 @@
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
 	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
-	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
+	    !is_rts_frame(frame_control)) {
 		skb_rts = rt2500usb_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
 		if (!skb_rts) {
@@ -1874,8 +1882,7 @@
 	memcpy(rt2x00_txdata_addr(entry), skb->data, skb->len);
 	rt2500usb_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
-	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
+	if (is_rts_frame(frame_control))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff -rU3 wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 14:11:38.000000000 +0100
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 14:22:40.000000000 +0100
@@ -2223,6 +2223,7 @@
 	int tx_status;
 	int ack;
 	int ring_full;
+	int rts;
 
 	txd = rt2x00_desc_addr(entry);
 	rt2x00_desc_read(txd, 0, &word);
@@ -2255,9 +2256,16 @@
 	entry->tx_status.retry_count = rt2x00_get_field32(
 		sta_csr4, STA_CSR4_RETRY_COUNT);
 
-	if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
+	/*
+	 * If this is not an RTS frame send the tx_status to d80211,
+	 * that method also cleans up the skb structure. When this
+	 * is a RTS frame, that it is our job to clean this structure up.
+	 */
+	if (!rts)
 		ieee80211_tx_status(rt2x00dev->hw,
 			entry->skb, &entry->tx_status);
+	else
+		dev_kfree_skb(entry->skb);
 
 	rt2x00_set_field32(&word, TXD_W0_VALID, 0);
 	rt2x00_desc_write(txd, 0, word);
@@ -2433,7 +2441,7 @@
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
 	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
-	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
+	    !is_rts_frame(frame_control)) {
 		skb_rts = rt61pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
 		if (!skb_rts) {
@@ -2463,8 +2471,7 @@
 	memcpy(rt2x00_data_addr(entry), skb->data, skb->len);
 	rt61pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
-	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
+	if (is_rts_frame(frame_control))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff -rU3 wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:11:59.000000000 +0100
+++ wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:23:22.000000000 +0100
@@ -2001,6 +2001,7 @@
 	u32 word;
 	int ack;
 	int ring_full;
+	int rts;
 
 	/*
 	 * Store the current status of the ring.
@@ -2034,9 +2035,16 @@
 		rt2x00_bbp_read(rt2x00dev, 32,
 			(u8*)&entry->tx_status.ack_signal);
 
-		if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
+		/*
+		 * If this is not an RTS frame send the tx_status to d80211,
+		 * that method also cleans up the skb structure. When this
+		 * is a RTS frame, that it is our job to clean this structure up.
+		 */
+		if (!rts)
 			ieee80211_tx_status(rt2x00dev->hw,
 				entry->skb, &entry->tx_status);
+		else
+			dev_kfree_skb(entry->skb);
 
 		CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 		entry->skb = NULL;
@@ -2123,7 +2131,7 @@
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
 	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
-	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
+	    !is_rts_frame(frame_control)) {
 		skb_rts = rt73usb_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
 		if (!skb_rts) {
@@ -2152,8 +2160,7 @@
 	memcpy(rt2x00_data_addr(entry), skb->data, skb->len);
 	rt73usb_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
-	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
+	if (is_rts_frame(frame_control))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
