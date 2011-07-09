From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 17/21] net: tulip/winbond-840: use common rx_copybreak
 handling
Date: Sat,  9 Jul 2011 19:17:53 +0200 (CEST)
Message-ID: <15d43c918eff036b89f087275f9444dc7a0c67e1.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51965 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754290Ab1GIRR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:56 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/tulip/winbond-840.c |   25 +++++--------------------
 1 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbon=
d-840.c
index 862eadf..c023512 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1228,26 +1228,11 @@ static int netdev_rx(struct net_device *dev)
 				netdev_dbg(dev, "  netdev_rx() normal Rx pkt length %d status %x\n=
",
 					   pkt_len, status);
 #endif
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single_for_cpu(np->pci_dev,np->rx_addr[entry],
-							    np->rx_skbuff[entry]->len,
-							    PCI_DMA_FROMDEVICE);
-				skb_copy_to_linear_data(skb, np->rx_skbuff[entry]->data, pkt_len);
-				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(np->pci_dev,np->rx_addr[entry],
-							       np->rx_skbuff[entry]->len,
-							       PCI_DMA_FROMDEVICE);
-			} else {
-				pci_unmap_single(np->pci_dev,np->rx_addr[entry],
-							np->rx_skbuff[entry]->len,
-							PCI_DMA_FROMDEVICE);
-				skb_put(skb =3D np->rx_skbuff[entry], pkt_len);
-				np->rx_skbuff[entry] =3D NULL;
-			}
+			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&np->pci_dev->dev, np->rx_addr[entry],
+				np->rx_buf_sz);
+
 #ifndef final_version				/* Remove after testing. */
 			/* You will want this info for the initial debug. */
 			if (debug > 5)
--=20
1.7.5.4

