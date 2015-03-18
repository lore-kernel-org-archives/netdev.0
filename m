From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/6] ipv6: get rid of __inet6_hash()
Date: Wed, 18 Mar 2015 14:05:36 -0700
Message-ID: <1426712738-23395-5-git-send-email-edumazet@google.com>
References: <1426712738-23395-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:34318 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933160AbbCRVGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 17:06:05 -0400
Received: by igqa13 with SMTP id a13so3407450igq.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 14:06:05 -0700 (PDT)
In-Reply-To: <1426712738-23395-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can now use inet_hash() and __inet_hash() instead of private
functions.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet6_hashtables.h |  2 --
 include/net/inet_hashtables.h  |  1 +
 net/dccp/ipv6.c                | 17 ++---------------
 net/ipv4/inet_hashtables.c     | 12 ++++++------
 net/ipv6/inet6_hashtables.c    | 38 +-------------------------------------
 net/ipv6/tcp_ipv6.c            | 17 ++---------------
 6 files changed, 12 insertions(+), 75 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 9201afe083fa..7ff588ca6817 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -38,8 +38,6 @@ static inline unsigned int __inet6_ehashfn(const u32 lhash,
 	return jhash_3words(lhash, fhash, ports, initval);
 }
 
-int __inet6_hash(struct sock *sk, struct inet_timewait_sock *twp);
-
 /*
  * Sockets in TCP_CLOSE state are _always_ taken out of the hash, so
  * we need not check it for TCP lookups anymore, thanks Alexey. -DaveM
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 06ad42182ec2..eee6c3399990 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -249,6 +249,7 @@ void inet_put_port(struct sock *sk);
 void inet_hashinfo_init(struct inet_hashinfo *h);
 
 int __inet_hash_nolisten(struct sock *sk, struct inet_timewait_sock *tw);
+int __inet_hash(struct sock *sk, struct inet_timewait_sock *tw);
 void inet_hash(struct sock *sk);
 void inet_unhash(struct sock *sk);
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9216d173dd5f..c655de5f67c9 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -40,19 +40,6 @@
 static const struct inet_connection_sock_af_ops dccp_ipv6_mapped;
 static const struct inet_connection_sock_af_ops dccp_ipv6_af_ops;
 
-static void dccp_v6_hash(struct sock *sk)
-{
-	if (sk->sk_state != DCCP_CLOSED) {
-		if (inet_csk(sk)->icsk_af_ops == &dccp_ipv6_mapped) {
-			inet_hash(sk);
-			return;
-		}
-		local_bh_disable();
-		__inet6_hash(sk, NULL);
-		local_bh_enable();
-	}
-}
-
 /* add pseudo-header to DCCP checksum stored in skb->csum */
 static inline __sum16 dccp_v6_csum_finish(struct sk_buff *skb,
 				      const struct in6_addr *saddr,
@@ -588,7 +575,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		dccp_done(newsk);
 		goto out;
 	}
-	__inet6_hash(newsk, NULL);
+	__inet_hash(newsk, NULL);
 
 	return newsk;
 
@@ -1056,7 +1043,7 @@ static struct proto dccp_v6_prot = {
 	.sendmsg	   = dccp_sendmsg,
 	.recvmsg	   = dccp_recvmsg,
 	.backlog_rcv	   = dccp_v6_do_rcv,
-	.hash		   = dccp_v6_hash,
+	.hash		   = inet_hash,
 	.unhash		   = inet_unhash,
 	.accept		   = inet_csk_accept,
 	.get_port	   = inet_csk_get_port,
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index ab7f677a97db..82753bd57e79 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -434,15 +434,13 @@ int __inet_hash_nolisten(struct sock *sk, struct inet_timewait_sock *tw)
 }
 EXPORT_SYMBOL_GPL(__inet_hash_nolisten);
 
-static void __inet_hash(struct sock *sk)
+int __inet_hash(struct sock *sk, struct inet_timewait_sock *tw)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct inet_listen_hashbucket *ilb;
 
-	if (sk->sk_state != TCP_LISTEN) {
-		__inet_hash_nolisten(sk, NULL);
-		return;
-	}
+	if (sk->sk_state != TCP_LISTEN)
+		return __inet_hash_nolisten(sk, tw);
 
 	WARN_ON(!sk_unhashed(sk));
 	ilb = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
@@ -451,13 +449,15 @@ static void __inet_hash(struct sock *sk)
 	__sk_nulls_add_node_rcu(sk, &ilb->head);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	spin_unlock(&ilb->lock);
+	return 0;
 }
+EXPORT_SYMBOL(__inet_hash);
 
 void inet_hash(struct sock *sk)
 {
 	if (sk->sk_state != TCP_CLOSE) {
 		local_bh_disable();
-		__inet_hash(sk);
+		__inet_hash(sk, NULL);
 		local_bh_enable();
 	}
 }
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index ed5787b20192..b86b429f5f81 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -42,42 +42,6 @@ u32 inet6_ehashfn(const struct net *net,
 			       inet6_ehash_secret + net_hash_mix(net));
 }
 
-int __inet6_hash(struct sock *sk, struct inet_timewait_sock *tw)
-{
-	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
-	int twrefcnt = 0;
-
-	WARN_ON(!sk_unhashed(sk));
-
-	if (sk->sk_state == TCP_LISTEN) {
-		struct inet_listen_hashbucket *ilb;
-
-		ilb = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
-		spin_lock(&ilb->lock);
-		__sk_nulls_add_node_rcu(sk, &ilb->head);
-		spin_unlock(&ilb->lock);
-	} else {
-		unsigned int hash;
-		struct hlist_nulls_head *list;
-		spinlock_t *lock;
-
-		sk->sk_hash = hash = sk_ehashfn(sk);
-		list = &inet_ehash_bucket(hashinfo, hash)->chain;
-		lock = inet_ehash_lockp(hashinfo, hash);
-		spin_lock(lock);
-		__sk_nulls_add_node_rcu(sk, list);
-		if (tw) {
-			WARN_ON(sk->sk_hash != tw->tw_hash);
-			twrefcnt = inet_twsk_unhash(tw);
-		}
-		spin_unlock(lock);
-	}
-
-	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
-	return twrefcnt;
-}
-EXPORT_SYMBOL(__inet6_hash);
-
 /*
  * Sockets in TCP_CLOSE state are _always_ taken out of the hash, so
  * we need not check it for TCP lookups anymore, thanks Alexey. -DaveM
@@ -306,6 +270,6 @@ int inet6_hash_connect(struct inet_timewait_death_row *death_row,
 		       struct sock *sk)
 {
 	return __inet_hash_connect(death_row, sk, inet6_sk_port_offset(sk),
-			__inet6_check_established, __inet6_hash);
+			__inet6_check_established, __inet_hash_nolisten);
 }
 EXPORT_SYMBOL_GPL(inet6_hash_connect);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5546df074583..720676d073d9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -104,19 +104,6 @@ static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 	}
 }
 
-static void tcp_v6_hash(struct sock *sk)
-{
-	if (sk->sk_state != TCP_CLOSE) {
-		if (inet_csk(sk)->icsk_af_ops == &ipv6_mapped) {
-			tcp_prot.hash(sk);
-			return;
-		}
-		local_bh_disable();
-		__inet6_hash(sk, NULL);
-		local_bh_enable();
-	}
-}
-
 static __u32 tcp_v6_init_sequence(const struct sk_buff *skb)
 {
 	return secure_tcpv6_sequence_number(ipv6_hdr(skb)->daddr.s6_addr32,
@@ -1224,7 +1211,7 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		tcp_done(newsk);
 		goto out;
 	}
-	__inet6_hash(newsk, NULL);
+	__inet_hash(newsk, NULL);
 
 	return newsk;
 
@@ -1883,7 +1870,7 @@ struct proto tcpv6_prot = {
 	.sendpage		= tcp_sendpage,
 	.backlog_rcv		= tcp_v6_do_rcv,
 	.release_cb		= tcp_release_cb,
-	.hash			= tcp_v6_hash,
+	.hash			= inet_hash,
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
 	.enter_memory_pressure	= tcp_enter_memory_pressure,
-- 
2.2.0.rc0.207.ga3a616c
