From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/2] net_sched: Remove broken act_simple
Date: Sun, 27 Oct 2013 06:43:32 -0700
Message-ID: <874n82u8vv.fsf@xmission.com>
References: <87fvrmu909.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, alexander.h.duyck@intel.com,
	jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:50236 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157Ab3J0Nnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 09:43:39 -0400
In-Reply-To: <87fvrmu909.fsf@xmission.com> (Eric W. Biederman's message of
	"Sun, 27 Oct 2013 06:40:54 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While reading through the code I noticed that act_simple does not
implement a .lookup function in act_simp_ops.

In practice this means that RTM_GETACTION and RTM_DELACTION will
always fail for "simple" actions.  This has been the case since at
least 2.6.12-rc1.  Which means this code has been broken for more
years than I care to think about.

On the principle that a broken example is worse than no example delete
this code.

Cc: jhs@mojatatu.com
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/tc_act/tc_defact.h        |   14 --
 include/uapi/linux/tc_act/Kbuild      |    1 -
 include/uapi/linux/tc_act/tc_defact.h |   19 ---
 net/sched/Kconfig                     |   14 --
 net/sched/Makefile                    |    1 -
 net/sched/act_simple.c                |  225 ---------------------------------
 6 files changed, 0 insertions(+), 274 deletions(-)
 delete mode 100644 include/net/tc_act/tc_defact.h
 delete mode 100644 include/uapi/linux/tc_act/tc_defact.h
 delete mode 100644 net/sched/act_simple.c

diff --git a/include/net/tc_act/tc_defact.h b/include/net/tc_act/tc_defact.h
deleted file mode 100644
index 65f024b80958..000000000000
--- a/include/net/tc_act/tc_defact.h
+++ /dev/null
@@ -1,14 +0,0 @@
-#ifndef __NET_TC_DEF_H
-#define __NET_TC_DEF_H
-
-#include <net/act_api.h>
-
-struct tcf_defact {
-	struct tcf_common	common;
-	u32     		tcfd_datalen;
-	void    		*tcfd_defdata;
-};
-#define to_defact(pc) \
-	container_of(pc, struct tcf_defact, common)
-
-#endif /* __NET_TC_DEF_H */
diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
index 713b331d9df3..5e4ef55bb43e 100644
--- a/include/uapi/linux/tc_act/Kbuild
+++ b/include/uapi/linux/tc_act/Kbuild
@@ -1,6 +1,5 @@
 # UAPI Header export list
 header-y += tc_csum.h
-header-y += tc_defact.h
 header-y += tc_gact.h
 header-y += tc_ipt.h
 header-y += tc_mirred.h
diff --git a/include/uapi/linux/tc_act/tc_defact.h b/include/uapi/linux/tc_act/tc_defact.h
deleted file mode 100644
index 17dddb40f740..000000000000
--- a/include/uapi/linux/tc_act/tc_defact.h
+++ /dev/null
@@ -1,19 +0,0 @@
-#ifndef __LINUX_TC_DEF_H
-#define __LINUX_TC_DEF_H
-
-#include <linux/pkt_cls.h>
-
-struct tc_defact {
-	tc_gen;
-};
-
-enum {
-	TCA_DEF_UNSPEC,
-	TCA_DEF_TM,
-	TCA_DEF_PARMS,
-	TCA_DEF_DATA,
-	__TCA_DEF_MAX
-};
-#define TCA_DEF_MAX (__TCA_DEF_MAX - 1)
-
-#endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 37af03bba732..05c7dba68af7 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -618,20 +618,6 @@ config NET_ACT_PEDIT
 	  To compile this code as a module, choose M here: the
 	  module will be called act_pedit.
 
-config NET_ACT_SIMP
-        tristate "Simple Example (Debug)"
-        depends on NET_CLS_ACT
-        ---help---
-	  Say Y here to add a simple action for demonstration purposes.
-	  It is meant as an example and for debugging purposes. It will
-	  print a configured policy string followed by the packet count
-	  to the console for every packet that passes by.
-
-	  If unsure, say N.
-
-	  To compile this code as a module, choose M here: the
-	  module will be called act_simple.
-
 config NET_ACT_CSUM
         tristate "Checksum Updating"
         depends on NET_CLS_ACT && INET
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 91e2acf15832..7c31261f32e9 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -13,7 +13,6 @@ obj-$(CONFIG_NET_ACT_MIRRED)	+= act_mirred.o
 obj-$(CONFIG_NET_ACT_IPT)	+= act_ipt.o
 obj-$(CONFIG_NET_ACT_NAT)	+= act_nat.o
 obj-$(CONFIG_NET_ACT_PEDIT)	+= act_pedit.o
-obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
 obj-$(CONFIG_NET_ACT_CSUM)	+= act_csum.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
deleted file mode 100644
index 7725eb4ab756..000000000000
--- a/net/sched/act_simple.c
+++ /dev/null
@@ -1,225 +0,0 @@
-/*
- * net/sched/simp.c	Simple example of an action
- *
- *		This program is free software; you can redistribute it and/or
- *		modify it under the terms of the GNU General Public License
- *		as published by the Free Software Foundation; either version
- *		2 of the License, or (at your option) any later version.
- *
- * Authors:	Jamal Hadi Salim (2005-8)
- *
- */
-
-#include <linux/module.h>
-#include <linux/slab.h>
-#include <linux/init.h>
-#include <linux/kernel.h>
-#include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
-#include <net/netlink.h>
-#include <net/pkt_sched.h>
-
-#define TCA_ACT_SIMP 22
-
-#include <linux/tc_act/tc_defact.h>
-#include <net/tc_act/tc_defact.h>
-
-#define SIMP_TAB_MASK     7
-static struct tcf_common *tcf_simp_ht[SIMP_TAB_MASK + 1];
-static u32 simp_idx_gen;
-static DEFINE_RWLOCK(simp_lock);
-
-static struct tcf_hashinfo simp_hash_info = {
-	.htab	=	tcf_simp_ht,
-	.hmask	=	SIMP_TAB_MASK,
-	.lock	=	&simp_lock,
-};
-
-#define SIMP_MAX_DATA	32
-static int tcf_simp(struct sk_buff *skb, const struct tc_action *a,
-		    struct tcf_result *res)
-{
-	struct tcf_defact *d = a->priv;
-
-	spin_lock(&d->tcf_lock);
-	d->tcf_tm.lastuse = jiffies;
-	bstats_update(&d->tcf_bstats, skb);
-
-	/* print policy string followed by _ then packet count
-	 * Example if this was the 3rd packet and the string was "hello"
-	 * then it would look like "hello_3" (without quotes)
-	 */
-	pr_info("simple: %s_%d\n",
-	       (char *)d->tcfd_defdata, d->tcf_bstats.packets);
-	spin_unlock(&d->tcf_lock);
-	return d->tcf_action;
-}
-
-static int tcf_simp_release(struct tcf_defact *d, int bind)
-{
-	int ret = 0;
-	if (d) {
-		if (bind)
-			d->tcf_bindcnt--;
-		d->tcf_refcnt--;
-		if (d->tcf_bindcnt <= 0 && d->tcf_refcnt <= 0) {
-			kfree(d->tcfd_defdata);
-			tcf_hash_destroy(&d->common, &simp_hash_info);
-			ret = 1;
-		}
-	}
-	return ret;
-}
-
-static int alloc_defdata(struct tcf_defact *d, char *defdata)
-{
-	d->tcfd_defdata = kzalloc(SIMP_MAX_DATA, GFP_KERNEL);
-	if (unlikely(!d->tcfd_defdata))
-		return -ENOMEM;
-	strlcpy(d->tcfd_defdata, defdata, SIMP_MAX_DATA);
-	return 0;
-}
-
-static void reset_policy(struct tcf_defact *d, char *defdata,
-			 struct tc_defact *p)
-{
-	spin_lock_bh(&d->tcf_lock);
-	d->tcf_action = p->action;
-	memset(d->tcfd_defdata, 0, SIMP_MAX_DATA);
-	strlcpy(d->tcfd_defdata, defdata, SIMP_MAX_DATA);
-	spin_unlock_bh(&d->tcf_lock);
-}
-
-static const struct nla_policy simple_policy[TCA_DEF_MAX + 1] = {
-	[TCA_DEF_PARMS]	= { .len = sizeof(struct tc_defact) },
-	[TCA_DEF_DATA]	= { .type = NLA_STRING, .len = SIMP_MAX_DATA },
-};
-
-static int tcf_simp_init(struct net *net, struct nlattr *nla,
-			 struct nlattr *est, struct tc_action *a,
-			 int ovr, int bind)
-{
-	struct nlattr *tb[TCA_DEF_MAX + 1];
-	struct tc_defact *parm;
-	struct tcf_defact *d;
-	struct tcf_common *pc;
-	char *defdata;
-	int ret = 0, err;
-
-	if (nla == NULL)
-		return -EINVAL;
-
-	err = nla_parse_nested(tb, TCA_DEF_MAX, nla, simple_policy);
-	if (err < 0)
-		return err;
-
-	if (tb[TCA_DEF_PARMS] == NULL)
-		return -EINVAL;
-
-	if (tb[TCA_DEF_DATA] == NULL)
-		return -EINVAL;
-
-	parm = nla_data(tb[TCA_DEF_PARMS]);
-	defdata = nla_data(tb[TCA_DEF_DATA]);
-
-	pc = tcf_hash_check(parm->index, a, bind, &simp_hash_info);
-	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
-				     &simp_idx_gen, &simp_hash_info);
-		if (IS_ERR(pc))
-			return PTR_ERR(pc);
-
-		d = to_defact(pc);
-		ret = alloc_defdata(d, defdata);
-		if (ret < 0) {
-			if (est)
-				gen_kill_estimator(&pc->tcfc_bstats,
-						   &pc->tcfc_rate_est);
-			kfree_rcu(pc, tcfc_rcu);
-			return ret;
-		}
-		d->tcf_action = parm->action;
-		ret = ACT_P_CREATED;
-	} else {
-		d = to_defact(pc);
-		if (!ovr) {
-			tcf_simp_release(d, bind);
-			return -EEXIST;
-		}
-		reset_policy(d, defdata, parm);
-	}
-
-	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, &simp_hash_info);
-	return ret;
-}
-
-static int tcf_simp_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_defact *d = a->priv;
-
-	if (d)
-		return tcf_simp_release(d, bind);
-	return 0;
-}
-
-static int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
-			 int bind, int ref)
-{
-	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_defact *d = a->priv;
-	struct tc_defact opt = {
-		.index   = d->tcf_index,
-		.refcnt  = d->tcf_refcnt - ref,
-		.bindcnt = d->tcf_bindcnt - bind,
-		.action  = d->tcf_action,
-	};
-	struct tcf_t t;
-
-	if (nla_put(skb, TCA_DEF_PARMS, sizeof(opt), &opt) ||
-	    nla_put_string(skb, TCA_DEF_DATA, d->tcfd_defdata))
-		goto nla_put_failure;
-	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
-	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
-	if (nla_put(skb, TCA_DEF_TM, sizeof(t), &t))
-		goto nla_put_failure;
-	return skb->len;
-
-nla_put_failure:
-	nlmsg_trim(skb, b);
-	return -1;
-}
-
-static struct tc_action_ops act_simp_ops = {
-	.kind		=	"simple",
-	.hinfo		=	&simp_hash_info,
-	.type		=	TCA_ACT_SIMP,
-	.capab		=	TCA_CAP_NONE,
-	.owner		=	THIS_MODULE,
-	.act		=	tcf_simp,
-	.dump		=	tcf_simp_dump,
-	.cleanup	=	tcf_simp_cleanup,
-	.init		=	tcf_simp_init,
-	.walk		=	tcf_generic_walker,
-};
-
-MODULE_AUTHOR("Jamal Hadi Salim(2005)");
-MODULE_DESCRIPTION("Simple example action");
-MODULE_LICENSE("GPL");
-
-static int __init simp_init_module(void)
-{
-	int ret = tcf_register_action(&act_simp_ops);
-	if (!ret)
-		pr_info("Simple TC action Loaded\n");
-	return ret;
-}
-
-static void __exit simp_cleanup_module(void)
-{
-	tcf_unregister_action(&act_simp_ops);
-}
-
-module_init(simp_init_module);
-module_exit(simp_cleanup_module);
-- 
1.7.5.4
