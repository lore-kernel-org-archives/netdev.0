From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] ixgbe: Add support for build_skb
Date: Thu, 16 Feb 2017 04:50:40 -0800
Message-ID: <20170216125041.46668-14-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:20936 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754778AbdBPMuu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:50 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds build_skb support to the Rx path.  There are several
advantages to this change.

1.  It avoids the memcpy and skb->head allocation for small packets which
    improves performance by about 5% in my tests.
2.  It avoids the memcpy, skb->head allocation, and eth_get_headlen
    for larger packets improving performance by about 10% in my tests.
3.  For VXLAN packets it allows the full header to be in skb->data which
    improves the performance by as much as 30% in some of my tests.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 49 ++++++++++++++++++++++++++-
 1 file changed, 48 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7c696b38b405..2a10365eae75 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1896,7 +1896,7 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
 	}
 
 	/* place header in linear portion of buffer */
-	if (skb_is_nonlinear(skb))
+	if (!skb_headlen(skb))
 		ixgbe_pull_tail(rx_ring, skb);
 
 #ifdef IXGBE_FCOE
@@ -2125,6 +2125,49 @@ static struct sk_buff *ixgbe_construct_skb(struct ixgbe_ring *rx_ring,
 	return skb;
 }
 
+static struct sk_buff *ixgbe_build_skb(struct ixgbe_ring *rx_ring,
+				       struct ixgbe_rx_buffer *rx_buffer,
+				       union ixgbe_adv_rx_desc *rx_desc,
+				       unsigned int size)
+{
+	void *va = page_address(rx_buffer->page) + rx_buffer->page_offset;
+#if (PAGE_SIZE < 8192)
+	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
+#else
+	unsigned int truesize = SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) +
+				SKB_DATA_ALIGN(IXGBE_SKB_PAD + size);
+#endif
+	struct sk_buff *skb;
+
+	/* prefetch first cache line of first page */
+	prefetch(va);
+#if L1_CACHE_BYTES < 128
+	prefetch(va + L1_CACHE_BYTES);
+#endif
+
+	/* build an skb to around the page buffer */
+	skb = build_skb(va - IXGBE_SKB_PAD, truesize);
+	if (unlikely(!skb))
+		return NULL;
+
+	/* update pointers within the skb to store the data */
+	skb_reserve(skb, IXGBE_SKB_PAD);
+	__skb_put(skb, size);
+
+	/* record DMA address if this is the start of a chain of buffers */
+	if (!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))
+		IXGBE_CB(skb)->dma = rx_buffer->dma;
+
+	/* update buffer offset */
+#if (PAGE_SIZE < 8192)
+	rx_buffer->page_offset ^= truesize;
+#else
+	rx_buffer->page_offset += truesize;
+#endif
+
+	return skb;
+}
+
 /**
  * ixgbe_clean_rx_irq - Clean completed descriptors from Rx ring - bounce buf
  * @q_vector: structure containing interrupt and ring information
@@ -2178,6 +2221,9 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		/* retrieve a buffer from the ring */
 		if (skb)
 			ixgbe_add_rx_frag(rx_ring, rx_buffer, skb, size);
+		else if (ring_uses_build_skb(rx_ring))
+			skb = ixgbe_build_skb(rx_ring, rx_buffer,
+					      rx_desc, size);
 		else
 			skb = ixgbe_construct_skb(rx_ring, rx_buffer,
 						  rx_desc, size);
@@ -3918,6 +3964,7 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 		if (test_bit(__IXGBE_RX_FCOE, &rx_ring->state))
 			set_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state);
 
+		clear_bit(__IXGBE_RX_BUILD_SKB_ENABLED, &rx_ring->state);
 		if (adapter->flags2 & IXGBE_FLAG2_RX_LEGACY)
 			continue;
 
-- 
2.11.0
