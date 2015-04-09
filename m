From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Thu,  9 Apr 2015 14:58:07 +0200
Message-ID: <1428584287-8197-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37040 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755121AbbDIM6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 08:58:12 -0400
Received: by wiaa2 with SMTP id a2so97227288wia.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 05:58:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces OpenFlow-based filter. So far, the very essential
packet fields are supported (according to OpenFlow v1.4 spec).

This patch is only the first step. There is a lot of potential performance
improvements possible to implement. Also a lot of features are missing
now. They will be addressed in follow-up patches.

To the name of this classifier, I believe that "cls_openflow" is pretty
accurate. It is actually a OpenFlow classifier.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
v2->v3:
- prepare masted key for faster matching
- use one mask per one cls_of_head as suggested by Thomas Graf
- Thomas Graf suggested to use hash lookup from the very beginning,
  so use rthashtable to store masked keys and do lookup in classify op

v1->v2:
- Added note to Kconfig about no relation to other OpenFlow items than
  classification suggested by Thomas Graf
- fixed TCA_BASIC_CLASSID c&p typo noticed by Jamal
- avoided union for tp suggested by Jamal
---
 include/uapi/linux/pkt_cls.h |  31 ++
 net/sched/Kconfig            |  17 +
 net/sched/Makefile           |   1 +
 net/sched/cls_openflow.c     | 791 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 840 insertions(+)
 create mode 100644 net/sched/cls_openflow.c

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index bf08e76..910898c 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -404,6 +404,37 @@ enum {
 
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
+	TCA_OF_KEY_IP_PROTO,		/* u8 */
+	TCA_OF_KEY_IPV4_SRC,		/* be32 */
+	TCA_OF_KEY_IPV4_SRC_MASK,	/* be32 */
+	TCA_OF_KEY_IPV4_DST,		/* be32 */
+	TCA_OF_KEY_IPV4_DST_MASK,	/* be32 */
+	TCA_OF_KEY_IPV6_SRC,		/* struct in6_addr */
+	TCA_OF_KEY_IPV6_SRC_MASK,	/* struct in6_addr */
+	TCA_OF_KEY_IPV6_DST,		/* struct in6_addr */
+	TCA_OF_KEY_IPV6_DST_MASK,	/* struct in6_addr */
+	TCA_OF_KEY_TCP_SRC,		/* be16 */
+	TCA_OF_KEY_TCP_DST,		/* be16 */
+	TCA_OF_KEY_UDP_SRC,		/* be16 */
+	TCA_OF_KEY_UDP_DST,		/* be16 */
+	__TCA_OF_MAX,
+};
+
+#define TCA_OF_MAX (__TCA_OF_MAX - 1)
+
 /* Extended Matches */
 
 struct tcf_ematch_tree_hdr {
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 2274e72..9126387 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -477,6 +477,23 @@ config NET_CLS_BPF
 	  To compile this code as a module, choose M here: the module will
 	  be called cls_bpf.
 
+config NET_CLS_OPENFLOW
+	tristate "OpenFlow classifier"
+	select NET_CLS
+	---help---
+	  If you say Y here, you will be able to classify packets based on
+	  a configurable combination of packet keys and masks according to
+	  OpenFlow standard.
+
+	  Please note that although the name of this classifier is "openflow",
+	  there is no relation to the OpenFlow wire protocol itself or any of
+	  the other OpenFlow specific concepts such as flow tables, group
+	  tables, counters, actions, etc. The only part taken from OpenFlow
+	  standard are match fields in packet that are used for classification.
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
index 0000000..91af663
--- /dev/null
+++ b/net/sched/cls_openflow.c
@@ -0,0 +1,791 @@
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
+#include <linux/rhashtable.h>
+
+#include <linux/if_ether.h>
+#include <linux/in6.h>
+#include <linux/ip.h>
+
+#include <net/sch_generic.h>
+#include <net/pkt_cls.h>
+#include <net/ip.h>
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
+	struct {
+		__be16 src;
+		__be16 dst;
+	} tp;
+} __aligned(BITS_PER_LONG / 8); /* Ensure that we can do comparisons as longs. */
+
+struct of_flow_mask_range {
+	unsigned short int start;
+	unsigned short int end;
+};
+
+struct of_flow_mask {
+	struct of_flow_key key;
+	struct of_flow_mask_range range;
+	struct rcu_head	rcu;
+};
+
+struct cls_of_head {
+	struct rhashtable ht;
+	struct of_flow_mask mask;
+	u32 hgen;
+	bool mask_assigned;
+	struct list_head filters;
+	struct rhashtable_params ht_params;
+	struct rcu_head rcu;
+};
+
+struct cls_of_filter {
+	struct rhash_head ht_node;
+	struct of_flow_key mkey;
+	struct tcf_exts exts;
+	struct tcf_result res;
+	struct of_flow_key key;
+	struct list_head list;
+	u32 handle;
+	struct rcu_head	rcu;
+};
+
+static unsigned short int of_mask_range(const struct of_flow_mask *mask)
+{
+	return mask->range.end - mask->range.start;
+}
+
+static void of_mask_update_range(struct of_flow_mask *mask)
+{
+	const u8 *bytes = (const u8 *) &mask->key;
+	size_t size = sizeof(mask->key);
+	size_t i, first = 0, last = size - 1;
+
+	for (i = 0; i < sizeof(mask->key); i++) {
+		if (bytes[i]) {
+			if (!first && i)
+				first = i;
+			last = i;
+		}
+	}
+	mask->range.start = rounddown(first, sizeof(long));
+	mask->range.end = roundup(last, sizeof(long));
+}
+
+static void *of_key_get_start(struct of_flow_key *key,
+			      const struct of_flow_mask *mask)
+{
+	return (u8 *) key + mask->range.start;
+}
+
+static int __check_header(struct sk_buff *skb, int len)
+{
+	if (unlikely(skb->len < len))
+		return -EINVAL;
+	if (unlikely(!pskb_may_pull(skb, len)))
+		return -ENOMEM;
+	return 0;
+}
+
+static int of_extract_ipv4(struct sk_buff *skb, struct of_flow_key *key)
+{
+	unsigned int iph_off = skb_network_offset(skb);
+	struct iphdr *iph;
+	unsigned int iph_len;
+	int err;
+
+	err = __check_header(skb, iph_off + sizeof(*iph));
+	if (unlikely(err))
+		goto errout;
+
+	iph_len = ip_hdrlen(skb);
+	if (unlikely(iph_len < sizeof(*iph) ||
+		     skb->len < iph_off + iph_len)) {
+		err = -EINVAL;
+		goto errout;
+	}
+
+	iph = ip_hdr(skb);
+	key->ipv4.src = iph->saddr;
+	key->ipv4.dst = iph->daddr;
+	key->ip.proto = iph->protocol;
+
+	skb_set_transport_header(skb, iph_off + iph_len);
+	return 0;
+
+errout:
+	memset(&key->ip, 0, sizeof(key->ip));
+	memset(&key->ipv4, 0, sizeof(key->ipv4));
+	return err;
+}
+
+static int of_extract_ipv6(struct sk_buff *skb, struct of_flow_key *key)
+{
+	unsigned int iph_off = skb_network_offset(skb);
+	int payload_off;
+	struct ipv6hdr *iph;
+	uint8_t nexthdr;
+	__be16 frag_off;
+	int err;
+
+	err = __check_header(skb, iph_off + sizeof(*iph));
+	if (unlikely(err))
+		goto errout;
+
+	iph = ipv6_hdr(skb);
+	nexthdr = iph->nexthdr;
+	payload_off = (u8 *) (iph + 1) - skb->data;
+
+	key->ip.proto = NEXTHDR_NONE;
+	key->ipv6.src = iph->saddr;
+	key->ipv6.dst = iph->daddr;
+
+	payload_off = ipv6_skip_exthdr(skb, payload_off, &nexthdr, &frag_off);
+	if (unlikely(payload_off < 0)) {
+		err = -EINVAL;
+		goto errout;
+	}
+
+	key->ip.proto = nexthdr;
+	skb_set_transport_header(skb, payload_off);
+	return 0;
+
+errout:
+	memset(&key->ip, 0, sizeof(key->ip));
+	memset(&key->ipv6, 0, sizeof(key->ipv6));
+	return err;
+}
+
+static bool __tcphdr_ok(struct sk_buff *skb)
+{
+	int tcph_off = skb_transport_offset(skb);
+	int tcph_len;
+
+	if (unlikely(!pskb_may_pull(skb, tcph_off + sizeof(struct tcphdr))))
+		return false;
+
+	tcph_len = tcp_hdrlen(skb);
+	if (unlikely(tcph_len < sizeof(struct tcphdr) ||
+		     skb->len < tcph_off + tcph_len))
+		return false;
+
+	return true;
+}
+
+static bool __udphdr_ok(struct sk_buff *skb)
+{
+	return pskb_may_pull(skb, skb_transport_offset(skb) +
+				  sizeof(struct udphdr));
+}
+
+static void of_extract_tp(struct sk_buff *skb, struct of_flow_key *key)
+{
+	if (key->ip.proto == IPPROTO_TCP) {
+		if (__tcphdr_ok(skb)) {
+			struct tcphdr *tcp = tcp_hdr(skb);
+
+			key->tp.src = tcp->source;
+			key->tp.dst = tcp->dest;
+		} else {
+			memset(&key->tp, 0, sizeof(key->tp));
+		}
+
+	} else if (key->ip.proto == IPPROTO_UDP) {
+		if (__udphdr_ok(skb)) {
+			struct udphdr *udp = udp_hdr(skb);
+
+			key->tp.src = udp->source;
+			key->tp.dst = udp->dest;
+		} else {
+			memset(&key->tp, 0, sizeof(key->tp));
+		}
+	}
+}
+
+static void of_extract_key(struct sk_buff *skb, struct of_flow_key *key)
+{
+	struct ethhdr *eth;
+	int err;
+
+	key->indev_ifindex = skb->skb_iif;
+
+	eth = eth_hdr(skb);
+	ether_addr_copy(key->eth.src, eth->h_source);
+	ether_addr_copy(key->eth.dst, eth->h_dest);
+
+	key->eth.type = skb->protocol;
+	if (key->eth.type == htons(ETH_P_IP)) {
+		err = of_extract_ipv4(skb, key);
+		if (likely(!err))
+			of_extract_tp(skb, key);
+	} else if (key->eth.type == htons(ETH_P_IPV6)) {
+		err = of_extract_ipv6(skb, key);
+		if (likely(!err))
+			of_extract_tp(skb, key);
+	}
+}
+
+static void of_set_masked_key(struct of_flow_key *mkey, struct of_flow_key *key,
+			      struct of_flow_mask *mask)
+{
+	const long *lkey = of_key_get_start(key, mask);
+	const long *lmask = of_key_get_start(&mask->key, mask);
+	long *lmkey = of_key_get_start(mkey, mask);
+	int i;
+
+	for (i = 0; i < of_mask_range(mask); i += sizeof(long))
+		*lmkey++ = *lkey++ & *lmask++;
+}
+
+static int of_classify(struct sk_buff *skb, const struct tcf_proto *tp,
+		       struct tcf_result *res)
+{
+	struct cls_of_head *head = rcu_dereference_bh(tp->root);
+	struct cls_of_filter *f;
+	struct of_flow_key skb_key;
+	struct of_flow_key skb_mkey;
+
+	of_extract_key(skb, &skb_key);
+	of_set_masked_key(&skb_mkey, &skb_key, &head->mask);
+
+	f = rhashtable_lookup_fast(&head->ht,
+				   of_key_get_start(&skb_mkey, &head->mask),
+				   head->ht_params);
+	if (f) {
+		*res = f->res;
+		return tcf_exts_exec(skb, &f->exts, res);
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
+static bool of_destroy(struct tcf_proto *tp, bool force)
+{
+	struct cls_of_head *head = rtnl_dereference(tp->root);
+	struct cls_of_filter *f, *next;
+
+	if (!force && !list_empty(&head->filters))
+		return false;
+
+	list_for_each_entry_safe(f, next, &head->filters, list) {
+		list_del_rcu(&f->list);
+		call_rcu(&f->rcu, of_destroy_filter);
+	}
+	RCU_INIT_POINTER(tp->root, NULL);
+	if (head->mask_assigned)
+		rhashtable_destroy(&head->ht);
+	kfree_rcu(head, rcu);
+	return true;
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
+	[TCA_OF_KEY_IP_PROTO]		= { .type = NLA_U8 },
+	[TCA_OF_KEY_IPV4_SRC]		= { .type = NLA_U32 },
+	[TCA_OF_KEY_IPV4_SRC_MASK]	= { .type = NLA_U32 },
+	[TCA_OF_KEY_IPV4_DST]		= { .type = NLA_U32 },
+	[TCA_OF_KEY_IPV4_DST_MASK]	= { .type = NLA_U32 },
+	[TCA_OF_KEY_IPV6_SRC]		= { .len = sizeof(struct in6_addr) },
+	[TCA_OF_KEY_IPV6_SRC_MASK]	= { .len = sizeof(struct in6_addr) },
+	[TCA_OF_KEY_IPV6_DST]		= { .len = sizeof(struct in6_addr) },
+	[TCA_OF_KEY_IPV6_DST_MASK]	= { .len = sizeof(struct in6_addr) },
+	[TCA_OF_KEY_TCP_SRC]		= { .type = NLA_U16 },
+	[TCA_OF_KEY_TCP_DST]		= { .type = NLA_U16 },
+	[TCA_OF_KEY_TCP_SRC]		= { .type = NLA_U16 },
+	[TCA_OF_KEY_TCP_DST]		= { .type = NLA_U16 },
+};
+
+static void of_set_key_val(struct nlattr **tb,
+			   void *val, int val_type,
+			   void *mask, int mask_type, int len)
+{
+	if (!tb[val_type])
+		return;
+	memcpy(val, nla_data(tb[val_type]), len);
+	if (mask_type == TCA_OF_UNSPEC || !tb[mask_type])
+		memset(mask, 0xff, len);
+	else
+		memcpy(mask, nla_data(tb[mask_type]), len);
+}
+
+static int of_set_key(struct net *net, struct nlattr **tb,
+		      struct of_flow_key *key, struct of_flow_key *mask)
+{
+	int err;
+
+	if (tb[TCA_OF_INDEV]) {
+		err = tcf_change_indev(net, tb[TCA_OF_INDEV]);
+		if (err < 0)
+			return err;
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
+		       &mask->eth.type, TCA_OF_UNSPEC,
+		       sizeof(key->eth.type));
+	if (key->eth.type == htons(ETH_P_IP) ||
+	    key->eth.type == htons(ETH_P_IPV6)) {
+		of_set_key_val(tb, &key->ip.proto, TCA_OF_KEY_IP_PROTO,
+			       &mask->ip.proto, TCA_OF_UNSPEC,
+			       sizeof(key->ip.proto));
+	}
+	if (key->eth.type == htons(ETH_P_IP)) {
+		of_set_key_val(tb, &key->ipv4.src, TCA_OF_KEY_IPV4_SRC,
+			       &mask->ipv4.src, TCA_OF_KEY_IPV4_SRC_MASK,
+			       sizeof(key->ipv4.src));
+		of_set_key_val(tb, &key->ipv4.dst, TCA_OF_KEY_IPV4_DST,
+			       &mask->ipv4.dst, TCA_OF_KEY_IPV4_DST_MASK,
+			       sizeof(key->ipv4.dst));
+	} else if (key->eth.type == htons(ETH_P_IPV6)) {
+		of_set_key_val(tb, &key->ipv6.src, TCA_OF_KEY_IPV6_SRC,
+			       &mask->ipv6.src, TCA_OF_KEY_IPV6_SRC_MASK,
+			       sizeof(key->ipv6.src));
+		of_set_key_val(tb, &key->ipv6.dst, TCA_OF_KEY_IPV6_DST,
+			       &mask->ipv6.dst, TCA_OF_KEY_IPV6_DST_MASK,
+			       sizeof(key->ipv6.dst));
+	}
+	if (key->ip.proto == IPPROTO_TCP) {
+		of_set_key_val(tb, &key->tp.src, TCA_OF_KEY_TCP_SRC,
+			       &mask->tp.src, TCA_OF_UNSPEC,
+			       sizeof(key->tp.src));
+		of_set_key_val(tb, &key->tp.dst, TCA_OF_KEY_TCP_DST,
+			       &mask->tp.dst, TCA_OF_UNSPEC,
+			       sizeof(key->tp.dst));
+	} else if (key->ip.proto == IPPROTO_UDP) {
+		of_set_key_val(tb, &key->tp.src, TCA_OF_KEY_UDP_SRC,
+			       &mask->tp.src, TCA_OF_UNSPEC,
+			       sizeof(key->tp.src));
+		of_set_key_val(tb, &key->tp.dst, TCA_OF_KEY_UDP_DST,
+			       &mask->tp.dst, TCA_OF_UNSPEC,
+			       sizeof(key->tp.dst));
+	}
+
+	return 0;
+}
+
+static bool of_mask_eq(struct of_flow_mask *mask1,
+		       struct of_flow_mask *mask2)
+{
+	const long *lmask1 = of_key_get_start(&mask1->key, mask1);
+	const long *lmask2 = of_key_get_start(&mask2->key, mask2);
+
+	return !memcmp(&mask1->range, &mask2->range, sizeof(mask1->range)) &&
+	       !memcmp(lmask1, lmask2, of_mask_range(mask1));
+}
+
+static const struct rhashtable_params of_ht_params = {
+	.key_offset = offsetof(struct cls_of_filter, mkey), /* base offset */
+	.head_offset = offsetof(struct cls_of_filter, ht_node),
+	.automatic_shrinking = true,
+};
+
+static int of_init_hashtable(struct cls_of_head *head,
+			     struct of_flow_mask *mask)
+{
+	head->ht_params = of_ht_params;
+	head->ht_params.key_len = of_mask_range(mask);
+	head->ht_params.key_offset += mask->range.start;
+
+	return rhashtable_init(&head->ht, &head->ht_params);
+}
+
+static int of_check_assign_mask(struct cls_of_head *head,
+				struct of_flow_mask *mask)
+{
+	int err;
+
+	if (head->mask_assigned) {
+		if (!of_mask_eq(&head->mask, mask))
+			return -EINVAL;
+		else
+			return 0;
+	}
+
+	/* Mask is not assigned yet. So assign it and init hashtable
+	 * according to that.
+	 */
+	err = of_init_hashtable(head, mask);
+	if (err)
+		return err;
+	memcpy(&head->mask, mask, sizeof(head->mask));
+	head->mask_assigned = true;
+	return 0;
+}
+
+static int of_set_parms(struct net *net, struct tcf_proto *tp,
+			struct cls_of_filter *f, struct of_flow_mask *mask,
+			unsigned long base, struct nlattr **tb,
+			struct nlattr *est, bool ovr)
+{
+	struct tcf_exts e;
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
+	err = of_set_key(net, tb, &f->key, &mask->key);
+	if (err)
+		goto errout;
+
+	of_mask_update_range(mask);
+	of_set_masked_key(&f->mkey, &f->key, mask);
+
+	tcf_exts_change(tp, &f->exts, &e);
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
+	struct of_flow_mask mask = {};
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
+	err = of_set_parms(net, tp, fnew, &mask, base, tb, tca[TCA_RATE], ovr);
+	if (err)
+		goto errout;
+
+	err = of_check_assign_mask(head, &mask);
+	if (err)
+		goto errout;
+
+	err = rhashtable_insert_fast(&head->ht, &fnew->ht_node,
+				     head->ht_params);
+	if (err)
+		goto errout;
+	if (fold)
+		rhashtable_remove_fast(&head->ht, &fold->ht_node,
+				       head->ht_params);
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
+	struct cls_of_head *head = rtnl_dereference(tp->root);
+	struct cls_of_filter *f = (struct cls_of_filter *) arg;
+
+	rhashtable_remove_fast(&head->ht, &f->ht_node,
+			       head->ht_params);
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
+	if (mask_type != TCA_OF_UNSPEC) {
+		err = nla_put(skb, mask_type, len, mask);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static int of_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+		   struct sk_buff *skb, struct tcmsg *t)
+{
+	struct cls_of_head *head = rtnl_dereference(tp->root);
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
+	    nla_put_u32(skb, TCA_OF_CLASSID, f->res.classid))
+		goto nla_put_failure;
+
+	key = &f->key;
+	mask = &head->mask.key;
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
+			    &mask->eth.type, TCA_OF_UNSPEC,
+			    sizeof(key->eth.type)))
+		goto nla_put_failure;
+	if ((key->eth.type == htons(ETH_P_IP) ||
+	     key->eth.type == htons(ETH_P_IPV6)) &&
+	    of_dump_key_val(skb, &key->ip.proto, TCA_OF_KEY_IP_PROTO,
+			    &mask->ip.proto, TCA_OF_UNSPEC,
+			    sizeof(key->ip.proto)))
+		goto nla_put_failure;
+
+	if (key->eth.type == htons(ETH_P_IP) &&
+	    (of_dump_key_val(skb, &key->ipv4.src, TCA_OF_KEY_IPV4_SRC,
+			     &mask->ipv4.src, TCA_OF_KEY_IPV4_SRC_MASK,
+			     sizeof(key->ipv4.src)) ||
+	     of_dump_key_val(skb, &key->ipv4.dst, TCA_OF_KEY_IPV4_DST,
+			     &mask->ipv4.dst, TCA_OF_KEY_IPV4_DST_MASK,
+			     sizeof(key->ipv4.dst))))
+		goto nla_put_failure;
+	else if (key->eth.type == htons(ETH_P_IPV6) &&
+		 (of_dump_key_val(skb, &key->ipv6.src, TCA_OF_KEY_IPV6_SRC,
+				  &mask->ipv6.src, TCA_OF_KEY_IPV6_SRC_MASK,
+				  sizeof(key->ipv6.src)) ||
+		  of_dump_key_val(skb, &key->ipv6.dst, TCA_OF_KEY_IPV6_DST,
+				  &mask->ipv6.dst, TCA_OF_KEY_IPV6_DST_MASK,
+				  sizeof(key->ipv6.dst))))
+		goto nla_put_failure;
+
+	if (key->ip.proto == IPPROTO_TCP &&
+	    (of_dump_key_val(skb, &key->tp.src, TCA_OF_KEY_TCP_SRC,
+			     &mask->tp.src, TCA_OF_UNSPEC,
+			     sizeof(key->tp.src)) ||
+	     of_dump_key_val(skb, &key->tp.dst, TCA_OF_KEY_TCP_DST,
+			     &mask->tp.dst, TCA_OF_UNSPEC,
+			     sizeof(key->tp.dst))))
+		goto nla_put_failure;
+	else if (key->ip.proto == IPPROTO_UDP &&
+		 (of_dump_key_val(skb, &key->tp.src, TCA_OF_KEY_UDP_SRC,
+				  &mask->tp.src, TCA_OF_UNSPEC,
+				  sizeof(key->tp.src)) ||
+		  of_dump_key_val(skb, &key->tp.dst, TCA_OF_KEY_UDP_DST,
+				  &mask->tp.dst, TCA_OF_UNSPEC,
+				  sizeof(key->tp.dst))))
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
