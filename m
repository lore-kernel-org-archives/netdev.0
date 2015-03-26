From: Roman Gushchin <klamm@yandex-team.ru>
Subject: [PATCH v3] net: sysctl for RA default route MTU
Date: Thu, 26 Mar 2015 14:49:54 +0300
Message-ID: <1427370594-18807-1-git-send-email-klamm@yandex-team.ru>
References: <1427307255.3555533.245187845.14A187CD@webmail.messagingengine.com>
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Roman Gushchin <klamm@yandex-team.ru>
To: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1g.mail.yandex.net ([95.108.253.251]:52182 "EHLO
	forward-corp1g.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751042AbbCZLut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 07:50:49 -0400
In-Reply-To: <1427307255.3555533.245187845.14A187CD@webmail.messagingengine.com>
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
and (re)configure it. Not simple. The suggested sysctl solves this
problem.

Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>

---

Changes from v1: add forgotten brace.
Changes from v2: move RA-specific code from route.c to ndisc.c
---
 Documentation/networking/ip-sysctl.txt |  5 +++++
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ipv6.h              |  1 +
 net/ipv6/addrconf.c                    | 10 ++++++++++
 net/ipv6/ndisc.c                       |  8 +++++++-
 5 files changed, 24 insertions(+), 1 deletion(-)

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
index 4d5169f..68b4e1e 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -53,6 +53,7 @@ struct ipv6_devconf {
 	__s32           ndisc_notify;
 	__s32		suppress_frag_ndisc;
 	__s32		accept_ra_mtu;
+	__s32		ra_default_route_mtu;
 	void		*sysctl;
 };
 
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
index b603002..cec352d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -202,6 +202,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
 	.accept_ra_mtu		= 1,
+	.ra_default_route_mtu	= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
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
@@ -5315,6 +5318,13 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec,
 		},
 		{
+			.procname	= "ra_default_route_mtu",
+			.data		= &ipv6_devconf.ra_default_route_mtu,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
+		{
 			/* sentinel */
 		}
 	},
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 471ed24..835b466 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1200,6 +1200,11 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 				  "RA: %s failed to add default route\n",
 				  __func__);
 			return;
+		} else {
+			u32 mtu = in6_dev->cnf.ra_default_route_mtu;
+
+			if (mtu && mtu >= IPV6_MIN_MTU && mtu <= in6_dev->cnf.mtu6)
+				dst_metric_set(&rt->dst, RTAX_MTU, mtu);
 		}
 
 		neigh = dst_neigh_lookup(&rt->dst, &ipv6_hdr(skb)->saddr);
@@ -1362,7 +1367,8 @@ skip_routeinfo:
 		} else if (in6_dev->cnf.mtu6 != mtu) {
 			in6_dev->cnf.mtu6 = mtu;
 
-			if (rt)
+			if (rt && (!in6_dev->cnf.ra_default_route_mtu ||
+				   mtu < in6_dev->cnf.ra_default_route_mtu))
 				dst_metric_set(&rt->dst, RTAX_MTU, mtu);
 
 			rt6_mtu_change(skb->dev, mtu);
-- 
2.1.0
