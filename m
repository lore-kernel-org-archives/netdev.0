From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_red: generalize accurate MAX_P support to
 RED/GRED/CHOKE
Date: Fri, 09 Dec 2011 13:46:45 +0100
Message-ID: <1323434805.2336.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
	 <1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1323360363.2521.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111208092130.656c39ff@nehalam.linuxnetplumber.net>
	 <1323368188.2529.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:55370 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753378Ab1LIMqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 07:46:51 -0500
Received: by lagp5 with SMTP id p5so1102300lag.19
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2011 04:46:49 -0800 (PST)
In-Reply-To: <1323368188.2529.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now RED uses a Q0.32 number to store max_p (max probability), allow
RED/GRED/CHOKE to use/report full resolution at config/dump time.

Old tc binaries are non aware of new attributes, and still set/get Plog.

New tc binary set/get both Plog and max_p for backward compatibility,
they display "probability value" if they get max_p from new kernels.

# tc -d  qdisc show dev ...
...
qdisc red 10: parent 1:1 limit 360Kb min 30Kb max 90Kb ecn ewma 5
probability 0.09 Scell_log 15

Make sure we avoid potential divides by 0 in reciprocal_value(), if
(max_th - min_th) is big.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/pkt_sched.h |    2 ++
 include/net/red.h         |   16 +++++++++++-----
 net/sched/sch_choke.c     |    8 +++++++-
 net/sched/sch_gred.c      |   22 ++++++++++++++++++----
 net/sched/sch_red.c       |    9 +++++++--
 5 files changed, 45 insertions(+), 12 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index e41e0d4..8786ea7 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -216,6 +216,7 @@ enum {
        TCA_GRED_PARMS,
        TCA_GRED_STAB,
        TCA_GRED_DPS,
+       TCA_GRED_MAX_P,
 	   __TCA_GRED_MAX,
 };
 
@@ -255,6 +256,7 @@ enum {
 	TCA_CHOKE_UNSPEC,
 	TCA_CHOKE_PARMS,
 	TCA_CHOKE_STAB,
+	TCA_CHOKE_MAX_P,
 	__TCA_CHOKE_MAX,
 };
 
diff --git a/include/net/red.h b/include/net/red.h
index 24606b2..ef715a1 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -155,9 +155,10 @@ static inline u32 red_maxp(u8 Plog)
 
 static inline void red_set_parms(struct red_parms *p,
 				 u32 qth_min, u32 qth_max, u8 Wlog, u8 Plog,
-				 u8 Scell_log, u8 *stab)
+				 u8 Scell_log, u8 *stab, u32 max_P)
 {
 	int delta = qth_max - qth_min;
+	u32 max_p_delta;
 
 	/* Reset average queue length, the value is strictly bound
 	 * to the parameters below, reseting hurts a bit but leaving
@@ -173,10 +174,14 @@ static inline void red_set_parms(struct red_parms *p,
 	if (delta < 0)
 		delta = 1;
 	p->qth_delta	= delta;
-	p->max_P	= red_maxp(Plog);
-	p->max_P	*= delta; /* max_P = (qth_max-qth_min)/2^Plog */
-
-	p->max_P_reciprocal  = reciprocal_value(p->max_P / delta);
+	if (!max_P) {
+		max_P = red_maxp(Plog);
+		max_P *= delta; /* max_P = (qth_max - qth_min)/2^Plog */
+	}
+	p->max_P = max_P;
+	max_p_delta = max_P / delta;
+	max_p_delta = max(max_p_delta, 1U);
+	p->max_P_reciprocal  = reciprocal_value(max_p_delta);
 
 	/* RED Adaptative target :
 	 * [min_th + 0.4*(min_th - max_th),
@@ -380,6 +385,7 @@ static inline void red_adaptative_algo(struct red_parms *p)
 		p->max_P = (p->max_P/10)*9; /* maxp = maxp * Beta */
 
 	max_p_delta = DIV_ROUND_CLOSEST(p->max_P, p->qth_delta);
+	max_p_delta = max(max_p_delta, 1U);
 	p->max_P_reciprocal = reciprocal_value(max_p_delta);
 }
 #endif
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 205d369..bef00ac 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -394,6 +394,7 @@ static void choke_reset(struct Qdisc *sch)
 static const struct nla_policy choke_policy[TCA_CHOKE_MAX + 1] = {
 	[TCA_CHOKE_PARMS]	= { .len = sizeof(struct tc_red_qopt) },
 	[TCA_CHOKE_STAB]	= { .len = RED_STAB_SIZE },
+	[TCA_CHOKE_MAX_P]	= { .type = NLA_U32 },
 };
 
 
@@ -415,6 +416,7 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 	int err;
 	struct sk_buff **old = NULL;
 	unsigned int mask;
+	u32 max_P;
 
 	if (opt == NULL)
 		return -EINVAL;
@@ -427,6 +429,8 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 	    tb[TCA_CHOKE_STAB] == NULL)
 		return -EINVAL;
 
+	max_P = tb[TCA_CHOKE_MAX_P] ? nla_get_u32(tb[TCA_CHOKE_MAX_P]) : 0;
+
 	ctl = nla_data(tb[TCA_CHOKE_PARMS]);
 
 	if (ctl->limit > CHOKE_MAX_QUEUE)
@@ -476,7 +480,8 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 
 	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
 		      ctl->Plog, ctl->Scell_log,
-		      nla_data(tb[TCA_CHOKE_STAB]));
+		      nla_data(tb[TCA_CHOKE_STAB]),
+		      max_P);
 
 	if (q->head == q->tail)
 		red_end_of_idle_period(&q->parms);
@@ -510,6 +515,7 @@ static int choke_dump(struct Qdisc *sch, struct sk_buff *skb)
 		goto nla_put_failure;
 
 	NLA_PUT(skb, TCA_CHOKE_PARMS, sizeof(opt), &opt);
+	NLA_PUT_U32(skb, TCA_CHOKE_MAX_P, q->parms.max_P);
 	return nla_nest_end(skb, opts);
 
 nla_put_failure:
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index b9493a0..2e830c8 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -34,7 +34,7 @@ struct gred_sched;
 
 struct gred_sched_data {
 	u32		limit;		/* HARD maximal queue length	*/
-	u32      	DP;		/* the drop pramaters */
+	u32		DP;		/* the drop parameters */
 	u32		bytesin;	/* bytes seen on virtualQ so far*/
 	u32		packetsin;	/* packets seen on virtualQ so far*/
 	u32		backlog;	/* bytes on the virtualQ */
@@ -379,7 +379,8 @@ static inline int gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
 }
 
 static inline int gred_change_vq(struct Qdisc *sch, int dp,
-				 struct tc_gred_qopt *ctl, int prio, u8 *stab)
+				 struct tc_gred_qopt *ctl, int prio,
+				 u8 *stab, u32 max_P)
 {
 	struct gred_sched *table = qdisc_priv(sch);
 	struct gred_sched_data *q;
@@ -400,7 +401,7 @@ static inline int gred_change_vq(struct Qdisc *sch, int dp,
 
 	red_set_parms(&q->parms,
 		      ctl->qth_min, ctl->qth_max, ctl->Wlog, ctl->Plog,
-		      ctl->Scell_log, stab);
+		      ctl->Scell_log, stab, max_P);
 
 	return 0;
 }
@@ -409,6 +410,7 @@ static const struct nla_policy gred_policy[TCA_GRED_MAX + 1] = {
 	[TCA_GRED_PARMS]	= { .len = sizeof(struct tc_gred_qopt) },
 	[TCA_GRED_STAB]		= { .len = 256 },
 	[TCA_GRED_DPS]		= { .len = sizeof(struct tc_gred_sopt) },
+	[TCA_GRED_MAX_P]	= { .type = NLA_U32 },
 };
 
 static int gred_change(struct Qdisc *sch, struct nlattr *opt)
@@ -418,6 +420,7 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 	struct nlattr *tb[TCA_GRED_MAX + 1];
 	int err, prio = GRED_DEF_PRIO;
 	u8 *stab;
+	u32 max_P;
 
 	if (opt == NULL)
 		return -EINVAL;
@@ -433,6 +436,8 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 	    tb[TCA_GRED_STAB] == NULL)
 		return -EINVAL;
 
+	max_P = tb[TCA_GRED_MAX_P] ? nla_get_u32(tb[TCA_GRED_MAX_P]) : 0;
+
 	err = -EINVAL;
 	ctl = nla_data(tb[TCA_GRED_PARMS]);
 	stab = nla_data(tb[TCA_GRED_STAB]);
@@ -457,7 +462,7 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 
 	sch_tree_lock(sch);
 
-	err = gred_change_vq(sch, ctl->DP, ctl, prio, stab);
+	err = gred_change_vq(sch, ctl->DP, ctl, prio, stab, max_P);
 	if (err < 0)
 		goto errout_locked;
 
@@ -498,6 +503,7 @@ static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 	struct gred_sched *table = qdisc_priv(sch);
 	struct nlattr *parms, *opts = NULL;
 	int i;
+	u32 max_p[MAX_DPs];
 	struct tc_gred_sopt sopt = {
 		.DPs	= table->DPs,
 		.def_DP	= table->def,
@@ -509,6 +515,14 @@ static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (opts == NULL)
 		goto nla_put_failure;
 	NLA_PUT(skb, TCA_GRED_DPS, sizeof(sopt), &sopt);
+
+	for (i = 0; i < MAX_DPs; i++) {
+		struct gred_sched_data *q = table->tab[i];
+
+		max_p[i] = q ? q->parms.max_P : 0;
+	}
+	NLA_PUT(skb, TCA_GRED_MAX_P, sizeof(max_p), max_p);
+
 	parms = nla_nest_start(skb, TCA_GRED_PARMS);
 	if (parms == NULL)
 		goto nla_put_failure;
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 8f5a85b..ce2256a 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -170,6 +170,7 @@ static void red_destroy(struct Qdisc *sch)
 static const struct nla_policy red_policy[TCA_RED_MAX + 1] = {
 	[TCA_RED_PARMS]	= { .len = sizeof(struct tc_red_qopt) },
 	[TCA_RED_STAB]	= { .len = RED_STAB_SIZE },
+	[TCA_RED_MAX_P] = { .type = NLA_U32 },
 };
 
 static int red_change(struct Qdisc *sch, struct nlattr *opt)
@@ -179,6 +180,7 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 	struct tc_red_qopt *ctl;
 	struct Qdisc *child = NULL;
 	int err;
+	u32 max_P;
 
 	if (opt == NULL)
 		return -EINVAL;
@@ -191,6 +193,8 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 	    tb[TCA_RED_STAB] == NULL)
 		return -EINVAL;
 
+	max_P = tb[TCA_RED_MAX_P] ? nla_get_u32(tb[TCA_RED_MAX_P]) : 0;
+
 	ctl = nla_data(tb[TCA_RED_PARMS]);
 
 	if (ctl->limit > 0) {
@@ -209,8 +213,9 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 	}
 
 	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
-				 ctl->Plog, ctl->Scell_log,
-				 nla_data(tb[TCA_RED_STAB]));
+		      ctl->Plog, ctl->Scell_log,
+		      nla_data(tb[TCA_RED_STAB]),
+		      max_P);
 
 	del_timer(&q->adapt_timer);
 	if (ctl->flags & TC_RED_ADAPTATIVE)
