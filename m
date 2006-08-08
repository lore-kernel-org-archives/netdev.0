From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/4] [NETLINK]: Dont set socket error for failed event notifications
Date: Wed, 09 Aug 2006 00:00:03 +0200
Message-ID: <20060809205440.025848027@postel.suug.ch>
References: <20060809204821.216122988@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:22178 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751373AbWHIUzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 16:55:20 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_remove_set_err
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Setting a socket error on all sockets subscribed to a group
if an event notificiation of said group fails due to memory
pressure only confuses applications and is of no use. 

This patch removes it all together.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/bridge/br_netlink.c
===================================================================
--- net-2.6.19.git.orig/net/bridge/br_netlink.c
+++ net-2.6.19.git/net/bridge/br_netlink.c
@@ -76,25 +76,17 @@ rtattr_failure:
 void br_ifinfo_notify(int event, struct net_bridge_port *port)
 {
 	struct sk_buff *skb;
-	int err = -ENOMEM;
 
 	pr_debug("bridge notify event=%d\n", event);
 	skb = alloc_skb(NLMSG_SPACE(sizeof(struct ifinfomsg) + 128),
 			GFP_ATOMIC);
 	if (!skb)
-		goto err_out;
+		return;
 
-	err = br_fill_ifinfo(skb, port, current->pid, 0, event, 0);
-	if (err)
-		goto err_kfree;
-
-	rtnl_multicast(skb, RTNLGRP_LINK, GFP_ATOMIC);
-	return;
-
-err_kfree:
-	kfree_skb(skb);
-err_out:
-	netlink_set_err(rtnl, 0, RTNLGRP_LINK, err);
+	if (br_fill_ifinfo(skb, port, current->pid, 0, event, 0) <= 0)
+		kfree_skb(skb);
+	else
+		rtnl_multicast(skb, RTNLGRP_LINK, GFP_ATOMIC);
 }
 
 /*
Index: net-2.6.19.git/net/core/fib_rules.c
===================================================================
--- net-2.6.19.git.orig/net/core/fib_rules.c
+++ net-2.6.19.git/net/core/fib_rules.c
@@ -349,11 +349,11 @@ static void notify_rule_change(int event
 	struct sk_buff *skb = alloc_skb(size, GFP_KERNEL);
 
 	if (skb == NULL)
-		netlink_set_err(rtnl, 0, ops->nlgroup, ENOBUFS);
-	else if (fib_nl_fill_rule(skb, rule, 0, 0, event, 0, ops) < 0) {
+		return;
+
+	if (fib_nl_fill_rule(skb, rule, 0, 0, event, 0, ops) <= 0)
 		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, ops->nlgroup, EINVAL);
-	} else
+	else
 		rtnl_multicast(skb, ops->nlgroup, GFP_KERNEL);
 }
 
Index: net-2.6.19.git/net/decnet/dn_dev.c
===================================================================
--- net-2.6.19.git.orig/net/decnet/dn_dev.c
+++ net-2.6.19.git/net/decnet/dn_dev.c
@@ -748,17 +748,13 @@ static void rtmsg_ifa(int event, struct 
 	int size = NLMSG_SPACE(sizeof(struct ifaddrmsg)+128);
 
 	skb = alloc_skb(size, GFP_KERNEL);
-	if (!skb) {
-		netlink_set_err(rtnl, 0, RTNLGRP_DECnet_IFADDR, ENOBUFS);
-		return;
-	}
-	if (dn_dev_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
-		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_DECnet_IFADDR, EINVAL);
+	if (skb == NULL)
 		return;
-	}
 
-	rtnl_multicast(skb, RTNLGRP_DECnet_IFADDR, GFP_KERNEL);
+	if (dn_dev_fill_ifaddr(skb, ifa, 0, 0, event, 0) <= 0)
+		kfree_skb(skb);
+	else
+		rtnl_multicast(skb, RTNLGRP_DECnet_IFADDR, GFP_KERNEL);
 }
 
 static int dn_dev_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
Index: net-2.6.19.git/net/ipv4/devinet.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/devinet.c
+++ net-2.6.19.git/net/ipv4/devinet.c
@@ -1195,11 +1195,11 @@ static void rtmsg_ifa(int event, struct 
 
 	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb == NULL)
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_IFADDR, ENOBUFS);
-	else if (inet_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
+		return;
+
+	if (inet_fill_ifaddr(skb, ifa, 0, 0, event, 0) <= 0)
 		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_IFADDR, EINVAL);
-	} else
+	else
 		rtnl_multicast(skb, RTNLGRP_IPV4_IFADDR, GFP_KERNEL);
 }
 
Index: net-2.6.19.git/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/addrconf.c
+++ net-2.6.19.git/net/ipv6/addrconf.c
@@ -3283,17 +3283,13 @@ static void inet6_ifa_notify(int event, 
 	int size = NLMSG_SPACE(sizeof(struct ifaddrmsg) + INET6_IFADDR_RTA_SPACE);
 
 	skb = alloc_skb(size, GFP_ATOMIC);
-	if (!skb) {
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_IFADDR, ENOBUFS);
+	if (skb == NULL)
 		return;
-	}
-	if (inet6_fill_ifaddr(skb, ifa, current->pid, 0, event, 0) < 0) {
-		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_IFADDR, EINVAL);
-		return;
-	}
 
-	rtnl_multicast(skb, RTNLGRP_IPV6_IFADDR, GFP_ATOMIC);
+	if (inet6_fill_ifaddr(skb, ifa, current->pid, 0, event, 0) <= 0)
+		kfree_skb(skb);
+	else
+		rtnl_multicast(skb, RTNLGRP_IPV6_IFADDR, GFP_ATOMIC);
 }
 
 static void inline ipv6_store_devconf(struct ipv6_devconf *cnf,
@@ -3437,17 +3433,13 @@ void inet6_ifinfo_notify(int event, stru
 	int size = NLMSG_SPACE(sizeof(struct ifinfomsg) + INET6_IFINFO_RTA_SPACE);
 	
 	skb = alloc_skb(size, GFP_ATOMIC);
-	if (!skb) {
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_IFINFO, ENOBUFS);
-		return;
-	}
-	if (inet6_fill_ifinfo(skb, idev, current->pid, 0, event, 0) < 0) {
-		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_IFINFO, EINVAL);
+	if (skb == NULL)
 		return;
-	}
 
-	rtnl_multicast(skb, RTNLGRP_IPV6_IFINFO, GFP_ATOMIC);
+	if (inet6_fill_ifinfo(skb, idev, current->pid, 0, event, 0) <= 0)
+		kfree_skb(skb);
+	else
+		rtnl_multicast(skb, RTNLGRP_IPV6_IFINFO, GFP_ATOMIC);
 }
 
 /* Maximum length of prefix_cacheinfo attributes */
@@ -3502,17 +3494,13 @@ static void inet6_prefix_notify(int even
 	int size = NLMSG_SPACE(sizeof(struct prefixmsg) + INET6_PREFIX_RTA_SPACE);
 
 	skb = alloc_skb(size, GFP_ATOMIC);
-	if (!skb) {
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_PREFIX, ENOBUFS);
+	if (skb == NULL)
 		return;
-	}
-	if (inet6_fill_prefix(skb, idev, pinfo, current->pid, 0, event, 0) < 0) {
-		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_PREFIX, EINVAL);
-		return;
-	}
 
-	rtnl_multicast(skb, RTNLGRP_IPV6_PREFIX, GFP_ATOMIC);
+	if (inet6_fill_prefix(skb, idev, pinfo, current->pid, 0, event, 0) <= 0)
+		kfree_skb(skb);
+	else
+		rtnl_multicast(skb, RTNLGRP_IPV6_PREFIX, GFP_ATOMIC);
 }
 
 static struct rtnetlink_link inet6_rtnetlink_table[RTM_NR_MSGTYPES] = {
Index: net-2.6.19.git/net/ipv6/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/route.c
+++ net-2.6.19.git/net/ipv6/route.c
@@ -2183,17 +2183,13 @@ void inet6_rt_notify(int event, struct r
 		seq = nlh->nlmsg_seq;
 	
 	skb = alloc_skb(size, gfp_any());
-	if (!skb) {
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_ROUTE, ENOBUFS);
+	if (skb == NULL)
 		return;
-	}
-	if (rt6_fill_node(skb, rt, NULL, NULL, 0, event, pid, seq, 0, 0) < 0) {
-		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_ROUTE, EINVAL);
-		return;
-	}
 
-	rtnl_multicast(skb, RTNLGRP_IPV6_ROUTE, gfp_any());
+	if (rt6_fill_node(skb, rt, NULL, NULL, 0, event, pid, seq, 0, 0) <= 0)
+		kfree_skb(skb);
+	else
+		rtnl_multicast(skb, RTNLGRP_IPV6_ROUTE, gfp_any());
 }
 
 /*
Index: net-2.6.19.git/include/linux/netlink.h
===================================================================
--- net-2.6.19.git.orig/include/linux/netlink.h
+++ net-2.6.19.git/include/linux/netlink.h
@@ -156,7 +156,6 @@ extern int netlink_has_listeners(struct 
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
 			     __u32 group, gfp_t allocation);
-extern void netlink_set_err(struct sock *ssk, __u32 pid, __u32 group, int code);
 extern int netlink_register_notifier(struct notifier_block *nb);
 extern int netlink_unregister_notifier(struct notifier_block *nb);
 
Index: net-2.6.19.git/net/netlink/af_netlink.c
===================================================================
--- net-2.6.19.git.orig/net/netlink/af_netlink.c
+++ net-2.6.19.git/net/netlink/af_netlink.c
@@ -955,50 +955,6 @@ int netlink_broadcast(struct sock *ssk, 
 	return -ESRCH;
 }
 
-struct netlink_set_err_data {
-	struct sock *exclude_sk;
-	u32 pid;
-	u32 group;
-	int code;
-};
-
-static inline int do_one_set_err(struct sock *sk,
-				 struct netlink_set_err_data *p)
-{
-	struct netlink_sock *nlk = nlk_sk(sk);
-
-	if (sk == p->exclude_sk)
-		goto out;
-
-	if (nlk->pid == p->pid || p->group - 1 >= nlk->ngroups ||
-	    !test_bit(p->group - 1, nlk->groups))
-		goto out;
-
-	sk->sk_err = p->code;
-	sk->sk_error_report(sk);
-out:
-	return 0;
-}
-
-void netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
-{
-	struct netlink_set_err_data info;
-	struct hlist_node *node;
-	struct sock *sk;
-
-	info.exclude_sk = ssk;
-	info.pid = pid;
-	info.group = group;
-	info.code = code;
-
-	read_lock(&nl_table_lock);
-
-	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
-		do_one_set_err(sk, &info);
-
-	read_unlock(&nl_table_lock);
-}
-
 static int netlink_setsockopt(struct socket *sock, int level, int optname,
                               char __user *optval, int optlen)
 {
@@ -1825,7 +1781,6 @@ EXPORT_SYMBOL(netlink_broadcast);
 EXPORT_SYMBOL(netlink_dump_start);
 EXPORT_SYMBOL(netlink_kernel_create);
 EXPORT_SYMBOL(netlink_register_notifier);
-EXPORT_SYMBOL(netlink_set_err);
 EXPORT_SYMBOL(netlink_set_nonroot);
 EXPORT_SYMBOL(netlink_unicast);
 EXPORT_SYMBOL(netlink_unregister_notifier);

