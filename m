From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] udp: Neaten and reduce size of compute_score
 functions
Date: Mon, 01 Dec 2014 17:39:01 -0800
Message-ID: <1417484341.4894.6.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The compute_score functions are a bit difficult to read.

Neaten them a bit to reduce object sizes and make them a
bit more intelligible.

Return early to avoid indentation and avoid unnecessary
initializations.

(allyesconfig, but w/ -O2 and no profiling)

$ size net/ipv[46]/udp.o.*
   text	   data	    bss	    dec	    hex	filename
  28680	   1184	     25	  29889	   74c1	net/ipv4/udp.o.new
  28756	   1184	     25	  29965	   750d	net/ipv4/udp.o.old
  17600	   1010	      2	  18612	   48b4	net/ipv6/udp.o.new
  17632	   1010	      2	  18644	   48d4	net/ipv6/udp.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/udp.c | 111 +++++++++++++++++++++++++++++++-------------------------
 net/ipv6/udp.c | 113 ++++++++++++++++++++++++++++++++-------------------------
 2 files changed, 125 insertions(+), 99 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b2d6068..227e6ad 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -336,38 +336,45 @@ int udp_v4_get_port(struct sock *sk, unsigned short snum)
 	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal, hash2_nulladdr);
 }
 
-static inline int compute_score(struct sock *sk, struct net *net, __be32 saddr,
-			 unsigned short hnum,
-			 __be16 sport, __be32 daddr, __be16 dport, int dif)
+static inline int compute_score(struct sock *sk, struct net *net,
+				__be32 saddr, unsigned short hnum, __be16 sport,
+				__be32 daddr, __be16 dport, int dif)
 {
-	int score = -1;
+	int score;
+	struct inet_sock *inet;
 
-	if (net_eq(sock_net(sk), net) && udp_sk(sk)->udp_port_hash == hnum &&
-			!ipv6_only_sock(sk)) {
-		struct inet_sock *inet = inet_sk(sk);
+	if (!(net_eq(sock_net(sk), net) &&
+	      udp_sk(sk)->udp_port_hash == hnum &&
+	      !ipv6_only_sock(sk)))
+		return -1;
 
-		score = (sk->sk_family == PF_INET ? 2 : 1);
-		if (inet->inet_rcv_saddr) {
-			if (inet->inet_rcv_saddr != daddr)
-				return -1;
-			score += 4;
-		}
-		if (inet->inet_daddr) {
-			if (inet->inet_daddr != saddr)
-				return -1;
-			score += 4;
-		}
-		if (inet->inet_dport) {
-			if (inet->inet_dport != sport)
-				return -1;
-			score += 4;
-		}
-		if (sk->sk_bound_dev_if) {
-			if (sk->sk_bound_dev_if != dif)
-				return -1;
-			score += 4;
-		}
+	score = (sk->sk_family == PF_INET) ? 2 : 1;
+	inet = inet_sk(sk);
+
+	if (inet->inet_rcv_saddr) {
+		if (inet->inet_rcv_saddr != daddr)
+			return -1;
+		score += 4;
+	}
+
+	if (inet->inet_daddr) {
+		if (inet->inet_daddr != saddr)
+			return -1;
+		score += 4;
+	}
+
+	if (inet->inet_dport) {
+		if (inet->inet_dport != sport)
+			return -1;
+		score += 4;
+	}
+
+	if (sk->sk_bound_dev_if) {
+		if (sk->sk_bound_dev_if != dif)
+			return -1;
+		score += 4;
 	}
+
 	return score;
 }
 
@@ -378,33 +385,39 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 				 __be32 saddr, __be16 sport,
 				 __be32 daddr, unsigned int hnum, int dif)
 {
-	int score = -1;
+	int score;
+	struct inet_sock *inet;
 
-	if (net_eq(sock_net(sk), net) && !ipv6_only_sock(sk)) {
-		struct inet_sock *inet = inet_sk(sk);
+	if (!(net_eq(sock_net(sk), net) && !ipv6_only_sock(sk)))
+		return -1;
 
-		if (inet->inet_rcv_saddr != daddr)
+	inet = inet_sk(sk);
+
+	if (inet->inet_rcv_saddr != daddr)
+		return -1;
+	if (inet->inet_num != hnum)
+		return -1;
+
+	score = (sk->sk_family == PF_INET) ? 2 : 1;
+
+	if (inet->inet_daddr) {
+		if (inet->inet_daddr != saddr)
 			return -1;
-		if (inet->inet_num != hnum)
+		score += 4;
+	}
+
+	if (inet->inet_dport) {
+		if (inet->inet_dport != sport)
 			return -1;
+		score += 4;
+	}
 
-		score = (sk->sk_family == PF_INET ? 2 : 1);
-		if (inet->inet_daddr) {
-			if (inet->inet_daddr != saddr)
-				return -1;
-			score += 4;
-		}
-		if (inet->inet_dport) {
-			if (inet->inet_dport != sport)
-				return -1;
-			score += 4;
-		}
-		if (sk->sk_bound_dev_if) {
-			if (sk->sk_bound_dev_if != dif)
-				return -1;
-			score += 4;
-		}
+	if (sk->sk_bound_dev_if) {
+		if (sk->sk_bound_dev_if != dif)
+			return -1;
+		score += 4;
 	}
+
 	return score;
 }
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 7cfb5d7..0b9644a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -148,72 +148,85 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				const struct in6_addr *daddr, __be16 dport,
 				int dif)
 {
-	int score = -1;
+	int score;
+	struct inet_sock *inet;
 
-	if (net_eq(sock_net(sk), net) && udp_sk(sk)->udp_port_hash == hnum &&
-			sk->sk_family == PF_INET6) {
-		struct inet_sock *inet = inet_sk(sk);
+	if (!(net_eq(sock_net(sk), net) &&
+	      udp_sk(sk)->udp_port_hash == hnum &&
+	      sk->sk_family == PF_INET6))
+		return -1;
 
-		score = 0;
-		if (inet->inet_dport) {
-			if (inet->inet_dport != sport)
-				return -1;
-			score++;
-		}
-		if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
-			if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, daddr))
-				return -1;
-			score++;
-		}
-		if (!ipv6_addr_any(&sk->sk_v6_daddr)) {
-			if (!ipv6_addr_equal(&sk->sk_v6_daddr, saddr))
-				return -1;
-			score++;
-		}
-		if (sk->sk_bound_dev_if) {
-			if (sk->sk_bound_dev_if != dif)
-				return -1;
-			score++;
-		}
+	score = 0;
+	inet = inet_sk(sk);
+
+	if (inet->inet_dport) {
+		if (inet->inet_dport != sport)
+			return -1;
+		score++;
 	}
+
+	if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
+		if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, daddr))
+			return -1;
+		score++;
+	}
+
+	if (!ipv6_addr_any(&sk->sk_v6_daddr)) {
+		if (!ipv6_addr_equal(&sk->sk_v6_daddr, saddr))
+			return -1;
+		score++;
+	}
+
+	if (sk->sk_bound_dev_if) {
+		if (sk->sk_bound_dev_if != dif)
+			return -1;
+		score++;
+	}
+
 	return score;
 }
 
 #define SCORE2_MAX (1 + 1 + 1)
 static inline int compute_score2(struct sock *sk, struct net *net,
-				const struct in6_addr *saddr, __be16 sport,
-				const struct in6_addr *daddr, unsigned short hnum,
-				int dif)
+				 const struct in6_addr *saddr, __be16 sport,
+				 const struct in6_addr *daddr,
+				 unsigned short hnum, int dif)
 {
-	int score = -1;
+	int score;
+	struct inet_sock *inet;
 
-	if (net_eq(sock_net(sk), net) && udp_sk(sk)->udp_port_hash == hnum &&
-			sk->sk_family == PF_INET6) {
-		struct inet_sock *inet = inet_sk(sk);
+	if (!(net_eq(sock_net(sk), net) &&
+	      udp_sk(sk)->udp_port_hash == hnum &&
+	      sk->sk_family == PF_INET6))
+		return -1;
 
-		if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, daddr))
+	if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, daddr))
+		return -1;
+
+	score = 0;
+	inet = inet_sk(sk);
+
+	if (inet->inet_dport) {
+		if (inet->inet_dport != sport)
 			return -1;
-		score = 0;
-		if (inet->inet_dport) {
-			if (inet->inet_dport != sport)
-				return -1;
-			score++;
-		}
-		if (!ipv6_addr_any(&sk->sk_v6_daddr)) {
-			if (!ipv6_addr_equal(&sk->sk_v6_daddr, saddr))
-				return -1;
-			score++;
-		}
-		if (sk->sk_bound_dev_if) {
-			if (sk->sk_bound_dev_if != dif)
-				return -1;
-			score++;
-		}
+		score++;
 	}
+
+	if (!ipv6_addr_any(&sk->sk_v6_daddr)) {
+		if (!ipv6_addr_equal(&sk->sk_v6_daddr, saddr))
+			return -1;
+		score++;
+	}
+
+	if (sk->sk_bound_dev_if) {
+		if (sk->sk_bound_dev_if != dif)
+			return -1;
+		score++;
+	}
+
 	return score;
 }
 
-
 /* called with read_rcu_lock() */
 static struct sock *udp6_lib_lookup2(struct net *net,
 		const struct in6_addr *saddr, __be16 sport,
