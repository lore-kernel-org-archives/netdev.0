From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v2] ipv6: unify logic evaluating inet6_dev's accept_ra property
Date: Fri, 30 Nov 2012 22:25:59 +0200
Message-ID: <1354307159-24193-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, Tore Anderson <tore@fud.no>,
	shmulik.ladkani@gmail.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:42701 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755844Ab2K3U0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 15:26:25 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so352490eaa.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 12:26:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As of 026359b [ipv6: Send ICMPv6 RSes only when RAs are accepted], the
logic determining whether to send Router Solicitations is identical
to the logic determining whether kernel accepts Router Advertisements.

However the condition itself is repeated in several code locations.

Unify it by introducing 'ipv6_accept_ra()' accessor.

Also, simplify the condition expression, making it more readable.
No semantic change.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---

v2: proper comment styling

 include/net/ipv6.h  |    9 +++++++++
 net/ipv6/addrconf.c |    3 +--
 net/ipv6/ndisc.c    |   16 ++--------------
 3 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 979bf6c..985c6fa 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -271,6 +271,15 @@ struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 
 extern bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb);
 
+static inline bool ipv6_accept_ra(struct inet6_dev *idev)
+{
+	/* If forwarding is enabled, RA are not accepted unless the special
+	 * hybrid mode (accept_ra=2) is enabled.
+	 */
+	return idev->cnf.forwarding ? idev->cnf.accept_ra == 2 :
+	    idev->cnf.accept_ra;
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
 static inline int ip6_frag_nqueues(struct net *net)
 {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0424e4e..ca1ed8a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3005,8 +3005,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 	   router advertisements, start sending router solicitations.
 	 */
 
-	if (((ifp->idev->cnf.accept_ra == 1 && !ifp->idev->cnf.forwarding) ||
-	     ifp->idev->cnf.accept_ra == 2) &&
+	if (ipv6_accept_ra(ifp->idev) &&
 	    ifp->idev->cnf.rtr_solicits > 0 &&
 	    (dev->flags&IFF_LOOPBACK) == 0 &&
 	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2edce30..980cdc3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1033,18 +1033,6 @@ errout:
 	rtnl_set_sk_err(net, RTNLGRP_ND_USEROPT, err);
 }
 
-static inline int accept_ra(struct inet6_dev *in6_dev)
-{
-	/*
-	 * If forwarding is enabled, RA are not accepted unless the special
-	 * hybrid mode (accept_ra=2) is enabled.
-	 */
-	if (in6_dev->cnf.forwarding && in6_dev->cnf.accept_ra < 2)
-		return 0;
-
-	return in6_dev->cnf.accept_ra;
-}
-
 static void ndisc_router_discovery(struct sk_buff *skb)
 {
 	struct ra_msg *ra_msg = (struct ra_msg *)skb_transport_header(skb);
@@ -1092,7 +1080,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		return;
 	}
 
-	if (!accept_ra(in6_dev))
+	if (!ipv6_accept_ra(in6_dev))
 		goto skip_linkparms;
 
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
@@ -1248,7 +1236,7 @@ skip_linkparms:
 			     NEIGH_UPDATE_F_ISROUTER);
 	}
 
-	if (!accept_ra(in6_dev))
+	if (!ipv6_accept_ra(in6_dev))
 		goto out;
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
-- 
1.7.9
