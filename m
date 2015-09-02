From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next] Revert "net/ipv6: add sysctl option
 accept_ra_min_hop_limit"
Date: Wed, 2 Sep 2015 11:43:01 +0200
Message-ID: <20150902094301.GA6434@via.ecp.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: liuhangbin@gmail.com, hideaki.yoshifuji@miraclelinux.com,
	sd@queasysnail.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from artikodin.via.ecp.fr ([138.195.130.75]:59975 "EHLO
	artikodin.via.ecp.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbbIBJuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 05:50:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 8013d1d7eafb0589ca766db6b74026f76b7f5cb4.

There are several issues with this patch.
It completely cancels the security changes introduced by 6fd99094de2b
("ipv6: Don't reduce hop limit for an interface").
The current default value (min hop limit = 1) can result in the same
denial of service that 6fd99094de2b prevents, but it is hard to define
a correct and sane default value.
More generally, it is yet another IPv6 sysctl, and we already have too
many.

This was introduced to satisfy a TAHI test case which, in my opinion, is
too strict, turning the RFC's "SHOULD" into a "MUST":

    If the received Cur Hop Limit value is non-zero, the host
    SHOULD set its CurHopLimit variable to the received value.

The behavior of this sysctl is wrong in multiple ways.  Some are
fixable, but let's not rush this commit into mainline, and revert this
while we still can, then we can come up with a better solution.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 Documentation/networking/ip-sysctl.txt |  8 --------
 include/linux/ipv6.h                   |  1 -
 include/uapi/linux/ipv6.h              |  1 -
 net/ipv6/addrconf.c                    | 10 ----------
 net/ipv6/ndisc.c                       | 16 +++++++++-------
 5 files changed, 9 insertions(+), 27 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ebe94f2cab98..c845aca413c8 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1371,14 +1371,6 @@ accept_ra_from_local - BOOLEAN
 	   disabled if accept_ra_from_local is disabled
                on a specific interface.
 
-accept_ra_min_hop_limit - INTEGER
-	Minimum hop limit Information in Router Advertisement.
-
-	Hop limit Information in Router Advertisement less than this
-	variable shall be ignored.
-
-	Default: 1
-
 accept_ra_pinfo - BOOLEAN
 	Learn Prefix Information in Router Advertisement.
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index f1f32af6d9b9..5e6d3b8f5a42 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -29,7 +29,6 @@ struct ipv6_devconf {
 	__s32		max_desync_factor;
 	__s32		max_addresses;
 	__s32		accept_ra_defrtr;
-	__s32		accept_ra_min_hop_limit;
 	__s32		accept_ra_pinfo;
 	__s32		ignore_routes_with_linkdown;
 #ifdef CONFIG_IPV6_ROUTER_PREF
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 38b4fef20219..44d13121de52 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -172,7 +172,6 @@ enum {
 	DEVCONF_ACCEPT_RA_MTU,
 	DEVCONF_STABLE_SECRET,
 	DEVCONF_USE_OIF_ADDRS_ONLY,
-	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
 	DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
 	DEVCONF_MAX
 };
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 99c0f2b843f0..c8829ce0bbe7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -195,7 +195,6 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.max_addresses		= IPV6_MAX_ADDRESSES,
 	.accept_ra_defrtr	= 1,
 	.accept_ra_from_local	= 0,
-	.accept_ra_min_hop_limit= 1,
 	.accept_ra_pinfo	= 1,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	.accept_ra_rtr_pref	= 1,
@@ -239,7 +238,6 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.max_addresses		= IPV6_MAX_ADDRESSES,
 	.accept_ra_defrtr	= 1,
 	.accept_ra_from_local	= 0,
-	.accept_ra_min_hop_limit= 1,
 	.accept_ra_pinfo	= 1,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	.accept_ra_rtr_pref	= 1,
@@ -4658,7 +4656,6 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_MAX_DESYNC_FACTOR] = cnf->max_desync_factor;
 	array[DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
 	array[DEVCONF_ACCEPT_RA_DEFRTR] = cnf->accept_ra_defrtr;
-	array[DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT] = cnf->accept_ra_min_hop_limit;
 	array[DEVCONF_ACCEPT_RA_PINFO] = cnf->accept_ra_pinfo;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	array[DEVCONF_ACCEPT_RA_RTR_PREF] = cnf->accept_ra_rtr_pref;
@@ -5594,13 +5591,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	= "accept_ra_min_hop_limit",
-			.data		= &ipv6_devconf.accept_ra_min_hop_limit,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
 			.procname	= "accept_ra_pinfo",
 			.data		= &ipv6_devconf.accept_ra_pinfo,
 			.maxlen		= sizeof(int),
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 64a71354b069..fac72658bf59 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1235,16 +1235,18 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	if (rt)
 		rt6_set_expires(rt, jiffies + (HZ * lifetime));
-	if (in6_dev->cnf.accept_ra_min_hop_limit < 256 &&
-	    ra_msg->icmph.icmp6_hop_limit) {
-		if (in6_dev->cnf.accept_ra_min_hop_limit <= ra_msg->icmph.icmp6_hop_limit) {
+	if (ra_msg->icmph.icmp6_hop_limit) {
+		/* Only set hop_limit on the interface if it is higher than
+		 * the current hop_limit.
+		 */
+		if (in6_dev->cnf.hop_limit < ra_msg->icmph.icmp6_hop_limit) {
 			in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
-			if (rt)
-				dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
-					       ra_msg->icmph.icmp6_hop_limit);
 		} else {
-			ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than minimum\n");
+			ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than current\n");
 		}
+		if (rt)
+			dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
+				       ra_msg->icmph.icmp6_hop_limit);
 	}
 
 skip_defrtr:
-- 
2.5.1
