From: Joel Scherpelz <jscherpelz@google.com>
Subject: [PATCH net-next] net: ipv6: Add sysctl for minimum prefix len acceptable in RIOs.
Date: Wed, 22 Mar 2017 18:19:04 +0900
Message-ID: <20170322091904.73420-1-jscherpelz@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Joel Scherpelz <jscherpelz@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33026 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759011AbdCVJTc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 05:19:32 -0400
Received: by mail-pg0-f50.google.com with SMTP id w20so3791809pgc.0
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 02:19:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds a new sysctl accept_ra_rt_info_min_plen that
defines the minimum acceptable prefix length of Route Information
Options. The new sysctl is intended to be used together with
accept_ra_rt_info_max_plen to configure a range of acceptable
prefix lengths. It is useful to prevent misconfigurations from
unintentionally blackholing too much of the IPv6 address space
(e.g., home routers announcing RIOs for fc00::/7, which is
incorrect).

Signed-off-by: Joel Scherpelz <jscherpelz@google.com>
---
 Documentation/networking/ip-sysctl.txt | 13 +++++++++++--
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ipv6.h              |  1 +
 include/uapi/linux/sysctl.h            |  1 +
 net/ipv6/addrconf.c                    | 10 ++++++++++
 net/ipv6/ndisc.c                       |  2 ++
 6 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ed3d0791eb27..3099c1e2706f 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1453,11 +1453,20 @@ accept_ra_pinfo - BOOLEAN
 	Functional default: enabled if accept_ra is enabled.
 			    disabled if accept_ra is disabled.
 
+accept_ra_rt_info_min_plen - INTEGER
+	Minimum prefix length of Route Information in RA.
+
+	Route Information w/ prefix smaller than this variable shall
+	be ignored.
+
+	Functional default: 0 if accept_ra_rtr_pref is enabled.
+			    -1 if accept_ra_rtr_pref is disabled.
+
 accept_ra_rt_info_max_plen - INTEGER
 	Maximum prefix length of Route Information in RA.
 
-	Route Information w/ prefix larger than or equal to this
-	variable shall be ignored.
+	Route Information w/ prefix larger than this variable shall
+	be ignored.
 
 	Functional default: 0 if accept_ra_rtr_pref is enabled.
 			    -1 if accept_ra_rtr_pref is disabled.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index f0d79bd054ca..e1b442996f81 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -37,6 +37,7 @@ struct ipv6_devconf {
 	__s32		accept_ra_rtr_pref;
 	__s32		rtr_probe_interval;
 #ifdef CONFIG_IPV6_ROUTE_INFO
+	__s32		accept_ra_rt_info_min_plen;
 	__s32		accept_ra_rt_info_max_plen;
 #endif
 #endif
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index d8f6a1ac9af4..2ae59178189d 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -184,6 +184,7 @@ enum {
 	DEVCONF_ENHANCED_DAD,
 	DEVCONF_ADDR_GEN_MODE,
 	DEVCONF_DISABLE_POLICY,
+	DEVCONF_ACCEPT_RA_RT_INFO_MIN_PLEN,
 	DEVCONF_MAX
 };
 
diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
index d2b12152e358..e13d48058b8d 100644
--- a/include/uapi/linux/sysctl.h
+++ b/include/uapi/linux/sysctl.h
@@ -568,6 +568,7 @@ enum {
 	NET_IPV6_PROXY_NDP=23,
 	NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
 	NET_IPV6_ACCEPT_RA_FROM_LOCAL=26,
+	NET_IPV6_ACCEPT_RA_RT_INFO_MIN_PLEN=27,
 	__NET_IPV6_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8c69768a5c46..dff5beb26a01 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -224,6 +224,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_ra_rtr_pref	= 1,
 	.rtr_probe_interval	= 60 * HZ,
 #ifdef CONFIG_IPV6_ROUTE_INFO
+	.accept_ra_rt_info_min_plen = 0,
 	.accept_ra_rt_info_max_plen = 0,
 #endif
 #endif
@@ -277,6 +278,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.accept_ra_rtr_pref	= 1,
 	.rtr_probe_interval	= 60 * HZ,
 #ifdef CONFIG_IPV6_ROUTE_INFO
+	.accept_ra_rt_info_min_plen = 0,
 	.accept_ra_rt_info_max_plen = 0,
 #endif
 #endif
@@ -4979,6 +4981,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_RTR_PROBE_INTERVAL] =
 		jiffies_to_msecs(cnf->rtr_probe_interval);
 #ifdef CONFIG_IPV6_ROUTE_INFO
+	array[DEVCONF_ACCEPT_RA_RT_INFO_MIN_PLEN] = cnf->accept_ra_rt_info_min_plen;
 	array[DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN] = cnf->accept_ra_rt_info_max_plen;
 #endif
 #endif
@@ -6122,6 +6125,13 @@ static const struct ctl_table addrconf_sysctl[] = {
 	},
 #ifdef CONFIG_IPV6_ROUTE_INFO
 	{
+		.procname	= "accept_ra_rt_info_min_plen",
+		.data		= &ipv6_devconf.accept_ra_rt_info_min_plen,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "accept_ra_rt_info_max_plen",
 		.data		= &ipv6_devconf.accept_ra_rt_info_max_plen,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 7ebac630d3c6..ffa23be1b533 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1418,6 +1418,8 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			if (ri->prefix_len == 0 &&
 			    !in6_dev->cnf.accept_ra_defrtr)
 				continue;
+			if (ri->prefix_len < in6_dev->cnf.accept_ra_rt_info_min_plen)
+				continue;
 			if (ri->prefix_len > in6_dev->cnf.accept_ra_rt_info_max_plen)
 				continue;
 			rt6_route_rcv(skb->dev, (u8 *)p, (p->nd_opt_len) << 3,
-- 
2.12.1.500.gab5fba24ee-goog
