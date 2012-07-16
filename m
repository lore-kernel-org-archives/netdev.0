From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv6: fix incorrect route 'expires' value passed to userspace.
Date: Mon, 16 Jul 2012 16:09:37 +0800
Message-ID: <5003CC41.9080204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:9515 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750843Ab2GPIK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 04:10:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When userspace use RTM_GETROUTE to dump route table, with a already
expired route entry, we always got an 'expires' value(2147157)
calculated base on INT_MAX.

The reason of this problem is in the following satement:
	rt->dst.expires - jiffies < INT_MAX
gcc promoted the type of both sides of '<' to unsigned long, thus
a small negative value would be considered greater than INT_MAX.

This patch fix this by cast the result of subtraction to an 'int'
which I think is large enough for the expires.

Also we should do some fix in rtnl_put_cacheinfo() which use
jiffies_to_clock_t(which take an unsigned log as parameter) to
convert jiffies to clock_t to handle the negative expires.
---
 net/core/rtnetlink.c |    3 ++-
 net/ipv6/route.c     |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 21318d1..f92f3d8 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -641,7 +641,8 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 	};
 
 	if (expires)
-		ci.rta_expires = jiffies_to_clock_t(expires);
+		ci.rta_expires = expires > 0 ? jiffies_to_clock_t(expires)
+			: -jiffies_to_clock_t(-expires);
 
 	return nla_put(skb, RTA_CACHEINFO, sizeof(ci), &ci);
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index becb048..a7fec9d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2516,7 +2516,7 @@ static int rt6_fill_node(struct net *net,
 		goto nla_put_failure;
 	if (!(rt->rt6i_flags & RTF_EXPIRES))
 		expires = 0;
-	else if (rt->dst.expires - jiffies < INT_MAX)
+	else if ((int)(rt->dst.expires - jiffies) < INT_MAX)
 		expires = rt->dst.expires - jiffies;
 	else
 		expires = INT_MAX;
-- 
1.7.1
