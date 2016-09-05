From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/29] netfilter: remove ip_conntrack* sysctl compat code
Date: Mon,  5 Sep 2016 12:58:23 +0200
Message-ID: <1473073124-5015-9-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This backward compatibility has been around for more than ten years,
since Yasuyuki Kozakai introduced IPv6 in conntrack. These days, we have
alternate /proc/net/nf_conntrack* entries, the ctnetlink interface and
the conntrack utility got adopted by many people in the user community
according to what I observed on the netfilter user mailing list.

So let's get rid of this.

Note that nf_conntrack_htable_size and unsigned int nf_conntrack_max do
not need to be exported as symbol anymore.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h       |   8 -
 include/net/netns/conntrack.h                      |   8 -
 net/ipv4/netfilter/Kconfig                         |  11 -
 net/ipv4/netfilter/Makefile                        |   5 -
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |  70 ---
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   | 491 ---------------------
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c       |  39 +-
 net/netfilter/nf_conntrack_core.c                  |   3 -
 net/netfilter/nf_conntrack_proto.c                 |  81 +---
 net/netfilter/nf_conntrack_proto_generic.c         |  39 +-
 net/netfilter/nf_conntrack_proto_sctp.c            |  85 +---
 net/netfilter/nf_conntrack_proto_tcp.c             | 127 +-----
 net/netfilter/nf_conntrack_proto_udp.c             |  49 +-
 13 files changed, 7 insertions(+), 1009 deletions(-)
 delete mode 100644 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 1a5fb36..de629f1 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -134,14 +134,6 @@ void nf_ct_l4proto_pernet_unregister(struct net *net,
 int nf_ct_l4proto_register(struct nf_conntrack_l4proto *proto);
 void nf_ct_l4proto_unregister(struct nf_conntrack_l4proto *proto);
 
-static inline void nf_ct_kfree_compat_sysctl_table(struct nf_proto_net *pn)
-{
-#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
-	kfree(pn->ctl_compat_table);
-	pn->ctl_compat_table = NULL;
-#endif
-}
-
 /* Generic netlink helpers */
 int nf_ct_port_tuple_to_nlattr(struct sk_buff *skb,
 			       const struct nf_conntrack_tuple *tuple);
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 38b1a80..e469e85 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -15,10 +15,6 @@ struct nf_proto_net {
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header *ctl_table_header;
 	struct ctl_table        *ctl_table;
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	struct ctl_table_header *ctl_compat_header;
-	struct ctl_table        *ctl_compat_table;
-#endif
 #endif
 	unsigned int		users;
 };
@@ -58,10 +54,6 @@ struct nf_ip_net {
 	struct nf_udp_net	udp;
 	struct nf_icmp_net	icmp;
 	struct nf_icmp_net	icmpv6;
-#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
-	struct ctl_table_header *ctl_table_header;
-	struct ctl_table	*ctl_table;
-#endif
 };
 
 struct ct_pcpu {
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index c187c60..d613309 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -25,17 +25,6 @@ config NF_CONNTRACK_IPV4
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-config NF_CONNTRACK_PROC_COMPAT
-	bool "proc/sysctl compatibility with old connection tracking"
-	depends on NF_CONNTRACK_PROCFS && NF_CONNTRACK_IPV4
-	default y
-	help
-	  This option enables /proc and sysctl compatibility with the old
-	  layer 3 dependent connection tracking. This is needed to keep
-	  old programs that have not been adapted to the new names working.
-
-	  If unsure, say Y.
-
 if NF_TABLES
 
 config NF_TABLES_IPV4
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 87b073d..853328f 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -4,11 +4,6 @@
 
 # objects for l3 independent conntrack
 nf_conntrack_ipv4-y	:=  nf_conntrack_l3proto_ipv4.o nf_conntrack_proto_icmp.o
-ifeq ($(CONFIG_NF_CONNTRACK_PROC_COMPAT),y)
-ifeq ($(CONFIG_PROC_FS),y)
-nf_conntrack_ipv4-objs	+= nf_conntrack_l3proto_ipv4_compat.o
-endif
-endif
 
 # connection tracking
 obj-$(CONFIG_NF_CONNTRACK_IPV4) += nf_conntrack_ipv4.o
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index ae1a71a..870aebd 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -202,47 +202,6 @@ static struct nf_hook_ops ipv4_conntrack_ops[] __read_mostly = {
 	},
 };
 
-#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
-static int log_invalid_proto_min = 0;
-static int log_invalid_proto_max = 255;
-
-static struct ctl_table ip_ct_sysctl_table[] = {
-	{
-		.procname	= "ip_conntrack_max",
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "ip_conntrack_count",
-		.maxlen		= sizeof(int),
-		.mode		= 0444,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "ip_conntrack_buckets",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0444,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "ip_conntrack_checksum",
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "ip_conntrack_log_invalid",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &log_invalid_proto_min,
-		.extra2		= &log_invalid_proto_max,
-	},
-	{ }
-};
-#endif /* CONFIG_SYSCTL && CONFIG_NF_CONNTRACK_PROC_COMPAT */
-
 /* Fast function for those who don't want to parse /proc (and I don't
    blame them). */
 /* Reversing the socket's dst/src point of view gives us the reply
@@ -350,20 +309,6 @@ static struct nf_sockopt_ops so_getorigdst = {
 
 static int ipv4_init_net(struct net *net)
 {
-#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
-	struct nf_ip_net *in = &net->ct.nf_ct_proto;
-	in->ctl_table = kmemdup(ip_ct_sysctl_table,
-				sizeof(ip_ct_sysctl_table),
-				GFP_KERNEL);
-	if (!in->ctl_table)
-		return -ENOMEM;
-
-	in->ctl_table[0].data = &nf_conntrack_max;
-	in->ctl_table[1].data = &net->ct.count;
-	in->ctl_table[2].data = &nf_conntrack_htable_size;
-	in->ctl_table[3].data = &net->ct.sysctl_checksum;
-	in->ctl_table[4].data = &net->ct.sysctl_log_invalid;
-#endif
 	return 0;
 }
 
@@ -380,9 +325,6 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.nlattr_to_tuple = ipv4_nlattr_to_tuple,
 	.nla_policy	 = ipv4_nla_policy,
 #endif
-#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
-	.ctl_table_path  = "net/ipv4/netfilter",
-#endif
 	.init_net	 = ipv4_init_net,
 	.me		 = THIS_MODULE,
 };
@@ -492,16 +434,7 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 		goto cleanup_icmpv4;
 	}
 
-#if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
-	ret = nf_conntrack_ipv4_compat_init();
-	if (ret < 0)
-		goto cleanup_proto;
-#endif
 	return ret;
-#if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
- cleanup_proto:
-	nf_ct_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
-#endif
  cleanup_icmpv4:
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_icmp);
  cleanup_udp4:
@@ -520,9 +453,6 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 {
 	synchronize_net();
-#if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
-	nf_conntrack_ipv4_compat_fini();
-#endif
 	nf_ct_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_icmp);
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udp4);
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
deleted file mode 100644
index 67bfc69..0000000
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ /dev/null
@@ -1,491 +0,0 @@
-/* ip_conntrack proc compat - based on ip_conntrack_standalone.c
- *
- * (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
- * (C) 2006-2010 Patrick McHardy <kaber@trash.net>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-#include <linux/types.h>
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
-#include <linux/percpu.h>
-#include <linux/security.h>
-#include <net/net_namespace.h>
-
-#include <linux/netfilter.h>
-#include <net/netfilter/nf_conntrack_core.h>
-#include <net/netfilter/nf_conntrack_l3proto.h>
-#include <net/netfilter/nf_conntrack_l4proto.h>
-#include <net/netfilter/nf_conntrack_expect.h>
-#include <net/netfilter/nf_conntrack_acct.h>
-#include <linux/rculist_nulls.h>
-#include <linux/export.h>
-
-struct ct_iter_state {
-	struct seq_net_private p;
-	struct hlist_nulls_head *hash;
-	unsigned int htable_size;
-	unsigned int bucket;
-};
-
-static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
-{
-	struct ct_iter_state *st = seq->private;
-	struct hlist_nulls_node *n;
-
-	for (st->bucket = 0;
-	     st->bucket < st->htable_size;
-	     st->bucket++) {
-		n = rcu_dereference(
-			hlist_nulls_first_rcu(&st->hash[st->bucket]));
-		if (!is_a_nulls(n))
-			return n;
-	}
-	return NULL;
-}
-
-static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
-				      struct hlist_nulls_node *head)
-{
-	struct ct_iter_state *st = seq->private;
-
-	head = rcu_dereference(hlist_nulls_next_rcu(head));
-	while (is_a_nulls(head)) {
-		if (likely(get_nulls_value(head) == st->bucket)) {
-			if (++st->bucket >= st->htable_size)
-				return NULL;
-		}
-		head = rcu_dereference(
-			hlist_nulls_first_rcu(&st->hash[st->bucket]));
-	}
-	return head;
-}
-
-static struct hlist_nulls_node *ct_get_idx(struct seq_file *seq, loff_t pos)
-{
-	struct hlist_nulls_node *head = ct_get_first(seq);
-
-	if (head)
-		while (pos && (head = ct_get_next(seq, head)))
-			pos--;
-	return pos ? NULL : head;
-}
-
-static void *ct_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(RCU)
-{
-	struct ct_iter_state *st = seq->private;
-
-	rcu_read_lock();
-
-	nf_conntrack_get_ht(&st->hash, &st->htable_size);
-	return ct_get_idx(seq, *pos);
-}
-
-static void *ct_seq_next(struct seq_file *s, void *v, loff_t *pos)
-{
-	(*pos)++;
-	return ct_get_next(s, v);
-}
-
-static void ct_seq_stop(struct seq_file *s, void *v)
-	__releases(RCU)
-{
-	rcu_read_unlock();
-}
-
-#ifdef CONFIG_NF_CONNTRACK_SECMARK
-static void ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
-{
-	int ret;
-	u32 len;
-	char *secctx;
-
-	ret = security_secid_to_secctx(ct->secmark, &secctx, &len);
-	if (ret)
-		return;
-
-	seq_printf(s, "secctx=%s ", secctx);
-
-	security_release_secctx(secctx, len);
-}
-#else
-static inline void ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
-{
-}
-#endif
-
-static bool ct_seq_should_skip(const struct nf_conn *ct,
-			       const struct net *net,
-			       const struct nf_conntrack_tuple_hash *hash)
-{
-	/* we only want to print DIR_ORIGINAL */
-	if (NF_CT_DIRECTION(hash))
-		return true;
-
-	if (nf_ct_l3num(ct) != AF_INET)
-		return true;
-
-	if (!net_eq(nf_ct_net(ct), net))
-		return true;
-
-	return false;
-}
-
-static int ct_seq_show(struct seq_file *s, void *v)
-{
-	struct nf_conntrack_tuple_hash *hash = v;
-	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(hash);
-	const struct nf_conntrack_l3proto *l3proto;
-	const struct nf_conntrack_l4proto *l4proto;
-	int ret = 0;
-
-	NF_CT_ASSERT(ct);
-	if (ct_seq_should_skip(ct, seq_file_net(s), hash))
-		return 0;
-
-	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
-		return 0;
-
-	/* check if we raced w. object reuse */
-	if (!nf_ct_is_confirmed(ct) ||
-	    ct_seq_should_skip(ct, seq_file_net(s), hash))
-		goto release;
-
-	l3proto = __nf_ct_l3proto_find(nf_ct_l3num(ct));
-	NF_CT_ASSERT(l3proto);
-	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
-	NF_CT_ASSERT(l4proto);
-
-	ret = -ENOSPC;
-	seq_printf(s, "%-8s %u %ld ",
-		   l4proto->name, nf_ct_protonum(ct),
-		   nf_ct_expires(ct) / HZ);
-
-	if (l4proto->print_conntrack)
-		l4proto->print_conntrack(s, ct);
-
-	if (seq_has_overflowed(s))
-		goto release;
-
-	print_tuple(s, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
-		    l3proto, l4proto);
-
-	if (seq_has_overflowed(s))
-		goto release;
-
-	if (seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL))
-		goto release;
-
-	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
-		seq_printf(s, "[UNREPLIED] ");
-
-	print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
-		    l3proto, l4proto);
-
-	if (seq_has_overflowed(s))
-		goto release;
-
-	if (seq_print_acct(s, ct, IP_CT_DIR_REPLY))
-		goto release;
-
-	if (test_bit(IPS_ASSURED_BIT, &ct->status))
-		seq_printf(s, "[ASSURED] ");
-
-#ifdef CONFIG_NF_CONNTRACK_MARK
-	seq_printf(s, "mark=%u ", ct->mark);
-#endif
-
-	ct_show_secctx(s, ct);
-
-	seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use));
-
-	if (seq_has_overflowed(s))
-		goto release;
-
-	ret = 0;
-release:
-	nf_ct_put(ct);
-	return ret;
-}
-
-static const struct seq_operations ct_seq_ops = {
-	.start = ct_seq_start,
-	.next  = ct_seq_next,
-	.stop  = ct_seq_stop,
-	.show  = ct_seq_show
-};
-
-static int ct_open(struct inode *inode, struct file *file)
-{
-	return seq_open_net(inode, file, &ct_seq_ops,
-			    sizeof(struct ct_iter_state));
-}
-
-static const struct file_operations ct_file_ops = {
-	.owner   = THIS_MODULE,
-	.open    = ct_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = seq_release_net,
-};
-
-/* expects */
-struct ct_expect_iter_state {
-	struct seq_net_private p;
-	unsigned int bucket;
-};
-
-static struct hlist_node *ct_expect_get_first(struct seq_file *seq)
-{
-	struct ct_expect_iter_state *st = seq->private;
-	struct hlist_node *n;
-
-	for (st->bucket = 0; st->bucket < nf_ct_expect_hsize; st->bucket++) {
-		n = rcu_dereference(
-			hlist_first_rcu(&nf_ct_expect_hash[st->bucket]));
-		if (n)
-			return n;
-	}
-	return NULL;
-}
-
-static struct hlist_node *ct_expect_get_next(struct seq_file *seq,
-					     struct hlist_node *head)
-{
-	struct ct_expect_iter_state *st = seq->private;
-
-	head = rcu_dereference(hlist_next_rcu(head));
-	while (head == NULL) {
-		if (++st->bucket >= nf_ct_expect_hsize)
-			return NULL;
-		head = rcu_dereference(
-			hlist_first_rcu(&nf_ct_expect_hash[st->bucket]));
-	}
-	return head;
-}
-
-static struct hlist_node *ct_expect_get_idx(struct seq_file *seq, loff_t pos)
-{
-	struct hlist_node *head = ct_expect_get_first(seq);
-
-	if (head)
-		while (pos && (head = ct_expect_get_next(seq, head)))
-			pos--;
-	return pos ? NULL : head;
-}
-
-static void *exp_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(RCU)
-{
-	rcu_read_lock();
-	return ct_expect_get_idx(seq, *pos);
-}
-
-static void *exp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	(*pos)++;
-	return ct_expect_get_next(seq, v);
-}
-
-static void exp_seq_stop(struct seq_file *seq, void *v)
-	__releases(RCU)
-{
-	rcu_read_unlock();
-}
-
-static int exp_seq_show(struct seq_file *s, void *v)
-{
-	struct nf_conntrack_expect *exp;
-	const struct hlist_node *n = v;
-
-	exp = hlist_entry(n, struct nf_conntrack_expect, hnode);
-
-	if (!net_eq(nf_ct_net(exp->master), seq_file_net(s)))
-		return 0;
-
-	if (exp->tuple.src.l3num != AF_INET)
-		return 0;
-
-	if (exp->timeout.function)
-		seq_printf(s, "%ld ", timer_pending(&exp->timeout)
-			   ? (long)(exp->timeout.expires - jiffies)/HZ : 0);
-	else
-		seq_printf(s, "- ");
-
-	seq_printf(s, "proto=%u ", exp->tuple.dst.protonum);
-
-	print_tuple(s, &exp->tuple,
-		    __nf_ct_l3proto_find(exp->tuple.src.l3num),
-		    __nf_ct_l4proto_find(exp->tuple.src.l3num,
-					 exp->tuple.dst.protonum));
-	seq_putc(s, '\n');
-
-	return 0;
-}
-
-static const struct seq_operations exp_seq_ops = {
-	.start = exp_seq_start,
-	.next = exp_seq_next,
-	.stop = exp_seq_stop,
-	.show = exp_seq_show
-};
-
-static int exp_open(struct inode *inode, struct file *file)
-{
-	return seq_open_net(inode, file, &exp_seq_ops,
-			    sizeof(struct ct_expect_iter_state));
-}
-
-static const struct file_operations ip_exp_file_ops = {
-	.owner   = THIS_MODULE,
-	.open    = exp_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = seq_release_net,
-};
-
-static void *ct_cpu_seq_start(struct seq_file *seq, loff_t *pos)
-{
-	struct net *net = seq_file_net(seq);
-	int cpu;
-
-	if (*pos == 0)
-		return SEQ_START_TOKEN;
-
-	for (cpu = *pos-1; cpu < nr_cpu_ids; ++cpu) {
-		if (!cpu_possible(cpu))
-			continue;
-		*pos = cpu+1;
-		return per_cpu_ptr(net->ct.stat, cpu);
-	}
-
-	return NULL;
-}
-
-static void *ct_cpu_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	struct net *net = seq_file_net(seq);
-	int cpu;
-
-	for (cpu = *pos; cpu < nr_cpu_ids; ++cpu) {
-		if (!cpu_possible(cpu))
-			continue;
-		*pos = cpu+1;
-		return per_cpu_ptr(net->ct.stat, cpu);
-	}
-
-	return NULL;
-}
-
-static void ct_cpu_seq_stop(struct seq_file *seq, void *v)
-{
-}
-
-static int ct_cpu_seq_show(struct seq_file *seq, void *v)
-{
-	struct net *net = seq_file_net(seq);
-	unsigned int nr_conntracks = atomic_read(&net->ct.count);
-	const struct ip_conntrack_stat *st = v;
-
-	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  searched found new invalid ignore delete delete_list insert insert_failed drop early_drop icmp_error  expect_new expect_create expect_delete search_restart\n");
-		return 0;
-	}
-
-	seq_printf(seq, "%08x  %08x %08x %08x %08x %08x %08x %08x "
-			"%08x %08x %08x %08x %08x  %08x %08x %08x %08x\n",
-		   nr_conntracks,
-		   st->searched,
-		   st->found,
-		   st->new,
-		   st->invalid,
-		   st->ignore,
-		   st->delete,
-		   st->delete_list,
-		   st->insert,
-		   st->insert_failed,
-		   st->drop,
-		   st->early_drop,
-		   st->error,
-
-		   st->expect_new,
-		   st->expect_create,
-		   st->expect_delete,
-		   st->search_restart
-		);
-	return 0;
-}
-
-static const struct seq_operations ct_cpu_seq_ops = {
-	.start  = ct_cpu_seq_start,
-	.next   = ct_cpu_seq_next,
-	.stop   = ct_cpu_seq_stop,
-	.show   = ct_cpu_seq_show,
-};
-
-static int ct_cpu_seq_open(struct inode *inode, struct file *file)
-{
-	return seq_open_net(inode, file, &ct_cpu_seq_ops,
-			    sizeof(struct seq_net_private));
-}
-
-static const struct file_operations ct_cpu_seq_fops = {
-	.owner   = THIS_MODULE,
-	.open    = ct_cpu_seq_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = seq_release_net,
-};
-
-static int __net_init ip_conntrack_net_init(struct net *net)
-{
-	struct proc_dir_entry *proc, *proc_exp, *proc_stat;
-
-	proc = proc_create("ip_conntrack", 0440, net->proc_net, &ct_file_ops);
-	if (!proc)
-		goto err1;
-
-	proc_exp = proc_create("ip_conntrack_expect", 0440, net->proc_net,
-			       &ip_exp_file_ops);
-	if (!proc_exp)
-		goto err2;
-
-	proc_stat = proc_create("ip_conntrack", S_IRUGO,
-				net->proc_net_stat, &ct_cpu_seq_fops);
-	if (!proc_stat)
-		goto err3;
-	return 0;
-
-err3:
-	remove_proc_entry("ip_conntrack_expect", net->proc_net);
-err2:
-	remove_proc_entry("ip_conntrack", net->proc_net);
-err1:
-	return -ENOMEM;
-}
-
-static void __net_exit ip_conntrack_net_exit(struct net *net)
-{
-	remove_proc_entry("ip_conntrack", net->proc_net_stat);
-	remove_proc_entry("ip_conntrack_expect", net->proc_net);
-	remove_proc_entry("ip_conntrack", net->proc_net);
-}
-
-static struct pernet_operations ip_conntrack_net_ops = {
-	.init = ip_conntrack_net_init,
-	.exit = ip_conntrack_net_exit,
-};
-
-int __init nf_conntrack_ipv4_compat_init(void)
-{
-	return register_pernet_subsys(&ip_conntrack_net_ops);
-}
-
-void __exit nf_conntrack_ipv4_compat_fini(void)
-{
-	unregister_pernet_subsys(&ip_conntrack_net_ops);
-}
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index c567e1b..4b5904b 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -327,17 +327,6 @@ static struct ctl_table icmp_sysctl_table[] = {
 	},
 	{ }
 };
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-static struct ctl_table icmp_compat_sysctl_table[] = {
-	{
-		.procname	= "ip_conntrack_icmp_timeout",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{ }
-};
-#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
 static int icmp_kmemdup_sysctl_table(struct nf_proto_net *pn,
@@ -355,40 +344,14 @@ static int icmp_kmemdup_sysctl_table(struct nf_proto_net *pn,
 	return 0;
 }
 
-static int icmp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
-					    struct nf_icmp_net *in)
-{
-#ifdef CONFIG_SYSCTL
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	pn->ctl_compat_table = kmemdup(icmp_compat_sysctl_table,
-				       sizeof(icmp_compat_sysctl_table),
-				       GFP_KERNEL);
-	if (!pn->ctl_compat_table)
-		return -ENOMEM;
-
-	pn->ctl_compat_table[0].data = &in->timeout;
-#endif
-#endif
-	return 0;
-}
-
 static int icmp_init_net(struct net *net, u_int16_t proto)
 {
-	int ret;
 	struct nf_icmp_net *in = icmp_pernet(net);
 	struct nf_proto_net *pn = &in->pn;
 
 	in->timeout = nf_ct_icmp_timeout;
 
-	ret = icmp_kmemdup_compat_sysctl_table(pn, in);
-	if (ret < 0)
-		return ret;
-
-	ret = icmp_kmemdup_sysctl_table(pn, in);
-	if (ret < 0)
-		nf_ct_kfree_compat_sysctl_table(pn);
-
-	return ret;
+	return icmp_kmemdup_sysctl_table(pn, in);
 }
 
 static struct nf_proto_net *icmp_get_net_proto(struct net *net)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index dd2c43a..22558b7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -161,10 +161,7 @@ static void nf_conntrack_all_unlock(void)
 }
 
 unsigned int nf_conntrack_htable_size __read_mostly;
-EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
-
 unsigned int nf_conntrack_max __read_mostly;
-EXPORT_SYMBOL_GPL(nf_conntrack_max);
 
 DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index b65d586..8d2c7d8 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -159,54 +159,6 @@ static int kill_l4proto(struct nf_conn *i, void *data)
 	       nf_ct_l3num(i) == l4proto->l3proto;
 }
 
-static struct nf_ip_net *nf_ct_l3proto_net(struct net *net,
-					   struct nf_conntrack_l3proto *l3proto)
-{
-	if (l3proto->l3proto == PF_INET)
-		return &net->ct.nf_ct_proto;
-	else
-		return NULL;
-}
-
-static int nf_ct_l3proto_register_sysctl(struct net *net,
-					 struct nf_conntrack_l3proto *l3proto)
-{
-	int err = 0;
-	struct nf_ip_net *in = nf_ct_l3proto_net(net, l3proto);
-	/* nf_conntrack_l3proto_ipv6 doesn't support sysctl */
-	if (in == NULL)
-		return 0;
-
-#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
-	if (in->ctl_table != NULL) {
-		err = nf_ct_register_sysctl(net,
-					    &in->ctl_table_header,
-					    l3proto->ctl_table_path,
-					    in->ctl_table);
-		if (err < 0) {
-			kfree(in->ctl_table);
-			in->ctl_table = NULL;
-		}
-	}
-#endif
-	return err;
-}
-
-static void nf_ct_l3proto_unregister_sysctl(struct net *net,
-					    struct nf_conntrack_l3proto *l3proto)
-{
-	struct nf_ip_net *in = nf_ct_l3proto_net(net, l3proto);
-
-	if (in == NULL)
-		return;
-#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
-	if (in->ctl_table_header != NULL)
-		nf_ct_unregister_sysctl(&in->ctl_table_header,
-					&in->ctl_table,
-					0);
-#endif
-}
-
 int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto)
 {
 	int ret = 0;
@@ -241,7 +193,7 @@ EXPORT_SYMBOL_GPL(nf_ct_l3proto_register);
 int nf_ct_l3proto_pernet_register(struct net *net,
 				  struct nf_conntrack_l3proto *proto)
 {
-	int ret = 0;
+	int ret;
 
 	if (proto->init_net) {
 		ret = proto->init_net(net);
@@ -249,7 +201,7 @@ int nf_ct_l3proto_pernet_register(struct net *net,
 			return ret;
 	}
 
-	return nf_ct_l3proto_register_sysctl(net, proto);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_pernet_register);
 
@@ -272,8 +224,6 @@ EXPORT_SYMBOL_GPL(nf_ct_l3proto_unregister);
 void nf_ct_l3proto_pernet_unregister(struct net *net,
 				     struct nf_conntrack_l3proto *proto)
 {
-	nf_ct_l3proto_unregister_sysctl(net, proto);
-
 	/* Remove all contrack entries for this protocol */
 	nf_ct_iterate_cleanup(net, kill_l3proto, proto, 0, 0);
 }
@@ -312,26 +262,6 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
 			}
 		}
 	}
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	if (l4proto->l3proto != AF_INET6 && pn->ctl_compat_table != NULL) {
-		if (err < 0) {
-			nf_ct_kfree_compat_sysctl_table(pn);
-			goto out;
-		}
-		err = nf_ct_register_sysctl(net,
-					    &pn->ctl_compat_header,
-					    "net/ipv4/netfilter",
-					    pn->ctl_compat_table);
-		if (err == 0)
-			goto out;
-
-		nf_ct_kfree_compat_sysctl_table(pn);
-		nf_ct_unregister_sysctl(&pn->ctl_table_header,
-					&pn->ctl_table,
-					pn->users);
-	}
-out:
-#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 	return err;
 }
@@ -346,13 +276,6 @@ void nf_ct_l4proto_unregister_sysctl(struct net *net,
 		nf_ct_unregister_sysctl(&pn->ctl_table_header,
 					&pn->ctl_table,
 					pn->users);
-
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	if (l4proto->l3proto != AF_INET6 && pn->ctl_compat_header != NULL)
-		nf_ct_unregister_sysctl(&pn->ctl_compat_header,
-					&pn->ctl_compat_table,
-					0);
-#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 86dc752..d5868ba 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -151,17 +151,6 @@ static struct ctl_table generic_sysctl_table[] = {
 	},
 	{ }
 };
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-static struct ctl_table generic_compat_sysctl_table[] = {
-	{
-		.procname	= "ip_conntrack_generic_timeout",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{ }
-};
-#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
 static int generic_kmemdup_sysctl_table(struct nf_proto_net *pn,
@@ -179,40 +168,14 @@ static int generic_kmemdup_sysctl_table(struct nf_proto_net *pn,
 	return 0;
 }
 
-static int generic_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
-					       struct nf_generic_net *gn)
-{
-#ifdef CONFIG_SYSCTL
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	pn->ctl_compat_table = kmemdup(generic_compat_sysctl_table,
-				       sizeof(generic_compat_sysctl_table),
-				       GFP_KERNEL);
-	if (!pn->ctl_compat_table)
-		return -ENOMEM;
-
-	pn->ctl_compat_table[0].data = &gn->timeout;
-#endif
-#endif
-	return 0;
-}
-
 static int generic_init_net(struct net *net, u_int16_t proto)
 {
-	int ret;
 	struct nf_generic_net *gn = generic_pernet(net);
 	struct nf_proto_net *pn = &gn->pn;
 
 	gn->timeout = nf_ct_generic_timeout;
 
-	ret = generic_kmemdup_compat_sysctl_table(pn, gn);
-	if (ret < 0)
-		return ret;
-
-	ret = generic_kmemdup_sysctl_table(pn, gn);
-	if (ret < 0)
-		nf_ct_kfree_compat_sysctl_table(pn);
-
-	return ret;
+	return generic_kmemdup_sysctl_table(pn, gn);
 }
 
 static struct nf_proto_net *generic_get_net_proto(struct net *net)
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index e769f05..982ea62 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -705,54 +705,6 @@ static struct ctl_table sctp_sysctl_table[] = {
 	},
 	{ }
 };
-
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-static struct ctl_table sctp_compat_sysctl_table[] = {
-	{
-		.procname	= "ip_conntrack_sctp_timeout_closed",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_sctp_timeout_cookie_wait",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_sctp_timeout_cookie_echoed",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_sctp_timeout_established",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_sctp_timeout_shutdown_sent",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_sctp_timeout_shutdown_recd",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_sctp_timeout_shutdown_ack_sent",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{ }
-};
-#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif
 
 static int sctp_kmemdup_sysctl_table(struct nf_proto_net *pn,
@@ -781,32 +733,8 @@ static int sctp_kmemdup_sysctl_table(struct nf_proto_net *pn,
 	return 0;
 }
 
-static int sctp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
-					    struct sctp_net *sn)
-{
-#ifdef CONFIG_SYSCTL
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	pn->ctl_compat_table = kmemdup(sctp_compat_sysctl_table,
-				       sizeof(sctp_compat_sysctl_table),
-				       GFP_KERNEL);
-	if (!pn->ctl_compat_table)
-		return -ENOMEM;
-
-	pn->ctl_compat_table[0].data = &sn->timeouts[SCTP_CONNTRACK_CLOSED];
-	pn->ctl_compat_table[1].data = &sn->timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
-	pn->ctl_compat_table[2].data = &sn->timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
-	pn->ctl_compat_table[3].data = &sn->timeouts[SCTP_CONNTRACK_ESTABLISHED];
-	pn->ctl_compat_table[4].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
-	pn->ctl_compat_table[5].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
-	pn->ctl_compat_table[6].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
-#endif
-#endif
-	return 0;
-}
-
 static int sctp_init_net(struct net *net, u_int16_t proto)
 {
-	int ret;
 	struct sctp_net *sn = sctp_pernet(net);
 	struct nf_proto_net *pn = &sn->pn;
 
@@ -817,18 +745,7 @@ static int sctp_init_net(struct net *net, u_int16_t proto)
 			sn->timeouts[i] = sctp_timeouts[i];
 	}
 
-	if (proto == AF_INET) {
-		ret = sctp_kmemdup_compat_sysctl_table(pn, sn);
-		if (ret < 0)
-			return ret;
-
-		ret = sctp_kmemdup_sysctl_table(pn, sn);
-		if (ret < 0)
-			nf_ct_kfree_compat_sysctl_table(pn);
-	} else
-		ret = sctp_kmemdup_sysctl_table(pn, sn);
-
-	return ret;
+	return sctp_kmemdup_sysctl_table(pn, sn);
 }
 
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 4abe9e1..69f6877 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1481,90 +1481,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 	},
 	{ }
 };
-
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-static struct ctl_table tcp_compat_sysctl_table[] = {
-	{
-		.procname	= "ip_conntrack_tcp_timeout_syn_sent",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_syn_sent2",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_syn_recv",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_established",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_fin_wait",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_close_wait",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_last_ack",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_time_wait",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_close",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_max_retrans",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_loose",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_be_liberal",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_max_retrans",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{ }
-};
-#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
 static int tcp_kmemdup_sysctl_table(struct nf_proto_net *pn,
@@ -1597,38 +1513,8 @@ static int tcp_kmemdup_sysctl_table(struct nf_proto_net *pn,
 	return 0;
 }
 
-static int tcp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
-					   struct nf_tcp_net *tn)
-{
-#ifdef CONFIG_SYSCTL
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	pn->ctl_compat_table = kmemdup(tcp_compat_sysctl_table,
-				       sizeof(tcp_compat_sysctl_table),
-				       GFP_KERNEL);
-	if (!pn->ctl_compat_table)
-		return -ENOMEM;
-
-	pn->ctl_compat_table[0].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
-	pn->ctl_compat_table[1].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT2];
-	pn->ctl_compat_table[2].data = &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
-	pn->ctl_compat_table[3].data = &tn->timeouts[TCP_CONNTRACK_ESTABLISHED];
-	pn->ctl_compat_table[4].data = &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
-	pn->ctl_compat_table[5].data = &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT];
-	pn->ctl_compat_table[6].data = &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
-	pn->ctl_compat_table[7].data = &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
-	pn->ctl_compat_table[8].data = &tn->timeouts[TCP_CONNTRACK_CLOSE];
-	pn->ctl_compat_table[9].data = &tn->timeouts[TCP_CONNTRACK_RETRANS];
-	pn->ctl_compat_table[10].data = &tn->tcp_loose;
-	pn->ctl_compat_table[11].data = &tn->tcp_be_liberal;
-	pn->ctl_compat_table[12].data = &tn->tcp_max_retrans;
-#endif
-#endif
-	return 0;
-}
-
 static int tcp_init_net(struct net *net, u_int16_t proto)
 {
-	int ret;
 	struct nf_tcp_net *tn = tcp_pernet(net);
 	struct nf_proto_net *pn = &tn->pn;
 
@@ -1643,18 +1529,7 @@ static int tcp_init_net(struct net *net, u_int16_t proto)
 		tn->tcp_max_retrans = nf_ct_tcp_max_retrans;
 	}
 
-	if (proto == AF_INET) {
-		ret = tcp_kmemdup_compat_sysctl_table(pn, tn);
-		if (ret < 0)
-			return ret;
-
-		ret = tcp_kmemdup_sysctl_table(pn, tn);
-		if (ret < 0)
-			nf_ct_kfree_compat_sysctl_table(pn);
-	} else
-		ret = tcp_kmemdup_sysctl_table(pn, tn);
-
-	return ret;
+	return tcp_kmemdup_sysctl_table(pn, tn);
 }
 
 static struct nf_proto_net *tcp_get_net_proto(struct net *net)
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 8a057e1..20f35ed 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -218,23 +218,6 @@ static struct ctl_table udp_sysctl_table[] = {
 	},
 	{ }
 };
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-static struct ctl_table udp_compat_sysctl_table[] = {
-	{
-		.procname	= "ip_conntrack_udp_timeout",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_udp_timeout_stream",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{ }
-};
-#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
 static int udp_kmemdup_sysctl_table(struct nf_proto_net *pn,
@@ -254,27 +237,8 @@ static int udp_kmemdup_sysctl_table(struct nf_proto_net *pn,
 	return 0;
 }
 
-static int udp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
-					   struct nf_udp_net *un)
-{
-#ifdef CONFIG_SYSCTL
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	pn->ctl_compat_table = kmemdup(udp_compat_sysctl_table,
-				       sizeof(udp_compat_sysctl_table),
-				       GFP_KERNEL);
-	if (!pn->ctl_compat_table)
-		return -ENOMEM;
-
-	pn->ctl_compat_table[0].data = &un->timeouts[UDP_CT_UNREPLIED];
-	pn->ctl_compat_table[1].data = &un->timeouts[UDP_CT_REPLIED];
-#endif
-#endif
-	return 0;
-}
-
 static int udp_init_net(struct net *net, u_int16_t proto)
 {
-	int ret;
 	struct nf_udp_net *un = udp_pernet(net);
 	struct nf_proto_net *pn = &un->pn;
 
@@ -285,18 +249,7 @@ static int udp_init_net(struct net *net, u_int16_t proto)
 			un->timeouts[i] = udp_timeouts[i];
 	}
 
-	if (proto == AF_INET) {
-		ret = udp_kmemdup_compat_sysctl_table(pn, un);
-		if (ret < 0)
-			return ret;
-
-		ret = udp_kmemdup_sysctl_table(pn, un);
-		if (ret < 0)
-			nf_ct_kfree_compat_sysctl_table(pn);
-	} else
-		ret = udp_kmemdup_sysctl_table(pn, un);
-
-	return ret;
+	return udp_kmemdup_sysctl_table(pn, un);
 }
 
 static struct nf_proto_net *udp_get_net_proto(struct net *net)
-- 
2.1.4

