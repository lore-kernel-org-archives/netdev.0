From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 2/9] ipv6: split inet6_ehashfn to hash functions per compilation unit
Date: Sat, 19 Oct 2013 21:48:52 +0200
Message-ID: <1382212139-20301-3-git-send-email-hannes@stressinduktion.org>
References: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45258 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab3JSTtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 15:49:03 -0400
In-Reply-To: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch splits the inet6_ehashfn into separate ones in
ipv6/inet6_hashtables.o and ipv6/udp.o to ease the introduction of
seperate secrets keys later.

Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet6_hashtables.h | 28 +++++++---------------------
 include/net/ipv6.h             |  4 ++--
 net/ipv6/inet6_hashtables.c    | 24 ++++++++++++++++++++++++
 net/ipv6/udp.c                 | 20 ++++++++++++++++----
 4 files changed, 49 insertions(+), 27 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index a105d1a..ae06135 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -28,28 +28,14 @@
 
 struct inet_hashinfo;
 
-static inline unsigned int inet6_ehashfn(struct net *net,
-				const struct in6_addr *laddr, const u16 lport,
-				const struct in6_addr *faddr, const __be16 fport)
+static inline unsigned int __inet6_ehashfn(const u32 lhash,
+				    const u16 lport,
+				    const u32 fhash,
+				    const __be16 fport,
+				    const u32 initval)
 {
-	u32 ports = (((u32)lport) << 16) | (__force u32)fport;
-
-	return jhash_3words((__force u32)laddr->s6_addr32[3],
-			    ipv6_addr_jhash(faddr),
-			    ports,
-			    inet_ehash_secret + net_hash_mix(net));
-}
-
-static inline int inet6_sk_ehashfn(const struct sock *sk)
-{
-	const struct inet_sock *inet = inet_sk(sk);
-	const struct in6_addr *laddr = &sk->sk_v6_rcv_saddr;
-	const struct in6_addr *faddr = &sk->sk_v6_daddr;
-	const __u16 lport = inet->inet_num;
-	const __be16 fport = inet->inet_dport;
-	struct net *net = sock_net(sk);
-
-	return inet6_ehashfn(net, laddr, lport, faddr, fport);
+	const u32 ports = (((u32)lport) << 16) | (__force u32)fport;
+	return jhash_3words(lhash, fhash, ports, initval);
 }
 
 int __inet6_hash(struct sock *sk, struct inet_timewait_sock *twp);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index fe1c7f6..a35055f 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -539,14 +539,14 @@ static inline u32 ipv6_addr_hash(const struct in6_addr *a)
 }
 
 /* more secured version of ipv6_addr_hash() */
-static inline u32 ipv6_addr_jhash(const struct in6_addr *a)
+static inline u32 __ipv6_addr_jhash(const struct in6_addr *a, const u32 initval)
 {
 	u32 v = (__force u32)a->s6_addr32[0] ^ (__force u32)a->s6_addr32[1];
 
 	return jhash_3words(v,
 			    (__force u32)a->s6_addr32[2],
 			    (__force u32)a->s6_addr32[3],
-			    ipv6_hash_secret);
+			    initval);
 }
 
 static inline bool ipv6_addr_loopback(const struct in6_addr *a)
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 842d833..fa7dd38 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -23,6 +23,30 @@
 #include <net/secure_seq.h>
 #include <net/ip.h>
 
+static unsigned int inet6_ehashfn(struct net *net,
+				  const struct in6_addr *laddr,
+				  const u16 lport,
+				  const struct in6_addr *faddr,
+				  const __be16 fport)
+{
+	const u32 lhash = (__force u32)laddr->s6_addr32[3];
+	const u32 fhash = __ipv6_addr_jhash(faddr, ipv6_hash_secret);
+	return __inet6_ehashfn(lhash, lport, fhash, fport,
+			       inet_ehash_secret + net_hash_mix(net));
+}
+
+static int inet6_sk_ehashfn(const struct sock *sk)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+	const struct in6_addr *laddr = &sk->sk_v6_rcv_saddr;
+	const struct in6_addr *faddr = &sk->sk_v6_daddr;
+	const __u16 lport = inet->inet_num;
+	const __be16 fport = inet->inet_dport;
+	struct net *net = sock_net(sk);
+
+	return inet6_ehashfn(net, laddr, lport, faddr, fport);
+}
+
 int __inet6_hash(struct sock *sk, struct inet_timewait_sock *tw)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index b496de1..324bd36 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -53,6 +53,18 @@
 #include <trace/events/skb.h>
 #include "udp_impl.h"
 
+static unsigned int udp6_ehashfn(struct net *net,
+				  const struct in6_addr *laddr,
+				  const u16 lport,
+				  const struct in6_addr *faddr,
+				  const __be16 fport)
+{
+	const u32 lhash = (__force u32)laddr->s6_addr32[3];
+	const u32 fhash = __ipv6_addr_jhash(faddr, ipv6_hash_secret);
+	return __inet6_ehashfn(lhash, lport, fhash, fport,
+			       inet_ehash_secret + net_hash_mix(net));
+}
+
 int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 {
 	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
@@ -214,8 +226,8 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				hash = inet6_ehashfn(net, daddr, hnum,
-						     saddr, sport);
+				hash = udp6_ehashfn(net, daddr, hnum,
+						    saddr, sport);
 				matches = 1;
 			} else if (score == SCORE2_MAX)
 				goto exact_match;
@@ -295,8 +307,8 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				hash = inet6_ehashfn(net, daddr, hnum,
-						     saddr, sport);
+				hash = udp6_ehashfn(net, daddr, hnum,
+						    saddr, sport);
 				matches = 1;
 			}
 		} else if (score == badness && reuseport) {
-- 
1.8.3.1
