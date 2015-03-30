From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 2/3] ipv6: Extend the route lookups to low priority
 metrics.
Date: Mon, 30 Mar 2015 12:33:56 +0200
Message-ID: <20150330103355.GK3311@secunet.com>
References: <54CF3348.40207@huawei.com>
 <20150203092845.GT13046@secunet.com>
 <54D0A8DB.4010106@huawei.com>
 <20150203120140.GU13046@secunet.com>
 <54D17D1A.3020706@huawei.com>
 <20150205072125.GY13046@secunet.com>
 <54EFD87A.5080907@huawei.com>
 <20150330103210.GI3311@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<yangyingliang@huawei.com>, <hannes@redhat.com>
To: shengyong <shengyong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60248 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659AbbC3KeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 06:34:01 -0400
Content-Disposition: inline
In-Reply-To: <20150330103210.GI3311@secunet.com>
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
index 4318626..e4b24c8 100644
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
