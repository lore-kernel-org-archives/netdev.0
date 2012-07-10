From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/16] inet: Kill FLOWI_FLAG_PRECOW_METRICS.
Date: Tue, 10 Jul 2012 08:07:39 -0700 (PDT)
Message-ID: <20120710.080739.1866706014687407098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608Ab2GJPHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:40 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id EA63858662D
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer needed.  TCP writes metrics, but now in it's own special
cache that does not dirty the route metrics.  Therefore there is no
longer any reason to pre-cow metrics in this way.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h              |    5 ++---
 include/net/inet_sock.h         |    2 --
 include/net/route.h             |    2 --
 net/ipv4/inet_connection_sock.c |    2 +-
 net/ipv4/route.c                |   11 ++---------
 net/ipv6/route.c                |    2 +-
 6 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index bd524f5..ce9cb76 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -20,9 +20,8 @@ struct flowi_common {
 	__u8	flowic_proto;
 	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
-#define FLOWI_FLAG_PRECOW_METRICS	0x02
-#define FLOWI_FLAG_CAN_SLEEP		0x04
-#define FLOWI_FLAG_RT_NOCACHE		0x08
+#define FLOWI_FLAG_CAN_SLEEP		0x02
+#define FLOWI_FLAG_RT_NOCACHE		0x04
 	__u32	flowic_secid;
 };
 
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index ae17e13..924d7b9 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -245,8 +245,6 @@ static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
 
 	if (inet_sk(sk)->transparent || inet_sk(sk)->hdrincl)
 		flags |= FLOWI_FLAG_ANYSRC;
-	if (sk->sk_protocol == IPPROTO_TCP)
-		flags |= FLOWI_FLAG_PRECOW_METRICS;
 	return flags;
 }
 
diff --git a/include/net/route.h b/include/net/route.h
index 211e266..635d7a9 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -278,8 +278,6 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 
 	if (inet_sk(sk)->transparent)
 		flow_flags |= FLOWI_FLAG_ANYSRC;
-	if (protocol == IPPROTO_TCP)
-		flow_flags |= FLOWI_FLAG_PRECOW_METRICS;
 	if (can_sleep)
 		flow_flags |= FLOWI_FLAG_CAN_SLEEP;
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 034ddbe..76825be 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -375,7 +375,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct ip_options_rcu *opt = inet_rsk(req)->opt;
 	struct net *net = sock_net(sk);
-	int flags = inet_sk_flowi_flags(sk) & ~FLOWI_FLAG_PRECOW_METRICS;
+	int flags = inet_sk_flowi_flags(sk);
 
 	if (nocache)
 		flags |= FLOWI_FLAG_RT_NOCACHE;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e376354..d4834e2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1658,7 +1658,7 @@ void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
 	struct rtable *rt;
 
 	flowi4_init_output(&fl4, oif, mark, RT_TOS(iph->tos), RT_SCOPE_UNIVERSE,
-			   protocol, flow_flags | FLOWI_FLAG_PRECOW_METRICS,
+			   protocol, flow_flags,
 			   iph->daddr, iph->saddr, 0, 0);
 	rt = __ip_route_output_key(net, &fl4);
 	if (!IS_ERR(rt)) {
@@ -1836,18 +1836,11 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 {
 	struct inet_peer_base *base;
 	struct inet_peer *peer;
-	int create = 0;
-
-	/* If a peer entry exists for this destination, we must hook
-	 * it up in order to get at cached metrics.
-	 */
-	if (fl4 && (fl4->flowi4_flags & FLOWI_FLAG_PRECOW_METRICS))
-		create = 1;
 
 	base = inetpeer_base_ptr(rt->_peer);
 	BUG_ON(!base);
 
-	peer = inet_getpeer_v4(base, rt->rt_dst, create);
+	peer = inet_getpeer_v4(base, rt->rt_dst, 0);
 	if (peer) {
 		__rt_set_peer(rt, peer);
 		rt->rt_peer_genid = rt_peer_genid();
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0c06847..b7eb51e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1093,7 +1093,7 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = oif;
 	fl6.flowi6_mark = mark;
-	fl6.flowi6_flags = FLOWI_FLAG_PRECOW_METRICS;
+	fl6.flowi6_flags = 0;
 	fl6.daddr = iph->daddr;
 	fl6.saddr = iph->saddr;
 	fl6.flowlabel = (*(__be32 *) iph) & IPV6_FLOWINFO_MASK;
-- 
1.7.10.4
