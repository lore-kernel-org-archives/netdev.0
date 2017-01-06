From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [next PATCH 08/11] ixgbe: Add support for padding packet
Date: Fri, 06 Jan 2017 08:07:28 -0800
Message-ID: <20170106160726.1501.63698.stgit@localhost.localdomain>
References: <20170106155448.1501.31298.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32934 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967113AbdAFQHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 11:07:30 -0500
Received: by mail-pg0-f66.google.com with SMTP id g1so44420256pgn.0
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 08:07:30 -0800 (PST)
In-Reply-To: <20170106155448.1501.31298.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for providing a buffer with headroom and tailroom
to allow for shared info, NET_SKB_PAD, and NET_IP_ALIGN.  With this
combined with the DMA changes we can start using build_skb to build frames
around an incoming Rx buffer instead of having to memcpy the headers.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   17 ++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   43 +++++++++++++++++++++++--
 2 files changed, 56 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 80328e657d6a..3537d07b4807 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -94,6 +94,14 @@
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
@@ -235,6 +243,7 @@ struct ixgbe_rx_queue_stats {
 
 enum ixgbe_ring_state_t {
 	__IXGBE_RX_3K_BUFFER,
+	__IXGBE_RX_BUILD_SKB_ENABLED,
 	__IXGBE_RX_RSC_ENABLED,
 	__IXGBE_RX_CSUM_UDP_ZERO_ERR,
 	__IXGBE_RX_FCOE,
@@ -244,6 +253,9 @@ enum ixgbe_ring_state_t {
 	__IXGBE_HANG_CHECK_ARMED,
 };
 
+#define ring_uses_build_skb(ring) \
+	test_bit(__IXGBE_RX_BUILD_SKB_ENABLED, &(ring)->state)
+
 struct ixgbe_fwd_adapter {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct net_device *netdev;
@@ -355,6 +367,10 @@ static inline unsigned int ixgbe_rx_bufsz(struct ixgbe_ring *ring)
 {
 	if (test_bit(__IXGBE_RX_3K_BUFFER, &ring->state))
 		return IXGBE_RXBUFFER_3K;
+#if (PAGE_SIZE < 8192)
+	if (ring_uses_build_skb(ring))
+		return IXGBE_MAX_FRAME_BUILD_SKB;
+#endif
 	return IXGBE_RXBUFFER_2K;
 }
 
@@ -670,6 +686,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_VLAN_PROMISC		BIT(13)
 #define IXGBE_FLAG2_EEE_CAPABLE			BIT(14)
 #define IXGBE_FLAG2_EEE_ENABLED			BIT(15)
+#define IXGBE_FLAG2_RX_LEGACY			BIT(16)
 
 	/* Tx fast path data */
 	int num_tx_queues;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 79495cc990c2..8529eafb9717 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1565,6 +1565,11 @@ static inline void ixgbe_rx_checksum(struct ixgbe_ring *ring,
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
@@ -1601,7 +1606,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 
 	bi->dma = dma;
 	bi->page = page;
-	bi->page_offset = 0;
+	bi->page_offset = ixgbe_rx_offset(rx_ring);
 	bi->pagecnt_bias = 1;
 
 	return true;
@@ -2018,7 +2023,9 @@ static void ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
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
@@ -2100,7 +2107,7 @@ static struct sk_buff *ixgbe_construct_skb(struct ixgbe_ring *rx_ring,
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
 #else
-	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
 	struct sk_buff *skb;
 
@@ -3462,7 +3469,10 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 	srrctl = IXGBE_RX_HDR_SIZE << IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT;
 
 	/* configure the packet buffer length */
-	srrctl |= ixgbe_rx_bufsz(rx_ring) >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+	if (test_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state))
+		srrctl |= IXGBE_RXBUFFER_3K >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+	else
+		srrctl |= IXGBE_RXBUFFER_2K >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 
 	/* configure descriptor type */
 	srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
@@ -3796,6 +3806,17 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
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
@@ -3941,12 +3962,26 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 
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
 
