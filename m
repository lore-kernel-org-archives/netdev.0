From: kaber@trash.net
Subject: [PATCH 5/6] ipv6: ip6mr: support multiple tables
Date: Tue, 11 May 2010 16:02:30 +0200
Message-ID: <1273586551-3521-6-git-send-email-kaber@trash.net>
References: <1273586551-3521-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40384 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758038Ab0EKOCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 10:02:37 -0400
In-Reply-To: <1273586551-3521-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

This patch adds support for multiple independant multicast routing instances,
named "tables".

Userspace multicast routing daemons can bind to a specific table instance by
issuing a setsockopt call using a new option MRT6_TABLE. The table number is
stored in the raw socket data and affects all following ip6mr setsockopt(),
getsockopt() and ioctl() calls. By default, a single table (RT6_TABLE_DFLT)
is created with a default routing rule pointing to it. Newly created pim6reg
devices have the table number appended ("pim6regX"), with the exception of
devices created in the default table, which are named just "pim6reg" for
compatibility reasons.

Packets are directed to a specific table instance using routing rules,
similar to how regular routing rules work. Currently iif, oif and mark
are supported as keys, source and destination addresses could be supported
additionally.

Example usage:

- bind pimd/xorp/... to a specific table:

uint32_t table = 123;
setsockopt(fd, SOL_IPV6, MRT6_TABLE, &table, sizeof(table));

- create routing rules directing packets to the new table:

# ip -6 mrule add iif eth0 lookup 123
# ip -6 mrule add oif eth0 lookup 123

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/ipv6.h      |    1 +
 include/linux/mroute6.h   |   15 ++-
 include/linux/rtnetlink.h |    3 +-
 include/net/netns/ipv6.h  |    5 +
 net/ipv6/Kconfig          |   14 ++
 net/ipv6/ip6_output.c     |    2 +-
 net/ipv6/ip6mr.c          |  428 ++++++++++++++++++++++++++++++++++++++-------
 7 files changed, 396 insertions(+), 72 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 0e26903..99e1ab7 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -383,6 +383,7 @@ struct raw6_sock {
 	__u32			checksum;	/* perform checksum */
 	__u32			offset;		/* checksum offset  */
 	struct icmp6_filter	filter;
+	__u32			ip6mr_table;
 	/* ipv6_pinfo has to be the last member of raw6_sock, see inet6_sk_generic */
 	struct ipv6_pinfo	inet6;
 };
diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index 0370dd4..6091ab7 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -24,7 +24,8 @@
 #define MRT6_DEL_MFC	(MRT6_BASE+5)	/* Delete a multicast forwarding entry	*/
 #define MRT6_VERSION	(MRT6_BASE+6)	/* Get the kernel multicast version	*/
 #define MRT6_ASSERT	(MRT6_BASE+7)	/* Activate PIM assert mode		*/
-#define MRT6_PIM	(MRT6_BASE+8)	/* enable PIM code	*/
+#define MRT6_PIM	(MRT6_BASE+8)	/* enable PIM code			*/
+#define MRT6_TABLE	(MRT6_BASE+9)	/* Specify mroute table ID		*/
 
 #define SIOCGETMIFCNT_IN6	SIOCPROTOPRIVATE	/* IP protocol privates */
 #define SIOCGETSGCNT_IN6	(SIOCPROTOPRIVATE+1)
@@ -229,11 +230,17 @@ extern int ip6mr_get_route(struct net *net, struct sk_buff *skb,
 			   struct rtmsg *rtm, int nowait);
 
 #ifdef CONFIG_IPV6_MROUTE
-extern struct sock *mroute6_socket(struct net *net);
+extern struct sock *mroute6_socket(struct net *net, struct sk_buff *skb);
 extern int ip6mr_sk_done(struct sock *sk);
 #else
-static inline struct sock *mroute6_socket(struct net *net) { return NULL; }
-static inline int ip6mr_sk_done(struct sock *sk) { return 0; }
+static inline struct sock *mroute6_socket(struct net *net, struct sk_buff *skb)
+{
+	return NULL;
+}
+static inline int ip6mr_sk_done(struct sock *sk)
+{
+	return 0;
+}
 #endif
 #endif
 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 5a42c36..fbc8cb0 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -11,7 +11,8 @@
  * families, values above 128 may be used arbitrarily.
  */
 #define RTNL_FAMILY_IPMR		128
-#define RTNL_FAMILY_MAX			128
+#define RTNL_FAMILY_IP6MR		129
+#define RTNL_FAMILY_MAX			129
 
 /****
  *		Routing/neighbour discovery messages.
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 4e2780e..81abfcb 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -59,7 +59,12 @@ struct netns_ipv6 {
 	struct sock             *tcp_sk;
 	struct sock             *igmp_sk;
 #ifdef CONFIG_IPV6_MROUTE
+#ifndef CONFIG_IPV6_MROUTE_MULTIPLE_TABLES
 	struct mr6_table	*mrt6;
+#else
+	struct list_head	mr6_tables;
+	struct fib_rules_ops	*mr6_rules_ops;
+#endif
 #endif
 };
 #endif
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index a578096..36d7437 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -229,6 +229,20 @@ config IPV6_MROUTE
 	  Experimental support for IPv6 multicast forwarding.
 	  If unsure, say N.
 
+config IPV6_MROUTE_MULTIPLE_TABLES
+	bool "IPv6: multicast policy routing"
+	depends on IPV6_MROUTE
+	select FIB_RULES
+	help
+	  Normally, a multicast router runs a userspace daemon and decides
+	  what to do with a multicast packet based on the source and
+	  destination addresses. If you say Y here, the multicast router
+	  will also be able to take interfaces and packet marks into
+	  account and run multiple instances of userspace daemons
+	  simultaneously, each one handling a single table.
+
+	  If unsure, say N.
+
 config IPV6_PIMSM_V2
 	bool "IPv6: PIM-SM version 2 support (EXPERIMENTAL)"
 	depends on IPV6_MROUTE
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 5173aca..cd963f6 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -108,7 +108,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
 		if (!(dev->flags & IFF_LOOPBACK) && sk_mc_loop(skb->sk) &&
-		    ((mroute6_socket(dev_net(dev)) &&
+		    ((mroute6_socket(dev_net(dev), skb) &&
 		     !(IP6CB(skb)->flags & IP6SKB_FORWARDED)) ||
 		     ipv6_chk_mcast_addr(dev, &ipv6_hdr(skb)->daddr,
 					 &ipv6_hdr(skb)->saddr))) {
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 9419fce..c2920a1 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -42,6 +42,7 @@
 #include <linux/if_arp.h>
 #include <net/checksum.h>
 #include <net/netlink.h>
+#include <net/fib_rules.h>
 
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
@@ -52,9 +53,11 @@
 #include <net/ip6_checksum.h>
 
 struct mr6_table {
+	struct list_head	list;
 #ifdef CONFIG_NET_NS
 	struct net		*net;
 #endif
+	u32			id;
 	struct sock		*mroute6_sk;
 	struct timer_list	ipmr_expire_timer;
 	struct list_head	mfc6_unres_queue;
@@ -69,6 +72,14 @@ struct mr6_table {
 #endif
 };
 
+struct ip6mr_rule {
+	struct fib_rule		common;
+};
+
+struct ip6mr_result {
+	struct mr6_table	*mrt;
+};
+
 /* Big lock, protecting vif table, mrt cache and mroute socket state.
    Note that the changes are semaphored via rtnl_lock.
  */
@@ -94,6 +105,9 @@ static DEFINE_SPINLOCK(mfc_unres_lock);
 
 static struct kmem_cache *mrt_cachep __read_mostly;
 
+static struct mr6_table *ip6mr_new_table(struct net *net, u32 id);
+static void ip6mr_free_table(struct mr6_table *mrt);
+
 static int ip6_mr_forward(struct net *net, struct mr6_table *mrt,
 			  struct sk_buff *skb, struct mfc6_cache *cache);
 static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
@@ -101,12 +115,220 @@ static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
 static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 			     struct mfc6_cache *c, struct rtmsg *rtm);
 static void mroute_clean_tables(struct mr6_table *mrt);
+static void ipmr_expire_process(unsigned long arg);
+
+#ifdef CONFIG_IPV6_MROUTE_MULTIPLE_TABLES
+#define ip6mr_for_each_table(mrt, met) \
+	list_for_each_entry_rcu(mrt, &net->ipv6.mr6_tables, list)
+
+static struct mr6_table *ip6mr_get_table(struct net *net, u32 id)
+{
+	struct mr6_table *mrt;
 
+	ip6mr_for_each_table(mrt, net) {
+		if (mrt->id == id)
+			return mrt;
+	}
+	return NULL;
+}
+
+static int ip6mr_fib_lookup(struct net *net, struct flowi *flp,
+			    struct mr6_table **mrt)
+{
+	struct ip6mr_result res;
+	struct fib_lookup_arg arg = { .result = &res, };
+	int err;
+
+	err = fib_rules_lookup(net->ipv6.mr6_rules_ops, flp, 0, &arg);
+	if (err < 0)
+		return err;
+	*mrt = res.mrt;
+	return 0;
+}
+
+static int ip6mr_rule_action(struct fib_rule *rule, struct flowi *flp,
+			     int flags, struct fib_lookup_arg *arg)
+{
+	struct ip6mr_result *res = arg->result;
+	struct mr6_table *mrt;
+
+	switch (rule->action) {
+	case FR_ACT_TO_TBL:
+		break;
+	case FR_ACT_UNREACHABLE:
+		return -ENETUNREACH;
+	case FR_ACT_PROHIBIT:
+		return -EACCES;
+	case FR_ACT_BLACKHOLE:
+	default:
+		return -EINVAL;
+	}
+
+	mrt = ip6mr_get_table(rule->fr_net, rule->table);
+	if (mrt == NULL)
+		return -EAGAIN;
+	res->mrt = mrt;
+	return 0;
+}
+
+static int ip6mr_rule_match(struct fib_rule *rule, struct flowi *flp, int flags)
+{
+	return 1;
+}
+
+static const struct nla_policy ip6mr_rule_policy[FRA_MAX + 1] = {
+	FRA_GENERIC_POLICY,
+};
+
+static int ip6mr_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
+				struct fib_rule_hdr *frh, struct nlattr **tb)
+{
+	return 0;
+}
+
+static int ip6mr_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
+			      struct nlattr **tb)
+{
+	return 1;
+}
+
+static int ip6mr_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
+			   struct fib_rule_hdr *frh)
+{
+	frh->dst_len = 0;
+	frh->src_len = 0;
+	frh->tos     = 0;
+	return 0;
+}
+
+static const struct fib_rules_ops __net_initdata ip6mr_rules_ops_template = {
+	.family		= RTNL_FAMILY_IP6MR,
+	.rule_size	= sizeof(struct ip6mr_rule),
+	.addr_size	= sizeof(struct in6_addr),
+	.action		= ip6mr_rule_action,
+	.match		= ip6mr_rule_match,
+	.configure	= ip6mr_rule_configure,
+	.compare	= ip6mr_rule_compare,
+	.default_pref	= fib_default_rule_pref,
+	.fill		= ip6mr_rule_fill,
+	.nlgroup	= RTNLGRP_IPV6_RULE,
+	.policy		= ip6mr_rule_policy,
+	.owner		= THIS_MODULE,
+};
+
+static int __net_init ip6mr_rules_init(struct net *net)
+{
+	struct fib_rules_ops *ops;
+	struct mr6_table *mrt;
+	int err;
+
+	ops = fib_rules_register(&ip6mr_rules_ops_template, net);
+	if (IS_ERR(ops))
+		return PTR_ERR(ops);
+
+	INIT_LIST_HEAD(&net->ipv6.mr6_tables);
+
+	mrt = ip6mr_new_table(net, RT6_TABLE_DFLT);
+	if (mrt == NULL) {
+		err = -ENOMEM;
+		goto err1;
+	}
+
+	err = fib_default_rule_add(ops, 0x7fff, RT6_TABLE_DFLT, 0);
+	if (err < 0)
+		goto err2;
+
+	net->ipv6.mr6_rules_ops = ops;
+	return 0;
+
+err2:
+	kfree(mrt);
+err1:
+	fib_rules_unregister(ops);
+	return err;
+}
+
+static void __net_exit ip6mr_rules_exit(struct net *net)
+{
+	struct mr6_table *mrt, *next;
+
+	list_for_each_entry_safe(mrt, next, &net->ipv6.mr6_tables, list)
+		ip6mr_free_table(mrt);
+	fib_rules_unregister(net->ipv6.mr6_rules_ops);
+}
+#else
+#define ip6mr_for_each_table(mrt, net) \
+	for (mrt = net->ipv6.mrt6; mrt; mrt = NULL)
+
+static struct mr6_table *ip6mr_get_table(struct net *net, u32 id)
+{
+	return net->ipv6.mrt6;
+}
+
+static int ip6mr_fib_lookup(struct net *net, struct flowi *flp,
+			    struct mr6_table **mrt)
+{
+	*mrt = net->ipv6.mrt6;
+	return 0;
+}
+
+static int __net_init ip6mr_rules_init(struct net *net)
+{
+	net->ipv6.mrt6 = ip6mr_new_table(net, RT6_TABLE_DFLT);
+	return net->ipv6.mrt6 ? 0 : -ENOMEM;
+}
+
+static void __net_exit ip6mr_rules_exit(struct net *net)
+{
+	ip6mr_free_table(net->ipv6.mrt6);
+}
+#endif
+
+static struct mr6_table *ip6mr_new_table(struct net *net, u32 id)
+{
+	struct mr6_table *mrt;
+	unsigned int i;
+
+	mrt = ip6mr_get_table(net, id);
+	if (mrt != NULL)
+		return mrt;
+
+	mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
+	if (mrt == NULL)
+		return NULL;
+	mrt->id = id;
+	write_pnet(&mrt->net, net);
+
+	/* Forwarding cache */
+	for (i = 0; i < MFC6_LINES; i++)
+		INIT_LIST_HEAD(&mrt->mfc6_cache_array[i]);
+
+	INIT_LIST_HEAD(&mrt->mfc6_unres_queue);
+
+	setup_timer(&mrt->ipmr_expire_timer, ipmr_expire_process,
+		    (unsigned long)mrt);
+
+#ifdef CONFIG_IPV6_PIMSM_V2
+	mrt->mroute_reg_vif_num = -1;
+#endif
+#ifdef CONFIG_IPV6_MROUTE_MULTIPLE_TABLES
+	list_add_tail_rcu(&mrt->list, &net->ipv6.mr6_tables);
+#endif
+	return mrt;
+}
+
+static void ip6mr_free_table(struct mr6_table *mrt)
+{
+	del_timer(&mrt->ipmr_expire_timer);
+	mroute_clean_tables(mrt);
+	kfree(mrt);
+}
 
 #ifdef CONFIG_PROC_FS
 
 struct ipmr_mfc_iter {
 	struct seq_net_private p;
+	struct mr6_table *mrt;
 	struct list_head *cache;
 	int ct;
 };
@@ -115,7 +337,7 @@ struct ipmr_mfc_iter {
 static struct mfc6_cache *ipmr_mfc_seq_idx(struct net *net,
 					   struct ipmr_mfc_iter *it, loff_t pos)
 {
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt = it->mrt;
 	struct mfc6_cache *mfc;
 
 	read_lock(&mrt_lock);
@@ -144,6 +366,7 @@ static struct mfc6_cache *ipmr_mfc_seq_idx(struct net *net,
 
 struct ipmr_vif_iter {
 	struct seq_net_private p;
+	struct mr6_table *mrt;
 	int ct;
 };
 
@@ -151,7 +374,7 @@ static struct mif_device *ip6mr_vif_seq_idx(struct net *net,
 					    struct ipmr_vif_iter *iter,
 					    loff_t pos)
 {
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt = iter->mrt;
 
 	for (iter->ct = 0; iter->ct < mrt->maxvif; ++iter->ct) {
 		if (!MIF_EXISTS(mrt, iter->ct))
@@ -165,7 +388,15 @@ static struct mif_device *ip6mr_vif_seq_idx(struct net *net,
 static void *ip6mr_vif_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(mrt_lock)
 {
+	struct ipmr_vif_iter *iter = seq->private;
 	struct net *net = seq_file_net(seq);
+	struct mr6_table *mrt;
+
+	mrt = ip6mr_get_table(net, RT6_TABLE_DFLT);
+	if (mrt == NULL)
+		return ERR_PTR(-ENOENT);
+
+	iter->mrt = mrt;
 
 	read_lock(&mrt_lock);
 	return *pos ? ip6mr_vif_seq_idx(net, seq->private, *pos - 1)
@@ -176,7 +407,7 @@ static void *ip6mr_vif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ipmr_vif_iter *iter = seq->private;
 	struct net *net = seq_file_net(seq);
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt = iter->mrt;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
@@ -198,8 +429,8 @@ static void ip6mr_vif_seq_stop(struct seq_file *seq, void *v)
 
 static int ip6mr_vif_seq_show(struct seq_file *seq, void *v)
 {
-	struct net *net = seq_file_net(seq);
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct ipmr_vif_iter *iter = seq->private;
+	struct mr6_table *mrt = iter->mrt;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
@@ -241,8 +472,15 @@ static const struct file_operations ip6mr_vif_fops = {
 
 static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
 {
+	struct ipmr_mfc_iter *it = seq->private;
 	struct net *net = seq_file_net(seq);
+	struct mr6_table *mrt;
+
+	mrt = ip6mr_get_table(net, RT6_TABLE_DFLT);
+	if (mrt == NULL)
+		return ERR_PTR(-ENOENT);
 
+	it->mrt = mrt;
 	return *pos ? ipmr_mfc_seq_idx(net, seq->private, *pos - 1)
 		: SEQ_START_TOKEN;
 }
@@ -252,7 +490,7 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	struct mfc6_cache *mfc = v;
 	struct ipmr_mfc_iter *it = seq->private;
 	struct net *net = seq_file_net(seq);
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt = it->mrt;
 
 	++*pos;
 
@@ -293,8 +531,7 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 {
 	struct ipmr_mfc_iter *it = seq->private;
-	struct net *net = seq_file_net(seq);
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt = it->mrt;
 
 	if (it->cache == &mrt->mfc6_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
@@ -305,8 +542,6 @@ static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 {
 	int n;
-	struct net *net = seq_file_net(seq);
-	struct mr6_table *mrt = net->ipv6.mrt6;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
@@ -316,6 +551,7 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 	} else {
 		const struct mfc6_cache *mfc = v;
 		const struct ipmr_mfc_iter *it = seq->private;
+		struct mr6_table *mrt = it->mrt;
 
 		seq_printf(seq, "%pI6 %pI6 %-3hd",
 			   &mfc->mf6c_mcastgrp, &mfc->mf6c_origin,
@@ -375,8 +611,12 @@ static int pim6_rcv(struct sk_buff *skb)
 	struct ipv6hdr   *encap;
 	struct net_device  *reg_dev = NULL;
 	struct net *net = dev_net(skb->dev);
-	struct mr6_table *mrt = net->ipv6.mrt6;
-	int reg_vif_num = mrt->mroute_reg_vif_num;
+	struct mr6_table *mrt;
+	struct flowi fl = {
+		.iif	= skb->dev->ifindex,
+		.mark	= skb->mark,
+	};
+	int reg_vif_num;
 
 	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(*encap)))
 		goto drop;
@@ -399,6 +639,10 @@ static int pim6_rcv(struct sk_buff *skb)
 	    ntohs(encap->payload_len) + sizeof(*pim) > skb->len)
 		goto drop;
 
+	if (ip6mr_fib_lookup(net, &fl, &mrt) < 0)
+		goto drop;
+	reg_vif_num = mrt->mroute_reg_vif_num;
+
 	read_lock(&mrt_lock);
 	if (reg_vif_num >= 0)
 		reg_dev = mrt->vif6_table[reg_vif_num].dev;
@@ -438,7 +682,17 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb,
 				      struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt;
+	struct flowi fl = {
+		.oif		= dev->ifindex,
+		.iif		= skb->skb_iif,
+		.mark		= skb->mark,
+	};
+	int err;
+
+	err = ip6mr_fib_lookup(net, &fl, &mrt);
+	if (err < 0)
+		return err;
 
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
@@ -463,11 +717,17 @@ static void reg_vif_setup(struct net_device *dev)
 	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
-static struct net_device *ip6mr_reg_vif(struct net *net)
+static struct net_device *ip6mr_reg_vif(struct net *net, struct mr6_table *mrt)
 {
 	struct net_device *dev;
+	char name[IFNAMSIZ];
+
+	if (mrt->id == RT6_TABLE_DFLT)
+		sprintf(name, "pim6reg");
+	else
+		sprintf(name, "pim6reg%u", mrt->id);
 
-	dev = alloc_netdev(0, "pim6reg", reg_vif_setup);
+	dev = alloc_netdev(0, name, reg_vif_setup);
 	if (dev == NULL)
 		return NULL;
 
@@ -665,7 +925,7 @@ static int mif6_add(struct net *net, struct mr6_table *mrt,
 		 */
 		if (mrt->mroute_reg_vif_num >= 0)
 			return -EADDRINUSE;
-		dev = ip6mr_reg_vif(net);
+		dev = ip6mr_reg_vif(net, mrt);
 		if (!dev)
 			return -ENOBUFS;
 		err = dev_set_allmulti(dev, 1);
@@ -995,7 +1255,7 @@ static int ip6mr_device_event(struct notifier_block *this,
 {
 	struct net_device *dev = ptr;
 	struct net *net = dev_net(dev);
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt;
 	struct mif_device *v;
 	int ct;
 	LIST_HEAD(list);
@@ -1003,10 +1263,12 @@ static int ip6mr_device_event(struct notifier_block *this,
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
 
-	v = &mrt->vif6_table[0];
-	for (ct = 0; ct < mrt->maxvif; ct++, v++) {
-		if (v->dev == dev)
-			mif6_delete(mrt, ct, &list);
+	ip6mr_for_each_table(mrt, net) {
+		v = &mrt->vif6_table[0];
+		for (ct = 0; ct < mrt->maxvif; ct++, v++) {
+			if (v->dev == dev)
+				mif6_delete(mrt, ct, &list);
+		}
 	}
 	unregister_netdevice_many(&list);
 
@@ -1023,29 +1285,11 @@ static struct notifier_block ip6_mr_notifier = {
 
 static int __net_init ip6mr_net_init(struct net *net)
 {
-	struct mr6_table *mrt;
-	unsigned int i;
-	int err = 0;
+	int err;
 
-	mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
-	if (mrt == NULL) {
-		err = -ENOMEM;
+	err = ip6mr_rules_init(net);
+	if (err < 0)
 		goto fail;
-	}
-
-	write_pnet(&mrt->net, net);
-
-	for (i = 0; i < MFC6_LINES; i++)
-		INIT_LIST_HEAD(&mrt->mfc6_cache_array[i]);
-
-	INIT_LIST_HEAD(&mrt->mfc6_unres_queue);
-
-	setup_timer(&mrt->ipmr_expire_timer, ipmr_expire_process,
-		    (unsigned long)mrt);
-
-#ifdef CONFIG_IPV6_PIMSM_V2
-	mrt->mroute_reg_vif_num = -1;
-#endif
 
 #ifdef CONFIG_PROC_FS
 	err = -ENOMEM;
@@ -1055,14 +1299,13 @@ static int __net_init ip6mr_net_init(struct net *net)
 		goto proc_cache_fail;
 #endif
 
-	net->ipv6.mrt6 = mrt;
 	return 0;
 
 #ifdef CONFIG_PROC_FS
 proc_cache_fail:
 	proc_net_remove(net, "ip6_mr_vif");
 proc_vif_fail:
-	kfree(mrt);
+	ip6mr_rules_exit(net);
 #endif
 fail:
 	return err;
@@ -1070,15 +1313,11 @@ fail:
 
 static void __net_exit ip6mr_net_exit(struct net *net)
 {
-	struct mr6_table *mrt = net->ipv6.mrt6;
-
 #ifdef CONFIG_PROC_FS
 	proc_net_remove(net, "ip6_mr_cache");
 	proc_net_remove(net, "ip6_mr_vif");
 #endif
-	del_timer(&mrt->ipmr_expire_timer);
-	mroute_clean_tables(mrt);
-	kfree(mrt);
+	ip6mr_rules_exit(net);
 }
 
 static struct pernet_operations ip6mr_net_ops = {
@@ -1279,28 +1518,39 @@ static int ip6mr_sk_init(struct mr6_table *mrt, struct sock *sk)
 
 int ip6mr_sk_done(struct sock *sk)
 {
-	int err = 0;
+	int err = -EACCES;
 	struct net *net = sock_net(sk);
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt;
 
 	rtnl_lock();
-	if (sk == mrt->mroute6_sk) {
-		write_lock_bh(&mrt_lock);
-		mrt->mroute6_sk = NULL;
-		net->ipv6.devconf_all->mc_forwarding--;
-		write_unlock_bh(&mrt_lock);
+	ip6mr_for_each_table(mrt, net) {
+		if (sk == mrt->mroute6_sk) {
+			write_lock_bh(&mrt_lock);
+			mrt->mroute6_sk = NULL;
+			net->ipv6.devconf_all->mc_forwarding--;
+			write_unlock_bh(&mrt_lock);
 
-		mroute_clean_tables(mrt);
-	} else
-		err = -EACCES;
+			mroute_clean_tables(mrt);
+			err = 0;
+			break;
+		}
+	}
 	rtnl_unlock();
 
 	return err;
 }
 
-struct sock *mroute6_socket(struct net *net)
+struct sock *mroute6_socket(struct net *net, struct sk_buff *skb)
 {
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt;
+	struct flowi fl = {
+		.iif	= skb->skb_iif,
+		.oif	= skb->dev->ifindex,
+		.mark	= skb->mark,
+	};
+
+	if (ip6mr_fib_lookup(net, &fl, &mrt) < 0)
+		return NULL;
 
 	return mrt->mroute6_sk;
 }
@@ -1319,7 +1569,11 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	struct mf6cctl mfc;
 	mifi_t mifi;
 	struct net *net = sock_net(sk);
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt;
+
+	mrt = ip6mr_get_table(net, raw6_sk(sk)->ip6mr_table ? : RT6_TABLE_DFLT);
+	if (mrt == NULL)
+		return -ENOENT;
 
 	if (optname != MRT6_INIT) {
 		if (sk != mrt->mroute6_sk && !capable(CAP_NET_ADMIN))
@@ -1409,6 +1663,27 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	}
 
 #endif
+#ifdef CONFIG_IPV6_MROUTE_MULTIPLE_TABLES
+	case MRT6_TABLE:
+	{
+		u32 v;
+
+		if (optlen != sizeof(u32))
+			return -EINVAL;
+		if (get_user(v, (u32 __user *)optval))
+			return -EFAULT;
+		if (sk == mrt->mroute6_sk)
+			return -EBUSY;
+
+		rtnl_lock();
+		ret = 0;
+		if (!ip6mr_new_table(net, v))
+			ret = -ENOMEM;
+		raw6_sk(sk)->ip6mr_table = v;
+		rtnl_unlock();
+		return ret;
+	}
+#endif
 	/*
 	 *	Spurious command, or MRT6_VERSION which you cannot
 	 *	set.
@@ -1428,7 +1703,11 @@ int ip6_mroute_getsockopt(struct sock *sk, int optname, char __user *optval,
 	int olr;
 	int val;
 	struct net *net = sock_net(sk);
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt;
+
+	mrt = ip6mr_get_table(net, raw6_sk(sk)->ip6mr_table ? : RT6_TABLE_DFLT);
+	if (mrt == NULL)
+		return -ENOENT;
 
 	switch (optname) {
 	case MRT6_VERSION:
@@ -1471,7 +1750,11 @@ int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg)
 	struct mif_device *vif;
 	struct mfc6_cache *c;
 	struct net *net = sock_net(sk);
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt;
+
+	mrt = ip6mr_get_table(net, raw6_sk(sk)->ip6mr_table ? : RT6_TABLE_DFLT);
+	if (mrt == NULL)
+		return -ENOENT;
 
 	switch (cmd) {
 	case SIOCGETMIFCNT_IN6:
@@ -1683,7 +1966,16 @@ int ip6_mr_input(struct sk_buff *skb)
 {
 	struct mfc6_cache *cache;
 	struct net *net = dev_net(skb->dev);
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt;
+	struct flowi fl = {
+		.iif	= skb->dev->ifindex,
+		.mark	= skb->mark,
+	};
+	int err;
+
+	err = ip6mr_fib_lookup(net, &fl, &mrt);
+	if (err < 0)
+		return err;
 
 	read_lock(&mrt_lock);
 	cache = ip6mr_cache_find(mrt,
@@ -1758,10 +2050,14 @@ int ip6mr_get_route(struct net *net,
 		    struct sk_buff *skb, struct rtmsg *rtm, int nowait)
 {
 	int err;
-	struct mr6_table *mrt = net->ipv6.mrt6;
+	struct mr6_table *mrt;
 	struct mfc6_cache *cache;
 	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
 
+	mrt = ip6mr_get_table(net, RT6_TABLE_DFLT);
+	if (mrt == NULL)
+		return -ENOENT;
+
 	read_lock(&mrt_lock);
 	cache = ip6mr_cache_find(mrt, &rt->rt6i_src.addr, &rt->rt6i_dst.addr);
 
-- 
1.7.0.4

