From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] e1000e: Add missing dma_mapping_error-call in e1000_alloc_jumbo_rx_buffers
Date: Wed, 27 Mar 2013 04:05:33 -0700
Message-ID: <1364382333-14721-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364382333-14721-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8713 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879Ab3C0LFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 07:05:44 -0400
In-Reply-To: <1364382333-14721-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>

After dma_map_page, dma_mapping_error must be called. It seems safe to
not free the skb/page allocated in this function, as the skb/page can be
reused later.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 948b86ff..7e615e2 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -848,11 +848,16 @@ check_page:
 			}
 		}
 
-		if (!buffer_info->dma)
+		if (!buffer_info->dma) {
 			buffer_info->dma = dma_map_page(&pdev->dev,
 			                                buffer_info->page, 0,
 			                                PAGE_SIZE,
 							DMA_FROM_DEVICE);
+			if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
+				adapter->alloc_rx_buff_failed++;
+				break;
+			}
+		}
 
 		rx_desc = E1000_RX_DESC_EXT(*rx_ring, i);
 		rx_desc->read.buffer_addr = cpu_to_le64(buffer_info->dma);
-- 
1.7.11.7
