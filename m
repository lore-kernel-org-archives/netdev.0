From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] ixgbe: Add support for padding packet
Date: Thu, 16 Feb 2017 04:50:38 -0800
Message-ID: <20170216125041.46668-12-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:20936 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754772AbdBPMut (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:49 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for providing a buffer with headroom and tailroom
to allow for shared info, NET_SKB_PAD, and NET_IP_ALIGN.  With this
combined with the DMA changes we can start using build_skb to build frames
around an incoming Rx buffer instead of having to memcpy the headers.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 17 +++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 43 ++++++++++++++++++++++++---
 2 files changed, 56 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index f3515ce8894d..a2cc43d28888 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -91,6 +91,14 @@
 #define IXGBE_RXBUFFER_4K    4096
 #define IXGBE_MAX_RXBUFFER  16384  /* largest size for a single descriptor */
 
+#define IXGBE_SKB_PAD		(NET_SKB_PAD + NET_IP_ALIGN)
+#if (PAGE_SIZE < 8192)
+#define IXGBE_MAX_FRAME_BUILD_SKB \
+	(SKB_WITH_OVERHEAD(IXGBE_RXBUFFER_2K) - IXGBE_SKB_PAD)
+#else
+#define IGB_MAX_FRAME_BUILD_SKB IXGBE_RXBUFFER_2K
+#endif
+
 /*
  * NOTE: netdev_alloc_skb reserves up to 64 bytes, NET_IP_ALIGN means we
  * reserve 64 more, and skb_shared_info adds an additional 320 bytes more,
@@ -227,6 +235,7 @@ struct ixgbe_rx_queue_stats {
 
 enum ixgbe_ring_state_t {
 	__IXGBE_RX_3K_BUFFER,
+	__IXGBE_RX_BUILD_SKB_ENABLED,
 	__IXGBE_RX_RSC_ENABLED,
 	__IXGBE_RX_CSUM_UDP_ZERO_ERR,
 	__IXGBE_RX_FCOE,
@@ -236,6 +245,9 @@ enum ixgbe_ring_state_t {
 	__IXGBE_HANG_CHECK_ARMED,
 };
 
+#define ring_uses_build_skb(ring) \
+	test_bit(__IXGBE_RX_BUILD_SKB_ENABLED, &(ring)->state)
+
 struct ixgbe_fwd_adapter {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct net_device *netdev;
@@ -347,6 +359,10 @@ static inline unsigned int ixgbe_rx_bufsz(struct ixgbe_ring *ring)
 {
 	if (test_bit(__IXGBE_RX_3K_BUFFER, &ring->state))
 		return IXGBE_RXBUFFER_3K;
+#if (PAGE_SIZE < 8192)
+	if (ring_uses_build_skb(ring))
+		return IXGBE_MAX_FRAME_BUILD_SKB;
+#endif
 	return IXGBE_RXBUFFER_2K;
 }
 
@@ -545,6 +561,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_VLAN_PROMISC		BIT(13)
 #define IXGBE_FLAG2_EEE_CAPABLE			BIT(14)
 #define IXGBE_FLAG2_EEE_ENABLED			BIT(15)
+#define IXGBE_FLAG2_RX_LEGACY			BIT(16)
 
 	/* Tx fast path data */
 	int num_tx_queues;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1e5575305f2a..7c696b38b405 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1552,6 +1552,11 @@ static inline void ixgbe_rx_checksum(struct ixgbe_ring *ring,
 	}
 }
 
+static inline unsigned int ixgbe_rx_offset(struct ixgbe_ring *rx_ring)
+{
+	return ring_uses_build_skb(rx_ring) ? IXGBE_SKB_PAD : 0;
+}
+
 static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 				    struct ixgbe_rx_buffer *bi)
 {
@@ -1588,7 +1593,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 
 	bi->dma = dma;
 	bi->page = page;
-	bi->page_offset = 0;
+	bi->page_offset = ixgbe_rx_offset(rx_ring);
 	bi->pagecnt_bias = 1;
 
 	return true;
@@ -2001,7 +2006,9 @@ static void ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
 #else
-	unsigned int truesize = SKB_DATA_ALIGN(size);
+	unsigned int truesize = ring_uses_build_skb(rx_ring) ?
+				SKB_DATA_ALIGN(IXGBE_SKB_PAD + size) :
+				SKB_DATA_ALIGN(size);
 #endif
 	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, rx_buffer->page,
 			rx_buffer->page_offset, size, truesize);
@@ -2083,7 +2090,7 @@ static struct sk_buff *ixgbe_construct_skb(struct ixgbe_ring *rx_ring,
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
 #else
-	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
 	struct sk_buff *skb;
 
@@ -3410,7 +3417,10 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 	srrctl = IXGBE_RX_HDR_SIZE << IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT;
 
 	/* configure the packet buffer length */
-	srrctl |= ixgbe_rx_bufsz(rx_ring) >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+	if (test_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state))
+		srrctl |= IXGBE_RXBUFFER_3K >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+	else
+		srrctl |= IXGBE_RXBUFFER_2K >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 
 	/* configure descriptor type */
 	srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
@@ -3744,6 +3754,17 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 		 */
 		rxdctl &= ~0x3FFFFF;
 		rxdctl |=  0x080420;
+#if (PAGE_SIZE < 8192)
+	} else {
+		rxdctl &= ~(IXGBE_RXDCTL_RLPMLMASK |
+			    IXGBE_RXDCTL_RLPML_EN);
+
+		/* Limit the maximum frame size so we don't overrun the skb */
+		if (ring_uses_build_skb(ring) &&
+		    !test_bit(__IXGBE_RX_3K_BUFFER, &ring->state))
+			rxdctl |= IXGBE_MAX_FRAME_BUILD_SKB |
+				  IXGBE_RXDCTL_RLPML_EN;
+#endif
 	}
 
 	/* initialize Rx descriptor 0 */
@@ -3889,12 +3910,26 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 
 		clear_ring_rsc_enabled(rx_ring);
 		clear_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state);
+		clear_bit(__IXGBE_RX_BUILD_SKB_ENABLED, &rx_ring->state);
 
 		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
 			set_ring_rsc_enabled(rx_ring);
 
 		if (test_bit(__IXGBE_RX_FCOE, &rx_ring->state))
 			set_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state);
+
+		if (adapter->flags2 & IXGBE_FLAG2_RX_LEGACY)
+			continue;
+
+		set_bit(__IXGBE_RX_BUILD_SKB_ENABLED, &rx_ring->state);
+
+#if (PAGE_SIZE < 8192)
+		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
+			set_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state);
+
+		if (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN))
+			set_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state);
+#endif
 	}
 }
 
-- 
2.11.0
