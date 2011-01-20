From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net_sched: cleanups
Date: Thu, 20 Jan 2011 06:26:56 +0100
Message-ID: <1295501217.2653.480.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:36128 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768Ab1ATF1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 00:27:06 -0500
Received: by wwi17 with SMTP id 17so1064974wwi.1
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 21:27:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup net/sched code to current CodingStyle and practices.

Reduce inline abuse

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/act_api.c     |   46 ++--
 net/sched/act_csum.c    |    2 
 net/sched/act_gact.c    |    8 
 net/sched/act_ipt.c     |   16 -
 net/sched/act_mirred.c  |    4 
 net/sched/act_nat.c     |    2 
 net/sched/act_pedit.c   |   10 -
 net/sched/act_police.c  |    9 
 net/sched/act_simple.c  |   10 -
 net/sched/act_skbedit.c |    8 
 net/sched/cls_api.c     |   33 ++-
 net/sched/cls_basic.c   |   17 -
 net/sched/cls_cgroup.c  |    8 
 net/sched/cls_flow.c    |    4 
 net/sched/cls_fw.c      |   38 +---
 net/sched/cls_route.c   |  126 +++++++------
 net/sched/cls_rsvp.h    |   95 +++++-----
 net/sched/cls_tcindex.c |    2 
 net/sched/cls_u32.c     |   77 ++++----
 net/sched/em_cmp.c      |   47 ++--
 net/sched/em_meta.c     |   42 +---
 net/sched/em_nbyte.c    |    3 
 net/sched/em_text.c     |    3 
 net/sched/em_u32.c      |    2 
 net/sched/ematch.c      |   37 ++-
 net/sched/sch_api.c     |  137 ++++++++------
 net/sched/sch_atm.c     |   16 -
 net/sched/sch_cbq.c     |  358 +++++++++++++++++++-------------------
 net/sched/sch_dsmark.c  |   21 +-
 net/sched/sch_fifo.c    |    9 
 net/sched/sch_generic.c |   29 +--
 net/sched/sch_gred.c    |   85 ++++-----
 net/sched/sch_hfsc.c    |   35 +--
 net/sched/sch_htb.c     |  104 ++++++-----
 net/sched/sch_multiq.c  |    8 
 net/sched/sch_netem.c   |    6 
 net/sched/sch_prio.c    |   34 +--
 net/sched/sch_red.c     |   61 +++---
 net/sched/sch_sfq.c     |   18 -
 net/sched/sch_tbf.c     |   37 ++-
 net/sched/sch_teql.c    |   36 +--
 41 files changed, 842 insertions(+), 801 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 23b25f8..15873e1 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -78,7 +78,7 @@ static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 			   struct tc_action *a, struct tcf_hashinfo *hinfo)
 {
 	struct tcf_common *p;
-	int err = 0, index = -1,i = 0, s_i = 0, n_i = 0;
+	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	struct nlattr *nest;
 
 	read_lock_bh(hinfo->lock);
@@ -126,7 +126,7 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 {
 	struct tcf_common *p, *s_p;
 	struct nlattr *nest;
-	int i= 0, n_i = 0;
+	int i = 0, n_i = 0;
 
 	nest = nla_nest_start(skb, a->order);
 	if (nest == NULL)
@@ -138,7 +138,7 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 		while (p != NULL) {
 			s_p = p->tcfc_next;
 			if (ACT_P_DELETED == tcf_hash_release(p, 0, hinfo))
-				 module_put(a->ops->owner);
+				module_put(a->ops->owner);
 			n_i++;
 			p = s_p;
 		}
@@ -447,7 +447,8 @@ tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
-	if ((err = tcf_action_dump_old(skb, a, bind, ref)) > 0) {
+	err = tcf_action_dump_old(skb, a, bind, ref);
+	if (err > 0) {
 		nla_nest_end(skb, nest);
 		return err;
 	}
@@ -491,7 +492,7 @@ struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est,
 	struct tc_action *a;
 	struct tc_action_ops *a_o;
 	char act_name[IFNAMSIZ];
-	struct nlattr *tb[TCA_ACT_MAX+1];
+	struct nlattr *tb[TCA_ACT_MAX + 1];
 	struct nlattr *kind;
 	int err;
 
@@ -549,9 +550,9 @@ struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est,
 		goto err_free;
 
 	/* module count goes up only when brand new policy is created
-	   if it exists and is only bound to in a_o->init() then
-	   ACT_P_CREATED is not returned (a zero is).
-	*/
+	 * if it exists and is only bound to in a_o->init() then
+	 * ACT_P_CREATED is not returned (a zero is).
+	 */
 	if (err != ACT_P_CREATED)
 		module_put(a_o->owner);
 	a->ops = a_o;
@@ -569,7 +570,7 @@ err_out:
 struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est,
 				  char *name, int ovr, int bind)
 {
-	struct nlattr *tb[TCA_ACT_MAX_PRIO+1];
+	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
 	struct tc_action *head = NULL, *act, *act_prev = NULL;
 	int err;
 	int i;
@@ -697,7 +698,7 @@ act_get_notify(struct net *net, u32 pid, struct nlmsghdr *n,
 static struct tc_action *
 tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 {
-	struct nlattr *tb[TCA_ACT_MAX+1];
+	struct nlattr *tb[TCA_ACT_MAX + 1];
 	struct tc_action *a;
 	int index;
 	int err;
@@ -770,7 +771,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	struct tcamsg *t;
 	struct netlink_callback dcb;
 	struct nlattr *nest;
-	struct nlattr *tb[TCA_ACT_MAX+1];
+	struct nlattr *tb[TCA_ACT_MAX + 1];
 	struct nlattr *kind;
 	struct tc_action *a = create_a(0);
 	int err = -ENOMEM;
@@ -821,7 +822,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	nlh->nlmsg_flags |= NLM_F_ROOT;
 	module_put(a->ops->owner);
 	kfree(a);
-	err = rtnetlink_send(skb, net, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
+	err = rtnetlink_send(skb, net, pid, RTNLGRP_TC,
+			     n->nlmsg_flags & NLM_F_ECHO);
 	if (err > 0)
 		return 0;
 
@@ -842,14 +844,14 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	      u32 pid, int event)
 {
 	int i, ret;
-	struct nlattr *tb[TCA_ACT_MAX_PRIO+1];
+	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
 	struct tc_action *head = NULL, *act, *act_prev = NULL;
 
 	ret = nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL);
 	if (ret < 0)
 		return ret;
 
-	if (event == RTM_DELACTION && n->nlmsg_flags&NLM_F_ROOT) {
+	if (event == RTM_DELACTION && n->nlmsg_flags & NLM_F_ROOT) {
 		if (tb[1] != NULL)
 			return tca_action_flush(net, tb[1], n, pid);
 		else
@@ -892,7 +894,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 		/* now do the delete */
 		tcf_action_destroy(head, 0);
 		ret = rtnetlink_send(skb, net, pid, RTNLGRP_TC,
-				     n->nlmsg_flags&NLM_F_ECHO);
+				     n->nlmsg_flags & NLM_F_ECHO);
 		if (ret > 0)
 			return 0;
 		return ret;
@@ -936,7 +938,7 @@ static int tcf_add_notify(struct net *net, struct tc_action *a,
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	NETLINK_CB(skb).dst_group = RTNLGRP_TC;
 
-	err = rtnetlink_send(skb, net, pid, RTNLGRP_TC, flags&NLM_F_ECHO);
+	err = rtnetlink_send(skb, net, pid, RTNLGRP_TC, flags & NLM_F_ECHO);
 	if (err > 0)
 		err = 0;
 	return err;
@@ -967,7 +969,7 @@ tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 
 	/* dump then free all the actions after update; inserted policy
 	 * stays intact
-	 * */
+	 */
 	ret = tcf_add_notify(net, act, pid, seq, RTM_NEWACTION, n->nlmsg_flags);
 	for (a = act; a; a = act) {
 		act = a->next;
@@ -993,8 +995,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		return -EINVAL;
 	}
 
-	/* n->nlmsg_flags&NLM_F_CREATE
-	 * */
+	/* n->nlmsg_flags & NLM_F_CREATE */
 	switch (n->nlmsg_type) {
 	case RTM_NEWACTION:
 		/* we are going to assume all other flags
@@ -1003,7 +1004,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		 * but since we want avoid ambiguity (eg when flags
 		 * is zero) then just set this
 		 */
-		if (n->nlmsg_flags&NLM_F_REPLACE)
+		if (n->nlmsg_flags & NLM_F_REPLACE)
 			ovr = 1;
 replay:
 		ret = tcf_action_add(net, tca[TCA_ACT_TAB], n, pid, ovr);
@@ -1028,7 +1029,7 @@ replay:
 static struct nlattr *
 find_dump_kind(const struct nlmsghdr *n)
 {
-	struct nlattr *tb1, *tb2[TCA_ACT_MAX+1];
+	struct nlattr *tb1, *tb2[TCA_ACT_MAX + 1];
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
 	struct nlattr *nla[TCAA_MAX + 1];
 	struct nlattr *kind;
@@ -1071,9 +1072,8 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	}
 
 	a_o = tc_lookup_action(kind);
-	if (a_o == NULL) {
+	if (a_o == NULL)
 		return 0;
-	}
 
 	memset(&a, 0, sizeof(struct tc_action));
 	a.ops = a_o;
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 83ddfc0..6cdf9ab 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -63,7 +63,7 @@ static int tcf_csum_init(struct nlattr *nla, struct nlattr *est,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_CSUM_MAX, nla,csum_policy);
+	err = nla_parse_nested(tb, TCA_CSUM_MAX, nla, csum_policy);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index c2ed90a..2b4ab4b 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -50,7 +50,7 @@ static int gact_determ(struct tcf_gact *gact)
 }
 
 typedef int (*g_rand)(struct tcf_gact *gact);
-static g_rand gact_rand[MAX_RAND]= { NULL, gact_net_rand, gact_determ };
+static g_rand gact_rand[MAX_RAND] = { NULL, gact_net_rand, gact_determ };
 #endif /* CONFIG_GACT_PROB */
 
 static const struct nla_policy gact_policy[TCA_GACT_MAX + 1] = {
@@ -89,7 +89,7 @@ static int tcf_gact_init(struct nlattr *nla, struct nlattr *est,
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*gact),
 				     bind, &gact_idx_gen, &gact_hash_info);
 		if (IS_ERR(pc))
-		    return PTR_ERR(pc);
+			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
@@ -205,9 +205,9 @@ MODULE_LICENSE("GPL");
 static int __init gact_init_module(void)
 {
 #ifdef CONFIG_GACT_PROB
-	printk(KERN_INFO "GACT probability on\n");
+	pr_info("GACT probability on\n");
 #else
-	printk(KERN_INFO "GACT probability NOT on\n");
+	pr_info("GACT probability NOT on\n");
 #endif
 	return tcf_register_action(&act_gact_ops);
 }
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index c2a7c20..9fc211a 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -138,7 +138,7 @@ static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
 		pc = tcf_hash_create(index, est, a, sizeof(*ipt), bind,
 				     &ipt_idx_gen, &ipt_hash_info);
 		if (IS_ERR(pc))
-		    return PTR_ERR(pc);
+			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
@@ -162,7 +162,8 @@ static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
 	if (unlikely(!t))
 		goto err2;
 
-	if ((err = ipt_init_target(t, tname, hook)) < 0)
+	err = ipt_init_target(t, tname, hook);
+	if (err < 0)
 		goto err3;
 
 	spin_lock_bh(&ipt->tcf_lock);
@@ -212,8 +213,9 @@ static int tcf_ipt(struct sk_buff *skb, struct tc_action *a,
 	bstats_update(&ipt->tcf_bstats, skb);
 
 	/* yes, we have to worry about both in and out dev
-	 worry later - danger - this API seems to have changed
-	 from earlier kernels */
+	 * worry later - danger - this API seems to have changed
+	 * from earlier kernels
+	 */
 	par.in       = skb->dev;
 	par.out      = NULL;
 	par.hooknum  = ipt->tcfi_hook;
@@ -253,9 +255,9 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 	struct tc_cnt c;
 
 	/* for simple targets kernel size == user size
-	** user name = target name
-	** for foolproof you need to not assume this
-	*/
+	 * user name = target name
+	 * for foolproof you need to not assume this
+	 */
 
 	t = kmemdup(ipt->tcfi_t, ipt->tcfi_t->u.user.target_size, GFP_ATOMIC);
 	if (unlikely(!t))
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index d765067..961386e 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -41,13 +41,13 @@ static struct tcf_hashinfo mirred_hash_info = {
 	.lock	=	&mirred_lock,
 };
 
-static inline int tcf_mirred_release(struct tcf_mirred *m, int bind)
+static int tcf_mirred_release(struct tcf_mirred *m, int bind)
 {
 	if (m) {
 		if (bind)
 			m->tcf_bindcnt--;
 		m->tcf_refcnt--;
-		if(!m->tcf_bindcnt && m->tcf_refcnt <= 0) {
+		if (!m->tcf_bindcnt && m->tcf_refcnt <= 0) {
 			list_del(&m->tcfm_list);
 			if (m->tcfm_dev)
 				dev_put(m->tcfm_dev);
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 178a4bd..762b027 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -69,7 +69,7 @@ static int tcf_nat_init(struct nlattr *nla, struct nlattr *est,
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
 				     &nat_idx_gen, &nat_hash_info);
 		if (IS_ERR(pc))
-		    return PTR_ERR(pc);
+			return PTR_ERR(pc);
 		p = to_tcf_nat(pc);
 		ret = ACT_P_CREATED;
 	} else {
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 445bef7..50c7c06 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -70,7 +70,7 @@ static int tcf_pedit_init(struct nlattr *nla, struct nlattr *est,
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
 				     &pedit_idx_gen, &pedit_hash_info);
 		if (IS_ERR(pc))
-		    return PTR_ERR(pc);
+			return PTR_ERR(pc);
 		p = to_pedit(pc);
 		keys = kmalloc(ksize, GFP_KERNEL);
 		if (keys == NULL) {
@@ -127,11 +127,9 @@ static int tcf_pedit(struct sk_buff *skb, struct tc_action *a,
 	int i, munged = 0;
 	unsigned int off;
 
-	if (skb_cloned(skb)) {
-		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-			return p->tcf_action;
-		}
-	}
+	if (skb_cloned(skb) &&
+	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+		return p->tcf_action;
 
 	off = skb_network_offset(skb);
 
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index e2f08b1..8a16307 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -22,8 +22,8 @@
 #include <net/act_api.h>
 #include <net/netlink.h>
 
-#define L2T(p,L)   qdisc_l2t((p)->tcfp_R_tab, L)
-#define L2T_P(p,L) qdisc_l2t((p)->tcfp_P_tab, L)
+#define L2T(p, L)   qdisc_l2t((p)->tcfp_R_tab, L)
+#define L2T_P(p, L) qdisc_l2t((p)->tcfp_P_tab, L)
 
 #define POL_TAB_MASK     15
 static struct tcf_common *tcf_police_ht[POL_TAB_MASK + 1];
@@ -37,8 +37,7 @@ static struct tcf_hashinfo police_hash_info = {
 };
 
 /* old policer structure from before tc actions */
-struct tc_police_compat
-{
+struct tc_police_compat {
 	u32			index;
 	int			action;
 	u32			limit;
@@ -139,7 +138,7 @@ static const struct nla_policy police_policy[TCA_POLICE_MAX + 1] = {
 static int tcf_act_police_locate(struct nlattr *nla, struct nlattr *est,
 				 struct tc_action *a, int ovr, int bind)
 {
-	unsigned h;
+	unsigned int h;
 	int ret = 0, err;
 	struct nlattr *tb[TCA_POLICE_MAX + 1];
 	struct tc_police *parm;
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 7287cff..a34a22d 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -47,7 +47,7 @@ static int tcf_simp(struct sk_buff *skb, struct tc_action *a, struct tcf_result
 	/* print policy string followed by _ then packet count
 	 * Example if this was the 3rd packet and the string was "hello"
 	 * then it would look like "hello_3" (without quotes)
-	 **/
+	 */
 	pr_info("simple: %s_%d\n",
 	       (char *)d->tcfd_defdata, d->tcf_bstats.packets);
 	spin_unlock(&d->tcf_lock);
@@ -125,7 +125,7 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
 				     &simp_idx_gen, &simp_hash_info);
 		if (IS_ERR(pc))
-		    return PTR_ERR(pc);
+			return PTR_ERR(pc);
 
 		d = to_defact(pc);
 		ret = alloc_defdata(d, defdata);
@@ -149,7 +149,7 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 	return ret;
 }
 
-static inline int tcf_simp_cleanup(struct tc_action *a, int bind)
+static int tcf_simp_cleanup(struct tc_action *a, int bind)
 {
 	struct tcf_defact *d = a->priv;
 
@@ -158,8 +158,8 @@ static inline int tcf_simp_cleanup(struct tc_action *a, int bind)
 	return 0;
 }
 
-static inline int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
-				int bind, int ref)
+static int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
+			 int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_defact *d = a->priv;
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 836f5fe..5f6f0c7 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -113,7 +113,7 @@ static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
 				     &skbedit_idx_gen, &skbedit_hash_info);
 		if (IS_ERR(pc))
-		    return PTR_ERR(pc);
+			return PTR_ERR(pc);
 
 		d = to_skbedit(pc);
 		ret = ACT_P_CREATED;
@@ -144,7 +144,7 @@ static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
 	return ret;
 }
 
-static inline int tcf_skbedit_cleanup(struct tc_action *a, int bind)
+static int tcf_skbedit_cleanup(struct tc_action *a, int bind)
 {
 	struct tcf_skbedit *d = a->priv;
 
@@ -153,8 +153,8 @@ static inline int tcf_skbedit_cleanup(struct tc_action *a, int bind)
 	return 0;
 }
 
-static inline int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
-				int bind, int ref)
+static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
+			    int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_skbedit *d = a->priv;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 5fd0c28..bb2c523 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -85,7 +85,7 @@ int unregister_tcf_proto_ops(struct tcf_proto_ops *ops)
 	int rc = -ENOENT;
 
 	write_lock(&cls_mod_lock);
-	for (tp = &tcf_proto_base; (t=*tp) != NULL; tp = &t->next)
+	for (tp = &tcf_proto_base; (t = *tp) != NULL; tp = &t->next)
 		if (t == ops)
 			break;
 
@@ -111,7 +111,7 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 	u32 first = TC_H_MAKE(0xC0000000U, 0U);
 
 	if (tp)
-		first = tp->prio-1;
+		first = tp->prio - 1;
 
 	return first;
 }
@@ -149,7 +149,8 @@ replay:
 
 	if (prio == 0) {
 		/* If no priority is given, user wants we allocated it. */
-		if (n->nlmsg_type != RTM_NEWTFILTER || !(n->nlmsg_flags&NLM_F_CREATE))
+		if (n->nlmsg_type != RTM_NEWTFILTER ||
+		    !(n->nlmsg_flags & NLM_F_CREATE))
 			return -ENOENT;
 		prio = TC_H_MAKE(0x80000000U, 0U);
 	}
@@ -176,7 +177,8 @@ replay:
 	}
 
 	/* Is it classful? */
-	if ((cops = q->ops->cl_ops) == NULL)
+	cops = q->ops->cl_ops;
+	if (!cops)
 		return -EINVAL;
 
 	if (cops->tcf_chain == NULL)
@@ -196,10 +198,11 @@ replay:
 		goto errout;
 
 	/* Check the chain for existence of proto-tcf with this priority */
-	for (back = chain; (tp=*back) != NULL; back = &tp->next) {
+	for (back = chain; (tp = *back) != NULL; back = &tp->next) {
 		if (tp->prio >= prio) {
 			if (tp->prio == prio) {
-				if (!nprio || (tp->protocol != protocol && protocol))
+				if (!nprio ||
+				    (tp->protocol != protocol && protocol))
 					goto errout;
 			} else
 				tp = NULL;
@@ -216,7 +219,8 @@ replay:
 			goto errout;
 
 		err = -ENOENT;
-		if (n->nlmsg_type != RTM_NEWTFILTER || !(n->nlmsg_flags&NLM_F_CREATE))
+		if (n->nlmsg_type != RTM_NEWTFILTER ||
+		    !(n->nlmsg_flags & NLM_F_CREATE))
 			goto errout;
 
 
@@ -420,7 +424,8 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 
 	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
 		return skb->len;
-	if ((dev = __dev_get_by_index(net, tcm->tcm_ifindex)) == NULL)
+	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
+	if (!dev)
 		return skb->len;
 
 	if (!tcm->tcm_parent)
@@ -429,7 +434,8 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 		q = qdisc_lookup(dev, TC_H_MAJ(tcm->tcm_parent));
 	if (!q)
 		goto out;
-	if ((cops = q->ops->cl_ops) == NULL)
+	cops = q->ops->cl_ops;
+	if (!cops)
 		goto errout;
 	if (cops->tcf_chain == NULL)
 		goto errout;
@@ -444,8 +450,9 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 
 	s_t = cb->args[0];
 
-	for (tp=*chain, t=0; tp; tp = tp->next, t++) {
-		if (t < s_t) continue;
+	for (tp = *chain, t = 0; tp; tp = tp->next, t++) {
+		if (t < s_t)
+			continue;
 		if (TC_H_MAJ(tcm->tcm_info) &&
 		    TC_H_MAJ(tcm->tcm_info) != tp->prio)
 			continue;
@@ -468,10 +475,10 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 		arg.skb = skb;
 		arg.cb = cb;
 		arg.w.stop = 0;
-		arg.w.skip = cb->args[1]-1;
+		arg.w.skip = cb->args[1] - 1;
 		arg.w.count = 0;
 		tp->ops->walk(tp, &arg.w);
-		cb->args[1] = arg.w.count+1;
+		cb->args[1] = arg.w.count + 1;
 		if (arg.w.stop)
 			break;
 	}
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index f23d915..8be8872 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -21,14 +21,12 @@
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
-struct basic_head
-{
+struct basic_head {
 	u32			hgenerator;
 	struct list_head	flist;
 };
 
-struct basic_filter
-{
+struct basic_filter {
 	u32			handle;
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
@@ -92,8 +90,7 @@ static int basic_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static inline void basic_delete_filter(struct tcf_proto *tp,
-				       struct basic_filter *f)
+static void basic_delete_filter(struct tcf_proto *tp, struct basic_filter *f)
 {
 	tcf_unbind_filter(tp, &f->res);
 	tcf_exts_destroy(tp, &f->exts);
@@ -135,9 +132,9 @@ static const struct nla_policy basic_policy[TCA_BASIC_MAX + 1] = {
 	[TCA_BASIC_EMATCHES]	= { .type = NLA_NESTED },
 };
 
-static inline int basic_set_parms(struct tcf_proto *tp, struct basic_filter *f,
-				  unsigned long base, struct nlattr **tb,
-				  struct nlattr *est)
+static int basic_set_parms(struct tcf_proto *tp, struct basic_filter *f,
+			   unsigned long base, struct nlattr **tb,
+			   struct nlattr *est)
 {
 	int err = -EINVAL;
 	struct tcf_exts e;
@@ -203,7 +200,7 @@ static int basic_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 		} while (--i > 0 && basic_get(tp, head->hgenerator));
 
 		if (i <= 0) {
-			printk(KERN_ERR "Insufficient number of handles\n");
+			pr_err("Insufficient number of handles\n");
 			goto errout;
 		}
 
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index d49c40f..32a3351 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -56,7 +56,8 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
 {
 	struct cgroup_cls_state *cs;
 
-	if (!(cs = kzalloc(sizeof(*cs), GFP_KERNEL)))
+	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
+	if (!cs)
 		return ERR_PTR(-ENOMEM);
 
 	if (cgrp->parent)
@@ -94,8 +95,7 @@ static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	return cgroup_add_files(cgrp, ss, ss_files, ARRAY_SIZE(ss_files));
 }
 
-struct cls_cgroup_head
-{
+struct cls_cgroup_head {
 	u32			handle;
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
@@ -166,7 +166,7 @@ static int cls_cgroup_change(struct tcf_proto *tp, unsigned long base,
 			     u32 handle, struct nlattr **tca,
 			     unsigned long *arg)
 {
-	struct nlattr *tb[TCA_CGROUP_MAX+1];
+	struct nlattr *tb[TCA_CGROUP_MAX + 1];
 	struct cls_cgroup_head *head = tp->root;
 	struct tcf_ematch_tree t;
 	struct tcf_exts e;
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 5b271a1..5eec16e 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -121,7 +121,7 @@ static u32 flow_get_proto_src(struct sk_buff *skb)
 		if (!pskb_network_may_pull(skb, sizeof(*iph)))
 			break;
 		iph = ip_hdr(skb);
-		if (iph->frag_off & htons(IP_MF|IP_OFFSET))
+		if (iph->frag_off & htons(IP_MF | IP_OFFSET))
 			break;
 		poff = proto_ports_offset(iph->protocol);
 		if (poff >= 0 &&
@@ -163,7 +163,7 @@ static u32 flow_get_proto_dst(struct sk_buff *skb)
 		if (!pskb_network_may_pull(skb, sizeof(*iph)))
 			break;
 		iph = ip_hdr(skb);
-		if (iph->frag_off & htons(IP_MF|IP_OFFSET))
+		if (iph->frag_off & htons(IP_MF | IP_OFFSET))
 			break;
 		poff = proto_ports_offset(iph->protocol);
 		if (poff >= 0 &&
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 93b0a7b..26e7bc4 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -31,14 +31,12 @@
 
 #define HTSIZE (PAGE_SIZE/sizeof(struct fw_filter *))
 
-struct fw_head
-{
+struct fw_head {
 	struct fw_filter *ht[HTSIZE];
 	u32 mask;
 };
 
-struct fw_filter
-{
+struct fw_filter {
 	struct fw_filter	*next;
 	u32			id;
 	struct tcf_result	res;
@@ -53,7 +51,7 @@ static const struct tcf_ext_map fw_ext_map = {
 	.police = TCA_FW_POLICE
 };
 
-static __inline__ int fw_hash(u32 handle)
+static inline int fw_hash(u32 handle)
 {
 	if (HTSIZE == 4096)
 		return ((handle >> 24) & 0xFFF) ^
@@ -82,14 +80,14 @@ static __inline__ int fw_hash(u32 handle)
 static int fw_classify(struct sk_buff *skb, struct tcf_proto *tp,
 			  struct tcf_result *res)
 {
-	struct fw_head *head = (struct fw_head*)tp->root;
+	struct fw_head *head = (struct fw_head *)tp->root;
 	struct fw_filter *f;
 	int r;
 	u32 id = skb->mark;
 
 	if (head != NULL) {
 		id &= head->mask;
-		for (f=head->ht[fw_hash(id)]; f; f=f->next) {
+		for (f = head->ht[fw_hash(id)]; f; f = f->next) {
 			if (f->id == id) {
 				*res = f->res;
 #ifdef CONFIG_NET_CLS_IND
@@ -105,7 +103,8 @@ static int fw_classify(struct sk_buff *skb, struct tcf_proto *tp,
 		}
 	} else {
 		/* old method */
-		if (id && (TC_H_MAJ(id) == 0 || !(TC_H_MAJ(id^tp->q->handle)))) {
+		if (id && (TC_H_MAJ(id) == 0 ||
+			   !(TC_H_MAJ(id ^ tp->q->handle)))) {
 			res->classid = id;
 			res->class = 0;
 			return 0;
@@ -117,13 +116,13 @@ static int fw_classify(struct sk_buff *skb, struct tcf_proto *tp,
 
 static unsigned long fw_get(struct tcf_proto *tp, u32 handle)
 {
-	struct fw_head *head = (struct fw_head*)tp->root;
+	struct fw_head *head = (struct fw_head *)tp->root;
 	struct fw_filter *f;
 
 	if (head == NULL)
 		return 0;
 
-	for (f=head->ht[fw_hash(handle)]; f; f=f->next) {
+	for (f = head->ht[fw_hash(handle)]; f; f = f->next) {
 		if (f->id == handle)
 			return (unsigned long)f;
 	}
@@ -139,8 +138,7 @@ static int fw_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static inline void
-fw_delete_filter(struct tcf_proto *tp, struct fw_filter *f)
+static void fw_delete_filter(struct tcf_proto *tp, struct fw_filter *f)
 {
 	tcf_unbind_filter(tp, &f->res);
 	tcf_exts_destroy(tp, &f->exts);
@@ -156,8 +154,8 @@ static void fw_destroy(struct tcf_proto *tp)
 	if (head == NULL)
 		return;
 
-	for (h=0; h<HTSIZE; h++) {
-		while ((f=head->ht[h]) != NULL) {
+	for (h = 0; h < HTSIZE; h++) {
+		while ((f = head->ht[h]) != NULL) {
 			head->ht[h] = f->next;
 			fw_delete_filter(tp, f);
 		}
@@ -167,14 +165,14 @@ static void fw_destroy(struct tcf_proto *tp)
 
 static int fw_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct fw_head *head = (struct fw_head*)tp->root;
-	struct fw_filter *f = (struct fw_filter*)arg;
+	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_filter *f = (struct fw_filter *)arg;
 	struct fw_filter **fp;
 
 	if (head == NULL || f == NULL)
 		goto out;
 
-	for (fp=&head->ht[fw_hash(f->id)]; *fp; fp = &(*fp)->next) {
+	for (fp = &head->ht[fw_hash(f->id)]; *fp; fp = &(*fp)->next) {
 		if (*fp == f) {
 			tcf_tree_lock(tp);
 			*fp = f->next;
@@ -240,7 +238,7 @@ static int fw_change(struct tcf_proto *tp, unsigned long base,
 		     struct nlattr **tca,
 		     unsigned long *arg)
 {
-	struct fw_head *head = (struct fw_head*)tp->root;
+	struct fw_head *head = (struct fw_head *)tp->root;
 	struct fw_filter *f = (struct fw_filter *) *arg;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_FW_MAX + 1];
@@ -302,7 +300,7 @@ errout:
 
 static void fw_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
-	struct fw_head *head = (struct fw_head*)tp->root;
+	struct fw_head *head = (struct fw_head *)tp->root;
 	int h;
 
 	if (head == NULL)
@@ -332,7 +330,7 @@ static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 		   struct sk_buff *skb, struct tcmsg *t)
 {
 	struct fw_head *head = (struct fw_head *)tp->root;
-	struct fw_filter *f = (struct fw_filter*)fh;
+	struct fw_filter *f = (struct fw_filter *)fh;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 694dcd8..d580cdf 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -23,34 +23,30 @@
 #include <net/pkt_cls.h>
 
 /*
-   1. For now we assume that route tags < 256.
-      It allows to use direct table lookups, instead of hash tables.
-   2. For now we assume that "from TAG" and "fromdev DEV" statements
-      are mutually  exclusive.
-   3. "to TAG from ANY" has higher priority, than "to ANY from XXX"
+ * 1. For now we assume that route tags < 256.
+ *    It allows to use direct table lookups, instead of hash tables.
+ * 2. For now we assume that "from TAG" and "fromdev DEV" statements
+ *    are mutually  exclusive.
+ * 3. "to TAG from ANY" has higher priority, than "to ANY from XXX"
  */
 
-struct route4_fastmap
-{
+struct route4_fastmap {
 	struct route4_filter	*filter;
 	u32			id;
 	int			iif;
 };
 
-struct route4_head
-{
+struct route4_head {
 	struct route4_fastmap	fastmap[16];
-	struct route4_bucket	*table[256+1];
+	struct route4_bucket	*table[256 + 1];
 };
 
-struct route4_bucket
-{
+struct route4_bucket {
 	/* 16 FROM buckets + 16 IIF buckets + 1 wildcard bucket */
-	struct route4_filter	*ht[16+16+1];
+	struct route4_filter	*ht[16 + 16 + 1];
 };
 
-struct route4_filter
-{
+struct route4_filter {
 	struct route4_filter	*next;
 	u32			id;
 	int			iif;
@@ -61,20 +57,20 @@ struct route4_filter
 	struct route4_bucket	*bkt;
 };
 
-#define ROUTE4_FAILURE ((struct route4_filter*)(-1L))
+#define ROUTE4_FAILURE ((struct route4_filter *)(-1L))
 
 static const struct tcf_ext_map route_ext_map = {
 	.police = TCA_ROUTE4_POLICE,
 	.action = TCA_ROUTE4_ACT
 };
 
-static __inline__ int route4_fastmap_hash(u32 id, int iif)
+static inline int route4_fastmap_hash(u32 id, int iif)
 {
-	return id&0xF;
+	return id & 0xF;
 }
 
-static inline
-void route4_reset_fastmap(struct Qdisc *q, struct route4_head *head, u32 id)
+static void
+route4_reset_fastmap(struct Qdisc *q, struct route4_head *head, u32 id)
 {
 	spinlock_t *root_lock = qdisc_root_sleeping_lock(q);
 
@@ -83,32 +79,33 @@ void route4_reset_fastmap(struct Qdisc *q, struct route4_head *head, u32 id)
 	spin_unlock_bh(root_lock);
 }
 
-static inline void
+static void
 route4_set_fastmap(struct route4_head *head, u32 id, int iif,
 		   struct route4_filter *f)
 {
 	int h = route4_fastmap_hash(id, iif);
+
 	head->fastmap[h].id = id;
 	head->fastmap[h].iif = iif;
 	head->fastmap[h].filter = f;
 }
 
-static __inline__ int route4_hash_to(u32 id)
+static inline int route4_hash_to(u32 id)
 {
-	return id&0xFF;
+	return id & 0xFF;
 }
 
-static __inline__ int route4_hash_from(u32 id)
+static inline int route4_hash_from(u32 id)
 {
-	return (id>>16)&0xF;
+	return (id >> 16) & 0xF;
 }
 
-static __inline__ int route4_hash_iif(int iif)
+static inline int route4_hash_iif(int iif)
 {
-	return 16 + ((iif>>16)&0xF);
+	return 16 + ((iif >> 16) & 0xF);
 }
 
-static __inline__ int route4_hash_wild(void)
+static inline int route4_hash_wild(void)
 {
 	return 32;
 }
@@ -131,21 +128,22 @@ static __inline__ int route4_hash_wild(void)
 static int route4_classify(struct sk_buff *skb, struct tcf_proto *tp,
 			   struct tcf_result *res)
 {
-	struct route4_head *head = (struct route4_head*)tp->root;
+	struct route4_head *head = (struct route4_head *)tp->root;
 	struct dst_entry *dst;
 	struct route4_bucket *b;
 	struct route4_filter *f;
 	u32 id, h;
 	int iif, dont_cache = 0;
 
-	if ((dst = skb_dst(skb)) == NULL)
+	dst = skb_dst(skb);
+	if (!dst)
 		goto failure;
 
 	id = dst->tclassid;
 	if (head == NULL)
 		goto old_method;
 
-	iif = ((struct rtable*)dst)->fl.iif;
+	iif = ((struct rtable *)dst)->fl.iif;
 
 	h = route4_fastmap_hash(id, iif);
 	if (id == head->fastmap[h].id &&
@@ -161,7 +159,8 @@ static int route4_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	h = route4_hash_to(id);
 
 restart:
-	if ((b = head->table[h]) != NULL) {
+	b = head->table[h];
+	if (b) {
 		for (f = b->ht[route4_hash_from(id)]; f; f = f->next)
 			if (f->id == id)
 				ROUTE4_APPLY_RESULT();
@@ -197,8 +196,9 @@ old_method:
 
 static inline u32 to_hash(u32 id)
 {
-	u32 h = id&0xFF;
-	if (id&0x8000)
+	u32 h = id & 0xFF;
+
+	if (id & 0x8000)
 		h += 256;
 	return h;
 }
@@ -211,17 +211,17 @@ static inline u32 from_hash(u32 id)
 	if (!(id & 0x8000)) {
 		if (id > 255)
 			return 256;
-		return id&0xF;
+		return id & 0xF;
 	}
-	return 16 + (id&0xF);
+	return 16 + (id & 0xF);
 }
 
 static unsigned long route4_get(struct tcf_proto *tp, u32 handle)
 {
-	struct route4_head *head = (struct route4_head*)tp->root;
+	struct route4_head *head = (struct route4_head *)tp->root;
 	struct route4_bucket *b;
 	struct route4_filter *f;
-	unsigned h1, h2;
+	unsigned int h1, h2;
 
 	if (!head)
 		return 0;
@@ -230,11 +230,12 @@ static unsigned long route4_get(struct tcf_proto *tp, u32 handle)
 	if (h1 > 256)
 		return 0;
 
-	h2 = from_hash(handle>>16);
+	h2 = from_hash(handle >> 16);
 	if (h2 > 32)
 		return 0;
 
-	if ((b = head->table[h1]) != NULL) {
+	b = head->table[h1];
+	if (b) {
 		for (f = b->ht[h2]; f; f = f->next)
 			if (f->handle == handle)
 				return (unsigned long)f;
@@ -251,7 +252,7 @@ static int route4_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static inline void
+static void
 route4_delete_filter(struct tcf_proto *tp, struct route4_filter *f)
 {
 	tcf_unbind_filter(tp, &f->res);
@@ -267,11 +268,12 @@ static void route4_destroy(struct tcf_proto *tp)
 	if (head == NULL)
 		return;
 
-	for (h1=0; h1<=256; h1++) {
+	for (h1 = 0; h1 <= 256; h1++) {
 		struct route4_bucket *b;
 
-		if ((b = head->table[h1]) != NULL) {
-			for (h2=0; h2<=32; h2++) {
+		b = head->table[h1];
+		if (b) {
+			for (h2 = 0; h2 <= 32; h2++) {
 				struct route4_filter *f;
 
 				while ((f = b->ht[h2]) != NULL) {
@@ -287,9 +289,9 @@ static void route4_destroy(struct tcf_proto *tp)
 
 static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct route4_head *head = (struct route4_head*)tp->root;
-	struct route4_filter **fp, *f = (struct route4_filter*)arg;
-	unsigned h = 0;
+	struct route4_head *head = (struct route4_head *)tp->root;
+	struct route4_filter **fp, *f = (struct route4_filter *)arg;
+	unsigned int h = 0;
 	struct route4_bucket *b;
 	int i;
 
@@ -299,7 +301,7 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 	h = f->handle;
 	b = f->bkt;
 
-	for (fp = &b->ht[from_hash(h>>16)]; *fp; fp = &(*fp)->next) {
+	for (fp = &b->ht[from_hash(h >> 16)]; *fp; fp = &(*fp)->next) {
 		if (*fp == f) {
 			tcf_tree_lock(tp);
 			*fp = f->next;
@@ -310,7 +312,7 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 
 			/* Strip tree */
 
-			for (i=0; i<=32; i++)
+			for (i = 0; i <= 32; i++)
 				if (b->ht[i])
 					return 0;
 
@@ -380,7 +382,8 @@ static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 	}
 
 	h1 = to_hash(nhandle);
-	if ((b = head->table[h1]) == NULL) {
+	b = head->table[h1];
+	if (!b) {
 		err = -ENOBUFS;
 		b = kzalloc(sizeof(struct route4_bucket), GFP_KERNEL);
 		if (b == NULL)
@@ -391,6 +394,7 @@ static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 		tcf_tree_unlock(tp);
 	} else {
 		unsigned int h2 = from_hash(nhandle >> 16);
+
 		err = -EEXIST;
 		for (fp = b->ht[h2]; fp; fp = fp->next)
 			if (fp->handle == f->handle)
@@ -444,7 +448,8 @@ static int route4_change(struct tcf_proto *tp, unsigned long base,
 	if (err < 0)
 		return err;
 
-	if ((f = (struct route4_filter*)*arg) != NULL) {
+	f = (struct route4_filter *)*arg;
+	if (f) {
 		if (f->handle != handle && handle)
 			return -EINVAL;
 
@@ -481,7 +486,7 @@ static int route4_change(struct tcf_proto *tp, unsigned long base,
 
 reinsert:
 	h = from_hash(f->handle >> 16);
-	for (fp = &f->bkt->ht[h]; (f1=*fp) != NULL; fp = &f1->next)
+	for (fp = &f->bkt->ht[h]; (f1 = *fp) != NULL; fp = &f1->next)
 		if (f->handle < f1->handle)
 			break;
 
@@ -492,7 +497,8 @@ reinsert:
 	if (old_handle && f->handle != old_handle) {
 		th = to_hash(old_handle);
 		h = from_hash(old_handle >> 16);
-		if ((b = head->table[th]) != NULL) {
+		b = head->table[th];
+		if (b) {
 			for (fp = &b->ht[h]; *fp; fp = &(*fp)->next) {
 				if (*fp == f) {
 					*fp = f->next;
@@ -515,7 +521,7 @@ errout:
 static void route4_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
 	struct route4_head *head = tp->root;
-	unsigned h, h1;
+	unsigned int h, h1;
 
 	if (head == NULL)
 		arg->stop = 1;
@@ -549,7 +555,7 @@ static void route4_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 static int route4_dump(struct tcf_proto *tp, unsigned long fh,
 		       struct sk_buff *skb, struct tcmsg *t)
 {
-	struct route4_filter *f = (struct route4_filter*)fh;
+	struct route4_filter *f = (struct route4_filter *)fh;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 	u32 id;
@@ -563,15 +569,15 @@ static int route4_dump(struct tcf_proto *tp, unsigned long fh,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (!(f->handle&0x8000)) {
-		id = f->id&0xFF;
+	if (!(f->handle & 0x8000)) {
+		id = f->id & 0xFF;
 		NLA_PUT_U32(skb, TCA_ROUTE4_TO, id);
 	}
-	if (f->handle&0x80000000) {
-		if ((f->handle>>16) != 0xFFFF)
+	if (f->handle & 0x80000000) {
+		if ((f->handle >> 16) != 0xFFFF)
 			NLA_PUT_U32(skb, TCA_ROUTE4_IIF, f->iif);
 	} else {
-		id = f->id>>16;
+		id = f->id >> 16;
 		NLA_PUT_U32(skb, TCA_ROUTE4_FROM, id);
 	}
 	if (f->res.classid)
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 425a179..402c44b 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -66,28 +66,25 @@
    powerful classification engine.  */
 
 
-struct rsvp_head
-{
+struct rsvp_head {
 	u32			tmap[256/32];
 	u32			hgenerator;
 	u8			tgenerator;
 	struct rsvp_session	*ht[256];
 };
 
-struct rsvp_session
-{
+struct rsvp_session {
 	struct rsvp_session	*next;
 	__be32			dst[RSVP_DST_LEN];
 	struct tc_rsvp_gpi 	dpi;
 	u8			protocol;
 	u8			tunnelid;
 	/* 16 (src,sport) hash slots, and one wildcard source slot */
-	struct rsvp_filter	*ht[16+1];
+	struct rsvp_filter	*ht[16 + 1];
 };
 
 
-struct rsvp_filter
-{
+struct rsvp_filter {
 	struct rsvp_filter	*next;
 	__be32			src[RSVP_DST_LEN];
 	struct tc_rsvp_gpi	spi;
@@ -100,17 +97,19 @@ struct rsvp_filter
 	struct rsvp_session	*sess;
 };
 
-static __inline__ unsigned hash_dst(__be32 *dst, u8 protocol, u8 tunnelid)
+static inline unsigned int hash_dst(__be32 *dst, u8 protocol, u8 tunnelid)
 {
-	unsigned h = (__force __u32)dst[RSVP_DST_LEN-1];
+	unsigned int h = (__force __u32)dst[RSVP_DST_LEN - 1];
+
 	h ^= h>>16;
 	h ^= h>>8;
 	return (h ^ protocol ^ tunnelid) & 0xFF;
 }
 
-static __inline__ unsigned hash_src(__be32 *src)
+static inline unsigned int hash_src(__be32 *src)
 {
-	unsigned h = (__force __u32)src[RSVP_DST_LEN-1];
+	unsigned int h = (__force __u32)src[RSVP_DST_LEN-1];
+
 	h ^= h>>16;
 	h ^= h>>8;
 	h ^= h>>4;
@@ -134,10 +133,10 @@ static struct tcf_ext_map rsvp_ext_map = {
 static int rsvp_classify(struct sk_buff *skb, struct tcf_proto *tp,
 			 struct tcf_result *res)
 {
-	struct rsvp_session **sht = ((struct rsvp_head*)tp->root)->ht;
+	struct rsvp_session **sht = ((struct rsvp_head *)tp->root)->ht;
 	struct rsvp_session *s;
 	struct rsvp_filter *f;
-	unsigned h1, h2;
+	unsigned int h1, h2;
 	__be32 *dst, *src;
 	u8 protocol;
 	u8 tunnelid = 0;
@@ -162,13 +161,13 @@ restart:
 	src = &nhptr->saddr.s6_addr32[0];
 	dst = &nhptr->daddr.s6_addr32[0];
 	protocol = nhptr->nexthdr;
-	xprt = ((u8*)nhptr) + sizeof(struct ipv6hdr);
+	xprt = ((u8 *)nhptr) + sizeof(struct ipv6hdr);
 #else
 	src = &nhptr->saddr;
 	dst = &nhptr->daddr;
 	protocol = nhptr->protocol;
-	xprt = ((u8*)nhptr) + (nhptr->ihl<<2);
-	if (nhptr->frag_off & htons(IP_MF|IP_OFFSET))
+	xprt = ((u8 *)nhptr) + (nhptr->ihl<<2);
+	if (nhptr->frag_off & htons(IP_MF | IP_OFFSET))
 		return -1;
 #endif
 
@@ -176,10 +175,10 @@ restart:
 	h2 = hash_src(src);
 
 	for (s = sht[h1]; s; s = s->next) {
-		if (dst[RSVP_DST_LEN-1] == s->dst[RSVP_DST_LEN-1] &&
+		if (dst[RSVP_DST_LEN-1] == s->dst[RSVP_DST_LEN - 1] &&
 		    protocol == s->protocol &&
 		    !(s->dpi.mask &
-		      (*(u32*)(xprt+s->dpi.offset)^s->dpi.key)) &&
+		      (*(u32 *)(xprt + s->dpi.offset) ^ s->dpi.key)) &&
 #if RSVP_DST_LEN == 4
 		    dst[0] == s->dst[0] &&
 		    dst[1] == s->dst[1] &&
@@ -188,8 +187,8 @@ restart:
 		    tunnelid == s->tunnelid) {
 
 			for (f = s->ht[h2]; f; f = f->next) {
-				if (src[RSVP_DST_LEN-1] == f->src[RSVP_DST_LEN-1] &&
-				    !(f->spi.mask & (*(u32*)(xprt+f->spi.offset)^f->spi.key))
+				if (src[RSVP_DST_LEN-1] == f->src[RSVP_DST_LEN - 1] &&
+				    !(f->spi.mask & (*(u32 *)(xprt + f->spi.offset) ^ f->spi.key))
 #if RSVP_DST_LEN == 4
 				    &&
 				    src[0] == f->src[0] &&
@@ -205,7 +204,7 @@ matched:
 						return 0;
 
 					tunnelid = f->res.classid;
-					nhptr = (void*)(xprt + f->tunnelhdr - sizeof(*nhptr));
+					nhptr = (void *)(xprt + f->tunnelhdr - sizeof(*nhptr));
 					goto restart;
 				}
 			}
@@ -224,11 +223,11 @@ matched:
 
 static unsigned long rsvp_get(struct tcf_proto *tp, u32 handle)
 {
-	struct rsvp_session **sht = ((struct rsvp_head*)tp->root)->ht;
+	struct rsvp_session **sht = ((struct rsvp_head *)tp->root)->ht;
 	struct rsvp_session *s;
 	struct rsvp_filter *f;
-	unsigned h1 = handle&0xFF;
-	unsigned h2 = (handle>>8)&0xFF;
+	unsigned int h1 = handle & 0xFF;
+	unsigned int h2 = (handle >> 8) & 0xFF;
 
 	if (h2 > 16)
 		return 0;
@@ -258,7 +257,7 @@ static int rsvp_init(struct tcf_proto *tp)
 	return -ENOBUFS;
 }
 
-static inline void
+static void
 rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
 {
 	tcf_unbind_filter(tp, &f->res);
@@ -277,13 +276,13 @@ static void rsvp_destroy(struct tcf_proto *tp)
 
 	sht = data->ht;
 
-	for (h1=0; h1<256; h1++) {
+	for (h1 = 0; h1 < 256; h1++) {
 		struct rsvp_session *s;
 
 		while ((s = sht[h1]) != NULL) {
 			sht[h1] = s->next;
 
-			for (h2=0; h2<=16; h2++) {
+			for (h2 = 0; h2 <= 16; h2++) {
 				struct rsvp_filter *f;
 
 				while ((f = s->ht[h2]) != NULL) {
@@ -299,13 +298,13 @@ static void rsvp_destroy(struct tcf_proto *tp)
 
 static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct rsvp_filter **fp, *f = (struct rsvp_filter*)arg;
-	unsigned h = f->handle;
+	struct rsvp_filter **fp, *f = (struct rsvp_filter *)arg;
+	unsigned int h = f->handle;
 	struct rsvp_session **sp;
 	struct rsvp_session *s = f->sess;
 	int i;
 
-	for (fp = &s->ht[(h>>8)&0xFF]; *fp; fp = &(*fp)->next) {
+	for (fp = &s->ht[(h >> 8) & 0xFF]; *fp; fp = &(*fp)->next) {
 		if (*fp == f) {
 			tcf_tree_lock(tp);
 			*fp = f->next;
@@ -314,12 +313,12 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
 
 			/* Strip tree */
 
-			for (i=0; i<=16; i++)
+			for (i = 0; i <= 16; i++)
 				if (s->ht[i])
 					return 0;
 
 			/* OK, session has no flows */
-			for (sp = &((struct rsvp_head*)tp->root)->ht[h&0xFF];
+			for (sp = &((struct rsvp_head *)tp->root)->ht[h & 0xFF];
 			     *sp; sp = &(*sp)->next) {
 				if (*sp == s) {
 					tcf_tree_lock(tp);
@@ -337,13 +336,14 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
 	return 0;
 }
 
-static unsigned gen_handle(struct tcf_proto *tp, unsigned salt)
+static unsigned int gen_handle(struct tcf_proto *tp, unsigned salt)
 {
 	struct rsvp_head *data = tp->root;
 	int i = 0xFFFF;
 
 	while (i-- > 0) {
 		u32 h;
+
 		if ((data->hgenerator += 0x10000) == 0)
 			data->hgenerator = 0x10000;
 		h = data->hgenerator|salt;
@@ -355,10 +355,10 @@ static unsigned gen_handle(struct tcf_proto *tp, unsigned salt)
 
 static int tunnel_bts(struct rsvp_head *data)
 {
-	int n = data->tgenerator>>5;
-	u32 b = 1<<(data->tgenerator&0x1F);
+	int n = data->tgenerator >> 5;
+	u32 b = 1 << (data->tgenerator & 0x1F);
 
-	if (data->tmap[n]&b)
+	if (data->tmap[n] & b)
 		return 0;
 	data->tmap[n] |= b;
 	return 1;
@@ -372,10 +372,10 @@ static void tunnel_recycle(struct rsvp_head *data)
 
 	memset(tmap, 0, sizeof(tmap));
 
-	for (h1=0; h1<256; h1++) {
+	for (h1 = 0; h1 < 256; h1++) {
 		struct rsvp_session *s;
 		for (s = sht[h1]; s; s = s->next) {
-			for (h2=0; h2<=16; h2++) {
+			for (h2 = 0; h2 <= 16; h2++) {
 				struct rsvp_filter *f;
 
 				for (f = s->ht[h2]; f; f = f->next) {
@@ -395,8 +395,8 @@ static u32 gen_tunnel(struct rsvp_head *data)
 {
 	int i, k;
 
-	for (k=0; k<2; k++) {
-		for (i=255; i>0; i--) {
+	for (k = 0; k < 2; k++) {
+		for (i = 255; i > 0; i--) {
 			if (++data->tgenerator == 0)
 				data->tgenerator = 1;
 			if (tunnel_bts(data))
@@ -428,7 +428,7 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 	struct nlattr *opt = tca[TCA_OPTIONS-1];
 	struct nlattr *tb[TCA_RSVP_MAX + 1];
 	struct tcf_exts e;
-	unsigned h1, h2;
+	unsigned int h1, h2;
 	__be32 *dst;
 	int err;
 
@@ -443,7 +443,8 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 	if (err < 0)
 		return err;
 
-	if ((f = (struct rsvp_filter*)*arg) != NULL) {
+	f = (struct rsvp_filter *)*arg;
+	if (f) {
 		/* Node exists: adjust only classid */
 
 		if (f->handle != handle && handle)
@@ -500,7 +501,7 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 			goto errout;
 	}
 
-	for (sp = &data->ht[h1]; (s=*sp) != NULL; sp = &s->next) {
+	for (sp = &data->ht[h1]; (s = *sp) != NULL; sp = &s->next) {
 		if (dst[RSVP_DST_LEN-1] == s->dst[RSVP_DST_LEN-1] &&
 		    pinfo && pinfo->protocol == s->protocol &&
 		    memcmp(&pinfo->dpi, &s->dpi, sizeof(s->dpi)) == 0 &&
@@ -523,7 +524,7 @@ insert:
 			tcf_exts_change(tp, &f->exts, &e);
 
 			for (fp = &s->ht[h2]; *fp; fp = &(*fp)->next)
-				if (((*fp)->spi.mask&f->spi.mask) != f->spi.mask)
+				if (((*fp)->spi.mask & f->spi.mask) != f->spi.mask)
 					break;
 			f->next = *fp;
 			wmb();
@@ -567,7 +568,7 @@ errout2:
 static void rsvp_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
 	struct rsvp_head *head = tp->root;
-	unsigned h, h1;
+	unsigned int h, h1;
 
 	if (arg->stop)
 		return;
@@ -598,7 +599,7 @@ static void rsvp_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
-	struct rsvp_filter *f = (struct rsvp_filter*)fh;
+	struct rsvp_filter *f = (struct rsvp_filter *)fh;
 	struct rsvp_session *s;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
@@ -624,7 +625,7 @@ static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
 	NLA_PUT(skb, TCA_RSVP_PINFO, sizeof(pinfo), &pinfo);
 	if (f->res.classid)
 		NLA_PUT_U32(skb, TCA_RSVP_CLASSID, f->res.classid);
-	if (((f->handle>>8)&0xFF) != 16)
+	if (((f->handle >> 8) & 0xFF) != 16)
 		NLA_PUT(skb, TCA_RSVP_SRC, sizeof(f->src), f->src);
 
 	if (tcf_exts_dump(skb, &f->exts, &rsvp_ext_map) < 0)
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 20ef330..36667fa 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -249,7 +249,7 @@ tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 		 * of the hashing index is below the threshold.
 		 */
 		if ((cp.mask >> cp.shift) < PERFECT_HASH_THRESHOLD)
-			cp.hash = (cp.mask >> cp.shift)+1;
+			cp.hash = (cp.mask >> cp.shift) + 1;
 		else
 			cp.hash = DEFAULT_HASH_SIZE;
 	}
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index b0c2a82..966920c 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -42,8 +42,7 @@
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
-struct tc_u_knode
-{
+struct tc_u_knode {
 	struct tc_u_knode	*next;
 	u32			handle;
 	struct tc_u_hnode	*ht_up;
@@ -63,19 +62,17 @@ struct tc_u_knode
 	struct tc_u32_sel	sel;
 };
 
-struct tc_u_hnode
-{
+struct tc_u_hnode {
 	struct tc_u_hnode	*next;
 	u32			handle;
 	u32			prio;
 	struct tc_u_common	*tp_c;
 	int			refcnt;
-	unsigned		divisor;
+	unsigned int		divisor;
 	struct tc_u_knode	*ht[1];
 };
 
-struct tc_u_common
-{
+struct tc_u_common {
 	struct tc_u_hnode	*hlist;
 	struct Qdisc		*q;
 	int			refcnt;
@@ -87,9 +84,11 @@ static const struct tcf_ext_map u32_ext_map = {
 	.police = TCA_U32_POLICE
 };
 
-static __inline__ unsigned u32_hash_fold(__be32 key, struct tc_u32_sel *sel, u8 fshift)
+static inline unsigned int u32_hash_fold(__be32 key,
+					 const struct tc_u32_sel *sel,
+					 u8 fshift)
 {
-	unsigned h = ntohl(key & sel->hmask)>>fshift;
+	unsigned int h = ntohl(key & sel->hmask) >> fshift;
 
 	return h;
 }
@@ -101,7 +100,7 @@ static int u32_classify(struct sk_buff *skb, struct tcf_proto *tp, struct tcf_re
 		unsigned int	  off;
 	} stack[TC_U32_MAXDEPTH];
 
-	struct tc_u_hnode *ht = (struct tc_u_hnode*)tp->root;
+	struct tc_u_hnode *ht = (struct tc_u_hnode *)tp->root;
 	unsigned int off = skb_network_offset(skb);
 	struct tc_u_knode *n;
 	int sdepth = 0;
@@ -120,7 +119,7 @@ next_knode:
 		struct tc_u32_key *key = n->sel.keys;
 
 #ifdef CONFIG_CLS_U32_PERF
-		n->pf->rcnt +=1;
+		n->pf->rcnt += 1;
 		j = 0;
 #endif
 
@@ -133,7 +132,7 @@ next_knode:
 		}
 #endif
 
-		for (i = n->sel.nkeys; i>0; i--, key++) {
+		for (i = n->sel.nkeys; i > 0; i--, key++) {
 			int toff = off + key->off + (off2 & key->offmask);
 			__be32 *data, _data;
 
@@ -148,13 +147,13 @@ next_knode:
 				goto next_knode;
 			}
 #ifdef CONFIG_CLS_U32_PERF
-			n->pf->kcnts[j] +=1;
+			n->pf->kcnts[j] += 1;
 			j++;
 #endif
 		}
 		if (n->ht_down == NULL) {
 check_terminal:
-			if (n->sel.flags&TC_U32_TERMINAL) {
+			if (n->sel.flags & TC_U32_TERMINAL) {
 
 				*res = n->res;
 #ifdef CONFIG_NET_CLS_IND
@@ -164,7 +163,7 @@ check_terminal:
 				}
 #endif
 #ifdef CONFIG_CLS_U32_PERF
-				n->pf->rhit +=1;
+				n->pf->rhit += 1;
 #endif
 				r = tcf_exts_exec(skb, &n->exts, res);
 				if (r < 0) {
@@ -197,10 +196,10 @@ check_terminal:
 			sel = ht->divisor & u32_hash_fold(*data, &n->sel,
 							  n->fshift);
 		}
-		if (!(n->sel.flags&(TC_U32_VAROFFSET|TC_U32_OFFSET|TC_U32_EAT)))
+		if (!(n->sel.flags & (TC_U32_VAROFFSET | TC_U32_OFFSET | TC_U32_EAT)))
 			goto next_ht;
 
-		if (n->sel.flags&(TC_U32_OFFSET|TC_U32_VAROFFSET)) {
+		if (n->sel.flags & (TC_U32_OFFSET | TC_U32_VAROFFSET)) {
 			off2 = n->sel.off + 3;
 			if (n->sel.flags & TC_U32_VAROFFSET) {
 				__be16 *data, _data;
@@ -215,7 +214,7 @@ check_terminal:
 			}
 			off2 &= ~3;
 		}
-		if (n->sel.flags&TC_U32_EAT) {
+		if (n->sel.flags & TC_U32_EAT) {
 			off += off2;
 			off2 = 0;
 		}
@@ -236,11 +235,11 @@ out:
 
 deadloop:
 	if (net_ratelimit())
-		printk(KERN_WARNING "cls_u32: dead loop\n");
+		pr_warning("cls_u32: dead loop\n");
 	return -1;
 }
 
-static __inline__ struct tc_u_hnode *
+static struct tc_u_hnode *
 u32_lookup_ht(struct tc_u_common *tp_c, u32 handle)
 {
 	struct tc_u_hnode *ht;
@@ -252,10 +251,10 @@ u32_lookup_ht(struct tc_u_common *tp_c, u32 handle)
 	return ht;
 }
 
-static __inline__ struct tc_u_knode *
+static struct tc_u_knode *
 u32_lookup_key(struct tc_u_hnode *ht, u32 handle)
 {
-	unsigned sel;
+	unsigned int sel;
 	struct tc_u_knode *n = NULL;
 
 	sel = TC_U32_HASH(handle);
@@ -300,7 +299,7 @@ static u32 gen_new_htid(struct tc_u_common *tp_c)
 	do {
 		if (++tp_c->hgenerator == 0x7FF)
 			tp_c->hgenerator = 1;
-	} while (--i>0 && u32_lookup_ht(tp_c, (tp_c->hgenerator|0x800)<<20));
+	} while (--i > 0 && u32_lookup_ht(tp_c, (tp_c->hgenerator|0x800)<<20));
 
 	return i > 0 ? (tp_c->hgenerator|0x800)<<20 : 0;
 }
@@ -378,9 +377,9 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode* key)
 static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 {
 	struct tc_u_knode *n;
-	unsigned h;
+	unsigned int h;
 
-	for (h=0; h<=ht->divisor; h++) {
+	for (h = 0; h <= ht->divisor; h++) {
 		while ((n = ht->ht[h]) != NULL) {
 			ht->ht[h] = n->next;
 
@@ -446,13 +445,13 @@ static void u32_destroy(struct tcf_proto *tp)
 
 static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct tc_u_hnode *ht = (struct tc_u_hnode*)arg;
+	struct tc_u_hnode *ht = (struct tc_u_hnode *)arg;
 
 	if (ht == NULL)
 		return 0;
 
 	if (TC_U32_KEY(ht->handle))
-		return u32_delete_key(tp, (struct tc_u_knode*)ht);
+		return u32_delete_key(tp, (struct tc_u_knode *)ht);
 
 	if (tp->root == ht)
 		return -EINVAL;
@@ -470,14 +469,14 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 static u32 gen_new_kid(struct tc_u_hnode *ht, u32 handle)
 {
 	struct tc_u_knode *n;
-	unsigned i = 0x7FF;
+	unsigned int i = 0x7FF;
 
-	for (n=ht->ht[TC_U32_HASH(handle)]; n; n = n->next)
+	for (n = ht->ht[TC_U32_HASH(handle)]; n; n = n->next)
 		if (i < TC_U32_NODE(n->handle))
 			i = TC_U32_NODE(n->handle);
 	i++;
 
-	return handle|(i>0xFFF ? 0xFFF : i);
+	return handle | (i > 0xFFF ? 0xFFF : i);
 }
 
 static const struct nla_policy u32_policy[TCA_U32_MAX + 1] = {
@@ -566,7 +565,8 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (err < 0)
 		return err;
 
-	if ((n = (struct tc_u_knode*)*arg) != NULL) {
+	n = (struct tc_u_knode *)*arg;
+	if (n) {
 		if (TC_U32_KEY(n->handle) == 0)
 			return -EINVAL;
 
@@ -574,7 +574,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	}
 
 	if (tb[TCA_U32_DIVISOR]) {
-		unsigned divisor = nla_get_u32(tb[TCA_U32_DIVISOR]);
+		unsigned int divisor = nla_get_u32(tb[TCA_U32_DIVISOR]);
 
 		if (--divisor > 0x100)
 			return -EINVAL;
@@ -585,7 +585,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 			if (handle == 0)
 				return -ENOMEM;
 		}
-		ht = kzalloc(sizeof(*ht) + divisor*sizeof(void*), GFP_KERNEL);
+		ht = kzalloc(sizeof(*ht) + divisor*sizeof(void *), GFP_KERNEL);
 		if (ht == NULL)
 			return -ENOBUFS;
 		ht->tp_c = tp_c;
@@ -683,7 +683,7 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	struct tc_u_common *tp_c = tp->data;
 	struct tc_u_hnode *ht;
 	struct tc_u_knode *n;
-	unsigned h;
+	unsigned int h;
 
 	if (arg->stop)
 		return;
@@ -717,7 +717,7 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
-	struct tc_u_knode *n = (struct tc_u_knode*)fh;
+	struct tc_u_knode *n = (struct tc_u_knode *)fh;
 	struct nlattr *nest;
 
 	if (n == NULL)
@@ -730,8 +730,9 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 		goto nla_put_failure;
 
 	if (TC_U32_KEY(n->handle) == 0) {
-		struct tc_u_hnode *ht = (struct tc_u_hnode*)fh;
-		u32 divisor = ht->divisor+1;
+		struct tc_u_hnode *ht = (struct tc_u_hnode *)fh;
+		u32 divisor = ht->divisor + 1;
+
 		NLA_PUT_U32(skb, TCA_U32_DIVISOR, divisor);
 	} else {
 		NLA_PUT(skb, TCA_U32_SEL,
@@ -755,7 +756,7 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 			goto nla_put_failure;
 
 #ifdef CONFIG_NET_CLS_IND
-		if(strlen(n->indev))
+		if (strlen(n->indev))
 			NLA_PUT_STRING(skb, TCA_U32_INDEV, n->indev);
 #endif
 #ifdef CONFIG_CLS_U32_PERF
diff --git a/net/sched/em_cmp.c b/net/sched/em_cmp.c
index bc45039..1c8360a 100644
--- a/net/sched/em_cmp.c
+++ b/net/sched/em_cmp.c
@@ -33,40 +33,41 @@ static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *em,
 		return 0;
 
 	switch (cmp->align) {
-		case TCF_EM_ALIGN_U8:
-			val = *ptr;
-			break;
+	case TCF_EM_ALIGN_U8:
+		val = *ptr;
+		break;
 
-		case TCF_EM_ALIGN_U16:
-			val = get_unaligned_be16(ptr);
+	case TCF_EM_ALIGN_U16:
+		val = get_unaligned_be16(ptr);
 
-			if (cmp_needs_transformation(cmp))
-				val = be16_to_cpu(val);
-			break;
+		if (cmp_needs_transformation(cmp))
+			val = be16_to_cpu(val);
+		break;
 
-		case TCF_EM_ALIGN_U32:
-			/* Worth checking boundries? The branching seems
-			 * to get worse. Visit again. */
-			val = get_unaligned_be32(ptr);
+	case TCF_EM_ALIGN_U32:
+		/* Worth checking boundries? The branching seems
+		 * to get worse. Visit again.
+		 */
+		val = get_unaligned_be32(ptr);
 
-			if (cmp_needs_transformation(cmp))
-				val = be32_to_cpu(val);
-			break;
+		if (cmp_needs_transformation(cmp))
+			val = be32_to_cpu(val);
+		break;
 
-		default:
-			return 0;
+	default:
+		return 0;
 	}
 
 	if (cmp->mask)
 		val &= cmp->mask;
 
 	switch (cmp->opnd) {
-		case TCF_EM_OPND_EQ:
-			return val == cmp->val;
-		case TCF_EM_OPND_LT:
-			return val < cmp->val;
-		case TCF_EM_OPND_GT:
-			return val > cmp->val;
+	case TCF_EM_OPND_EQ:
+		return val == cmp->val;
+	case TCF_EM_OPND_LT:
+		return val < cmp->val;
+	case TCF_EM_OPND_GT:
+		return val > cmp->val;
 	}
 
 	return 0;
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 34da5e2..7af1f65 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -73,21 +73,18 @@
 #include <net/pkt_cls.h>
 #include <net/sock.h>
 
-struct meta_obj
-{
+struct meta_obj {
 	unsigned long		value;
 	unsigned int		len;
 };
 
-struct meta_value
-{
+struct meta_value {
 	struct tcf_meta_val	hdr;
 	unsigned long		val;
 	unsigned int		len;
 };
 
-struct meta_match
-{
+struct meta_match {
 	struct meta_value	lvalue;
 	struct meta_value	rvalue;
 };
@@ -483,8 +480,7 @@ META_COLLECTOR(int_sk_write_pend)
  * Meta value collectors assignment table
  **************************************************************************/
 
-struct meta_ops
-{
+struct meta_ops {
 	void		(*get)(struct sk_buff *, struct tcf_pkt_info *,
 			       struct meta_value *, struct meta_obj *, int *);
 };
@@ -494,7 +490,7 @@ struct meta_ops
 
 /* Meta value operations table listing all meta value collectors and
  * assigns them to a type and meta id. */
-static struct meta_ops __meta_ops[TCF_META_TYPE_MAX+1][TCF_META_ID_MAX+1] = {
+static struct meta_ops __meta_ops[TCF_META_TYPE_MAX + 1][TCF_META_ID_MAX + 1] = {
 	[TCF_META_TYPE_VAR] = {
 		[META_ID(DEV)]			= META_FUNC(var_dev),
 		[META_ID(SK_BOUND_IF)] 		= META_FUNC(var_sk_bound_if),
@@ -550,7 +546,7 @@ static struct meta_ops __meta_ops[TCF_META_TYPE_MAX+1][TCF_META_ID_MAX+1] = {
 	}
 };
 
-static inline struct meta_ops * meta_ops(struct meta_value *val)
+static inline struct meta_ops *meta_ops(struct meta_value *val)
 {
 	return &__meta_ops[meta_type(val)][meta_id(val)];
 }
@@ -649,9 +645,8 @@ static int meta_int_dump(struct sk_buff *skb, struct meta_value *v, int tlv)
 {
 	if (v->len == sizeof(unsigned long))
 		NLA_PUT(skb, tlv, sizeof(unsigned long), &v->val);
-	else if (v->len == sizeof(u32)) {
+	else if (v->len == sizeof(u32))
 		NLA_PUT_U32(skb, tlv, v->val);
-	}
 
 	return 0;
 
@@ -663,8 +658,7 @@ nla_put_failure:
  * Type specific operations table
  **************************************************************************/
 
-struct meta_type_ops
-{
+struct meta_type_ops {
 	void	(*destroy)(struct meta_value *);
 	int	(*compare)(struct meta_obj *, struct meta_obj *);
 	int	(*change)(struct meta_value *, struct nlattr *);
@@ -672,7 +666,7 @@ struct meta_type_ops
 	int	(*dump)(struct sk_buff *, struct meta_value *, int);
 };
 
-static struct meta_type_ops __meta_type_ops[TCF_META_TYPE_MAX+1] = {
+static struct meta_type_ops __meta_type_ops[TCF_META_TYPE_MAX + 1] = {
 	[TCF_META_TYPE_VAR] = {
 		.destroy = meta_var_destroy,
 		.compare = meta_var_compare,
@@ -688,7 +682,7 @@ static struct meta_type_ops __meta_type_ops[TCF_META_TYPE_MAX+1] = {
 	}
 };
 
-static inline struct meta_type_ops * meta_type_ops(struct meta_value *v)
+static inline struct meta_type_ops *meta_type_ops(struct meta_value *v)
 {
 	return &__meta_type_ops[meta_type(v)];
 }
@@ -713,7 +707,7 @@ static int meta_get(struct sk_buff *skb, struct tcf_pkt_info *info,
 		return err;
 
 	if (meta_type_ops(v)->apply_extras)
-	    meta_type_ops(v)->apply_extras(v, dst);
+		meta_type_ops(v)->apply_extras(v, dst);
 
 	return 0;
 }
@@ -732,12 +726,12 @@ static int em_meta_match(struct sk_buff *skb, struct tcf_ematch *m,
 	r = meta_type_ops(&meta->lvalue)->compare(&l_value, &r_value);
 
 	switch (meta->lvalue.hdr.op) {
-		case TCF_EM_OPND_EQ:
-			return !r;
-		case TCF_EM_OPND_LT:
-			return r < 0;
-		case TCF_EM_OPND_GT:
-			return r > 0;
+	case TCF_EM_OPND_EQ:
+		return !r;
+	case TCF_EM_OPND_LT:
+		return r < 0;
+	case TCF_EM_OPND_GT:
+		return r > 0;
 	}
 
 	return 0;
@@ -771,7 +765,7 @@ static inline int meta_change_data(struct meta_value *dst, struct nlattr *nla)
 
 static inline int meta_is_supported(struct meta_value *val)
 {
-	return (!meta_id(val) || meta_ops(val)->get);
+	return !meta_id(val) || meta_ops(val)->get;
 }
 
 static const struct nla_policy meta_policy[TCA_EM_META_MAX + 1] = {
diff --git a/net/sched/em_nbyte.c b/net/sched/em_nbyte.c
index 1a4176a..a3bed07 100644
--- a/net/sched/em_nbyte.c
+++ b/net/sched/em_nbyte.c
@@ -18,8 +18,7 @@
 #include <linux/tc_ematch/tc_em_nbyte.h>
 #include <net/pkt_cls.h>
 
-struct nbyte_data
-{
+struct nbyte_data {
 	struct tcf_em_nbyte	hdr;
 	char			pattern[0];
 };
diff --git a/net/sched/em_text.c b/net/sched/em_text.c
index ea8f566..15d353d 100644
--- a/net/sched/em_text.c
+++ b/net/sched/em_text.c
@@ -19,8 +19,7 @@
 #include <linux/tc_ematch/tc_em_text.h>
 #include <net/pkt_cls.h>
 
-struct text_match
-{
+struct text_match {
 	u16			from_offset;
 	u16			to_offset;
 	u8			from_layer;
diff --git a/net/sched/em_u32.c b/net/sched/em_u32.c
index 953f147..797bdb8 100644
--- a/net/sched/em_u32.c
+++ b/net/sched/em_u32.c
@@ -35,7 +35,7 @@ static int em_u32_match(struct sk_buff *skb, struct tcf_ematch *em,
 	if (!tcf_valid_offset(skb, ptr, sizeof(u32)))
 		return 0;
 
-	return !(((*(__be32*) ptr)  ^ key->val) & key->mask);
+	return !(((*(__be32 *) ptr)  ^ key->val) & key->mask);
 }
 
 static struct tcf_ematch_ops em_u32_ops = {
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 5e37da9..88d93eb 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -93,7 +93,7 @@
 static LIST_HEAD(ematch_ops);
 static DEFINE_RWLOCK(ematch_mod_lock);
 
-static inline struct tcf_ematch_ops * tcf_em_lookup(u16 kind)
+static struct tcf_ematch_ops *tcf_em_lookup(u16 kind)
 {
 	struct tcf_ematch_ops *e = NULL;
 
@@ -163,8 +163,8 @@ void tcf_em_unregister(struct tcf_ematch_ops *ops)
 }
 EXPORT_SYMBOL(tcf_em_unregister);
 
-static inline struct tcf_ematch * tcf_em_get_match(struct tcf_ematch_tree *tree,
-						   int index)
+static inline struct tcf_ematch *tcf_em_get_match(struct tcf_ematch_tree *tree,
+						  int index)
 {
 	return &tree->matches[index];
 }
@@ -184,7 +184,8 @@ static int tcf_em_validate(struct tcf_proto *tp,
 
 	if (em_hdr->kind == TCF_EM_CONTAINER) {
 		/* Special ematch called "container", carries an index
-		 * referencing an external ematch sequence. */
+		 * referencing an external ematch sequence.
+		 */
 		u32 ref;
 
 		if (data_len < sizeof(ref))
@@ -195,7 +196,8 @@ static int tcf_em_validate(struct tcf_proto *tp,
 			goto errout;
 
 		/* We do not allow backward jumps to avoid loops and jumps
-		 * to our own position are of course illegal. */
+		 * to our own position are of course illegal.
+		 */
 		if (ref <= idx)
 			goto errout;
 
@@ -208,7 +210,8 @@ static int tcf_em_validate(struct tcf_proto *tp,
 		 * which automatically releases the reference again, therefore
 		 * the module MUST not be given back under any circumstances
 		 * here. Be aware, the destroy function assumes that the
-		 * module is held if the ops field is non zero. */
+		 * module is held if the ops field is non zero.
+		 */
 		em->ops = tcf_em_lookup(em_hdr->kind);
 
 		if (em->ops == NULL) {
@@ -221,7 +224,8 @@ static int tcf_em_validate(struct tcf_proto *tp,
 			if (em->ops) {
 				/* We dropped the RTNL mutex in order to
 				 * perform the module load. Tell the caller
-				 * to replay the request. */
+				 * to replay the request.
+				 */
 				module_put(em->ops->owner);
 				err = -EAGAIN;
 			}
@@ -230,7 +234,8 @@ static int tcf_em_validate(struct tcf_proto *tp,
 		}
 
 		/* ematch module provides expected length of data, so we
-		 * can do a basic sanity check. */
+		 * can do a basic sanity check.
+		 */
 		if (em->ops->datalen && data_len < em->ops->datalen)
 			goto errout;
 
@@ -246,7 +251,8 @@ static int tcf_em_validate(struct tcf_proto *tp,
 			 * TCF_EM_SIMPLE may be specified stating that the
 			 * data only consists of a u32 integer and the module
 			 * does not expected a memory reference but rather
-			 * the value carried. */
+			 * the value carried.
+			 */
 			if (em_hdr->flags & TCF_EM_SIMPLE) {
 				if (data_len < sizeof(u32))
 					goto errout;
@@ -334,7 +340,8 @@ int tcf_em_tree_validate(struct tcf_proto *tp, struct nlattr *nla,
 	 * The array of rt attributes is parsed in the order as they are
 	 * provided, their type must be incremental from 1 to n. Even
 	 * if it does not serve any real purpose, a failure of sticking
-	 * to this policy will result in parsing failure. */
+	 * to this policy will result in parsing failure.
+	 */
 	for (idx = 0; nla_ok(rt_match, list_len); idx++) {
 		err = -EINVAL;
 
@@ -359,7 +366,8 @@ int tcf_em_tree_validate(struct tcf_proto *tp, struct nlattr *nla,
 	/* Check if the number of matches provided by userspace actually
 	 * complies with the array of matches. The number was used for
 	 * the validation of references and a mismatch could lead to
-	 * undefined references during the matching process. */
+	 * undefined references during the matching process.
+	 */
 	if (idx != tree_hdr->nmatches) {
 		err = -EINVAL;
 		goto errout_abort;
@@ -449,7 +457,7 @@ int tcf_em_tree_dump(struct sk_buff *skb, struct tcf_ematch_tree *tree, int tlv)
 			.flags = em->flags
 		};
 
-		NLA_PUT(skb, i+1, sizeof(em_hdr), &em_hdr);
+		NLA_PUT(skb, i + 1, sizeof(em_hdr), &em_hdr);
 
 		if (em->ops && em->ops->dump) {
 			if (em->ops->dump(skb, em) < 0)
@@ -478,6 +486,7 @@ static inline int tcf_em_match(struct sk_buff *skb, struct tcf_ematch *em,
 			       struct tcf_pkt_info *info)
 {
 	int r = em->ops->match(skb, em, info);
+
 	return tcf_em_is_inverted(em) ? !r : r;
 }
 
@@ -527,8 +536,8 @@ pop_stack:
 
 stack_overflow:
 	if (net_ratelimit())
-		printk(KERN_WARNING "tc ematch: local stack overflow,"
-			" increase NET_EMATCH_STACK\n");
+		pr_warning("tc ematch: local stack overflow,"
+			   " increase NET_EMATCH_STACK\n");
 	return -1;
 }
 EXPORT_SYMBOL(__tcf_em_tree_match);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b22ca2d..36ac0ec 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -187,7 +187,7 @@ int unregister_qdisc(struct Qdisc_ops *qops)
 	int err = -ENOENT;
 
 	write_lock(&qdisc_mod_lock);
-	for (qp = &qdisc_base; (q=*qp)!=NULL; qp = &q->next)
+	for (qp = &qdisc_base; (q = *qp) != NULL; qp = &q->next)
 		if (q == qops)
 			break;
 	if (q) {
@@ -321,7 +321,9 @@ void qdisc_put_rtab(struct qdisc_rate_table *tab)
 	if (!tab || --tab->refcnt)
 		return;
 
-	for (rtabp = &qdisc_rtab_list; (rtab=*rtabp) != NULL; rtabp = &rtab->next) {
+	for (rtabp = &qdisc_rtab_list;
+	     (rtab = *rtabp) != NULL;
+	     rtabp = &rtab->next) {
 		if (rtab == tab) {
 			*rtabp = rtab->next;
 			kfree(rtab);
@@ -459,9 +461,8 @@ EXPORT_SYMBOL(qdisc_calculate_pkt_len);
 void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc)
 {
 	if (!(qdisc->flags & TCQ_F_WARN_NONWC)) {
-		printk(KERN_WARNING
-		       "%s: %s qdisc %X: is non-work-conserving?\n",
-		       txt, qdisc->ops->id, qdisc->handle >> 16);
+		pr_warn("%s: %s qdisc %X: is non-work-conserving?\n",
+			txt, qdisc->ops->id, qdisc->handle >> 16);
 		qdisc->flags |= TCQ_F_WARN_NONWC;
 	}
 }
@@ -625,7 +626,7 @@ static u32 qdisc_alloc_handle(struct net_device *dev)
 			autohandle = TC_H_MAKE(0x80000000U, 0);
 	} while	(qdisc_lookup(dev, autohandle) && --i > 0);
 
-	return i>0 ? autohandle : 0;
+	return i > 0 ? autohandle : 0;
 }
 
 void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
@@ -915,9 +916,8 @@ out:
 	return 0;
 }
 
-struct check_loop_arg
-{
-	struct qdisc_walker 	w;
+struct check_loop_arg {
+	struct qdisc_walker	w;
 	struct Qdisc		*p;
 	int			depth;
 };
@@ -970,7 +970,8 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	struct Qdisc *p = NULL;
 	int err;
 
-	if ((dev = __dev_get_by_index(net, tcm->tcm_ifindex)) == NULL)
+	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
+	if (!dev)
 		return -ENODEV;
 
 	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
@@ -980,12 +981,12 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	if (clid) {
 		if (clid != TC_H_ROOT) {
 			if (TC_H_MAJ(clid) != TC_H_MAJ(TC_H_INGRESS)) {
-				if ((p = qdisc_lookup(dev, TC_H_MAJ(clid))) == NULL)
+				p = qdisc_lookup(dev, TC_H_MAJ(clid));
+				if (!p)
 					return -ENOENT;
 				q = qdisc_leaf(p, clid);
-			} else { /* ingress */
-				if (dev_ingress_queue(dev))
-					q = dev_ingress_queue(dev)->qdisc_sleeping;
+			} else if (dev_ingress_queue(dev)) {
+				q = dev_ingress_queue(dev)->qdisc_sleeping;
 			}
 		} else {
 			q = dev->qdisc;
@@ -996,7 +997,8 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		if (tcm->tcm_handle && q->handle != tcm->tcm_handle)
 			return -EINVAL;
 	} else {
-		if ((q = qdisc_lookup(dev, tcm->tcm_handle)) == NULL)
+		q = qdisc_lookup(dev, tcm->tcm_handle);
+		if (!q)
 			return -ENOENT;
 	}
 
@@ -1008,7 +1010,8 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 			return -EINVAL;
 		if (q->handle == 0)
 			return -ENOENT;
-		if ((err = qdisc_graft(dev, p, skb, n, clid, NULL, q)) != 0)
+		err = qdisc_graft(dev, p, skb, n, clid, NULL, q);
+		if (err != 0)
 			return err;
 	} else {
 		qdisc_notify(net, skb, n, clid, NULL, q);
@@ -1017,7 +1020,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 }
 
 /*
-   Create/change qdisc.
+ * Create/change qdisc.
  */
 
 static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
@@ -1036,7 +1039,8 @@ replay:
 	clid = tcm->tcm_parent;
 	q = p = NULL;
 
-	if ((dev = __dev_get_by_index(net, tcm->tcm_ifindex)) == NULL)
+	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
+	if (!dev)
 		return -ENODEV;
 
 	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
@@ -1046,12 +1050,12 @@ replay:
 	if (clid) {
 		if (clid != TC_H_ROOT) {
 			if (clid != TC_H_INGRESS) {
-				if ((p = qdisc_lookup(dev, TC_H_MAJ(clid))) == NULL)
+				p = qdisc_lookup(dev, TC_H_MAJ(clid));
+				if (!p)
 					return -ENOENT;
 				q = qdisc_leaf(p, clid);
-			} else { /* ingress */
-				if (dev_ingress_queue_create(dev))
-					q = dev_ingress_queue(dev)->qdisc_sleeping;
+			} else if (dev_ingress_queue_create(dev)) {
+				q = dev_ingress_queue(dev)->qdisc_sleeping;
 			}
 		} else {
 			q = dev->qdisc;
@@ -1063,13 +1067,14 @@ replay:
 
 		if (!q || !tcm->tcm_handle || q->handle != tcm->tcm_handle) {
 			if (tcm->tcm_handle) {
-				if (q && !(n->nlmsg_flags&NLM_F_REPLACE))
+				if (q && !(n->nlmsg_flags & NLM_F_REPLACE))
 					return -EEXIST;
 				if (TC_H_MIN(tcm->tcm_handle))
 					return -EINVAL;
-				if ((q = qdisc_lookup(dev, tcm->tcm_handle)) == NULL)
+				q = qdisc_lookup(dev, tcm->tcm_handle);
+				if (!q)
 					goto create_n_graft;
-				if (n->nlmsg_flags&NLM_F_EXCL)
+				if (n->nlmsg_flags & NLM_F_EXCL)
 					return -EEXIST;
 				if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id))
 					return -EINVAL;
@@ -1079,7 +1084,7 @@ replay:
 				atomic_inc(&q->refcnt);
 				goto graft;
 			} else {
-				if (q == NULL)
+				if (!q)
 					goto create_n_graft;
 
 				/* This magic test requires explanation.
@@ -1101,9 +1106,9 @@ replay:
 				 *   For now we select create/graft, if
 				 *   user gave KIND, which does not match existing.
 				 */
-				if ((n->nlmsg_flags&NLM_F_CREATE) &&
-				    (n->nlmsg_flags&NLM_F_REPLACE) &&
-				    ((n->nlmsg_flags&NLM_F_EXCL) ||
+				if ((n->nlmsg_flags & NLM_F_CREATE) &&
+				    (n->nlmsg_flags & NLM_F_REPLACE) &&
+				    ((n->nlmsg_flags & NLM_F_EXCL) ||
 				     (tca[TCA_KIND] &&
 				      nla_strcmp(tca[TCA_KIND], q->ops->id))))
 					goto create_n_graft;
@@ -1118,7 +1123,7 @@ replay:
 	/* Change qdisc parameters */
 	if (q == NULL)
 		return -ENOENT;
-	if (n->nlmsg_flags&NLM_F_EXCL)
+	if (n->nlmsg_flags & NLM_F_EXCL)
 		return -EEXIST;
 	if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id))
 		return -EINVAL;
@@ -1128,7 +1133,7 @@ replay:
 	return err;
 
 create_n_graft:
-	if (!(n->nlmsg_flags&NLM_F_CREATE))
+	if (!(n->nlmsg_flags & NLM_F_CREATE))
 		return -ENOENT;
 	if (clid == TC_H_INGRESS) {
 		if (dev_ingress_queue(dev))
@@ -1234,16 +1239,19 @@ static int qdisc_notify(struct net *net, struct sk_buff *oskb,
 		return -ENOBUFS;
 
 	if (old && !tc_qdisc_dump_ignore(old)) {
-		if (tc_fill_qdisc(skb, old, clid, pid, n->nlmsg_seq, 0, RTM_DELQDISC) < 0)
+		if (tc_fill_qdisc(skb, old, clid, pid, n->nlmsg_seq,
+				  0, RTM_DELQDISC) < 0)
 			goto err_out;
 	}
 	if (new && !tc_qdisc_dump_ignore(new)) {
-		if (tc_fill_qdisc(skb, new, clid, pid, n->nlmsg_seq, old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
+		if (tc_fill_qdisc(skb, new, clid, pid, n->nlmsg_seq,
+				  old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
 			goto err_out;
 	}
 
 	if (skb->len)
-		return rtnetlink_send(skb, net, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
+		return rtnetlink_send(skb, net, pid, RTNLGRP_TC,
+				      n->nlmsg_flags & NLM_F_ECHO);
 
 err_out:
 	kfree_skb(skb);
@@ -1275,7 +1283,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 			q_idx++;
 			continue;
 		}
-		if (!tc_qdisc_dump_ignore(q) && 
+		if (!tc_qdisc_dump_ignore(q) &&
 		    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
 				  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0)
 			goto done;
@@ -1356,7 +1364,8 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	u32 qid = TC_H_MAJ(clid);
 	int err;
 
-	if ((dev = __dev_get_by_index(net, tcm->tcm_ifindex)) == NULL)
+	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
+	if (!dev)
 		return -ENODEV;
 
 	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
@@ -1391,9 +1400,9 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 			qid = dev->qdisc->handle;
 
 		/* Now qid is genuine qdisc handle consistent
-		   both with parent and child.
-
-		   TC_H_MAJ(pid) still may be unspecified, complete it now.
+		 * both with parent and child.
+		 *
+		 * TC_H_MAJ(pid) still may be unspecified, complete it now.
 		 */
 		if (pid)
 			pid = TC_H_MAKE(qid, pid);
@@ -1403,7 +1412,8 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	}
 
 	/* OK. Locate qdisc */
-	if ((q = qdisc_lookup(dev, qid)) == NULL)
+	q = qdisc_lookup(dev, qid);
+	if (!q)
 		return -ENOENT;
 
 	/* An check that it supports classes */
@@ -1423,13 +1433,14 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 
 	if (cl == 0) {
 		err = -ENOENT;
-		if (n->nlmsg_type != RTM_NEWTCLASS || !(n->nlmsg_flags&NLM_F_CREATE))
+		if (n->nlmsg_type != RTM_NEWTCLASS ||
+		    !(n->nlmsg_flags & NLM_F_CREATE))
 			goto out;
 	} else {
 		switch (n->nlmsg_type) {
 		case RTM_NEWTCLASS:
 			err = -EEXIST;
-			if (n->nlmsg_flags&NLM_F_EXCL)
+			if (n->nlmsg_flags & NLM_F_EXCL)
 				goto out;
 			break;
 		case RTM_DELTCLASS:
@@ -1521,14 +1532,14 @@ static int tclass_notify(struct net *net, struct sk_buff *oskb,
 		return -EINVAL;
 	}
 
-	return rtnetlink_send(skb, net, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
+	return rtnetlink_send(skb, net, pid, RTNLGRP_TC,
+			      n->nlmsg_flags & NLM_F_ECHO);
 }
 
-struct qdisc_dump_args
-{
-	struct qdisc_walker w;
-	struct sk_buff *skb;
-	struct netlink_callback *cb;
+struct qdisc_dump_args {
+	struct qdisc_walker	w;
+	struct sk_buff		*skb;
+	struct netlink_callback	*cb;
 };
 
 static int qdisc_class_dump(struct Qdisc *q, unsigned long cl, struct qdisc_walker *arg)
@@ -1590,7 +1601,7 @@ static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
 
 static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct tcmsg *tcm = (struct tcmsg*)NLMSG_DATA(cb->nlh);
+	struct tcmsg *tcm = (struct tcmsg *)NLMSG_DATA(cb->nlh);
 	struct net *net = sock_net(skb->sk);
 	struct netdev_queue *dev_queue;
 	struct net_device *dev;
@@ -1598,7 +1609,8 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 
 	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
 		return 0;
-	if ((dev = dev_get_by_index(net, tcm->tcm_ifindex)) == NULL)
+	dev = dev_get_by_index(net, tcm->tcm_ifindex);
+	if (!dev)
 		return 0;
 
 	s_t = cb->args[0];
@@ -1621,19 +1633,22 @@ done:
 }
 
 /* Main classifier routine: scans classifier chain attached
-   to this qdisc, (optionally) tests for protocol and asks
-   specific classifiers.
+ * to this qdisc, (optionally) tests for protocol and asks
+ * specific classifiers.
  */
 int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
 		       struct tcf_result *res)
 {
 	__be16 protocol = skb->protocol;
-	int err = 0;
+	int err;
 
 	for (; tp; tp = tp->next) {
-		if ((tp->protocol == protocol ||
-		     tp->protocol == htons(ETH_P_ALL)) &&
-		    (err = tp->classify(skb, tp, res)) >= 0) {
+		if (tp->protocol != protocol &&
+		    tp->protocol != htons(ETH_P_ALL))
+			continue;
+		err = tp->classify(skb, tp, res);
+
+		if (err >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 			if (err != TC_ACT_RECLASSIFY && skb->tc_verd)
 				skb->tc_verd = SET_TC_VERD(skb->tc_verd, 0);
@@ -1664,11 +1679,11 @@ reclassify:
 
 		if (verd++ >= MAX_REC_LOOP) {
 			if (net_ratelimit())
-				printk(KERN_NOTICE
-				       "%s: packet reclassify loop"
+				pr_notice("%s: packet reclassify loop"
 					  " rule prio %u protocol %02x\n",
-				       tp->q->ops->id,
-				       tp->prio & 0xffff, ntohs(tp->protocol));
+					  tp->q->ops->id,
+					  tp->prio & 0xffff,
+					  ntohs(tp->protocol));
 			return TC_ACT_SHOT;
 		}
 		skb->tc_verd = SET_TC_VERD(skb->tc_verd, verd);
@@ -1761,7 +1776,7 @@ static int __init pktsched_init(void)
 
 	err = register_pernet_subsys(&psched_net_ops);
 	if (err) {
-		printk(KERN_ERR "pktsched_init: "
+		pr_err("pktsched_init: "
 		       "cannot initialize per netns operations\n");
 		return err;
 	}
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 943d733..3f08158 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -319,7 +319,7 @@ static int atm_tc_delete(struct Qdisc *sch, unsigned long arg)
 	 * creation), and one for the reference held when calling delete.
 	 */
 	if (flow->ref < 2) {
-		printk(KERN_ERR "atm_tc_delete: flow->ref == %d\n", flow->ref);
+		pr_err("atm_tc_delete: flow->ref == %d\n", flow->ref);
 		return -EINVAL;
 	}
 	if (flow->ref > 2)
@@ -384,12 +384,12 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			}
 		}
 		flow = NULL;
-	done:
-		;		
+done:
+		;
 	}
-	if (!flow)
+	if (!flow) {
 		flow = &p->link;
-	else {
+	} else {
 		if (flow->vcc)
 			ATM_SKB(skb)->atm_options = flow->vcc->atm_options;
 		/*@@@ looks good ... but it's not supposed to work :-) */
@@ -576,8 +576,7 @@ static void atm_tc_destroy(struct Qdisc *sch)
 
 	list_for_each_entry_safe(flow, tmp, &p->flows, list) {
 		if (flow->ref > 1)
-			printk(KERN_ERR "atm_destroy: %p->ref = %d\n", flow,
-			       flow->ref);
+			pr_err("atm_destroy: %p->ref = %d\n", flow, flow->ref);
 		atm_tc_put(sch, (unsigned long)flow);
 	}
 	tasklet_kill(&p->task);
@@ -616,9 +615,8 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 	}
 	if (flow->excess)
 		NLA_PUT_U32(skb, TCA_ATM_EXCESS, flow->classid);
-	else {
+	else
 		NLA_PUT_U32(skb, TCA_ATM_EXCESS, 0);
-	}
 
 	nla_nest_end(skb, nest);
 	return skb->len;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index c80d1c2..4aaf44c 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -72,8 +72,7 @@
 struct cbq_sched_data;
 
 
-struct cbq_class
-{
+struct cbq_class {
 	struct Qdisc_class_common common;
 	struct cbq_class	*next_alive;	/* next class with backlog in this priority band */
 
@@ -139,19 +138,18 @@ struct cbq_class
 	int			refcnt;
 	int			filters;
 
-	struct cbq_class 	*defaults[TC_PRIO_MAX+1];
+	struct cbq_class	*defaults[TC_PRIO_MAX + 1];
 };
 
-struct cbq_sched_data
-{
+struct cbq_sched_data {
 	struct Qdisc_class_hash	clhash;			/* Hash table of all classes */
-	int			nclasses[TC_CBQ_MAXPRIO+1];
-	unsigned		quanta[TC_CBQ_MAXPRIO+1];
+	int			nclasses[TC_CBQ_MAXPRIO + 1];
+	unsigned int		quanta[TC_CBQ_MAXPRIO + 1];
 
 	struct cbq_class	link;
 
-	unsigned		activemask;
-	struct cbq_class	*active[TC_CBQ_MAXPRIO+1];	/* List of all classes
+	unsigned int		activemask;
+	struct cbq_class	*active[TC_CBQ_MAXPRIO + 1];	/* List of all classes
 								   with backlog */
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -162,7 +160,7 @@ struct cbq_sched_data
 	int			tx_len;
 	psched_time_t		now;		/* Cached timestamp */
 	psched_time_t		now_rt;		/* Cached real time */
-	unsigned		pmask;
+	unsigned int		pmask;
 
 	struct hrtimer		delay_timer;
 	struct qdisc_watchdog	watchdog;	/* Watchdog timer,
@@ -175,9 +173,9 @@ struct cbq_sched_data
 };
 
 
-#define L2T(cl,len)	qdisc_l2t((cl)->R_tab,len)
+#define L2T(cl, len)	qdisc_l2t((cl)->R_tab, len)
 
-static __inline__ struct cbq_class *
+static inline struct cbq_class *
 cbq_class_lookup(struct cbq_sched_data *q, u32 classid)
 {
 	struct Qdisc_class_common *clc;
@@ -193,25 +191,27 @@ cbq_class_lookup(struct cbq_sched_data *q, u32 classid)
 static struct cbq_class *
 cbq_reclassify(struct sk_buff *skb, struct cbq_class *this)
 {
-	struct cbq_class *cl, *new;
+	struct cbq_class *cl;
 
-	for (cl = this->tparent; cl; cl = cl->tparent)
-		if ((new = cl->defaults[TC_PRIO_BESTEFFORT]) != NULL && new != this)
-			return new;
+	for (cl = this->tparent; cl; cl = cl->tparent) {
+		struct cbq_class *new = cl->defaults[TC_PRIO_BESTEFFORT];
 
+		if (new != NULL && new != this)
+			return new;
+	}
 	return NULL;
 }
 
 #endif
 
 /* Classify packet. The procedure is pretty complicated, but
-   it allows us to combine link sharing and priority scheduling
-   transparently.
-
-   Namely, you can put link sharing rules (f.e. route based) at root of CBQ,
-   so that it resolves to split nodes. Then packets are classified
-   by logical priority, or a more specific classifier may be attached
-   to the split node.
+ * it allows us to combine link sharing and priority scheduling
+ * transparently.
+ *
+ * Namely, you can put link sharing rules (f.e. route based) at root of CBQ,
+ * so that it resolves to split nodes. Then packets are classified
+ * by logical priority, or a more specific classifier may be attached
+ * to the split node.
  */
 
 static struct cbq_class *
@@ -227,7 +227,7 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	/*
 	 *  Step 1. If skb->priority points to one of our classes, use it.
 	 */
-	if (TC_H_MAJ(prio^sch->handle) == 0 &&
+	if (TC_H_MAJ(prio ^ sch->handle) == 0 &&
 	    (cl = cbq_class_lookup(q, prio)) != NULL)
 		return cl;
 
@@ -243,10 +243,11 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		    (result = tc_classify_compat(skb, head->filter_list, &res)) < 0)
 			goto fallback;
 
-		if ((cl = (void*)res.class) == NULL) {
+		cl = (void *)res.class;
+		if (!cl) {
 			if (TC_H_MAJ(res.classid))
 				cl = cbq_class_lookup(q, res.classid);
-			else if ((cl = defmap[res.classid&TC_PRIO_MAX]) == NULL)
+			else if ((cl = defmap[res.classid & TC_PRIO_MAX]) == NULL)
 				cl = defmap[TC_PRIO_BESTEFFORT];
 
 			if (cl == NULL || cl->level >= head->level)
@@ -282,7 +283,7 @@ fallback:
 	 * Step 4. No success...
 	 */
 	if (TC_H_MAJ(prio) == 0 &&
-	    !(cl = head->defaults[prio&TC_PRIO_MAX]) &&
+	    !(cl = head->defaults[prio & TC_PRIO_MAX]) &&
 	    !(cl = head->defaults[TC_PRIO_BESTEFFORT]))
 		return head;
 
@@ -290,12 +291,12 @@ fallback:
 }
 
 /*
-   A packet has just been enqueued on the empty class.
-   cbq_activate_class adds it to the tail of active class list
-   of its priority band.
+ * A packet has just been enqueued on the empty class.
+ * cbq_activate_class adds it to the tail of active class list
+ * of its priority band.
  */
 
-static __inline__ void cbq_activate_class(struct cbq_class *cl)
+static inline void cbq_activate_class(struct cbq_class *cl)
 {
 	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	int prio = cl->cpriority;
@@ -314,9 +315,9 @@ static __inline__ void cbq_activate_class(struct cbq_class *cl)
 }
 
 /*
-   Unlink class from active chain.
-   Note that this same procedure is done directly in cbq_dequeue*
-   during round-robin procedure.
+ * Unlink class from active chain.
+ * Note that this same procedure is done directly in cbq_dequeue*
+ * during round-robin procedure.
  */
 
 static void cbq_deactivate_class(struct cbq_class *this)
@@ -350,7 +351,7 @@ cbq_mark_toplevel(struct cbq_sched_data *q, struct cbq_class *cl)
 {
 	int toplevel = q->toplevel;
 
-	if (toplevel > cl->level && !(cl->q->flags&TCQ_F_THROTTLED)) {
+	if (toplevel > cl->level && !(cl->q->flags & TCQ_F_THROTTLED)) {
 		psched_time_t now;
 		psched_tdiff_t incr;
 
@@ -363,7 +364,7 @@ cbq_mark_toplevel(struct cbq_sched_data *q, struct cbq_class *cl)
 				q->toplevel = cl->level;
 				return;
 			}
-		} while ((cl=cl->borrow) != NULL && toplevel > cl->level);
+		} while ((cl = cl->borrow) != NULL && toplevel > cl->level);
 	}
 }
 
@@ -418,11 +419,11 @@ static void cbq_ovl_classic(struct cbq_class *cl)
 		delay += cl->offtime;
 
 		/*
-		   Class goes to sleep, so that it will have no
-		   chance to work avgidle. Let's forgive it 8)
-
-		   BTW cbq-2.0 has a crap in this
-		   place, apparently they forgot to shift it by cl->ewma_log.
+		 * Class goes to sleep, so that it will have no
+		 * chance to work avgidle. Let's forgive it 8)
+		 *
+		 * BTW cbq-2.0 has a crap in this
+		 * place, apparently they forgot to shift it by cl->ewma_log.
 		 */
 		if (cl->avgidle < 0)
 			delay -= (-cl->avgidle) - ((-cl->avgidle) >> cl->ewma_log);
@@ -439,8 +440,8 @@ static void cbq_ovl_classic(struct cbq_class *cl)
 		q->wd_expires = delay;
 
 	/* Dirty work! We must schedule wakeups based on
-	   real available rate, rather than leaf rate,
-	   which may be tiny (even zero).
+	 * real available rate, rather than leaf rate,
+	 * which may be tiny (even zero).
 	 */
 	if (q->toplevel == TC_CBQ_MAXLEVEL) {
 		struct cbq_class *b;
@@ -460,7 +461,7 @@ static void cbq_ovl_classic(struct cbq_class *cl)
 }
 
 /* TC_CBQ_OVL_RCLASSIC: penalize by offtime classes in hierarchy, when
-   they go overlimit
+ * they go overlimit
  */
 
 static void cbq_ovl_rclassic(struct cbq_class *cl)
@@ -595,7 +596,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 	struct Qdisc *sch = q->watchdog.qdisc;
 	psched_time_t now;
 	psched_tdiff_t delay = 0;
-	unsigned pmask;
+	unsigned int pmask;
 
 	now = psched_get_time();
 
@@ -665,15 +666,15 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 #endif
 
 /*
-   It is mission critical procedure.
-
-   We "regenerate" toplevel cutoff, if transmitting class
-   has backlog and it is not regulated. It is not part of
-   original CBQ description, but looks more reasonable.
-   Probably, it is wrong. This question needs further investigation.
-*/
+ * It is mission critical procedure.
+ *
+ * We "regenerate" toplevel cutoff, if transmitting class
+ * has backlog and it is not regulated. It is not part of
+ * original CBQ description, but looks more reasonable.
+ * Probably, it is wrong. This question needs further investigation.
+ */
 
-static __inline__ void
+static inline void
 cbq_update_toplevel(struct cbq_sched_data *q, struct cbq_class *cl,
 		    struct cbq_class *borrowed)
 {
@@ -684,7 +685,7 @@ cbq_update_toplevel(struct cbq_sched_data *q, struct cbq_class *cl,
 					q->toplevel = borrowed->level;
 					return;
 				}
-			} while ((borrowed=borrowed->borrow) != NULL);
+			} while ((borrowed = borrowed->borrow) != NULL);
 		}
 #if 0
 	/* It is not necessary now. Uncommenting it
@@ -712,10 +713,10 @@ cbq_update(struct cbq_sched_data *q)
 		cl->bstats.bytes += len;
 
 		/*
-		   (now - last) is total time between packet right edges.
-		   (last_pktlen/rate) is "virtual" busy time, so that
-
-			 idle = (now - last) - last_pktlen/rate
+		 * (now - last) is total time between packet right edges.
+		 * (last_pktlen/rate) is "virtual" busy time, so that
+		 *
+		 *	idle = (now - last) - last_pktlen/rate
 		 */
 
 		idle = q->now - cl->last;
@@ -725,9 +726,9 @@ cbq_update(struct cbq_sched_data *q)
 			idle -= L2T(cl, len);
 
 		/* true_avgidle := (1-W)*true_avgidle + W*idle,
-		   where W=2^{-ewma_log}. But cl->avgidle is scaled:
-		   cl->avgidle == true_avgidle/W,
-		   hence:
+		 * where W=2^{-ewma_log}. But cl->avgidle is scaled:
+		 * cl->avgidle == true_avgidle/W,
+		 * hence:
 		 */
 			avgidle += idle - (avgidle>>cl->ewma_log);
 		}
@@ -741,22 +742,22 @@ cbq_update(struct cbq_sched_data *q)
 			cl->avgidle = avgidle;
 
 			/* Calculate expected time, when this class
-			   will be allowed to send.
-			   It will occur, when:
-			   (1-W)*true_avgidle + W*delay = 0, i.e.
-			   idle = (1/W - 1)*(-true_avgidle)
-			   or
-			   idle = (1 - W)*(-cl->avgidle);
+			 * will be allowed to send.
+			 * It will occur, when:
+			 * (1-W)*true_avgidle + W*delay = 0, i.e.
+			 * idle = (1/W - 1)*(-true_avgidle)
+			 * or
+			 * idle = (1 - W)*(-cl->avgidle);
 			 */
 			idle = (-avgidle) - ((-avgidle) >> cl->ewma_log);
 
 			/*
-			   That is not all.
-			   To maintain the rate allocated to the class,
-			   we add to undertime virtual clock,
-			   necessary to complete transmitted packet.
-			   (len/phys_bandwidth has been already passed
-			   to the moment of cbq_update)
+			 * That is not all.
+			 * To maintain the rate allocated to the class,
+			 * we add to undertime virtual clock,
+			 * necessary to complete transmitted packet.
+			 * (len/phys_bandwidth has been already passed
+			 * to the moment of cbq_update)
 			 */
 
 			idle -= L2T(&q->link, len);
@@ -778,7 +779,7 @@ cbq_update(struct cbq_sched_data *q)
 	cbq_update_toplevel(q, this, q->tx_borrowed);
 }
 
-static __inline__ struct cbq_class *
+static inline struct cbq_class *
 cbq_under_limit(struct cbq_class *cl)
 {
 	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
@@ -794,16 +795,17 @@ cbq_under_limit(struct cbq_class *cl)
 
 	do {
 		/* It is very suspicious place. Now overlimit
-		   action is generated for not bounded classes
-		   only if link is completely congested.
-		   Though it is in agree with ancestor-only paradigm,
-		   it looks very stupid. Particularly,
-		   it means that this chunk of code will either
-		   never be called or result in strong amplification
-		   of burstiness. Dangerous, silly, and, however,
-		   no another solution exists.
+		 * action is generated for not bounded classes
+		 * only if link is completely congested.
+		 * Though it is in agree with ancestor-only paradigm,
+		 * it looks very stupid. Particularly,
+		 * it means that this chunk of code will either
+		 * never be called or result in strong amplification
+		 * of burstiness. Dangerous, silly, and, however,
+		 * no another solution exists.
 		 */
-		if ((cl = cl->borrow) == NULL) {
+		cl = cl->borrow;
+		if (!cl) {
 			this_cl->qstats.overlimits++;
 			this_cl->overlimit(this_cl);
 			return NULL;
@@ -816,7 +818,7 @@ cbq_under_limit(struct cbq_class *cl)
 	return cl;
 }
 
-static __inline__ struct sk_buff *
+static inline struct sk_buff *
 cbq_dequeue_prio(struct Qdisc *sch, int prio)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
@@ -840,7 +842,7 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 
 			if (cl->deficit <= 0) {
 				/* Class exhausted its allotment per
-				   this round. Switch to the next one.
+				 * this round. Switch to the next one.
 				 */
 				deficit = 1;
 				cl->deficit += cl->quantum;
@@ -850,8 +852,8 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 			skb = cl->q->dequeue(cl->q);
 
 			/* Class did not give us any skb :-(
-			   It could occur even if cl->q->q.qlen != 0
-			   f.e. if cl->q == "tbf"
+			 * It could occur even if cl->q->q.qlen != 0
+			 * f.e. if cl->q == "tbf"
 			 */
 			if (skb == NULL)
 				goto skip_class;
@@ -880,7 +882,7 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 skip_class:
 			if (cl->q->q.qlen == 0 || prio != cl->cpriority) {
 				/* Class is empty or penalized.
-				   Unlink it from active chain.
+				 * Unlink it from active chain.
 				 */
 				cl_prev->next_alive = cl->next_alive;
 				cl->next_alive = NULL;
@@ -919,14 +921,14 @@ next_class:
 	return NULL;
 }
 
-static __inline__ struct sk_buff *
+static inline struct sk_buff *
 cbq_dequeue_1(struct Qdisc *sch)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
-	unsigned activemask;
+	unsigned int activemask;
 
-	activemask = q->activemask&0xFF;
+	activemask = q->activemask & 0xFF;
 	while (activemask) {
 		int prio = ffz(~activemask);
 		activemask &= ~(1<<prio);
@@ -951,11 +953,11 @@ cbq_dequeue(struct Qdisc *sch)
 	if (q->tx_class) {
 		psched_tdiff_t incr2;
 		/* Time integrator. We calculate EOS time
-		   by adding expected packet transmission time.
-		   If real time is greater, we warp artificial clock,
-		   so that:
-
-		   cbq_time = max(real_time, work);
+		 * by adding expected packet transmission time.
+		 * If real time is greater, we warp artificial clock,
+		 * so that:
+		 *
+		 * cbq_time = max(real_time, work);
 		 */
 		incr2 = L2T(&q->link, q->tx_len);
 		q->now += incr2;
@@ -977,22 +979,22 @@ cbq_dequeue(struct Qdisc *sch)
 		}
 
 		/* All the classes are overlimit.
-
-		   It is possible, if:
-
-		   1. Scheduler is empty.
-		   2. Toplevel cutoff inhibited borrowing.
-		   3. Root class is overlimit.
-
-		   Reset 2d and 3d conditions and retry.
-
-		   Note, that NS and cbq-2.0 are buggy, peeking
-		   an arbitrary class is appropriate for ancestor-only
-		   sharing, but not for toplevel algorithm.
-
-		   Our version is better, but slower, because it requires
-		   two passes, but it is unavoidable with top-level sharing.
-		*/
+		 *
+		 * It is possible, if:
+		 *
+		 * 1. Scheduler is empty.
+		 * 2. Toplevel cutoff inhibited borrowing.
+		 * 3. Root class is overlimit.
+		 *
+		 * Reset 2d and 3d conditions and retry.
+		 *
+		 * Note, that NS and cbq-2.0 are buggy, peeking
+		 * an arbitrary class is appropriate for ancestor-only
+		 * sharing, but not for toplevel algorithm.
+		 *
+		 * Our version is better, but slower, because it requires
+		 * two passes, but it is unavoidable with top-level sharing.
+		 */
 
 		if (q->toplevel == TC_CBQ_MAXLEVEL &&
 		    q->link.undertime == PSCHED_PASTPERFECT)
@@ -1003,7 +1005,8 @@ cbq_dequeue(struct Qdisc *sch)
 	}
 
 	/* No packets in scheduler or nobody wants to give them to us :-(
-	   Sigh... start watchdog timer in the last case. */
+	 * Sigh... start watchdog timer in the last case.
+	 */
 
 	if (sch->q.qlen) {
 		sch->qstats.overlimits++;
@@ -1025,13 +1028,14 @@ static void cbq_adjust_levels(struct cbq_class *this)
 		int level = 0;
 		struct cbq_class *cl;
 
-		if ((cl = this->children) != NULL) {
+		cl = this->children;
+		if (cl) {
 			do {
 				if (cl->level > level)
 					level = cl->level;
 			} while ((cl = cl->sibling) != this->children);
 		}
-		this->level = level+1;
+		this->level = level + 1;
 	} while ((this = this->tparent) != NULL);
 }
 
@@ -1047,14 +1051,15 @@ static void cbq_normalize_quanta(struct cbq_sched_data *q, int prio)
 	for (h = 0; h < q->clhash.hashsize; h++) {
 		hlist_for_each_entry(cl, n, &q->clhash.hash[h], common.hnode) {
 			/* BUGGGG... Beware! This expression suffer of
-			   arithmetic overflows!
+			 * arithmetic overflows!
 			 */
 			if (cl->priority == prio) {
 				cl->quantum = (cl->weight*cl->allot*q->nclasses[prio])/
 					q->quanta[prio];
 			}
 			if (cl->quantum <= 0 || cl->quantum>32*qdisc_dev(cl->qdisc)->mtu) {
-				printk(KERN_WARNING "CBQ: class %08x has bad quantum==%ld, repaired.\n", cl->common.classid, cl->quantum);
+				pr_warning("CBQ: class %08x has bad quantum==%ld, repaired.\n",
+					   cl->common.classid, cl->quantum);
 				cl->quantum = qdisc_dev(cl->qdisc)->mtu/2 + 1;
 			}
 		}
@@ -1065,18 +1070,18 @@ static void cbq_sync_defmap(struct cbq_class *cl)
 {
 	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	struct cbq_class *split = cl->split;
-	unsigned h;
+	unsigned int h;
 	int i;
 
 	if (split == NULL)
 		return;
 
-	for (i=0; i<=TC_PRIO_MAX; i++) {
-		if (split->defaults[i] == cl && !(cl->defmap&(1<<i)))
+	for (i = 0; i <= TC_PRIO_MAX; i++) {
+		if (split->defaults[i] == cl && !(cl->defmap & (1<<i)))
 			split->defaults[i] = NULL;
 	}
 
-	for (i=0; i<=TC_PRIO_MAX; i++) {
+	for (i = 0; i <= TC_PRIO_MAX; i++) {
 		int level = split->level;
 
 		if (split->defaults[i])
@@ -1089,7 +1094,7 @@ static void cbq_sync_defmap(struct cbq_class *cl)
 			hlist_for_each_entry(c, n, &q->clhash.hash[h],
 					     common.hnode) {
 				if (c->split == split && c->level < level &&
-				    c->defmap&(1<<i)) {
+				    c->defmap & (1<<i)) {
 					split->defaults[i] = c;
 					level = c->level;
 				}
@@ -1103,7 +1108,8 @@ static void cbq_change_defmap(struct cbq_class *cl, u32 splitid, u32 def, u32 ma
 	struct cbq_class *split = NULL;
 
 	if (splitid == 0) {
-		if ((split = cl->split) == NULL)
+		split = cl->split;
+		if (!split)
 			return;
 		splitid = split->common.classid;
 	}
@@ -1121,9 +1127,9 @@ static void cbq_change_defmap(struct cbq_class *cl, u32 splitid, u32 def, u32 ma
 		cl->defmap = 0;
 		cbq_sync_defmap(cl);
 		cl->split = split;
-		cl->defmap = def&mask;
+		cl->defmap = def & mask;
 	} else
-		cl->defmap = (cl->defmap&~mask)|(def&mask);
+		cl->defmap = (cl->defmap & ~mask) | (def & mask);
 
 	cbq_sync_defmap(cl);
 }
@@ -1136,7 +1142,7 @@ static void cbq_unlink_class(struct cbq_class *this)
 	qdisc_class_hash_remove(&q->clhash, &this->common);
 
 	if (this->tparent) {
-		clp=&this->sibling;
+		clp = &this->sibling;
 		cl = *clp;
 		do {
 			if (cl == this) {
@@ -1175,7 +1181,7 @@ static void cbq_link_class(struct cbq_class *this)
 	}
 }
 
-static unsigned int cbq_drop(struct Qdisc* sch)
+static unsigned int cbq_drop(struct Qdisc *sch)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl, *cl_head;
@@ -1183,7 +1189,8 @@ static unsigned int cbq_drop(struct Qdisc* sch)
 	unsigned int len;
 
 	for (prio = TC_CBQ_MAXPRIO; prio >= 0; prio--) {
-		if ((cl_head = q->active[prio]) == NULL)
+		cl_head = q->active[prio];
+		if (!cl_head)
 			continue;
 
 		cl = cl_head;
@@ -1200,13 +1207,13 @@ static unsigned int cbq_drop(struct Qdisc* sch)
 }
 
 static void
-cbq_reset(struct Qdisc* sch)
+cbq_reset(struct Qdisc *sch)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl;
 	struct hlist_node *n;
 	int prio;
-	unsigned h;
+	unsigned int h;
 
 	q->activemask = 0;
 	q->pmask = 0;
@@ -1238,21 +1245,21 @@ cbq_reset(struct Qdisc* sch)
 
 static int cbq_set_lss(struct cbq_class *cl, struct tc_cbq_lssopt *lss)
 {
-	if (lss->change&TCF_CBQ_LSS_FLAGS) {
-		cl->share = (lss->flags&TCF_CBQ_LSS_ISOLATED) ? NULL : cl->tparent;
-		cl->borrow = (lss->flags&TCF_CBQ_LSS_BOUNDED) ? NULL : cl->tparent;
+	if (lss->change & TCF_CBQ_LSS_FLAGS) {
+		cl->share = (lss->flags & TCF_CBQ_LSS_ISOLATED) ? NULL : cl->tparent;
+		cl->borrow = (lss->flags & TCF_CBQ_LSS_BOUNDED) ? NULL : cl->tparent;
 	}
-	if (lss->change&TCF_CBQ_LSS_EWMA)
+	if (lss->change & TCF_CBQ_LSS_EWMA)
 		cl->ewma_log = lss->ewma_log;
-	if (lss->change&TCF_CBQ_LSS_AVPKT)
+	if (lss->change & TCF_CBQ_LSS_AVPKT)
 		cl->avpkt = lss->avpkt;
-	if (lss->change&TCF_CBQ_LSS_MINIDLE)
+	if (lss->change & TCF_CBQ_LSS_MINIDLE)
 		cl->minidle = -(long)lss->minidle;
-	if (lss->change&TCF_CBQ_LSS_MAXIDLE) {
+	if (lss->change & TCF_CBQ_LSS_MAXIDLE) {
 		cl->maxidle = lss->maxidle;
 		cl->avgidle = lss->maxidle;
 	}
-	if (lss->change&TCF_CBQ_LSS_OFFTIME)
+	if (lss->change & TCF_CBQ_LSS_OFFTIME)
 		cl->offtime = lss->offtime;
 	return 0;
 }
@@ -1280,10 +1287,10 @@ static int cbq_set_wrr(struct cbq_class *cl, struct tc_cbq_wrropt *wrr)
 	if (wrr->weight)
 		cl->weight = wrr->weight;
 	if (wrr->priority) {
-		cl->priority = wrr->priority-1;
+		cl->priority = wrr->priority - 1;
 		cl->cpriority = cl->priority;
 		if (cl->priority >= cl->priority2)
-			cl->priority2 = TC_CBQ_MAXPRIO-1;
+			cl->priority2 = TC_CBQ_MAXPRIO - 1;
 	}
 
 	cbq_addprio(q, cl);
@@ -1300,10 +1307,10 @@ static int cbq_set_overlimit(struct cbq_class *cl, struct tc_cbq_ovl *ovl)
 		cl->overlimit = cbq_ovl_delay;
 		break;
 	case TC_CBQ_OVL_LOWPRIO:
-		if (ovl->priority2-1 >= TC_CBQ_MAXPRIO ||
-		    ovl->priority2-1 <= cl->priority)
+		if (ovl->priority2 - 1 >= TC_CBQ_MAXPRIO ||
+		    ovl->priority2 - 1 <= cl->priority)
 			return -EINVAL;
-		cl->priority2 = ovl->priority2-1;
+		cl->priority2 = ovl->priority2 - 1;
 		cl->overlimit = cbq_ovl_lowprio;
 		break;
 	case TC_CBQ_OVL_DROP:
@@ -1382,9 +1389,9 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!q->link.q)
 		q->link.q = &noop_qdisc;
 
-	q->link.priority = TC_CBQ_MAXPRIO-1;
-	q->link.priority2 = TC_CBQ_MAXPRIO-1;
-	q->link.cpriority = TC_CBQ_MAXPRIO-1;
+	q->link.priority = TC_CBQ_MAXPRIO - 1;
+	q->link.priority2 = TC_CBQ_MAXPRIO - 1;
+	q->link.cpriority = TC_CBQ_MAXPRIO - 1;
 	q->link.ovl_strategy = TC_CBQ_OVL_CLASSIC;
 	q->link.overlimit = cbq_ovl_classic;
 	q->link.allot = psched_mtu(qdisc_dev(sch));
@@ -1415,7 +1422,7 @@ put_rtab:
 	return err;
 }
 
-static __inline__ int cbq_dump_rate(struct sk_buff *skb, struct cbq_class *cl)
+static int cbq_dump_rate(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 
@@ -1427,7 +1434,7 @@ nla_put_failure:
 	return -1;
 }
 
-static __inline__ int cbq_dump_lss(struct sk_buff *skb, struct cbq_class *cl)
+static int cbq_dump_lss(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_cbq_lssopt opt;
@@ -1452,15 +1459,15 @@ nla_put_failure:
 	return -1;
 }
 
-static __inline__ int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
+static int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_cbq_wrropt opt;
 
 	opt.flags = 0;
 	opt.allot = cl->allot;
-	opt.priority = cl->priority+1;
-	opt.cpriority = cl->cpriority+1;
+	opt.priority = cl->priority + 1;
+	opt.cpriority = cl->cpriority + 1;
 	opt.weight = cl->weight;
 	NLA_PUT(skb, TCA_CBQ_WRROPT, sizeof(opt), &opt);
 	return skb->len;
@@ -1470,13 +1477,13 @@ nla_put_failure:
 	return -1;
 }
 
-static __inline__ int cbq_dump_ovl(struct sk_buff *skb, struct cbq_class *cl)
+static int cbq_dump_ovl(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_cbq_ovl opt;
 
 	opt.strategy = cl->ovl_strategy;
-	opt.priority2 = cl->priority2+1;
+	opt.priority2 = cl->priority2 + 1;
 	opt.pad = 0;
 	opt.penalty = cl->penalty;
 	NLA_PUT(skb, TCA_CBQ_OVL_STRATEGY, sizeof(opt), &opt);
@@ -1487,7 +1494,7 @@ nla_put_failure:
 	return -1;
 }
 
-static __inline__ int cbq_dump_fopt(struct sk_buff *skb, struct cbq_class *cl)
+static int cbq_dump_fopt(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_cbq_fopt opt;
@@ -1506,7 +1513,7 @@ nla_put_failure:
 }
 
 #ifdef CONFIG_NET_CLS_ACT
-static __inline__ int cbq_dump_police(struct sk_buff *skb, struct cbq_class *cl)
+static int cbq_dump_police(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_cbq_police opt;
@@ -1570,7 +1577,7 @@ static int
 cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 	       struct sk_buff *skb, struct tcmsg *tcm)
 {
-	struct cbq_class *cl = (struct cbq_class*)arg;
+	struct cbq_class *cl = (struct cbq_class *)arg;
 	struct nlattr *nest;
 
 	if (cl->tparent)
@@ -1598,7 +1605,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	struct gnet_dump *d)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	struct cbq_class *cl = (struct cbq_class*)arg;
+	struct cbq_class *cl = (struct cbq_class *)arg;
 
 	cl->qstats.qlen = cl->q->q.qlen;
 	cl->xstats.avgidle = cl->avgidle;
@@ -1618,7 +1625,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 		     struct Qdisc **old)
 {
-	struct cbq_class *cl = (struct cbq_class*)arg;
+	struct cbq_class *cl = (struct cbq_class *)arg;
 
 	if (new == NULL) {
 		new = qdisc_create_dflt(sch->dev_queue,
@@ -1641,10 +1648,9 @@ static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	return 0;
 }
 
-static struct Qdisc *
-cbq_leaf(struct Qdisc *sch, unsigned long arg)
+static struct Qdisc *cbq_leaf(struct Qdisc *sch, unsigned long arg)
 {
-	struct cbq_class *cl = (struct cbq_class*)arg;
+	struct cbq_class *cl = (struct cbq_class *)arg;
 
 	return cl->q;
 }
@@ -1683,13 +1689,12 @@ static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 		kfree(cl);
 }
 
-static void
-cbq_destroy(struct Qdisc* sch)
+static void cbq_destroy(struct Qdisc *sch)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct hlist_node *n, *next;
 	struct cbq_class *cl;
-	unsigned h;
+	unsigned int h;
 
 #ifdef CONFIG_NET_CLS_ACT
 	q->rx_class = NULL;
@@ -1713,7 +1718,7 @@ cbq_destroy(struct Qdisc* sch)
 
 static void cbq_put(struct Qdisc *sch, unsigned long arg)
 {
-	struct cbq_class *cl = (struct cbq_class*)arg;
+	struct cbq_class *cl = (struct cbq_class *)arg;
 
 	if (--cl->refcnt == 0) {
 #ifdef CONFIG_NET_CLS_ACT
@@ -1736,7 +1741,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 {
 	int err;
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	struct cbq_class *cl = (struct cbq_class*)*arg;
+	struct cbq_class *cl = (struct cbq_class *)*arg;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_CBQ_MAX + 1];
 	struct cbq_class *parent;
@@ -1828,13 +1833,14 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 
 	if (classid) {
 		err = -EINVAL;
-		if (TC_H_MAJ(classid^sch->handle) || cbq_class_lookup(q, classid))
+		if (TC_H_MAJ(classid ^ sch->handle) ||
+		    cbq_class_lookup(q, classid))
 			goto failure;
 	} else {
 		int i;
-		classid = TC_H_MAKE(sch->handle,0x8000);
+		classid = TC_H_MAKE(sch->handle, 0x8000);
 
-		for (i=0; i<0x8000; i++) {
+		for (i = 0; i < 0x8000; i++) {
 			if (++q->hgenerator >= 0x8000)
 				q->hgenerator = 1;
 			if (cbq_class_lookup(q, classid|q->hgenerator) == NULL)
@@ -1891,11 +1897,11 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	cl->minidle = -0x7FFFFFFF;
 	cbq_set_lss(cl, nla_data(tb[TCA_CBQ_LSSOPT]));
 	cbq_set_wrr(cl, nla_data(tb[TCA_CBQ_WRROPT]));
-	if (cl->ewma_log==0)
+	if (cl->ewma_log == 0)
 		cl->ewma_log = q->link.ewma_log;
-	if (cl->maxidle==0)
+	if (cl->maxidle == 0)
 		cl->maxidle = q->link.maxidle;
-	if (cl->avpkt==0)
+	if (cl->avpkt == 0)
 		cl->avpkt = q->link.avpkt;
 	cl->overlimit = cbq_ovl_classic;
 	if (tb[TCA_CBQ_OVL_STRATEGY])
@@ -1921,7 +1927,7 @@ failure:
 static int cbq_delete(struct Qdisc *sch, unsigned long arg)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	struct cbq_class *cl = (struct cbq_class*)arg;
+	struct cbq_class *cl = (struct cbq_class *)arg;
 	unsigned int qlen;
 
 	if (cl->filters || cl->children || cl == &q->link)
@@ -1979,7 +1985,7 @@ static unsigned long cbq_bind_filter(struct Qdisc *sch, unsigned long parent,
 				     u32 classid)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	struct cbq_class *p = (struct cbq_class*)parent;
+	struct cbq_class *p = (struct cbq_class *)parent;
 	struct cbq_class *cl = cbq_class_lookup(q, classid);
 
 	if (cl) {
@@ -1993,7 +1999,7 @@ static unsigned long cbq_bind_filter(struct Qdisc *sch, unsigned long parent,
 
 static void cbq_unbind_filter(struct Qdisc *sch, unsigned long arg)
 {
-	struct cbq_class *cl = (struct cbq_class*)arg;
+	struct cbq_class *cl = (struct cbq_class *)arg;
 
 	cl->filters--;
 }
@@ -2003,7 +2009,7 @@ static void cbq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl;
 	struct hlist_node *n;
-	unsigned h;
+	unsigned int h;
 
 	if (arg->stop)
 		return;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 60f4bdd..4970d56 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -137,10 +137,10 @@ static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
 		mask = nla_get_u8(tb[TCA_DSMARK_MASK]);
 
 	if (tb[TCA_DSMARK_VALUE])
-		p->value[*arg-1] = nla_get_u8(tb[TCA_DSMARK_VALUE]);
+		p->value[*arg - 1] = nla_get_u8(tb[TCA_DSMARK_VALUE]);
 
 	if (tb[TCA_DSMARK_MASK])
-		p->mask[*arg-1] = mask;
+		p->mask[*arg - 1] = mask;
 
 	err = 0;
 
@@ -155,8 +155,8 @@ static int dsmark_delete(struct Qdisc *sch, unsigned long arg)
 	if (!dsmark_valid_index(p, arg))
 		return -EINVAL;
 
-	p->mask[arg-1] = 0xff;
-	p->value[arg-1] = 0;
+	p->mask[arg - 1] = 0xff;
+	p->value[arg - 1] = 0;
 
 	return 0;
 }
@@ -175,7 +175,7 @@ static void dsmark_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 		if (p->mask[i] == 0xff && !p->value[i])
 			goto ignore;
 		if (walker->count >= walker->skip) {
-			if (walker->fn(sch, i+1, walker) < 0) {
+			if (walker->fn(sch, i + 1, walker) < 0) {
 				walker->stop = 1;
 				break;
 			}
@@ -304,9 +304,8 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 		 * and don't need yet another qdisc as a bypass.
 		 */
 		if (p->mask[index] != 0xff || p->value[index])
-			printk(KERN_WARNING
-			       "dsmark_dequeue: unsupported protocol %d\n",
-			       ntohs(skb->protocol));
+			pr_warning("dsmark_dequeue: unsupported protocol %d\n",
+				   ntohs(skb->protocol));
 		break;
 	}
 
@@ -424,14 +423,14 @@ static int dsmark_dump_class(struct Qdisc *sch, unsigned long cl,
 	if (!dsmark_valid_index(p, cl))
 		return -EINVAL;
 
-	tcm->tcm_handle = TC_H_MAKE(TC_H_MAJ(sch->handle), cl-1);
+	tcm->tcm_handle = TC_H_MAKE(TC_H_MAJ(sch->handle), cl - 1);
 	tcm->tcm_info = p->q->handle;
 
 	opts = nla_nest_start(skb, TCA_OPTIONS);
 	if (opts == NULL)
 		goto nla_put_failure;
-	NLA_PUT_U8(skb, TCA_DSMARK_MASK, p->mask[cl-1]);
-	NLA_PUT_U8(skb, TCA_DSMARK_VALUE, p->value[cl-1]);
+	NLA_PUT_U8(skb, TCA_DSMARK_MASK, p->mask[cl - 1]);
+	NLA_PUT_U8(skb, TCA_DSMARK_VALUE, p->value[cl - 1]);
 
 	return nla_nest_end(skb, opts);
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index aa4d633..b3075f8 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -19,12 +19,11 @@
 
 /* 1 band FIFO pseudo-"scheduler" */
 
-struct fifo_sched_data
-{
+struct fifo_sched_data {
 	u32 limit;
 };
 
-static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
@@ -34,7 +33,7 @@ static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return qdisc_reshape_fail(skb, sch);
 }
 
-static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
@@ -44,7 +43,7 @@ static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return qdisc_reshape_fail(skb, sch);
 }
 
-static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct sk_buff *skb_head;
 	struct fifo_sched_data *q = qdisc_priv(sch);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 34dc598..33917c3 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -87,8 +87,8 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 		 */
 		kfree_skb(skb);
 		if (net_ratelimit())
-			printk(KERN_WARNING "Dead loop on netdevice %s, "
-			       "fix it urgently!\n", dev_queue->dev->name);
+			pr_warning("Dead loop on netdevice %s, fix it urgently!\n",
+				   dev_queue->dev->name);
 		ret = qdisc_qlen(q);
 	} else {
 		/*
@@ -137,8 +137,8 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	} else {
 		/* Driver returned NETDEV_TX_BUSY - requeue skb */
 		if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
-			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
-			       dev->name, ret, q->q.qlen);
+			pr_warning("BUG %s code %d qlen %d\n",
+				   dev->name, ret, q->q.qlen);
 
 		ret = dev_requeue_skb(skb, q);
 	}
@@ -412,8 +412,9 @@ static struct Qdisc noqueue_qdisc = {
 };
 
 
-static const u8 prio2band[TC_PRIO_MAX+1] =
-	{ 1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1 };
+static const u8 prio2band[TC_PRIO_MAX + 1] = {
+	1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1
+};
 
 /* 3-band FIFO queue: old style, but should be a bit faster than
    generic prio+fifo combination.
@@ -445,7 +446,7 @@ static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *priv,
 	return priv->q + band;
 }
 
-static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
+static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc)
 {
 	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
 		int band = prio2band[skb->priority & TC_PRIO_MAX];
@@ -460,7 +461,7 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
 	return qdisc_drop(skb, qdisc);
 }
 
-static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
+static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
 {
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
 	int band = bitmap2band[priv->bitmap];
@@ -479,7 +480,7 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 	return NULL;
 }
 
-static struct sk_buff *pfifo_fast_peek(struct Qdisc* qdisc)
+static struct sk_buff *pfifo_fast_peek(struct Qdisc *qdisc)
 {
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
 	int band = bitmap2band[priv->bitmap];
@@ -493,7 +494,7 @@ static struct sk_buff *pfifo_fast_peek(struct Qdisc* qdisc)
 	return NULL;
 }
 
-static void pfifo_fast_reset(struct Qdisc* qdisc)
+static void pfifo_fast_reset(struct Qdisc *qdisc)
 {
 	int prio;
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
@@ -510,7 +511,7 @@ static int pfifo_fast_dump(struct Qdisc *qdisc, struct sk_buff *skb)
 {
 	struct tc_prio_qopt opt = { .bands = PFIFO_FAST_BANDS };
 
-	memcpy(&opt.priomap, prio2band, TC_PRIO_MAX+1);
+	memcpy(&opt.priomap, prio2band, TC_PRIO_MAX + 1);
 	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 	return skb->len;
 
@@ -679,20 +680,18 @@ static void attach_one_default_qdisc(struct net_device *dev,
 				     struct netdev_queue *dev_queue,
 				     void *_unused)
 {
-	struct Qdisc *qdisc;
+	struct Qdisc *qdisc = &noqueue_qdisc;
 
 	if (dev->tx_queue_len) {
 		qdisc = qdisc_create_dflt(dev_queue,
 					  &pfifo_fast_ops, TC_H_ROOT);
 		if (!qdisc) {
-			printk(KERN_INFO "%s: activation failed\n", dev->name);
+			netdev_info(dev, "activation failed\n");
 			return;
 		}
 
 		/* Can by-pass the queue discipline for default qdisc */
 		qdisc->flags |= TCQ_F_CAN_BYPASS;
-	} else {
-		qdisc =  &noqueue_qdisc;
 	}
 	dev_queue->qdisc_sleeping = qdisc;
 }
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 51dcc2a..b9493a0 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -32,8 +32,7 @@
 struct gred_sched_data;
 struct gred_sched;
 
-struct gred_sched_data
-{
+struct gred_sched_data {
 	u32		limit;		/* HARD maximal queue length	*/
 	u32      	DP;		/* the drop pramaters */
 	u32		bytesin;	/* bytes seen on virtualQ so far*/
@@ -50,8 +49,7 @@ enum {
 	GRED_RIO_MODE,
 };
 
-struct gred_sched
-{
+struct gred_sched {
 	struct gred_sched_data *tab[MAX_DPs];
 	unsigned long	flags;
 	u32		red_flags;
@@ -150,17 +148,18 @@ static inline int gred_use_harddrop(struct gred_sched *t)
 	return t->red_flags & TC_RED_HARDDROP;
 }
 
-static int gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct gred_sched_data *q=NULL;
-	struct gred_sched *t= qdisc_priv(sch);
+	struct gred_sched_data *q = NULL;
+	struct gred_sched *t = qdisc_priv(sch);
 	unsigned long qavg = 0;
 	u16 dp = tc_index_to_dp(skb);
 
-	if (dp >= t->DPs  || (q = t->tab[dp]) == NULL) {
+	if (dp >= t->DPs || (q = t->tab[dp]) == NULL) {
 		dp = t->def;
 
-		if ((q = t->tab[dp]) == NULL) {
+		q = t->tab[dp];
+		if (!q) {
 			/* Pass through packets not assigned to a DP
 			 * if no default DP has been configured. This
 			 * allows for DP flows to be left untouched.
@@ -183,7 +182,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		for (i = 0; i < t->DPs; i++) {
 			if (t->tab[i] && t->tab[i]->prio < q->prio &&
 			    !red_is_idling(&t->tab[i]->parms))
-				qavg +=t->tab[i]->parms.qavg;
+				qavg += t->tab[i]->parms.qavg;
 		}
 
 	}
@@ -203,28 +202,28 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		gred_store_wred_set(t, q);
 
 	switch (red_action(&q->parms, q->parms.qavg + qavg)) {
-		case RED_DONT_MARK:
-			break;
-
-		case RED_PROB_MARK:
-			sch->qstats.overlimits++;
-			if (!gred_use_ecn(t) || !INET_ECN_set_ce(skb)) {
-				q->stats.prob_drop++;
-				goto congestion_drop;
-			}
-
-			q->stats.prob_mark++;
-			break;
-
-		case RED_HARD_MARK:
-			sch->qstats.overlimits++;
-			if (gred_use_harddrop(t) || !gred_use_ecn(t) ||
-			    !INET_ECN_set_ce(skb)) {
-				q->stats.forced_drop++;
-				goto congestion_drop;
-			}
-			q->stats.forced_mark++;
-			break;
+	case RED_DONT_MARK:
+		break;
+
+	case RED_PROB_MARK:
+		sch->qstats.overlimits++;
+		if (!gred_use_ecn(t) || !INET_ECN_set_ce(skb)) {
+			q->stats.prob_drop++;
+			goto congestion_drop;
+		}
+
+		q->stats.prob_mark++;
+		break;
+
+	case RED_HARD_MARK:
+		sch->qstats.overlimits++;
+		if (gred_use_harddrop(t) || !gred_use_ecn(t) ||
+		    !INET_ECN_set_ce(skb)) {
+			q->stats.forced_drop++;
+			goto congestion_drop;
+		}
+		q->stats.forced_mark++;
+		break;
 	}
 
 	if (q->backlog + qdisc_pkt_len(skb) <= q->limit) {
@@ -241,7 +240,7 @@ congestion_drop:
 	return NET_XMIT_CN;
 }
 
-static struct sk_buff *gred_dequeue(struct Qdisc* sch)
+static struct sk_buff *gred_dequeue(struct Qdisc *sch)
 {
 	struct sk_buff *skb;
 	struct gred_sched *t = qdisc_priv(sch);
@@ -254,9 +253,9 @@ static struct sk_buff *gred_dequeue(struct Qdisc* sch)
 
 		if (dp >= t->DPs || (q = t->tab[dp]) == NULL) {
 			if (net_ratelimit())
-				printk(KERN_WARNING "GRED: Unable to relocate "
-				       "VQ 0x%x after dequeue, screwing up "
-				       "backlog.\n", tc_index_to_dp(skb));
+				pr_warning("GRED: Unable to relocate VQ 0x%x "
+					   "after dequeue, screwing up "
+					   "backlog.\n", tc_index_to_dp(skb));
 		} else {
 			q->backlog -= qdisc_pkt_len(skb);
 
@@ -273,7 +272,7 @@ static struct sk_buff *gred_dequeue(struct Qdisc* sch)
 	return NULL;
 }
 
-static unsigned int gred_drop(struct Qdisc* sch)
+static unsigned int gred_drop(struct Qdisc *sch)
 {
 	struct sk_buff *skb;
 	struct gred_sched *t = qdisc_priv(sch);
@@ -286,9 +285,9 @@ static unsigned int gred_drop(struct Qdisc* sch)
 
 		if (dp >= t->DPs || (q = t->tab[dp]) == NULL) {
 			if (net_ratelimit())
-				printk(KERN_WARNING "GRED: Unable to relocate "
-				       "VQ 0x%x while dropping, screwing up "
-				       "backlog.\n", tc_index_to_dp(skb));
+				pr_warning("GRED: Unable to relocate VQ 0x%x "
+					   "while dropping, screwing up "
+					   "backlog.\n", tc_index_to_dp(skb));
 		} else {
 			q->backlog -= len;
 			q->stats.other++;
@@ -308,7 +307,7 @@ static unsigned int gred_drop(struct Qdisc* sch)
 
 }
 
-static void gred_reset(struct Qdisc* sch)
+static void gred_reset(struct Qdisc *sch)
 {
 	int i;
 	struct gred_sched *t = qdisc_priv(sch);
@@ -369,8 +368,8 @@ static inline int gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
 
 	for (i = table->DPs; i < MAX_DPs; i++) {
 		if (table->tab[i]) {
-			printk(KERN_WARNING "GRED: Warning: Destroying "
-			       "shadowed VQ 0x%x\n", i);
+			pr_warning("GRED: Warning: Destroying "
+				   "shadowed VQ 0x%x\n", i);
 			gred_destroy_vq(table->tab[i]);
 			table->tab[i] = NULL;
 		}
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 2e45791..dea4009 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -81,8 +81,7 @@
  *   that are expensive on 32-bit architectures.
  */
 
-struct internal_sc
-{
+struct internal_sc {
 	u64	sm1;	/* scaled slope of the 1st segment */
 	u64	ism1;	/* scaled inverse-slope of the 1st segment */
 	u64	dx;	/* the x-projection of the 1st segment */
@@ -92,8 +91,7 @@ struct internal_sc
 };
 
 /* runtime service curve */
-struct runtime_sc
-{
+struct runtime_sc {
 	u64	x;	/* current starting position on x-axis */
 	u64	y;	/* current starting position on y-axis */
 	u64	sm1;	/* scaled slope of the 1st segment */
@@ -104,15 +102,13 @@ struct runtime_sc
 	u64	ism2;	/* scaled inverse-slope of the 2nd segment */
 };
 
-enum hfsc_class_flags
-{
+enum hfsc_class_flags {
 	HFSC_RSC = 0x1,
 	HFSC_FSC = 0x2,
 	HFSC_USC = 0x4
 };
 
-struct hfsc_class
-{
+struct hfsc_class {
 	struct Qdisc_class_common cl_common;
 	unsigned int	refcnt;		/* usage count */
 
@@ -140,8 +136,8 @@ struct hfsc_class
 	u64	cl_cumul;		/* cumulative work in bytes done by
 					   real-time criteria */
 
-	u64 	cl_d;			/* deadline*/
-	u64 	cl_e;			/* eligible time */
+	u64	cl_d;			/* deadline*/
+	u64	cl_e;			/* eligible time */
 	u64	cl_vt;			/* virtual time */
 	u64	cl_f;			/* time when this class will fit for
 					   link-sharing, max(myf, cfmin) */
@@ -176,8 +172,7 @@ struct hfsc_class
 	unsigned long	cl_nactive;	/* number of active children */
 };
 
-struct hfsc_sched
-{
+struct hfsc_sched {
 	u16	defcls;				/* default class id */
 	struct hfsc_class root;			/* root class */
 	struct Qdisc_class_hash clhash;		/* class hash */
@@ -693,7 +688,7 @@ init_vf(struct hfsc_class *cl, unsigned int len)
 		if (go_active) {
 			n = rb_last(&cl->cl_parent->vt_tree);
 			if (n != NULL) {
-				max_cl = rb_entry(n, struct hfsc_class,vt_node);
+				max_cl = rb_entry(n, struct hfsc_class, vt_node);
 				/*
 				 * set vt to the average of the min and max
 				 * classes.  if the parent's period didn't
@@ -1177,8 +1172,10 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 			return NULL;
 		}
 #endif
-		if ((cl = (struct hfsc_class *)res.class) == NULL) {
-			if ((cl = hfsc_find_class(res.classid, sch)) == NULL)
+		cl = (struct hfsc_class *)res.class;
+		if (!cl) {
+			cl = hfsc_find_class(res.classid, sch);
+			if (!cl)
 				break; /* filter selected invalid classid */
 			if (cl->level >= head->level)
 				break; /* filter may only point downwards */
@@ -1316,7 +1313,7 @@ hfsc_dump_sc(struct sk_buff *skb, int attr, struct internal_sc *sc)
 	return -1;
 }
 
-static inline int
+static int
 hfsc_dump_curves(struct sk_buff *skb, struct hfsc_class *cl)
 {
 	if ((cl->cl_flags & HFSC_RSC) &&
@@ -1420,7 +1417,8 @@ hfsc_schedule_watchdog(struct Qdisc *sch)
 	struct hfsc_class *cl;
 	u64 next_time = 0;
 
-	if ((cl = eltree_get_minel(q)) != NULL)
+	cl = eltree_get_minel(q);
+	if (cl)
 		next_time = cl->cl_e;
 	if (q->root.cl_cfmin != 0) {
 		if (next_time == 0 || next_time > q->root.cl_cfmin)
@@ -1626,7 +1624,8 @@ hfsc_dequeue(struct Qdisc *sch)
 	 * find the class with the minimum deadline among
 	 * the eligible classes.
 	 */
-	if ((cl = eltree_get_mindl(q, cur_time)) != NULL) {
+	cl = eltree_get_mindl(q, cur_time);
+	if (cl) {
 		realtime = 1;
 	} else {
 		/*
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 984c1b0..3e86fd3 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -99,9 +99,10 @@ struct htb_class {
 			struct rb_root feed[TC_HTB_NUMPRIO];	/* feed trees */
 			struct rb_node *ptr[TC_HTB_NUMPRIO];	/* current class ptr */
 			/* When class changes from state 1->2 and disconnects from
-			   parent's feed then we lost ptr value and start from the
-			   first child again. Here we store classid of the
-			   last valid ptr (used when ptr is NULL). */
+			 * parent's feed then we lost ptr value and start from the
+			 * first child again. Here we store classid of the
+			 * last valid ptr (used when ptr is NULL).
+			 */
 			u32 last_ptr_id[TC_HTB_NUMPRIO];
 		} inner;
 	} un;
@@ -185,7 +186,7 @@ static inline struct htb_class *htb_find(u32 handle, struct Qdisc *sch)
  * have no valid leaf we try to use MAJOR:default leaf. It still unsuccessfull
  * then finish and return direct queue.
  */
-#define HTB_DIRECT (struct htb_class*)-1
+#define HTB_DIRECT ((struct htb_class *)-1L)
 
 static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 				      int *qerr)
@@ -197,11 +198,13 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 	int result;
 
 	/* allow to select class by setting skb->priority to valid classid;
-	   note that nfmark can be used too by attaching filter fw with no
-	   rules in it */
+	 * note that nfmark can be used too by attaching filter fw with no
+	 * rules in it
+	 */
 	if (skb->priority == sch->handle)
 		return HTB_DIRECT;	/* X:0 (direct flow) selected */
-	if ((cl = htb_find(skb->priority, sch)) != NULL && cl->level == 0)
+	cl = htb_find(skb->priority, sch);
+	if (cl && cl->level == 0)
 		return cl;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
@@ -216,10 +219,12 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 			return NULL;
 		}
 #endif
-		if ((cl = (void *)res.class) == NULL) {
+		cl = (void *)res.class;
+		if (!cl) {
 			if (res.classid == sch->handle)
 				return HTB_DIRECT;	/* X:0 (direct flow) */
-			if ((cl = htb_find(res.classid, sch)) == NULL)
+			cl = htb_find(res.classid, sch);
+			if (!cl)
 				break;	/* filter selected invalid classid */
 		}
 		if (!cl->level)
@@ -378,7 +383,8 @@ static void htb_activate_prios(struct htb_sched *q, struct htb_class *cl)
 
 			if (p->un.inner.feed[prio].rb_node)
 				/* parent already has its feed in use so that
-				   reset bit in mask as parent is already ok */
+				 * reset bit in mask as parent is already ok
+				 */
 				mask &= ~(1 << prio);
 
 			htb_add_to_id_tree(p->un.inner.feed + prio, cl, prio);
@@ -413,8 +419,9 @@ static void htb_deactivate_prios(struct htb_sched *q, struct htb_class *cl)
 
 			if (p->un.inner.ptr[prio] == cl->node + prio) {
 				/* we are removing child which is pointed to from
-				   parent feed - forget the pointer but remember
-				   classid */
+				 * parent feed - forget the pointer but remember
+				 * classid
+				 */
 				p->un.inner.last_ptr_id[prio] = cl->common.classid;
 				p->un.inner.ptr[prio] = NULL;
 			}
@@ -664,8 +671,9 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level,
 				   unsigned long start)
 {
 	/* don't run for longer than 2 jiffies; 2 is used instead of
-	   1 to simplify things when jiffy is going to be incremented
-	   too soon */
+	 * 1 to simplify things when jiffy is going to be incremented
+	 * too soon
+	 */
 	unsigned long stop_at = start + 2;
 	while (time_before(jiffies, stop_at)) {
 		struct htb_class *cl;
@@ -688,7 +696,7 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level,
 
 	/* too much load - let's continue after a break for scheduling */
 	if (!(q->warned & HTB_WARN_TOOMANYEVENTS)) {
-		printk(KERN_WARNING "htb: too many events!\n");
+		pr_warning("htb: too many events!\n");
 		q->warned |= HTB_WARN_TOOMANYEVENTS;
 	}
 
@@ -696,7 +704,8 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level,
 }
 
 /* Returns class->node+prio from id-tree where classe's id is >= id. NULL
-   is no such one exists. */
+ * is no such one exists.
+ */
 static struct rb_node *htb_id_find_next_upper(int prio, struct rb_node *n,
 					      u32 id)
 {
@@ -740,12 +749,14 @@ static struct htb_class *htb_lookup_leaf(struct rb_root *tree, int prio,
 	for (i = 0; i < 65535; i++) {
 		if (!*sp->pptr && *sp->pid) {
 			/* ptr was invalidated but id is valid - try to recover
-			   the original or next ptr */
+			 * the original or next ptr
+			 */
 			*sp->pptr =
 			    htb_id_find_next_upper(prio, sp->root, *sp->pid);
 		}
 		*sp->pid = 0;	/* ptr is valid now so that remove this hint as it
-				   can become out of date quickly */
+				 * can become out of date quickly
+				 */
 		if (!*sp->pptr) {	/* we are at right end; rewind & go up */
 			*sp->pptr = sp->root;
 			while ((*sp->pptr)->rb_left)
@@ -773,7 +784,8 @@ static struct htb_class *htb_lookup_leaf(struct rb_root *tree, int prio,
 }
 
 /* dequeues packet at given priority and level; call only if
-   you are sure that there is active class at prio/level */
+ * you are sure that there is active class at prio/level
+ */
 static struct sk_buff *htb_dequeue_tree(struct htb_sched *q, int prio,
 					int level)
 {
@@ -790,9 +802,10 @@ next:
 			return NULL;
 
 		/* class can be empty - it is unlikely but can be true if leaf
-		   qdisc drops packets in enqueue routine or if someone used
-		   graft operation on the leaf since last dequeue;
-		   simply deactivate and skip such class */
+		 * qdisc drops packets in enqueue routine or if someone used
+		 * graft operation on the leaf since last dequeue;
+		 * simply deactivate and skip such class
+		 */
 		if (unlikely(cl->un.leaf.q->q.qlen == 0)) {
 			struct htb_class *next;
 			htb_deactivate(q, cl);
@@ -832,7 +845,8 @@ next:
 					  ptr[0]) + prio);
 		}
 		/* this used to be after charge_class but this constelation
-		   gives us slightly better performance */
+		 * gives us slightly better performance
+		 */
 		if (!cl->un.leaf.q->q.qlen)
 			htb_deactivate(q, cl);
 		htb_charge_class(q, cl, level, skb);
@@ -882,6 +896,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 		m = ~q->row_mask[level];
 		while (m != (int)(-1)) {
 			int prio = ffz(m);
+
 			m |= 1 << prio;
 			skb = htb_dequeue_tree(q, prio, level);
 			if (likely(skb != NULL)) {
@@ -989,13 +1004,12 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 		return err;
 
 	if (tb[TCA_HTB_INIT] == NULL) {
-		printk(KERN_ERR "HTB: hey probably you have bad tc tool ?\n");
+		pr_err("HTB: hey probably you have bad tc tool ?\n");
 		return -EINVAL;
 	}
 	gopt = nla_data(tb[TCA_HTB_INIT]);
 	if (gopt->version != HTB_VER >> 16) {
-		printk(KERN_ERR
-		       "HTB: need tc/htb version %d (minor is %d), you have %d\n",
+		pr_err("HTB: need tc/htb version %d (minor is %d), you have %d\n",
 		       HTB_VER >> 16, HTB_VER & 0xffff, gopt->version);
 		return -EINVAL;
 	}
@@ -1208,9 +1222,10 @@ static void htb_destroy(struct Qdisc *sch)
 	cancel_work_sync(&q->work);
 	qdisc_watchdog_cancel(&q->watchdog);
 	/* This line used to be after htb_destroy_class call below
-	   and surprisingly it worked in 2.4. But it must precede it
-	   because filter need its target class alive to be able to call
-	   unbind_filter on it (without Oops). */
+	 * and surprisingly it worked in 2.4. But it must precede it
+	 * because filter need its target class alive to be able to call
+	 * unbind_filter on it (without Oops).
+	 */
 	tcf_destroy_chain(&q->filter_list);
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
@@ -1344,11 +1359,12 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 
 		/* check maximal depth */
 		if (parent && parent->parent && parent->parent->level < 2) {
-			printk(KERN_ERR "htb: tree is too deep\n");
+			pr_err("htb: tree is too deep\n");
 			goto failure;
 		}
 		err = -ENOBUFS;
-		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
+		cl = kzalloc(sizeof(*cl), GFP_KERNEL);
+		if (!cl)
 			goto failure;
 
 		err = gen_new_estimator(&cl->bstats, &cl->rate_est,
@@ -1368,8 +1384,9 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			RB_CLEAR_NODE(&cl->node[prio]);
 
 		/* create leaf qdisc early because it uses kmalloc(GFP_KERNEL)
-		   so that can't be used inside of sch_tree_lock
-		   -- thanks to Karlis Peisenieks */
+		 * so that can't be used inside of sch_tree_lock
+		 * -- thanks to Karlis Peisenieks
+		 */
 		new_q = qdisc_create_dflt(sch->dev_queue,
 					  &pfifo_qdisc_ops, classid);
 		sch_tree_lock(sch);
@@ -1421,17 +1438,18 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	}
 
 	/* it used to be a nasty bug here, we have to check that node
-	   is really leaf before changing cl->un.leaf ! */
+	 * is really leaf before changing cl->un.leaf !
+	 */
 	if (!cl->level) {
 		cl->quantum = rtab->rate.rate / q->rate2quantum;
 		if (!hopt->quantum && cl->quantum < 1000) {
-			printk(KERN_WARNING
+			pr_warning(
 			       "HTB: quantum of class %X is small. Consider r2q change.\n",
 			       cl->common.classid);
 			cl->quantum = 1000;
 		}
 		if (!hopt->quantum && cl->quantum > 200000) {
-			printk(KERN_WARNING
+			pr_warning(
 			       "HTB: quantum of class %X is big. Consider r2q change.\n",
 			       cl->common.classid);
 			cl->quantum = 200000;
@@ -1480,13 +1498,13 @@ static unsigned long htb_bind_filter(struct Qdisc *sch, unsigned long parent,
 	struct htb_class *cl = htb_find(classid, sch);
 
 	/*if (cl && !cl->level) return 0;
-	   The line above used to be there to prevent attaching filters to
-	   leaves. But at least tc_index filter uses this just to get class
-	   for other reasons so that we have to allow for it.
-	   ----
-	   19.6.2002 As Werner explained it is ok - bind filter is just
-	   another way to "lock" the class - unlike "get" this lock can
-	   be broken by class during destroy IIUC.
+	 * The line above used to be there to prevent attaching filters to
+	 * leaves. But at least tc_index filter uses this just to get class
+	 * for other reasons so that we have to allow for it.
+	 * ----
+	 * 19.6.2002 As Werner explained it is ok - bind filter is just
+	 * another way to "lock" the class - unlike "get" this lock can
+	 * be broken by class during destroy IIUC.
 	 */
 	if (cl)
 		cl->filter_cnt++;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 21f13da..820f2a7 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -156,7 +156,7 @@ static unsigned int multiq_drop(struct Qdisc *sch)
 	unsigned int len;
 	struct Qdisc *qdisc;
 
-	for (band = q->bands-1; band >= 0; band--) {
+	for (band = q->bands - 1; band >= 0; band--) {
 		qdisc = q->queues[band];
 		if (qdisc->ops->drop) {
 			len = qdisc->ops->drop(qdisc);
@@ -265,7 +265,7 @@ static int multiq_init(struct Qdisc *sch, struct nlattr *opt)
 	for (i = 0; i < q->max_bands; i++)
 		q->queues[i] = &noop_qdisc;
 
-	err = multiq_tune(sch,opt);
+	err = multiq_tune(sch, opt);
 
 	if (err)
 		kfree(q->queues);
@@ -346,7 +346,7 @@ static int multiq_dump_class(struct Qdisc *sch, unsigned long cl,
 	struct multiq_sched_data *q = qdisc_priv(sch);
 
 	tcm->tcm_handle |= TC_H_MIN(cl);
-	tcm->tcm_info = q->queues[cl-1]->handle;
+	tcm->tcm_info = q->queues[cl - 1]->handle;
 	return 0;
 }
 
@@ -378,7 +378,7 @@ static void multiq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 			arg->count++;
 			continue;
 		}
-		if (arg->fn(sch, band+1, arg) < 0) {
+		if (arg->fn(sch, band + 1, arg) < 0) {
 			arg->stop = 1;
 			break;
 		}
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 1c4bce8..c2bbbe6 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -211,8 +211,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	cb = netem_skb_cb(skb);
-	if (q->gap == 0 || 		/* not doing reordering */
-	    q->counter < q->gap || 	/* inside last reordering gap */
+	if (q->gap == 0 ||		/* not doing reordering */
+	    q->counter < q->gap ||	/* inside last reordering gap */
 	    q->reorder < get_crandom(&q->reorder_cor)) {
 		psched_time_t now;
 		psched_tdiff_t delay;
@@ -249,7 +249,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return ret;
 }
 
-static unsigned int netem_drop(struct Qdisc* sch)
+static unsigned int netem_drop(struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	unsigned int len = 0;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 966158d..3bea31e 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -22,8 +22,7 @@
 #include <net/pkt_sched.h>
 
 
-struct prio_sched_data
-{
+struct prio_sched_data {
 	int bands;
 	struct tcf_proto *filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
@@ -54,7 +53,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		if (!q->filter_list || err < 0) {
 			if (TC_H_MAJ(band))
 				band = 0;
-			return q->queues[q->prio2band[band&TC_PRIO_MAX]];
+			return q->queues[q->prio2band[band & TC_PRIO_MAX]];
 		}
 		band = res.classid;
 	}
@@ -107,7 +106,7 @@ static struct sk_buff *prio_peek(struct Qdisc *sch)
 	return NULL;
 }
 
-static struct sk_buff *prio_dequeue(struct Qdisc* sch)
+static struct sk_buff *prio_dequeue(struct Qdisc *sch)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	int prio;
@@ -124,7 +123,7 @@ static struct sk_buff *prio_dequeue(struct Qdisc* sch)
 
 }
 
-static unsigned int prio_drop(struct Qdisc* sch)
+static unsigned int prio_drop(struct Qdisc *sch)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	int prio;
@@ -143,24 +142,24 @@ static unsigned int prio_drop(struct Qdisc* sch)
 
 
 static void
-prio_reset(struct Qdisc* sch)
+prio_reset(struct Qdisc *sch)
 {
 	int prio;
 	struct prio_sched_data *q = qdisc_priv(sch);
 
-	for (prio=0; prio<q->bands; prio++)
+	for (prio = 0; prio < q->bands; prio++)
 		qdisc_reset(q->queues[prio]);
 	sch->q.qlen = 0;
 }
 
 static void
-prio_destroy(struct Qdisc* sch)
+prio_destroy(struct Qdisc *sch)
 {
 	int prio;
 	struct prio_sched_data *q = qdisc_priv(sch);
 
 	tcf_destroy_chain(&q->filter_list);
-	for (prio=0; prio<q->bands; prio++)
+	for (prio = 0; prio < q->bands; prio++)
 		qdisc_destroy(q->queues[prio]);
 }
 
@@ -177,7 +176,7 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 	if (qopt->bands > TCQ_PRIO_BANDS || qopt->bands < 2)
 		return -EINVAL;
 
-	for (i=0; i<=TC_PRIO_MAX; i++) {
+	for (i = 0; i <= TC_PRIO_MAX; i++) {
 		if (qopt->priomap[i] >= qopt->bands)
 			return -EINVAL;
 	}
@@ -186,7 +185,7 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 	q->bands = qopt->bands;
 	memcpy(q->prio2band, qopt->priomap, TC_PRIO_MAX+1);
 
-	for (i=q->bands; i<TCQ_PRIO_BANDS; i++) {
+	for (i = q->bands; i < TCQ_PRIO_BANDS; i++) {
 		struct Qdisc *child = q->queues[i];
 		q->queues[i] = &noop_qdisc;
 		if (child != &noop_qdisc) {
@@ -196,9 +195,10 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 	}
 	sch_tree_unlock(sch);
 
-	for (i=0; i<q->bands; i++) {
+	for (i = 0; i < q->bands; i++) {
 		if (q->queues[i] == &noop_qdisc) {
 			struct Qdisc *child, *old;
+
 			child = qdisc_create_dflt(sch->dev_queue,
 						  &pfifo_qdisc_ops,
 						  TC_H_MAKE(sch->handle, i + 1));
@@ -224,7 +224,7 @@ static int prio_init(struct Qdisc *sch, struct nlattr *opt)
 	struct prio_sched_data *q = qdisc_priv(sch);
 	int i;
 
-	for (i=0; i<TCQ_PRIO_BANDS; i++)
+	for (i = 0; i < TCQ_PRIO_BANDS; i++)
 		q->queues[i] = &noop_qdisc;
 
 	if (opt == NULL) {
@@ -232,7 +232,7 @@ static int prio_init(struct Qdisc *sch, struct nlattr *opt)
 	} else {
 		int err;
 
-		if ((err= prio_tune(sch, opt)) != 0)
+		if ((err = prio_tune(sch, opt)) != 0)
 			return err;
 	}
 	return 0;
@@ -245,7 +245,7 @@ static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	struct tc_prio_qopt opt;
 
 	opt.bands = q->bands;
-	memcpy(&opt.priomap, q->prio2band, TC_PRIO_MAX+1);
+	memcpy(&opt.priomap, q->prio2band, TC_PRIO_MAX + 1);
 
 	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 
@@ -342,7 +342,7 @@ static void prio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 			arg->count++;
 			continue;
 		}
-		if (arg->fn(sch, prio+1, arg) < 0) {
+		if (arg->fn(sch, prio + 1, arg) < 0) {
 			arg->stop = 1;
 			break;
 		}
@@ -350,7 +350,7 @@ static void prio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 	}
 }
 
-static struct tcf_proto ** prio_find_tcf(struct Qdisc *sch, unsigned long cl)
+static struct tcf_proto **prio_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index a6009c5..6891575 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -36,8 +36,7 @@
 	if RED works correctly.
  */
 
-struct red_sched_data
-{
+struct red_sched_data {
 	u32			limit;		/* HARD maximal queue length */
 	unsigned char		flags;
 	struct red_parms	parms;
@@ -55,7 +54,7 @@ static inline int red_use_harddrop(struct red_sched_data *q)
 	return q->flags & TC_RED_HARDDROP;
 }
 
-static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 	struct Qdisc *child = q->qdisc;
@@ -67,29 +66,29 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		red_end_of_idle_period(&q->parms);
 
 	switch (red_action(&q->parms, q->parms.qavg)) {
-		case RED_DONT_MARK:
-			break;
-
-		case RED_PROB_MARK:
-			sch->qstats.overlimits++;
-			if (!red_use_ecn(q) || !INET_ECN_set_ce(skb)) {
-				q->stats.prob_drop++;
-				goto congestion_drop;
-			}
-
-			q->stats.prob_mark++;
-			break;
-
-		case RED_HARD_MARK:
-			sch->qstats.overlimits++;
-			if (red_use_harddrop(q) || !red_use_ecn(q) ||
-			    !INET_ECN_set_ce(skb)) {
-				q->stats.forced_drop++;
-				goto congestion_drop;
-			}
-
-			q->stats.forced_mark++;
-			break;
+	case RED_DONT_MARK:
+		break;
+
+	case RED_PROB_MARK:
+		sch->qstats.overlimits++;
+		if (!red_use_ecn(q) || !INET_ECN_set_ce(skb)) {
+			q->stats.prob_drop++;
+			goto congestion_drop;
+		}
+
+		q->stats.prob_mark++;
+		break;
+
+	case RED_HARD_MARK:
+		sch->qstats.overlimits++;
+		if (red_use_harddrop(q) || !red_use_ecn(q) ||
+		    !INET_ECN_set_ce(skb)) {
+			q->stats.forced_drop++;
+			goto congestion_drop;
+		}
+
+		q->stats.forced_mark++;
+		break;
 	}
 
 	ret = qdisc_enqueue(skb, child);
@@ -107,7 +106,7 @@ congestion_drop:
 	return NET_XMIT_CN;
 }
 
-static struct sk_buff * red_dequeue(struct Qdisc* sch)
+static struct sk_buff *red_dequeue(struct Qdisc *sch)
 {
 	struct sk_buff *skb;
 	struct red_sched_data *q = qdisc_priv(sch);
@@ -122,7 +121,7 @@ static struct sk_buff * red_dequeue(struct Qdisc* sch)
 	return skb;
 }
 
-static struct sk_buff * red_peek(struct Qdisc* sch)
+static struct sk_buff *red_peek(struct Qdisc *sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 	struct Qdisc *child = q->qdisc;
@@ -130,7 +129,7 @@ static struct sk_buff * red_peek(struct Qdisc* sch)
 	return child->ops->peek(child);
 }
 
-static unsigned int red_drop(struct Qdisc* sch)
+static unsigned int red_drop(struct Qdisc *sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 	struct Qdisc *child = q->qdisc;
@@ -149,7 +148,7 @@ static unsigned int red_drop(struct Qdisc* sch)
 	return 0;
 }
 
-static void red_reset(struct Qdisc* sch)
+static void red_reset(struct Qdisc *sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 
@@ -216,7 +215,7 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 }
 
-static int red_init(struct Qdisc* sch, struct nlattr *opt)
+static int red_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 239ec53..54a36f4 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -92,8 +92,7 @@ typedef unsigned char sfq_index;
  * while following values [SFQ_SLOTS ... SFQ_SLOTS + SFQ_DEPTH - 1]
  * are 'pointers' to dep[] array
  */
-struct sfq_head
-{
+struct sfq_head {
 	sfq_index	next;
 	sfq_index	prev;
 };
@@ -108,11 +107,10 @@ struct sfq_slot {
 	short		allot; /* credit for this slot */
 };
 
-struct sfq_sched_data
-{
+struct sfq_sched_data {
 /* Parameters */
 	int		perturb_period;
-	unsigned	quantum;	/* Allotment per round: MUST BE >= MTU */
+	unsigned int	quantum;	/* Allotment per round: MUST BE >= MTU */
 	int		limit;
 
 /* Variables */
@@ -137,12 +135,12 @@ static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, sfq_index
 	return &q->dep[val - SFQ_SLOTS];
 }
 
-static __inline__ unsigned sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1)
+static unsigned int sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1)
 {
 	return jhash_2words(h, h1, q->perturbation) & (SFQ_HASH_DIVISOR - 1);
 }
 
-static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
+static unsigned int sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 {
 	u32 h, h2;
 
@@ -157,13 +155,13 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 		iph = ip_hdr(skb);
 		h = (__force u32)iph->daddr;
 		h2 = (__force u32)iph->saddr ^ iph->protocol;
-		if (iph->frag_off & htons(IP_MF|IP_OFFSET))
+		if (iph->frag_off & htons(IP_MF | IP_OFFSET))
 			break;
 		poff = proto_ports_offset(iph->protocol);
 		if (poff >= 0 &&
 		    pskb_network_may_pull(skb, iph->ihl * 4 + 4 + poff)) {
 			iph = ip_hdr(skb);
-			h2 ^= *(u32*)((void *)iph + iph->ihl * 4 + poff);
+			h2 ^= *(u32 *)((void *)iph + iph->ihl * 4 + poff);
 		}
 		break;
 	}
@@ -181,7 +179,7 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 		if (poff >= 0 &&
 		    pskb_network_may_pull(skb, sizeof(*iph) + 4 + poff)) {
 			iph = ipv6_hdr(skb);
-			h2 ^= *(u32*)((void *)iph + sizeof(*iph) + poff);
+			h2 ^= *(u32 *)((void *)iph + sizeof(*iph) + poff);
 		}
 		break;
 	}
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 77565e7..475edfb 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -97,8 +97,7 @@
 	changed the limit is not effective anymore.
 */
 
-struct tbf_sched_data
-{
+struct tbf_sched_data {
 /* Parameters */
 	u32		limit;		/* Maximal length of backlog: bytes */
 	u32		buffer;		/* Token bucket depth/rate: MUST BE >= MTU/B */
@@ -115,10 +114,10 @@ struct tbf_sched_data
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
 };
 
-#define L2T(q,L)   qdisc_l2t((q)->R_tab,L)
-#define L2T_P(q,L) qdisc_l2t((q)->P_tab,L)
+#define L2T(q, L)   qdisc_l2t((q)->R_tab, L)
+#define L2T_P(q, L) qdisc_l2t((q)->P_tab, L)
 
-static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
@@ -138,7 +137,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return NET_XMIT_SUCCESS;
 }
 
-static unsigned int tbf_drop(struct Qdisc* sch)
+static unsigned int tbf_drop(struct Qdisc *sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	unsigned int len = 0;
@@ -150,7 +149,7 @@ static unsigned int tbf_drop(struct Qdisc* sch)
 	return len;
 }
 
-static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
+static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
@@ -209,7 +208,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 	return NULL;
 }
 
-static void tbf_reset(struct Qdisc* sch)
+static void tbf_reset(struct Qdisc *sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
@@ -227,7 +226,7 @@ static const struct nla_policy tbf_policy[TCA_TBF_MAX + 1] = {
 	[TCA_TBF_PTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
 };
 
-static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
+static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	int err;
 	struct tbf_sched_data *q = qdisc_priv(sch);
@@ -236,7 +235,7 @@ static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
 	struct qdisc_rate_table *rtab = NULL;
 	struct qdisc_rate_table *ptab = NULL;
 	struct Qdisc *child = NULL;
-	int max_size,n;
+	int max_size, n;
 
 	err = nla_parse_nested(tb, TCA_TBF_PTAB, opt, tbf_policy);
 	if (err < 0)
@@ -259,15 +258,18 @@ static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
 	}
 
 	for (n = 0; n < 256; n++)
-		if (rtab->data[n] > qopt->buffer) break;
-	max_size = (n << qopt->rate.cell_log)-1;
+		if (rtab->data[n] > qopt->buffer)
+			break;
+	max_size = (n << qopt->rate.cell_log) - 1;
 	if (ptab) {
 		int size;
 
 		for (n = 0; n < 256; n++)
-			if (ptab->data[n] > qopt->mtu) break;
-		size = (n << qopt->peakrate.cell_log)-1;
-		if (size < max_size) max_size = size;
+			if (ptab->data[n] > qopt->mtu)
+				break;
+		size = (n << qopt->peakrate.cell_log) - 1;
+		if (size < max_size)
+			max_size = size;
 	}
 	if (max_size < 0)
 		goto done;
@@ -310,7 +312,7 @@ done:
 	return err;
 }
 
-static int tbf_init(struct Qdisc* sch, struct nlattr *opt)
+static int tbf_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
@@ -422,8 +424,7 @@ static void tbf_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 	}
 }
 
-static const struct Qdisc_class_ops tbf_class_ops =
-{
+static const struct Qdisc_class_ops tbf_class_ops = {
 	.graft		=	tbf_graft,
 	.leaf		=	tbf_leaf,
 	.get		=	tbf_get,
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 84ce48e..64c071d 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -53,8 +53,7 @@
       which will not break load balancing, though native slave
       traffic will have the highest priority.  */
 
-struct teql_master
-{
+struct teql_master {
 	struct Qdisc_ops qops;
 	struct net_device *dev;
 	struct Qdisc *slaves;
@@ -65,22 +64,21 @@ struct teql_master
 	unsigned long	tx_dropped;
 };
 
-struct teql_sched_data
-{
+struct teql_sched_data {
 	struct Qdisc *next;
 	struct teql_master *m;
 	struct neighbour *ncache;
 	struct sk_buff_head q;
 };
 
-#define NEXT_SLAVE(q) (((struct teql_sched_data*)qdisc_priv(q))->next)
+#define NEXT_SLAVE(q) (((struct teql_sched_data *)qdisc_priv(q))->next)
 
-#define FMASK (IFF_BROADCAST|IFF_POINTOPOINT)
+#define FMASK (IFF_BROADCAST | IFF_POINTOPOINT)
 
 /* "teql*" qdisc routines */
 
 static int
-teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+teql_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct net_device *dev = qdisc_dev(sch);
 	struct teql_sched_data *q = qdisc_priv(sch);
@@ -97,7 +95,7 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 }
 
 static struct sk_buff *
-teql_dequeue(struct Qdisc* sch)
+teql_dequeue(struct Qdisc *sch)
 {
 	struct teql_sched_data *dat = qdisc_priv(sch);
 	struct netdev_queue *dat_queue;
@@ -117,13 +115,13 @@ teql_dequeue(struct Qdisc* sch)
 }
 
 static struct sk_buff *
-teql_peek(struct Qdisc* sch)
+teql_peek(struct Qdisc *sch)
 {
 	/* teql is meant to be used as root qdisc */
 	return NULL;
 }
 
-static __inline__ void
+static inline void
 teql_neigh_release(struct neighbour *n)
 {
 	if (n)
@@ -131,7 +129,7 @@ teql_neigh_release(struct neighbour *n)
 }
 
 static void
-teql_reset(struct Qdisc* sch)
+teql_reset(struct Qdisc *sch)
 {
 	struct teql_sched_data *dat = qdisc_priv(sch);
 
@@ -141,13 +139,14 @@ teql_reset(struct Qdisc* sch)
 }
 
 static void
-teql_destroy(struct Qdisc* sch)
+teql_destroy(struct Qdisc *sch)
 {
 	struct Qdisc *q, *prev;
 	struct teql_sched_data *dat = qdisc_priv(sch);
 	struct teql_master *master = dat->m;
 
-	if ((prev = master->slaves) != NULL) {
+	prev = master->slaves;
+	if (prev) {
 		do {
 			q = NEXT_SLAVE(prev);
 			if (q == sch) {
@@ -179,7 +178,7 @@ teql_destroy(struct Qdisc* sch)
 static int teql_qdisc_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct net_device *dev = qdisc_dev(sch);
-	struct teql_master *m = (struct teql_master*)sch->ops;
+	struct teql_master *m = (struct teql_master *)sch->ops;
 	struct teql_sched_data *q = qdisc_priv(sch);
 
 	if (dev->hard_header_len > m->dev->hard_header_len)
@@ -290,7 +289,8 @@ restart:
 	nores = 0;
 	busy = 0;
 
-	if ((q = start) == NULL)
+	q = start;
+	if (!q)
 		goto drop;
 
 	do {
@@ -355,10 +355,10 @@ drop:
 
 static int teql_master_open(struct net_device *dev)
 {
-	struct Qdisc * q;
+	struct Qdisc *q;
 	struct teql_master *m = netdev_priv(dev);
 	int mtu = 0xFFFE;
-	unsigned flags = IFF_NOARP|IFF_MULTICAST;
+	unsigned int flags = IFF_NOARP | IFF_MULTICAST;
 
 	if (m->slaves == NULL)
 		return -EUNATCH;
@@ -426,7 +426,7 @@ static int teql_master_mtu(struct net_device *dev, int new_mtu)
 		do {
 			if (new_mtu > qdisc_dev(q)->mtu)
 				return -EINVAL;
-		} while ((q=NEXT_SLAVE(q)) != m->slaves);
+		} while ((q = NEXT_SLAVE(q)) != m->slaves);
 	}
 
 	dev->mtu = new_mtu;


