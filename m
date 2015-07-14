From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] ravb: do not invalidate cache for RX buffer twice
Date: Wed, 15 Jul 2015 00:56:52 +0300
Message-ID: <4759713.2ulGRKsd9L@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33060 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbbGNV44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 17:56:56 -0400
Received: by lbbyj8 with SMTP id yj8so14109926lbb.0
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 14:56:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First, dma_sync_single_for_cpu() shouldn't have been called in the first place
(it's a streaming DMA API). dma_unmap_single() should have been called instead.
Second, dma_unmap_single() call after handing the buffer to napi_gro_receive()
makes little sense.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave Miller's 'net.git' repo.

Don't know why I missed this DMA API misuse while working on the driver. :-<

 drivers/net/ethernet/renesas/ravb_main.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

Index: net/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net/drivers/net/ethernet/renesas/ravb_main.c
@@ -543,10 +543,9 @@ static bool ravb_rx(struct net_device *n
 
 			skb = priv->rx_skb[q][entry];
 			priv->rx_skb[q][entry] = NULL;
-			dma_sync_single_for_cpu(&ndev->dev,
-						le32_to_cpu(desc->dptr),
-						ALIGN(PKT_BUF_SZ, 16),
-						DMA_FROM_DEVICE);
+			dma_unmap_single(&ndev->dev, le32_to_cpu(desc->dptr),
+					 ALIGN(PKT_BUF_SZ, 16),
+					 DMA_FROM_DEVICE);
 			get_ts &= (q == RAVB_NC) ?
 					RAVB_RXTSTAMP_TYPE_V2_L2_EVENT :
 					~RAVB_RXTSTAMP_TYPE_V2_L2_EVENT;
@@ -584,9 +583,6 @@ static bool ravb_rx(struct net_device *n
 			if (!skb)
 				break;	/* Better luck next round. */
 			ravb_set_buffer_align(skb);
-			dma_unmap_single(&ndev->dev, le32_to_cpu(desc->dptr),
-					 ALIGN(PKT_BUF_SZ, 16),
-					 DMA_FROM_DEVICE);
 			dma_addr = dma_map_single(&ndev->dev, skb->data,
 						  le16_to_cpu(desc->ds_cc),
 						  DMA_FROM_DEVICE);
