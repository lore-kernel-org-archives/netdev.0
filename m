From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH net-next] pkt_sched: namespace aware ifb
Date: Sun, 13 Jan 2013 11:41:41 -0500
Message-ID: <20130113164141.GL5259@kvack.org>
References: <50F1699E.1000200@hartkopp.net> <20130112.132316.2121287993605534669.davem@davemloft.net> <20130112.133630.257139657732337147.davem@davemloft.net> <1358046374.20249.1789.camel@edumazet-glaptop> <20130113035013.GJ5259@kvack.org> <1358056199.20249.2121.camel@edumazet-glaptop> <50F2C860.1060602@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:48237 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755090Ab3AMQlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jan 2013 11:41:42 -0500
Content-Disposition: inline
In-Reply-To: <50F2C860.1060602@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

On Sun, Jan 13, 2013 at 09:44:48AM -0500, Jamal Hadi Salim wrote:
> Eric, the point probably Ben was trying to make is not about 
> synchronizing rather about which namespace has the right to that action 
> config. Your change is correct for the common use of actions
> but does not fix the larger picture.
...
> In such a case, the "tc actions" netlink path may be
> entered from a different namespace than the one that is
> using it. Then current->nsproxy->net_ns is no longer correct.
> 
> To correct this, i think what Ben points out in passing the
> init() the correct namespace seem like the way to go. Feel free
> to make that change - otherwise i will get to it and fix it.

Yep, Jamal's right on the point I'm trying to make.  To deal with this, I 
think we need a patch along the lines of the following to pass the 'struct 
net *' down to where it's needed...  Please note that I've only compile 
tested this with all the net/sched modules enabled and a allmodconfig 
build.  It's a bit bigger, but passing the argument down through the call 
chain looks simpler than trying to stuff a struct net pointer into the 
various structures and keep that in sync with the network device's network 
namespace.

		-ben
-- 
"Thought is the essence of where you are now."

-- 
pkt_sched: namespace aware ifb v2

Eric Dumazet pointed out that act_mirred needs to find the current net_ns,
and struct net pointer is not provided in the call chain.  His original
patch made use of current->nsproxy->net_ns to find the network namespace,
but this fails to work correctly for userspace code that makes use of
netlink sockets in different network namespaces.  Instead, pass the
"struct net *" down along the call chain to where it is needed.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 drivers/net/ifb.c         |    2 +-
 include/net/act_api.h     |   12 +++++++++---
 include/net/pkt_cls.h     |    7 ++++---
 include/net/sch_generic.h |    2 +-
 net/sched/act_api.c       |   18 ++++++++++--------
 net/sched/act_csum.c      |    2 +-
 net/sched/act_gact.c      |    5 +++--
 net/sched/act_ipt.c       |    2 +-
 net/sched/act_mirred.c    |    7 ++++---
 net/sched/act_nat.c       |    2 +-
 net/sched/act_pedit.c     |    5 +++--
 net/sched/act_police.c    |    5 +++--
 net/sched/act_simple.c    |    5 +++--
 net/sched/act_skbedit.c   |    5 +++--
 net/sched/cls_api.c       |   11 ++++++-----
 net/sched/cls_basic.c     |   13 +++++++------
 net/sched/cls_cgroup.c    |    5 +++--
 net/sched/cls_flow.c      |    4 ++--
 net/sched/cls_fw.c        |   10 +++++-----
 net/sched/cls_route.c     |   15 ++++++++-------
 net/sched/cls_rsvp.h      |    4 ++--
 net/sched/cls_tcindex.c   |   14 ++++++++------
 net/sched/cls_u32.c       |   13 +++++++------
 23 files changed, 95 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 344dceb..8216438 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -90,7 +90,7 @@ static void ri_tasklet(unsigned long dev)
 		u64_stats_update_end(&dp->tsync);
 
 		rcu_read_lock();
-		skb->dev = dev_get_by_index_rcu(&init_net, skb->skb_iif);
+		skb->dev = dev_get_by_index_rcu(dev_net(_dev), skb->skb_iif);
 		if (!skb->dev) {
 			rcu_read_unlock();
 			dev_kfree_skb(skb);
diff --git a/include/net/act_api.h b/include/net/act_api.h
index c739531..112c25c 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -91,7 +91,9 @@ struct tc_action_ops {
 	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
 	int     (*cleanup)(struct tc_action *, int bind);
 	int     (*lookup)(struct tc_action *, u32);
-	int     (*init)(struct nlattr *, struct nlattr *, struct tc_action *, int , int);
+	int     (*init)(struct net *net, struct nlattr *nla,
+			struct nlattr *est, struct tc_action *act, int ovr,
+			int bind);
 	int     (*walk)(struct sk_buff *, struct netlink_callback *, int, struct tc_action *);
 };
 
@@ -116,8 +118,12 @@ extern int tcf_register_action(struct tc_action_ops *a);
 extern int tcf_unregister_action(struct tc_action_ops *a);
 extern void tcf_action_destroy(struct tc_action *a, int bind);
 extern int tcf_action_exec(struct sk_buff *skb, const struct tc_action *a, struct tcf_result *res);
-extern struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est, char *n, int ovr, int bind);
-extern struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est, char *n, int ovr, int bind);
+extern struct tc_action *tcf_action_init(struct net *net, struct nlattr *nla,
+					 struct nlattr *est, char *n, int ovr,
+					 int bind);
+extern struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
+					   struct nlattr *est, char *n, int ovr,
+					   int bind);
 extern int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 9fcc680..1317450 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -126,9 +126,10 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 	return 0;
 }
 
-extern int tcf_exts_validate(struct tcf_proto *tp, struct nlattr **tb,
-	                     struct nlattr *rate_tlv, struct tcf_exts *exts,
-	                     const struct tcf_ext_map *map);
+extern int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
+			     struct nlattr **tb, struct nlattr *rate_tlv,
+			     struct tcf_exts *exts,
+			     const struct tcf_ext_map *map);
 extern void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts);
 extern void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 	                     struct tcf_exts *src);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1540f9c..2d06c2a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -195,7 +195,7 @@ struct tcf_proto_ops {
 
 	unsigned long		(*get)(struct tcf_proto*, u32 handle);
 	void			(*put)(struct tcf_proto*, unsigned long);
-	int			(*change)(struct sk_buff *,
+	int			(*change)(struct net *net, struct sk_buff *,
 					struct tcf_proto*, unsigned long,
 					u32 handle, struct nlattr **,
 					unsigned long *);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 65d240c..8579c4b 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -485,8 +485,9 @@ errout:
 	return err;
 }
 
-struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est,
-				    char *name, int ovr, int bind)
+struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
+				    struct nlattr *est, char *name, int ovr,
+				    int bind)
 {
 	struct tc_action *a;
 	struct tc_action_ops *a_o;
@@ -542,9 +543,9 @@ struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est,
 
 	/* backward compatibility for policer */
 	if (name == NULL)
-		err = a_o->init(tb[TCA_ACT_OPTIONS], est, a, ovr, bind);
+		err = a_o->init(net, tb[TCA_ACT_OPTIONS], est, a, ovr, bind);
 	else
-		err = a_o->init(nla, est, a, ovr, bind);
+		err = a_o->init(net, nla, est, a, ovr, bind);
 	if (err < 0)
 		goto err_free;
 
@@ -566,8 +567,9 @@ err_out:
 	return ERR_PTR(err);
 }
 
-struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est,
-				  char *name, int ovr, int bind)
+struct tc_action *tcf_action_init(struct net *net, struct nlattr *nla,
+				  struct nlattr *est, char *name, int ovr,
+				  int bind)
 {
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
 	struct tc_action *head = NULL, *act, *act_prev = NULL;
@@ -579,7 +581,7 @@ struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est,
 		return ERR_PTR(err);
 
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
-		act = tcf_action_init_1(tb[i], est, name, ovr, bind);
+		act = tcf_action_init_1(net, tb[i], est, name, ovr, bind);
 		if (IS_ERR(act))
 			goto err;
 		act->order = i;
@@ -960,7 +962,7 @@ tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	struct tc_action *a;
 	u32 seq = n->nlmsg_seq;
 
-	act = tcf_action_init(nla, NULL, NULL, ovr, 0);
+	act = tcf_action_init(net, nla, NULL, NULL, ovr, 0);
 	if (act == NULL)
 		goto done;
 	if (IS_ERR(act)) {
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 2c8ad7c..08fa1e8 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -51,7 +51,7 @@ static const struct nla_policy csum_policy[TCA_CSUM_MAX + 1] = {
 	[TCA_CSUM_PARMS] = { .len = sizeof(struct tc_csum), },
 };
 
-static int tcf_csum_init(struct nlattr *nla, struct nlattr *est,
+static int tcf_csum_init(struct net *n, struct nlattr *nla, struct nlattr *est,
 			 struct tc_action *a, int ovr, int bind)
 {
 	struct nlattr *tb[TCA_CSUM_MAX + 1];
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 05d60859..fd2b3cf 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -58,8 +58,9 @@ static const struct nla_policy gact_policy[TCA_GACT_MAX + 1] = {
 	[TCA_GACT_PROB]		= { .len = sizeof(struct tc_gact_p) },
 };
 
-static int tcf_gact_init(struct nlattr *nla, struct nlattr *est,
-			 struct tc_action *a, int ovr, int bind)
+static int tcf_gact_init(struct net *net, struct nlattr *nla,
+			 struct nlattr *est, struct tc_action *a,
+			 int ovr, int bind)
 {
 	struct nlattr *tb[TCA_GACT_MAX + 1];
 	struct tc_gact *parm;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 58fb3c7..0fb9e3f 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -102,7 +102,7 @@ static const struct nla_policy ipt_policy[TCA_IPT_MAX + 1] = {
 	[TCA_IPT_TARG]	= { .len = sizeof(struct xt_entry_target) },
 };
 
-static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
+static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 			struct tc_action *a, int ovr, int bind)
 {
 	struct nlattr *tb[TCA_IPT_MAX + 1];
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 9c0fd0c..5d676ed 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -62,8 +62,9 @@ static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
 	[TCA_MIRRED_PARMS]	= { .len = sizeof(struct tc_mirred) },
 };
 
-static int tcf_mirred_init(struct nlattr *nla, struct nlattr *est,
-			   struct tc_action *a, int ovr, int bind)
+static int tcf_mirred_init(struct net *net, struct nlattr *nla,
+			   struct nlattr *est, struct tc_action *a, int ovr,
+			   int bind)
 {
 	struct nlattr *tb[TCA_MIRRED_MAX + 1];
 	struct tc_mirred *parm;
@@ -88,7 +89,7 @@ static int tcf_mirred_init(struct nlattr *nla, struct nlattr *est,
 		return -EINVAL;
 	}
 	if (parm->ifindex) {
-		dev = __dev_get_by_index(&init_net, parm->ifindex);
+		dev = __dev_get_by_index(net, parm->ifindex);
 		if (dev == NULL)
 			return -ENODEV;
 		switch (dev->type) {
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index b5d029e..876f0ef 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -44,7 +44,7 @@ static const struct nla_policy nat_policy[TCA_NAT_MAX + 1] = {
 	[TCA_NAT_PARMS]	= { .len = sizeof(struct tc_nat) },
 };
 
-static int tcf_nat_init(struct nlattr *nla, struct nlattr *est,
+static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 			struct tc_action *a, int ovr, int bind)
 {
 	struct nlattr *tb[TCA_NAT_MAX + 1];
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 45c53ab..0c3fadd 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -38,8 +38,9 @@ static const struct nla_policy pedit_policy[TCA_PEDIT_MAX + 1] = {
 	[TCA_PEDIT_PARMS]	= { .len = sizeof(struct tc_pedit) },
 };
 
-static int tcf_pedit_init(struct nlattr *nla, struct nlattr *est,
-			  struct tc_action *a, int ovr, int bind)
+static int tcf_pedit_init(struct net *net, struct nlattr *nla,
+			  struct nlattr *est, struct tc_action *a,
+			  int ovr, int bind)
 {
 	struct nlattr *tb[TCA_PEDIT_MAX + 1];
 	struct tc_pedit *parm;
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index a9de232..8dbd695 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -130,8 +130,9 @@ static const struct nla_policy police_policy[TCA_POLICE_MAX + 1] = {
 	[TCA_POLICE_RESULT]	= { .type = NLA_U32 },
 };
 
-static int tcf_act_police_locate(struct nlattr *nla, struct nlattr *est,
-				 struct tc_action *a, int ovr, int bind)
+static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
+				 struct nlattr *est, struct tc_action *a,
+				 int ovr, int bind)
 {
 	unsigned int h;
 	int ret = 0, err;
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 3714f60..7725eb4 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -95,8 +95,9 @@ static const struct nla_policy simple_policy[TCA_DEF_MAX + 1] = {
 	[TCA_DEF_DATA]	= { .type = NLA_STRING, .len = SIMP_MAX_DATA },
 };
 
-static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
-			 struct tc_action *a, int ovr, int bind)
+static int tcf_simp_init(struct net *net, struct nlattr *nla,
+			 struct nlattr *est, struct tc_action *a,
+			 int ovr, int bind)
 {
 	struct nlattr *tb[TCA_DEF_MAX + 1];
 	struct tc_defact *parm;
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 476e0fa..cb42211 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -67,8 +67,9 @@ static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
 	[TCA_SKBEDIT_MARK]		= { .len = sizeof(u32) },
 };
 
-static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
-			 struct tc_action *a, int ovr, int bind)
+static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
+			    struct nlattr *est, struct tc_action *a,
+			    int ovr, int bind)
 {
 	struct nlattr *tb[TCA_SKBEDIT_MAX + 1];
 	struct tc_skbedit *parm;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index ff55ed6..964f5e4 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -321,7 +321,7 @@ replay:
 		}
 	}
 
-	err = tp->ops->change(skb, tp, cl, t->tcm_handle, tca, &fh);
+	err = tp->ops->change(net, skb, tp, cl, t->tcm_handle, tca, &fh);
 	if (err == 0) {
 		if (tp_created) {
 			spin_lock_bh(root_lock);
@@ -508,7 +508,7 @@ void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts)
 }
 EXPORT_SYMBOL(tcf_exts_destroy);
 
-int tcf_exts_validate(struct tcf_proto *tp, struct nlattr **tb,
+int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 		  struct nlattr *rate_tlv, struct tcf_exts *exts,
 		  const struct tcf_ext_map *map)
 {
@@ -519,7 +519,7 @@ int tcf_exts_validate(struct tcf_proto *tp, struct nlattr **tb,
 		struct tc_action *act;
 
 		if (map->police && tb[map->police]) {
-			act = tcf_action_init_1(tb[map->police], rate_tlv,
+			act = tcf_action_init_1(net, tb[map->police], rate_tlv,
 						"police", TCA_ACT_NOREPLACE,
 						TCA_ACT_BIND);
 			if (IS_ERR(act))
@@ -528,8 +528,9 @@ int tcf_exts_validate(struct tcf_proto *tp, struct nlattr **tb,
 			act->type = TCA_OLD_COMPAT;
 			exts->action = act;
 		} else if (map->action && tb[map->action]) {
-			act = tcf_action_init(tb[map->action], rate_tlv, NULL,
-					      TCA_ACT_NOREPLACE, TCA_ACT_BIND);
+			act = tcf_action_init(net, tb[map->action], rate_tlv,
+					      NULL, TCA_ACT_NOREPLACE,
+					      TCA_ACT_BIND);
 			if (IS_ERR(act))
 				return PTR_ERR(act);
 
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 344a11b..d76a35d 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -132,15 +132,16 @@ static const struct nla_policy basic_policy[TCA_BASIC_MAX + 1] = {
 	[TCA_BASIC_EMATCHES]	= { .type = NLA_NESTED },
 };
 
-static int basic_set_parms(struct tcf_proto *tp, struct basic_filter *f,
-			   unsigned long base, struct nlattr **tb,
+static int basic_set_parms(struct net *net, struct tcf_proto *tp,
+			   struct basic_filter *f, unsigned long base,
+			   struct nlattr **tb,
 			   struct nlattr *est)
 {
 	int err = -EINVAL;
 	struct tcf_exts e;
 	struct tcf_ematch_tree t;
 
-	err = tcf_exts_validate(tp, tb, est, &e, &basic_ext_map);
+	err = tcf_exts_validate(net, tp, tb, est, &e, &basic_ext_map);
 	if (err < 0)
 		return err;
 
@@ -162,7 +163,7 @@ errout:
 	return err;
 }
 
-static int basic_change(struct sk_buff *in_skb,
+static int basic_change(struct net *net, struct sk_buff *in_skb,
 			struct tcf_proto *tp, unsigned long base, u32 handle,
 			struct nlattr **tca, unsigned long *arg)
 {
@@ -182,7 +183,7 @@ static int basic_change(struct sk_buff *in_skb,
 	if (f != NULL) {
 		if (handle && f->handle != handle)
 			return -EINVAL;
-		return basic_set_parms(tp, f, base, tb, tca[TCA_RATE]);
+		return basic_set_parms(net, tp, f, base, tb, tca[TCA_RATE]);
 	}
 
 	err = -ENOBUFS;
@@ -208,7 +209,7 @@ static int basic_change(struct sk_buff *in_skb,
 		f->handle = head->hgenerator;
 	}
 
-	err = basic_set_parms(tp, f, base, tb, tca[TCA_RATE]);
+	err = basic_set_parms(net, tp, f, base, tb, tca[TCA_RATE]);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 6db7855..3a294eb 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -178,7 +178,7 @@ static const struct nla_policy cgroup_policy[TCA_CGROUP_MAX + 1] = {
 	[TCA_CGROUP_EMATCHES]	= { .type = NLA_NESTED },
 };
 
-static int cls_cgroup_change(struct sk_buff *in_skb,
+static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 			     struct tcf_proto *tp, unsigned long base,
 			     u32 handle, struct nlattr **tca,
 			     unsigned long *arg)
@@ -215,7 +215,8 @@ static int cls_cgroup_change(struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &cgroup_ext_map);
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e,
+				&cgroup_ext_map);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index ce82d0c..e6c1427 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -351,7 +351,7 @@ static const struct nla_policy flow_policy[TCA_FLOW_MAX + 1] = {
 	[TCA_FLOW_PERTURB]	= { .type = NLA_U32 },
 };
 
-static int flow_change(struct sk_buff *in_skb, 
+static int flow_change(struct net *net, struct sk_buff *in_skb,
 		       struct tcf_proto *tp, unsigned long base,
 		       u32 handle, struct nlattr **tca,
 		       unsigned long *arg)
@@ -397,7 +397,7 @@ static int flow_change(struct sk_buff *in_skb,
 			return -EOPNOTSUPP;
 	}
 
-	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &flow_ext_map);
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, &flow_ext_map);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 4075a0a..1135d82 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -192,7 +192,7 @@ static const struct nla_policy fw_policy[TCA_FW_MAX + 1] = {
 };
 
 static int
-fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
+fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	struct nlattr **tb, struct nlattr **tca, unsigned long base)
 {
 	struct fw_head *head = (struct fw_head *)tp->root;
@@ -200,7 +200,7 @@ fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
 	u32 mask;
 	int err;
 
-	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &fw_ext_map);
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, &fw_ext_map);
 	if (err < 0)
 		return err;
 
@@ -233,7 +233,7 @@ errout:
 	return err;
 }
 
-static int fw_change(struct sk_buff *in_skb,
+static int fw_change(struct net *net, struct sk_buff *in_skb,
 		     struct tcf_proto *tp, unsigned long base,
 		     u32 handle,
 		     struct nlattr **tca,
@@ -255,7 +255,7 @@ static int fw_change(struct sk_buff *in_skb,
 	if (f != NULL) {
 		if (f->id != handle && handle)
 			return -EINVAL;
-		return fw_change_attrs(tp, f, tb, tca, base);
+		return fw_change_attrs(net, tp, f, tb, tca, base);
 	}
 
 	if (!handle)
@@ -282,7 +282,7 @@ static int fw_change(struct sk_buff *in_skb,
 
 	f->id = handle;
 
-	err = fw_change_attrs(tp, f, tb, tca, base);
+	err = fw_change_attrs(net, tp, f, tb, tca, base);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index c10d57b..37da567 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -335,9 +335,10 @@ static const struct nla_policy route4_policy[TCA_ROUTE4_MAX + 1] = {
 	[TCA_ROUTE4_IIF]	= { .type = NLA_U32 },
 };
 
-static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
-	struct route4_filter *f, u32 handle, struct route4_head *head,
-	struct nlattr **tb, struct nlattr *est, int new)
+static int route4_set_parms(struct net *net, struct tcf_proto *tp,
+			    unsigned long base, struct route4_filter *f,
+			    u32 handle, struct route4_head *head,
+			    struct nlattr **tb, struct nlattr *est, int new)
 {
 	int err;
 	u32 id = 0, to = 0, nhandle = 0x8000;
@@ -346,7 +347,7 @@ static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 	struct route4_bucket *b;
 	struct tcf_exts e;
 
-	err = tcf_exts_validate(tp, tb, est, &e, &route_ext_map);
+	err = tcf_exts_validate(net, tp, tb, est, &e, &route_ext_map);
 	if (err < 0)
 		return err;
 
@@ -427,7 +428,7 @@ errout:
 	return err;
 }
 
-static int route4_change(struct sk_buff *in_skb,
+static int route4_change(struct net *net, struct sk_buff *in_skb,
 		       struct tcf_proto *tp, unsigned long base,
 		       u32 handle,
 		       struct nlattr **tca,
@@ -457,7 +458,7 @@ static int route4_change(struct sk_buff *in_skb,
 		if (f->bkt)
 			old_handle = f->handle;
 
-		err = route4_set_parms(tp, base, f, handle, head, tb,
+		err = route4_set_parms(net, tp, base, f, handle, head, tb,
 			tca[TCA_RATE], 0);
 		if (err < 0)
 			return err;
@@ -480,7 +481,7 @@ static int route4_change(struct sk_buff *in_skb,
 	if (f == NULL)
 		goto errout;
 
-	err = route4_set_parms(tp, base, f, handle, head, tb,
+	err = route4_set_parms(net, tp, base, f, handle, head, tb,
 		tca[TCA_RATE], 1);
 	if (err < 0)
 		goto errout;
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 494bbb9..252d8b0 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -416,7 +416,7 @@ static const struct nla_policy rsvp_policy[TCA_RSVP_MAX + 1] = {
 	[TCA_RSVP_PINFO]	= { .len = sizeof(struct tc_rsvp_pinfo) },
 };
 
-static int rsvp_change(struct sk_buff *in_skb,
+static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 		       struct tcf_proto *tp, unsigned long base,
 		       u32 handle,
 		       struct nlattr **tca,
@@ -440,7 +440,7 @@ static int rsvp_change(struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &rsvp_ext_map);
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, &rsvp_ext_map);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index a1293b4..b86535a 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -197,9 +197,10 @@ static const struct nla_policy tcindex_policy[TCA_TCINDEX_MAX + 1] = {
 };
 
 static int
-tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
-		  struct tcindex_data *p, struct tcindex_filter_result *r,
-		  struct nlattr **tb, struct nlattr *est)
+tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
+		  u32 handle, struct tcindex_data *p,
+		  struct tcindex_filter_result *r, struct nlattr **tb,
+		 struct nlattr *est)
 {
 	int err, balloc = 0;
 	struct tcindex_filter_result new_filter_result, *old_r = r;
@@ -208,7 +209,7 @@ tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 	struct tcindex_filter *f = NULL; /* make gcc behave */
 	struct tcf_exts e;
 
-	err = tcf_exts_validate(tp, tb, est, &e, &tcindex_ext_map);
+	err = tcf_exts_validate(net, tp, tb, est, &e, &tcindex_ext_map);
 	if (err < 0)
 		return err;
 
@@ -332,7 +333,7 @@ errout:
 }
 
 static int
-tcindex_change(struct sk_buff *in_skb,
+tcindex_change(struct net *net, struct sk_buff *in_skb,
 	       struct tcf_proto *tp, unsigned long base, u32 handle,
 	       struct nlattr **tca, unsigned long *arg)
 {
@@ -353,7 +354,8 @@ tcindex_change(struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	return tcindex_set_parms(tp, base, handle, p, r, tb, tca[TCA_RATE]);
+	return tcindex_set_parms(net, tp, base, handle, p, r, tb,
+				 tca[TCA_RATE]);
 }
 
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index c7c27bc..eb07a1e 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -488,15 +488,15 @@ static const struct nla_policy u32_policy[TCA_U32_MAX + 1] = {
 	[TCA_U32_MARK]		= { .len = sizeof(struct tc_u32_mark) },
 };
 
-static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
-			 struct tc_u_hnode *ht,
+static int u32_set_parms(struct net *net, struct tcf_proto *tp,
+			 unsigned long base, struct tc_u_hnode *ht,
 			 struct tc_u_knode *n, struct nlattr **tb,
 			 struct nlattr *est)
 {
 	int err;
 	struct tcf_exts e;
 
-	err = tcf_exts_validate(tp, tb, est, &e, &u32_ext_map);
+	err = tcf_exts_validate(net, tp, tb, est, &e, &u32_ext_map);
 	if (err < 0)
 		return err;
 
@@ -544,7 +544,7 @@ errout:
 	return err;
 }
 
-static int u32_change(struct sk_buff *in_skb,
+static int u32_change(struct net *net, struct sk_buff *in_skb,
 		      struct tcf_proto *tp, unsigned long base, u32 handle,
 		      struct nlattr **tca,
 		      unsigned long *arg)
@@ -570,7 +570,8 @@ static int u32_change(struct sk_buff *in_skb,
 		if (TC_U32_KEY(n->handle) == 0)
 			return -EINVAL;
 
-		return u32_set_parms(tp, base, n->ht_up, n, tb, tca[TCA_RATE]);
+		return u32_set_parms(net, tp, base, n->ht_up, n, tb,
+				     tca[TCA_RATE]);
 	}
 
 	if (tb[TCA_U32_DIVISOR]) {
@@ -656,7 +657,7 @@ static int u32_change(struct sk_buff *in_skb,
 	}
 #endif
 
-	err = u32_set_parms(tp, base, ht, n, tb, tca[TCA_RATE]);
+	err = u32_set_parms(net, tp, base, ht, n, tb, tca[TCA_RATE]);
 	if (err == 0) {
 		struct tc_u_knode **ins;
 		for (ins = &ht->ht[TC_U32_HASH(handle)]; *ins; ins = &(*ins)->next)
