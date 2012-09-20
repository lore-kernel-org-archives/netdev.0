From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH 1/5] ucc_geth: Reduce IRQ off in xmit path
Date: Thu, 20 Sep 2012 10:06:56 +0200
Message-ID: <OF540E33B1.6013BC69-ONC1257A7F.002C410C-C1257A7F.002C94CB@transmode.se>
References: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se> <20120919223416.GA16087@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:62182 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601Ab2ITIHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 04:07:00 -0400
In-Reply-To: <20120919223416.GA16087@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> wrote on 2012/09/20 00:34:16:
>
> Joakim Tjernlund <Joakim.Tjernlund@transmode.se> :
> > Currently ucc_geth_start_xmit wraps IRQ off for the
> > whole body just to be safe.
> > Reduce the IRQ off period to a minimum.
>
> It opens a window in ucc_geth_start_xmit where the skb slot in
> ugeth->tx_skbuff[txQ] is set and T_RA has not been written into
> the descriptor status. Consider a racing poll : the !skb test in
> ucc_geth_tx may not work as expected.

Right, good catch!

Surprisingly the driver never showed any malfunction even though I hit
it pretty hard.

I will send a V2 of this patch where I move the assignment inside the IRQ
off part:
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3200,8 +3200,6 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
        /* Start from the next BD that should be filled */
        bd = ugeth->txBd[txQ];
        bd_status = in_be32((u32 __iomem *)bd);
-       /* Save the skb pointer so we can free it later */
-       ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;

        /* Update the current skb pointer (wrapping if this was the last) */
        ugeth->skb_curtx[txQ] =
@@ -3209,6 +3207,8 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
             1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);

        spin_lock_irqsave(&ugeth->lock, flags);
+       /* Save the skb pointer so we can free it later */
+       ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;
        /* set up the buffer descriptor */
        out_be32(&((struct qe_bd __iomem *)bd)->buf,
                      dma_map_single(ugeth->dev, skb->data,

 Jocke
