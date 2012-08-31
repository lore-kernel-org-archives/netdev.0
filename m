From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC v2] fq_codel : interval servo on hosts
Date: Fri, 31 Aug 2012 06:57:46 -0700
Message-ID: <1346421466.2591.38.camel@edumazet-glaptop>
References: <1346396137.2586.301.camel@edumazet-glaptop>
	<1346421031.2591.34.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tomas Hruby <thruby@google.com>, Nandita Dukkipati <nanditad@google.com>,
	netdev <netdev@vger.kernel.org>
To: codel@lists.bufferbloat.net
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1346421031.2591.34.camel@edumazet-glaptop>
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

On Fri, 2012-08-31 at 06:50 -0700, Eric Dumazet wrote:
> On Thu, 2012-08-30 at 23:55 -0700, Eric Dumazet wrote:
> > On locally generated TCP traffic (host), we can override the 100 ms
> > interval value using the more accurate RTT estimation maintained by TCP
> > stack (tp->srtt)
> > 
> > Datacenter workload benefits using shorter feedback (say if RTT is below
> > 1 ms, we can react 100 times faster to a congestion)
> > 
> > Idea from Yuchung Cheng.
> > 
> 
> Linux patch would be the following :
> 
> I'll do tests next week, but I am sending a raw patch right now if
> anybody wants to try it.
> 
> Presumably we also want to adjust target as well.
> 
> To get more precise srtt values in the datacenter, we might avoid the
> 'one jiffie slack' on small values in tcp_rtt_estimator(), as we force
> m to be 1 before the scaling by 8 :
> 
> if (m == 0)
> 	m = 1;
> 
> We only need to force the least significant bit of srtt to be set.
> 

Hmm, I also need to properly init default_interval after
codel_params_init(&q->cparams) :

 net/sched/sch_fq_codel.c |   24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 9fc1c62..f04ff6a 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -25,6 +25,7 @@
 #include <net/pkt_sched.h>
 #include <net/flow_keys.h>
 #include <net/codel.h>
+#include <linux/tcp.h>
 
 /*	Fair Queue CoDel.
  *
@@ -59,6 +60,7 @@ struct fq_codel_sched_data {
 	u32		perturbation;	/* hash perturbation */
 	u32		quantum;	/* psched_mtu(qdisc_dev(sch)); */
 	struct codel_params cparams;
+	codel_time_t	default_interval;
 	struct codel_stats cstats;
 	u32		drop_overlimit;
 	u32		new_flow_count;
@@ -211,6 +213,14 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 }
 
+/* Given TCP srtt evaluation, return codel interval.
+ * srtt is given in jiffies, scaled by 8.
+ */
+static codel_time_t tcp_srtt_to_codel(unsigned int srtt)
+{
+	return srtt * ((NSEC_PER_SEC >> (CODEL_SHIFT + 3)) / HZ);
+}
+
 /* This is the specific function called from codel_dequeue()
  * to dequeue a packet from queue. Note: backlog is handled in
  * codel, we dont need to reduce it here.
@@ -220,12 +230,21 @@ static struct sk_buff *dequeue(struct codel_vars *vars, struct Qdisc *sch)
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
 	struct fq_codel_flow *flow;
 	struct sk_buff *skb = NULL;
+	struct sock *sk;
 
 	flow = container_of(vars, struct fq_codel_flow, cvars);
 	if (flow->head) {
 		skb = dequeue_head(flow);
 		q->backlogs[flow - q->flows] -= qdisc_pkt_len(skb);
 		sch->q.qlen--;
+		sk = skb->sk;
+		q->cparams.interval = q->default_interval;
+		if (sk && sk->sk_protocol == IPPROTO_TCP) {
+			u32 srtt = tcp_sk(sk)->srtt;
+
+			if (srtt)
+				q->cparams.interval = tcp_srtt_to_codel(srtt);
+		}
 	}
 	return skb;
 }
@@ -330,7 +349,7 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
 	if (tb[TCA_FQ_CODEL_INTERVAL]) {
 		u64 interval = nla_get_u32(tb[TCA_FQ_CODEL_INTERVAL]);
 
-		q->cparams.interval = (interval * NSEC_PER_USEC) >> CODEL_SHIFT;
+		q->default_interval = (interval * NSEC_PER_USEC) >> CODEL_SHIFT;
 	}
 
 	if (tb[TCA_FQ_CODEL_LIMIT])
@@ -395,6 +414,7 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 	INIT_LIST_HEAD(&q->new_flows);
 	INIT_LIST_HEAD(&q->old_flows);
 	codel_params_init(&q->cparams);
+	q->default_interval = q->cparams.interval;
 	codel_stats_init(&q->cstats);
 	q->cparams.ecn = true;
 
@@ -441,7 +461,7 @@ static int fq_codel_dump(struct Qdisc *sch, struct sk_buff *skb)
 	    nla_put_u32(skb, TCA_FQ_CODEL_LIMIT,
 			sch->limit) ||
 	    nla_put_u32(skb, TCA_FQ_CODEL_INTERVAL,
-			codel_time_to_us(q->cparams.interval)) ||
+			codel_time_to_us(q->default_interval)) ||
 	    nla_put_u32(skb, TCA_FQ_CODEL_ECN,
 			q->cparams.ecn) ||
 	    nla_put_u32(skb, TCA_FQ_CODEL_QUANTUM,
