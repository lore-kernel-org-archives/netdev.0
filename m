From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH v2] ucc_geth: Reduce IRQ off in xmit path
Date: Thu, 20 Sep 2012 10:17:01 +0200
Message-ID: <1348129021-28333-1-git-send-email-Joakim.Tjernlund@transmode.se>
References: <20120919223416.GA16087@electric-eye.fr.zoreil.com>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:53720 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab2ITIRL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 04:17:11 -0400
In-Reply-To: <20120919223416.GA16087@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ucc_geth_start_xmit wraps IRQ off for the
whole body just to be safe.
Reduce the IRQ off period to a minimum.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---

 v2: Move assignment of ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]]
     inside IRQ off section to prevent racing against
     ucc_geth_tx(). Spotted by Francois Romieu <romieu@fr.zoreil.com>

 drivers/net/ethernet/freescale/ucc_geth.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 9ac14f8..0100bca 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3181,21 +3181,20 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	ugeth_vdbg("%s: IN", __func__);
 
-	spin_lock_irqsave(&ugeth->lock, flags);
-
 	dev->stats.tx_bytes += skb->len;
 
 	/* Start from the next BD that should be filled */
 	bd = ugeth->txBd[txQ];
 	bd_status = in_be32((u32 __iomem *)bd);
-	/* Save the skb pointer so we can free it later */
-	ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;
 
 	/* Update the current skb pointer (wrapping if this was the last) */
 	ugeth->skb_curtx[txQ] =
 	    (ugeth->skb_curtx[txQ] +
 	     1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
 
+	spin_lock_irqsave(&ugeth->lock, flags);
+	/* Save the skb pointer so we can free it later */
+	ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;
 	/* set up the buffer descriptor */
 	out_be32(&((struct qe_bd __iomem *)bd)->buf,
 		      dma_map_single(ugeth->dev, skb->data,
@@ -3207,6 +3206,8 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* set bd status and length */
 	out_be32((u32 __iomem *)bd, bd_status);
+	spin_unlock_irqrestore(&ugeth->lock, flags);
+
 
 	/* Move to next BD in the ring */
 	if (!(bd_status & T_W))
@@ -3238,8 +3239,6 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	uccf = ugeth->uccf;
 	out_be16(uccf->p_utodr, UCC_FAST_TOD);
 #endif
-	spin_unlock_irqrestore(&ugeth->lock, flags);
-
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.8.6
