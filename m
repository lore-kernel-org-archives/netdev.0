From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 01/16] Loosen source address check on IPv4 output
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.61466.stgit@este>
References: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:53158 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475AbYJAPZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 11:25:24 -0400
In-reply-to: <20081001142431.4893.48078.stgit@este>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_route_output() contains a check to make sure that no flows with
non-local source IP addresses are routed. This obviously makes using
such addresses impossible.

This patch introduces a flowi flag which makes omitting this check
possible. The new flag provides a way of handling transparent and
non-transparent connections differently.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/flow.h |    2 ++
 net/ipv4/route.c   |   20 +++++++++++++-------
 2 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 228b247..b45a5e4 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -47,6 +47,8 @@ struct flowi {
 #define fl4_scope	nl_u.ip4_u.scope
 
 	__u8	proto;
+	__u8	flags;
+#define FLOWI_FLAG_ANYSRC 0x01
 	union {
 		struct {
 			__be16	sport;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f62187b..a6d7c58 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2361,11 +2361,6 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 		    ipv4_is_zeronet(oldflp->fl4_src))
 			goto out;
 
-		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-		dev_out = ip_dev_find(net, oldflp->fl4_src);
-		if (dev_out == NULL)
-			goto out;
-
 		/* I removed check for oif == dev_out->oif here.
 		   It was wrong for two reasons:
 		   1. ip_dev_find(net, saddr) can return wrong iface, if saddr
@@ -2377,6 +2372,11 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 		if (oldflp->oif == 0
 		    && (ipv4_is_multicast(oldflp->fl4_dst) ||
 			oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
+			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
+			dev_out = ip_dev_find(net, oldflp->fl4_src);
+			if (dev_out == NULL)
+				goto out;
+
 			/* Special hack: user can direct multicasts
 			   and limited broadcast via necessary interface
 			   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
@@ -2395,9 +2395,15 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 			fl.oif = dev_out->ifindex;
 			goto make_route;
 		}
-		if (dev_out)
+
+		if (!(oldflp->flags & FLOWI_FLAG_ANYSRC)) {
+			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
+			dev_out = ip_dev_find(net, oldflp->fl4_src);
+			if (dev_out == NULL)
+				goto out;
 			dev_put(dev_out);
-		dev_out = NULL;
+			dev_out = NULL;
+		}
 	}
 
 


