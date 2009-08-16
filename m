From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] Update Neighbor Cache when IPv6 RA is received on a router
Date: Sat, 15 Aug 2009 20:19:54 -0400
Message-ID: <1250381994-21329-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from BISCAYNE-ONE-STATION.MIT.EDU ([18.7.7.80]:62020 "EHLO
	biscayne-one-station.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752678AbZHPAUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2009 20:20:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When processing a received IPv6 Router Advertisement, the kernel
creates or updates an IPv6 Neighbor Cache entry for the sender --
but presently this does not occur if IPv6 forwarding is enabled
(net.ipv6.conf.*.forwarding = 1), or if IPv6 Router Advertisements
are not accepted (net.ipv6.conf.*.accept_ra = 0), because in these
cases processing of the Router Advertisement has already halted.

This patch allows the Neighbor Cache to be updated in these cases,
while still avoiding any modification to routes or link parameters.

This continues to satisfy RFC 4861, since any entry created in the
Neighbor Cache as the result of a received Router Advertisement is
still placed in the STALE state.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/ipv6/ndisc.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 1ba42bd..44b4c87 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1151,10 +1151,6 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			   skb->dev->name);
 		return;
 	}
-	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra) {
-		in6_dev_put(in6_dev);
-		return;
-	}
 
 	if (!ndisc_parse_options(opt, optlen, &ndopts)) {
 		in6_dev_put(in6_dev);
@@ -1163,6 +1159,10 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		return;
 	}
 
+	/* skip route and link configuration on routers */
+	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra)
+		goto skip_linkparms;
+
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	/* skip link-specific parameters from interior routers */
 	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
@@ -1283,9 +1283,7 @@ skip_defrtr:
 		}
 	}
 
-#ifdef CONFIG_IPV6_NDISC_NODETYPE
 skip_linkparms:
-#endif
 
 	/*
 	 *	Process options.
@@ -1312,6 +1310,10 @@ skip_linkparms:
 			     NEIGH_UPDATE_F_ISROUTER);
 	}
 
+	/* skip route and link configuration on routers */
+	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra)
+		goto out;
+
 #ifdef CONFIG_IPV6_ROUTE_INFO
 	if (in6_dev->cnf.accept_ra_rtr_pref && ndopts.nd_opts_ri) {
 		struct nd_opt_hdr *p;
-- 
1.6.0.4

