From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
Date: Thu, 17 Dec 2009 16:50:34 +0530
Message-ID: <20091217112034.9937.48474.sendpatchset@krkumar2.in.ibm.com>
Cc: herbert@gondor.apana.org.au, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:49930 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964967AbZLQLUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 06:20:40 -0500
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id nBHMKdOu023352
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 09:20:39 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHBGd3n1142808
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 22:16:39 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHBKbtP007743
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 22:20:38 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, Dec 17, 2009, Krishna Kumar2/India/IBM@IBMIN wrote on
>
> Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
>
> > >> I think sch_direct_xmit() is not even calling dev_hard_start_xmit() as
> > >> the tx queue is stopped
> > >> and does a dev_requeue_skb() and returns NETDEV_TX_BUSY.
> > >
> > > Yes but if the queue was stopped then we shouldn't even get into
> > > sch_direct_xmit.
> > I don't see any checks for txq_stopped in the callers of
> sch_direct_xmit() :
> > __dev_xmit_skb() and qdisc_restart().  Both these routines get the txq
> > and call
> > sch_direct_xmit() which checks if tx queue is stopped or frozen.
> >
> > Am i missing something?
> 
> Yes - dequeue_skb.
> 
> The final skb, before the queue was stopped, is transmitted by
> the driver. The next time sch_direct_xmit is called, it gets a
> skb and finds the device is stopped and requeue's the skb. For
> all subsequent xmits, dequeue_skb returns NULL (and the other
> caller - __dev_xmit_skb can never be called since qdisc_qlen is
> true) and thus requeue's will not happen. This also means that
> the number of requeues you see (eg 283K in one run) is the number
> of times the queue was stopped and restarted. So it looks like
> driver either:
> 
> 1. didn't stop the queue when xmiting a packet successfully (the
>       condition being that it would not be possible to xmit the
>       next skb). But this doesn't seem to be the case.
> 2. wrongly restarted the queue. Possible - since a few places
>       use both the start & wake queue api's.

[ Resending, since I sent to wrong id last time - sorry for
some duplicates ]

On a (slightly) related note, qdisc_restart() has this code:
	/* Dequeue packet */
	skb = dequeue_skb(q);
	if (unlikely(!skb))
		return 0;

When a txq is stopped, all subsequent dev_queue_xmits will
execute this path, pass the "unlikely" code, and return. Is
it reasonable to remove "unlikely" in both dequeue_skb and
qdisc_restart, if so patch inlined below:

thanks,

- KK

From: Krishna Kumar <krkumar2@in.ibm.com>

1. Remove two unlikely checks since stopped queue's will result
	int getting a NULL skb.
2. Remove an extra space after unlikely check.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/sched/sch_generic.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2009-12-17 16:29:59.000000000 +0530
+++ new/net/sched/sch_generic.c	2009-12-17 16:30:55.000000000 +0530
@@ -51,7 +51,7 @@ static inline struct sk_buff *dequeue_sk
 {
 	struct sk_buff *skb = q->gso_skb;
 
-	if (unlikely(skb)) {
+	if (skb) {
 		struct net_device *dev = qdisc_dev(q);
 		struct netdev_queue *txq;
 
@@ -134,7 +134,7 @@ int sch_direct_xmit(struct sk_buff *skb,
 		ret = handle_dev_cpu_collision(skb, txq, q);
 	} else {
 		/* Driver returned NETDEV_TX_BUSY - requeue skb */
-		if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
+		if (unlikely(ret != NETDEV_TX_BUSY && net_ratelimit()))
 			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
 
@@ -176,7 +176,7 @@ static inline int qdisc_restart(struct Q
 
 	/* Dequeue packet */
 	skb = dequeue_skb(q);
-	if (unlikely(!skb))
+	if (!skb)
 		return 0;
 
 	root_lock = qdisc_lock(q);
