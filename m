From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] igb: Clear Rx buffer_info in configure instead of clean
Date: Fri, 17 Mar 2017 12:58:08 -0700
Message-ID: <20170317195818.74912-4-jeffrey.t.kirsher@intel.com>
References: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30552 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751207AbdCQT60 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 15:58:26 -0400
In-Reply-To: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that instead of going through the entire ring on Rx
cleanup we only go through the region that was designated to be cleaned up
and stop when we reach the region where new allocations should start.

In addition we can avoid having to perform a memset on the Rx buffer_info
structures until we are about to start using the ring again.  By deferring
this we can avoid dirtying the cache any more than we have to which can
help to improve the time needed to bring the interface down and then back
up again in a reset or suspend/resume cycle.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1d76d3a90a17..680f0d3d9b72 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3435,7 +3435,7 @@ int igb_setup_rx_resources(struct igb_ring *rx_ring)
 
 	size = sizeof(struct igb_rx_buffer) * rx_ring->count;
 
-	rx_ring->rx_buffer_info = vzalloc(size);
+	rx_ring->rx_buffer_info = vmalloc(size);
 	if (!rx_ring->rx_buffer_info)
 		goto err;
 
@@ -3759,6 +3759,10 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	rxdctl |= IGB_RX_HTHRESH << 8;
 	rxdctl |= IGB_RX_WTHRESH << 16;
 
+	/* initialize rx_buffer_info */
+	memset(ring->rx_buffer_info, 0,
+	       sizeof(struct igb_rx_buffer) * ring->count);
+
 	/* initialize Rx descriptor 0 */
 	rx_desc = IGB_RX_DESC(ring, 0);
 	rx_desc->wb.upper.length = 0;
@@ -3937,23 +3941,16 @@ static void igb_free_all_rx_resources(struct igb_adapter *adapter)
  **/
 static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 {
-	unsigned long size;
-	u16 i;
+	u16 i = rx_ring->next_to_clean;
 
 	if (rx_ring->skb)
 		dev_kfree_skb(rx_ring->skb);
 	rx_ring->skb = NULL;
 
-	if (!rx_ring->rx_buffer_info)
-		return;
-
 	/* Free all the Rx ring sk_buffs */
-	for (i = 0; i < rx_ring->count; i++) {
+	while (i != rx_ring->next_to_alloc) {
 		struct igb_rx_buffer *buffer_info = &rx_ring->rx_buffer_info[i];
 
-		if (!buffer_info->page)
-			continue;
-
 		/* Invalidate cache lines that may have been written to by
 		 * device so that we avoid corrupting memory.
 		 */
@@ -3972,12 +3969,11 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 		__page_frag_cache_drain(buffer_info->page,
 					buffer_info->pagecnt_bias);
 
-		buffer_info->page = NULL;
+		i++;
+		if (i == rx_ring->count)
+			i = 0;
 	}
 
-	size = sizeof(struct igb_rx_buffer) * rx_ring->count;
-	memset(rx_ring->rx_buffer_info, 0, size);
-
 	rx_ring->next_to_alloc = 0;
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
-- 
2.12.0
