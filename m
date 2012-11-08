From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: remove rt6i_peer_genid from rt6_info and its handler
Date: Thu,  8 Nov 2012 15:56:33 +0800
Message-ID: <1352361393-4807-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:58630 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427Ab2KHH4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 02:56:45 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so1854712pbb.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 23:56:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

6431cbc25f(Create a mechanism for upward inetpeer propagation into routes)
introduces these codes, but this mechanism is never enabled since
rt6i_peer_genid always is zero whether it is not assigned or assigned by
rt6_peer_genid(). After 5943634fc5 (ipv4: Maintain redirect and PMTU info
in struct rtable again), the ipv4 related codes of this mechanism has been
removed, I think we maybe able to remove them now.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 include/net/ip6_fib.h |    1 -
 net/ipv6/route.c      |   18 ++----------------
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 20210d7..26210cf 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -117,7 +117,6 @@ struct rt6_info {
 	struct rt6key			rt6i_src;
 	struct rt6key			rt6i_prefsrc;
 	u32				rt6i_metric;
-	u32				rt6i_peer_genid;
 
 	struct inet6_dev		*rt6i_idev;
 	unsigned long			_rt6i_peer;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c42650c..0db1828 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -321,13 +321,6 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	}
 }
 
-static atomic_t __rt6_peer_genid = ATOMIC_INIT(0);
-
-static u32 rt6_peer_genid(void)
-{
-	return atomic_read(&__rt6_peer_genid);
-}
-
 void rt6_bind_peer(struct rt6_info *rt, int create)
 {
 	struct inet_peer_base *base;
@@ -341,8 +334,6 @@ void rt6_bind_peer(struct rt6_info *rt, int create)
 	if (peer) {
 		if (!rt6_set_peer(rt, peer))
 			inet_putpeer(peer);
-		else
-			rt->rt6i_peer_genid = rt6_peer_genid();
 	}
 }
 
@@ -1099,14 +1090,9 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	if (rt->rt6i_genid != rt_genid(dev_net(rt->dst.dev)))
 		return NULL;
 
-	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie)) {
-		if (rt->rt6i_peer_genid != rt6_peer_genid()) {
-			if (!rt6_has_peer(rt))
-				rt6_bind_peer(rt, 0);
-			rt->rt6i_peer_genid = rt6_peer_genid();
-		}
+	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
 		return dst;
-	}
+
 	return NULL;
 }
 
-- 
1.7.4.1
