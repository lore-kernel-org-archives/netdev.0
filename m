From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH] net/ipv6: add sysctl option min_hop_limit
Date: Wed, 29 Jul 2015 14:45:50 +0800
Message-ID: <1438152350-6579-1-git-send-email-liuhangbin@gmail.com>
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34882 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbbG2GqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 02:46:08 -0400
Received: by pdrg1 with SMTP id g1so548413pdr.2
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 23:46:08 -0700 (PDT)
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

So add sysctl option min_hop_limit to let user choose the minimum hop limit
value they can accept from RA. And set default to 1 to meet RFC standards.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |  4 ++++
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ipv6.h              |  1 +
 net/ipv6/addrconf.c                    | 10 ++++++++++
 net/ipv6/ndisc.c                       |  8 +++-----
 5 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 5fae770..844904b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1431,6 +1431,10 @@ hop_limit - INTEGER
 	Default Hop Limit to set.
 	Default: 64
 
+min_hop_limit - INTEGER
+	Minimum hop limit value can be accepted from Router Advertisement.
+	Default: 1
+
 mtu - INTEGER
 	Default Maximum Transfer Unit
 	Default: 1280 (IPv6 required minimum)
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 82806c6..cd9e6af 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -11,6 +11,7 @@
 struct ipv6_devconf {
 	__s32		forwarding;
 	__s32		hop_limit;
+	__s32           min_hop_limit;
 	__s32		mtu6;
 	__s32		accept_ra;
 	__s32		accept_redirects;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 5efa54a..c1c09bb 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -171,6 +171,7 @@ enum {
 	DEVCONF_USE_OPTIMISTIC,
 	DEVCONF_ACCEPT_RA_MTU,
 	DEVCONF_STABLE_SECRET,
+	DEVCONF_MIN_HOP_LIMIT,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 21c2c81..b6ed39e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -176,6 +176,7 @@ static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.forwarding		= 0,
 	.hop_limit		= IPV6_DEFAULT_HOPLIMIT,
+	.min_hop_limit		= 1,
 	.mtu6			= IPV6_MIN_MTU,
 	.accept_ra		= 1,
 	.accept_redirects	= 1,
@@ -217,6 +218,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.forwarding		= 0,
 	.hop_limit		= IPV6_DEFAULT_HOPLIMIT,
+	.min_hop_limit		= 1,
 	.mtu6			= IPV6_MIN_MTU,
 	.accept_ra		= 1,
 	.accept_redirects	= 1,
@@ -4538,6 +4540,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	memset(array, 0, bytes);
 	array[DEVCONF_FORWARDING] = cnf->forwarding;
 	array[DEVCONF_HOPLIMIT] = cnf->hop_limit;
+	array[DEVCONF_MIN_HOP_LIMIT] = cnf->min_hop_limit;
 	array[DEVCONF_MTU6] = cnf->mtu6;
 	array[DEVCONF_ACCEPT_RA] = cnf->accept_ra;
 	array[DEVCONF_ACCEPT_REDIRECTS] = cnf->accept_redirects;
@@ -5328,6 +5331,13 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec,
 		},
 		{
+			.procname	= "min_hop_limit",
+			.data		= &ipv6_devconf.min_hop_limit,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
+		{
 			.procname	= "mtu",
 			.data		= &ipv6_devconf.mtu6,
 			.maxlen		= sizeof(int),
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0a05b35..c22f3ac 100644
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
+		if (in6_dev->cnf.min_hop_limit <= ra_msg->icmph.icmp6_hop_limit &&
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
