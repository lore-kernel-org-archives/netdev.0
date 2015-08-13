From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/2] net: ipv6 sysctl option to ignore routes when nexthop link is down
Date: Thu, 13 Aug 2015 10:39:01 -0400
Message-ID: <1439476741-952-2-git-send-email-gospo@cumulusnetworks.com>
References: <1439476741-952-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:33653 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817AbbHMOjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 10:39:46 -0400
Received: by ykaz130 with SMTP id z130so42838771yka.0
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 07:39:45 -0700 (PDT)
In-Reply-To: <1439476741-952-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like the ipv4 patch with a similar title, this adds a sysctl to allow
the user to change routing behavior based on whether or not the
interface associated with the nexthop was an up or down link.  The
default setting preserves the current behavior, but anyone that enables
it will notice that nexthops on down interfaces will no longer be
selected:

net.ipv6.conf.all.ignore_routes_with_linkdown = 0
net.ipv6.conf.default.ignore_routes_with_linkdown = 0
net.ipv6.conf.lo.ignore_routes_with_linkdown = 0
...

When the above sysctls are set, not only will link status be reported to
userspace, but an indication that a nexthop is dead and will not be used
is also reported.

1000::/8 via 7000::2 dev p7p1  metric 1024 dead linkdown  pref medium
1000::/8 via 8000::2 dev p8p1  metric 1024  pref medium
7000::/8 dev p7p1  proto kernel  metric 256 dead linkdown  pref medium
8000::/8 dev p8p1  proto kernel  metric 256  pref medium
9000::/8 via 8000::2 dev p8p1  metric 2048  pref medium
9000::/8 via 7000::2 dev p7p1  metric 1024 dead linkdown  pref medium
fe80::/64 dev p7p1  proto kernel  metric 256 dead linkdown  pref medium
fe80::/64 dev p8p1  proto kernel  metric 256  pref medium

This also adds devconf support and notification when sysctl values
change.

v2: drop use of rt6i_nhflags since it is not needed right now

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
---
 include/linux/ipv6.h      |   1 +
 include/uapi/linux/ipv6.h |   1 +
 net/ipv6/addrconf.c       | 105 +++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/route.c          |  11 ++++-
 4 files changed, 116 insertions(+), 2 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index cb9dcad..f1f32af 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -31,6 +31,7 @@ struct ipv6_devconf {
 	__s32		accept_ra_defrtr;
 	__s32		accept_ra_min_hop_limit;
 	__s32		accept_ra_pinfo;
+	__s32		ignore_routes_with_linkdown;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	__s32		accept_ra_rtr_pref;
 	__s32		rtr_probe_interval;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 80f3b74..38b4fef 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -173,6 +173,7 @@ enum {
 	DEVCONF_STABLE_SECRET,
 	DEVCONF_USE_OIF_ADDRS_ONLY,
 	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
+	DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 53e3a9d..5dfbac7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -214,6 +214,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 		.initialized = false,
 	},
 	.use_oif_addrs_only	= 0,
+	.ignore_routes_with_linkdown = 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -257,6 +258,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 		.initialized = false,
 	},
 	.use_oif_addrs_only	= 0,
+	.ignore_routes_with_linkdown = 0,
 };
 
 /* Check if a valid qdisc is available */
@@ -472,6 +474,9 @@ static int inet6_netconf_msgsize_devconf(int type)
 	if (type == -1 || type == NETCONFA_PROXY_NEIGH)
 		size += nla_total_size(4);
 
+	if (type == -1 || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN)
+		size += nla_total_size(4);
+
 	return size;
 }
 
@@ -508,6 +513,11 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	    nla_put_s32(skb, NETCONFA_PROXY_NEIGH, devconf->proxy_ndp) < 0)
 		goto nla_put_failure;
 
+	if ((type == -1 || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN) &&
+	    nla_put_s32(skb, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+			devconf->ignore_routes_with_linkdown) < 0)
+		goto nla_put_failure;
+
 	nlmsg_end(skb, nlh);
 	return 0;
 
@@ -544,6 +554,7 @@ static const struct nla_policy devconf_ipv6_policy[NETCONFA_MAX+1] = {
 	[NETCONFA_IFINDEX]	= { .len = sizeof(int) },
 	[NETCONFA_FORWARDING]	= { .len = sizeof(int) },
 	[NETCONFA_PROXY_NEIGH]	= { .len = sizeof(int) },
+	[NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN]	= { .len = sizeof(int) },
 };
 
 static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
@@ -766,6 +777,63 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 		rt6_purge_dflt_routers(net);
 	return 1;
 }
+
+static void addrconf_linkdown_change(struct net *net, __s32 newf)
+{
+	struct net_device *dev;
+	struct inet6_dev *idev;
+
+	for_each_netdev(net, dev) {
+		idev = __in6_dev_get(dev);
+		if (idev) {
+			int changed = (!idev->cnf.ignore_routes_with_linkdown) ^ (!newf);
+
+			idev->cnf.ignore_routes_with_linkdown = newf;
+			if (changed)
+				inet6_netconf_notify_devconf(dev_net(dev),
+							     NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+							     dev->ifindex,
+							     &idev->cnf);
+		}
+	}
+}
+
+static int addrconf_fixup_linkdown(struct ctl_table *table, int *p, int newf)
+{
+	struct net *net;
+	int old;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	net = (struct net *)table->extra2;
+	old = *p;
+	*p = newf;
+
+	if (p == &net->ipv6.devconf_dflt->ignore_routes_with_linkdown) {
+		if ((!newf) ^ (!old))
+			inet6_netconf_notify_devconf(net,
+						     NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+						     NETCONFA_IFINDEX_DEFAULT,
+						     net->ipv6.devconf_dflt);
+		rtnl_unlock();
+		return 0;
+	}
+
+	if (p == &net->ipv6.devconf_all->ignore_routes_with_linkdown) {
+		net->ipv6.devconf_dflt->ignore_routes_with_linkdown = newf;
+		addrconf_linkdown_change(net, newf);
+		if ((!newf) ^ (!old))
+			inet6_netconf_notify_devconf(net,
+						     NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+						     NETCONFA_IFINDEX_ALL,
+						     net->ipv6.devconf_all);
+	}
+	rtnl_unlock();
+
+	return 1;
+}
+
 #endif
 
 /* Nobody refers to this ifaddr, destroy it */
@@ -4616,6 +4684,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
 	array[DEVCONF_ACCEPT_RA_FROM_LOCAL] = cnf->accept_ra_from_local;
 	array[DEVCONF_ACCEPT_RA_MTU] = cnf->accept_ra_mtu;
+	array[DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN] = cnf->ignore_routes_with_linkdown;
 	/* we omit DEVCONF_STABLE_SECRET for now */
 	array[DEVCONF_USE_OIF_ADDRS_ONLY] = cnf->use_oif_addrs_only;
 }
@@ -5338,6 +5407,34 @@ out:
 	return err;
 }
 
+static
+int addrconf_sysctl_ignore_routes_with_linkdown(struct ctl_table *ctl,
+						int write,
+						void __user *buffer,
+						size_t *lenp,
+						loff_t *ppos)
+{
+	int *valp = ctl->data;
+	int val = *valp;
+	loff_t pos = *ppos;
+	struct ctl_table lctl;
+	int ret;
+
+	/* ctl->data points to idev->cnf.ignore_routes_when_linkdown
+	 * we should not modify it until we get the rtnl lock.
+	 */
+	lctl = *ctl;
+	lctl.data = &val;
+
+	ret = proc_dointvec(&lctl, write, buffer, lenp, ppos);
+
+	if (write)
+		ret = addrconf_fixup_linkdown(ctl, valp, val);
+	if (ret)
+		*ppos = pos;
+	return ret;
+}
+
 static struct addrconf_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
@@ -5629,7 +5726,13 @@ static struct addrconf_sysctl_table
 			.maxlen         = sizeof(int),
 			.mode           = 0644,
 			.proc_handler   = proc_dointvec,
-
+		},
+		{
+			.procname	= "ignore_routes_with_linkdown",
+			.data		= &ipv6_devconf.ignore_routes_with_linkdown,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= addrconf_sysctl_ignore_routes_with_linkdown,
 		},
 		{
 			/* sentinel */
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 26b51e1..e15684f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -665,6 +665,12 @@ static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
 {
 	int m;
 	bool match_do_rr = false;
+	struct inet6_dev *idev = rt->rt6i_idev;
+	struct net_device *dev = rt->dst.dev;
+
+	if (dev && !netif_carrier_ok(dev) &&
+	    idev->cnf.ignore_routes_with_linkdown)
+		goto out;
 
 	if (rt6_check_expired(rt))
 		goto out;
@@ -2885,8 +2891,11 @@ static int rt6_fill_node(struct net *net,
 	else
 		rtm->rtm_type = RTN_UNICAST;
 	rtm->rtm_flags = 0;
-	if (!netif_carrier_ok(rt->dst.dev))
+	if (!netif_carrier_ok(rt->dst.dev)) {
 		rtm->rtm_flags |= RTNH_F_LINKDOWN;
+		if (rt->rt6i_idev->cnf.ignore_routes_with_linkdown)
+			rtm->rtm_flags |= RTNH_F_DEAD;
+	}
 	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
 	rtm->rtm_protocol = rt->rt6i_protocol;
 	if (rt->rt6i_flags & RTF_DYNAMIC)
-- 
1.9.3
