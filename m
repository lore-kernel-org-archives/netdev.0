From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 13/21] net: sundance: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:52 +0200 (CEST)
Message-ID: <bd07a0287d0bff554c4eaf3f3d306471facac515.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51955 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754221Ab1GIRRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:55 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/sundance.c |   26 ++++++--------------------
 1 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 4793df8..0a16798 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1355,26 +1355,12 @@ static void rx_poll(unsigned long data)
 					   ", bogus_cnt %d.\n",
 					   pkt_len, boguscnt);
 #endif
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				dma_sync_single_for_cpu(&np->pci_dev->dev,
-						le32_to_cpu(desc->frag[0].addr),
-						np->rx_buf_sz, DMA_FROM_DEVICE);
-				skb_copy_to_linear_data(skb, np->rx_skbuff[entry]->data, pkt_len);
-				dma_sync_single_for_device(&np->pci_dev->dev,
-						le32_to_cpu(desc->frag[0].addr),
-						np->rx_buf_sz, DMA_FROM_DEVICE);
-				skb_put(skb, pkt_len);
-			} else {
-				dma_unmap_single(&np->pci_dev->dev,
-					le32_to_cpu(desc->frag[0].addr),
-					np->rx_buf_sz, DMA_FROM_DEVICE);
-				skb_put(skb =3D np->rx_skbuff[entry], pkt_len);
-				np->rx_skbuff[entry] =3D NULL;
-			}
+			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&np->pci_dev->dev,
+				le32_to_cpu(desc->frag[0].addr),
+				np->rx_buf_sz);
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			/* Note: checksum -> skb->ip_summed =3D CHECKSUM_UNNECESSARY; */
 			netif_rx(skb);
--=20
1.7.5.4

