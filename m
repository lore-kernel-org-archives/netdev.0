From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v4 03/10] ipv6: Combine rt6_alloc_cow and rt6_alloc_clone
Date: Wed, 20 May 2015 15:52:22 -0700
Message-ID: <1432162349-788789-4-git-send-email-kafai@fb.com>
References: <1432162349-788789-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:7142 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753335AbbETWxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 18:53:16 -0400
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id t4KMq0eF000834
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 15:53:16 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004347.ppops.net with ESMTP id 1uh2bg83nq-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 15:53:16 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 ffa0bedcff4211e480c40002c991e86a-75fda3a0 for <netdev@vger.kernel.org>;	Wed,
 20 May 2015 15:53:15 -0700
In-Reply-To: <1432162349-788789-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A prep work for creating RTF_CACHE on exception only.  After this
patch, the same condition (rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY))
is checked twice. This redundancy will be removed in the later patch.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 net/ipv6/route.c | 45 ++++++++++++++++++++-------------------------
 1 file changed, 20 insertions(+), 25 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 978e94e..c820308 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -655,6 +655,11 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 	return match ? match : net->ipv6.ip6_null_entry;
 }
 
+static bool rt6_is_gw_or_nonexthop(const struct rt6_info *rt)
+{
+	return (rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY));
+}
+
 #ifdef CONFIG_IPV6_ROUTE_INFO
 int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		  const struct in6_addr *gwaddr)
@@ -833,9 +838,9 @@ int ip6_ins_rt(struct rt6_info *rt)
 	return __ip6_ins_rt(rt, &info, &mxc);
 }
 
-static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
-				      const struct in6_addr *daddr,
-				      const struct in6_addr *saddr)
+static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
+					   const struct in6_addr *daddr,
+					   const struct in6_addr *saddr)
 {
 	struct rt6_info *rt;
 
@@ -846,33 +851,24 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
 	rt = ip6_rt_copy(ort, daddr);
 
 	if (rt) {
-		if (ort->rt6i_dst.plen != 128 &&
-		    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
-			rt->rt6i_flags |= RTF_ANYCAST;
-
 		rt->rt6i_flags |= RTF_CACHE;
 
+		if (!rt6_is_gw_or_nonexthop(ort)) {
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
@@ -918,10 +914,9 @@ redo_rt6_select:
 	if (rt->rt6i_flags & RTF_CACHE)
 		goto out2;
 
-	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
-		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
-	else if (!(rt->dst.flags & DST_HOST) || !(rt->rt6i_flags & RTF_LOCAL))
-		nrt = rt6_alloc_clone(rt, &fl6->daddr);
+	if (!rt6_is_gw_or_nonexthop(rt) ||
+	    !(rt->dst.flags & DST_HOST) || !(rt->rt6i_flags & RTF_LOCAL))
+		nrt = ip6_rt_cache_alloc(rt, &fl6->daddr, &fl6->saddr);
 	else
 		goto out2;
 
-- 
1.8.1
