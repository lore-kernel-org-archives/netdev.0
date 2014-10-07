From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Quota in __qdisc_run() (was: qdisc: validate skb without
 holding lock)
Date: Tue, 07 Oct 2014 08:01:20 -0700
Message-ID: <1412694080.11091.131.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141003.145647.1980640682969765484.davem@davemloft.net>
	 <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141003.153645.72976986956341944.davem@davemloft.net>
	 <1412379044.17245.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141007093441.35ce3a02@redhat.com>
	 <1412686038.11091.111.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141007153050.792c9743@redhat.com>
	 <1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:55397 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176AbaJGPBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 11:01:23 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so7342467pab.12
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 08:01:22 -0700 (PDT)
In-Reply-To: <1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-07 at 16:43 +0200, Hannes Frederic Sowa wrote:

> This needs to be:
> 
> do
>    ...
> while ((iskb = iskb->next))

I do not feel needed to break the bulk dequeue at precise quota
boundary. These quotas are advisory, and bql prefers to get its full
budget for appropriate feedback from TX completion.

Quota was a packet quota, which was quite irrelevant if segmentation had
to be done, so I would just let the dequeue be done so that we benefit
from optimal xmit_more.

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2b349a4de3c8e3491fad210a9400d26bda5b52fe..581ba0dcc2474f325d1c0b3e1dc957648f11992f 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -58,7 +58,8 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 
 static void try_bulk_dequeue_skb(struct Qdisc *q,
 				 struct sk_buff *skb,
-				 const struct netdev_queue *txq)
+				 const struct netdev_queue *txq,
+				 int *packets)
 {
 	int bytelimit = qdisc_avail_bulklimit(txq) - skb->len;
 
@@ -71,6 +72,7 @@ static void try_bulk_dequeue_skb(struct Qdisc *q,
 		bytelimit -= nskb->len; /* covers GSO len */
 		skb->next = nskb;
 		skb = nskb;
+		(*packets)++;
 	}
 	skb->next = NULL;
 }
@@ -78,11 +80,13 @@ static void try_bulk_dequeue_skb(struct Qdisc *q,
 /* Note that dequeue_skb can possibly return a SKB list (via skb->next).
  * A requeued skb (via q->gso_skb) can also be a SKB list.
  */
-static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate)
+static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
+				   int *packets)
 {
 	struct sk_buff *skb = q->gso_skb;
 	const struct netdev_queue *txq = q->dev_queue;
 
+	*packets = 1; /* yes, this might be not accurate, only if BQL is wrong */
 	*validate = true;
 	if (unlikely(skb)) {
 		/* check the reason of requeuing without tx lock first */
@@ -99,7 +103,7 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate)
 		    !netif_xmit_frozen_or_stopped(txq)) {
 			skb = q->dequeue(q);
 			if (skb && qdisc_may_bulk(q))
-				try_bulk_dequeue_skb(q, skb, txq);
+				try_bulk_dequeue_skb(q, skb, txq, packets);
 		}
 	}
 	return skb;
@@ -205,7 +209,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
  *				>0 - queue is not empty.
  *
  */
-static inline int qdisc_restart(struct Qdisc *q)
+static inline int qdisc_restart(struct Qdisc *q, int *packets)
 {
 	struct netdev_queue *txq;
 	struct net_device *dev;
@@ -214,7 +218,7 @@ static inline int qdisc_restart(struct Qdisc *q)
 	bool validate;
 
 	/* Dequeue packet */
-	skb = dequeue_skb(q, &validate);
+	skb = dequeue_skb(q, &validate, packets);
 	if (unlikely(!skb))
 		return 0;
 
@@ -230,14 +234,16 @@ static inline int qdisc_restart(struct Qdisc *q)
 void __qdisc_run(struct Qdisc *q)
 {
 	int quota = weight_p;
+	int packets;
 
-	while (qdisc_restart(q)) {
+	while (qdisc_restart(q, &packets)) {
 		/*
 		 * Ordered by possible occurrence: Postpone processing if
 		 * 1. we've exceeded packet quota
 		 * 2. another process needs the CPU;
 		 */
-		if (--quota <= 0 || need_resched()) {
+		quota -= packets;
+		if (quota <= 0 || need_resched()) {
 			__netif_schedule(q);
 			break;
 		}
