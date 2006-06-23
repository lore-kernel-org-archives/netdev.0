From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/3] rt2x00: per-queue TX flow control
Date: Fri, 23 Jun 2006 15:09:33 +0200 (CEST)
Message-ID: <20060623130933.8283D483AB@silver.suse.cz>
References: <20060623150913.986994000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:27606 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964810AbWFWNIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 09:08:11 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060623150913.986994000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivo van Doorn <ivdoorn@gmail.com>

Based on Jiri's patch for rt2x00 driver to do TX flow control.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index 8b856dd..946cf86 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1002,6 +1002,12 @@ rt2400pci_txdone(void *data)
 	struct txd		*txd;
 	int			tx_status;
 	int			ack;
+	int			ring_full;
+
+	/*
+	 * Store the current status of the ring.
+	 */
+	ring_full = rt2x00_ring_full(ring);
 
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
@@ -1062,6 +1068,16 @@ rt2400pci_txdone(void *data)
 		rt2x00pci->scan->status = SCANNING_READY;
 		complete(&rt2x00pci->scan->completion);
 	}
+
+	/*
+	 * If the data ring was full before the txdone handler
+	 * we must make sure the packet queue in the d80211 stack
+	 * is reenabled when the txdone handler has finished.
+	 */
+	entry = ring->entry;
+	if (ring_full && !rt2x00_ring_full(ring))
+		ieee80211_wake_queue(ring->net_dev,
+			entry->tx_status.control.queue);
 }
 
 static irqreturn_t
@@ -1541,18 +1557,26 @@ rt2400pci_tx(struct net_device *net_dev,
 		ERROR("Attempt to send packet over invalid queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
-		return NET_XMIT_DROP;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
 
-	if (rt2x00_ring_full(ring))
-		return NET_XMIT_DROP;
+	if (rt2x00_ring_full(ring)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	entry = rt2x00_get_data_entry(ring);
 	txd = entry->desc_addr;
 
 	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
-	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
-		return NET_XMIT_DROP;
+	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
+		ERROR("Arrived at non-free entry in the non-full queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00pci, txd, skb, control);
@@ -1560,6 +1584,9 @@ rt2400pci_tx(struct net_device *net_dev,
 
 	rt2x00_ring_index_inc(ring);
 
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
+
 	rt2x00_register_read(rt2x00pci, TXCSR0, &reg);
 	if (control->queue == IEEE80211_TX_QUEUE_DATA0)
 		rt2x00_set_field32(&reg, TXCSR0_KICK_PRIO, 1);
@@ -1569,7 +1596,7 @@ rt2400pci_tx(struct net_device *net_dev,
 		rt2x00_set_field32(&reg, TXCSR0_KICK_ATIM, 1);
 	rt2x00_register_write(rt2x00pci, TXCSR0, reg);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int
@@ -1669,6 +1696,8 @@ rt2400pci_open(struct net_device *net_de
 
 	SET_FLAG(rt2x00pci, RADIO_ENABLED);
 
+	ieee80211_start_queues(net_dev);
+
 	return 0;
 
 exit_fail:
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
index 6aeaf1a..ca0edd5 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1090,6 +1090,12 @@ rt2500pci_txdone(void *data)
 	struct txd		*txd;
 	int			tx_status;
 	int			ack;
+	int			ring_full;
+
+	/*
+	 * Store the current status of the ring.
+	 */
+	ring_full = rt2x00_ring_full(ring);
 
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
@@ -1150,6 +1156,16 @@ rt2500pci_txdone(void *data)
 		rt2x00pci->scan->status = SCANNING_READY;
 		complete(&rt2x00pci->scan->completion);
 	}
+
+	/*
+	 * If the data ring was full before the txdone handler
+	 * we must make sure the packet queue in the d80211 stack
+	 * is reenabled when the txdone handler has finished.
+	 */
+	entry = ring->entry;
+	if (ring_full && !rt2x00_ring_full(ring))
+		ieee80211_wake_queue(ring->net_dev,
+			entry->tx_status.control.queue);
 }
 
 static irqreturn_t
@@ -1664,18 +1680,26 @@ rt2500pci_tx(struct net_device *net_dev,
 		ERROR("Attempt to send packet over invalid queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
-		return NET_XMIT_DROP;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
 
-	if (rt2x00_ring_full(ring))
-		return NET_XMIT_DROP;
+	if (rt2x00_ring_full(ring)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	entry = rt2x00_get_data_entry(ring);
 	txd = entry->desc_addr;
 
 	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
-	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
-		return NET_XMIT_DROP;
+	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
+		ERROR("Arrived at non-free entry in the non-full queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00pci, txd, skb, control);
@@ -1683,6 +1707,9 @@ rt2500pci_tx(struct net_device *net_dev,
 
 	rt2x00_ring_index_inc(ring);
 
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
+
 	rt2x00_register_read(rt2x00pci, TXCSR0, &reg);
 	if (control->queue == IEEE80211_TX_QUEUE_DATA0)
 		rt2x00_set_field32(&reg, TXCSR0_KICK_PRIO, 1);
@@ -1692,7 +1719,7 @@ rt2500pci_tx(struct net_device *net_dev,
 		rt2x00_set_field32(&reg, TXCSR0_KICK_ATIM, 1);
 	rt2x00_register_write(rt2x00pci, TXCSR0, reg);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int
@@ -1792,6 +1819,8 @@ rt2500pci_open(struct net_device *net_de
 
 	SET_FLAG(rt2x00pci, RADIO_ENABLED);
 
+	ieee80211_start_queues(net_dev);
+
 	return 0;
 
 exit_fail:
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
index 1193e60..76c3a68 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -930,6 +930,12 @@ rt2500usb_txdone(void *data)
 	struct data_entry	*entry;
 	struct txd		*txd;
 	int			ack;
+	int			ring_full;
+
+	/*
+	 * Store the current status of the ring.
+	 */
+	ring_full = rt2x00_ring_full(ring);
 
 	 while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
@@ -982,6 +988,16 @@ rt2500usb_txdone(void *data)
 		rt2x00usb->scan->status = SCANNING_READY;
 		complete(&rt2x00usb->scan->completion);
 	}
+
+	/*
+	 * If the data ring was full before the txdone handler
+	 * we must make sure the packet queue in the d80211 stack
+	 * is reenabled when the txdone handler has finished.
+	 */
+	entry = ring->entry;
+	if (ring_full && !rt2x00_ring_full(ring))
+		ieee80211_wake_queue(ring->net_dev,
+			entry->tx_status.control.queue);
 }
 
 static void
@@ -1376,15 +1392,26 @@ rt2500usb_tx(struct net_device *net_dev,
 		ERROR("Attempt to send packet over invalid queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
-		return NET_XMIT_DROP;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
 
-	if (rt2x00_ring_full(ring))
-		return NET_XMIT_DROP;
+	if (rt2x00_ring_full(ring)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	entry = rt2x00_get_data_entry(ring);
 	txd = rt2x00usb_txdesc_addr(entry);
 
+	if (GET_FLAG(entry, ENTRY_OWNER_NIC)) {
+		ERROR("Arrived at non-free entry in the non-full queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
+
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt2500usb_write_tx_desc(rt2x00usb, txd, skb, control);
 	entry->skb = skb;
@@ -1402,7 +1429,10 @@ rt2500usb_tx(struct net_device *net_dev,
 
 	rt2x00_ring_index_inc(ring);
 
-	return 0;
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
+
+	return NETDEV_TX_OK;
 }
 
 static inline void
@@ -1469,6 +1499,8 @@ rt2500usb_open(struct net_device *net_de
 
 	SET_FLAG(rt2x00usb, RADIO_ENABLED);
 
+	ieee80211_start_queues(net_dev);
+
 	return 0;
 
 exit_fail:
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
index fdbfa60..0799f9f 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -1353,6 +1353,12 @@ rt61pci_txdone(void *data)
 	int			tx_status;
 	int			ack;
 	int			reg;
+	int			ring_full;
+
+	/*
+	 * Store the current status of the ring.
+	 */
+	ring_full = rt2x00_ring_full(ring);
 
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
@@ -1418,6 +1424,16 @@ rt61pci_txdone(void *data)
 		rt2x00pci->scan->status = SCANNING_READY;
 		complete(&rt2x00pci->scan->completion);
 	}
+
+	/*
+	 * If the data ring was full before the txdone handler
+	 * we must make sure the packet queue in the d80211 stack
+	 * is reenabled when the txdone handler has finished.
+	 */
+	entry = ring->entry;
+	if (ring_full && !rt2x00_ring_full(ring))
+		ieee80211_wake_queue(ring->net_dev,
+			entry->tx_status.control.queue);
 }
 
 static irqreturn_t
@@ -2100,18 +2116,26 @@ rt61pci_tx(struct net_device *net_dev,
 		ERROR("Attempt to send packet over invalid queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
-		return NET_XMIT_DROP;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
 
-	if (rt2x00_ring_full(ring))
-		return NET_XMIT_DROP;
+	if (rt2x00_ring_full(ring)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	entry = rt2x00_get_data_entry(ring);
 	txd = entry->desc_addr;
 
 	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
-	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
-		return NET_XMIT_DROP;
+	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
+		ERROR("Arrived at non-free entry in the non-full queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt61pci_write_tx_desc(rt2x00pci, txd, skb, control);
@@ -2119,6 +2143,9 @@ rt61pci_tx(struct net_device *net_dev,
 
 	rt2x00_ring_index_inc(ring);
 
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
+
 	rt2x00_register_read(rt2x00pci, TX_CNTL_CSR, &reg);
 	if (control->queue == IEEE80211_TX_QUEUE_DATA0)
 		rt2x00_set_field32(&reg, TX_CNTL_CSR_KICK_TX_AC0, 1);
@@ -2132,7 +2159,7 @@ rt61pci_tx(struct net_device *net_dev,
 		rt2x00_set_field32(&reg, TX_CNTL_CSR_KICK_TX_MGMT, 1);
 	rt2x00_register_write(rt2x00pci, TX_CNTL_CSR, reg);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int
@@ -2249,6 +2276,8 @@ rt61pci_open(struct net_device *net_dev)
 
 	SET_FLAG(rt2x00pci, RADIO_ENABLED);
 
+	ieee80211_start_queues(net_dev);
+
 	return 0;
 
 exit_fail:
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.c b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
index 48e9917..1871204 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -1094,6 +1094,12 @@ rt73usb_txdone(void *data)
 	struct data_entry	*entry;
 	struct txd		*txd;
 	int			ack;
+	int			ring_full;
+
+	/*
+	 * Store the current status of the ring.
+	 */
+	ring_full = rt2x00_ring_full(ring);
 
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
@@ -1148,6 +1154,16 @@ rt73usb_txdone(void *data)
 		rt2x00usb->scan->status = SCANNING_READY;
 		complete(&rt2x00usb->scan->completion);
 	}
+
+	/*
+	 * If the data ring was full before the txdone handler
+	 * we must make sure the packet queue in the d80211 stack
+	 * is reenabled when the txdone handler has finished.
+	 */
+	entry = ring->entry;
+	if (ring_full && !rt2x00_ring_full(ring))
+		ieee80211_wake_queue(ring->net_dev,
+			entry->tx_status.control.queue);
 }
 
 static void
@@ -1668,15 +1684,26 @@ rt73usb_tx(struct net_device *net_dev,
 		ERROR("Attempt to send packet over invalid queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
-		return NET_XMIT_DROP;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
 
-	if (rt2x00_ring_full(ring))
-		return NET_XMIT_DROP;
+	if (rt2x00_ring_full(ring)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	entry = rt2x00_get_data_entry(ring);
 	txd = rt2x00usb_txdesc_addr(entry);
 
+	if (GET_FLAG(entry, ENTRY_OWNER_NIC)) {
+		ERROR("Arrived at non-free entry in the non-full queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
+
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt73usb_write_tx_desc(rt2x00usb, txd, skb, control);
 	entry->skb = skb;
@@ -1694,7 +1721,10 @@ rt73usb_tx(struct net_device *net_dev,
 
 	rt2x00_ring_index_inc(ring);
 
-	return 0;
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
+
+	return NETDEV_TX_OK;
 }
 
 static inline void
@@ -1766,6 +1796,8 @@ rt73usb_open(struct net_device *net_dev)
 
 	SET_FLAG(rt2x00usb, RADIO_ENABLED);
 
+	ieee80211_start_queues(net_dev);
+
 	return 0;
 
 exit_fail:

