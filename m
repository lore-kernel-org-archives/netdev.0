From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 3/6 RESEND v2] pkt_sched: sch_generic: Add generic
	qdisc->ops->peek() implementation.
Date: Thu, 30 Oct 2008 13:05:59 +0000
Message-ID: <20081030130559.GD22853@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:23324 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbYJ3NGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 09:06:06 -0400
Received: by ey-out-2122.google.com with SMTP id 6so211259eyi.37
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 06:06:05 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: sch_generic: Add generic qdisc->ops->peek() implementation.
With feedback from Patrick McHardy.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_api.c     |   12 ++++++++++++
 net/sched/sch_generic.c |   16 ++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b16ad29..e564661 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -102,6 +102,10 @@ static int tclass_notify(struct sk_buff *oskb, struct nlmsghdr *n,
    requeues once dequeued packet. It is used for non-standard or
    just buggy devices, which can defer output even if netif_queue_stopped()=0.
 
+   ---peek
+
+   like dequeue but without removing a packet from the queue
+
    ---reset
 
    returns qdisc to initial state: purge all buffers, clear all
@@ -149,6 +153,14 @@ int register_qdisc(struct Qdisc_ops *qops)
 		qops->enqueue = noop_qdisc_ops.enqueue;
 	if (qops->requeue == NULL)
 		qops->requeue = noop_qdisc_ops.requeue;
+	if (qops->peek == NULL) {
+		if (qops->dequeue == NULL) {
+			qops->peek = noop_qdisc_ops.peek;
+		} else {
+			rc = -EINVAL;
+			goto out;
+		}
+	}
 	if (qops->dequeue == NULL)
 		qops->dequeue = noop_qdisc_ops.dequeue;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 93cd30c..318c9f6 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -320,6 +320,7 @@ struct Qdisc_ops noop_qdisc_ops __read_mostly = {
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
+	.peek		=	noop_dequeue,
 	.requeue	=	noop_requeue,
 	.owner		=	THIS_MODULE,
 };
@@ -346,6 +347,7 @@ static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
+	.peek		=	noop_dequeue,
 	.requeue	=	noop_requeue,
 	.owner		=	THIS_MODULE,
 };
@@ -411,6 +413,19 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 	return NULL;
 }
 
+static struct sk_buff *pfifo_fast_peek(struct Qdisc* qdisc)
+{
+	int prio;
+	struct sk_buff_head *list = qdisc_priv(qdisc);
+
+	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
+		if (!skb_queue_empty(list + prio))
+			return skb_peek(list + prio);
+	}
+
+	return NULL;
+}
+
 static int pfifo_fast_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
 	qdisc->q.qlen++;
@@ -457,6 +472,7 @@ static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.priv_size	=	PFIFO_FAST_BANDS * sizeof(struct sk_buff_head),
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
+	.peek		=	pfifo_fast_peek,
 	.requeue	=	pfifo_fast_requeue,
 	.init		=	pfifo_fast_init,
 	.reset		=	pfifo_fast_reset,
-- 
1.5.6.5

