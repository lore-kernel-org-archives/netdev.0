From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 05/11] udp: perform full socket lookup in early demux
Date: Fri, 22 Sep 2017 23:06:29 +0200
Message-ID: <885587b31985cedbb4696c03dd28ba3b39f20ff3.1506114055.git.pabeni@redhat.com>
References: <cover.1506114055.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54374 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752710AbdIVVHG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 17:07:06 -0400
In-Reply-To: <cover.1506114055.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since UDP early demux lookup fetches noref socket references,
we can safely be optimistic about it and set the sk reference
even if the skb is not going to land on such socket, avoiding
the rx dst cache usage for unconnected unicast sockets.

This avoids a second lookup for unconnected sockets, and clean
up a bit the whole udp early demux code.

After this change, on hosts not acting as routers, the UDP
early demux never affect negatively the receive performances,
while before this change UDP early demux caused measurable
performance impact for unconnected sockets.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/udp.h |  2 ++
 net/ipv4/udp.c      | 62 +++++++++++++++++++----------------------------------
 net/ipv6/udp.c      | 57 ++++++++++++------------------------------------
 3 files changed, 38 insertions(+), 83 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index eaea63bc79bb..9c68b57543cc 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -92,6 +92,8 @@ static inline struct udp_sock *udp_sk(const struct sock *sk)
 	return (struct udp_sock *)sk;
 }
 
+void udp_set_skb_rx_dst(struct sock *sk, struct sk_buff *skb, u32 cookie);
+
 static inline void udp_set_no_check6_tx(struct sock *sk, bool val)
 {
 	udp_sk(sk)->no_check6_tx = val;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ba49d5aa9f09..5cbbd78024dc 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2043,6 +2043,11 @@ static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
 							 inet_compute_pseudo);
 }
 
+static bool udp_use_rx_dst_cache(struct sock *sk, struct sk_buff *skb)
+{
+	return sk->sk_state == TCP_ESTABLISHED || skb->pkt_type != PACKET_HOST;
+}
+
 /*
  *	All we need to do is get the socket, and then do a checksum.
  */
@@ -2088,8 +2093,8 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		struct dst_entry *dst = skb_dst(skb);
 		int ret;
 
-		if (unlikely(sk->sk_rx_dst != dst))
-			udp_sk_rx_dst_set(sk, dst);
+		if (udp_use_rx_dst_cache(sk, skb))
+			dst_update(&sk->sk_rx_dst, dst);
 
 		ret = udp_queue_rcv_skb(sk, skb);
 		if (!noref_sk)
@@ -2196,42 +2201,28 @@ static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
 	return result;
 }
 
-/* For unicast we should only early demux connected sockets or we can
- * break forwarding setups.  The chains here can be long so only check
- * if the first socket is an exact match and if not move on.
- */
-static struct sock *__udp4_lib_demux_lookup(struct net *net,
-					    __be16 loc_port, __be32 loc_addr,
-					    __be16 rmt_port, __be32 rmt_addr,
-					    int dif, int sdif)
+void udp_set_skb_rx_dst(struct sock *sk, struct sk_buff *skb, u32 cookie)
 {
-	unsigned short hnum = ntohs(loc_port);
-	unsigned int hash2 = udp4_portaddr_hash(net, loc_addr, hnum);
-	unsigned int slot2 = hash2 & udp_table.mask;
-	struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
-	INET_ADDR_COOKIE(acookie, rmt_addr, loc_addr);
-	const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
-	struct sock *sk;
+	struct dst_entry *dst = dst_access(&sk->sk_rx_dst, cookie);
 
-	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
-		if (INET_MATCH(sk, net, acookie, rmt_addr,
-			       loc_addr, ports, dif, sdif))
-			return sk;
-		/* Only check first socket in chain */
-		break;
+	if (dst) {
+		/* set noref for now.
+		 * any place which wants to hold dst has to call
+		 * dst_hold_safe()
+		 */
+		skb_dst_set_noref(skb, dst);
 	}
-	return NULL;
 }
+EXPORT_SYMBOL_GPL(udp_set_skb_rx_dst);
 
 void udp_v4_early_demux(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
+	int dif = skb->dev->ifindex;
+	int sdif = inet_sdif(skb);
 	const struct iphdr *iph;
 	const struct udphdr *uh;
 	struct sock *sk = NULL;
-	struct dst_entry *dst;
-	int dif = skb->dev->ifindex;
-	int sdif = inet_sdif(skb);
 	int ours;
 
 	/* validate the packet */
@@ -2260,25 +2251,16 @@ void udp_v4_early_demux(struct sk_buff *skb)
 						   uh->source, iph->saddr,
 						   dif, sdif);
 	} else if (skb->pkt_type == PACKET_HOST) {
-		sk = __udp4_lib_demux_lookup(net, uh->dest, iph->daddr,
-					     uh->source, iph->saddr, dif, sdif);
+		sk = __udp4_lib_lookup(net, iph->saddr, uh->source, iph->daddr,
+				       uh->dest, dif, sdif, &udp_table, skb);
 	}
 
 	if (!sk)
 		return;
 
 	skb_set_noref_sk(skb, sk);
-	dst = READ_ONCE(sk->sk_rx_dst);
-
-	if (dst)
-		dst = dst_check(dst, 0);
-	if (dst) {
-		/* set noref for now.
-		 * any place which wants to hold dst has to call
-		 * dst_hold_safe()
-		 */
-		skb_dst_set_noref(skb, dst);
-	}
+	if (udp_use_rx_dst_cache(sk, skb))
+		udp_set_skb_rx_dst(sk, skb, 0);
 }
 
 int udp_rcv(struct sk_buff *skb)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8f62392c4c35..67d340679c3a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -773,13 +773,18 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 
 static void udp6_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
 {
-	if (udp_sk_rx_dst_set(sk, dst)) {
+	if (unlikely(dst_update(&sk->sk_rx_dst, dst))) {
 		const struct rt6_info *rt = (const struct rt6_info *)dst;
 
 		inet6_sk(sk)->rx_dst_cookie = rt6_get_cookie(rt);
 	}
 }
 
+static bool udp6_use_rx_dst_cache(struct sock *sk)
+{
+	return sk->sk_state == TCP_ESTABLISHED;
+}
+
 int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		   int proto)
 {
@@ -830,7 +835,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		struct dst_entry *dst = skb_dst(skb);
 		int ret;
 
-		if (unlikely(sk->sk_rx_dst != dst))
+		if (udp6_use_rx_dst_cache(sk))
 			udp6_sk_rx_dst_set(sk, dst);
 
 		ret = udpv6_queue_rcv_skb(sk, skb);
@@ -905,37 +910,13 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	return 0;
 }
 
-
-static struct sock *__udp6_lib_demux_lookup(struct net *net,
-			__be16 loc_port, const struct in6_addr *loc_addr,
-			__be16 rmt_port, const struct in6_addr *rmt_addr,
-			int dif, int sdif)
-{
-	unsigned short hnum = ntohs(loc_port);
-	unsigned int hash2 = udp6_portaddr_hash(net, loc_addr, hnum);
-	unsigned int slot2 = hash2 & udp_table.mask;
-	struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
-	const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
-	struct sock *sk;
-
-	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
-		if (sk->sk_state == TCP_ESTABLISHED &&
-		    INET6_MATCH(sk, net, rmt_addr, loc_addr, ports, dif, sdif))
-			return sk;
-		/* Only check first socket in chain */
-		break;
-	}
-	return NULL;
-}
-
 static void udp_v6_early_demux(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
-	const struct udphdr *uh;
-	struct sock *sk;
-	struct dst_entry *dst;
 	int dif = skb->dev->ifindex;
 	int sdif = inet6_sdif(skb);
+	const struct udphdr *uh;
+	struct sock *sk;
 
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) +
 	    sizeof(struct udphdr)))
@@ -944,10 +925,9 @@ static void udp_v6_early_demux(struct sk_buff *skb)
 	uh = udp_hdr(skb);
 
 	if (skb->pkt_type == PACKET_HOST)
-		sk = __udp6_lib_demux_lookup(net, uh->dest,
-					     &ipv6_hdr(skb)->daddr,
-					     uh->source, &ipv6_hdr(skb)->saddr,
-					     dif, sdif);
+		sk = __udp6_lib_lookup(net, &ipv6_hdr(skb)->saddr, uh->source,
+				       &ipv6_hdr(skb)->daddr, uh->dest, dif,
+				       sdif, &udp_table, skb);
 	else
 		return;
 
@@ -955,17 +935,8 @@ static void udp_v6_early_demux(struct sk_buff *skb)
 		return;
 
 	skb_set_noref_sk(skb, sk);
-	dst = READ_ONCE(sk->sk_rx_dst);
-
-	if (dst)
-		dst = dst_check(dst, inet6_sk(sk)->rx_dst_cookie);
-	if (dst) {
-		/* set noref for now.
-		 * any place which wants to hold dst has to call
-		 * dst_hold_safe()
-		 */
-		skb_dst_set_noref(skb, dst);
-	}
+	if (udp6_use_rx_dst_cache(sk))
+		udp_set_skb_rx_dst(sk, skb, inet6_sk(sk)->rx_dst_cookie);
 }
 
 static __inline__ int udpv6_rcv(struct sk_buff *skb)
-- 
2.13.5
