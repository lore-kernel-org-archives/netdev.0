From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 01/04]: Remove CONFIG_NET_ESTIMATOR option
Date: Tue, 19 Jun 2007 17:02:19 +0200 (MEST)
Message-ID: <20070619150200.30997.73722.sendpatchset@localhost.localdomain>
References: <20070619150159.30997.77256.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60154 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412AbXFSPCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 11:02:21 -0400
In-Reply-To: <20070619150159.30997.77256.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Remove CONFIG_NET_ESTIMATOR option

The generic estimator is always built in anways and all the config options
does is prevent including a minimal amount of code for setting it up.
Additionally the option is already automatically selected for most cases.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0f93837e26f826f49382b567ef15efe0e4995615
tree 43796c93685c9c18fe0d82b1f848f6e6fc7ed63f
parent bd438b7a813667f60e47f45aee35be2d5a2bcc32
author Patrick McHardy <kaber@trash.net> Thu, 14 Jun 2007 16:29:07 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 14 Jun 2007 16:29:07 +0200

 net/sched/Kconfig       |   12 ------------
 net/sched/act_api.c     |    6 ------
 net/sched/act_police.c  |   18 ------------------
 net/sched/sch_api.c     |    6 ------
 net/sched/sch_cbq.c     |    8 --------
 net/sched/sch_generic.c |    2 --
 net/sched/sch_hfsc.c    |    8 --------
 7 files changed, 0 insertions(+), 60 deletions(-)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 475df84..7828c37 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -275,7 +275,6 @@ config CLS_U32_MARK
 config NET_CLS_RSVP
 	tristate "IPv4 Resource Reservation Protocol (RSVP)"
 	select NET_CLS
-	select NET_ESTIMATOR
 	---help---
 	  The Resource Reservation Protocol (RSVP) permits end systems to
 	  request a minimum and maximum data flow rate for a connection; this
@@ -290,7 +289,6 @@ config NET_CLS_RSVP
 config NET_CLS_RSVP6
 	tristate "IPv6 Resource Reservation Protocol (RSVP6)"
 	select NET_CLS
-	select NET_ESTIMATOR
 	---help---
 	  The Resource Reservation Protocol (RSVP) permits end systems to
 	  request a minimum and maximum data flow rate for a connection; this
@@ -382,7 +380,6 @@ config NET_EMATCH_TEXT
 
 config NET_CLS_ACT
 	bool "Actions"
-	select NET_ESTIMATOR
 	---help---
 	  Say Y here if you want to use traffic control actions. Actions
 	  get attached to classifiers and are invoked after a successful
@@ -465,7 +462,6 @@ config NET_ACT_SIMP
 config NET_CLS_POLICE
 	bool "Traffic Policing (obsolete)"
 	depends on NET_CLS_ACT!=y
-	select NET_ESTIMATOR
 	---help---
 	  Say Y here if you want to do traffic policing, i.e. strict
 	  bandwidth limiting. This option is obsoleted by the traffic
@@ -480,14 +476,6 @@ config NET_CLS_IND
 	  classification based on the incoming device. This option is
 	  likely to disappear in favour of the metadata ematch.
 
-config NET_ESTIMATOR
-	bool "Rate estimator"
-	---help---
-	  Say Y here to allow using rate estimators to estimate the current
-	  rate-of-flow for network devices, queues, etc. This module is
-	  automatically selected if needed but can be selected manually for
-	  statistical purposes.
-
 endif # NET_SCHED
 
 endmenu
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 711dd26..72bb9bd 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -42,10 +42,8 @@ void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 			write_lock_bh(hinfo->lock);
 			*p1p = p->tcfc_next;
 			write_unlock_bh(hinfo->lock);
-#ifdef CONFIG_NET_ESTIMATOR
 			gen_kill_estimator(&p->tcfc_bstats,
 					   &p->tcfc_rate_est);
-#endif
 			kfree(p);
 			return;
 		}
@@ -236,11 +234,9 @@ struct tcf_common *tcf_hash_create(u32 index, struct rtattr *est, struct tc_acti
 	p->tcfc_index = index ? index : tcf_hash_new_index(idx_gen, hinfo);
 	p->tcfc_tm.install = jiffies;
 	p->tcfc_tm.lastuse = jiffies;
-#ifdef CONFIG_NET_ESTIMATOR
 	if (est)
 		gen_new_estimator(&p->tcfc_bstats, &p->tcfc_rate_est,
 				  p->tcfc_stats_lock, est);
-#endif
 	a->priv = (void *) p;
 	return p;
 }
@@ -614,9 +610,7 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 			goto errout;
 
 	if (gnet_stats_copy_basic(&d, &h->tcf_bstats) < 0 ||
-#ifdef CONFIG_NET_ESTIMATOR
 	    gnet_stats_copy_rate_est(&d, &h->tcf_rate_est) < 0 ||
-#endif
 	    gnet_stats_copy_queue(&d, &h->tcf_qstats) < 0)
 		goto errout;
 
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 616f465..580698d 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -118,10 +118,8 @@ void tcf_police_destroy(struct tcf_police *p)
 			write_lock_bh(&police_lock);
 			*p1p = p->tcf_next;
 			write_unlock_bh(&police_lock);
-#ifdef CONFIG_NET_ESTIMATOR
 			gen_kill_estimator(&p->tcf_bstats,
 					   &p->tcf_rate_est);
-#endif
 			if (p->tcfp_R_tab)
 				qdisc_put_rtab(p->tcfp_R_tab);
 			if (p->tcfp_P_tab)
@@ -227,7 +225,6 @@ override:
 		police->tcfp_ptoks = L2T_P(police, police->tcfp_mtu);
 	police->tcf_action = parm->action;
 
-#ifdef CONFIG_NET_ESTIMATOR
 	if (tb[TCA_POLICE_AVRATE-1])
 		police->tcfp_ewma_rate =
 			*(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
@@ -235,7 +232,6 @@ override:
 		gen_replace_estimator(&police->tcf_bstats,
 				      &police->tcf_rate_est,
 				      police->tcf_stats_lock, est);
-#endif
 
 	spin_unlock_bh(&police->tcf_lock);
 	if (ret != ACT_P_CREATED)
@@ -281,14 +277,12 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
 	police->tcf_bstats.bytes += skb->len;
 	police->tcf_bstats.packets++;
 
-#ifdef CONFIG_NET_ESTIMATOR
 	if (police->tcfp_ewma_rate &&
 	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
 		police->tcf_qstats.overlimits++;
 		spin_unlock(&police->tcf_lock);
 		return police->tcf_action;
 	}
-#endif
 
 	if (skb->len <= police->tcfp_mtu) {
 		if (police->tcfp_R_tab == NULL) {
@@ -348,10 +342,8 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	if (police->tcfp_result)
 		RTA_PUT(skb, TCA_POLICE_RESULT, sizeof(int),
 			&police->tcfp_result);
-#ifdef CONFIG_NET_ESTIMATOR
 	if (police->tcfp_ewma_rate)
 		RTA_PUT(skb, TCA_POLICE_AVRATE, 4, &police->tcfp_ewma_rate);
-#endif
 	return skb->len;
 
 rtattr_failure:
@@ -477,14 +469,12 @@ struct tcf_police *tcf_police_locate(struct rtattr *rta, struct rtattr *est)
 			goto failure;
 		police->tcfp_result = *(u32*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
 	}
-#ifdef CONFIG_NET_ESTIMATOR
 	if (tb[TCA_POLICE_AVRATE-1]) {
 		if (RTA_PAYLOAD(tb[TCA_POLICE_AVRATE-1]) != sizeof(u32))
 			goto failure;
 		police->tcfp_ewma_rate =
 			*(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
 	}
-#endif
 	police->tcfp_toks = police->tcfp_burst = parm->burst;
 	police->tcfp_mtu = parm->mtu;
 	if (police->tcfp_mtu == 0) {
@@ -498,11 +488,9 @@ struct tcf_police *tcf_police_locate(struct rtattr *rta, struct rtattr *est)
 	police->tcf_index = parm->index ? parm->index :
 		tcf_police_new_index();
 	police->tcf_action = parm->action;
-#ifdef CONFIG_NET_ESTIMATOR
 	if (est)
 		gen_new_estimator(&police->tcf_bstats, &police->tcf_rate_est,
 				  police->tcf_stats_lock, est);
-#endif
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
 	write_lock_bh(&police_lock);
 	police->tcf_next = tcf_police_ht[h];
@@ -528,14 +516,12 @@ int tcf_police(struct sk_buff *skb, struct tcf_police *police)
 	police->tcf_bstats.bytes += skb->len;
 	police->tcf_bstats.packets++;
 
-#ifdef CONFIG_NET_ESTIMATOR
 	if (police->tcfp_ewma_rate &&
 	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
 		police->tcf_qstats.overlimits++;
 		spin_unlock(&police->tcf_lock);
 		return police->tcf_action;
 	}
-#endif
 	if (skb->len <= police->tcfp_mtu) {
 		if (police->tcfp_R_tab == NULL) {
 			spin_unlock(&police->tcf_lock);
@@ -591,10 +577,8 @@ int tcf_police_dump(struct sk_buff *skb, struct tcf_police *police)
 	if (police->tcfp_result)
 		RTA_PUT(skb, TCA_POLICE_RESULT, sizeof(int),
 			&police->tcfp_result);
-#ifdef CONFIG_NET_ESTIMATOR
 	if (police->tcfp_ewma_rate)
 		RTA_PUT(skb, TCA_POLICE_AVRATE, 4, &police->tcfp_ewma_rate);
-#endif
 	return skb->len;
 
 rtattr_failure:
@@ -612,9 +596,7 @@ int tcf_police_dump_stats(struct sk_buff *skb, struct tcf_police *police)
 		goto errout;
 
 	if (gnet_stats_copy_basic(&d, &police->tcf_bstats) < 0 ||
-#ifdef CONFIG_NET_ESTIMATOR
 	    gnet_stats_copy_rate_est(&d, &police->tcf_rate_est) < 0 ||
-#endif
 	    gnet_stats_copy_queue(&d, &police->tcf_qstats) < 0)
 		goto errout;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index bec600a..0f9e1c7 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -515,7 +515,6 @@ qdisc_create(struct net_device *dev, u32 handle, struct rtattr **tca, int *errp)
 	sch->handle = handle;
 
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS-1])) == 0) {
-#ifdef CONFIG_NET_ESTIMATOR
 		if (tca[TCA_RATE-1]) {
 			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
 						sch->stats_lock,
@@ -531,7 +530,6 @@ qdisc_create(struct net_device *dev, u32 handle, struct rtattr **tca, int *errp)
 				goto err_out3;
 			}
 		}
-#endif
 		qdisc_lock_tree(dev);
 		list_add_tail(&sch->list, &dev->qdisc_list);
 		qdisc_unlock_tree(dev);
@@ -559,11 +557,9 @@ static int qdisc_change(struct Qdisc *sch, struct rtattr **tca)
 		if (err)
 			return err;
 	}
-#ifdef CONFIG_NET_ESTIMATOR
 	if (tca[TCA_RATE-1])
 		gen_replace_estimator(&sch->bstats, &sch->rate_est,
 			sch->stats_lock, tca[TCA_RATE-1]);
-#endif
 	return 0;
 }
 
@@ -839,9 +835,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		goto rtattr_failure;
 
 	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
-#ifdef CONFIG_NET_ESTIMATOR
 	    gnet_stats_copy_rate_est(&d, &q->rate_est) < 0 ||
-#endif
 	    gnet_stats_copy_queue(&d, &q->qstats) < 0)
 		goto rtattr_failure;
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index ee2d596..bf1ea9e 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1653,9 +1653,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 		cl->xstats.undertime = cl->undertime - q->now;
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-#ifdef CONFIG_NET_ESTIMATOR
 	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
-#endif
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
@@ -1726,9 +1724,7 @@ static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 	tcf_destroy_chain(cl->filter_list);
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
-#ifdef CONFIG_NET_ESTIMATOR
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
-#endif
 	if (cl != &q->link)
 		kfree(cl);
 }
@@ -1873,11 +1869,9 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 
 		sch_tree_unlock(sch);
 
-#ifdef CONFIG_NET_ESTIMATOR
 		if (tca[TCA_RATE-1])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
 				cl->stats_lock, tca[TCA_RATE-1]);
-#endif
 		return 0;
 	}
 
@@ -1963,11 +1957,9 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 		cbq_set_fopt(cl, RTA_DATA(tb[TCA_CBQ_FOPT-1]));
 	sch_tree_unlock(sch);
 
-#ifdef CONFIG_NET_ESTIMATOR
 	if (tca[TCA_RATE-1])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
 			cl->stats_lock, tca[TCA_RATE-1]);
-#endif
 
 	*arg = (unsigned long)cl;
 	return 0;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 9461e8a..5f65d03 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -512,9 +512,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 		return;
 
 	list_del(&qdisc->list);
-#ifdef CONFIG_NET_ESTIMATOR
 	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
-#endif
 	if (ops->reset)
 		ops->reset(qdisc);
 	if (ops->destroy)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 9d124c4..7ccdf63 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1054,11 +1054,9 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		}
 		sch_tree_unlock(sch);
 
-#ifdef CONFIG_NET_ESTIMATOR
 		if (tca[TCA_RATE-1])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
 				cl->stats_lock, tca[TCA_RATE-1]);
-#endif
 		return 0;
 	}
 
@@ -1112,11 +1110,9 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->cl_pcvtoff = parent->cl_cvtoff;
 	sch_tree_unlock(sch);
 
-#ifdef CONFIG_NET_ESTIMATOR
 	if (tca[TCA_RATE-1])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
 			cl->stats_lock, tca[TCA_RATE-1]);
-#endif
 	*arg = (unsigned long)cl;
 	return 0;
 }
@@ -1128,9 +1124,7 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 
 	tcf_destroy_chain(cl->filter_list);
 	qdisc_destroy(cl->qdisc);
-#ifdef CONFIG_NET_ESTIMATOR
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
-#endif
 	if (cl != &q->root)
 		kfree(cl);
 }
@@ -1384,9 +1378,7 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	xstats.rtwork  = cl->cl_cumul;
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-#ifdef CONFIG_NET_ESTIMATOR
 	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
-#endif
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
