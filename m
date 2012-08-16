From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net-next 1/9] ixgbe: Remove code that was initializing Rx page offset
Date: Thu, 16 Aug 2012 15:48:30 -0700
Message-ID: <1345157318-23731-2-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12017 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755378Ab2HPWst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 18:48:49 -0400
In-Reply-To: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change reverts an earlier patch that introduced
ixgbe_init_rx_page_offset. The idea behind the function was to provide
some variation in the starting offset for the page in order to reduce
hot-spots in the cache. However it doesn't appear to provide any
significant benefit in the testing I have done. It has however been a
source of several bugs, and it blocks us from being able to use 2K
fragments on larger page sizes. So the decision I made was to remove it.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 27 +--------------------------
 1 file changed, 1 insertion(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4326f74..f7351c6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1167,7 +1167,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 	}
 
 	bi->dma = dma;
-	bi->page_offset ^= ixgbe_rx_bufsz(rx_ring);
+	bi->page_offset = 0;
 
 	return true;
 }
@@ -4130,27 +4130,6 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_init_rx_page_offset - initialize page offset values for Rx buffers
- * @rx_ring: ring to setup
- *
- * On many IA platforms the L1 cache has a critical stride of 4K, this
- * results in each receive buffer starting in the same cache set.  To help
- * reduce the pressure on this cache set we can interleave the offsets so
- * that only every other buffer will be in the same cache set.
- **/
-static void ixgbe_init_rx_page_offset(struct ixgbe_ring *rx_ring)
-{
-	struct ixgbe_rx_buffer *rx_buffer = rx_ring->rx_buffer_info;
-	u16 i;
-
-	for (i = 0; i < rx_ring->count; i += 2) {
-		rx_buffer[0].page_offset = 0;
-		rx_buffer[1].page_offset = ixgbe_rx_bufsz(rx_ring);
-		rx_buffer = &rx_buffer[2];
-	}
-}
-
-/**
  * ixgbe_clean_rx_ring - Free Rx Buffers per Queue
  * @rx_ring: ring to free buffers from
  **/
@@ -4195,8 +4174,6 @@ static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
 	memset(rx_ring->rx_buffer_info, 0, size);
 
-	ixgbe_init_rx_page_offset(rx_ring);
-
 	/* Zero out the descriptor ring */
 	memset(rx_ring->desc, 0, rx_ring->size);
 
@@ -4646,8 +4623,6 @@ int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 
-	ixgbe_init_rx_page_offset(rx_ring);
-
 	return 0;
 err:
 	vfree(rx_ring->rx_buffer_info);
-- 
1.7.11.2
