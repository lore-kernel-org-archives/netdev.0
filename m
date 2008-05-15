From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] ucc_geth: Fix arguments to dma map/unmap functions
Date: Thu, 15 May 2008 17:00:21 -0500
Message-ID: <1210888821-15471-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:43288 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349AbYEOWA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 18:00:26 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m4FM0Nc5018330
	for <netdev@vger.kernel.org>; Thu, 15 May 2008 15:00:24 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id m4FM0Mv0024437
	for <netdev@vger.kernel.org>; Thu, 15 May 2008 17:00:22 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were passing NULL as the device.  When we actually start supporting
more interesting memory configurations, this will break things, so
we proactively are fixing the bug.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/ucc_geth.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index b3bbb2d..28e6450 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -237,7 +237,7 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
 	skb->dev = ugeth->dev;
 
 	out_be32(&((struct qe_bd __iomem *)bd)->buf,
-		      dma_map_single(NULL,
+		      dma_map_single(&ugeth->dev->dev,
 				     skb->data,
 				     ugeth->ug_info->uf_info.max_rx_buf_length +
 				     UCC_GETH_RX_DATA_BUF_ALIGNMENT,
@@ -2158,7 +2158,7 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 			continue;
 		for (j = 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
 			if (ugeth->tx_skbuff[i][j]) {
-				dma_unmap_single(NULL,
+				dma_unmap_single(&ugeth->dev->dev,
 						 in_be32(&((struct qe_bd __iomem *)bd)->buf),
 						 (in_be32((u32 __iomem *)bd) &
 						  BD_LENGTH_MASK),
@@ -2186,7 +2186,7 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 			bd = ugeth->p_rx_bd_ring[i];
 			for (j = 0; j < ugeth->ug_info->bdRingLenRx[i]; j++) {
 				if (ugeth->rx_skbuff[i][j]) {
-					dma_unmap_single(NULL,
+					dma_unmap_single(&ugeth->dev->dev,
 						in_be32(&((struct qe_bd __iomem *)bd)->buf),
 						ugeth->ug_info->
 						uf_info.max_rx_buf_length +
@@ -3406,7 +3406,8 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* set up the buffer descriptor */
 	out_be32(&((struct qe_bd __iomem *)bd)->buf,
-		      dma_map_single(NULL, skb->data, skb->len, DMA_TO_DEVICE));
+		      dma_map_single(&ugeth->dev->dev, skb->data,
+			      skb->len, DMA_TO_DEVICE));
 
 	/* printk(KERN_DEBUG"skb->data is 0x%x\n",skb->data); */
 
-- 
1.5.4.GIT

