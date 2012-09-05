From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH v2] ipv6: fix handling of blackhole and prohibit routes
Date: Wed,  5 Sep 2012 07:34:18 -0400
Message-ID: <1346844858-3210-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20120904.155836.51164588359279575.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57121 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab2IEJhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 05:37:42 -0400
In-Reply-To: <20120904.155836.51164588359279575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When adding a blackhole or a prohibit route, they were handling like classic
routes. Moreover, it was only possible to add this kind of routes by specifying
an interface.

Bug already reported here:
  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=498498

Before the patch:
  $ ip route add blackhole 2001::1/128
  RTNETLINK answers: No such device
  $ ip route add blackhole 2001::1/128 dev eth0
  $ ip -6 route | grep 2001
  2001::1 dev eth0  metric 1024

After:
  $ ip route add blackhole 2001::1/128
  $ ip -6 route | grep 2001
  blackhole 2001::1 dev lo  metric 1024  error -22

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ip6_fib.h |  1 +
 net/ipv6/route.c      | 32 ++++++++++++++++++++++++++++----
 2 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 0fedbd8..cd64cf3 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -37,6 +37,7 @@ struct fib6_config {
 	int		fc_ifindex;
 	u32		fc_flags;
 	u32		fc_protocol;
+	u32		fc_type;	/* only 8 bits are used */
 
 	struct in6_addr	fc_dst;
 	struct in6_addr	fc_src;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8e80fd2..5642fb5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1463,8 +1463,18 @@ int ip6_route_add(struct fib6_config *cfg)
 		}
 		rt->dst.output = ip6_pkt_discard_out;
 		rt->dst.input = ip6_pkt_discard;
-		rt->dst.error = -ENETUNREACH;
 		rt->rt6i_flags = RTF_REJECT|RTF_NONEXTHOP;
+		switch (cfg->fc_type) {
+		case RTM_BLACKHOLE:
+			rt->dst.error = -EINVAL;
+			break;
+		case RTM_PROHIBIT:
+			rt->dst.error = -EACCES;
+			break;
+		default:
+			rt->dst.error = -ENETUNREACH;
+			break;
+		}
 		goto install_route;
 	}
 
@@ -2261,8 +2271,11 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	cfg->fc_src_len = rtm->rtm_src_len;
 	cfg->fc_flags = RTF_UP;
 	cfg->fc_protocol = rtm->rtm_protocol;
+	cfg->type = rtm->rtm_type;
 
-	if (rtm->rtm_type == RTN_UNREACHABLE)
+	if (rtm->rtm_type == RTN_UNREACHABLE ||
+	    rtm->rtm_type == RTN_BLACKHOLE ||
+	    rtm->rtm_type == RTN_PROHIBIT)
 		cfg->fc_flags |= RTF_REJECT;
 
 	if (rtm->rtm_type == RTN_LOCAL)
@@ -2391,8 +2404,19 @@ static int rt6_fill_node(struct net *net,
 	rtm->rtm_table = table;
 	if (nla_put_u32(skb, RTA_TABLE, table))
 		goto nla_put_failure;
-	if (rt->rt6i_flags & RTF_REJECT)
-		rtm->rtm_type = RTN_UNREACHABLE;
+	if (rt->rt6i_flags & RTF_REJECT) {
+		switch (rt->dst.error) {
+		case -EINVAL:
+			rtm->rtm_type = RTN_BLACKHOLE;
+			break;
+		case -EACCES:
+			rtm->rtm_type = RTN_PROHIBIT;
+			break;
+		default:
+			rtm->rtm_type = RTN_UNREACHABLE;
+			break;
+		}
+	}
 	else if (rt->rt6i_flags & RTF_LOCAL)
 		rtm->rtm_type = RTN_LOCAL;
 	else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
-- 
1.7.12
