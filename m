From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 3/3] ipv6: Check rt->dst.from for the DST_NOCACHE route
Date: Wed, 11 Nov 2015 11:51:08 -0800
Message-ID: <1447271468-3930566-4-git-send-email-kafai@fb.com>
References: <1447271468-3930566-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54865 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752591AbbKKTvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 14:51:20 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tABJmgDc010713
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 11:51:19 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y43bvj98w-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 11:51:19 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 9315b50288ad11e5a2e80002c991e86a-a87f5230 for <netdev@vger.kernel.org>;	Wed,
 11 Nov 2015 11:51:18 -0800
In-Reply-To: <1447271468-3930566-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All DST_NOCACHE rt6_info used to have rt->dst.from set to
its parent.

After commit 8e3d5be73681 ("ipv6: Avoid double dst_free"),
DST_NOCACHE is also set to rt6_info which does not have
a parent (i.e. rt->dst.from is NULL).

This patch catches the rt->dst.from == NULL case.

Fixes: 8e3d5be73681 ("ipv6: Avoid double dst_free")
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_fib.h | 3 ++-
 net/ipv6/route.c      | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index aaf9700..fb961a5 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -167,7 +167,8 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
 
 static inline u32 rt6_get_cookie(const struct rt6_info *rt)
 {
-	if (rt->rt6i_flags & RTF_PCPU || unlikely(rt->dst.flags & DST_NOCACHE))
+	if (rt->rt6i_flags & RTF_PCPU ||
+	    (unlikely(rt->dst.flags & DST_NOCACHE) && rt->dst.from))
 		rt = (struct rt6_info *)(rt->dst.from);
 
 	return rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3754cf9..6f01fe1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1281,7 +1281,8 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 
 	rt6_dst_from_metrics_check(rt);
 
-	if ((rt->rt6i_flags & RTF_PCPU) || unlikely(dst->flags & DST_NOCACHE))
+	if (rt->rt6i_flags & RTF_PCPU ||
+	    (unlikely(dst->flags & DST_NOCACHE) && rt->dst.from))
 		return rt6_dst_from_check(rt, cookie);
 	else
 		return rt6_check(rt, cookie);
-- 
2.5.1
