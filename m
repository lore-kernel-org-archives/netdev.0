From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/7] igb: Use dma_unmap_addr and dma_unmap_len defines
Date: Sat, 22 Sep 2012 03:30:36 -0700
Message-ID: <1348309836-7107-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8125 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755383Ab2IVKbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 06:31:09 -0400
In-Reply-To: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to improve performance on systems that do not require
the DMA unmap calls.  On those systems we do not need to make use of the
unmap address for Tx or the unmap length so we can drop both thereby
reducing the size of the Tx buffer info structure.

In addition I have changed the logic to check for unmap length instead of
unmap address when checking to see if a buffer needs to be unmapped from
DMA use.  The reasons for this change is that on some platforms it is
possible to receive a valid DMA address of 0 from an IOMMU.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |  4 +-
 drivers/net/ethernet/intel/igb/igb_main.c | 64 +++++++++++++++----------------
 2 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 9cad058..8aad230 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -168,8 +168,8 @@ struct igb_tx_buffer {
 	unsigned int bytecount;
 	u16 gso_segs;
 	__be16 protocol;
-	dma_addr_t dma;
-	u32 length;
+	DEFINE_DMA_UNMAP_ADDR(dma);
+	DEFINE_DMA_UNMAP_LEN(len);
 	u32 tx_flags;
 };
 
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index db6e456..60bf465 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -403,8 +403,8 @@ static void igb_dump(struct igb_adapter *adapter)
 		buffer_info = &tx_ring->tx_buffer_info[tx_ring->next_to_clean];
 		pr_info(" %5d %5X %5X %016llX %04X %p %016llX\n",
 			n, tx_ring->next_to_use, tx_ring->next_to_clean,
-			(u64)buffer_info->dma,
-			buffer_info->length,
+			(u64)dma_unmap_addr(buffer_info, dma),
+			dma_unmap_len(buffer_info, len),
 			buffer_info->next_to_watch,
 			(u64)buffer_info->time_stamp);
 	}
@@ -455,8 +455,8 @@ static void igb_dump(struct igb_adapter *adapter)
 				" %04X  %p %016llX %p%s\n", i,
 				le64_to_cpu(u0->a),
 				le64_to_cpu(u0->b),
-				(u64)buffer_info->dma,
-				buffer_info->length,
+				(u64)dma_unmap_addr(buffer_info, dma),
+				dma_unmap_len(buffer_info, len),
 				buffer_info->next_to_watch,
 				(u64)buffer_info->time_stamp,
 				buffer_info->skb, next_desc);
@@ -465,7 +465,8 @@ static void igb_dump(struct igb_adapter *adapter)
 				print_hex_dump(KERN_INFO, "",
 					DUMP_PREFIX_ADDRESS,
 					16, 1, buffer_info->skb->data,
-					buffer_info->length, true);
+					dma_unmap_len(buffer_info, len),
+					true);
 		}
 	}
 
@@ -3198,20 +3199,20 @@ void igb_unmap_and_free_tx_resource(struct igb_ring *ring,
 {
 	if (tx_buffer->skb) {
 		dev_kfree_skb_any(tx_buffer->skb);
-		if (tx_buffer->dma)
+		if (dma_unmap_len(tx_buffer, len))
 			dma_unmap_single(ring->dev,
-					 tx_buffer->dma,
-					 tx_buffer->length,
+					 dma_unmap_addr(tx_buffer, dma),
+					 dma_unmap_len(tx_buffer, len),
 					 DMA_TO_DEVICE);
-	} else if (tx_buffer->dma) {
+	} else if (dma_unmap_len(tx_buffer, len)) {
 		dma_unmap_page(ring->dev,
-			       tx_buffer->dma,
-			       tx_buffer->length,
+			       dma_unmap_addr(tx_buffer, dma),
+			       dma_unmap_len(tx_buffer, len),
 			       DMA_TO_DEVICE);
 	}
 	tx_buffer->next_to_watch = NULL;
 	tx_buffer->skb = NULL;
-	tx_buffer->dma = 0;
+	dma_unmap_len_set(tx_buffer, len, 0);
 	/* buffer_info must be completely set up in the transmit path */
 }
 
@@ -4206,7 +4207,7 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 		       const u8 hdr_len)
 {
 	struct sk_buff *skb = first->skb;
-	struct igb_tx_buffer *tx_buffer_info;
+	struct igb_tx_buffer *tx_buffer;
 	union e1000_adv_tx_desc *tx_desc;
 	dma_addr_t dma;
 	struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
@@ -4227,8 +4228,8 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 		goto dma_error;
 
 	/* record length, and DMA address */
-	first->length = size;
-	first->dma = dma;
+	dma_unmap_len_set(first, len, size);
+	dma_unmap_addr_set(first, dma, dma);
 	tx_desc->read.buffer_addr = cpu_to_le64(dma);
 
 	for (;;) {
@@ -4270,9 +4271,9 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 		if (dma_mapping_error(tx_ring->dev, dma))
 			goto dma_error;
 
-		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		tx_buffer_info->length = size;
-		tx_buffer_info->dma = dma;
+		tx_buffer = &tx_ring->tx_buffer_info[i];
+		dma_unmap_len_set(tx_buffer, len, size);
+		dma_unmap_addr_set(tx_buffer, dma, dma);
 
 		tx_desc->read.olinfo_status = 0;
 		tx_desc->read.buffer_addr = cpu_to_le64(dma);
@@ -4323,9 +4324,9 @@ dma_error:
 
 	/* clear dma mappings for failed tx_buffer_info map */
 	for (;;) {
-		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		igb_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
-		if (tx_buffer_info == first)
+		tx_buffer = &tx_ring->tx_buffer_info[i];
+		igb_unmap_and_free_tx_resource(tx_ring, tx_buffer);
+		if (tx_buffer == first)
 			break;
 		if (i == 0)
 			i = tx_ring->count;
@@ -5716,18 +5717,19 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 
 		/* free the skb */
 		dev_kfree_skb_any(tx_buffer->skb);
-		tx_buffer->skb = NULL;
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
-				 tx_buffer->dma,
-				 tx_buffer->length,
+				 dma_unmap_addr(tx_buffer, dma),
+				 dma_unmap_len(tx_buffer, len),
 				 DMA_TO_DEVICE);
 
+		/* clear tx_buffer data */
+		tx_buffer->skb = NULL;
+		dma_unmap_len_set(tx_buffer, len, 0);
+
 		/* clear last DMA location and unmap remaining buffers */
 		while (tx_desc != eop_desc) {
-			tx_buffer->dma = 0;
-
 			tx_buffer++;
 			tx_desc++;
 			i++;
@@ -5738,17 +5740,15 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 			}
 
 			/* unmap any remaining paged data */
-			if (tx_buffer->dma) {
+			if (dma_unmap_len(tx_buffer, len)) {
 				dma_unmap_page(tx_ring->dev,
-					       tx_buffer->dma,
-					       tx_buffer->length,
+					       dma_unmap_addr(tx_buffer, dma),
+					       dma_unmap_len(tx_buffer, len),
 					       DMA_TO_DEVICE);
+				dma_unmap_len_set(tx_buffer, len, 0);
 			}
 		}
 
-		/* clear last DMA location */
-		tx_buffer->dma = 0;
-
 		/* move us one more past the eop_desc for start of next pkt */
 		tx_buffer++;
 		tx_desc++;
-- 
1.7.11.4
