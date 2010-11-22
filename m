From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH] ks8842: Fix TX cache flush issue
Date: Mon, 22 Nov 2010 13:50:57 +0100
Message-ID: <1290430257.13971.7.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ferringb@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw21.han.skanova.net ([81.236.55.21]:41466 "EHLO
	smtp-gw21.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755732Ab0KVMu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 07:50:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a cache sync issue found in MeeGo 1.1.

It was found that bytes after the first 64 of the TX buffer was not
flushed from the cache correctly.

The patch switches out kmalloc/dma_map_single/dma_sync_single_for_devic=
e
to dma_alloc_coherent.

Signed-off-by: Richard R=C3=B6jfors <richard.rojfors@pelagicore.com>
---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 928b2b8..55a11ba 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -449,10 +449,6 @@ static int ks8842_tx_frame_dma(struct sk_buff *skb=
, struct net_device *netdev)
 	*buf++ =3D (skb->len >> 8) & 0xff;
 	skb_copy_from_linear_data(skb, buf, skb->len);
=20
-	dma_sync_single_range_for_device(adapter->dev,
-		sg_dma_address(&ctl->sg), 0, sg_dma_len(&ctl->sg),
-		DMA_TO_DEVICE);
-
 	/* make sure the length is a multiple of 4 */
 	if (sg_dma_len(&ctl->sg) % 4)
 		sg_dma_len(&ctl->sg) +=3D 4 - sg_dma_len(&ctl->sg) % 4;
@@ -908,12 +904,10 @@ static void ks8842_dealloc_dma_bufs(struct ks8842=
_adapter *adapter)
=20
 	tasklet_kill(&rx_ctl->tasklet);
=20
-	if (sg_dma_address(&tx_ctl->sg))
-		dma_unmap_single(adapter->dev, sg_dma_address(&tx_ctl->sg),
-			DMA_BUFFER_SIZE, DMA_TO_DEVICE);
+	if (tx_ctl->buf)
+		dma_free_coherent(adapter->dev, DMA_BUFFER_SIZE,
+			tx_ctl->buf, sg_dma_address(&tx_ctl->sg));
 	sg_dma_address(&tx_ctl->sg) =3D 0;
-
-	kfree(tx_ctl->buf);
 	tx_ctl->buf =3D NULL;
 }
=20
@@ -945,21 +939,13 @@ static int ks8842_alloc_dma_bufs(struct net_devic=
e *netdev)
 	}
=20
 	/* allocate DMA buffer */
-	tx_ctl->buf =3D kmalloc(DMA_BUFFER_SIZE, GFP_KERNEL);
+	tx_ctl->buf =3D dma_alloc_coherent(adapter->dev, DMA_BUFFER_SIZE,
+		&sg_dma_address(&tx_ctl->sg), GFP_KERNEL);
 	if (!tx_ctl->buf) {
 		err =3D -ENOMEM;
 		goto err;
 	}
=20
-	sg_dma_address(&tx_ctl->sg) =3D dma_map_single(adapter->dev,
-		tx_ctl->buf, DMA_BUFFER_SIZE, DMA_TO_DEVICE);
-	err =3D dma_mapping_error(adapter->dev,
-		sg_dma_address(&tx_ctl->sg));
-	if (err) {
-		sg_dma_address(&tx_ctl->sg) =3D 0;
-		goto err;
-	}
-
 	rx_ctl->chan =3D dma_request_channel(mask, ks8842_dma_filter_fn,
 					   (void *)(long)rx_ctl->channel);
 	if (!rx_ctl->chan) {

