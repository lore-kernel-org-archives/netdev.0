From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V6 1/2] qdisc: bulk dequeue support for qdiscs with
	TCQ_F_ONETXQUEUE
Date: Wed, 01 Oct 2014 22:35:59 +0200
Message-ID: <20141001203536.3321.5201.stgit@dragon>
References: <20141001203345.3321.99675.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29764 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355AbaJAUgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 16:36:07 -0400
In-Reply-To: <20141001203345.3321.99675.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on DaveM's recent API work on dev_hard_start_xmit(), that allows
sending/processing an entire skb list.

This patch implements qdisc bulk dequeue, by allowing multiple packets
to be dequeued in dequeue_skb().

The optimization principle for this is two fold, (1) to amortize
locking cost and (2) avoid expensive tailptr update for notifying HW.
 (1) Several packets are dequeued while holding the qdisc root_lock,
amortizing locking cost over several packet.  The dequeued SKB list is
processed under the TXQ lock in dev_hard_start_xmit(), thus also
amortizing the cost of the TXQ lock.
 (2) Further more, dev_hard_start_xmit() will utilize the skb->xmit_more
API to delay HW tailptr update, which also reduces the cost per
packet.

One restriction of the new API is that every SKB must belong to the
same TXQ.  This patch takes the easy way out, by restricting bulk
dequeue to qdisc's with the TCQ_F_ONETXQUEUE flag, that specifies the
qdisc only have attached a single TXQ.

Some detail about the flow; dev_hard_start_xmit() will process the skb
list, and transmit packets individually towards the driver (see
xmit_one()).  In case the driver stops midway in the list, the
remaining skb list is returned by dev_hard_start_xmit().  In
sch_direct_xmit() this returned list is requeued by dev_requeue_skb().

To avoid overshooting the HW limits, which results in requeuing, the
patch limits the amount of bytes dequeued, based on the drivers BQL
limits.  In-effect bulking will only happen for BQL enabled drivers.

Small amounts for extra HoL blocking (2x MTU/0.24ms) were
measured at 100Mbit/s, with bulking 8 packets, but the
oscillating nature of the measurement indicate something, like
sched latency might be causing this effect. More comparisons
show, that this oscillation goes away occationally. Thus, we
disregard this artifact completely and remove any "magic" bulking
limit.

For now, as a conservative approach, stop bulking when seeing TSO and
segmented GSO packets.  They already benefit from bulking on their own.
A followup patch add this, to allow easier bisect-ability for finding
regressions.

Jointed work with Hannes, Daniel and Florian.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>

---
V6:
 - Remove packet "budget" limit, rely 100% on BQL

V5:
 - Changed "budget" limit to 7 packets (from 8)
 - Choosing to use skb->len, because BQL uses that
 - Added testing results to patch desc

V4:
- Patch rewritten in the Red Hat Neuchatel office jointed work with
  Hannes, Daniel and Florian.
- Conservative approach of only using on BQL enabled drivers
- No user tunable parameter, but limit bulking to 8 packets.
- For now, avoid bulking GSO packets packets.

V3:
 - Correct use of BQL
 - Some minor adjustments based on feedback.
 - Default setting only bulk dequeue 1 extra packet (2 packets).

V2:
 - Restruct functions, split out functionality
 - Use BQL bytelimit to avoid overshooting driver limits
---

 include/net/sch_generic.h |   16 ++++++++++++++++
 net/sched/sch_generic.c   |   46 +++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f126698..d17ed6f 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -7,6 +7,7 @@
 #include <linux/pkt_sched.h>
 #include <linux/pkt_cls.h>
 #include <linux/percpu.h>
+#include <linux/dynamic_queue_limits.h>
 #include <net/gen_stats.h>
 #include <net/rtnetlink.h>
 
@@ -119,6 +120,21 @@ static inline void qdisc_run_end(struct Qdisc *qdisc)
 	qdisc->__state &= ~__QDISC___STATE_RUNNING;
 }
 
+static inline bool qdisc_may_bulk(const struct Qdisc *qdisc)
+{
+	return qdisc->flags & TCQ_F_ONETXQUEUE;
+}
+
+static inline int qdisc_avail_bulklimit(const struct netdev_queue *txq)
+{
+#ifdef CONFIG_BQL
+	/* Non-BQL migrated drivers will return 0, too. */
+	return dql_avail(&txq->dql);
+#else
+	return 0;
+#endif
+}
+
 static inline bool qdisc_is_throttled(const struct Qdisc *qdisc)
 {
 	return test_bit(__QDISC_STATE_THROTTLED, &qdisc->state) ? true : false;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7c8e5d7..c2e87e6 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -56,6 +56,41 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 	return 0;
 }
 
+static struct sk_buff *try_bulk_dequeue_skb(struct Qdisc *q,
+					    struct sk_buff *head_skb,
+					    int bytelimit)
+{
+	struct sk_buff *skb, *tail_skb = head_skb;
+
+	while (bytelimit > 0) {
+		/* For now, don't bulk dequeue GSO (or GSO segmented) pkts */
+		if (tail_skb->next || skb_is_gso(tail_skb))
+			break;
+
+		skb = q->dequeue(q);
+		if (!skb)
+			break;
+
+		bytelimit -= skb->len; /* covers GSO len */
+		skb = validate_xmit_skb(skb, qdisc_dev(q));
+		if (!skb)
+			break;
+
+		/* "skb" can be a skb list after validate call above
+		 * (GSO segmented), but it is okay to append it to
+		 * current tail_skb->next, because next round will exit
+		 * in-case "tail_skb->next" is a skb list.
+		 */
+		tail_skb->next = skb;
+		tail_skb = skb;
+	}
+
+	return head_skb;
+}
+
+/* Note that dequeue_skb can possibly return a SKB list (via skb->next).
+ * A requeued skb (via q->gso_skb) can also be a SKB list.
+ */
 static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 {
 	struct sk_buff *skb = q->gso_skb;
@@ -70,10 +105,17 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 		} else
 			skb = NULL;
 	} else {
-		if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq)) {
+		if (!(q->flags & TCQ_F_ONETXQUEUE) ||
+		    !netif_xmit_frozen_or_stopped(txq)) {
+			int bytelimit = qdisc_avail_bulklimit(txq);
+
 			skb = q->dequeue(q);
-			if (skb)
+			if (skb) {
+				bytelimit -= skb->len;
 				skb = validate_xmit_skb(skb, qdisc_dev(q));
+			}
+			if (skb && qdisc_may_bulk(q))
+				skb = try_bulk_dequeue_skb(q, skb, bytelimit);
 		}
 	}
 
