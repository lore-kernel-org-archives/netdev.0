From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 21/21] net: yellowfin: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:53 +0200 (CEST)
Message-ID: <bf7f9370b83ff9297f5100b435f2a060347a5275.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51950 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754353Ab1GIRR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:57 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/yellowfin.c |   27 ++++++---------------------
 1 files changed, 6 insertions(+), 21 deletions(-)

diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 3e5ac60..e1aa4a6 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -1124,27 +1124,12 @@ static int yellowfin_rx(struct net_device *dev)
 				printk(KERN_DEBUG "  %s() normal Rx pkt length %d of %d, bogus_cnt=
 %d\n",
 				       __func__, pkt_len, data_size, boguscnt);
 #endif
-			/* Check if the packet is long enough to just pass up the skbuff
-			   without copying to a properly sized skbuff. */
-			if (pkt_len > rx_copybreak) {
-				skb_put(skb =3D rx_skb, pkt_len);
-				pci_unmap_single(yp->pci_dev,
-					le32_to_cpu(yp->rx_ring[entry].addr),
-					yp->rx_buf_sz,
-					PCI_DMA_FROMDEVICE);
-				yp->rx_skbuff[entry] =3D NULL;
-			} else {
-				skb =3D dev_alloc_skb(pkt_len + 2);
-				if (skb =3D=3D NULL)
-					break;
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				skb_copy_to_linear_data(skb, rx_skb->data, pkt_len);
-				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(yp->pci_dev,
-								le32_to_cpu(desc->addr),
-								yp->rx_buf_sz,
-								PCI_DMA_FROMDEVICE);
-			}
+			skb =3D dev_skb_finish_rx_dma(&yp->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&yp->pci_dev->dev,
+				le32_to_cpu(desc->addr),
+				yp->rx_buf_sz);
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->stats.rx_packets++;
--=20
1.7.5.4

