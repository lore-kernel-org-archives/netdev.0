From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/5] soreuseport: TCP/IPv4 implementation
Date: Mon, 14 Jan 2013 12:00:20 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1301141140330.3472@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f74.google.com ([209.85.214.74]:56216 "EHLO
	mail-bk0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757557Ab3ANUAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 15:00:24 -0500
Received: by mail-bk0-f74.google.com with SMTP id je9so288336bkc.3
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 12:00:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow multiple listener sockets to bind to the same port.

Motivation for soresuseport would be something like a web server
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
 include/net/inet_hashtables.h   |   13 ++++++++--
 net/ipv4/inet_connection_sock.c |   48 ++++++++++++++++++++++++++++++---------
 net/ipv4/inet_hashtables.c      |   28 +++++++++++++++++-----
 net/ipv4/tcp_ipv4.c             |    4 ++-
 4 files changed, 72 insertions(+), 21 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 67a8fa0..2968c8f 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -81,7 +81,9 @@ struct inet_bind_bucket {
 	struct net		*ib_net;
 #endif
 	unsigned short		port;
-	signed short		fastreuse;
+	signed char		fastreuse;
+	signed char		fastreuseport;
+	int			fastuid;
 	int			num_owners;
 	struct hlist_node	node;
 	struct hlist_head	owners;
@@ -257,15 +259,19 @@ extern void inet_unhash(struct sock *sk);
 
 extern struct sock *__inet_lookup_listener(struct net *net,
 					   struct inet_hashinfo *hashinfo,
+					   const __be32 saddr,
+					   const __be16 sport,
 					   const __be32 daddr,
 					   const unsigned short hnum,
 					   const int dif);
 
 static inline struct sock *inet_lookup_listener(struct net *net,
 		struct inet_hashinfo *hashinfo,
+		__be32 saddr, __be16 sport,
 		__be32 daddr, __be16 dport, int dif)
 {
-	return __inet_lookup_listener(net, hashinfo, daddr, ntohs(dport), dif);
+	return __inet_lookup_listener(net, hashinfo, saddr, sport,
+	    daddr, ntohs(dport), dif);
 }
 
 /* Socket demux engine toys. */
@@ -358,7 +364,8 @@ static inline struct sock *__inet_lookup(struct net *net,
 	struct sock *sk = __inet_lookup_established(net, hashinfo,
 				saddr, sport, daddr, hnum, dif);
 
-	return sk ? : __inet_lookup_listener(net, hashinfo, daddr, hnum, dif);
+	return sk ? : __inet_lookup_listener(net, hashinfo, saddr, sport,
+	    daddr, hnum, dif);
 }
 
 static inline struct sock *inet_lookup(struct net *net,
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index d0670f0..c2ce445 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -59,6 +59,8 @@ int inet_csk_bind_conflict(const struct sock *sk,
 	struct sock *sk2;
 	struct hlist_node *node;
 	int reuse = sk->sk_reuse;
+	int reuseport = sk->sk_reuseport;
+	int uid = sock_i_uid((struct sock *)sk);
 
 	/*
 	 * Unlike other sk lookup places we do not check
@@ -73,8 +75,11 @@ int inet_csk_bind_conflict(const struct sock *sk,
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
-			if (!reuse || !sk2->sk_reuse ||
-			    sk2->sk_state == TCP_LISTEN) {
+			if ((!reuse || !sk2->sk_reuse ||
+			    sk2->sk_state == TCP_LISTEN) &&
+			    (!reuseport || !sk2->sk_reuseport ||
+			    (sk2->sk_state != TCP_TIME_WAIT &&
+			     uid != sock_i_uid(sk2)))) {
 				const __be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
 				if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
 				    sk2_rcv_saddr == sk_rcv_saddr(sk))
@@ -106,6 +111,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	int ret, attempts = 5;
 	struct net *net = sock_net(sk);
 	int smallest_size = -1, smallest_rover;
+	int uid = sock_i_uid(sk);
 
 	local_bh_disable();
 	if (!snum) {
@@ -125,9 +131,12 @@ again:
 			spin_lock(&head->lock);
 			inet_bind_bucket_for_each(tb, node, &head->chain)
 				if (net_eq(ib_net(tb), net) && tb->port == rover) {
-					if (tb->fastreuse > 0 &&
-					    sk->sk_reuse &&
-					    sk->sk_state != TCP_LISTEN &&
+					if (((tb->fastreuse > 0 &&
+					      sk->sk_reuse &&
+					      sk->sk_state != TCP_LISTEN) ||
+					     (tb->fastreuseport > 0 &&
+					      sk->sk_reuseport &&
+					      tb->fastuid == uid)) &&
 					    (tb->num_owners < smallest_size || smallest_size == -1)) {
 						smallest_size = tb->num_owners;
 						smallest_rover = rover;
@@ -185,14 +194,17 @@ tb_found:
 		if (sk->sk_reuse == SK_FORCE_REUSE)
 			goto success;
 
-		if (tb->fastreuse > 0 &&
-		    sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
+		if (((tb->fastreuse > 0 &&
+		      sk->sk_reuse && sk->sk_state != TCP_LISTEN) ||
+		     (tb->fastreuseport > 0 &&
+		      sk->sk_reuseport && tb->fastuid == uid)) &&
 		    smallest_size == -1) {
 			goto success;
 		} else {
 			ret = 1;
 			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
-				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
+				if (((sk->sk_reuse && sk->sk_state != TCP_LISTEN) ||
+				     (sk->sk_reuseport && tb->fastuid == uid)) &&
 				    smallest_size != -1 && --attempts >= 0) {
 					spin_unlock(&head->lock);
 					goto again;
@@ -212,9 +224,23 @@ tb_not_found:
 			tb->fastreuse = 1;
 		else
 			tb->fastreuse = 0;
-	} else if (tb->fastreuse &&
-		   (!sk->sk_reuse || sk->sk_state == TCP_LISTEN))
-		tb->fastreuse = 0;
+		if (sk->sk_reuseport) {
+			tb->fastreuseport = 1;
+			tb->fastuid = uid;
+		} else {
+			tb->fastreuseport = 0;
+			tb->fastuid = 0;
+		}
+	} else {
+		if (tb->fastreuse &&
+		    (!sk->sk_reuse || sk->sk_state == TCP_LISTEN))
+			tb->fastreuse = 0;
+		if (tb->fastreuseport &&
+		    (!sk->sk_reuseport || tb->fastuid != uid)) {
+			tb->fastreuseport = 0;
+			tb->fastuid = 0;
+		}
+	}
 success:
 	if (!inet_csk(sk)->icsk_bind_hash)
 		inet_bind_hash(sk, tb, snum);
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index fa3ae81..491cb85 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -39,6 +39,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 		write_pnet(&tb->ib_net, hold_net(net));
 		tb->port      = snum;
 		tb->fastreuse = 0;
+		tb->fastreuseport = 0;
 		tb->num_owners = 0;
 		INIT_HLIST_HEAD(&tb->owners);
 		hlist_add_head(&tb->node, &head->chain);
@@ -151,16 +152,16 @@ static inline int compute_score(struct sock *sk, struct net *net,
 	if (net_eq(sock_net(sk), net) && inet->inet_num == hnum &&
 			!ipv6_only_sock(sk)) {
 		__be32 rcv_saddr = inet->inet_rcv_saddr;
-		score = sk->sk_family == PF_INET ? 1 : 0;
+		score = sk->sk_family == PF_INET ? 2 : 1;
 		if (rcv_saddr) {
 			if (rcv_saddr != daddr)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 		if (sk->sk_bound_dev_if) {
 			if (sk->sk_bound_dev_if != dif)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 	}
 	return score;
@@ -176,6 +177,7 @@ static inline int compute_score(struct sock *sk, struct net *net,
 
 struct sock *__inet_lookup_listener(struct net *net,
 				    struct inet_hashinfo *hashinfo,
+				    const __be32 saddr, __be16 sport,
 				    const __be32 daddr, const unsigned short hnum,
 				    const int dif)
 {
@@ -183,17 +185,29 @@ struct sock *__inet_lookup_listener(struct net *net,
 	struct hlist_nulls_node *node;
 	unsigned int hash = inet_lhashfn(net, hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
-	int score, hiscore;
+	int score, hiscore, matches = 0, reuseport = 0;
+	u32 phash = 0;
 
 	rcu_read_lock();
 begin:
 	result = NULL;
-	hiscore = -1;
+	hiscore = 0;
 	sk_nulls_for_each_rcu(sk, node, &ilb->head) {
 		score = compute_score(sk, net, hnum, daddr, dif);
 		if (score > hiscore) {
 			result = sk;
 			hiscore = score;
+			reuseport = sk->sk_reuseport;
+			if (reuseport) {
+				phash = inet_ehashfn(net, daddr, hnum,
+				    saddr, sport);
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
@@ -501,7 +515,8 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			inet_bind_bucket_for_each(tb, node, &head->chain) {
 				if (net_eq(ib_net(tb), net) &&
 				    tb->port == port) {
-					if (tb->fastreuse >= 0)
+					if (tb->fastreuse >= 0 ||
+					    tb->fastreuseport >= 0)
 						goto next_port;
 					WARN_ON(hlist_empty(&tb->owners));
 					if (!check_established(death_row, sk,
@@ -518,6 +533,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 				break;
 			}
 			tb->fastreuse = -1;
+			tb->fastreuseport = -1;
 			goto ok;
 
 		next_port:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c6ce9ca..bbbdcc5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -657,7 +657,8 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 		 * no RST generated if md5 hash doesn't match.
 		 */
 		sk1 = __inet_lookup_listener(dev_net(skb_dst(skb)->dev),
-					     &tcp_hashinfo, ip_hdr(skb)->daddr,
+					     &tcp_hashinfo, ip_hdr(skb)->saddr,
+					     th->source, ip_hdr(skb)->daddr,
 					     ntohs(th->source), inet_iif(skb));
 		/* don't send rst if it can't find key */
 		if (!sk1)
@@ -2074,6 +2075,7 @@ do_time_wait:
 	case TCP_TW_SYN: {
 		struct sock *sk2 = inet_lookup_listener(dev_net(skb->dev),
 							&tcp_hashinfo,
+							iph->saddr, th->source,
 							iph->daddr, th->dest,
 							inet_iif(skb));
 		if (sk2) {
-- 
1.7.7.3
