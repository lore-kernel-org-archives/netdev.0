From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] tg3: avoid double-freeing of rx data memory
Date: Wed,  6 Nov 2013 14:02:36 +0100
Message-ID: <1383742956-18731-1-git-send-email-ivecera@redhat.com>
Cc: davem@davemloft.net, Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31574 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756152Ab3KFNCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 08:02:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If build_skb fails the memory associated with the ring buffer is freed but
the ri->data member is not zeroed in this case. This causes a double-free
of this memory in tg3_free_rings->... path. The patch moves this block after
setting ri->data to NULL.
It would be nice to fix this bug also in stable >= v3.4 trees.

Cc: Nithin Nayak Sujir <nsujir@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 12d961c..cd76d2a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6848,12 +6848,6 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			pci_unmap_single(tp->pdev, dma_addr, skb_size,
 					 PCI_DMA_FROMDEVICE);
 
-			skb = build_skb(data, frag_size);
-			if (!skb) {
-				tg3_frag_free(frag_size != 0, data);
-				goto drop_it_no_recycle;
-			}
-			skb_reserve(skb, TG3_RX_OFFSET(tp));
 			/* Ensure that the update to the data happens
 			 * after the usage of the old DMA mapping.
 			 */
@@ -6861,6 +6855,12 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 
 			ri->data = NULL;
 
+			skb = build_skb(data, frag_size);
+			if (!skb) {
+				tg3_frag_free(frag_size != 0, data);
+				goto drop_it_no_recycle;
+			}
+			skb_reserve(skb, TG3_RX_OFFSET(tp));
 		} else {
 			tg3_recycle_rx(tnapi, tpr, opaque_key,
 				       desc_idx, *post_ptr);
-- 
1.8.1.5
