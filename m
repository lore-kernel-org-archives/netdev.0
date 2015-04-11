From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 05/10] ipv6: Allow pmtu update on /128 via gateway route
Date: Fri, 10 Apr 2015 18:59:31 -0700
Message-ID: <1428717576-1040383-6-git-send-email-kafai@fb.com>
References: <1428717576-1040383-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41979 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755102AbbDKB7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:59:49 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3B1xjnx009255
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:59:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1tpqk1gcgf-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:59:49 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 6d8d5c62dfee11e486b70002c992ebde-7fcd32c0 for <netdev@vger.kernel.org>;	Fri,
 10 Apr 2015 18:59:46 -0700
In-Reply-To: <1428717576-1040383-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider there is a permanent /128 via gateway route (DST_HOST) in
the route table.  When there is a pmtu update, the pmtu DST_HOST route is
updated and the RTF_EXPIRES is set.  The permanent DST_HOST route will be
removed after expiration.

Since we are at it, the patch is trying to simplify some checking cases in
ip6_rt_update_pmtu().

1. !(rt6->rt6i_flags & RTF_CACHE) is used to decide when
a RTF_CACHE route needs to be created for pmtu update.

2. Remove the rt6->rt6i_dst.plen == 128 check since RTF_CACHE route will
be created (if it is needed) before updating the mtu.

3. Add a check to ensure no pmtu update on RTF_LOCAL route

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1b57bc9..75f3b5d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1105,15 +1105,17 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 			       struct sk_buff *skb, u32 mtu)
 {
 	struct rt6_info *rt6 = (struct rt6_info *)dst;
+	struct net *net;
+
+	if (rt6->rt6i_flags & RTF_LOCAL)
+		return;
 
 	dst_confirm(dst);
 	mtu = max_t(u32, mtu, IPV6_MIN_MTU);
 	if (mtu >= dst_mtu(dst))
 		return;
 
-	if (!(rt6->rt6i_flags & RTF_CACHE) &&
-	    (!(rt6->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)) ||
-	     !(rt6->dst.flags & DST_HOST))) {
+	if (!(rt6->rt6i_flags & RTF_CACHE)) {
 		const struct in6_addr *daddr, *saddr;
 		struct rt6_info *nrt6;
 
@@ -1146,13 +1148,10 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 		rt6 = (struct rt6_info *)dst;
 	}
 
-	if (rt6->rt6i_dst.plen == 128) {
-		struct net *net = dev_net(dst->dev);
-
-		rt6->rt6i_flags |= RTF_MODIFIED;
-		dst_metric_set(dst, RTAX_MTU, mtu);
-		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
-	}
+	net = dev_net(rt6->dst.dev);
+	rt6->rt6i_flags |= RTF_MODIFIED;
+	dst_metric_set(dst, RTAX_MTU, mtu);
+	rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
 }
 
 void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
-- 
1.8.1
