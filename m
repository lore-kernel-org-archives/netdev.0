From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v4 net 2/3] ipv6: Avoid redoing fib6_lookup() for RTF_CACHE hit case
Date: Fri, 10 Oct 2014 11:48:07 -0700
Message-ID: <1412966888-31384-3-git-send-email-kafai@fb.com>
References: <1412966888-31384-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:13040 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751665AbaJJSsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 14:48:16 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s9AIliQt020048
	for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 11:48:15 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1pxfaf1dgc-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 11:48:15 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 fd89015250ad11e48f4a0002c99293a0-84bfd3e0 for <netdev@vger.kernel.org>;	Fri,
 10 Oct 2014 11:48:14 -0700
In-Reply-To: <1412966888-31384-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is a RTF_CACHE hit, no need to redo fib6_lookup()
with reachable=0.

Cc: David Miller <davem@davemloft.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/route.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 797a6e7..5469ecf 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -927,12 +927,12 @@ redo_rt6_select:
 			goto out;
 	}
 
-	if (rt->rt6i_flags & RTF_CACHE)
-		goto out;
-
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
+	if (rt->rt6i_flags & RTF_CACHE)
+		goto out2;
+
 	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
-- 
1.8.1
