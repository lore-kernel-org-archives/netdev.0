From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] ucc_geth: Rework the TX logic.
Date: Thu, 26 Mar 2009 18:44:05 +0100
Message-ID: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: avorontsov@ru.mvista.com, leoli@freescale.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:59728 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752906AbZCZRoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 13:44:10 -0400
Received: from tmnt04.transmode.se (tmnt04.transmode.se [192.168.46.15])
	by gw1.transmode.se (Postfix) with ESMTP id B0DE57ECFA
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 18:44:07 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The line:
 if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
       break;
in ucc_geth_tx() didn not make sense to me. Rework & cleanup
this logic to something understandable.
---

Reworked the patch according to Antons comments.

 drivers/net/ucc_geth.c |   66 +++++++++++++++++++++++++++--------------------
 1 files changed, 38 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 7fc91aa..465de3a 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -161,6 +161,17 @@ static struct ucc_geth_info ugeth_primary_info = {
 
 static struct ucc_geth_info ugeth_info[8];
 
+
+static inline u32 __iomem *bd2buf(u8 __iomem *bd)
+{
+	return (u32 __iomem *)(bd+4);
+}
+
+static inline u32 __iomem *bd2status(u8 __iomem *bd)
+{
+	return (u32 __iomem *)bd;
+}
+
 #ifdef DEBUG
 static void mem_disp(u8 *addr, int size)
 {
@@ -3048,6 +3059,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u8 __iomem *bd;			/* BD pointer */
 	u32 bd_status;
 	u8 txQ = 0;
+	int tx_ind;
 
 	ugeth_vdbg("%s: IN", __func__);
 
@@ -3057,21 +3069,19 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Start from the next BD that should be filled */
 	bd = ugeth->txBd[txQ];
-	bd_status = in_be32((u32 __iomem *)bd);
+	bd_status = in_be32(bd2status(bd));
 	/* Save the skb pointer so we can free it later */
-	ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;
+	tx_ind = ugeth->skb_curtx[txQ];
+	ugeth->tx_skbuff[txQ][tx_ind] = skb;
 
 	/* Update the current skb pointer (wrapping if this was the last) */
-	ugeth->skb_curtx[txQ] =
-	    (ugeth->skb_curtx[txQ] +
-	     1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
+	tx_ind = (tx_ind + 1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
+	ugeth->skb_curtx[txQ] = tx_ind;
 
 	/* set up the buffer descriptor */
-	out_be32(&((struct qe_bd __iomem *)bd)->buf,
-		      dma_map_single(&ugeth->dev->dev, skb->data,
-			      skb->len, DMA_TO_DEVICE));
-
-	/* printk(KERN_DEBUG"skb->data is 0x%x\n",skb->data); */
+	out_be32(bd2buf(bd),
+		 dma_map_single(&ugeth->dev->dev, skb->data,
+				skb->len, DMA_TO_DEVICE));
 
 	bd_status = (bd_status & T_W) | T_R | T_I | T_L | skb->len;
 
@@ -3088,9 +3098,9 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* If the next BD still needs to be cleaned up, then the bds
 	   are full.  We need to tell the kernel to stop sending us stuff. */
-	if (bd == ugeth->confBd[txQ]) {
-		if (!netif_queue_stopped(dev))
-			netif_stop_queue(dev);
+
+	if (!in_be32(bd2buf(bd))) {
+		netif_stop_queue(dev);
 	}
 
 	ugeth->txBd[txQ] = bd;
@@ -3198,41 +3208,41 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 	u8 __iomem *bd;		/* BD pointer */
 	u32 bd_status;
+	int tx_ind, num_freed;
 
 	bd = ugeth->confBd[txQ];
-	bd_status = in_be32((u32 __iomem *)bd);
-
+	bd_status = in_be32(bd2status(bd));
+	tx_ind = ugeth->skb_dirtytx[txQ];
+	num_freed = 0;
 	/* Normal processing. */
 	while ((bd_status & T_R) == 0) {
 		/* BD contains already transmitted buffer.   */
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
 
-		if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
-			break;
+		if (bd == ugeth->txBd[txQ])
+			break; /* Queue is empty */
 
 		dev->stats.tx_packets++;
 
 		/* Free the sk buffer associated with this TxBD */
-		dev_kfree_skb(ugeth->
-				  tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]]);
-		ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]] = NULL;
-		ugeth->skb_dirtytx[txQ] =
-		    (ugeth->skb_dirtytx[txQ] +
-		     1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
-
-		/* We freed a buffer, so now we can restart transmission */
-		if (netif_queue_stopped(dev))
-			netif_wake_queue(dev);
+		dev_kfree_skb(ugeth->tx_skbuff[txQ][tx_ind]);
+		ugeth->tx_skbuff[txQ][tx_ind] = NULL;
+		out_be32(bd2buf(bd), 0); /* Mark it free */
+		num_freed++;
+		tx_ind = (tx_ind + 1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
 
 		/* Advance the confirmation BD pointer */
 		if (!(bd_status & T_W))
 			bd += sizeof(struct qe_bd);
 		else
 			bd = ugeth->p_tx_bd_ring[txQ];
-		bd_status = in_be32((u32 __iomem *)bd);
+		bd_status = in_be32(bd2status(bd));
 	}
 	ugeth->confBd[txQ] = bd;
+	ugeth->skb_dirtytx[txQ] = tx_ind;
+	if (num_freed)
+		netif_wake_queue(dev); /* We freed some buffers, so restart transmission */
 	return 0;
 }
 
-- 
1.6.1.3

