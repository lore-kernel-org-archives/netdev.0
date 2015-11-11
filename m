From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 2/3] ipv6: Check expire on DST_NOCACHE route
Date: Wed, 11 Nov 2015 11:51:07 -0800
Message-ID: <1447271468-3930566-3-git-send-email-kafai@fb.com>
References: <1447271468-3930566-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41750 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752528AbbKKTvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 14:51:32 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tABJlAxN003014
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 11:51:32 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1y1duhgmym-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 11:51:32 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 9309821e88ad11e5954624be0595f910-14df8230 for <netdev@vger.kernel.org>;	Wed,
 11 Nov 2015 11:51:18 -0800
In-Reply-To: <1447271468-3930566-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the expires of the DST_NOCACHE rt can be set during
the ip6_rt_update_pmtu(), we also need to consider the expires
value when doing ip6_dst_check().

This patches creates __rt6_check_expired() to only
check the expire value (if one exists) of the current rt.

In rt6_dst_from_check(), it adds __rt6_check_expired() as
one of the condition check.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 74907c5..3754cf9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -404,6 +404,14 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	}
 }
 
+static bool __rt6_check_expired(const struct rt6_info *rt)
+{
+	if (rt->rt6i_flags & RTF_EXPIRES)
+		return time_after(jiffies, rt->dst.expires);
+	else
+		return false;
+}
+
 static bool rt6_check_expired(const struct rt6_info *rt)
 {
 	if (rt->rt6i_flags & RTF_EXPIRES) {
@@ -1252,7 +1260,8 @@ static struct dst_entry *rt6_check(struct rt6_info *rt, u32 cookie)
 
 static struct dst_entry *rt6_dst_from_check(struct rt6_info *rt, u32 cookie)
 {
-	if (rt->dst.obsolete == DST_OBSOLETE_FORCE_CHK &&
+	if (!__rt6_check_expired(rt) &&
+	    rt->dst.obsolete == DST_OBSOLETE_FORCE_CHK &&
 	    rt6_check((struct rt6_info *)(rt->dst.from), cookie))
 		return &rt->dst;
 	else
-- 
2.5.1
