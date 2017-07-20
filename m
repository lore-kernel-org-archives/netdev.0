From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net] ipv6: no need to return rt->dst.error if it is not null entry.
Date: Thu, 20 Jul 2017 22:51:26 +0800
Message-ID: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34671 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934805AbdGTOv4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 10:51:56 -0400
Received: by mail-pg0-f66.google.com with SMTP id v190so2970350pgv.1
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 07:51:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib
result when requested"). When we get a prohibit ertry, we will return
-EACCES directly.

Before:
+ ip netns exec client ip -6 route get 2003::1
prohibit 2003::1 dev lo table unspec proto kernel src 2001::1 metric
4294967295 error -13

After:
+ ip netns exec server ip -6 route get 2002::1
RTNETLINK answers: Network is unreachable

Since we will check the ip6_null_entry later. There is not sense
to check the dst.error after get rt.

Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv6/route.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d30c96..8fc52de 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3637,12 +3637,6 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		dst = ip6_route_lookup(net, &fl6, 0);
 
 	rt = container_of(dst, struct rt6_info, dst);
-	if (rt->dst.error) {
-		err = rt->dst.error;
-		ip6_rt_put(rt);
-		goto errout;
-	}
-
 	if (rt == net->ipv6.ip6_null_entry) {
 		err = rt->dst.error;
 		ip6_rt_put(rt);
-- 
2.5.5
