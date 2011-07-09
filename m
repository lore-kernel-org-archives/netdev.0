From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 08/21] net: natsemi: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:51 +0200 (CEST)
Message-ID: <8484cbd5bd425b05b627d94dfd93bc6de7e7cdf4.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Hockin <thockin@hockin.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51949 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754177Ab1GIRRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:55 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/natsemi.c |   30 +++++-------------------------
 1 files changed, 5 insertions(+), 25 deletions(-)

diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 8f8b65a..b461321 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2340,31 +2340,11 @@ static void netdev_rx(struct net_device *dev, i=
nt *work_done, int work_to_do)
 			 */
 		} else {
 			struct sk_buff *skb;
-			/* Omit CRC size. */
-			/* Check if the packet is long enough to accept
-			 * without copying to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + RX_OFFSET)) !=3D NULL) {
-				/* 16 byte align the IP header */
-				skb_reserve(skb, RX_OFFSET);
-				pci_dma_sync_single_for_cpu(np->pci_dev,
-					np->rx_dma[entry],
-					buflen,
-					PCI_DMA_FROMDEVICE);
-				skb_copy_to_linear_data(skb,
-					np->rx_skbuff[entry]->data, pkt_len);
-				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(np->pci_dev,
-					np->rx_dma[entry],
-					buflen,
-					PCI_DMA_FROMDEVICE);
-			} else {
-				pci_unmap_single(np->pci_dev, np->rx_dma[entry],
-						 buflen + NATSEMI_PADDING,
-						 PCI_DMA_FROMDEVICE);
-				skb_put(skb =3D np->rx_skbuff[entry], pkt_len);
-				np->rx_skbuff[entry] =3D NULL;
-			}
+
+			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&np->pci_dev->dev, np->rx_dma[entry], buflen);
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			netif_receive_skb(skb);
 			dev->stats.rx_packets++;
--=20
1.7.5.4

