From: Paul Marks <pmarks@google.com>
Subject: [PATCH v2] ipv6: Fix default route failover when CONFIG_IPV6_ROUTER_PREF=n
Date: Mon,  3 Dec 2012 12:26:54 -0800
Message-ID: <1354566414-5752-1-git-send-email-pmarks@google.com>
References: <20121203.135923.1359930693250099951.davem@davemloft.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	Paul Marks <pmarks@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:41261 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab2LCU2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 15:28:14 -0500
Received: by mail-qa0-f74.google.com with SMTP id r4so15706qaq.1
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 12:28:13 -0800 (PST)
In-Reply-To: <20121203.135923.1359930693250099951.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I believe this commit from 2008 was incorrect:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=398bcbebb6f721ac308df1e3d658c0029bb74503

When CONFIG_IPV6_ROUTER_PREF is disabled, the kernel should follow
RFC4861 section 6.3.6: if no route is NUD_VALID, then traffic should be
sprayed across all routers (indirectly triggering NUD) until one of them
becomes NUD_VALID.

However, the following experiment demonstrates that this does not work:

1) Connect to an IPv6 network.
2) Change the router's MAC (and link-local) address.

The kernel will lock onto the first router and never try the new one, even
if the first becomes unreachable.  This patch fixes the problem by
allowing rt6_check_neigh() to return 0; if all routers return 0, then
rt6_select() will fall back to round-robin behavior.

This patch should have no effect when CONFIG_IPV6_ROUTER_PREF=y.

Note that rt6_check_neigh() is only used in a boolean context, so I've
changed its return type accordingly.

Signed-off-by: Paul Marks <pmarks@google.com>
---
Changelog since v1:
- Changed return type from 'int' to 'bool'.

 net/ipv6/route.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b1e6cf0..35f2815 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -487,35 +487,32 @@ static inline int rt6_check_dev(struct rt6_info *rt, int oif)
 	return 0;
 }
 
-static inline int rt6_check_neigh(struct rt6_info *rt)
+static inline bool rt6_check_neigh(struct rt6_info *rt)
 {
 	struct neighbour *neigh;
-	int m;
+	bool ret = false;
 
 	neigh = rt->n;
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
-		m = 1;
+		ret = true;
 	else if (neigh) {
 		read_lock_bh(&neigh->lock);
 		if (neigh->nud_state & NUD_VALID)
-			m = 2;
+			ret = true;
 #ifdef CONFIG_IPV6_ROUTER_PREF
-		else if (neigh->nud_state & NUD_FAILED)
-			m = 0;
+		else if (!(neigh->nud_state & NUD_FAILED))
+			ret = true;
 #endif
-		else
-			m = 1;
 		read_unlock_bh(&neigh->lock);
-	} else
-		m = 0;
-	return m;
+	}
+	return ret;
 }
 
 static int rt6_score_route(struct rt6_info *rt, int oif,
 			   int strict)
 {
-	int m, n;
+	int m;
 
 	m = rt6_check_dev(rt, oif);
 	if (!m && (strict & RT6_LOOKUP_F_IFACE))
@@ -523,8 +520,7 @@ static int rt6_score_route(struct rt6_info *rt, int oif,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	m |= IPV6_DECODE_PREF(IPV6_EXTRACT_PREF(rt->rt6i_flags)) << 2;
 #endif
-	n = rt6_check_neigh(rt);
-	if (!n && (strict & RT6_LOOKUP_F_REACHABLE))
+	if (!rt6_check_neigh(rt) && (strict & RT6_LOOKUP_F_REACHABLE))
 		return -1;
 	return m;
 }
-- 
1.7.7.3
