From: Thomas Graf <tgraf@suug.ch>
Subject: [NETLINK]: Do precise netlink message allocations where possible
Date: Fri, 10 Nov 2006 13:17:06 +0100
Message-ID: <20061110121706.GH8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:51683 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932851AbWKJMQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 07:16:47 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Account for the netlink message header size directly in nlmsg_new()
instead of relying on the caller calculate it correctly.

Replaces error handling of message construction functions when
constructing notifications with bug traps since a failure implies
a bug in calculating the size of the skb.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/net/netlink.h
===================================================================
--- net-2.6.20.orig/include/net/netlink.h	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/include/net/netlink.h	2006-11-10 11:18:34.000000000 +0100
@@ -500,14 +500,15 @@
 
 /**
  * nlmsg_new - Allocate a new netlink message
- * @size: maximum size of message
+ * @payload: size of the message payload
  * @flags: the type of memory to allocate.
  *
- * Use NLMSG_GOODSIZE if size isn't know and you need a good default size.
+ * Use NLMSG_DEFAULT_SIZE if the size of the payload isn't known
+ * and a good default is needed.
  */
-static inline struct sk_buff *nlmsg_new(int size, gfp_t flags)
+static inline struct sk_buff *nlmsg_new(size_t payload, gfp_t flags)
 {
-	return alloc_skb(size, flags);
+	return alloc_skb(nlmsg_total_size(payload), flags);
 }
 
 /**
Index: net-2.6.20/include/linux/netlink.h
===================================================================
--- net-2.6.20.orig/include/linux/netlink.h	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/include/linux/netlink.h	2006-11-10 11:18:34.000000000 +0100
@@ -174,6 +174,7 @@
  */
 #define NLMSG_GOODORDER 0
 #define NLMSG_GOODSIZE (SKB_MAX_ORDER(0, NLMSG_GOODORDER))
+#define NLMSG_DEFAULT_SIZE (NLMSG_GOODSIZE - NLMSG_HDRLEN)
 
 
 struct netlink_callback
Index: net-2.6.20/net/ipv4/fib_semantics.c
===================================================================
--- net-2.6.20.orig/net/ipv4/fib_semantics.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/ipv4/fib_semantics.c	2006-11-10 13:06:19.000000000 +0100
@@ -273,25 +273,49 @@
 	return -1;
 }
 
+static inline size_t fib_nlmsg_size(struct fib_info *fi)
+{
+	size_t payload = NLMSG_ALIGN(sizeof(struct rtmsg))
+			 + nla_total_size(4) /* RTA_TABLE */
+			 + nla_total_size(4) /* RTA_DST */
+			 + nla_total_size(4) /* RTA_PRIORITY */
+			 + nla_total_size(4); /* RTA_PREFSRC */
+
+	/* space for nested metrics */
+	payload += nla_total_size((RTAX_MAX * nla_total_size(4)));
+
+	if (fi->fib_nhs) {
+		/* Also handles the special case fib_nhs == 1 */
+
+		/* each nexthop is packed in an attribute */
+		size_t nhsize = nla_total_size(sizeof(struct rtnexthop));
+
+		/* may contain flow and gateway attribute */
+		nhsize += 2 * nla_total_size(4);
+
+		/* all nexthops are packed in a nested attribute */
+		payload += nla_total_size(fi->fib_nhs * nhsize);
+	}
+
+	return payload;
+}
+
 void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
 	       int dst_len, u32 tb_id, struct nl_info *info)
 {
 	struct sk_buff *skb;
-	int payload = sizeof(struct rtmsg) + 256;
 	u32 seq = info->nlh ? info->nlh->nlmsg_seq : 0;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(nlmsg_total_size(payload), GFP_KERNEL);
+	skb = nlmsg_new(fib_nlmsg_size(fa->fa_info), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
 
 	err = fib_dump_info(skb, info->pid, seq, event, tb_id,
 			    fa->fa_type, fa->fa_scope, key, dst_len,
 			    fa->fa_tos, fa->fa_info, 0);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout;
-	}
+	/* failure implies BUG in fib_nlmsg_size() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, info->pid, RTNLGRP_IPV4_ROUTE,
 			  info->nlh, GFP_KERNEL);
Index: net-2.6.20/kernel/taskstats.c
===================================================================
--- net-2.6.20.orig/kernel/taskstats.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/kernel/taskstats.c	2006-11-10 11:18:34.000000000 +0100
@@ -77,8 +77,7 @@
 	/*
 	 * If new attributes are added, please revisit this allocation
 	 */
-	size = nlmsg_total_size(genlmsg_total_size(size));
-	skb = nlmsg_new(size, GFP_KERNEL);
+	skb = nlmsg_new(genlmsg_total_size(size), GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 
Index: net-2.6.20/net/bridge/br_netlink.c
===================================================================
--- net-2.6.20.orig/net/bridge/br_netlink.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/bridge/br_netlink.c	2006-11-10 13:00:46.000000000 +0100
@@ -15,6 +15,18 @@
 #include <net/netlink.h>
 #include "br_private.h"
 
+static inline size_t br_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
+	       + nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
+	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
+	       + nla_total_size(4) /* IFLA_MASTER */
+	       + nla_total_size(4) /* IFLA_MTU */
+	       + nla_total_size(4) /* IFLA_LINK */
+	       + nla_total_size(1) /* IFLA_OPERSTATE */
+	       + nla_total_size(1); /* IFLA_PROTINFO */
+}
+
 /*
  * Create one netlink message for one interface
  * Contains port and master info as well as carrier and bridge state.
@@ -77,19 +89,16 @@
 void br_ifinfo_notify(int event, struct net_bridge_port *port)
 {
 	struct sk_buff *skb;
-	int payload = sizeof(struct ifinfomsg) + 128;
 	int err = -ENOBUFS;
 
 	pr_debug("bridge notify event=%d\n", event);
-	skb = nlmsg_new(nlmsg_total_size(payload), GFP_ATOMIC);
+	skb = nlmsg_new(br_nlmsg_size(), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
 
 	err = br_fill_ifinfo(skb, port, 0, 0, event, 0);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout;
-	}
+	/* failure implies BUG in br_nlmsg_size() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
 errout:
Index: net-2.6.20/net/core/fib_rules.c
===================================================================
--- net-2.6.20.orig/net/core/fib_rules.c	2006-11-10 01:46:06.000000000 +0100
+++ net-2.6.20/net/core/fib_rules.c	2006-11-10 11:19:26.000000000 +0100
@@ -306,6 +306,22 @@
 	return err;
 }
 
+static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
+					 struct fib_rule *rule)
+{
+	size_t payload = NLMSG_ALIGN(sizeof(struct fib_rule_hdr))
+			 + nla_total_size(IFNAMSIZ) /* FRA_IFNAME */
+			 + nla_total_size(4) /* FRA_PRIORITY */
+			 + nla_total_size(4) /* FRA_TABLE */
+			 + nla_total_size(4) /* FRA_FWMARK */
+			 + nla_total_size(4); /* FRA_FWMASK */
+
+	if (ops->nlmsg_payload)
+		payload += ops->nlmsg_payload(rule);
+
+	return payload;
+}
+
 static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 			    u32 pid, u32 seq, int type, int flags,
 			    struct fib_rules_ops *ops)
@@ -384,15 +400,13 @@
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	skb = nlmsg_new(fib_rule_nlmsg_size(ops, rule), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
 
 	err = fib_nl_fill_rule(skb, rule, pid, nlh->nlmsg_seq, event, 0, ops);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout;
-	}
+	/* failure implies BUG in fib_rule_nlmsg_size() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, pid, ops->nlgroup, nlh, GFP_KERNEL);
 errout:
Index: net-2.6.20/net/core/neighbour.c
===================================================================
--- net-2.6.20.orig/net/core/neighbour.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/core/neighbour.c	2006-11-10 12:58:23.000000000 +0100
@@ -2410,20 +2410,27 @@
 #endif /* CONFIG_PROC_FS */
 
 #ifdef CONFIG_ARPD
+static inline size_t neigh_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct ndmsg))
+	       + nla_total_size(MAX_ADDR_LEN) /* NDA_DST */
+	       + nla_total_size(MAX_ADDR_LEN) /* NDA_LLADDR */
+	       + nla_total_size(sizeof(struct nda_cacheinfo))
+	       + nla_total_size(4); /* NDA_PROBES */
+}
+
 static void __neigh_notify(struct neighbour *n, int type, int flags)
 {
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	skb = nlmsg_new(neigh_nlmsg_size(), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
 
 	err = neigh_fill_info(skb, n, 0, 0, type, flags);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout;
-	}
+	/* failure implies BUG in neigh_nlmsg_size() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, 0, RTNLGRP_NEIGH, NULL, GFP_ATOMIC);
 errout:
Index: net-2.6.20/net/decnet/dn_table.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_table.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/decnet/dn_table.c	2006-11-10 13:05:22.000000000 +0100
@@ -263,6 +263,32 @@
 	return 0;
 }
 
+static inline size_t dn_fib_nlmsg_size(struct dn_fib_info *fi)
+{
+	size_t payload = NLMSG_ALIGN(struct rtmsg)
+			 + nla_total_size(4) /* RTA_TABLE */
+			 + nla_total_size(2) /* RTA_DST */
+			 + nla_total_size(4); /* RTA_PRIORITY */
+
+	/* space for nested metrics */
+	payload += nla_total_size((RTAX_MAX * nla_total_size(4)));
+
+	if (fi->fib_nhs) {
+		/* Also handles the special case fib_nhs == 1 */
+
+		/* each nexthop is packed in an attribute */
+		size_t nhsize = nla_total_size(sizeof(struct rtnexthop));
+
+		/* may contain a gateway attribute */
+		nhsize += nla_total_size(4);
+
+		/* all nexthops are packed in a nested attribute */
+		payload += nla_total_size(fi->fib_nhs * nhsize);
+	}
+
+	return payload;
+}
+
 static int dn_fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
                         u32 tb_id, u8 type, u8 scope, void *dst, int dst_len,
                         struct dn_fib_info *fi, unsigned int flags)
@@ -335,17 +361,15 @@
         u32 pid = req ? req->pid : 0;
 	int err = -ENOBUFS;
 
-        skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+        skb = nlmsg_new(dn_fib_nlmsg_size(DN_FIB_INFO(f), GFP_KERNEL));
         if (skb == NULL)
 		goto errout;
 
         err = dn_fib_dump_info(skb, pid, nlh->nlmsg_seq, event, tb_id,
 			       f->fn_type, f->fn_scope, &f->fn_key, z,
 			       DN_FIB_INFO(f), 0);
-	if (err < 0) {
-                kfree_skb(skb);
-		goto errout;
-        }
+	/* failure implies BUG in dn_fib_nlmsg_size() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, pid, RTNLGRP_DECnet_ROUTE, nlh, GFP_KERNEL);
 errout:
Index: net-2.6.20/net/ipv4/devinet.c
===================================================================
--- net-2.6.20.orig/net/ipv4/devinet.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/ipv4/devinet.c	2006-11-10 12:43:30.000000000 +0100
@@ -1120,6 +1120,16 @@
 	.notifier_call =inetdev_event,
 };
 
+static inline size_t inet_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct ifaddrmsg))
+	       + nla_total_size(4) /* IFA_ADDRESS */
+	       + nla_total_size(4) /* IFA_LOCAL */
+	       + nla_total_size(4) /* IFA_BROADCAST */
+	       + nla_total_size(4) /* IFA_ANYCAST */
+	       + nla_total_size(IFNAMSIZ); /* IFA_LABEL */
+}
+
 static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
 			    u32 pid, u32 seq, int event, unsigned int flags)
 {
@@ -1208,15 +1218,13 @@
 	u32 seq = nlh ? nlh->nlmsg_seq : 0;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	skb = nlmsg_new(inet_nlmsg_size(), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
 
 	err = inet_fill_ifaddr(skb, ifa, pid, seq, event, 0);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout;
-	}
+	/* failure implies BUG in inet_nlmsg_size() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, pid, RTNLGRP_IPV4_IFADDR, nlh, GFP_KERNEL);
 errout:
Index: net-2.6.20/net/ipv6/addrconf.c
===================================================================
--- net-2.6.20.orig/net/ipv6/addrconf.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/ipv6/addrconf.c	2006-11-10 12:42:03.000000000 +0100
@@ -3098,10 +3098,9 @@
 
 static inline int inet6_ifaddr_msgsize(void)
 {
-	return nlmsg_total_size(sizeof(struct ifaddrmsg) +
-				nla_total_size(16) +
-				nla_total_size(sizeof(struct ifa_cacheinfo)) +
-				128);
+	return NLMSG_ALIGN(sizeof(struct ifaddrmsg))
+	       + nla_total_size(16) /* IFA_ADDRESS */
+	       + nla_total_size(sizeof(struct ifa_cacheinfo));
 }
 
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
@@ -3329,10 +3328,8 @@
 
 	err = inet6_fill_ifaddr(skb, ifa, NETLINK_CB(in_skb).pid,
 				nlh->nlmsg_seq, RTM_NEWADDR, 0);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout_ifa;
-	}
+	/* failure implies BUG in inet6_ifaddr_msgsize() */
+	BUG_ON(err < 0);
 
 	err = rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
 errout_ifa:
@@ -3351,10 +3348,8 @@
 		goto errout;
 
 	err = inet6_fill_ifaddr(skb, ifa, 0, 0, event, 0);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout;
-	}
+	/* failure implies BUG in inet6_ifaddr_msgsize() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
 errout:
@@ -3397,16 +3392,19 @@
 	array[DEVCONF_PROXY_NDP] = cnf->proxy_ndp;
 }
 
-/* Maximum length of ifinfomsg attributes */
-#define INET6_IFINFO_RTA_SPACE \
-		RTA_SPACE(IFNAMSIZ) /* IFNAME */ + \
-		RTA_SPACE(MAX_ADDR_LEN) /* ADDRESS */ +	\
-		RTA_SPACE(sizeof(u32)) /* MTU */ + \
-		RTA_SPACE(sizeof(int)) /* LINK */ + \
-		RTA_SPACE(0) /* PROTINFO */ + \
-		RTA_SPACE(sizeof(u32)) /* FLAGS */ + \
-		RTA_SPACE(sizeof(struct ifla_cacheinfo)) /* CACHEINFO */ + \
-		RTA_SPACE(sizeof(__s32[DEVCONF_MAX])) /* CONF */
+static inline size_t inet6_if_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
+	       + nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
+	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
+	       + nla_total_size(4) /* IFLA_MTU */
+	       + nla_total_size(4) /* IFLA_LINK */
+	       + nla_total_size( /* IFLA_PROTINFO */
+			nla_total_size(4) /* IFLA_INET6_FLAGS */
+			+ nla_total_size(sizeof(struct ifla_cacheinfo))
+			+ nla_total_size(DEVCONF_MAX * 4) /* IFLA_INET6_CONF */
+		 );
+}
 
 static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev, 
 			     u32 pid, u32 seq, int event, unsigned int flags)
@@ -3501,18 +3499,15 @@
 void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
 {
 	struct sk_buff *skb;
-	int payload = sizeof(struct ifinfomsg) + INET6_IFINFO_RTA_SPACE;
 	int err = -ENOBUFS;
 	
-	skb = nlmsg_new(nlmsg_total_size(payload), GFP_ATOMIC);
+	skb = nlmsg_new(inet6_if_nlmsg_size(), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
 
 	err = inet6_fill_ifinfo(skb, idev, 0, 0, event, 0);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout;
-	}
+	/* failure implies BUG in inet6_if_nlmsg_size() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
 errout:
@@ -3520,10 +3515,12 @@
 		rtnl_set_sk_err(RTNLGRP_IPV6_IFADDR, err);
 }
 
-/* Maximum length of prefix_cacheinfo attributes */
-#define INET6_PREFIX_RTA_SPACE \
-		RTA_SPACE(sizeof(((struct prefix_info *)NULL)->prefix)) /* ADDRESS */ + \
-		RTA_SPACE(sizeof(struct prefix_cacheinfo)) /* CACHEINFO */
+static inline size_t inet6_prefix_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct prefixmsg))
+	       + nla_total_size(sizeof(struct in6_addr))
+	       + nla_total_size(sizeof(struct prefix_cacheinfo));
+}
 
 static int inet6_fill_prefix(struct sk_buff *skb, struct inet6_dev *idev,
 			struct prefix_info *pinfo, u32 pid, u32 seq, 
@@ -3569,18 +3566,15 @@
 			 struct prefix_info *pinfo)
 {
 	struct sk_buff *skb;
-	int payload = sizeof(struct prefixmsg) + INET6_PREFIX_RTA_SPACE;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(nlmsg_total_size(payload), GFP_ATOMIC);
+	skb = nlmsg_new(inet6_prefix_nlmsg_size(), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
 
 	err = inet6_fill_prefix(skb, idev, pinfo, 0, 0, event, 0);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout;
-	}
+	/* failure implies BUG in inet6_prefix_nlmsg_size() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, 0, RTNLGRP_IPV6_PREFIX, NULL, GFP_ATOMIC);
 errout:
Index: net-2.6.20/net/ipv6/route.c
===================================================================
--- net-2.6.20.orig/net/ipv6/route.c	2006-11-10 01:46:06.000000000 +0100
+++ net-2.6.20/net/ipv6/route.c	2006-11-10 11:18:34.000000000 +0100
@@ -2005,6 +2005,20 @@
 	return ip6_route_add(&cfg);
 }
 
+static inline size_t rt6_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct rtmsg))
+	       + nla_total_size(16) /* RTA_SRC */
+	       + nla_total_size(16) /* RTA_DST */
+	       + nla_total_size(16) /* RTA_GATEWAY */
+	       + nla_total_size(16) /* RTA_PREFSRC */
+	       + nla_total_size(4) /* RTA_TABLE */
+	       + nla_total_size(4) /* RTA_IIF */
+	       + nla_total_size(4) /* RTA_OIF */
+	       + nla_total_size(4) /* RTA_PRIORITY */
+	       + nla_total_size(sizeof(struct rta_cacheinfo));
+}
+
 static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
 			 struct in6_addr *dst, struct in6_addr *src,
 			 int iif, int type, u32 pid, u32 seq,
@@ -2199,7 +2213,6 @@
 	struct sk_buff *skb;
 	u32 pid = 0, seq = 0;
 	struct nlmsghdr *nlh = NULL;
-	int payload = sizeof(struct rtmsg) + 256;
 	int err = -ENOBUFS;
 
 	if (info) {
@@ -2209,15 +2222,13 @@
 			seq = nlh->nlmsg_seq;
 	}
 
-	skb = nlmsg_new(nlmsg_total_size(payload), gfp_any());
+	skb = nlmsg_new(rt6_nlmsg_size(), gfp_any());
 	if (skb == NULL)
 		goto errout;
 
 	err = rt6_fill_node(skb, rt, NULL, NULL, 0, event, pid, seq, 0, 0);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout;
-	}
+	/* failure implies BUG in rt6_nlmsg_size() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, pid, RTNLGRP_IPV6_ROUTE, nlh, gfp_any());
 errout:
Index: net-2.6.20/net/netlabel/netlabel_mgmt.c
===================================================================
--- net-2.6.20.orig/net/netlabel/netlabel_mgmt.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/netlabel/netlabel_mgmt.c	2006-11-10 11:18:34.000000000 +0100
@@ -356,7 +356,7 @@
 	void *data;
 	struct netlbl_dom_map *entry;
 
-	ans_skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	ans_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (ans_skb == NULL)
 		return -ENOMEM;
 	data = netlbl_netlink_hdr_put(ans_skb,
@@ -492,7 +492,7 @@
 	struct sk_buff *ans_skb = NULL;
 	void *data;
 
-	ans_skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	ans_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (ans_skb == NULL)
 		return -ENOMEM;
 	data = netlbl_netlink_hdr_put(ans_skb,
Index: net-2.6.20/net/netlabel/netlabel_unlabeled.c
===================================================================
--- net-2.6.20.orig/net/netlabel/netlabel_unlabeled.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/netlabel/netlabel_unlabeled.c	2006-11-10 11:18:34.000000000 +0100
@@ -138,7 +138,7 @@
 	struct sk_buff *ans_skb;
 	void *data;
 
-	ans_skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	ans_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (ans_skb == NULL)
 		goto list_failure;
 	data = netlbl_netlink_hdr_put(ans_skb,
Index: net-2.6.20/net/netlink/af_netlink.c
===================================================================
--- net-2.6.20.orig/net/netlink/af_netlink.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/netlink/af_netlink.c	2006-11-10 11:18:34.000000000 +0100
@@ -1148,7 +1148,7 @@
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
 	err = -ENOBUFS;
-	skb = nlmsg_new(len, GFP_KERNEL);
+	skb = alloc_skb(len, GFP_KERNEL);
 	if (skb==NULL)
 		goto out;
 
@@ -1435,14 +1435,13 @@
 	struct sk_buff *skb;
 	struct nlmsghdr *rep;
 	struct nlmsgerr *errmsg;
-	int size;
+	size_t payload = sizeof(*errmsg);
 
-	if (err == 0)
-		size = nlmsg_total_size(sizeof(*errmsg));
-	else
-		size = nlmsg_total_size(sizeof(*errmsg) + nlmsg_len(nlh));
+	/* error messages get the original request appened */
+	if (err)
+		payload += nlmsg_len(nlh);
 
-	skb = nlmsg_new(size, GFP_KERNEL);
+	skb = nlmsg_new(payload, GFP_KERNEL);
 	if (!skb) {
 		struct sock *sk;
 
Index: net-2.6.20/net/netlink/genetlink.c
===================================================================
--- net-2.6.20.orig/net/netlink/genetlink.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/netlink/genetlink.c	2006-11-10 11:18:34.000000000 +0100
@@ -480,7 +480,7 @@
 	struct sk_buff *skb;
 	int err;
 
-	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (skb == NULL)
 		return ERR_PTR(-ENOBUFS);
 
Index: net-2.6.20/net/core/rtnetlink.c
===================================================================
--- net-2.6.20.orig/net/core/rtnetlink.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/core/rtnetlink.c	2006-11-10 12:37:21.000000000 +0100
@@ -273,6 +273,25 @@
 	a->tx_compressed = b->tx_compressed;
 };
 
+static inline size_t if_nlmsg_size(int iwbuflen)
+{
+	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
+	       + nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
+	       + nla_total_size(IFNAMSIZ) /* IFLA_QDISC */
+	       + nla_total_size(sizeof(struct rtnl_link_ifmap))
+	       + nla_total_size(sizeof(struct rtnl_link_stats))
+	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
+	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_BROADCAST */
+	       + nla_total_size(4) /* IFLA_TXQLEN */
+	       + nla_total_size(4) /* IFLA_WEIGHT */
+	       + nla_total_size(4) /* IFLA_MTU */
+	       + nla_total_size(4) /* IFLA_LINK */
+	       + nla_total_size(4) /* IFLA_MASTER */
+	       + nla_total_size(1) /* IFLA_OPERSTATE */
+	       + nla_total_size(1) /* IFLA_LINKMODE */
+	       + nla_total_size(iwbuflen);
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    void *iwbuf, int iwbuflen, int type, u32 pid,
 			    u32 seq, u32 change, unsigned int flags)
@@ -558,7 +577,7 @@
 	struct sk_buff *nskb;
 	char *iw_buf = NULL, *iw = NULL;
 	int iw_buf_len = 0;
-	int err, payload;
+	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
 	if (err < 0)
@@ -587,9 +606,7 @@
 	}
 #endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
 
-	payload = NLMSG_ALIGN(sizeof(struct ifinfomsg) +
-			      nla_total_size(iw_buf_len));
-	nskb = nlmsg_new(nlmsg_total_size(payload), GFP_KERNEL);
+	nskb = nlmsg_new(if_nlmsg_size(iw_buf_len), GFP_KERNEL);
 	if (nskb == NULL) {
 		err = -ENOBUFS;
 		goto errout;
@@ -597,10 +614,8 @@
 
 	err = rtnl_fill_ifinfo(nskb, dev, iw, iw_buf_len, RTM_NEWLINK,
 			       NETLINK_CB(skb).pid, nlh->nlmsg_seq, 0, 0);
-	if (err <= 0) {
-		kfree_skb(nskb);
-		goto errout;
-	}
+	/* failure impilies BUG in if_nlmsg_size or wireless_rtnetlink_get */
+	BUG_ON(err < 0);
 
 	err = rtnl_unicast(nskb, NETLINK_CB(skb).pid);
 errout:
@@ -639,15 +654,13 @@
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	skb = nlmsg_new(if_nlmsg_size(0), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
 
 	err = rtnl_fill_ifinfo(skb, dev, NULL, 0, type, 0, 0, change, 0);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout;
-	}
+	/* failure implies BUG in if_nlmsg_size() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, 0, RTNLGRP_LINK, NULL, GFP_KERNEL);
 errout:
Index: net-2.6.20/net/netlabel/netlabel_cipso_v4.c
===================================================================
--- net-2.6.20.orig/net/netlabel/netlabel_cipso_v4.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/netlabel/netlabel_cipso_v4.c	2006-11-10 11:18:34.000000000 +0100
@@ -452,7 +452,7 @@
 	}
 
 list_start:
-	ans_skb = nlmsg_new(NLMSG_GOODSIZE * nlsze_mult, GFP_KERNEL);
+	ans_skb = nlmsg_new(NLMSG_DEFAULT_SIZE * nlsze_mult, GFP_KERNEL);
 	if (ans_skb == NULL) {
 		ret_val = -ENOMEM;
 		goto list_failure;
Index: net-2.6.20/include/net/fib_rules.h
===================================================================
--- net-2.6.20.orig/include/net/fib_rules.h	2006-11-10 01:46:06.000000000 +0100
+++ net-2.6.20/include/net/fib_rules.h	2006-11-10 11:18:34.000000000 +0100
@@ -52,6 +52,7 @@
 					struct nlmsghdr *,
 					struct fib_rule_hdr *);
 	u32			(*default_pref)(void);
+	size_t			(*nlmsg_payload)(struct fib_rule *);
 
 	int			nlgroup;
 	struct nla_policy	*policy;
Index: net-2.6.20/net/decnet/dn_rules.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_rules.c	2006-11-10 01:46:06.000000000 +0100
+++ net-2.6.20/net/decnet/dn_rules.c	2006-11-10 11:19:58.000000000 +0100
@@ -241,6 +241,12 @@
 	return 0;
 }
 
+static size_t dn_fib_rule_nlmsg_payload(struct fib_rule *rule)
+{
+	return nla_total_size(2) /* dst */
+	       + nla_total_size(2); /* src */
+}
+
 int dn_fib_dump_rules(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	return fib_rules_dump(skb, cb, AF_DECnet);
Index: net-2.6.20/net/ipv4/fib_rules.c
===================================================================
--- net-2.6.20.orig/net/ipv4/fib_rules.c	2006-11-10 01:46:06.000000000 +0100
+++ net-2.6.20/net/ipv4/fib_rules.c	2006-11-10 11:19:38.000000000 +0100
@@ -299,6 +299,13 @@
 	return 0;
 }
 
+static size_t fib4_rule_nlmsg_payload(struct fib_rule *rule)
+{
+	return nla_total_size(4) /* dst */
+	       + nla_total_size(4) /* src */
+	       + nla_total_size(4); /* flow */
+}
+
 static struct fib_rules_ops fib4_rules_ops = {
 	.family		= AF_INET,
 	.rule_size	= sizeof(struct fib4_rule),
@@ -308,6 +315,7 @@
 	.compare	= fib4_rule_compare,
 	.fill		= fib4_rule_fill,
 	.default_pref	= fib4_rule_default_pref,
+	.nlmsg_payload	= fib4_rule_nlmsg_payload,
 	.nlgroup	= RTNLGRP_IPV4_RULE,
 	.policy		= fib4_rule_policy,
 	.rules_list	= &fib4_rules,
Index: net-2.6.20/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.20.orig/net/ipv6/fib6_rules.c	2006-11-10 01:46:06.000000000 +0100
+++ net-2.6.20/net/ipv6/fib6_rules.c	2006-11-10 11:19:48.000000000 +0100
@@ -232,6 +232,12 @@
 	return 0x3FFF;
 }
 
+static size_t fib6_rule_nlmsg_payload(struct fib_rule *rule)
+{
+	return nla_total_size(16) /* dst */
+	       + nla_total_size(16); /* src */
+}
+
 static struct fib_rules_ops fib6_rules_ops = {
 	.family			= AF_INET6,
 	.rule_size		= sizeof(struct fib6_rule),
@@ -241,6 +247,7 @@
 	.compare		= fib6_rule_compare,
 	.fill			= fib6_rule_fill,
 	.default_pref		= fib6_rule_default_pref,
+	.nlmsg_payload		= fib6_rule_nlmsg_payload,
 	.nlgroup		= RTNLGRP_IPV6_RULE,
 	.policy			= fib6_rule_policy,
 	.rules_list		= &fib6_rules,
