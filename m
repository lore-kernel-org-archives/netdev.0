From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net-next v4] net/ipv6: add sysctl option accept_ra_min_hop_limit
Date: Thu, 30 Jul 2015 10:55:07 +0800
Message-ID: <1438224907-30873-1-git-send-email-liuhangbin@gmail.com>
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:32807 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbbG3CzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 22:55:20 -0400
Received: by pdbnt7 with SMTP id nt7so16170273pdb.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 19:55:20 -0700 (PDT)
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
 net/ipv6/ndisc.c                       | 14 +++++---------
 5 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 1a5ab21b..00d26d9 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1340,6 +1340,14 @@ accept_ra_from_local - BOOLEAN
 	   disabled if accept_ra_from_local is disabled
                on a specific interface.
 
+accept_ra_min_hop_limit - INTEGER
+	Minimum hop limit Information in Router Advertisement.
+
+	Hop limit Information in Router Advertisement less than this
+	variable shall be ignored.
+
+	Default: 1
+
 accept_ra_pinfo - BOOLEAN
 	Learn Prefix Information in Router Advertisement.
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 06ed637..cb9dcad 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -29,6 +29,7 @@ struct ipv6_devconf {
 	__s32		max_desync_factor;
 	__s32		max_addresses;
 	__s32		accept_ra_defrtr;
+	__s32		accept_ra_min_hop_limit;
 	__s32		accept_ra_pinfo;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	__s32		accept_ra_rtr_pref;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 641a146..80f3b74 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -172,6 +172,7 @@ enum {
 	DEVCONF_ACCEPT_RA_MTU,
 	DEVCONF_STABLE_SECRET,
 	DEVCONF_USE_OIF_ADDRS_ONLY,
+	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index eb0c6a3..53e3a9d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -195,6 +195,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.max_addresses		= IPV6_MAX_ADDRESSES,
 	.accept_ra_defrtr	= 1,
 	.accept_ra_from_local	= 0,
+	.accept_ra_min_hop_limit= 1,
 	.accept_ra_pinfo	= 1,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	.accept_ra_rtr_pref	= 1,
@@ -237,6 +238,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.max_addresses		= IPV6_MAX_ADDRESSES,
 	.accept_ra_defrtr	= 1,
 	.accept_ra_from_local	= 0,
+	.accept_ra_min_hop_limit= 1,
 	.accept_ra_pinfo	= 1,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	.accept_ra_rtr_pref	= 1,
@@ -4588,6 +4590,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_MAX_DESYNC_FACTOR] = cnf->max_desync_factor;
 	array[DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
 	array[DEVCONF_ACCEPT_RA_DEFRTR] = cnf->accept_ra_defrtr;
+	array[DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT] = cnf->accept_ra_min_hop_limit;
 	array[DEVCONF_ACCEPT_RA_PINFO] = cnf->accept_ra_pinfo;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	array[DEVCONF_ACCEPT_RA_RTR_PREF] = cnf->accept_ra_rtr_pref;
@@ -5485,6 +5488,13 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec,
 		},
 		{
+			.procname	= "accept_ra_min_hop_limit",
+			.data		= &ipv6_devconf.accept_ra_min_hop_limit,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
+		{
 			.procname	= "accept_ra_pinfo",
 			.data		= &ipv6_devconf.accept_ra_pinfo,
 			.maxlen		= sizeof(int),
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0a05b35..5619e64 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1225,18 +1225,14 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	if (rt)
 		rt6_set_expires(rt, jiffies + (HZ * lifetime));
-	if (ra_msg->icmph.icmp6_hop_limit) {
-		/* Only set hop_limit on the interface if it is higher than
-		 * the current hop_limit.
-		 */
-		if (in6_dev->cnf.hop_limit < ra_msg->icmph.icmp6_hop_limit) {
-			in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
-		} else {
-			ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than current\n");
-		}
+	if (in6_dev->cnf.accept_ra_min_hop_limit < 256 && ra_msg->icmph.icmp6_hop_limit &&
+	    in6_dev->cnf.accept_ra_min_hop_limit <= ra_msg->icmph.icmp6_hop_limit) {
+		in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
 		if (rt)
 			dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
 				       ra_msg->icmph.icmp6_hop_limit);
+	} else {
+		ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than minimum\n");
 	}
 
 skip_defrtr:
-- 
1.9.3
