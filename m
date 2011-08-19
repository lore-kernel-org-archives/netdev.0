From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] ixgbe: Refactor transmit map and cleanup routines
Date: Fri, 19 Aug 2011 06:11:24 -0700
Message-ID: <1313759486-23575-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313759486-23575-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65409 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328Ab1HSNLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 09:11:31 -0400
In-Reply-To: <1313759486-23575-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch implements a partial refactor of the TX map/queue and cleanup
routines.  It merges the map and queue functionality and as a result
improves the transmit performance by avoiding unnecessary reads from memory.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   13 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  450 +++++++++++++------------
 2 files changed, 247 insertions(+), 216 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index e04a8e4..a12fd9f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -96,6 +96,7 @@
 #define IXGBE_TX_FLAGS_IPV4		(u32)(1 << 3)
 #define IXGBE_TX_FLAGS_FCOE		(u32)(1 << 4)
 #define IXGBE_TX_FLAGS_FSO		(u32)(1 << 5)
+#define IXGBE_TX_FLAGS_MAPPED_AS_PAGE	(u32)(1 << 6)
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_MASK   0x0000e000
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
@@ -141,14 +142,14 @@ struct vf_macvlans {
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct ixgbe_tx_buffer {
-	struct sk_buff *skb;
-	dma_addr_t dma;
+	union ixgbe_adv_tx_desc *next_to_watch;
 	unsigned long time_stamp;
-	u16 length;
-	u16 next_to_watch;
-	unsigned int bytecount;
+	dma_addr_t dma;
+	u32 length;
+	u32 tx_flags;
+	struct sk_buff *skb;
+	u32 bytecount;
 	u16 gso_segs;
-	u8 mapped_as_page;
 };
 
 struct ixgbe_rx_buffer {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index faa83ce..d9c1625 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -385,7 +385,7 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 		tx_ring = adapter->tx_ring[n];
 		tx_buffer_info =
 			&tx_ring->tx_buffer_info[tx_ring->next_to_clean];
-		pr_info(" %5d %5X %5X %016llX %04X %3X %016llX\n",
+		pr_info(" %5d %5X %5X %016llX %04X %p %016llX\n",
 			   n, tx_ring->next_to_use, tx_ring->next_to_clean,
 			   (u64)tx_buffer_info->dma,
 			   tx_buffer_info->length,
@@ -424,7 +424,7 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
 			u0 = (struct my_u0 *)tx_desc;
 			pr_info("T [0x%03X]    %016llX %016llX %016llX"
-				" %04X  %3X %016llX %p", i,
+				" %04X  %p %016llX %p", i,
 				le64_to_cpu(u0->a),
 				le64_to_cpu(u0->b),
 				(u64)tx_buffer_info->dma,
@@ -643,27 +643,31 @@ static inline void ixgbe_irq_rearm_queues(struct ixgbe_adapter *adapter,
 	}
 }
 
-void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *tx_ring,
-				      struct ixgbe_tx_buffer *tx_buffer_info)
+static inline void ixgbe_unmap_tx_resource(struct ixgbe_ring *ring,
+					   struct ixgbe_tx_buffer *tx_buffer)
 {
-	if (tx_buffer_info->dma) {
-		if (tx_buffer_info->mapped_as_page)
-			dma_unmap_page(tx_ring->dev,
-				       tx_buffer_info->dma,
-				       tx_buffer_info->length,
-				       DMA_TO_DEVICE);
+	if (tx_buffer->dma) {
+		if (tx_buffer->tx_flags & IXGBE_TX_FLAGS_MAPPED_AS_PAGE)
+			dma_unmap_page(ring->dev,
+			               tx_buffer->dma,
+			               tx_buffer->length,
+			               DMA_TO_DEVICE);
 		else
-			dma_unmap_single(tx_ring->dev,
-					 tx_buffer_info->dma,
-					 tx_buffer_info->length,
-					 DMA_TO_DEVICE);
-		tx_buffer_info->dma = 0;
+			dma_unmap_single(ring->dev,
+			                 tx_buffer->dma,
+			                 tx_buffer->length,
+			                 DMA_TO_DEVICE);
 	}
-	if (tx_buffer_info->skb) {
+	tx_buffer->dma = 0;
+}
+
+void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *tx_ring,
+				      struct ixgbe_tx_buffer *tx_buffer_info)
+{
+	ixgbe_unmap_tx_resource(tx_ring, tx_buffer_info);
+	if (tx_buffer_info->skb)
 		dev_kfree_skb_any(tx_buffer_info->skb);
-		tx_buffer_info->skb = NULL;
-	}
-	tx_buffer_info->time_stamp = 0;
+	tx_buffer_info->skb = NULL;
 	/* tx_buffer_info must be completely set up in the transmit path */
 }
 
@@ -797,56 +801,72 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 			       struct ixgbe_ring *tx_ring)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	union ixgbe_adv_tx_desc *tx_desc, *eop_desc;
-	struct ixgbe_tx_buffer *tx_buffer_info;
+	struct ixgbe_tx_buffer *tx_buffer;
+	union ixgbe_adv_tx_desc *tx_desc;
 	unsigned int total_bytes = 0, total_packets = 0;
-	u16 i, eop, count = 0;
+	u16 i = tx_ring->next_to_clean;
+	u16 count;
 
-	i = tx_ring->next_to_clean;
-	eop = tx_ring->tx_buffer_info[i].next_to_watch;
-	eop_desc = IXGBE_TX_DESC_ADV(tx_ring, eop);
+	tx_buffer = &tx_ring->tx_buffer_info[i];
+	tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
 
-	while ((eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) &&
-	       (count < q_vector->tx.work_limit)) {
-		bool cleaned = false;
-		rmb(); /* read buffer_info after eop_desc */
-		for ( ; !cleaned; count++) {
-			tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
-			tx_buffer_info = &tx_ring->tx_buffer_info[i];
+	for (count = 0; count < q_vector->tx.work_limit; count++) {
+		union ixgbe_adv_tx_desc *eop_desc = tx_buffer->next_to_watch;
+
+		/* if next_to_watch is not set then there is no work pending */
+		if (!eop_desc)
+			break;
+
+		/* if DD is not set pending work has not been completed */
+		if (!(eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)))
+			break;
+
+		/* count the packet as being completed */
+		tx_ring->tx_stats.completed++;
+
+		/* clear next_to_watch to prevent false hangs */
+		tx_buffer->next_to_watch = NULL;
 
+		/* prevent any other reads prior to eop_desc being verified */
+		rmb();
+
+		do {
+			ixgbe_unmap_tx_resource(tx_ring, tx_buffer);
 			tx_desc->wb.status = 0;
-			cleaned = (i == eop);
+			if (likely(tx_desc == eop_desc)) {
+				eop_desc = NULL;
+				dev_kfree_skb_any(tx_buffer->skb);
+				tx_buffer->skb = NULL;
+
+				total_bytes += tx_buffer->bytecount;
+				total_packets += tx_buffer->gso_segs;
+			}
 
+			tx_buffer++;
+			tx_desc++;
 			i++;
-			if (i == tx_ring->count)
+			if (unlikely(i == tx_ring->count)) {
 				i = 0;
 
-			if (cleaned && tx_buffer_info->skb) {
-				total_bytes += tx_buffer_info->bytecount;
-				total_packets += tx_buffer_info->gso_segs;
+				tx_buffer = tx_ring->tx_buffer_info;
+				tx_desc = IXGBE_TX_DESC_ADV(tx_ring, 0);
 			}
 
-			ixgbe_unmap_and_free_tx_resource(tx_ring,
-							 tx_buffer_info);
-		}
-
-		tx_ring->tx_stats.completed++;
-		eop = tx_ring->tx_buffer_info[i].next_to_watch;
-		eop_desc = IXGBE_TX_DESC_ADV(tx_ring, eop);
+		} while (eop_desc);
 	}
 
 	tx_ring->next_to_clean = i;
+	u64_stats_update_begin(&tx_ring->syncp);
 	tx_ring->stats.bytes += total_bytes;
 	tx_ring->stats.packets += total_packets;
-	u64_stats_update_begin(&tx_ring->syncp);
+	u64_stats_update_end(&tx_ring->syncp);
 	q_vector->tx.total_bytes += total_bytes;
 	q_vector->tx.total_packets += total_packets;
-	u64_stats_update_end(&tx_ring->syncp);
 
 	if (check_for_tx_hang(tx_ring) && ixgbe_check_tx_hang(tx_ring)) {
 		/* schedule immediate reset if we believe we hung */
 		struct ixgbe_hw *hw = &adapter->hw;
-		tx_desc = IXGBE_TX_DESC_ADV(tx_ring, eop);
+		tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
 		e_err(drv, "Detected Tx Unit Hang\n"
 			"  Tx Queue             <%d>\n"
 			"  TDH, TDT             <%x>, <%x>\n"
@@ -858,8 +878,8 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 			tx_ring->queue_index,
 			IXGBE_READ_REG(hw, IXGBE_TDH(tx_ring->reg_idx)),
 			IXGBE_READ_REG(hw, IXGBE_TDT(tx_ring->reg_idx)),
-			tx_ring->next_to_use, eop,
-			tx_ring->tx_buffer_info[eop].time_stamp, jiffies);
+			tx_ring->next_to_use, i,
+			tx_ring->tx_buffer_info[i].time_stamp, jiffies);
 
 		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
 
@@ -6406,185 +6426,179 @@ static bool ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 	return (skb->ip_summed == CHECKSUM_PARTIAL);
 }
 
-static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
-			struct ixgbe_ring *tx_ring,
-			struct sk_buff *skb, u32 tx_flags,
-			unsigned int first, const u8 hdr_len)
+static __le32 ixgbe_tx_cmd_type(u32 tx_flags)
 {
-	struct device *dev = tx_ring->dev;
-	struct ixgbe_tx_buffer *tx_buffer_info;
-	unsigned int len;
-	unsigned int total = skb->len;
-	unsigned int offset = 0, size, count = 0;
-	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
-	unsigned int f;
-	unsigned int bytecount = skb->len;
-	u16 gso_segs = 1;
-	u16 i;
+	/* set type for advanced descriptor with frame checksum insertion */
+	__le32 cmd_type = cpu_to_le32(IXGBE_ADVTXD_DTYP_DATA |
+				      IXGBE_ADVTXD_DCMD_IFCS |
+				      IXGBE_ADVTXD_DCMD_DEXT);
 
-	i = tx_ring->next_to_use;
+	/* set HW vlan bit if vlan is present */
+	if (tx_flags & IXGBE_TX_FLAGS_VLAN)
+		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_DCMD_VLE);
 
-	if (tx_flags & IXGBE_TX_FLAGS_FCOE)
-		/* excluding fcoe_crc_eof for FCoE */
-		total -= sizeof(struct fcoe_crc_eof);
+	/* set segmentation enable bits for TSO/FSO */
+#ifdef IXGBE_FCOE
+	if ((tx_flags & IXGBE_TX_FLAGS_TSO) || (tx_flags & IXGBE_TX_FLAGS_FSO))
+#else
+	if (tx_flags & IXGBE_TX_FLAGS_TSO)
+#endif
+		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_DCMD_TSE);
 
-	len = min(skb_headlen(skb), total);
-	while (len) {
-		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
-
-		tx_buffer_info->length = size;
-		tx_buffer_info->mapped_as_page = false;
-		tx_buffer_info->dma = dma_map_single(dev,
-						     skb->data + offset,
-						     size, DMA_TO_DEVICE);
-		if (dma_mapping_error(dev, tx_buffer_info->dma))
-			goto dma_error;
-		tx_buffer_info->time_stamp = jiffies;
-		tx_buffer_info->next_to_watch = i;
+	return cmd_type;
+}
 
-		len -= size;
-		total -= size;
-		offset += size;
-		count++;
+static __le32 ixgbe_tx_olinfo_status(u32 tx_flags, unsigned int paylen)
+{
+	__le32 olinfo_status =
+		cpu_to_le32(paylen << IXGBE_ADVTXD_PAYLEN_SHIFT);
 
-		if (len) {
-			i++;
-			if (i == tx_ring->count)
-				i = 0;
-		}
+	if (tx_flags & IXGBE_TX_FLAGS_TSO) {
+		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_POPTS_TXSM |
+					    (1 << IXGBE_ADVTXD_IDX_SHIFT));
+		/* enble IPv4 checksum for TSO */
+		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
+			olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_POPTS_IXSM);
 	}
 
-	for (f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+	/* enable L4 checksum for TSO and TX checksum offload */
+	if (tx_flags & IXGBE_TX_FLAGS_CSUM)
+		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_POPTS_TXSM);
 
-		frag = &skb_shinfo(skb)->frags[f];
-		len = min((unsigned int)frag->size, total);
-		offset = frag->page_offset;
+#ifdef IXGBE_FCOE
+	/* use index 1 context for FCOE/FSO */
+	if (tx_flags & IXGBE_TX_FLAGS_FCOE)
+		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_CC |
+					    (1 << IXGBE_ADVTXD_IDX_SHIFT));
 
-		while (len) {
-			i++;
-			if (i == tx_ring->count)
-				i = 0;
+#endif
+	return olinfo_status;
+}
 
-			tx_buffer_info = &tx_ring->tx_buffer_info[i];
-			size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
-
-			tx_buffer_info->length = size;
-			tx_buffer_info->dma = dma_map_page(dev,
-							   frag->page,
-							   offset, size,
-							   DMA_TO_DEVICE);
-			tx_buffer_info->mapped_as_page = true;
-			if (dma_mapping_error(dev, tx_buffer_info->dma))
-				goto dma_error;
-			tx_buffer_info->time_stamp = jiffies;
-			tx_buffer_info->next_to_watch = i;
-
-			len -= size;
-			total -= size;
-			offset += size;
-			count++;
+#define IXGBE_TXD_CMD (IXGBE_TXD_CMD_EOP | \
+		       IXGBE_TXD_CMD_RS)
+
+static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
+			 struct sk_buff *skb,
+			 struct ixgbe_tx_buffer *first,
+			 u32 tx_flags,
+			 const u8 hdr_len)
+{
+	struct device *dev = tx_ring->dev;
+	struct ixgbe_tx_buffer *tx_buffer_info;
+	union ixgbe_adv_tx_desc *tx_desc;
+	dma_addr_t dma;
+	__le32 cmd_type, olinfo_status;
+	struct skb_frag_struct *frag;
+	unsigned int f = 0;
+	unsigned int data_len = skb->data_len;
+	unsigned int size = skb_headlen(skb);
+	u32 offset = 0;
+	u32 paylen = skb->len - hdr_len;
+	u16 i = tx_ring->next_to_use;
+	u16 gso_segs;
+
+#ifdef IXGBE_FCOE
+	if (tx_flags & IXGBE_TX_FLAGS_FCOE) {
+		if (data_len >= sizeof(struct fcoe_crc_eof)) {
+			data_len -= sizeof(struct fcoe_crc_eof);
+		} else {
+			size -= sizeof(struct fcoe_crc_eof) - data_len;
+			data_len = 0;
 		}
-		if (total == 0)
-			break;
 	}
 
-	if (tx_flags & IXGBE_TX_FLAGS_TSO)
-		gso_segs = skb_shinfo(skb)->gso_segs;
-#ifdef IXGBE_FCOE
-	/* adjust for FCoE Sequence Offload */
-	else if (tx_flags & IXGBE_TX_FLAGS_FSO)
-		gso_segs = DIV_ROUND_UP(skb->len - hdr_len,
-					skb_shinfo(skb)->gso_size);
-#endif /* IXGBE_FCOE */
-	bytecount += (gso_segs - 1) * hdr_len;
+#endif
+	dma = dma_map_single(dev, skb->data, size, DMA_TO_DEVICE);
+	if (dma_mapping_error(dev, dma))
+		goto dma_error;
 
-	/* multiply data chunks by size of headers */
-	tx_ring->tx_buffer_info[i].bytecount = bytecount;
-	tx_ring->tx_buffer_info[i].gso_segs = gso_segs;
-	tx_ring->tx_buffer_info[i].skb = skb;
-	tx_ring->tx_buffer_info[first].next_to_watch = i;
+	cmd_type = ixgbe_tx_cmd_type(tx_flags);
+	olinfo_status = ixgbe_tx_olinfo_status(tx_flags, paylen);
 
-	return count;
+	tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
 
-dma_error:
-	e_dev_err("TX DMA map failed\n");
+	for (;;) {
+		while (size > IXGBE_MAX_DATA_PER_TXD) {
+			tx_desc->read.buffer_addr = cpu_to_le64(dma + offset);
+			tx_desc->read.cmd_type_len =
+				cmd_type | cpu_to_le32(IXGBE_MAX_DATA_PER_TXD);
+			tx_desc->read.olinfo_status = olinfo_status;
 
-	/* clear timestamp and dma mappings for failed tx_buffer_info map */
-	tx_buffer_info->dma = 0;
-	tx_buffer_info->time_stamp = 0;
-	tx_buffer_info->next_to_watch = 0;
-	if (count)
-		count--;
+			offset += IXGBE_MAX_DATA_PER_TXD;
+			size -= IXGBE_MAX_DATA_PER_TXD;
+
+			tx_desc++;
+			i++;
+			if (i == tx_ring->count) {
+				tx_desc = IXGBE_TX_DESC_ADV(tx_ring, 0);
+				i = 0;
+			}
+		}
 
-	/* clear timestamp and dma mappings for remaining portion of packet */
-	while (count--) {
-		if (i == 0)
-			i += tx_ring->count;
-		i--;
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		ixgbe_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
-	}
+		tx_buffer_info->length = offset + size;
+		tx_buffer_info->tx_flags = tx_flags;
+		tx_buffer_info->dma = dma;
 
-	return 0;
-}
+		tx_desc->read.buffer_addr = cpu_to_le64(dma + offset);
+		tx_desc->read.cmd_type_len = cmd_type | cpu_to_le32(size);
+		tx_desc->read.olinfo_status = olinfo_status;
 
-static void ixgbe_tx_queue(struct ixgbe_ring *tx_ring,
-			   int tx_flags, int count, u32 paylen, u8 hdr_len)
-{
-	union ixgbe_adv_tx_desc *tx_desc = NULL;
-	struct ixgbe_tx_buffer *tx_buffer_info;
-	u32 olinfo_status = 0, cmd_type_len = 0;
-	unsigned int i;
-	u32 txd_cmd = IXGBE_TXD_CMD_EOP | IXGBE_TXD_CMD_RS | IXGBE_TXD_CMD_IFCS;
-
-	cmd_type_len |= IXGBE_ADVTXD_DTYP_DATA;
+		if (!data_len)
+			break;
 
-	cmd_type_len |= IXGBE_ADVTXD_DCMD_IFCS | IXGBE_ADVTXD_DCMD_DEXT;
+		frag = &skb_shinfo(skb)->frags[f];
+#ifdef IXGBE_FCOE
+		size = min_t(unsigned int, data_len, frag->size);
+#else
+		size = frag->size;
+#endif
+		data_len -= size;
+		f++;
 
-	if (tx_flags & IXGBE_TX_FLAGS_VLAN)
-		cmd_type_len |= IXGBE_ADVTXD_DCMD_VLE;
+		offset = 0;
+		tx_flags |= IXGBE_TX_FLAGS_MAPPED_AS_PAGE;
 
-	if (tx_flags & IXGBE_TX_FLAGS_TSO) {
-		cmd_type_len |= IXGBE_ADVTXD_DCMD_TSE;
+		dma = dma_map_page(dev, frag->page, frag->page_offset,
+				   size, DMA_TO_DEVICE);
+		if (dma_mapping_error(dev, dma))
+			goto dma_error;
 
-		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
-				 IXGBE_ADVTXD_POPTS_SHIFT;
+		tx_desc++;
+		i++;
+		if (i == tx_ring->count) {
+			tx_desc = IXGBE_TX_DESC_ADV(tx_ring, 0);
+			i = 0;
+		}
+	}
 
-		/* use index 1 context for tso */
-		olinfo_status |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
-		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
-			olinfo_status |= IXGBE_TXD_POPTS_IXSM <<
-					 IXGBE_ADVTXD_POPTS_SHIFT;
+	tx_desc->read.cmd_type_len |= cpu_to_le32(IXGBE_TXD_CMD);
 
-	} else if (tx_flags & IXGBE_TX_FLAGS_CSUM)
-		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
-				 IXGBE_ADVTXD_POPTS_SHIFT;
+	i++;
+	if (i == tx_ring->count)
+		i = 0;
 
-	if (tx_flags & IXGBE_TX_FLAGS_FCOE) {
-		olinfo_status |= IXGBE_ADVTXD_CC;
-		olinfo_status |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
-		if (tx_flags & IXGBE_TX_FLAGS_FSO)
-			cmd_type_len |= IXGBE_ADVTXD_DCMD_TSE;
-	}
+	tx_ring->next_to_use = i;
 
-	olinfo_status |= ((paylen - hdr_len) << IXGBE_ADVTXD_PAYLEN_SHIFT);
+	if (tx_flags & IXGBE_TX_FLAGS_TSO)
+		gso_segs = skb_shinfo(skb)->gso_segs;
+#ifdef IXGBE_FCOE
+	/* adjust for FCoE Sequence Offload */
+	else if (tx_flags & IXGBE_TX_FLAGS_FSO)
+		gso_segs = DIV_ROUND_UP(skb->len - hdr_len,
+					skb_shinfo(skb)->gso_size);
+#endif /* IXGBE_FCOE */
+	else
+		gso_segs = 1;
 
-	i = tx_ring->next_to_use;
-	while (count--) {
-		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
-		tx_desc->read.buffer_addr = cpu_to_le64(tx_buffer_info->dma);
-		tx_desc->read.cmd_type_len =
-			cpu_to_le32(cmd_type_len | tx_buffer_info->length);
-		tx_desc->read.olinfo_status = cpu_to_le32(olinfo_status);
-		i++;
-		if (i == tx_ring->count)
-			i = 0;
-	}
+	/* multiply data chunks by size of headers */
+	tx_buffer_info->bytecount = paylen + (gso_segs * hdr_len);
+	tx_buffer_info->gso_segs = gso_segs;
+	tx_buffer_info->skb = skb;
 
-	tx_desc->read.cmd_type_len |= cpu_to_le32(txd_cmd);
+	/* set the timestamp */
+	first->time_stamp = jiffies;
 
 	/*
 	 * Force memory writes to complete before letting h/w
@@ -6594,8 +6608,30 @@ static void ixgbe_tx_queue(struct ixgbe_ring *tx_ring,
 	 */
 	wmb();
 
-	tx_ring->next_to_use = i;
+	/* set next_to_watch value indicating a packet is present */
+	first->next_to_watch = tx_desc;
+
+	/* notify HW of packet */
 	writel(i, tx_ring->tail);
+
+	return;
+dma_error:
+	dev_err(dev, "TX DMA map failed\n");
+
+	/* clear dma mappings for failed tx_buffer_info map */
+	for (;;) {
+		tx_buffer_info = &tx_ring->tx_buffer_info[i];
+		ixgbe_unmap_tx_resource(tx_ring, tx_buffer_info);
+		if (tx_buffer_info == first)
+			break;
+		if (i == 0)
+			i = tx_ring->count;
+		i--;
+	}
+
+	dev_kfree_skb_any(skb);
+
+	tx_ring->next_to_use = i;
 }
 
 static void ixgbe_atr(struct ixgbe_ring *ring, struct sk_buff *skb,
@@ -6742,12 +6778,12 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			  struct ixgbe_adapter *adapter,
 			  struct ixgbe_ring *tx_ring)
 {
+	struct ixgbe_tx_buffer *first;
 	int tso;
-	u32  tx_flags = 0;
+	u32 tx_flags = 0;
 #if PAGE_SIZE > IXGBE_MAX_DATA_PER_TXD
 	unsigned short f;
 #endif
-	u16 first;
 	u16 count = TXD_USE_COUNT(skb_headlen(skb));
 	__be16 protocol;
 	u8 hdr_len = 0;
@@ -6796,7 +6832,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 
 #endif
 	/* record the location of the first descriptor for this packet */
-	first = tx_ring->next_to_use;
+	first = &tx_ring->tx_buffer_info[tx_ring->next_to_use];
 
 	if (tx_flags & IXGBE_TX_FLAGS_FCOE) {
 #ifdef IXGBE_FCOE
@@ -6817,22 +6853,16 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			tx_flags |= IXGBE_TX_FLAGS_TSO;
 		else if (ixgbe_tx_csum(tx_ring, skb, tx_flags, protocol))
 			tx_flags |= IXGBE_TX_FLAGS_CSUM;
-	}
 
-	count = ixgbe_tx_map(adapter, tx_ring, skb, tx_flags, first, hdr_len);
-	if (count) {
 		/* add the ATR filter if ATR is on */
 		if (test_bit(__IXGBE_TX_FDIR_INIT_DONE, &tx_ring->state))
 			ixgbe_atr(tx_ring, skb, tx_flags, protocol);
-		ixgbe_tx_queue(tx_ring, tx_flags, count, skb->len, hdr_len);
-		ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
-
-	} else {
-		tx_ring->tx_buffer_info[first].time_stamp = 0;
-		tx_ring->next_to_use = first;
-		goto out_drop;
 	}
 
+	ixgbe_tx_map(tx_ring, skb, first, tx_flags, hdr_len);
+
+	ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
+
 	return NETDEV_TX_OK;
 
 out_drop:
-- 
1.7.6

