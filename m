From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 05/05]: Kill CONFIG_NET_CLS_POLICE
Date: Mon,  9 Jul 2007 22:46:19 +0200 (MEST)
Message-ID: <20070709204618.1461.5868.sendpatchset@localhost.localdomain>
References: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41519 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754644AbXGIUqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:46:21 -0400
In-Reply-To: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Kill CONFIG_NET_CLS_POLICE

The NET_CLS_ACT option is now a full replacement for NET_CLS_POLICE,
remove the old code. The config option will be kept around to select
the equivalent NET_CLS_ACT options for a short time to allow easier
upgrades.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ae706f6576493e8e190ebf2c7e9cc7e60a3ee760
tree 1bd5deb115cfb9a051b14fc7e43bf3dd1bf2a223
parent e43a238efc6a97ee9fbff39dd414455561d9a941
author Patrick McHardy <kaber@trash.net> Mon, 09 Jul 2007 22:31:13 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 09 Jul 2007 22:31:13 +0200

 include/net/act_api.h     |   30 -----
 include/net/pkt_cls.h     |    8 -
 include/net/sch_generic.h |    2 
 net/sched/Kconfig         |    8 +
 net/sched/Makefile        |    1 
 net/sched/act_police.c    |  246 ++-------------------------------------------
 net/sched/cls_api.c       |   40 -------
 net/sched/cls_u32.c       |    3 -
 net/sched/sch_atm.c       |   19 ---
 net/sched/sch_cbq.c       |   45 +++-----
 net/sched/sch_dsmark.c    |   13 --
 net/sched/sch_hfsc.c      |    3 -
 net/sched/sch_htb.c       |    3 -
 net/sched/sch_ingress.c   |   19 ---
 net/sched/sch_tbf.c       |    2 
 15 files changed, 38 insertions(+), 404 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 2f0273f..68b4eaf 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -121,34 +121,4 @@ extern int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, in
 extern int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_copy_stats (struct sk_buff *,struct tc_action *, int);
 #endif /* CONFIG_NET_CLS_ACT */
-
-extern int tcf_police(struct sk_buff *skb, struct tcf_police *p);
-extern void tcf_police_destroy(struct tcf_police *p);
-extern struct tcf_police * tcf_police_locate(struct rtattr *rta, struct rtattr *est);
-extern int tcf_police_dump(struct sk_buff *skb, struct tcf_police *p);
-extern int tcf_police_dump_stats(struct sk_buff *skb, struct tcf_police *p);
-
-static inline int
-tcf_police_release(struct tcf_police *p, int bind)
-{
-	int ret = 0;
-#ifdef CONFIG_NET_CLS_ACT
-	if (p) {
-		if (bind)
-			p->tcf_bindcnt--;
-
-		p->tcf_refcnt--;
-		if (p->tcf_refcnt <= 0 && !p->tcf_bindcnt) {
-			tcf_police_destroy(p);
-			ret = 1;
-		}
-	}
-#else
-	if (p && --p->tcf_refcnt == 0)
-		tcf_police_destroy(p);
-
-#endif /* CONFIG_NET_CLS_ACT */
-	return ret;
-}
-
 #endif
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 4129df7..bbe0905 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -65,8 +65,6 @@ struct tcf_exts
 {
 #ifdef CONFIG_NET_CLS_ACT
 	struct tc_action *action;
-#elif defined CONFIG_NET_CLS_POLICE
-	struct tcf_police *police;
 #endif
 };
 
@@ -91,8 +89,6 @@ tcf_exts_is_predicative(struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	return !!exts->action;
-#elif defined CONFIG_NET_CLS_POLICE
-	return !!exts->police;
 #else
 	return 0;
 #endif
@@ -129,11 +125,7 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 #ifdef CONFIG_NET_CLS_ACT
 	if (exts->action)
 		return tcf_action_exec(skb, exts->action, res);
-#elif defined CONFIG_NET_CLS_POLICE
-	if (exts->police)
-		return tcf_police(skb, exts->police);
 #endif
-
 	return 0;
 }
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 0153cd9..8a67f24 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -290,7 +290,7 @@ static inline int qdisc_reshape_fail(struct sk_buff *skb, struct Qdisc *sch)
 {
 	sch->qstats.drops++;
 
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 	if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
 		goto drop;
 
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index b466288..d3f7c3f 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -472,12 +472,12 @@ config NET_ACT_SIMP
 
 config NET_CLS_POLICE
 	bool "Traffic Policing (obsolete)"
-	depends on NET_CLS_ACT!=y
+	select NET_CLS_ACT
+	select NET_ACT_POLICE
 	---help---
 	  Say Y here if you want to do traffic policing, i.e. strict
-	  bandwidth limiting. This option is obsoleted by the traffic
-	  policer implemented as action, it stays here for compatibility
-	  reasons.
+	  bandwidth limiting. This option is obsolete and just selects
+	  the option replacing it. It will be removed in the future.
 
 config NET_CLS_IND
 	bool "Incoming device classification"
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 020767a..b67c36f 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -8,7 +8,6 @@ obj-$(CONFIG_NET_SCHED)		+= sch_api.o sch_blackhole.o
 obj-$(CONFIG_NET_CLS)		+= cls_api.o
 obj-$(CONFIG_NET_CLS_ACT)	+= act_api.o
 obj-$(CONFIG_NET_ACT_POLICE)	+= act_police.o
-obj-$(CONFIG_NET_CLS_POLICE)	+= act_police.o
 obj-$(CONFIG_NET_ACT_GACT)	+= act_gact.o
 obj-$(CONFIG_NET_ACT_MIRRED)	+= act_mirred.o
 obj-$(CONFIG_NET_ACT_IPT)	+= act_ipt.o
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index d204038..bf90e60 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -50,7 +50,6 @@ struct tc_police_compat
 
 /* Each policer is serialized by its individual spinlock */
 
-#ifdef CONFIG_NET_CLS_ACT
 static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *cb,
 			      int type, struct tc_action *a)
 {
@@ -96,9 +95,8 @@ rtattr_failure:
 	nlmsg_trim(skb, r);
 	goto done;
 }
-#endif
 
-void tcf_police_destroy(struct tcf_police *p)
+static void tcf_police_destroy(struct tcf_police *p)
 {
 	unsigned int h = tcf_hash(p->tcf_index, POL_TAB_MASK);
 	struct tcf_common **p1p;
@@ -121,7 +119,6 @@ void tcf_police_destroy(struct tcf_police *p)
 	BUG_TRAP(0);
 }
 
-#ifdef CONFIG_NET_CLS_ACT
 static int tcf_act_police_locate(struct rtattr *rta, struct rtattr *est,
 				 struct tc_action *a, int ovr, int bind)
 {
@@ -247,10 +244,19 @@ failure:
 static int tcf_act_police_cleanup(struct tc_action *a, int bind)
 {
 	struct tcf_police *p = a->priv;
+	int ret = 0;
 
-	if (p != NULL)
-		return tcf_police_release(p, bind);
-	return 0;
+	if (p != NULL) {
+		if (bind)
+			p->tcf_bindcnt--;
+
+		p->tcf_refcnt--;
+		if (p->tcf_refcnt <= 0 && !p->tcf_bindcnt) {
+			tcf_police_destroy(p);
+			ret = 1;
+		}
+	}
+	return ret;
 }
 
 static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
@@ -372,229 +378,3 @@ police_cleanup_module(void)
 
 module_init(police_init_module);
 module_exit(police_cleanup_module);
-
-#else /* CONFIG_NET_CLS_ACT */
-
-static struct tcf_common *tcf_police_lookup(u32 index)
-{
-	struct tcf_hashinfo *hinfo = &police_hash_info;
-	struct tcf_common *p;
-
-	read_lock(hinfo->lock);
-	for (p = hinfo->htab[tcf_hash(index, hinfo->hmask)]; p;
-	     p = p->tcfc_next) {
-		if (p->tcfc_index == index)
-			break;
-	}
-	read_unlock(hinfo->lock);
-
-	return p;
-}
-
-static u32 tcf_police_new_index(void)
-{
-	u32 *idx_gen = &police_idx_gen;
-	u32 val = *idx_gen;
-
-	do {
-		if (++val == 0)
-			val = 1;
-	} while (tcf_police_lookup(val));
-
-	return (*idx_gen = val);
-}
-
-struct tcf_police *tcf_police_locate(struct rtattr *rta, struct rtattr *est)
-{
-	unsigned int h;
-	struct tcf_police *police;
-	struct rtattr *tb[TCA_POLICE_MAX];
-	struct tc_police *parm;
-	int size;
-
-	if (rtattr_parse_nested(tb, TCA_POLICE_MAX, rta) < 0)
-		return NULL;
-
-	if (tb[TCA_POLICE_TBF-1] == NULL)
-		return NULL;
-	size = RTA_PAYLOAD(tb[TCA_POLICE_TBF-1]);
-	if (size != sizeof(*parm) && size != sizeof(struct tc_police_compat))
-		return NULL;
-
-	parm = RTA_DATA(tb[TCA_POLICE_TBF-1]);
-
-	if (parm->index) {
-		struct tcf_common *pc;
-
-		pc = tcf_police_lookup(parm->index);
-		if (pc) {
-			police = to_police(pc);
-			police->tcf_refcnt++;
-			return police;
-		}
-	}
-	police = kzalloc(sizeof(*police), GFP_KERNEL);
-	if (unlikely(!police))
-		return NULL;
-
-	police->tcf_refcnt = 1;
-	spin_lock_init(&police->tcf_lock);
-	if (parm->rate.rate) {
-		police->tcfp_R_tab =
-			qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE-1]);
-		if (police->tcfp_R_tab == NULL)
-			goto failure;
-		if (parm->peakrate.rate) {
-			police->tcfp_P_tab =
-				qdisc_get_rtab(&parm->peakrate,
-					       tb[TCA_POLICE_PEAKRATE-1]);
-			if (police->tcfp_P_tab == NULL)
-				goto failure;
-		}
-	}
-	if (tb[TCA_POLICE_RESULT-1]) {
-		if (RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))
-			goto failure;
-		police->tcfp_result = *(u32*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
-	}
-	if (tb[TCA_POLICE_AVRATE-1]) {
-		if (RTA_PAYLOAD(tb[TCA_POLICE_AVRATE-1]) != sizeof(u32))
-			goto failure;
-		police->tcfp_ewma_rate =
-			*(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
-	}
-	police->tcfp_toks = police->tcfp_burst = parm->burst;
-	police->tcfp_mtu = parm->mtu;
-	if (police->tcfp_mtu == 0) {
-		police->tcfp_mtu = ~0;
-		if (police->tcfp_R_tab)
-			police->tcfp_mtu = 255<<police->tcfp_R_tab->rate.cell_log;
-	}
-	if (police->tcfp_P_tab)
-		police->tcfp_ptoks = L2T_P(police, police->tcfp_mtu);
-	police->tcfp_t_c = psched_get_time();
-	police->tcf_index = parm->index ? parm->index :
-		tcf_police_new_index();
-	police->tcf_action = parm->action;
-	if (est)
-		gen_new_estimator(&police->tcf_bstats, &police->tcf_rate_est,
-				  &police->tcf_lock, est);
-	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
-	write_lock_bh(&police_lock);
-	police->tcf_next = tcf_police_ht[h];
-	tcf_police_ht[h] = &police->common;
-	write_unlock_bh(&police_lock);
-	return police;
-
-failure:
-	if (police->tcfp_R_tab)
-		qdisc_put_rtab(police->tcfp_R_tab);
-	kfree(police);
-	return NULL;
-}
-
-int tcf_police(struct sk_buff *skb, struct tcf_police *police)
-{
-	psched_time_t now;
-	long toks;
-	long ptoks = 0;
-
-	spin_lock(&police->tcf_lock);
-
-	police->tcf_bstats.bytes += skb->len;
-	police->tcf_bstats.packets++;
-
-	if (police->tcfp_ewma_rate &&
-	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
-		police->tcf_qstats.overlimits++;
-		spin_unlock(&police->tcf_lock);
-		return police->tcf_action;
-	}
-	if (skb->len <= police->tcfp_mtu) {
-		if (police->tcfp_R_tab == NULL) {
-			spin_unlock(&police->tcf_lock);
-			return police->tcfp_result;
-		}
-
-		now = psched_get_time();
-		toks = psched_tdiff_bounded(now, police->tcfp_t_c,
-					    police->tcfp_burst);
-		if (police->tcfp_P_tab) {
-			ptoks = toks + police->tcfp_ptoks;
-			if (ptoks > (long)L2T_P(police, police->tcfp_mtu))
-				ptoks = (long)L2T_P(police, police->tcfp_mtu);
-			ptoks -= L2T_P(police, skb->len);
-		}
-		toks += police->tcfp_toks;
-		if (toks > (long)police->tcfp_burst)
-			toks = police->tcfp_burst;
-		toks -= L2T(police, skb->len);
-		if ((toks|ptoks) >= 0) {
-			police->tcfp_t_c = now;
-			police->tcfp_toks = toks;
-			police->tcfp_ptoks = ptoks;
-			spin_unlock(&police->tcf_lock);
-			return police->tcfp_result;
-		}
-	}
-
-	police->tcf_qstats.overlimits++;
-	spin_unlock(&police->tcf_lock);
-	return police->tcf_action;
-}
-EXPORT_SYMBOL(tcf_police);
-
-int tcf_police_dump(struct sk_buff *skb, struct tcf_police *police)
-{
-	unsigned char *b = skb_tail_pointer(skb);
-	struct tc_police opt;
-
-	opt.index = police->tcf_index;
-	opt.action = police->tcf_action;
-	opt.mtu = police->tcfp_mtu;
-	opt.burst = police->tcfp_burst;
-	if (police->tcfp_R_tab)
-		opt.rate = police->tcfp_R_tab->rate;
-	else
-		memset(&opt.rate, 0, sizeof(opt.rate));
-	if (police->tcfp_P_tab)
-		opt.peakrate = police->tcfp_P_tab->rate;
-	else
-		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
-	RTA_PUT(skb, TCA_POLICE_TBF, sizeof(opt), &opt);
-	if (police->tcfp_result)
-		RTA_PUT(skb, TCA_POLICE_RESULT, sizeof(int),
-			&police->tcfp_result);
-	if (police->tcfp_ewma_rate)
-		RTA_PUT(skb, TCA_POLICE_AVRATE, 4, &police->tcfp_ewma_rate);
-	return skb->len;
-
-rtattr_failure:
-	nlmsg_trim(skb, b);
-	return -1;
-}
-
-int tcf_police_dump_stats(struct sk_buff *skb, struct tcf_police *police)
-{
-	struct gnet_dump d;
-
-	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
-					 TCA_XSTATS, &police->tcf_lock,
-					 &d) < 0)
-		goto errout;
-
-	if (gnet_stats_copy_basic(&d, &police->tcf_bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &police->tcf_rate_est) < 0 ||
-	    gnet_stats_copy_queue(&d, &police->tcf_qstats) < 0)
-		goto errout;
-
-	if (gnet_stats_finish_copy(&d) < 0)
-		goto errout;
-
-	return 0;
-
-errout:
-	return -1;
-}
-
-#endif /* CONFIG_NET_CLS_ACT */
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 36b72aa..5f0fbca 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -458,11 +458,6 @@ tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts)
 		tcf_action_destroy(exts->action, TCA_ACT_UNBIND);
 		exts->action = NULL;
 	}
-#elif defined CONFIG_NET_CLS_POLICE
-	if (exts->police) {
-		tcf_police_release(exts->police, TCA_ACT_UNBIND);
-		exts->police = NULL;
-	}
 #endif
 }
 
@@ -496,17 +491,6 @@ tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
 			exts->action = act;
 		}
 	}
-#elif defined CONFIG_NET_CLS_POLICE
-	if (map->police && tb[map->police-1]) {
-		struct tcf_police *p;
-
-		p = tcf_police_locate(tb[map->police-1], rate_tlv);
-		if (p == NULL)
-			return -EINVAL;
-
-		exts->police = p;
-	} else if (map->action && tb[map->action-1])
-		return -EOPNOTSUPP;
 #else
 	if ((map->action && tb[map->action-1]) ||
 	    (map->police && tb[map->police-1]))
@@ -529,15 +513,6 @@ tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 		if (act)
 			tcf_action_destroy(act, TCA_ACT_UNBIND);
 	}
-#elif defined CONFIG_NET_CLS_POLICE
-	if (src->police) {
-		struct tcf_police *p;
-		tcf_tree_lock(tp);
-		p = xchg(&dst->police, src->police);
-		tcf_tree_unlock(tp);
-		if (p)
-			tcf_police_release(p, TCA_ACT_UNBIND);
-	}
 #endif
 }
 
@@ -566,17 +541,6 @@ tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
 			p_rta->rta_len = skb_tail_pointer(skb) - (u8 *)p_rta;
 		}
 	}
-#elif defined CONFIG_NET_CLS_POLICE
-	if (map->police && exts->police) {
-		struct rtattr *p_rta = (struct rtattr *)skb_tail_pointer(skb);
-
-		RTA_PUT(skb, map->police, 0, NULL);
-
-		if (tcf_police_dump(skb, exts->police) < 0)
-			goto rtattr_failure;
-
-		p_rta->rta_len = skb_tail_pointer(skb) - (u8 *)p_rta;
-	}
 #endif
 	return 0;
 rtattr_failure: __attribute__ ((unused))
@@ -591,10 +555,6 @@ tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
 	if (exts->action)
 		if (tcf_action_copy_stats(skb, exts->action, 1) < 0)
 			goto rtattr_failure;
-#elif defined CONFIG_NET_CLS_POLICE
-	if (exts->police)
-		if (tcf_police_dump_stats(skb, exts->police) < 0)
-			goto rtattr_failure;
 #endif
 	return 0;
 rtattr_failure: __attribute__ ((unused))
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 77961e2..8dbe369 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -782,9 +782,6 @@ static int __init init_u32(void)
 #ifdef CONFIG_CLS_U32_PERF
 	printk("    Performance counters on\n");
 #endif
-#ifdef CONFIG_NET_CLS_POLICE
-	printk("    OLD policer on \n");
-#endif
 #ifdef CONFIG_NET_CLS_IND
 	printk("    input device check on \n");
 #endif
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 37ae6d1..417ec8f 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -428,26 +428,9 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 				ATM_SKB(skb)->atm_options |= ATM_ATMOPT_CLP;
 			break;
 		}
-#elif defined(CONFIG_NET_CLS_POLICE)
-		switch (result) {
-		case TC_POLICE_SHOT:
-			kfree_skb(skb);
-			goto drop;
-		case TC_POLICE_RECLASSIFY:
-			if (flow->excess)
-				flow = flow->excess;
-			else {
-				ATM_SKB(skb)->atm_options |= ATM_ATMOPT_CLP;
-				break;
-			}
-			/* fall through */
-		case TC_POLICE_OK:
-			/* fall through */
-		default:
-			break;
-		}
 #endif
 	}
+
 	if ((ret = flow->q->enqueue(skb, flow->q)) != 0) {
 drop: __maybe_unused
 		sch->qstats.drops++;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 77381f1..e38c283 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -82,7 +82,7 @@ struct cbq_class
 	unsigned char		priority2;	/* priority to be used after overlimit */
 	unsigned char		ewma_log;	/* time constant for idle time calculation */
 	unsigned char		ovl_strategy;
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 	unsigned char		police;
 #endif
 
@@ -154,7 +154,7 @@ struct cbq_sched_data
 	struct cbq_class	*active[TC_CBQ_MAXPRIO+1];	/* List of all classes
 								   with backlog */
 
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 	struct cbq_class	*rx_class;
 #endif
 	struct cbq_class	*tx_class;
@@ -196,7 +196,7 @@ cbq_class_lookup(struct cbq_sched_data *q, u32 classid)
 	return NULL;
 }
 
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 
 static struct cbq_class *
 cbq_reclassify(struct sk_buff *skb, struct cbq_class *this)
@@ -271,15 +271,6 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		case TC_ACT_RECLASSIFY:
 			return cbq_reclassify(skb, cl);
 		}
-#elif defined(CONFIG_NET_CLS_POLICE)
-		switch (result) {
-		case TC_POLICE_RECLASSIFY:
-			return cbq_reclassify(skb, cl);
-		case TC_POLICE_SHOT:
-			return NULL;
-		default:
-			break;
-		}
 #endif
 		if (cl->level == 0)
 			return cl;
@@ -392,7 +383,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	int ret;
 	struct cbq_class *cl = cbq_classify(skb, sch, &ret);
 
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 	q->rx_class = cl;
 #endif
 	if (cl == NULL) {
@@ -402,7 +393,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return ret;
 	}
 
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 	cl->q->__parent = sch;
 #endif
 	if ((ret = cl->q->enqueue(skb, cl->q)) == NET_XMIT_SUCCESS) {
@@ -437,7 +428,7 @@ cbq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 
 	cbq_mark_toplevel(q, cl);
 
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 	q->rx_class = cl;
 	cl->q->__parent = sch;
 #endif
@@ -672,9 +663,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 	return HRTIMER_NORESTART;
 }
 
-
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
-
+#ifdef CONFIG_NET_CLS_ACT
 static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 {
 	int len = skb->len;
@@ -1367,7 +1356,7 @@ static int cbq_set_overlimit(struct cbq_class *cl, struct tc_cbq_ovl *ovl)
 	return 0;
 }
 
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 static int cbq_set_police(struct cbq_class *cl, struct tc_cbq_police *p)
 {
 	cl->police = p->police;
@@ -1535,7 +1524,7 @@ rtattr_failure:
 	return -1;
 }
 
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 static __inline__ int cbq_dump_police(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
@@ -1561,7 +1550,7 @@ static int cbq_dump_attr(struct sk_buff *skb, struct cbq_class *cl)
 	    cbq_dump_rate(skb, cl) < 0 ||
 	    cbq_dump_wrr(skb, cl) < 0 ||
 	    cbq_dump_ovl(skb, cl) < 0 ||
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 	    cbq_dump_police(skb, cl) < 0 ||
 #endif
 	    cbq_dump_fopt(skb, cl) < 0)
@@ -1656,7 +1645,7 @@ static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 						     cl->classid)) == NULL)
 				return -ENOBUFS;
 		} else {
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 			if (cl->police == TC_POLICE_RECLASSIFY)
 				new->reshape_fail = cbq_reshape_fail;
 #endif
@@ -1721,7 +1710,7 @@ cbq_destroy(struct Qdisc* sch)
 	struct cbq_class *cl;
 	unsigned h;
 
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 	q->rx_class = NULL;
 #endif
 	/*
@@ -1750,7 +1739,7 @@ static void cbq_put(struct Qdisc *sch, unsigned long arg)
 	struct cbq_class *cl = (struct cbq_class*)arg;
 
 	if (--cl->refcnt == 0) {
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 		struct cbq_sched_data *q = qdisc_priv(sch);
 
 		spin_lock_bh(&sch->dev->queue_lock);
@@ -1798,7 +1787,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 	    RTA_PAYLOAD(tb[TCA_CBQ_WRROPT-1]) < sizeof(struct tc_cbq_wrropt))
 			return -EINVAL;
 
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 	if (tb[TCA_CBQ_POLICE-1] &&
 	    RTA_PAYLOAD(tb[TCA_CBQ_POLICE-1]) < sizeof(struct tc_cbq_police))
 			return -EINVAL;
@@ -1841,7 +1830,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 		if (tb[TCA_CBQ_OVL_STRATEGY-1])
 			cbq_set_overlimit(cl, RTA_DATA(tb[TCA_CBQ_OVL_STRATEGY-1]));
 
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 		if (tb[TCA_CBQ_POLICE-1])
 			cbq_set_police(cl, RTA_DATA(tb[TCA_CBQ_POLICE-1]));
 #endif
@@ -1934,7 +1923,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 	cl->overlimit = cbq_ovl_classic;
 	if (tb[TCA_CBQ_OVL_STRATEGY-1])
 		cbq_set_overlimit(cl, RTA_DATA(tb[TCA_CBQ_OVL_STRATEGY-1]));
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 	if (tb[TCA_CBQ_POLICE-1])
 		cbq_set_police(cl, RTA_DATA(tb[TCA_CBQ_POLICE-1]));
 #endif
@@ -1978,7 +1967,7 @@ static int cbq_delete(struct Qdisc *sch, unsigned long arg)
 		q->tx_class = NULL;
 		q->tx_borrowed = NULL;
 	}
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 	if (q->rx_class == cl)
 		q->rx_class = NULL;
 #endif
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 2d7e891..60f8919 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -246,21 +246,10 @@ static int dsmark_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 			kfree_skb(skb);
 			sch->qstats.drops++;
 			return NET_XMIT_BYPASS;
-#elif defined(CONFIG_NET_CLS_POLICE)
-		case TC_POLICE_SHOT:
-			kfree_skb(skb);
-			sch->qstats.drops++;
-			return NET_XMIT_POLICED;
-#if 0
-		case TC_POLICE_RECLASSIFY:
-			/* FIXME: what to do here ??? */
-#endif
 #endif
-		case TC_POLICE_OK:
+		case TC_ACT_OK:
 			skb->tc_index = TC_H_MIN(res.classid);
 			break;
-		case TC_POLICE_UNSPEC:
-			/* fall through */
 		default:
 			if (p->default_index != NO_DEFAULT_INDEX)
 				skb->tc_index = p->default_index;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 874452c..55e7e45 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1174,9 +1174,6 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		case TC_ACT_SHOT:
 			return NULL;
 		}
-#elif defined(CONFIG_NET_CLS_POLICE)
-		if (result == TC_POLICE_SHOT)
-			return NULL;
 #endif
 		if ((cl = (struct hfsc_class *)res.class) == NULL) {
 			if ((cl = hfsc_find_class(res.classid, sch)) == NULL)
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c031486..b8e4837 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -252,9 +252,6 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 		case TC_ACT_SHOT:
 			return NULL;
 		}
-#elif defined(CONFIG_NET_CLS_POLICE)
-		if (result == TC_POLICE_SHOT)
-			return HTB_DIRECT;
 #endif
 		if ((cl = (void *)res.class) == NULL) {
 			if (res.classid == sch->handle)
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index cd0aab6..51f16b0 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -164,31 +164,12 @@ static int ingress_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 			result = TC_ACT_OK;
 			break;
 	}
-/* backward compat */
-#else
-#ifdef	CONFIG_NET_CLS_POLICE
-	switch (result) {
-		case TC_POLICE_SHOT:
-		result = NF_DROP;
-		sch->qstats.drops++;
-		break;
-		case TC_POLICE_RECLASSIFY: /* DSCP remarking here ? */
-		case TC_POLICE_OK:
-		case TC_POLICE_UNSPEC:
-		default:
-		sch->bstats.packets++;
-		sch->bstats.bytes += skb->len;
-		result = NF_ACCEPT;
-		break;
-	}
-
 #else
 	D2PRINTK("Overriding result to ACCEPT\n");
 	result = NF_ACCEPT;
 	sch->bstats.packets++;
 	sch->bstats.bytes += skb->len;
 #endif
-#endif
 
 	return result;
 }
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index b8b3345..8c2639a 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -125,7 +125,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	if (skb->len > q->max_size) {
 		sch->qstats.drops++;
-#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
+#ifdef CONFIG_NET_CLS_ACT
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
 #endif
 			kfree_skb(skb);
