From: Chris Mi <chrism@mellanox.com>
Subject: [patch net v2 1/4] net/sched: Change tc_action refcnt and bindcnt to atomic
Date: Mon, 16 Oct 2017 07:18:35 -0400
Message-ID: <1508152718-28726-2-git-send-email-chrism@mellanox.com>
References: <1508152718-28726-1-git-send-email-chrism@mellanox.com>
Cc: jhs@mojatatu.com, lucasb@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39082 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752007AbdJPLS4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 07:18:56 -0400
In-Reply-To: <1508152718-28726-1-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If many filters share the same action. That action's refcnt and bindcnt
could be manipulated by many RCU callbacks at the same time. This patch
makes these operations atomic.

Fixes commit in pre-git era.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chris Mi <chrism@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/act_api.h      |  4 ++--
 net/sched/act_api.c        | 21 +++++++++++----------
 net/sched/act_bpf.c        |  4 ++--
 net/sched/act_connmark.c   |  4 ++--
 net/sched/act_csum.c       |  4 ++--
 net/sched/act_gact.c       |  4 ++--
 net/sched/act_ife.c        |  4 ++--
 net/sched/act_ipt.c        |  4 ++--
 net/sched/act_mirred.c     |  4 ++--
 net/sched/act_nat.c        |  4 ++--
 net/sched/act_pedit.c      |  4 ++--
 net/sched/act_police.c     |  4 ++--
 net/sched/act_sample.c     |  4 ++--
 net/sched/act_simple.c     |  4 ++--
 net/sched/act_skbedit.c    |  4 ++--
 net/sched/act_skbmod.c     |  4 ++--
 net/sched/act_tunnel_key.c |  4 ++--
 net/sched/act_vlan.c       |  4 ++--
 18 files changed, 45 insertions(+), 44 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index b944e0eb..a469ab6 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -25,8 +25,8 @@ struct tc_action {
 	struct tcf_idrinfo		*idrinfo;
 
 	u32				tcfa_index;
-	int				tcfa_refcnt;
-	int				tcfa_bindcnt;
+	atomic_t			tcfa_refcnt;
+	atomic_t			tcfa_bindcnt;
 	u32				tcfa_capab;
 	int				tcfa_action;
 	struct tcf_t			tcfa_tm;
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index da6fa82..9c0224d 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -88,12 +88,13 @@ int __tcf_idr_release(struct tc_action *p, bool bind, bool strict)
 
 	if (p) {
 		if (bind)
-			p->tcfa_bindcnt--;
-		else if (strict && p->tcfa_bindcnt > 0)
+			atomic_dec(&p->tcfa_bindcnt);
+		else if (strict && atomic_read(&p->tcfa_bindcnt) > 0)
 			return -EPERM;
 
-		p->tcfa_refcnt--;
-		if (p->tcfa_bindcnt <= 0 && p->tcfa_refcnt <= 0) {
+		atomic_dec(&p->tcfa_refcnt);
+		if (atomic_read(&p->tcfa_bindcnt) == 0 &&
+		    atomic_read(&p->tcfa_refcnt) == 0) {
 			if (p->ops->cleanup)
 				p->ops->cleanup(p, bind);
 			tcf_idr_remove(p->idrinfo, p);
@@ -245,8 +246,8 @@ bool tcf_idr_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
 
 	if (index && p) {
 		if (bind)
-			p->tcfa_bindcnt++;
-		p->tcfa_refcnt++;
+			atomic_inc(&p->tcfa_bindcnt);
+		atomic_inc(&p->tcfa_refcnt);
 		*a = p;
 		return true;
 	}
@@ -274,9 +275,9 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 
 	if (unlikely(!p))
 		return -ENOMEM;
-	p->tcfa_refcnt = 1;
+	atomic_set(&p->tcfa_refcnt, 1);
 	if (bind)
-		p->tcfa_bindcnt = 1;
+		atomic_set(&p->tcfa_bindcnt, 1);
 
 	if (cpustats) {
 		p->cpu_bstats = netdev_alloc_pcpu_stats(struct gnet_stats_basic_cpu);
@@ -727,7 +728,7 @@ static void cleanup_a(struct list_head *actions, int ovr)
 		return;
 
 	list_for_each_entry(a, actions, list)
-		a->tcfa_refcnt--;
+		atomic_dec(&a->tcfa_refcnt);
 }
 
 int tcf_action_init(struct net *net, struct tcf_proto *tp, struct nlattr *nla,
@@ -751,7 +752,7 @@ int tcf_action_init(struct net *net, struct tcf_proto *tp, struct nlattr *nla,
 		}
 		act->order = i;
 		if (ovr)
-			act->tcfa_refcnt++;
+			atomic_inc(&act->tcfa_refcnt);
 		list_add_tail(&act->list, actions);
 	}
 
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index c0c707e..4ddf281 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -141,8 +141,8 @@ static int tcf_bpf_dump(struct sk_buff *skb, struct tc_action *act,
 	struct tcf_bpf *prog = to_bpf(act);
 	struct tc_act_bpf opt = {
 		.index   = prog->tcf_index,
-		.refcnt  = prog->tcf_refcnt - ref,
-		.bindcnt = prog->tcf_bindcnt - bind,
+		.refcnt  = atomic_read(&prog->tcf_refcnt) - ref,
+		.bindcnt = atomic_read(&prog->tcf_bindcnt) - bind,
 		.action  = prog->tcf_action,
 	};
 	struct tcf_t tm;
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 10b7a88..d2cf658 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -153,8 +153,8 @@ static inline int tcf_connmark_dump(struct sk_buff *skb, struct tc_action *a,
 
 	struct tc_connmark opt = {
 		.index   = ci->tcf_index,
-		.refcnt  = ci->tcf_refcnt - ref,
-		.bindcnt = ci->tcf_bindcnt - bind,
+		.refcnt  = atomic_read(&ci->tcf_refcnt) - ref,
+		.bindcnt = atomic_read(&ci->tcf_bindcnt) - bind,
 		.action  = ci->tcf_action,
 		.zone   = ci->zone,
 	};
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 1c40caa..b9ca424 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -575,8 +575,8 @@ static int tcf_csum_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 		.update_flags = p->update_flags,
 		.index   = p->tcf_index,
 		.action  = p->tcf_action,
-		.refcnt  = p->tcf_refcnt - ref,
-		.bindcnt = p->tcf_bindcnt - bind,
+		.refcnt  = atomic_read(&p->tcf_refcnt) - ref,
+		.bindcnt = atomic_read(&p->tcf_bindcnt) - bind,
 	};
 	struct tcf_t t;
 
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index e29a48e..b1326b7 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -169,8 +169,8 @@ static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a,
 	struct tcf_gact *gact = to_gact(a);
 	struct tc_gact opt = {
 		.index   = gact->tcf_index,
-		.refcnt  = gact->tcf_refcnt - ref,
-		.bindcnt = gact->tcf_bindcnt - bind,
+		.refcnt  = atomic_read(&gact->tcf_refcnt) - ref,
+		.bindcnt = atomic_read(&gact->tcf_bindcnt) - bind,
 		.action  = gact->tcf_action,
 	};
 	struct tcf_t t;
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 8ccd358..5cdcc87 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -551,8 +551,8 @@ static int tcf_ife_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 	struct tcf_ife_info *ife = to_ife(a);
 	struct tc_ife opt = {
 		.index = ife->tcf_index,
-		.refcnt = ife->tcf_refcnt - ref,
-		.bindcnt = ife->tcf_bindcnt - bind,
+		.refcnt = atomic_read(&ife->tcf_refcnt) - ref,
+		.bindcnt = atomic_read(&ife->tcf_bindcnt) - bind,
 		.action = ife->tcf_action,
 		.flags = ife->flags,
 	};
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index d9e399a..02c14dc 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -277,8 +277,8 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 	if (unlikely(!t))
 		goto nla_put_failure;
 
-	c.bindcnt = ipt->tcf_bindcnt - bind;
-	c.refcnt = ipt->tcf_refcnt - ref;
+	c.bindcnt = atomic_read(&ipt->tcf_bindcnt) - bind;
+	c.refcnt = atomic_read(&ipt->tcf_refcnt) - ref;
 	strcpy(t->u.user.name, ipt->tcfi_t->u.kernel.target->name);
 
 	if (nla_put(skb, TCA_IPT_TARG, ipt->tcfi_t->u.user.target_size, t) ||
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 416627c..aeeeb38 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -249,8 +249,8 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 	struct tc_mirred opt = {
 		.index   = m->tcf_index,
 		.action  = m->tcf_action,
-		.refcnt  = m->tcf_refcnt - ref,
-		.bindcnt = m->tcf_bindcnt - bind,
+		.refcnt  = atomic_read(&m->tcf_refcnt) - ref,
+		.bindcnt = atomic_read(&m->tcf_bindcnt) - bind,
 		.eaction = m->tcfm_eaction,
 		.ifindex = m->tcfm_ifindex,
 	};
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index c365d01..58fa1ae 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -256,8 +256,8 @@ static int tcf_nat_dump(struct sk_buff *skb, struct tc_action *a,
 
 		.index    = p->tcf_index,
 		.action   = p->tcf_action,
-		.refcnt   = p->tcf_refcnt - ref,
-		.bindcnt  = p->tcf_bindcnt - bind,
+		.refcnt   = atomic_read(&p->tcf_refcnt) - ref,
+		.bindcnt  = atomic_read(&p->tcf_bindcnt) - bind,
 	};
 	struct tcf_t t;
 
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 491fe5de..27b9fea 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -391,8 +391,8 @@ static int tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,
 	opt->nkeys = p->tcfp_nkeys;
 	opt->flags = p->tcfp_flags;
 	opt->action = p->tcf_action;
-	opt->refcnt = p->tcf_refcnt - ref;
-	opt->bindcnt = p->tcf_bindcnt - bind;
+	opt->refcnt = atomic_read(&p->tcf_refcnt) - ref;
+	opt->bindcnt = atomic_read(&p->tcf_bindcnt) - bind;
 
 	if (p->tcfp_keys_ex) {
 		tcf_pedit_key_ex_dump(skb, p->tcfp_keys_ex, p->tcfp_nkeys);
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 3bb2ebf..d8a1ac6 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -272,8 +272,8 @@ static int tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a,
 		.action = police->tcf_action,
 		.mtu = police->tcfp_mtu,
 		.burst = PSCHED_NS2TICKS(police->tcfp_burst),
-		.refcnt = police->tcf_refcnt - ref,
-		.bindcnt = police->tcf_bindcnt - bind,
+		.refcnt = atomic_read(&police->tcf_refcnt) - ref,
+		.bindcnt = atomic_read(&police->tcf_bindcnt) - bind,
 	};
 	struct tcf_t t;
 
diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
index ec986ae..64889a4 100644
--- a/net/sched/act_sample.c
+++ b/net/sched/act_sample.c
@@ -179,8 +179,8 @@ static int tcf_sample_dump(struct sk_buff *skb, struct tc_action *a,
 	struct tc_sample opt = {
 		.index      = s->tcf_index,
 		.action     = s->tcf_action,
-		.refcnt     = s->tcf_refcnt - ref,
-		.bindcnt    = s->tcf_bindcnt - bind,
+		.refcnt     = atomic_read(&s->tcf_refcnt) - ref,
+		.bindcnt    = atomic_read(&s->tcf_bindcnt) - bind,
 	};
 	struct tcf_t t;
 
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index e7b57e5..ec7e397 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -148,8 +148,8 @@ static int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
 	struct tcf_defact *d = to_defact(a);
 	struct tc_defact opt = {
 		.index   = d->tcf_index,
-		.refcnt  = d->tcf_refcnt - ref,
-		.bindcnt = d->tcf_bindcnt - bind,
+		.refcnt  = atomic_read(&d->tcf_refcnt) - ref,
+		.bindcnt = atomic_read(&d->tcf_bindcnt) - bind,
 		.action  = d->tcf_action,
 	};
 	struct tcf_t t;
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 59949d6..2b05e56 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -172,8 +172,8 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	struct tcf_skbedit *d = to_skbedit(a);
 	struct tc_skbedit opt = {
 		.index   = d->tcf_index,
-		.refcnt  = d->tcf_refcnt - ref,
-		.bindcnt = d->tcf_bindcnt - bind,
+		.refcnt  = atomic_read(&d->tcf_refcnt) - ref,
+		.bindcnt = atomic_read(&d->tcf_bindcnt) - bind,
 		.action  = d->tcf_action,
 	};
 	struct tcf_t t;
diff --git a/net/sched/act_skbmod.c b/net/sched/act_skbmod.c
index b642ad3..ca1ddf9 100644
--- a/net/sched/act_skbmod.c
+++ b/net/sched/act_skbmod.c
@@ -201,8 +201,8 @@ static int tcf_skbmod_dump(struct sk_buff *skb, struct tc_action *a,
 	struct tcf_skbmod_params  *p = rtnl_dereference(d->skbmod_p);
 	struct tc_skbmod opt = {
 		.index   = d->tcf_index,
-		.refcnt  = d->tcf_refcnt - ref,
-		.bindcnt = d->tcf_bindcnt - bind,
+		.refcnt  = atomic_read(&d->tcf_refcnt) - ref,
+		.bindcnt = atomic_read(&d->tcf_bindcnt) - bind,
 		.action  = d->tcf_action,
 	};
 	struct tcf_t t;
diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index 30c9627..158d472 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -250,8 +250,8 @@ static int tunnel_key_dump(struct sk_buff *skb, struct tc_action *a,
 	struct tcf_tunnel_key_params *params;
 	struct tc_tunnel_key opt = {
 		.index    = t->tcf_index,
-		.refcnt   = t->tcf_refcnt - ref,
-		.bindcnt  = t->tcf_bindcnt - bind,
+		.refcnt   = atomic_read(&t->tcf_refcnt) - ref,
+		.bindcnt  = atomic_read(&t->tcf_bindcnt) - bind,
 	};
 	struct tcf_t tm;
 
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 16eb067..e2d7aab 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -208,8 +208,8 @@ static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
 	struct tcf_vlan *v = to_vlan(a);
 	struct tc_vlan opt = {
 		.index    = v->tcf_index,
-		.refcnt   = v->tcf_refcnt - ref,
-		.bindcnt  = v->tcf_bindcnt - bind,
+		.refcnt   = atomic_read(&v->tcf_refcnt) - ref,
+		.bindcnt  = atomic_read(&v->tcf_bindcnt) - bind,
 		.action   = v->tcf_action,
 		.v_action = v->tcfv_action,
 	};
-- 
1.8.3.1
