From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] codel: add ce_threshold attribute
Date: Fri, 08 May 2015 15:05:12 -0700
Message-ID: <1431122712.22756.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Glenn Judd <glenn.judd@morganstanley.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:38858 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981AbbEHWFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 18:05:14 -0400
Received: by igbhj9 with SMTP id hj9so32957802igb.1
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 15:05:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

For DCTCP or similar ECN based deployments on fabrics with shallow
buffers, hosts are responsible for a good part of the buffering.

This patch adds an optional ce_threshold to codel & fq_codel qdiscs,
so that DCTCP can have feedback from queuing in the host.

A DCTCP enabled egress port simply have a queue occupancy threshold
above which ECT packets get CE mark.

In codel language this translates to a sojourn time, so that one doesn't
have to worry about bytes or bandwidth but delays.

This makes the host an active participant in the health of the whole
network.

This also helps experimenting DCTCP in a setup without DCTCP compliant
fabric.

On following example, ce_threshold is set to 1ms, and we can see from
'ldelay xxx us' that TCP is not trying to go around the 5ms codel
target.

Queue has more capacity to absorb inelastic bursts (say from UDP
traffic), as queues are maintained to an optimal level.

lpaa23:~# ./tc -s -d qd sh dev eth1
qdisc mq 1: dev eth1 root 
 Sent 87910654696 bytes 58065331 pkt (dropped 0, overlimits 0 requeues 42961) 
 backlog 3108242b 364p requeues 42961 
qdisc codel 8063: dev eth1 parent 1:1 limit 1000p target 5.0ms ce_threshold 1.0ms interval 100.0ms 
 Sent 7363778701 bytes 4863809 pkt (dropped 0, overlimits 0 requeues 5503) 
 rate 2348Mbit 193919pps backlog 255866b 46p requeues 5503 
  count 0 lastcount 0 ldelay 1.0ms drop_next 0us
  maxpacket 68130 ecn_mark 0 drop_overlimit 0 ce_mark 72384
qdisc codel 8064: dev eth1 parent 1:2 limit 1000p target 5.0ms ce_threshold 1.0ms interval 100.0ms 
 Sent 7636486190 bytes 5043942 pkt (dropped 0, overlimits 0 requeues 5186) 
 rate 2319Mbit 191538pps backlog 207418b 64p requeues 5186 
  count 0 lastcount 0 ldelay 694us drop_next 0us
  maxpacket 68130 ecn_mark 0 drop_overlimit 0 ce_mark 69873
qdisc codel 8065: dev eth1 parent 1:3 limit 1000p target 5.0ms ce_threshold 1.0ms interval 100.0ms 
 Sent 11569360142 bytes 7641602 pkt (dropped 0, overlimits 0 requeues 5554) 
 rate 3041Mbit 251096pps backlog 210446b 59p requeues 5554 
  count 0 lastcount 0 ldelay 889us drop_next 0us
  maxpacket 68130 ecn_mark 0 drop_overlimit 0 ce_mark 37780
...

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Florian Westphal <fw@strlen.de>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Glenn Judd <glenn.judd@morganstanley.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/net/codel.h            |   12 +++++++++++-
 include/uapi/linux/pkt_sched.h |    4 ++++
 net/sched/sch_codel.c          |   15 +++++++++++++--
 net/sched/sch_fq_codel.c       |   17 +++++++++++++++--
 4 files changed, 43 insertions(+), 5 deletions(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index aeee28081245c9215f10badd611f58ba0124fcd0..8c0f78f209e86687d3fc73e6b32d39f42ed31b60 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -7,7 +7,7 @@
  *  Copyright (C) 2011-2012 Kathleen Nichols <nichols@pollere.com>
  *  Copyright (C) 2011-2012 Van Jacobson <van@pollere.net>
  *  Copyright (C) 2012 Michael D. Taht <dave.taht@bufferbloat.net>
- *  Copyright (C) 2012 Eric Dumazet <edumazet@google.com>
+ *  Copyright (C) 2012,2015 Eric Dumazet <edumazet@google.com>
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions
@@ -119,11 +119,13 @@ static inline u32 codel_time_to_us(codel_time_t val)
 /**
  * struct codel_params - contains codel parameters
  * @target:	target queue size (in time units)
+ * @ce_threshold:  threshold for marking packets with ECN CE
  * @interval:	width of moving time window
  * @ecn:	is Explicit Congestion Notification enabled
  */
 struct codel_params {
 	codel_time_t	target;
+	codel_time_t	ce_threshold;
 	codel_time_t	interval;
 	bool		ecn;
 };
@@ -159,17 +161,22 @@ struct codel_vars {
  * @maxpacket:	largest packet we've seen so far
  * @drop_count:	temp count of dropped packets in dequeue()
  * ecn_mark:	number of packets we ECN marked instead of dropping
+ * ce_mark:	number of packets CE marked because sojourn time was above ce_threshold
  */
 struct codel_stats {
 	u32		maxpacket;
 	u32		drop_count;
 	u32		ecn_mark;
+	u32		ce_mark;
 };
 
+#define CODEL_DISABLED_THRESHOLD INT_MAX
+
 static void codel_params_init(struct codel_params *params)
 {
 	params->interval = MS2TIME(100);
 	params->target = MS2TIME(5);
+	params->ce_threshold = CODEL_DISABLED_THRESHOLD;
 	params->ecn = false;
 }
 
@@ -350,6 +357,9 @@ static struct sk_buff *codel_dequeue(struct Qdisc *sch,
 						    vars->rec_inv_sqrt);
 	}
 end:
+	if (skb && codel_time_after(vars->ldelay, params->ce_threshold) &&
+	    INET_ECN_set_ce(skb))
+		stats->ce_mark++;
 	return skb;
 }
 #endif
diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 534b847107453019d362e9f9f9c0969fc3100c8b..69d88b309cc7c32614556e6254f911fe7c579c8a 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -679,6 +679,7 @@ enum {
 	TCA_CODEL_LIMIT,
 	TCA_CODEL_INTERVAL,
 	TCA_CODEL_ECN,
+	TCA_CODEL_CE_THRESHOLD,
 	__TCA_CODEL_MAX
 };
 
@@ -695,6 +696,7 @@ struct tc_codel_xstats {
 	__u32	drop_overlimit; /* number of time max qdisc packet limit was hit */
 	__u32	ecn_mark;  /* number of packets we ECN marked instead of dropped */
 	__u32	dropping;  /* are we in dropping state ? */
+	__u32	ce_mark;   /* number of CE marked packets because of ce_threshold */
 };
 
 /* FQ_CODEL */
@@ -707,6 +709,7 @@ enum {
 	TCA_FQ_CODEL_ECN,
 	TCA_FQ_CODEL_FLOWS,
 	TCA_FQ_CODEL_QUANTUM,
+	TCA_FQ_CODEL_CE_THRESHOLD,
 	__TCA_FQ_CODEL_MAX
 };
 
@@ -730,6 +733,7 @@ struct tc_fq_codel_qd_stats {
 				 */
 	__u32	new_flows_len;	/* count of flows in new list */
 	__u32	old_flows_len;	/* count of flows in old list */
+	__u32	ce_mark;	/* packets above ce_threshold */
 };
 
 struct tc_fq_codel_cl_stats {
diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index de28f8e968e8176ac7630a1e6fcccb45ad295f5d..1474b6560facb48ed15cd159f697280495f44a75 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -6,7 +6,7 @@
  *
  *  Implemented on linux by :
  *  Copyright (C) 2012 Michael D. Taht <dave.taht@bufferbloat.net>
- *  Copyright (C) 2012 Eric Dumazet <edumazet@google.com>
+ *  Copyright (C) 2012,2015 Eric Dumazet <edumazet@google.com>
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions
@@ -109,6 +109,7 @@ static const struct nla_policy codel_policy[TCA_CODEL_MAX + 1] = {
 	[TCA_CODEL_LIMIT]	= { .type = NLA_U32 },
 	[TCA_CODEL_INTERVAL]	= { .type = NLA_U32 },
 	[TCA_CODEL_ECN]		= { .type = NLA_U32 },
+	[TCA_CODEL_CE_THRESHOLD]= { .type = NLA_U32 },
 };
 
 static int codel_change(struct Qdisc *sch, struct nlattr *opt)
@@ -133,6 +134,12 @@ static int codel_change(struct Qdisc *sch, struct nlattr *opt)
 		q->params.target = ((u64)target * NSEC_PER_USEC) >> CODEL_SHIFT;
 	}
 
+	if (tb[TCA_CODEL_CE_THRESHOLD]) {
+		u64 val = nla_get_u32(tb[TCA_CODEL_CE_THRESHOLD]);
+
+		q->params.ce_threshold = (val * NSEC_PER_USEC) >> CODEL_SHIFT;
+	}
+
 	if (tb[TCA_CODEL_INTERVAL]) {
 		u32 interval = nla_get_u32(tb[TCA_CODEL_INTERVAL]);
 
@@ -201,7 +208,10 @@ static int codel_dump(struct Qdisc *sch, struct sk_buff *skb)
 	    nla_put_u32(skb, TCA_CODEL_ECN,
 			q->params.ecn))
 		goto nla_put_failure;
-
+	if (q->params.ce_threshold != CODEL_DISABLED_THRESHOLD &&
+	    nla_put_u32(skb, TCA_CODEL_CE_THRESHOLD,
+			codel_time_to_us(q->params.ce_threshold)))
+		goto nla_put_failure;
 	return nla_nest_end(skb, opts);
 
 nla_put_failure:
@@ -220,6 +230,7 @@ static int codel_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 		.ldelay		= codel_time_to_us(q->vars.ldelay),
 		.dropping	= q->vars.dropping,
 		.ecn_mark	= q->stats.ecn_mark,
+		.ce_mark	= q->stats.ce_mark,
 	};
 
 	if (q->vars.dropping) {
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index a6fc53d69513baa3578e6b73a7947ae1dee8ee0c..367af033f6b5a4978a166692d7a21c9b6740ccf2 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -6,7 +6,7 @@
  *	as published by the Free Software Foundation; either version
  *	2 of the License, or (at your option) any later version.
  *
- *  Copyright (C) 2012 Eric Dumazet <edumazet@google.com>
+ *  Copyright (C) 2012,2015 Eric Dumazet <edumazet@google.com>
  */
 
 #include <linux/module.h>
@@ -292,6 +292,7 @@ static const struct nla_policy fq_codel_policy[TCA_FQ_CODEL_MAX + 1] = {
 	[TCA_FQ_CODEL_ECN]	= { .type = NLA_U32 },
 	[TCA_FQ_CODEL_FLOWS]	= { .type = NLA_U32 },
 	[TCA_FQ_CODEL_QUANTUM]	= { .type = NLA_U32 },
+	[TCA_FQ_CODEL_CE_THRESHOLD] = { .type = NLA_U32 },
 };
 
 static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
@@ -322,6 +323,12 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
 		q->cparams.target = (target * NSEC_PER_USEC) >> CODEL_SHIFT;
 	}
 
+	if (tb[TCA_FQ_CODEL_CE_THRESHOLD]) {
+		u64 val = nla_get_u32(tb[TCA_FQ_CODEL_CE_THRESHOLD]);
+
+		q->cparams.ce_threshold = (val * NSEC_PER_USEC) >> CODEL_SHIFT;
+	}
+
 	if (tb[TCA_FQ_CODEL_INTERVAL]) {
 		u64 interval = nla_get_u32(tb[TCA_FQ_CODEL_INTERVAL]);
 
@@ -441,6 +448,11 @@ static int fq_codel_dump(struct Qdisc *sch, struct sk_buff *skb)
 			q->flows_cnt))
 		goto nla_put_failure;
 
+	if (q->cparams.ce_threshold != CODEL_DISABLED_THRESHOLD &&
+	    nla_put_u32(skb, TCA_FQ_CODEL_CE_THRESHOLD,
+			codel_time_to_us(q->cparams.ce_threshold)))
+		goto nla_put_failure;
+
 	return nla_nest_end(skb, opts);
 
 nla_put_failure:
@@ -459,7 +471,8 @@ static int fq_codel_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 	st.qdisc_stats.drop_overlimit = q->drop_overlimit;
 	st.qdisc_stats.ecn_mark = q->cstats.ecn_mark;
 	st.qdisc_stats.new_flow_count = q->new_flow_count;
-
+	st.qdisc_stats.ce_mark = q->cstats.ce_mark;
+	
 	list_for_each(pos, &q->new_flows)
 		st.qdisc_stats.new_flows_len++;
 
