From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC] tc: introduce OpenFlow classifier
Date: Thu, 22 Jan 2015 14:37:04 +0100
Message-ID: <1421933824-17916-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:62075 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbbAVNhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 08:37:10 -0500
Received: by mail-wi0-f175.google.com with SMTP id fb4so35573672wid.2
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 05:37:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces OpenFlow-based filter. So far, the very essential
packet fields are supported (according to OpenFlow v1.4 spec).

Known issues: skb_flow_dissect hashes out ipv6 addresses. That needs
to be changed to store them somewhere so they can be used later on.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/uapi/linux/pkt_cls.h |  33 +++
 net/sched/Kconfig            |  11 +
 net/sched/Makefile           |   1 +
 net/sched/cls_openflow.c     | 514 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 559 insertions(+)
 create mode 100644 net/sched/cls_openflow.c

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 25731df..d4cef16 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -402,6 +402,39 @@ enum {
 
 #define TCA_BPF_MAX (__TCA_BPF_MAX - 1)
 
+/* OpenFlow classifier */
+
+enum {
+	TCA_OF_UNSPEC,
+	TCA_OF_CLASSID,
+	TCA_OF_POLICE,
+	TCA_OF_INDEV,
+	TCA_OF_ACT,
+	TCA_OF_KEY_ETH_DST,		/* ETH_ALEN */
+	TCA_OF_KEY_ETH_DST_MASK,	/* ETH_ALEN */
+	TCA_OF_KEY_ETH_SRC,		/* ETH_ALEN */
+	TCA_OF_KEY_ETH_SRC_MASK,	/* ETH_ALEN */
+	TCA_OF_KEY_ETH_TYPE,		/* be16 */
+	TCA_OF_KEY_ETH_TYPE_MASK,	/* be16 */
+	TCA_OF_KEY_IP_PROTO,		/* u8 */
+	TCA_OF_KEY_IP_PROTO_MASK,	/* u8 */
+	TCA_OF_KEY_IPV4_SRC,		/* be32 */
+	TCA_OF_KEY_IPV4_SRC_MASK,	/* be32 */
+	TCA_OF_KEY_IPV4_DST,		/* be32 */
+	TCA_OF_KEY_IPV4_DST_MASK,	/* be32 */
+	TCA_OF_KEY_IPV6_SRC,		/* struct in6_addr */
+	TCA_OF_KEY_IPV6_SRC_MASK,	/* struct in6_addr */
+	TCA_OF_KEY_IPV6_DST,		/* struct in6_addr */
+	TCA_OF_KEY_IPV6_DST_MASK,	/* struct in6_addr */
+	TCA_OF_KEY_TP_SRC,		/* be16 */
+	TCA_OF_KEY_TP_SRC_MASK,		/* be16 */
+	TCA_OF_KEY_TP_DST,		/* be16 */
+	TCA_OF_KEY_TP_DST_MASK,		/* be16 */
+	__TCA_OF_MAX,
+};
+
+#define TCA_OF_MAX (__TCA_OF_MAX - 1)
+
 /* Extended Matches */
 
 struct tcf_ematch_tree_hdr {
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 475e35e..9b01fae 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -477,6 +477,17 @@ config NET_CLS_BPF
 	  To compile this code as a module, choose M here: the module will
 	  be called cls_bpf.
 
+config NET_CLS_OPENFLOW
+	tristate "OpenFlow classifier"
+	select NET_CLS
+	---help---
+	  If you say Y here, you will be able to classify packets based on
+	  a configurable combination of packet keys and masks accordint to
+	  OpenFlow standard.
+
+	  To compile this code as a module, choose M here: the module will
+	  be called cls_openflow.
+
 config NET_EMATCH
 	bool "Extended Matches"
 	select NET_CLS
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 7ca7f4c..5faa9ca 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -56,6 +56,7 @@ obj-$(CONFIG_NET_CLS_BASIC)	+= cls_basic.o
 obj-$(CONFIG_NET_CLS_FLOW)	+= cls_flow.o
 obj-$(CONFIG_NET_CLS_CGROUP)	+= cls_cgroup.o
 obj-$(CONFIG_NET_CLS_BPF)	+= cls_bpf.o
+obj-$(CONFIG_NET_CLS_OPENFLOW)	+= cls_openflow.o
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
 obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
 obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
diff --git a/net/sched/cls_openflow.c b/net/sched/cls_openflow.c
new file mode 100644
index 0000000..1c261fa
--- /dev/null
+++ b/net/sched/cls_openflow.c
@@ -0,0 +1,514 @@
+/*
+ * net/sched/cls_openflow.c		OpenFlow classifier
+ *
+ * Copyright (c) 2015 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+
+#include <linux/if_ether.h>
+#include <linux/in6.h>
+
+#include <net/sch_generic.h>
+#include <net/pkt_cls.h>
+
+struct of_flow_key {
+	int	indev_ifindex;
+	struct {
+		u8	src[ETH_ALEN];
+		u8	dst[ETH_ALEN];
+		__be16	type;
+	} eth;
+	struct {
+		u8	proto;
+	} ip;
+	union {
+		struct {
+			__be32 src;
+			__be32 dst;
+		} ipv4;
+		struct {
+			struct in6_addr src;
+			struct in6_addr dst;
+		} ipv6;
+	};
+	union {
+		struct {
+			__be16 src;
+			__be16 dst;
+		} tp;
+	};
+} __aligned(BITS_PER_LONG / 8); /* Ensure that we can do comparisons as longs. */
+
+struct of_flow_match {
+	struct of_flow_key key;
+	struct of_flow_key mask;
+};
+
+struct cls_of_head {
+	struct list_head filters;
+	u32 hgen;
+	struct rcu_head rcu;
+};
+
+struct cls_of_filter {
+	struct list_head list;
+	u32 handle;
+	struct tcf_exts exts;
+	struct tcf_result res;
+	struct tcf_proto *tp;
+	struct of_flow_match match;
+	struct rcu_head	rcu;
+};
+
+static void of_extract_key(struct sk_buff *skb, struct of_flow_key *skb_key)
+{
+	struct flow_keys flow_keys;
+	struct ethhdr *eth;
+
+	skb_key->indev_ifindex = skb->skb_iif;
+
+	eth = eth_hdr(skb);
+	ether_addr_copy(skb_key->eth.src, eth->h_source);
+	ether_addr_copy(skb_key->eth.dst, eth->h_dest);
+
+	skb_flow_dissect(skb, &flow_keys);
+	skb_key->eth.type = flow_keys.n_proto;
+	skb_key->ip.proto = flow_keys.ip_proto;
+	skb_key->ipv4.src = flow_keys.src;
+	skb_key->ipv4.dst = flow_keys.dst;
+	skb_key->tp.src = flow_keys.port16[0];
+	skb_key->tp.dst = flow_keys.port16[1];
+}
+
+static bool of_match(struct of_flow_key *skb_key, struct cls_of_filter *f)
+{
+	const long *lkey = (const long *) &f->match.key;
+	const long *lmask = (const long *) &f->match.mask;
+	const long *lskb_key = (const long *) skb_key;
+	int i;
+
+	for (i = 0; i < sizeof(struct of_flow_key); i += sizeof(const long)) {
+		if ((*lkey++ & *lmask) != (*lskb_key++ & *lmask))
+			return false;
+		lmask++;
+	}
+	return true;
+}
+
+static int of_classify(struct sk_buff *skb, const struct tcf_proto *tp,
+		       struct tcf_result *res)
+{
+	struct cls_of_head *head = rcu_dereference_bh(tp->root);
+	struct cls_of_filter *f;
+	struct of_flow_key skb_key;
+	int ret;
+
+	of_extract_key(skb, &skb_key);
+
+	list_for_each_entry_rcu(f, &head->filters, list) {
+		if (!of_match(&skb_key, f))
+			continue;
+
+		*res = f->res;
+
+		ret = tcf_exts_exec(skb, &f->exts, res);
+		if (ret < 0)
+			continue;
+
+		return ret;
+	}
+	return -1;
+}
+
+static int of_init(struct tcf_proto *tp)
+{
+	struct cls_of_head *head;
+
+	head = kzalloc(sizeof(*head), GFP_KERNEL);
+	if (!head)
+		return -ENOBUFS;
+
+	INIT_LIST_HEAD_RCU(&head->filters);
+	rcu_assign_pointer(tp->root, head);
+
+	return 0;
+}
+
+static void of_destroy_filter(struct rcu_head *head)
+{
+	struct cls_of_filter *f = container_of(head, struct cls_of_filter, rcu);
+
+	tcf_exts_destroy(&f->exts);
+	kfree(f);
+}
+
+static void of_destroy(struct tcf_proto *tp)
+{
+	struct cls_of_head *head = rtnl_dereference(tp->root);
+	struct cls_of_filter *f, *next;
+
+	list_for_each_entry_safe(f, next, &head->filters, list) {
+		list_del_rcu(&f->list);
+		call_rcu(&f->rcu, of_destroy_filter);
+	}
+	RCU_INIT_POINTER(tp->root, NULL);
+	kfree_rcu(head, rcu);
+}
+
+static unsigned long of_get(struct tcf_proto *tp, u32 handle)
+{
+	struct cls_of_head *head = rtnl_dereference(tp->root);
+	struct cls_of_filter *f;
+
+	list_for_each_entry(f, &head->filters, list)
+		if (f->handle == handle)
+			return (unsigned long) f;
+	return 0;
+}
+
+static const struct nla_policy of_policy[TCA_OF_MAX + 1] = {
+	[TCA_OF_UNSPEC]			= { .type = NLA_UNSPEC },
+	[TCA_OF_CLASSID]		= { .type = NLA_U32 },
+	[TCA_OF_INDEV]			= { .type = NLA_STRING,
+					    .len = IFNAMSIZ },
+	[TCA_OF_KEY_ETH_DST]		= { .len = ETH_ALEN },
+	[TCA_OF_KEY_ETH_DST_MASK]	= { .len = ETH_ALEN },
+	[TCA_OF_KEY_ETH_SRC]		= { .len = ETH_ALEN },
+	[TCA_OF_KEY_ETH_SRC_MASK]	= { .len = ETH_ALEN },
+	[TCA_OF_KEY_ETH_TYPE]		= { .type = NLA_U16 },
+	[TCA_OF_KEY_ETH_TYPE_MASK]	= { .type = NLA_U16 },
+	[TCA_OF_KEY_IP_PROTO]		= { .type = NLA_U8 },
+	[TCA_OF_KEY_IP_PROTO_MASK]	= { .type = NLA_U8 },
+	[TCA_OF_KEY_IPV4_SRC]		= { .type = NLA_U32 },
+	[TCA_OF_KEY_IPV4_SRC_MASK]	= { .type = NLA_U32 },
+	[TCA_OF_KEY_IPV4_DST]		= { .type = NLA_U32 },
+	[TCA_OF_KEY_IPV4_DST_MASK]	= { .type = NLA_U32 },
+	[TCA_OF_KEY_IPV6_SRC]		= { .len = sizeof(struct in6_addr) },
+	[TCA_OF_KEY_IPV6_SRC_MASK]	= { .len = sizeof(struct in6_addr) },
+	[TCA_OF_KEY_IPV6_DST]		= { .len = sizeof(struct in6_addr) },
+	[TCA_OF_KEY_IPV6_DST_MASK]	= { .len = sizeof(struct in6_addr) },
+	[TCA_OF_KEY_TP_SRC]		= { .type = NLA_U16 },
+	[TCA_OF_KEY_TP_SRC_MASK]	= { .type = NLA_U16 },
+	[TCA_OF_KEY_TP_DST]		= { .type = NLA_U16 },
+	[TCA_OF_KEY_TP_DST_MASK]	= { .type = NLA_U16 },
+};
+
+static void of_set_key_val(struct nlattr **tb,
+			   void *val, int val_type,
+			   void *mask, int mask_type, int len)
+{
+	if (!tb[val_type])
+		return;
+	memcpy(val, nla_data(tb[val_type]), len);
+	if (!tb[mask_type])
+		memset(mask, 0xff, len);
+	else
+		memcpy(mask, nla_data(tb[mask_type]), len);
+}
+
+static int of_set_parms(struct net *net, struct tcf_proto *tp,
+			struct cls_of_filter *f, unsigned long base,
+			struct nlattr **tb, struct nlattr *est, bool ovr)
+{
+	struct tcf_exts e;
+	struct of_flow_key *key, *mask;
+	int err;
+
+	tcf_exts_init(&e, TCA_OF_ACT, TCA_OF_POLICE);
+	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_OF_CLASSID]) {
+		f->res.classid = nla_get_u32(tb[TCA_OF_CLASSID]);
+		tcf_bind_filter(tp, &f->res, base);
+	}
+
+	key = &f->match.key;
+	mask = &f->match.mask;
+
+	if (tb[TCA_OF_INDEV]) {
+		err = tcf_change_indev(net, tb[TCA_OF_INDEV]);
+		if (err < 0)
+			goto errout;
+		key->indev_ifindex = err;
+		mask->indev_ifindex = 0xffffffff;
+	}
+
+	of_set_key_val(tb, key->eth.dst, TCA_OF_KEY_ETH_DST,
+		       mask->eth.dst, TCA_OF_KEY_ETH_DST_MASK,
+		       sizeof(key->eth.dst));
+	of_set_key_val(tb, key->eth.src, TCA_OF_KEY_ETH_SRC,
+		       mask->eth.src, TCA_OF_KEY_ETH_SRC_MASK,
+		       sizeof(key->eth.src));
+	of_set_key_val(tb, &key->eth.type, TCA_OF_KEY_ETH_TYPE,
+		       &mask->eth.type, TCA_OF_KEY_ETH_TYPE_MASK,
+		       sizeof(key->eth.type));
+	of_set_key_val(tb, &key->ip.proto, TCA_OF_KEY_IP_PROTO,
+		       &mask->ip.proto, TCA_OF_KEY_IP_PROTO_MASK,
+		       sizeof(key->ip.proto));
+	of_set_key_val(tb, &key->ipv4.src, TCA_OF_KEY_IPV4_SRC,
+		       &mask->ipv4.src, TCA_OF_KEY_IPV4_SRC_MASK,
+		       sizeof(key->ipv4.src));
+	of_set_key_val(tb, &key->ipv4.dst, TCA_OF_KEY_IPV4_DST,
+		       &mask->ipv4.dst, TCA_OF_KEY_IPV4_DST_MASK,
+		       sizeof(key->ipv4.dst));
+	of_set_key_val(tb, &key->ipv6.src, TCA_OF_KEY_IPV6_SRC,
+		       &mask->ipv6.src, TCA_OF_KEY_IPV6_SRC_MASK,
+		       sizeof(key->ipv6.src));
+	of_set_key_val(tb, &key->ipv6.dst, TCA_OF_KEY_IPV6_DST,
+		       &mask->ipv6.dst, TCA_OF_KEY_IPV6_DST_MASK,
+		       sizeof(key->ipv6.dst));
+	of_set_key_val(tb, &key->tp.src, TCA_OF_KEY_TP_SRC,
+		       &mask->tp.src, TCA_OF_KEY_TP_SRC_MASK,
+		       sizeof(key->tp.src));
+	of_set_key_val(tb, &key->tp.dst, TCA_OF_KEY_TP_DST,
+		       &mask->tp.dst, TCA_OF_KEY_TP_SRC_MASK,
+		       sizeof(key->tp.dst));
+
+	tcf_exts_change(tp, &f->exts, &e);
+	f->tp = tp;
+
+	return 0;
+errout:
+	tcf_exts_destroy(&e);
+	return err;
+}
+
+static u32 of_grab_new_handle(struct tcf_proto *tp,
+			      struct cls_of_head *head)
+{
+	unsigned int i = 0x80000000;
+	u32 handle;
+
+	do {
+		if (++head->hgen == 0x7FFFFFFF)
+			head->hgen = 1;
+	} while (--i > 0 && of_get(tp, head->hgen));
+
+	if (unlikely(i == 0)) {
+		pr_err("Insufficient number of handles\n");
+		handle = 0;
+	} else {
+		handle = head->hgen;
+	}
+
+	return handle;
+}
+
+static int of_change(struct net *net, struct sk_buff *in_skb,
+		     struct tcf_proto *tp, unsigned long base,
+		     u32 handle, struct nlattr **tca,
+		     unsigned long *arg, bool ovr)
+{
+	struct cls_of_head *head = rtnl_dereference(tp->root);
+	struct cls_of_filter *fold = (struct cls_of_filter *) *arg;
+	struct cls_of_filter *fnew;
+	struct nlattr *tb[TCA_OF_MAX + 1];
+	int err;
+
+	if (!tca[TCA_OPTIONS])
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_OF_MAX, tca[TCA_OPTIONS], of_policy);
+	if (err < 0)
+		return err;
+
+	if (fold && handle && fold->handle != handle)
+		return -EINVAL;
+
+	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
+	if (!fnew)
+		return -ENOBUFS;
+
+	tcf_exts_init(&fnew->exts, TCA_OF_ACT, TCA_OF_POLICE);
+
+	if (!handle) {
+		handle = of_grab_new_handle(tp, head);
+		if (!handle) {
+			err = -EINVAL;
+			goto errout;
+		}
+	}
+	fnew->handle = handle;
+
+	err = of_set_parms(net, tp, fnew, base, tb, tca[TCA_RATE], ovr);
+	if (err < 0)
+		goto errout;
+
+	*arg = (unsigned long) fnew;
+
+	if (fold) {
+		list_replace_rcu(&fnew->list, &fold->list);
+		tcf_unbind_filter(tp, &fold->res);
+		call_rcu(&fold->rcu, of_destroy_filter);
+	} else {
+		list_add_tail_rcu(&fnew->list, &head->filters);
+	}
+
+	return 0;
+
+errout:
+	kfree(fnew);
+	return err;
+}
+
+static int of_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	struct cls_of_filter *f = (struct cls_of_filter *) arg;
+
+	list_del_rcu(&f->list);
+	tcf_unbind_filter(tp, &f->res);
+	call_rcu(&f->rcu, of_destroy_filter);
+	return 0;
+}
+
+static void of_walk(struct tcf_proto *tp, struct tcf_walker *arg)
+{
+	struct cls_of_head *head = rtnl_dereference(tp->root);
+	struct cls_of_filter *f;
+
+	list_for_each_entry_rcu(f, &head->filters, list) {
+		if (arg->count < arg->skip)
+			goto skip;
+		if (arg->fn(tp, (unsigned long) f, arg) < 0) {
+			arg->stop = 1;
+			break;
+		}
+skip:
+		arg->count++;
+	}
+}
+
+static int of_dump_key_val(struct sk_buff *skb,
+			   void *val, int val_type,
+			   void *mask, int mask_type, int len)
+{
+	int err;
+
+	if (!memchr_inv(mask, 0, len))
+		return 0;
+	err = nla_put(skb, val_type, len, val);
+	if (err)
+		return err;
+	err = nla_put(skb, mask_type, len, mask);
+	if (err)
+		return err;
+	return 0;
+}
+
+static int of_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+		   struct sk_buff *skb, struct tcmsg *t)
+{
+	struct cls_of_filter *f = (struct cls_of_filter *) fh;
+	struct nlattr *nest;
+	struct of_flow_key *key, *mask;
+
+	if (!f)
+		return skb->len;
+
+	t->tcm_handle = f->handle;
+
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (!nest)
+		goto nla_put_failure;
+
+	if (f->res.classid &&
+	    nla_put_u32(skb, TCA_BASIC_CLASSID, f->res.classid))
+		goto nla_put_failure;
+
+	key = &f->match.key;
+	mask = &f->match.mask;
+
+	if (mask->indev_ifindex) {
+		struct net_device *dev;
+
+		dev = __dev_get_by_index(net, key->indev_ifindex);
+		if (dev && nla_put_string(skb, TCA_OF_INDEV, dev->name))
+			goto nla_put_failure;
+	}
+
+	if (of_dump_key_val(skb, key->eth.dst, TCA_OF_KEY_ETH_DST,
+			    mask->eth.dst, TCA_OF_KEY_ETH_DST_MASK,
+			    sizeof(key->eth.dst)) ||
+	    of_dump_key_val(skb, key->eth.src, TCA_OF_KEY_ETH_SRC,
+			    mask->eth.src, TCA_OF_KEY_ETH_SRC_MASK,
+			    sizeof(key->eth.src)) ||
+	    of_dump_key_val(skb, &key->eth.type, TCA_OF_KEY_ETH_TYPE,
+			    &mask->eth.type, TCA_OF_KEY_ETH_TYPE_MASK,
+			    sizeof(key->eth.type)) ||
+	    of_dump_key_val(skb, &key->ip.proto, TCA_OF_KEY_IP_PROTO,
+			    &mask->ip.proto, TCA_OF_KEY_IP_PROTO_MASK,
+			    sizeof(key->ip.proto)) ||
+	    of_dump_key_val(skb, &key->ipv4.src, TCA_OF_KEY_IPV4_SRC,
+			    &mask->ipv4.src, TCA_OF_KEY_IPV4_SRC_MASK,
+			    sizeof(key->ipv4.src)) ||
+	    of_dump_key_val(skb, &key->ipv4.dst, TCA_OF_KEY_IPV4_DST,
+			    &mask->ipv4.dst, TCA_OF_KEY_IPV4_DST_MASK,
+			    sizeof(key->ipv4.dst)) ||
+	    of_dump_key_val(skb, &key->ipv6.src, TCA_OF_KEY_IPV6_SRC,
+			    &mask->ipv6.src, TCA_OF_KEY_IPV6_SRC_MASK,
+			    sizeof(key->ipv6.src)) ||
+	    of_dump_key_val(skb, &key->ipv6.dst, TCA_OF_KEY_IPV6_DST,
+			    &mask->ipv6.dst, TCA_OF_KEY_IPV6_DST_MASK,
+			    sizeof(key->ipv6.dst)) ||
+	    of_dump_key_val(skb, &key->tp.src, TCA_OF_KEY_TP_SRC,
+			    &mask->tp.src, TCA_OF_KEY_TP_SRC_MASK,
+			    sizeof(key->tp.src)) ||
+	    of_dump_key_val(skb, &key->tp.dst, TCA_OF_KEY_TP_DST,
+			    &mask->tp.dst, TCA_OF_KEY_TP_DST_MASK,
+			    sizeof(key->tp.dst)))
+		goto nla_put_failure;
+
+	if (tcf_exts_dump(skb, &f->exts))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, nest);
+
+	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
+		goto nla_put_failure;
+
+	return skb->len;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nest);
+	return -1;
+}
+
+static struct tcf_proto_ops cls_of_ops __read_mostly = {
+	.kind		= "openflow",
+	.classify	= of_classify,
+	.init		= of_init,
+	.destroy	= of_destroy,
+	.get		= of_get,
+	.change		= of_change,
+	.delete		= of_delete,
+	.walk		= of_walk,
+	.dump		= of_dump,
+	.owner		= THIS_MODULE,
+};
+
+static int __init cls_of_init(void)
+{
+	return register_tcf_proto_ops(&cls_of_ops);
+}
+
+static void __exit cls_of_exit(void)
+{
+	unregister_tcf_proto_ops(&cls_of_ops);
+}
+
+module_init(cls_of_init);
+module_exit(cls_of_exit);
+
+MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
+MODULE_DESCRIPTION("OpenFlow classifier");
+MODULE_LICENSE("GPL v2");
-- 
1.9.3
