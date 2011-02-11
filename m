From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 12/14] net/fec: provide device for dma functions and matching sizes for map and unmap
Date: Fri, 11 Feb 2011 11:32:20 +0100
Message-ID: <1297420342-17739-12-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45122 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755692Ab1BKKci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:38 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes warnings when CONFIG_DMA_API_DEBUG=3Dy:

	NULL NULL: DMA-API: device driver tries to free DMA memory it has not =
allocated [device address=3D0x000000004781a020] [size=3D64 bytes]
	net eth0: DMA-API: device driver frees DMA memory with different size =
[device address=3D0x000000004781a020] [map size=3D2048 bytes] [unmap si=
ze=3D64 bytes]

Moreover pass the platform device to dma_{,un}map_single which makes
more sense because the logical network device doesn't know anything
about dma.

Passing the platform device was a suggestion by Lothar Wa=C3=9Fmann.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 3f5dfe2..0c984d6 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -297,7 +297,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net=
_device *ndev)
 	/* Push the data cache so the CPM does not get stale memory
 	 * data.
 	 */
-	bdp->cbd_bufaddr =3D dma_map_single(&ndev->dev, bufaddr,
+	bdp->cbd_bufaddr =3D dma_map_single(&fep->pdev->dev, bufaddr,
 			FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
=20
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
@@ -497,7 +497,8 @@ fec_enet_tx(struct net_device *ndev)
 		if (bdp =3D=3D fep->cur_tx && fep->tx_full =3D=3D 0)
 			break;
=20
-		dma_unmap_single(&ndev->dev, bdp->cbd_bufaddr, FEC_ENET_TX_FRSIZE, D=
MA_TO_DEVICE);
+		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
+				FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
 		bdp->cbd_bufaddr =3D 0;
=20
 		skb =3D fep->tx_skbuff[fep->skb_dirty];
@@ -624,8 +625,8 @@ fec_enet_rx(struct net_device *ndev)
 		ndev->stats.rx_bytes +=3D pkt_len;
 		data =3D (__u8*)__va(bdp->cbd_bufaddr);
=20
-		dma_unmap_single(NULL, bdp->cbd_bufaddr, bdp->cbd_datlen,
-				DMA_FROM_DEVICE);
+		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
+				FEC_ENET_TX_FRSIZE, DMA_FROM_DEVICE);
=20
 		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
 			swap_buffer(data, pkt_len);
@@ -649,8 +650,8 @@ fec_enet_rx(struct net_device *ndev)
 			netif_rx(skb);
 		}
=20
-		bdp->cbd_bufaddr =3D dma_map_single(NULL, data, bdp->cbd_datlen,
-			DMA_FROM_DEVICE);
+		bdp->cbd_bufaddr =3D dma_map_single(&fep->pdev->dev, data,
+				FEC_ENET_TX_FRSIZE, DMA_FROM_DEVICE);
 rx_processing_done:
 		/* Clear the status flags for this buffer */
 		status &=3D ~BD_ENET_RX_STATS;
@@ -1075,7 +1076,7 @@ static void fec_enet_free_buffers(struct net_devi=
ce *ndev)
 		skb =3D fep->rx_skbuff[i];
=20
 		if (bdp->cbd_bufaddr)
-			dma_unmap_single(&ndev->dev, bdp->cbd_bufaddr,
+			dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
 					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
 		if (skb)
 			dev_kfree_skb(skb);
@@ -1103,7 +1104,7 @@ static int fec_enet_alloc_buffers(struct net_devi=
ce *ndev)
 		}
 		fep->rx_skbuff[i] =3D skb;
=20
-		bdp->cbd_bufaddr =3D dma_map_single(&ndev->dev, skb->data,
+		bdp->cbd_bufaddr =3D dma_map_single(&fep->pdev->dev, skb->data,
 				FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
 		bdp->cbd_sc =3D BD_ENET_RX_EMPTY;
 		bdp++;
--=20
1.7.2.3

