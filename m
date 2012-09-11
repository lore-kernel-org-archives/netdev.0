From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 3/4] ipv6: use net->rt_genid to check dst validity
Date: Tue, 11 Sep 2012 10:09:46 +0200
Message-ID: <1347350987-8054-4-git-send-email-nicolas.dichtel@6wind.com>
References: <504DFF90.3010802@6wind.com>
 <1347350987-8054-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: vyasevich@gmail.com, davem@davemloft.net, eric.dumazet@gmail.com,
	sds@tycho.nsa.gov, james.l.morris@oracle.com, eparis@parisplace.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:39463 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377Ab2IKIJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 04:09:41 -0400
In-Reply-To: <1347350987-8054-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 dst should take care of rt_genid too. When a xfrm policy is inserted or
deleted, all dst should be invalidated.
To force the validation, dst entries should be created with ->obsolete set to
DST_OBSOLETE_FORCE_CHK. This was already the case for all functions calling
ip6_dst_alloc(), except for ip6_rt_copy().

As a consequence, we can remove the specific code in inet6_connection_sock.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ip6_fib.h            |  5 ++---
 net/ipv6/inet6_connection_sock.c | 23 +----------------------
 net/ipv6/route.c                 | 13 +++++++++----
 3 files changed, 12 insertions(+), 29 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index cd64cf3..8a2a203 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -112,9 +112,8 @@ struct rt6_info {
 	struct inet6_dev		*rt6i_idev;
 	unsigned long			_rt6i_peer;
 
-#ifdef CONFIG_XFRM
-	u32				rt6i_flow_cache_genid;
-#endif
+	u32				rt6i_genid;
+
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
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 339d921..561f249 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -281,13 +281,14 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 					     struct fib6_table *table)
 {
 	struct rt6_info *rt = dst_alloc(&net->ipv6.ip6_dst_ops, dev,
-					0, DST_OBSOLETE_NONE, flags);
+					0, DST_OBSOLETE_FORCE_CHK, flags);
 
 	if (rt) {
 		struct dst_entry *dst = &rt->dst;
 
 		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
+		rt->rt6i_genid = rt_genid(net);
 	}
 	return rt;
 }
@@ -1031,6 +1032,13 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 
 	rt = (struct rt6_info *) dst;
 
+	/* All IPV6 dsts are created with ->obsolete set to the value
+	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
+	 * into this function always.
+	 */
+	if (rt->rt6i_genid != rt_genid(dev_net(rt->dst.dev)))
+		return NULL;
+
 	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie)) {
 		if (rt->rt6i_peer_genid != rt6_peer_genid()) {
 			if (!rt6_has_peer(rt))
@@ -1397,8 +1405,6 @@ int ip6_route_add(struct fib6_config *cfg)
 		goto out;
 	}
 
-	rt->dst.obsolete = -1;
-
 	if (cfg->fc_flags & RTF_EXPIRES)
 		rt6_set_expires(rt, jiffies +
 				clock_t_to_jiffies(cfg->fc_expires));
@@ -2093,7 +2099,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->dst.input = ip6_input;
 	rt->dst.output = ip6_output;
 	rt->rt6i_idev = idev;
-	rt->dst.obsolete = -1;
 
 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;
 	if (anycast)
-- 
1.7.12
