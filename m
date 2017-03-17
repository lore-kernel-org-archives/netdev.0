From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] igb: Add support for padding packet
Date: Fri, 17 Mar 2017 12:58:15 -0700
Message-ID: <20170317195818.74912-11-jeffrey.t.kirsher@intel.com>
References: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:21553 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751263AbdCQT62 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 15:58:28 -0400
In-Reply-To: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

With the size of the frame limited we can now write to an offset within the
buffer instead of having to write at the very start of the buffer.  The
advantage to this is that it allows us to leave padding room for things
like supporting XDP in the future.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      | 11 +++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c | 14 ++++++++++++--
 2 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index eb91c87e0c1d..dc6e2980718f 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -314,6 +314,7 @@ struct igb_q_vector {
 
 enum e1000_ring_flags_t {
 	IGB_RING_FLAG_RX_3K_BUFFER,
+	IGB_RING_FLAG_RX_BUILD_SKB_ENABLED,
 	IGB_RING_FLAG_RX_SCTP_CSUM,
 	IGB_RING_FLAG_RX_LB_VLAN_BSWAP,
 	IGB_RING_FLAG_TX_CTX_IDX,
@@ -327,11 +328,21 @@ enum e1000_ring_flags_t {
 #define clear_ring_uses_large_buffer(ring) \
 	clear_bit(IGB_RING_FLAG_RX_3K_BUFFER, &(ring)->flags)
 
+#define ring_uses_build_skb(ring) \
+	test_bit(IGB_RING_FLAG_RX_BUILD_SKB_ENABLED, &(ring)->flags)
+#define set_ring_build_skb_enabled(ring) \
+	set_bit(IGB_RING_FLAG_RX_BUILD_SKB_ENABLED, &(ring)->flags)
+#define clear_ring_build_skb_enabled(ring) \
+	clear_bit(IGB_RING_FLAG_RX_BUILD_SKB_ENABLED, &(ring)->flags)
+
 static inline unsigned int igb_rx_bufsz(struct igb_ring *ring)
 {
 #if (PAGE_SIZE < 8192)
 	if (ring_uses_large_buffer(ring))
 		return IGB_RXBUFFER_3072;
+
+	if (ring_uses_build_skb(ring))
+		return IGB_MAX_FRAME_BUILD_SKB + IGB_TS_HDR_LEN;
 #endif
 	return IGB_RXBUFFER_2048;
 }
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 24c20d401240..3ef66577872b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3783,11 +3783,14 @@ static void igb_set_rx_buffer_len(struct igb_adapter *adapter,
 				  struct igb_ring *rx_ring)
 {
 	/* set build_skb and buffer size flags */
+	clear_ring_build_skb_enabled(rx_ring);
 	clear_ring_uses_large_buffer(rx_ring);
 
 	if (adapter->flags & IGB_FLAG_RX_LEGACY)
 		return;
 
+	set_ring_build_skb_enabled(rx_ring);
+
 #if (PAGE_SIZE < 8192)
 	if (adapter->max_frame_size <= IGB_MAX_FRAME_BUILD_SKB)
 		return;
@@ -6957,7 +6960,9 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = igb_rx_pg_size(rx_ring) / 2;
 #else
-	unsigned int truesize = SKB_DATA_ALIGN(size);
+	unsigned int truesize = ring_uses_build_skb(rx_ring) ?
+				SKB_DATA_ALIGN(IGB_SKB_PAD + size) :
+				SKB_DATA_ALIGN(size);
 #endif
 	unsigned int pull_len;
 
@@ -7293,6 +7298,11 @@ static int igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 	return total_packets;
 }
 
+static inline unsigned int igb_rx_offset(struct igb_ring *rx_ring)
+{
+	return ring_uses_build_skb(rx_ring) ? IGB_SKB_PAD : 0;
+}
+
 static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 				  struct igb_rx_buffer *bi)
 {
@@ -7328,7 +7338,7 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 
 	bi->dma = dma;
 	bi->page = page;
-	bi->page_offset = 0;
+	bi->page_offset = igb_rx_offset(rx_ring);
 	bi->pagecnt_bias = 1;
 
 	return true;
-- 
2.12.0
