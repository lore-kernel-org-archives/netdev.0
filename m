From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 1/9] ipv4: split inet_ehashfn to hash functions per compilation unit
Date: Sat, 19 Oct 2013 21:48:51 +0200
Message-ID: <1382212139-20301-2-git-send-email-hannes@stressinduktion.org>
References: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This duplicates a bit of code but let's us easily introduce
separate secret keys later. The separate compilation units are
ipv4/inet_hashtabbles.o, ipv4/udp.o and rds/connection.o.

Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet_sock.h    | 22 ++++++----------------
 net/ipv4/inet_hashtables.c | 21 +++++++++++++++++++++
 net/ipv4/udp.c             | 16 ++++++++++++----
 net/rds/connection.c       |  6 +++---
 4 files changed, 42 insertions(+), 23 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 06da91e..7a6c7f8 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -208,26 +208,16 @@ extern u32 inet_ehash_secret;
 extern u32 ipv6_hash_secret;
 void build_ehash_secret(void);
 
-static inline unsigned int inet_ehashfn(struct net *net,
-					const __be32 laddr, const __u16 lport,
-					const __be32 faddr, const __be16 fport)
+static inline unsigned int __inet_ehashfn(const __be32 laddr,
+					  const __u16 lport,
+					  const __be32 faddr,
+					  const __be16 fport,
+					  u32 initval)
 {
 	return jhash_3words((__force __u32) laddr,
 			    (__force __u32) faddr,
 			    ((__u32) lport) << 16 | (__force __u32)fport,
-			    inet_ehash_secret + net_hash_mix(net));
-}
-
-static inline int inet_sk_ehashfn(const struct sock *sk)
-{
-	const struct inet_sock *inet = inet_sk(sk);
-	const __be32 laddr = inet->inet_rcv_saddr;
-	const __u16 lport = inet->inet_num;
-	const __be32 faddr = inet->inet_daddr;
-	const __be16 fport = inet->inet_dport;
-	struct net *net = sock_net(sk);
-
-	return inet_ehashfn(net, laddr, lport, faddr, fport);
+			    initval);
 }
 
 static inline struct request_sock *inet_reqsk_alloc(struct request_sock_ops *ops)
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index a4b66bb..18aa668 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -24,6 +24,27 @@
 #include <net/secure_seq.h>
 #include <net/ip.h>
 
+static unsigned int inet_ehashfn(struct net *net, const __be32 laddr,
+				 const __u16 lport, const __be32 faddr,
+				 const __be16 fport)
+{
+	return __inet_ehashfn(laddr, lport, faddr, fport,
+			      inet_ehash_secret + net_hash_mix(net));
+}
+
+
+static unsigned int inet_sk_ehashfn(const struct sock *sk)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+	const __be32 laddr = inet->inet_rcv_saddr;
+	const __u16 lport = inet->inet_num;
+	const __be32 faddr = inet->inet_daddr;
+	const __be16 fport = inet->inet_dport;
+	struct net *net = sock_net(sk);
+
+	return inet_ehashfn(net, laddr, lport, faddr, fport);
+}
+
 /*
  * Allocate and initialize a new local port bind bucket.
  * The bindhash mutex for snum's hash chain must be held here.
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9f27bb8..b4437c7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -407,6 +407,14 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 	return score;
 }
 
+static unsigned int udp_ehashfn(struct net *net, const __be32 laddr,
+				 const __u16 lport, const __be32 faddr,
+				 const __be16 fport)
+{
+	return __inet_ehashfn(laddr, lport, faddr, fport,
+			      inet_ehash_secret + net_hash_mix(net));
+}
+
 
 /* called with read_rcu_lock() */
 static struct sock *udp4_lib_lookup2(struct net *net,
@@ -430,8 +438,8 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				hash = inet_ehashfn(net, daddr, hnum,
-						    saddr, sport);
+				hash = udp_ehashfn(net, daddr, hnum,
+						   saddr, sport);
 				matches = 1;
 			}
 		} else if (score == badness && reuseport) {
@@ -511,8 +519,8 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				hash = inet_ehashfn(net, daddr, hnum,
-						    saddr, sport);
+				hash = udp_ehashfn(net, daddr, hnum,
+						   saddr, sport);
 				matches = 1;
 			}
 		} else if (score == badness && reuseport) {
diff --git a/net/rds/connection.c b/net/rds/connection.c
index 642ad42..45e2366 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -52,9 +52,9 @@ static struct kmem_cache *rds_conn_slab;
 static struct hlist_head *rds_conn_bucket(__be32 laddr, __be32 faddr)
 {
 	/* Pass NULL, don't need struct net for hash */
-	unsigned long hash = inet_ehashfn(NULL,
-					  be32_to_cpu(laddr), 0,
-					  be32_to_cpu(faddr), 0);
+	unsigned long hash = __inet_ehashfn(be32_to_cpu(laddr), 0,
+					    be32_to_cpu(faddr), 0,
+					    inet_ehash_secret);
 	return &rds_conn_hash[hash & RDS_CONNECTION_HASH_MASK];
 }
 
-- 
1.8.3.1
