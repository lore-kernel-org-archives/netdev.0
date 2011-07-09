From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 15/21] net: tulip/de2104x: use common rx_copybreak handling
 [strict refill!]
Date: Sat,  9 Jul 2011 19:17:53 +0200 (CEST)
Message-ID: <29374e542d6211f31b9ed0571a60b795f4aed1bb.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51954 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754217Ab1GIRRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:55 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/tulip/de2104x.c |   38 +++++++++--------------------------=
---
 1 files changed, 9 insertions(+), 29 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index ce90efc..80a34b6 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -409,8 +409,7 @@ static void de_rx (struct de_private *de)
 	while (--rx_work) {
 		u32 status, len;
 		dma_addr_t mapping;
-		struct sk_buff *skb, *copy_skb;
-		unsigned copying_skb, buflen;
+		struct sk_buff *skb;
=20
 		skb =3D de->rx_skb[rx_tail].skb;
 		BUG_ON(!skb);
@@ -432,42 +431,22 @@ static void de_rx (struct de_private *de)
 			goto rx_next;
 		}
=20
-		copying_skb =3D (len <=3D rx_copybreak);
-
 		netif_dbg(de, rx_status, de->dev,
 			  "rx slot %d status 0x%x len %d copying? %d\n",
-			  rx_tail, status, len, copying_skb);
+			  rx_tail, status, len, len <=3D rx_copybreak);
=20
-		buflen =3D copying_skb ? (len + RX_OFFSET) : de->rx_buf_sz;
-		copy_skb =3D dev_alloc_skb (buflen);
-		if (unlikely(!copy_skb)) {
+		skb =3D dev_skb_finish_rx_dma_refill(&de->rx_skb[rx_tail].skb,
+			len, rx_copybreak, 0, RX_OFFSET,
+			&de->pdev->dev, &mapping, de->rx_buf_sz);
+		de->rx_skb[rx_tail].mapping =3D mapping;
+
+		if (unlikely(!skb)) {
 			de->net_stats.rx_dropped++;
 			drop =3D 1;
 			rx_work =3D 100;
 			goto rx_next;
 		}
=20
-		if (!copying_skb) {
-			pci_unmap_single(de->pdev, mapping,
-					 buflen, PCI_DMA_FROMDEVICE);
-			skb_put(skb, len);
-
-			mapping =3D
-			de->rx_skb[rx_tail].mapping =3D
-				pci_map_single(de->pdev, copy_skb->data,
-					       buflen, PCI_DMA_FROMDEVICE);
-			de->rx_skb[rx_tail].skb =3D copy_skb;
-		} else {
-			pci_dma_sync_single_for_cpu(de->pdev, mapping, len, PCI_DMA_FROMDEV=
ICE);
-			skb_reserve(copy_skb, RX_OFFSET);
-			skb_copy_from_linear_data(skb, skb_put(copy_skb, len),
-						  len);
-			pci_dma_sync_single_for_device(de->pdev, mapping, len, PCI_DMA_FROM=
DEVICE);
-
-			/* We'll reuse the original ring buffer. */
-			skb =3D copy_skb;
-		}
-
 		skb->protocol =3D eth_type_trans (skb, de->dev);
=20
 		de->net_stats.rx_packets++;
@@ -1292,6 +1271,7 @@ static int de_refill_rx (struct de_private *de)
 		de->rx_skb[i].mapping =3D pci_map_single(de->pdev,
 			skb->data, de->rx_buf_sz, PCI_DMA_FROMDEVICE);
 		de->rx_skb[i].skb =3D skb;
+		skb_reserve(skb, RX_OFFSET);
=20
 		de->rx_ring[i].opts1 =3D cpu_to_le32(DescOwn);
 		if (i =3D=3D (DE_RX_RING_SIZE - 1))
--=20
1.7.5.4

