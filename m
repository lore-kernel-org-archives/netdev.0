From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv3 net] ipv6: no need to return rt->dst.error if it is prohibit entry
Date: Wed, 26 Jul 2017 17:20:29 +0800
Message-ID: <1501060829-11928-1-git-send-email-liuhangbin@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Ahern <dsahern@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35177 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750813AbdGZJVD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 05:21:03 -0400
Received: by mail-pf0-f196.google.com with SMTP id q85so14998501pfq.2
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 02:21:03 -0700 (PDT)
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

Fix this by add prohibit and blk hole check.

At the same time, after commit
2f460933f58e ("ipv6: initialize route null entry in addrconf_init()") and
242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf")
We will init rt6i_idev correctly. So we could dump ip6_null_entry
(unreachable route entry) safely now.

Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv6/route.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d30c96..b05da74 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3637,13 +3637,12 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		dst = ip6_route_lookup(net, &fl6, 0);
 
 	rt = container_of(dst, struct rt6_info, dst);
-	if (rt->dst.error) {
-		err = rt->dst.error;
-		ip6_rt_put(rt);
-		goto errout;
-	}
-
-	if (rt == net->ipv6.ip6_null_entry) {
+	if (rt->dst.error &&
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	    rt != net->ipv6.ip6_prohibit_entry &&
+	    rt != net->ipv6.ip6_blk_hole_entry &&
+#endif
+	    rt != net->ipv6.ip6_null_entry) {
 		err = rt->dst.error;
 		ip6_rt_put(rt);
 		goto errout;
-- 
2.5.5
