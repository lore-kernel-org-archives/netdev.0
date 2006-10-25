From: David Kimdon <david.kimdon@devicescape.com>
Subject: [take3 2/5] d80211: remove bitfields from ieee80211_tx_status
Date: Wed, 25 Oct 2006 11:42:53 -0700
Message-ID: <20061025184253.GC30046@devicescape.com>
References: <20061025184235.502701000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:16285 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S932432AbWJYSmy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 14:42:54 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="tx_status_bitfields.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both one-bit bitfields have been subsumed into the new 'flags'
structure member and the new IEEE80211_TX_STATUS_* definitions. 

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
@@ -209,8 +209,10 @@ struct ieee80211_tx_status {
 	/* copied ieee80211_tx_control structure */
 	struct ieee80211_tx_control control;
 
-	unsigned int tx_filtered:1;
-	unsigned int ack:1; /* whether the TX frame was ACKed */
+#define IEEE80211_TX_STATUS_TX_FILTERED	(1<<0)
+#define IEEE80211_TX_STATUS_ACK		(1<<1) /* whether the TX frame was ACKed */
+	u32 flags;		/* tx staus flags defined above */
+
 	int ack_signal; /* measured signal strength of the ACK frame */
 	int excessive_retries;
 	int retry_count;
Index: wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -426,12 +426,14 @@ static void adm8211_interrupt_tci(struct
 
 		if (status & TDES0_STATUS_ES) {
 			stats->tx_errors++;
-			priv->tx_buffers[entry].tx_status.ack = 0;
+			priv->tx_buffers[entry].tx_status.flags &=
+						~IEEE80211_TX_STATUS_ACK;
 
 			if (status & (TDES0_STATUS_TUF | TDES0_STATUS_TRO))
 				stats->tx_fifo_errors++;
 		} else
-			priv->tx_buffers[entry].tx_status.ack = 1;
+			priv->tx_buffers[entry].tx_status.flags |=
+						IEEE80211_TX_STATUS_ACK;
 
 		pci_unmap_single(priv->pdev, priv->tx_buffers[entry].mapping,
 				 priv->tx_buffers[entry].skb->len, PCI_DMA_TODEVICE);
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
@@ -1122,7 +1122,8 @@ void bcm43xx_dma_handle_txstatus(struct 
 			 * status of the transmission.
 			 * Some fields of txstat are already filled in dma_tx().
 			 */
-			meta->txstat.ack = status->acked;
+			if (status->acked)
+				meta->txstat.flags |= IEEE80211_TX_STATUS_ACK;
 			meta->txstat.retry_count = status->frame_count - 1;
 			ieee80211_tx_status_irqsafe(bcm->net_dev, meta->skb, &(meta->txstat));
 			/* skb is freed by ieee80211_tx_status_irqsafe() */
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
@@ -500,7 +500,8 @@ void bcm43xx_pio_handle_txstatus(struct 
 	queue->tx_devq_packets--;
 	queue->tx_devq_used -= (packet->skb->len + phy->txhdr_size);
 
-	packet->txstat.ack = status->acked;
+	if (status->acked)
+		packet->txstat.flags |= IEEE80211_TX_STATUS_ACK;
 	packet->txstat.retry_count = status->frame_count - 1;
 	ieee80211_tx_status_irqsafe(bcm->net_dev, packet->skb,
 				    &(packet->txstat));
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1741,10 +1741,11 @@ static void rt2400pci_txdone(void *data)
 
 		ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 
+		entry->tx_status.flags  = 0;
 		/*
-		 * TODO: How can te below field be set correctly?
+		 * TODO: How can bit IEEE80211_TX_STATUS_TX_FILTERED of
+		 * entry->tx_status.flags be set correctly?
 		 */
-		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
@@ -1756,11 +1757,10 @@ static void rt2400pci_txdone(void *data)
 		 * was succesfull.
 		 */
 		tx_status = rt2x00_get_field32(txd->word0, TXD_W0_RESULT);
-		entry->tx_status.ack = 0;
 		entry->tx_status.excessive_retries = 0;
 		if (ack && (tx_status == TX_SUCCESS ||
 		    tx_status == TX_SUCCESS_RETRY))
-			entry->tx_status.ack = 1;
+			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
 		else if (ack && tx_status == TX_FAIL_RETRY) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
 			entry->tx_status.excessive_retries = 1;
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1890,10 +1890,11 @@ static void rt2500pci_txdone(void *data)
 
 		ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 
+		entry->tx_status.flags = 0;
 		/*
-		 * TODO: How can te below field be set correctly?
+		 * TODO: How can the IEEE80211_TX_STATUS_TX_FILTERED bit of
+		 * entry->tx_status.flags be set correctly?
 		 */
-		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
@@ -1905,11 +1906,10 @@ static void rt2500pci_txdone(void *data)
 		 * was succesfull.
 		 */
 		tx_status = rt2x00_get_field32(txd->word0, TXD_W0_RESULT);
-		entry->tx_status.ack = 0;
 		entry->tx_status.excessive_retries = 0;
 		if (ack && (tx_status == TX_SUCCESS ||
 		    tx_status == TX_SUCCESS_RETRY))
-			entry->tx_status.ack = 1;
+			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
 		else if (ack && tx_status == TX_FAIL_RETRY) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
 			entry->tx_status.excessive_retries = 1;
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -4044,13 +4044,13 @@ void ieee80211_tx_status(struct net_devi
 				 * that this TX packet failed because of that.
 				 */
 				status->excessive_retries = 0;
-				status->tx_filtered = 1;
+				status->flags |= IEEE80211_TX_STATUS_TX_FILTERED;
 			}
 			sta_info_put(sta);
 		}
 	}
 
-	if (status->tx_filtered) {
+	if (status->flags & IEEE80211_TX_STATUS_TX_FILTERED) {
 		struct sta_info *sta;
 		sta = sta_info_get(local, hdr->addr1);
 		if (sta) {
@@ -4112,7 +4112,7 @@ void ieee80211_tx_status(struct net_devi
 	frag = le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_FRAG;
 	type = le16_to_cpu(hdr->frame_control) & IEEE80211_FCTL_FTYPE;
 
-        if (status->ack) {
+        if (status->flags & IEEE80211_TX_STATUS_ACK) {
 		if (frag == 0) {
 			local->dot11TransmittedFrameCount++;
 			if (is_multicast_ether_addr(hdr->addr1))
@@ -4141,8 +4141,8 @@ void ieee80211_tx_status(struct net_devi
 		return;
 	}
 
-	msg_type = status->ack ? ieee80211_msg_tx_callback_ack :
-		ieee80211_msg_tx_callback_fail;
+	msg_type = (status->flags & IEEE80211_TX_STATUS_ACK) ?
+	       	ieee80211_msg_tx_callback_ack : ieee80211_msg_tx_callback_fail;
 
 	/* skb was the original skb used for TX. Clone it and give the clone
 	 * to netif_rx(). Free original skb. */
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -2326,10 +2326,11 @@ static void rt61pci_txdone_entry(struct 
 
 	ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 
+	entry->tx_status.flags = 0;
 	/*
-	 * TODO: How can te below field be set correctly?
+	 * TODO: How can the IEEE80211_TX_STATUS_TX_FILTERED bit of
+	 * entry->tx_status.flags be set correctly?
 	 */
-	entry->tx_status.tx_filtered = 0;
 
 	entry->tx_status.queue_length = entry->ring->stats.limit;
 	entry->tx_status.queue_number = entry->tx_status.control.queue;
@@ -2341,11 +2342,10 @@ static void rt61pci_txdone_entry(struct 
 	 * was succesfull.
 	 */
 	tx_status = rt2x00_get_field32(sta_csr4, STA_CSR4_TX_RESULT);
-	entry->tx_status.ack = 0;
 	entry->tx_status.excessive_retries = 0;
 	if (ack && (tx_status == TX_SUCCESS ||
 	    tx_status == TX_SUCCESS_RETRY))
-		entry->tx_status.ack = 1;
+		entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
 	else if (ack && tx_status == TX_FAIL_RETRY) {
 		rt2x00dev->low_level_stats.dot11ACKFailureCount++;
 		entry->tx_status.excessive_retries = 1;
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -1678,10 +1678,11 @@ static void rt2500usb_txdone(void *data)
 
 		ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 
+		entry->tx_status.flags = 0;
 		/*
-		 * TODO: How can te below field be set correctly?
+		 * TODO: How can bit IEEE80211_TX_STATUS_TX_FILTERED of
+		 * entry->tx_status.flags be set correctly?
 		 */
-		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = entry->ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
@@ -1691,10 +1692,9 @@ static void rt2500usb_txdone(void *data)
 		 * ACK response when ACK was requested and status
 		 * was succesfull.
 		 */
-		entry->tx_status.ack = 0;
 		entry->tx_status.excessive_retries = 0;
 		if (ack && (urb->status == TX_SUCCESS))
-			entry->tx_status.ack = 1;
+			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
 		else if (ack && urb->status == TX_FAIL_OTHER) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
 			entry->tx_status.excessive_retries = 1;
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -1968,10 +1968,11 @@ static void rt73usb_txdone(void *data)
 
 		ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 
+		entry->tx_status.flags = 0;
 		/*
-		 * TODO: How can te below field be set correctly?
+		 * TODO: How can bit IEEE80211_TX_STATUS_TX_FILTERED of
+		 * entry->tx_status.flags be set correctly?
 		 */
-		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = entry->ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
@@ -1981,10 +1982,9 @@ static void rt73usb_txdone(void *data)
 		 * ACK response when ACK was requested and status
 		 * was succesfull.
 		 */
-		entry->tx_status.ack = 0;
 		entry->tx_status.excessive_retries = 0;
 		if (ack && (urb->status == TX_SUCCESS))
-			entry->tx_status.ack = 1;
+			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
 		else {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
 			entry->tx_status.excessive_retries = 1;

--
