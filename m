From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2] pkt_sched: fq: warn users using defrate
Date: Fri, 15 Nov 2013 08:57:26 -0800
Message-ID: <1384534646.28716.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:42172 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab3KOQ5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 11:57:48 -0500
Received: by mail-pb0-f45.google.com with SMTP id mc8so3826729pbc.4
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 08:57:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 7eec4174ff29 ("pkt_sched: fq: fix non TCP flows pacing")
obsoleted TCA_FQ_FLOW_DEFAULT_RATE without notice for the users.

Suggested by David Miller

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/pkt_sched.h |    4 +---
 net/sched/sch_fq.c             |   10 ++++------
 2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 307f293477e8..885001b62c83 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -763,9 +763,7 @@ enum {
 
 	TCA_FQ_RATE_ENABLE,	/* enable/disable rate limiting */
 
-	TCA_FQ_FLOW_DEFAULT_RATE,/* for sockets with unspecified sk_rate,
-				  * use the following rate
-				  */
+	TCA_FQ_FLOW_DEFAULT_RATE,/* obsolete, do not use */
 
 	TCA_FQ_FLOW_MAX_RATE,	/* per flow max rate */
 
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index d4fa38e4af80..26906ab51c52 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -88,7 +88,6 @@ struct fq_sched_data {
 	struct fq_flow	internal;	/* for non classified or high prio packets */
 	u32		quantum;
 	u32		initial_quantum;
-	u32		flow_default_rate;/* rate per flow : bytes per second */
 	u32		flow_max_rate;	/* optional max rate per flow */
 	u32		flow_plimit;	/* max packets per flow */
 	struct rb_root	*fq_root;
@@ -650,7 +649,8 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 		q->initial_quantum = nla_get_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
 
 	if (tb[TCA_FQ_FLOW_DEFAULT_RATE])
-		q->flow_default_rate = nla_get_u32(tb[TCA_FQ_FLOW_DEFAULT_RATE]);
+		pr_warn_ratelimited("sch_fq: defrate %u ignored.\n",
+				    nla_get_u32(tb[TCA_FQ_FLOW_DEFAULT_RATE]));
 
 	if (tb[TCA_FQ_FLOW_MAX_RATE])
 		q->flow_max_rate = nla_get_u32(tb[TCA_FQ_FLOW_MAX_RATE]);
@@ -699,7 +699,6 @@ static int fq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->flow_plimit		= 100;
 	q->quantum		= 2 * psched_mtu(qdisc_dev(sch));
 	q->initial_quantum	= 10 * psched_mtu(qdisc_dev(sch));
-	q->flow_default_rate	= 0;
 	q->flow_max_rate	= ~0U;
 	q->rate_enable		= 1;
 	q->new_flows.first	= NULL;
@@ -726,9 +725,8 @@ static int fq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (opts == NULL)
 		goto nla_put_failure;
 
-	/* TCA_FQ_FLOW_DEFAULT_RATE is not used anymore,
-	 * do not bother giving its value
-	 */
+	/* TCA_FQ_FLOW_DEFAULT_RATE is not used anymore */
+
 	if (nla_put_u32(skb, TCA_FQ_PLIMIT, sch->limit) ||
 	    nla_put_u32(skb, TCA_FQ_FLOW_PLIMIT, q->flow_plimit) ||
 	    nla_put_u32(skb, TCA_FQ_QUANTUM, q->quantum) ||
