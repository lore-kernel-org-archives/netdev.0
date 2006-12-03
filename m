From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 14/26] rt2x00: Add more statistics readin
Date: Sun, 3 Dec 2006 19:19:01 +0100
Message-ID: <200612031919.01412.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:18521 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758820AbWLCST2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:28 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144331nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:27 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure all statistics the d80211 stack requires.
Some of this requires values to be read during
interrupt process (add a new function to handle this).
And other fields can be read from the registers at
request time.
Note that rt61pci and rt73usb had an invalid registername
the legacy drivers are suggesting the CRC_ERROR count is
actually the FCS_ERROR count.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 13:49:47.000000000 +0100
+++ wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 14:03:05.000000000 +0100
@@ -1624,14 +1624,7 @@
 		    !rt2x00_get_field32(word, TXD_W0_VALID))
 			break;
 
-		ack = rt2x00_get_field32(word, TXD_W0_ACK);
-
-		entry->tx_status.flags  = 0;
-		/*
-		 * TODO: How can bit IEEE80211_TX_STATUS_TX_FILTERED of
-		 * entry->tx_status.flags be set correctly?
-		 */
-
+		entry->tx_status.flags = 0;
 		entry->tx_status.queue_length = ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
@@ -1641,15 +1634,11 @@
 		 * ACK response when ACK was requested and status
 		 * was succesfull.
 		 */
+		ack = rt2x00_get_field32(word, TXD_W0_ACK);
+		rts = GET_FLAG(entry, ENTRY_RTS_FRAME);
 		tx_status = rt2x00_get_field32(word, TXD_W0_RESULT);
-		entry->tx_status.excessive_retries = 0;
-		if (ack && (tx_status == TX_SUCCESS ||
-		    tx_status == TX_SUCCESS_RETRY))
-			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
-		else if (ack && tx_status == TX_FAIL_RETRY) {
-			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries = 1;
-		}
+		rt2x00_update_tx_stats(rt2x00dev, &entry->tx_status, tx_status,
+			ack, rts);
 
 		rt2x00_bbp_read(rt2x00dev, 32,
 			(u8*)&entry->tx_status.ack_signal);
@@ -2183,10 +2172,8 @@
 
 	/*
 	 * Update FCS error count from register.
-	 * The dot11ACKFailureCount is updated in interrupt time.
-	 * TODO: dot11RTSFailureCount and dot11RTSSuccessCount
-	 * are never updated, we need to find a method to see
-	 * where we can update those statistics from.
+	 * The dot11ACKFailureCount, dot11RTSFailureCount and
+	 * dot11RTSSuccessCount are updated in interrupt time.
 	 */
 	rt2x00_register_read(rt2x00dev, CNT0, &reg);
 	rt2x00dev->low_level_stats.dot11FCSErrorCount +=
diff -rU3 wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 13:52:24.000000000 +0100
+++ wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 14:00:23.000000000 +0100
@@ -1787,14 +1787,7 @@
 		    !rt2x00_get_field32(word, TXD_W0_VALID))
 			break;
 
-		ack = rt2x00_get_field32(word, TXD_W0_ACK);
-
 		entry->tx_status.flags = 0;
-		/*
-		 * TODO: How can the IEEE80211_TX_STATUS_TX_FILTERED bit of
-		 * entry->tx_status.flags be set correctly?
-		 */
-
 		entry->tx_status.queue_length = ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
@@ -1804,15 +1797,11 @@
 		 * ACK response when ACK was requested and status
 		 * was succesfull.
 		 */
+		ack = rt2x00_get_field32(word, TXD_W0_ACK);
+		rts = GET_FLAG(entry, ENTRY_RTS_FRAME);
 		tx_status = rt2x00_get_field32(word, TXD_W0_RESULT);
-		entry->tx_status.excessive_retries = 0;
-		if (ack && (tx_status == TX_SUCCESS ||
-		    tx_status == TX_SUCCESS_RETRY))
-			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
-		else if (ack && tx_status == TX_FAIL_RETRY) {
-			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries = 1;
-		}
+		rt2x00_update_tx_stats(rt2x00dev, &entry->tx_status, tx_status,
+			ack, rts);
 
 		rt2x00_bbp_read(rt2x00dev, 32,
 			(u8*)&entry->tx_status.ack_signal);
@@ -2342,10 +2331,8 @@
 
 	/*
 	 * Update FCS error count from register.
-	 * The dot11ACKFailureCount is updated in interrupt time.
-	 * TODO: dot11RTSFailureCount and dot11RTSSuccessCount
-	 * are never updated, we need to find a method to see
-	 * where we can update those statistics from.
+	 * The dot11ACKFailureCount, dot11RTSFailureCount and
+	 * dot11RTSSuccessCount are updated in interrupt time.
 	 */
 	rt2x00_register_read(rt2x00dev, CNT0, &reg);
 	rt2x00dev->low_level_stats.dot11FCSErrorCount +=
diff -rU3 wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 13:52:23.000000000 +0100
+++ wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:00:12.000000000 +0100
@@ -1744,14 +1744,7 @@
 		if (GET_FLAG(entry, ENTRY_OWNER_NIC))
 			break;
 
-		ack = rt2x00_get_field32(word, TXD_W0_ACK);
-
 		entry->tx_status.flags = 0;
-		/*
-		 * TODO: How can bit IEEE80211_TX_STATUS_TX_FILTERED of
-		 * entry->tx_status.flags be set correctly?
-		 */
-
 		entry->tx_status.queue_length = entry->ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
@@ -1760,13 +1753,11 @@
 		 * ACK response when ACK was requested and status
 		 * was succesfull.
 		 */
-		entry->tx_status.excessive_retries = 0;
-		if (ack && (urb->status == TX_SUCCESS))
-			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
-		else if (ack && urb->status == TX_FAIL_OTHER) {
-			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries = 1;
-		}
+		ack = rt2x00_get_field32(word, TXD_W0_ACK);
+		rts = GET_FLAG(entry, ENTRY_RTS_FRAME);
+		tx_status = !urb->status ? TX_SUCCESS : TX_FAIL_RETRY;
+		rt2x00_update_tx_stats(rt2x00dev, &entry->tx_status, tx_status,
+			ack, rts);
 
 		rt2x00_bbp_read(rt2x00dev, 0,
 			(u8*)&entry->tx_status.ack_signal);
@@ -2241,10 +2232,8 @@
 
 	/*
 	 * Update FCS error count from register.
-	 * The dot11ACKFailureCount is updated in interrupt time.
-	 * TODO: dot11RTSFailureCount and dot11RTSSuccessCount
-	 * are never updated, we need to find a method to see
-	 * where we can update those statistics from.
+	 * The dot11ACKFailureCount, dot11RTSFailureCount and
+	 * dot11RTSSuccessCount are updated in interrupt time.
 	 */
 	rt2x00_register_read(rt2x00dev, STA_CSR0, &reg);
 	rt2x00dev->low_level_stats.dot11FCSErrorCount +=
diff -rU3 wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 13:48:57.000000000 +0100
+++ wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 13:55:51.000000000 +0100
@@ -1040,6 +1040,26 @@
 	return NULL;
 }
 
+static inline void rt2x00_update_tx_stats(struct rt2x00_dev *rt2x00dev,
+	struct ieee80211_tx_status *tx_status, const int status,
+	const int is_ack, const int is_rts)
+{
+	struct ieee80211_low_level_stats *stats = &rt2x00dev->low_level_stats;
+
+	if (is_ack)
+		tx_status->flags |= IEEE80211_TX_STATUS_ACK;
+	tx_status->excessive_retries = (status == TX_FAIL_RETRY);
+
+	if (!is_ack && status == TX_FAIL_RETRY)
+		stats->dot11ACKFailureCount++;
+
+	if (is_rts) {
+		if (status == TX_SUCCESS || status == TX_SUCCESS_RETRY)
+			stats->dot11RTSSuccessCount++;
+		else
+			stats->dot11RTSFailureCount++;
+	}
+}
 /*
  * Device specific rate value.
  * We will have to create the device specific rate value
diff -rU3 wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 13:52:24.000000000 +0100
+++ wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 14:00:36.000000000 +0100
@@ -2238,11 +2238,6 @@
 	ack = rt2x00_get_field32(word, TXD_W0_ACK);
 
 	entry->tx_status.flags = 0;
-	/*
-	 * TODO: How can the IEEE80211_TX_STATUS_TX_FILTERED bit of
-	 * entry->tx_status.flags be set correctly?
-	 */
-
 	entry->tx_status.queue_length = entry->ring->stats.limit;
 	entry->tx_status.queue_number = entry->tx_status.control.queue;
 
@@ -2252,15 +2247,11 @@
 	 * ACK response when ACK was requested and status
 	 * was succesfull.
 	 */
+	ack = rt2x00_get_field32(word, TXD_W0_ACK);
+	rts = GET_FLAG(entry, ENTRY_RTS_FRAME);
 	tx_status = rt2x00_get_field32(sta_csr4, STA_CSR4_TX_RESULT);
-	entry->tx_status.excessive_retries = 0;
-	if (ack && (tx_status == TX_SUCCESS ||
-	    tx_status == TX_SUCCESS_RETRY))
-		entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
-	else if (ack && tx_status == TX_FAIL_RETRY) {
-		rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-		entry->tx_status.excessive_retries = 1;
-	}
+	rt2x00_update_tx_stats(rt2x00dev, &entry->tx_status, tx_status,
+		ack, rts);
 
 	rt2x00_bbp_read(rt2x00dev, 32,
 		(u8*)&entry->tx_status.ack_signal);
@@ -2825,14 +2816,17 @@
 	struct ieee80211_low_level_stats *stats)
 {
 	struct rt2x00_dev *rt2x00dev = hw->priv;
+	u32 reg;
 
 	/*
-	 * The dot11ACKFailureCount is updated in interrupt time.
-	 * TODO: dot11FCSErrorCount, dot11RTSFailureCount and
-	 * dot11RTSSuccessCount are never updated,
-	 * we need to find a method to see where we can update
-	 * those statistics from.
-	 */
+	 * Update FCS error count from register.
+	 * The dot11ACKFailureCount, dot11RTSFailureCount and
+	 * dot11RTSSuccessCount are updated in interrupt time.
+	 */
+	rt2x00_register_read(rt2x00dev, STA_CSR0, &reg);
+	rt2x00dev->low_level_stats.dot11FCSErrorCount +=
+		rt2x00_get_field32(reg, STA_CSR0_FCS_ERROR);
+
 	memcpy(stats, &rt2x00dev->low_level_stats, sizeof(*stats));
 
 	return 0;
diff -rU3 wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-12-03 13:04:29.000000000 +0100
+++ wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-12-03 14:01:38.000000000 +0100
@@ -604,10 +604,10 @@
  */
 
 /*
- * STA_CSR0: RX PLCP error count & RX CRC error count.
+ * STA_CSR0: RX PLCP error count & RX FCS error count.
  */
 #define STA_CSR0			0x30c0
-#define STA_CSR0_CRC_ERROR		FIELD32(0x0000ffff)
+#define STA_CSR0_FCS_ERROR		FIELD32(0x0000ffff)
 #define STA_CSR0_PLCP_ERROR		FIELD32(0xffff0000)
 
 /*
diff -rU3 wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 13:52:23.000000000 +0100
+++ wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:00:46.000000000 +0100
@@ -2025,14 +2025,7 @@
 		if (GET_FLAG(entry, ENTRY_OWNER_NIC))
 			break;
 
-		ack = rt2x00_get_field32(word, TXD_W0_ACK);
-
 		entry->tx_status.flags = 0;
-		/*
-		 * TODO: How can bit IEEE80211_TX_STATUS_TX_FILTERED of
-		 * entry->tx_status.flags be set correctly?
-		 */
-
 		entry->tx_status.queue_length = entry->ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
@@ -2041,13 +2034,11 @@
 		 * ACK response when ACK was requested and status
 		 * was succesfull.
 		 */
-		entry->tx_status.excessive_retries = 0;
-		if (ack && (urb->status == TX_SUCCESS))
-			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
-		else {
-			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries = 1;
-		}
+		ack = rt2x00_get_field32(word, TXD_W0_ACK);
+		rts = GET_FLAG(entry, ENTRY_RTS_FRAME);
+		tx_status = !urb->status ? TX_SUCCESS : TX_FAIL_RETRY;
+		rt2x00_update_tx_stats(rt2x00dev, &entry->tx_status, tx_status,
+			ack, rts);
 
 		rt2x00_bbp_read(rt2x00dev, 32,
 			(u8*)&entry->tx_status.ack_signal);
@@ -2517,14 +2508,17 @@
 	struct ieee80211_low_level_stats *stats)
 {
 	struct rt2x00_dev *rt2x00dev = hw->priv;
+	u32 reg;
 
 	/*
-	 * The dot11ACKFailureCount is updated in interrupt time.
-	 * TODO: dot11FCSErrorCount, dot11RTSFailureCount and
-	 * dot11RTSSuccessCount are never updated,
-	 * we need to find a method to see where we can update
-	 * those statistics from.
-	 */
+	 * Update FCS error count from register.
+	 * The dot11ACKFailureCount, dot11RTSFailureCount and
+	 * dot11RTSSuccessCount are updated in interrupt time.
+	 */
+	rt2x00_register_read(rt2x00dev, STA_CSR0, &reg);
+	rt2x00dev->low_level_stats.dot11FCSErrorCount +=
+		rt2x00_get_field32(reg, STA_CSR0_FCS_ERROR);
+
 	memcpy(stats, &rt2x00dev->low_level_stats, sizeof(*stats));
 
 	return 0;
diff -rU3 wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt73usb.h wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-12-03 13:04:31.000000000 +0100
+++ wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-12-03 14:01:58.000000000 +0100
@@ -504,10 +504,10 @@
  */
 
 /*
- * STA_CSR0: RX PLCP error count & RX CRC error count.
+ * STA_CSR0: RX PLCP error count & RX FCS error count.
  */
 #define STA_CSR0			0x30c0
-#define STA_CSR0_CRC_ERROR		FIELD32(0x0000ffff)
+#define STA_CSR0_FCS_ERROR		FIELD32(0x0000ffff)
 #define STA_CSR0_PLCP_ERROR		FIELD32(0xffff0000)
 
 /*
