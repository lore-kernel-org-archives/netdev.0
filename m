From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 16/24] RT2x00: Fix rt61pci interrupt handling
Date: Wed, 26 Jul 2006 20:29:30 +0200
Message-ID: <200607262029.30542.IvDoorn@gmail.com>
References: <200607261905.36712.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:2063 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161015AbWGZS3m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 14:29:42 -0400
Received: by nf-out-0910.google.com with SMTP id o25so839729nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 11:29:41 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200607261905.36712.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

rt61pci irq is a bit different compared to the others,
when the irq is raised, we should read from the register which
ring and which entry has been send. And this entry should
be processed. Using a for loop to go through all entries
is no longer working since we require certain statistics
from the registers.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -rU3 wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt61irq/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-25 14:55:25.000000000 +0200
+++ wireless-dev-rt61irq/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-25 16:13:19.000000000 +0200
@@ -1473,72 +1473,119 @@
 	rt61pci_activity_led(rt2x00dev, total_rssi);
 }
 
-static void rt61pci_txdone(void *data)
+static void rt61pci_txdone_entry(struct data_entry *entry, u32 sta_csr4)
 {
-	struct data_ring *ring = data;
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
-	struct data_entry *entry;
+	struct rt2x00_dev *rt2x00dev =
+		ieee80211_dev_hw_data(entry->ring->net_dev);
 	struct txd *txd;
 	int tx_status;
 	int ack;
-	int reg;
 	int ring_full;
 
+	txd = rt2x00pci_desc_addr(entry);
+
+	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC) ||
+	    !rt2x00_get_field32(txd->word0, TXD_W0_VALID))
+		return;
+
+	ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
+
 	/*
-	 * Store the current status of the ring.
+	 * TODO: How can te below field be set correctly?
 	 */
-	ring_full = rt2x00_ring_full(ring);
+	entry->tx_status.tx_filtered = 0;
 
-	while (!rt2x00_ring_empty(ring)) {
-		entry = rt2x00_get_data_entry_done(ring);
-		txd = rt2x00pci_desc_addr(entry);
+	entry->tx_status.queue_length = entry->ring->stats.limit;
 
-		rt2x00_register_read(rt2x00dev, STA_CSR4, &reg);
+	/*
+	 * The TXD_W0_RESULT field will only be set when
+	 * we had requested an ACK. So we have received an
+	 * ACK response when ACK was requested and status
+	 * was succesfull.
+	 */
+	tx_status = rt2x00_get_field32(sta_csr4, STA_CSR4_TX_RESULT);
+	entry->tx_status.ack = 0;
+	if (ack && (tx_status == TX_SUCCESS ||
+	    tx_status == TX_SUCCESS_RETRY))
+		entry->tx_status.ack = 1;
+	else if (ack && tx_status == TX_FAIL_RETRY) {
+		rt2x00dev->low_level_stats.dot11ACKFailureCount++;
+		entry->tx_status.excessive_retries++;
+	}
 
-		if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC) ||
-		    !rt2x00_get_field32(txd->word0, TXD_W0_VALID) ||
-		    !rt2x00_get_field32(reg, STA_CSR4_VALID))
-			break;
+	rt2x00_bbp_read(rt2x00dev, 32,
+		(u8*)&entry->tx_status.ack_signal);
 
-		ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
+	entry->tx_status.retry_count = rt2x00_get_field32(
+		sta_csr4, STA_CSR4_RETRY_COUNT);
 
-		/*
-		 * TODO: How can te below field be set correctly?
-		 */
-		entry->tx_status.tx_filtered = 0;
+	if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
+		ieee80211_tx_status(entry->ring->net_dev,
+			entry->skb, &entry->tx_status);
 
-		entry->tx_status.queue_length = ring->stats.limit;
+	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
+	entry->skb = NULL;
 
-		/*
-		 * The TXD_W0_RESULT field will only be set when
-		 * we had requested an ACK. So we have received an
-		 * ACK response when ACK was requested and status
-		 * was succesfull.
-		 */
-		tx_status = rt2x00_get_field32(reg, STA_CSR4_TX_RESULT);
-		entry->tx_status.ack = 0;
-		if (ack && (tx_status == TX_SUCCESS ||
-		    tx_status == TX_SUCCESS_RETRY))
-			entry->tx_status.ack = 1;
-		else if (ack && tx_status == TX_FAIL_RETRY) {
-			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries++;
-		}
+	/*
+	 * Store the current status of the ring.
+	 */
+	ring_full = rt2x00_ring_full(entry->ring);
 
-		rt2x00_bbp_read(rt2x00dev, 32,
-			(u8*)&entry->tx_status.ack_signal);
+	rt2x00_ring_index_done_inc(entry->ring);
 
-		entry->tx_status.retry_count = rt2x00_get_field32(
-			reg, STA_CSR4_RETRY_COUNT);
+	/*
+	 * If the data ring was full before the txdone handler
+	 * we must make sure the packet queue in the d80211 stack
+	 * is reenabled when the txdone handler has finished.
+	 */
+	if (ring_full && !rt2x00_ring_full(entry->ring))
+		ieee80211_wake_queue(entry->ring->net_dev,
+			entry->tx_status.control.queue);
+}
 
-		if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
-			ieee80211_tx_status(ring->net_dev,
-				entry->skb, &entry->tx_status);
+static void rt61pci_txdone(void *data)
+{
+	struct data_ring *ring = data;
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
+	int index;
+	int reg;
 
-		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
-		entry->skb = NULL;
+	/*
+	 * Keep looping while STA_CSR4 contains value data.
+	 * at each read the value will be reset to a new value,
+	 * which we should check since it contains the ring
+	 * and index number of the entry which has been
+	 * completely transmitted.
+	 */
+	while (1) {
+		/*
+		 * Stop looping when the entry is invalid.
+		 */
+		rt2x00_register_read(rt2x00dev, STA_CSR4, &reg);
+		if (!rt2x00_get_field32(reg, STA_CSR4_VALID))
+			break;
 
-		rt2x00_ring_index_done_inc(ring);
+		/*
+		 * Skip this entry when it contains an invalid
+		 * ring identication number.
+		 */
+		ring = rt2x00_get_ring(rt2x00dev,
+			rt2x00_get_field32(reg, STA_CSR4_PID_TYPE));
+		if (unlikely(!ring))
+			continue;
+
+		/*
+		 * Skip this entry when it contains an invalid
+		 * index number.
+		 */
+		index = rt2x00_get_field32(reg, STA_CSR4_PID_SUBTYPE);
+		if (unlikely(index >= ring->stats.limit))
+			continue;
+
+		/*
+		 * Packet received correctly, we can now process it.
+		 */
+		rt61pci_txdone_entry(&ring->entry[index], reg);
 	}
 
 	/*
@@ -1554,16 +1601,6 @@
 		rt2x00dev->scan->status = SCANNING_READY;
 		complete(&rt2x00dev->scan->completion);
 	}
-
-	/*
-	 * If the data ring was full before the txdone handler
-	 * we must make sure the packet queue in the d80211 stack
-	 * is reenabled when the txdone handler has finished.
-	 */
-	entry = ring->entry;
-	if (ring_full && !rt2x00_ring_full(ring))
-		ieee80211_wake_queue(ring->net_dev,
-			entry->tx_status.control.queue);
 }
 
 static irqreturn_t rt61pci_interrupt(int irq, void *dev_instance,
@@ -1966,6 +2003,8 @@
 		rt2x00_set_field32(&txd->word1, TXD_W1_BUFFER_COUNT, 1);
 		rt2x00_set_field32(&txd->word6, TXD_W6_BUFFER_PHYSICAL_ADDRESS,
 			ring->entry[i].data_dma);
+		rt2x00_set_field32(&txd->word5, TXD_W5_PID_TYPE, ring->type);
+		rt2x00_set_field32(&txd->word5, TXD_W5_PID_SUBTYPE, i);
 	}
 
 	rt2x00_ring_index_clear(ring);
diff -rU3 wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-rt61irq/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-25 10:09:44.000000000 +0200
+++ wireless-dev-rt61irq/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-25 16:10:20.000000000 +0200
@@ -633,8 +633,8 @@
 #define STA_CSR4_VALID			FIELD32(0x00000001)
 #define STA_CSR4_TX_RESULT		FIELD32(0x0000000e)
 #define STA_CSR4_RETRY_COUNT		FIELD32(0x000000f0)
-#define STA_CSR4_PID_SUBTYPE		FIELD32(0x00003f00)
-#define STA_CSR4_PID_TYPE		FIELD32(0x0000c000)
+#define STA_CSR4_PID_SUBTYPE		FIELD32(0x00001f00)
+#define STA_CSR4_PID_TYPE		FIELD32(0x0000e000)
 #define STA_CSR4_TXRATE			FIELD32(0x000f0000)
 
 /*
@@ -1172,13 +1172,15 @@
 /*
  * WORD5
  * FRAME_OFFSET: Frame start offset inside ASIC TXFIFO (after TXINFO field).
- * PACKET_ID: Driver assigned packet ID to categorize TXResult in interrupt.
+ * TXD_W5_PID_SUBTYPE: Driver assigned packet ID index for txdone handler.
+ * TXD_W5_PID_TYPE: Driver assigned packet ID type for txdone handler.
  * WAITING_DMA_DONE_INT: TXD been filled with data
  * and waiting for TxDoneISR housekeeping.
  */
 	__le32 word5;
 #define TXD_W5_FRAME_OFFSET		FIELD32(0x000000ff)
-#define TXD_W5_PACKET_ID		FIELD32(0x0000ff00)
+#define TXD_W5_PID_SUBTYPE		FIELD32(0x00001f00)
+#define TXD_W5_PID_TYPE			FIELD32(0x0000e000)
 #define TXD_W5_TX_POWER			FIELD32(0x00ff0000)
 #define TXD_W5_WAITING_DMA_DONE_INT	FIELD32(0x01000000)
 
