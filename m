From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 01/10] vmxnet3: use netdev_alloc_skb_ip_align
Date: Tue, 15 Jan 2013 09:28:26 -0800
Message-ID: <1358270915-32758-2-git-send-email-stephen@networkplumber.org>
References: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:32932 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779Ab3AORaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 12:30:04 -0500
Received: by mail-pb0-f50.google.com with SMTP id wz7so168654pbc.37
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 09:30:04 -0800 (PST)
In-Reply-To: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_skb_align, rather than open code using dev_alloc_skb.
Change allocation at startup to use GFP_KERNEL.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |   12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index dc8913c..3402a0c 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -580,15 +580,14 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32 ring_idx,
 
 		if (rbi->buf_type == VMXNET3_RX_BUF_SKB) {
 			if (rbi->skb == NULL) {
-				rbi->skb = dev_alloc_skb(rbi->len +
-							 NET_IP_ALIGN);
+				rbi->skb = __netdev_alloc_skb_ip_align(adapter->netdev,
+								       rbi->len,
+								       GFP_KERNEL);
 				if (unlikely(rbi->skb == NULL)) {
 					rq->stats.rx_buf_alloc_failure++;
 					break;
 				}
-				rbi->skb->dev = adapter->netdev;
 
-				skb_reserve(rbi->skb, NET_IP_ALIGN);
 				rbi->dma_addr = pci_map_single(adapter->pdev,
 						rbi->skb->data, rbi->len,
 						PCI_DMA_FROMDEVICE);
@@ -1221,7 +1220,8 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 
 			skip_page_frags = false;
 			ctx->skb = rbi->skb;
-			new_skb = dev_alloc_skb(rbi->len + NET_IP_ALIGN);
+			new_skb = netdev_alloc_skb_ip_align(adapter->netdev,
+							    rbi->len);
 			if (new_skb == NULL) {
 				/* Skb allocation failed, do not handover this
 				 * skb to stack. Reuse it. Drop the existing pkt
@@ -1239,8 +1239,6 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 			skb_put(ctx->skb, rcd->len);
 
 			/* Immediate refill */
-			new_skb->dev = adapter->netdev;
-			skb_reserve(new_skb, NET_IP_ALIGN);
 			rbi->skb = new_skb;
 			rbi->dma_addr = pci_map_single(adapter->pdev,
 						       rbi->skb->data, rbi->len,
-- 
1.7.10.4
