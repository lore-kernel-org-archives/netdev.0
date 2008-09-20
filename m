From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Sun, 21 Sep 2008 01:48:43 +0200
Message-ID: <20080920234843.GA2531@ami.dom.local>
References: <20080913205408.GA2545@ami.dom.local> <20080914061610.GA20571@gondor.apana.org.au> <20080914202715.GA2540@ami.dom.local> <20080920.002137.108837580.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:56270 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbYITXpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 19:45:55 -0400
Received: by mu-out-0910.google.com with SMTP id g7so832855muf.1
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2008 16:45:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080920.002137.108837580.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 20, 2008 at 12:21:37AM -0700, David Miller wrote:
...
> Let's look at what actually matters for cpu utilization.  These
> __qdisc_run() things are invoked in two situations where we might
> block on the hw queue being stopped:
> 
> 1) When feeding packets into the qdisc in dev_queue_xmit().
> 
>    Guess what?  We _know_ the queue this packet is going to
>    hit.
> 
>    The only new thing we can possible trigger and be interested
>    in at this specific point is if _this_ packet can be sent at
>    this time.
> 
>    And we can check that queue mapping after the qdisc_enqueue_root()
>    call, so that multiq aware qdiscs can have made their changes.
> 
> 2) When waking up a queue.  And here we should schedule the qdisc_run
>    _unconditionally_.
> 
>    If the queue was full, it is extremely likely that new packets
>    are bound for that device queue.  There is no real savings to
>    be had by doing this peek/requeue/dequeue stuff.
> 
> The cpu utilization savings exist for case #1 only, and we can
> implement the bypass logic _perfectly_ as described above.
> 
> For #2 there is nothing to check, just do it and see what comes
> out of the qdisc.

Right, unless __netif_schedule() wasn't done when waking up. I've
thought about this because of another thread/patch around this
problem, and got misled by dev_requeue_skb() scheduling. Now, I think
this could be the main reason for this high load. Anyway, if we want
to skip this check for #2 I think something like the patch below is
needed.

> I would suggest adding an skb pointer argument to qdisc_run().
> If it's NULL, unconditionally schedule __qdisc_run().  Else,
> only schedule if the TX queue indicated by skb_queue_mapping()
> is not stopped.
> 
> dev_queue_xmit() will use the "pass the skb" case, but only if
> qdisc_enqueue_root()'s return value doesn't indicate that there
> is a potential drop.  On potential drop, we'll pass NULL to
> make sure we don't potentially reference a free'd SKB.
> 
> The other case in net_tx_action() can always pass NULL to qdisc_run().

I'm not convinced this #1 is useful for us: this could be an skb #1000
in a queue; the tx status could change many times before this packet
would be #1; why worry? This adds additional checks on the fast path
for something which is unlikely even if this skb would be #1, but for
any later skbs it's only a guess. IMHO, if we can't check for the next
skb to be xmitted it's better to skip this test entirely (which seems
to be safe with the patch below).

Jarek P.

--------------->
pkt_sched: dev_requeue_skb: Don't schedule if a queue is stopped

Doing __netif_schedule() while requeuing because of a stopped tx queue
and skipping such a test in qdisc_run() can cause a requeuing loop with
high cpu use until the queue is awaken.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_generic.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ec0a083..bae2eb8 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -42,14 +42,17 @@ static inline int qdisc_qlen(struct Qdisc *q)
 	return q->q.qlen;
 }
 
-static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
+static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q,
+				  bool stopped)
 {
 	if (unlikely(skb->next))
 		q->gso_skb = skb;
 	else
 		q->ops->requeue(skb, q);
 
-	__netif_schedule(q);
+	if (!stopped)
+		__netif_schedule(q);
+
 	return 0;
 }
 
@@ -89,7 +92,7 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 		 * some time.
 		 */
 		__get_cpu_var(netdev_rx_stat).cpu_collision++;
-		ret = dev_requeue_skb(skb, q);
+		ret = dev_requeue_skb(skb, q, false);
 	}
 
 	return ret;
@@ -121,6 +124,7 @@ static inline int qdisc_restart(struct Qdisc *q)
 	struct net_device *dev;
 	spinlock_t *root_lock;
 	struct sk_buff *skb;
+	bool stopped;
 
 	/* Dequeue packet */
 	if (unlikely((skb = dequeue_skb(q)) == NULL))
@@ -135,9 +139,13 @@ static inline int qdisc_restart(struct Qdisc *q)
 	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_tx_queue_stopped(txq) &&
-	    !netif_tx_queue_frozen(txq))
+	if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq)) {
 		ret = dev_hard_start_xmit(skb, dev, txq);
+		stopped = netif_tx_queue_stopped(txq) ||
+			  netif_tx_queue_frozen(txq);
+	} else {
+		stopped = true;
+	}
 	HARD_TX_UNLOCK(dev, txq);
 
 	spin_lock(root_lock);
@@ -159,12 +167,11 @@ static inline int qdisc_restart(struct Qdisc *q)
 			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
 
-		ret = dev_requeue_skb(skb, q);
+		ret = dev_requeue_skb(skb, q, stopped);
 		break;
 	}
 
-	if (ret && (netif_tx_queue_stopped(txq) ||
-		    netif_tx_queue_frozen(txq)))
+	if (ret && stopped)
 		ret = 0;
 
 	return ret;
