From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 5/8] ipv6: udp: optimize unicast RX path
Date: Sun, 08 Nov 2009 21:18:30 +0100
Message-ID: <4AF72796.3090209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46199 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186AbZKHUSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 15:18:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We first locate the (local port) hash chain head
If few sockets are in this chain, we proceed with previous lookup algo.

If too many sockets are listed, we take a look at the secondary
(port, address) hash chain.

We choose the shortest chain and proceed with a RCU lookup on the elected chain.

But, if we chose (port, address) chain, and fail to find a socket on given address,
 we must try another lookup on (port, in6addr_any) chain to find sockets not bound
to a particular IP.

-> No extra cost for typical setups, where the first lookup will probabbly
be performed.

RCU lookups everywhere, we dont acquire spinlock.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/udp.c |  112 +++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 109 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e5fadd..c5b0451 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -146,6 +146,88 @@ static inline int compute_score(struct sock *sk, struct net *net,
 	return score;
 }
 
+#define SCORE2_MAX (1 + 1 + 1)
+static inline int compute_score2(struct sock *sk, struct net *net,
+				const struct in6_addr *saddr, __be16 sport,
+				const struct in6_addr *daddr, unsigned short hnum,
+				int dif)
+{
+	int score = -1;
+
+	if (net_eq(sock_net(sk), net) && udp_sk(sk)->udp_port_hash == hnum &&
+			sk->sk_family == PF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
+
+		if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
+			return -1;
+		score = 0;
+		if (inet->inet_dport) {
+			if (inet->inet_dport != sport)
+				return -1;
+			score++;
+		}
+		if (!ipv6_addr_any(&np->daddr)) {
+			if (!ipv6_addr_equal(&np->daddr, saddr))
+				return -1;
+			score++;
+		}
+		if (sk->sk_bound_dev_if) {
+			if (sk->sk_bound_dev_if != dif)
+				return -1;
+			score++;
+		}
+	}
+	return score;
+}
+
+#define udp_portaddr_for_each_entry_rcu(__sk, node, list) \
+	hlist_nulls_for_each_entry_rcu(__sk, node, list, __sk_common.skc_portaddr_node)
+
+/* called with read_rcu_lock() */
+static struct sock *udp6_lib_lookup2(struct net *net,
+		const struct in6_addr *saddr, __be16 sport,
+		const struct in6_addr *daddr, unsigned int hnum, int dif,
+		struct udp_hslot *hslot2, unsigned int slot2)
+{
+	struct sock *sk, *result;
+	struct hlist_nulls_node *node;
+	int score, badness;
+
+begin:
+	result = NULL;
+	badness = -1;
+	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
+		score = compute_score2(sk, net, saddr, sport,
+				      daddr, hnum, dif);
+		if (score > badness) {
+			result = sk;
+			badness = score;
+			if (score == SCORE2_MAX)
+				goto exact_match;
+		}
+	}
+	/*
+	 * if the nulls value we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 * We probably met an item that was moved to another chain.
+	 */
+	if (get_nulls_value(node) != slot2)
+		goto begin;
+
+	if (result) {
+exact_match:
+		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
+			result = NULL;
+		else if (unlikely(compute_score2(result, net, saddr, sport,
+				  daddr, hnum, dif) < badness)) {
+			sock_put(result);
+			goto begin;
+		}
+	}
+	return result;
+}
+
 static struct sock *__udp6_lib_lookup(struct net *net,
 				      struct in6_addr *saddr, __be16 sport,
 				      struct in6_addr *daddr, __be16 dport,
@@ -154,11 +236,35 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
 	unsigned short hnum = ntohs(dport);
-	unsigned int hash = udp_hashfn(net, hnum, udptable->mask);
-	struct udp_hslot *hslot = &udptable->hash[hash];
+	unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
+	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
 	int score, badness;
 
 	rcu_read_lock();
+	if (hslot->count > 10) {
+		hash2 = udp6_portaddr_hash(net, daddr, hnum);
+		slot2 = hash2 & udptable->mask;
+		hslot2 = &udptable->hash2[slot2];
+		if (hslot->count < hslot2->count)
+			goto begin;
+
+		result = udp6_lib_lookup2(net, saddr, sport,
+					  daddr, hnum, dif,
+					  hslot2, slot2);
+		if (!result) {
+			hash2 = udp6_portaddr_hash(net, &in6addr_any, hnum);
+			slot2 = hash2 & udptable->mask;
+			hslot2 = &udptable->hash2[slot2];
+			if (hslot->count < hslot2->count)
+				goto begin;
+
+			result = udp6_lib_lookup2(net, &in6addr_any, sport,
+						  daddr, hnum, dif,
+						  hslot2, slot2);
+		}
+		rcu_read_unlock();
+		return result;
+	}
 begin:
 	result = NULL;
 	badness = -1;
@@ -174,7 +280,7 @@ begin:
 	 * not the expected one, we must restart lookup.
 	 * We probably met an item that was moved to another chain.
 	 */
-	if (get_nulls_value(node) != hash)
+	if (get_nulls_value(node) != slot)
 		goto begin;
 
 	if (result) {
