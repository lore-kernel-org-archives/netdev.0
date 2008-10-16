From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 3/6] pkt_sched: sch_generic: Add generic qdisc->ops->peek()
	implementation.
Date: Thu, 16 Oct 2008 09:47:48 +0000
Message-ID: <20081016094748.GD19019@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:27586 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbYJPJrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 05:47:55 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1152801eyi.37
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 02:47:53 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: sch_generic: Add generic qdisc->ops->peek() implementation.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_api.c     |    6 ++++++
 net/sched/sch_generic.c |   16 ++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 1122c95..6cdc4e0 100644
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
@@ -149,6 +153,8 @@ int register_qdisc(struct Qdisc_ops *qops)
 		qops->enqueue = noop_qdisc_ops.enqueue;
 	if (qops->requeue == NULL)
 		qops->requeue = noop_qdisc_ops.requeue;
+	if (qops->peek == NULL)
+		qops->peek = noop_qdisc_ops.peek;
 	if (qops->dequeue == NULL)
 		qops->dequeue = noop_qdisc_ops.dequeue;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7b5572d..ccf7e04 100644
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
@@ -345,6 +346,7 @@ static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
+	.peek		=	noop_dequeue,
 	.requeue	=	noop_requeue,
 	.owner		=	THIS_MODULE,
 };
@@ -409,6 +411,19 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
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
@@ -455,6 +470,7 @@ static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.priv_size	=	PFIFO_FAST_BANDS * sizeof(struct sk_buff_head),
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
+	.peek		=	pfifo_fast_peek,
 	.requeue	=	pfifo_fast_requeue,
 	.init		=	pfifo_fast_init,
 	.reset		=	pfifo_fast_reset,
-- 
1.5.6.5

