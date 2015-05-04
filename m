From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 4/6] e1000: Replace e1000_free_frag with
 skb_free_frag
Date: Mon, 04 May 2015 16:15:05 -0700
Message-ID: <20150504231505.1538.58292.stgit@ahduyck-vm-fedora22>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net
To: linux-mm@kvack.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49472 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752026AbbEDXPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 19:15:10 -0400
In-Reply-To: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 983eb4e6f7aa..74dc15055971 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2079,11 +2079,6 @@ static void *e1000_alloc_frag(const struct e1000_adapter *a)
 	return data;
 }
 
-static void e1000_free_frag(const void *data)
-{
-	put_page(virt_to_head_page(data));
-}
-
 /**
  * e1000_clean_rx_ring - Free Rx Buffers per Queue
  * @adapter: board private structure
@@ -2107,7 +2102,7 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 						 adapter->rx_buffer_len,
 						 DMA_FROM_DEVICE);
 			if (buffer_info->rxbuf.data) {
-				e1000_free_frag(buffer_info->rxbuf.data);
+				skb_free_frag(buffer_info->rxbuf.data);
 				buffer_info->rxbuf.data = NULL;
 			}
 		} else if (adapter->clean_rx == e1000_clean_jumbo_rx_irq) {
@@ -4594,28 +4589,28 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 			data = e1000_alloc_frag(adapter);
 			/* Failed allocation, critical failure */
 			if (!data) {
-				e1000_free_frag(olddata);
+				skb_free_frag(olddata);
 				adapter->alloc_rx_buff_failed++;
 				break;
 			}
 
 			if (!e1000_check_64k_bound(adapter, data, bufsz)) {
 				/* give up */
-				e1000_free_frag(data);
-				e1000_free_frag(olddata);
+				skb_free_frag(data);
+				skb_free_frag(olddata);
 				adapter->alloc_rx_buff_failed++;
 				break;
 			}
 
 			/* Use new allocation */
-			e1000_free_frag(olddata);
+			skb_free_frag(olddata);
 		}
 		buffer_info->dma = dma_map_single(&pdev->dev,
 						  data,
 						  adapter->rx_buffer_len,
 						  DMA_FROM_DEVICE);
 		if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
-			e1000_free_frag(data);
+			skb_free_frag(data);
 			buffer_info->dma = 0;
 			adapter->alloc_rx_buff_failed++;
 			break;
@@ -4637,7 +4632,7 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 					 adapter->rx_buffer_len,
 					 DMA_FROM_DEVICE);
 
-			e1000_free_frag(data);
+			skb_free_frag(data);
 			buffer_info->rxbuf.data = NULL;
 			buffer_info->dma = 0;
 
