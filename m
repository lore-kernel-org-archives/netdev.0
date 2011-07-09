From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 07/21] net: lib82596: use common rx_copybreak handling
 [strict refill!]
Date: Sat,  9 Jul 2011 19:17:51 +0200 (CEST)
Message-ID: <041aed2721ea22ee6e7d122c3c21a59b4042f431.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51950 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754162Ab1GIRRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:55 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/lib82596.c |   66 ++++++++++------------------------------=
-------
 1 files changed, 14 insertions(+), 52 deletions(-)

diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index 9e04289..d19e05b 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -679,67 +679,29 @@ static inline int i596_rx(struct net_device *dev)
 		if (rbd !=3D NULL && (rfd->stat & SWAP16(STAT_OK))) {
 			/* a good frame */
 			int pkt_len =3D SWAP16(rbd->count) & 0x3fff;
-			struct sk_buff *skb =3D rbd->skb;
-			int rx_in_place =3D 0;
+			struct sk_buff *skb;
+			dma_addr_t dma_addr;
=20
 			DEB(DEB_RXADDR, print_eth(rbd->v_data, "received"));
 			frames++;
=20
-			/* Check if the packet is long enough to just accept
-			 * without copying to a properly sized skbuff.
-			 */
+			dma_addr =3D SWAP32(rbd->b_data);
+			skb =3D dev_skb_finish_rx_dma_refill(&rbd->skb,
+				pkt_len, rx_copybreak, NET_IP_ALIGN, 0,
+				dev->dev.parent, &dma_addr, PKT_BUF_SZ);
+			rbd->v_data =3D rbd->skb->data;
+			rbd->b_data =3D SWAP32(dma_addr);
+			DMA_WBACK_INV(dev, rbd, sizeof(struct i596_rbd));
=20
-			if (pkt_len > rx_copybreak) {
-				struct sk_buff *newskb;
-				dma_addr_t dma_addr;
-
-				dma_unmap_single(dev->dev.parent,
-						 (dma_addr_t)SWAP32(rbd->b_data),
-						 PKT_BUF_SZ, DMA_FROM_DEVICE);
-				/* Get fresh skbuff to replace filled one. */
-				newskb =3D netdev_alloc_skb_ip_align(dev,
-								   PKT_BUF_SZ);
-				if (newskb =3D=3D NULL) {
-					skb =3D NULL;	/* drop pkt */
-					goto memory_squeeze;
-				}
-
-				/* Pass up the skb already on the Rx ring. */
-				skb_put(skb, pkt_len);
-				rx_in_place =3D 1;
-				rbd->skb =3D newskb;
-				dma_addr =3D dma_map_single(dev->dev.parent,
-							  newskb->data,
-							  PKT_BUF_SZ,
-							  DMA_FROM_DEVICE);
-				rbd->v_data =3D newskb->data;
-				rbd->b_data =3D SWAP32(dma_addr);
-				DMA_WBACK_INV(dev, rbd, sizeof(struct i596_rbd));
-			} else
-				skb =3D netdev_alloc_skb_ip_align(dev, pkt_len);
-memory_squeeze:
-			if (skb =3D=3D NULL) {
-				/* XXX tulip.c can defer packets here!! */
-				printk(KERN_ERR
-				       "%s: i596_rx Memory squeeze, dropping packet.\n",
-				       dev->name);
-				dev->stats.rx_dropped++;
-			} else {
-				if (!rx_in_place) {
-					/* 16 byte align the data fields */
-					dma_sync_single_for_cpu(dev->dev.parent,
-								(dma_addr_t)SWAP32(rbd->b_data),
-								PKT_BUF_SZ, DMA_FROM_DEVICE);
-					memcpy(skb_put(skb, pkt_len), rbd->v_data, pkt_len);
-					dma_sync_single_for_device(dev->dev.parent,
-								   (dma_addr_t)SWAP32(rbd->b_data),
-								   PKT_BUF_SZ, DMA_FROM_DEVICE);
-				}
-				skb->len =3D pkt_len;
+			if (likely(skb)) {
 				skb->protocol =3D eth_type_trans(skb, dev);
 				netif_rx(skb);
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes +=3D pkt_len;
+			} else {
+				netdev_err(dev,
+				       "i596_rx Memory squeeze, dropping packet.\n");
+				dev->stats.rx_dropped++;
 			}
 		} else {
 			DEB(DEB_ERRORS, printk(KERN_DEBUG
--=20
1.7.5.4

