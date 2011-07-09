From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 04/21] net: fealnx: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:51 +0200 (CEST)
Message-ID: <07c0278a1a313fd8c244c544a69cd5cfd12b7065.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37401 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753977Ab1GIRRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:53 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/fealnx.c |   39 +++++++--------------------------------
 1 files changed, 7 insertions(+), 32 deletions(-)

diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index fa8677c..b692a4d 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1693,46 +1693,21 @@ static int netdev_rx(struct net_device *dev)
=20
 			struct sk_buff *skb;
 			/* Omit the four octet CRC from the length. */
-			short pkt_len =3D ((rx_status & FLNGMASK) >> FLNGShift) - 4;
+			short pkt_len =3D ((rx_status & FLNGMASK) >> FLNGShift) - ETH_FCS_L=
EN;
=20
 #ifndef final_version
 			if (debug)
 				printk(KERN_DEBUG "  netdev_rx() normal Rx pkt length %d"
 				       " status %x.\n", pkt_len, rx_status);
 #endif
+			skb =3D dev_skb_finish_rx_dma(&np->cur_rx->skbuff,
+				pkt_len, rx_copybreak,
+				&np->pci_dev->dev, np->cur_rx->buffer,
+				np->rx_buf_sz);
=20
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single_for_cpu(np->pci_dev,
-							    np->cur_rx->buffer,
-							    np->rx_buf_sz,
-							    PCI_DMA_FROMDEVICE);
-				/* Call copy + cksum if available. */
-
-#if ! defined(__alpha__)
-				skb_copy_to_linear_data(skb,
-					np->cur_rx->skbuff->data, pkt_len);
-				skb_put(skb, pkt_len);
-#else
-				memcpy(skb_put(skb, pkt_len),
-					np->cur_rx->skbuff->data, pkt_len);
-#endif
-				pci_dma_sync_single_for_device(np->pci_dev,
-							       np->cur_rx->buffer,
-							       np->rx_buf_sz,
-							       PCI_DMA_FROMDEVICE);
-			} else {
-				pci_unmap_single(np->pci_dev,
-						 np->cur_rx->buffer,
-						 np->rx_buf_sz,
-						 PCI_DMA_FROMDEVICE);
-				skb_put(skb =3D np->cur_rx->skbuff, pkt_len);
-				np->cur_rx->skbuff =3D NULL;
+			if (!np->cur_rx->skbuff)
 				--np->really_rx_count;
-			}
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->stats.rx_packets++;
--=20
1.7.5.4

