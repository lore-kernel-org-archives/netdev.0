From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH 08/10] ipv6: Do not use inetpeer when creating RTF_CACHE route for /128 via gateway entry
Date: Fri, 10 Apr 2015 18:54:11 -0700
Message-ID: <1428717253-1006248-9-git-send-email-kafai@fb.com>
References: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:4295 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755211AbbDKByd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:54:33 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3B1sDm7002406
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:54:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1tpqk1gc7u-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:54:33 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 b193eea4dfed11e48f800002c991e86a-ea7d12c0 for <netdev@vger.kernel.org>;	Fri,
 10 Apr 2015 18:54:30 -0700
In-Reply-To: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is a pmtu exception on /128 via gateway route, we need to
create a separate metrics copy for the newly created RTF_CACHE route instead
of reusing the inetpeer cache.  Otherwise, the original mtu will be
over-written and the mtu update will stay after the expiration.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 91c80bc..61ce45e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -322,8 +322,16 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	struct rt6_info *rt = (struct rt6_info *)dst;
 	struct inet6_dev *idev = rt->rt6i_idev;
 	struct dst_entry *from = dst->from;
+	unsigned long peer_metrics = 0;
 
-	if (!(rt->dst.flags & DST_HOST))
+	if (rt6_has_peer(rt)) {
+		struct inet_peer *peer = rt6_peer_ptr(rt);
+
+		peer_metrics = (unsigned long)peer->metrics;
+		inet_putpeer(peer);
+	}
+
+	if (peer_metrics != dst->_metrics)
 		dst_destroy_metrics_generic(dst);
 
 	if (idev) {
@@ -333,11 +341,6 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 
 	dst->from = NULL;
 	dst_release(from);
-
-	if (rt6_has_peer(rt)) {
-		struct inet_peer *peer = rt6_peer_ptr(rt);
-		inet_putpeer(peer);
-	}
 }
 
 static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
@@ -1956,6 +1959,8 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 
 		rt->rt6i_dst.addr = *dest;
 		rt->rt6i_dst.plen = 128;
+		if (ort->dst.flags & DST_HOST)
+			dst_cow_metrics_generic(&rt->dst, rt->dst._metrics);
 		dst_copy_metrics(&rt->dst, &ort->dst);
 		rt->dst.error = ort->dst.error;
 		rt->rt6i_idev = ort->rt6i_idev;
-- 
1.8.1
