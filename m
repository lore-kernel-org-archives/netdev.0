From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 06/11] e1000: Call dev_kfree_skby_any instead of dev_kfree_skb.
Date: Mon, 10 Mar 2014 20:21:23 -0700
Message-ID: <877g81pgi4.fsf_-_@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<871ty9qvaf.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37334 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018AbaCKDVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:21:36 -0400
In-Reply-To: <871ty9qvaf.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 10 Mar 2014 20:16:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 46e6544ed1b7..64036d3ef62b 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4066,7 +4066,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				 * too
 				 */
 				if (rx_ring->rx_skb_top)
-					dev_kfree_skb(rx_ring->rx_skb_top);
+					dev_kfree_skb_any(rx_ring->rx_skb_top);
 				rx_ring->rx_skb_top = NULL;
 				goto next_desc;
 			}
@@ -4143,7 +4143,7 @@ process_skb:
 		/* eth type trans needs skb->data to point to something */
 		if (!pskb_may_pull(skb, ETH_HLEN)) {
 			e_err(drv, "pskb_may_pull failed.\n");
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			goto next_desc;
 		}
 
@@ -4394,7 +4394,7 @@ check_page:
 							DMA_FROM_DEVICE);
 			if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
 				put_page(buffer_info->page);
-				dev_kfree_skb(skb);
+				dev_kfree_skb_any(skb);
 				buffer_info->page = NULL;
 				buffer_info->skb = NULL;
 				buffer_info->dma = 0;
@@ -4469,21 +4469,21 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 			skb = netdev_alloc_skb_ip_align(netdev, bufsz);
 			/* Failed allocation, critical failure */
 			if (!skb) {
-				dev_kfree_skb(oldskb);
+				dev_kfree_skb_any(oldskb);
 				adapter->alloc_rx_buff_failed++;
 				break;
 			}
 
 			if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
 				/* give up */
-				dev_kfree_skb(skb);
-				dev_kfree_skb(oldskb);
+				dev_kfree_skb_any(skb);
+				dev_kfree_skb_any(oldskb);
 				adapter->alloc_rx_buff_failed++;
 				break; /* while !buffer_info->skb */
 			}
 
 			/* Use new allocation */
-			dev_kfree_skb(oldskb);
+			dev_kfree_skb_any(oldskb);
 		}
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
@@ -4493,7 +4493,7 @@ map_skb:
 						  buffer_info->length,
 						  DMA_FROM_DEVICE);
 		if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			buffer_info->skb = NULL;
 			buffer_info->dma = 0;
 			adapter->alloc_rx_buff_failed++;
@@ -4511,7 +4511,7 @@ map_skb:
 			e_err(rx_err, "dma align check failed: %u bytes at "
 			      "%p\n", adapter->rx_buffer_len,
 			      (void *)(unsigned long)buffer_info->dma);
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			buffer_info->skb = NULL;
 
 			dma_unmap_single(&pdev->dev, buffer_info->dma,
-- 
1.7.5.4
