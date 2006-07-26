From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 15/24] RT2x00: Merge PCI and USB version of data_entry structure
Date: Wed, 26 Jul 2006 19:05:32 +0200
Message-ID: <200607261905.32410.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:5025 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030310AbWGZRHk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:40 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812601nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:39 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Merge the data_entry structure for USB and PCI into
a single structure. This means that all access to the data_addr
and desc_addr should now be performed through the functions:
rt2x00pci_desc_addr()
rt2x00pci_data_addr()
And for usb:
rt2x00usb_urb()
rt2x00usb_rxdata_addr()
rt2x00usb_rxdesc_addr()
rt2x00usb_txdata_addr()
rt2x00usb_txdesc_addr()

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-23 22:41:51.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-25 10:44:12.000000000 +0200
@@ -1039,7 +1039,7 @@
 
 	while (1) {
 		entry = rt2x00_get_data_entry(ring);
-		rxd = entry->desc_addr;
+		rxd = rt2x00pci_desc_addr(entry);
 
 		if (rt2x00_get_field32(rxd->word0, RXD_W0_OWNER_NIC))
 			break;
@@ -1058,7 +1058,8 @@
 
 			skb_reserve(skb, NET_IP_ALIGN);
 
-			memcpy(skb_put(skb, size), entry->data_addr, size);
+			memcpy(skb_put(skb, size), rt2x00pci_data_addr(entry),
+				size);
 
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
@@ -1100,7 +1101,7 @@
 
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
-		txd = entry->desc_addr;
+		txd = rt2x00pci_desc_addr(entry);
 
 		if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC) ||
 		    !rt2x00_get_field32(txd->word0, TXD_W0_VALID))
@@ -1237,10 +1238,10 @@
  * DMA ring functions.
  */
 static int rt2400pci_alloc_ring(struct rt2x00_dev *rt2x00dev,
-	struct data_ring *ring, void (*handler)(void *),
+	unsigned short type, void (*handler)(void *),
 	const u16 max_entries, const u16 data_size, const u16 desc_size)
 {
-	struct data_entry *entry;
+	struct data_ring *ring = &rt2x00dev->ring[type];
 	unsigned int i;
 
 	/*
@@ -1261,15 +1262,15 @@
 
 	rt2x00_ring_index_clear(ring);
 
+	ring->type = type;
 	ring->stats.limit = max_entries;
-	ring->entry_size = sizeof(struct data_entry);
 	ring->data_size = data_size;
 	ring->desc_size = desc_size;
 
 	/*
 	 * Allocate all ring entries.
 	 */
-	ring->entry = kmalloc(ring->stats.limit * ring->entry_size,
+	ring->entry = kmalloc(ring->stats.limit * sizeof(struct data_entry),
 		GFP_KERNEL);
 	if (!ring->entry)
 		return -ENOMEM;
@@ -1288,15 +1289,14 @@
 	 * Initialize all ring entries to contain valid
 	 * addresses.
 	 */
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		entry[i].skb = NULL;
-		entry[i].desc_addr = ring->data_addr
+		ring->entry[i].skb = NULL;
+		ring->entry[i].priv = ring->data_addr
 			+ (i * ring->desc_size);
-		entry[i].data_addr = ring->data_addr
+		ring->entry[i].data_addr = ring->data_addr
 			+ (ring->stats.limit * ring->desc_size)
 			+ (i * ring->data_size);
-		entry[i].data_dma = ring->data_dma
+		ring->entry[i].data_dma = ring->data_dma
 			+ (ring->stats.limit * ring->desc_size)
 			+ (i * ring->data_size);
 	}
@@ -1329,19 +1329,19 @@
 	SET_FLAG(rt2x00dev, DEVICE_SUPPORT_ATIM);
 
 	if (rt2400pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_RX], rt2400pci_rxdone,
+		rt2x00dev, RING_RX, rt2400pci_rxdone,
 		RX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct rxd)) ||
 	    rt2400pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_TX], rt2400pci_txdone,
+		rt2x00dev, RING_TX, rt2400pci_txdone,
 		 TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt2400pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_ATIM], rt2400pci_txdone,
+		rt2x00dev, RING_ATIM, rt2400pci_txdone,
 		ATIM_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt2400pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_PRIO], rt2400pci_txdone,
+		rt2x00dev, RING_PRIO, rt2400pci_txdone,
 		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt2400pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_BEACON], rt2400pci_beacondone,
+		rt2x00dev, RING_BEACON, rt2400pci_beacondone,
 		BEACON_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd))) {
 		ERROR("DMA allocation failed.\n");
 		return -ENOMEM;
@@ -1368,20 +1368,18 @@
 static void rt2400pci_init_rxdesc(struct rt2x00_dev *rt2x00dev,
 	struct data_ring *ring)
 {
-	struct data_entry *entry;
 	struct rxd *rxd;
 	unsigned int i;
 
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		rxd = entry[i].desc_addr;
+		rxd = rt2x00pci_desc_addr(&ring->entry[i]);
 
 		rt2x00_set_field32(&rxd->word2, RXD_W2_BUFFER_LENGTH,
 			ring->data_size);
 		rt2x00_set_field32(&rxd->word1, RXD_W1_BUFFER_ADDRESS,
-			entry[i].data_dma);
+			ring->entry[i].data_dma);
 		rt2x00_set_field32(&rxd->word0, RXD_W0_OWNER_NIC, 1);
 	}
 
@@ -1391,20 +1389,18 @@
 static void rt2400pci_init_txdesc(struct rt2x00_dev *rt2x00dev,
 	struct data_ring *ring)
 {
-	struct data_entry *entry;
 	struct txd *txd;
 	unsigned int i;
 
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		txd = entry[i].desc_addr;
+		txd = rt2x00pci_desc_addr(&ring->entry[i]);
 
 		rt2x00_set_field32(&txd->word2, TXD_W2_BUFFER_LENGTH,
 			ring->data_size);
 		rt2x00_set_field32(&txd->word1, TXD_W1_BUFFER_ADDRESS,
-			entry[i].data_dma);
+			ring->entry[i].data_dma);
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		rt2x00_set_field32(&txd->word0, TXD_W0_OWNER_NIC, 0);
 	}
@@ -1671,7 +1667,7 @@
 	}
 
 	entry = rt2x00_get_data_entry(ring);
-	txd = entry->desc_addr;
+	txd = rt2x00pci_desc_addr(entry);
 
 	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC) ||
 	    rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
@@ -1687,7 +1683,7 @@
 	 */
 	rt2x00_set_sequence(skb, &rt2x00dev->interface.sequence);
 
-	memcpy(entry->data_addr, skb->data, skb->len);
+	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
@@ -2286,8 +2282,9 @@
 	 */
 	rt2x00_set_sequence(skb, &rt2x00dev->interface.sequence);
 
-	memcpy(entry->data_addr, skb->data, skb->len);
-	rt2400pci_write_tx_desc(rt2x00dev, entry->desc_addr, skb, control);
+	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
+	rt2400pci_write_tx_desc(rt2x00dev, rt2x00pci_desc_addr(entry),
+		skb, control);
 
 	return 0;
 }
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2400pci.h 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	
2006-07-23 17:15:44.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	
2006-07-25 10:09:31.000000000 +0200
@@ -845,6 +845,20 @@
 };
 
 /*
+ * Small handlers to determine the descriptor and
+ * data address within each entry.
+ */
+static inline void* rt2x00pci_data_addr(struct data_entry *entry)
+{
+	return entry->data_addr;
+}
+
+static inline void* rt2x00pci_desc_addr(struct data_entry *entry)
+{
+	return entry->priv;
+}
+
+/*
  * Macro's for converting txpower from EEPROM to dscape value
  * and from dscape value to register value.
  * NOTE: Logics in rt2400pci for txpower are reversed
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-23 22:59:00.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-25 14:50:08.000000000 +0200
@@ -1137,7 +1137,7 @@
 
 	while (1) {
 		entry = rt2x00_get_data_entry(ring);
-		rxd = entry->desc_addr;
+		rxd = rt2x00pci_desc_addr(entry);
 
 		if (rt2x00_get_field32(rxd->word0, RXD_W0_OWNER_NIC))
 			break;
@@ -1156,7 +1156,8 @@
 
 			skb_reserve(skb, NET_IP_ALIGN);
 
-			memcpy(skb_put(skb, size), entry->data_addr, size);
+			memcpy(skb_put(skb, size), rt2x00pci_data_addr(entry),
+				size);
 
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
@@ -1201,7 +1202,7 @@
 
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
-		txd = entry->desc_addr;
+		txd = rt2x00pci_desc_addr(entry);
 
 		if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC) ||
 		    !rt2x00_get_field32(txd->word0, TXD_W0_VALID))
@@ -1338,10 +1339,10 @@
  * DMA ring functions.
  */
 static int rt2500pci_alloc_ring(struct rt2x00_dev *rt2x00dev,
-	struct data_ring *ring, void (*handler)(void *),
+	unsigned short type, void (*handler)(void *),
 	const u16 max_entries, const u16 data_size, const u16 desc_size)
 {
-	struct data_entry *entry;
+	struct data_ring *ring = &rt2x00dev->ring[type];
 	unsigned int i;
 
 	/*
@@ -1363,15 +1364,15 @@
 
 	rt2x00_ring_index_clear(ring);
 
+	ring->type = type;
 	ring->stats.limit = max_entries;
-	ring->entry_size = sizeof(struct data_entry);
 	ring->data_size = data_size;
 	ring->desc_size = desc_size;
 
 	/*
 	 * Allocate all ring entries.
 	 */
-	ring->entry = kmalloc(ring->stats.limit * ring->entry_size,
+	ring->entry = kmalloc(ring->stats.limit * sizeof(struct data_entry),
 		GFP_KERNEL);
 	if (!ring->entry)
 		return -ENOMEM;
@@ -1390,15 +1391,14 @@
 	 * Initialize all ring entries to contain valid
 	 * addresses.
 	 */
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		entry[i].skb = NULL;
-		entry[i].desc_addr = ring->data_addr
+		ring->entry[i].skb = NULL;
+		ring->entry[i].priv = ring->data_addr
 			+ (i * ring->desc_size);
-		entry[i].data_addr = ring->data_addr
+		ring->entry[i].data_addr = ring->data_addr
 			+ (ring->stats.limit * ring->desc_size)
 			+ (i * ring->data_size);
-		entry[i].data_dma = ring->data_dma
+		ring->entry[i].data_dma = ring->data_dma
 			+ (ring->stats.limit * ring->desc_size)
 			+ (i * ring->data_size);
 	}
@@ -1431,19 +1431,19 @@
 	SET_FLAG(rt2x00dev, DEVICE_SUPPORT_ATIM);
 
 	if (rt2500pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_RX], rt2500pci_rxdone,
+		rt2x00dev, RING_RX, rt2500pci_rxdone,
 		RX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct rxd)) ||
 	    rt2500pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_TX], rt2500pci_txdone,
+		rt2x00dev, RING_TX, rt2500pci_txdone,
 		 TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt2500pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_ATIM], rt2500pci_txdone,
+		rt2x00dev, RING_ATIM, rt2500pci_txdone,
 		ATIM_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt2500pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_PRIO], rt2500pci_txdone,
+		rt2x00dev, RING_PRIO, rt2500pci_txdone,
 		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt2500pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_BEACON], rt2500pci_beacondone,
+		rt2x00dev, RING_BEACON, rt2500pci_beacondone,
 		BEACON_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd))) {
 		ERROR("DMA allocation failed.\n");
 		return -ENOMEM;
@@ -1470,18 +1470,16 @@
 static void rt2500pci_init_rxdesc(struct rt2x00_dev *rt2x00dev,
 	struct data_ring *ring)
 {
-	struct data_entry *entry;
 	struct rxd *rxd;
 	unsigned int i;
 
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		rxd = entry[i].desc_addr;
+		rxd = rt2x00pci_desc_addr(&ring->entry[i]);
 
 		rt2x00_set_field32(&rxd->word1, RXD_W1_BUFFER_ADDRESS,
-			entry[i].data_dma);
+			ring->entry[i].data_dma);
 		rt2x00_set_field32(&rxd->word0, RXD_W0_OWNER_NIC, 1);
 	}
 
@@ -1491,18 +1489,16 @@
 static void rt2500pci_init_txdesc(struct rt2x00_dev *rt2x00dev,
 	struct data_ring *ring)
 {
-	struct data_entry *entry;
 	struct txd *txd;
 	unsigned int i;
 
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		txd = entry[i].desc_addr;
+		txd = rt2x00pci_desc_addr(&ring->entry[i]);
 
 		rt2x00_set_field32(&txd->word1, TXD_W1_BUFFER_ADDRESS,
-			entry[i].data_dma);
+			ring->entry[i].data_dma);
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		rt2x00_set_field32(&txd->word0, TXD_W0_OWNER_NIC, 0);
 	}
@@ -1807,7 +1803,7 @@
 	}
 
 	entry = rt2x00_get_data_entry(ring);
-	txd = entry->desc_addr;
+	txd = rt2x00pci_desc_addr(entry);
 
 	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC) ||
 	    rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
@@ -1823,7 +1819,7 @@
 	 */
 	rt2x00_set_sequence(skb, &rt2x00dev->interface.sequence);
 
-	memcpy(entry->data_addr, skb->data, skb->len);
+	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
@@ -2413,8 +2409,9 @@
 	 */
 	rt2x00_set_sequence(skb, &rt2x00dev->interface.sequence);
 
-	memcpy(entry->data_addr, skb->data, skb->len);
-	rt2500pci_write_tx_desc(rt2x00dev, entry->desc_addr, skb, control);
+	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
+	rt2500pci_write_tx_desc(rt2x00dev, rt2x00pci_desc_addr(entry),
+		skb, control);
 
 	return 0;
 }
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2500pci.h 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	
2006-07-23 17:16:15.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	
2006-07-25 10:09:39.000000000 +0200
@@ -1114,6 +1114,20 @@
 };
 
 /*
+ * Small handlers to determine the descriptor and
+ * data address within each entry.
+ */
+static inline void* rt2x00pci_data_addr(struct data_entry *entry)
+{
+	return entry->data_addr;
+}
+
+static inline void* rt2x00pci_desc_addr(struct data_entry *entry)
+{
+	return entry->priv;
+}
+
+/*
  * Macro's for converting txpower from EEPROM to dscape value
  * and from dscape value to register value.
  */
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-23 23:00:43.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-25 15:37:14.000000000 +0200
@@ -949,6 +949,7 @@
 	struct data_entry *entry;
 	struct sk_buff *skb;
 	struct rxd *rxd;
+	struct urb *urb;
 	u16 size;
 	u8 rssi_count;
 	char total_rssi;
@@ -962,6 +963,7 @@
 	while (1) {
 		entry = rt2x00_get_data_entry(ring);
 		rxd = rt2x00usb_rxdesc_addr(entry);
+		urb = rt2x00usb_urb(entry);
 
 		if (GET_FLAG(entry, ENTRY_OWNER_NIC))
 			break;
@@ -969,9 +971,9 @@
 		/*
 		 * There has been a problem. Ignore packet.
 		 */
-		if (entry->urb->status) {
+		if (urb->status) {
 			SET_FLAG(entry, ENTRY_OWNER_NIC);
-			usb_submit_urb(entry->urb, GFP_ATOMIC);
+			usb_submit_urb(urb, GFP_ATOMIC);
 			rt2x00_ring_index_inc(ring);
 			continue;
 		}
@@ -1008,7 +1010,7 @@
 		}
 
 		SET_FLAG(entry, ENTRY_OWNER_NIC);
-		usb_submit_urb(entry->urb, GFP_ATOMIC);
+		usb_submit_urb(urb, GFP_ATOMIC);
 
 		rt2x00_ring_index_inc(ring);
 	}
@@ -1031,6 +1033,7 @@
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry *entry;
 	struct txd *txd;
+	struct urb *urb;
 	int ack;
 	int ring_full;
 
@@ -1042,6 +1045,7 @@
 	 while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
 		txd = rt2x00usb_txdesc_addr(entry);
+		urb = rt2x00usb_urb(entry);
 
 		if (GET_FLAG(entry, ENTRY_OWNER_NIC))
 			break;
@@ -1061,9 +1065,9 @@
 		 * was succesfull.
 		 */
 		entry->tx_status.ack = 0;
-		if (ack && (entry->urb->status == TX_SUCCESS))
+		if (ack && (urb->status == TX_SUCCESS))
 			entry->tx_status.ack = 1;
-		else if (ack && entry->urb->status == TX_FAIL_OTHER) {
+		else if (ack && urb->status == TX_FAIL_OTHER) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
 			entry->tx_status.excessive_retries++;
 		}
@@ -1117,7 +1121,7 @@
 	if (urb->status)
 		return;
 
-	if (GET_FLAG(entry, ENTRY_TYPE_RX))
+	if (entry->ring->type == RING_RX)
 		rt2500usb_activity_led(rt2x00dev, 1);
 
 	queue_work(rt2x00dev->workqueue, &entry->ring->irq_work);
@@ -1127,10 +1131,10 @@
  * DMA ring functions.
  */
 static int rt2500usb_alloc_ring(struct rt2x00_dev *rt2x00dev,
-	struct data_ring *ring, void (*handler)(void *),
+	unsigned short type, void (*handler)(void *),
 	const u16 max_entries, const u16 data_size, const u16 desc_size)
 {
-	struct data_entry *entry;
+	struct data_ring *ring = &rt2x00dev->ring[type];
 	unsigned int i;
 	int status;
 
@@ -1153,15 +1157,15 @@
 
 	rt2x00_ring_index_clear(ring);
 
+	ring->type = type;
 	ring->stats.limit = max_entries;
-	ring->entry_size = sizeof(struct data_entry);
 	ring->data_size = data_size;
 	ring->desc_size = desc_size;
 
 	/*
 	 * Allocate all ring entries.
 	 */
-	ring->entry = kmalloc(ring->stats.limit * ring->entry_size,
+	ring->entry = kmalloc(ring->stats.limit * sizeof(struct data_entry),
 		GFP_KERNEL);
 	if (!ring->entry)
 		return -ENOMEM;
@@ -1182,20 +1186,19 @@
 	 * addresses.
 	 */
 	status = 0;
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		entry[i].ring = ring;
+		ring->entry[i].ring = ring;
 		if (!status)
-			entry[i].urb = usb_alloc_urb(0, GFP_KERNEL);
+			ring->entry[i].priv = usb_alloc_urb(0, GFP_KERNEL);
 		else
-			entry[i].urb = NULL;
-		if (!entry[i].urb)
+			ring->entry[i].priv = NULL;
+		if (!ring->entry[i].priv)
 			status = -ENOMEM;
-		entry[i].skb = NULL;
-		entry[i].data_addr = ring->data_addr
+		ring->entry[i].skb = NULL;
+		ring->entry[i].data_addr = ring->data_addr
 			+ (i * ring->desc_size)
 			+ (i * ring->data_size);
-		entry[i].data_dma = ring->data_dma
+		ring->entry[i].data_dma = ring->data_dma
 			+ (i * ring->desc_size)
 			+ (i * ring->data_size);
 	}
@@ -1206,16 +1209,16 @@
 static void rt2500usb_free_ring(struct rt2x00_dev *rt2x00dev,
 	struct data_ring *ring)
 {
-	struct data_entry *entry;
+	struct urb *urb;
 	unsigned int i;
 
 	if (!ring->entry)
 		goto exit;
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		usb_kill_urb(entry[i].urb);
-		usb_free_urb(entry[i].urb);
+		urb = rt2x00usb_urb(&ring->entry[i]);
+		usb_kill_urb(urb);
+		usb_free_urb(urb);
 	}
 
 	kfree(ring->entry);
@@ -1242,19 +1245,19 @@
 	SET_FLAG(rt2x00dev, DEVICE_SUPPORT_ATIM);
 
 	if (rt2500usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_RX], &rt2500usb_rxdone,
+		rt2x00dev, RING_RX, &rt2500usb_rxdone,
 		RX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct rxd)) ||
 	    rt2500usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_TX], &rt2500usb_txdone,
+		rt2x00dev, RING_TX, &rt2500usb_txdone,
 		 TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt2500usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_ATIM], &rt2500usb_txdone,
+		rt2x00dev, RING_ATIM, &rt2500usb_txdone,
 		ATIM_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt2500usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_PRIO], &rt2500usb_txdone,
+		rt2x00dev, RING_PRIO, &rt2500usb_txdone,
 		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt2500usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_BEACON], &rt2500usb_beacondone,
+		rt2x00dev, RING_BEACON, &rt2500usb_beacondone,
 		BEACON_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd))) {
 		ERROR("DMA allocation failed.\n");
 		return -ENOMEM;
@@ -1283,37 +1286,37 @@
 {
 	struct usb_device *usb_dev =
 		interface_to_usbdev(rt2x00dev_usb(rt2x00dev));
-	struct data_entry *entry;
+	struct urb *urb;
 	unsigned int i;
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		entry[i].urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
-		entry[i].urb->transfer_dma = entry[i].data_dma;
+		urb = rt2x00usb_urb(&ring->entry[i]);
+		urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
+		urb->transfer_dma = ring->entry[i].data_dma;
 		usb_fill_bulk_urb(
-			entry[i].urb,
+			urb,
 			usb_dev,
 			usb_rcvbulkpipe(usb_dev, 1),
-			entry[i].data_addr,
+			ring->entry[i].data_addr,
 			ring->entry_size + ring->desc_size,
 			rt2500usb_interrupt,
-			&entry[i]);
-		SET_FLAG(&entry[i], ENTRY_OWNER_NIC | ENTRY_TYPE_RX);
-		usb_submit_urb(entry[i].urb, GFP_ATOMIC);
+			&ring->entry[i]);
+		SET_FLAG(&ring->entry[i], ENTRY_OWNER_NIC);
+		usb_submit_urb(urb, GFP_ATOMIC);
 	}
 }
 
 static void rt2500usb_init_txring(struct rt2x00_dev *rt2x00dev,
 	struct data_ring *ring)
 {
-	struct data_entry *entry;
+	struct urb *urb;
 	unsigned int i;
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		entry[i].urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
-		entry[i].urb->transfer_dma = entry[i].data_dma;
-		CLEAR_FLAGS(&entry[i]);
+		urb = rt2x00usb_urb(&ring->entry[i]);
+		urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
+		urb->transfer_dma = ring->entry[i].data_dma;
+		CLEAR_FLAGS(&ring->entry[i]);
 	}
 }
 
@@ -1536,14 +1539,14 @@
 
 	SET_FLAG(entry, ENTRY_OWNER_NIC);
 	usb_fill_bulk_urb(
-		entry->urb,
+		rt2x00usb_urb(entry),
 		usb_dev,
 		usb_sndbulkpipe(usb_dev, 1),
 		entry->data_addr,
 		skb->len + ring->desc_size,
 		rt2500usb_interrupt,
 		entry);
-	usb_submit_urb(entry->urb, GFP_ATOMIC);
+	usb_submit_urb(rt2x00usb_urb(entry), GFP_ATOMIC);
 
 	rt2x00_ring_index_inc(ring);
 
@@ -1555,12 +1558,10 @@
 
 static inline void rt2500usb_reset_ring(struct data_ring *ring)
 {
-	struct data_entry *entry;
 	unsigned int i;
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++)
-		usb_kill_urb(entry[i].urb);
+		usb_kill_urb(ring->entry[i].urb);
 }
 
 static int rt2500usb_reset(struct net_device *net_dev)
@@ -2050,14 +2051,14 @@
 
 	SET_FLAG(entry, ENTRY_OWNER_NIC);
 	usb_fill_bulk_urb(
-		entry->urb,
+		rt2x00usb_urb(entry),
 		usb_dev,
 		usb_sndbulkpipe(usb_dev, 1),
 		entry->data_addr,
 		skb->len + rt2x00dev->ring[RING_BEACON].desc_size,
 		rt2500usb_interrupt,
 		entry);
-	usb_submit_urb(entry->urb, GFP_ATOMIC);
+	usb_submit_urb(rt2x00usb_urb(entry), GFP_ATOMIC);
 
 	return 0;
 }
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2500usb.h 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	
2006-07-23 17:16:31.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	
2006-07-25 10:08:02.000000000 +0200
@@ -634,6 +634,37 @@
 };
 
 /*
+ * The location of the descriptor is variating and depends
+ * on the fact if it is a TX or RX ring and the length of the packet.
+ * We need some small handlers to properly access the descriptors.
+ */
+static inline struct urb* rt2x00usb_urb(struct data_entry *entry)
+{
+	return (struct urb*)entry->priv;
+}
+
+static inline void* rt2x00usb_rxdata_addr(struct data_entry *entry)
+{
+	return entry->data_addr;
+}
+
+static inline void* rt2x00usb_rxdesc_addr(struct data_entry *entry)
+{
+	return entry->data_addr +
+		(rt2x00usb_urb(entry)->actual_length - entry->ring->desc_size);
+}
+
+static inline void* rt2x00usb_txdata_addr(struct data_entry *entry)
+{
+	return entry->data_addr + entry->ring->desc_size;
+}
+
+static inline void* rt2x00usb_txdesc_addr(struct data_entry *entry)
+{
+	return entry->data_addr;
+}
+
+/*
  * Macro's for converting txpower from EEPROM to dscape value
  * and from dscape value to register value.
  */
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2x00.h 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-07-23 
22:32:51.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2x00.h	
2006-07-25 10:15:58.000000000 +0200
@@ -445,6 +445,51 @@
 }
 
 /*
+ * data_entry
+ * The data ring is a list of data entries.
+ * Each entry holds a reference to the descriptor
+ * and the data buffer. For TX rings the reference to the
+ * sk_buff of the packet being transmitted is also stored here.
+ */
+struct data_entry{
+	/*
+	 * Status flags
+	 */
+	unsigned int flags;
+#define ENTRY_OWNER_NIC	0x00000001
+#define ENTRY_RTS_FRAME	0x00000002
+
+	/*
+	 * Ring we belong to.
+	 */
+	struct data_ring *ring;
+
+	/*
+	 * sk_buff for the packet which is being transmitted
+	 * in this entry (Only used with TX related rings).
+	 */
+	struct sk_buff *skb;
+
+	/*
+	 * Store a ieee80211_tx_status structure in each
+	 * ring entry, this will optimize the txdone
+	 * handler.
+	 */
+	struct ieee80211_tx_status tx_status;
+
+	/*
+	 * private pointer specific to driver.
+	 */
+	void *priv;
+
+	/*
+	 * Data address for this entry.
+	 */
+	void *data_addr;
+	dma_addr_t data_dma;
+};
+
+/*
  * data_ring
  * Data rings are used by the device to send and receive packets.
  * The data_addr is the base address of the data memory.
@@ -465,7 +510,7 @@
 	/*
 	 * Base address for the device specific data entries.
 	 */
-	void *entry;
+	struct data_entry *entry;
 
 	/*
 	 * TX queue statistic info.
@@ -490,9 +535,9 @@
 	u8 index_done;
 
 	/*
-	 * Size of device specific data entry structure.
+	 * Ring type.
 	 */
-	u16 entry_size;
+	u16 type;
 
 	/*
 	 * Size of packet and descriptor in bytes.
@@ -505,14 +550,16 @@
  * Handlers to determine the address of the current device specific
  * data entry, where either index or index_done points to.
  */
-static inline void* rt2x00_get_data_entry(struct data_ring *ring)
+static inline struct data_entry* rt2x00_get_data_entry(
+	struct data_ring *ring)
 {
-	return ring->entry + (ring->index * ring->entry_size);
+	return &ring->entry[ring->index];
 }
 
-static inline void* rt2x00_get_data_entry_done(struct data_ring *ring)
+static inline struct data_entry* rt2x00_get_data_entry_done(
+	struct data_ring *ring)
 {
-	return ring->entry + (ring->index_done * ring->entry_size);
+	return &ring->entry[ring->index_done];
 }
 
 /*
@@ -899,7 +946,7 @@
 /*
  * Initialize a ieee80211_entry by filling in all fields and correctly
  * construct the device specific val and val2 fields.
-  */
+ */
 static inline void device_rate_entry(struct ieee80211_rate *entry,
 	int rate, int mask, int plcp, int flags)
 {
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	
2006-07-23 17:59:04.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	
2006-07-25 10:13:00.000000000 +0200
@@ -76,45 +76,6 @@
 #endif /* CONFIG_RT2X00_BUTTON */
 
 /*
- * data_entry
- * The data ring is a list of data entries.
- * Each entry holds a reference to the descriptor
- * and the data buffer. For TX rings the reference to the
- * sk_buff of the packet being transmitted is also stored here.
- */
-struct data_entry {
-	/*
-	 * Status flag.
-	 */
-	unsigned int flags;
-#define ENTRY_RTS_FRAME		0x00000001
-
-	/*
-	 * sk_buff for the packet which is being transmitted
-	 * in this entry (Only used with TX related rings).
-	 */
-	struct sk_buff *skb;
-
-	/*
-	 * Store a ieee80211_tx_status structure in each
-	 * ring entry, this will optimize the txdone
-	 * handler.
-	 */
-	struct ieee80211_tx_status tx_status;
-
-	/*
-	 * Descriptor address for this entry.
-	 */
-	void *desc_addr;
-
-	/*
-	 * Data address for this entry.
-	 */
-	void *data_addr;
-	dma_addr_t data_dma;
-};
-
-/*
  * HW button variables & functions.
  * The delay between each poll is set by the module parameter.
  */
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	
2006-07-23 17:58:43.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	
2006-07-25 10:13:18.000000000 +0200
@@ -43,78 +43,6 @@
 #define REGISTER_TIMEOUT_FIRMWARE	1000
 
 /*
- * data_entry
- * The data ring is a list of data entries.
- * Each entry holds a reference to the descriptor
- * and the data buffer. For TX rings the reference to the
- * sk_buff of the packet being transmitted is also stored here.
- */
-struct data_entry {
-	/*
-	 * Status flag.
-	 */
-	unsigned int flags;
-#define ENTRY_OWNER_NIC		0x00000001
-#define ENTRY_TYPE_RX		0x00000002
-#define ENTRY_RTS_FRAME		0x00000004
-
-	/*
-	 * Ring we belong to.
-	 */
-	struct data_ring *ring;
-
-	/*
-	 * URB for communication with device.
-	 */
-	struct urb *urb;
-
-	/*
-	 * sk_buff for the packet which is being transmitted
-	 * in this entry (Only used with TX related rings).
-	 */
-	struct sk_buff *skb;
-
-	/*
-	 * Store a ieee80211_tx_status structure in each
-	 * ring entry, this will optimize the txdone
-	 * handler.
-	 */
-	struct ieee80211_tx_status tx_status;
-
-	/*
-	 * Data address for this entry.
-	 */
-	void *data_addr;
-	dma_addr_t data_dma;
-};
-
-/*
- * The location of the descriptor is variating and depends
- * on the fact if it is a TX or RX ring and the length of the packet.
- * We need some small handlers to properly access the descriptors.
- */
-static inline void* rt2x00usb_rxdata_addr(struct data_entry *entry)
-{
-	return entry->data_addr;
-}
-
-static inline void* rt2x00usb_rxdesc_addr(struct data_entry *entry)
-{
-	return entry->data_addr +
-		(entry->urb->actual_length - entry->ring->desc_size);
-}
-
-static inline void* rt2x00usb_txdata_addr(struct data_entry *entry)
-{
-	return entry->data_addr + entry->ring->desc_size;
-}
-
-static inline void* rt2x00usb_txdesc_addr(struct data_entry *entry)
-{
-	return entry->data_addr;
-}
-
-/*
  * USB request types.
  */
 #define USB_VENDOR_REQUEST	( USB_TYPE_VENDOR | USB_RECIP_DEVICE )
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.c	
2006-07-23 23:19:17.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt61pci.c	
2006-07-25 14:55:25.000000000 +0200
@@ -1424,7 +1424,7 @@
 
 	while (1) {
 		entry = rt2x00_get_data_entry(ring);
-		rxd = entry->desc_addr;
+		rxd = rt2x00pci_desc_addr(entry);
 
 		if (rt2x00_get_field32(rxd->word0, RXD_W0_OWNER_NIC))
 			break;
@@ -1442,7 +1442,8 @@
 
 			skb_reserve(skb, NET_IP_ALIGN);
 
-			memcpy(skb_put(skb, size), entry->data_addr, size);
+			memcpy(skb_put(skb, size), rt2x00pci_data_addr(entry),
+				size);
 
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);
@@ -1490,7 +1491,7 @@
 
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
-		txd = entry->desc_addr;
+		txd = rt2x00pci_desc_addr(entry);
 
 		rt2x00_register_read(rt2x00dev, STA_CSR4, &reg);
 
@@ -1796,10 +1797,10 @@
  * DMA ring functions.
  */
 static int rt61pci_alloc_ring(struct rt2x00_dev *rt2x00dev,
-	struct data_ring *ring, void (*handler)(void *),
+	unsigned short type, void (*handler)(void *),
 	const u16 max_entries, const u16 data_size, const u16 desc_size)
 {
-	struct data_entry *entry;
+	struct data_ring *ring = &rt2x00dev->ring[type];
 	unsigned int i;
 
 	/*
@@ -1821,15 +1822,15 @@
 
 	rt2x00_ring_index_clear(ring);
 
+	ring->type = type;
 	ring->stats.limit = max_entries;
-	ring->entry_size = sizeof(struct data_entry);
 	ring->data_size = data_size;
 	ring->desc_size = desc_size;
 
 	/*
 	 * Allocate all ring entries.
 	 */
-	ring->entry = kmalloc(ring->stats.limit * ring->entry_size,
+	ring->entry = kmalloc(ring->stats.limit * sizeof(struct data_entry),
 		GFP_KERNEL);
 	if (!ring->entry)
 		return -ENOMEM;
@@ -1848,15 +1849,14 @@
 	 * Initialize all ring entries to contain valid
 	 * addresses.
 	 */
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		entry[i].skb = NULL;
-		entry[i].desc_addr = ring->data_addr
+		ring->entry[i].skb = NULL;
+		ring->entry[i].priv = ring->data_addr
 			+ (i * ring->desc_size);
-		entry[i].data_addr = ring->data_addr
+		ring->entry[i].data_addr = ring->data_addr
 			+ (ring->stats.limit * ring->desc_size)
 			+ (i * ring->data_size);
-		entry[i].data_dma = ring->data_dma
+		ring->entry[i].data_dma = ring->data_dma
 			+ (ring->stats.limit * ring->desc_size)
 			+ (i * ring->data_size);
 	}
@@ -1887,25 +1887,25 @@
 	}
 
 	if (rt61pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_RX], rt61pci_rxdone,
+		rt2x00dev, RING_RX, rt61pci_rxdone,
 		RX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct rxd)) ||
 	    rt61pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_AC_BK], rt61pci_txdone,
+		rt2x00dev, RING_AC_BK, rt61pci_txdone,
 		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt61pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_AC_BE], rt61pci_txdone,
+		rt2x00dev, RING_AC_BE, rt61pci_txdone,
 		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt61pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_AC_VI], rt61pci_txdone,
+		rt2x00dev, RING_AC_VI, rt61pci_txdone,
 		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt61pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_AC_VO], rt61pci_txdone,
+		rt2x00dev, RING_AC_VO, rt61pci_txdone,
 		 TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt61pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_PRIO], rt61pci_txdone,
+		rt2x00dev, RING_PRIO, rt61pci_txdone,
 		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt61pci_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_BEACON], rt61pci_beacondone,
+		rt2x00dev, RING_BEACON, rt61pci_beacondone,
 		BEACON_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd)) ) {
 		ERROR("DMA allocation failed.\n");
 		return -ENOMEM;
@@ -1934,19 +1934,17 @@
 static void rt61pci_init_rxdesc(struct rt2x00_dev *rt2x00dev,
 	struct data_ring *ring)
 {
-	struct data_entry *entry;
 	struct rxd *rxd;
 	unsigned int i;
 
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		rxd = entry[i].desc_addr;
+		rxd = rt2x00pci_desc_addr(&ring->entry[i]);
 
 		rt2x00_set_field32(&rxd->word0, RXD_W0_OWNER_NIC, 1);
 		rt2x00_set_field32(&rxd->word5, RXD_W5_BUFFER_PHYSICAL_ADDRESS,
-			entry[i].data_dma);
+			ring->entry[i].data_dma);
 	}
 
 	rt2x00_ring_index_clear(ring);
@@ -1955,21 +1953,19 @@
 static void rt61pci_init_txdesc(struct rt2x00_dev *rt2x00dev,
 	struct data_ring *ring)
 {
-	struct data_entry *entry;
 	struct txd *txd;
 	unsigned int i;
 
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		txd = entry[i].desc_addr;
+		txd = rt2x00pci_desc_addr(&ring->entry[i]);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		rt2x00_set_field32(&txd->word0, TXD_W0_OWNER_NIC, 0);
 		rt2x00_set_field32(&txd->word1, TXD_W1_BUFFER_COUNT, 1);
 		rt2x00_set_field32(&txd->word6, TXD_W6_BUFFER_PHYSICAL_ADDRESS,
-			entry[i].data_dma);
+			ring->entry[i].data_dma);
 	}
 
 	rt2x00_ring_index_clear(ring);
@@ -2271,7 +2267,7 @@
 	}
 
 	entry = rt2x00_get_data_entry(ring);
-	txd = entry->desc_addr;
+	txd = rt2x00pci_desc_addr(entry);
 
 	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC) ||
 	    rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
@@ -2282,7 +2278,7 @@
 		return NETDEV_TX_BUSY;
 	}
 
-	memcpy(entry->data_addr, skb->data, skb->len);
+	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt61pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
@@ -2898,8 +2894,9 @@
 	 */
 	control->queue = IEEE80211_TX_QUEUE_BEACON;
 
-	memcpy(entry->data_addr, skb->data, skb->len);
-	rt61pci_write_tx_desc(rt2x00dev, entry->desc_addr, skb, control);
+	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
+	rt61pci_write_tx_desc(rt2x00dev, rt2x00pci_desc_addr(entry),
+		skb, control);
 
 	return 0;
 }
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.h 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.h	
2006-07-23 23:21:39.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt61pci.h	
2006-07-25 10:09:44.000000000 +0200
@@ -1330,6 +1330,20 @@
 };
 
 /*
+ * Small handlers to determine the descriptor and
+ * data address within each entry.
+ */
+static inline void* rt2x00pci_data_addr(struct data_entry *entry)
+{
+	return entry->data_addr;
+}
+
+static inline void* rt2x00pci_desc_addr(struct data_entry *entry)
+{
+	return entry->priv;
+}
+
+/*
  * Macro's for converting txpower from EEPROM to dscape value
  * and from dscape value to register value.
  */
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-23 23:17:42.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-25 15:37:22.000000000 +0200
@@ -1128,6 +1128,7 @@
 	struct data_entry *entry;
 	struct sk_buff *skb;
 	struct rxd *rxd;
+	struct urb *urb;
 	u16 size;
 	u8 rssi_count;
 	char total_rssi;
@@ -1141,6 +1142,7 @@
 	while (1) {
 		entry = rt2x00_get_data_entry(ring);
 		rxd = rt2x00usb_rxdesc_addr(entry);
+		urb = rt2x00usb_urb(entry);
 
 		if (GET_FLAG(entry, ENTRY_OWNER_NIC))
 			break;
@@ -1148,9 +1150,9 @@
 		/*
 		 * There has been a problem. Ignore packet.
 		 */
-		if (entry->urb->status) {
+		if (urb->status) {
 			SET_FLAG(entry, ENTRY_OWNER_NIC);
-			usb_submit_urb(entry->urb, GFP_ATOMIC);
+			usb_submit_urb(urb, GFP_ATOMIC);
 			rt2x00_ring_index_inc(ring);
 			continue;
 		}
@@ -1187,7 +1189,7 @@
 		}
 
 		SET_FLAG(entry, ENTRY_OWNER_NIC);
-		usb_submit_urb(entry->urb, GFP_ATOMIC);
+		usb_submit_urb(urb, GFP_ATOMIC);
 
 		rt2x00_ring_index_inc(ring);
 	}
@@ -1212,6 +1214,7 @@
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry *entry;
 	struct txd *txd;
+	struct urb *urb;
 	int ack;
 	int ring_full;
 
@@ -1222,7 +1225,8 @@
 
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
-		txd = rt2x00usb_txdesc_addr(entry);;
+		txd = rt2x00usb_txdesc_addr(entry);
+		urb = rt2x00usb_urb(entry);
 
 		if (GET_FLAG(entry, ENTRY_OWNER_NIC))
 			break;
@@ -1242,7 +1246,7 @@
 		 * was succesfull.
 		 */
 		entry->tx_status.ack = 0;
-		if (ack && (entry->urb->status == TX_SUCCESS))
+		if (ack && (urb->status == TX_SUCCESS))
 			entry->tx_status.ack = 1;
 		else {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
@@ -1413,10 +1417,10 @@
  * DMA ring functions.
  */
 static int rt73usb_alloc_ring(struct rt2x00_dev *rt2x00dev,
-	struct data_ring *ring, void (*handler)(void *),
+	unsigned short type, void (*handler)(void *),
 	const u16 max_entries, const u16 data_size, const u16 desc_size)
 {
-	struct data_entry *entry;
+	struct data_ring *ring = &rt2x00dev->ring[type];
 	unsigned int i;
 	int status;
 
@@ -1439,15 +1443,15 @@
 
 	rt2x00_ring_index_clear(ring);
 
+	ring->type = type;
 	ring->stats.limit = max_entries;
-	ring->entry_size = sizeof(struct data_entry);
 	ring->data_size = data_size;
 	ring->desc_size = desc_size;
 
 	/*
 	 * Allocate all ring entries.
 	 */
-	ring->entry = kmalloc(ring->stats.limit * ring->entry_size,
+	ring->entry = kmalloc(ring->stats.limit * sizeof(struct data_entry),
 		GFP_KERNEL);
 	if (!ring->entry)
 		return -ENOMEM;
@@ -1468,20 +1472,19 @@
 	 * addresses.
 	 */
 	status = 0;
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		entry[i].ring = ring;
+		ring->entry[i].ring = ring;
 		if (!status)
-			entry[i].urb = usb_alloc_urb(0, GFP_KERNEL);
+			ring->entry[i].priv = usb_alloc_urb(0, GFP_KERNEL);
 		else
-			entry[i].urb = NULL;
-		if (!entry[i].urb)
+			ring->entry[i].priv = NULL;
+		if (!ring->entry[i].priv)
 			status = -ENOMEM;
-		entry[i].skb = NULL;
-		entry[i].data_addr = ring->data_addr
+		ring->entry[i].skb = NULL;
+		ring->entry[i].data_addr = ring->data_addr
 			+ (i * ring->desc_size)
 			+ (i * ring->data_size);
-		entry[i].data_dma = ring->data_dma
+		ring->entry[i].data_dma = ring->data_dma
 			+ (i * ring->desc_size)
 			+ (i * ring->data_size);
 	}
@@ -1492,16 +1495,16 @@
 static void rt73usb_free_ring(struct rt2x00_dev *rt2x00dev,
 	struct data_ring *ring)
 {
-	struct	data_entry *entry;
+	struct urb *urb;
 	unsigned int i;
 
 	if (!ring->entry)
 		goto exit;
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		usb_kill_urb(entry[i].urb);
-		usb_free_urb(entry[i].urb);
+		urb = rt2x00usb_urb(&ring->entry[i]);
+		usb_kill_urb(urb);
+		usb_free_urb(urb);
 	}
 
 	kfree(ring->entry);
@@ -1526,25 +1529,25 @@
 	}
 
 	if (rt73usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_RX], rt73usb_rxdone,
+		rt2x00dev, RING_RX, rt73usb_rxdone,
 		RX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct rxd)) ||
 	    rt73usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_AC_BK], rt73usb_txdone,
+		rt2x00dev, RING_AC_BK, rt73usb_txdone,
 		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt73usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_AC_BE], rt73usb_txdone,
+		rt2x00dev, RING_AC_BE, rt73usb_txdone,
 		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt73usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_AC_VI], rt73usb_txdone,
+		rt2x00dev, RING_AC_VI, rt73usb_txdone,
 		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt73usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_AC_VO], rt73usb_txdone,
+		rt2x00dev, RING_AC_VO, rt73usb_txdone,
 		 TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt73usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_PRIO], rt73usb_txdone,
+		rt2x00dev, RING_PRIO, rt73usb_txdone,
 		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd)) ||
 	    rt73usb_alloc_ring(
-		rt2x00dev, &rt2x00dev->ring[RING_BEACON], rt73usb_beacondone,
+		rt2x00dev, RING_BEACON, rt73usb_beacondone,
 		BEACON_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd)) ) {
 		ERROR("DMA allocation failed.\n");
 		return -ENOMEM;
@@ -1575,37 +1578,37 @@
 {
 	struct usb_device *usb_dev =
 		interface_to_usbdev(rt2x00dev_usb(rt2x00dev));
-	struct data_entry *entry;
+	struct urb *urb;
 	unsigned int i;
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		entry[i].urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
-		entry[i].urb->transfer_dma = entry[i].data_dma;
+		urb = rt2x00usb_urb(&ring->entry[i]);
+		urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
+		urb->transfer_dma = ring->entry[i].data_dma;
 		usb_fill_bulk_urb(
-			entry[i].urb,
+			urb,
 			usb_dev,
 			usb_rcvbulkpipe(usb_dev, 1),
-			entry[i].data_addr,
+			ring->entry[i].data_addr,
 			ring->entry_size + ring->desc_size,
 			rt73usb_interrupt,
-			&entry[i]);
-		SET_FLAG(&entry[i], ENTRY_OWNER_NIC | ENTRY_TYPE_RX);
-		usb_submit_urb(entry[i].urb, GFP_ATOMIC);
+			&ring->entry[i]);
+		SET_FLAG(&ring->entry[i], ENTRY_OWNER_NIC);
+		usb_submit_urb(urb, GFP_ATOMIC);
 	}
 }
 
 static void rt73usb_init_txring(struct rt2x00_dev *rt2x00dev,
 	struct data_ring *ring)
 {
-	struct data_entry *entry;
+	struct urb *urb;
 	unsigned int i;
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++) {
-		entry[i].urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
-		entry[i].urb->transfer_dma = entry[i].data_dma;
-		CLEAR_FLAGS(&entry[i]);
+		urb = rt2x00usb_urb(&ring->entry[i]);
+		urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
+		urb->transfer_dma = ring->entry[i].data_dma;
+		CLEAR_FLAGS(&ring->entry[i]);
 	}
 }
 
@@ -1847,14 +1850,14 @@
 
 	SET_FLAG(entry, ENTRY_OWNER_NIC);
 	usb_fill_bulk_urb(
-		entry->urb,
+		rt2x00usb_urb(entry),
 		usb_dev,
 		usb_sndbulkpipe(usb_dev, 1),
 		entry->data_addr,
 		skb->len + ring->desc_size,
 		rt73usb_interrupt,
 		entry);
-	usb_submit_urb(entry->urb, GFP_ATOMIC);
+	usb_submit_urb(rt2x00usb_urb(entry), GFP_ATOMIC);
 
 	rt2x00_ring_index_inc(ring);
 
@@ -1866,12 +1869,10 @@
 
 static inline void rt73usb_reset_ring(struct data_ring *ring)
 {
-	struct data_entry *entry;
 	unsigned int i;
 
-	entry = ring->entry;
 	for (i = 0; i < ring->stats.limit; i++)
-		usb_kill_urb(entry[i].urb);
+		usb_kill_urb(ring->entry[i].urb);
 }
 
 static int rt73usb_reset(struct net_device *net_dev)
@@ -2408,14 +2409,14 @@
 
 	SET_FLAG(entry, ENTRY_OWNER_NIC);
 	usb_fill_bulk_urb(
-		entry->urb,
+		rt2x00usb_urb(entry),
 		usb_dev,
 		usb_sndbulkpipe(usb_dev, 1),
 		entry->data_addr,
 		skb->len + rt2x00dev->ring[RING_BEACON].desc_size,
 		rt73usb_interrupt,
 		entry);
-	usb_submit_urb(entry->urb, GFP_ATOMIC);
+	usb_submit_urb(rt2x00usb_urb(entry), GFP_ATOMIC);
 
 	return 0;
 }
diff -rU3 wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.h 
wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.h	
2006-07-23 18:33:18.000000000 +0200
+++ wireless-dev-ringentry/drivers/net/wireless/d80211/rt2x00/rt73usb.h	
2006-07-25 10:07:34.000000000 +0200
@@ -895,6 +895,36 @@
 };
 
 /*
+ * The location of the descriptor is variating and depends
+ * on the fact if it is a TX or RX ring and the length of the packet.
+ * We need some small handlers to properly access the descriptors.
+ */
+static inline struct urb* rt2x00usb_urb(struct data_entry *entry)
+{
+	return (struct urb*)entry->priv;
+}
+
+static inline void* rt2x00usb_rxdata_addr(struct data_entry *entry)
+{
+	return entry->data_addr + entry->ring->desc_size;
+}
+
+static inline void* rt2x00usb_rxdesc_addr(struct data_entry *entry)
+{
+	return entry->data_addr;
+}
+
+static inline void* rt2x00usb_txdata_addr(struct data_entry *entry)
+{
+	return entry->data_addr + entry->ring->desc_size;
+}
+
+static inline void* rt2x00usb_txdesc_addr(struct data_entry *entry)
+{
+	return entry->data_addr;
+}
+
+/*
  * Macro's for converting txpower from EEPROM to dscape value
  * and from dscape value to register value.
  */
