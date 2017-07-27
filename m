From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv4 net] ipv6: no need to check rt->dst.error when get route info
Date: Fri, 28 Jul 2017 00:25:36 +0800
Message-ID: <1501172736-13685-1-git-send-email-liuhangbin@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Ahern <dsahern@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34016 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751607AbdG0Q0R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 12:26:17 -0400
Received: by mail-pf0-f196.google.com with SMTP id u17so105635pfa.1
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 09:26:17 -0700 (PDT)
In-Reply-To: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib
result when requested"). When we get a prohibit ertry, we will return
-EACCES directly instead of dump route info.

Fix it by remove the rt->dst.error check.

Before fix:
\# ip -6 route add prohibit 2003::/64 dev eth1
\# ip -6 route get fibmatch 2003::1
RTNETLINK answers: Permission denied
\# ip -6 route add unreachable 2004::/64 dev eth1
\# ip -6 route get fibmatch 2004::1
RTNETLINK answers: No route to host

After fix:
\# ip -6 route add prohibit 2003::/64 dev eth1
\# ip -6 route get fibmatch 2003::1
prohibit 2003::/64 dev lo metric 1024 error -13 pref medium
\# ip -6 route add unreachable 2004::/64 dev eth1
\# ip -6 route get fibmatch 2004::1
unreachable 2004::/64 dev lo metric 1024 error -113 pref medium

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
