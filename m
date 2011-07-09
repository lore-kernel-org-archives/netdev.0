From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 18/21] net: typhoon: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:53 +0200 (CEST)
Message-ID: <86c335595654802d096c5c6c79f5d3fb71d4bd22.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Dillow <dave@thedillows.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51949 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754060Ab1GIRR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:56 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: fix inverted test on skb refill/reuse

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/typhoon.c |   26 +++++++-------------------
 1 files changed, 7 insertions(+), 19 deletions(-)

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 1d5091a..e769cad 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1646,7 +1646,7 @@ typhoon_rx(struct typhoon *tp, struct basic_ring =
*rxRing, volatile __le32 * read
 	   volatile __le32 * cleared, int budget)
 {
 	struct rx_desc *rx;
-	struct sk_buff *skb, *new_skb;
+	struct sk_buff *new_skb;
 	struct rxbuff_ent *rxb;
 	dma_addr_t dma_addr;
 	u32 local_ready;
@@ -1663,7 +1663,6 @@ typhoon_rx(struct typhoon *tp, struct basic_ring =
*rxRing, volatile __le32 * read
 		rx =3D (struct rx_desc *) (rxRing->ringBase + rxaddr);
 		idx =3D rx->addr;
 		rxb =3D &tp->rxbuffers[idx];
-		skb =3D rxb->skb;
 		dma_addr =3D rxb->dma_addr;
=20
 		typhoon_inc_rx_index(&rxaddr, 1);
@@ -1675,25 +1674,14 @@ typhoon_rx(struct typhoon *tp, struct basic_rin=
g *rxRing, volatile __le32 * read
=20
 		pkt_len =3D le16_to_cpu(rx->frameLen);
=20
-		if(pkt_len < rx_copybreak &&
-		   (new_skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-			skb_reserve(new_skb, 2);
-			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr,
-						    PKT_BUF_SZ,
-						    PCI_DMA_FROMDEVICE);
-			skb_copy_to_linear_data(new_skb, skb->data, pkt_len);
-			pci_dma_sync_single_for_device(tp->pdev, dma_addr,
-						       PKT_BUF_SZ,
-						       PCI_DMA_FROMDEVICE);
-			skb_put(new_skb, pkt_len);
+		new_skb =3D dev_skb_finish_rx_dma(&rxb->skb, pkt_len,
+						rx_copybreak, &tp->pdev->dev,
+						dma_addr, PKT_BUF_SZ);
+		if (rxb->skb)
 			typhoon_recycle_rx_skb(tp, idx);
-		} else {
-			new_skb =3D skb;
-			skb_put(new_skb, pkt_len);
-			pci_unmap_single(tp->pdev, dma_addr, PKT_BUF_SZ,
-				       PCI_DMA_FROMDEVICE);
+		else
 			typhoon_alloc_rx_skb(tp, idx);
-		}
+
 		new_skb->protocol =3D eth_type_trans(new_skb, tp->dev);
 		csum_bits =3D rx->rxStatus & (TYPHOON_RX_IP_CHK_GOOD |
 			TYPHOON_RX_UDP_CHK_GOOD | TYPHOON_RX_TCP_CHK_GOOD);
--=20
1.7.5.4

