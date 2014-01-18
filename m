From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 6/7] ixgbevf: redo dma mapping using the tx buffer info
Date: Fri, 17 Jan 2014 18:30:04 -0800
Message-ID: <1390012205-21995-7-git-send-email-aaron.f.brown@intel.com>
References: <1390012205-21995-1-git-send-email-aaron.f.brown@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24162 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752608AbaARCaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 21:30:16 -0500
In-Reply-To: <1390012205-21995-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch takes advantage of the dma buffer always being present in the
first descriptor and mapped as single. As such we can call dma_unmap_single
and don't need to check for DMA mapping in ixgbevf_clean_tx_irq().

In addition this patch makes use of the DMA API.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  5 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 94 ++++++++++++++---------
 2 files changed, 59 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index bad3219..5482932 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -52,9 +52,9 @@ struct ixgbevf_tx_buffer {
 	unsigned int bytecount;
 	unsigned short gso_segs;
 	__be16 protocol;
-	dma_addr_t dma;
+	DEFINE_DMA_UNMAP_ADDR(dma);
+	DEFINE_DMA_UNMAP_LEN(len);
 	u32 tx_flags;
-	u16 length;
 };
 
 struct ixgbevf_rx_buffer {
@@ -147,7 +147,6 @@ struct ixgbevf_ring {
 #define IXGBE_TX_FLAGS_VLAN		(u32)(1 << 1)
 #define IXGBE_TX_FLAGS_TSO		(u32)(1 << 2)
 #define IXGBE_TX_FLAGS_IPV4		(u32)(1 << 3)
-#define IXGBE_TX_FLAGS_MAPPED_AS_PAGE	(u32)(1 << 4)
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_MASK	0x0000e000
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 61425f8..0fc0433 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -145,28 +145,25 @@ static void ixgbevf_set_ivar(struct ixgbevf_adapter *adapter, s8 direction,
 }
 
 static void ixgbevf_unmap_and_free_tx_resource(struct ixgbevf_ring *tx_ring,
-					       struct ixgbevf_tx_buffer
-					       *tx_buffer_info)
-{
-	if (tx_buffer_info->dma) {
-		if (tx_buffer_info->tx_flags & IXGBE_TX_FLAGS_MAPPED_AS_PAGE)
-			dma_unmap_page(tx_ring->dev,
-				       tx_buffer_info->dma,
-				       tx_buffer_info->length,
-				       DMA_TO_DEVICE);
-		else
+					struct ixgbevf_tx_buffer *tx_buffer)
+{
+	if (tx_buffer->skb) {
+		dev_kfree_skb_any(tx_buffer->skb);
+		if (dma_unmap_len(tx_buffer, len))
 			dma_unmap_single(tx_ring->dev,
-					 tx_buffer_info->dma,
-					 tx_buffer_info->length,
+					 dma_unmap_addr(tx_buffer, dma),
+					 dma_unmap_len(tx_buffer, len),
 					 DMA_TO_DEVICE);
-		tx_buffer_info->dma = 0;
-	}
-	if (tx_buffer_info->skb) {
-		dev_kfree_skb_any(tx_buffer_info->skb);
-		tx_buffer_info->skb = NULL;
+	} else if (dma_unmap_len(tx_buffer, len)) {
+		dma_unmap_page(tx_ring->dev,
+			       dma_unmap_addr(tx_buffer, dma),
+			       dma_unmap_len(tx_buffer, len),
+			       DMA_TO_DEVICE);
 	}
-	tx_buffer_info->time_stamp = 0;
-	/* tx_buffer_info must be completely set up in the transmit path */
+	tx_buffer->next_to_watch = NULL;
+	tx_buffer->skb = NULL;
+	dma_unmap_len_set(tx_buffer, len, 0);
+	/* tx_buffer must be completely set up in the transmit path */
 }
 
 #define IXGBE_MAX_TXD_PWR	14
@@ -221,8 +218,18 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 		total_bytes += tx_buffer->bytecount;
 		total_packets += tx_buffer->gso_segs;
 
+		/* free the skb */
+		dev_kfree_skb_any(tx_buffer->skb);
+
+		/* unmap skb header data */
+		dma_unmap_single(tx_ring->dev,
+				 dma_unmap_addr(tx_buffer, dma),
+				 dma_unmap_len(tx_buffer, len),
+				 DMA_TO_DEVICE);
+
 		/* clear tx_buffer data */
-		ixgbevf_unmap_and_free_tx_resource(tx_ring, tx_buffer);
+		tx_buffer->skb = NULL;
+		dma_unmap_len_set(tx_buffer, len, 0);
 
 		/* unmap remaining buffers */
 		while (tx_desc != eop_desc) {
@@ -237,7 +244,14 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 				tx_desc = IXGBEVF_TX_DESC(tx_ring, 0);
 			}
 
-			ixgbevf_unmap_and_free_tx_resource(tx_ring, tx_buffer);
+			/* unmap any remaining paged data */
+			if (dma_unmap_len(tx_buffer, len)) {
+				dma_unmap_page(tx_ring->dev,
+					       dma_unmap_addr(tx_buffer, dma),
+					       dma_unmap_len(tx_buffer, len),
+					       DMA_TO_DEVICE);
+				dma_unmap_len_set(tx_buffer, len, 0);
+			}
 		}
 
 		tx_desc->wb.status = 0;
@@ -2904,6 +2918,7 @@ static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 static int ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
 			  struct ixgbevf_tx_buffer *first)
 {
+	dma_addr_t dma;
 	struct sk_buff *skb = first->skb;
 	struct ixgbevf_tx_buffer *tx_buffer_info;
 	unsigned int len;
@@ -2921,14 +2936,16 @@ static int ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
 		size = min(len, (unsigned int)IXGBE_MAX_DATA_PER_TXD);
 
-		tx_buffer_info->length = size;
 		tx_buffer_info->tx_flags = first->tx_flags;
-		tx_buffer_info->dma = dma_map_single(tx_ring->dev,
-						     skb->data + offset,
-						     size, DMA_TO_DEVICE);
-		if (dma_mapping_error(tx_ring->dev, tx_buffer_info->dma))
+		dma = dma_map_single(tx_ring->dev, skb->data + offset,
+				     size, DMA_TO_DEVICE);
+		if (dma_mapping_error(tx_ring->dev, dma))
 			goto dma_error;
 
+		/* record length, and DMA address */
+		dma_unmap_len_set(tx_buffer_info, len, size);
+		dma_unmap_addr_set(tx_buffer_info, dma, dma);
+
 		len -= size;
 		total -= size;
 		offset += size;
@@ -2949,16 +2966,15 @@ static int ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
 			size = min(len, (unsigned int)IXGBE_MAX_DATA_PER_TXD);
 
-			tx_buffer_info->length = size;
-			tx_buffer_info->dma =
-				skb_frag_dma_map(tx_ring->dev, frag,
-						 offset, size, DMA_TO_DEVICE);
-			tx_buffer_info->tx_flags |=
-						IXGBE_TX_FLAGS_MAPPED_AS_PAGE;
-			if (dma_mapping_error(tx_ring->dev,
-					      tx_buffer_info->dma))
+			dma = skb_frag_dma_map(tx_ring->dev, frag,
+					       offset, size, DMA_TO_DEVICE);
+			if (dma_mapping_error(tx_ring->dev, dma))
 				goto dma_error;
 
+			/* record length, and DMA address */
+			dma_unmap_len_set(tx_buffer_info, len, size);
+			dma_unmap_addr_set(tx_buffer_info, dma, dma);
+
 			len -= size;
 			total -= size;
 			offset += size;
@@ -3043,11 +3059,15 @@ static void ixgbevf_tx_queue(struct ixgbevf_ring *tx_ring,
 
 	i = tx_ring->next_to_use;
 	while (count--) {
+		dma_addr_t dma;
+		unsigned int len;
+
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
+		dma = dma_unmap_addr(tx_buffer_info, dma);
+		len = dma_unmap_len(tx_buffer_info, len);
 		tx_desc = IXGBEVF_TX_DESC(tx_ring, i);
-		tx_desc->read.buffer_addr = cpu_to_le64(tx_buffer_info->dma);
-		tx_desc->read.cmd_type_len =
-			cpu_to_le32(cmd_type_len | tx_buffer_info->length);
+		tx_desc->read.buffer_addr = cpu_to_le64(dma);
+		tx_desc->read.cmd_type_len = cpu_to_le32(cmd_type_len | len);
 		tx_desc->read.olinfo_status = cpu_to_le32(olinfo_status);
 		i++;
 		if (i == tx_ring->count)
-- 
1.8.5.GIT
