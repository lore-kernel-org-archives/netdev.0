From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next v3 8/9] ipv6: Break up ip6_rt_copy()
Date: Fri, 1 May 2015 17:26:57 -0700
Message-ID: <1430526418-3132761-9-git-send-email-kafai@fb.com>
References: <1430526418-3132761-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:5194 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750778AbbEBA2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 20:28:22 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t420QfAZ014305
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 17:28:22 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u4djf8uf0-6
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 17:28:22 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 221900a4f06211e4a0660002c9521c9e-c52d11e0 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 17:28:19 -0700
In-Reply-To: <1430526418-3132761-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch breaks up ip6_rt_copy() into ip6_rt_copy_init() and
ip6_rt_cache_alloc().

In the later patch, we need to create a percpu rt6_info copy. Hence,
refactor the common rt6_info init codes to ip6_rt_copy_init().

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 net/ipv6/route.c | 90 ++++++++++++++++++++++++++------------------------------
 1 file changed, 41 insertions(+), 49 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3302e73..1d12207 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -72,8 +72,7 @@ enum rt6_nud_state {
 	RT6_NUD_SUCCEED = 1
 };
 
-static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
-				    const struct in6_addr *dest);
+static void ip6_rt_copy_init(struct rt6_info *rt, struct rt6_info *ort);
 static struct dst_entry	*ip6_dst_check(struct dst_entry *dst, u32 cookie);
 static unsigned int	 ip6_default_advmss(const struct dst_entry *dst);
 static unsigned int	 ip6_mtu(const struct dst_entry *dst);
@@ -848,22 +847,32 @@ static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
 	 *	Clone the route.
 	 */
 
-	rt = ip6_rt_copy(ort, daddr);
+	if (ort->rt6i_flags & RTF_CACHE)
+		ort = (struct rt6_info *)ort->dst.from;
 
-	if (rt) {
-		rt->rt6i_flags |= RTF_CACHE;
+	rt = ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
+			   0, ort->rt6i_table);
+
+	if (!rt)
+		return NULL;
+
+	ip6_rt_copy_init(rt, ort);
+	rt->rt6i_flags |= RTF_CACHE;
+	rt->rt6i_metric = 0;
+	rt->dst.flags |= DST_HOST;
+	rt->rt6i_dst.addr = *daddr;
+	rt->rt6i_dst.plen = 128;
 
-		if (!rt6_is_gw_or_nonexthop(ort)) {
-			if (ort->rt6i_dst.plen != 128 &&
-			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
-				rt->rt6i_flags |= RTF_ANYCAST;
+	if (!rt6_is_gw_or_nonexthop(ort)) {
+		if (ort->rt6i_dst.plen != 128 &&
+		    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
+			rt->rt6i_flags |= RTF_ANYCAST;
 #ifdef CONFIG_IPV6_SUBTREES
-			if (rt->rt6i_src.plen && saddr) {
-				rt->rt6i_src.addr = *saddr;
-				rt->rt6i_src.plen = 128;
-			}
-#endif
+		if (rt->rt6i_src.plen && saddr) {
+			rt->rt6i_src.addr = *saddr;
+			rt->rt6i_src.plen = 128;
 		}
+#endif
 	}
 
 	return rt;
@@ -1906,7 +1915,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 				     NEIGH_UPDATE_F_ISROUTER))
 		     );
 
-	nrt = ip6_rt_copy(rt, &msg->dest);
+	nrt = ip6_rt_cache_alloc(rt, &msg->dest, NULL);
 	if (!nrt)
 		goto out;
 
@@ -1948,42 +1957,25 @@ static void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
 	dst_init_metrics(&rt->dst, dst_metrics_ptr(&from->dst), true);
 }
 
-static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
-				    const struct in6_addr *dest)
-{
-	struct net *net = dev_net(ort->dst.dev);
-	struct rt6_info *rt;
-
-	if (ort->rt6i_flags & RTF_CACHE)
-		ort = (struct rt6_info *)ort->dst.from;
-
-	rt = ip6_dst_alloc(net, ort->dst.dev, 0,
-			   ort->rt6i_table);
-
-	if (rt) {
-		rt->dst.input = ort->dst.input;
-		rt->dst.output = ort->dst.output;
-		rt->dst.flags |= DST_HOST;
-
-		rt->rt6i_dst.addr = *dest;
-		rt->rt6i_dst.plen = 128;
-		rt->dst.error = ort->dst.error;
-		rt->rt6i_idev = ort->rt6i_idev;
-		if (rt->rt6i_idev)
-			in6_dev_hold(rt->rt6i_idev);
-		rt->dst.lastuse = jiffies;
-		rt->rt6i_gateway = ort->rt6i_gateway;
-		rt->rt6i_flags = ort->rt6i_flags;
-		rt6_set_from(rt, ort);
-		rt->rt6i_metric = 0;
-
+static void ip6_rt_copy_init(struct rt6_info *rt, struct rt6_info *ort)
+{
+	rt->dst.input = ort->dst.input;
+	rt->dst.output = ort->dst.output;
+	rt->rt6i_dst = ort->rt6i_dst;
+	rt->dst.error = ort->dst.error;
+	rt->rt6i_idev = ort->rt6i_idev;
+	if (rt->rt6i_idev)
+		in6_dev_hold(rt->rt6i_idev);
+	rt->dst.lastuse = jiffies;
+	rt->rt6i_gateway = ort->rt6i_gateway;
+	rt->rt6i_flags = ort->rt6i_flags;
+	rt6_set_from(rt, ort);
+	rt->rt6i_metric = ort->rt6i_metric;
 #ifdef CONFIG_IPV6_SUBTREES
-		memcpy(&rt->rt6i_src, &ort->rt6i_src, sizeof(struct rt6key));
+	rt->rt6i_src = ort->rt6i_src;
 #endif
-		memcpy(&rt->rt6i_prefsrc, &ort->rt6i_prefsrc, sizeof(struct rt6key));
-		rt->rt6i_table = ort->rt6i_table;
-	}
-	return rt;
+	rt->rt6i_prefsrc = ort->rt6i_prefsrc;
+	rt->rt6i_table = ort->rt6i_table;
 }
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
-- 
1.8.1
