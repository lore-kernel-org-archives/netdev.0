From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bna: use netdev_alloc_skb_ip_align()
Date: Fri, 08 Jul 2011 17:29:30 +0200
Message-ID: <1310138970.2333.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65306 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360Ab1GHP3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 11:29:43 -0400
Received: by wyg8 with SMTP id 8so1388470wyg.19
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2011 08:29:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some workloads need some headroom (NET_SKB_PAD) to avoid expensive
reallocations.

Using netdev_alloc_skb_ip_align() instead of bare skb_alloc() brings the
NET_IP_ALIGN and the NET_SKB_PAD headroom.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Rasesh Mody <rmody@brocade.com>
CC: Debashis Dutt <ddutt@brocade.com>
---
 drivers/net/bna/bnad.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 44e219c..795b93b 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -386,14 +386,12 @@ bnad_alloc_n_post_rxbufs(struct bnad *bnad, struct bna_rcb *rcb)
 			BNA_RXQ_QPGE_PTR_GET(unmap_prod, rcb->sw_qpt, rxent,
 					     wi_range);
 		}
-		skb = alloc_skb(rcb->rxq->buffer_size + NET_IP_ALIGN,
-				     GFP_ATOMIC);
+		skb = netdev_alloc_skb_ip_align(bnad->netdev,
+						rcb->rxq->buffer_size);
 		if (unlikely(!skb)) {
 			BNAD_UPDATE_CTR(bnad, rxbuf_alloc_failed);
 			goto finishing;
 		}
-		skb->dev = bnad->netdev;
-		skb_reserve(skb, NET_IP_ALIGN);
 		unmap_array[unmap_prod].skb = skb;
 		dma_addr = dma_map_single(&bnad->pcidev->dev, skb->data,
 					  rcb->rxq->buffer_size,


