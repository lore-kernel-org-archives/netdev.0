From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/3] ipv6, route: remove BACKTRACK() macro
Date: Mon, 10 Sep 2012 20:48:45 +0800
Message-ID: <1347281326-26890-2-git-send-email-amwang@redhat.com>
References: <1347281326-26890-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40967 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757880Ab2IJMs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 08:48:56 -0400
In-Reply-To: <1347281326-26890-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't save any code, nor it helps readability.

Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/route.c |   48 ++++++++++++++++++++++++++++--------------------
 1 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b130bf2..71267e9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -675,24 +675,6 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 }
 #endif
 
-#define BACKTRACK(__net, saddr)			\
-do { \
-	if (rt == __net->ipv6.ip6_null_entry) {	\
-		struct fib6_node *pn; \
-		while (1) { \
-			if (fn->fn_flags & RTN_TL_ROOT) \
-				goto out; \
-			pn = fn->parent; \
-			if (FIB6_SUBTREE(pn) && FIB6_SUBTREE(pn) != fn) \
-				fn = fib6_lookup(FIB6_SUBTREE(pn), NULL, saddr); \
-			else \
-				fn = pn; \
-			if (fn->fn_flags & RTN_RTINFO) \
-				goto restart; \
-		} \
-	} \
-} while (0)
-
 static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 					     struct fib6_table *table,
 					     struct flowi6 *fl6, int flags)
@@ -705,7 +687,20 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 restart:
 	rt = fn->leaf;
 	rt = rt6_device_match(net, rt, &fl6->saddr, fl6->flowi6_oif, flags);
-	BACKTRACK(net, &fl6->saddr);
+	if (rt == net->ipv6.ip6_null_entry) {
+		struct fib6_node *pn;
+		while (1) {
+			if (fn->fn_flags & RTN_TL_ROOT)
+				goto out;
+			pn = fn->parent;
+			if (FIB6_SUBTREE(pn) && FIB6_SUBTREE(pn) != fn)
+				fn = fib6_lookup(FIB6_SUBTREE(pn), NULL, &fl6->saddr);
+			else
+				fn = pn;
+			if (fn->fn_flags & RTN_RTINFO)
+				goto restart;
+		}
+	}
 out:
 	dst_use(&rt->dst, jiffies);
 	read_unlock_bh(&table->tb6_lock);
@@ -867,7 +862,20 @@ restart_2:
 restart:
 	rt = rt6_select(fn, oif, strict | reachable);
 
-	BACKTRACK(net, &fl6->saddr);
+	if (rt == net->ipv6.ip6_null_entry) {
+		struct fib6_node *pn;
+		while (1) {
+			if (fn->fn_flags & RTN_TL_ROOT)
+				goto out;
+			pn = fn->parent;
+			if (FIB6_SUBTREE(pn) && FIB6_SUBTREE(pn) != fn)
+				fn = fib6_lookup(FIB6_SUBTREE(pn), NULL, &fl6->saddr);
+			else
+				fn = pn;
+			if (fn->fn_flags & RTN_RTINFO)
+				goto restart;
+		}
+	}
 	if (rt == net->ipv6.ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
 		goto out;
-- 
1.7.7.6
