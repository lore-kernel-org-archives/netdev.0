From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net_sched: htb: do not mix 1ns and 64ns time units
Date: Tue, 04 Jun 2013 10:11:48 -0700
Message-ID: <1370365908.24311.222.camel@edumazet-glaptop>
References: <20130529151330.22c5c89e@redhat.com>
	 <20130604141342.00c8eb9f@redhat.com>
	 <1370359133.24311.208.camel@edumazet-glaptop>
	 <1370361306.24311.214.camel@edumazet-glaptop>
	 <1370361727.24311.215.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Jiri Benc <jbenc@redhat.com>, David Miller <davem@redhat.com>,
	j.vimal@gmail.com, Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	bloat@lists.bufferbloat.net, Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35090 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757488Ab3FDRLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 13:11:51 -0400
Received: by mail-pd0-f178.google.com with SMTP id w16so532211pde.23
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 10:11:50 -0700 (PDT)
In-Reply-To: <1370361727.24311.215.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 56b765b79 ("htb: improved accuracy at high rates") added another
regression for low rates, because it mixes 1ns and 64ns time units.

So the maximum delay (mbuffer) was not 60 second, but 937 ms.

Lets convert all time fields to 1ns as 64bit arches are becoming the
norm.

Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_htb.c |   34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 79b1876..e58b738 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -109,7 +109,7 @@ struct htb_class {
 	} un;
 	struct rb_node node[TC_HTB_NUMPRIO];	/* node for self or feed tree */
 	struct rb_node pq_node;	/* node for event queue */
-	psched_time_t pq_key;
+	s64	pq_key;
 
 	int prio_activity;	/* for which prios are we active */
 	enum htb_cmode cmode;	/* current mode of the class */
@@ -121,10 +121,10 @@ struct htb_class {
 	/* token bucket parameters */
 	struct psched_ratecfg rate;
 	struct psched_ratecfg ceil;
-	s64 buffer, cbuffer;	/* token bucket depth/rate */
-	psched_tdiff_t mbuffer;	/* max wait time */
-	s64 tokens, ctokens;	/* current number of tokens */
-	psched_time_t t_c;	/* checkpoint time */
+	s64	buffer, cbuffer;	/* token bucket depth/rate */
+	s64	mbuffer;		/* max wait time */
+	s64	tokens, ctokens;	/* current number of tokens */
+	s64	t_c;			/* checkpoint time */
 };
 
 struct htb_sched {
@@ -141,15 +141,15 @@ struct htb_sched {
 	struct rb_root wait_pq[TC_HTB_MAXDEPTH];
 
 	/* time of nearest event per level (row) */
-	psched_time_t near_ev_cache[TC_HTB_MAXDEPTH];
+	s64	near_ev_cache[TC_HTB_MAXDEPTH];
 
 	int defcls;		/* class where unclassified flows go to */
 
 	/* filters for qdisc itself */
 	struct tcf_proto *filter_list;
 
-	int rate2quantum;	/* quant = rate / rate2quantum */
-	psched_time_t now;	/* cached dequeue time */
+	int	rate2quantum;	/* quant = rate / rate2quantum */
+	s64	now;	/* cached dequeue time */
 	struct qdisc_watchdog watchdog;
 
 	/* non shaped skbs; let them go directly thru */
@@ -664,8 +664,8 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
  * next pending event (0 for no event in pq, q->now for too many events).
  * Note: Applied are events whose have cl->pq_key <= q->now.
  */
-static psched_time_t htb_do_events(struct htb_sched *q, int level,
-				   unsigned long start)
+static s64 htb_do_events(struct htb_sched *q, int level,
+			 unsigned long start)
 {
 	/* don't run for longer than 2 jiffies; 2 is used instead of
 	 * 1 to simplify things when jiffy is going to be incremented
@@ -857,7 +857,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 	struct sk_buff *skb;
 	struct htb_sched *q = qdisc_priv(sch);
 	int level;
-	psched_time_t next_event;
+	s64 next_event;
 	unsigned long start_at;
 
 	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
@@ -880,7 +880,7 @@ ok:
 	for (level = 0; level < TC_HTB_MAXDEPTH; level++) {
 		/* common case optimization - skip event handler quickly */
 		int m;
-		psched_time_t event;
+		s64 event;
 
 		if (q->now >= q->near_ev_cache[level]) {
 			event = htb_do_events(q, level, start_at);
@@ -1117,8 +1117,8 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 
 	if (!cl->level && cl->un.leaf.q)
 		cl->qstats.qlen = cl->un.leaf.q->q.qlen;
-	cl->xstats.tokens = cl->tokens;
-	cl->xstats.ctokens = cl->ctokens;
+	cl->xstats.tokens = PSCHED_NS2TICKS(cl->tokens);
+	cl->xstats.ctokens = PSCHED_NS2TICKS(cl->ctokens);
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
@@ -1200,7 +1200,7 @@ static void htb_parent_to_leaf(struct htb_sched *q, struct htb_class *cl,
 	parent->un.leaf.q = new_q ? new_q : &noop_qdisc;
 	parent->tokens = parent->buffer;
 	parent->ctokens = parent->cbuffer;
-	parent->t_c = psched_get_time();
+	parent->t_c = ktime_to_ns(ktime_get());
 	parent->cmode = HTB_CAN_SEND;
 }
 
@@ -1417,8 +1417,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		/* set class to be in HTB_CAN_SEND state */
 		cl->tokens = PSCHED_TICKS2NS(hopt->buffer);
 		cl->ctokens = PSCHED_TICKS2NS(hopt->cbuffer);
-		cl->mbuffer = 60 * PSCHED_TICKS_PER_SEC;	/* 1min */
-		cl->t_c = psched_get_time();
+		cl->mbuffer = 60ULL * NSEC_PER_SEC;	/* 1min */
+		cl->t_c = ktime_to_ns(ktime_get());
 		cl->cmode = HTB_CAN_SEND;
 
 		/* attach to the hash list and parent's family */
