From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [RFC PATCH net-next 1/1] Introduce skbmod action
Date: Mon, 11 Jul 2016 08:12:44 -0400
Message-ID: <1468239164-17898-1-git-send-email-jhs@emojatatu.com>
Cc: daniel@iogearbox.net, xiyou.wangcong@gmail.com,
	nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34420 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758651AbcGKMMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 08:12:53 -0400
Received: by mail-it0-f65.google.com with SMTP id u186so8925201ita.1
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 05:12:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

This action is intended to be an upgrade from a usability perspective
from pedit. Compare this:

sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
u32 match ip protocol 1 0xff flowid 1:2 \
action pedit munge offset -14 u8 set 0x02 \
       munge offset -13 u8 set 0x15 \
       munge offset -12 u8 set 0x15 \
       munge offset -11 u8 set 0x15 \
       munge offset -10 u16 set 0x1515 \
       pipe

to:

sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
u32 match ip protocol 1 0xff flowid 1:2 \
action skbmod dstmac 02:15:15:15:15:15

The dump output is even more tricky.

pedit is a good starting point - but once you start going to a large
number of policies then from a programmability, ops and usability point
of view you need something with more succint params.

I have added only DST MAC - but for (ethernet) completion I will add SRC MAC
and ethertype.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/tc_act/tc_skbmod.h        |  33 ++++++
 include/uapi/linux/tc_act/tc_skbmod.h |  43 +++++++
 net/sched/act_skbmod.c                | 216 ++++++++++++++++++++++++++++++++++
 3 files changed, 292 insertions(+)
 create mode 100644 include/net/tc_act/tc_skbmod.h
 create mode 100644 include/uapi/linux/tc_act/tc_skbmod.h
 create mode 100644 net/sched/act_skbmod.c

diff --git a/include/net/tc_act/tc_skbmod.h b/include/net/tc_act/tc_skbmod.h
new file mode 100644
index 0000000..4980960
--- /dev/null
+++ b/include/net/tc_act/tc_skbmod.h
@@ -0,0 +1,33 @@
+/*
+ * Copyright (c) 2016, Jamal Hadi Salim
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * Author: Jamal Hadi Salim <jhs@mojatatu.com>
+ */
+
+#ifndef __NET_TC_SKBMOD_H
+#define __NET_TC_SKBMOD_H
+
+#include <net/act_api.h>
+#include <linux/tc_act/tc_skbmod.h>
+
+struct tcf_skbmod {
+	struct tcf_common	common;
+	u32	flags;
+	u8	eth_dst[ETH_ALEN];
+};
+#define to_skbmod(a) \
+	container_of(a->priv, struct tcf_skbmod, common)
+
+#endif /* __NET_TC_SKBMOD_H */
diff --git a/include/uapi/linux/tc_act/tc_skbmod.h b/include/uapi/linux/tc_act/tc_skbmod.h
new file mode 100644
index 0000000..e447240
--- /dev/null
+++ b/include/uapi/linux/tc_act/tc_skbmod.h
@@ -0,0 +1,43 @@
+/*
+ * Copyright (c) 2016, Jamal Hadi Salim
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ *
+ * Author: Jamal Hadi Salim
+ */
+
+#ifndef __LINUX_TC_SKBMOD_H
+#define __LINUX_TC_SKBMOD_H
+
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_SKBMOD 15
+
+#define SKBMOD_F_DMAC	0x1
+
+struct tc_skbmod {
+	tc_gen;
+};
+
+enum {
+	TCA_SKBMOD_UNSPEC,
+	TCA_SKBMOD_TM,
+	TCA_SKBMOD_PARMS,
+	TCA_SKBMOD_DMAC,
+	TCA_SKBMOD_PAD,
+	__TCA_SKBMOD_MAX
+};
+#define TCA_SKBMOD_MAX (__TCA_SKBMOD_MAX - 1)
+
+#endif
diff --git a/net/sched/act_skbmod.c b/net/sched/act_skbmod.c
new file mode 100644
index 0000000..81e470e
--- /dev/null
+++ b/net/sched/act_skbmod.c
@@ -0,0 +1,216 @@
+/*
+ * copyright Jamal Hadi Salim (2016)
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * Author: Jamal Hadi Salim <jhs@mojatatu.com>
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+
+#include <linux/tc_act/tc_skbmod.h>
+#include <net/tc_act/tc_skbmod.h>
+
+#define SKBMOD_TAB_MASK     15
+
+static int skbmod_net_id;
+
+static int tcf_skbmod_run(struct sk_buff *skb, const struct tc_action *a,
+			  struct tcf_result *res)
+{
+	struct tcf_skbmod *d = a->priv;
+
+	spin_lock(&d->tcf_lock);
+	tcf_lastuse_update(&d->tcf_tm);
+	bstats_update(&d->tcf_bstats, skb);
+
+	if (d->flags & SKBMOD_F_DMAC)
+		ether_addr_copy(eth_hdr(skb)->h_dest, m->eth_dst);
+
+	spin_unlock(&d->tcf_lock);
+	return d->tcf_action;
+}
+
+static const struct nla_policy skbmod_policy[TCA_SKBMOD_MAX + 1] = {
+	[TCA_SKBMOD_PARMS]		= { .len = sizeof(struct tc_skbmod) },
+	[TCA_SKBMOD_DMAC]		= { .len = ETH_ALEN },
+};
+
+static int tcf_skbmod_init(struct net *net, struct nlattr *nla,
+			    struct nlattr *est, struct tc_action *a,
+			    int ovr, int bind)
+{
+	struct tc_action_net *tn = net_generic(net, skbmod_net_id);
+	struct nlattr *tb[TCA_SKBMOD_MAX + 1];
+	struct tc_skbmod *parm;
+	struct tcf_skbmod *d;
+	u32 flags = 0, *priority = NULL, *mark = NULL;
+	u16 *queue_mapping = NULL, *ptype = NULL;
+	bool exists = false;
+	int ret = 0, err;
+
+	if (nla == NULL)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_SKBMOD_MAX, nla, skbmod_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_SKBMOD_PARMS] == NULL)
+		return -EINVAL;
+
+	/*Allow zero valued dmac */
+	if (tb[TCA_SKBMOD_DMAC]) {
+		daddr = nla_data(tb[TCA_SKBMOD_DMAC]);
+		flags |= SKBMOD_F_DMAC;
+	}
+
+	if (!flags) {
+		return -EINVAL;
+	}
+
+	parm = nla_data(tb[TCA_SKBMOD_PARMS]);
+
+	exists = tcf_hash_check(tn, parm->index, a, bind);
+	if (exists && bind)
+		return 0;
+
+	if (!exists) {
+		ret = tcf_hash_create(tn, parm->index, est, a,
+				      sizeof(*d), bind, false);
+		if (ret)
+			return ret;
+
+		d = to_skbmod(a);
+		ret = ACT_P_CREATED;
+	} else {
+		d = to_skbmod(a);
+		tcf_hash_release(a, bind);
+		if (!ovr)
+			return -EEXIST;
+	}
+
+	spin_lock_bh(&d->tcf_lock);
+
+	d->flags = flags;
+	if (flags & SKBMOD_F_DMAC)
+		ether_addr_copy(m->eth_dst, daddr);
+
+	d->tcf_action = parm->action;
+
+	spin_unlock_bh(&d->tcf_lock);
+
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(tn, a);
+	return ret;
+}
+
+static int tcf_skbmod_dump(struct sk_buff *skb, struct tc_action *a,
+			    int bind, int ref)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tcf_skbmod *d = a->priv;
+	struct tc_skbmod opt = {
+		.index   = d->tcf_index,
+		.refcnt  = d->tcf_refcnt - ref,
+		.bindcnt = d->tcf_bindcnt - bind,
+		.action  = d->tcf_action,
+	};
+	struct tcf_t t;
+
+	if (nla_put(skb, TCA_SKBMOD_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
+	if ((d->flags & SKBMOD_F_DMAC) &&
+	    nla_put(skb, TCA_SKBMOD_DMAC, ETH_ALEN, m->eth_dst))
+		goto nla_put_failure;
+
+	tcf_tm_dump(&t, &d->tcf_tm);
+	if (nla_put_64bit(skb, TCA_SKBMOD_TM, sizeof(t), &t, TCA_SKBMOD_PAD))
+		goto nla_put_failure;
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static int tcf_skbmod_walker(struct net *net, struct sk_buff *skb,
+			      struct netlink_callback *cb, int type,
+			      struct tc_action *a)
+{
+	struct tc_action_net *tn = net_generic(net, skbmod_net_id);
+
+	return tcf_generic_walker(tn, skb, cb, type, a);
+}
+
+static int tcf_skbmod_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct tc_action_net *tn = net_generic(net, skbmod_net_id);
+
+	return tcf_hash_search(tn, a, index);
+}
+
+static struct tc_action_ops act_skbmod_ops = {
+	.kind		=	"skbmod",
+	.type		=	TCA_ACT_SKBMOD,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_skbmod_run,
+	.dump		=	tcf_skbmod_dump,
+	.init		=	tcf_skbmod_init,
+	.walk		=	tcf_skbmod_walker,
+	.lookup		=	tcf_skbmod_search,
+};
+
+static __net_init int skbmod_init_net(struct net *net)
+{
+	struct tc_action_net *tn = net_generic(net, skbmod_net_id);
+
+	return tc_action_net_init(tn, &act_skbmod_ops, SKBMOD_TAB_MASK);
+}
+
+static void __net_exit skbmod_exit_net(struct net *net)
+{
+	struct tc_action_net *tn = net_generic(net, skbmod_net_id);
+
+	tc_action_net_exit(tn);
+}
+
+static struct pernet_operations skbmod_net_ops = {
+	.init = skbmod_init_net,
+	.exit = skbmod_exit_net,
+	.id   = &skbmod_net_id,
+	.size = sizeof(struct tc_action_net),
+};
+
+MODULE_AUTHOR("Jamal Hadi Salim, <jhs@mojatatu.com>");
+MODULE_DESCRIPTION("SKB mod-ing");
+MODULE_LICENSE("GPL");
+
+static int __init skbmod_init_module(void)
+{
+	return tcf_register_action(&act_skbmod_ops, &skbmod_net_ops);
+}
+
+static void __exit skbmod_cleanup_module(void)
+{
+	tcf_unregister_action(&act_skbmod_ops, &skbmod_net_ops);
+}
+
+module_init(skbmod_init_module);
+module_exit(skbmod_cleanup_module);
-- 
1.9.1
