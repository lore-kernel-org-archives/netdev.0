From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 09/21] net: pcnet32: use common rx_copybreak handling [strict
 refill!]
Date: Sat,  9 Jul 2011 19:17:52 +0200 (CEST)
Message-ID: <0f270b4469acf1db6e18025c7097f6e4e338ad5d.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Don Fry <pcnet32@frontier.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51952 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754194Ab1GIRRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:55 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also use netdev_alloc_skb_ip_align() to make code correct (skb->dev
is needed in new common path) and easier to follow.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/pcnet32.c |   52 ++++++++---------------------------------=
-------
 1 files changed, 9 insertions(+), 43 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 8b3090d..baae404 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -588,7 +588,7 @@ static void pcnet32_realloc_rx_ring(struct net_devi=
ce *dev,
 	/* now allocate any new buffers needed */
 	for (; new < size; new++) {
 		struct sk_buff *rx_skbuff;
-		new_skb_list[new] =3D dev_alloc_skb(PKT_BUF_SKB);
+		new_skb_list[new] =3D netdev_alloc_skb_ip_align(dev, PKT_BUF_SKB);
 		rx_skbuff =3D new_skb_list[new];
 		if (!rx_skbuff) {
 			/* keep the original lists and buffers */
@@ -596,7 +596,6 @@ static void pcnet32_realloc_rx_ring(struct net_devi=
ce *dev,
 				  __func__);
 			goto free_all_new;
 		}
-		skb_reserve(rx_skbuff, NET_IP_ALIGN);
=20
 		new_dma_addr_list[new] =3D
 			    pci_map_single(lp->pci_dev, rx_skbuff->data,
@@ -1147,51 +1146,18 @@ static void pcnet32_rx_entry(struct net_device =
*dev,
 		return;
 	}
=20
-	if (pkt_len > rx_copybreak) {
-		struct sk_buff *newskb;
-
-		newskb =3D dev_alloc_skb(PKT_BUF_SKB);
-		if (newskb) {
-			skb_reserve(newskb, NET_IP_ALIGN);
-			skb =3D lp->rx_skbuff[entry];
-			pci_unmap_single(lp->pci_dev,
-					 lp->rx_dma_addr[entry],
-					 PKT_BUF_SIZE,
-					 PCI_DMA_FROMDEVICE);
-			skb_put(skb, pkt_len);
-			lp->rx_skbuff[entry] =3D newskb;
-			lp->rx_dma_addr[entry] =3D
-					    pci_map_single(lp->pci_dev,
-							   newskb->data,
-							   PKT_BUF_SIZE,
-							   PCI_DMA_FROMDEVICE);
-			rxp->base =3D cpu_to_le32(lp->rx_dma_addr[entry]);
-			rx_in_place =3D 1;
-		} else
-			skb =3D NULL;
-	} else
-		skb =3D dev_alloc_skb(pkt_len + NET_IP_ALIGN);
+	skb =3D dev_skb_finish_rx_dma_refill(&lp->rx_skbuff[entry],
+		pkt_len, rx_copybreak, NET_IP_ALIGN, 0,
+		&lp->pci_dev->dev, &lp->rx_dma_addr[entry],
+		PKT_BUF_SIZE);
+	rxp->base =3D cpu_to_le32(lp->rx_dma_addr[entry]);
=20
 	if (skb =3D=3D NULL) {
 		netif_err(lp, drv, dev, "Memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
-	if (!rx_in_place) {
-		skb_reserve(skb, NET_IP_ALIGN);
-		skb_put(skb, pkt_len);	/* Make room */
-		pci_dma_sync_single_for_cpu(lp->pci_dev,
-					    lp->rx_dma_addr[entry],
-					    pkt_len,
-					    PCI_DMA_FROMDEVICE);
-		skb_copy_to_linear_data(skb,
-				 (unsigned char *)(lp->rx_skbuff[entry]->data),
-				 pkt_len);
-		pci_dma_sync_single_for_device(lp->pci_dev,
-					       lp->rx_dma_addr[entry],
-					       pkt_len,
-					       PCI_DMA_FROMDEVICE);
-	}
+
 	dev->stats.rx_bytes +=3D skb->len;
 	skb->protocol =3D eth_type_trans(skb, dev);
 	netif_receive_skb(skb);
@@ -2271,7 +2237,8 @@ static int pcnet32_init_ring(struct net_device *d=
ev)
 	for (i =3D 0; i < lp->rx_ring_size; i++) {
 		struct sk_buff *rx_skbuff =3D lp->rx_skbuff[i];
 		if (rx_skbuff =3D=3D NULL) {
-			lp->rx_skbuff[i] =3D dev_alloc_skb(PKT_BUF_SKB);
+			lp->rx_skbuff[i] =3D
+				netdev_alloc_skb_ip_align(dev, PKT_BUF_SKB);
 			rx_skbuff =3D lp->rx_skbuff[i];
 			if (!rx_skbuff) {
 				/* there is not much we can do at this point */
@@ -2279,7 +2246,6 @@ static int pcnet32_init_ring(struct net_device *d=
ev)
 					  __func__);
 				return -1;
 			}
-			skb_reserve(rx_skbuff, NET_IP_ALIGN);
 		}
=20
 		rmb();
--=20
1.7.5.4

