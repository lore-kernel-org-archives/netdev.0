From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/4] ipv4: Pass explicit destination address to
 rt_bind_peer().
Date: Wed, 18 May 2011 18:56:42 -0400 (EDT)
Message-ID: <20110518.185642.1538072073327275084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755729Ab1ERW4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:56:44 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4IMugDo017423
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 18 May 2011 15:56:43 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    4 ++--
 net/ipv4/icmp.c     |    8 ++++----
 net/ipv4/route.c    |   16 ++++++++--------
 net/ipv4/tcp_ipv4.c |    2 +-
 4 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 600d0f2..db7b343 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -290,14 +290,14 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 	return rt;
 }
 
-extern void rt_bind_peer(struct rtable *rt, int create);
+extern void rt_bind_peer(struct rtable *rt, __be32 daddr, int create);
 
 static inline struct inet_peer *rt_get_peer(struct rtable *rt, __be32 daddr)
 {
 	if (rt->peer)
 		return rt->peer;
 
-	rt_bind_peer(rt, 0);
+	rt_bind_peer(rt, daddr, 0);
 	return rt->peer;
 }
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 3f47585..5395e45 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -234,7 +234,7 @@ static inline void icmp_xmit_unlock(struct sock *sk)
  */
 
 static inline bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
-		int type, int code)
+				      struct flowi4 *fl4, int type, int code)
 {
 	struct dst_entry *dst = &rt->dst;
 	bool rc = true;
@@ -253,7 +253,7 @@ static inline bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 	/* Limit if icmp type is enabled in ratemask. */
 	if ((1 << type) & net->ipv4.sysctl_icmp_ratemask) {
 		if (!rt->peer)
-			rt_bind_peer(rt, 1);
+			rt_bind_peer(rt, fl4->daddr, 1);
 		rc = inet_peer_xrlim_allow(rt->peer,
 					   net->ipv4.sysctl_icmp_ratelimit);
 	}
@@ -363,7 +363,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
 		goto out_unlock;
-	if (icmpv4_xrlim_allow(net, rt, icmp_param->data.icmph.type,
+	if (icmpv4_xrlim_allow(net, rt, &fl4, icmp_param->data.icmph.type,
 			       icmp_param->data.icmph.code))
 		icmp_push_reply(icmp_param, &fl4, &ipc, &rt);
 	ip_rt_put(rt);
@@ -603,7 +603,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	if (IS_ERR(rt))
 		goto out_unlock;
 
-	if (!icmpv4_xrlim_allow(net, rt, type, code))
+	if (!icmpv4_xrlim_allow(net, rt, &fl4, type, code))
 		goto ende;
 
 	/* RFC says return as much as we can without exceeding 576 bytes. */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9c5ad86..b24d58e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -156,7 +156,7 @@ static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 	u32 *p = NULL;
 
 	if (!rt->peer)
-		rt_bind_peer(rt, 1);
+		rt_bind_peer(rt, rt->rt_dst, 1);
 
 	peer = rt->peer;
 	if (peer) {
@@ -1193,11 +1193,11 @@ static u32 rt_peer_genid(void)
 	return atomic_read(&__rt_peer_genid);
 }
 
-void rt_bind_peer(struct rtable *rt, int create)
+void rt_bind_peer(struct rtable *rt, __be32 daddr, int create)
 {
 	struct inet_peer *peer;
 
-	peer = inet_getpeer_v4(rt->rt_dst, create);
+	peer = inet_getpeer_v4(daddr, create);
 
 	if (peer && cmpxchg(&rt->peer, NULL, peer) != NULL)
 		inet_putpeer(peer);
@@ -1231,7 +1231,7 @@ void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
 
 	if (rt) {
 		if (rt->peer == NULL)
-			rt_bind_peer(rt, 1);
+			rt_bind_peer(rt, rt->rt_dst, 1);
 
 		/* If peer is attached to destination, it is never detached,
 		   so that we need not to grab a lock to dereference it.
@@ -1377,7 +1377,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	rcu_read_unlock();
 
 	if (!rt->peer)
-		rt_bind_peer(rt, 1);
+		rt_bind_peer(rt, rt->rt_dst, 1);
 	peer = rt->peer;
 	if (!peer) {
 		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);
@@ -1445,7 +1445,7 @@ static int ip_error(struct sk_buff *skb)
 	}
 
 	if (!rt->peer)
-		rt_bind_peer(rt, 1);
+		rt_bind_peer(rt, rt->rt_dst, 1);
 	peer = rt->peer;
 
 	send = true;
@@ -1552,7 +1552,7 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 	dst_confirm(dst);
 
 	if (!rt->peer)
-		rt_bind_peer(rt, 1);
+		rt_bind_peer(rt, rt->rt_dst, 1);
 	peer = rt->peer;
 	if (peer) {
 		if (mtu < ip_rt_min_pmtu)
@@ -1609,7 +1609,7 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 		struct inet_peer *peer;
 
 		if (!rt->peer)
-			rt_bind_peer(rt, 0);
+			rt_bind_peer(rt, rt->rt_dst, 0);
 
 		peer = rt->peer;
 		if (peer && peer->pmtu_expires)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1d290ac..3c8d9b6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1781,7 +1781,7 @@ struct inet_peer *tcp_v4_get_peer(struct sock *sk, bool *release_it)
 		*release_it = true;
 	} else {
 		if (!rt->peer)
-			rt_bind_peer(rt, 1);
+			rt_bind_peer(rt, inet->inet_daddr, 1);
 		peer = rt->peer;
 		*release_it = false;
 	}
-- 
1.7.4.4

