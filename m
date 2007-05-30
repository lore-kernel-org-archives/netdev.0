From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 02/02]: Add flow classifier
Date: Wed, 30 May 2007 11:40:58 +0200 (MEST)
Message-ID: <20070530094022.24073.86144.sendpatchset@localhost.localdomain>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, hadi@cyberus.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33832 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbXE3JlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 05:41:00 -0400
In-Reply-To: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Add flow classifier

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit e98a4dd4f6cef4d46f180dee2e91e7f359a854c3
tree f56ea6da8115c5ee9fbc30421f9c4e392a8c55a7
parent 666e402224e5ca36af0b5a07d424b9c092bce91e
author Patrick McHardy <kaber@trash.net> Wed, 30 May 2007 11:22:49 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 30 May 2007 11:22:49 +0200

 include/linux/pkt_cls.h |   37 +++
 net/sched/Kconfig       |   11 +
 net/sched/Makefile      |    1 
 net/sched/cls_flow.c    |  570 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 619 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index c3f01b3..0137591 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -328,6 +328,43 @@ enum
 
 #define TCA_TCINDEX_MAX     (__TCA_TCINDEX_MAX - 1)
 
+/* Flow filter */
+
+enum
+{
+	FLOW_KEY_SRC,
+	FLOW_KEY_DST,
+	FLOW_KEY_PROTO_SRC,
+	FLOW_KEY_PROTO_DST,
+	FLOW_KEY_PRIORITY,
+	FLOW_KEY_MARK,
+	FLOW_KEY_NFCT,
+	FLOW_KEY_NFCT_SRC,
+	FLOW_KEY_NFCT_DST,
+	FLOW_KEY_NFCT_PROTO_SRC,
+	FLOW_KEY_NFCT_PROTO_DST,
+	FLOW_KEY_RTIIF,
+	FLOW_KEY_RTCLASSID,
+	FLOW_KEY_SKUID,
+	FLOW_KEY_SKGID,
+	__FLOW_KEY_MAX,
+};
+
+#define FLOW_KEY_MAX	(__FLOW_KEY_MAX - 1)
+
+enum
+{
+	TCA_FLOW_UNSPEC,
+	TCA_FLOW_KEYS,
+	TCA_FLOW_BASECLASS,
+	TCA_FLOW_CLASSES,
+	TCA_FLOW_ACT,
+	TCA_FLOW_POLICE,
+	__TCA_FLOW_MAX
+};
+
+#define TCA_FLOW_MAX	(__TCA_FLOW_MAX - 1)
+
 /* Basic filter */
 
 enum
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 475df84..6f33a79 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -302,6 +302,17 @@ config NET_CLS_RSVP6
 	  To compile this code as a module, choose M here: the
 	  module will be called cls_rsvp6.
 
+config NET_CLS_FLOW
+	tristate "Flow classifier"
+	select NET_CLS
+	---help---
+	  If you say Y here, you will be able to classify packets based on
+	  a configurable combination of packet keys. This is mostly useful
+	  in combination with SFQ.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called cls_flow.
+
 config NET_EMATCH
 	bool "Extended Matches"
 	select NET_CLS
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 020767a..54ad85a 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -35,6 +35,7 @@ obj-$(CONFIG_NET_CLS_RSVP)	+= cls_rsvp.o
 obj-$(CONFIG_NET_CLS_TCINDEX)	+= cls_tcindex.o
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
 obj-$(CONFIG_NET_CLS_BASIC)	+= cls_basic.o
+obj-$(CONFIG_NET_CLS_FLOW)	+= cls_flow.o
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
 obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
 obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
new file mode 100644
index 0000000..ebb79ea
--- /dev/null
+++ b/net/sched/cls_flow.c
@@ -0,0 +1,570 @@
+/*
+ * net/sched/cls_flow.c		Generic flow classifier
+ *
+ * Copyright (c) 2007 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/jhash.h>
+#include <linux/pkt_cls.h>
+#include <linux/skbuff.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+
+#include <net/pkt_cls.h>
+#include <net/ip.h>
+#include <net/route.h>
+#if defined(CONFIG_NF_CONNTRACK) || defined (CONFIG_NF_CONNTRACK_MODULE)
+#include <net/netfilter/nf_conntrack.h>
+#endif
+
+struct flow_head
+{
+	struct list_head	filters;
+};
+
+struct flow_filter
+{
+	struct list_head	list;
+	struct tcf_exts		exts;
+	u32			handle;
+	u32			nkeys;
+	u32			keymask;
+	u32			baseclass;
+	u16			classes;
+};
+
+static struct tcf_ext_map flow_ext_map = {
+	.action	= TCA_FLOW_ACT,
+	.police	= TCA_FLOW_POLICE,
+};
+
+static inline u32 addr_fold(void *addr)
+{
+	unsigned long a = (unsigned long)addr;
+
+	return (a & 0xFFFFFFFF) ^ (BITS_PER_LONG > 32 ? a >> 32 : 0);
+}
+
+static u32 flow_get_src(const struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		return ip_hdr(skb)->saddr;
+	case __constant_htons(ETH_P_IPV6):
+		return ipv6_hdr(skb)->saddr.s6_addr[3];
+	default:
+		return addr_fold(skb->sk);
+	}
+}
+
+static u32 flow_get_dst(const struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		return ip_hdr(skb)->daddr;
+	case __constant_htons(ETH_P_IPV6):
+		return ipv6_hdr(skb)->daddr.s6_addr[3];
+	default:
+		return addr_fold(skb->dst) ^ skb->protocol;
+	}
+}
+
+static int has_ports(int protocol)
+{
+	switch (protocol) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE:
+	case IPPROTO_SCTP:
+	case IPPROTO_DCCP:
+	case IPPROTO_ESP:
+		return 1;
+	default:
+		return 0;
+	}
+}
+
+static u32 flow_get_proto_src(const struct sk_buff *skb)
+{
+	u32 res;
+
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP): {
+		struct iphdr *iph = ip_hdr(skb);
+
+		res = iph->protocol;
+		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
+		    has_ports(iph->protocol))
+			res ^= *(u16 *)((void *)iph + iph->ihl * 4);
+		break;
+	}
+	case __constant_htons(ETH_P_IPV6): {
+		struct ipv6hdr *iph = ipv6_hdr(skb);
+
+		res = iph->nexthdr;
+		if (has_ports(iph->nexthdr))
+			res ^= *(u16 *)&iph[1];
+		break;
+	}
+	default:
+		res = addr_fold(skb->sk);
+	}
+
+	return res;
+}
+
+static u32 flow_get_proto_dst(const struct sk_buff *skb)
+{
+	u32 res;
+
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP): {
+		struct iphdr *iph = ip_hdr(skb);
+
+		res = iph->protocol;
+		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
+		    has_ports(iph->protocol))
+			res ^= *(u16 *)((void *)iph + iph->ihl * 4 + 2);
+		break;
+	}
+	case __constant_htons(ETH_P_IPV6): {
+		struct ipv6hdr *iph = ipv6_hdr(skb);
+
+		res = iph->nexthdr;
+		if (has_ports(iph->nexthdr))
+			res ^= *(u16 *)((void *)&iph[1] + 2);
+		break;
+	}
+	default:
+		res = addr_fold(skb->dst) ^ skb->protocol;
+	}
+
+	return res;
+}
+
+static u32 flow_get_priority(const struct sk_buff *skb)
+{
+	return skb->priority;
+}
+
+static u32 flow_get_mark(const struct sk_buff *skb)
+{
+	return skb->mark;
+}
+
+static u32 flow_get_nfct(const struct sk_buff *skb)
+{
+#if defined(CONFIG_NF_CONNTRACK) || defined (CONFIG_NF_CONNTRACK_MODULE)
+	return addr_fold(skb->nfct);
+#else
+	return 0;
+#endif
+}
+
+#define CTTUPLE(skb, member)						\
+({									\
+	enum ip_conntrack_info ctinfo;					\
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);			\
+	if (ct == NULL)							\
+		goto fallback;						\
+	ct->tuplehash[CTINFO2DIR(ctinfo)].tuple.member;			\
+})
+
+static u32 flow_get_nfct_src(const struct sk_buff *skb)
+{
+#if defined(CONFIG_NF_CONNTRACK) || defined (CONFIG_NF_CONNTRACK_MODULE)
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		return CTTUPLE(skb, src.u3.ip);
+	case __constant_htons(ETH_P_IPV6):
+		return CTTUPLE(skb, src.u3.ip6[3]);
+	}
+fallback:
+#endif
+	return flow_get_src(skb);
+}
+
+static u32 flow_get_nfct_dst(const struct sk_buff *skb)
+{
+#if defined(CONFIG_NF_CONNTRACK) || defined (CONFIG_NF_CONNTRACK_MODULE)
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		return CTTUPLE(skb, dst.u3.ip);
+	case __constant_htons(ETH_P_IPV6):
+		return CTTUPLE(skb, dst.u3.ip6[3]);
+	}
+fallback:
+#endif
+	return flow_get_dst(skb);
+}
+
+static u32 flow_get_nfct_proto_src(const struct sk_buff *skb)
+{
+#if defined(CONFIG_NF_CONNTRACK) || defined (CONFIG_NF_CONNTRACK_MODULE)
+	return CTTUPLE(skb, src.u.all);
+fallback:
+#endif
+	return flow_get_proto_src(skb);
+}
+
+static u32 flow_get_nfct_proto_dst(const struct sk_buff *skb)
+{
+#if defined(CONFIG_NF_CONNTRACK) || defined (CONFIG_NF_CONNTRACK_MODULE)
+	return CTTUPLE(skb, dst.u.all);
+fallback:
+#endif
+	return flow_get_proto_dst(skb);
+}
+
+static u32 flow_get_rtclassid(const struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_CLS_ROUTE
+	if (skb->dst)
+		return skb->dst->tclassid;
+#endif
+	return 0;
+}
+
+static u32 flow_get_rtiif(const struct sk_buff *skb)
+{
+	if (skb->dst && skb->dst->ops->family == AF_INET)
+		return ((struct rtable *)skb->dst)->fl.iif;
+	return 0;
+}
+
+static u32 flow_get_skuid(const struct sk_buff *skb)
+{
+	if (skb->sk && skb->sk->sk_socket && skb->sk->sk_socket->file)
+		return skb->sk->sk_socket->file->f_uid;
+	return 0;
+}
+
+static u32 flow_get_skgid(const struct sk_buff *skb)
+{
+	if (skb->sk && skb->sk->sk_socket && skb->sk->sk_socket->file)
+		return skb->sk->sk_socket->file->f_gid;
+	return 0;
+}
+
+static u32 flow_key_get(const struct sk_buff *skb, int key)
+{
+	switch (key) {
+	case FLOW_KEY_SRC:
+		return flow_get_src(skb);
+	case FLOW_KEY_DST:
+		return flow_get_dst(skb);
+	case FLOW_KEY_PROTO_SRC:
+		return flow_get_proto_src(skb);
+	case FLOW_KEY_PROTO_DST:
+		return flow_get_proto_dst(skb);
+	case FLOW_KEY_PRIORITY:
+		return flow_get_priority(skb);
+	case FLOW_KEY_MARK:
+		return flow_get_mark(skb);
+	case FLOW_KEY_NFCT:
+		return flow_get_nfct(skb);
+	case FLOW_KEY_NFCT_SRC:
+		return flow_get_nfct_src(skb);
+	case FLOW_KEY_NFCT_DST:
+		return flow_get_nfct_dst(skb);
+	case FLOW_KEY_NFCT_PROTO_SRC:
+		return flow_get_nfct_proto_src(skb);
+	case FLOW_KEY_NFCT_PROTO_DST:
+		return flow_get_nfct_proto_dst(skb);
+	case FLOW_KEY_RTIIF:
+		return flow_get_rtiif(skb);
+	case FLOW_KEY_RTCLASSID:
+		return flow_get_rtclassid(skb);
+	case FLOW_KEY_SKUID:
+		return flow_get_skuid(skb);
+	case FLOW_KEY_SKGID:
+		return flow_get_skgid(skb);
+	default:
+		BUG();
+		return 0;
+	}
+}
+
+static int flow_classify(struct sk_buff *skb, struct tcf_proto *tp,
+			 struct tcf_result *res)
+{
+	struct flow_head *head = tp->root;
+	struct flow_filter *f;
+	u32 keymask;
+	u32 classid;
+	unsigned int n, key;
+	int r;
+
+	list_for_each_entry(f, &head->filters, list) {
+		u32 keys[f->nkeys];
+
+		keymask = f->keymask;
+
+		for (n = 0; n < f->nkeys; n++) {
+			key = ffs(keymask) - 1;
+			keymask &= ~(1 << key);
+			keys[n] = flow_key_get(skb, key);
+		}
+
+		classid = jhash2(keys, f->nkeys, 0);
+		if (f->classes)
+			classid %= f->classes;
+
+		res->class   = 0;
+		res->classid = TC_H_MAKE(f->baseclass, f->baseclass + classid);
+
+		r = tcf_exts_exec(skb, &f->exts, res);
+		if (r < 0)
+			continue;
+		return r;
+	}
+	return -1;
+}
+
+static int flow_change(struct tcf_proto *tp, unsigned long base,
+		       u32 handle, struct rtattr **tca,
+		       unsigned long *arg)
+{
+	struct flow_head *head = tp->root;
+	struct flow_filter *f;
+	struct rtattr *opt = tca[TCA_OPTIONS-1];
+	struct rtattr *tb[TCA_FLOW_MAX];
+	struct tcf_exts e;
+	unsigned int nkeys = 0;
+	u32 baseclass = 0;
+	u32 keymask = 0;
+	int err;
+
+	if (opt == NULL)
+		return -EINVAL;
+
+	err = rtattr_parse_nested(tb, TCA_FLOW_MAX, opt);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_FLOW_BASECLASS-1]) {
+		if (RTA_PAYLOAD(tb[TCA_FLOW_BASECLASS-1]) < sizeof(u32))
+			return -EINVAL;
+		baseclass = *(u32 *)RTA_DATA(tb[TCA_FLOW_BASECLASS-1]);
+		if (TC_H_MIN(baseclass) == 0)
+			return -EINVAL;
+	}
+
+	if (tb[TCA_FLOW_CLASSES-1] &&
+	    RTA_PAYLOAD(tb[TCA_FLOW_CLASSES-1]) < sizeof(u16))
+		return -EINVAL;
+
+	if (tb[TCA_FLOW_KEYS-1]) {
+		if (RTA_PAYLOAD(tb[TCA_FLOW_KEYS-1]) < sizeof(u32))
+			return -EINVAL;
+
+		keymask = *(u32 *)RTA_DATA(tb[TCA_FLOW_KEYS-1]);
+		if (fls(keymask) - 1 > FLOW_KEY_MAX)
+			return -EOPNOTSUPP;
+
+		nkeys = hweight32(keymask);
+		if (nkeys == 0)
+			return -EINVAL;
+	}
+
+	err = tcf_exts_validate(tp, tb, tca[TCA_RATE-1], &e, &flow_ext_map);
+	if (err < 0)
+		return err;
+
+	f = (struct flow_filter *)*arg;
+	if (f != NULL) {
+		err = -EINVAL;
+		if (f->handle != handle && handle)
+			goto errout;
+	} else {
+		err = -EINVAL;
+		if (!handle)
+			goto errout;
+		if (!tb[TCA_FLOW_KEYS-1])
+			goto errout;
+
+		if (TC_H_MAJ(baseclass) == 0)
+			baseclass = TC_H_MAKE(tp->q->handle, baseclass);
+		if (TC_H_MIN(baseclass) == 0)
+			baseclass = TC_H_MAKE(baseclass, 1);
+
+		err = -ENOBUFS;
+		f = kzalloc(sizeof(*f), GFP_KERNEL);
+		if (f == NULL)
+			goto errout;
+
+		f->handle = handle;
+	}
+
+	if (tb[TCA_FLOW_KEYS-1]) {
+		f->keymask = keymask;
+		f->nkeys   = nkeys;
+	}
+	if (baseclass)
+		f->baseclass = baseclass;
+	if (tb[TCA_FLOW_CLASSES-1])
+		f->classes = *(u16 *)RTA_DATA(tb[TCA_FLOW_CLASSES-1]);
+	tcf_exts_change(tp, &f->exts, &e);
+
+	tcf_tree_lock(tp);
+	if (*arg == 0)
+		list_add(&f->list, &head->filters);
+	tcf_tree_unlock(tp);
+
+	*arg = (unsigned long)f;
+	return 0;
+
+errout:
+	tcf_exts_destroy(tp, &e);
+	return err;
+}
+
+static void flow_destroy_filter(struct tcf_proto *tp, struct flow_filter *f)
+{
+	tcf_exts_destroy(tp, &f->exts);
+	kfree(f);
+}
+
+static int flow_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	struct flow_filter *f = (struct flow_filter *)arg;
+
+	tcf_tree_lock(tp);
+	list_del(&f->list);
+	tcf_tree_unlock(tp);
+	flow_destroy_filter(tp, f);
+	return 0;
+}
+
+static int flow_init(struct tcf_proto *tp)
+{
+	struct flow_head *head;
+
+	head = kzalloc(sizeof(*head), GFP_KERNEL);
+	if (head == NULL)
+		return -ENOBUFS;
+	INIT_LIST_HEAD(&head->filters);
+	tp->root = head;
+	return 0;
+}
+
+static void flow_destroy(struct tcf_proto *tp)
+{
+	struct flow_head *head = tp->root;
+	struct flow_filter *f, *next;
+
+	list_for_each_entry_safe(f, next, &head->filters, list) {
+		list_del(&f->list);
+		flow_destroy_filter(tp, f);
+	}
+	kfree(head);
+}
+
+static unsigned long flow_get(struct tcf_proto *tp, u32 handle)
+{
+	struct flow_head *head = tp->root;
+	struct flow_filter *f;
+
+	list_for_each_entry(f, &head->filters, list)
+		if (f->handle == handle)
+			return (unsigned long)f;
+	return 0;
+}
+
+static void flow_put(struct tcf_proto *tp, unsigned long f)
+{
+	return;
+}
+
+static int flow_dump(struct tcf_proto *tp, unsigned long fh,
+		     struct sk_buff *skb, struct tcmsg *t)
+{
+	struct flow_filter *f = (struct flow_filter *)fh;
+	unsigned char *b = skb_tail_pointer(skb);
+	struct rtattr *rta;
+
+	if (f == NULL)
+		return skb->len;
+
+	t->tcm_handle = f->handle;
+
+	rta = (struct rtattr *)b;
+	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+
+	RTA_PUT(skb, TCA_FLOW_KEYS, sizeof(u32), &f->keymask);
+	if (f->baseclass)
+		RTA_PUT(skb, TCA_FLOW_BASECLASS, sizeof(u32), &f->baseclass);
+	if (f->classes)
+		RTA_PUT(skb, TCA_FLOW_CLASSES, sizeof(u16), &f->classes);
+
+	if (tcf_exts_dump(skb, &f->exts, &flow_ext_map) < 0)
+		goto rtattr_failure;
+
+	rta->rta_len = skb_tail_pointer(skb) - b;
+
+	if (tcf_exts_dump_stats(skb, &f->exts, &flow_ext_map) < 0)
+		goto rtattr_failure;
+
+	return skb->len;
+
+rtattr_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static void flow_walk(struct tcf_proto *tp, struct tcf_walker *arg)
+{
+	struct flow_head *head = tp->root;
+	struct flow_filter *f;
+
+	list_for_each_entry(f, &head->filters, list) {
+		if (arg->count < arg->skip)
+			goto skip;
+		if (arg->fn(tp, (unsigned long)f, arg) < 0) {
+			arg->stop = 1;
+			break;
+		}
+skip:
+		arg->count++;
+	}
+}
+
+static struct tcf_proto_ops cls_flow_ops = {
+	.kind		= "flow",
+	.classify	= flow_classify,
+	.init		= flow_init,
+	.destroy	= flow_destroy,
+	.change		= flow_change,
+	.delete		= flow_delete,
+	.get		= flow_get,
+	.put		= flow_put,
+	.dump		= flow_dump,
+	.walk		= flow_walk,
+	.owner		= THIS_MODULE,
+};
+
+static int __init cls_flow_init(void)
+{
+	return register_tcf_proto_ops(&cls_flow_ops);
+}
+
+static void __exit cls_flow_exit(void)
+{
+	unregister_tcf_proto_ops(&cls_flow_ops);
+}
+
+module_init(cls_flow_init);
+module_exit(cls_flow_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_DESCRIPTION("TC flow classifier");
