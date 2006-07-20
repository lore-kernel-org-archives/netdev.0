From: Patrick McHardy <kaber@trash.net>
Subject: [IPV4]: Fix nexthop realm dumping for multipath routes
Date: Thu, 20 Jul 2006 16:28:22 +0200
Message-ID: <44BF9306.7080008@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090700090504010504030006"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37062 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932579AbWGTO3z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 10:29:55 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090700090504010504030006
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------090700090504010504030006
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPV4]: Fix nexthop realm dumping for multipath routes

Routing realms exist per nexthop, but are only returned to userspace for
the first nexthop. This is due to the fact that iproute2 only allows to
set the realm for the first nexthop and the kernel refuses multipath routes
where only a single realm is present.

Dump all realms for multipath routes to enable iproute to correctly display
them.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c76610a1027809f58840fe65b7abc8704f80dcc8
tree 9651193c156548539845ed0a2bd8af8e51182a00
parent 8e0ae6dc963ce12c8d9264d27509ff551dcb57fa
author Patrick McHardy <kaber@trash.net> Wed, 19 Jul 2006 19:22:24 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 19 Jul 2006 19:22:24 +0200

 net/ipv4/fib_semantics.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3c45256..1f19cdf 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -963,10 +963,6 @@ fib_dump_info(struct sk_buff *skb, u32 p
 	rtm->rtm_protocol = fi->fib_protocol;
 	if (fi->fib_priority)
 		RTA_PUT(skb, RTA_PRIORITY, 4, &fi->fib_priority);
-#ifdef CONFIG_NET_CLS_ROUTE
-	if (fi->fib_nh[0].nh_tclassid)
-		RTA_PUT(skb, RTA_FLOW, 4, &fi->fib_nh[0].nh_tclassid);
-#endif
 	if (rtnetlink_put_metrics(skb, fi->fib_metrics) < 0)
 		goto rtattr_failure;
 	if (fi->fib_prefsrc)
@@ -976,6 +972,10 @@ #endif
 			RTA_PUT(skb, RTA_GATEWAY, 4, &fi->fib_nh->nh_gw);
 		if (fi->fib_nh->nh_oif)
 			RTA_PUT(skb, RTA_OIF, sizeof(int), &fi->fib_nh->nh_oif);
+#ifdef CONFIG_NET_CLS_ROUTE
+		if (fi->fib_nh[0].nh_tclassid)
+			RTA_PUT(skb, RTA_FLOW, 4, &fi->fib_nh[0].nh_tclassid);
+#endif
 	}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (fi->fib_nhs > 1) {
@@ -994,6 +994,10 @@ #ifdef CONFIG_IP_ROUTE_MULTIPATH
 			nhp->rtnh_ifindex = nh->nh_oif;
 			if (nh->nh_gw)
 				RTA_PUT(skb, RTA_GATEWAY, 4, &nh->nh_gw);
+#ifdef CONFIG_NET_CLS_ROUTE
+			if (nh->nh_tclassid)
+				RTA_PUT(skb, RTA_FLOW, 4, &nh->nh_tclassid);
+#endif
 			nhp->rtnh_len = skb->tail - (unsigned char*)nhp;
 		} endfor_nexthops(fi);
 		mp_head->rta_type = RTA_MULTIPATH;

--------------090700090504010504030006--
