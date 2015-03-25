From: Roman Gushchin <klamm@yandex-team.ru>
Subject: [PATCH] net: sysctl for RA default route MTU
Date: Wed, 25 Mar 2015 12:49:26 +0300
Message-ID: <1427276966-3980-1-git-send-email-klamm@yandex-team.ru>
References: <20150324.152705.921124268458994532.davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, Roman Gushchin <klamm@yandex-team.ru>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1m.cmail.yandex.net ([5.255.216.100]:58030 "EHLO
	forward-corp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752294AbbCYJtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 05:49:53 -0400
In-Reply-To: <20150324.152705.921124268458994532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces new ipv6 sysctl: ra_default_route_mtu.
If it's set (> 0), it defines per-route MTU for any new default route
received by RA.

This sysctl will help in the following configuration: we want to use
jumbo-frames for internal networks and default ethernet frames for
default route. Per-route MTU can only lower per-link MTU, so link MTU
should be set to ~9000 (statically or via RA).

Due to dynamic nature of RA, setting MTU for default route will require
userspace agent, that will monitor changes of default route
and (re)configure it. Not simple. The suggested sysctl solves this problem.

Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
---
 Documentation/networking/ip-sysctl.txt | 5 +++++
 include/linux/ipv6.h                   | 1 +
 include/uapi/linux/ipv6.h              | 1 +
 net/ipv6/addrconf.c                    | 9 +++++++++
 net/ipv6/ndisc.c                       | 3 ++-
 net/ipv6/route.c                       | 8 ++++++++
 6 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 1b8c964..c013dda 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1316,6 +1316,11 @@ accept_ra_mtu - BOOLEAN
 	Functional default: enabled if accept_ra is enabled.
 			    disabled if accept_ra is disabled.
 
+ra_default_route_mtu - INTEGER
+	Define MTU for any new default route received by RA.
+
+	Functional default: disabled (0).
+
 accept_redirects - BOOLEAN
 	Accept Redirects.
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 4d5169f..b310c9f 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -40,6 +40,7 @@ struct ipv6_devconf {
 	__s32		proxy_ndp;
 	__s32		accept_source_route;
 	__s32		accept_ra_from_local;
+	__s32		ra_default_route_mtu;
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	__s32		optimistic_dad;
 	__s32		use_optimistic;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 437a6a4..4539c31 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -170,6 +170,7 @@ enum {
 	DEVCONF_ACCEPT_RA_FROM_LOCAL,
 	DEVCONF_USE_OPTIMISTIC,
 	DEVCONF_ACCEPT_RA_MTU,
+	DEVCONF_RA_DEFAULT_ROUTE_MTU,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b603002..9d5ec10 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -189,6 +189,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_ra_defrtr	= 1,
 	.accept_ra_from_local	= 0,
 	.accept_ra_pinfo	= 1,
+	.ra_default_route_mtu	= 0,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	.accept_ra_rtr_pref	= 1,
 	.rtr_probe_interval	= 60 * HZ,
@@ -240,6 +241,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
 	.accept_ra_mtu		= 1,
+	.ra_default_route_mtu	= 0,
 };
 
 /* Check if a valid qdisc is available */
@@ -4398,6 +4400,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
 	array[DEVCONF_ACCEPT_RA_FROM_LOCAL] = cnf->accept_ra_from_local;
 	array[DEVCONF_ACCEPT_RA_MTU] = cnf->accept_ra_mtu;
+	array[DEVCONF_RA_DEFAULT_ROUTE_MTU] = cnf->ra_default_route_mtu;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5314,6 +5317,12 @@ static struct addrconf_sysctl_table
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
+			.procname	= "ra_default_route_mtu",
+			.data		= &ipv6_devconf.ra_default_route_mtu,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
 		{
 			/* sentinel */
 		}
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 471ed24..c70ab44 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1362,7 +1362,8 @@ skip_routeinfo:
 		} else if (in6_dev->cnf.mtu6 != mtu) {
 			in6_dev->cnf.mtu6 = mtu;
 
-			if (rt)
+			if (rt && (!in6_dev->cnf.ra_default_route_mtu ||
+				   mtu < in6_dev->cnf.ra_default_route_mtu))
 				dst_metric_set(&rt->dst, RTAX_MTU, mtu);
 
 			rt6_mtu_change(skb->dev, mtu);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4688bd4..6394adf 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1714,6 +1714,14 @@ int ip6_route_add(struct fib6_config *cfg)
 
 	rt->rt6i_flags = cfg->fc_flags;
 
+	if ((cfg->fc_flags & (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY)) ==
+	    (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY)) {
+		u32 mtu = idev->cnf.ra_default_route_mtu;
+
+		if (mtu && mtu >= IPV6_MIN_MTU && mtu <= idev->cnf.mtu6)
+			dst_metric_set(&rt->dst, RTAX_MTU, mtu);
+	}
+
 install_route:
 	rt->dst.dev = dev;
 	rt->rt6i_idev = idev;
-- 
2.1.0
