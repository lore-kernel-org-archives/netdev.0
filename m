From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v5 net 2/3] ipv6: Avoid redoing fib6_lookup() for RTF_CACHE hit case
Date: Mon, 20 Oct 2014 13:42:44 -0700
Message-ID: <1413837765-5446-3-git-send-email-kafai@fb.com>
References: <1413837765-5446-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:43144 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753287AbaJTUnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 16:43:45 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id s9KKcopR011507
	for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 13:43:45 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by m0004348.ppops.net with ESMTP id 1q55rxgfjj-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 13:43:45 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 c7ba6d9c589911e49a0e0002c95209d8-fabf33e0 for <netdev@vger.kernel.org>;	Mon,
 20 Oct 2014 13:43:43 -0700
In-Reply-To: <1413837765-5446-1-git-send-email-kafai@fb.com>
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
index f1ab2f4..98c523f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -944,12 +944,12 @@ redo_rt6_select:
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
