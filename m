From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 14/46] net: sunbmac: cleanup magic '34'
Date: Mon, 11 Jul 2011 02:52:50 +0200 (CEST)
Message-ID: <3dd566e33bcf1fc1ff9d3c0ba67b697e7df00ec6.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43685 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471Ab1GKAwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:53 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Offset of 34 bytes (32+2) after aligning the skb->data to 64 looks
suspicious. Remove the alignment, and use NET_IP_ALIGN instead of the m=
agic.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/sunbmac.c |   32 ++++++++++++++------------------
 1 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index e28d3ea..efc5389 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -228,24 +228,21 @@ static void bigmac_init_rings(struct bigmac *bp, =
int from_irq)
 	for (i =3D 0; i < RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
=20
-		skb =3D __netdev_alloc_skb_aligned(dev,
-						 RX_BUF_ALLOC_SIZE,
-						 SUNBMAC_RX_ALIGNMENT,
-						 gfp_flags);
+		skb =3D __netdev_alloc_skb(dev, RX_BUF_ALLOC_SIZE,
+					 gfp_flags);
 		if (!skb)
 			continue;
=20
 		bp->rx_skbs[i] =3D skb;
-
-		skb_reserve(skb, 34);
+		skb_reserve(skb, NET_IP_ALIGN);
=20
 		bb->be_rxd[i].rx_addr =3D
 			dma_map_single(&bp->bigmac_op->dev,
 				       skb->data,
-				       RX_BUF_ALLOC_SIZE - 34,
+				       RX_BUF_ALLOC_SIZE - NET_IP_ALIGN,
 				       DMA_FROM_DEVICE);
 		bb->be_rxd[i].rx_flags =3D
-			(RXD_OWN | ((RX_BUF_ALLOC_SIZE - 34) & RXD_LENGTH));
+			(RXD_OWN | ((RX_BUF_ALLOC_SIZE - NET_IP_ALIGN) & RXD_LENGTH));
 	}
=20
 	for (i =3D 0; i < TX_RING_SIZE; i++)
@@ -820,7 +817,7 @@ static void bigmac_rx(struct bigmac *bp)
 			/* Return it to the BigMAC. */
 			bp->enet_stats.rx_dropped++;
 			this->rx_flags =3D
-				(RXD_OWN | ((RX_BUF_ALLOC_SIZE - 34) & RXD_LENGTH));
+				(RXD_OWN | ((RX_BUF_ALLOC_SIZE - NET_IP_ALIGN) & RXD_LENGTH));
 			goto next;
 		}
 		skb =3D bp->rx_skbs[elem];
@@ -828,27 +825,26 @@ static void bigmac_rx(struct bigmac *bp)
 			struct sk_buff *new_skb;
=20
 			/* Now refill the entry, if we can. */
-			new_skb =3D __netdev_alloc_skb_aligned(dev,
-							     RX_BUF_ALLOC_SIZE,
-							     SUNBMAC_RX_ALIGNMENT,
-							     GFP_ATOMIC);
+			new_skb =3D __netdev_alloc_skb(dev,
+						     RX_BUF_ALLOC_SIZE,
+						     GFP_ATOMIC);
 			if (new_skb =3D=3D NULL) {
 				drops++;
 				goto drop_it;
 			}
 			dma_unmap_single(&bp->bigmac_op->dev,
 					 this->rx_addr,
-					 RX_BUF_ALLOC_SIZE - 34,
+					 RX_BUF_ALLOC_SIZE - NET_IP_ALIGN,
 					 DMA_FROM_DEVICE);
 			bp->rx_skbs[elem] =3D new_skb;
-			skb_reserve(new_skb, 34);
+			skb_reserve(new_skb, NET_IP_ALIGN);
 			this->rx_addr =3D
 				dma_map_single(&bp->bigmac_op->dev,
 					       new_skb->data,
-					       RX_BUF_ALLOC_SIZE - 34,
+					       RX_BUF_ALLOC_SIZE - NET_IP_ALIGN,
 					       DMA_FROM_DEVICE);
 			this->rx_flags =3D
-				(RXD_OWN | ((RX_BUF_ALLOC_SIZE - 34) & RXD_LENGTH));
+				(RXD_OWN | ((RX_BUF_ALLOC_SIZE - NET_IP_ALIGN) & RXD_LENGTH));
=20
 			skb_put(skb, len);
 		} else {
@@ -870,7 +866,7 @@ static void bigmac_rx(struct bigmac *bp)
=20
 			/* Reuse original ring buffer. */
 			this->rx_flags =3D
-				(RXD_OWN | ((RX_BUF_ALLOC_SIZE - 34) & RXD_LENGTH));
+				(RXD_OWN | ((RX_BUF_ALLOC_SIZE - NET_IP_ALIGN) & RXD_LENGTH));
=20
 			skb =3D copy_skb;
 		}
--=20
1.7.5.4

