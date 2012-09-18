From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 1/5] ucc_geth: Reduce IRQ off in xmit path
Date: Tue, 18 Sep 2012 18:56:21 +0200
Message-ID: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:51997 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386Ab2IRQ4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2012 12:56:36 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id 0C5512581E1
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 18:56:34 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ucc_geth_start_xmit wraps IRQ off for the
whole body just to be safe.
Reduce the IRQ off period to a minimum.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ethernet/freescale/ucc_geth.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 9ac14f8..e609c93 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3181,8 +3181,6 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	ugeth_vdbg("%s: IN", __func__);
 
-	spin_lock_irqsave(&ugeth->lock, flags);
-
 	dev->stats.tx_bytes += skb->len;
 
 	/* Start from the next BD that should be filled */
@@ -3196,6 +3194,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	    (ugeth->skb_curtx[txQ] +
 	     1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
 
+	spin_lock_irqsave(&ugeth->lock, flags);
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
