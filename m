From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net] ipv6: Fix __ip6_route_redirect
Date: Tue, 20 Jan 2015 19:16:02 -0800
Message-ID: <1421810162-2910767-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52323 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751430AbbAUDQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 22:16:07 -0500
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t0L3FVSV018010
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 19:16:06 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1s1yfwgyf6-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 19:16:06 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 d4953e6ea11b11e484340002c95209d8-b3d646d0 for <netdev@vger.kernel.org>;	Tue,
 20 Jan 2015 19:16:03 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In my last commit (a3c00e4: ipv6: Remove BACKTRACK macro), the changes in
__ip6_route_redirect is incorrect.  The following case is missed:
1. The for loop tries to find a valid gateway rt. If it fails to find
   one, rt will be NULL.
2. When rt is NULL, it is set to the ip6_null_entry.
3. The newly added 'else if', from a3c00e4, will stop the backtrack from
   happening.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/route.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 166e33b..49596535 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1242,12 +1242,16 @@ restart:
 		rt = net->ipv6.ip6_null_entry;
 	else if (rt->dst.error) {
 		rt = net->ipv6.ip6_null_entry;
-	} else if (rt == net->ipv6.ip6_null_entry) {
+		goto out;
+	}
+
+	if (rt == net->ipv6.ip6_null_entry) {
 		fn = fib6_backtrack(fn, &fl6->saddr);
 		if (fn)
 			goto restart;
 	}
 
+out:
 	dst_hold(&rt->dst);
 
 	read_unlock_bh(&table->tb6_lock);
-- 
1.8.1
