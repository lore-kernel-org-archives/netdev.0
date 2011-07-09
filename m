From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 20/21] net: via-velocity: use common rx_copybreak handling
Date: Sat,  9 Jul 2011 19:17:53 +0200 (CEST)
Message-ID: <fde4e58b4575124aaa9878ea2329dcb3445c50f0.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51962 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754273Ab1GIRR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:56 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also fixes a bug, where FCS was not stripped from copied packets.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/via-velocity.c |   59 +++++++-----------------------------=
-------
 1 files changed, 10 insertions(+), 49 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index f929242..cdc51de 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1987,37 +1987,6 @@ static inline void velocity_rx_csum(struct rx_de=
sc *rd, struct sk_buff *skb)
 }
=20
 /**
- *	velocity_rx_copy	-	in place Rx copy for small packets
- *	@rx_skb: network layer packet buffer candidate
- *	@pkt_size: received data size
- *	@rd: receive packet descriptor
- *	@dev: network device
- *
- *	Replace the current skb that is scheduled for Rx processing by a
- *	shorter, immediately allocated skb, if the received packet is small
- *	enough. This function returns a negative value if the received
- *	packet is too big or if memory is exhausted.
- */
-static int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size,
-			    struct velocity_info *vptr)
-{
-	int ret =3D -1;
-	if (pkt_size < rx_copybreak) {
-		struct sk_buff *new_skb;
-
-		new_skb =3D netdev_alloc_skb_ip_align(vptr->dev, pkt_size);
-		if (new_skb) {
-			new_skb->ip_summed =3D rx_skb[0]->ip_summed;
-			skb_copy_from_linear_data(*rx_skb, new_skb->data, pkt_size);
-			*rx_skb =3D new_skb;
-			ret =3D 0;
-		}
-
-	}
-	return ret;
-}
-
-/**
  *	velocity_iph_realign	-	IP header alignment
  *	@vptr: velocity we are handling
  *	@skb: network layer packet buffer
@@ -2027,10 +1996,10 @@ static int velocity_rx_copy(struct sk_buff **rx=
_skb, int pkt_size,
  *	configured by the user.
  */
 static inline void velocity_iph_realign(struct velocity_info *vptr,
-					struct sk_buff *skb, int pkt_size)
+					struct sk_buff *skb)
 {
 	if (vptr->flags & VELOCITY_FLAGS_IP_ALIGN) {
-		memmove(skb->data + 2, skb->data, pkt_size);
+		memmove(skb->data + 2, skb->data, skb->len);
 		skb_reserve(skb, 2);
 	}
 }
@@ -2064,9 +2033,6 @@ static int velocity_receive_frame(struct velocity=
_info *vptr, int idx)
=20
 	skb =3D rd_info->skb;
=20
-	pci_dma_sync_single_for_cpu(vptr->pdev, rd_info->skb_dma,
-				    vptr->rx.buf_sz, PCI_DMA_FROMDEVICE);
-
 	/*
 	 *	Drop frame not meeting IEEE 802.3
 	 */
@@ -2078,30 +2044,25 @@ static int velocity_receive_frame(struct veloci=
ty_info *vptr, int idx)
 		}
 	}
=20
-	pci_action =3D pci_dma_sync_single_for_device;
+	skb =3D dev_skb_finish_rx_dma(&rd_info->skb,
+		pkt_len - ETH_FCS_LEN, rx_copybreak,
+		&vptr->pdev->dev, rd_info->skb_dma, vptr->rx.buf_sz);
+	if (!skb)
+		/* not copied */
+		velocity_iph_realign(vptr, skb);
=20
 	velocity_rx_csum(rd, skb);
=20
-	if (velocity_rx_copy(&skb, pkt_len, vptr) < 0) {
-		velocity_iph_realign(vptr, skb, pkt_len);
-		pci_action =3D pci_unmap_single;
-		rd_info->skb =3D NULL;
-	}
-
-	pci_action(vptr->pdev, rd_info->skb_dma, vptr->rx.buf_sz,
-		   PCI_DMA_FROMDEVICE);
-
-	skb_put(skb, pkt_len - 4);
 	skb->protocol =3D eth_type_trans(skb, vptr->dev);
=20
+	stats->rx_bytes +=3D skb->len;
+
 	if (vptr->vlgrp && (rd->rdesc0.RSR & RSR_DETAG)) {
 		vlan_hwaccel_rx(skb, vptr->vlgrp,
 				swab16(le16_to_cpu(rd->rdesc1.PQTAG)));
 	} else
 		netif_rx(skb);
=20
-	stats->rx_bytes +=3D pkt_len;
-
 	return 0;
 }
=20
--=20
1.7.5.4

