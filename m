From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 10/12] [IPv6]: Use rtnl registration interface
Date: Thu, 22 Mar 2007 14:00:05 +0100
Message-ID: <20070322130058.497167346@lsx.localdomain>
References: <20070322125955.055083236@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53666 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064AbXCVNCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:02:17 -0400
Content-Disposition: inline; filename=rtnl_reg_ip6_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/include/net/ip6_fib.h
===================================================================
--- net-2.6.22.orig/include/net/ip6_fib.h	2007-03-22 13:23:12.000000000 +0100
+++ net-2.6.22/include/net/ip6_fib.h	2007-03-22 13:24:02.000000000 +0100
@@ -218,8 +218,6 @@ extern void			fib6_init(void);
 
 extern void			fib6_rules_init(void);
 extern void			fib6_rules_cleanup(void);
-extern int			fib6_rules_dump(struct sk_buff *,
-						struct netlink_callback *);
 
 #endif
 #endif
Index: net-2.6.22/net/ipv6/addrconf.c
===================================================================
--- net-2.6.22.orig/net/ipv6/addrconf.c	2007-03-22 13:23:12.000000000 +0100
+++ net-2.6.22/net/ipv6/addrconf.c	2007-03-22 13:24:02.000000000 +0100
@@ -3607,23 +3607,6 @@ errout:
 		rtnl_set_sk_err(RTNLGRP_IPV6_PREFIX, err);
 }
 
-static struct rtnetlink_link inet6_rtnetlink_table[RTM_NR_MSGTYPES] = {
-	[RTM_GETLINK - RTM_BASE] = { .dumpit	= inet6_dump_ifinfo, },
-	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
-	[RTM_DELADDR - RTM_BASE] = { .doit	= inet6_rtm_deladdr, },
-	[RTM_GETADDR - RTM_BASE] = { .doit	= inet6_rtm_getaddr,
-				     .dumpit	= inet6_dump_ifaddr, },
-	[RTM_GETMULTICAST - RTM_BASE] = { .dumpit = inet6_dump_ifmcaddr, },
-	[RTM_GETANYCAST - RTM_BASE] = { .dumpit	= inet6_dump_ifacaddr, },
-	[RTM_NEWROUTE - RTM_BASE] = { .doit	= inet6_rtm_newroute, },
-	[RTM_DELROUTE - RTM_BASE] = { .doit	= inet6_rtm_delroute, },
-	[RTM_GETROUTE - RTM_BASE] = { .doit	= inet6_rtm_getroute,
-				      .dumpit	= inet6_dump_fib, },
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	[RTM_GETRULE  - RTM_BASE] = { .dumpit   = fib6_rules_dump,   },
-#endif
-};
-
 static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 {
 	inet6_ifa_notify(event ? : RTM_NEWADDR, ifp);
@@ -4135,7 +4118,18 @@ int __init addrconf_init(void)
 	register_netdevice_notifier(&ipv6_dev_notf);
 
 	addrconf_verify(0);
-	rtnetlink_links[PF_INET6] = inet6_rtnetlink_table;
+
+	err = __rtnl_register(PF_INET6, RTM_GETLINK, NULL, inet6_dump_ifinfo);
+	if (err < 0)
+		goto errout;
+
+	/* Only the first call to __rtnl_register can fail */
+	__rtnl_register(PF_INET6, RTM_NEWADDR, inet6_rtm_newaddr, NULL);
+	__rtnl_register(PF_INET6, RTM_DELADDR, inet6_rtm_deladdr, NULL);
+	__rtnl_register(PF_INET6, RTM_GETADDR, inet6_rtm_getaddr, inet6_dump_ifaddr);
+	__rtnl_register(PF_INET6, RTM_GETMULTICAST, NULL, inet6_dump_ifmcaddr);
+	__rtnl_register(PF_INET6, RTM_GETANYCAST, NULL, inet6_dump_ifacaddr);
+
 #ifdef CONFIG_SYSCTL
 	addrconf_sysctl.sysctl_header =
 		register_sysctl_table(addrconf_sysctl.addrconf_root_dir);
@@ -4143,6 +4137,10 @@ int __init addrconf_init(void)
 #endif
 
 	return 0;
+errout:
+	unregister_netdevice_notifier(&ipv6_dev_notf);
+
+	return err;
 }
 
 void __exit addrconf_cleanup(void)
@@ -4154,7 +4152,6 @@ void __exit addrconf_cleanup(void)
 
 	unregister_netdevice_notifier(&ipv6_dev_notf);
 
-	rtnetlink_links[PF_INET6] = NULL;
 #ifdef CONFIG_SYSCTL
 	addrconf_sysctl_unregister(&ipv6_devconf_dflt);
 	addrconf_sysctl_unregister(&ipv6_devconf);
Index: net-2.6.22/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.22.orig/net/ipv6/fib6_rules.c	2007-03-22 13:23:12.000000000 +0100
+++ net-2.6.22/net/ipv6/fib6_rules.c	2007-03-22 13:24:02.000000000 +0100
@@ -221,7 +221,7 @@ nla_put_failure:
 	return -ENOBUFS;
 }
 
-int fib6_rules_dump(struct sk_buff *skb, struct netlink_callback *cb)
+static int fib6_rules_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	return fib_rules_dump(skb, cb, AF_INET6);
 }
@@ -259,9 +259,11 @@ void __init fib6_rules_init(void)
 	list_add_tail(&main_rule.common.list, &fib6_rules);
 
 	fib_rules_register(&fib6_rules_ops);
+	__rtnl_register(PF_INET6, RTM_GETRULE, NULL, fib6_rules_dump);
 }
 
 void fib6_rules_cleanup(void)
 {
+	rtnl_unregister(PF_INET6, RTM_GETRULE);
 	fib_rules_unregister(&fib6_rules_ops);
 }
Index: net-2.6.22/include/net/ip6_route.h
===================================================================
--- net-2.6.22.orig/include/net/ip6_route.h	2007-03-22 13:23:12.000000000 +0100
+++ net-2.6.22/include/net/ip6_route.h	2007-03-22 13:24:02.000000000 +0100
@@ -116,12 +116,7 @@ extern void			rt6_pmtu_discovery(struct 
 						   struct net_device *dev,
 						   u32 pmtu);
 
-struct nlmsghdr;
 struct netlink_callback;
-extern int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb);
-extern int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
-extern int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
-extern int inet6_rtm_getroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
 
 struct rt6_rtnl_dump_arg
 {
Index: net-2.6.22/net/ipv6/route.c
===================================================================
--- net-2.6.22.orig/net/ipv6/route.c	2007-03-22 13:23:12.000000000 +0100
+++ net-2.6.22/net/ipv6/route.c	2007-03-22 13:24:02.000000000 +0100
@@ -1994,7 +1994,7 @@ errout:
 	return err;
 }
 
-int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct fib6_config cfg;
 	int err;
@@ -2006,7 +2006,7 @@ int inet6_rtm_delroute(struct sk_buff *s
 	return ip6_route_del(&cfg);
 }
 
-int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct fib6_config cfg;
 	int err;
@@ -2143,7 +2143,7 @@ int rt6_dump_route(struct rt6_info *rt, 
 		     prefix, NLM_F_MULTI);
 }
 
-int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
+static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct nlattr *tb[RTA_MAX+1];
 	struct rt6_info *rt;
@@ -2487,6 +2487,10 @@ void __init ip6_route_init(void)
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	fib6_rules_init();
 #endif
+
+	__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL);
+	__rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL);
+	__rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL);
 }
 
 void ip6_route_cleanup(void)
Index: net-2.6.22/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.22.orig/net/ipv6/ip6_fib.c	2007-03-22 13:23:12.000000000 +0100
+++ net-2.6.22/net/ipv6/ip6_fib.c	2007-03-22 13:24:02.000000000 +0100
@@ -359,7 +359,7 @@ end:
 	return res;
 }
 
-int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
+static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	unsigned int h, s_h;
 	unsigned int e = 0, s_e;
@@ -1478,6 +1478,8 @@ void __init fib6_init(void)
 					   NULL, NULL);
 
 	fib6_tables_init();
+
+	__rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
 }
 
 void fib6_gc_cleanup(void)
Index: net-2.6.22/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.22.orig/net/ipv6/af_inet6.c	2007-03-22 13:23:12.000000000 +0100
+++ net-2.6.22/net/ipv6/af_inet6.c	2007-03-22 13:24:02.000000000 +0100
@@ -945,6 +945,8 @@ static void __exit inet6_exit(void)
 {
 	/* First of all disallow new sockets creation. */
 	sock_unregister(PF_INET6);
+	/* Disallow any further netlink messages */
+	rtnl_unregister_all(PF_INET6);
 
 	/* Cleanup code parts. */
 	ipv6_packet_cleanup();

--

