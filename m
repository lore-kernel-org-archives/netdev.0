From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 03/12] [NEIGH]: Use rtnl registration interface
Date: Wed, 21 Mar 2007 01:05:56 +0100
Message-ID: <20070321000709.645914398@lsx.localdomain>
References: <20070321000553.070942307@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44414 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752352AbXCUAmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:42:11 -0400
Content-Disposition: inline; filename=rtnl_reg_neigh_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/include/net/neighbour.h
===================================================================
--- net-2.6.22.orig/include/net/neighbour.h	2007-03-20 23:53:20.000000000 +0100
+++ net-2.6.22/include/net/neighbour.h	2007-03-21 00:52:29.000000000 +0100
@@ -24,6 +24,7 @@
 
 #include <linux/err.h>
 #include <linux/sysctl.h>
+#include <net/rtnetlink.h>
 
 #define NUD_IN_TIMER	(NUD_INCOMPLETE|NUD_REACHABLE|NUD_DELAY|NUD_PROBE)
 #define NUD_VALID	(NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE|NUD_PROBE|NUD_STALE|NUD_DELAY)
@@ -213,16 +214,7 @@ extern void			pneigh_enqueue(struct neig
 extern struct pneigh_entry	*pneigh_lookup(struct neigh_table *tbl, const void *key, struct net_device *dev, int creat);
 extern int			pneigh_delete(struct neigh_table *tbl, const void *key, struct net_device *dev);
 
-struct netlink_callback;
-struct nlmsghdr;
-extern int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb);
-extern int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
-extern int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
 extern void neigh_app_ns(struct neighbour *n);
-
-extern int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb);
-extern int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
-
 extern void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void *), void *cookie);
 extern void __neigh_for_each_release(struct neigh_table *tbl, int (*cb)(struct neighbour *));
 extern void pneigh_for_each(struct neigh_table *tbl, void (*cb)(struct pneigh_entry *));
Index: net-2.6.22/net/core/neighbour.c
===================================================================
--- net-2.6.22.orig/net/core/neighbour.c	2007-03-20 23:53:21.000000000 +0100
+++ net-2.6.22/net/core/neighbour.c	2007-03-21 00:52:29.000000000 +0100
@@ -1435,7 +1435,7 @@ int neigh_table_clear(struct neigh_table
 	return 0;
 }
 
-int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int nl_neigh_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct ndmsg *ndm;
 	struct nlattr *dst_attr;
@@ -1500,7 +1500,7 @@ out:
 	return err;
 }
 
-int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int nl_neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct ndmsg *ndm;
 	struct nlattr *tb[NDA_MAX+1];
@@ -1780,7 +1780,7 @@ static struct nla_policy nl_ntbl_parm_po
 	[NDTPA_LOCKTIME]		= { .type = NLA_U64 },
 };
 
-int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int nl_neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct neigh_table *tbl;
 	struct ndtmsg *ndtmsg;
@@ -1904,7 +1904,7 @@ errout:
 	return err;
 }
 
-int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
+static int nl_neightbl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int family, tidx, nidx = 0;
 	int tbl_skip = cb->args[0];
@@ -2028,7 +2028,7 @@ out:
 	return rc;
 }
 
-int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
+static int nl_neigh_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct neigh_table *tbl;
 	int t, family, s_t;
@@ -2737,14 +2737,26 @@ void neigh_sysctl_unregister(struct neig
 
 #endif	/* CONFIG_SYSCTL */
 
+static int __init neigh_init(void)
+{
+	rtnl_register(PF_UNSPEC, RTM_NEWNEIGH, nl_neigh_add, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELNEIGH, nl_neigh_del, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETNEIGH, NULL, nl_neigh_dump);
+
+	rtnl_register(PF_UNSPEC, RTM_GETNEIGHTBL, NULL, nl_neightbl_dump);
+	rtnl_register(PF_UNSPEC, RTM_SETNEIGHTBL, nl_neightbl_set, NULL);
+
+	return 0;
+}
+
+subsys_initcall(neigh_init);
+
 EXPORT_SYMBOL(__neigh_event_send);
 EXPORT_SYMBOL(neigh_changeaddr);
 EXPORT_SYMBOL(neigh_compat_output);
 EXPORT_SYMBOL(neigh_connected_output);
 EXPORT_SYMBOL(neigh_create);
-EXPORT_SYMBOL(neigh_delete);
 EXPORT_SYMBOL(neigh_destroy);
-EXPORT_SYMBOL(neigh_dump_info);
 EXPORT_SYMBOL(neigh_event_ns);
 EXPORT_SYMBOL(neigh_ifdown);
 EXPORT_SYMBOL(neigh_lookup);
Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-03-21 00:52:28.000000000 +0100
+++ net-2.6.22/net/core/rtnetlink.c	2007-03-21 00:52:29.000000000 +0100
@@ -962,16 +962,11 @@ static struct rtnetlink_link link_rtnetl
 {
 	[RTM_GETADDR     - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
 	[RTM_GETROUTE    - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
-	[RTM_NEWNEIGH    - RTM_BASE] = { .doit   = neigh_add		 },
-	[RTM_DELNEIGH    - RTM_BASE] = { .doit   = neigh_delete		 },
-	[RTM_GETNEIGH    - RTM_BASE] = { .dumpit = neigh_dump_info	 },
 #ifdef CONFIG_FIB_RULES
 	[RTM_NEWRULE     - RTM_BASE] = { .doit   = fib_nl_newrule	 },
 	[RTM_DELRULE     - RTM_BASE] = { .doit   = fib_nl_delrule	 },
 #endif
 	[RTM_GETRULE     - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
-	[RTM_GETNEIGHTBL - RTM_BASE] = { .dumpit = neightbl_dump_info	 },
-	[RTM_SETNEIGHTBL - RTM_BASE] = { .doit   = neightbl_set		 },
 };
 
 static int rtnetlink_event(struct notifier_block *this, unsigned long event, void *ptr)

--

