From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/8] ixgbe: Use __free_pages instead of put_page to release pages
Date: Fri,  4 May 2012 03:35:14 -0700
Message-ID: <1336127716-20383-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336127716-20383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2289 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755361Ab2EDKfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 06:35:22 -0400
In-Reply-To: <1336127716-20383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change replaces the calls to put_page with calls to __free_page.

Since the FCoE code is able to access order 1 pages I thought it would be a
good idea to change things over to using __free_pages since that is the
preferred approach for freeing pages.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 09409ae..c2ceda9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1144,7 +1144,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 	 * there isn't much point in holding memory we can't use
 	 */
 	if (dma_mapping_error(rx_ring->dev, dma)) {
-		put_page(page);
+		__free_pages(page, ixgbe_rx_pg_order(rx_ring));
 		bi->page = NULL;
 
 		rx_ring->rx_stats.alloc_rx_page_failed++;
@@ -4102,7 +4102,8 @@ static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 				       DMA_FROM_DEVICE);
 		rx_buffer->dma = 0;
 		if (rx_buffer->page)
-			put_page(rx_buffer->page);
+			__free_pages(rx_buffer->page,
+				     ixgbe_rx_pg_order(rx_ring));
 		rx_buffer->page = NULL;
 	}
 
-- 
1.7.7.6
