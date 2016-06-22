From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/4] net_sched: sch_htb: export class backlog in dumps
Date: Tue, 21 Jun 2016 23:16:51 -0700
Message-ID: <1466576212-15012-4-git-send-email-edumazet@google.com>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36251 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbcFVHUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 03:20:24 -0400
Received: by mail-pf0-f178.google.com with SMTP id t190so14984150pfb.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 00:20:23 -0700 (PDT)
In-Reply-To: <1466576212-15012-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already get child qdisc qlen, we also can get its backlog
so that class dumps can report it.

Also replace qstats by a single drop counter, but move it in
a separate cache line so that drops do not dirty useful cache lines.

Tested:

$ tc -s cl sh dev eth0
class htb 1:1 root leaf 3: prio 0 rate 1Gbit ceil 1Gbit burst 500000b cburst 500000b
 Sent 2183346912 bytes 9021815 pkt (dropped 2340774, overlimits 0 requeues 0)
 rate 1001Mbit 517543pps backlog 120758b 499p requeues 0
 lended: 9021770 borrowed: 0 giants: 0
 tokens: 9 ctokens: 9

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_htb.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index f3882259c385..ba098f2654b4 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -117,7 +117,6 @@ struct htb_class {
 	 * Written often fields
 	 */
 	struct gnet_stats_basic_packed bstats;
-	struct gnet_stats_queue	qstats;
 	struct tc_htb_xstats	xstats;	/* our special stats */
 
 	/* token bucket parameters */
@@ -140,6 +139,8 @@ struct htb_class {
 	enum htb_cmode		cmode;		/* current mode of the class */
 	struct rb_node		pq_node;	/* node for event queue */
 	struct rb_node		node[TC_HTB_NUMPRIO];	/* node for self or feed tree */
+
+	unsigned int drops ____cacheline_aligned_in_smp;
 };
 
 struct htb_level {
@@ -595,7 +596,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 					to_free)) != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(ret)) {
 			qdisc_qstats_drop(sch);
-			cl->qstats.drops++;
+			cl->drops++;
 		}
 		return ret;
 	} else {
@@ -1110,17 +1111,22 @@ static int
 htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
+	struct gnet_stats_queue qs = {
+		.drops = cl->drops,
+	};
 	__u32 qlen = 0;
 
-	if (!cl->level && cl->un.leaf.q)
+	if (!cl->level && cl->un.leaf.q) {
 		qlen = cl->un.leaf.q->q.qlen;
+		qs.backlog = cl->un.leaf.q->qstats.backlog;
+	}
 	cl->xstats.tokens = PSCHED_NS2TICKS(cl->tokens);
 	cl->xstats.ctokens = PSCHED_NS2TICKS(cl->ctokens);
 
 	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
 				  d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, NULL, &cl->qstats, qlen) < 0)
+	    gnet_stats_copy_queue(d, NULL, &qs, qlen) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &cl->xstats, sizeof(cl->xstats));
-- 
2.8.0.rc3.226.g39d4020
