From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: sch_fq: account for schedule/timers
 drifts
Date: Thu, 22 Sep 2016 08:58:55 -0700
Message-ID: <1474559935.23058.123.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34956 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751123AbcIVP66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 11:58:58 -0400
Received: by mail-pa0-f65.google.com with SMTP id hi10so3826528pac.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 08:58:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It looks like the following patch can make FQ very precise, even in VM
or stressed hosts. It matters at high pacing rates.

We take into account the difference between the time that was programmed
when last packet was sent, and current time (a drift of tens of usecs is
often observed)

Add an EWMA of the unthrottle latency to help diagnostics.

This latency is the difference between current time and oldest packet in
delayed RB-tree. This accounts for the high resolution timer latency,
but can be different under stress, as fq_check_throttled() can be
opportunistically be called from a dequeue() called after an enqueue()
for a different flow. 


Tested:
// Start a 10Gbit flow
$ netperf --google-pacing-rate 1250000000 -H lpaa24 -l 10000 -- -K bbr &

Before patch :
$ sar -n DEV 10 5 | grep eth0 | grep Average
Average:         eth0  17106.04 756876.84   1102.75 1119049.02      0.00      0.00      0.52

After patch :
$ sar -n DEV 10 5 | grep eth0 | grep Average
Average:         eth0  17867.00 800245.90   1151.77 1183172.12      0.00      0.00      0.52

A new iproute2 tc can output the 'unthrottle latency' :

$ tc -s qd sh dev eth0 | grep latency
  0 gc, 0 highprio, 32490767 throttled, 2382 ns latency

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/pkt_sched.h |    2 +-
 net/sched/sch_fq.c             |   21 ++++++++++++++++++---
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index f8e39dbaa781..df7451d35131 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -811,7 +811,7 @@ struct tc_fq_qd_stats {
 	__u32	flows;
 	__u32	inactive_flows;
 	__u32	throttled_flows;
-	__u32	pad;
+	__u32	unthrottle_latency_ns;
 };
 
 /* Heavy-Hitter Filter */
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 5dd929cc1423..18e752439f6f 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -86,6 +86,7 @@ struct fq_sched_data {
 
 	struct rb_root	delayed;	/* for rate limited flows */
 	u64		time_next_delayed_flow;
+	unsigned long	unthrottle_latency_ns;
 
 	struct fq_flow	internal;	/* for non classified or high prio packets */
 	u32		quantum;
@@ -408,11 +409,19 @@ static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 
 static void fq_check_throttled(struct fq_sched_data *q, u64 now)
 {
+	unsigned long sample;
 	struct rb_node *p;
 
 	if (q->time_next_delayed_flow > now)
 		return;
 
+	/* Update unthrottle latency EWMA.
+	 * This is cheap and can help diagnosing timer/latency problems.
+	 */
+	sample = (unsigned long)(now - q->time_next_delayed_flow);
+	q->unthrottle_latency_ns -= q->unthrottle_latency_ns >> 3;
+	q->unthrottle_latency_ns += sample >> 3;
+
 	q->time_next_delayed_flow = ~0ULL;
 	while ((p = rb_first(&q->delayed)) != NULL) {
 		struct fq_flow *f = container_of(p, struct fq_flow, rate_node);
@@ -515,7 +524,12 @@ begin:
 			len = NSEC_PER_SEC;
 			q->stat_pkts_too_long++;
 		}
-
+		/* Account for schedule/timers drifts.
+		 * f->time_next_packet was set when prior packet was sent,
+		 * and current time (@now) can be too late by tens of us.
+		 */
+		if (f->time_next_packet)
+			len -= min(len/2, now - f->time_next_packet);
 		f->time_next_packet = now + len;
 	}
 out:
@@ -787,6 +801,7 @@ static int fq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->initial_quantum	= 10 * psched_mtu(qdisc_dev(sch));
 	q->flow_refill_delay	= msecs_to_jiffies(40);
 	q->flow_max_rate	= ~0U;
+	q->time_next_delayed_flow = ~0ULL;
 	q->rate_enable		= 1;
 	q->new_flows.first	= NULL;
 	q->old_flows.first	= NULL;
@@ -854,8 +869,8 @@ static int fq_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 	st.flows		  = q->flows;
 	st.inactive_flows	  = q->inactive_flows;
 	st.throttled_flows	  = q->throttled_flows;
-	st.pad			  = 0;
-
+	st.unthrottle_latency_ns  = min_t(unsigned long,
+					  q->unthrottle_latency_ns, ~0U);
 	sch_tree_unlock(sch);
 
 	return gnet_stats_copy_app(d, &st, sizeof(st));
