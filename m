From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 11/21] net: sis190: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:52 +0200 (CEST)
Message-ID: <70c7510f0dc4c0bb8ccedea45efed70260f0b7f4.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51953 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754218Ab1GIRRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:55 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/sis190.c |   38 +++++---------------------------------
 1 files changed, 5 insertions(+), 33 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 8ad7bfb..6836e0d 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -530,29 +530,6 @@ static u32 sis190_rx_fill(struct sis190_private *t=
p, struct net_device *dev,
 	return cur - start;
 }
=20
-static bool sis190_try_rx_copy(struct sis190_private *tp,
-			       struct sk_buff **sk_buff, int pkt_size,
-			       dma_addr_t addr)
-{
-	struct sk_buff *skb;
-	bool done =3D false;
-
-	if (pkt_size >=3D rx_copybreak)
-		goto out;
-
-	skb =3D netdev_alloc_skb_ip_align(tp->dev, pkt_size);
-	if (!skb)
-		goto out;
-
-	pci_dma_sync_single_for_cpu(tp->pci_dev, addr, tp->rx_buf_sz,
-				PCI_DMA_FROMDEVICE);
-	skb_copy_to_linear_data(skb, sk_buff[0]->data, pkt_size);
-	*sk_buff =3D skb;
-	done =3D true;
-out:
-	return done;
-}
-
 static inline int sis190_rx_pkt_err(u32 status, struct net_device_stat=
s *stats)
 {
 #define ErrMask	(OVRUN | SHORT | LIMIT | MIIER | NIBON | COLON | ABORT=
)
@@ -612,19 +589,14 @@ static int sis190_rx_interrupt(struct net_device =
*dev,
 				continue;
 			}
=20
-
-			if (sis190_try_rx_copy(tp, &skb, pkt_size, addr)) {
-				pci_dma_sync_single_for_device(pdev, addr,
-					tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+			skb =3D dev_skb_finish_rx_dma(&tp->Rx_skbuff[entry],
+				pkt_size, rx_copybreak,
+				&pdev->dev, addr, tp->rx_buf_sz);
+			if (tp->Rx_skbuff[entry])	/* copied */
 				sis190_give_to_asic(desc, tp->rx_buf_sz);
-			} else {
-				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
-						 PCI_DMA_FROMDEVICE);
-				tp->Rx_skbuff[entry] =3D NULL;
+			else
 				sis190_make_unusable_by_asic(desc);
-			}
=20
-			skb_put(skb, pkt_size);
 			skb->protocol =3D eth_type_trans(skb, dev);
=20
 			sis190_rx_skb(skb);
--=20
1.7.5.4

