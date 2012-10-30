From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] igbvf: Check for error on dma_map_single call
Date: Tue, 30 Oct 2012 00:04:27 -0700
Message-ID: <1351580670-8292-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5842 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755310Ab2J3HEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 03:04:37 -0400
In-Reply-To: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Ignoring the return value from a call to the kernel dma_map API functions
can cause data corruption and system instability.  Check the return value
and take appropriate action.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 0ac11f5..4051ec4 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -184,6 +184,13 @@ static void igbvf_alloc_rx_buffers(struct igbvf_ring *rx_ring,
 				             buffer_info->page_offset,
 				             PAGE_SIZE / 2,
 					     DMA_FROM_DEVICE);
+			if (dma_mapping_error(&pdev->dev,
+					      buffer_info->page_dma)) {
+				__free_page(buffer_info->page);
+				buffer_info->page = NULL;
+				dev_err(&pdev->dev, "RX DMA map failed\n");
+				break;
+			}
 		}
 
 		if (!buffer_info->skb) {
@@ -197,6 +204,12 @@ static void igbvf_alloc_rx_buffers(struct igbvf_ring *rx_ring,
 			buffer_info->dma = dma_map_single(&pdev->dev, skb->data,
 			                                  bufsz,
 							  DMA_FROM_DEVICE);
+			if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
+				dev_kfree_skb(buffer_info->skb);
+				buffer_info->skb = NULL;
+				dev_err(&pdev->dev, "RX DMA map failed\n");
+				goto no_buffers;
+			}
 		}
 		/* Refresh the desc even if buffer_addrs didn't change because
 		 * each write-back erases this info. */
-- 
1.7.11.7
