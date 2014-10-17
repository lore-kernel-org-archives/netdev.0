From: Erik Kline <ek@google.com>
Subject: [RFC PATCH net-next] net: ipv6: Add a sysctl to make optimistic addresses useful candidates
Date: Fri, 17 Oct 2014 13:31:49 +0900
Message-ID: <1413520309-13814-1-git-send-email-ek@google.com>
Cc: hannes@stressinduktion.org, lorenzo@google.com,
	edumazet@google.com, Erik Kline <ek@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:51568 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbaJQEcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 00:32:13 -0400
Received: by mail-pa0-f74.google.com with SMTP id kq14so7826pab.3
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 21:32:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a sysctl that causes an interface's optimistic addresses
to be considered equivalent to other non-deprecated addresses
for source address selection purposes.  Preferred addresses
will still take precendence over optimistic addresses, subject
to other ranking in the source address selection algorithm.

This is useful where different interfaces are connected to
different networks from different ISPs (e.g., a cell network
and a home wifi network).

The current behaviour complies with RFC 3484/6724, and it
makes sense if the host has only one interface, or has
multiple interfaces on the same network (same or cooperating
administrative domain(s), but not in the multiple distinct
networks case.

For example, if a mobile device has an IPv6 address on an LTE
network and then connects to IPv6-enabled wifi, while the wifi
IPv6 address is undergoing DAD, IPv6 connections will try use
the wifi default route with the LTE IPv6 address, and will get
stuck until they time out.

Also: add an entry in ip-sysctl.txt for optimistic_dad.

Signed-off-by: Erik Kline <ek@google.com>
---
 Documentation/networking/ip-sysctl.txt | 13 +++++++++++++
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ipv6.h              |  1 +
 net/ipv6/addrconf.c                    | 29 ++++++++++++++++++++++++++++-
 4 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index c7a81ac..9bf32bc 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1458,6 +1458,19 @@ suppress_frag_ndisc - INTEGER
 	1 - (default) discard fragmented neighbor discovery packets
 	0 - allow fragmented neighbor discovery packets
 
+optimistic_dad - BOOLEAN
+	Whether to perform Optimistic Duplicate Address Detection (RFC 4429).
+		0: disabled (default)
+		1: enabled
+
+use_optimistic - BOOLEAN
+	If enabled, do not classify optimistic addresses as deprecated during
+	source address selection.  Preferred addresses will still be chosen
+	before optimistic addresses, subject to other ranking in the source
+	address selection algorithm.
+		0: disabled (default)
+		1: enabled
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index ff56053..7121a2e 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -42,6 +42,7 @@ struct ipv6_devconf {
 	__s32		accept_ra_from_local;
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	__s32		optimistic_dad;
+	__s32		use_optimistic;
 #endif
 #ifdef CONFIG_IPV6_MROUTE
 	__s32		mc_forwarding;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index efa2666..5b2c6d9 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -154,6 +154,7 @@ enum {
 	DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
 	DEVCONF_PROXY_NDP,
 	DEVCONF_OPTIMISTIC_DAD,
+	DEVCONF_USE_OPTIMISTIC,
 	DEVCONF_ACCEPT_SOURCE_ROUTE,
 	DEVCONF_MC_FORWARDING,
 	DEVCONF_DISABLE_IPV6,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 725c763..fc8c08d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1169,6 +1169,9 @@ enum {
 	IPV6_SADDR_RULE_LABEL,
 	IPV6_SADDR_RULE_PRIVACY,
 	IPV6_SADDR_RULE_ORCHID,
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	IPV6_SADDR_RULE_NOT_OPTIMISTIC,
+#endif
 	IPV6_SADDR_RULE_PREFIX,
 	IPV6_SADDR_RULE_MAX
 };
@@ -1257,10 +1260,17 @@ static int ipv6_get_saddr_eval(struct net *net,
 		score->scopedist = ret;
 		break;
 	case IPV6_SADDR_RULE_PREFERRED:
+	    {
 		/* Rule 3: Avoid deprecated and optimistic addresses */
+		u8 avoid = IFA_F_DEPRECATED;
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+		if (!score->ifa->idev->cnf.use_optimistic)
+			avoid |= IFA_F_OPTIMISTIC;
+#endif
 		ret = ipv6_saddr_preferred(score->addr_type) ||
-		      !(score->ifa->flags & (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC));
+		      !(score->ifa->flags & avoid);
 		break;
+	    }
 #ifdef CONFIG_IPV6_MIP6
 	case IPV6_SADDR_RULE_HOA:
 	    {
@@ -1299,6 +1309,14 @@ static int ipv6_get_saddr_eval(struct net *net,
 		ret = !(ipv6_addr_orchid(&score->ifa->addr) ^
 			ipv6_addr_orchid(dst->addr));
 		break;
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	case IPV6_SADDR_RULE_NOT_OPTIMISTIC:
+		/* Optimistic addresses still have lower precedence than other
+		 * preferred addresses.
+		 */
+		ret = !(score->ifa->flags & IFA_F_OPTIMISTIC);
+		break;
+#endif
 	case IPV6_SADDR_RULE_PREFIX:
 		/* Rule 8: Use longest matching prefix */
 		ret = ipv6_addr_diff(&score->ifa->addr, dst->addr);
@@ -4330,6 +4348,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_ACCEPT_SOURCE_ROUTE] = cnf->accept_source_route;
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	array[DEVCONF_OPTIMISTIC_DAD] = cnf->optimistic_dad;
+	array[DEVCONF_USE_OPTIMISTIC] = cnf->use_optimistic;
 #endif
 #ifdef CONFIG_IPV6_MROUTE
 	array[DEVCONF_MC_FORWARDING] = cnf->mc_forwarding;
@@ -5155,6 +5174,14 @@ static struct addrconf_sysctl_table
 			.proc_handler   = proc_dointvec,
 
 		},
+		{
+			.procname       = "use_optimistic",
+			.data           = &ipv6_devconf.use_optimistic,
+			.maxlen         = sizeof(int),
+			.mode           = 0644,
+			.proc_handler   = proc_dointvec,
+
+		},
 #endif
 #ifdef CONFIG_IPV6_MROUTE
 		{
-- 
2.1.0.rc2.206.gedb03e5
