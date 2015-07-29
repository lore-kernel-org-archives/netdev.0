From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv3] net/ipv6: add sysctl option accept_ra_min_hop_limit
Date: Wed, 29 Jul 2015 18:14:18 +0800
Message-ID: <1438164858-5253-1-git-send-email-liuhangbin@gmail.com>
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36856 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbbG2KOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 06:14:35 -0400
Received: by pachj5 with SMTP id hj5so3399098pac.3
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 03:14:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")
disabled accept hop limit from RA if it is higher than the current hop
limit for security stuff. But this behavior kind of break the RFC definition.

RFC 4861, 6.3.4.  Processing Received Router Advertisements
   A Router Advertisement field (e.g., Cur Hop Limit, Reachable Time,
   and Retrans Timer) may contain a value denoting that it is
   unspecified.  In such cases, the parameter should be ignored and the
   host should continue using whatever value it is already using.

   If the received Cur Hop Limit value is non-zero, the host SHOULD set
   its CurHopLimit variable to the received value.

So add sysctl option accept_ra_min_hop_limit to let user choose the minimum
hop limit value they can accept from RA. And set default to 1 to meet RFC
standards.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |  8 ++++++++
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ipv6.h              |  1 +
 net/ipv6/addrconf.c                    | 10 ++++++++++
 net/ipv6/ndisc.c                       |  8 +++-----
 5 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 5fae770..ced0a38 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1346,6 +1346,14 @@ accept_ra_pinfo - BOOLEAN
 	Functional default: enabled if accept_ra is enabled.
 			    disabled if accept_ra is disabled.
 
+accept_ra_min_hop_limit - INTEGER
+	Minimum hop limit Information in Router Advertisement.
+
+	Hop limit Information in Router Advertisement less than this
+	variable shall be ignored.
+
+	Default: 1
+
 accept_ra_rt_info_max_plen - INTEGER
 	Maximum prefix length of Route Information in RA.
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 82806c6..ac01ab4 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -30,6 +30,7 @@ struct ipv6_devconf {
 	__s32		max_addresses;
 	__s32		accept_ra_defrtr;
 	__s32		accept_ra_pinfo;
+	__s32		accept_ra_min_hop_limit;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	__s32		accept_ra_rtr_pref;
 	__s32		rtr_probe_interval;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 5efa54a..68094e33 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -171,6 +171,7 @@ enum {
 	DEVCONF_USE_OPTIMISTIC,
 	DEVCONF_ACCEPT_RA_MTU,
 	DEVCONF_STABLE_SECRET,
+	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 21c2c81..77df8f2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -196,6 +196,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_ra_defrtr	= 1,
 	.accept_ra_from_local	= 0,
 	.accept_ra_pinfo	= 1,
+	.accept_ra_min_hop_limit= 1,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	.accept_ra_rtr_pref	= 1,
 	.rtr_probe_interval	= 60 * HZ,
@@ -237,6 +238,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.accept_ra_defrtr	= 1,
 	.accept_ra_from_local	= 0,
 	.accept_ra_pinfo	= 1,
+	.accept_ra_min_hop_limit= 1,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	.accept_ra_rtr_pref	= 1,
 	.rtr_probe_interval	= 60 * HZ,
@@ -4561,6 +4563,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
 	array[DEVCONF_ACCEPT_RA_DEFRTR] = cnf->accept_ra_defrtr;
 	array[DEVCONF_ACCEPT_RA_PINFO] = cnf->accept_ra_pinfo;
+	array[DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT] = cnf->accept_ra_min_hop_limit;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	array[DEVCONF_ACCEPT_RA_RTR_PREF] = cnf->accept_ra_rtr_pref;
 	array[DEVCONF_RTR_PROBE_INTERVAL] =
@@ -5462,6 +5465,13 @@ static struct addrconf_sysctl_table
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
+		{
+			.procname	= "accept_ra_min_hop_limit",
+			.data		= &ipv6_devconf.accept_ra_min_hop_limit,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
 #ifdef CONFIG_IPV6_ROUTER_PREF
 		{
 			.procname	= "accept_ra_rtr_pref",
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0a05b35..acda056 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1226,13 +1226,11 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	if (rt)
 		rt6_set_expires(rt, jiffies + (HZ * lifetime));
 	if (ra_msg->icmph.icmp6_hop_limit) {
-		/* Only set hop_limit on the interface if it is higher than
-		 * the current hop_limit.
-		 */
-		if (in6_dev->cnf.hop_limit < ra_msg->icmph.icmp6_hop_limit) {
+		if (in6_dev->cnf.accept_ra_min_hop_limit <= ra_msg->icmph.icmp6_hop_limit &&
+		    ra_msg->icmph.icmp6_hop_limit != 0) {
 			in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
 		} else {
-			ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than current\n");
+			ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than minimum\n");
 		}
 		if (rt)
 			dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
-- 
1.9.3
