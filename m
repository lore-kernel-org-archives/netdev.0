From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 12/21] net: starfire: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:52 +0200 (CEST)
Message-ID: <1a8ac3bda6c5ff6442758db58c151e681ce31395.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ion Badulescu <ionut@badula.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51947 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754236Ab1GIRRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:55 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/starfire.c |   27 ++++++++-------------------
 1 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 860a508..1664f25 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1475,26 +1475,15 @@ static int __netdev_rx(struct net_device *dev, =
int *quota)
=20
 		if (debug > 4)
 			printk(KERN_DEBUG "  netdev_rx() normal Rx pkt length %d, quota %d.=
\n", pkt_len, *quota);
-		/* Check if the packet is long enough to accept without copying
-		   to a minimally-sized skbuff. */
-		if (pkt_len < rx_copybreak &&
-		    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-			skb_reserve(skb, 2);	/* 16 byte align the IP header */
-			pci_dma_sync_single_for_cpu(np->pci_dev,
-						    np->rx_info[entry].mapping,
-						    pkt_len, PCI_DMA_FROMDEVICE);
-			skb_copy_to_linear_data(skb, np->rx_info[entry].skb->data, pkt_len)=
;
-			pci_dma_sync_single_for_device(np->pci_dev,
-						       np->rx_info[entry].mapping,
-						       pkt_len, PCI_DMA_FROMDEVICE);
-			skb_put(skb, pkt_len);
-		} else {
-			pci_unmap_single(np->pci_dev, np->rx_info[entry].mapping, np->rx_bu=
f_sz, PCI_DMA_FROMDEVICE);
-			skb =3D np->rx_info[entry].skb;
-			skb_put(skb, pkt_len);
-			np->rx_info[entry].skb =3D NULL;
+
+		skb =3D dev_skb_finish_rx_dma(&np->rx_info[entry].skb,
+			pkt_len, rx_copybreak,
+			&np->pci_dev->dev, np->rx_info[entry].mapping,
+			np->rx_buf_sz);
+
+		if (!np->rx_info[entry].skb)	/* not copied */
 			np->rx_info[entry].mapping =3D 0;
-		}
+
 #ifndef final_version			/* Remove after testing. */
 		/* You will want this info for the initial debug. */
 		if (debug > 5) {
--=20
1.7.5.4

