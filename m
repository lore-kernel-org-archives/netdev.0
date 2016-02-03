From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: [PATCH stable v2 1/1] net/ipv6: add sysctl option accept_ra_min_hop_limit
Date: Wed, 3 Feb 2016 10:56:16 +0900
Message-ID: <1454464576-17776-1-git-send-email-machida.yuki@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuki Machida <machida.yuki@jp.fujitsu.com>,
	Hangbin Liu <liuhangbin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>, <hideaki.yoshifuji@miraclelinux.com>,
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:30779 "EHLO
	mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130AbcBCB4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 20:56:55 -0500
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id DE2DFAC049B
	for <netdev@vger.kernel.org>; Wed,  3 Feb 2016 10:56:49 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply the following patch to v4.1.x.

By commit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")
that have been added in the 4.0-rc7, it no longer comply with RFC4861.
This problem has been fixed in the commit 8013d1d7eafb 
("net/ipv6: add sysctl option accept_ra_min_hop_limit") 
in 4.3-rc1, but 4.1.x is still.

[ Upstream 8013d1d7eafb0589ca766db6b74026f76b7f5cb4 ]

Commit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")
disabled accept hop limit from RA if it is smaller than the current hop
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
Acked-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 Documentation/networking/ip-sysctl.txt |  8 ++++++++
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ipv6.h              |  2 ++
 net/ipv6/addrconf.c                    | 10 ++++++++++
 net/ipv6/ndisc.c                       | 16 +++++++---------
 5 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 071fb18..07fad3d 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1321,6 +1321,14 @@ accept_ra_from_local - BOOLEAN
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
index e4b4649..01c2592 100644
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
index 5efa54a..21cfddf 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -171,6 +171,8 @@ enum {
 	DEVCONF_USE_OPTIMISTIC,
 	DEVCONF_ACCEPT_RA_MTU,
 	DEVCONF_STABLE_SECRET,
+	__DEVCONF_USE_OIF_ADDRS_ONLY,	/* not implemented */
+	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f4795b0..28c4bc5 100644
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
@@ -236,6 +237,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.max_addresses		= IPV6_MAX_ADDRESSES,
 	.accept_ra_defrtr	= 1,
 	.accept_ra_from_local	= 0,
+	.accept_ra_min_hop_limit= 1,
 	.accept_ra_pinfo	= 1,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	.accept_ra_rtr_pref	= 1,
@@ -4565,6 +4567,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_MAX_DESYNC_FACTOR] = cnf->max_desync_factor;
 	array[DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
 	array[DEVCONF_ACCEPT_RA_DEFRTR] = cnf->accept_ra_defrtr;
+	array[DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT] = cnf->accept_ra_min_hop_limit;
 	array[DEVCONF_ACCEPT_RA_PINFO] = cnf->accept_ra_pinfo;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	array[DEVCONF_ACCEPT_RA_RTR_PREF] = cnf->accept_ra_rtr_pref;
@@ -5458,6 +5461,13 @@ static struct addrconf_sysctl_table
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
index 96f153c..abb0bdd 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1225,18 +1225,16 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	if (rt)
 		rt6_set_expires(rt, jiffies + (HZ * lifetime));
-	if (ra_msg->icmph.icmp6_hop_limit) {
-		/* Only set hop_limit on the interface if it is higher than
-		 * the current hop_limit.
-		 */
-		if (in6_dev->cnf.hop_limit < ra_msg->icmph.icmp6_hop_limit) {
+	if (in6_dev->cnf.accept_ra_min_hop_limit < 256 &&
+	    ra_msg->icmph.icmp6_hop_limit) {
+		if (in6_dev->cnf.accept_ra_min_hop_limit <= ra_msg->icmph.icmp6_hop_limit) {
 			in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
+			if (rt)
+				dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
+					       ra_msg->icmph.icmp6_hop_limit);
 		} else {
-			ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than current\n");
+			ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than minimum\n");
 		}
-		if (rt)
-			dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
-				       ra_msg->icmph.icmp6_hop_limit);
 	}
 
 skip_defrtr:
-- 
1.9.1
