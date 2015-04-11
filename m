From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH 03/10] ipv6: Combine rt6_alloc_cow and rt6_alloc_clone
Date: Fri, 10 Apr 2015 18:54:06 -0700
Message-ID: <1428717253-1006248-4-git-send-email-kafai@fb.com>
References: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:27566 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754290AbbDKByd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:54:33 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3B1sEVZ012623
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:54:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1tpqvkrc82-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:54:32 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 b1021c2cdfed11e4b8c00002c991e86a-eb7d32c0 for <netdev@vger.kernel.org>;	Fri,
 10 Apr 2015 18:54:29 -0700
In-Reply-To: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A prep work for creating RTF_CACHE on exception only.  After this
patch, the same condition (rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY))
is checked twice. This redundancy will be removed in the later patch.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 40 +++++++++++++++-------------------------
 1 file changed, 15 insertions(+), 25 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0ccb8ec..f753a67 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -872,9 +872,9 @@ int ip6_ins_rt(struct rt6_info *rt)
 	return __ip6_ins_rt(rt, &info, &mxc);
 }
 
-static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
-				      const struct in6_addr *daddr,
-				      const struct in6_addr *saddr)
+static struct rt6_info *ip6_pmtu_rt_cache_alloc(struct rt6_info *ort,
+						const struct in6_addr *daddr,
+						const struct in6_addr *saddr)
 {
 	struct rt6_info *rt;
 
@@ -885,33 +885,24 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
 	rt = ip6_rt_copy(ort, daddr);
 
 	if (rt) {
-		if (ort->rt6i_dst.plen != 128 &&
-		    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
-			rt->rt6i_flags |= RTF_ANYCAST;
-
 		rt->rt6i_flags |= RTF_CACHE;
 
+		if (!(ort->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY))) {
+			if (ort->rt6i_dst.plen != 128 &&
+			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
+				rt->rt6i_flags |= RTF_ANYCAST;
 #ifdef CONFIG_IPV6_SUBTREES
-		if (rt->rt6i_src.plen && saddr) {
-			rt->rt6i_src.addr = *saddr;
-			rt->rt6i_src.plen = 128;
-		}
+			if (rt->rt6i_src.plen && saddr) {
+				rt->rt6i_src.addr = *saddr;
+				rt->rt6i_src.plen = 128;
+			}
 #endif
+		}
 	}
 
 	return rt;
 }
 
-static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
-					const struct in6_addr *daddr)
-{
-	struct rt6_info *rt = ip6_rt_copy(ort, daddr);
-
-	if (rt)
-		rt->rt6i_flags |= RTF_CACHE;
-	return rt;
-}
-
 static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table, int oif,
 				      struct flowi6 *fl6, int flags)
 {
@@ -957,10 +948,9 @@ redo_rt6_select:
 	if (rt->rt6i_flags & RTF_CACHE)
 		goto out2;
 
-	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
-		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
-	else if (!(rt->dst.flags & DST_HOST))
-		nrt = rt6_alloc_clone(rt, &fl6->daddr);
+	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)) ||
+	    !(rt->dst.flags & DST_HOST))
+		nrt = ip6_pmtu_rt_cache_alloc(rt, &fl6->daddr, &fl6->saddr);
 	else
 		goto out2;
 
-- 
1.8.1
