From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6: match those routes that have different metirc
Date: Mon, 11 Nov 2013 11:00:53 +0800
Message-ID: <52804865.8090206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:7212 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751003Ab3KKDDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Nov 2013 22:03:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now the kernel only match those routes that have the same
metirc, so if those routes are non-reachable, then the packets
can't be sent out.

But according to the rfc 4191 section 3.2, if the best route
points to a non-reachable route, the next best route should be
consulted. So the kernel should not only match those routes that
have minimum metric, and should also match others.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/route.c | 17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7faa9d5..96cd22a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -629,7 +629,7 @@ static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
 	if (strict & RT6_LOOKUP_F_REACHABLE)
 		rt6_probe(rt);
 
-	if (m > *mpri) {
+	if (m > *mpri && (!match || rt->rt6i_metric == match->rt6i_metric)) {
 		*do_rr = match_do_rr;
 		*mpri = m;
 		match = rt;
@@ -639,19 +639,13 @@ out:
 }
 
 static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
-				     struct rt6_info *rr_head,
-				     u32 metric, int oif, int strict,
-				     bool *do_rr)
+				     int oif, int strict, bool *do_rr)
 {
 	struct rt6_info *rt, *match;
 	int mpri = -1;
 
 	match = NULL;
-	for (rt = rr_head; rt && rt->rt6i_metric == metric;
-	     rt = rt->dst.rt6_next)
-		match = find_match(rt, oif, strict, &mpri, match, do_rr);
-	for (rt = fn->leaf; rt && rt != rr_head && rt->rt6i_metric == metric;
-	     rt = rt->dst.rt6_next)
+	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next)
 		match = find_match(rt, oif, strict, &mpri, match, do_rr);
 
 	return match;
@@ -667,14 +661,13 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 	if (!rt0)
 		fn->rr_ptr = rt0 = fn->leaf;
 
-	match = find_rr_leaf(fn, rt0, rt0->rt6i_metric, oif, strict,
-			     &do_rr);
+	match = find_rr_leaf(fn, oif, strict, &do_rr);
 
 	if (do_rr) {
 		struct rt6_info *next = rt0->dst.rt6_next;
 
 		/* no entries matched; do round-robin */
-		if (!next || next->rt6i_metric != rt0->rt6i_metric)
+		if (!next)
 			next = fn->leaf;
 
 		if (next != rt0)
-- 
1.8.3.1
