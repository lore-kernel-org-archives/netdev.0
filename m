From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Sun, 17 Jul 2016 04:41:24 -0400
Message-ID: <1468744884-8246-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33637 "EHLO
	mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbcGQIlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 04:41:51 -0400
Received: by mail-qt0-f194.google.com with SMTP id j37so5739091qta.0
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2016 01:41:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

This action is intended to be an upgrade from a usability perspective
from pedit (as well as operational debugability).
Compare this:

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
action skbmod dmac 02:15:15:15:15:15

Or worse, try to debug a policy with destination mac, source mac and
etherype. Then make that a hundred rules and you'll get my point.

In the future common use cases on pedit can be migrated to this action
(as an example different fields in ip v4/6, transports like tcp/udp/sctp
etc). For this first cut, this allows modifying basic ethernet header.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/tc_act/tc_skbmod.h        |  35 +++++
 include/uapi/linux/tc_act/tc_skbmod.h |  47 +++++++
 net/sched/Kconfig                     |  11 ++
 net/sched/Makefile                    |   1 +
 net/sched/act_skbmod.c                | 245 ++++++++++++++++++++++++++++++++++
 5 files changed, 339 insertions(+)
 create mode 100644 include/net/tc_act/tc_skbmod.h
 create mode 100644 include/uapi/linux/tc_act/tc_skbmod.h
 create mode 100644 net/sched/act_skbmod.c

diff --git a/include/net/tc_act/tc_skbmod.h b/include/net/tc_act/tc_skbmod.h
new file mode 100644
index 0000000..661a107
--- /dev/null
+++ b/include/net/tc_act/tc_skbmod.h
@@ -0,0 +1,35 @@
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
+	u16	eth_type;
+	u8	eth_src[ETH_ALEN];
+};
+#define to_skbmod(a) \
+	container_of(a->priv, struct tcf_skbmod, common)
+
+#endif /* __NET_TC_SKBMOD_H */
diff --git a/include/uapi/linux/tc_act/tc_skbmod.h b/include/uapi/linux/tc_act/tc_skbmod.h
new file mode 100644
index 0000000..c268b94
--- /dev/null
+++ b/include/uapi/linux/tc_act/tc_skbmod.h
@@ -0,0 +1,47 @@
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
+#define SKBMOD_F_SMAC	0x2
+#define SKBMOD_F_ETYPE	0x4
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
+	TCA_SKBMOD_SMAC,
+	TCA_SKBMOD_ETYPE,
+	TCA_SKBMOD_PAD,
+	__TCA_SKBMOD_MAX
+};
+#define TCA_SKBMOD_MAX (__TCA_SKBMOD_MAX - 1)
+
+#endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index b148302..ca0386c 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -739,6 +739,17 @@ config NET_ACT_CONNMARK
 	  To compile this code as a module, choose M here: the
 	  module will be called act_connmark.
 
+config NET_ACT_SKBMOD
+        tristate "skb data modification action"
+        depends on NET_CLS_ACT
+        ---help---
+	  Say Y here to allow modification of skb data
+
+	  If unsure, say N.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called act_skbmod.
+
 config NET_ACT_IFE
         tristate "Inter-FE action based on IETF ForCES InterFE LFB"
         depends on NET_CLS_ACT
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 84bddb3..edead66 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_NET_ACT_CSUM)	+= act_csum.o
 obj-$(CONFIG_NET_ACT_VLAN)	+= act_vlan.o
 obj-$(CONFIG_NET_ACT_BPF)	+= act_bpf.o
 obj-$(CONFIG_NET_ACT_CONNMARK)	+= act_connmark.o
+obj-$(CONFIG_NET_ACT_SKBMOD)	+= act_skbmod.o
 obj-$(CONFIG_NET_ACT_IFE)	+= act_ife.o
 obj-$(CONFIG_NET_IFE_SKBMARK)	+= act_meta_mark.o
 obj-$(CONFIG_NET_IFE_SKBPRIO)	+= act_meta_skbprio.o
diff --git a/net/sched/act_skbmod.c b/net/sched/act_skbmod.c
new file mode 100644
index 0000000..b8e88091
--- /dev/null
+++ b/net/sched/act_skbmod.c
@@ -0,0 +1,245 @@
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
+		ether_addr_copy(eth_hdr(skb)->h_dest, d->eth_dst);
+	if (d->flags & SKBMOD_F_SMAC)
+		ether_addr_copy(eth_hdr(skb)->h_source, d->eth_src);
+	if (d->flags & SKBMOD_F_ETYPE)
+		eth_hdr(skb)->h_proto = d->eth_type;
+
+	spin_unlock(&d->tcf_lock);
+	return d->tcf_action;
+}
+
+static const struct nla_policy skbmod_policy[TCA_SKBMOD_MAX + 1] = {
+	[TCA_SKBMOD_PARMS]		= { .len = sizeof(struct tc_skbmod) },
+	[TCA_SKBMOD_DMAC]		= { .len = ETH_ALEN },
+	[TCA_SKBMOD_SMAC]		= { .len = ETH_ALEN },
+	[TCA_SKBMOD_ETYPE]		= { .type = NLA_U16 },
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
+	u32 flags = 0;
+	u8 *daddr = NULL;
+	u8 *saddr = NULL;
+	u16 eth_type = 0;
+
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
+	/*Allow zero valued mac */
+	if (tb[TCA_SKBMOD_DMAC]) {
+		daddr = nla_data(tb[TCA_SKBMOD_DMAC]);
+		flags |= SKBMOD_F_DMAC;
+	}
+
+	if (tb[TCA_SKBMOD_SMAC]) {
+		saddr = nla_data(tb[TCA_SKBMOD_SMAC]);
+		flags |= SKBMOD_F_SMAC;
+	}
+
+	if (tb[TCA_SKBMOD_ETYPE]) {
+		eth_type = nla_get_u16(tb[TCA_SKBMOD_ETYPE]);
+		flags |= SKBMOD_F_ETYPE;
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
+		ether_addr_copy(d->eth_dst, daddr);
+	if (flags & SKBMOD_F_SMAC)
+		ether_addr_copy(d->eth_src, saddr);
+	if (flags & SKBMOD_F_ETYPE)
+		d->eth_type = htons(eth_type);
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
+	    nla_put(skb, TCA_SKBMOD_DMAC, ETH_ALEN, d->eth_dst))
+		goto nla_put_failure;
+	if ((d->flags & SKBMOD_F_SMAC) &&
+	    nla_put(skb, TCA_SKBMOD_SMAC, ETH_ALEN, d->eth_src))
+		goto nla_put_failure;
+	if ((d->flags & SKBMOD_F_ETYPE) &&
+	    nla_put_u16(skb, TCA_SKBMOD_ETYPE, ntohs(d->eth_type)))
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
+MODULE_DESCRIPTION("SKB data mod-ing");
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
