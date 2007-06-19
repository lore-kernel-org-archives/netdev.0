From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 02/04]: Remove unnecessary stats_lock pointers
Date: Tue, 19 Jun 2007 17:02:21 +0200 (MEST)
Message-ID: <20070619150202.30997.18717.sendpatchset@localhost.localdomain>
References: <20070619150159.30997.77256.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60158 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784AbXFSPCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 11:02:22 -0400
In-Reply-To: <20070619150159.30997.77256.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Remove unnecessary stats_lock pointers

Remove stats_lock pointers from qdisc-internal structures, in all cases
it points to dev->queue_lock. The only case where it is necessary is for
top-level qdiscs, where it might also point to dev->ingress_lock in case
of the ingress qdisc. Also remove it from actions completely, it always
points to the actions internal lock.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 00b3839a51961a8fda98d3941d0809f16be0ea59
tree 05186e615bc7af5dbe27d634972bcb71e6f10d25
parent 0f93837e26f826f49382b567ef15efe0e4995615
author Patrick McHardy <kaber@trash.net> Thu, 14 Jun 2007 16:30:09 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 14 Jun 2007 16:30:09 +0200

 include/net/act_api.h  |    2 --
 net/sched/act_api.c    |    7 +++----
 net/sched/act_police.c |    8 +++-----
 net/sched/sch_atm.c    |    1 -
 net/sched/sch_cbq.c    |    8 +++-----
 net/sched/sch_hfsc.c   |   10 +++-------
 6 files changed, 12 insertions(+), 24 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 8b06c2f..2f0273f 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -19,7 +19,6 @@ struct tcf_common {
 	struct gnet_stats_basic		tcfc_bstats;
 	struct gnet_stats_queue		tcfc_qstats;
 	struct gnet_stats_rate_est	tcfc_rate_est;
-	spinlock_t			*tcfc_stats_lock;
 	spinlock_t			tcfc_lock;
 };
 #define tcf_next	common.tcfc_next
@@ -32,7 +31,6 @@ struct tcf_common {
 #define tcf_bstats	common.tcfc_bstats
 #define tcf_qstats	common.tcfc_qstats
 #define tcf_rate_est	common.tcfc_rate_est
-#define tcf_stats_lock	common.tcfc_stats_lock
 #define tcf_lock	common.tcfc_lock
 
 struct tcf_police {
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 72bb9bd..32cc191 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -230,13 +230,12 @@ struct tcf_common *tcf_hash_create(u32 index, struct rtattr *est, struct tc_acti
 		p->tcfc_bindcnt = 1;
 
 	spin_lock_init(&p->tcfc_lock);
-	p->tcfc_stats_lock = &p->tcfc_lock;
 	p->tcfc_index = index ? index : tcf_hash_new_index(idx_gen, hinfo);
 	p->tcfc_tm.install = jiffies;
 	p->tcfc_tm.lastuse = jiffies;
 	if (est)
 		gen_new_estimator(&p->tcfc_bstats, &p->tcfc_rate_est,
-				  p->tcfc_stats_lock, est);
+				  &p->tcfc_lock, est);
 	a->priv = (void *) p;
 	return p;
 }
@@ -595,12 +594,12 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 	if (compat_mode) {
 		if (a->type == TCA_OLD_COMPAT)
 			err = gnet_stats_start_copy_compat(skb, 0,
-				TCA_STATS, TCA_XSTATS, h->tcf_stats_lock, &d);
+				TCA_STATS, TCA_XSTATS, &h->tcf_lock, &d);
 		else
 			return 0;
 	} else
 		err = gnet_stats_start_copy(skb, TCA_ACT_STATS,
-			h->tcf_stats_lock, &d);
+					    &h->tcf_lock, &d);
 
 	if (err < 0)
 		goto errout;
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 580698d..3e8716d 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -183,7 +183,6 @@ static int tcf_act_police_locate(struct rtattr *rta, struct rtattr *est,
 	ret = ACT_P_CREATED;
 	police->tcf_refcnt = 1;
 	spin_lock_init(&police->tcf_lock);
-	police->tcf_stats_lock = &police->tcf_lock;
 	if (bind)
 		police->tcf_bindcnt = 1;
 override:
@@ -231,7 +230,7 @@ override:
 	if (est)
 		gen_replace_estimator(&police->tcf_bstats,
 				      &police->tcf_rate_est,
-				      police->tcf_stats_lock, est);
+				      &police->tcf_lock, est);
 
 	spin_unlock_bh(&police->tcf_lock);
 	if (ret != ACT_P_CREATED)
@@ -450,7 +449,6 @@ struct tcf_police *tcf_police_locate(struct rtattr *rta, struct rtattr *est)
 
 	police->tcf_refcnt = 1;
 	spin_lock_init(&police->tcf_lock);
-	police->tcf_stats_lock = &police->tcf_lock;
 	if (parm->rate.rate) {
 		police->tcfp_R_tab =
 			qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE-1]);
@@ -490,7 +488,7 @@ struct tcf_police *tcf_police_locate(struct rtattr *rta, struct rtattr *est)
 	police->tcf_action = parm->action;
 	if (est)
 		gen_new_estimator(&police->tcf_bstats, &police->tcf_rate_est,
-				  police->tcf_stats_lock, est);
+				  &police->tcf_lock, est);
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
 	write_lock_bh(&police_lock);
 	police->tcf_next = tcf_police_ht[h];
@@ -591,7 +589,7 @@ int tcf_police_dump_stats(struct sk_buff *skb, struct tcf_police *police)
 	struct gnet_dump d;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
-					 TCA_XSTATS, police->tcf_stats_lock,
+					 TCA_XSTATS, &police->tcf_lock,
 					 &d) < 0)
 		goto errout;
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index d1c383f..16fe802 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -71,7 +71,6 @@ struct atm_flow_data {
 	int			ref;		/* reference count */
 	struct gnet_stats_basic	bstats;
 	struct gnet_stats_queue	qstats;
-	spinlock_t		*stats_lock;
 	struct atm_flow_data	*next;
 	struct atm_flow_data	*excess;	/* flow for excess traffic;
 						   NULL to set CLP instead */
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index bf1ea9e..b093d8f 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -148,7 +148,6 @@ struct cbq_class
 	struct gnet_stats_basic bstats;
 	struct gnet_stats_queue qstats;
 	struct gnet_stats_rate_est rate_est;
-	spinlock_t		*stats_lock;
 	struct tc_cbq_xstats	xstats;
 
 	struct tcf_proto	*filter_list;
@@ -1442,7 +1441,6 @@ static int cbq_init(struct Qdisc *sch, struct rtattr *opt)
 	q->link.ewma_log = TC_CBQ_DEF_EWMA;
 	q->link.avpkt = q->link.allot/2;
 	q->link.minidle = -0x7FFFFFFF;
-	q->link.stats_lock = &sch->dev->queue_lock;
 
 	qdisc_watchdog_init(&q->watchdog, sch);
 	hrtimer_init(&q->delay_timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
@@ -1871,7 +1869,8 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 
 		if (tca[TCA_RATE-1])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-				cl->stats_lock, tca[TCA_RATE-1]);
+					      &sch->dev->queue_lock,
+					      tca[TCA_RATE-1]);
 		return 0;
 	}
 
@@ -1929,7 +1928,6 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 	cl->allot = parent->allot;
 	cl->quantum = cl->allot;
 	cl->weight = cl->R_tab->rate.rate;
-	cl->stats_lock = &sch->dev->queue_lock;
 
 	sch_tree_lock(sch);
 	cbq_link_class(cl);
@@ -1959,7 +1957,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 
 	if (tca[TCA_RATE-1])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-			cl->stats_lock, tca[TCA_RATE-1]);
+				  &sch->dev->queue_lock, tca[TCA_RATE-1]);
 
 	*arg = (unsigned long)cl;
 	return 0;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 7ccdf63..7130a24 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -122,7 +122,6 @@ struct hfsc_class
 	struct gnet_stats_basic bstats;
 	struct gnet_stats_queue qstats;
 	struct gnet_stats_rate_est rate_est;
-	spinlock_t	*stats_lock;
 	unsigned int	level;		/* class level in hierarchy */
 	struct tcf_proto *filter_list;	/* filter list */
 	unsigned int	filter_cnt;	/* filter count */
@@ -1056,7 +1055,8 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 		if (tca[TCA_RATE-1])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-				cl->stats_lock, tca[TCA_RATE-1]);
+					      &sch->dev->queue_lock,
+					      tca[TCA_RATE-1]);
 		return 0;
 	}
 
@@ -1096,7 +1096,6 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
-	cl->stats_lock = &sch->dev->queue_lock;
 	INIT_LIST_HEAD(&cl->children);
 	cl->vt_tree = RB_ROOT;
 	cl->cf_tree = RB_ROOT;
@@ -1112,7 +1111,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (tca[TCA_RATE-1])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-			cl->stats_lock, tca[TCA_RATE-1]);
+				  &sch->dev->queue_lock, tca[TCA_RATE-1]);
 	*arg = (unsigned long)cl;
 	return 0;
 }
@@ -1440,8 +1439,6 @@ hfsc_init_qdisc(struct Qdisc *sch, struct rtattr *opt)
 		return -EINVAL;
 	qopt = RTA_DATA(opt);
 
-	sch->stats_lock = &sch->dev->queue_lock;
-
 	q->defcls = qopt->defcls;
 	for (i = 0; i < HFSC_HSIZE; i++)
 		INIT_LIST_HEAD(&q->clhash[i]);
@@ -1456,7 +1453,6 @@ hfsc_init_qdisc(struct Qdisc *sch, struct rtattr *opt)
 					  sch->handle);
 	if (q->root.qdisc == NULL)
 		q->root.qdisc = &noop_qdisc;
-	q->root.stats_lock = &sch->dev->queue_lock;
 	INIT_LIST_HEAD(&q->root.children);
 	q->root.vt_tree = RB_ROOT;
 	q->root.cf_tree = RB_ROOT;
