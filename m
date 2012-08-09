From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 1/3] igb: fix panic while dumping packets on Tx hang with IOMMU
Date: Thu,  9 Aug 2012 02:39:10 -0700
Message-ID: <1344505152-28167-2-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1344505152-28167-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6239 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753133Ab2HIJjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 05:39:22 -0400
In-Reply-To: <1344505152-28167-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch resolves a "BUG: unable to handle kernel paging request at ..."
oops while dumping packet data. The issue occurs with IOMMU enabled due to
the address provided by phys_to_virt().

This patch avoids phys_to_virt() by making using skb->data and the address
of the pages allocated for Rx.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b7c2d50..48cc4fb 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -462,10 +462,10 @@ static void igb_dump(struct igb_adapter *adapter)
 				(u64)buffer_info->time_stamp,
 				buffer_info->skb, next_desc);
 
-			if (netif_msg_pktdata(adapter) && buffer_info->dma != 0)
+			if (netif_msg_pktdata(adapter) && buffer_info->skb)
 				print_hex_dump(KERN_INFO, "",
 					DUMP_PREFIX_ADDRESS,
-					16, 1, phys_to_virt(buffer_info->dma),
+					16, 1, buffer_info->skb->data,
 					buffer_info->length, true);
 		}
 	}
@@ -547,18 +547,17 @@ rx_ring_summary:
 					(u64)buffer_info->dma,
 					buffer_info->skb, next_desc);
 
-				if (netif_msg_pktdata(adapter)) {
+				if (netif_msg_pktdata(adapter) &&
+				    buffer_info->dma && buffer_info->skb) {
 					print_hex_dump(KERN_INFO, "",
-						DUMP_PREFIX_ADDRESS,
-						16, 1,
-						phys_to_virt(buffer_info->dma),
-						IGB_RX_HDR_LEN, true);
+						  DUMP_PREFIX_ADDRESS,
+						  16, 1, buffer_info->skb->data,
+						  IGB_RX_HDR_LEN, true);
 					print_hex_dump(KERN_INFO, "",
 					  DUMP_PREFIX_ADDRESS,
 					  16, 1,
-					  phys_to_virt(
-					    buffer_info->page_dma +
-					    buffer_info->page_offset),
+					  page_address(buffer_info->page) +
+						      buffer_info->page_offset,
 					  PAGE_SIZE/2, true);
 				}
 			}
-- 
1.7.11.2
