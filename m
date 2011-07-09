From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 05/21] net: hamachi: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:51 +0200 (CEST)
Message-ID: <a05b6f349fd9a71ec475ccf7cec8bc1425ebd758.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51946 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754131Ab1GIRRy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:54 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/hamachi.c |   43 ++++++++---------------------------------=
--
 1 files changed, 8 insertions(+), 35 deletions(-)

diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index c274b3d..68ee914 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1465,7 +1465,7 @@ static int hamachi_rx(struct net_device *dev)
 		} else {
 			struct sk_buff *skb;
 			/* Omit CRC */
-			u16 pkt_len =3D (frame_status & 0x07ff) - 4;
+			u16 pkt_len =3D (frame_status & 0x07ff) - ETH_FCS_LEN;
 #ifdef RX_CHECKSUM
 			u32 pfck =3D *(u32 *) &buf_addr[data_size - 8];
 #endif
@@ -1485,42 +1485,15 @@ static int hamachi_rx(struct net_device *dev)
 					   *(s32*)&(buf_addr[data_size - 8]),
 					   *(s32*)&(buf_addr[data_size - 4]));
 #endif
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-#ifdef RX_CHECKSUM
-				printk(KERN_ERR "%s: rx_copybreak non-zero "
-				  "not good with RX_CHECKSUM\n", dev->name);
-#endif
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single_for_cpu(hmp->pci_dev,
-							    leXX_to_cpu(hmp->rx_ring[entry].addr),
-							    hmp->rx_buf_sz,
-							    PCI_DMA_FROMDEVICE);
-				/* Call copy + cksum if available. */
-#if 1 || USE_IP_COPYSUM
-				skb_copy_to_linear_data(skb,
-					hmp->rx_skbuff[entry]->data, pkt_len);
-				skb_put(skb, pkt_len);
-#else
-				memcpy(skb_put(skb, pkt_len), hmp->rx_ring_dma
-					+ entry*sizeof(*desc), pkt_len);
-#endif
-				pci_dma_sync_single_for_device(hmp->pci_dev,
-							       leXX_to_cpu(hmp->rx_ring[entry].addr),
-							       hmp->rx_buf_sz,
-							       PCI_DMA_FROMDEVICE);
-			} else {
-				pci_unmap_single(hmp->pci_dev,
-						 leXX_to_cpu(hmp->rx_ring[entry].addr),
-						 hmp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-				skb_put(skb =3D hmp->rx_skbuff[entry], pkt_len);
-				hmp->rx_skbuff[entry] =3D NULL;
-			}
+
+			skb =3D dev_skb_finish_rx_dma(&hmp->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&hmp->pci_dev->dev,
+				leXX_to_cpu(hmp->rx_ring[entry].addr),
+				hmp->rx_buf_sz);
+
 			skb->protocol =3D eth_type_trans(skb, dev);
=20
-
 #ifdef RX_CHECKSUM
 			/* TCP or UDP on ipv4, DIX encoding */
 			if (pfck>>24 =3D=3D 0x91 || pfck>>24 =3D=3D 0x51) {
--=20
1.7.5.4

