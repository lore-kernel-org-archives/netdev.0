From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 5/6] ipv6: Break up ip6_rt_copy()
Date: Tue, 28 Apr 2015 14:07:52 -0700
Message-ID: <1430255273-3045254-6-git-send-email-kafai@fb.com>
References: <1430255273-3045254-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44235 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030931AbbD1VJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 17:09:01 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3SL8vIE012222
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 14:09:01 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u2fn7ggcv-6
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 14:09:01 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 ae2aca3eedea11e4b0880002c9521c9e-1ffdd2c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 14:08:13 -0700
In-Reply-To: <1430255273-3045254-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch breaks up ip6_rt_copy() into ip6_rt_copy_init() and
ip6_rt_cache_alloc().

In the later patch, we need to create a percpu rt6_info copy. Hence,
refactor the common rt6_info init codes to ip6_rt_copy_init().

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/route.c | 80 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 46 insertions(+), 34 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 09ab0f4..cb3c585 100644
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
@@ -848,11 +851,9 @@ static struct rt6_info *ip6_pmtu_rt_cache_alloc(struct rt6_info *ort,
 	 *	Clone the route.
 	 */
 
-	rt = ip6_rt_copy(ort, daddr);
+	rt = ip6_rt_cache_alloc(ort, daddr);
 
 	if (rt) {
-		rt->rt6i_flags |= RTF_CACHE;
-
 		if (!rt6_is_gw_or_nonexthop(ort)) {
 			if (ort->rt6i_dst.plen != 128 &&
 			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
@@ -1865,7 +1866,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 				     NEIGH_UPDATE_F_ISROUTER))
 		     );
 
-	nrt = ip6_rt_copy(rt, &msg->dest);
+	nrt = ip6_rt_cache_alloc(rt, &msg->dest);
 	if (!nrt)
 		goto out;
 
@@ -1907,41 +1908,52 @@ static void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
 	dst_init_metrics(&rt->dst, dst_metrics_ptr(&from->dst), true);
 }
 
-static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
-				    const struct in6_addr *dest)
+static void ip6_rt_copy_init(struct rt6_info *rt,
+			     struct rt6_info *ort,
+			     const struct in6_addr *dest)
 {
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
+	if (dest) {
 		rt->dst.flags |= DST_HOST;
-
 		rt->rt6i_dst.addr = *dest;
 		rt->rt6i_dst.plen = 128;
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
+		rt->rt6i_dst = ort->rt6i_dst;
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
+	rt6_set_from(rt, ort);
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
+	struct rt6_info *rt;
+
+	if (ort->rt6i_flags & RTF_CACHE)
+		ort = (struct rt6_info *)ort->dst.from;
+
+	rt = ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
+			   0, ort->rt6i_table);
+
+	if (!rt)
+		return NULL;
+	ip6_rt_copy_init(rt, ort, dest);
+	rt->rt6i_flags |= RTF_CACHE;
+	rt->rt6i_metric = 0;
 	return rt;
 }
 
-- 
1.8.1
