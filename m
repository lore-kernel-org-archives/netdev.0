From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 9/10] rt2x00: TXD/RTS fixes
Date: Sun, 27 Aug 2006 17:39:15 +0200
Message-ID: <200608271739.15996.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46123 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932140AbWH0Pj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 11:39:28 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1091661nfa
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 08:39:27 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes several issues with TXD and RTS control.

excessive_retries is not a counter and should be set to
either 1 or 0. Otherwise all folluw up frames will be marked
as excessive retry...

ENTRY_RTS_FRAME should be cleared when frame has been send,
otherwise the next frame for this txd will also be marked as RTS.

Checking for only IEEE80211_STYPE_RTS is bad since it is the same
value as a AUTH frame and possible other fields as well.
The correct check is to check for a CTL frame with the RTS flag set.

Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:56:28.000000000 +0200
+++ wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:59:44.000000000 +0200
@@ -1767,6 +1767,7 @@
 		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = ring->stats.limit;
+		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
 		/*
 		 * The TXD_W0_RESULT field will only be set when
@@ -1776,12 +1777,13 @@
 		 */
 		tx_status = rt2x00_get_field32(txd->word0, TXD_W0_RESULT);
 		entry->tx_status.ack = 0;
+		entry->tx_status.excessive_retries = 0;
 		if (ack && (tx_status == TX_SUCCESS ||
 		    tx_status == TX_SUCCESS_RETRY))
 			entry->tx_status.ack = 1;
 		else if (ack && tx_status == TX_FAIL_RETRY) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries++;
+			entry->tx_status.excessive_retries = 1;
 		}
 
 		rt2x00_bbp_read(rt2x00dev, 32,
@@ -1795,6 +1797,7 @@
 				entry->skb, &entry->tx_status);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
+		CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 		entry->skb = NULL;
 
 		rt2x00_ring_index_done_inc(ring);
@@ -1961,7 +1964,8 @@
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
+	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
+	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff -rU3 wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:56:34.000000000 +0200
+++ wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 17:00:46.000000000 +0200
@@ -1916,6 +1916,7 @@
 		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = ring->stats.limit;
+		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
 		/*
 		 * The TXD_W0_RESULT field will only be set when
@@ -1925,12 +1926,13 @@
 		 */
 		tx_status = rt2x00_get_field32(txd->word0, TXD_W0_RESULT);
 		entry->tx_status.ack = 0;
+		entry->tx_status.excessive_retries = 0;
 		if (ack && (tx_status == TX_SUCCESS ||
 		    tx_status == TX_SUCCESS_RETRY))
 			entry->tx_status.ack = 1;
 		else if (ack && tx_status == TX_FAIL_RETRY) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries++;
+			entry->tx_status.excessive_retries = 1;
 		}
 
 		rt2x00_bbp_read(rt2x00dev, 32,
@@ -1944,6 +1946,7 @@
 				entry->skb, &entry->tx_status);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
+		CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 		entry->skb = NULL;
 
 		rt2x00_ring_index_done_inc(ring);
@@ -2110,7 +2113,8 @@
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
+	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
+	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff -rU3 wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:35:43.000000000 +0200
+++ wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 17:01:39.000000000 +0200
@@ -1683,6 +1683,7 @@
 		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = entry->ring->stats.limit;
+		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
 		/*
 		 * Check if we have received an
@@ -1690,11 +1691,12 @@
 		 * was succesfull.
 		 */
 		entry->tx_status.ack = 0;
+		entry->tx_status.excessive_retries = 0;
 		if (ack && (urb->status == TX_SUCCESS))
 			entry->tx_status.ack = 1;
 		else if (ack && urb->status == TX_FAIL_OTHER) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries++;
+			entry->tx_status.excessive_retries = 1;
 		}
 
 		rt2x00_bbp_read(rt2x00dev, 0,
@@ -1704,6 +1706,7 @@
 			ieee80211_tx_status(ring->net_dev,
 				entry->skb, &entry->tx_status);
 
+		CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 		entry->skb = NULL;
 
 		rt2x00_ring_index_done_inc(entry->ring);
@@ -1819,7 +1822,8 @@
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt2500usb_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
+	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
+	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff -rU3 wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:38:04.000000000 +0200
+++ wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 17:02:27.000000000 +0200
@@ -2352,6 +2352,7 @@
 	entry->tx_status.tx_filtered = 0;
 
 	entry->tx_status.queue_length = entry->ring->stats.limit;
+	entry->tx_status.queue_number = entry->tx_status.control.queue;
 
 	/*
 	 * The TXD_W0_RESULT field will only be set when
@@ -2361,12 +2362,13 @@
 	 */
 	tx_status = rt2x00_get_field32(sta_csr4, STA_CSR4_TX_RESULT);
 	entry->tx_status.ack = 0;
+	entry->tx_status.excessive_retries = 0;
 	if (ack && (tx_status == TX_SUCCESS ||
 	    tx_status == TX_SUCCESS_RETRY))
 		entry->tx_status.ack = 1;
 	else if (ack && tx_status == TX_FAIL_RETRY) {
 		rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-		entry->tx_status.excessive_retries++;
+		entry->tx_status.excessive_retries = 1;
 	}
 
 	rt2x00_bbp_read(rt2x00dev, 32,
@@ -2380,6 +2382,7 @@
 			entry->skb, &entry->tx_status);
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
+	CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = NULL;
 
 	/*
@@ -2581,7 +2584,8 @@
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt61pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
+	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
+	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff -rU3 wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 16:40:05.000000000 +0200
+++ wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 17:03:19.000000000 +0200
@@ -1973,6 +1973,7 @@
 		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = entry->ring->stats.limit;
+		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
 		/*
 		 * Check if we have received an
@@ -1980,11 +1981,12 @@
 		 * was succesfull.
 		 */
 		entry->tx_status.ack = 0;
+		entry->tx_status.excessive_retries = 0;
 		if (ack && (urb->status == TX_SUCCESS))
 			entry->tx_status.ack = 1;
 		else {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries++;
+			entry->tx_status.excessive_retries = 1;
 		}
 
 		rt2x00_bbp_read(rt2x00dev, 32,
@@ -1994,6 +1996,7 @@
 			ieee80211_tx_status(ring->net_dev,
 				entry->skb, &entry->tx_status);
 
+		CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 		entry->skb = NULL;
 
 		rt2x00_ring_index_done_inc(entry->ring);
@@ -2108,7 +2111,8 @@
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt73usb_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
+	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
+	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
