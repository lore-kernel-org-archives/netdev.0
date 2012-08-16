From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net-next 3/9] ixgbe: Only use double buffering if page size is less than 8K
Date: Thu, 16 Aug 2012 15:48:32 -0700
Message-ID: <1345157318-23731-4-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12017 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755317Ab2HPWsu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 18:48:50 -0400
In-Reply-To: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we do not use double buffering if the page
size is larger than 4K.  Instead we will simply walk through the page using
up to 3K per receive, and if we receive less than we only move the offset
by that amount.  We will free the page when there is no longer any space
left that we can use instead of checking the page count to see if we can
cycle back to the start.

The main motivation behind this is to avoid the unnecessary truesize cost
for using a half page when most packets are 2K or smaller. With this new
approach the largest possible truesize for a page fragment will be 3K when
PAGE_SIZE is larger than 4K.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 24 ++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 40 ++++++++++++++++++---------
 2 files changed, 45 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index b9623e9..fd2bc69 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -78,6 +78,9 @@
 
 /* Supported Rx Buffer Sizes */
 #define IXGBE_RXBUFFER_256    256  /* Used for skb receive header */
+#define IXGBE_RXBUFFER_2K    2048
+#define IXGBE_RXBUFFER_3K    3072
+#define IXGBE_RXBUFFER_4K    4096
 #define IXGBE_MAX_RXBUFFER  16384  /* largest size for a single descriptor */
 
 /*
@@ -293,16 +296,25 @@ struct ixgbe_ring_feature {
  * this is twice the size of a half page we need to double the page order
  * for FCoE enabled Rx queues.
  */
-#if defined(IXGBE_FCOE) && (PAGE_SIZE < 8192)
-static inline unsigned int ixgbe_rx_pg_order(struct ixgbe_ring *ring)
+static inline unsigned int ixgbe_rx_bufsz(struct ixgbe_ring *ring)
 {
-	return test_bit(__IXGBE_RX_FCOE, &ring->state) ? 1 : 0;
+#ifdef IXGBE_FCOE
+	if (test_bit(__IXGBE_RX_FCOE, &ring->state))
+		return (PAGE_SIZE < 8192) ? IXGBE_RXBUFFER_4K :
+					    IXGBE_RXBUFFER_3K;
+#endif
+	return IXGBE_RXBUFFER_2K;
 }
-#else
-#define ixgbe_rx_pg_order(_ring) 0
+
+static inline unsigned int ixgbe_rx_pg_order(struct ixgbe_ring *ring)
+{
+#ifdef IXGBE_FCOE
+	if (test_bit(__IXGBE_RX_FCOE, &ring->state))
+		return (PAGE_SIZE < 8192) ? 1 : 0;
 #endif
+	return 0;
+}
 #define ixgbe_rx_pg_size(_ring) (PAGE_SIZE << ixgbe_rx_pg_order(_ring))
-#define ixgbe_rx_bufsz(_ring) ((PAGE_SIZE / 2) << ixgbe_rx_pg_order(_ring))
 
 struct ixgbe_ring_container {
 	struct ixgbe_ring *ring;	/* pointer to linked list of rings */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6a8c484..9305e9a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1612,21 +1612,45 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 {
 	struct page *page = rx_buffer->page;
 	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
+#if (PAGE_SIZE < 8192)
 	unsigned int truesize = ixgbe_rx_bufsz(rx_ring);
+#else
+	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+	unsigned int last_offset = ixgbe_rx_pg_size(rx_ring) -
+				   ixgbe_rx_bufsz(rx_ring);
+#endif
 
 	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
 			rx_buffer->page_offset, size, truesize);
 
-	/* if we are only owner of page and it is local we can reuse it */
-	if (unlikely(page_count(page) != 1) ||
-	    unlikely(page_to_nid(page) != numa_node_id()))
+	/* avoid re-using remote pages */
+	if (unlikely(page_to_nid(page) != numa_node_id()))
+		return false;
+
+#if (PAGE_SIZE < 8192)
+	/* if we are only owner of page we can reuse it */
+	if (unlikely(page_count(page) != 1))
 		return false;
 
 	/* flip page offset to other buffer */
 	rx_buffer->page_offset ^= truesize;
 
+	/*
+	 * since we are the only owner of the page and we need to
+	 * increment it, just set the value to 2 in order to avoid
+	 * an unecessary locked operation
+	 */
+	atomic_set(&page->_count, 2);
+#else
+	/* move offset up to the next cache line */
+	rx_buffer->page_offset += truesize;
+
+	if (rx_buffer->page_offset > last_offset)
+		return false;
+
 	/* bump ref count on page before it is given to the stack */
 	get_page(page);
+#endif
 
 	return true;
 }
@@ -2863,11 +2887,7 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 	srrctl = IXGBE_RX_HDR_SIZE << IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT;
 
 	/* configure the packet buffer length */
-#if PAGE_SIZE > IXGBE_MAX_RXBUFFER
-	srrctl |= IXGBE_MAX_RXBUFFER >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-#else
 	srrctl |= ixgbe_rx_bufsz(rx_ring) >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-#endif
 
 	/* configure descriptor type */
 	srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
@@ -2975,13 +2995,7 @@ static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
 	 * total size of max desc * buf_len is not greater
 	 * than 65536
 	 */
-#if (PAGE_SIZE <= 8192)
 	rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
-#elif (PAGE_SIZE <= 16384)
-	rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
-#else
-	rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
-#endif
 	IXGBE_WRITE_REG(hw, IXGBE_RSCCTL(reg_idx), rscctrl);
 }
 
-- 
1.7.11.2
