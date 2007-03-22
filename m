From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 05/12] [IPv4]: Use rtnl registration interface
Date: Thu, 22 Mar 2007 14:00:00 +0100
Message-ID: <20070322130057.809466206@lsx.localdomain>
References: <20070322125955.055083236@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53649 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751487AbXCVNBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:01:50 -0400
Content-Disposition: inline; filename=rtnl_reg_ip4_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/include/net/ip_fib.h
===================================================================
--- net-2.6.22.orig/include/net/ip_fib.h	2007-03-22 12:48:05.000000000 +0100
+++ net-2.6.22/include/net/ip_fib.h	2007-03-22 12:53:03.000000000 +0100
@@ -215,10 +215,6 @@ extern void fib_select_default(const str
 /* Exported by fib_frontend.c */
 extern struct nla_policy rtm_ipv4_policy[];
 extern void		ip_fib_init(void);
-extern int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
-extern int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
-extern int inet_rtm_getroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
-extern int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb);
 extern int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			       struct net_device *dev, __be32 *spec_dst, u32 *itag);
 extern void fib_select_multipath(const struct flowi *flp, struct fib_result *res);
@@ -235,8 +231,6 @@ extern __be32  __fib_res_prefsrc(struct 
 extern struct fib_table *fib_hash_init(u32 id);
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-extern int fib4_rules_dump(struct sk_buff *skb, struct netlink_callback *cb);
-
 extern void __init fib4_rules_init(void);
 
 #ifdef CONFIG_NET_CLS_ROUTE
Index: net-2.6.22/net/ipv4/devinet.c
===================================================================
--- net-2.6.22.orig/net/ipv4/devinet.c	2007-03-22 12:48:05.000000000 +0100
+++ net-2.6.22/net/ipv4/devinet.c	2007-03-22 12:54:49.000000000 +0100
@@ -48,7 +48,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/notifier.h>
 #include <linux/inetdevice.h>
@@ -62,7 +61,7 @@
 #include <net/ip.h>
 #include <net/route.h>
 #include <net/ip_fib.h>
-#include <net/netlink.h>
+#include <net/rtnetlink.h>
 
 struct ipv4_devconf ipv4_devconf = {
 	.accept_redirects = 1,
@@ -1241,19 +1240,6 @@ errout:
 		rtnl_set_sk_err(RTNLGRP_IPV4_IFADDR, err);
 }
 
-static struct rtnetlink_link inet_rtnetlink_table[RTM_NR_MSGTYPES] = {
-	[RTM_NEWADDR  - RTM_BASE] = { .doit	= inet_rtm_newaddr,	},
-	[RTM_DELADDR  - RTM_BASE] = { .doit	= inet_rtm_deladdr,	},
-	[RTM_GETADDR  - RTM_BASE] = { .dumpit	= inet_dump_ifaddr,	},
-	[RTM_NEWROUTE - RTM_BASE] = { .doit	= inet_rtm_newroute,	},
-	[RTM_DELROUTE - RTM_BASE] = { .doit	= inet_rtm_delroute,	},
-	[RTM_GETROUTE - RTM_BASE] = { .doit	= inet_rtm_getroute,
-				      .dumpit	= inet_dump_fib,	},
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-	[RTM_GETRULE  - RTM_BASE] = { .dumpit	= fib4_rules_dump,	},
-#endif
-};
-
 #ifdef CONFIG_SYSCTL
 
 void inet_forward_change(void)
@@ -1636,7 +1622,10 @@ void __init devinet_init(void)
 {
 	register_gifconf(PF_INET, inet_gifconf);
 	register_netdevice_notifier(&ip_netdev_notifier);
-	rtnetlink_links[PF_INET] = inet_rtnetlink_table;
+
+	rtnl_register(PF_INET, RTM_NEWADDR, inet_rtm_newaddr, NULL);
+	rtnl_register(PF_INET, RTM_DELADDR, inet_rtm_deladdr, NULL);
+	rtnl_register(PF_INET, RTM_GETADDR, NULL, inet_dump_ifaddr);
 #ifdef CONFIG_SYSCTL
 	devinet_sysctl.sysctl_header =
 		register_sysctl_table(devinet_sysctl.devinet_root_dir);
Index: net-2.6.22/net/ipv4/fib_rules.c
===================================================================
--- net-2.6.22.orig/net/ipv4/fib_rules.c	2007-03-22 12:48:05.000000000 +0100
+++ net-2.6.22/net/ipv4/fib_rules.c	2007-03-22 13:23:53.000000000 +0100
@@ -277,7 +277,7 @@ nla_put_failure:
 	return -ENOBUFS;
 }
 
-int fib4_rules_dump(struct sk_buff *skb, struct netlink_callback *cb)
+static int fib4_rule_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	return fib_rules_dump(skb, cb, AF_INET);
 }
@@ -329,4 +329,6 @@ void __init fib4_rules_init(void)
 	list_add_tail(&default_rule.common.list, &fib4_rules);
 
 	fib_rules_register(&fib4_rules_ops);
+
+	rtnl_register(PF_INET, RTM_GETRULE, NULL, fib4_rule_dump);
 }
Index: net-2.6.22/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.22.orig/net/ipv4/fib_frontend.c	2007-03-22 12:48:05.000000000 +0100
+++ net-2.6.22/net/ipv4/fib_frontend.c	2007-03-22 12:57:04.000000000 +0100
@@ -34,7 +34,6 @@
 #include <linux/if_addr.h>
 #include <linux/if_arp.h>
 #include <linux/skbuff.h>
-#include <linux/netlink.h>
 #include <linux/init.h>
 #include <linux/list.h>
 
@@ -46,6 +45,7 @@
 #include <net/icmp.h>
 #include <net/arp.h>
 #include <net/ip_fib.h>
+#include <net/rtnetlink.h>
 
 #define FFprint(a...) printk(KERN_DEBUG a)
 
@@ -535,7 +535,7 @@ errout:
 	return err;
 }
 
-int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct fib_config cfg;
 	struct fib_table *tb;
@@ -556,7 +556,7 @@ errout:
 	return err;
 }
 
-int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct fib_config cfg;
 	struct fib_table *tb;
@@ -577,7 +577,7 @@ errout:
 	return err;
 }
 
-int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
+static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	unsigned int h, s_h;
 	unsigned int e = 0, s_e;
@@ -914,6 +914,10 @@ void __init ip_fib_init(void)
 	register_netdevice_notifier(&fib_netdev_notifier);
 	register_inetaddr_notifier(&fib_inetaddr_notifier);
 	nl_fib_lookup_init();
+
+	rtnl_register(PF_INET, RTM_NEWROUTE, inet_rtm_newroute, NULL);
+	rtnl_register(PF_INET, RTM_DELROUTE, inet_rtm_delroute, NULL);
+	rtnl_register(PF_INET, RTM_GETROUTE, NULL, inet_dump_fib);
 }
 
 EXPORT_SYMBOL(inet_addr_type);
Index: net-2.6.22/net/ipv4/route.c
===================================================================
--- net-2.6.22.orig/net/ipv4/route.c	2007-03-22 12:48:05.000000000 +0100
+++ net-2.6.22/net/ipv4/route.c	2007-03-22 12:57:26.000000000 +0100
@@ -82,7 +82,6 @@
 #include <linux/proc_fs.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
 #include <linux/pkt_sched.h>
@@ -104,6 +103,7 @@
 #include <net/xfrm.h>
 #include <net/ip_mp_alg.h>
 #include <net/netevent.h>
+#include <net/rtnetlink.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -2721,7 +2721,7 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
+static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct rtmsg *rtm;
 	struct nlattr *tb[RTA_MAX+1];
@@ -3194,6 +3194,8 @@ int __init ip_rt_init(void)
 	xfrm_init();
 	xfrm4_init();
 #endif
+	rtnl_register(PF_INET, RTM_GETROUTE, inet_rtm_getroute, NULL);
+
 	return rc;
 }
 

--

