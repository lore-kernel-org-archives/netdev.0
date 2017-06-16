From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 12/21] ipv6: call dst_hold_safe() properly
Date: Fri, 16 Jun 2017 10:47:35 -0700
Message-ID: <20170616174744.139688-13-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35027 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752511AbdFPRsa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:30 -0400
Received: by mail-pf0-f196.google.com with SMTP id s66so7558058pfs.2
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:30 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Similar as ipv4, ipv6 path also needs to call dst_hold_safe() when
necessary to avoid double free issue on the dst.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/addrconf.c | 4 ++--
 net/ipv6/route.c    | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0aa36b093013..2a6397714d70 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5576,8 +5576,8 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 				ip6_del_rt(rt);
 		}
 		if (ifp->rt) {
-			dst_hold(&ifp->rt->dst);
-			ip6_del_rt(ifp->rt);
+			if (dst_hold_safe(&ifp->rt->dst))
+				ip6_del_rt(ifp->rt);
 		}
 		rt_genid_bump_ipv6(net);
 		break;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 908b71188c57..c52c51908881 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1366,8 +1366,8 @@ static void ip6_link_failure(struct sk_buff *skb)
 	rt = (struct rt6_info *) skb_dst(skb);
 	if (rt) {
 		if (rt->rt6i_flags & RTF_CACHE) {
-			dst_hold(&rt->dst);
-			ip6_del_rt(rt);
+			if (dst_hold_safe(&rt->dst))
+				ip6_del_rt(rt);
 		} else if (rt->rt6i_node && (rt->rt6i_flags & RTF_DEFAULT)) {
 			rt->rt6i_node->fn_sernum = -1;
 		}
-- 
2.13.1.518.g3df882009-goog
