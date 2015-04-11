From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 09/10] ipv6: Break up ip6_rt_copy()
Date: Fri, 10 Apr 2015 18:59:35 -0700
Message-ID: <1428717576-1040383-10-git-send-email-kafai@fb.com>
References: <1428717576-1040383-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:8448 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752702AbbDKB7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:59:51 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3B1xGHN008207
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:59:50 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1tpqk1gcgc-6
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:59:50 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 6dd38b7edfee11e486b70002c992ebde-7fcd32c0 for <netdev@vger.kernel.org>;	Fri,
 10 Apr 2015 18:59:46 -0700
In-Reply-To: <1428717576-1040383-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch breaks up ip6_rt_copy() into ip6_rt_copy_init() and
ip6_rt_cache_alloc().

In the later patch, we need to create a percpu rt6_info copy. Hence, refactor
the common rt6_info init codes to ip6_rt_copy_init().

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 76 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 44 insertions(+), 32 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 61ce45e..665e41c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -72,8 +72,11 @@ enum rt6_nud_state {
 	RT6_NUD_SUCCEED = 1
 };
 
-static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
-				    const struct in6_addr *dest);
+static void ip6_rt_copy_init(struct rt6_info *rt,
+			     struct rt6_info *ort,
+			     const struct in6_addr *dest);
+static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
+					   const struct in6_addr *dest);
 static struct dst_entry	*ip6_dst_check(struct dst_entry *dst, u32 cookie);
 static unsigned int	 ip6_default_advmss(const struct dst_entry *dst);
 static unsigned int	 ip6_mtu(const struct dst_entry *dst);
@@ -903,11 +906,9 @@ static struct rt6_info *ip6_pmtu_rt_cache_alloc(struct rt6_info *ort,
 	 *	Clone the route.
 	 */
 
-	rt = ip6_rt_copy(ort, daddr);
+	rt = ip6_rt_cache_alloc(ort, daddr);
 
 	if (rt) {
-		rt->rt6i_flags |= RTF_CACHE;
-
 		if (!(ort->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY))) {
 			if (ort->rt6i_dst.plen != 128 &&
 			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
@@ -1913,7 +1914,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 				     NEIGH_UPDATE_F_ISROUTER))
 		     );
 
-	nrt = ip6_rt_copy(rt, &msg->dest);
+	nrt = ip6_rt_cache_alloc(rt, &msg->dest);
 	if (!nrt)
 		goto out;
 
@@ -1945,39 +1946,50 @@ out:
  *	Misc support functions
  */
 
-static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
-				    const struct in6_addr *dest)
+static void ip6_rt_copy_init(struct rt6_info *rt,
+			     struct rt6_info *ort,
+			     const struct in6_addr *dest)
 {
-	struct net *net = dev_net(ort->dst.dev);
-	struct rt6_info *rt = ip6_dst_alloc(net, ort->dst.dev, 0,
-					    ort->rt6i_table);
-
-	if (rt) {
-		rt->dst.input = ort->dst.input;
-		rt->dst.output = ort->dst.output;
+	if (dest) {
 		rt->dst.flags |= DST_HOST;
-
 		rt->rt6i_dst.addr = *dest;
 		rt->rt6i_dst.plen = 128;
-		if (ort->dst.flags & DST_HOST)
-			dst_cow_metrics_generic(&rt->dst, rt->dst._metrics);
-		dst_copy_metrics(&rt->dst, &ort->dst);
-		rt->dst.error = ort->dst.error;
-		rt->rt6i_idev = ort->rt6i_idev;
-		if (rt->rt6i_idev)
-			in6_dev_hold(rt->rt6i_idev);
-		rt->dst.lastuse = jiffies;
-		rt->rt6i_gateway = ort->rt6i_gateway;
-		rt->rt6i_flags = ort->rt6i_flags;
-		rt6_set_from(rt, ort);
-		rt->rt6i_metric = 0;
+	} else {
+		memcpy(&rt->rt6i_dst, &ort->rt6i_dst, sizeof(rt->rt6i_dst));
+	}
 
+	rt->dst.input = ort->dst.input;
+	rt->dst.output = ort->dst.output;
+	rt->dst.error = ort->dst.error;
+	rt->rt6i_idev = ort->rt6i_idev;
+	if (rt->rt6i_idev)
+		in6_dev_hold(rt->rt6i_idev);
+	rt->dst.lastuse = jiffies;
+	rt->rt6i_gateway = ort->rt6i_gateway;
+	rt->rt6i_flags = ort->rt6i_flags;
+	rt->rt6i_metric = ort->rt6i_metric;
 #ifdef CONFIG_IPV6_SUBTREES
-		memcpy(&rt->rt6i_src, &ort->rt6i_src, sizeof(struct rt6key));
+	rt->rt6i_src = ort->rt6i_src;
 #endif
-		memcpy(&rt->rt6i_prefsrc, &ort->rt6i_prefsrc, sizeof(struct rt6key));
-		rt->rt6i_table = ort->rt6i_table;
-	}
+	rt->rt6i_prefsrc = ort->rt6i_prefsrc;
+	rt->rt6i_table = ort->rt6i_table;
+}
+
+static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
+					   const struct in6_addr *dest)
+{
+	struct rt6_info *rt = ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
+					    0, ort->rt6i_table);
+
+	if (!rt)
+		return NULL;
+	ip6_rt_copy_init(rt, ort, dest);
+	if (ort->dst.flags & DST_HOST)
+		dst_cow_metrics_generic(&rt->dst, rt->dst._metrics);
+	dst_copy_metrics(&rt->dst, &ort->dst);
+	rt->rt6i_flags |= RTF_CACHE;
+	rt6_set_from(rt, ort);
+	rt->rt6i_metric = 0;
 	return rt;
 }
 
-- 
1.8.1
