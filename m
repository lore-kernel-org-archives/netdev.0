From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] htb: reorder struct htb_class fields for
 performance
Date: Thu, 13 Jun 2013 07:58:30 -0700
Message-ID: <1371135510.3252.109.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:51691 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755447Ab3FMO6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 10:58:34 -0400
Received: by mail-ee0-f52.google.com with SMTP id c50so5241294eek.11
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 07:58:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

htb_class structures are big, and source of false sharing on SMP.

By carefully splitting them in two parts, we can improve performance.

I got 9 % performance increase on a 24 threads machine, with 200
concurrent netperf in TCP_RR mode, using a HTB hierarchy of 4 classes.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com> 
---
 net/sched/sch_htb.c |   62 ++++++++++++++++++++++--------------------
 1 file changed, 33 insertions(+), 29 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 1a3655a..7954e73 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -76,23 +76,39 @@ enum htb_cmode {
 	HTB_CAN_SEND		/* class can send */
 };
 
-/* interior & leaf nodes; props specific to leaves are marked L: */
+/* interior & leaf nodes; props specific to leaves are marked L:
+ * To reduce false sharing, place mostly read fields at beginning,
+ * and mostly written ones at the end.
+ */
 struct htb_class {
 	struct Qdisc_class_common common;
-	/* general class parameters */
-	struct gnet_stats_basic_packed bstats;
-	struct gnet_stats_queue qstats;
+	struct psched_ratecfg	rate;
+	struct psched_ratecfg	ceil;
+	s64			buffer, cbuffer;/* token bucket depth/rate */
+	s64			mbuffer;	/* max wait time */
+	int			prio;		/* these two are used only by leaves... */
+	int			quantum;	/* but stored for parent-to-leaf return */
+
+	struct tcf_proto	*filter_list;	/* class attached filters */
+	int			filter_cnt;
+	int			refcnt;		/* usage count of this class */
+
+	int			level;		/* our level (see above) */
+	unsigned int		children;
+	struct htb_class	*parent;	/* parent class */
+
 	struct gnet_stats_rate_est64 rate_est;
-	struct tc_htb_xstats xstats;	/* our special stats */
-	int refcnt;		/* usage count of this class */
 
-	/* topology */
-	int level;		/* our level (see above) */
-	unsigned int children;
-	struct htb_class *parent;	/* parent class */
+	/*
+	 * Written often fields
+	 */
+	struct gnet_stats_basic_packed bstats;
+	struct gnet_stats_queue	qstats;
+	struct tc_htb_xstats	xstats;	/* our special stats */
 
-	int prio;		/* these two are used only by leaves... */
-	int quantum;		/* but stored for parent-to-leaf return */
+	/* token bucket parameters */
+	s64			tokens, ctokens;/* current number of tokens */
+	s64			t_c;		/* checkpoint time */
 
 	union {
 		struct htb_class_leaf {
@@ -111,24 +127,12 @@ struct htb_class {
 			u32 last_ptr_id[TC_HTB_NUMPRIO];
 		} inner;
 	} un;
-	struct rb_node node[TC_HTB_NUMPRIO];	/* node for self or feed tree */
-	struct rb_node pq_node;	/* node for event queue */
-	s64	pq_key;
-
-	int prio_activity;	/* for which prios are we active */
-	enum htb_cmode cmode;	/* current mode of the class */
+	s64			pq_key;
 
-	/* class attached filters */
-	struct tcf_proto *filter_list;
-	int filter_cnt;
-
-	/* token bucket parameters */
-	struct psched_ratecfg rate;
-	struct psched_ratecfg ceil;
-	s64	buffer, cbuffer;	/* token bucket depth/rate */
-	s64	mbuffer;		/* max wait time */
-	s64	tokens, ctokens;	/* current number of tokens */
-	s64	t_c;			/* checkpoint time */
+	int			prio_activity;	/* for which prios are we active */
+	enum htb_cmode		cmode;		/* current mode of the class */
+	struct rb_node		pq_node;	/* node for event queue */
+	struct rb_node		node[TC_HTB_NUMPRIO];	/* node for self or feed tree */
 };
 
 struct htb_sched {
