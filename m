From: Tom Herbert <therbert@google.com>
Subject: [PATCH RFC]: soreuseport: Bind multiple sockets to same port
Date: Sun, 18 Apr 2010 23:33:37 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004182321480.1822@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:22580 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab0DSGdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 02:33:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is some work we've done to scale TCP listeners/UDP servers.  It
might be apropos with some of the discussion on SO_REUSEADDR for UDP.
---
This patch implements so_reuseport (SO_REUSEPORT socket option) for
TCP and UDP.  For TCP, so_reuseport allows multiple listener sockets
to be bound to the same port.  In the case of UDP, so_reuseport allows
multiple sockets to bind to the same port.  To prevent port hijacking
all sockets bound to the same port using so_reuseport must have the
same uid.  Received packets are distributed to multiple sockets bound
to the same port using a 4-tuple hash.

The motivating case for so_resuseport in TCP would be something like
a web server binding to port 80 running with multiple threads, where
each thread might have it's own listener socket.  This could be done
as an alternative to other models: 1) have one listener thread which
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

The TCP implementation has a problem in that the request sockets for a
listener are attached to a listener socket.  If a SYN is received, a
listener socket is chosen and request structure is created (SYN-RECV
state).  If the subsequent ack in 3WHS does not match the same port
by so_reusport, the connection state is not found (reset) and the
request structure is orphaned.  This scenario would occur when the
number of listener sockets bound to a port changes (new ones are
added, or old ones closed).  We are looking for a solution to this,
maybe allow multiple sockets to share the same request table...

The motivating case for so_reuseport in UDP would be something like a
DNS server.  An alternative would be to recv on the same socket from
multiple threads.  As in the case of TCP, the load across these threads
tends to be disproportionate and we also see a lot of contection on
the socket lock.  Note that SO_REUSEADDR already allows multiple UDP
sockets to bind to the same port, however there is no provision to
prevent hijacking and nothing to distribute packets across all the
sockets sharing the same bound port.  This patch does not change the
semantics of SO_REUSEADDR, but provides usable functionality of it
for unicast.
---
diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 9a6115e..37b699f 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -22,7 +22,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
+#define SO_REUSEPORT	15
 
 #ifndef SO_PASSCRED /* powerpc only differs in these */
 #define SO_PASSCRED	16
diff --git a/include/linux/inet.h b/include/linux/inet.h
index 4cca05c..bd8f0b6 100644
--- a/include/linux/inet.h
+++ b/include/linux/inet.h
@@ -51,6 +51,12 @@
 #define INET_ADDRSTRLEN		(16)
 #define INET6_ADDRSTRLEN	(48)
 
+static inline u32 inet_next_pseudo_random32(u32 seed)
+{
+	/* Pseudo random number generator from numerical recipes */
+	return seed * 1664525 + 1013904223;
+}
+
 extern __be32 in_aton(const char *str);
 extern int in4_pton(const char *src, int srclen, u8 *dst, int delim, const char **end);
 extern int in6_pton(const char *src, int srclen, u8 *dst, int delim, const char **end);
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 74358d1..0887675 100644
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
@@ -356,7 +362,8 @@ static inline struct sock *__inet_lookup(struct net *net,
 	struct sock *sk = __inet_lookup_established(net, hashinfo,
 				saddr, sport, daddr, hnum, dif);
 
-	return sk ? : __inet_lookup_listener(net, hashinfo, daddr, hnum, dif);
+	return sk ? : __inet_lookup_listener(net, hashinfo, saddr, sport,
+	    daddr, hnum, dif);
 }
 
 static inline struct sock *inet_lookup(struct net *net,
diff --git a/include/net/sock.h b/include/net/sock.h
index 56df440..58c6fa9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -114,6 +114,7 @@ struct net;
  *	@skc_family: network address family
  *	@skc_state: Connection state
  *	@skc_reuse: %SO_REUSEADDR setting
+ *	@skc_reuseport: %SO_REUSEPORT setting
  *	@skc_bound_dev_if: bound device index if != 0
  *	@skc_bind_node: bind hash linkage for various protocol lookup tables
  *	@skc_portaddr_node: second hash linkage for UDP/UDP-Lite protocol
@@ -140,7 +141,8 @@ struct sock_common {
 	};
 	unsigned short		skc_family;
 	volatile unsigned char	skc_state;
-	unsigned char		skc_reuse;
+	unsigned char		skc_reuse:1;
+	unsigned char		skc_reuseport:1;
 	int			skc_bound_dev_if;
 	union {
 		struct hlist_node	skc_bind_node;
@@ -233,6 +235,7 @@ struct sock {
 #define sk_family		__sk_common.skc_family
 #define sk_state		__sk_common.skc_state
 #define sk_reuse		__sk_common.skc_reuse
+#define sk_reuseport		__sk_common.skc_reuseport
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_prot			__sk_common.skc_prot
diff --git a/net/core/sock.c b/net/core/sock.c
index 7effa1e..801efc6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -497,6 +497,9 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	case SO_REUSEADDR:
 		sk->sk_reuse = valbool;
 		break;
+	case SO_REUSEPORT:
+		sk->sk_reuseport = valbool;
+		break;
 	case SO_TYPE:
 	case SO_PROTOCOL:
 	case SO_DOMAIN:
@@ -780,6 +783,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_reuse;
 		break;
 
+	case SO_REUSEPORT:
+		v.val = sk->sk_reuseport;
+		break;
+
 	case SO_KEEPALIVE:
 		v.val = !!sock_flag(sk, SOCK_KEEPOPEN);
 		break;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 8da6429..02961c8 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -56,6 +56,8 @@ int inet_csk_bind_conflict(const struct sock *sk,
 	struct sock *sk2;
 	struct hlist_node *node;
 	int reuse = sk->sk_reuse;
+	int reuseport = sk->sk_reuseport;
+	int uid = sock_i_uid((struct sock *)sk);
 
 	/*
 	 * Unlike other sk lookup places we do not check
@@ -70,8 +72,11 @@ int inet_csk_bind_conflict(const struct sock *sk,
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
 				const __be32 sk2_rcv_saddr = inet_rcv_saddr(sk2);
 				if (!sk2_rcv_saddr || !sk_rcv_saddr ||
 				    sk2_rcv_saddr == sk_rcv_saddr)
@@ -96,6 +101,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	int ret, attempts = 5;
 	struct net *net = sock_net(sk);
 	int smallest_size = -1, smallest_rover;
+	int uid = sock_i_uid(sk);
 
 	local_bh_disable();
 	if (!snum) {
@@ -113,9 +119,12 @@ again:
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
@@ -165,14 +174,18 @@ have_snum:
 	goto tb_not_found;
 tb_found:
 	if (!hlist_empty(&tb->owners)) {
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
 			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
-				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
+				if (((sk->sk_reuse &&
+				      sk->sk_state != TCP_LISTEN) ||
+				     sk->sk_reuseport) &&
 				    smallest_size != -1 && --attempts >= 0) {
 					spin_unlock(&head->lock);
 					goto again;
@@ -191,9 +204,23 @@ tb_not_found:
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
index 2b79377..f7c23e1 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -38,6 +38,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 		write_pnet(&tb->ib_net, hold_net(net));
 		tb->port      = snum;
 		tb->fastreuse = 0;
+		tb->fastreuseport = 0;
 		tb->num_owners = 0;
 		INIT_HLIST_HEAD(&tb->owners);
 		hlist_add_head(&tb->node, &head->chain);
@@ -129,16 +130,16 @@ static inline int compute_score(struct sock *sk, struct net *net,
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
@@ -154,6 +155,7 @@ static inline int compute_score(struct sock *sk, struct net *net,
 
 struct sock *__inet_lookup_listener(struct net *net,
 				    struct inet_hashinfo *hashinfo,
+				    const __be32 saddr, __be16 sport,
 				    const __be32 daddr, const unsigned short hnum,
 				    const int dif)
 {
@@ -161,26 +163,39 @@ struct sock *__inet_lookup_listener(struct net *net,
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
+				    saddr, htons(sport));
+				matches = 1;
+			}
+		} else if (score == hiscore && reuseport) {
+			matches++;
+			if (((u64)phash * matches) >> 32 == 0)
+				result = sk;
+			phash = inet_next_pseudo_random32(phash);
 		}
 	}
-	/*
-	 * if the nulls value we got at the end of this lookup is
-	 * not the expected one, we must restart lookup.
+/*
+ * if the nulls value we got at the end of this lookup is
+ * not the expected one, we must restart lookup.
 	 * We probably met an item that was moved to another chain.
 	 */
 	if (get_nulls_value(node) != hash + LISTENING_NULLS_BASE)
 		goto begin;
+
 	if (result) {
 		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
 			result = NULL;
@@ -467,7 +482,8 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			inet_bind_bucket_for_each(tb, node, &head->chain) {
 				if (net_eq(ib_net(tb), net) &&
 				    tb->port == port) {
-					if (tb->fastreuse >= 0)
+					if (tb->fastreuse >= 0 ||
+					    tb->fastreuseport >= 0)
 						goto next_port;
 					WARN_ON(hlist_empty(&tb->owners));
 					if (!check_established(death_row, sk,
@@ -484,6 +500,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 				break;
 			}
 			tb->fastreuse = -1;
+			tb->fastreuseport = -1;
 			goto ok;
 
 		next_port:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ad08392..71cf97d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1735,6 +1735,7 @@ do_time_wait:
 	case TCP_TW_SYN: {
 		struct sock *sk2 = inet_lookup_listener(dev_net(skb->dev),
 							&tcp_hashinfo,
+							iph->saddr, th->source,
 							iph->daddr, th->dest,
 							inet_iif(skb));
 		if (sk2) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 666b963..59404fa 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -135,6 +135,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 {
 	struct sock *sk2;
 	struct hlist_nulls_node *node;
+	int uid = sock_i_uid(sk);
 
 	sk_nulls_for_each(sk2, node, &hslot->head)
 		if (net_eq(sock_net(sk2), net) &&
@@ -143,6 +144,8 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
+		      uid != sock_i_uid(sk2)) &&
 		    (*saddr_comp)(sk, sk2)) {
 			if (bitmap)
 				__set_bit(udp_sk(sk2)->udp_port_hash >> log,
@@ -332,26 +335,26 @@ static inline int compute_score(struct sock *sk, struct net *net, __be32 saddr,
 			!ipv6_only_sock(sk)) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		score = (sk->sk_family == PF_INET ? 1 : 0);
+		score = (sk->sk_family == PF_INET ? 2 : 1);
 		if (inet->inet_rcv_saddr) {
 			if (inet->inet_rcv_saddr != daddr)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 		if (inet->inet_daddr) {
 			if (inet->inet_daddr != saddr)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 		if (inet->inet_dport) {
 			if (inet->inet_dport != sport)
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
@@ -360,7 +363,6 @@ static inline int compute_score(struct sock *sk, struct net *net, __be32 saddr,
 /*
  * In this second variant, we check (daddr, dport) matches (inet_rcv_sadd, inet_num)
  */
-#define SCORE2_MAX (1 + 2 + 2 + 2)
 static inline int compute_score2(struct sock *sk, struct net *net,
 				 __be32 saddr, __be16 sport,
 				 __be32 daddr, unsigned int hnum, int dif)
@@ -375,21 +377,21 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 		if (inet->inet_num != hnum)
 			return -1;
 
-		score = (sk->sk_family == PF_INET ? 1 : 0);
+		score = (sk->sk_family == PF_INET ? 2 : 1);
 		if (inet->inet_daddr) {
 			if (inet->inet_daddr != saddr)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 		if (inet->inet_dport) {
 			if (inet->inet_dport != sport)
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
@@ -404,19 +406,29 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
-	int score, badness;
+	int score, badness, matches = 0, reuseport = 0;
+	u32 hash = 0;
 
 begin:
 	result = NULL;
-	badness = -1;
+	badness = 0;
 	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
 		score = compute_score2(sk, net, saddr, sport,
 				      daddr, hnum, dif);
 		if (score > badness) {
 			result = sk;
 			badness = score;
-			if (score == SCORE2_MAX)
-				goto exact_match;
+			reuseport = sk->sk_reuseport;
+			if (reuseport) {
+				hash = inet_ehashfn(net, daddr, hnum,
+				    saddr, htons(sport));
+				matches = 1;
+			}
+		} else if (score == badness && reuseport) {
+			matches++;
+			if (((u64)hash * matches) >> 32 == 0)
+				result = sk;
+			hash = inet_next_pseudo_random32(hash);
 		}
 	}
 	/*
@@ -428,7 +440,6 @@ begin:
 		goto begin;
 
 	if (result) {
-exact_match:
 		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
 			result = NULL;
 		else if (unlikely(compute_score2(result, net, saddr, sport,
@@ -452,7 +463,8 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	unsigned short hnum = ntohs(dport);
 	unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
 	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
-	int score, badness;
+	int score, badness, matches = 0, reuseport = 0;
+	u32 hash;
 
 	rcu_read_lock();
 	if (hslot->count > 10) {
@@ -481,13 +493,24 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	}
 begin:
 	result = NULL;
-	badness = -1;
+	badness = 0;
 	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
 		score = compute_score(sk, net, saddr, hnum, sport,
 				      daddr, dport, dif);
 		if (score > badness) {
 			result = sk;
 			badness = score;
+			reuseport = sk->sk_reuseport;
+			if (reuseport) {
+				hash = inet_ehashfn(net, daddr, hnum,
+				    saddr, htons(sport));
+				matches = 1;
+			}
+		} else if (score == badness && reuseport) {
+			matches++;
+			if (((u64)hash * matches) >> 32 == 0)
+				result = sk;
+			hash = inet_next_pseudo_random32(hash);
 		}
 	}
 	/*
