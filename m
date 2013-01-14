From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/5] soreuseport: TCP/IPv6 implementation
Date: Mon, 14 Jan 2013 12:00:25 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1301141140310.3563@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f202.google.com ([209.85.217.202]:43595 "EHLO
	mail-lb0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757471Ab3ANUZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 15:25:05 -0500
Received: by mail-lb0-f202.google.com with SMTP id s4so293160lbc.3
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 12:25:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow multiple listener sockets to bind to the same port.

Motivation for soreuseport would be something like a web server
binding to port 80 running with multiple threads, where each thread
might have it's own listener socket.  This could be done as an
alternative to other models: 1) have one listener thread which
dispatches completed connections to workers. 2) accept on a single
listener socket from multiple threads.  In case #1 the listener thread
can easily become the bottleneck with high connection turn-over rate.
In case #2, the proportion of connections accepted per thread tends
to be uneven under high connection load (assuming simple event loop:
while (1) { accept(); process() }, wakeup does not promote fairness
among the sockets.  We have seen the  disproportion to be as high
as 3:1 ratio between thread accepting most connections and the one
accepting the fewest.  With so_reusport the distribution is
uniform.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/inet6_hashtables.h   |    5 ++++-
 net/ipv6/inet6_connection_sock.c |   18 +++++++++++++-----
 net/ipv6/inet6_hashtables.c      |   19 ++++++++++++++++---
 net/ipv6/tcp_ipv6.c              |    4 +++-
 4 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 9e34c87..7ca75cb 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -71,6 +71,8 @@ extern struct sock *__inet6_lookup_established(struct net *net,
 
 extern struct sock *inet6_lookup_listener(struct net *net,
 					  struct inet_hashinfo *hashinfo,
+					  const struct in6_addr *saddr,
+					  const __be16 sport,
 					  const struct in6_addr *daddr,
 					  const unsigned short hnum,
 					  const int dif);
@@ -88,7 +90,8 @@ static inline struct sock *__inet6_lookup(struct net *net,
 	if (sk)
 		return sk;
 
-	return inet6_lookup_listener(net, hashinfo, daddr, hnum, dif);
+	return inet6_lookup_listener(net, hashinfo, saddr, sport,
+				     daddr, hnum, dif);
 }
 
 static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 3064785..3ed48ce 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -32,6 +32,9 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 {
 	const struct sock *sk2;
 	const struct hlist_node *node;
+	int reuse = sk->sk_reuse;
+	int reuseport = sk->sk_reuseport;
+	int sk_uid = sock_i_uid((struct sock *)sk);
 
 	/* We must walk the whole port owner list in this case. -DaveM */
 	/*
@@ -42,11 +45,16 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 		if (sk != sk2 &&
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
-		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if) &&
-		    (!sk->sk_reuse || !sk2->sk_reuse ||
-		     sk2->sk_state == TCP_LISTEN) &&
-		     ipv6_rcv_saddr_equal(sk, sk2))
-			break;
+		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
+			if ((!reuse || !sk2->sk_reuse ||
+			     sk2->sk_state == TCP_LISTEN) &&
+			    (!reuseport || !sk2->sk_reuseport ||
+			     (sk2->sk_state != TCP_TIME_WAIT &&
+			      sk_uid != sock_i_uid((struct sock *)sk2)))) {
+				if (ipv6_rcv_saddr_equal(sk, sk2))
+					break;
+			}
+		}
 	}
 
 	return node != NULL;
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index dea17fd..cdce916 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -158,25 +158,38 @@ static inline int compute_score(struct sock *sk, struct net *net,
 }
 
 struct sock *inet6_lookup_listener(struct net *net,
-		struct inet_hashinfo *hashinfo, const struct in6_addr *daddr,
+		struct inet_hashinfo *hashinfo, const struct in6_addr *saddr,
+		const __be16 sport, const struct in6_addr *daddr,
 		const unsigned short hnum, const int dif)
 {
 	struct sock *sk;
 	const struct hlist_nulls_node *node;
 	struct sock *result;
-	int score, hiscore;
+	int score, hiscore, matches = 0, reuseport = 0;
+	u32 phash = 0;
 	unsigned int hash = inet_lhashfn(net, hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
 
 	rcu_read_lock();
 begin:
 	result = NULL;
-	hiscore = -1;
+	hiscore = 0;
 	sk_nulls_for_each(sk, node, &ilb->head) {
 		score = compute_score(sk, net, hnum, daddr, dif);
 		if (score > hiscore) {
 			hiscore = score;
 			result = sk;
+			reuseport = sk->sk_reuseport;
+			if (reuseport) {
+				phash = inet6_ehashfn(net, daddr, hnum,
+				   saddr, sport);
+				matches = 1;
+			}
+		} else if (score == hiscore && reuseport) {
+			matches++;
+			if (((u64)phash * matches) >> 32 == 0)
+				result = sk;
+			phash = next_pseudo_random32(phash);
 		}
 	}
 	/*
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3701c3c..06087e5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -834,7 +834,8 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		 * no RST generated if md5 hash doesn't match.
 		 */
 		sk1 = inet6_lookup_listener(dev_net(skb_dst(skb)->dev),
-					   &tcp_hashinfo, &ipv6h->daddr,
+					   &tcp_hashinfo, &ipv6h->saddr,
+					   th->source, &ipv6h->daddr,
 					   ntohs(th->source), inet6_iif(skb));
 		if (!sk1)
 			return;
@@ -1598,6 +1599,7 @@ do_time_wait:
 		struct sock *sk2;
 
 		sk2 = inet6_lookup_listener(dev_net(skb->dev), &tcp_hashinfo,
+					    &ipv6_hdr(skb)->saddr, th->source,
 					    &ipv6_hdr(skb)->daddr,
 					    ntohs(th->dest), inet6_iif(skb));
 		if (sk2 != NULL) {
-- 
1.7.7.3
