From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH] net_sched: restore qdisc quota fairness limits after bulk
	dequeue
Date: Thu, 09 Oct 2014 12:18:10 +0200
Message-ID: <20141009101640.26713.80729.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Dave Taht <dave.taht@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753329AbaJIKSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2014 06:18:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restore the quota fairness between qdisc's, that we broke with commit
5772e9a346 ("qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE").

Before that commit, the quota in __qdisc_run() were in packets as
dequeue_skb() would only dequeue a single packet, that assumption
broke with bulk dequeue.

We choose not to account for the number of packets inside the TSO/GSO
packets (accessable via "skb_gso_segs").  As the previous fairness
also had this "defect". Thus, GSO/TSO packets counts as a single
packet.

Further more, we choose to slack on accuracy, by allowing a bulk
dequeue try_bulk_dequeue_skb() to exceed the "packets" limit, only
limited by the BQL bytelimit.  This is done because BQL prefers to get
its full budget for appropriate feedback from TX completion.

In future, we might consider reworking this further and, if it allows,
switch to a time-based model, as suggested by Eric. Right now, we only
restore old semantics.

Joint work with Eric, Hannes, Daniel and Jesper.  Hannes wrote the
first patch in cooperation with Daniel and Jesper.  Eric rewrote the
patch.

Fixes: 5772e9a346 ("qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---

 net/sched/sch_generic.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2b349a4..b1840a8 100644
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
+		(*packets)++; /* GSO counts as one pkt */
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
 
+	*packets = 1;
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
