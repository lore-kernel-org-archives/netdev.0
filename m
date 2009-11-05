From: Jon Loeliger <jdl@jdl.com>
Subject: Re: [PATCH RFC] gianfar: Do not call skb recycling with disabled IRQs
Date: Thu, 05 Nov 2009 11:40:21 -0600
Message-ID: <E1N66Jp-0004Y0-8Q@jdl.com>
References: <20091104225711.GA30844@oksana.dev.rtsoft.ru>
	<E1N62ti-0003iS-K2@jdl.com>
	<20091105142028.GB17171@oksana.dev.rtsoft.ru>
	<E1N63WM-0003xK-PN@jdl.com> <E1N64UY-00049g-Hb@jdl.com>
	<20091105165738.GA31923@oksana.dev.rtsoft.ru>
	<9F4C7D19E8361D4C94921B95BE08B81B950713@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Fleming Andy-AFLEMING <afleming@freescale.com>,
	Jason Wessel <jason.wessel@windriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-reply-to: <9F4C7D19E8361D4C94921B95BE08B81B950713@zin33exm22.fsl.freescale.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

> 
> [.....]
> > drivers/net/gianfar.c |   19 +++----------------
> > 1 files changed, 3 insertions(+), 16 deletions(-)
> >
> >diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c=20
> >index 197b358..a0ae604 100644
> >--- a/drivers/net/gianfar.c
> >+++ b/drivers/net/gianfar.c
> >@@ -1899,10 +1899,8 @@ static int gfar_start_xmit(struct=20
> >sk_buff *skb, struct net_device *dev)
> > 	u32 lstatus;
> > 	int i, rq = 0;
> > 	u32 bufaddr;
> >-	unsigned long flags;
> > 	unsigned int nr_frags, length;
> > 
> >-
> > 	rq = skb->queue_mapping;
> > 	tx_queue = priv->tx_queue[rq];
> > 	txq = netdev_get_tx_queue(dev, rq);
> >@@ -1928,14 +1926,11 @@ static int gfar_start_xmit(struct 
> >sk_buff *skb, struct net_device *dev)
> > 	/* total number of fragments in the SKB */
> > 	nr_frags = skb_shinfo(skb)->nr_frags;
> > 
> >-	spin_lock_irqsave(&tx_queue->txlock, flags);
> >-
> > 	/* check if there is space to queue this packet */
> > 	if ((nr_frags+1) > tx_queue->num_txbdfree) {
> > 		/* no space, stop the queue */
> > 		netif_tx_stop_queue(txq);
> > 		dev->stats.tx_fifo_errors++;
> >-		spin_unlock_irqrestore(&tx_queue->txlock, flags);
> > 		return NETDEV_TX_BUSY;
> > 	}
> > 
> >@@ -2033,9 +2028,6 @@ static int gfar_start_xmit(struct 
> >sk_buff *skb, struct net_device *dev)
> > 	/* Tell the DMA to go go go */
> > 	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT >> tx_queue->qindex);
> > 
> >-	/* Unlock priv */
> >-	spin_unlock_irqrestore(&tx_queue->txlock, flags);
> >-
> > 	return NETDEV_TX_OK;
> > }
> > 
> >@@ -2550,7 +2542,6 @@ static int gfar_poll(struct napi_struct 
> >*napi, int budget)
> > 	int tx_cleaned = 0, i, left_over_budget = budget;
> > 	unsigned long serviced_queues = 0;
> > 	int num_queues = 0;
> >-	unsigned long flags;
> > 
> > 	num_queues = gfargrp->num_rx_queues;
> > 	budget_per_queue = budget/num_queues;
> >@@ -2570,13 +2561,9 @@ static int gfar_poll(struct napi_struct 
> >*napi, int budget)
> > 			rx_queue = priv->rx_queue[i];
> > 			tx_queue = priv->tx_queue[rx_queue->qindex];
> > 
> >-			/* If we fail to get the lock,
> >-			 * don't bother with the TX BDs */
> >-			if 
> >(spin_trylock_irqsave(&tx_queue->txlock, flags)) {
> >-				tx_cleaned += 
> >gfar_clean_tx_ring(tx_queue);
> >-			=09
> >spin_unlock_irqrestore(&tx_queue->txlock,
> >-							flags);
> >-			}
> >+			netif_tx_lock_bh(priv->ndev);
> 
> Will this not lead to locking all the tx queues even though at this
> point we are working on a "particular queue" ?

Similar but different question:  What version is this patch based upon?
I can't find:

    > >index 197b358..a0ae604 100644

My search of 2.6.31 up through current linux head (v2.6.32-rc6-26-g91d3f9b)
and benh's current head (94a8d5caba74211ec76dac80fc6e2d5c391530df) do not
have a version of this code with separate txqueues.

I confess I'm not too familiar with the history here, so I don't know
if that feature is in flux, or came, or went, or what.

That boils down to:  I can't directly apply your patch, but I could
hand-fudge its intent, but only on a single tx queue variant.

jdl
