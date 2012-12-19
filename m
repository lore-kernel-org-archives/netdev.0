From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Wed, 19 Dec 2012 06:56:46 -0500
Message-ID: <50D1AB7E.5060000@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com> <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050503020000070306090906"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	Yury Stankevich <urykhy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Hasan Chowdhury <shemonc@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50D1A8A7.1090002@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050503020000070306090906
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


To be applied pending more testing.

Attached. Sorry, I thought I had sent this out over the weekend.
I have done basic testing with a single mark and sending pings to
update stats which can then displayed for the mark.

Hasan/Yury, if you test this please use the latest iproute2 with only 
the first patch I posted (originally from Hasan). Hasan please use that
patch not your version - if theres anything wrong we can find out sooner
before the patch becomes final.

cheers,
jamal

--------------050503020000070306090906
Content-Type: text/plain; charset=UTF-8;
 name="xt-p1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="xt-p1"

commit 82330cc874429c63bd0e476e413a79ebab3da350
Author: Jamal Hadi Salim <hadi@mojatatu.com>
Date:   Wed Dec 19 06:23:28 2012 -0500

    Fix iptables/xtables ABI changes. We will eventually replace
    act_ipt with act_xt since only very few targets still support the
    old xtables interface
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 235e01a..1693973 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -578,12 +578,25 @@ config NET_ACT_MIRRED
 config NET_ACT_IPT
         tristate "IPtables targets"
         depends on NET_CLS_ACT && NETFILTER && IP_NF_IPTABLES
+	select NET_ACT_XT
         ---help---
 	  Say Y here to be able to invoke iptables targets after successful
-	  classification.
+	  classification. Better yet choose NET_ACT_XT since this version
+	  will eventually be obsoleted.
 
 	  To compile this code as a module, choose M here: the
 	  module will be called act_ipt.
+config NET_ACT_XT
+        tristate "New IPtables targets"
+        depends on NET_CLS_ACT && NETFILTER && IP_NF_IPTABLES
+        ---help---
+	  Say Y here to be able to invoke iptables targets after successful
+	  classification using the new xtables mechanism. This mechanism
+	  will eventually replace NET_ACT_IPT
+
+	  To compile this code as a module, choose M here: the
+	  module will be called act_xt.
+
 
 config NET_ACT_NAT
         tristate "Stateless NAT"
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 978cbf0..10a1136 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -11,6 +11,7 @@ obj-$(CONFIG_NET_ACT_POLICE)	+= act_police.o
 obj-$(CONFIG_NET_ACT_GACT)	+= act_gact.o
 obj-$(CONFIG_NET_ACT_MIRRED)	+= act_mirred.o
 obj-$(CONFIG_NET_ACT_IPT)	+= act_ipt.o
+obj-$(CONFIG_NET_ACT_XT)	+= act_xt.o
 obj-$(CONFIG_NET_ACT_NAT)	+= act_nat.o
 obj-$(CONFIG_NET_ACT_PEDIT)	+= act_pedit.o
 obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
diff --git a/net/sched/act_xt.c b/net/sched/act_xt.c
new file mode 100644
index 0000000..589cfe6
--- /dev/null
+++ b/net/sched/act_xt.c
@@ -0,0 +1,324 @@
+/*
+ * net/sched/act_xt.c     iptables target interface
+ *
+ *TODO: Add other tables. For now we only support the ipv4 table targets
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Copyright:	Jamal Hadi Salim (2002-12)
+ */
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+#include <linux/tc_act/tc_ipt.h>
+#include <net/tc_act/tc_ipt.h>
+
+#include <linux/netfilter_ipv4/ip_tables.h>
+
+#define IPT_TAB_MASK     15
+static struct tcf_common *tcf_ipt_ht[IPT_TAB_MASK + 1];
+static u32 ipt_idx_gen;
+static DEFINE_RWLOCK(ipt_lock);
+
+static struct tcf_hashinfo ipt_hash_info = {
+	.htab = tcf_ipt_ht,
+	.hmask = IPT_TAB_MASK,
+	.lock = &ipt_lock,
+};
+
+static int ipt_init_target(struct xt_entry_target *t, char *table,
+			   unsigned int hook)
+{
+	struct xt_tgchk_param par;
+	struct xt_target *target;
+	int ret = 0;
+
+	target = xt_request_find_target(AF_INET, t->u.user.name,
+					t->u.user.revision);
+	if (IS_ERR(target))
+		return PTR_ERR(target);
+
+	t->u.kernel.target = target;
+	par.table = table;
+	par.entryinfo = NULL;
+	par.target = target;
+	par.targinfo = t->data;
+	par.hook_mask = hook;
+	par.family = NFPROTO_IPV4;
+
+	ret = xt_check_target(&par, t->u.target_size - sizeof(*t), 0, false);
+	if (ret < 0) {
+		module_put(t->u.kernel.target->me);
+		return ret;
+	}
+	return 0;
+}
+
+static void ipt_destroy_target(struct xt_entry_target *t)
+{
+	struct xt_tgdtor_param par = {
+		.target = t->u.kernel.target,
+		.targinfo = t->data,
+	};
+	if (par.target->destroy != NULL)
+		par.target->destroy(&par);
+	module_put(par.target->me);
+}
+
+static int tcf_ipt_release(struct tcf_ipt *ipt, int bind)
+{
+	int ret = 0;
+	if (ipt) {
+		if (bind)
+			ipt->tcf_bindcnt--;
+		ipt->tcf_refcnt--;
+		if (ipt->tcf_bindcnt <= 0 && ipt->tcf_refcnt <= 0) {
+			ipt_destroy_target(ipt->tcfi_t);
+			kfree(ipt->tcfi_tname);
+			kfree(ipt->tcfi_t);
+			tcf_hash_destroy(&ipt->common, &ipt_hash_info);
+			ret = ACT_P_DELETED;
+		}
+	}
+	return ret;
+}
+
+static const struct nla_policy ipt_policy[TCA_IPT_MAX + 1] = {
+	[TCA_IPT_TABLE] = {.type = NLA_STRING,.len = IFNAMSIZ},
+	[TCA_IPT_HOOK] = {.type = NLA_U32},
+	[TCA_IPT_INDEX] = {.type = NLA_U32},
+	[TCA_IPT_TARG] = {.len = sizeof(struct xt_entry_target)},
+};
+
+static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
+			struct tc_action *a, int ovr, int bind)
+{
+	struct nlattr *tb[TCA_IPT_MAX + 1];
+	struct tcf_ipt *ipt;
+	struct tcf_common *pc;
+	struct xt_entry_target *td, *t;
+	char *tname;
+	int ret = 0, err;
+	u32 hook = 0;
+	u32 index = 0;
+
+	if (nla == NULL)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_IPT_MAX, nla, ipt_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_IPT_HOOK] == NULL)
+		return -EINVAL;
+	if (tb[TCA_IPT_TARG] == NULL)
+		return -EINVAL;
+
+	td = (struct xt_entry_target *)nla_data(tb[TCA_IPT_TARG]);
+	if (nla_len(tb[TCA_IPT_TARG]) < td->u.target_size)
+		return -EINVAL;
+
+	if (tb[TCA_IPT_INDEX] != NULL)
+		index = nla_get_u32(tb[TCA_IPT_INDEX]);
+
+	pc = tcf_hash_check(index, a, bind, &ipt_hash_info);
+	if (!pc) {
+		pc = tcf_hash_create(index, est, a, sizeof(*ipt), bind,
+				     &ipt_idx_gen, &ipt_hash_info);
+		if (IS_ERR(pc))
+			return PTR_ERR(pc);
+		ret = ACT_P_CREATED;
+	} else {
+		if (!ovr) {
+			tcf_ipt_release(to_ipt(pc), bind);
+			return -EEXIST;
+		}
+	}
+	ipt = to_ipt(pc);
+
+	hook = nla_get_u32(tb[TCA_IPT_HOOK]);
+
+	err = -ENOMEM;
+	tname = kmalloc(IFNAMSIZ, GFP_KERNEL);
+	if (unlikely(!tname))
+		goto err1;
+	if (tb[TCA_IPT_TABLE] == NULL ||
+	    nla_strlcpy(tname, tb[TCA_IPT_TABLE], IFNAMSIZ) >= IFNAMSIZ)
+		strcpy(tname, "mangle");
+
+	t = kmemdup(td, td->u.target_size, GFP_KERNEL);
+	if (unlikely(!t))
+		goto err2;
+
+	err = ipt_init_target(t, tname, hook);
+	if (err < 0)
+		goto err3;
+
+	spin_lock_bh(&ipt->tcf_lock);
+	if (ret != ACT_P_CREATED) {
+		ipt_destroy_target(ipt->tcfi_t);
+		kfree(ipt->tcfi_tname);
+		kfree(ipt->tcfi_t);
+	}
+	ipt->tcfi_tname = tname;
+	ipt->tcfi_t = t;
+	ipt->tcfi_hook = hook;
+	spin_unlock_bh(&ipt->tcf_lock);
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(pc, &ipt_hash_info);
+	return ret;
+
+err3:
+	kfree(t);
+err2:
+	kfree(tname);
+err1:
+	if (ret == ACT_P_CREATED) {
+		if (est)
+			gen_kill_estimator(&pc->tcfc_bstats,
+					   &pc->tcfc_rate_est);
+		kfree_rcu(pc, tcfc_rcu);
+	}
+	return err;
+}
+
+static int tcf_ipt_cleanup(struct tc_action *a, int bind)
+{
+	struct tcf_ipt *ipt = a->priv;
+	return tcf_ipt_release(ipt, bind);
+}
+
+static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
+		   struct tcf_result *res)
+{
+	int ret = 0, result = 0;
+	struct tcf_ipt *ipt = a->priv;
+	struct xt_action_param par;
+
+	if (skb_cloned(skb)) {
+		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			return TC_ACT_UNSPEC;
+	}
+
+	spin_lock(&ipt->tcf_lock);
+
+	ipt->tcf_tm.lastuse = jiffies;
+	bstats_update(&ipt->tcf_bstats, skb);
+
+	/* yes, we have to worry about both in and out dev
+	 * worry later - danger - this API seems to have changed
+	 * from earlier kernels
+	 */
+	par.in = skb->dev;
+	par.out = NULL;
+	par.hooknum = ipt->tcfi_hook;
+	par.target = ipt->tcfi_t->u.kernel.target;
+	par.targinfo = ipt->tcfi_t->data;
+	ret = par.target->target(skb, &par);
+
+	switch (ret) {
+	case NF_ACCEPT:
+		result = TC_ACT_OK;
+		break;
+	case NF_DROP:
+		result = TC_ACT_SHOT;
+		ipt->tcf_qstats.drops++;
+		break;
+	case XT_CONTINUE:
+		result = TC_ACT_PIPE;
+		break;
+	default:
+		net_notice_ratelimited
+		    ("tc filter: Bogus netfilter code %d assume ACCEPT\n", ret);
+		result = TC_POLICE_OK;
+		break;
+	}
+	spin_unlock(&ipt->tcf_lock);
+	return result;
+
+}
+
+static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind,
+			int ref)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tcf_ipt *ipt = a->priv;
+	struct xt_entry_target *t;
+	struct tcf_t tm;
+	struct tc_cnt c;
+
+	/* for simple targets kernel size == user size
+	 * user name = target name
+	 * for foolproof you need to not assume this
+	 */
+
+	t = kmemdup(ipt->tcfi_t, ipt->tcfi_t->u.user.target_size, GFP_ATOMIC);
+	if (unlikely(!t))
+		goto nla_put_failure;
+
+	c.bindcnt = ipt->tcf_bindcnt - bind;
+	c.refcnt = ipt->tcf_refcnt - ref;
+	strcpy(t->u.user.name, ipt->tcfi_t->u.kernel.target->name);
+
+	if (nla_put(skb, TCA_IPT_TARG, ipt->tcfi_t->u.user.target_size, t) ||
+	    nla_put_u32(skb, TCA_IPT_INDEX, ipt->tcf_index) ||
+	    nla_put_u32(skb, TCA_IPT_HOOK, ipt->tcfi_hook) ||
+	    nla_put(skb, TCA_IPT_CNT, sizeof(struct tc_cnt), &c) ||
+	    nla_put_string(skb, TCA_IPT_TABLE, ipt->tcfi_tname))
+		goto nla_put_failure;
+	tm.install = jiffies_to_clock_t(jiffies - ipt->tcf_tm.install);
+	tm.lastuse = jiffies_to_clock_t(jiffies - ipt->tcf_tm.lastuse);
+	tm.expires = jiffies_to_clock_t(ipt->tcf_tm.expires);
+	if (nla_put(skb, TCA_IPT_TM, sizeof(tm), &tm))
+		goto nla_put_failure;
+	kfree(t);
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	kfree(t);
+	return -1;
+}
+
+static struct tc_action_ops act_ipt_ops = {
+	.kind = "xt",
+	.hinfo = &ipt_hash_info,
+	.type = TCA_ACT_IPT,
+	.capab = TCA_CAP_NONE,
+	.owner = THIS_MODULE,
+	.act = tcf_ipt,
+	.dump = tcf_ipt_dump,
+	.cleanup = tcf_ipt_cleanup,
+	.lookup = tcf_hash_search,
+	.init = tcf_ipt_init,
+	.walk = tcf_generic_walker
+};
+
+MODULE_AUTHOR("Jamal Hadi Salim(2002-12)");
+MODULE_DESCRIPTION("New Iptables target actions");
+MODULE_LICENSE("GPL");
+
+static int __init ipt_init_module(void)
+{
+	return tcf_register_action(&act_ipt_ops);
+}
+
+static void __exit ipt_cleanup_module(void)
+{
+	tcf_unregister_action(&act_ipt_ops);
+}
+
+module_init(ipt_init_module);
+module_exit(ipt_cleanup_module);

--------------050503020000070306090906--
