From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] ipv6: fix handling of throw routes
Date: Thu,  6 Sep 2012 11:53:35 -0400
Message-ID: <1346946815-3094-1-git-send-email-nicolas.dichtel@6wind.com>
References: <5048A374.60005@6wind.com>
Cc: netdev@vger.kernel.org, markus.stenberg@iki.fi,
	eric.dumazet@gmail.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:59735 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755019Ab2IFNvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 09:51:02 -0400
In-Reply-To: <5048A374.60005@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's the same problem that previous fix about blackhole and prohibit routes.

When adding a throw route, it was handled like a classic route.
Moreover, it was only possible to add this kind of routes by specifying
an interface.

Before the patch:
  $ ip route add throw 2001::2/128
  RTNETLINK answers: No such device
  $ ip route add throw 2001::2/128 dev eth0
  $ ip -6 route | grep 2001::2
  2001::2 dev eth0  metric 1024

After:
  $ ip route add throw 2001::2/128
  $ ip -6 route | grep 2001::2
  throw 2001::2 dev lo  metric 1024  error -11

Reported-by: Markus Stenberg <markus.stenberg@iki.fi>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/route.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fa26444..339d921 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1471,6 +1471,9 @@ int ip6_route_add(struct fib6_config *cfg)
 		case RTN_PROHIBIT:
 			rt->dst.error = -EACCES;
 			break;
+		case RTN_THROW:
+			rt->dst.error = -EAGAIN;
+			break;
 		default:
 			rt->dst.error = -ENETUNREACH;
 			break;
@@ -2275,7 +2278,8 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	if (rtm->rtm_type == RTN_UNREACHABLE ||
 	    rtm->rtm_type == RTN_BLACKHOLE ||
-	    rtm->rtm_type == RTN_PROHIBIT)
+	    rtm->rtm_type == RTN_PROHIBIT ||
+	    rtm->rtm_type == RTN_THROW)
 		cfg->fc_flags |= RTF_REJECT;
 
 	if (rtm->rtm_type == RTN_LOCAL)
@@ -2412,6 +2416,9 @@ static int rt6_fill_node(struct net *net,
 		case -EACCES:
 			rtm->rtm_type = RTN_PROHIBIT;
 			break;
+		case -EAGAIN:
+			rtm->rtm_type = RTN_THROW;
+			break;
 		default:
 			rtm->rtm_type = RTN_UNREACHABLE;
 			break;
-- 
1.7.12
