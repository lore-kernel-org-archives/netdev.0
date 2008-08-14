From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 14 Aug 2008 07:59:07 +0000
Message-ID: <20080814075907.GA6797@ff.dom.local>
References: <20080813102701.GD5367@ff.dom.local> <20080813104238.GA11374@gondor.apana.org.au> <20080813105052.GA6838@ff.dom.local> <20080813.151918.61294677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.191]:14908 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471AbYHNH7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 03:59:15 -0400
Received: by gv-out-0910.google.com with SMTP id e6so119822gvc.37
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 00:59:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080813.151918.61294677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 03:19:18PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 13 Aug 2008 10:50:52 +0000
> 
> > On Wed, Aug 13, 2008 at 08:42:38PM +1000, Herbert Xu wrote:
> > > On Wed, Aug 13, 2008 at 10:27:01AM +0000, Jarek Poplawski wrote:
> > > > 
> > > > - in net_tx_action() we can hit a place just after clear_bit() where
> > > > none of these bits is set. Of course, hitting this 2 times in a row
> > > > seems to be very unprobable, yet possible, and a lock isn't helpful
> > > > here, so probably some change around this would make this nicer.
> > > >
> > > > - isn't there possible some longer ping-pong between qdic_run() and
> > > > net_tx_action() when dev_requeue_skb() would get it back to
> > > > __netif_schedule() and so on (with NETDEV_TX_BUSY)?
> > > 
> > > Good point.  I think we should add an aliveness check in both
> > > net_tx_action and qdisc_run.  In fact the net_tx_action problem
> > > existed previously as well.  But it is pretty darn unlikely.
> > 
> > Yes, it seems qdisc_reset() doesn't have to help with this, so
> > probably there is needed some requeue counter or something...
> 
> Ok, so what I'm going to do is check in my patch and then try
> to figure out how to resolve this "both bits clear" scenerio.

Here is my proposal.

Jarek P.

----------->

net: Change handling of the __QDISC_STATE_SCHED flag in net_tx_action().

Change handling of the __QDISC_STATE_SCHED flag in net_tx_action() to
enable proper control in dev_deactivate_queue(). Now, if this flag is
seen as unset under root_lock means a qdisc can't be netif_scheduled.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/core/dev.c |   34 +++++++++++++++++++---------------
 1 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 600bb23..f67581b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1339,19 +1339,23 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 }
 
 
-void __netif_schedule(struct Qdisc *q)
+static inline void __netif_reschedule(struct Qdisc *q)
 {
-	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
-		struct softnet_data *sd;
-		unsigned long flags;
+	struct softnet_data *sd;
+	unsigned long flags;
 
-		local_irq_save(flags);
-		sd = &__get_cpu_var(softnet_data);
-		q->next_sched = sd->output_queue;
-		sd->output_queue = q;
-		raise_softirq_irqoff(NET_TX_SOFTIRQ);
-		local_irq_restore(flags);
-	}
+	local_irq_save(flags);
+	sd = &__get_cpu_var(softnet_data);
+	q->next_sched = sd->output_queue;
+	sd->output_queue = q;
+	raise_softirq_irqoff(NET_TX_SOFTIRQ);
+	local_irq_restore(flags);
+}
+
+void __netif_schedule(struct Qdisc *q)
+{
+	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state))
+		__netif_reschedule(q);
 }
 EXPORT_SYMBOL(__netif_schedule);
 
@@ -1974,15 +1978,15 @@ static void net_tx_action(struct softirq_action *h)
 
 			head = head->next_sched;
 
-			smp_mb__before_clear_bit();
-			clear_bit(__QDISC_STATE_SCHED, &q->state);
-
 			root_lock = qdisc_lock(q);
 			if (spin_trylock(root_lock)) {
+				smp_mb__before_clear_bit();
+				clear_bit(__QDISC_STATE_SCHED,
+					  &q->state);
 				qdisc_run(q);
 				spin_unlock(root_lock);
 			} else {
-				__netif_schedule(q);
+				__netif_reschedule(q);
 			}
 		}
 	}
