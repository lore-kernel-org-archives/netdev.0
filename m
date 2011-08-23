From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next,v4 11/12] bna: SKB PCI UNMAP Fix
Date: Tue, 23 Aug 2011 10:56:07 -0700
Message-ID: <1314122168-14314-12-git-send-email-rmody@brocade.com>
References: <1314122168-14314-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:47483 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754392Ab1HWR4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 13:56:48 -0400
In-Reply-To: <1314122168-14314-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Found a leak in sk_buff unmapping of PCI dma addresses where boundary
   conditions are not properly handled in freeing all Tx buffers. Freeing
   of all Tx buffers is done considering sk_buffs data and fragments can
   be mapped at the boundary.

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |   39 ++++++++-----------------------
 1 files changed, 10 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 16fa435..07570d3 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -133,39 +133,20 @@ bnad_free_all_txbufs(struct bnad *bnad,
 	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
 	struct bnad_skb_unmap *unmap_array;
 	struct sk_buff		*skb = NULL;
-	int			i;
+	int			q;
 
 	unmap_array = unmap_q->unmap_array;
 
-	unmap_cons = 0;
-	while (unmap_cons < unmap_q->q_depth) {
-		skb = unmap_array[unmap_cons].skb;
-		if (!skb) {
-			unmap_cons++;
+	for (q = 0; q < unmap_q->q_depth; q++) {
+		skb = unmap_array[q].skb;
+		if (!skb)
 			continue;
-		}
-		unmap_array[unmap_cons].skb = NULL;
-
-		dma_unmap_single(&bnad->pcidev->dev,
-				 dma_unmap_addr(&unmap_array[unmap_cons],
-						dma_addr), skb_headlen(skb),
-						DMA_TO_DEVICE);
 
-		dma_unmap_addr_set(&unmap_array[unmap_cons], dma_addr, 0);
-		if (++unmap_cons >= unmap_q->q_depth)
-			break;
+		unmap_cons = q;
+		BNAD_PCI_UNMAP_SKB(&bnad->pcidev->dev, unmap_array, unmap_cons,
+				   unmap_q->q_depth, skb,
+				   skb_shinfo(skb)->nr_frags);
 
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			dma_unmap_page(&bnad->pcidev->dev,
-				       dma_unmap_addr(&unmap_array[unmap_cons],
-						      dma_addr),
-				       skb_shinfo(skb)->frags[i].size,
-				       DMA_TO_DEVICE);
-			dma_unmap_addr_set(&unmap_array[unmap_cons], dma_addr,
-					   0);
-			if (++unmap_cons >= unmap_q->q_depth)
-				break;
-		}
 		dev_kfree_skb_any(skb);
 	}
 }
-- 
1.7.1

