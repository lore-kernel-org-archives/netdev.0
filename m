From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 10/21] net: sgiseeq: use common rx_copybreak handling [strict
 refill!]
Date: Sat,  9 Jul 2011 19:17:52 +0200 (CEST)
Message-ID: <8a0643e9affb5355fff01f3c45d44e6da8d34e76.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51951 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754211Ab1GIRRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:55 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does this card really loop back transmitted packets? The code can be
cleaned up further if it isn't.

Because buffer status is written in it, there is additional pair of
DMA sync to cpu/device before the common path. If it turns out to be
big performance hit this patch should be reverted.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/sgiseeq.c |   66 ++++++++++++++++++-----------------------=
-------
 1 files changed, 25 insertions(+), 41 deletions(-)

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 52fb7ed..a4c6d93 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -340,9 +340,8 @@ static inline void sgiseeq_rx(struct net_device *de=
v, struct sgiseeq_private *sp
 {
 	struct sgiseeq_rx_desc *rd;
 	struct sk_buff *skb =3D NULL;
-	struct sk_buff *newskb;
 	unsigned char pkt_status;
-	int len =3D 0;
+	int packet_ok, len =3D 0;
 	unsigned int orig_end =3D PREV_RX(sp->rx_new);
=20
 	/* Service every received packet. */
@@ -350,53 +349,38 @@ static inline void sgiseeq_rx(struct net_device *=
dev, struct sgiseeq_private *sp
 	dma_sync_desc_cpu(dev, rd);
 	while (!(rd->rdma.cntinfo & HPCDMA_OWN)) {
 		len =3D PKT_BUF_SZ - (rd->rdma.cntinfo & HPCDMA_BCNT) - 3;
-		dma_unmap_single(dev->dev.parent, rd->rdma.pbuf,
+		dma_sync_single_for_cpu(dev->dev.parent, rd->rdma.pbuf,
 				 PKT_BUF_SZ, DMA_FROM_DEVICE);
 		pkt_status =3D rd->skb->data[len];
 		if (pkt_status & SEEQ_RSTAT_FIG) {
 			/* Packet is OK. */
 			/* We don't want to receive our own packets */
-			if (memcmp(rd->skb->data + 6, dev->dev_addr, ETH_ALEN)) {
-				if (len > rx_copybreak) {
-					skb =3D rd->skb;
-					newskb =3D netdev_alloc_skb(dev, PKT_BUF_SZ);
-					if (!newskb) {
-						newskb =3D skb;
-						skb =3D NULL;
-						goto memory_squeeze;
-					}
-					skb_reserve(newskb, 2);
-				} else {
-					skb =3D netdev_alloc_skb_ip_align(dev, len);
-					if (skb)
-						skb_copy_to_linear_data(skb, rd->skb->data, len);
-
-					newskb =3D rd->skb;
-				}
-memory_squeeze:
-				if (skb) {
-					skb_put(skb, len);
-					skb->protocol =3D eth_type_trans(skb, dev);
-					netif_rx(skb);
-					dev->stats.rx_packets++;
-					dev->stats.rx_bytes +=3D len;
-				} else {
-					printk(KERN_NOTICE "%s: Memory squeeze, deferring packet.\n",
-						dev->name);
-					dev->stats.rx_dropped++;
-				}
-			} else {
-				/* Silently drop my own packets */
-				newskb =3D rd->skb;
-			}
+			packet_ok =3D memcmp(rd->skb->data + 6, dev->dev_addr, ETH_ALEN);
 		} else {
 			record_rx_errors(dev, pkt_status);
-			newskb =3D rd->skb;
+			packet_ok =3D 0;
+		}
+		dma_sync_single_for_device(dev->dev.parent, rd->rdma.pbuf,
+			PKT_BUF_SZ, DMA_FROM_DEVICE);
+
+		if (packet_ok) {
+			dma_addr_t dma =3D rd->rdma.pbuf;
+			skb =3D dev_skb_finish_rx_dma_refill(&rd->skb,
+				len, rx_copybreak, 0, 2,
+				dev->dev.parent, &dma, PKT_BUF_SZ);
+			rd->rdma.pbuf =3D dma;
+
+			if (likely(skb)) {
+				skb->protocol =3D eth_type_trans(skb, dev);
+				netif_rx(skb);
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes +=3D len;
+			} else {
+				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n",
+					dev->name);
+				dev->stats.rx_dropped++;
+			}
 		}
-		rd->skb =3D newskb;
-		rd->rdma.pbuf =3D dma_map_single(dev->dev.parent,
-					       newskb->data - 2,
-					       PKT_BUF_SZ, DMA_FROM_DEVICE);
=20
 		/* Return the entry to the ring pool. */
 		rd->rdma.cntinfo =3D RCNTINFO_INIT;
--=20
1.7.5.4

