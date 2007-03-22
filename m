From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 09/12] [DECNet]: Use rtnl registration interface
Date: Thu, 22 Mar 2007 14:00:04 +0100
Message-ID: <20070322130058.360920786@lsx.localdomain>
References: <20070322125955.055083236@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53663 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894AbXCVNCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:02:11 -0400
Content-Disposition: inline; filename=rtnl_reg_dn_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/include/net/dn_fib.h
===================================================================
--- net-2.6.22.orig/include/net/dn_fib.h	2007-03-22 13:23:13.000000000 +0100
+++ net-2.6.22/include/net/dn_fib.h	2007-03-22 13:24:01.000000000 +0100
@@ -148,17 +148,8 @@ extern void dn_fib_rules_cleanup(void);
 extern unsigned dnet_addr_type(__le16 addr);
 extern int dn_fib_lookup(struct flowi *fl, struct dn_fib_res *res);
 
-/*
- * rtnetlink interface
- */
-extern int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
-extern int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
 extern int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb);
 
-extern int dn_fib_rtm_delrule(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
-extern int dn_fib_rtm_newrule(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
-extern int dn_fib_dump_rules(struct sk_buff *skb, struct netlink_callback *cb);
-
 extern void dn_fib_free_info(struct dn_fib_info *fi);
 
 static inline void dn_fib_info_put(struct dn_fib_info *fi)
Index: net-2.6.22/net/decnet/dn_rules.c
===================================================================
--- net-2.6.22.orig/net/decnet/dn_rules.c	2007-03-22 13:23:13.000000000 +0100
+++ net-2.6.22/net/decnet/dn_rules.c	2007-03-22 13:24:01.000000000 +0100
@@ -241,7 +241,7 @@ static u32 dn_fib_rule_default_pref(void
 	return 0;
 }
 
-int dn_fib_dump_rules(struct sk_buff *skb, struct netlink_callback *cb)
+static int dn_fib_dump_rules(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	return fib_rules_dump(skb, cb, AF_DECnet);
 }
@@ -265,10 +265,12 @@ void __init dn_fib_rules_init(void)
 {
 	list_add_tail(&default_rule.common.list, &dn_fib_rules);
 	fib_rules_register(&dn_fib_rules_ops);
+	rtnl_register(PF_DECnet, RTM_GETRULE, NULL, dn_fib_dump_rules);
 }
 
 void __exit dn_fib_rules_cleanup(void)
 {
+	rtnl_unregister(PF_DECnet, RTM_GETRULE);
 	fib_rules_unregister(&dn_fib_rules_ops);
 }
 
Index: net-2.6.22/net/decnet/dn_fib.c
===================================================================
--- net-2.6.22.orig/net/decnet/dn_fib.c	2007-03-22 13:23:13.000000000 +0100
+++ net-2.6.22/net/decnet/dn_fib.c	2007-03-22 13:24:01.000000000 +0100
@@ -501,7 +501,7 @@ static int dn_fib_check_attr(struct rtms
 	return 0;
 }
 
-int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct dn_fib_table *tb;
 	struct rtattr **rta = arg;
@@ -517,7 +517,7 @@ int dn_fib_rtm_delroute(struct sk_buff *
 	return -ESRCH;
 }
 
-int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct dn_fib_table *tb;
 	struct rtattr **rta = arg;
@@ -745,11 +745,13 @@ void __exit dn_fib_cleanup(void)
 
 void __init dn_fib_init(void)
 {
-
 	dn_fib_table_init();
 	dn_fib_rules_init();
 
 	register_dnaddr_notifier(&dn_fib_dnaddr_notifier);
+
+	rtnl_register(PF_DECnet, RTM_NEWROUTE, dn_fib_rtm_newroute, NULL);
+	rtnl_register(PF_DECnet, RTM_DELROUTE, dn_fib_rtm_delroute, NULL);
 }
 
 
Index: net-2.6.22/net/decnet/af_decnet.c
===================================================================
--- net-2.6.22.orig/net/decnet/af_decnet.c	2007-03-22 13:23:13.000000000 +0100
+++ net-2.6.22/net/decnet/af_decnet.c	2007-03-22 13:24:01.000000000 +0100
@@ -2413,6 +2413,7 @@ module_init(decnet_init);
 static void __exit decnet_exit(void)
 {
 	sock_unregister(AF_DECnet);
+	rtnl_unregister_all(PF_DECnet);
 	dev_remove_pack(&dn_dix_packet_type);
 
 	dn_unregister_sysctl();
Index: net-2.6.22/net/decnet/dn_dev.c
===================================================================
--- net-2.6.22.orig/net/decnet/dn_dev.c	2007-03-22 13:23:13.000000000 +0100
+++ net-2.6.22/net/decnet/dn_dev.c	2007-03-22 13:24:01.000000000 +0100
@@ -1447,24 +1447,6 @@ static const struct file_operations dn_d
 
 #endif /* CONFIG_PROC_FS */
 
-static struct rtnetlink_link dnet_rtnetlink_table[RTM_NR_MSGTYPES] =
-{
-	[RTM_NEWADDR  - RTM_BASE] = { .doit	= dn_nl_newaddr,	},
-	[RTM_DELADDR  - RTM_BASE] = { .doit	= dn_nl_deladdr,	},
-	[RTM_GETADDR  - RTM_BASE] = { .dumpit	= dn_nl_dump_ifaddr,	},
-#ifdef CONFIG_DECNET_ROUTER
-	[RTM_NEWROUTE - RTM_BASE] = { .doit	= dn_fib_rtm_newroute,	},
-	[RTM_DELROUTE - RTM_BASE] = { .doit	= dn_fib_rtm_delroute,	},
-	[RTM_GETROUTE - RTM_BASE] = { .doit	= dn_cache_getroute,
-				      .dumpit	= dn_fib_dump,		},
-	[RTM_GETRULE  - RTM_BASE] = { .dumpit	= dn_fib_dump_rules,	},
-#else
-	[RTM_GETROUTE - RTM_BASE] = { .doit	= dn_cache_getroute,
-				      .dumpit	= dn_cache_dump,	},
-#endif
-
-};
-
 static int __initdata addr[2];
 module_param_array(addr, int, NULL, 0444);
 MODULE_PARM_DESC(addr, "The DECnet address of this machine: area,node");
@@ -1485,7 +1467,9 @@ void __init dn_dev_init(void)
 
 	dn_dev_devices_on();
 
-	rtnetlink_links[PF_DECnet] = dnet_rtnetlink_table;
+	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL);
+	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL);
+	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr);
 
 	proc_net_fops_create("decnet_dev", S_IRUGO, &dn_dev_seq_fops);
 
@@ -1500,8 +1484,6 @@ void __init dn_dev_init(void)
 
 void __exit dn_dev_cleanup(void)
 {
-	rtnetlink_links[PF_DECnet] = NULL;
-
 #ifdef CONFIG_SYSCTL
 	{
 		int i;
Index: net-2.6.22/include/net/dn_route.h
===================================================================
--- net-2.6.22.orig/include/net/dn_route.h	2007-03-22 13:23:13.000000000 +0100
+++ net-2.6.22/include/net/dn_route.h	2007-03-22 13:24:01.000000000 +0100
@@ -18,7 +18,6 @@
 extern struct sk_buff *dn_alloc_skb(struct sock *sk, int size, gfp_t pri);
 extern int dn_route_output_sock(struct dst_entry **pprt, struct flowi *, struct sock *sk, int flags);
 extern int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb);
-extern int dn_cache_getroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
 extern void dn_rt_cache_flush(int delay);
 
 /* Masks for flags field */
Index: net-2.6.22/net/decnet/dn_route.c
===================================================================
--- net-2.6.22.orig/net/decnet/dn_route.c	2007-03-22 13:23:13.000000000 +0100
+++ net-2.6.22/net/decnet/dn_route.c	2007-03-22 13:24:01.000000000 +0100
@@ -1522,7 +1522,7 @@ rtattr_failure:
 /*
  * This is called by both endnodes and routers now.
  */
-int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void *arg)
+static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct rtattr **rta = arg;
 	struct rtmsg *rtm = NLMSG_DATA(nlh);
@@ -1813,6 +1813,13 @@ void __init dn_route_init(void)
 	dn_dst_ops.gc_thresh = (dn_rt_hash_mask + 1);
 
 	proc_net_fops_create("decnet_cache", S_IRUGO, &dn_rt_cache_seq_fops);
+
+#ifdef CONFIG_DECNET_ROUTER
+	rtnl_register(PF_DECnet, RTM_GETROUTE, dn_cache_getroute, dn_fib_dump);
+#else
+	rtnl_register(PF_DECnet, RTM_GETROUTE, dn_cache_getroute,
+		      dn_cache_dump);
+#endif
 }
 
 void __exit dn_route_cleanup(void)

--

