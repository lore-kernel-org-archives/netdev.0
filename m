From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [net-next] vmxnet3: Fix memory leaks in rx path (fwd)
Date: Fri, 19 Jun 2015 13:37:03 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1506191336230.12845@promg-1n-a-dhcp378.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:36964 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755492AbbFSUgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 16:36:14 -0400
Received: from sc9-mailhost3.vmware.com (sc9-mailhost3.vmware.com [10.113.161.73])
	by smtp-outbound-1.vmware.com (Postfix) with ESMTP id 07EEA28CD8
	for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 13:36:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If rcd length was zero, the page used for frag was not being released. It
was being replaced with a newly allocated page. This change takes care
of that memory leak.

Signed-off-by: Guolin Yang <gyang@vmware.com>
Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index bb35210..ab53975 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -861,6 +861,9 @@ vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 					     , skb_headlen(skb));
 		}
 
+		if (skb->len <= VMXNET3_HDR_COPY_SIZE)
+			ctx->copy_size = skb->len;
+
 		/* make sure headers are accessible directly */
 		if (unlikely(!pskb_may_pull(skb, ctx->copy_size)))
 			goto err;
@@ -1273,36 +1276,36 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 			if (skip_page_frags)
 				goto rcd_done;
 
-			new_page = alloc_page(GFP_ATOMIC);
-			if (unlikely(new_page == NULL)) {
+			if (rcd->len) {
+				new_page = alloc_page(GFP_ATOMIC);
 				/* Replacement page frag could not be allocated.
 				 * Reuse this page. Drop the pkt and free the
 				 * skb which contained this page as a frag. Skip
 				 * processing all the following non-sop frags.
 				 */
-				rq->stats.rx_buf_alloc_failure++;
-				dev_kfree_skb(ctx->skb);
-				ctx->skb = NULL;
-				skip_page_frags = true;
-				goto rcd_done;
-			}
+				if (unlikely(!new_page)) {
+					rq->stats.rx_buf_alloc_failure++;
+					dev_kfree_skb(ctx->skb);
+					ctx->skb = NULL;
+					skip_page_frags = true;
+					goto rcd_done;
+				}
 
-			if (rcd->len) {
 				dma_unmap_page(&adapter->pdev->dev,
 					       rbi->dma_addr, rbi->len,
 					       PCI_DMA_FROMDEVICE);
 
 				vmxnet3_append_frag(ctx->skb, rcd, rbi);
-			}
 
-			/* Immediate refill */
-			rbi->page = new_page;
-			rbi->dma_addr = dma_map_page(&adapter->pdev->dev,
-						     rbi->page,
-						     0, PAGE_SIZE,
-						     PCI_DMA_FROMDEVICE);
-			rxd->addr = cpu_to_le64(rbi->dma_addr);
-			rxd->len = rbi->len;
+				/* Immediate refill */
+				rbi->page = new_page;
+				rbi->dma_addr = dma_map_page(&adapter->pdev->dev
+							, rbi->page,
+							0, PAGE_SIZE,
+							PCI_DMA_FROMDEVICE);
+				rxd->addr = cpu_to_le64(rbi->dma_addr);
+				rxd->len = rbi->len;
+			}
 		}
 
 
