From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 02/21] net: 3c59x: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:51 +0200 (CEST)
Message-ID: <5a242c5dbd6222d87b77a22b9c6fe6cdfa0351f3.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37397 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753779Ab1GIRRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:53 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/3c59x.c |   23 ++++++-----------------
 1 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 8cc2256..456726c 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2576,25 +2576,14 @@ boomerang_rx(struct net_device *dev)
 				pr_debug("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
=20
-			/* Check if the packet is long enough to just accept without
-			   copying to a properly sized skbuff. */
-			if (pkt_len < rx_copybreak && (skb =3D dev_alloc_skb(pkt_len + 2)) =
!=3D NULL) {
-				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
-				pci_dma_sync_single_for_cpu(VORTEX_PCI(vp), dma, PKT_BUF_SZ, PCI_D=
MA_FROMDEVICE);
-				/* 'skb_put()' points to the start of sk_buff data area. */
-				memcpy(skb_put(skb, pkt_len),
-					   vp->rx_skbuff[entry]->data,
-					   pkt_len);
-				pci_dma_sync_single_for_device(VORTEX_PCI(vp), dma, PKT_BUF_SZ, PC=
I_DMA_FROMDEVICE);
+			skb =3D dev_skb_finish_rx_dma(&vp->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&VORTEX_PCI(vp)->dev, dma, PKT_BUF_SZ);
+			if (skb)
 				vp->rx_copy++;
-			} else {
-				/* Pass up the skbuff already on the Rx ring. */
-				skb =3D vp->rx_skbuff[entry];
-				vp->rx_skbuff[entry] =3D NULL;
-				skb_put(skb, pkt_len);
-				pci_unmap_single(VORTEX_PCI(vp), dma, PKT_BUF_SZ, PCI_DMA_FROMDEVI=
CE);
+			else
 				vp->rx_nocopy++;
-			}
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			{					/* Use hardware checksum info. */
 				int csum_bits =3D rx_status & 0xee000000;
--=20
1.7.5.4

