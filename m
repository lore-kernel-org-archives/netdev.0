From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 4/8] ipv4: udp: optimize unicast RX path
Date: Sun, 08 Nov 2009 21:18:11 +0100
Message-ID: <4AF72783.3040501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46195 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbZKHUSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 15:18:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We first locate the (local port) hash chain head
If few sockets are in this chain, we proceed with previous lookup algo.

If too many sockets are listed, we take a look at the secondary
(port, address) hash chain we added in previous patch.

We choose the shortest chain and proceed with a RCU lookup on the elected chain.

But, if we chose (port, address) chain, and fail to find a socket on given address,
 we must try another lookup on (port, INADDR_ANY) chain to find socket not bound
to a particular IP.

-> No extra cost for typical setups, where the first lookup will probabbly
be performed.

RCU lookups everywhere, we dont acquire spinlock.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/udp.c |  115 +++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 112 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5f04216..dd7f3d2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -298,6 +298,91 @@ static inline int compute_score(struct sock *sk, struct net *net, __be32 saddr,
 	return score;
 }
 
+/*
+ * In this second variant, we check (daddr, dport) matches (inet_rcv_sadd, inet_num)
+ */
+#define SCORE2_MAX (1 + 2 + 2 + 2)
+static inline int compute_score2(struct sock *sk, struct net *net,
+				 __be32 saddr, __be16 sport,
+				 __be32 daddr, unsigned int hnum, int dif)
+{
+	int score = -1;
+
+	if (net_eq(sock_net(sk), net) && !ipv6_only_sock(sk)) {
+		struct inet_sock *inet = inet_sk(sk);
+
+		if (inet->inet_rcv_saddr != daddr)
+			return -1;
+		if (inet->inet_num != hnum)
+			return -1;
+
+		score = (sk->sk_family == PF_INET ? 1 : 0);
+		if (inet->inet_daddr) {
+			if (inet->inet_daddr != saddr)
+				return -1;
+			score += 2;
+		}
+		if (inet->inet_dport) {
+			if (inet->inet_dport != sport)
+				return -1;
+			score += 2;
+		}
+		if (sk->sk_bound_dev_if) {
+			if (sk->sk_bound_dev_if != dif)
+				return -1;
+			score += 2;
+		}
+	}
+	return score;
+}
+
+#define udp_portaddr_for_each_entry_rcu(__sk, node, list) \
+	hlist_nulls_for_each_entry_rcu(__sk, node, list, __sk_common.skc_portaddr_node)
+
+/* called with read_rcu_lock() */
+static struct sock *udp4_lib_lookup2(struct net *net,
+		__be32 saddr, __be16 sport,
+		__be32 daddr, unsigned int hnum, int dif,
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
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
@@ -308,11 +393,35 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
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
+		hash2 = udp4_portaddr_hash(net, daddr, hnum);
+		slot2 = hash2 & udptable->mask;
+		hslot2 = &udptable->hash2[slot2];
+		if (hslot->count < hslot2->count)
+			goto begin;
+
+		result = udp4_lib_lookup2(net, saddr, sport,
+					  daddr, hnum, dif,
+					  hslot2, slot2);
+		if (!result) {
+			hash2 = udp4_portaddr_hash(net, INADDR_ANY, hnum);
+			slot2 = hash2 & udptable->mask;
+			hslot2 = &udptable->hash2[slot2];
+			if (hslot->count < hslot2->count)
+				goto begin;
+
+			result = udp4_lib_lookup2(net, INADDR_ANY, sport,
+						  daddr, hnum, dif,
+						  hslot2, slot2);
+		}
+		rcu_read_unlock();
+		return result;
+	}
 begin:
 	result = NULL;
 	badness = -1;
@@ -329,7 +438,7 @@ begin:
 	 * not the expected one, we must restart lookup.
 	 * We probably met an item that was moved to another chain.
 	 */
-	if (get_nulls_value(node) != hash)
+	if (get_nulls_value(node) != slot)
 		goto begin;
 
 	if (result) {
