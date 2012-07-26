From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbe: fix panic while dumping packets on Tx hang with IOMMU
Date: Thu, 26 Jul 2012 04:21:24 -0700
Message-ID: <1343301684-10158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19214 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602Ab2GZLVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2012 07:21:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch resolves a "BUG: unable to handle kernel paging request at ..."
oops while dumping packet data. The issue occurs with IOMMU enabled due to
the address provided by phys_to_virt().

This patch makes use of skb->data on Tx and the virtual address of the pages
allocated for Rx.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3b6784c..c709eae 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -396,11 +396,10 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 				pr_cont("\n");
 
 			if (netif_msg_pktdata(adapter) &&
-			    dma_unmap_len(tx_buffer, len) != 0)
+			    tx_buffer->skb)
 				print_hex_dump(KERN_INFO, "",
 					DUMP_PREFIX_ADDRESS, 16, 1,
-					phys_to_virt(dma_unmap_addr(tx_buffer,
-								    dma)),
+					tx_buffer->skb->data,
 					dma_unmap_len(tx_buffer, len),
 					true);
 		}
@@ -474,10 +473,12 @@ rx_ring_summary:
 					(u64)rx_buffer_info->dma,
 					rx_buffer_info->skb);
 
-				if (netif_msg_pktdata(adapter)) {
+				if (netif_msg_pktdata(adapter) &&
+				    rx_buffer_info->dma) {
 					print_hex_dump(KERN_INFO, "",
 					   DUMP_PREFIX_ADDRESS, 16, 1,
-					   phys_to_virt(rx_buffer_info->dma),
+					   page_address(rx_buffer_info->page) +
+						    rx_buffer_info->page_offset,
 					   ixgbe_rx_bufsz(rx_ring), true);
 				}
 			}
-- 
1.7.11.2
