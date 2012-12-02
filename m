From: Paul Marks <pmarks@google.com>
Subject: [PATCH] ipv6: Fix default route failover when CONFIG_IPV6_ROUTER_PREF=n
Date: Sun,  2 Dec 2012 02:00:21 -0800
Message-ID: <1354442421-689-1-git-send-email-pmarks@google.com>
Cc: netdev@vger.kernel.org, Paul Marks <pmarks@google.com>
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:34471 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560Ab2LBKAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 05:00:52 -0500
Received: by mail-vb0-f74.google.com with SMTP id s24so119655vbi.1
        for <netdev@vger.kernel.org>; Sun, 02 Dec 2012 02:00:52 -0800 (PST)
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

Note that rt6_check_neigh() is only used in a boolean context, so the
presence of both "m = 1" and "m = 2" was irrelevant and confusing.

Signed-off-by: Paul Marks <pmarks@google.com>
---
 net/ipv6/route.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b1e6cf0..60b2995 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -490,7 +490,7 @@ static inline int rt6_check_dev(struct rt6_info *rt, int oif)
 static inline int rt6_check_neigh(struct rt6_info *rt)
 {
 	struct neighbour *neigh;
-	int m;
+	int m = 0;
 
 	neigh = rt->n;
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
@@ -499,16 +499,13 @@ static inline int rt6_check_neigh(struct rt6_info *rt)
 	else if (neigh) {
 		read_lock_bh(&neigh->lock);
 		if (neigh->nud_state & NUD_VALID)
-			m = 2;
+			m = 1;
 #ifdef CONFIG_IPV6_ROUTER_PREF
-		else if (neigh->nud_state & NUD_FAILED)
-			m = 0;
-#endif
-		else
+		else if (!(neigh->nud_state & NUD_FAILED))
 			m = 1;
+#endif
 		read_unlock_bh(&neigh->lock);
-	} else
-		m = 0;
+	}
 	return m;
 }
 
-- 
1.7.7.3
