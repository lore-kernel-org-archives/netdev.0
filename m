From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 9/9] ipv4: ipmr: support multiple tables
Date: Tue, 13 Apr 2010 17:03:23 +0200
Message-ID: <1271171003-11901-10-git-send-email-kaber@trash.net>
References: <1271171003-11901-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51259 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345Ab0DMPD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 11:03:28 -0400
In-Reply-To: <1271171003-11901-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for multiple independant multicast routing instances,
named "tables".

Userspace multicast routing daemons can bind to a specific table instance by
issuing a setsockopt call using a new option MRT_TABLE. The table number is
stored in the raw socket data and affects all following ipmr setsockopt(),
getsockopt() and ioctl() calls. By default, a single table (RT_TABLE_DEFAULT)
is created with a default routing rule pointing to it. Newly created pimreg
devices have the table number appended ("pimregX"), with the exception of
devices created in the default table, which are named just "pimreg" for
compatibility reasons.

Packets are directed to a specific table instance using routing rules,
similar to how regular routing rules work. Currently iif, oif and mark
are supported as keys, source and destination addresses could be supported
additionally.

Example usage:

- bind pimd/xorp/... to a specific table:

uint32_t table = 123;
setsockopt(fd, IPPROTO_IP, MRT_TABLE, &table, sizeof(table));

- create routing rules directing packets to the new table:

# ip mrule add iif eth0 lookup 123
# ip mrule add oif eth0 lookup 123

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/fib_rules.h |    1 +
 include/linux/mroute.h    |    3 +-
 include/net/netns/ipv4.h  |    5 +
 include/net/raw.h         |    1 +
 net/ipv4/Kconfig          |   14 ++
 net/ipv4/ipmr.c           |  399 ++++++++++++++++++++++++++++++++++++++-------
 6 files changed, 361 insertions(+), 62 deletions(-)

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 405e411..04a3976 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -21,6 +21,7 @@
 #define FIB_RULES_IPV4		AF_INET
 #define FIB_RULES_IPV6		AF_INET6
 #define FIB_RULES_DECNET	AF_DECnet
+#define FIB_RULES_IPMR		128
 
 struct fib_rule_hdr {
 	__u8		family;
diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index 7ff6c77..fa04b24 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -27,7 +27,8 @@
 #define MRT_DEL_MFC	(MRT_BASE+5)	/* Delete a multicast forwarding entry	*/
 #define MRT_VERSION	(MRT_BASE+6)	/* Get the kernel multicast version	*/
 #define MRT_ASSERT	(MRT_BASE+7)	/* Activate PIM assert mode		*/
-#define MRT_PIM		(MRT_BASE+8)	/* enable PIM code	*/
+#define MRT_PIM		(MRT_BASE+8)	/* enable PIM code			*/
+#define MRT_TABLE	(MRT_BASE+9)	/* Specify mroute table ID		*/
 
 #define SIOCGETVIFCNT	SIOCPROTOPRIVATE	/* IP protocol privates */
 #define SIOCGETSGCNT	(SIOCPROTOPRIVATE+1)
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 72e762a..ae07fee 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -59,7 +59,12 @@ struct netns_ipv4 {
 	atomic_t rt_genid;
 
 #ifdef CONFIG_IP_MROUTE
+#ifndef CONFIG_IP_MROUTE_MULTIPLE_TABLES
 	struct mr_table		*mrt;
+#else
+	struct list_head	mr_tables;
+	struct fib_rules_ops	*mr_rules_ops;
+#endif
 #endif
 };
 #endif
diff --git a/include/net/raw.h b/include/net/raw.h
index 67cc643..43c5750 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -61,6 +61,7 @@ struct raw_sock {
 	/* inet_sock has to be the first member */
 	struct inet_sock   inet;
 	struct icmp_filter filter;
+	u32		   ipmr_table;
 };
 
 static inline struct raw_sock *raw_sk(const struct sock *sk)
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index c9a1c68..be59774 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -250,6 +250,20 @@ config IP_MROUTE
 	  <file:Documentation/networking/multicast.txt>. If you haven't heard
 	  about it, you don't need it.
 
+config IP_MROUTE_MULTIPLE_TABLES
+	bool "IP: multicast policy routing"
+	depends on IP_ADVANCED_ROUTER
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
 config IP_PIMSM_V1
 	bool "IP: PIM-SM version 1 support"
 	depends on IP_MROUTE
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 498f4e9..5df5fd7 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -63,12 +63,15 @@
 #include <net/ipip.h>
 #include <net/checksum.h>
 #include <net/netlink.h>
+#include <net/fib_rules.h>
 
 #if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
 #define CONFIG_IP_PIMSM	1
 #endif
 
 struct mr_table {
+	struct list_head	list;
+	u32			id;
 	struct sock		*mroute_sk;
 	struct timer_list	ipmr_expire_timer;
 	struct list_head	mfc_unres_queue;
@@ -83,6 +86,14 @@ struct mr_table {
 #endif
 };
 
+struct ipmr_rule {
+	struct fib_rule		common;
+};
+
+struct ipmr_result {
+	struct mr_table		*mrt;
+};
+
 /* Big lock, protecting vif table, mrt cache and mroute socket state.
    Note that the changes are semaphored via rtnl_lock.
  */
@@ -108,6 +119,7 @@ static DEFINE_SPINLOCK(mfc_unres_lock);
 
 static struct kmem_cache *mrt_cachep __read_mostly;
 
+static struct mr_table *ipmr_new_table(struct net *net, u32 id);
 static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 			 struct sk_buff *skb, struct mfc_cache *cache,
 			 int local);
@@ -115,6 +127,206 @@ static int ipmr_cache_report(struct mr_table *mrt,
 			     struct sk_buff *pkt, vifi_t vifi, int assert);
 static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 			    struct mfc_cache *c, struct rtmsg *rtm);
+static void ipmr_expire_process(unsigned long arg);
+
+#ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
+#define ipmr_for_each_table(mrt, net) \
+	list_for_each_entry_rcu(mrt, &net->ipv4.mr_tables, list)
+
+static struct mr_table *ipmr_get_table(struct net *net, u32 id)
+{
+	struct mr_table *mrt;
+
+	ipmr_for_each_table(mrt, net) {
+		if (mrt->id == id)
+			return mrt;
+	}
+	return NULL;
+}
+
+static int ipmr_fib_lookup(struct net *net, struct flowi *flp,
+			   struct mr_table **mrt)
+{
+	struct ipmr_result res;
+	struct fib_lookup_arg arg = { .result = &res, };
+	int err;
+
+	err = fib_rules_lookup(net->ipv4.mr_rules_ops, flp, 0, &arg);
+	if (err < 0)
+		return err;
+	*mrt = res.mrt;
+	return 0;
+}
+
+static int ipmr_rule_action(struct fib_rule *rule, struct flowi *flp,
+			    int flags, struct fib_lookup_arg *arg)
+{
+	struct ipmr_result *res = arg->result;
+	struct mr_table *mrt;
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
+	mrt = ipmr_get_table(rule->fr_net, rule->table);
+	if (mrt == NULL)
+		return -EAGAIN;
+	res->mrt = mrt;
+	return 0;
+}
+
+static int ipmr_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
+{
+	return 1;
+}
+
+static const struct nla_policy ipmr_rule_policy[FRA_MAX + 1] = {
+	FRA_GENERIC_POLICY,
+};
+
+static int ipmr_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
+			       struct fib_rule_hdr *frh, struct nlattr **tb)
+{
+	return 0;
+}
+
+static int ipmr_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
+			     struct nlattr **tb)
+{
+	return 1;
+}
+
+static int ipmr_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
+			  struct fib_rule_hdr *frh)
+{
+	frh->dst_len = 0;
+	frh->src_len = 0;
+	frh->tos     = 0;
+	return 0;
+}
+
+static struct fib_rules_ops ipmr_rules_ops_template = {
+	.family		= FIB_RULES_IPMR,
+	.rule_size	= sizeof(struct ipmr_rule),
+	.addr_size	= sizeof(u32),
+	.action		= ipmr_rule_action,
+	.match		= ipmr_rule_match,
+	.configure	= ipmr_rule_configure,
+	.compare	= ipmr_rule_compare,
+	.default_pref	= fib_default_rule_pref,
+	.fill		= ipmr_rule_fill,
+	.nlgroup	= RTNLGRP_IPV4_RULE,
+	.policy		= ipmr_rule_policy,
+	.owner		= THIS_MODULE,
+};
+
+static int __net_init ipmr_rules_init(struct net *net)
+{
+	struct fib_rules_ops *ops;
+	struct mr_table *mrt;
+	int err;
+
+	ops = fib_rules_register(&ipmr_rules_ops_template, net);
+	if (IS_ERR(ops))
+		return PTR_ERR(ops);
+
+	INIT_LIST_HEAD(&net->ipv4.mr_tables);
+
+	mrt = ipmr_new_table(net, RT_TABLE_DEFAULT);
+	if (mrt == NULL) {
+		err = -ENOMEM;
+		goto err1;
+	}
+
+	err = fib_default_rule_add(ops, 0x7fff, RT_TABLE_DEFAULT, 0);
+	if (err < 0)
+		goto err2;
+
+	net->ipv4.mr_rules_ops = ops;
+	return 0;
+
+err2:
+	kfree(mrt);
+err1:
+	fib_rules_unregister(ops);
+	return err;
+}
+
+static void __net_exit ipmr_rules_exit(struct net *net)
+{
+	struct mr_table *mrt, *next;
+
+	list_for_each_entry_safe(mrt, next, &net->ipv4.mr_tables, list)
+		kfree(mrt);
+	fib_rules_unregister(net->ipv4.mr_rules_ops);
+}
+#else
+#define ipmr_for_each_table(mrt, net) \
+	for (mrt = net->ipv4.mrt; mrt; mrt = NULL)
+
+static struct mr_table *ipmr_get_table(struct net *net, u32 id)
+{
+	return net->ipv4.mrt;
+}
+
+static int ipmr_fib_lookup(struct net *net, struct flowi *flp,
+			   struct mr_table **mrt)
+{
+	*mrt = net->ipv4.mrt;
+	return 0;
+}
+
+static int __net_init ipmr_rules_init(struct net *net)
+{
+	net->ipv4.mrt = ipmr_new_table(net, RT_TABLE_DEFAULT);
+	return net->ipv4.mrt ? 0 : -ENOMEM;
+}
+
+static void __net_exit ipmr_rules_exit(struct net *net)
+{
+	kfree(net->ipv4.mrt);
+}
+#endif
+
+static struct mr_table *ipmr_new_table(struct net *net, u32 id)
+{
+	struct mr_table *mrt;
+	unsigned int i;
+
+	mrt = ipmr_get_table(net, id);
+	if (mrt != NULL)
+		return mrt;
+
+	mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
+	if (mrt == NULL)
+		return NULL;
+	mrt->id = id;
+
+	/* Forwarding cache */
+	for (i = 0; i < MFC_LINES; i++)
+		INIT_LIST_HEAD(&mrt->mfc_cache_array[i]);
+
+	INIT_LIST_HEAD(&mrt->mfc_unres_queue);
+
+	setup_timer(&mrt->ipmr_expire_timer, ipmr_expire_process,
+		    (unsigned long)mrt);
+
+#ifdef CONFIG_IP_PIMSM
+	mrt->mroute_reg_vif_num = -1;
+#endif
+#ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
+	list_add_tail_rcu(&mrt->list, &net->ipv4.mr_tables);
+#endif
+	return mrt;
+}
 
 /* Service routines creating virtual interfaces: DVMRP tunnels and PIMREG */
 
@@ -215,7 +427,17 @@ failure:
 static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt;
+	struct flowi fl = {
+		.oif		= dev->ifindex,
+		.iif		= skb->skb_iif,
+		.mark		= skb->mark,
+	};
+	int err;
+
+	err = ipmr_fib_lookup(net, &fl, &mrt);
+	if (err < 0)
+		return err;
 
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
@@ -240,12 +462,18 @@ static void reg_vif_setup(struct net_device *dev)
 	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
-static struct net_device *ipmr_reg_vif(struct net *net)
+static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
 {
 	struct net_device *dev;
 	struct in_device *in_dev;
+	char name[IFNAMSIZ];
+
+	if (mrt->id == RT_TABLE_DEFAULT)
+		sprintf(name, "pimreg");
+	else
+		sprintf(name, "pimreg%u", mrt->id);
 
-	dev = alloc_netdev(0, "pimreg", reg_vif_setup);
+	dev = alloc_netdev(0, name, reg_vif_setup);
 
 	if (dev == NULL)
 		return NULL;
@@ -461,7 +689,7 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 		 */
 		if (mrt->mroute_reg_vif_num >= 0)
 			return -EADDRINUSE;
-		dev = ipmr_reg_vif(net);
+		dev = ipmr_reg_vif(net, mrt);
 		if (!dev)
 			return -ENOBUFS;
 		err = dev_set_allmulti(dev, 1);
@@ -928,17 +1156,19 @@ static void mroute_clean_tables(struct mr_table *mrt)
 static void mrtsock_destruct(struct sock *sk)
 {
 	struct net *net = sock_net(sk);
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt;
 
 	rtnl_lock();
-	if (sk == mrt->mroute_sk) {
-		IPV4_DEVCONF_ALL(net, MC_FORWARDING)--;
+	ipmr_for_each_table(mrt, net) {
+		if (sk == mrt->mroute_sk) {
+			IPV4_DEVCONF_ALL(net, MC_FORWARDING)--;
 
-		write_lock_bh(&mrt_lock);
-		mrt->mroute_sk = NULL;
-		write_unlock_bh(&mrt_lock);
+			write_lock_bh(&mrt_lock);
+			mrt->mroute_sk = NULL;
+			write_unlock_bh(&mrt_lock);
 
-		mroute_clean_tables(mrt);
+			mroute_clean_tables(mrt);
+		}
 	}
 	rtnl_unlock();
 }
@@ -956,7 +1186,11 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 	struct vifctl vif;
 	struct mfcctl mfc;
 	struct net *net = sock_net(sk);
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt;
+
+	mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
+	if (mrt == NULL)
+		return -ENOENT;
 
 	if (optname != MRT_INIT) {
 		if (sk != mrt->mroute_sk && !capable(CAP_NET_ADMIN))
@@ -1055,6 +1289,27 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		return ret;
 	}
 #endif
+#ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
+	case MRT_TABLE:
+	{
+		u32 v;
+
+		if (optlen != sizeof(u32))
+			return -EINVAL;
+		if (get_user(v, (u32 __user *)optval))
+			return -EFAULT;
+		if (sk == mrt->mroute_sk)
+			return -EBUSY;
+
+		rtnl_lock();
+		ret = 0;
+		if (!ipmr_new_table(net, v))
+			ret = -ENOMEM;
+		raw_sk(sk)->ipmr_table = v;
+		rtnl_unlock();
+		return ret;
+	}
+#endif
 	/*
 	 *	Spurious command, or MRT_VERSION which you cannot
 	 *	set.
@@ -1073,7 +1328,11 @@ int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int
 	int olr;
 	int val;
 	struct net *net = sock_net(sk);
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt;
+
+	mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
+	if (mrt == NULL)
+		return -ENOENT;
 
 	if (optname != MRT_VERSION &&
 #ifdef CONFIG_IP_PIMSM
@@ -1115,7 +1374,11 @@ int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 	struct vif_device *vif;
 	struct mfc_cache *c;
 	struct net *net = sock_net(sk);
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt;
+
+	mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
+	if (mrt == NULL)
+		return -ENOENT;
 
 	switch (cmd) {
 	case SIOCGETVIFCNT:
@@ -1166,17 +1429,20 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 {
 	struct net_device *dev = ptr;
 	struct net *net = dev_net(dev);
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt;
 	struct vif_device *v;
 	int ct;
 	LIST_HEAD(list);
 
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
-	v = &mrt->vif_table[0];
-	for (ct = 0; ct < mrt->maxvif; ct++, v++) {
-		if (v->dev == dev)
-			vif_delete(mrt, ct, 1, &list);
+
+	ipmr_for_each_table(mrt, net) {
+		v = &mrt->vif_table[0];
+		for (ct = 0; ct < mrt->maxvif; ct++, v++) {
+			if (v->dev == dev)
+				vif_delete(mrt, ct, 1, &list);
+		}
 	}
 	unregister_netdevice_many(&list);
 	return NOTIFY_DONE;
@@ -1443,8 +1709,9 @@ int ip_mr_input(struct sk_buff *skb)
 {
 	struct mfc_cache *cache;
 	struct net *net = dev_net(skb->dev);
-	struct mr_table *mrt = net->ipv4.mrt;
 	int local = skb_rtable(skb)->rt_flags & RTCF_LOCAL;
+	struct mr_table *mrt;
+	int err;
 
 	/* Packet is looped back after forward, it should not be
 	   forwarded second time, but still can be delivered locally.
@@ -1452,6 +1719,10 @@ int ip_mr_input(struct sk_buff *skb)
 	if (IPCB(skb)->flags&IPSKB_FORWARDED)
 		goto dont_forward;
 
+	err = ipmr_fib_lookup(net, &skb_rtable(skb)->fl, &mrt);
+	if (err < 0)
+		return err;
+
 	if (!local) {
 		    if (IPCB(skb)->opt.router_alert) {
 			    if (ip_call_ra_chain(skb))
@@ -1522,12 +1793,11 @@ dont_forward:
 }
 
 #ifdef CONFIG_IP_PIMSM
-static int __pim_rcv(struct sk_buff *skb, unsigned int pimlen)
+static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
+		     unsigned int pimlen)
 {
 	struct net_device *reg_dev = NULL;
 	struct iphdr *encap;
-	struct net *net = dev_net(skb->dev);
-	struct mr_table *mrt = net->ipv4.mrt;
 
 	encap = (struct iphdr *)(skb_transport_header(skb) + pimlen);
 	/*
@@ -1578,18 +1848,21 @@ int pim_rcv_v1(struct sk_buff * skb)
 {
 	struct igmphdr *pim;
 	struct net *net = dev_net(skb->dev);
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt;
 
 	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(struct iphdr)))
 		goto drop;
 
 	pim = igmp_hdr(skb);
 
+	if (ipmr_fib_lookup(net, &skb_rtable(skb)->fl, &mrt) < 0)
+		goto drop;
+
 	if (!mrt->mroute_do_pim ||
 	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER)
 		goto drop;
 
-	if (__pim_rcv(skb, sizeof(*pim))) {
+	if (__pim_rcv(mrt, skb, sizeof(*pim))) {
 drop:
 		kfree_skb(skb);
 	}
@@ -1601,6 +1874,8 @@ drop:
 static int pim_rcv(struct sk_buff * skb)
 {
 	struct pimreghdr *pim;
+	struct net *net = dev_net(skb->dev);
+	struct mr_table *mrt;
 
 	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(struct iphdr)))
 		goto drop;
@@ -1612,7 +1887,10 @@ static int pim_rcv(struct sk_buff * skb)
 	     csum_fold(skb_checksum(skb, 0, skb->len, 0))))
 		goto drop;
 
-	if (__pim_rcv(skb, sizeof(*pim))) {
+	if (ipmr_fib_lookup(net, &skb_rtable(skb)->fl, &mrt) < 0)
+		goto drop;
+
+	if (__pim_rcv(mrt, skb, sizeof(*pim))) {
 drop:
 		kfree_skb(skb);
 	}
@@ -1663,10 +1941,14 @@ int ipmr_get_route(struct net *net,
 		   struct sk_buff *skb, struct rtmsg *rtm, int nowait)
 {
 	int err;
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt;
 	struct mfc_cache *cache;
 	struct rtable *rt = skb_rtable(skb);
 
+	mrt = ipmr_get_table(net, RT_TABLE_DEFAULT);
+	if (mrt == NULL)
+		return -ENOENT;
+
 	read_lock(&mrt_lock);
 	cache = ipmr_cache_find(mrt, rt->rt_src, rt->rt_dst);
 
@@ -1717,6 +1999,7 @@ int ipmr_get_route(struct net *net,
  */
 struct ipmr_vif_iter {
 	struct seq_net_private p;
+	struct mr_table *mrt;
 	int ct;
 };
 
@@ -1724,7 +2007,7 @@ static struct vif_device *ipmr_vif_seq_idx(struct net *net,
 					   struct ipmr_vif_iter *iter,
 					   loff_t pos)
 {
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt = iter->mrt;
 
 	for (iter->ct = 0; iter->ct < mrt->maxvif; ++iter->ct) {
 		if (!VIF_EXISTS(mrt, iter->ct))
@@ -1738,7 +2021,15 @@ static struct vif_device *ipmr_vif_seq_idx(struct net *net,
 static void *ipmr_vif_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(mrt_lock)
 {
+	struct ipmr_vif_iter *iter = seq->private;
 	struct net *net = seq_file_net(seq);
+	struct mr_table *mrt;
+
+	mrt = ipmr_get_table(net, RT_TABLE_DEFAULT);
+	if (mrt == NULL)
+		return ERR_PTR(-ENOENT);
+
+	iter->mrt = mrt;
 
 	read_lock(&mrt_lock);
 	return *pos ? ipmr_vif_seq_idx(net, seq->private, *pos - 1)
@@ -1749,7 +2040,7 @@ static void *ipmr_vif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ipmr_vif_iter *iter = seq->private;
 	struct net *net = seq_file_net(seq);
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt = iter->mrt;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
@@ -1771,8 +2062,8 @@ static void ipmr_vif_seq_stop(struct seq_file *seq, void *v)
 
 static int ipmr_vif_seq_show(struct seq_file *seq, void *v)
 {
-	struct net *net = seq_file_net(seq);
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct ipmr_vif_iter *iter = seq->private;
+	struct mr_table *mrt = iter->mrt;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
@@ -1814,6 +2105,7 @@ static const struct file_operations ipmr_vif_fops = {
 
 struct ipmr_mfc_iter {
 	struct seq_net_private p;
+	struct mr_table *mrt;
 	struct list_head *cache;
 	int ct;
 };
@@ -1822,7 +2114,7 @@ struct ipmr_mfc_iter {
 static struct mfc_cache *ipmr_mfc_seq_idx(struct net *net,
 					  struct ipmr_mfc_iter *it, loff_t pos)
 {
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt = it->mrt;
 	struct mfc_cache *mfc;
 
 	read_lock(&mrt_lock);
@@ -1850,7 +2142,13 @@ static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct ipmr_mfc_iter *it = seq->private;
 	struct net *net = seq_file_net(seq);
+	struct mr_table *mrt;
+
+	mrt = ipmr_get_table(net, RT_TABLE_DEFAULT);
+	if (mrt == NULL)
+		return ERR_PTR(-ENOENT);
 
+	it->mrt = mrt;
 	it->cache = NULL;
 	it->ct = 0;
 	return *pos ? ipmr_mfc_seq_idx(net, seq->private, *pos - 1)
@@ -1862,7 +2160,7 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	struct mfc_cache *mfc = v;
 	struct ipmr_mfc_iter *it = seq->private;
 	struct net *net = seq_file_net(seq);
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt = it->mrt;
 
 	++*pos;
 
@@ -1903,8 +2201,7 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 {
 	struct ipmr_mfc_iter *it = seq->private;
-	struct net *net = seq_file_net(seq);
-	struct mr_table *mrt = net->ipv4.mrt;
+	struct mr_table *mrt = it->mrt;
 
 	if (it->cache == &mrt->mfc_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
@@ -1915,8 +2212,6 @@ static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 {
 	int n;
-	struct net *net = seq_file_net(seq);
-	struct mr_table *mrt = net->ipv4.mrt;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
@@ -1924,6 +2219,7 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 	} else {
 		const struct mfc_cache *mfc = v;
 		const struct ipmr_mfc_iter *it = seq->private;
+		const struct mr_table *mrt = it->mrt;
 
 		seq_printf(seq, "%08lX %08lX %-3hd",
 			   (unsigned long) mfc->mfc_mcastgrp,
@@ -1989,28 +2285,11 @@ static const struct net_protocol pim_protocol = {
  */
 static int __net_init ipmr_net_init(struct net *net)
 {
-	struct mr_table *mrt;
-	unsigned int i;
-	int err = 0;
+	int err;
 
-	mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
-	if (mrt == NULL) {
-		err = -ENOMEM;
+	err = ipmr_rules_init(net);
+	if (err < 0)
 		goto fail;
-	}
-
-	/* Forwarding cache */
-	for (i = 0; i < MFC_LINES; i++)
-		INIT_LIST_HEAD(&mrt->mfc_cache_array[i]);
-
-	INIT_LIST_HEAD(&mrt->mfc_unres_queue);
-
-	setup_timer(&mrt->ipmr_expire_timer, ipmr_expire_process,
-		    (unsigned long)net);
-
-#ifdef CONFIG_IP_PIMSM
-	mrt->mroute_reg_vif_num = -1;
-#endif
 
 #ifdef CONFIG_PROC_FS
 	err = -ENOMEM;
@@ -2019,15 +2298,13 @@ static int __net_init ipmr_net_init(struct net *net)
 	if (!proc_net_fops_create(net, "ip_mr_cache", 0, &ipmr_mfc_fops))
 		goto proc_cache_fail;
 #endif
-
-	net->ipv4.mrt = mrt;
 	return 0;
 
 #ifdef CONFIG_PROC_FS
 proc_cache_fail:
 	proc_net_remove(net, "ip_mr_vif");
 proc_vif_fail:
-	kfree(mrt);
+	ipmr_rules_exit(net);
 #endif
 fail:
 	return err;
@@ -2039,7 +2316,7 @@ static void __net_exit ipmr_net_exit(struct net *net)
 	proc_net_remove(net, "ip_mr_cache");
 	proc_net_remove(net, "ip_mr_vif");
 #endif
-	kfree(net->ipv4.mrt);
+	ipmr_rules_exit(net);
 }
 
 static struct pernet_operations ipmr_net_ops = {
-- 
1.7.0.4

