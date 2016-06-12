From: Su Xuemin <suxm@chinanetcenter.com>
Subject: [PATCH v3] udp reuseport: fix packet of same flow hashed to different socket
Date: Sun, 12 Jun 2016 20:43:27 +0800
Message-ID: <1465735407-8345-1-git-send-email-suxm@chinanetcenter.com>
Cc: linux-kernel@vger.kernel.org, suxm@chinanetcenter.com,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Su, Xuemin" <suxm@chinanetcenter.com>

There is a corner case in which udp packets belonging to a same
flow are hashed to different socket when hslot->count changes from 10
to 11:

1) When hslot->count <= 10, __udp_lib_lookup() searches udp_table->hash,
and always passes 'daddr' to udp_ehashfn().

2) When hslot->count > 10, __udp_lib_lookup() searches udp_table->hash2,
but may pass 'INADDR_ANY' to udp_ehashfn() if the sockets are bound to
INADDR_ANY instead of some specific addr.

That means when hslot->count changes from 10 to 11, the hash calculated by
udp_ehashfn() is also changed, and the udp packets belonging to a same
flow will be hashed to different socket.

This is easily reproduced:
1) Create 10 udp sockets and bind all of them to 0.0.0.0:40000.
2) From the same host send udp packets to 127.0.0.1:40000, record the
socket index which receives the packets.
3) Create 1 more udp socket and bind it to 0.0.0.0:44096. The number 44096
is 40000 + UDP_HASH_SIZE(4096), this makes the new socket put into the
same hslot as the aformentioned 10 sockets, and makes the hslot->count
change from 10 to 11.
4) From the same host send udp packets to 127.0.0.1:40000, and the socket
index which receives the packets will be different from the one received
in step 2.
This should not happen as the socket bound to 0.0.0.0:44096 should not
change the behavior of the sockets bound to 0.0.0.0:40000.

It's the same case for IPv6, and this patch also fixes that.

Signed-off-by: Su, Xuemin <suxm@chinanetcenter.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
I use this tree to generate the patch:
  git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

 net/ipv4/udp.c | 68 ++++++++++++----------------------------------------------
 net/ipv6/udp.c | 66 ++++++++++++--------------------------------------------
 2 files changed, 28 insertions(+), 106 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0ff31d9..586f1b0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -391,9 +391,9 @@ int udp_v4_get_port(struct sock *sk, unsigned short snum)
 	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal, hash2_nulladdr);
 }
 
-static inline int compute_score(struct sock *sk, struct net *net,
-				__be32 saddr, unsigned short hnum, __be16 sport,
-				__be32 daddr, __be16 dport, int dif)
+static int compute_score(struct sock *sk, struct net *net,
+			 __be32 saddr, __be16 sport,
+			 __be32 daddr, unsigned short hnum, int dif)
 {
 	int score;
 	struct inet_sock *inet;
@@ -434,52 +434,6 @@ static inline int compute_score(struct sock *sk, struct net *net,
 	return score;
 }
 
-/*
- * In this second variant, we check (daddr, dport) matches (inet_rcv_sadd, inet_num)
- */
-static inline int compute_score2(struct sock *sk, struct net *net,
-				 __be32 saddr, __be16 sport,
-				 __be32 daddr, unsigned int hnum, int dif)
-{
-	int score;
-	struct inet_sock *inet;
-
-	if (!net_eq(sock_net(sk), net) ||
-	    ipv6_only_sock(sk))
-		return -1;
-
-	inet = inet_sk(sk);
-
-	if (inet->inet_rcv_saddr != daddr ||
-	    inet->inet_num != hnum)
-		return -1;
-
-	score = (sk->sk_family == PF_INET) ? 2 : 1;
-
-	if (inet->inet_daddr) {
-		if (inet->inet_daddr != saddr)
-			return -1;
-		score += 4;
-	}
-
-	if (inet->inet_dport) {
-		if (inet->inet_dport != sport)
-			return -1;
-		score += 4;
-	}
-
-	if (sk->sk_bound_dev_if) {
-		if (sk->sk_bound_dev_if != dif)
-			return -1;
-		score += 4;
-	}
-
-	if (sk->sk_incoming_cpu == raw_smp_processor_id())
-		score++;
-
-	return score;
-}
-
 static u32 udp_ehashfn(const struct net *net, const __be32 laddr,
 		       const __u16 lport, const __be32 faddr,
 		       const __be16 fport)
@@ -492,7 +446,7 @@ static u32 udp_ehashfn(const struct net *net, const __be32 laddr,
 			      udp_ehash_secret + net_hash_mix(net));
 }
 
-/* called with read_rcu_lock() */
+/* called with rcu_read_lock() */
 static struct sock *udp4_lib_lookup2(struct net *net,
 		__be32 saddr, __be16 sport,
 		__be32 daddr, unsigned int hnum, int dif,
@@ -506,7 +460,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 	result = NULL;
 	badness = 0;
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
-		score = compute_score2(sk, net, saddr, sport,
+		score = compute_score(sk, net, saddr, sport,
 				      daddr, hnum, dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
@@ -556,14 +510,20 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 					  daddr, hnum, dif,
 					  hslot2, slot2, skb);
 		if (!result) {
+			unsigned int old = hash2;
 			hash2 = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
+
+			/* avoid search the same slot again. */
+			if (unlikely(old == hash2))
+				return result;
+
 			slot2 = hash2 & udptable->mask;
 			hslot2 = &udptable->hash2[slot2];
 			if (hslot->count < hslot2->count)
 				goto begin;
 
 			result = udp4_lib_lookup2(net, saddr, sport,
-						  htonl(INADDR_ANY), hnum, dif,
+						  daddr, hnum, dif,
 						  hslot2, slot2, skb);
 		}
 		return result;
@@ -572,8 +532,8 @@ begin:
 	result = NULL;
 	badness = 0;
 	sk_for_each_rcu(sk, &hslot->head) {
-		score = compute_score(sk, net, saddr, hnum, sport,
-				      daddr, dport, dif);
+		score = compute_score(sk, net, saddr, sport,
+				      daddr, hnum, dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f421c9f..7c833dd 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -115,11 +115,10 @@ static void udp_v6_rehash(struct sock *sk)
 	udp_lib_rehash(sk, new_hash);
 }
 
-static inline int compute_score(struct sock *sk, struct net *net,
-				unsigned short hnum,
-				const struct in6_addr *saddr, __be16 sport,
-				const struct in6_addr *daddr, __be16 dport,
-				int dif)
+static int compute_score(struct sock *sk, struct net *net,
+			 const struct in6_addr *saddr, __be16 sport,
+			 const struct in6_addr *daddr, unsigned short hnum,
+			 int dif)
 {
 	int score;
 	struct inet_sock *inet;
@@ -162,50 +161,7 @@ static inline int compute_score(struct sock *sk, struct net *net,
 	return score;
 }
 
-static inline int compute_score2(struct sock *sk, struct net *net,
-				 const struct in6_addr *saddr, __be16 sport,
-				 const struct in6_addr *daddr,
-				 unsigned short hnum, int dif)
-{
-	int score;
-	struct inet_sock *inet;
-
-	if (!net_eq(sock_net(sk), net) ||
-	    udp_sk(sk)->udp_port_hash != hnum ||
-	    sk->sk_family != PF_INET6)
-		return -1;
-
-	if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, daddr))
-		return -1;
-
-	score = 0;
-	inet = inet_sk(sk);
-
-	if (inet->inet_dport) {
-		if (inet->inet_dport != sport)
-			return -1;
-		score++;
-	}
-
-	if (!ipv6_addr_any(&sk->sk_v6_daddr)) {
-		if (!ipv6_addr_equal(&sk->sk_v6_daddr, saddr))
-			return -1;
-		score++;
-	}
-
-	if (sk->sk_bound_dev_if) {
-		if (sk->sk_bound_dev_if != dif)
-			return -1;
-		score++;
-	}
-
-	if (sk->sk_incoming_cpu == raw_smp_processor_id())
-		score++;
-
-	return score;
-}
-
-/* called with read_rcu_lock() */
+/* called with rcu_read_lock() */
 static struct sock *udp6_lib_lookup2(struct net *net,
 		const struct in6_addr *saddr, __be16 sport,
 		const struct in6_addr *daddr, unsigned int hnum, int dif,
@@ -219,7 +175,7 @@ static struct sock *udp6_lib_lookup2(struct net *net,
 	result = NULL;
 	badness = -1;
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
-		score = compute_score2(sk, net, saddr, sport,
+		score = compute_score(sk, net, saddr, sport,
 				      daddr, hnum, dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
@@ -270,14 +226,20 @@ struct sock *__udp6_lib_lookup(struct net *net,
 					  daddr, hnum, dif,
 					  hslot2, slot2, skb);
 		if (!result) {
+			unsigned int old = hash2;
 			hash2 = udp6_portaddr_hash(net, &in6addr_any, hnum);
+
+			/* avoid search the same slot again. */
+			if (unlikely(old == hash2))
+				return result;
+
 			slot2 = hash2 & udptable->mask;
 			hslot2 = &udptable->hash2[slot2];
 			if (hslot->count < hslot2->count)
 				goto begin;
 
 			result = udp6_lib_lookup2(net, saddr, sport,
-						  &in6addr_any, hnum, dif,
+						  daddr, hnum, dif,
 						  hslot2, slot2, skb);
 		}
 		return result;
@@ -286,7 +248,7 @@ begin:
 	result = NULL;
 	badness = -1;
 	sk_for_each_rcu(sk, &hslot->head) {
-		score = compute_score(sk, net, hnum, saddr, sport, daddr, dport, dif);
+		score = compute_score(sk, net, saddr, sport, daddr, hnum, dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-- 
1.8.3.1
