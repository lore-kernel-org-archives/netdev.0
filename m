From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 2/11] 82544 PCI-X hang fix + TSO updates
Date: Mon, 8 Sep 2003 20:14:12 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081839110.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Bug fix: 82544 hang with PCI-X: if outgoing Tx buffers terminate
  within evenly-aligned dwords, and the device is sharing the bus
  segment with another PCI-X device, 82544 can hang the bus on a 
  split-completion transaction.  Fix is to split buffer into two
  buffers with the first one not terminating within evenly-aligned
  dword address, and the second one being 4-bytes, which goes as a
  non-split-conpletion PCI-X transaction.
* 8254x controllers that support TSO do an internal calculation to
  make sure there is enough FIFO space to handle the overhead
  of each TSO segment before DMA'ing TSO data from host memory.  The 
  internal calculation is dependent on the mss of the TSO (defines
  the number of segments), but the reserved space is a constant, so
  we need to adjust the maximum size of each buffer queued to the 
  hardware to hold the equation and not overrun the FIFO.  This is
  per TSO because the mss can change from one send to the next.

---------------

diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000.h linux-2.6.0-test4/drivers/net/e1000.new/e1000.h
--- linux-2.6.0-test4/drivers/net/e1000/e1000.h	2003-08-22 16:50:56.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000.h	2003-09-08 09:13:16.000000000 -0700
@@ -194,6 +194,7 @@ struct e1000_adapter {
 	uint32_t tx_head_addr;
 	uint32_t tx_fifo_size;
 	atomic_t tx_fifo_stall;
+	boolean_t pcix_82544;
 
 	/* RX */
 	struct e1000_desc_ring rx_ring;
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_main.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_main.c	2003-08-22 16:54:23.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c	2003-09-08 09:13:11.000000000 -0700
@@ -820,6 +820,12 @@ e1000_configure_tx(struct e1000_adapter 
 		adapter->txd_cmd |= E1000_TXD_CMD_RS;
 	else
 		adapter->txd_cmd |= E1000_TXD_CMD_RPS;
+
+	/* Cache if we're 82544 running in PCI-X because we'll
+	 * need this to apply a workaround later in the send path. */
+	if(adapter->hw.mac_type == e1000_82544 &&
+	   adapter->hw.bus_type == e1000_bus_type_pcix)
+		adapter->pcix_82544 = 1;
 }
 
 /**
@@ -1512,11 +1518,18 @@ e1000_tx_map(struct e1000_adapter *adapt
 {
 	struct e1000_desc_ring *tx_ring = &adapter->tx_ring;
 	struct e1000_buffer *buffer_info;
-	int len = skb->len;
+	unsigned int len = skb->len, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int offset = 0, size, count = 0, i;
 
 #ifdef NETIF_F_TSO
-	unsigned int tso = skb_shinfo(skb)->tso_size;
+	unsigned int mss = skb_shinfo(skb)->tso_size;
+	/* The controller does a simple calculation to 
+	 * make sure there is enough room in the FIFO before
+	 * initiating the DMA for each buffer.  The calc is:
+	 * 4 = ceil(buffer len/mss).  To make sure we don't
+	 * overrun the FIFO, adjust the max buffer len if mss
+	 * drops. */
+	if(mss) max_per_txd = min(mss << 2, max_per_txd);
 #endif
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
@@ -1526,13 +1520,20 @@ e1000_tx_map(struct e1000_adapter *adapt
 
 	while(len) {
 		buffer_info = &tx_ring->buffer_info[i];
-		size = min(len, E1000_MAX_DATA_PER_TXD);
+		size = min(len, max_per_txd);
 #ifdef NETIF_F_TSO
 		/* Workaround for premature desc write-backs
 		 * in TSO mode.  Append 4-byte sentinel desc */
-		if(tso && !nr_frags && size == len && size > 4)
+		if(mss && !nr_frags && size == len && size > 8)
 			size -= 4;
 #endif
+		/* Workaround for potential 82544 hang in PCI-X.  Avoid
+		 * terminating buffers within evenly-aligned dwords. */
+		if(adapter->pcix_82544 &&
+		   !((unsigned long)(skb->data + offset + size - 1) & 4) &&
+		   size > 4)
+			size -= 4;
+
 		buffer_info->length = size;
 		buffer_info->dma =
 			pci_map_single(adapter->pdev,
@@ -1552,22 +1546,30 @@ e1000_tx_map(struct e1000_adapter *adapt
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = 0;
+		offset = frag->page_offset;
 
 		while(len) {
 			buffer_info = &tx_ring->buffer_info[i];
-			size = min(len, E1000_MAX_DATA_PER_TXD);
+			size = min(len, max_per_txd);
 #ifdef NETIF_F_TSO
 			/* Workaround for premature desc write-backs
 			 * in TSO mode.  Append 4-byte sentinel desc */
-			if(tso && f == (nr_frags-1) && size == len && size > 4)
+			if(mss && f == (nr_frags-1) && size == len && size > 8)
 				size -= 4;
 #endif
+			/* Workaround for potential 82544 hang in PCI-X.
+			 * Avoid terminating buffers within evenly-aligned
+			 * dwords. */
+			if(adapter->pcix_82544 &&
+			   !((unsigned long)(frag->page+offset+size-1) & 4) &&
+			   size > 4)
+				size -= 4;
+
 			buffer_info->length = size;
 			buffer_info->dma =
 				pci_map_page(adapter->pdev,
 					frag->page,
-					frag->page_offset + offset,
+					offset,
 					size,
 					PCI_DMA_TODEVICE);
 			buffer_info->time_stamp = jiffies;
@@ -1578,6 +1606,31 @@ e1000_tx_map(struct e1000_adapter *adapt
 			if(++i == tx_ring->count) i = 0;
 		}
 	}
+
+	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count) {
+
+		/* There aren't enough descriptors available to queue up
+		 * this send, so undo the mapping and abort the send. 
+		 * We could have done the check before we mapped the skb,
+		 * but because of all the workarounds (above), it's too
+		 * difficult to predict how many we're going to need.*/
+		i = first;
+
+		while(count--) {
+			buffer_info = &tx_ring->buffer_info[i];
+			if(buffer_info->dma) {
+				pci_unmap_page(adapter->pdev,
+					       buffer_info->dma,
+					       buffer_info->length,
+					       PCI_DMA_TODEVICE);
+				buffer_info->dma = 0;
+			}
+			if(++i == tx_ring->count) i = 0;
+		}
+
+		return 0;
+	}
+
 	i = (i == 0) ? tx_ring->count - 1 : i - 1;
 	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;
@@ -1672,29 +1725,19 @@ no_fifo_stall_required:
 	return 0;
 }
 
-/* Tx Descriptors needed, worst case */
-#define TXD_USE_COUNT(S) (((S) >> E1000_MAX_TXD_PWR) + \
-			 (((S) & (E1000_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
-#define DESC_NEEDED TXD_USE_COUNT(MAX_JUMBO_FRAME_SIZE) + \
-	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1
-
 static int
 e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev->priv;
 	unsigned int first;
 	unsigned int tx_flags = 0;
+	int count;
 
 	if(skb->len <= 0) {
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
 
-	if(E1000_DESC_UNUSED(&adapter->tx_ring) < DESC_NEEDED) {
-		netif_stop_queue(netdev);
-		return 1;
-	}
-
 	if(adapter->hw.mac_type == e1000_82547) {
 		if(e1000_82547_fifo_workaround(adapter, skb)) {
 			netif_stop_queue(netdev);
@@ -1715,7 +1758,12 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	else if(e1000_tx_csum(adapter, skb))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
 
-	e1000_tx_queue(adapter, e1000_tx_map(adapter, skb, first), tx_flags);
+	if((count = e1000_tx_map(adapter, skb, first)))
+		e1000_tx_queue(adapter, count, tx_flags);
+	else {
+		netif_stop_queue(netdev);
+		return 1;
+	}
 
 	netdev->trans_start = jiffies;
 
