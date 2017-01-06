From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next] net: ipv6: put autoconf routes into per-interface tables
Date: Sat,  7 Jan 2017 00:30:26 +0900
Message-ID: <20170106153026.24785-1-lorenzo@google.com>
Cc: zenczykowski@gmail.com, hannes@stressinduktion.org, ek@google.com,
        hideaki.yoshifuji@miraclelinux.com, davem@davemloft.net,
        dsa@cumulusnetworks.com, drosen@google.com,
        Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:32774 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965181AbdAFPae (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 10:30:34 -0500
Received: by mail-pg0-f54.google.com with SMTP id g1so214037714pgn.0
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 07:30:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, IPv6 router discovery always puts routes into
RT6_TABLE_MAIN. This makes it difficult to maintain and switch
between multiple simultaneous network connections (e.g., wifi
and wired).

To work around this connection managers typically either move
autoconfiguration to userspace entirely (e.g., dhcpcd) or take
the routes they want and re-add them to the main table as static
routes with low metrics (e.g., NetworkManager). This puts the
burden on the connection manager to watch netlink or listen to
RAs to see if the routes have changed, delete the routes when
their lifetime expires, etc. This is complex and often not
implemented correctly.

This patch adds a per-interface sysctl to have the kernel put
autoconf routes into different tables. This allows each interface
to have its own routing table if desired.  Choosing the default
interface, or using different interfaces at the same time on a
per-socket or per-packet basis) can be done using policy routing
mechanisms that use as SO_BINDTODEVICE / IPV6_PKTINFO, mark-based
routing, or UID-based routing to select specific routing tables.

The sysctl behaves as follows:

- = 0: default. Put routes into RT6_TABLE_MAIN if the interface
       is not in a VRF, or into the VRF table if it is.
- > 0: manual. Put routes into the specified table.
- < 0: automatic. Add the absolute value of the sysctl to the
       device's ifindex, and use that table.

The automatic mode is most useful in conjunction with
net.ipv6.conf.default.accept_ra_rt_table. A connection manager
or distribution can set this to, say, -1000 on boot, and
thereafter know that routes received on every interface will
always be in that interface's routing table, and that the mapping
between interfaces and routing tables is deterministic. It also
ensures that if an interface is created and immediately receives
an RA, the route will go into the correct routing table without
needing any intervention from userspace.

The automatic mode (with conf.default.accept_ra_rt_table = -1000)
has been used in Android since 5.0.

Tested: compiles allnoconfig, allyesconfig, allmodconfig
Tested: passes existing Android kernel unit tests
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 Documentation/networking/ip-sysctl.txt | 13 +++++++++++
 include/linux/ipv6.h                   |  1 +
 include/net/addrconf.h                 |  2 ++
 include/uapi/linux/ipv6.h              |  1 +
 net/ipv6/addrconf.c                    | 40 +++++++++++++++++++++++++++++++---
 net/ipv6/route.c                       | 11 +++++-----
 6 files changed, 59 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 7dd65c9cf7..d1311d8f33 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1471,6 +1471,19 @@ accept_ra_rt_info_max_plen - INTEGER
 	Functional default: 0 if accept_ra_rtr_pref is enabled.
 			    -1 if accept_ra_rtr_pref is disabled.
 
+accept_ra_rt_table - INTEGER
+	Which table to put routes created by Router Advertisements into.
+
+	= 0: Use the main table if the device is not in a VRF, and the
+	     VRF table if it is.
+	> 0: Use the specified table.
+	< 0: Add the absolute value to the receiving interface index,
+	     and use that table. For example, if set to -1000, an RA
+	     received on interface index 4 will create routes in
+	     table 1004.
+
+	Default: 0
+
 accept_ra_rtr_pref - BOOLEAN
 	Accept Router Preference in RA.
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 671d014e64..55d75074aa 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -69,6 +69,7 @@ struct ipv6_devconf {
 	__s32		seg6_require_hmac;
 #endif
 	__u32		enhanced_dad;
+	__s32		accept_ra_rt_table;
 
 	struct ctl_table_header *sysctl_header;
 };
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 8f998afc13..e1bd2bc027 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -242,6 +242,8 @@ static inline bool ipv6_is_mld(struct sk_buff *skb, int nexthdr, int offset)
 void addrconf_prefix_rcv(struct net_device *dev,
 			 u8 *opt, int len, bool sllao);
 
+u32 addrconf_rt_table(const struct net_device *dev, u32 default_table);
+
 /*
  *	anycast prototypes (anycast.c)
  */
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index eaf65dc82e..95c3553242 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -182,6 +182,7 @@ enum {
 	DEVCONF_SEG6_ENABLED,
 	DEVCONF_SEG6_REQUIRE_HMAC,
 	DEVCONF_ENHANCED_DAD,
+	DEVCONF_ACCEPT_RA_RT_TABLE,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c1e124bc8e..d4a6b877f8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -243,6 +243,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.seg6_require_hmac	= 0,
 #endif
 	.enhanced_dad           = 1,
+	.accept_ra_rt_table	= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -294,6 +295,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.seg6_require_hmac	= 0,
 #endif
 	.enhanced_dad           = 1,
+	.accept_ra_rt_table	= 0,
 };
 
 /* Check if a valid qdisc is available */
@@ -2210,6 +2212,30 @@ static void  ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpad
 		ipv6_regen_rndid(idev);
 }
 
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+u32 addrconf_rt_table(const struct net_device *dev, u32 default_table)
+{
+	struct inet6_dev *idev = in6_dev_get(dev);
+	u32 table;
+	int sysctl = idev->cnf.accept_ra_rt_table;
+
+	if (sysctl == 0)
+		table = l3mdev_fib_table(dev) ? : default_table;
+	else if (sysctl > 0)
+		table = (u32)sysctl;
+	else
+		table = (unsigned int)dev->ifindex + (-sysctl);
+
+	in6_dev_put(idev);
+	return table;
+}
+#else
+u32 addrconf_rt_table(const struct net_device *dev, u32 default_table)
+{
+	return RT6_TABLE_DFLT;
+}
+#endif
+
 /*
  *	Add prefix route.
  */
@@ -2219,7 +2245,7 @@ addrconf_prefix_route(struct in6_addr *pfx, int plen, struct net_device *dev,
 		      unsigned long expires, u32 flags)
 {
 	struct fib6_config cfg = {
-		.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_PREFIX,
+		.fc_table = addrconf_rt_table(dev, RT6_TABLE_PREFIX),
 		.fc_metric = IP6_RT_PRIO_ADDRCONF,
 		.fc_ifindex = dev->ifindex,
 		.fc_expires = expires,
@@ -2252,9 +2278,9 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 	struct fib6_node *fn;
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
-	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_PREFIX;
 
-	table = fib6_get_table(dev_net(dev), tb_id);
+	table = fib6_get_table(dev_net(dev),
+			       addrconf_rt_table(dev, RT6_TABLE_PREFIX));
 	if (!table)
 		return NULL;
 
@@ -4975,6 +5001,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_SEG6_REQUIRE_HMAC] = cnf->seg6_require_hmac;
 #endif
 	array[DEVCONF_ENHANCED_DAD] = cnf->enhanced_dad;
+	array[DEVCONF_ACCEPT_RA_RT_TABLE] = cnf->accept_ra_rt_table;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -6090,6 +6117,13 @@ static const struct ctl_table addrconf_sysctl[] = {
 		.proc_handler   = proc_dointvec,
 	},
 	{
+		.procname	= "accept_ra_rt_table",
+		.data		= &ipv6_devconf.accept_ra_rt_table,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		/* sentinel */
 	}
 };
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8417c41d8e..86469ec27f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2345,13 +2345,12 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 					   const struct in6_addr *gwaddr,
 					   struct net_device *dev)
 {
-	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_INFO;
 	int ifindex = dev->ifindex;
 	struct fib6_node *fn;
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
 
-	table = fib6_get_table(net, tb_id);
+	table = fib6_get_table(net, addrconf_rt_table(dev, RT6_TABLE_INFO));
 	if (!table)
 		return NULL;
 
@@ -2392,7 +2391,7 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 		.fc_nlinfo.nl_net = net,
 	};
 
-	cfg.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_INFO,
+	cfg.fc_table = addrconf_rt_table(dev, RT6_TABLE_INFO);
 	cfg.fc_dst = *prefix;
 	cfg.fc_gateway = *gwaddr;
 
@@ -2408,11 +2407,11 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 
 struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_device *dev)
 {
-	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_DFLT;
 	struct rt6_info *rt;
 	struct fib6_table *table;
 
-	table = fib6_get_table(dev_net(dev), tb_id);
+	table = fib6_get_table(dev_net(dev),
+			       addrconf_rt_table(dev, RT6_TABLE_DFLT));
 	if (!table)
 		return NULL;
 
@@ -2434,7 +2433,7 @@ struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 				     unsigned int pref)
 {
 	struct fib6_config cfg = {
-		.fc_table	= l3mdev_fib_table(dev) ? : RT6_TABLE_DFLT,
+		.fc_table	= addrconf_rt_table(dev, RT6_TABLE_DFLT),
 		.fc_metric	= IP6_RT_PRIO_USER,
 		.fc_ifindex	= dev->ifindex,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT |
-- 
2.11.0.390.gc69c2f50cf-goog
