From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 07/10] ipv6: Extend the route lookups to low priority metrics.
Date: Fri, 10 Apr 2015 18:59:33 -0700
Message-ID: <1428717576-1040383-8-git-send-email-kafai@fb.com>
References: <1428717576-1040383-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:17333 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754897AbbDKB7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:59:49 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3B1xdON009232
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:59:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1tpqk1gcge-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:59:49 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 6da4f502dfee11e4a18f0002c991e86a-e8fce2c0 for <netdev@vger.kernel.org>;	Fri,
 10 Apr 2015 18:59:46 -0700
In-Reply-To: <1428717576-1040383-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>

We search only for routes with highest priority metric in
find_rr_leaf(). However if one of these routes is marked
as invalid, we may fail to find a route even if there is
a appropriate route with lower priority. Then we loose
connectivity until the garbage collector deletes the
invalid route. This typically happens if a host route
expires afer a pmtu event. Fix this by searching also
for routes with a lower priority metric.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5d0fd6c..91c80bc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -652,15 +652,33 @@ static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
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
1.8.1
