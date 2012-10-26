From: roy.qing.li@gmail.com
Subject: [RFC PATCH net-next] ipv6: remove rt6i_peer_genid from rt6_info and its handler
Date: Fri, 26 Oct 2012 21:01:59 +0800
Message-ID: <1351256519-7704-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35932 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280Ab2JZNCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 09:02:06 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so1916461pad.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 06:02:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

6431cbc25f(Create a mechanism for upward inetpeer propagation into routes)
introduces these codes, but this mechanism is never enabled since
rt6i_peer_genid always is zero whether it is not assigned or assigned by
rt6_peer_genid(). After 5943634fc5 (ipv4: Maintain redirect and PMTU info
in struct rtable again), the ipv4 related codes of this mechanism have been
removed, I think we maybe able to remove them now.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 include/net/ip6_fib.h |    1 -
 net/ipv6/route.c      |   16 ++--------------
 2 files changed, 2 insertions(+), 15 deletions(-)

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
index c42650c..6ceee24 100644
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
 
@@ -1100,11 +1091,8 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 		return NULL;
 
 	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie)) {
-		if (rt->rt6i_peer_genid != rt6_peer_genid()) {
-			if (!rt6_has_peer(rt))
-				rt6_bind_peer(rt, 0);
-			rt->rt6i_peer_genid = rt6_peer_genid();
-		}
+		if (!rt6_has_peer(rt))
+			rt6_bind_peer(rt, 0);
 		return dst;
 	}
 	return NULL;
-- 
1.7.4.1
