From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/2] net_sched: Remove broken act_skbedit
Date: Sun, 27 Oct 2013 06:42:44 -0700
Message-ID: <87a9huu8x7.fsf@xmission.com>
References: <87fvrmu909.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, alexander.h.duyck@intel.com,
	jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48390 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049Ab3J0Nmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 09:42:51 -0400
In-Reply-To: <87fvrmu909.fsf@xmission.com> (Eric W. Biederman's message of
	"Sun, 27 Oct 2013 06:40:54 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While reading through the code I noticed that act_skbedit does not
implement a .lookup function in act_skbedit_ops.

In practice this means that RTM_GETACTION and RTM_DELACTION will
always fail for skbedit actions.  This has been the case since at
least 2.6.12-rc1 well before this code was added.  Which means in
practice this code does not work and has never worked.

Since the code has been in the tree and broken for 5 years and no
one has noticed it seems reasonable to delete the code.

Cc: alexander.h.duyck@intel.com
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/tc_act/tc_skbedit.h        |   36 -----
 include/uapi/linux/tc_act/Kbuild       |    1 -
 include/uapi/linux/tc_act/tc_skbedit.h |   46 -------
 net/sched/Kconfig                      |   11 --
 net/sched/Makefile                     |    1 -
 net/sched/act_skbedit.c                |  224 --------------------------------
 6 files changed, 0 insertions(+), 319 deletions(-)
 delete mode 100644 include/net/tc_act/tc_skbedit.h
 delete mode 100644 include/uapi/linux/tc_act/tc_skbedit.h
 delete mode 100644 net/sched/act_skbedit.c

diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
deleted file mode 100644
index e103fe02f375..000000000000
--- a/include/net/tc_act/tc_skbedit.h
+++ /dev/null
@@ -1,36 +0,0 @@
-/*
- * Copyright (c) 2008, Intel Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms and conditions of the GNU General Public License,
- * version 2, as published by the Free Software Foundation.
- *
- * This program is distributed in the hope it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
- *
- * Author: Alexander Duyck <alexander.h.duyck@intel.com>
- */
-
-#ifndef __NET_TC_SKBEDIT_H
-#define __NET_TC_SKBEDIT_H
-
-#include <net/act_api.h>
-
-struct tcf_skbedit {
-	struct tcf_common	common;
-	u32			flags;
-	u32     		priority;
-	u32     		mark;
-	u16			queue_mapping;
-	/* XXX: 16-bit pad here? */
-};
-#define to_skbedit(pc) \
-	container_of(pc, struct tcf_skbedit, common)
-
-#endif /* __NET_TC_SKBEDIT_H */
diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
index 56f121605c99..713b331d9df3 100644
--- a/include/uapi/linux/tc_act/Kbuild
+++ b/include/uapi/linux/tc_act/Kbuild
@@ -6,4 +6,3 @@ header-y += tc_ipt.h
 header-y += tc_mirred.h
 header-y += tc_nat.h
 header-y += tc_pedit.h
-header-y += tc_skbedit.h
diff --git a/include/uapi/linux/tc_act/tc_skbedit.h b/include/uapi/linux/tc_act/tc_skbedit.h
deleted file mode 100644
index 7a2e910a5f08..000000000000
--- a/include/uapi/linux/tc_act/tc_skbedit.h
+++ /dev/null
@@ -1,46 +0,0 @@
-/*
- * Copyright (c) 2008, Intel Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms and conditions of the GNU General Public License,
- * version 2, as published by the Free Software Foundation.
- *
- * This program is distributed in the hope it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
- *
- * Author: Alexander Duyck <alexander.h.duyck@intel.com>
- */
-
-#ifndef __LINUX_TC_SKBEDIT_H
-#define __LINUX_TC_SKBEDIT_H
-
-#include <linux/pkt_cls.h>
-
-#define TCA_ACT_SKBEDIT 11
-
-#define SKBEDIT_F_PRIORITY		0x1
-#define SKBEDIT_F_QUEUE_MAPPING		0x2
-#define SKBEDIT_F_MARK			0x4
-
-struct tc_skbedit {
-	tc_gen;
-};
-
-enum {
-	TCA_SKBEDIT_UNSPEC,
-	TCA_SKBEDIT_TM,
-	TCA_SKBEDIT_PARMS,
-	TCA_SKBEDIT_PRIORITY,
-	TCA_SKBEDIT_QUEUE_MAPPING,
-	TCA_SKBEDIT_MARK,
-	__TCA_SKBEDIT_MAX
-};
-#define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
-
-#endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index c03a32a0418e..37af03bba732 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -632,17 +632,6 @@ config NET_ACT_SIMP
 	  To compile this code as a module, choose M here: the
 	  module will be called act_simple.
 
-config NET_ACT_SKBEDIT
-        tristate "SKB Editing"
-        depends on NET_CLS_ACT
-        ---help---
-	  Say Y here to change skb priority or queue_mapping settings.
-
-	  If unsure, say N.
-
-	  To compile this code as a module, choose M here: the
-	  module will be called act_skbedit.
-
 config NET_ACT_CSUM
         tristate "Checksum Updating"
         depends on NET_CLS_ACT && INET
diff --git a/net/sched/Makefile b/net/sched/Makefile
index e5f9abe9a5db..91e2acf15832 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -14,7 +14,6 @@ obj-$(CONFIG_NET_ACT_IPT)	+= act_ipt.o
 obj-$(CONFIG_NET_ACT_NAT)	+= act_nat.o
 obj-$(CONFIG_NET_ACT_PEDIT)	+= act_pedit.o
 obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
-obj-$(CONFIG_NET_ACT_SKBEDIT)	+= act_skbedit.o
 obj-$(CONFIG_NET_ACT_CSUM)	+= act_csum.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
deleted file mode 100644
index cb4221171f93..000000000000
--- a/net/sched/act_skbedit.c
+++ /dev/null
@@ -1,224 +0,0 @@
-/*
- * Copyright (c) 2008, Intel Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms and conditions of the GNU General Public License,
- * version 2, as published by the Free Software Foundation.
- *
- * This program is distributed in the hope it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
- *
- * Author: Alexander Duyck <alexander.h.duyck@intel.com>
- */
-
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/kernel.h>
-#include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
-#include <net/netlink.h>
-#include <net/pkt_sched.h>
-
-#include <linux/tc_act/tc_skbedit.h>
-#include <net/tc_act/tc_skbedit.h>
-
-#define SKBEDIT_TAB_MASK     15
-static struct tcf_common *tcf_skbedit_ht[SKBEDIT_TAB_MASK + 1];
-static u32 skbedit_idx_gen;
-static DEFINE_RWLOCK(skbedit_lock);
-
-static struct tcf_hashinfo skbedit_hash_info = {
-	.htab	=	tcf_skbedit_ht,
-	.hmask	=	SKBEDIT_TAB_MASK,
-	.lock	=	&skbedit_lock,
-};
-
-static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
-		       struct tcf_result *res)
-{
-	struct tcf_skbedit *d = a->priv;
-
-	spin_lock(&d->tcf_lock);
-	d->tcf_tm.lastuse = jiffies;
-	bstats_update(&d->tcf_bstats, skb);
-
-	if (d->flags & SKBEDIT_F_PRIORITY)
-		skb->priority = d->priority;
-	if (d->flags & SKBEDIT_F_QUEUE_MAPPING &&
-	    skb->dev->real_num_tx_queues > d->queue_mapping)
-		skb_set_queue_mapping(skb, d->queue_mapping);
-	if (d->flags & SKBEDIT_F_MARK)
-		skb->mark = d->mark;
-
-	spin_unlock(&d->tcf_lock);
-	return d->tcf_action;
-}
-
-static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
-	[TCA_SKBEDIT_PARMS]		= { .len = sizeof(struct tc_skbedit) },
-	[TCA_SKBEDIT_PRIORITY]		= { .len = sizeof(u32) },
-	[TCA_SKBEDIT_QUEUE_MAPPING]	= { .len = sizeof(u16) },
-	[TCA_SKBEDIT_MARK]		= { .len = sizeof(u32) },
-};
-
-static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
-			    struct nlattr *est, struct tc_action *a,
-			    int ovr, int bind)
-{
-	struct nlattr *tb[TCA_SKBEDIT_MAX + 1];
-	struct tc_skbedit *parm;
-	struct tcf_skbedit *d;
-	struct tcf_common *pc;
-	u32 flags = 0, *priority = NULL, *mark = NULL;
-	u16 *queue_mapping = NULL;
-	int ret = 0, err;
-
-	if (nla == NULL)
-		return -EINVAL;
-
-	err = nla_parse_nested(tb, TCA_SKBEDIT_MAX, nla, skbedit_policy);
-	if (err < 0)
-		return err;
-
-	if (tb[TCA_SKBEDIT_PARMS] == NULL)
-		return -EINVAL;
-
-	if (tb[TCA_SKBEDIT_PRIORITY] != NULL) {
-		flags |= SKBEDIT_F_PRIORITY;
-		priority = nla_data(tb[TCA_SKBEDIT_PRIORITY]);
-	}
-
-	if (tb[TCA_SKBEDIT_QUEUE_MAPPING] != NULL) {
-		flags |= SKBEDIT_F_QUEUE_MAPPING;
-		queue_mapping = nla_data(tb[TCA_SKBEDIT_QUEUE_MAPPING]);
-	}
-
-	if (tb[TCA_SKBEDIT_MARK] != NULL) {
-		flags |= SKBEDIT_F_MARK;
-		mark = nla_data(tb[TCA_SKBEDIT_MARK]);
-	}
-
-	if (!flags)
-		return -EINVAL;
-
-	parm = nla_data(tb[TCA_SKBEDIT_PARMS]);
-
-	pc = tcf_hash_check(parm->index, a, bind, &skbedit_hash_info);
-	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
-				     &skbedit_idx_gen, &skbedit_hash_info);
-		if (IS_ERR(pc))
-			return PTR_ERR(pc);
-
-		d = to_skbedit(pc);
-		ret = ACT_P_CREATED;
-	} else {
-		d = to_skbedit(pc);
-		if (!ovr) {
-			tcf_hash_release(pc, bind, &skbedit_hash_info);
-			return -EEXIST;
-		}
-	}
-
-	spin_lock_bh(&d->tcf_lock);
-
-	d->flags = flags;
-	if (flags & SKBEDIT_F_PRIORITY)
-		d->priority = *priority;
-	if (flags & SKBEDIT_F_QUEUE_MAPPING)
-		d->queue_mapping = *queue_mapping;
-	if (flags & SKBEDIT_F_MARK)
-		d->mark = *mark;
-
-	d->tcf_action = parm->action;
-
-	spin_unlock_bh(&d->tcf_lock);
-
-	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, &skbedit_hash_info);
-	return ret;
-}
-
-static int tcf_skbedit_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_skbedit *d = a->priv;
-
-	if (d)
-		return tcf_hash_release(&d->common, bind, &skbedit_hash_info);
-	return 0;
-}
-
-static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
-			    int bind, int ref)
-{
-	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_skbedit *d = a->priv;
-	struct tc_skbedit opt = {
-		.index   = d->tcf_index,
-		.refcnt  = d->tcf_refcnt - ref,
-		.bindcnt = d->tcf_bindcnt - bind,
-		.action  = d->tcf_action,
-	};
-	struct tcf_t t;
-
-	if (nla_put(skb, TCA_SKBEDIT_PARMS, sizeof(opt), &opt))
-		goto nla_put_failure;
-	if ((d->flags & SKBEDIT_F_PRIORITY) &&
-	    nla_put(skb, TCA_SKBEDIT_PRIORITY, sizeof(d->priority),
-		    &d->priority))
-		goto nla_put_failure;
-	if ((d->flags & SKBEDIT_F_QUEUE_MAPPING) &&
-	    nla_put(skb, TCA_SKBEDIT_QUEUE_MAPPING,
-		    sizeof(d->queue_mapping), &d->queue_mapping))
-		goto nla_put_failure;
-	if ((d->flags & SKBEDIT_F_MARK) &&
-	    nla_put(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
-		    &d->mark))
-		goto nla_put_failure;
-	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
-	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
-	if (nla_put(skb, TCA_SKBEDIT_TM, sizeof(t), &t))
-		goto nla_put_failure;
-	return skb->len;
-
-nla_put_failure:
-	nlmsg_trim(skb, b);
-	return -1;
-}
-
-static struct tc_action_ops act_skbedit_ops = {
-	.kind		=	"skbedit",
-	.hinfo		=	&skbedit_hash_info,
-	.type		=	TCA_ACT_SKBEDIT,
-	.capab		=	TCA_CAP_NONE,
-	.owner		=	THIS_MODULE,
-	.act		=	tcf_skbedit,
-	.dump		=	tcf_skbedit_dump,
-	.cleanup	=	tcf_skbedit_cleanup,
-	.init		=	tcf_skbedit_init,
-	.walk		=	tcf_generic_walker,
-};
-
-MODULE_AUTHOR("Alexander Duyck, <alexander.h.duyck@intel.com>");
-MODULE_DESCRIPTION("SKB Editing");
-MODULE_LICENSE("GPL");
-
-static int __init skbedit_init_module(void)
-{
-	return tcf_register_action(&act_skbedit_ops);
-}
-
-static void __exit skbedit_cleanup_module(void)
-{
-	tcf_unregister_action(&act_skbedit_ops);
-}
-
-module_init(skbedit_init_module);
-module_exit(skbedit_cleanup_module);
-- 
1.7.5.4
