From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/8] ixgbevf: Check for error on dma_map_single call
Date: Tue, 23 Oct 2012 03:24:45 -0700
Message-ID: <1350987887-16161-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28521 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755991Ab2JWKYy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 06:24:54 -0400
In-Reply-To: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Ignoring the return value from a call to the kernel dma_map API functions
can cause data corruption and system instability.  Check the return value
and take appropriate action.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 537ed19..805e02c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -359,6 +359,12 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 			bi->dma = dma_map_single(&pdev->dev, skb->data,
 						 rx_ring->rx_buf_len,
 						 DMA_FROM_DEVICE);
+			if (dma_mapping_error(&pdev->dev, bi->dma)) {
+				dev_kfree_skb(skb);
+				bi->skb = NULL;
+				dev_err(&pdev->dev, "RX DMA map failed\n");
+				break;
+			}
 		}
 		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma);
 
@@ -2817,10 +2823,10 @@ static int ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
 			tx_buffer_info->dma =
 				skb_frag_dma_map(tx_ring->dev, frag,
 						 offset, size, DMA_TO_DEVICE);
-			tx_buffer_info->mapped_as_page = true;
 			if (dma_mapping_error(tx_ring->dev,
 					      tx_buffer_info->dma))
 				goto dma_error;
+			tx_buffer_info->mapped_as_page = true;
 			tx_buffer_info->next_to_watch = i;
 
 			len -= size;
-- 
1.7.11.7
