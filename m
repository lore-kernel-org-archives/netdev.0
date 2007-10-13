From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [PATCH 01/14] Loosen source address check on IPv4 output
Date: Sat, 13 Oct 2007 19:29:29 +0200
Message-ID: <20071013172929.22517.2585.stgit@nessa.odu>
References: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:45511 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760597AbXJMSjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 14:39:41 -0400
Received: from nessa.odu ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPV00DTJ1U69V10@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 13 Oct 2007 19:27:42 +0200 (CEST)
In-reply-to: <20071013172857.22517.84760.stgit@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip_route_output() contains a check to make sure that no flows with
non-local source IP addresses are routed. This obviously makes using
such addresses impossible.

This patch introduces a flowi flag which makes omitting this check
possible. The new flag provides a way of handling transparent and
non-transparent connections differently.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
Acked-by: Patrick McHardy <kaber@trash.net>
---

 include/net/flow.h |    1 +
 net/ipv4/route.c   |   20 +++++++++++++-------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index af59fa5..c734d50 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -49,6 +49,7 @@ struct flowi {
 	__u8	proto;
 	__u8	flags;
 #define FLOWI_FLAG_MULTIPATHOLDROUTE 0x01
+#define FLOWI_FLAG_ANYSRC 0x02
 	union {
 		struct {
 			__be16	sport;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 21b12de..6f7e4cb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2155,11 +2155,6 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 		    ZERONET(oldflp->fl4_src))
 			goto out;
 
-		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-		dev_out = ip_dev_find(oldflp->fl4_src);
-		if (dev_out == NULL)
-			goto out;
-
 		/* I removed check for oif == dev_out->oif here.
 		   It was wrong for two reasons:
 		   1. ip_dev_find(saddr) can return wrong iface, if saddr is
@@ -2170,6 +2165,11 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 
 		if (oldflp->oif == 0
 		    && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
+			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
+			dev_out = ip_dev_find(oldflp->fl4_src);
+			if (dev_out == NULL)
+				goto out;
+
 			/* Special hack: user can direct multicasts
 			   and limited broadcast via necessary interface
 			   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
@@ -2188,9 +2188,15 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 			fl.oif = dev_out->ifindex;
 			goto make_route;
 		}
-		if (dev_out)
+
+		if (!(oldflp->flags & FLOWI_FLAG_ANYSRC)) {
+			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
+			dev_out = ip_dev_find(oldflp->fl4_src);
+			if (dev_out == NULL)
+				goto out;
 			dev_put(dev_out);
-		dev_out = NULL;
+			dev_out = NULL;
+		}
 	}
 
 

