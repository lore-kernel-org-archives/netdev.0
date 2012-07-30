From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH v4] ipv6: fix incorrect route 'expires' value passed to userspace
Date: Mon, 30 Jul 2012 10:01:30 +0800
Message-ID: <1343613690-3236-1-git-send-email-lw@cn.fujitsu.com>
References: <1343199114.2626.11088.camel@edumazet-glaptop>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Li Wei <lw@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:20161 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753886Ab2G3CDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2012 22:03:10 -0400
In-Reply-To: <1343199114.2626.11088.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When userspace use RTM_GETROUTE to dump route table, with an already
expired route entry, we always got an 'expires' value(2147157)
calculated base on INT_MAX.

The reason of this problem is in the following satement:
	rt->dst.expires - jiffies < INT_MAX
gcc promoted the type of both sides of '<' to unsigned long, thus
a small negative value would be considered greater than INT_MAX.

With the help of Eric Dumazet, do the out of bound checks in
rtnl_put_cacheinfo(), _after_ conversion to clock_t.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
In fact, all the code was reconstructed by Eric, I just put the
commit log and resent it to the maillist, thanks Eric!

 net/core/rtnetlink.c |    8 ++++++--
 net/ipv6/route.c     |    8 ++------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index bc9e380..5ff949d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -625,9 +625,13 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 		.rta_id =  id,
 	};
 
-	if (expires)
-		ci.rta_expires = jiffies_to_clock_t(expires);
+	if (expires) {
+		unsigned long clock;
 
+		clock = jiffies_to_clock_t(abs(expires));
+		clock = min_t(unsigned long, clock, INT_MAX);
+		ci.rta_expires = (expires > 0) ? clock : -clock;
+	}
 	return nla_put(skb, RTA_CACHEINFO, sizeof(ci), &ci);
 }
 EXPORT_SYMBOL_GPL(rtnl_put_cacheinfo);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cf02cb9..8e80fd2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2480,12 +2480,8 @@ static int rt6_fill_node(struct net *net,
 		goto nla_put_failure;
 	if (nla_put_u32(skb, RTA_PRIORITY, rt->rt6i_metric))
 		goto nla_put_failure;
-	if (!(rt->rt6i_flags & RTF_EXPIRES))
-		expires = 0;
-	else if (rt->dst.expires - jiffies < INT_MAX)
-		expires = rt->dst.expires - jiffies;
-	else
-		expires = INT_MAX;
+
+	expires = (rt->rt6i_flags & RTF_EXPIRES) ? rt->dst.expires - jiffies : 0;
 
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, rt->dst.error) < 0)
 		goto nla_put_failure;
-- 
1.7.10.1
