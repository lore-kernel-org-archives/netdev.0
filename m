From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 6/5] rt2x00: per-queue TX flow control
Date: Wed, 14 Jun 2006 18:36:35 +0200
Message-ID: <20060614183635.546d3346@griffin.suse.cz>
References: <20060612211454.409884000.midnight@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:8125 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750728AbWFNQgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 12:36:38 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060612211454.409884000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a patch for rt2x00 driver to do TX flow control.

It is compile-tested only.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c |   26 ++++++++++++++++++-------
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c |   26 ++++++++++++++++++-------
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c |   18 +++++++++++++----
 drivers/net/wireless/d80211/rt2x00/rt61pci.c   |   26 ++++++++++++++++++-------
 drivers/net/wireless/d80211/rt2x00/rt73usb.c   |   18 +++++++++++++----
 5 files changed, 85 insertions(+), 29 deletions(-)

--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1001,7 +1001,7 @@ rt2400pci_txdone(void *data)
 	struct data_entry	*entry;
 	struct txd		*txd;
 	int			tx_status;
-	int			ack;
+	int			ack, wake, queue;
 
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
@@ -1048,7 +1048,11 @@ rt2400pci_txdone(void *data)
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		entry->skb = NULL;
 
+		wake = rt2x00_ring_full(ring);
+		queue = entry->tx_status.control.queue;
 		rt2x00_ring_index_done_inc(ring);
+		if (wake)
+			ieee80211_wake_queue(ring->net_dev, queue);
 	}
 
 	/*
@@ -1541,24 +1545,31 @@ rt2400pci_tx(struct net_device *net_dev,
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
 
-	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
-	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
-		return NET_XMIT_DROP;
+	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC) ||
+	    rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00pci, txd, skb, control);
 	entry->skb = skb;
 
 	rt2x00_ring_index_inc(ring);
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
 
 	rt2x00_register_read(rt2x00pci, TXCSR0, &reg);
 	if (control->queue == IEEE80211_TX_QUEUE_DATA0)
@@ -1668,6 +1679,7 @@ rt2400pci_open(struct net_device *net_de
 	rt2x00_register_write(rt2x00pci, CSR8, reg);
 
 	SET_FLAG(rt2x00pci, RADIO_ENABLED);
+	ieee80211_start_queues(net_dev);
 
 	return 0;
 
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1089,7 +1089,7 @@ rt2500pci_txdone(void *data)
 	struct data_entry	*entry;
 	struct txd		*txd;
 	int			tx_status;
-	int			ack;
+	int			ack, wake, queue;
 
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
@@ -1136,7 +1136,11 @@ rt2500pci_txdone(void *data)
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		entry->skb = NULL;
 
+		wake = rt2x00_ring_full(ring);
+		queue = entry->tx_status.control.queue;
 		rt2x00_ring_index_done_inc(ring);
+		if (wake)
+			ieee80211_wake_queue(ring->net_dev, queue);
 	}
 
 	/*
@@ -1664,24 +1668,31 @@ rt2500pci_tx(struct net_device *net_dev,
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
 
-	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
-	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
-		return NET_XMIT_DROP;
+	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC) ||
+	    rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00pci, txd, skb, control);
 	entry->skb = skb;
 
 	rt2x00_ring_index_inc(ring);
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
 
 	rt2x00_register_read(rt2x00pci, TXCSR0, &reg);
 	if (control->queue == IEEE80211_TX_QUEUE_DATA0)
@@ -1791,6 +1802,7 @@ rt2500pci_open(struct net_device *net_de
 	rt2x00_register_write(rt2x00pci, CSR8, reg);
 
 	SET_FLAG(rt2x00pci, RADIO_ENABLED);
+	ieee80211_start_queues(net_dev);
 
 	return 0;
 
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -929,7 +929,7 @@ rt2500usb_txdone(void *data)
 		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
 	struct txd		*txd;
-	int			ack;
+	int			ack, wake, queue;
 
 	 while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
@@ -968,7 +968,11 @@ rt2500usb_txdone(void *data)
 	
 		entry->skb = NULL;
 	
+		wake = rt2x00_ring_full(ring);
+		queue = entry->tx_status.control.queue;
 		rt2x00_ring_index_done_inc(entry->ring);
+		if (wake)
+			ieee80211_wake_queue(ring->net_dev, queue);
 	}
 
 	/*
@@ -1376,11 +1380,14 @@ rt2500usb_tx(struct net_device *net_dev,
 		ERROR("Attempt to send packet over invalid queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
-		return NET_XMIT_DROP;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_BUSY;
 	}
 
-	if (rt2x00_ring_full(ring))
-		return NET_XMIT_DROP;
+	if (rt2x00_ring_full(ring)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	entry = rt2x00_get_data_entry(ring);
 	txd = rt2x00usb_txdesc_addr(entry);
@@ -1401,6 +1408,8 @@ rt2500usb_tx(struct net_device *net_dev,
 	usb_submit_urb(entry->urb, GFP_ATOMIC);
 
 	rt2x00_ring_index_inc(ring);
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
 
 	return 0;
 }
@@ -1468,6 +1477,7 @@ rt2500usb_open(struct net_device *net_de
 	rt2500usb_enable_led(rt2x00usb);
 
 	SET_FLAG(rt2x00usb, RADIO_ENABLED);
+	ieee80211_start_queues(net_dev);
 
 	return 0;
 
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -1351,7 +1351,7 @@ rt61pci_txdone(void *data)
 	struct data_entry	*entry;
 	struct txd		*txd;
 	int			tx_status;
-	int			ack;
+	int			ack, wake, queue;
 	int			reg;
 
 	while (!rt2x00_ring_empty(ring)) {
@@ -1402,7 +1402,11 @@ rt61pci_txdone(void *data)
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		entry->skb = NULL;
 
+		wake = rt2x00_ring_full(ring);
+		queue = entry->tx_status.control.queue;
 		rt2x00_ring_index_done_inc(ring);
+		if (wake)
+			ieee80211_wake_queue(ring->net_dev, queue);
 	}
 
 	/*
@@ -2100,24 +2104,31 @@ rt61pci_tx(struct net_device *net_dev,
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
 
-	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
-	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
-		return NET_XMIT_DROP;
+	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC) ||
+	    rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
 
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt61pci_write_tx_desc(rt2x00pci, txd, skb, control);
 	entry->skb = skb;
 
 	rt2x00_ring_index_inc(ring);
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
 
 	rt2x00_register_read(rt2x00pci, TX_CNTL_CSR, &reg);
 	if (control->queue == IEEE80211_TX_QUEUE_DATA0)
@@ -2248,6 +2259,7 @@ rt61pci_open(struct net_device *net_dev)
 	rt2x00_register_write(rt2x00pci, INT_SOURCE_CSR, reg);
 
 	SET_FLAG(rt2x00pci, RADIO_ENABLED);
+	ieee80211_start_queues(net_dev);
 
 	return 0;
 
--- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ dscape/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -1093,7 +1093,7 @@ rt73usb_txdone(void *data)
 		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
 	struct txd		*txd;
-	int			ack;
+	int			ack, wake, queue;
 
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
@@ -1132,7 +1132,11 @@ rt73usb_txdone(void *data)
 
 		entry->skb = NULL;
 
+		wake = rt2x00_ring_full(ring);
+		queue = entry->tx_status.control.queue;
 		rt2x00_ring_index_done_inc(entry->ring);
+		if (wake)
+			ieee80211_wake_queue(ring->net_dev, queue);
 	}
 
 	/*
@@ -1668,11 +1672,14 @@ rt73usb_tx(struct net_device *net_dev,
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
@@ -1693,6 +1700,8 @@ rt73usb_tx(struct net_device *net_dev,
 	usb_submit_urb(entry->urb, GFP_ATOMIC);
 
 	rt2x00_ring_index_inc(ring);
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
 
 	return 0;
 }
@@ -1765,6 +1774,7 @@ rt73usb_open(struct net_device *net_dev)
 	rt73usb_enable_led(rt2x00usb);
 
 	SET_FLAG(rt2x00usb, RADIO_ENABLED);
+	ieee80211_start_queues(net_dev);
 
 	return 0;
 
