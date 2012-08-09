From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 2/3] e1000e: fix panic while dumping packets on Tx hang with IOMMU
Date: Thu,  9 Aug 2012 02:39:11 -0700
Message-ID: <1344505152-28167-3-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1344505152-28167-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6239 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495Ab2HIJjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 05:39:22 -0400
In-Reply-To: <1344505152-28167-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch resolves a "BUG: unable to handle kernel paging request at ..."
oops while dumping packet data. The issue occurs with IOMMU enabled due to
the address provided by phys_to_virt().

This patch avoids phys_to_virt() by using skb->data and the address of the
pages allocated for Rx.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 36 +++++++++++++++++++++---------
 1 file changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 95b2453..46c3b1f 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -178,6 +178,24 @@ static void e1000_regdump(struct e1000_hw *hw, struct e1000_reg_info *reginfo)
 	pr_info("%-15s %08x %08x\n", rname, regs[0], regs[1]);
 }
 
+static void e1000e_dump_ps_pages(struct e1000_adapter *adapter,
+				 struct e1000_buffer *bi)
+{
+	int i;
+	struct e1000_ps_page *ps_page;
+
+	for (i = 0; i < adapter->rx_ps_pages; i++) {
+		ps_page = &bi->ps_pages[i];
+
+		if (ps_page->page) {
+			pr_info("packet dump for ps_page %d:\n", i);
+			print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS,
+				       16, 1, page_address(ps_page->page),
+				       PAGE_SIZE, true);
+		}
+	}
+}
+
 /*
  * e1000e_dump - Print registers, Tx-ring and Rx-ring
  */
@@ -299,10 +317,10 @@ static void e1000e_dump(struct e1000_adapter *adapter)
 			(unsigned long long)buffer_info->time_stamp,
 			buffer_info->skb, next_desc);
 
-		if (netif_msg_pktdata(adapter) && buffer_info->dma != 0)
+		if (netif_msg_pktdata(adapter) && buffer_info->skb)
 			print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS,
-				       16, 1, phys_to_virt(buffer_info->dma),
-				       buffer_info->length, true);
+				       16, 1, buffer_info->skb->data,
+				       buffer_info->skb->len, true);
 	}
 
 	/* Print Rx Ring Summary */
@@ -381,10 +399,8 @@ rx_ring_summary:
 					buffer_info->skb, next_desc);
 
 				if (netif_msg_pktdata(adapter))
-					print_hex_dump(KERN_INFO, "",
-						DUMP_PREFIX_ADDRESS, 16, 1,
-						phys_to_virt(buffer_info->dma),
-						adapter->rx_ps_bsize0, true);
+					e1000e_dump_ps_pages(adapter,
+							     buffer_info);
 			}
 		}
 		break;
@@ -444,12 +460,12 @@ rx_ring_summary:
 					(unsigned long long)buffer_info->dma,
 					buffer_info->skb, next_desc);
 
-				if (netif_msg_pktdata(adapter))
+				if (netif_msg_pktdata(adapter) &&
+				    buffer_info->skb)
 					print_hex_dump(KERN_INFO, "",
 						       DUMP_PREFIX_ADDRESS, 16,
 						       1,
-						       phys_to_virt
-						       (buffer_info->dma),
+						       buffer_info->skb->data,
 						       adapter->rx_buffer_len,
 						       true);
 			}
-- 
1.7.11.2
