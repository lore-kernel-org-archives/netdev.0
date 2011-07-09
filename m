From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 19/21] net: via-rhine: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:53 +0200 (CEST)
Message-ID: <482551f30b3125f687454555f575bc08f216c796.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51967 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754296Ab1GIRR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:56 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/via-rhine.c |   37 +++++--------------------------------
 1 files changed, 5 insertions(+), 32 deletions(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 7f23ab9..c97265e 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1764,40 +1764,13 @@ static int rhine_rx(struct net_device *dev, int=
 limit)
 		} else {
 			struct sk_buff *skb =3D NULL;
 			/* Length should omit the CRC */
-			int pkt_len =3D data_size - 4;
+			int pkt_len =3D data_size - ETH_FCS_LEN;
 			u16 vlan_tci =3D 0;
=20
-			/* Check if the packet is long enough to accept without
-			   copying to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak)
-				skb =3D netdev_alloc_skb_ip_align(dev, pkt_len);
-			if (skb) {
-				pci_dma_sync_single_for_cpu(rp->pdev,
-							    rp->rx_skbuff_dma[entry],
-							    rp->rx_buf_sz,
-							    PCI_DMA_FROMDEVICE);
-
-				skb_copy_to_linear_data(skb,
-						 rp->rx_skbuff[entry]->data,
-						 pkt_len);
-				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(rp->pdev,
-							       rp->rx_skbuff_dma[entry],
-							       rp->rx_buf_sz,
-							       PCI_DMA_FROMDEVICE);
-			} else {
-				skb =3D rp->rx_skbuff[entry];
-				if (skb =3D=3D NULL) {
-					netdev_err(dev, "Inconsistent Rx descriptor chain\n");
-					break;
-				}
-				rp->rx_skbuff[entry] =3D NULL;
-				skb_put(skb, pkt_len);
-				pci_unmap_single(rp->pdev,
-						 rp->rx_skbuff_dma[entry],
-						 rp->rx_buf_sz,
-						 PCI_DMA_FROMDEVICE);
-			}
+			skb =3D dev_skb_finish_rx_dma(&rp->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&rp->pdev->dev, rp->rx_skbuff_dma[entry],
+				rp->rx_buf_sz);
=20
 			if (unlikely(desc_length & DescTag))
 				vlan_tci =3D rhine_get_vlan_tci(skb, data_size);
--=20
1.7.5.4

