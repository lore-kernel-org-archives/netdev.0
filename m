From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/6] net: initialize sk_txhash using random value
Date: Fri, 27 Feb 2015 19:11:44 -0800
Message-ID: <1425093109-1077-2-git-send-email-therbert@google.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:44302 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbbB1DMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 22:12:44 -0500
Received: by igdh15 with SMTP id h15so5347503igd.3
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 19:12:43 -0800 (PST)
In-Reply-To: <1425093109-1077-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates sock_init_txhash which simply intializes sk_txhash
to a random value. This satisfies the entropy requirements of the
hash and is stronger than old method of doing flow_hash_from_keys.
This function can be called for any type of connected socket, and will
generate different hash values for same 4-tuple across different
IP protocols or namespaces.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip.h    | 13 -------------
 include/net/ipv6.h  | 14 --------------
 include/net/sock.h  |  6 ++++++
 net/ipv4/datagram.c |  2 +-
 net/ipv4/tcp_ipv4.c |  4 ++--
 net/ipv6/datagram.c |  2 +-
 net/ipv6/tcp_ipv6.c |  4 ++--
 7 files changed, 12 insertions(+), 33 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 025c61c..11991ed 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -352,19 +352,6 @@ static inline __wsum inet_compute_pseudo(struct sk_buff *skb, int proto)
 				  skb->len, proto, 0);
 }
 
-static inline void inet_set_txhash(struct sock *sk)
-{
-	struct inet_sock *inet = inet_sk(sk);
-	struct flow_keys keys;
-
-	keys.src = inet->inet_saddr;
-	keys.dst = inet->inet_daddr;
-	keys.port16[0] = inet->inet_sport;
-	keys.port16[1] = inet->inet_dport;
-
-	sk->sk_txhash = flow_hash_from_keys(&keys);
-}
-
 static inline __wsum inet_gro_compute_pseudo(struct sk_buff *skb, int proto)
 {
 	const struct iphdr *iph = skb_gro_network_header(skb);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index b767306..3201815 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -691,20 +691,6 @@ static inline int ip6_sk_dst_hoplimit(struct ipv6_pinfo *np, struct flowi6 *fl6,
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static inline void ip6_set_txhash(struct sock *sk)
-{
-	struct inet_sock *inet = inet_sk(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct flow_keys keys;
-
-	keys.src = (__force __be32)ipv6_addr_hash(&np->saddr);
-	keys.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
-	keys.port16[0] = inet->inet_sport;
-	keys.port16[1] = inet->inet_dport;
-
-	sk->sk_txhash = flow_hash_from_keys(&keys);
-}
-
 static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 					__be32 flowlabel, bool autolabel)
 {
diff --git a/include/net/sock.h b/include/net/sock.h
index ab186b1..0f03241 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -56,6 +56,7 @@
 #include <linux/uaccess.h>
 #include <linux/page_counter.h>
 #include <linux/memcontrol.h>
+#include <linux/random.h>
 #include <linux/static_key.h>
 #include <linux/aio.h>
 #include <linux/sched.h>
@@ -880,6 +881,11 @@ static inline void sock_rps_reset_rxhash(struct sock *sk)
 #endif
 }
 
+static inline void sock_init_txhash(struct sock *sk)
+{
+	sk->sk_txhash = prandom_u32();
+}
+
 #define sk_wait_event(__sk, __timeo, __condition)			\
 	({	int __rc;						\
 		release_sock(__sk);					\
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 90c0e83..7a09672 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -76,7 +76,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	inet->inet_daddr = fl4->daddr;
 	inet->inet_dport = usin->sin_port;
 	sk->sk_state = TCP_ESTABLISHED;
-	inet_set_txhash(sk);
+	sock_init_txhash(sk);
 	inet->inet_id = jiffies;
 
 	sk_dst_set(sk, &rt->dst);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5a2dfed..2c2f141 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -222,7 +222,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (err)
 		goto failure;
 
-	inet_set_txhash(sk);
+	sock_init_txhash(sk);
 
 	rt = ip_route_newports(fl4, rt, orig_sport, orig_dport,
 			       inet->inet_sport, inet->inet_dport, sk);
@@ -1328,7 +1328,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newinet->mc_ttl	      = ip_hdr(skb)->ttl;
 	newinet->rcv_tos      = ip_hdr(skb)->tos;
 	inet_csk(newsk)->icsk_ext_hdr_len = 0;
-	inet_set_txhash(newsk);
+	sock_init_txhash(newsk);
 	if (inet_opt)
 		inet_csk(newsk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
 	newinet->inet_id = newtp->write_seq ^ jiffies;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index c215be7..fc5d3f0 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -199,7 +199,7 @@ ipv4_connected:
 		      NULL);
 
 	sk->sk_state = TCP_ESTABLISHED;
-	ip6_set_txhash(sk);
+	sock_init_txhash(sk);
 out:
 	fl6_sock_release(flowlabel);
 	return err;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5d46832..ef7e968 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -295,7 +295,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (err)
 		goto late_failure;
 
-	ip6_set_txhash(sk);
+	sock_init_txhash(sk);
 
 	if (!tp->write_seq && likely(!tp->repair))
 		tp->write_seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
@@ -1155,7 +1155,7 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newsk->sk_v6_rcv_saddr = ireq->ir_v6_loc_addr;
 	newsk->sk_bound_dev_if = ireq->ir_iif;
 
-	ip6_set_txhash(newsk);
+	sock_init_txhash(newsk);
 
 	/* Now IPv6 options...
 
-- 
2.2.0.rc0.207.ga3a616c
