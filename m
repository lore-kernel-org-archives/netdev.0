From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/4] ipv6: route: make rtm_getroute not assume rtnl is locked
Date: Tue, 15 Aug 2017 16:34:42 +0200
Message-ID: <20170815143444.17002-3-fw@strlen.de>
References: <20170815143444.17002-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41030 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752401AbdHOOed (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:34:33 -0400
In-Reply-To: <20170815143444.17002-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__dev_get_by_index assumes RTNL is held, use _rcu version instead.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/route.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 035762fed07d..ec694fdb8cc5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3616,8 +3616,11 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		struct net_device *dev;
 		int flags = 0;
 
-		dev = __dev_get_by_index(net, iif);
+		rcu_read_lock();
+
+		dev = dev_get_by_index_rcu(net, iif);
 		if (!dev) {
+			rcu_read_unlock();
 			err = -ENODEV;
 			goto errout;
 		}
@@ -3629,6 +3632,8 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 
 		if (!fibmatch)
 			dst = ip6_route_input_lookup(net, dev, &fl6, flags);
+
+		rcu_read_unlock();
 	} else {
 		fl6.flowi6_oif = oif;
 
-- 
2.13.0
