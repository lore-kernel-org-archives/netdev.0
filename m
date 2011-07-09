From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 16/21] net: tulip/interrupt.c: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:53 +0200 (CEST)
Message-ID: <14a1560aa41b0a21d9c20fdcdde79fff93114f30.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51946 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754262Ab1GIRR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:56 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note:
The driver has NAPI and non-NAPI versions that look the same.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/tulip/interrupt.c |   77 ++++++++-------------------------=
-------
 1 files changed, 16 insertions(+), 61 deletions(-)

diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrup=
t.c
index 5350d75..990f2a7 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -200,32 +200,14 @@ int tulip_poll(struct napi_struct *napi, int budg=
et)
 						dev->stats.rx_fifo_errors++;
                                }
                        } else {
-                               struct sk_buff *skb;
-
-                               /* Check if the packet is long enough t=
o accept without copying
-                                  to a minimally-sized skbuff. */
-                               if (pkt_len < tulip_rx_copybreak &&
-                                   (skb =3D dev_alloc_skb(pkt_len + 2)=
) !=3D NULL) {
-                                       skb_reserve(skb, 2);    /* 16 b=
yte align the IP header */
-                                       pci_dma_sync_single_for_cpu(tp-=
>pdev,
-								   tp->rx_buffers[entry].mapping,
-								   pkt_len, PCI_DMA_FROMDEVICE);
-#if ! defined(__alpha__)
-                                       skb_copy_to_linear_data(skb, tp=
->rx_buffers[entry].skb->data,
-                                                        pkt_len);
-                                       skb_put(skb, pkt_len);
-#else
-                                       memcpy(skb_put(skb, pkt_len),
-                                              tp->rx_buffers[entry].sk=
b->data,
-                                              pkt_len);
-#endif
-                                       pci_dma_sync_single_for_device(=
tp->pdev,
-								      tp->rx_buffers[entry].mapping,
-								      pkt_len, PCI_DMA_FROMDEVICE);
-                               } else {        /* Pass up the skb alre=
ady on the Rx ring. */
-                                       char *temp =3D skb_put(skb =3D =
tp->rx_buffers[entry].skb,
-                                                            pkt_len);
+				struct sk_buff *skb =3D dev_skb_finish_rx_dma(
+					&tp->rx_buffers[entry].skb,
+					pkt_len, tulip_rx_copybreak,
+					&tp->pdev->dev,
+					tp->rx_buffers[entry].mapping,
+					PKT_BUF_SZ);
=20
+				if (!tp->rx_buffers[entry].skb) {
 #ifndef final_version
                                        if (tp->rx_buffers[entry].mappi=
ng !=3D
                                            le32_to_cpu(tp->rx_ring[ent=
ry].buffer1)) {
@@ -233,14 +215,9 @@ int tulip_poll(struct napi_struct *napi, int budge=
t)
 						       "Internal fault: The skbuff addresses do not match in tul=
ip_rx: %08x vs. %08llx %p / %p\n",
 						       le32_to_cpu(tp->rx_ring[entry].buffer1),
 						       (unsigned long long)tp->rx_buffers[entry].mapping,
-						       skb->head, temp);
+						       skb->head, skb->data);
                                        }
 #endif
-
-                                       pci_unmap_single(tp->pdev, tp->=
rx_buffers[entry].mapping,
-                                                        PKT_BUF_SZ, PC=
I_DMA_FROMDEVICE);
-
-                                       tp->rx_buffers[entry].skb =3D N=
ULL;
                                        tp->rx_buffers[entry].mapping =3D=
 0;
                                }
                                skb->protocol =3D eth_type_trans(skb, d=
ev);
@@ -426,32 +403,14 @@ static int tulip_rx(struct net_device *dev)
 					dev->stats.rx_fifo_errors++;
 			}
 		} else {
-			struct sk_buff *skb;
-
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < tulip_rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single_for_cpu(tp->pdev,
-							    tp->rx_buffers[entry].mapping,
-							    pkt_len, PCI_DMA_FROMDEVICE);
-#if ! defined(__alpha__)
-				skb_copy_to_linear_data(skb, tp->rx_buffers[entry].skb->data,
-						 pkt_len);
-				skb_put(skb, pkt_len);
-#else
-				memcpy(skb_put(skb, pkt_len),
-				       tp->rx_buffers[entry].skb->data,
-				       pkt_len);
-#endif
-				pci_dma_sync_single_for_device(tp->pdev,
-							       tp->rx_buffers[entry].mapping,
-							       pkt_len, PCI_DMA_FROMDEVICE);
-			} else { 	/* Pass up the skb already on the Rx ring. */
-				char *temp =3D skb_put(skb =3D tp->rx_buffers[entry].skb,
-						     pkt_len);
+			struct sk_buff *skb =3D dev_skb_finish_rx_dma(
+				&tp->rx_buffers[entry].skb,
+				pkt_len, tulip_rx_copybreak,
+				&tp->pdev->dev,
+				tp->rx_buffers[entry].mapping,
+				PKT_BUF_SZ);
=20
+			if (!tp->rx_buffers[entry].skb) {
 #ifndef final_version
 				if (tp->rx_buffers[entry].mapping !=3D
 				    le32_to_cpu(tp->rx_ring[entry].buffer1)) {
@@ -459,14 +418,10 @@ static int tulip_rx(struct net_device *dev)
 						"Internal fault: The skbuff addresses do not match in tulip_rx: =
%08x vs. %Lx %p / %p\n",
 						le32_to_cpu(tp->rx_ring[entry].buffer1),
 						(long long)tp->rx_buffers[entry].mapping,
-						skb->head, temp);
+						skb->head, skb->data);
 				}
 #endif
=20
-				pci_unmap_single(tp->pdev, tp->rx_buffers[entry].mapping,
-						 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
-
-				tp->rx_buffers[entry].skb =3D NULL;
 				tp->rx_buffers[entry].mapping =3D 0;
 			}
 			skb->protocol =3D eth_type_trans(skb, dev);
--=20
1.7.5.4

