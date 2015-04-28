From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 3/5] ipv6: Stop /128 route from disappearing after pmtu update
Date: Tue, 28 Apr 2015 13:03:05 -0700
Message-ID: <1430251387-2942539-4-git-send-email-kafai@fb.com>
References: <1430251387-2942539-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Yang Yingliang <yangyingliang@huawei.com>,
	shengyong <shengyong1@huawei.com>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:32593 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1031053AbbD1UDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 16:03:30 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3SK3UV3001071
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:03:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u2fw6r7n5-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:03:30 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 a0f3939aede111e4b3dc0002c9521c9e-aba42c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 13:03:25 -0700
In-Reply-To: <1430251387-2942539-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is mostly from Steffen Klassert <steffen.klassert@secunet.com>.
I only removed the (rt6->rt6i_dst.plen == 128) check from
ip6_rt_update_pmtu() because the (rt6->rt6i_flags & RTF_CACHE) test
has already implied it.

This patch:
1. Create RTF_CACHE route for /128 non local route
2. After (1), all routes that allow pmtu update should have a RTF_CACHE
   clone.  Hence, stop updating MTU for any non RTF_CACHE route.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 07562a2..aa4cfdd 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -977,7 +977,7 @@ redo_rt6_select:
 
 	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
-	else if (!(rt->dst.flags & DST_HOST))
+	else if (!(rt->dst.flags & DST_HOST) || !(rt->dst.flags & RTF_LOCAL))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
 	else
 		goto out2;
@@ -1172,7 +1172,7 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 	struct rt6_info *rt6 = (struct rt6_info *)dst;
 
 	dst_confirm(dst);
-	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
+	if (mtu < dst_mtu(dst) && (rt6->rt6i_flags & RTF_CACHE)) {
 		struct net *net = dev_net(dst->dev);
 
 		rt6->rt6i_flags |= RTF_MODIFIED;
-- 
1.8.1
