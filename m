From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 2/2] ipv6: Extend the route lookups to low priority
 metrics.
Date: Wed, 28 Jan 2015 13:12:57 +0100
Message-ID: <20150128121256.GO13046@secunet.com>
References: <54C78B8D.1070104@huawei.com>
 <20150128121026.GM13046@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55849 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933864AbbA1UlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jan 2015 15:41:20 -0500
Content-Disposition: inline
In-Reply-To: <20150128121026.GM13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We search only for routes with highest prioriy metric in
find_rr_leaf(). However if one of these routes is marked
as invalid, we may fail to find a route even if there is
a appropriate route with lower priority. Then we loose
connectivity until the garbage collector deletes the
invalid route. This typically happens if a host route
expires afer a pmtu event. Fix this by searching also
for routes with a lower priority metric.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/route.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3e864e7..ce354c9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -654,15 +654,33 @@ static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
 				     u32 metric, int oif, int strict,
 				     bool *do_rr)
 {
-	struct rt6_info *rt, *match;
+	struct rt6_info *rt, *match, *cont;
 	int mpri = -1;
 
 	match = NULL;
-	for (rt = rr_head; rt && rt->rt6i_metric == metric;
-	     rt = rt->dst.rt6_next)
+	cont = NULL;
+	for (rt = rr_head; rt; rt = rt->dst.rt6_next) {
+		if (rt->rt6i_metric != metric) {
+			cont = rt;
+			break;
+		}
+
+		match = find_match(rt, oif, strict, &mpri, match, do_rr);
+	}
+
+	for (rt = fn->leaf; rt && rt != rr_head; rt = rt->dst.rt6_next) {
+		if (rt->rt6i_metric != metric) {
+			cont = rt;
+			break;
+		}
+
 		match = find_match(rt, oif, strict, &mpri, match, do_rr);
-	for (rt = fn->leaf; rt && rt != rr_head && rt->rt6i_metric == metric;
-	     rt = rt->dst.rt6_next)
+	}
+
+	if (match || !cont)
+		return match;
+
+	for (rt = cont; rt; rt = rt->dst.rt6_next)
 		match = find_match(rt, oif, strict, &mpri, match, do_rr);
 
 	return match;
-- 
1.9.1
