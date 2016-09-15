From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] pkt_sched: fq: use proper locking in
 fq_dump_stats()
Date: Thu, 15 Sep 2016 16:20:01 -0700
Message-ID: <1473981601.22679.64.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33669 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757150AbcIOXUD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 19:20:03 -0400
Received: by mail-pf0-f195.google.com with SMTP id q2so140547pfj.0
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 16:20:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When fq is used on 32bit kernels, we need to lock the qdisc before
copying 64bit fields.

Otherwise "tc -s qdisc ..." might report bogus values.

Fixes: afe4fd062416 ("pkt_sched: fq: Fair Queue packet scheduler")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_fq.c |   32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index e5458b99e09c..dc52cc10d6ed 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -823,20 +823,24 @@ nla_put_failure:
 static int fq_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 {
 	struct fq_sched_data *q = qdisc_priv(sch);
-	u64 now = ktime_get_ns();
-	struct tc_fq_qd_stats st = {
-		.gc_flows		= q->stat_gc_flows,
-		.highprio_packets	= q->stat_internal_packets,
-		.tcp_retrans		= q->stat_tcp_retrans,
-		.throttled		= q->stat_throttled,
-		.flows_plimit		= q->stat_flows_plimit,
-		.pkts_too_long		= q->stat_pkts_too_long,
-		.allocation_errors	= q->stat_allocation_errors,
-		.flows			= q->flows,
-		.inactive_flows		= q->inactive_flows,
-		.throttled_flows	= q->throttled_flows,
-		.time_next_delayed_flow	= q->time_next_delayed_flow - now,
-	};
+	struct tc_fq_qd_stats st;
+
+	sch_tree_lock(sch);
+
+	st.gc_flows		  = q->stat_gc_flows;
+	st.highprio_packets	  = q->stat_internal_packets;
+	st.tcp_retrans		  = q->stat_tcp_retrans;
+	st.throttled		  = q->stat_throttled;
+	st.flows_plimit		  = q->stat_flows_plimit;
+	st.pkts_too_long	  = q->stat_pkts_too_long;
+	st.allocation_errors	  = q->stat_allocation_errors;
+	st.time_next_delayed_flow = q->time_next_delayed_flow - ktime_get_ns();
+	st.flows		  = q->flows;
+	st.inactive_flows	  = q->inactive_flows;
+	st.throttled_flows	  = q->throttled_flows;
+	st.pad			  = 0;
+
+	sch_tree_unlock(sch);
 
 	return gnet_stats_copy_app(d, &st, sizeof(st));
 }
