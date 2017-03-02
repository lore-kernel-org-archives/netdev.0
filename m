From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v2] ipv6: ignore null_entry in inet6_rtm_getroute() too
Date: Wed,  1 Mar 2017 20:48:39 -0800
Message-ID: <1488430119-4670-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35066 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752238AbdCBEtJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 23:49:09 -0500
Received: by mail-pg0-f65.google.com with SMTP id 1so7997471pgz.2
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 20:48:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like commit 1f17e2f2c8a8 ("net: ipv6: ignore null_entry on route dumps"),
we need to ignore null entry in inet6_rtm_getroute() too.

Return -ENETUNREACH here to sync with IPv4 behavior, as suggested by David.

Fixes: a1a22c1206 ("net: ipv6: Keep nexthop of multipath route on admin down")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/route.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f54f426..df757b2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3627,6 +3627,12 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
 	}
 
+	if (rt == net->ipv6.ip6_null_entry) {
+		err = rt->dst.error;
+		ip6_rt_put(rt);
+		goto errout;
+	}
+
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb) {
 		ip6_rt_put(rt);
-- 
2.5.5
