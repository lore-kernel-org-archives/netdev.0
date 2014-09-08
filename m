From: Alex Gartrell <agartrell@fb.com>
Subject: [RFC PATCH net-next] ip6: Do not expire uncached routes for mtu invalidation
Date: Mon, 8 Sep 2014 01:34:43 -0700
Message-ID: <1410165283-29337-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <edumazet@google.com>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>, <ps@fb.com>, Alex Gartrell <agartrell@fb.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44332 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753060AbaIHIgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 04:36:40 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s888SVum003364
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2014 01:36:39 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1p7h9xe1f2-5
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 01:36:38 -0700
Received: from facebook.com (2401:db00:20:7017:face:0:13:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 001263f8373311e4b94f24be0593f280-3e3e93f0 for <netdev@vger.kernel.org>;	Mon,
 08 Sep 2014 01:34:51 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does two things: first it won't introduced RTF_EXPIRES to
rt6i_flags unless it already exists or RTF_CACHE is set; second, in
ip_pol_route, we'll check for expiration without the RTF_EXPIRES bit, and,
if it's set, zero out the pmtu so that we'll fall back to the device mtu.

This fixes an issue where we were deleting local, uncached dst routes.
This would result in packets being rejected after mtu expiration.

Here's a repro of the problem.

  ip addr add dev lo face::1/128
  grep ^face0000000000000000000000000001 /proc/net/ipv6_route
  # The flags do not have RTF_MODIFIED | RTF_EXPIRED

  ipvsadm -A -t 8.8.8.8:15213 # service not supported on first try
  ipvsadm -A -t [face::1]:15213 -s rr > /dev/null
  ipvsadm -a -t [face::1]:15213 -r 2401:db00:20:7017:face:0:13:0 --ipip > /dev/null

  timeout 3 nc face::1 15213

  grep ^face0000000000000000000000000001 /proc/net/ipv6_route
  # The flags will not include RTF_MODIFIED | RTF_EXPIRED

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip6_fib.h |  3 ++-
 net/ipv6/route.c      | 13 ++++++++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 9bcb220..2f0d4d0 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -184,7 +184,8 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
 		rt0->dst.expires = rt->dst.expires;
 
 	dst_set_expires(&rt0->dst, timeout);
-	rt0->rt6i_flags |= RTF_EXPIRES;
+	if (rt0->rt6i_flags & (RTF_CACHE | RTF_EXPIRES))
+		rt0->rt6i_flags |= RTF_EXPIRES;
 }
 
 static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f74b041..a509a06 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -947,8 +947,19 @@ restart:
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
-	else
+	else {
+		if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.expires &&
+		    time_after(jiffies, rt->dst.expires)) {
+			/* Uncached routes may have expires set if we
+			 * intend to expire the MTU but not the dest
+			 * itself.  In that case, we should reset the mtu
+			 * before handing it back */
+			dst_metric_set(&rt->dst, RTAX_MTU, 0);
+			rt6_clean_expires(rt);
+			rt->rt6i_flags &= ~RTF_MODIFIED;
+		}
 		goto out2;
+	}
 
 	ip6_rt_put(rt);
 	rt = nrt ? : net->ipv6.ip6_null_entry;
-- 
1.8.1
