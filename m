From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: fix throughtput regression with TSO
 autosizing
Date: Fri, 27 Feb 2015 07:13:07 -0800
Message-ID: <1425049987.5130.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424948758-48244-1-git-send-email-jaedon.shin@gmail.com>
	 <20150226.113650.2092516427472228316.davem@davemloft.net>
	 <F8B81F3F-4E21-4468-8963-2A762AF9A7CC@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Jaedon Shin <jaedon.shin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33053 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbbB0PNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 10:13:10 -0500
Received: by pabli10 with SMTP id li10so7316116pab.0
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 07:13:09 -0800 (PST)
In-Reply-To: <F8B81F3F-4E21-4468-8963-2A762AF9A7CC@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 23:33 +0900, Jaedon Shin wrote:
> > On Feb 27, 2015, at 1:36 AM, David Miller <davem@davemloft.net> wrote:
> > 
> > From: Jaedon Shin <jaedon.shin@gmail.com>
> > Date: Thu, 26 Feb 2015 20:05:58 +0900
> > 
> >> This patch prevents the performance degradation of xmit after
> >> 605ad7f ("tcp: refine TSO autosizing").
> >> 
> >> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
> > 
> > I doubt this is the correct way to fix this.
> > 
> > Also, you need to describe in detail what the actual problem
> > is, how you evaluated the cause, and what made you think that
> > your choosen solution is the proper one.
> 
> The bcmgenet_tx_reclaim() of tx_ring[{0,1,2,3}] process only under 18 
> descriptors is too late reclaiming transmitted skb. Therefore, 
> performance degradation of xmit after 605ad7f ("tcp: refine TSO autosizing").

But the real cause is that this driver disables interrupts unless a
certain amount of TX descriptors are used.

This is wrong and should be fixed.

Only if this fix is proven to not be possible, skb_orphan() will be
needed.

Random guess, could you simply try this quick and dirty patch :

(dirty because I am lazy and I think Florian is already working on it)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index ff83c46bc389..0c2e1b0cd180 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1028,9 +1028,6 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 		last_c_index &= (num_tx_bds - 1);
 	}
 
-	if (ring->free_bds > (MAX_SKB_FRAGS + 1))
-		ring->int_disable(priv, ring);
-
 	if (netif_tx_queue_stopped(txq))
 		netif_tx_wake_queue(txq);
 
@@ -1302,11 +1299,13 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	bcmgenet_tdma_ring_writel(priv, ring->index,
 				  ring->prod_index, TDMA_PROD_INDEX);
 
-	if (ring->free_bds <= (MAX_SKB_FRAGS + 1)) {
+	if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
 		netif_tx_stop_queue(txq);
+
+	if (unlikely(!ring->int_enabled)) {
+		ring->int_enabled = true;
 		ring->int_enable(priv, ring);
 	}
-
 out:
 	spin_unlock_irqrestore(&ring->lock, flags);
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index b36ddec0cc0a..90d52893a1c8 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -530,6 +530,7 @@ struct bcmgenet_tx_ring {
 	unsigned int	prod_index;	/* Tx ring producer index SW copy */
 	unsigned int	cb_ptr;		/* Tx ring initial CB ptr */
 	unsigned int	end_ptr;	/* Tx ring end CB ptr */
+	bool			int_enabled;
 	void (*int_enable)(struct bcmgenet_priv *priv,
 			   struct bcmgenet_tx_ring *);
 	void (*int_disable)(struct bcmgenet_priv *priv,
