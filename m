From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 03/21] net: epic100: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:51 +0200 (CEST)
Message-ID: <445d0b178e1dc456d443f2b6925d62bb5ad240de.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37399 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754111Ab1GIRRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:53 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/epic100.c |   32 ++++++++------------------------
 1 files changed, 8 insertions(+), 24 deletions(-)

diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 814c187..0a22072 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1188,37 +1188,21 @@ static int epic_rx(struct net_device *dev, int =
budget)
 		} else {
 			/* Malloc up new buffer, compatible with net-2e. */
 			/* Omit the four octet CRC from the length. */
-			short pkt_len =3D (status >> 16) - 4;
+			short pkt_len =3D (status >> 16) - ETH_FCS_LEN;
 			struct sk_buff *skb;
=20
-			if (pkt_len > PKT_BUF_SZ - 4) {
+			if (pkt_len > PKT_BUF_SZ - ETH_FCS_LEN) {
 				printk(KERN_ERR "%s: Oversized Ethernet frame, status %x "
 					   "%d bytes.\n",
 					   dev->name, status, pkt_len);
 				pkt_len =3D 1514;
 			}
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single_for_cpu(ep->pci_dev,
-							    ep->rx_ring[entry].bufaddr,
-							    ep->rx_buf_sz,
-							    PCI_DMA_FROMDEVICE);
-				skb_copy_to_linear_data(skb, ep->rx_skbuff[entry]->data, pkt_len);
-				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(ep->pci_dev,
-							       ep->rx_ring[entry].bufaddr,
-							       ep->rx_buf_sz,
-							       PCI_DMA_FROMDEVICE);
-			} else {
-				pci_unmap_single(ep->pci_dev,
-					ep->rx_ring[entry].bufaddr,
-					ep->rx_buf_sz, PCI_DMA_FROMDEVICE);
-				skb_put(skb =3D ep->rx_skbuff[entry], pkt_len);
-				ep->rx_skbuff[entry] =3D NULL;
-			}
+
+			skb =3D dev_skb_finish_rx_dma(&ep->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&ep->pci_dev->dev, ep->rx_ring[entry].bufaddr,
+				ep->rx_buf_sz);
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			netif_receive_skb(skb);
 			dev->stats.rx_packets++;
--=20
1.7.5.4

