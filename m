From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 2/2] ipv6: Initialize rt6_info properly in ip6_blackhole_route()
Date: Thu, 15 Oct 2015 16:39:58 -0700
Message-ID: <1444952398-1505791-3-git-send-email-kafai@fb.com>
References: <1444952398-1505791-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>, Phil Sutter <phil@nwl.cc>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:12607 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752400AbbJOXkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 19:40:31 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t9FNdlFo010569
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 16:40:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1xg665re34-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 16:40:30 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1dded664739611e5b1cf0002c9dfb610-fd7fd230 for <netdev@vger.kernel.org>;	Thu,
 15 Oct 2015 16:40:28 -0700
In-Reply-To: <1444952398-1505791-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_blackhole_route() does not initialize the newly allocated
rt6_info properly.  This patch:
1. Call rt6_info_init() to initialize rt6i_siblings and rt6i_uncached

2. The current rt->dst._metrics init code is incorrect:
   - 'rt->dst._metrics = ort->dst._metris' is not always safe
   - Not sure what dst_copy_metrics() is trying to do here
     considering ip6_rt_blackhole_cow_metrics() always returns
     NULL

   Fix:
   - Always do dst_copy_metrics()
   - Replace ip6_rt_blackhole_cow_metrics() with
     dst_cow_metrics_generic()

3. Mask out the RTF_PCPU bit from the newly allocated blackhole route.
   This bug triggers an oops (reported by Phil Sutter) in rt6_get_cookie().
   It is because RTF_PCPU is set while rt->dst.from is NULL.

Fixes: d52d3997f843 ("ipv6: Create percpu rt6_info")
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reported-by: Phil Sutter <phil@nwl.cc>
Tested-by: Phil Sutter <phil@nwl.cc>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Phil Sutter <phil@nwl.cc>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/route.c | 20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4198017..968f31c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -248,12 +248,6 @@ static void ip6_rt_blackhole_redirect(struct dst_entry *dst, struct sock *sk,
 {
 }
 
-static u32 *ip6_rt_blackhole_cow_metrics(struct dst_entry *dst,
-					 unsigned long old)
-{
-	return NULL;
-}
-
 static struct dst_ops ip6_dst_blackhole_ops = {
 	.family			=	AF_INET6,
 	.destroy		=	ip6_dst_destroy,
@@ -262,7 +256,7 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 	.default_advmss		=	ip6_default_advmss,
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
 	.redirect		=	ip6_rt_blackhole_redirect,
-	.cow_metrics		=	ip6_rt_blackhole_cow_metrics,
+	.cow_metrics		=	dst_cow_metrics_generic,
 	.neigh_lookup		=	ip6_neigh_lookup,
 };
 
@@ -1219,24 +1213,20 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 
 	rt = dst_alloc(&ip6_dst_blackhole_ops, ort->dst.dev, 1, DST_OBSOLETE_NONE, 0);
 	if (rt) {
-		new = &rt->dst;
-
-		memset(new + 1, 0, sizeof(*rt) - sizeof(*new));
+		rt6_info_init(rt);
 
+		new = &rt->dst;
 		new->__use = 1;
 		new->input = dst_discard;
 		new->output = dst_discard_sk;
 
-		if (dst_metrics_read_only(&ort->dst))
-			new->_metrics = ort->dst._metrics;
-		else
-			dst_copy_metrics(new, &ort->dst);
+		dst_copy_metrics(new, &ort->dst);
 		rt->rt6i_idev = ort->rt6i_idev;
 		if (rt->rt6i_idev)
 			in6_dev_hold(rt->rt6i_idev);
 
 		rt->rt6i_gateway = ort->rt6i_gateway;
-		rt->rt6i_flags = ort->rt6i_flags;
+		rt->rt6i_flags = ort->rt6i_flags & ~RTF_PCPU;
 		rt->rt6i_metric = 0;
 
 		memcpy(&rt->rt6i_dst, &ort->rt6i_dst, sizeof(struct rt6key));
-- 
2.5.1
