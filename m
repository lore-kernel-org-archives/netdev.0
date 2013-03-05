From: Paolo valente <paolo.valente@unimore.it>
Subject: [PATCH BUGFIX 4/6] pkt_sched: prevent budget from wrapping around after a dequeue
Date: Tue,  5 Mar 2013 19:05:00 +0100
Message-ID: <1362506702-4985-5-git-send-email-paolo.valente@unimore.it>
References: <20130226.173700.882998504986475149.davem@davemloft.net>
 <1362506702-4985-1-git-send-email-paolo.valente@unimore.it>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fchecconi@gmail.com, rizzo@iet.unipi.it,
	Paolo Valente <paolo.valente@unimore.it>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362506702-4985-1-git-send-email-paolo.valente@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aggregate budgets are computed so as to guarantee that, after an
aggregate has been selected for service, that aggregate has enough
budget to serve at least one maximum-size packet for the classes it
contains. For this reason, after a new aggregate has been selected
for service, its next packet is immediately dequeued, without any
further control.

The maximum packet size for a class, lmax, can be changed through
qfq_change_class(). In case the user sets lmax to a lower value than
the the size of some of the still-to-arrive packets, QFQ+ will
automatically push up lmax as it enqueues these packets.  This
automatic push up is likely to happen with TSO/GSO.

In any case, if lmax is assigned a lower value than the size of some
of the packets already enqueued for the class, then the following
problem may occur: the size of the next packet to dequeue for the
class may happen to be larger than lmax, after the aggregate to which
the class belongs has been just selected for service. In this case,
even the budget of the aggregate, which is an unsigned value, may be
lower than the size of the next packet to dequeue. After dequeueing
this packet and subtracting its size from the budget, the latter would
wrap around.

This fix prevents the budget from wrapping around after any packet
dequeue.

Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
Reviewed-by: Fabio Checconi <fchecconi@gmail.com>
---
 net/sched/sch_qfq.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 0dbec31..26149e2 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1070,7 +1070,15 @@ static struct sk_buff *qfq_dequeue(struct Qdisc *sch)
 	qdisc_bstats_update(sch, skb);
 
 	agg_dequeue(in_serv_agg, cl, len);
-	in_serv_agg->budget -= len;
+	/* If lmax is lowered, through qfq_change_class, for a class
+	 * owning pending packets with larger size than the new value
+	 * of lmax, then the following condition may hold.
+	 */
+	if (unlikely(in_serv_agg->budget < len))
+		in_serv_agg->budget = 0;
+	else
+		in_serv_agg->budget -= len;
+
 	q->V += (u64)len * IWSUM;
 	pr_debug("qfq dequeue: len %u F %lld now %lld\n",
 		 len, (unsigned long long) in_serv_agg->F,
-- 
1.7.9.5
