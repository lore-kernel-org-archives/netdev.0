From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH V3] ipv6: fix incorrect route 'expires' value passed to userspace
Date: Wed, 25 Jul 2012 13:25:42 +0800
Message-ID: <500F8356.5040008@cn.fujitsu.com>
References: <20120719.104906.38765587582698093.davem@davemloft.net> <5008B794.7010904@cn.fujitsu.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6F9C@saturn3.aculab.com> <20120720.112241.2111041227435292899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:43492 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751102Ab2GYF0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 01:26:34 -0400
In-Reply-To: <20120720.112241.2111041227435292899.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When userspace use RTM_GETROUTE to dump route table, with an already
expired route entry, we always got an 'expires' value(2147157)
calculated base on INT_MAX.

The reason of this problem is in the following satement:
	rt->dst.expires - jiffies < INT_MAX
gcc promoted the type of both sides of '<' to unsigned long, thus
a small negative value would be considered greater than INT_MAX.

This patch fix this by use the same trick as time_after macro to
avoid the 'unsigned long' type promotion and deal with jiffies
wrapping.

Also we should do some fix in rtnl_put_cacheinfo() which use
jiffies_to_clock_t(which take an unsigned long as parameter) to
convert jiffies to clock_t to handle the negative expires.

With the help of David Laight, we can make the code a little clean.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/core/rtnetlink.c |    3 ++-
 net/ipv6/route.c     |   11 ++++++-----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 334b930..2e96396 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -626,7 +626,8 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 	};
 
 	if (expires)
-		ci.rta_expires = jiffies_to_clock_t(expires);
+		ci.rta_expires = expires > 0 ? jiffies_to_clock_t(expires)
+			: -jiffies_to_clock_t(-expires);
 
 	return nla_put(skb, RTA_CACHEINFO, sizeof(ci), &ci);
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cf02cb9..6efeb28 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2480,12 +2480,13 @@ static int rt6_fill_node(struct net *net,
 		goto nla_put_failure;
 	if (nla_put_u32(skb, RTA_PRIORITY, rt->rt6i_metric))
 		goto nla_put_failure;
-	if (!(rt->rt6i_flags & RTF_EXPIRES))
+	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
 		expires = 0;
-	else if (rt->dst.expires - jiffies < INT_MAX)
-		expires = rt->dst.expires - jiffies;
-	else
-		expires = INT_MAX;
+	} else {
+		expires = (long)rt->dst.expires - (long)jiffies;
+		if (expires != (int)expires)
+			expires = expires > 0 ? INT_MAX : INT_MIN;
+	}
 
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, rt->dst.error) < 0)
 		goto nla_put_failure;
-- 
1.7.10.1
