From: Erik Kline <ek@google.com>
Subject: [PATCH v2 net-next] net: ipv6: Add a sysctl to make optimistic addresses useful candidates
Date: Tue, 28 Oct 2014 18:11:14 +0900
Message-ID: <1414487474-18201-1-git-send-email-ek@google.com>
Cc: davem@davemloft.net, ben@decadent.org.uk, lorenzo@google.com,
	hannes@stressinduktion.org, Erik Kline <ek@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:53357 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbaJ1JLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 05:11:25 -0400
Received: by mail-pd0-f202.google.com with SMTP id ft15so33545pdb.5
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 02:11:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a sysctl that causes an interface's optimistic addresses
to be considered equivalent to other non-deprecated addresses
for source address selection purposes.  Preferred addresses
will still take precedence over optimistic addresses, subject
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

Also, because optimistic nodes can receive frames, issue
an RTM_NEWADDR as soon as DAD starts (with the IFA_F_OPTIMSTIC
flag appropriately set).  A second RTM_NEWADDR is sent if DAD
completes (the address flags have changed), otherwise an
RTM_DELADDR is sent.

Also: add an entry in ip-sysctl.txt for optimistic_dad.

Signed-off-by: Erik Kline <ek@google.com>
---
 Documentation/networking/ip-sysctl.txt | 13 ++++++++++
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ipv6.h              |  1 +
 net/ipv6/addrconf.c                    | 46 ++++++++++++++++++++++++++++++++--
 4 files changed, 59 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 0307e28..e03cf49 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1452,6 +1452,19 @@ suppress_frag_ndisc - INTEGER
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
index efa2666..e863d08 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -164,6 +164,7 @@ enum {
 	DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL,
 	DEVCONF_SUPPRESS_FRAG_NDISC,
 	DEVCONF_ACCEPT_RA_FROM_LOCAL,
+	DEVCONF_USE_OPTIMISTIC,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 50b95b2..8d12b7c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1170,6 +1170,9 @@ enum {
 	IPV6_SADDR_RULE_PRIVACY,
 	IPV6_SADDR_RULE_ORCHID,
 	IPV6_SADDR_RULE_PREFIX,
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	IPV6_SADDR_RULE_NOT_OPTIMISTIC,
+#endif
 	IPV6_SADDR_RULE_MAX
 };
 
@@ -1197,6 +1200,15 @@ static inline int ipv6_saddr_preferred(int type)
 	return 0;
 }
 
+static inline bool ipv6_use_optimistic_addr(struct inet6_dev *idev)
+{
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	return idev && idev->cnf.optimistic_dad && idev->cnf.use_optimistic;
+#else
+	return false;
+#endif
+}
+
 static int ipv6_get_saddr_eval(struct net *net,
 			       struct ipv6_saddr_score *score,
 			       struct ipv6_saddr_dst *dst,
@@ -1257,10 +1269,16 @@ static int ipv6_get_saddr_eval(struct net *net,
 		score->scopedist = ret;
 		break;
 	case IPV6_SADDR_RULE_PREFERRED:
+	    {
 		/* Rule 3: Avoid deprecated and optimistic addresses */
+		u8 avoid = IFA_F_DEPRECATED;
+
+		if (!ipv6_use_optimistic_addr(score->ifa->idev))
+			avoid |= IFA_F_OPTIMISTIC;
 		ret = ipv6_saddr_preferred(score->addr_type) ||
-		      !(score->ifa->flags & (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC));
+		      !(score->ifa->flags & avoid);
 		break;
+	    }
 #ifdef CONFIG_IPV6_MIP6
 	case IPV6_SADDR_RULE_HOA:
 	    {
@@ -1306,6 +1324,14 @@ static int ipv6_get_saddr_eval(struct net *net,
 			ret = score->ifa->prefix_len;
 		score->matchlen = ret;
 		break;
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	case IPV6_SADDR_RULE_NOT_OPTIMISTIC:
+		/* Optimistic addresses still have lower precedence than other
+		 * preferred addresses.
+		 */
+		ret = !(score->ifa->flags & IFA_F_OPTIMISTIC);
+		break;
+#endif
 	default:
 		ret = 0;
 	}
@@ -3222,8 +3248,15 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 	 * Optimistic nodes can start receiving
 	 * Frames right away
 	 */
-	if (ifp->flags & IFA_F_OPTIMISTIC)
+	if (ifp->flags & IFA_F_OPTIMISTIC) {
 		ip6_ins_rt(ifp->rt);
+		if (ipv6_use_optimistic_addr(idev)) {
+			/* Because optimistic nodes can use this address,
+			 * notify listeners. If DAD fails, RTM_DELADDR is sent.
+			 */
+			ipv6_ifa_notify(RTM_NEWADDR, ifp);
+		}
+	}
 
 	addrconf_dad_kick(ifp);
 out:
@@ -4330,6 +4363,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_ACCEPT_SOURCE_ROUTE] = cnf->accept_source_route;
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	array[DEVCONF_OPTIMISTIC_DAD] = cnf->optimistic_dad;
+	array[DEVCONF_USE_OPTIMISTIC] = cnf->use_optimistic;
 #endif
 #ifdef CONFIG_IPV6_MROUTE
 	array[DEVCONF_MC_FORWARDING] = cnf->mc_forwarding;
@@ -5155,6 +5189,14 @@ static struct addrconf_sysctl_table
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
