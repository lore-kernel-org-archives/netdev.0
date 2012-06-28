From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fq_codel: report congestion notification
 at enqueue time
Date: Thu, 28 Jun 2012 19:07:17 +0200
Message-ID: <1340903237.13187.151.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>, netdev <netdev@vger.kernel.org>,
	codel@lists.bufferbloat.net, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>, Matt Mathis <mattmathis@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <codel-bounces@lists.bufferbloat.net>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

At enqueue time, check sojourn time of packet at head of the queue,
and return NET_XMIT_CN instead of NET_XMIT_SUCCESS if this sejourn
time is above codel @target.

This permits local TCP stack to call tcp_enter_cwr() and reduce its cwnd
without drops (for example if ECN is not enabled for the flow)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Dave Taht <dave.taht@bufferbloat.net>
Cc: Tom Herbert <therbert@google.com>
Cc: Matt Mathis <mattmathis@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 include/linux/pkt_sched.h |    1 +
 include/net/codel.h       |    2 +-
 net/sched/sch_fq_codel.c  |   19 +++++++++++++++----
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 32aef0a..4d409a5 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -714,6 +714,7 @@ struct tc_fq_codel_qd_stats {
 				 */
 	__u32	new_flows_len;	/* count of flows in new list */
 	__u32	old_flows_len;	/* count of flows in old list */
+	__u32	congestion_count;
 };
 
 struct tc_fq_codel_cl_stats {
diff --git a/include/net/codel.h b/include/net/codel.h
index 550debf..8c7d6a7 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -148,7 +148,7 @@ struct codel_vars {
  * struct codel_stats - contains codel shared variables and stats
  * @maxpacket:	largest packet we've seen so far
  * @drop_count:	temp count of dropped packets in dequeue()
- * ecn_mark:	number of packets we ECN marked instead of dropping
+ * @ecn_mark:	number of packets we ECN marked instead of dropping
  */
 struct codel_stats {
 	u32		maxpacket;
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 9fc1c62..c0485a0 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -62,6 +62,7 @@ struct fq_codel_sched_data {
 	struct codel_stats cstats;
 	u32		drop_overlimit;
 	u32		new_flow_count;
+	u32		congestion_count;
 
 	struct list_head new_flows;	/* list of new flows */
 	struct list_head old_flows;	/* list of old flows */
@@ -196,16 +197,25 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		flow->deficit = q->quantum;
 		flow->dropped = 0;
 	}
-	if (++sch->q.qlen < sch->limit)
+	if (++sch->q.qlen < sch->limit) {
+		codel_time_t hdelay = codel_get_enqueue_time(skb) -
+				      codel_get_enqueue_time(flow->head);
+
+		/* If this flow is congested, tell the caller ! */
+		if (codel_time_after(hdelay, q->cparams.target)) {
+			q->congestion_count++;
+			return NET_XMIT_CN;
+		}
 		return NET_XMIT_SUCCESS;
-
+	}
 	q->drop_overlimit++;
 	/* Return Congestion Notification only if we dropped a packet
 	 * from this flow.
 	 */
-	if (fq_codel_drop(sch) == idx)
+	if (fq_codel_drop(sch) == idx) {
+		q->congestion_count++;
 		return NET_XMIT_CN;
-
+	}
 	/* As we dropped a packet, better let upper stack know this */
 	qdisc_tree_decrease_qlen(sch, 1);
 	return NET_XMIT_SUCCESS;
@@ -467,6 +477,7 @@ static int fq_codel_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 
 	st.qdisc_stats.maxpacket = q->cstats.maxpacket;
 	st.qdisc_stats.drop_overlimit = q->drop_overlimit;
+	st.qdisc_stats.congestion_count = q->congestion_count;
 	st.qdisc_stats.ecn_mark = q->cstats.ecn_mark;
 	st.qdisc_stats.new_flow_count = q->new_flow_count;
