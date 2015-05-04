From: Markus Stenberg <markus.stenberg@iki.fi>
Subject: [PATCH] ipv6: RTA_PREFSRC dumping was somewhat incorrect.
Date: Mon, 4 May 2015 14:46:02 +0300
Message-ID: <BAADD2CA-4AC1-4916-B035-246F3CBF080B@iki.fi>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Markus Stenberg <markus.stenberg@iki.fi>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-out1.inet.fi ([62.71.2.203]:34113 "EHLO jenni2.inet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422AbbEDLwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 07:52:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid dumping RTA_PREFSRC twice if iif is not set, but dst is.

Note that the change also dumps RTA_PREFSRC even if iif RTA_IIF is
sent. As scopes are not that rare in IPv6, I believe that to be
correct behavior.

Signed-off-by: Markus Stenberg <markus.stenberg@iki.fi>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5c48293..442fa29 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2607,6 +2607,7 @@ static int rt6_fill_node(struct net *net,
 	struct nlmsghdr *nlh;
 	long expires;
 	u32 table;
+	struct in6_addr saddr_buf;
 
 	if (prefix) {	/* user wants prefix routes only */
 		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
@@ -2702,15 +2703,13 @@ static int rt6_fill_node(struct net *net,
 #endif
 			if (nla_put_u32(skb, RTA_IIF, iif))
 				goto nla_put_failure;
-	} else if (dst) {
-		struct in6_addr saddr_buf;
+	}
+
+	if (dst) {
 		if (ip6_route_get_saddr(net, rt, dst, 0, &saddr_buf) == 0 &&
 		    nla_put_in6_addr(skb, RTA_PREFSRC, &saddr_buf))
 			goto nla_put_failure;
-	}
-
-	if (rt->rt6i_prefsrc.plen) {
-		struct in6_addr saddr_buf;
+	} else if (rt->rt6i_prefsrc.plen) {
 		saddr_buf = rt->rt6i_prefsrc.addr;
 		if (nla_put_in6_addr(skb, RTA_PREFSRC, &saddr_buf))
 			goto nla_put_failure;
