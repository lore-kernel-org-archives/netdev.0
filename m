From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH RFC] gianfar: Do not call skb recycling with disabled IRQs
Date: Thu, 5 Nov 2009 19:57:38 +0300
Message-ID: <20091105165738.GA31923@oksana.dev.rtsoft.ru>
References: <20091104225711.GA30844@oksana.dev.rtsoft.ru>
 <E1N62ti-0003iS-K2@jdl.com>
 <20091105142028.GB17171@oksana.dev.rtsoft.ru>
 <E1N63WM-0003xK-PN@jdl.com>
 <E1N64UY-00049g-Hb@jdl.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linuxppc-dev@ozlabs.org, Jason Wessel <jason.wessel@windriver.com>,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jon Loeliger <jdl@jdl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:3153 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755904AbZKEQ5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 11:57:34 -0500
Content-Disposition: inline
In-Reply-To: <E1N64UY-00049g-Hb@jdl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before calling gfar_clean_tx_ring() we grab an irqsave spinlock, and
then try to recycle an skb, which requires IRQs to be enabled. This
leads to the following badness:

nf_conntrack version 0.5.0 (1008 buckets, 4032 max)
------------[ cut here ]------------
Badness at kernel/softirq.c:143
NIP: c003e3c4 LR: c423a528 CTR: c003e344
...
NIP [c003e3c4] local_bh_enable+0x80/0xc4
LR [c423a528] destroy_conntrack+0xd4/0x13c [nf_conntrack]
Call Trace:
[c15d1b60] [c003e32c] local_bh_disable+0x1c/0x34 (unreliable)
[c15d1b70] [c423a528] destroy_conntrack+0xd4/0x13c [nf_conntrack]
[c15d1b80] [c02c6370] nf_conntrack_destroy+0x3c/0x70
--- Exception: c428168c at 0xc15d1c50
LR = 0xc15d1c40
[c15d1ba0] [c0286f3c] skb_release_head_state+0x100/0x104 (unreliable)
[c15d1bb0] [c0288340] skb_recycle_check+0x8c/0x10c
[c15d1bc0] [c01e1688] gfar_poll+0x190/0x384
[c15d1c10] [c02935ac] net_rx_action+0xec/0x22c
[c15d1c50] [c003dd8c] __do_softirq+0xe8/0x224
[c15d1ca0] [c000624c] do_softirq+0x78/0x80
[c15d1cb0] [c003d868] irq_exit+0x60/0x78
...

We can't easily get rid of the irqsave spinlock, because we must
guard ourselves from start_xmit.

So, fix this by dropping the irqsave spinlock from both xmit_start
and clean_tx_ring routines. Instead, lock the whole tx queue via
netif_tx_lock_bh() in clean_tx_ring().

Reported-by: Jon Loeliger <jdl@jdl.com>
Not-yet-Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

On Thu, Nov 05, 2009 at 09:43:18AM -0600, Jon Loeliger wrote:
[...]
> This is with essentially a stock 2.6.31 kernel for an 8315.
> I've seen the problem for both task 'insmod' and 'iptables'.
> Um, conn_track is a module being loaded here.  Our brief analysis
> runs like this:
> 
>     This is an issue with the gianfar driver.  In gfar_poll(), irqs are
>     disabled for the handling of gfar_clean_tx_ring(dev) (line 1928).
>     In this call, skbs can call skb_recycle_check, which can release
>     head state (net/core/skbuff.c@506), which can cause conntrack
>     cleanup (net/core/skbuff.c@402->include/linux/skbuff.h@1923), which
>     cannot be done with IRQs disabled...that is the badness.

Ugh.

We may try to call netif_tx_lock_bh() in gfar_clean_tx_ring() and
drop the irqsave spinlock start_xmit (sky2-like scheme).

But that basically means that with skb recycling we can't safely
use KGDBoE, though we can add something like this:

| diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
| index a00ec63..4d82bd7 100644
| --- a/drivers/net/gianfar.c
| +++ b/drivers/net/gianfar.c
| @@ -1619,7 +1619,8 @@ static int gfar_clean_tx_ring(struct net_device *dev)
|  		 * If there's room in the queue (limit it to rx_buffer_size)
|  		 * we add this skb back into the pool, if it's the right size
|  		 */
| -		if (skb_queue_len(&priv->rx_recycle) < priv->rx_ring_size &&
| +		if (!irqs_disabled() &&
| +			skb_queue_len(&priv->rx_recycle) < priv->rx_ring_size &&
|  				skb_recycle_check(skb, priv->rx_buffer_size +
|  					RXBUF_ALIGNMENT))
| 			__skb_queue_head(&priv->rx_recycle, skb);

So we won't recycle skbs with irqs disabled.

Anyway, apart from KGDBoE, the following patch might fix the conntrack
issue, can you try it?

With this patch the kernel boots via NFS, and survives netperf, though
I'd like to audit changes a little more and run some netperf tests, I
might also put the netif_tx_lock_bh() stuff out of the loop.

So this patch isn't for the merge.

 drivers/net/gianfar.c |   19 +++----------------
 1 files changed, 3 insertions(+), 16 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 197b358..a0ae604 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1899,10 +1899,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 lstatus;
 	int i, rq = 0;
 	u32 bufaddr;
-	unsigned long flags;
 	unsigned int nr_frags, length;
 
-
 	rq = skb->queue_mapping;
 	tx_queue = priv->tx_queue[rq];
 	txq = netdev_get_tx_queue(dev, rq);
@@ -1928,14 +1926,11 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* total number of fragments in the SKB */
 	nr_frags = skb_shinfo(skb)->nr_frags;
 
-	spin_lock_irqsave(&tx_queue->txlock, flags);
-
 	/* check if there is space to queue this packet */
 	if ((nr_frags+1) > tx_queue->num_txbdfree) {
 		/* no space, stop the queue */
 		netif_tx_stop_queue(txq);
 		dev->stats.tx_fifo_errors++;
-		spin_unlock_irqrestore(&tx_queue->txlock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -2033,9 +2028,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Tell the DMA to go go go */
 	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT >> tx_queue->qindex);
 
-	/* Unlock priv */
-	spin_unlock_irqrestore(&tx_queue->txlock, flags);
-
 	return NETDEV_TX_OK;
 }
 
@@ -2550,7 +2542,6 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	int tx_cleaned = 0, i, left_over_budget = budget;
 	unsigned long serviced_queues = 0;
 	int num_queues = 0;
-	unsigned long flags;
 
 	num_queues = gfargrp->num_rx_queues;
 	budget_per_queue = budget/num_queues;
@@ -2570,13 +2561,9 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 			rx_queue = priv->rx_queue[i];
 			tx_queue = priv->tx_queue[rx_queue->qindex];
 
-			/* If we fail to get the lock,
-			 * don't bother with the TX BDs */
-			if (spin_trylock_irqsave(&tx_queue->txlock, flags)) {
-				tx_cleaned += gfar_clean_tx_ring(tx_queue);
-				spin_unlock_irqrestore(&tx_queue->txlock,
-							flags);
-			}
+			netif_tx_lock_bh(priv->ndev);
+			tx_cleaned += gfar_clean_tx_ring(tx_queue);
+			netif_tx_unlock_bh(priv->ndev);
 
 			rx_cleaned_per_queue = gfar_clean_rx_ring(rx_queue,
 							budget_per_queue);
-- 
1.6.3.3

