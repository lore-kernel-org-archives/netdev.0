From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH V3 2/2] qdisc: bulk dequeue support for qdiscs
	with TCQ_F_ONETXQUEUE
Date: Fri, 19 Sep 2014 22:49:47 +0200
Message-ID: <20140919204926.3231.1970.stgit@dragon>
References: <20140919204706.3231.59125.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:63162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757956AbaISUuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 16:50:10 -0400
In-Reply-To: <20140919204706.3231.59125.stgit@dragon>
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
limits.

It also see GSO and segmented GSO packets, as a seperate kind of SKB
bulking, and thus tries to avoid and stop dequeuing when seeing a GSO
packet (both real GSO and segmented GSO skb lists).

Choosing a very conservative initial default value of 1 extra packet
dequeue, if bulking is allowed.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2:
 - Restruct functions, split out functionality
 - Use BQL bytelimit to avoid overshooting driver limits

V3:
 - Correct use of BQL
 - Some minor adjustments based on feedback.
 - Default setting only bulk dequeue 1 extra packet (2 packets).

 include/net/sch_generic.h  |    2 +
 net/core/sysctl_net_core.c |    9 ++++++
 net/sched/sch_generic.c    |   70 ++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 78 insertions(+), 3 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1e89b9a..da9324f 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -14,6 +14,8 @@ struct qdisc_walker;
 struct tcf_walker;
 struct module;
 
+extern int qdisc_bulk_dequeue_limit;
+
 struct qdisc_rate_table {
 	struct tc_ratespec rate;
 	u32		data[256];
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cf9cd13..5505841 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -361,6 +361,15 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "qdisc_bulk_dequeue_limit",
+		.data		= &qdisc_bulk_dequeue_limit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.extra1		= &zero,
+		.extra2		= &ushort_max,
+		.proc_handler	= proc_dointvec_minmax
+	},
 	{ }
 };
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 346ef85..eee2280 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -34,6 +34,9 @@
 const struct Qdisc_ops *default_qdisc_ops = &pfifo_fast_ops;
 EXPORT_SYMBOL(default_qdisc_ops);
 
+// FIXME: Still undecided where to put this parameter...
+int qdisc_bulk_dequeue_limit __read_mostly = 1;
+
 /* Main transmission queue. */
 
 /* Modifications to data participating in scheduling must be protected with
@@ -56,6 +59,67 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 	return 0;
 }
 
+static inline bool qdisc_may_bulk(const struct Qdisc *qdisc)
+{
+	return qdisc->flags & TCQ_F_ONETXQUEUE;
+}
+
+static inline struct sk_buff *qdisc_dequeue_validate(struct Qdisc *qdisc)
+{
+	struct sk_buff *skb = qdisc->dequeue(qdisc);
+
+	if (skb != NULL)
+		skb = validate_xmit_skb(skb, qdisc_dev(qdisc));
+
+	return skb;
+}
+
+static inline struct sk_buff *qdisc_bulk_dequeue_skb(struct Qdisc *q,
+						     struct sk_buff *head)
+{
+	struct sk_buff *new, *skb = head;
+	struct netdev_queue *txq = q->dev_queue;
+	int bytelimit = netdev_tx_avail_queue(txq);
+	int limit = qdisc_bulk_dequeue_limit;
+
+	bytelimit -= skb->len; /* incorrect len if skb->next, but exits below */
+
+	// if (bytelimit < psched_mtu(qdisc_dev(q)) //proposed by fw
+	if (bytelimit < 0)
+		return head;
+
+	do {
+		if (skb->next || skb_is_gso(skb)) {
+			/* Stop processing if the skb is already a skb
+			 * list (e.g a segmented GSO packet, from
+			 * below or func caller) or a real GSO packet
+			 */
+			break;
+		}
+		new = q->dequeue(q);
+		if (new) {
+			bytelimit -= new->len; /* covers GSO len */
+			new = validate_xmit_skb(new, qdisc_dev(q));
+			if (!new)
+				break;
+			/* "new" can be a skb list after validate call
+			 * above (GSO segmented), but it is okay to
+			 * append it to current skb->next, because
+			 * next round will exit in-case "new" were a
+			 * skb list.
+			 */
+			skb->next = new;
+			skb = new;
+		}
+	} while (new && --limit && (bytelimit >= 0));
+	skb = head;
+
+	return skb;
+}
+
+/* Note that dequeue_skb can possibly return a SKB list (via skb->next).
+ * A requeued skb (via q->gso_skb) can also be a SKB list.
+ */
 static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 {
 	struct sk_buff *skb = q->gso_skb;
@@ -71,9 +135,9 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 			skb = NULL;
 	} else {
 		if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq)) {
-			skb = q->dequeue(q);
-			if (skb)
-				skb = validate_xmit_skb(skb, qdisc_dev(q));
+			skb = qdisc_dequeue_validate(q);
+			if (skb && qdisc_may_bulk(q) && qdisc_bulk_dequeue_limit)
+				skb = qdisc_bulk_dequeue_skb(q, skb);
 		}
 	}
 
