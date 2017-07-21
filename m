From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 net] ipv6: should not return rt->dst.error if it is prohibit or blk hole entry.
Date: Fri, 21 Jul 2017 11:47:15 +0800
Message-ID: <1500608835-24845-1-git-send-email-liuhangbin@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37165 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966051AbdGUDrm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 23:47:42 -0400
Received: by mail-pg0-f66.google.com with SMTP id t8so4315411pgs.4
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 20:47:42 -0700 (PDT)
In-Reply-To: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
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
RTNETLINK answers: Permission denied

Fix this by add prohibit and blk hole check. Since ip6_null_entry's
error is already -ENETUNREACH. Merge the ip6_null_entry check and error
check together.

Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv6/route.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d30c96..c290aa4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3637,13 +3637,8 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		dst = ip6_route_lookup(net, &fl6, 0);
 
 	rt = container_of(dst, struct rt6_info, dst);
-	if (rt->dst.error) {
-		err = rt->dst.error;
-		ip6_rt_put(rt);
-		goto errout;
-	}
-
-	if (rt == net->ipv6.ip6_null_entry) {
+	if (rt->dst.error && rt != net->ipv6.ip6_prohibit_entry &&
+	    rt != net->ipv6.ip6_blk_hole_entry) {
 		err = rt->dst.error;
 		ip6_rt_put(rt);
 		goto errout;
-- 
2.5.5
