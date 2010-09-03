From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH] ipv6: add special mode accept_ra=2 to accept RA while
 configured as router
Date: Fri, 3 Sep 2010 08:59:14 -0400
Message-ID: <20100903125914.GA28460@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:47537 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab0ICM7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 08:59:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current IPv6 behavior is to not accept router advertisements while
forwarding, i.e. configured as router.

This does make sense, a router is typically not supposed to be auto
configured. However there are exceptions and we should allow the
current behavior to be overwritten.

Therefore this patch enables the user to overrule the "if forwarding
enabled then don't listen to RAs" rule by setting accept_ra to the
special value of 2.

An alternative would be to ignore the forwarding switch alltogether
and solely accept RAs based on the value of accept_ra. However, I
found that if not intended, accepting RAs as a router can lead to
strange unwanted behavior therefore we it seems wise to only do so
if the user explicitely asks for this behavior.

Signed-off-by: Thomas Graf <tgraf@infradead.org>

Index: net-2.6/net/ipv6/ndisc.c
===================================================================
--- net-2.6.orig/net/ipv6/ndisc.c
+++ net-2.6/net/ipv6/ndisc.c
@@ -1105,6 +1105,18 @@ errout:
 	rtnl_set_sk_err(net, RTNLGRP_ND_USEROPT, err);
 }
 
+static inline int accept_ra(struct inet6_dev *in6_dev)
+{
+	/*
+	 * If forwarding is enabled, RA are not accepted unless the special
+	 * hybrid mode (accept_ra=2) is enabled.
+	 */
+	if (in6_dev->cnf.forwarding && in6_dev->cnf.accept_ra < 2)
+		return 0;
+
+	return in6_dev->cnf.accept_ra;
+}
+
 static void ndisc_router_discovery(struct sk_buff *skb)
 {
 	struct ra_msg *ra_msg = (struct ra_msg *)skb_transport_header(skb);
@@ -1158,8 +1170,7 @@ static void ndisc_router_discovery(struc
 		return;
 	}
 
-	/* skip route and link configuration on routers */
-	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra)
+	if (!accept_ra(in6_dev))
 		goto skip_linkparms;
 
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
@@ -1309,8 +1320,7 @@ skip_linkparms:
 			     NEIGH_UPDATE_F_ISROUTER);
 	}
 
-	/* skip route and link configuration on routers */
-	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra)
+	if (!accept_ra(in6_dev))
 		goto out;
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
