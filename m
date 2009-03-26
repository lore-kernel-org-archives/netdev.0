From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 2/2] ucc_geth: Rework the TX logic.
Date: Thu, 26 Mar 2009 13:54:37 +0100
Message-ID: <1238072077-27044-2-git-send-email-Joakim.Tjernlund@transmode.se>
References: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: avorontsov@ru.mvista.com, leoli@freescale.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:51647 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752599AbZCZMyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 08:54:45 -0400
Received: from tmnt04.transmode.se (tmnt04.transmode.se [192.168.46.15])
	by gw1.transmode.se (Postfix) with ESMTP id 005C0C23D3
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 13:54:41 +0100 (CET)
In-Reply-To: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The line:
 if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
       break;
in ucc_geth_tx() didn not make sense to me. Rework & cleanup
this logic to something understandable.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ucc_geth.c |   40 ++++++++++++++++++++--------------------
 1 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 7fc91aa..b6ebefd 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3048,6 +3048,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u8 __iomem *bd;			/* BD pointer */
 	u32 bd_status;
 	u8 txQ = 0;
+	int txInd;
 
 	ugeth_vdbg("%s: IN", __func__);
 
@@ -3059,12 +3060,12 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	bd = ugeth->txBd[txQ];
 	bd_status = in_be32((u32 __iomem *)bd);
 	/* Save the skb pointer so we can free it later */
-	ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;
+	txInd = ugeth->skb_curtx[txQ];
+	ugeth->tx_skbuff[txQ][txInd] = skb;
 
 	/* Update the current skb pointer (wrapping if this was the last) */
-	ugeth->skb_curtx[txQ] =
-	    (ugeth->skb_curtx[txQ] +
-	     1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
+	txInd = (txInd + 1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
+	ugeth->skb_curtx[txQ] = txInd;
 
 	/* set up the buffer descriptor */
 	out_be32(&((struct qe_bd __iomem *)bd)->buf,
@@ -3088,9 +3089,8 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* If the next BD still needs to be cleaned up, then the bds
 	   are full.  We need to tell the kernel to stop sending us stuff. */
-	if (bd == ugeth->confBd[txQ]) {
-		if (!netif_queue_stopped(dev))
-			netif_stop_queue(dev);
+	if (!in_be32((u32 __iomem *)(bd+4))) {
+		netif_stop_queue(dev);
 	}
 
 	ugeth->txBd[txQ] = bd;
@@ -3198,32 +3198,29 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 	u8 __iomem *bd;		/* BD pointer */
 	u32 bd_status;
+	int txInd, num_freed;
 
 	bd = ugeth->confBd[txQ];
 	bd_status = in_be32((u32 __iomem *)bd);
-
+	txInd = ugeth->skb_dirtytx[txQ];
+	num_freed = 0;
 	/* Normal processing. */
 	while ((bd_status & T_R) == 0) {
 		/* BD contains already transmitted buffer.   */
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
 
-		if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
-			break;
+		if (!in_be32((u32 __iomem *)(bd+4)))
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
+		dev_kfree_skb(ugeth->tx_skbuff[txQ][txInd]);
+		ugeth->tx_skbuff[txQ][txInd] = NULL;
+		out_be32((u32 __iomem *)(bd+4), (int)NULL); /* Mark it free */
+		num_freed++;
+		txInd = (txInd + 1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
 
 		/* Advance the confirmation BD pointer */
 		if (!(bd_status & T_W))
@@ -3233,6 +3230,9 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 		bd_status = in_be32((u32 __iomem *)bd);
 	}
 	ugeth->confBd[txQ] = bd;
+	ugeth->skb_dirtytx[txQ] = txInd;
+	if (num_freed)
+		netif_wake_queue(dev); /* We freed some buffers, so restart transmission */
 	return 0;
 }
 
-- 
1.6.1.3

