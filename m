From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v5 net-next 4/4] ila: Add generic ILA translation facility
Date: Mon, 14 Dec 2015 15:56:48 -0800
Message-ID: <1450137408-2589240-5-git-send-email-tom@herbertland.com>
References: <1450137408-2589240-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:40426 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932841AbbLNX5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 18:57:04 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tBENrgkL024931
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 15:57:03 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1yt7qj8259-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 15:57:03 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 5ea9b284a2be11e590630002c95209d8-ea6e1210 for <netdev@vger.kernel.org>;	Mon,
 14 Dec 2015 15:57:02 -0800
In-Reply-To: <1450137408-2589240-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements an ILA tanslation table. This table can be
configured with identifier to locator mappings, and can be be queried
to resolve a mapping. Queries can be parameterized based on interface,
direction (incoming or outoing), and matching locator.  The table is
implemented using rhashtable and is configured via netlink (through
"ip ila .." in iproute).

The table may be used as alternative means to do do ILA tanslations
other than the lw tunnels

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/ila.h         |  18 ++
 include/uapi/linux/ila.h  |  22 ++
 net/ipv6/ila/Makefile     |   2 +-
 net/ipv6/ila/ila.h        |   2 +
 net/ipv6/ila/ila_common.c |   8 +
 net/ipv6/ila/ila_xlat.c   | 680 ++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 731 insertions(+), 1 deletion(-)
 create mode 100644 include/net/ila.h
 create mode 100644 net/ipv6/ila/ila_xlat.c

diff --git a/include/net/ila.h b/include/net/ila.h
new file mode 100644
index 0000000..9f4f43e
--- /dev/null
+++ b/include/net/ila.h
@@ -0,0 +1,18 @@
+/*
+ * ILA kernel interface
+ *
+ * Copyright (c) 2015 Tom Herbert <tom@herbertland.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ */
+
+#ifndef _NET_ILA_H
+#define _NET_ILA_H
+
+int ila_xlat_outgoing(struct sk_buff *skb);
+int ila_xlat_incoming(struct sk_buff *skb);
+
+#endif /* _NET_ILA_H */
diff --git a/include/uapi/linux/ila.h b/include/uapi/linux/ila.h
index 7ed9e67..abde7bb 100644
--- a/include/uapi/linux/ila.h
+++ b/include/uapi/linux/ila.h
@@ -3,13 +3,35 @@
 #ifndef _UAPI_LINUX_ILA_H
 #define _UAPI_LINUX_ILA_H
 
+/* NETLINK_GENERIC related info */
+#define ILA_GENL_NAME		"ila"
+#define ILA_GENL_VERSION	0x1
+
 enum {
 	ILA_ATTR_UNSPEC,
 	ILA_ATTR_LOCATOR,			/* u64 */
+	ILA_ATTR_IDENTIFIER,			/* u64 */
+	ILA_ATTR_LOCATOR_MATCH,			/* u64 */
+	ILA_ATTR_IFINDEX,			/* s32 */
+	ILA_ATTR_DIR,				/* u32 */
 
 	__ILA_ATTR_MAX,
 };
 
 #define ILA_ATTR_MAX		(__ILA_ATTR_MAX - 1)
 
+enum {
+	ILA_CMD_UNSPEC,
+	ILA_CMD_ADD,
+	ILA_CMD_DEL,
+	ILA_CMD_GET,
+
+	__ILA_CMD_MAX,
+};
+
+#define ILA_CMD_MAX	(__ILA_CMD_MAX - 1)
+
+#define ILA_DIR_IN	(1 << 0)
+#define ILA_DIR_OUT	(1 << 1)
+
 #endif /* _UAPI_LINUX_ILA_H */
diff --git a/net/ipv6/ila/Makefile b/net/ipv6/ila/Makefile
index 31d136b..4b32e59 100644
--- a/net/ipv6/ila/Makefile
+++ b/net/ipv6/ila/Makefile
@@ -4,4 +4,4 @@
 
 obj-$(CONFIG_IPV6_ILA) += ila.o
 
-ila-objs := ila_common.o ila_lwt.o
+ila-objs := ila_common.o ila_lwt.o ila_xlat.o
diff --git a/net/ipv6/ila/ila.h b/net/ipv6/ila/ila.h
index b94081f..28542cb 100644
--- a/net/ipv6/ila/ila.h
+++ b/net/ipv6/ila/ila.h
@@ -42,5 +42,7 @@ void update_ipv6_locator(struct sk_buff *skb, struct ila_params *p);
 
 int ila_lwt_init(void);
 void ila_lwt_fini(void);
+int ila_xlat_init(void);
+void ila_xlat_fini(void);
 
 #endif /* __ILA_H */
diff --git a/net/ipv6/ila/ila_common.c b/net/ipv6/ila/ila_common.c
index 64e1904..32dc9aa 100644
--- a/net/ipv6/ila/ila_common.c
+++ b/net/ipv6/ila/ila_common.c
@@ -80,12 +80,20 @@ static int __init ila_init(void)
 	if (ret)
 		goto fail_lwt;
 
+	ret = ila_xlat_init();
+	if (ret)
+		goto fail_xlat;
+
+	return 0;
+fail_xlat:
+	ila_lwt_fini();
 fail_lwt:
 	return ret;
 }
 
 static void __exit ila_fini(void)
 {
+	ila_xlat_fini();
 	ila_lwt_fini();
 }
 
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
new file mode 100644
index 0000000..1e1eaf3
--- /dev/null
+++ b/net/ipv6/ila/ila_xlat.c
@@ -0,0 +1,680 @@
+#include <linux/jhash.h>
+#include <linux/netfilter.h>
+#include <linux/rcupdate.h>
+#include <linux/rhashtable.h>
+#include <linux/vmalloc.h>
+#include <net/genetlink.h>
+#include <net/ila.h>
+#include <net/netns/generic.h>
+#include <uapi/linux/genetlink.h>
+#include "ila.h"
+
+struct ila_xlat_params {
+	struct ila_params ip;
+	__be64 identifier;
+	int ifindex;
+	unsigned int dir;
+};
+
+struct ila_map {
+	struct ila_xlat_params p;
+	struct rhash_head node;
+	struct ila_map __rcu *next;
+	struct rcu_head rcu;
+};
+
+static unsigned int ila_net_id;
+
+struct ila_net {
+	struct rhashtable rhash_table;
+	spinlock_t *locks; /* Bucket locks for entry manipulation */
+	unsigned int locks_mask;
+	bool hooks_registered;
+};
+
+#define	LOCKS_PER_CPU 10
+
+static int alloc_ila_locks(struct ila_net *ilan, gfp_t gfp)
+{
+	unsigned int i, size;
+	unsigned int nr_pcpus = num_possible_cpus();
+
+	nr_pcpus = min_t(unsigned int, nr_pcpus, 32UL);
+	size = roundup_pow_of_two(nr_pcpus * LOCKS_PER_CPU);
+
+	if (sizeof(spinlock_t) != 0) {
+#ifdef CONFIG_NUMA
+		if (size * sizeof(spinlock_t) > PAGE_SIZE &&
+		    gfp == GFP_KERNEL)
+			ilan->locks = vmalloc(size * sizeof(spinlock_t));
+		else
+#endif
+		ilan->locks = kmalloc_array(size, sizeof(spinlock_t),
+					    gfp);
+		if (!ilan->locks)
+			return -ENOMEM;
+		for (i = 0; i < size; i++)
+			spin_lock_init(&ilan->locks[i]);
+	}
+	ilan->locks_mask = size - 1;
+
+	return 0;
+}
+
+static u32 hashrnd __read_mostly;
+static __always_inline void __ila_hash_secret_init(void)
+{
+	net_get_random_once(&hashrnd, sizeof(hashrnd));
+}
+
+static inline u32 ila_identifier_hash(__be64 identifier)
+{
+	u32 *v = (u32 *)&identifier;
+
+	return jhash_2words(v[0], v[1], hashrnd);
+}
+
+static inline spinlock_t *ila_get_lock(struct ila_net *ilan, __be64 identifier)
+{
+	return &ilan->locks[ila_identifier_hash(identifier) & ilan->locks_mask];
+}
+
+static inline int ila_cmp_wildcards(struct ila_map *ila, __be64 loc,
+				    int ifindex, unsigned int dir)
+{
+	return (ila->p.ip.locator_match && ila->p.ip.locator_match != loc) ||
+	       (ila->p.ifindex && ila->p.ifindex != ifindex) ||
+	       !(ila->p.dir & dir);
+}
+
+static inline int ila_cmp_params(struct ila_map *ila, struct ila_xlat_params *p)
+{
+	return (ila->p.ip.locator_match != p->ip.locator_match) ||
+	       (ila->p.ifindex != p->ifindex) ||
+	       (ila->p.dir != p->dir);
+}
+
+static int ila_cmpfn(struct rhashtable_compare_arg *arg,
+		     const void *obj)
+{
+	const struct ila_map *ila = obj;
+
+	return (ila->p.identifier != *(__be64 *)arg->key);
+}
+
+static inline int ila_order(struct ila_map *ila)
+{
+	int score = 0;
+
+	if (ila->p.ip.locator_match)
+		score += 1 << 0;
+
+	if (ila->p.ifindex)
+		score += 1 << 1;
+
+	return score;
+}
+
+static const struct rhashtable_params rht_params = {
+	.nelem_hint = 1024,
+	.head_offset = offsetof(struct ila_map, node),
+	.key_offset = offsetof(struct ila_map, p.identifier),
+	.key_len = sizeof(u64), /* identifier */
+	.max_size = 1048576,
+	.min_size = 256,
+	.automatic_shrinking = true,
+	.obj_cmpfn = ila_cmpfn,
+};
+
+static struct genl_family ila_nl_family = {
+	.id		= GENL_ID_GENERATE,
+	.hdrsize	= 0,
+	.name		= ILA_GENL_NAME,
+	.version	= ILA_GENL_VERSION,
+	.maxattr	= ILA_ATTR_MAX,
+	.netnsok	= true,
+	.parallel_ops	= true,
+};
+
+static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
+	[ILA_ATTR_IDENTIFIER] = { .type = NLA_U64, },
+	[ILA_ATTR_LOCATOR] = { .type = NLA_U64, },
+	[ILA_ATTR_LOCATOR_MATCH] = { .type = NLA_U64, },
+	[ILA_ATTR_IFINDEX] = { .type = NLA_U32, },
+	[ILA_ATTR_DIR] = { .type = NLA_U32, },
+};
+
+static int parse_nl_config(struct genl_info *info,
+			   struct ila_xlat_params *p)
+{
+	memset(p, 0, sizeof(*p));
+
+	if (info->attrs[ILA_ATTR_IDENTIFIER])
+		p->identifier = (__force __be64)nla_get_u64(
+			info->attrs[ILA_ATTR_IDENTIFIER]);
+
+	if (info->attrs[ILA_ATTR_LOCATOR])
+		p->ip.locator = (__force __be64)nla_get_u64(
+			info->attrs[ILA_ATTR_LOCATOR]);
+
+	if (info->attrs[ILA_ATTR_LOCATOR_MATCH])
+		p->ip.locator_match = (__force __be64)nla_get_u64(
+			info->attrs[ILA_ATTR_LOCATOR_MATCH]);
+
+	if (info->attrs[ILA_ATTR_IFINDEX])
+		p->ifindex = nla_get_s32(info->attrs[ILA_ATTR_IFINDEX]);
+
+	if (info->attrs[ILA_ATTR_DIR])
+		p->dir = nla_get_u32(info->attrs[ILA_ATTR_DIR]);
+
+	return 0;
+}
+
+/* Must be called with rcu readlock */
+static inline struct ila_map *ila_lookup_wildcards(__be64 id, __be64 loc,
+						   int ifindex,
+						   unsigned int dir,
+						   struct ila_net *ilan)
+{
+	struct ila_map *ila;
+
+	ila = rhashtable_lookup_fast(&ilan->rhash_table, &id, rht_params);
+	while (ila) {
+		if (!ila_cmp_wildcards(ila, loc, ifindex, dir))
+			return ila;
+		ila = rcu_access_pointer(ila->next);
+	}
+
+	return NULL;
+}
+
+/* Must be called with rcu readlock */
+static inline struct ila_map *ila_lookup_by_params(struct ila_xlat_params *p,
+						   struct ila_net *ilan)
+{
+	struct ila_map *ila;
+
+	ila = rhashtable_lookup_fast(&ilan->rhash_table, &p->identifier,
+				     rht_params);
+	while (ila) {
+		if (!ila_cmp_params(ila, p))
+			return ila;
+		ila = rcu_access_pointer(ila->next);
+	}
+
+	return NULL;
+}
+
+static inline void ila_release(struct ila_map *ila)
+{
+	kfree_rcu(ila, rcu);
+}
+
+static void ila_free_cb(void *ptr, void *arg)
+{
+	struct ila_map *ila = (struct ila_map *)ptr, *next;
+
+	/* Assume rcu_readlock held */
+	while (ila) {
+		next = rcu_access_pointer(ila->next);
+		ila_release(ila);
+		ila = next;
+	}
+}
+
+static int ila_xlat_addr(struct sk_buff *skb, int dir);
+
+static unsigned int
+ila_nf_input(void *priv,
+	     struct sk_buff *skb,
+	     const struct nf_hook_state *state)
+{
+	ila_xlat_addr(skb, ILA_DIR_IN);
+	return NF_ACCEPT;
+}
+
+static struct nf_hook_ops ila_nf_hook_ops[] __read_mostly = {
+	{
+		.hook = ila_nf_input,
+		.pf = NFPROTO_IPV6,
+		.hooknum = NF_INET_PRE_ROUTING,
+		.priority = -1,
+	},
+};
+
+static int ila_add_mapping(struct net *net, struct ila_xlat_params *p)
+{
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	struct ila_map *ila, *head;
+	spinlock_t *lock = ila_get_lock(ilan, p->identifier);
+	int err = 0, order;
+
+	if (!ilan->hooks_registered) {
+		/* We defer registering net hooks in the namespace until the
+		 * first mapping is added.
+		 */
+		err = nf_register_net_hooks(net, ila_nf_hook_ops,
+					    ARRAY_SIZE(ila_nf_hook_ops));
+		if (err)
+			return err;
+	}
+
+	ila = kzalloc(sizeof(*ila), GFP_KERNEL);
+	if (!ila)
+		return -ENOMEM;
+
+	ila->p = *p;
+
+	if (p->ip.locator_match) {
+		/* Precompute checksum difference for translation since we
+		 * know both the old identifier and the new one.
+		 */
+		ila->p.ip.csum_diff = compute_csum_diff8(
+			(__be32 *)&p->ip.locator_match,
+			(__be32 *)&p->ip.locator);
+	}
+
+	order = ila_order(ila);
+
+	spin_lock(lock);
+
+	head = rhashtable_lookup_fast(&ilan->rhash_table, &p->identifier,
+				      rht_params);
+	if (!head) {
+		/* New entry for the rhash_table */
+		err = rhashtable_lookup_insert_fast(&ilan->rhash_table,
+						    &ila->node, rht_params);
+	} else {
+		struct ila_map *tila = head, *prev = NULL;
+
+		do {
+			if (!ila_cmp_params(tila, p)) {
+				err = -EEXIST;
+				goto out;
+			}
+
+			if (order > ila_order(tila))
+				break;
+
+			prev = tila;
+			tila = rcu_dereference_protected(tila->next,
+				lockdep_is_held(lock));
+		} while (tila);
+
+		if (prev) {
+			/* Insert in sub list of head */
+			RCU_INIT_POINTER(ila->next, tila);
+			rcu_assign_pointer(prev->next, ila);
+		} else {
+			/* Make this ila new head */
+			RCU_INIT_POINTER(ila->next, head);
+			err = rhashtable_replace_fast(&ilan->rhash_table,
+						      &head->node,
+						      &ila->node, rht_params);
+			if (err)
+				goto out;
+		}
+	}
+
+out:
+	spin_unlock(lock);
+
+	if (err)
+		kfree(ila);
+
+	return err;
+}
+
+static int ila_del_mapping(struct net *net, struct ila_xlat_params *p)
+{
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	struct ila_map *ila, *head, *prev;
+	spinlock_t *lock = ila_get_lock(ilan, p->identifier);
+	int err = -ENOENT;
+
+	spin_lock(lock);
+
+	head = rhashtable_lookup_fast(&ilan->rhash_table,
+				      &p->identifier, rht_params);
+	ila = head;
+
+	prev = NULL;
+
+	while (ila) {
+		if (ila_cmp_params(ila, p)) {
+			prev = ila;
+			ila = rcu_dereference_protected(ila->next,
+							lockdep_is_held(lock));
+			continue;
+		}
+
+		err = 0;
+
+		if (prev) {
+			/* Not head, just delete from list */
+			rcu_assign_pointer(prev->next, ila->next);
+		} else {
+			/* It is the head. If there is something in the
+			 * sublist we need to make a new head.
+			 */
+			head = rcu_dereference_protected(ila->next,
+							 lockdep_is_held(lock));
+			if (head) {
+				/* Put first entry in the sublist into the
+				 * table
+				 */
+				err = rhashtable_replace_fast(
+					&ilan->rhash_table, &ila->node,
+					&head->node, rht_params);
+				if (err)
+					goto out;
+			} else {
+				/* Entry no longer used */
+				err = rhashtable_remove_fast(&ilan->rhash_table,
+							     &ila->node,
+							     rht_params);
+			}
+		}
+
+		ila_release(ila);
+
+		break;
+	}
+
+out:
+	spin_unlock(lock);
+
+	return err;
+}
+
+static int ila_nl_cmd_add_mapping(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct ila_xlat_params p;
+	int err;
+
+	err = parse_nl_config(info, &p);
+	if (err)
+		return err;
+
+	return ila_add_mapping(net, &p);
+}
+
+static int ila_nl_cmd_del_mapping(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct ila_xlat_params p;
+	int err;
+
+	err = parse_nl_config(info, &p);
+	if (err)
+		return err;
+
+	ila_del_mapping(net, &p);
+
+	return 0;
+}
+
+static int ila_fill_info(struct ila_map *ila, struct sk_buff *msg)
+{
+	if (nla_put_u64(msg, ILA_ATTR_IDENTIFIER,
+			(__force u64)ila->p.identifier) ||
+	    nla_put_u64(msg, ILA_ATTR_LOCATOR,
+			(__force u64)ila->p.ip.locator) ||
+	    nla_put_u64(msg, ILA_ATTR_LOCATOR_MATCH,
+			(__force u64)ila->p.ip.locator_match) ||
+	    nla_put_s32(msg, ILA_ATTR_IFINDEX, ila->p.ifindex) ||
+	    nla_put_u32(msg, ILA_ATTR_DIR, ila->p.dir))
+		return -1;
+
+	return 0;
+}
+
+static int ila_dump_info(struct ila_map *ila,
+			 u32 portid, u32 seq, u32 flags,
+			 struct sk_buff *skb, u8 cmd)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(skb, portid, seq, &ila_nl_family, flags, cmd);
+	if (!hdr)
+		return -ENOMEM;
+
+	if (ila_fill_info(ila, skb) < 0)
+		goto nla_put_failure;
+
+	genlmsg_end(skb, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
+static int ila_nl_cmd_get_mapping(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	struct sk_buff *msg;
+	struct ila_xlat_params p;
+	struct ila_map *ila;
+	int ret;
+
+	ret = parse_nl_config(info, &p);
+	if (ret)
+		return ret;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	rcu_read_lock();
+
+	ila = ila_lookup_by_params(&p, ilan);
+	if (ila) {
+		ret = ila_dump_info(ila,
+				    info->snd_portid,
+				    info->snd_seq, 0, msg,
+				    info->genlhdr->cmd);
+	}
+
+	rcu_read_unlock();
+
+	if (ret < 0)
+		goto out_free;
+
+	return genlmsg_reply(msg, info);
+
+out_free:
+	nlmsg_free(msg);
+	return ret;
+}
+
+struct ila_dump_iter {
+	struct rhashtable_iter rhiter;
+};
+
+static int ila_nl_dump_start(struct netlink_callback *cb)
+{
+	struct net *net = sock_net(cb->skb->sk);
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	struct ila_dump_iter *iter = (struct ila_dump_iter *)cb->args;
+
+	return rhashtable_walk_init(&ilan->rhash_table, &iter->rhiter);
+}
+
+static int ila_nl_dump_done(struct netlink_callback *cb)
+{
+	struct ila_dump_iter *iter = (struct ila_dump_iter *)cb->args;
+
+	rhashtable_walk_exit(&iter->rhiter);
+
+	return 0;
+}
+
+static int ila_nl_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct ila_dump_iter *iter = (struct ila_dump_iter *)cb->args;
+	struct rhashtable_iter *rhiter = &iter->rhiter;
+	struct ila_map *ila;
+	int ret;
+
+	ret = rhashtable_walk_start(rhiter);
+	if (ret && ret != -EAGAIN)
+		goto done;
+
+	for (;;) {
+		ila = rhashtable_walk_next(rhiter);
+
+		if (IS_ERR(ila)) {
+			if (PTR_ERR(ila) == -EAGAIN)
+				continue;
+			ret = PTR_ERR(ila);
+			goto done;
+		} else if (!ila) {
+			break;
+		}
+
+		while (ila) {
+			ret =  ila_dump_info(ila, NETLINK_CB(cb->skb).portid,
+					     cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					     skb, ILA_CMD_GET);
+			if (ret)
+				goto done;
+
+			ila = rcu_access_pointer(ila->next);
+		}
+	}
+
+	ret = skb->len;
+
+done:
+	rhashtable_walk_stop(rhiter);
+	return ret;
+}
+
+static const struct genl_ops ila_nl_ops[] = {
+	{
+		.cmd = ILA_CMD_ADD,
+		.doit = ila_nl_cmd_add_mapping,
+		.policy = ila_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = ILA_CMD_DEL,
+		.doit = ila_nl_cmd_del_mapping,
+		.policy = ila_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = ILA_CMD_GET,
+		.doit = ila_nl_cmd_get_mapping,
+		.start = ila_nl_dump_start,
+		.dumpit = ila_nl_dump,
+		.done = ila_nl_dump_done,
+		.policy = ila_nl_policy,
+	},
+};
+
+#define ILA_HASH_TABLE_SIZE 1024
+
+static __net_init int ila_init_net(struct net *net)
+{
+	int err;
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+
+	err = alloc_ila_locks(ilan, GFP_KERNEL);
+	if (err)
+		return err;
+
+	rhashtable_init(&ilan->rhash_table, &rht_params);
+
+	return 0;
+}
+
+static __net_exit void ila_exit_net(struct net *net)
+{
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+
+	rhashtable_free_and_destroy(&ilan->rhash_table, ila_free_cb, NULL);
+
+	kvfree(ilan->locks);
+
+	if (ilan->hooks_registered)
+		nf_unregister_net_hooks(net, ila_nf_hook_ops,
+					ARRAY_SIZE(ila_nf_hook_ops));
+}
+
+static struct pernet_operations ila_net_ops = {
+	.init = ila_init_net,
+	.exit = ila_exit_net,
+	.id   = &ila_net_id,
+	.size = sizeof(struct ila_net),
+};
+
+static int ila_xlat_addr(struct sk_buff *skb, int dir)
+{
+	struct ila_map *ila;
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	struct net *net = dev_net(skb->dev);
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	__be64 identifier, locator_match;
+	size_t nhoff;
+
+	/* Assumes skb contains a valid IPv6 header that is pulled */
+
+	identifier = *(__be64 *)&ip6h->daddr.in6_u.u6_addr8[8];
+	locator_match = *(__be64 *)&ip6h->daddr.in6_u.u6_addr8[0];
+	nhoff = sizeof(struct ipv6hdr);
+
+	rcu_read_lock();
+
+	ila = ila_lookup_wildcards(identifier, locator_match,
+				   skb->dev->ifindex, dir, ilan);
+	if (ila)
+		update_ipv6_locator(skb, &ila->p.ip);
+
+	rcu_read_unlock();
+
+	return 0;
+}
+
+int ila_xlat_incoming(struct sk_buff *skb)
+{
+	return ila_xlat_addr(skb, ILA_DIR_IN);
+}
+EXPORT_SYMBOL(ila_xlat_incoming);
+
+int ila_xlat_outgoing(struct sk_buff *skb)
+{
+	return ila_xlat_addr(skb, ILA_DIR_OUT);
+}
+EXPORT_SYMBOL(ila_xlat_outgoing);
+
+int ila_xlat_init(void)
+{
+	int ret;
+
+	ret = register_pernet_device(&ila_net_ops);
+	if (ret)
+		goto exit;
+
+	ret = genl_register_family_with_ops(&ila_nl_family,
+					    ila_nl_ops);
+	if (ret < 0)
+		goto unregister;
+
+	return 0;
+
+unregister:
+	unregister_pernet_device(&ila_net_ops);
+exit:
+	return ret;
+}
+
+void ila_xlat_fini(void)
+{
+	genl_unregister_family(&ila_nl_family);
+	unregister_pernet_device(&ila_net_ops);
+}
+
-- 
2.4.6
