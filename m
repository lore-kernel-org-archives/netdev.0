From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 11/13] bna: Embed SKB Length in TX Vector
Date: Wed, 20 Nov 2013 21:54:15 -0800
Message-ID: <1385013257-32745-12-git-send-email-rmody@brocade.com>
References: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:55691 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751952Ab3KUGMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:12:06 -0500
In-Reply-To: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 - Store the length of the skb buffer mapped along with the handle and use it
   while unmapping the buffer.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 6 ++++--
 drivers/net/ethernet/brocade/bna/bnad.h | 1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 797d0f2..949eb2a 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -146,7 +146,8 @@ bnad_tx_buff_unmap(struct bnad *bnad,
 
 		dma_unmap_page(&bnad->pcidev->dev,
 			dma_unmap_addr(&unmap->vectors[vector], dma_addr),
-			skb_shinfo(skb)->frags[nvecs].size, DMA_TO_DEVICE);
+			dma_unmap_len(&unmap->vectors[vector], dma_len),
+			DMA_TO_DEVICE);
 		dma_unmap_addr_set(&unmap->vectors[vector], dma_addr, 0);
 		nvecs--;
 	}
@@ -3034,7 +3035,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	for (i = 0, vect_id = 0; i < vectors - 1; i++) {
 		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
-		u16		size = skb_frag_size(frag);
+		u32		size = skb_frag_size(frag);
 
 		if (unlikely(size == 0)) {
 			/* Undo the changes starting at tcb->producer_index */
@@ -3059,6 +3060,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 		dma_addr = skb_frag_dma_map(&bnad->pcidev->dev, frag,
 					    0, size, DMA_TO_DEVICE);
+		unmap->vectors[vect_id].dma_len = size;
 		BNA_SET_DMA_ADDR(dma_addr, &txqent->vector[vect_id].host_addr);
 		txqent->vector[vect_id].length = htons(size);
 		dma_unmap_addr_set(&unmap->vectors[vect_id], dma_addr,
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index f2b50d9..474a597 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -222,6 +222,7 @@ struct bnad_rx_info {
 
 struct bnad_tx_vector {
 	DEFINE_DMA_UNMAP_ADDR(dma_addr);
+	DEFINE_DMA_UNMAP_LEN(dma_len);
 };
 
 struct bnad_tx_unmap {
-- 
1.8.2.3
