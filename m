From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/8] Introduce sample tc action
Date: Thu, 10 Nov 2016 12:23:05 +0100
Message-ID: <1478776988-5400-6-git-send-email-jiri@resnulli.us>
References: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36677 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755209AbcKJLXT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 06:23:19 -0500
Received: by mail-wm0-f65.google.com with SMTP id m203so806762wma.3
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 03:23:18 -0800 (PST)
In-Reply-To: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

This action allow the user to sample traffic matched by tc classifier.
The sampling consists of choosing packets randomly, truncating them,
adding some informative metadata regarding the interface and the original
packet size and mark them with specific mark, to allow further tc rules to
match and process. The marked sample packets are then injected into the
device ingress qdisc using netif_receive_skb.

The packets metadata is packed using the ife encapsulation protocol, and
the outer packet's ethernet dest, source and eth_type, along with the
rate, mark and the optional truncation size can be configured from
userspace.

Example:
To sample ingress traffic from interface eth1, and redirect the sampled
the sampled packets to interface dummy0, one may use the commands:

tc qdisc add dev eth1 handle ffff: ingress

tc filter add dev eth1 parent ffff: \
	   matchall action sample rate 12 mark 17

tc filter add parent ffff: dev eth1 protocol all \
	   u32 match mark 17 0xff \
	   action mirred egress redirect dev dummy0

Where the first command adds an ingress qdisc and the second starts
sampling every 12'th packet on dev eth1 and marks the sampled packets with
17. The third command catches the sampled packets, which are marked with
17, and redirects them to dev dummy0.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/tc_act/tc_sample.h        |  65 ++++++++
 include/uapi/linux/tc_act/Kbuild      |   1 +
 include/uapi/linux/tc_act/tc_sample.h |  29 ++++
 net/sched/Kconfig                     |  13 ++
 net/sched/Makefile                    |   1 +
 net/sched/act_sample.c                | 283 ++++++++++++++++++++++++++++++++++
 6 files changed, 392 insertions(+)
 create mode 100644 include/net/tc_act/tc_sample.h
 create mode 100644 include/uapi/linux/tc_act/tc_sample.h
 create mode 100644 net/sched/act_sample.c

diff --git a/include/net/tc_act/tc_sample.h b/include/net/tc_act/tc_sample.h
new file mode 100644
index 0000000..73154b3
--- /dev/null
+++ b/include/net/tc_act/tc_sample.h
@@ -0,0 +1,65 @@
+#ifndef __NET_TC_SAMPLE_H
+#define __NET_TC_SAMPLE_H
+
+#include <net/act_api.h>
+#include <linux/tc_act/tc_sample.h>
+
+struct tcf_sample {
+	struct tc_action	common;
+	u32			rate;
+	u32			mark;
+	bool			truncate;
+	u32			trunc_size;
+	u32			packet_counter;
+	u8			eth_dst[ETH_ALEN];
+	u8			eth_src[ETH_ALEN];
+	u16			eth_type;
+	struct list_head	tcfm_list;
+};
+#define to_sample(a) ((struct tcf_sample *)a)
+
+static inline bool is_tcf_sample(const struct tc_action *a)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	return a->ops && a->ops->type == TCA_ACT_SAMPLE;
+#else
+	return false;
+#endif
+}
+
+static inline __u32 tcf_sample_mark(const struct tc_action *a)
+{
+	return to_sample(a)->mark;
+}
+
+static inline __u32 tcf_sample_rate(const struct tc_action *a)
+{
+	return to_sample(a)->rate;
+}
+
+static inline bool tcf_sample_truncate(const struct tc_action *a)
+{
+	return to_sample(a)->truncate;
+}
+
+static inline int tcf_sample_trunc_size(const struct tc_action *a)
+{
+	return to_sample(a)->trunc_size;
+}
+
+static inline u16 tcf_sample_eth_type(const struct tc_action *a)
+{
+	return to_sample(a)->eth_type;
+}
+
+static inline void tcf_sample_eth_dst_addr(const struct tc_action *a, u8 *dst)
+{
+	ether_addr_copy(dst, to_sample(a)->eth_dst);
+}
+
+static inline void tcf_sample_eth_src_addr(const struct tc_action *a, u8 *src)
+{
+	ether_addr_copy(src, to_sample(a)->eth_src);
+}
+
+#endif /* __NET_TC_SAMPLE_H */
diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
index e3969bd..6c6b8d6 100644
--- a/include/uapi/linux/tc_act/Kbuild
+++ b/include/uapi/linux/tc_act/Kbuild
@@ -4,6 +4,7 @@ header-y += tc_defact.h
 header-y += tc_gact.h
 header-y += tc_ipt.h
 header-y += tc_mirred.h
+header-y += tc_sample.h
 header-y += tc_nat.h
 header-y += tc_pedit.h
 header-y += tc_skbedit.h
diff --git a/include/uapi/linux/tc_act/tc_sample.h b/include/uapi/linux/tc_act/tc_sample.h
new file mode 100644
index 0000000..44ee9d0
--- /dev/null
+++ b/include/uapi/linux/tc_act/tc_sample.h
@@ -0,0 +1,29 @@
+#ifndef __LINUX_TC_SAMPLE_H
+#define __LINUX_TC_SAMPLE_H
+
+#include <linux/types.h>
+#include <linux/pkt_cls.h>
+#include <linux/if_ether.h>
+
+#define TCA_ACT_SAMPLE 26
+
+struct tc_sample {
+	tc_gen;
+};
+
+enum {
+	TCA_SAMPLE_UNSPEC,
+	TCA_SAMPLE_PARMS,
+	TCA_SAMPLE_TM,
+	TCA_SAMPLE_RATE,
+	TCA_SAMPLE_MARK,
+	TCA_SAMPLE_TRUNC_SIZE,
+	TCA_SAMPLE_ETH_DST,
+	TCA_SAMPLE_ETH_SRC,
+	TCA_SAMPLE_ETH_TYPE,
+	TCA_SAMPLE_PAD,
+	__TCA_SAMPLE_MAX
+};
+#define TCA_SAMPLE_MAX (__TCA_SAMPLE_MAX - 1)
+
+#endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 24f7cac..c54ea6b 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -650,6 +650,19 @@ config NET_ACT_MIRRED
 	  To compile this code as a module, choose M here: the
 	  module will be called act_mirred.
 
+config NET_ACT_SAMPLE
+        tristate "Traffic Sampling"
+        depends on NET_CLS_ACT
+        select NET_IFE
+        ---help---
+	  Say Y here to allow packet sampling tc action. The packet sample
+	  action consists of statistically duplicating packets, truncating them
+	  and adding descriptive metadata to them. The duplicated packets are
+	  then marked to allow further processing using tc.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called act_sample.
+
 config NET_ACT_IPT
         tristate "IPtables targets"
         depends on NET_CLS_ACT && NETFILTER && IP_NF_IPTABLES
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 4bdda36..7b915d2 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_NET_CLS_ACT)	+= act_api.o
 obj-$(CONFIG_NET_ACT_POLICE)	+= act_police.o
 obj-$(CONFIG_NET_ACT_GACT)	+= act_gact.o
 obj-$(CONFIG_NET_ACT_MIRRED)	+= act_mirred.o
+obj-$(CONFIG_NET_ACT_SAMPLE)	+= act_sample.o
 obj-$(CONFIG_NET_ACT_IPT)	+= act_ipt.o
 obj-$(CONFIG_NET_ACT_NAT)	+= act_nat.o
 obj-$(CONFIG_NET_ACT_PEDIT)	+= act_pedit.o
diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
new file mode 100644
index 0000000..6596f4b
--- /dev/null
+++ b/net/sched/act_sample.c
@@ -0,0 +1,283 @@
+/*
+ * net/sched/act_sample.c - Packet samplig tc action
+ * Copyright (c) 2016 Yotam Gigi <yotamg@mellanox.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
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
+#include <linux/gfp.h>
+#include <net/net_namespace.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+#include <linux/tc_act/tc_sample.h>
+#include <net/tc_act/tc_sample.h>
+#include <net/ife.h>
+
+#include <linux/if_arp.h>
+
+#define SAMPLE_TAB_MASK     7
+static int sample_net_id;
+static struct tc_action_ops act_sample_ops;
+
+static const struct nla_policy sample_policy[TCA_SAMPLE_MAX + 1] = {
+	[TCA_SAMPLE_PARMS]	= { .len = sizeof(struct tc_sample) },
+};
+
+static int tcf_sample_init(struct net *net, struct nlattr *nla,
+			   struct nlattr *est, struct tc_action **a, int ovr,
+			   int bind)
+{
+	struct tc_action_net *tn = net_generic(net, sample_net_id);
+	struct nlattr *tb[TCA_SAMPLE_MAX + 1];
+	struct tc_sample *parm;
+	struct tcf_sample *s;
+	int ret;
+	bool exists = false;
+
+	if (!nla)
+		return -EINVAL;
+	ret = nla_parse_nested(tb, TCA_SAMPLE_MAX, nla, sample_policy);
+	if (ret < 0)
+		return ret;
+	if (!tb[TCA_SAMPLE_PARMS] || !tb[TCA_SAMPLE_RATE] ||
+	    !tb[TCA_SAMPLE_MARK] || !tb[TCA_SAMPLE_ETH_TYPE])
+		return -EINVAL;
+
+	parm = nla_data(tb[TCA_SAMPLE_PARMS]);
+
+	exists = tcf_hash_check(tn, parm->index, a, bind);
+	if (exists && bind)
+		return 0;
+
+	if (!exists) {
+		ret = tcf_hash_create(tn, parm->index, est, a,
+				      &act_sample_ops, bind, false);
+		if (ret)
+			return ret;
+		ret = ACT_P_CREATED;
+	} else {
+		tcf_hash_release(*a, bind);
+		if (!ovr)
+			return -EEXIST;
+	}
+	s = to_sample(*a);
+
+	ASSERT_RTNL();
+	s->tcf_action = parm->action;
+	s->rate = nla_get_u32(tb[TCA_SAMPLE_RATE]);
+	s->mark = nla_get_u32(tb[TCA_SAMPLE_MARK]);
+	s->eth_type = nla_get_u16(tb[TCA_SAMPLE_ETH_TYPE]);
+
+	s->truncate = tb[TCA_SAMPLE_TRUNC_SIZE];
+	if (tb[TCA_SAMPLE_TRUNC_SIZE])
+		s->trunc_size = nla_get_u32(tb[TCA_SAMPLE_TRUNC_SIZE]);
+
+	s->packet_counter = 0;
+
+	if (tb[TCA_SAMPLE_ETH_SRC])
+		ether_addr_copy(s->eth_src, nla_data(tb[TCA_SAMPLE_ETH_SRC]));
+	else
+		eth_zero_addr(s->eth_src);
+	if (tb[TCA_SAMPLE_ETH_DST])
+		ether_addr_copy(s->eth_dst, nla_data(tb[TCA_SAMPLE_ETH_DST]));
+	else
+		eth_zero_addr(s->eth_dst);
+
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(tn, *a);
+	return ret;
+}
+
+static bool dev_ok_push(struct net_device *dev)
+{
+	switch (dev->type) {
+	case ARPHRD_TUNNEL:
+	case ARPHRD_TUNNEL6:
+	case ARPHRD_SIT:
+	case ARPHRD_IPGRE:
+	case ARPHRD_VOID:
+	case ARPHRD_NONE:
+		return false;
+	default:
+		return true;
+	}
+}
+
+static int tcf_sample(struct sk_buff *skb, const struct tc_action *a,
+		      struct tcf_result *res)
+{
+	struct tcf_sample *s = to_sample(a);
+	static struct ethhdr *ethhdr;
+	struct sk_buff *skb2;
+	int orig_size;
+	int retval;
+	u32 at;
+
+	tcf_lastuse_update(&s->tcf_tm);
+	bstats_cpu_update(this_cpu_ptr(s->common.cpu_bstats), skb);
+
+	rcu_read_lock();
+	retval = READ_ONCE(s->tcf_action);
+
+	if (++s->packet_counter % s->rate == 0) {
+		skb2 = skb_copy(skb, GFP_ATOMIC);
+		if (!skb2)
+			goto out;
+
+		if (s->truncate)
+			skb_trim(skb2, s->trunc_size);
+
+		at = G_TC_AT(skb->tc_verd);
+		skb2->mac_len = skb->mac_len;
+
+		/* on ingress, the mac header gets poped, so push it back */
+		if (!(at & AT_EGRESS) && dev_ok_push(skb->dev))
+			skb_push(skb2, skb2->mac_len);
+
+		orig_size = skb->len + skb->dev->hard_header_len;
+		ethhdr = ife_packet_info_pack(skb2, orig_size,
+					      skb->dev->ifindex, 0);
+		if (!ethhdr)
+			goto out;
+
+		ethhdr->h_proto = htons(s->eth_type);
+		if (!is_zero_ether_addr(s->eth_src))
+			ether_addr_copy(ethhdr->h_source, s->eth_src);
+		if (!is_zero_ether_addr(s->eth_dst))
+			ether_addr_copy(ethhdr->h_dest, s->eth_dst);
+
+		skb2->mark = s->mark;
+		netif_receive_skb(skb2);
+
+		/* mirror is always swallowed */
+		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
+	}
+out:
+	rcu_read_unlock();
+
+	return retval;
+}
+
+static int tcf_sample_dump(struct sk_buff *skb, struct tc_action *a,
+			   int bind, int ref)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tcf_sample *s = to_sample(a);
+	struct tc_sample opt = {
+		.index      = s->tcf_index,
+		.action     = s->tcf_action,
+		.refcnt     = s->tcf_refcnt - ref,
+		.bindcnt    = s->tcf_bindcnt - bind,
+	};
+	struct tcf_t t;
+
+	if (nla_put(skb, TCA_SAMPLE_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
+
+	tcf_tm_dump(&t, &s->tcf_tm);
+	if (nla_put_64bit(skb, TCA_SAMPLE_TM, sizeof(t), &t, TCA_SAMPLE_PAD))
+		goto nla_put_failure;
+
+	if (nla_put_u32(skb, TCA_SAMPLE_RATE, s->rate))
+		goto nla_put_failure;
+
+	if (nla_put_u32(skb, TCA_SAMPLE_MARK, s->mark))
+		goto nla_put_failure;
+
+	if (nla_put_u32(skb, TCA_SAMPLE_ETH_TYPE, s->eth_type))
+		goto nla_put_failure;
+
+	if (s->truncate)
+		if (nla_put_u32(skb, TCA_SAMPLE_TRUNC_SIZE, s->trunc_size))
+			goto nla_put_failure;
+
+	if (!is_zero_ether_addr(s->eth_src))
+		if (nla_put(skb, TCA_SAMPLE_ETH_SRC, ETH_ALEN, s->eth_src))
+			goto nla_put_failure;
+
+	if (!is_zero_ether_addr(s->eth_dst))
+		if (nla_put(skb, TCA_SAMPLE_ETH_DST, ETH_ALEN, s->eth_dst))
+			goto nla_put_failure;
+
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static int tcf_sample_walker(struct net *net, struct sk_buff *skb,
+			     struct netlink_callback *cb, int type,
+			     const struct tc_action_ops *ops)
+{
+	struct tc_action_net *tn = net_generic(net, sample_net_id);
+
+	return tcf_generic_walker(tn, skb, cb, type, ops);
+}
+
+static int tcf_sample_search(struct net *net, struct tc_action **a, u32 index)
+{
+	struct tc_action_net *tn = net_generic(net, sample_net_id);
+
+	return tcf_hash_search(tn, a, index);
+}
+
+static struct tc_action_ops act_sample_ops = {
+	.kind	= "sample",
+	.type	= TCA_ACT_SAMPLE,
+	.owner	= THIS_MODULE,
+	.act	= tcf_sample,
+	.dump	= tcf_sample_dump,
+	.init	= tcf_sample_init,
+	.walk	= tcf_sample_walker,
+	.lookup	= tcf_sample_search,
+	.size	= sizeof(struct tcf_sample),
+};
+
+static __net_init int sample_init_net(struct net *net)
+{
+	struct tc_action_net *tn = net_generic(net, sample_net_id);
+
+	return tc_action_net_init(tn, &act_sample_ops, SAMPLE_TAB_MASK);
+}
+
+static void __net_exit sample_exit_net(struct net *net)
+{
+	struct tc_action_net *tn = net_generic(net, sample_net_id);
+
+	tc_action_net_exit(tn);
+}
+
+static struct pernet_operations sample_net_ops = {
+	.init = sample_init_net,
+	.exit = sample_exit_net,
+	.id   = &sample_net_id,
+	.size = sizeof(struct tc_action_net),
+};
+
+static int __init sample_init_module(void)
+{
+	return tcf_register_action(&act_sample_ops, &sample_net_ops);
+}
+
+static void __exit sample_cleanup_module(void)
+{
+	tcf_unregister_action(&act_sample_ops, &sample_net_ops);
+}
+
+module_init(sample_init_module);
+module_exit(sample_cleanup_module);
+
+MODULE_AUTHOR("Yotam Gigi <yotamg@mellanox.com>");
+MODULE_DESCRIPTION("Packet sampling action");
+MODULE_LICENSE("GPL v2");
-- 
2.7.4
