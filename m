From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH v3] ucc_geth: Lockless xmit
Date: Fri, 21 Sep 2012 11:11:15 +0200
Message-ID: <1348218675-3804-1-git-send-email-Joakim.Tjernlund@transmode.se>
References: <1348129021-28333-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:62901 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932129Ab2IUJL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 05:11:26 -0400
In-Reply-To: <1348129021-28333-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ucc_geth_start_xmit wraps IRQ off for the
whole body just to be safe. By rearranging the code a bit
one can avoid the lock completely.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---

 v2: Move assignment of ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]]
     inside IRQ off section to prevent racing against
     ucc_geth_tx(). Spotted by Francois Romieu <romieu@fr.zoreil.com>

 v3: Lockless xmit
     Here is my attemept to do lockless xmit. Thanks to
     Francois Romieu <romieu@fr.zoreil.com> for the idea.

 drivers/net/ethernet/freescale/ucc_geth.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 9ac14f8..040aa70 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3177,19 +3177,20 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u8 __iomem *bd;			/* BD pointer */
 	u32 bd_status;
 	u8 txQ = 0;
-	unsigned long flags;
 
 	ugeth_vdbg("%s: IN", __func__);
 
-	spin_lock_irqsave(&ugeth->lock, flags);
-
 	dev->stats.tx_bytes += skb->len;
 
+	/* We are running in BH disabled context with netif_tx_lock
+	 * and TX reclaim runs via tp->napi.poll inside of a software
+	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
+	 * no IRQ context deadlocks to worry about either.  Rejoice!
+	 */
+
 	/* Start from the next BD that should be filled */
 	bd = ugeth->txBd[txQ];
 	bd_status = in_be32((u32 __iomem *)bd);
-	/* Save the skb pointer so we can free it later */
-	ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;
 
 	/* Update the current skb pointer (wrapping if this was the last) */
 	ugeth->skb_curtx[txQ] =
@@ -3207,6 +3208,8 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* set bd status and length */
 	out_be32((u32 __iomem *)bd, bd_status);
+	/* Save the skb pointer so we can free it later */
+	ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;
 
 	/* Move to next BD in the ring */
 	if (!(bd_status & T_W))
@@ -3238,8 +3241,6 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	uccf = ugeth->uccf;
 	out_be16(uccf->p_utodr, UCC_FAST_TOD);
 #endif
-	spin_unlock_irqrestore(&ugeth->lock, flags);
-
 	return NETDEV_TX_OK;
 }
 
@@ -3387,10 +3388,8 @@ static int ucc_geth_poll(struct napi_struct *napi, int budget)
 	ug_info = ugeth->ug_info;
 
 	/* Tx event processing */
-	spin_lock(&ugeth->lock);
 	for (i = 0; i < ug_info->numQueuesTx; i++)
 		ucc_geth_tx(ugeth->ndev, i);
-	spin_unlock(&ugeth->lock);
 
 	howmany = 0;
 	for (i = 0; i < ug_info->numQueuesRx; i++)
-- 
1.7.8.6
