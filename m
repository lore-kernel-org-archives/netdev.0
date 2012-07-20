From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH V2 resend] ipv6: fix incorrect route 'expires' value passed
 to userspace
Date: Fri, 20 Jul 2012 09:42:44 +0800
Message-ID: <5008B794.7010904@cn.fujitsu.com>
References: <5003CC41.9080204@cn.fujitsu.com> <20120716.025649.1070277404591664104.davem@davemloft.net> <50076AD3.1060604@cn.fujitsu.com> <20120719.104906.38765587582698093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:27185 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752087Ab2GTBna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 21:43:30 -0400
In-Reply-To: <20120719.104906.38765587582698093.davem@davemloft.net>
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

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/core/rtnetlink.c |    3 ++-
 net/ipv6/route.c     |    7 ++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

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
index becb048..7875255 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2516,10 +2516,11 @@ static int rt6_fill_node(struct net *net,
 		goto nla_put_failure;
 	if (!(rt->rt6i_flags & RTF_EXPIRES))
 		expires = 0;
-	else if (rt->dst.expires - jiffies < INT_MAX)
-		expires = rt->dst.expires - jiffies;
+	else if ((long)rt->dst.expires - (long)jiffies > INT_MIN
+			&& (long)rt->dst.expires - (long)jiffies < INT_MAX)
+		expires = (long)rt->dst.expires - (long)jiffies;
 	else
-		expires = INT_MAX;
+		expires = time_is_after_jiffies(rt->dst.expires) ? INT_MAX : INT_MIN;
 
 	peer = rt->rt6i_peer;
 	ts = tsage = 0;
-- 
1.7.1
