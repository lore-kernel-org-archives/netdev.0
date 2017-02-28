From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv6: ignore null_entry in inet6_rtm_getroute() too
Date: Tue, 28 Feb 2017 10:44:38 -0800
Message-ID: <1488307478-10081-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32775 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751527AbdB1Sy2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 13:54:28 -0500
Received: by mail-pg0-f66.google.com with SMTP id x17so2556205pgi.0
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 10:53:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like commit 1f17e2f2c8a8 ("net: ipv6: ignore null_entry on route dumps"),
we need to ignore null entry in inet6_rtm_getroute() too.

Return -ENOENT here because we return the same errno when deleting
the null entry.

Fixes: a1a22c1206 ("net: ipv6: Keep nexthop of multipath route on admin down")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/route.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f54f426..25590d1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3627,6 +3627,12 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
 	}
 
+	if (rt == net->ipv6.ip6_null_entry) {
+		ip6_rt_put(rt);
+		err = -ENOENT;
+		goto errout;
+	}
+
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb) {
 		ip6_rt_put(rt);
-- 
2.5.5
