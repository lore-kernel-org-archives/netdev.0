From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Wed, 7 Aug 2013 02:34:31 +0200
Message-ID: <20130807003431.GD16410@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: teco@inf-net.nl, yoshfuji@linux-ipv6.org, equinox@diac24.net,
	boutier@pps.univ-paris-diderot.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35830 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756323Ab3HGAec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 20:34:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case a subtree did not match we currently stop backtracking and return
NULL (root table from fib_lookup). This could yield in invalid routing
table lookups when using subtrees.

Instead continue to backtrack until a valid subtree or node is found
and return this match.

Also remove unneeded NULL check.

Reported-by: Teco Boot <teco@inf-net.nl>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: David Lamparter <equinox@diac24.net>
Cc: <boutier@pps.univ-paris-diderot.fr>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index ed828d6..73db48e 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -993,14 +993,22 @@ static struct fib6_node * fib6_lookup_1(struct fib6_node *root,
 
 			if (ipv6_prefix_equal(&key->addr, args->addr, key->plen)) {
 #ifdef CONFIG_IPV6_SUBTREES
-				if (fn->subtree)
-					fn = fib6_lookup_1(fn->subtree, args + 1);
+				if (fn->subtree) {
+					struct fib6_node *sfn;
+					sfn = fib6_lookup_1(fn->subtree,
+							    args + 1);
+					if (!sfn)
+						goto backtrack;
+					fn = sfn;
+				}
 #endif
-				if (!fn || fn->fn_flags & RTN_RTINFO)
+				if (fn->fn_flags & RTN_RTINFO)
 					return fn;
 			}
 		}
-
+#ifdef CONFIG_IPV6_SUBTREES
+backtrack:
+#endif
 		if (fn->fn_flags & RTN_ROOT)
 			break;
 
-- 
1.8.3.1
