From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/6] ixgbe: Fix Tx map failure path
Date: Thu, 26 Oct 2017 09:19:53 -0700
Message-ID: <20171026161955.4407-5-jeffrey.t.kirsher@intel.com>
References: <20171026161955.4407-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30235 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932441AbdJZQUU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 12:20:20 -0400
In-Reply-To: <20171026161955.4407-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is a partial revert of "ixgbe: Don't bother clearing buffer
memory for descriptor rings". Specifically I messed up the exception
handling path a bit and this resulted in us incorrectly adding the count
back in when we didn't need to.

In order to make this simpler I am reverting most of the exception handling
path change and instead just replacing the bit that was handled by the
unmap_and_free call.

Fixes: ffed21bcee7a ("ixgbe: Don't bother clearing buffer memory for descriptor rings")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4d76afd13868..6d5f31e94358 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8020,29 +8020,23 @@ static int ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 	return 0;
 dma_error:
 	dev_err(tx_ring->dev, "TX DMA map failed\n");
-	tx_buffer = &tx_ring->tx_buffer_info[i];
 
 	/* clear dma mappings for failed tx_buffer_info map */
-	while (tx_buffer != first) {
+	for (;;) {
+		tx_buffer = &tx_ring->tx_buffer_info[i];
 		if (dma_unmap_len(tx_buffer, len))
 			dma_unmap_page(tx_ring->dev,
 				       dma_unmap_addr(tx_buffer, dma),
 				       dma_unmap_len(tx_buffer, len),
 				       DMA_TO_DEVICE);
 		dma_unmap_len_set(tx_buffer, len, 0);
-
-		if (i--)
+		if (tx_buffer == first)
+			break;
+		if (i == 0)
 			i += tx_ring->count;
-		tx_buffer = &tx_ring->tx_buffer_info[i];
+		i--;
 	}
 
-	if (dma_unmap_len(tx_buffer, len))
-		dma_unmap_single(tx_ring->dev,
-				 dma_unmap_addr(tx_buffer, dma),
-				 dma_unmap_len(tx_buffer, len),
-				 DMA_TO_DEVICE);
-	dma_unmap_len_set(tx_buffer, len, 0);
-
 	dev_kfree_skb_any(first->skb);
 	first->skb = NULL;
 
-- 
2.14.2
