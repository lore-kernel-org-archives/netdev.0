From: Ben Jencks <ben@bjencks.net>
Subject: [PATCH RFC] ipv6: Add net.ipv6.conf.*.accept_ra_defrtr_table sysctl.
Date: Tue, 21 Aug 2012 23:48:06 -0400
Message-ID: <50345676.10506@bjencks.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:46287 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755386Ab2HVDsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 23:48:09 -0400
Received: by ghrr11 with SMTP id r11so442336ghr.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 20:48:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows configuration of the routing table to which default routes from
RAs are added on a per-interface basis.

One use case where this is required is a multi-homed router advertising
multiple prefixes, one for each upstream. The proper routing policy is
something like:

0: from all lookup local
10: from all lookup main
20: from <prefix1> lookup provider1
30: from <prefix2> lookup provider2

with directly connected and internal routes in main, and default routes
from providers 1 and 2 in their respective tables. With static routes
this is straightforward; if the route for either or both providers is
received via RA this configuration option becomes necessary to put the
routes in the appropriate tables.

Signed-off-by: Ben Jencks <ben@bjencks.net>
---
Patch is against v3.5.2, but applies cleanly to master as of today.

Looking for feedback on:
* Is this a worthwhile feature? Did I miss a good way to do this in
  userspace?
* Is a sysctl the right place to configure it? I know it's discouraged
  to add new ones, but it seems to fit best with the other similar
  configuration options.
* Is the rt6_purge_dflt_routers behavior correct? Should
  addrconf_fixup_forwarding be modified so that in the single device
  case it only purges from that device's table?

 Documentation/networking/ip-sysctl.txt |    6 +++++
 include/linux/ipv6.h                   |    2 ++
 include/linux/sysctl.h                 |    1 +
 kernel/sysctl_binary.c                 |    1 +
 net/ipv6/addrconf.c                    |   10 +++++++
 net/ipv6/route.c                       |   45 ++++++++++++++++++++++----------
 6 files changed, 51 insertions(+), 14 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 6f896b9..0d0947a 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1085,6 +1085,12 @@ accept_ra_defrtr - BOOLEAN
 	Functional default: enabled if accept_ra is enabled.
 			    disabled if accept_ra is disabled.
 
+accept_ra_defrtr_table - INTEGER
+	Routing table into which to put default route learned via Router
+	Advertisement.
+
+	Functional default: "main" routing table (254)
+
 accept_ra_pinfo - BOOLEAN
 	Learn Prefix Information in Router Advertisement.
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 8260ef7..fa9b4fe 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -153,6 +153,7 @@ struct ipv6_devconf {
 #endif
 	__s32		max_addresses;
 	__s32		accept_ra_defrtr;
+	__s32		accept_ra_defrtr_table;
 	__s32		accept_ra_pinfo;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	__s32		accept_ra_rtr_pref;
@@ -202,6 +203,7 @@ enum {
 	DEVCONF_MAX_ADDRESSES,
 	DEVCONF_FORCE_MLD_VERSION,
 	DEVCONF_ACCEPT_RA_DEFRTR,
+	DEVCONF_ACCEPT_RA_DEFRTR_TABLE,
 	DEVCONF_ACCEPT_RA_PINFO,
 	DEVCONF_ACCEPT_RA_RTR_PREF,
 	DEVCONF_RTR_PROBE_INTERVAL,
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index c34b4c8..80115c8 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -568,6 +568,7 @@ enum {
 	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=22,
 	NET_IPV6_PROXY_NDP=23,
 	NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
+	NET_IPV6_ACCEPT_RA_DEFRTR_TABLE=26,
 	__NET_IPV6_MAX
 };
 
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index a650694..da964f3 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -517,6 +517,7 @@ static const struct bin_table bin_net_ipv6_conf_var_table[] = {
 	{ CTL_INT,	NET_IPV6_MAX_ADDRESSES,			"max_addresses" },
 	{ CTL_INT,	NET_IPV6_FORCE_MLD_VERSION,		"force_mld_version" },
 	{ CTL_INT,	NET_IPV6_ACCEPT_RA_DEFRTR,		"accept_ra_defrtr" },
+	{ CTL_INT,	NET_IPV6_ACCEPT_RA_DEFRTR_TABLE,	"accept_ra_defrtr_table" },
 	{ CTL_INT,	NET_IPV6_ACCEPT_RA_PINFO,		"accept_ra_pinfo" },
 	{ CTL_INT,	NET_IPV6_ACCEPT_RA_RTR_PREF,		"accept_ra_rtr_pref" },
 	{ CTL_INT,	NET_IPV6_RTR_PROBE_INTERVAL,		"router_probe_interval" },
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f6411c..2bdb96c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -188,6 +188,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 #endif
 	.max_addresses		= IPV6_MAX_ADDRESSES,
 	.accept_ra_defrtr	= 1,
+	.accept_ra_defrtr_table	= RT6_TABLE_DFLT,
 	.accept_ra_pinfo	= 1,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	.accept_ra_rtr_pref	= 1,
@@ -222,6 +223,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 #endif
 	.max_addresses		= IPV6_MAX_ADDRESSES,
 	.accept_ra_defrtr	= 1,
+	.accept_ra_defrtr_table	= RT6_TABLE_DFLT,
 	.accept_ra_pinfo	= 1,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	.accept_ra_rtr_pref	= 1,
@@ -3894,6 +3896,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 #endif
 	array[DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
 	array[DEVCONF_ACCEPT_RA_DEFRTR] = cnf->accept_ra_defrtr;
+	array[DEVCONF_ACCEPT_RA_DEFRTR_TABLE] = cnf->accept_ra_defrtr_table;
 	array[DEVCONF_ACCEPT_RA_PINFO] = cnf->accept_ra_pinfo;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	array[DEVCONF_ACCEPT_RA_RTR_PREF] = cnf->accept_ra_rtr_pref;
@@ -4496,6 +4499,13 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec,
 		},
 		{
+			.procname	= "accept_ra_defrtr_table",
+			.data		= &ipv6_devconf.accept_ra_defrtr_table,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
+		{
 			.procname	= "accept_ra_pinfo",
 			.data		= &ipv6_devconf.accept_ra_pinfo,
 			.maxlen		= sizeof(int),
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index becb048..dafcb61 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1916,8 +1916,12 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 {
 	struct rt6_info *rt;
 	struct fib6_table *table;
+	struct inet6_dev *idev;
 
-	table = fib6_get_table(dev_net(dev), RT6_TABLE_DFLT);
+	idev = __in6_dev_get(dev);
+	if (!idev)
+		return NULL;
+	table = fib6_get_table(dev_net(dev), idev->cnf.accept_ra_defrtr_table);
 	if (!table)
 		return NULL;
 
@@ -1939,7 +1943,6 @@ struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 				     unsigned int pref)
 {
 	struct fib6_config cfg = {
-		.fc_table	= RT6_TABLE_DFLT,
 		.fc_metric	= IP6_RT_PRIO_USER,
 		.fc_ifindex	= dev->ifindex,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT |
@@ -1948,7 +1951,12 @@ struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 		.fc_nlinfo.nlh = NULL,
 		.fc_nlinfo.nl_net = dev_net(dev),
 	};
+	struct inet6_dev *idev;
 
+	/* idev should not be null, since we were called from
+	 * ndisc_router_discovery which already checked it */
+	idev = __in6_dev_get(dev);
+	cfg.fc_table = idev->cnf.accept_ra_defrtr_table;
 	cfg.fc_gateway = *gwaddr;
 
 	ip6_route_add(&cfg);
@@ -1960,23 +1968,32 @@ void rt6_purge_dflt_routers(struct net *net)
 {
 	struct rt6_info *rt;
 	struct fib6_table *table;
+	struct net_device *dev;
+	struct inet6_dev *idev;
 
-	/* NOTE: Keep consistent with rt6_get_dflt_router */
-	table = fib6_get_table(net, RT6_TABLE_DFLT);
-	if (!table)
-		return;
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		idev = __in6_dev_get(dev);
+		if (idev == NULL) {
+			continue;
+		}
+		table = fib6_get_table(net, idev->cnf.accept_ra_defrtr_table);
+		if (!table)
+			continue;
 
 restart:
-	read_lock_bh(&table->tb6_lock);
-	for (rt = table->tb6_root.leaf; rt; rt = rt->dst.rt6_next) {
-		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) {
-			dst_hold(&rt->dst);
-			read_unlock_bh(&table->tb6_lock);
-			ip6_del_rt(rt);
-			goto restart;
+		read_lock_bh(&table->tb6_lock);
+		for (rt = table->tb6_root.leaf; rt; rt = rt->dst.rt6_next) {
+			if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) {
+				dst_hold(&rt->dst);
+				read_unlock_bh(&table->tb6_lock);
+				ip6_del_rt(rt);
+				goto restart;
+			}
 		}
+		read_unlock_bh(&table->tb6_lock);
 	}
-	read_unlock_bh(&table->tb6_lock);
+	rcu_read_unlock();
 }
 
 static void rtmsg_to_fib6_config(struct net *net,
-- 
1.7.9.5
