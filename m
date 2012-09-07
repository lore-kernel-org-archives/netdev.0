From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH 2/2] ipv6: remove rt6i_flow_cache_genid field in rt6_info
Date: Fri,  7 Sep 2012 17:57:47 +0200
Message-ID: <1347033467-3757-3-git-send-email-nicolas.dichtel@6wind.com>
References: <5049FAE3.2050403@6wind.com>
 <1347033467-3757-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: vyasevich@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34148 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756795Ab2IGN4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 09:56:07 -0400
In-Reply-To: <1347033467-3757-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that flow_cache_genid is stored in dst, there is no need to add
specific code here.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ip6_fib.h            |  3 ---
 net/ipv6/inet6_connection_sock.c | 23 +----------------------
 2 files changed, 1 insertion(+), 25 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index cd64cf3..af11e95 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -112,9 +112,6 @@ struct rt6_info {
 	struct inet6_dev		*rt6i_idev;
 	unsigned long			_rt6i_peer;
 
-#ifdef CONFIG_XFRM
-	u32				rt6i_flow_cache_genid;
-#endif
 	/* more non-fragment space at head required */
 	unsigned short			rt6i_nfheader_len;
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 0251a60..c4f9341 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -175,33 +175,12 @@ void __inet6_csk_dst_store(struct sock *sk, struct dst_entry *dst,
 			   const struct in6_addr *saddr)
 {
 	__ip6_dst_store(sk, dst, daddr, saddr);
-
-#ifdef CONFIG_XFRM
-	{
-		struct rt6_info *rt = (struct rt6_info  *)dst;
-		rt->rt6i_flow_cache_genid = atomic_read(&flow_cache_genid);
-	}
-#endif
 }
 
 static inline
 struct dst_entry *__inet6_csk_dst_check(struct sock *sk, u32 cookie)
 {
-	struct dst_entry *dst;
-
-	dst = __sk_dst_check(sk, cookie);
-
-#ifdef CONFIG_XFRM
-	if (dst) {
-		struct rt6_info *rt = (struct rt6_info *)dst;
-		if (rt->rt6i_flow_cache_genid != atomic_read(&flow_cache_genid)) {
-			__sk_dst_reset(sk);
-			dst = NULL;
-		}
-	}
-#endif
-
-	return dst;
+	return __sk_dst_check(sk, cookie);
 }
 
 static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
-- 
1.7.12
