From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 05/13] Loosen source address check on IPv4 output
Date: Mon, 05 Mar 2007 16:45:41 +0100
Message-ID: <20070305154541.3471.36004.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:3556 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933539AbXCEPpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:45:43 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 7EB02294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:45:42 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip_route_output() contains a check to make sure that no flows with
non-local source IP addresses are routed. This obviously makes using
such addresses impossible.

This patch introduces a flowi flag which makes omitting this check
possible. The new flag provides a way of handling transparent and
non-transparent connections differently.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/net/flow.h |    1 +
 net/ipv4/route.c   |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index ce4b10d..9eb91f2 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -49,6 +49,7 @@ struct flowi {
 	__u8	proto;
 	__u8	flags;
 #define FLOWI_FLAG_MULTIPATHOLDROUTE 0x01
+#define FLOWI_FLAG_TRANSPARENT 0x02
 	union {
 		struct {
 			__be16	sport;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c526fb2..8091a96 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -572,7 +572,8 @@ static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 		(*(u16 *)&fl1->nl_u.ip4_u.tos ^
 		 *(u16 *)&fl2->nl_u.ip4_u.tos) |
 		(fl1->oif ^ fl2->oif) |
-		(fl1->iif ^ fl2->iif)) == 0;
+		(fl1->iif ^ fl2->iif) |
+		((fl1->flags ^ fl2->flags) & FLOWI_FLAG_TRANSPARENT)) == 0;
 }
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
@@ -2338,6 +2339,7 @@ static inline int __mkroute_output(struct rtable **result,
 	rth->fl.fl4_src	= oldflp->fl4_src;
 	rth->fl.oif	= oldflp->oif;
 	rth->fl.mark    = oldflp->mark;
+	rth->fl.flags	= oldflp->flags;
 	rth->rt_dst	= fl->fl4_dst;
 	rth->rt_src	= fl->fl4_src;
 	rth->rt_iif	= oldflp->oif ? : dev_out->ifindex;
@@ -2482,6 +2484,7 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 						  RT_SCOPE_LINK :
 						  RT_SCOPE_UNIVERSE),
 				      } },
+			    .flags = oldflp->flags,
 			    .mark = oldflp->mark,
 			    .iif = loopback_dev.ifindex,
 			    .oif = oldflp->oif };
@@ -2506,7 +2509,7 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 
 		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
 		dev_out = ip_dev_find(oldflp->fl4_src);
-		if (dev_out == NULL)
+		if (dev_out == NULL && !(oldflp->flags & FLOWI_FLAG_TRANSPARENT))
 			goto out;
 
 		/* I removed check for oif == dev_out->oif here.
@@ -2678,6 +2681,7 @@ int __ip_route_output_key(struct rtable **rp, const struct flowi *flp)
 		    rth->fl.iif == 0 &&
 		    rth->fl.oif == flp->oif &&
 		    rth->fl.mark == flp->mark &&
+		    !((rth->fl.flags ^ flp->flags) & FLOWI_FLAG_TRANSPARENT) &&
 		    !((rth->fl.fl4_tos ^ flp->fl4_tos) &
 			    (IPTOS_RT_MASK | RTO_ONLINK))) {
 

