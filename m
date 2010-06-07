From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v2] pkt_sched: gen_estimator: kill est_lock
 rwlock
Date: Mon, 07 Jun 2010 18:56:01 +0200
Message-ID: <1275929761.2545.159.camel@edumazet-laptop>
References: <1275921171.2545.102.camel@edumazet-laptop>
	 <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	 <1275924638.2545.121.camel@edumazet-laptop>
	 <1275926151.2545.126.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Changli Gao <xiaosuo@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:39889 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863Ab0FGQ4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 12:56:08 -0400
Received: by wwe15 with SMTP id 15so571998wwe.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 09:56:04 -0700 (PDT)
In-Reply-To: <1275926151.2545.126.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> For your information, bug is already there before my patch.
> 
> So this est_lock is a wrong protection, in the sense its so convoluted
> that nobody but you and me even noticed it was buggy in the first place.
> 
> (see commit 5d944c640b4 for a first patch)
> 
> 

Here is v2 of the patch.

Even if its a bug correction, I cooked it for net-next-2.6 since bug
probably never occured, and patch is too large to be sent to
net-2.6/linux-2.6 before testing.

Another bug comes from net/netfilter/xt_RATEEST.c : It apparently
calls gen_kill_estimator() / gen_new_estimator() without holding RTNL ?

So we should add another lock to protect things (est_root, elist[], ...)

David, I can send a net-2.6 patch for this one, since it should be small
enough. If yes, I'll respin this patch of course ;)

Thanks

[PATCH net-next-2.6] pkt_sched: gen_kill_estimator() rcu fixes

gen_kill_estimator() API is fundamentaly wrong, since caller should make
sure an RCU grace period is respected before freeing bstats or lock.

This was partially addressed in commit 5d944c640b4 (gen_estimator:
deadlock fix), but same problem exist for all gen_kill_estimator()
users.

Change its name to gen_kill_estimator_rcu() and change all callers to
use RCU grace period before freeing bstats container.

As a bonus, est_lock rwlock can be killed for good.

Special thanks to Changli Gao for commenting on a previous patch, this
made this bug clear to me.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/act_api.h              |    2 
 include/net/gen_stats.h            |    2 
 include/net/netfilter/xt_rateest.h |    1 
 net/core/gen_estimator.c           |   58 ++++++++++++---------------
 net/netfilter/xt_RATEEST.c         |   10 +++-
 net/sched/act_api.c                |    9 +++-
 net/sched/act_police.c             |   12 ++++-
 net/sched/sch_cbq.c                |   11 ++++-
 net/sched/sch_drr.c                |   11 ++++-
 net/sched/sch_generic.c            |    4 -
 net/sched/sch_hfsc.c               |   11 ++++-
 net/sched/sch_htb.c                |   11 ++++-
 12 files changed, 92 insertions(+), 50 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index c05fd71..bab385f 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -20,6 +20,7 @@ struct tcf_common {
 	struct gnet_stats_queue		tcfc_qstats;
 	struct gnet_stats_rate_est	tcfc_rate_est;
 	spinlock_t			tcfc_lock;
+	struct rcu_head			tcfc_rcu;
 };
 #define tcf_next	common.tcfc_next
 #define tcf_index	common.tcfc_index
@@ -32,6 +33,7 @@ struct tcf_common {
 #define tcf_qstats	common.tcfc_qstats
 #define tcf_rate_est	common.tcfc_rate_est
 #define tcf_lock	common.tcfc_lock
+#define tcf_rcu		common.tcfc_rcu
 
 struct tcf_police {
 	struct tcf_common	common;
diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index fa15771..3545696 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -40,7 +40,7 @@ extern int gnet_stats_finish_copy(struct gnet_dump *d);
 extern int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 			     struct gnet_stats_rate_est *rate_est,
 			     spinlock_t *stats_lock, struct nlattr *opt);
-extern void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
+extern void gen_kill_estimator_rcu(struct gnet_stats_basic_packed *bstats,
 			       struct gnet_stats_rate_est *rate_est);
 extern int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
 				 struct gnet_stats_rate_est *rate_est,
diff --git a/include/net/netfilter/xt_rateest.h b/include/net/netfilter/xt_rateest.h
index ddbf37e..5e14277 100644
--- a/include/net/netfilter/xt_rateest.h
+++ b/include/net/netfilter/xt_rateest.h
@@ -9,6 +9,7 @@ struct xt_rateest {
 	struct gnet_estimator		params;
 	struct gnet_stats_rate_est	rstats;
 	struct gnet_stats_basic_packed	bstats;
+	struct rcu_head			rcu;
 };
 
 extern struct xt_rateest *xt_rateest_lookup(const char *name);
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index cf8e703..bd06b4a 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -102,9 +102,6 @@ struct gen_estimator_head
 
 static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
 
-/* Protects against NULL dereference */
-static DEFINE_RWLOCK(est_lock);
-
 /* Protects against soft lockup during large deletion */
 static struct rb_root est_root = RB_ROOT;
 
@@ -115,29 +112,25 @@ static void est_timer(unsigned long arg)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(e, &elist[idx].list, list) {
-		u64 nbytes;
-		u64 brate;
-		u32 npackets;
-		u32 rate;
+		struct gnet_stats_basic_packed *bstats;
 
 		spin_lock(e->stats_lock);
-		read_lock(&est_lock);
-		if (e->bstats == NULL)
-			goto skip;
-
-		nbytes = e->bstats->bytes;
-		npackets = e->bstats->packets;
-		brate = (nbytes - e->last_bytes)<<(7 - idx);
-		e->last_bytes = nbytes;
-		e->avbps += (brate >> e->ewma_log) - (e->avbps >> e->ewma_log);
-		e->rate_est->bps = (e->avbps+0xF)>>5;
-
-		rate = (npackets - e->last_packets)<<(12 - idx);
-		e->last_packets = npackets;
-		e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
-		e->rate_est->pps = (e->avpps+0x1FF)>>10;
-skip:
-		read_unlock(&est_lock);
+		bstats = rcu_dereference(e->bstats);
+		if (bstats) {
+			u64 nbytes = ACCESS_ONCE(bstats->bytes);
+			u32 npackets = ACCESS_ONCE(bstats->packets);
+			u64 brate = (nbytes - e->last_bytes)<<(7 - idx);
+			u32 rate;
+
+			e->last_bytes = nbytes;
+			e->avbps += (brate >> e->ewma_log) - (e->avbps >> e->ewma_log);
+			e->rate_est->bps = (e->avbps+0xF)>>5;
+
+			rate = (npackets - e->last_packets)<<(12 - idx);
+			e->last_packets = npackets;
+			e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
+			e->rate_est->pps = (e->avpps+0x1FF)>>10;
+		}
 		spin_unlock(e->stats_lock);
 	}
 
@@ -255,15 +248,18 @@ static void __gen_kill_estimator(struct rcu_head *head)
 }
 
 /**
- * gen_kill_estimator - remove a rate estimator
+ * gen_kill_estimator_rcu - remove a rate estimator
  * @bstats: basic statistics
  * @rate_est: rate estimator statistics
  *
  * Removes the rate estimator specified by &bstats and &rate_est.
  *
- * NOTE: Called under rtnl_mutex
+ * NOTES:
+ *	Called under rtnl_mutex
+ *	Because est_timer() requirements (RCU protection), caller
+ *	should respect an RCU grace period before freeing bstats
  */
-void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
+void gen_kill_estimator_rcu(struct gnet_stats_basic_packed *bstats,
 			struct gnet_stats_rate_est *rate_est)
 {
 	struct gen_estimator *e;
@@ -271,15 +267,13 @@ void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
 	while ((e = gen_find_node(bstats, rate_est))) {
 		rb_erase(&e->node, &est_root);
 
-		write_lock_bh(&est_lock);
-		e->bstats = NULL;
-		write_unlock_bh(&est_lock);
+		rcu_assign_pointer(e->bstats, NULL);
 
 		list_del_rcu(&e->list);
 		call_rcu(&e->e_rcu, __gen_kill_estimator);
 	}
 }
-EXPORT_SYMBOL(gen_kill_estimator);
+EXPORT_SYMBOL(gen_kill_estimator_rcu);
 
 /**
  * gen_replace_estimator - replace rate estimator configuration
@@ -297,7 +291,7 @@ int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
 			  struct gnet_stats_rate_est *rate_est,
 			  spinlock_t *stats_lock, struct nlattr *opt)
 {
-	gen_kill_estimator(bstats, rate_est);
+	gen_kill_estimator_rcu(bstats, rate_est);
 	return gen_new_estimator(bstats, rate_est, stats_lock, opt);
 }
 EXPORT_SYMBOL(gen_replace_estimator);
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 69c01e1..55747cd 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -60,13 +60,18 @@ struct xt_rateest *xt_rateest_lookup(const char *name)
 }
 EXPORT_SYMBOL_GPL(xt_rateest_lookup);
 
+static void xt_rateeset_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct xt_rateest, rcu));
+}
+
 void xt_rateest_put(struct xt_rateest *est)
 {
 	mutex_lock(&xt_rateest_mutex);
 	if (--est->refcnt == 0) {
 		hlist_del(&est->list);
-		gen_kill_estimator(&est->bstats, &est->rstats);
-		kfree(est);
+		gen_kill_estimator_rcu(&est->bstats, &est->rstats);
+		call_rcu(&est->rcu, xt_rateeset_free_rcu);
 	}
 	mutex_unlock(&xt_rateest_mutex);
 }
@@ -179,6 +184,7 @@ static int __init xt_rateest_tg_init(void)
 static void __exit xt_rateest_tg_fini(void)
 {
 	xt_unregister_target(&xt_rateest_tg_reg);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 972378f..597b260 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -26,6 +26,11 @@
 #include <net/act_api.h>
 #include <net/netlink.h>
 
+static void tcf_common_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct tcf_common, tcfc_rcu));
+}
+
 void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 {
 	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
@@ -36,9 +41,9 @@ void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 			write_lock_bh(hinfo->lock);
 			*p1p = p->tcfc_next;
 			write_unlock_bh(hinfo->lock);
-			gen_kill_estimator(&p->tcfc_bstats,
+			gen_kill_estimator_rcu(&p->tcfc_bstats,
 					   &p->tcfc_rate_est);
-			kfree(p);
+			call_rcu(&p->tcfc_rcu, tcf_common_free_rcu);
 			return;
 		}
 	}
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 654f73d..c3afcba 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -97,6 +97,11 @@ nla_put_failure:
 	goto done;
 }
 
+static void tcf_police_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct tcf_police, tcf_rcu));
+}
+
 static void tcf_police_destroy(struct tcf_police *p)
 {
 	unsigned int h = tcf_hash(p->tcf_index, POL_TAB_MASK);
@@ -107,13 +112,13 @@ static void tcf_police_destroy(struct tcf_police *p)
 			write_lock_bh(&police_lock);
 			*p1p = p->tcf_next;
 			write_unlock_bh(&police_lock);
-			gen_kill_estimator(&p->tcf_bstats,
-					   &p->tcf_rate_est);
+			gen_kill_estimator_rcu(&p->tcf_bstats,
+					       &p->tcf_rate_est);
 			if (p->tcfp_R_tab)
 				qdisc_put_rtab(p->tcfp_R_tab);
 			if (p->tcfp_P_tab)
 				qdisc_put_rtab(p->tcfp_P_tab);
-			kfree(p);
+			call_rcu(&p->tcf_rcu, tcf_police_free_rcu);
 			return;
 		}
 	}
@@ -397,6 +402,7 @@ static void __exit
 police_cleanup_module(void)
 {
 	tcf_unregister_action(&act_police_ops);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 module_init(police_init_module);
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 28c01ef..d61b3b3 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -140,6 +140,7 @@ struct cbq_class
 	int			filters;
 
 	struct cbq_class 	*defaults[TC_PRIO_MAX+1];
+	struct rcu_head		rcu;
 };
 
 struct cbq_sched_data
@@ -1671,6 +1672,11 @@ static unsigned long cbq_get(struct Qdisc *sch, u32 classid)
 	return 0;
 }
 
+static void cbq_class_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct cbq_class, rcu));
+}
+
 static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
@@ -1680,9 +1686,9 @@ static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 	tcf_destroy_chain(&cl->filter_list);
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator_rcu(&cl->bstats, &cl->rate_est);
 	if (cl != &q->link)
-		kfree(cl);
+		call_rcu(&cl->rcu, cbq_class_free_rcu);
 }
 
 static void
@@ -2066,6 +2072,7 @@ static int __init cbq_module_init(void)
 static void __exit cbq_module_exit(void)
 {
 	unregister_qdisc(&cbq_qdisc_ops);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 module_init(cbq_module_init)
 module_exit(cbq_module_exit)
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index b74046a..f0d5aae 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -31,6 +31,7 @@ struct drr_class {
 
 	u32				quantum;
 	u32				deficit;
+	struct rcu_head			rcu;
 };
 
 struct drr_sched {
@@ -136,11 +137,16 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	return 0;
 }
 
+static void drr_class_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct drr_class, rcu));
+}
+
 static void drr_destroy_class(struct Qdisc *sch, struct drr_class *cl)
 {
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator_rcu(&cl->bstats, &cl->rate_est);
 	qdisc_destroy(cl->qdisc);
-	kfree(cl);
+	call_rcu(&cl->rcu, drr_class_free_rcu);
 }
 
 static int drr_delete_class(struct Qdisc *sch, unsigned long arg)
@@ -522,6 +528,7 @@ static int __init drr_init(void)
 static void __exit drr_exit(void)
 {
 	unregister_qdisc(&drr_qdisc_ops);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 module_init(drr_init);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index d20fcd2..22120d4 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -632,7 +632,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 
 	qdisc_put_stab(qdisc->stab);
 #endif
-	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
+	gen_kill_estimator_rcu(&qdisc->bstats, &qdisc->rate_est);
 	if (ops->reset)
 		ops->reset(qdisc);
 	if (ops->destroy)
@@ -643,7 +643,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 
 	kfree_skb(qdisc->gso_skb);
 	/*
-	 * gen_estimator est_timer() might access qdisc->q.lock,
+	 * gen_estimator est_timer() might access qdisc->q.lock or bstats
 	 * wait a RCU grace period before freeing qdisc.
 	 */
 	call_rcu(&qdisc->rcu_head, qdisc_rcu_free);
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index abd904b..c433aa8 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -174,6 +174,7 @@ struct hfsc_class
 	unsigned long	cl_vtperiod;	/* vt period sequence number */
 	unsigned long	cl_parentperiod;/* parent's vt period sequence number*/
 	unsigned long	cl_nactive;	/* number of active children */
+	struct rcu_head rcu;
 };
 
 struct hfsc_sched
@@ -1111,6 +1112,11 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	return 0;
 }
 
+static void hfsc_class_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct hfsc_class, rcu));
+}
+
 static void
 hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 {
@@ -1118,9 +1124,9 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 
 	tcf_destroy_chain(&cl->filter_list);
 	qdisc_destroy(cl->qdisc);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator_rcu(&cl->bstats, &cl->rate_est);
 	if (cl != &q->root)
-		kfree(cl);
+		call_rcu(&cl->rcu, hfsc_class_free_rcu);
 }
 
 static int
@@ -1742,6 +1748,7 @@ static void __exit
 hfsc_cleanup(void)
 {
 	unregister_qdisc(&hfsc_qdisc_ops);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 MODULE_LICENSE("GPL");
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0b52b8d..b7b5e29 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -123,6 +123,7 @@ struct htb_class {
 	psched_tdiff_t mbuffer;	/* max wait time */
 	long tokens, ctokens;	/* current number of tokens */
 	psched_time_t t_c;	/* checkpoint time */
+	struct rcu_head rcu;
 };
 
 struct htb_sched {
@@ -1190,18 +1191,23 @@ static void htb_parent_to_leaf(struct htb_sched *q, struct htb_class *cl,
 	parent->cmode = HTB_CAN_SEND;
 }
 
+static void htb_class_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct htb_class, rcu));
+}
+
 static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 {
 	if (!cl->level) {
 		WARN_ON(!cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
 	}
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator_rcu(&cl->bstats, &cl->rate_est);
 	qdisc_put_rtab(cl->rate);
 	qdisc_put_rtab(cl->ceil);
 
 	tcf_destroy_chain(&cl->filter_list);
-	kfree(cl);
+	call_rcu(&cl->rcu, htb_class_free_rcu);
 }
 
 static void htb_destroy(struct Qdisc *sch)
@@ -1573,6 +1579,7 @@ static int __init htb_module_init(void)
 static void __exit htb_module_exit(void)
 {
 	unregister_qdisc(&htb_qdisc_ops);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 module_init(htb_module_init)


