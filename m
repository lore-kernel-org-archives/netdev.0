From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 03/51] pkt_sched: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:57:53 -0400
Message-ID: <1333335521-1348-4-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994Ab2DBC7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:13 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/act_api.c     |    9 ++++++---
 net/sched/act_csum.c    |    6 ++++--
 net/sched/act_gact.c    |    9 ++++++---
 net/sched/act_ipt.c     |   14 ++++++++------
 net/sched/act_mirred.c  |    6 ++++--
 net/sched/act_nat.c     |    6 ++++--
 net/sched/act_pedit.c   |    6 ++++--
 net/sched/act_police.c  |   13 ++++++++-----
 net/sched/act_simple.c  |    8 +++++---
 net/sched/act_skbedit.c |   27 ++++++++++++++++-----------
 net/sched/cls_api.c     |    3 ++-
 net/sched/cls_basic.c   |    5 +++--
 net/sched/cls_flow.c    |   35 +++++++++++++++++++++--------------
 net/sched/cls_fw.c      |   15 +++++++++------
 net/sched/cls_route.c   |   16 ++++++++++------
 net/sched/cls_rsvp.h    |   16 ++++++++++------
 net/sched/cls_tcindex.c |   14 ++++++++------
 net/sched/cls_u32.c     |   40 ++++++++++++++++++++++++----------------
 net/sched/em_meta.c     |   19 ++++++++++++-------
 net/sched/ematch.c      |    6 ++++--
 net/sched/sch_api.c     |    9 ++++++---
 net/sched/sch_atm.c     |   21 +++++++++++++--------
 net/sched/sch_cbq.c     |   18 ++++++++++++------
 net/sched/sch_choke.c   |    5 +++--
 net/sched/sch_drr.c     |    3 ++-
 net/sched/sch_dsmark.c  |   18 +++++++++++-------
 net/sched/sch_fifo.c    |    3 ++-
 net/sched/sch_generic.c |    3 ++-
 net/sched/sch_gred.c    |    6 ++++--
 net/sched/sch_hfsc.c    |    6 ++++--
 net/sched/sch_htb.c     |    6 ++++--
 net/sched/sch_mqprio.c  |    3 ++-
 net/sched/sch_multiq.c  |    3 ++-
 net/sched/sch_netem.c   |   21 ++++++++++++++-------
 net/sched/sch_prio.c    |    3 ++-
 net/sched/sch_qfq.c     |    5 +++--
 net/sched/sch_red.c     |    5 +++--
 net/sched/sch_sfb.c     |    3 ++-
 net/sched/sch_sfq.c     |    3 ++-
 net/sched/sch_tbf.c     |    3 ++-
 40 files changed, 263 insertions(+), 157 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 93fdf13..5cfb160 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -127,7 +127,8 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 	nest = nla_nest_start(skb, a->order);
 	if (nest == NULL)
 		goto nla_put_failure;
-	NLA_PUT_STRING(skb, TCA_KIND, a->ops->kind);
+	if (nla_put_string(skb, TCA_KIND, a->ops->kind))
+		goto nla_put_failure;
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
 		p = hinfo->htab[tcf_hash(i, hinfo->hmask)];
 
@@ -139,7 +140,8 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 			p = s_p;
 		}
 	}
-	NLA_PUT_U32(skb, TCA_FCNT, n_i);
+	if (nla_put_u32(skb, TCA_FCNT, n_i))
+		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
 	return n_i;
@@ -437,7 +439,8 @@ tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	if (a->ops == NULL || a->ops->dump == NULL)
 		return err;
 
-	NLA_PUT_STRING(skb, TCA_KIND, a->ops->kind);
+	if (nla_put_string(skb, TCA_KIND, a->ops->kind))
+		goto nla_put_failure;
 	if (tcf_action_copy_stats(skb, a, 0))
 		goto nla_put_failure;
 	nest = nla_nest_start(skb, TCA_OPTIONS);
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 453a734..882124c 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -550,11 +550,13 @@ static int tcf_csum_dump(struct sk_buff *skb,
 	};
 	struct tcf_t t;
 
-	NLA_PUT(skb, TCA_CSUM_PARMS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_CSUM_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
-	NLA_PUT(skb, TCA_CSUM_TM, sizeof(t), &t);
+	if (nla_put(skb, TCA_CSUM_TM, sizeof(t), &t))
+		goto nla_put_failure;
 
 	return skb->len;
 
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index b77f5a0..f10fb82 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -162,7 +162,8 @@ static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 	};
 	struct tcf_t t;
 
-	NLA_PUT(skb, TCA_GACT_PARMS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_GACT_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
 #ifdef CONFIG_GACT_PROB
 	if (gact->tcfg_ptype) {
 		struct tc_gact_p p_opt = {
@@ -171,13 +172,15 @@ static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 			.ptype   = gact->tcfg_ptype,
 		};
 
-		NLA_PUT(skb, TCA_GACT_PROB, sizeof(p_opt), &p_opt);
+		if (nla_put(skb, TCA_GACT_PROB, sizeof(p_opt), &p_opt))
+			goto nla_put_failure;
 	}
 #endif
 	t.install = jiffies_to_clock_t(jiffies - gact->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - gact->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(gact->tcf_tm.expires);
-	NLA_PUT(skb, TCA_GACT_TM, sizeof(t), &t);
+	if (nla_put(skb, TCA_GACT_TM, sizeof(t), &t))
+		goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 60f8f61..0beba0e 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -267,15 +267,17 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 	c.refcnt = ipt->tcf_refcnt - ref;
 	strcpy(t->u.user.name, ipt->tcfi_t->u.kernel.target->name);
 
-	NLA_PUT(skb, TCA_IPT_TARG, ipt->tcfi_t->u.user.target_size, t);
-	NLA_PUT_U32(skb, TCA_IPT_INDEX, ipt->tcf_index);
-	NLA_PUT_U32(skb, TCA_IPT_HOOK, ipt->tcfi_hook);
-	NLA_PUT(skb, TCA_IPT_CNT, sizeof(struct tc_cnt), &c);
-	NLA_PUT_STRING(skb, TCA_IPT_TABLE, ipt->tcfi_tname);
+	if (nla_put(skb, TCA_IPT_TARG, ipt->tcfi_t->u.user.target_size, t) ||
+	    nla_put_u32(skb, TCA_IPT_INDEX, ipt->tcf_index) ||
+	    nla_put_u32(skb, TCA_IPT_HOOK, ipt->tcfi_hook) ||
+	    nla_put(skb, TCA_IPT_CNT, sizeof(struct tc_cnt), &c) ||
+	    nla_put_string(skb, TCA_IPT_TABLE, ipt->tcfi_tname))
+		goto nla_put_failure;
 	tm.install = jiffies_to_clock_t(jiffies - ipt->tcf_tm.install);
 	tm.lastuse = jiffies_to_clock_t(jiffies - ipt->tcf_tm.lastuse);
 	tm.expires = jiffies_to_clock_t(ipt->tcf_tm.expires);
-	NLA_PUT(skb, TCA_IPT_TM, sizeof (tm), &tm);
+	if (nla_put(skb, TCA_IPT_TM, sizeof (tm), &tm))
+		goto nla_put_failure;
 	kfree(t);
 	return skb->len;
 
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index e051398..d583aea 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -227,11 +227,13 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, i
 	};
 	struct tcf_t t;
 
-	NLA_PUT(skb, TCA_MIRRED_PARMS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_MIRRED_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - m->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - m->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(m->tcf_tm.expires);
-	NLA_PUT(skb, TCA_MIRRED_TM, sizeof(t), &t);
+	if (nla_put(skb, TCA_MIRRED_TM, sizeof(t), &t))
+		goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 001d1b3..b5d029e 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -284,11 +284,13 @@ static int tcf_nat_dump(struct sk_buff *skb, struct tc_action *a,
 	};
 	struct tcf_t t;
 
-	NLA_PUT(skb, TCA_NAT_PARMS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_NAT_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
-	NLA_PUT(skb, TCA_NAT_TM, sizeof(t), &t);
+	if (nla_put(skb, TCA_NAT_TM, sizeof(t), &t))
+		goto nla_put_failure;
 
 	return skb->len;
 
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 10d3aed..26aa2f6 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -215,11 +215,13 @@ static int tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,
 	opt->refcnt = p->tcf_refcnt - ref;
 	opt->bindcnt = p->tcf_bindcnt - bind;
 
-	NLA_PUT(skb, TCA_PEDIT_PARMS, s, opt);
+	if (nla_put(skb, TCA_PEDIT_PARMS, s, opt))
+		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
-	NLA_PUT(skb, TCA_PEDIT_TM, sizeof(t), &t);
+	if (nla_put(skb, TCA_PEDIT_TM, sizeof(t), &t))
+		goto nla_put_failure;
 	kfree(opt);
 	return skb->len;
 
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 6fb3f5a..a9de232 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -356,11 +356,14 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 		opt.rate = police->tcfp_R_tab->rate;
 	if (police->tcfp_P_tab)
 		opt.peakrate = police->tcfp_P_tab->rate;
-	NLA_PUT(skb, TCA_POLICE_TBF, sizeof(opt), &opt);
-	if (police->tcfp_result)
-		NLA_PUT_U32(skb, TCA_POLICE_RESULT, police->tcfp_result);
-	if (police->tcfp_ewma_rate)
-		NLA_PUT_U32(skb, TCA_POLICE_AVRATE, police->tcfp_ewma_rate);
+	if (nla_put(skb, TCA_POLICE_TBF, sizeof(opt), &opt))
+		goto nla_put_failure;
+	if (police->tcfp_result &&
+	    nla_put_u32(skb, TCA_POLICE_RESULT, police->tcfp_result))
+		goto nla_put_failure;
+	if (police->tcfp_ewma_rate &&
+	    nla_put_u32(skb, TCA_POLICE_AVRATE, police->tcfp_ewma_rate))
+		goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 73e0a3a..3922f2a 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -172,12 +172,14 @@ static int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
 	};
 	struct tcf_t t;
 
-	NLA_PUT(skb, TCA_DEF_PARMS, sizeof(opt), &opt);
-	NLA_PUT_STRING(skb, TCA_DEF_DATA, d->tcfd_defdata);
+	if (nla_put(skb, TCA_DEF_PARMS, sizeof(opt), &opt) ||
+	    nla_put_string(skb, TCA_DEF_DATA, d->tcfd_defdata))
+		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
-	NLA_PUT(skb, TCA_DEF_TM, sizeof(t), &t);
+	if (nla_put(skb, TCA_DEF_TM, sizeof(t), &t))
+		goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 35dbbe9..476e0fa 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -166,20 +166,25 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	};
 	struct tcf_t t;
 
-	NLA_PUT(skb, TCA_SKBEDIT_PARMS, sizeof(opt), &opt);
-	if (d->flags & SKBEDIT_F_PRIORITY)
-		NLA_PUT(skb, TCA_SKBEDIT_PRIORITY, sizeof(d->priority),
-			&d->priority);
-	if (d->flags & SKBEDIT_F_QUEUE_MAPPING)
-		NLA_PUT(skb, TCA_SKBEDIT_QUEUE_MAPPING,
-			sizeof(d->queue_mapping), &d->queue_mapping);
-	if (d->flags & SKBEDIT_F_MARK)
-		NLA_PUT(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
-			&d->mark);
+	if (nla_put(skb, TCA_SKBEDIT_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
+	if ((d->flags & SKBEDIT_F_PRIORITY) &&
+	    nla_put(skb, TCA_SKBEDIT_PRIORITY, sizeof(d->priority),
+		    &d->priority))
+		goto nla_put_failure;
+	if ((d->flags & SKBEDIT_F_QUEUE_MAPPING) &&
+	    nla_put(skb, TCA_SKBEDIT_QUEUE_MAPPING,
+		    sizeof(d->queue_mapping), &d->queue_mapping))
+		goto nla_put_failure;
+	if ((d->flags & SKBEDIT_F_MARK) &&
+	    nla_put(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
+		    &d->mark))
+		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
-	NLA_PUT(skb, TCA_SKBEDIT_TM, sizeof(t), &t);
+	if (nla_put(skb, TCA_SKBEDIT_TM, sizeof(t), &t))
+		goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index a69d44f..f452f69 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -357,7 +357,8 @@ static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
 	tcm->tcm_ifindex = qdisc_dev(tp->q)->ifindex;
 	tcm->tcm_parent = tp->classid;
 	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
-	NLA_PUT_STRING(skb, TCA_KIND, tp->ops->kind);
+	if (nla_put_string(skb, TCA_KIND, tp->ops->kind))
+		goto nla_put_failure;
 	tcm->tcm_handle = fh;
 	if (RTM_DELTFILTER != event) {
 		tcm->tcm_handle = 0;
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index ea1f70b..590960a 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -257,8 +257,9 @@ static int basic_dump(struct tcf_proto *tp, unsigned long fh,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (f->res.classid)
-		NLA_PUT_U32(skb, TCA_BASIC_CLASSID, f->res.classid);
+	if (f->res.classid &&
+	    nla_put_u32(skb, TCA_BASIC_CLASSID, f->res.classid))
+		goto nla_put_failure;
 
 	if (tcf_exts_dump(skb, &f->exts, &basic_ext_map) < 0 ||
 	    tcf_em_tree_dump(skb, &f->ematches, TCA_BASIC_EMATCHES) < 0)
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 1d8bd0d..ccd08c8 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -572,25 +572,32 @@ static int flow_dump(struct tcf_proto *tp, unsigned long fh,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	NLA_PUT_U32(skb, TCA_FLOW_KEYS, f->keymask);
-	NLA_PUT_U32(skb, TCA_FLOW_MODE, f->mode);
+	if (nla_put_u32(skb, TCA_FLOW_KEYS, f->keymask) ||
+	    nla_put_u32(skb, TCA_FLOW_MODE, f->mode))
+		goto nla_put_failure;
 
 	if (f->mask != ~0 || f->xor != 0) {
-		NLA_PUT_U32(skb, TCA_FLOW_MASK, f->mask);
-		NLA_PUT_U32(skb, TCA_FLOW_XOR, f->xor);
+		if (nla_put_u32(skb, TCA_FLOW_MASK, f->mask) ||
+		    nla_put_u32(skb, TCA_FLOW_XOR, f->xor))
+			goto nla_put_failure;
 	}
-	if (f->rshift)
-		NLA_PUT_U32(skb, TCA_FLOW_RSHIFT, f->rshift);
-	if (f->addend)
-		NLA_PUT_U32(skb, TCA_FLOW_ADDEND, f->addend);
+	if (f->rshift &&
+	    nla_put_u32(skb, TCA_FLOW_RSHIFT, f->rshift))
+		goto nla_put_failure;
+	if (f->addend &&
+	    nla_put_u32(skb, TCA_FLOW_ADDEND, f->addend))
+		goto nla_put_failure;
 
-	if (f->divisor)
-		NLA_PUT_U32(skb, TCA_FLOW_DIVISOR, f->divisor);
-	if (f->baseclass)
-		NLA_PUT_U32(skb, TCA_FLOW_BASECLASS, f->baseclass);
+	if (f->divisor &&
+	    nla_put_u32(skb, TCA_FLOW_DIVISOR, f->divisor))
+		goto nla_put_failure;
+	if (f->baseclass &&
+	    nla_put_u32(skb, TCA_FLOW_BASECLASS, f->baseclass))
+		goto nla_put_failure;
 
-	if (f->perturb_period)
-		NLA_PUT_U32(skb, TCA_FLOW_PERTURB, f->perturb_period / HZ);
+	if (f->perturb_period &&
+	    nla_put_u32(skb, TCA_FLOW_PERTURB, f->perturb_period / HZ))
+		goto nla_put_failure;
 
 	if (tcf_exts_dump(skb, &f->exts, &flow_ext_map) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 389af15..8384a47 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -346,14 +346,17 @@ static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (f->res.classid)
-		NLA_PUT_U32(skb, TCA_FW_CLASSID, f->res.classid);
+	if (f->res.classid &&
+	    nla_put_u32(skb, TCA_FW_CLASSID, f->res.classid))
+		goto nla_put_failure;
 #ifdef CONFIG_NET_CLS_IND
-	if (strlen(f->indev))
-		NLA_PUT_STRING(skb, TCA_FW_INDEV, f->indev);
+	if (strlen(f->indev) &&
+	    nla_put_string(skb, TCA_FW_INDEV, f->indev))
+		goto nla_put_failure;
 #endif /* CONFIG_NET_CLS_IND */
-	if (head->mask != 0xFFFFFFFF)
-		NLA_PUT_U32(skb, TCA_FW_MASK, head->mask);
+	if (head->mask != 0xFFFFFFFF &&
+	    nla_put_u32(skb, TCA_FW_MASK, head->mask))
+		goto nla_put_failure;
 
 	if (tcf_exts_dump(skb, &f->exts, &fw_ext_map) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 13ab66e..36fec42 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -571,17 +571,21 @@ static int route4_dump(struct tcf_proto *tp, unsigned long fh,
 
 	if (!(f->handle & 0x8000)) {
 		id = f->id & 0xFF;
-		NLA_PUT_U32(skb, TCA_ROUTE4_TO, id);
+		if (nla_put_u32(skb, TCA_ROUTE4_TO, id))
+			goto nla_put_failure;
 	}
 	if (f->handle & 0x80000000) {
-		if ((f->handle >> 16) != 0xFFFF)
-			NLA_PUT_U32(skb, TCA_ROUTE4_IIF, f->iif);
+		if ((f->handle >> 16) != 0xFFFF &&
+		    nla_put_u32(skb, TCA_ROUTE4_IIF, f->iif))
+			goto nla_put_failure;
 	} else {
 		id = f->id >> 16;
-		NLA_PUT_U32(skb, TCA_ROUTE4_FROM, id);
+		if (nla_put_u32(skb, TCA_ROUTE4_FROM, id))
+			goto nla_put_failure;
 	}
-	if (f->res.classid)
-		NLA_PUT_U32(skb, TCA_ROUTE4_CLASSID, f->res.classid);
+	if (f->res.classid &&
+	    nla_put_u32(skb, TCA_ROUTE4_CLASSID, f->res.classid))
+		goto nla_put_failure;
 
 	if (tcf_exts_dump(skb, &f->exts, &route_ext_map) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index b014279..18ab93e 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -615,18 +615,22 @@ static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	NLA_PUT(skb, TCA_RSVP_DST, sizeof(s->dst), &s->dst);
+	if (nla_put(skb, TCA_RSVP_DST, sizeof(s->dst), &s->dst))
+		goto nla_put_failure;
 	pinfo.dpi = s->dpi;
 	pinfo.spi = f->spi;
 	pinfo.protocol = s->protocol;
 	pinfo.tunnelid = s->tunnelid;
 	pinfo.tunnelhdr = f->tunnelhdr;
 	pinfo.pad = 0;
-	NLA_PUT(skb, TCA_RSVP_PINFO, sizeof(pinfo), &pinfo);
-	if (f->res.classid)
-		NLA_PUT_U32(skb, TCA_RSVP_CLASSID, f->res.classid);
-	if (((f->handle >> 8) & 0xFF) != 16)
-		NLA_PUT(skb, TCA_RSVP_SRC, sizeof(f->src), f->src);
+	if (nla_put(skb, TCA_RSVP_PINFO, sizeof(pinfo), &pinfo))
+		goto nla_put_failure;
+	if (f->res.classid &&
+	    nla_put_u32(skb, TCA_RSVP_CLASSID, f->res.classid))
+		goto nla_put_failure;
+	if (((f->handle >> 8) & 0xFF) != 16 &&
+	    nla_put(skb, TCA_RSVP_SRC, sizeof(f->src), f->src))
+		goto nla_put_failure;
 
 	if (tcf_exts_dump(skb, &f->exts, &rsvp_ext_map) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index dbe1992..fe29420 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -438,10 +438,11 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 
 	if (!fh) {
 		t->tcm_handle = ~0; /* whatever ... */
-		NLA_PUT_U32(skb, TCA_TCINDEX_HASH, p->hash);
-		NLA_PUT_U16(skb, TCA_TCINDEX_MASK, p->mask);
-		NLA_PUT_U32(skb, TCA_TCINDEX_SHIFT, p->shift);
-		NLA_PUT_U32(skb, TCA_TCINDEX_FALL_THROUGH, p->fall_through);
+		if (nla_put_u32(skb, TCA_TCINDEX_HASH, p->hash) ||
+		    nla_put_u16(skb, TCA_TCINDEX_MASK, p->mask) ||
+		    nla_put_u32(skb, TCA_TCINDEX_SHIFT, p->shift) ||
+		    nla_put_u32(skb, TCA_TCINDEX_FALL_THROUGH, p->fall_through))
+			goto nla_put_failure;
 		nla_nest_end(skb, nest);
 	} else {
 		if (p->perfect) {
@@ -460,8 +461,9 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 			}
 		}
 		pr_debug("handle = %d\n", t->tcm_handle);
-		if (r->res.class)
-			NLA_PUT_U32(skb, TCA_TCINDEX_CLASSID, r->res.classid);
+		if (r->res.class &&
+		    nla_put_u32(skb, TCA_TCINDEX_CLASSID, r->res.classid))
+			goto nla_put_failure;
 
 		if (tcf_exts_dump(skb, &r->exts, &tcindex_ext_map) < 0)
 			goto nla_put_failure;
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 939b627..591b006 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -733,36 +733,44 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 		struct tc_u_hnode *ht = (struct tc_u_hnode *)fh;
 		u32 divisor = ht->divisor + 1;
 
-		NLA_PUT_U32(skb, TCA_U32_DIVISOR, divisor);
+		if (nla_put_u32(skb, TCA_U32_DIVISOR, divisor))
+			goto nla_put_failure;
 	} else {
-		NLA_PUT(skb, TCA_U32_SEL,
-			sizeof(n->sel) + n->sel.nkeys*sizeof(struct tc_u32_key),
-			&n->sel);
+		if (nla_put(skb, TCA_U32_SEL,
+			    sizeof(n->sel) + n->sel.nkeys*sizeof(struct tc_u32_key),
+			    &n->sel))
+			goto nla_put_failure;
 		if (n->ht_up) {
 			u32 htid = n->handle & 0xFFFFF000;
-			NLA_PUT_U32(skb, TCA_U32_HASH, htid);
+			if (nla_put_u32(skb, TCA_U32_HASH, htid))
+				goto nla_put_failure;
 		}
-		if (n->res.classid)
-			NLA_PUT_U32(skb, TCA_U32_CLASSID, n->res.classid);
-		if (n->ht_down)
-			NLA_PUT_U32(skb, TCA_U32_LINK, n->ht_down->handle);
+		if (n->res.classid &&
+		    nla_put_u32(skb, TCA_U32_CLASSID, n->res.classid))
+			goto nla_put_failure;
+		if (n->ht_down &&
+		    nla_put_u32(skb, TCA_U32_LINK, n->ht_down->handle))
+			goto nla_put_failure;
 
 #ifdef CONFIG_CLS_U32_MARK
-		if (n->mark.val || n->mark.mask)
-			NLA_PUT(skb, TCA_U32_MARK, sizeof(n->mark), &n->mark);
+		if ((n->mark.val || n->mark.mask) &&
+		    nla_put(skb, TCA_U32_MARK, sizeof(n->mark), &n->mark))
+			goto nla_put_failure;
 #endif
 
 		if (tcf_exts_dump(skb, &n->exts, &u32_ext_map) < 0)
 			goto nla_put_failure;
 
 #ifdef CONFIG_NET_CLS_IND
-		if (strlen(n->indev))
-			NLA_PUT_STRING(skb, TCA_U32_INDEV, n->indev);
+		if (strlen(n->indev) &&
+		    nla_put_string(skb, TCA_U32_INDEV, n->indev))
+			goto nla_put_failure;
 #endif
 #ifdef CONFIG_CLS_U32_PERF
-		NLA_PUT(skb, TCA_U32_PCNT,
-		sizeof(struct tc_u32_pcnt) + n->sel.nkeys*sizeof(u64),
-			n->pf);
+		if (nla_put(skb, TCA_U32_PCNT,
+			    sizeof(struct tc_u32_pcnt) + n->sel.nkeys*sizeof(u64),
+			    n->pf))
+			goto nla_put_failure;
 #endif
 	}
 
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 1363bf1..4790c69 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -585,8 +585,9 @@ static void meta_var_apply_extras(struct meta_value *v,
 
 static int meta_var_dump(struct sk_buff *skb, struct meta_value *v, int tlv)
 {
-	if (v->val && v->len)
-		NLA_PUT(skb, tlv, v->len, (void *) v->val);
+	if (v->val && v->len &&
+	    nla_put(skb, tlv, v->len, (void *) v->val))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -636,10 +637,13 @@ static void meta_int_apply_extras(struct meta_value *v,
 
 static int meta_int_dump(struct sk_buff *skb, struct meta_value *v, int tlv)
 {
-	if (v->len == sizeof(unsigned long))
-		NLA_PUT(skb, tlv, sizeof(unsigned long), &v->val);
-	else if (v->len == sizeof(u32))
-		NLA_PUT_U32(skb, tlv, v->val);
+	if (v->len == sizeof(unsigned long)) {
+		if (nla_put(skb, tlv, sizeof(unsigned long), &v->val))
+			goto nla_put_failure;
+	} else if (v->len == sizeof(u32)) {
+		if (nla_put_u32(skb, tlv, v->val))
+			goto nla_put_failure;
+	}
 
 	return 0;
 
@@ -831,7 +835,8 @@ static int em_meta_dump(struct sk_buff *skb, struct tcf_ematch *em)
 	memcpy(&hdr.left, &meta->lvalue.hdr, sizeof(hdr.left));
 	memcpy(&hdr.right, &meta->rvalue.hdr, sizeof(hdr.right));
 
-	NLA_PUT(skb, TCA_EM_META_HDR, sizeof(hdr), &hdr);
+	if (nla_put(skb, TCA_EM_META_HDR, sizeof(hdr), &hdr))
+		goto nla_put_failure;
 
 	ops = meta_type_ops(&meta->lvalue);
 	if (ops->dump(skb, &meta->lvalue, TCA_EM_META_LVALUE) < 0 ||
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 88d93eb..aca233c 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -441,7 +441,8 @@ int tcf_em_tree_dump(struct sk_buff *skb, struct tcf_ematch_tree *tree, int tlv)
 	if (top_start == NULL)
 		goto nla_put_failure;
 
-	NLA_PUT(skb, TCA_EMATCH_TREE_HDR, sizeof(tree->hdr), &tree->hdr);
+	if (nla_put(skb, TCA_EMATCH_TREE_HDR, sizeof(tree->hdr), &tree->hdr))
+		goto nla_put_failure;
 
 	list_start = nla_nest_start(skb, TCA_EMATCH_TREE_LIST);
 	if (list_start == NULL)
@@ -457,7 +458,8 @@ int tcf_em_tree_dump(struct sk_buff *skb, struct tcf_ematch_tree *tree, int tlv)
 			.flags = em->flags
 		};
 
-		NLA_PUT(skb, i + 1, sizeof(em_hdr), &em_hdr);
+		if (nla_put(skb, i + 1, sizeof(em_hdr), &em_hdr))
+			goto nla_put_failure;
 
 		if (em->ops && em->ops->dump) {
 			if (em->ops->dump(skb, em) < 0)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 3d8981f..d2daefc 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -426,7 +426,8 @@ static int qdisc_dump_stab(struct sk_buff *skb, struct qdisc_size_table *stab)
 	nest = nla_nest_start(skb, TCA_STAB);
 	if (nest == NULL)
 		goto nla_put_failure;
-	NLA_PUT(skb, TCA_STAB_BASE, sizeof(stab->szopts), &stab->szopts);
+	if (nla_put(skb, TCA_STAB_BASE, sizeof(stab->szopts), &stab->szopts))
+		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
 	return skb->len;
@@ -1201,7 +1202,8 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	tcm->tcm_parent = clid;
 	tcm->tcm_handle = q->handle;
 	tcm->tcm_info = atomic_read(&q->refcnt);
-	NLA_PUT_STRING(skb, TCA_KIND, q->ops->id);
+	if (nla_put_string(skb, TCA_KIND, q->ops->id))
+		goto nla_put_failure;
 	if (q->ops->dump && q->ops->dump(q, skb) < 0)
 		goto nla_put_failure;
 	q->qstats.qlen = q->q.qlen;
@@ -1505,7 +1507,8 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	tcm->tcm_parent = q->handle;
 	tcm->tcm_handle = q->handle;
 	tcm->tcm_info = 0;
-	NLA_PUT_STRING(skb, TCA_KIND, q->ops->id);
+	if (nla_put_string(skb, TCA_KIND, q->ops->id))
+		goto nla_put_failure;
 	if (cl_ops->dump && cl_ops->dump(q, cl, skb, tcm) < 0)
 		goto nla_put_failure;
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index e25e490..a77a4fb 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -601,7 +601,8 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	NLA_PUT(skb, TCA_ATM_HDR, flow->hdr_len, flow->hdr);
+	if (nla_put(skb, TCA_ATM_HDR, flow->hdr_len, flow->hdr))
+		goto nla_put_failure;
 	if (flow->vcc) {
 		struct sockaddr_atmpvc pvc;
 		int state;
@@ -610,15 +611,19 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 		pvc.sap_addr.itf = flow->vcc->dev ? flow->vcc->dev->number : -1;
 		pvc.sap_addr.vpi = flow->vcc->vpi;
 		pvc.sap_addr.vci = flow->vcc->vci;
-		NLA_PUT(skb, TCA_ATM_ADDR, sizeof(pvc), &pvc);
+		if (nla_put(skb, TCA_ATM_ADDR, sizeof(pvc), &pvc))
+			goto nla_put_failure;
 		state = ATM_VF2VS(flow->vcc->flags);
-		NLA_PUT_U32(skb, TCA_ATM_STATE, state);
+		if (nla_put_u32(skb, TCA_ATM_STATE, state))
+			goto nla_put_failure;
+	}
+	if (flow->excess) {
+		if (nla_put_u32(skb, TCA_ATM_EXCESS, flow->classid))
+			goto nla_put_failure;
+	} else {
+		if (nla_put_u32(skb, TCA_ATM_EXCESS, 0))
+			goto nla_put_failure;
 	}
-	if (flow->excess)
-		NLA_PUT_U32(skb, TCA_ATM_EXCESS, flow->classid);
-	else
-		NLA_PUT_U32(skb, TCA_ATM_EXCESS, 0);
-
 	nla_nest_end(skb, nest);
 	return skb->len;
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 24d94c0..6aabd77 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1425,7 +1425,8 @@ static int cbq_dump_rate(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 
-	NLA_PUT(skb, TCA_CBQ_RATE, sizeof(cl->R_tab->rate), &cl->R_tab->rate);
+	if (nla_put(skb, TCA_CBQ_RATE, sizeof(cl->R_tab->rate), &cl->R_tab->rate))
+		goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
@@ -1450,7 +1451,8 @@ static int cbq_dump_lss(struct sk_buff *skb, struct cbq_class *cl)
 	opt.minidle = (u32)(-cl->minidle);
 	opt.offtime = cl->offtime;
 	opt.change = ~0;
-	NLA_PUT(skb, TCA_CBQ_LSSOPT, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_CBQ_LSSOPT, sizeof(opt), &opt))
+		goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
@@ -1468,7 +1470,8 @@ static int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
 	opt.priority = cl->priority + 1;
 	opt.cpriority = cl->cpriority + 1;
 	opt.weight = cl->weight;
-	NLA_PUT(skb, TCA_CBQ_WRROPT, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_CBQ_WRROPT, sizeof(opt), &opt))
+		goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
@@ -1485,7 +1488,8 @@ static int cbq_dump_ovl(struct sk_buff *skb, struct cbq_class *cl)
 	opt.priority2 = cl->priority2 + 1;
 	opt.pad = 0;
 	opt.penalty = cl->penalty;
-	NLA_PUT(skb, TCA_CBQ_OVL_STRATEGY, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_CBQ_OVL_STRATEGY, sizeof(opt), &opt))
+		goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
@@ -1502,7 +1506,8 @@ static int cbq_dump_fopt(struct sk_buff *skb, struct cbq_class *cl)
 		opt.split = cl->split ? cl->split->common.classid : 0;
 		opt.defmap = cl->defmap;
 		opt.defchange = ~0;
-		NLA_PUT(skb, TCA_CBQ_FOPT, sizeof(opt), &opt);
+		if (nla_put(skb, TCA_CBQ_FOPT, sizeof(opt), &opt))
+			goto nla_put_failure;
 	}
 	return skb->len;
 
@@ -1521,7 +1526,8 @@ static int cbq_dump_police(struct sk_buff *skb, struct cbq_class *cl)
 		opt.police = cl->police;
 		opt.__res1 = 0;
 		opt.__res2 = 0;
-		NLA_PUT(skb, TCA_CBQ_POLICE, sizeof(opt), &opt);
+		if (nla_put(skb, TCA_CBQ_POLICE, sizeof(opt), &opt))
+			goto nla_put_failure;
 	}
 	return skb->len;
 
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 7e267d7..81445cc 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -515,8 +515,9 @@ static int choke_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (opts == NULL)
 		goto nla_put_failure;
 
-	NLA_PUT(skb, TCA_CHOKE_PARMS, sizeof(opt), &opt);
-	NLA_PUT_U32(skb, TCA_CHOKE_MAX_P, q->parms.max_P);
+	if (nla_put(skb, TCA_CHOKE_PARMS, sizeof(opt), &opt) ||
+	    nla_put_u32(skb, TCA_CHOKE_MAX_P, q->parms.max_P))
+		goto nla_put_failure;
 	return nla_nest_end(skb, opts);
 
 nla_put_failure:
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 6b7fe4a..c218987 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -260,7 +260,8 @@ static int drr_dump_class(struct Qdisc *sch, unsigned long arg,
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
-	NLA_PUT_U32(skb, TCA_DRR_QUANTUM, cl->quantum);
+	if (nla_put_u32(skb, TCA_DRR_QUANTUM, cl->quantum))
+		goto nla_put_failure;
 	return nla_nest_end(skb, nest);
 
 nla_put_failure:
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 2c79020..389b856 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -429,8 +429,9 @@ static int dsmark_dump_class(struct Qdisc *sch, unsigned long cl,
 	opts = nla_nest_start(skb, TCA_OPTIONS);
 	if (opts == NULL)
 		goto nla_put_failure;
-	NLA_PUT_U8(skb, TCA_DSMARK_MASK, p->mask[cl - 1]);
-	NLA_PUT_U8(skb, TCA_DSMARK_VALUE, p->value[cl - 1]);
+	if (nla_put_u8(skb, TCA_DSMARK_MASK, p->mask[cl - 1]) ||
+	    nla_put_u8(skb, TCA_DSMARK_VALUE, p->value[cl - 1]))
+		goto nla_put_failure;
 
 	return nla_nest_end(skb, opts);
 
@@ -447,13 +448,16 @@ static int dsmark_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opts = nla_nest_start(skb, TCA_OPTIONS);
 	if (opts == NULL)
 		goto nla_put_failure;
-	NLA_PUT_U16(skb, TCA_DSMARK_INDICES, p->indices);
+	if (nla_put_u16(skb, TCA_DSMARK_INDICES, p->indices))
+		goto nla_put_failure;
 
-	if (p->default_index != NO_DEFAULT_INDEX)
-		NLA_PUT_U16(skb, TCA_DSMARK_DEFAULT_INDEX, p->default_index);
+	if (p->default_index != NO_DEFAULT_INDEX &&
+	    nla_put_u16(skb, TCA_DSMARK_DEFAULT_INDEX, p->default_index))
+		goto nla_put_failure;
 
-	if (p->set_tc_index)
-		NLA_PUT_FLAG(skb, TCA_DSMARK_SET_TC_INDEX);
+	if (p->set_tc_index &&
+	    nla_put_flag(skb, TCA_DSMARK_SET_TC_INDEX))
+		goto nla_put_failure;
 
 	return nla_nest_end(skb, opts);
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 66effe2..e15a9eb 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -85,7 +85,8 @@ static int fifo_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct tc_fifo_qopt opt = { .limit = sch->limit };
 
-	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_OPTIONS, sizeof(opt), &opt))
+		goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 67fc573..0eb1202 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -512,7 +512,8 @@ static int pfifo_fast_dump(struct Qdisc *qdisc, struct sk_buff *skb)
 	struct tc_prio_qopt opt = { .bands = PFIFO_FAST_BANDS };
 
 	memcpy(&opt.priomap, prio2band, TC_PRIO_MAX + 1);
-	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_OPTIONS, sizeof(opt), &opt))
+		goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 0b15236..55e3310 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -521,14 +521,16 @@ static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opts = nla_nest_start(skb, TCA_OPTIONS);
 	if (opts == NULL)
 		goto nla_put_failure;
-	NLA_PUT(skb, TCA_GRED_DPS, sizeof(sopt), &sopt);
+	if (nla_put(skb, TCA_GRED_DPS, sizeof(sopt), &sopt))
+		goto nla_put_failure;
 
 	for (i = 0; i < MAX_DPs; i++) {
 		struct gred_sched_data *q = table->tab[i];
 
 		max_p[i] = q ? q->parms.max_P : 0;
 	}
-	NLA_PUT(skb, TCA_GRED_MAX_P, sizeof(max_p), max_p);
+	if (nla_put(skb, TCA_GRED_MAX_P, sizeof(max_p), max_p))
+		goto nla_put_failure;
 
 	parms = nla_nest_start(skb, TCA_GRED_PARMS);
 	if (parms == NULL)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 9bdca2e..8db3e2c 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1305,7 +1305,8 @@ hfsc_dump_sc(struct sk_buff *skb, int attr, struct internal_sc *sc)
 	tsc.m1 = sm2m(sc->sm1);
 	tsc.d  = dx2d(sc->dx);
 	tsc.m2 = sm2m(sc->sm2);
-	NLA_PUT(skb, attr, sizeof(tsc), &tsc);
+	if (nla_put(skb, attr, sizeof(tsc), &tsc))
+		goto nla_put_failure;
 
 	return skb->len;
 
@@ -1573,7 +1574,8 @@ hfsc_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
 	}
 
 	qopt.defcls = q->defcls;
-	NLA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
+	if (nla_put(skb, TCA_OPTIONS, sizeof(qopt), &qopt))
+		goto nla_put_failure;
 	return skb->len;
 
  nla_put_failure:
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 29b942c..2ea6f19 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1051,7 +1051,8 @@ static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
-	NLA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
+	if (nla_put(skb, TCA_HTB_INIT, sizeof(gopt), &gopt))
+		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
 	spin_unlock_bh(root_lock);
@@ -1090,7 +1091,8 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	opt.quantum = cl->quantum;
 	opt.prio = cl->prio;
 	opt.level = cl->level;
-	NLA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_HTB_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 	spin_unlock_bh(root_lock);
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 28de430..d1831ca 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -247,7 +247,8 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 		opt.offset[i] = dev->tc_to_txq[i].offset;
 	}
 
-	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_OPTIONS, sizeof(opt), &opt))
+		goto nla_put_failure;
 
 	return skb->len;
 nla_put_failure:
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 49131d7..2a2b096 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -284,7 +284,8 @@ static int multiq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opt.bands = q->bands;
 	opt.max_bands = q->max_bands;
 
-	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_OPTIONS, sizeof(opt), &opt))
+		goto nla_put_failure;
 
 	return skb->len;
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 5da548f..1109731 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -834,7 +834,8 @@ static int dump_loss_model(const struct netem_sched_data *q,
 			.p23 = q->clg.a5,
 		};
 
-		NLA_PUT(skb, NETEM_LOSS_GI, sizeof(gi), &gi);
+		if (nla_put(skb, NETEM_LOSS_GI, sizeof(gi), &gi))
+			goto nla_put_failure;
 		break;
 	}
 	case CLG_GILB_ELL: {
@@ -845,7 +846,8 @@ static int dump_loss_model(const struct netem_sched_data *q,
 			.k1 = q->clg.a4,
 		};
 
-		NLA_PUT(skb, NETEM_LOSS_GE, sizeof(ge), &ge);
+		if (nla_put(skb, NETEM_LOSS_GE, sizeof(ge), &ge))
+			goto nla_put_failure;
 		break;
 	}
 	}
@@ -874,26 +876,31 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 	qopt.loss = q->loss;
 	qopt.gap = q->gap;
 	qopt.duplicate = q->duplicate;
-	NLA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
+	if (nla_put(skb, TCA_OPTIONS, sizeof(qopt), &qopt))
+		goto nla_put_failure;
 
 	cor.delay_corr = q->delay_cor.rho;
 	cor.loss_corr = q->loss_cor.rho;
 	cor.dup_corr = q->dup_cor.rho;
-	NLA_PUT(skb, TCA_NETEM_CORR, sizeof(cor), &cor);
+	if (nla_put(skb, TCA_NETEM_CORR, sizeof(cor), &cor))
+		goto nla_put_failure;
 
 	reorder.probability = q->reorder;
 	reorder.correlation = q->reorder_cor.rho;
-	NLA_PUT(skb, TCA_NETEM_REORDER, sizeof(reorder), &reorder);
+	if (nla_put(skb, TCA_NETEM_REORDER, sizeof(reorder), &reorder))
+		goto nla_put_failure;
 
 	corrupt.probability = q->corrupt;
 	corrupt.correlation = q->corrupt_cor.rho;
-	NLA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
+	if (nla_put(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt))
+		goto nla_put_failure;
 
 	rate.rate = q->rate;
 	rate.packet_overhead = q->packet_overhead;
 	rate.cell_size = q->cell_size;
 	rate.cell_overhead = q->cell_overhead;
-	NLA_PUT(skb, TCA_NETEM_RATE, sizeof(rate), &rate);
+	if (nla_put(skb, TCA_NETEM_RATE, sizeof(rate), &rate))
+		goto nla_put_failure;
 
 	if (dump_loss_model(q, skb) != 0)
 		goto nla_put_failure;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index b5d56a2..79359b6 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -247,7 +247,8 @@ static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opt.bands = q->bands;
 	memcpy(&opt.priomap, q->prio2band, TC_PRIO_MAX + 1);
 
-	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_OPTIONS, sizeof(opt), &opt))
+		goto nla_put_failure;
 
 	return skb->len;
 
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index e68cb44..9af01f3 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -429,8 +429,9 @@ static int qfq_dump_class(struct Qdisc *sch, unsigned long arg,
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
-	NLA_PUT_U32(skb, TCA_QFQ_WEIGHT, ONE_FP/cl->inv_w);
-	NLA_PUT_U32(skb, TCA_QFQ_LMAX, cl->lmax);
+	if (nla_put_u32(skb, TCA_QFQ_WEIGHT, ONE_FP/cl->inv_w) ||
+	    nla_put_u32(skb, TCA_QFQ_LMAX, cl->lmax))
+		goto nla_put_failure;
 	return nla_nest_end(skb, nest);
 
 nla_put_failure:
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index a5cc301..633e32d 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -272,8 +272,9 @@ static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opts = nla_nest_start(skb, TCA_OPTIONS);
 	if (opts == NULL)
 		goto nla_put_failure;
-	NLA_PUT(skb, TCA_RED_PARMS, sizeof(opt), &opt);
-	NLA_PUT_U32(skb, TCA_RED_MAX_P, q->parms.max_P);
+	if (nla_put(skb, TCA_RED_PARMS, sizeof(opt), &opt) ||
+	    nla_put_u32(skb, TCA_RED_MAX_P, q->parms.max_P))
+		goto nla_put_failure;
 	return nla_nest_end(skb, opts);
 
 nla_put_failure:
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index d7eea99..74305c8 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -570,7 +570,8 @@ static int sfb_dump(struct Qdisc *sch, struct sk_buff *skb)
 
 	sch->qstats.backlog = q->qdisc->qstats.backlog;
 	opts = nla_nest_start(skb, TCA_OPTIONS);
-	NLA_PUT(skb, TCA_SFB_PARMS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_SFB_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
 	return nla_nest_end(skb, opts);
 
 nla_put_failure:
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 02a21ab..d3a1bc2 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -812,7 +812,8 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	memcpy(&opt.stats, &q->stats, sizeof(opt.stats));
 	opt.flags	= q->flags;
 
-	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_OPTIONS, sizeof(opt), &opt))
+		goto nla_put_failure;
 
 	return skb->len;
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index b8e1563..4b056c15 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -359,7 +359,8 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
 	opt.mtu = q->mtu;
 	opt.buffer = q->buffer;
-	NLA_PUT(skb, TCA_TBF_PARMS, sizeof(opt), &opt);
+	if (nla_put(skb, TCA_TBF_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 	return skb->len;
-- 
1.7.7.6
