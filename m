From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] igb: split buffer_info into tx_buffer_info and rx_buffer_info
Date: Fri,  7 Oct 2011 00:18:40 -0700
Message-ID: <1317971926-23145-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34234 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759102Ab1JGHSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 03:18:52 -0400
In-Reply-To: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

In order to be able to improve the performance of the TX path it has been
necessary to add addition info to the tx_buffer_info structure.  However a
side effect is that the structure has gotten larger and this in turn has
also increased the size of the RX buffer info structure.  In order to avoid
this in the future I am splitting the single buffer_info structure into two
separate ones and instead I will join them by making the buffer_info
pointer in the ring a union of the two.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |   42 +++++-----
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   15 ++--
 drivers/net/ethernet/intel/igb/igb_main.c    |  123 +++++++++++++-------------
 3 files changed, 92 insertions(+), 88 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index beab918..56c68fc 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -132,27 +132,24 @@ struct vf_data_storage {
 
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
-struct igb_buffer {
+struct igb_tx_buffer {
+	u16 next_to_watch;
+	unsigned long time_stamp;
+	dma_addr_t dma;
+	u32 length;
+	u32 tx_flags;
+	struct sk_buff *skb;
+	unsigned int bytecount;
+	u16 gso_segs;
+	u8 mapped_as_page;
+};
+
+struct igb_rx_buffer {
 	struct sk_buff *skb;
 	dma_addr_t dma;
-	union {
-		/* TX */
-		struct {
-			unsigned long time_stamp;
-			u16 length;
-			u16 next_to_watch;
-			unsigned int bytecount;
-			u16 gso_segs;
-			u8 tx_flags;
-			u8 mapped_as_page;
-		};
-		/* RX */
-		struct {
-			struct page *page;
-			dma_addr_t page_dma;
-			u16 page_offset;
-		};
-	};
+	struct page *page;
+	dma_addr_t page_dma;
+	u32 page_offset;
 };
 
 struct igb_tx_queue_stats {
@@ -191,7 +188,10 @@ struct igb_ring {
 	struct igb_q_vector *q_vector;	/* backlink to q_vector */
 	struct net_device *netdev;	/* back pointer to net_device */
 	struct device *dev;		/* device pointer for dma mapping */
-	struct igb_buffer *buffer_info;	/* array of buffer info structs */
+	union {				/* array of buffer info structs */
+		struct igb_tx_buffer *tx_buffer_info;
+		struct igb_rx_buffer *rx_buffer_info;
+	};
 	void *desc;			/* descriptor ring memory */
 	unsigned long flags;		/* ring specific flags */
 	void __iomem *tail;		/* pointer to ring tail register */
@@ -377,7 +377,7 @@ extern void igb_setup_tctl(struct igb_adapter *);
 extern void igb_setup_rctl(struct igb_adapter *);
 extern netdev_tx_t igb_xmit_frame_ring(struct sk_buff *, struct igb_ring *);
 extern void igb_unmap_and_free_tx_resource(struct igb_ring *,
-					   struct igb_buffer *);
+					   struct igb_tx_buffer *);
 extern void igb_alloc_rx_buffers(struct igb_ring *, u16);
 extern void igb_update_stats(struct igb_adapter *, struct rtnl_link_stats64 *);
 extern bool igb_has_link(struct igb_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index a445c4f..f227fc5 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1579,7 +1579,8 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
                                 unsigned int size)
 {
 	union e1000_adv_rx_desc *rx_desc;
-	struct igb_buffer *buffer_info;
+	struct igb_rx_buffer *rx_buffer_info;
+	struct igb_tx_buffer *tx_buffer_info;
 	int rx_ntc, tx_ntc, count = 0;
 	u32 staterr;
 
@@ -1591,22 +1592,22 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 
 	while (staterr & E1000_RXD_STAT_DD) {
 		/* check rx buffer */
-		buffer_info = &rx_ring->buffer_info[rx_ntc];
+		rx_buffer_info = &rx_ring->rx_buffer_info[rx_ntc];
 
 		/* unmap rx buffer, will be remapped by alloc_rx_buffers */
 		dma_unmap_single(rx_ring->dev,
-		                 buffer_info->dma,
+				 rx_buffer_info->dma,
 				 IGB_RX_HDR_LEN,
 				 DMA_FROM_DEVICE);
-		buffer_info->dma = 0;
+		rx_buffer_info->dma = 0;
 
 		/* verify contents of skb */
-		if (!igb_check_lbtest_frame(buffer_info->skb, size))
+		if (!igb_check_lbtest_frame(rx_buffer_info->skb, size))
 			count++;
 
 		/* unmap buffer on tx side */
-		buffer_info = &tx_ring->buffer_info[tx_ntc];
-		igb_unmap_and_free_tx_resource(tx_ring, buffer_info);
+		tx_buffer_info = &tx_ring->tx_buffer_info[tx_ntc];
+		igb_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
 
 		/* increment rx/tx next to clean counters */
 		rx_ntc++;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 12faa99..2bdc783 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -339,7 +339,6 @@ static void igb_dump(struct igb_adapter *adapter)
 	struct igb_ring *tx_ring;
 	union e1000_adv_tx_desc *tx_desc;
 	struct my_u0 { u64 a; u64 b; } *u0;
-	struct igb_buffer *buffer_info;
 	struct igb_ring *rx_ring;
 	union e1000_adv_rx_desc *rx_desc;
 	u32 staterr;
@@ -376,8 +375,9 @@ static void igb_dump(struct igb_adapter *adapter)
 	printk(KERN_INFO "Queue [NTU] [NTC] [bi(ntc)->dma  ]"
 		" leng ntw timestamp\n");
 	for (n = 0; n < adapter->num_tx_queues; n++) {
+		struct igb_tx_buffer *buffer_info;
 		tx_ring = adapter->tx_ring[n];
-		buffer_info = &tx_ring->buffer_info[tx_ring->next_to_clean];
+		buffer_info = &tx_ring->tx_buffer_info[tx_ring->next_to_clean];
 		printk(KERN_INFO " %5d %5X %5X %016llX %04X %3X %016llX\n",
 			   n, tx_ring->next_to_use, tx_ring->next_to_clean,
 			   (u64)buffer_info->dma,
@@ -413,8 +413,9 @@ static void igb_dump(struct igb_adapter *adapter)
 			"leng  ntw timestamp        bi->skb\n");
 
 		for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
+			struct igb_tx_buffer *buffer_info;
 			tx_desc = IGB_TX_DESC(tx_ring, i);
-			buffer_info = &tx_ring->buffer_info[i];
+			buffer_info = &tx_ring->tx_buffer_info[i];
 			u0 = (struct my_u0 *)tx_desc;
 			printk(KERN_INFO "T [0x%03X]    %016llX %016llX %016llX"
 				" %04X  %3X %016llX %p", i,
@@ -493,7 +494,8 @@ rx_ring_summary:
 			"<-- Adv Rx Write-Back format\n");
 
 		for (i = 0; i < rx_ring->count; i++) {
-			buffer_info = &rx_ring->buffer_info[i];
+			struct igb_rx_buffer *buffer_info;
+			buffer_info = &rx_ring->rx_buffer_info[i];
 			rx_desc = IGB_RX_DESC(rx_ring, i);
 			u0 = (struct my_u0 *)rx_desc;
 			staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
@@ -2576,9 +2578,9 @@ int igb_setup_tx_resources(struct igb_ring *tx_ring)
 	struct device *dev = tx_ring->dev;
 	int size;
 
-	size = sizeof(struct igb_buffer) * tx_ring->count;
-	tx_ring->buffer_info = vzalloc(size);
-	if (!tx_ring->buffer_info)
+	size = sizeof(struct igb_tx_buffer) * tx_ring->count;
+	tx_ring->tx_buffer_info = vzalloc(size);
+	if (!tx_ring->tx_buffer_info)
 		goto err;
 
 	/* round up to nearest 4K */
@@ -2598,7 +2600,7 @@ int igb_setup_tx_resources(struct igb_ring *tx_ring)
 	return 0;
 
 err:
-	vfree(tx_ring->buffer_info);
+	vfree(tx_ring->tx_buffer_info);
 	dev_err(dev,
 		"Unable to allocate memory for the transmit descriptor ring\n");
 	return -ENOMEM;
@@ -2719,9 +2721,9 @@ int igb_setup_rx_resources(struct igb_ring *rx_ring)
 	struct device *dev = rx_ring->dev;
 	int size, desc_len;
 
-	size = sizeof(struct igb_buffer) * rx_ring->count;
-	rx_ring->buffer_info = vzalloc(size);
-	if (!rx_ring->buffer_info)
+	size = sizeof(struct igb_rx_buffer) * rx_ring->count;
+	rx_ring->rx_buffer_info = vzalloc(size);
+	if (!rx_ring->rx_buffer_info)
 		goto err;
 
 	desc_len = sizeof(union e1000_adv_rx_desc);
@@ -2744,8 +2746,8 @@ int igb_setup_rx_resources(struct igb_ring *rx_ring)
 	return 0;
 
 err:
-	vfree(rx_ring->buffer_info);
-	rx_ring->buffer_info = NULL;
+	vfree(rx_ring->rx_buffer_info);
+	rx_ring->rx_buffer_info = NULL;
 	dev_err(dev, "Unable to allocate memory for the receive descriptor"
 		" ring\n");
 	return -ENOMEM;
@@ -3107,8 +3109,8 @@ void igb_free_tx_resources(struct igb_ring *tx_ring)
 {
 	igb_clean_tx_ring(tx_ring);
 
-	vfree(tx_ring->buffer_info);
-	tx_ring->buffer_info = NULL;
+	vfree(tx_ring->tx_buffer_info);
+	tx_ring->tx_buffer_info = NULL;
 
 	/* if not set, then don't free */
 	if (!tx_ring->desc)
@@ -3135,7 +3137,7 @@ static void igb_free_all_tx_resources(struct igb_adapter *adapter)
 }
 
 void igb_unmap_and_free_tx_resource(struct igb_ring *tx_ring,
-				    struct igb_buffer *buffer_info)
+				    struct igb_tx_buffer *buffer_info)
 {
 	if (buffer_info->dma) {
 		if (buffer_info->mapped_as_page)
@@ -3166,21 +3168,21 @@ void igb_unmap_and_free_tx_resource(struct igb_ring *tx_ring,
  **/
 static void igb_clean_tx_ring(struct igb_ring *tx_ring)
 {
-	struct igb_buffer *buffer_info;
+	struct igb_tx_buffer *buffer_info;
 	unsigned long size;
 	unsigned int i;
 
-	if (!tx_ring->buffer_info)
+	if (!tx_ring->tx_buffer_info)
 		return;
 	/* Free all the Tx ring sk_buffs */
 
 	for (i = 0; i < tx_ring->count; i++) {
-		buffer_info = &tx_ring->buffer_info[i];
+		buffer_info = &tx_ring->tx_buffer_info[i];
 		igb_unmap_and_free_tx_resource(tx_ring, buffer_info);
 	}
 
-	size = sizeof(struct igb_buffer) * tx_ring->count;
-	memset(tx_ring->buffer_info, 0, size);
+	size = sizeof(struct igb_tx_buffer) * tx_ring->count;
+	memset(tx_ring->tx_buffer_info, 0, size);
 
 	/* Zero out the descriptor ring */
 	memset(tx_ring->desc, 0, tx_ring->size);
@@ -3211,8 +3213,8 @@ void igb_free_rx_resources(struct igb_ring *rx_ring)
 {
 	igb_clean_rx_ring(rx_ring);
 
-	vfree(rx_ring->buffer_info);
-	rx_ring->buffer_info = NULL;
+	vfree(rx_ring->rx_buffer_info);
+	rx_ring->rx_buffer_info = NULL;
 
 	/* if not set, then don't free */
 	if (!rx_ring->desc)
@@ -3247,12 +3249,12 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 	unsigned long size;
 	u16 i;
 
-	if (!rx_ring->buffer_info)
+	if (!rx_ring->rx_buffer_info)
 		return;
 
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
-		struct igb_buffer *buffer_info = &rx_ring->buffer_info[i];
+		struct igb_rx_buffer *buffer_info = &rx_ring->rx_buffer_info[i];
 		if (buffer_info->dma) {
 			dma_unmap_single(rx_ring->dev,
 			                 buffer_info->dma,
@@ -3279,8 +3281,8 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 		}
 	}
 
-	size = sizeof(struct igb_buffer) * rx_ring->count;
-	memset(rx_ring->buffer_info, 0, size);
+	size = sizeof(struct igb_rx_buffer) * rx_ring->count;
+	memset(rx_ring->rx_buffer_info, 0, size);
 
 	/* Zero out the descriptor ring */
 	memset(rx_ring->desc, 0, rx_ring->size);
@@ -3964,7 +3966,7 @@ static inline int igb_tso(struct igb_ring *tx_ring,
 	struct e1000_adv_tx_context_desc *context_desc;
 	unsigned int i;
 	int err;
-	struct igb_buffer *buffer_info;
+	struct igb_tx_buffer *buffer_info;
 	u32 info = 0, tu_cmd = 0;
 	u32 mss_l4len_idx;
 	u8 l4len;
@@ -3995,7 +3997,7 @@ static inline int igb_tso(struct igb_ring *tx_ring,
 
 	i = tx_ring->next_to_use;
 
-	buffer_info = &tx_ring->buffer_info[i];
+	buffer_info = &tx_ring->tx_buffer_info[i];
 	context_desc = IGB_TX_CTXTDESC(tx_ring, i);
 	/* VLAN MACLEN IPLEN */
 	if (tx_flags & IGB_TX_FLAGS_VLAN)
@@ -4043,14 +4045,14 @@ static inline bool igb_tx_csum(struct igb_ring *tx_ring,
 {
 	struct e1000_adv_tx_context_desc *context_desc;
 	struct device *dev = tx_ring->dev;
-	struct igb_buffer *buffer_info;
+	struct igb_tx_buffer *buffer_info;
 	u32 info = 0, tu_cmd = 0;
 	unsigned int i;
 
 	if ((skb->ip_summed == CHECKSUM_PARTIAL) ||
 	    (tx_flags & IGB_TX_FLAGS_VLAN)) {
 		i = tx_ring->next_to_use;
-		buffer_info = &tx_ring->buffer_info[i];
+		buffer_info = &tx_ring->tx_buffer_info[i];
 		context_desc = IGB_TX_CTXTDESC(tx_ring, i);
 
 		if (tx_flags & IGB_TX_FLAGS_VLAN)
@@ -4126,7 +4128,7 @@ static inline bool igb_tx_csum(struct igb_ring *tx_ring,
 static inline int igb_tx_map(struct igb_ring *tx_ring, struct sk_buff *skb,
 			     unsigned int first)
 {
-	struct igb_buffer *buffer_info;
+	struct igb_tx_buffer *buffer_info;
 	struct device *dev = tx_ring->dev;
 	unsigned int hlen = skb_headlen(skb);
 	unsigned int count = 0, i;
@@ -4135,7 +4137,7 @@ static inline int igb_tx_map(struct igb_ring *tx_ring, struct sk_buff *skb,
 
 	i = tx_ring->next_to_use;
 
-	buffer_info = &tx_ring->buffer_info[i];
+	buffer_info = &tx_ring->tx_buffer_info[i];
 	BUG_ON(hlen >= IGB_MAX_DATA_PER_TXD);
 	buffer_info->length = hlen;
 	/* set time_stamp *before* dma to help avoid a possible race */
@@ -4155,7 +4157,7 @@ static inline int igb_tx_map(struct igb_ring *tx_ring, struct sk_buff *skb,
 		if (i == tx_ring->count)
 			i = 0;
 
-		buffer_info = &tx_ring->buffer_info[i];
+		buffer_info = &tx_ring->tx_buffer_info[i];
 		BUG_ON(len >= IGB_MAX_DATA_PER_TXD);
 		buffer_info->length = len;
 		buffer_info->time_stamp = jiffies;
@@ -4168,12 +4170,12 @@ static inline int igb_tx_map(struct igb_ring *tx_ring, struct sk_buff *skb,
 
 	}
 
-	tx_ring->buffer_info[i].skb = skb;
-	tx_ring->buffer_info[i].tx_flags = skb_shinfo(skb)->tx_flags;
+	buffer_info->skb = skb;
+	buffer_info->tx_flags = skb_shinfo(skb)->tx_flags;
 	/* multiply data chunks by size of headers */
-	tx_ring->buffer_info[i].bytecount = ((gso_segs - 1) * hlen) + skb->len;
-	tx_ring->buffer_info[i].gso_segs = gso_segs;
-	tx_ring->buffer_info[first].next_to_watch = i;
+	buffer_info->bytecount = ((gso_segs - 1) * hlen) + skb->len;
+	buffer_info->gso_segs = gso_segs;
+	tx_ring->tx_buffer_info[first].next_to_watch = i;
 
 	return ++count;
 
@@ -4192,7 +4194,7 @@ dma_error:
 		if (i == 0)
 			i = tx_ring->count;
 		i--;
-		buffer_info = &tx_ring->buffer_info[i];
+		buffer_info = &tx_ring->tx_buffer_info[i];
 		igb_unmap_and_free_tx_resource(tx_ring, buffer_info);
 	}
 
@@ -4204,7 +4206,7 @@ static inline void igb_tx_queue(struct igb_ring *tx_ring,
 				u8 hdr_len)
 {
 	union e1000_adv_tx_desc *tx_desc;
-	struct igb_buffer *buffer_info;
+	struct igb_tx_buffer *buffer_info;
 	u32 olinfo_status = 0, cmd_type_len;
 	unsigned int i = tx_ring->next_to_use;
 
@@ -4240,7 +4242,7 @@ static inline void igb_tx_queue(struct igb_ring *tx_ring,
 	olinfo_status |= ((paylen - hdr_len) << E1000_ADVTXD_PAYLEN_SHIFT);
 
 	do {
-		buffer_info = &tx_ring->buffer_info[i];
+		buffer_info = &tx_ring->tx_buffer_info[i];
 		tx_desc = IGB_TX_DESC(tx_ring, i);
 		tx_desc->read.buffer_addr = cpu_to_le64(buffer_info->dma);
 		tx_desc->read.cmd_type_len =
@@ -4353,7 +4355,7 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	count = igb_tx_map(tx_ring, skb, first);
 	if (!count) {
 		dev_kfree_skb_any(skb);
-		tx_ring->buffer_info[first].time_stamp = 0;
+		tx_ring->tx_buffer_info[first].time_stamp = 0;
 		tx_ring->next_to_use = first;
 		return NETDEV_TX_OK;
 	}
@@ -5551,13 +5553,14 @@ static void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
 /**
  * igb_tx_hwtstamp - utility function which checks for TX time stamp
  * @q_vector: pointer to q_vector containing needed info
- * @buffer: pointer to igb_buffer structure
+ * @buffer: pointer to igb_tx_buffer structure
  *
  * If we were asked to do hardware stamping and such a time stamp is
  * available, then it must have been for this skb here because we only
  * allow only one such packet into the queue.
  */
-static void igb_tx_hwtstamp(struct igb_q_vector *q_vector, struct igb_buffer *buffer_info)
+static void igb_tx_hwtstamp(struct igb_q_vector *q_vector,
+			    struct igb_tx_buffer *buffer_info)
 {
 	struct igb_adapter *adapter = q_vector->adapter;
 	struct e1000_hw *hw = &adapter->hw;
@@ -5585,7 +5588,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 {
 	struct igb_adapter *adapter = q_vector->adapter;
 	struct igb_ring *tx_ring = q_vector->tx_ring;
-	struct igb_buffer *tx_buffer;
+	struct igb_tx_buffer *tx_buffer;
 	union e1000_adv_tx_desc *tx_desc;
 	unsigned int total_bytes = 0, total_packets = 0;
 	unsigned int budget = q_vector->tx_work_limit;
@@ -5594,7 +5597,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 	if (test_bit(__IGB_DOWN, &adapter->state))
 		return true;
 
-	tx_buffer = &tx_ring->buffer_info[i];
+	tx_buffer = &tx_ring->tx_buffer_info[i];
 	tx_desc = IGB_TX_DESC(tx_ring, i);
 
 	for (; budget; budget--) {
@@ -5627,7 +5630,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 			i++;
 			if (unlikely(i == tx_ring->count)) {
 				i = 0;
-				tx_buffer = tx_ring->buffer_info;
+				tx_buffer = tx_ring->tx_buffer_info;
 				tx_desc = IGB_TX_DESC(tx_ring, 0);
 			}
 		} while (eop_desc);
@@ -5643,7 +5646,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 
 	if (tx_ring->detect_tx_hung) {
 		struct e1000_hw *hw = &adapter->hw;
-		u16 eop = tx_ring->buffer_info[i].next_to_watch;
+		u16 eop = tx_ring->tx_buffer_info[i].next_to_watch;
 		union e1000_adv_tx_desc *eop_desc;
 
 		eop_desc = IGB_TX_DESC(tx_ring, eop);
@@ -5651,8 +5654,8 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 		/* Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		tx_ring->detect_tx_hung = false;
-		if (tx_ring->buffer_info[i].time_stamp &&
-		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp +
+		if (tx_ring->tx_buffer_info[i].time_stamp &&
+		    time_after(jiffies, tx_ring->tx_buffer_info[i].time_stamp +
 			       (adapter->tx_timeout_factor * HZ)) &&
 		    !(rd32(E1000_STATUS) & E1000_STATUS_TXOFF)) {
 
@@ -5674,7 +5677,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 				readl(tx_ring->tail),
 				tx_ring->next_to_use,
 				tx_ring->next_to_clean,
-				tx_ring->buffer_info[eop].time_stamp,
+				tx_ring->tx_buffer_info[eop].time_stamp,
 				eop,
 				jiffies,
 				eop_desc->wb.status);
@@ -5802,7 +5805,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 
 	while (staterr & E1000_RXD_STAT_DD) {
-		struct igb_buffer *buffer_info = &rx_ring->buffer_info[i];
+		struct igb_rx_buffer *buffer_info = &rx_ring->rx_buffer_info[i];
 		struct sk_buff *skb = buffer_info->skb;
 		union e1000_adv_rx_desc *next_rxd;
 
@@ -5855,8 +5858,8 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 		}
 
 		if (!(staterr & E1000_RXD_STAT_EOP)) {
-			struct igb_buffer *next_buffer;
-			next_buffer = &rx_ring->buffer_info[i];
+			struct igb_rx_buffer *next_buffer;
+			next_buffer = &rx_ring->rx_buffer_info[i];
 			buffer_info->skb = next_buffer->skb;
 			buffer_info->dma = next_buffer->dma;
 			next_buffer->skb = skb;
@@ -5917,7 +5920,7 @@ next_desc:
 }
 
 static bool igb_alloc_mapped_skb(struct igb_ring *rx_ring,
-				 struct igb_buffer *bi)
+				 struct igb_rx_buffer *bi)
 {
 	struct sk_buff *skb = bi->skb;
 	dma_addr_t dma = bi->dma;
@@ -5951,7 +5954,7 @@ static bool igb_alloc_mapped_skb(struct igb_ring *rx_ring,
 }
 
 static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
-				  struct igb_buffer *bi)
+				  struct igb_rx_buffer *bi)
 {
 	struct page *page = bi->page;
 	dma_addr_t page_dma = bi->page_dma;
@@ -5990,11 +5993,11 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 void igb_alloc_rx_buffers(struct igb_ring *rx_ring, u16 cleaned_count)
 {
 	union e1000_adv_rx_desc *rx_desc;
-	struct igb_buffer *bi;
+	struct igb_rx_buffer *bi;
 	u16 i = rx_ring->next_to_use;
 
 	rx_desc = IGB_RX_DESC(rx_ring, i);
-	bi = &rx_ring->buffer_info[i];
+	bi = &rx_ring->rx_buffer_info[i];
 	i -= rx_ring->count;
 
 	while (cleaned_count--) {
@@ -6015,7 +6018,7 @@ void igb_alloc_rx_buffers(struct igb_ring *rx_ring, u16 cleaned_count)
 		i++;
 		if (unlikely(!i)) {
 			rx_desc = IGB_RX_DESC(rx_ring, 0);
-			bi = rx_ring->buffer_info;
+			bi = rx_ring->rx_buffer_info;
 			i -= rx_ring->count;
 		}
 
-- 
1.7.6.4
