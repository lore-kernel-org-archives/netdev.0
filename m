From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 6/7] soreuseport: fast reuseport TCP socket selection
Date: Tue,  9 Feb 2016 18:39:12 -0500
Message-ID: <1455061153-7855-7-git-send-email-kraigatgoog@gmail.com>
References: <1455061153-7855-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:36729 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756263AbcBIXj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 18:39:28 -0500
Received: by mail-qk0-f179.google.com with SMTP id s68so1186365qkh.3
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 15:39:28 -0800 (PST)
In-Reply-To: <1455061153-7855-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This change extends the fast SO_REUSEPORT socket lookup implemented
for UDP to TCP.  Listener sockets with SO_REUSEPORT and the same
receive address are additionally added to an array for faster
random access.  This means that only a single socket from the group
must be found in the listener list before any socket in the group can
be used to receive a packet.  Previously, every socket in the group
needed to be considered before handing off the incoming packet.

This feature also exposes the ability to use a BPF program when
selecting a socket from a reuseport group.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/net/inet_hashtables.h    |  5 +++-
 net/ipv4/inet_connection_sock.c  | 14 ++++++---
 net/ipv4/inet_hashtables.c       | 64 +++++++++++++++++++++++++++++++++++++---
 net/ipv4/udp.c                   |  4 +--
 net/ipv6/inet6_connection_sock.c |  2 ++
 net/ipv6/inet6_hashtables.c      | 16 +++++++++-
 6 files changed, 93 insertions(+), 12 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 82403390af58..50f635c2c536 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -207,7 +207,10 @@ void inet_hashinfo_init(struct inet_hashinfo *h);
 
 bool inet_ehash_insert(struct sock *sk, struct sock *osk);
 bool inet_ehash_nolisten(struct sock *sk, struct sock *osk);
-void __inet_hash(struct sock *sk, struct sock *osk);
+int __inet_hash(struct sock *sk, struct sock *osk,
+		int (*saddr_same)(const struct sock *sk1,
+				  const struct sock *sk2,
+				  bool match_wildcard));
 int inet_hash(struct sock *sk);
 void inet_unhash(struct sock *sk);
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 4c457c492b1f..0daac5d7c3b9 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -24,6 +24,7 @@
 #include <net/tcp_states.h>
 #include <net/xfrm.h>
 #include <net/tcp.h>
+#include <net/sock_reuseport.h>
 
 #ifdef INET_CSK_DEBUG
 const char inet_csk_timer_bug_msg[] = "inet_csk BUG: unknown timer value\n";
@@ -67,7 +68,8 @@ int inet_csk_bind_conflict(const struct sock *sk,
 			if ((!reuse || !sk2->sk_reuse ||
 			    sk2->sk_state == TCP_LISTEN) &&
 			    (!reuseport || !sk2->sk_reuseport ||
-			    (sk2->sk_state != TCP_TIME_WAIT &&
+			     rcu_access_pointer(sk->sk_reuseport_cb) ||
+			     (sk2->sk_state != TCP_TIME_WAIT &&
 			     !uid_eq(uid, sock_i_uid(sk2))))) {
 
 				if (!sk2->sk_rcv_saddr || !sk->sk_rcv_saddr ||
@@ -132,6 +134,7 @@ again:
 					      sk->sk_state != TCP_LISTEN) ||
 					     (tb->fastreuseport > 0 &&
 					      sk->sk_reuseport &&
+					      !rcu_access_pointer(sk->sk_reuseport_cb) &&
 					      uid_eq(tb->fastuid, uid))) &&
 					    (tb->num_owners < smallest_size || smallest_size == -1)) {
 						smallest_size = tb->num_owners;
@@ -193,15 +196,18 @@ tb_found:
 		if (((tb->fastreuse > 0 &&
 		      sk->sk_reuse && sk->sk_state != TCP_LISTEN) ||
 		     (tb->fastreuseport > 0 &&
-		      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
-		    smallest_size == -1) {
+		      sk->sk_reuseport &&
+		      !rcu_access_pointer(sk->sk_reuseport_cb) &&
+		      uid_eq(tb->fastuid, uid))) && smallest_size == -1) {
 			goto success;
 		} else {
 			ret = 1;
 			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
 				if (((sk->sk_reuse && sk->sk_state != TCP_LISTEN) ||
 				     (tb->fastreuseport > 0 &&
-				      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
+				      sk->sk_reuseport &&
+				      !rcu_access_pointer(sk->sk_reuseport_cb) &&
+				      uid_eq(tb->fastuid, uid))) &&
 				    smallest_size != -1 && --attempts >= 0) {
 					spin_unlock(&head->lock);
 					goto again;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 5e4290b83255..c0f9942de924 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -20,10 +20,12 @@
 #include <linux/wait.h>
 #include <linux/vmalloc.h>
 
+#include <net/addrconf.h>
 #include <net/inet_connection_sock.h>
 #include <net/inet_hashtables.h>
 #include <net/secure_seq.h>
 #include <net/ip.h>
+#include <net/sock_reuseport.h>
 
 static u32 inet_ehashfn(const struct net *net, const __be32 laddr,
 			const __u16 lport, const __be32 faddr,
@@ -215,6 +217,7 @@ struct sock *__inet_lookup_listener(struct net *net,
 	unsigned int hash = inet_lhashfn(net, hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
 	int score, hiscore, matches = 0, reuseport = 0;
+	bool select_ok = true;
 	u32 phash = 0;
 
 	rcu_read_lock();
@@ -230,6 +233,15 @@ begin:
 			if (reuseport) {
 				phash = inet_ehashfn(net, daddr, hnum,
 						     saddr, sport);
+				if (select_ok) {
+					struct sock *sk2;
+					sk2 = reuseport_select_sock(sk, phash,
+								    skb, doff);
+					if (sk2) {
+						result = sk2;
+						goto found;
+					}
+				}
 				matches = 1;
 			}
 		} else if (score == hiscore && reuseport) {
@@ -247,11 +259,13 @@ begin:
 	if (get_nulls_value(node) != hash + LISTENING_NULLS_BASE)
 		goto begin;
 	if (result) {
+found:
 		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
 			result = NULL;
 		else if (unlikely(compute_score(result, net, hnum, daddr,
 				  dif) < hiscore)) {
 			sock_put(result);
+			select_ok = false;
 			goto begin;
 		}
 	}
@@ -450,34 +464,74 @@ bool inet_ehash_nolisten(struct sock *sk, struct sock *osk)
 }
 EXPORT_SYMBOL_GPL(inet_ehash_nolisten);
 
-void __inet_hash(struct sock *sk, struct sock *osk)
+static int inet_reuseport_add_sock(struct sock *sk,
+				   struct inet_listen_hashbucket *ilb,
+				   int (*saddr_same)(const struct sock *sk1,
+						     const struct sock *sk2,
+						     bool match_wildcard))
+{
+	struct sock *sk2;
+	struct hlist_nulls_node *node;
+	kuid_t uid = sock_i_uid(sk);
+
+	sk_nulls_for_each_rcu(sk2, node, &ilb->head) {
+		if (sk2 != sk &&
+		    sk2->sk_family == sk->sk_family &&
+		    ipv6_only_sock(sk2) == ipv6_only_sock(sk) &&
+		    sk2->sk_bound_dev_if == sk->sk_bound_dev_if &&
+		    sk2->sk_reuseport && uid_eq(uid, sock_i_uid(sk2)) &&
+		    saddr_same(sk, sk2, false))
+			return reuseport_add_sock(sk, sk2);
+	}
+
+	/* Initial allocation may have already happened via setsockopt */
+	if (!rcu_access_pointer(sk->sk_reuseport_cb))
+		return reuseport_alloc(sk);
+	return 0;
+}
+
+int __inet_hash(struct sock *sk, struct sock *osk,
+		 int (*saddr_same)(const struct sock *sk1,
+				   const struct sock *sk2,
+				   bool match_wildcard))
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct inet_listen_hashbucket *ilb;
+	int err = 0;
 
 	if (sk->sk_state != TCP_LISTEN) {
 		inet_ehash_nolisten(sk, osk);
-		return;
+		return 0;
 	}
 	WARN_ON(!sk_unhashed(sk));
 	ilb = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
 
 	spin_lock(&ilb->lock);
+	if (sk->sk_reuseport) {
+		err = inet_reuseport_add_sock(sk, ilb, saddr_same);
+		if (err)
+			goto unlock;
+	}
 	__sk_nulls_add_node_rcu(sk, &ilb->head);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+unlock:
 	spin_unlock(&ilb->lock);
+
+	return err;
 }
 EXPORT_SYMBOL(__inet_hash);
 
 int inet_hash(struct sock *sk)
 {
+	int err = 0;
+
 	if (sk->sk_state != TCP_CLOSE) {
 		local_bh_disable();
-		__inet_hash(sk, NULL);
+		err = __inet_hash(sk, NULL, ipv4_rcv_saddr_equal);
 		local_bh_enable();
 	}
 
-	return 0;
+	return err;
 }
 EXPORT_SYMBOL_GPL(inet_hash);
 
@@ -496,6 +550,8 @@ void inet_unhash(struct sock *sk)
 		lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 
 	spin_lock_bh(lock);
+	if (rcu_access_pointer(sk->sk_reuseport_cb))
+		reuseport_detach_sock(sk);
 	done = __sk_nulls_del_node_init_rcu(sk);
 	if (done)
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index be0b21852b13..ac3cedb25a9f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -356,8 +356,8 @@ EXPORT_SYMBOL(udp_lib_get_port);
  * match_wildcard == false: addresses must be exactly the same, i.e.
  *                          0.0.0.0 only equals to 0.0.0.0
  */
-static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2,
-				bool match_wildcard)
+int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2,
+			 bool match_wildcard)
 {
 	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 36c3f0155010..532c3ef282c5 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -26,6 +26,7 @@
 #include <net/ip6_route.h>
 #include <net/sock.h>
 #include <net/inet6_connection_sock.h>
+#include <net/sock_reuseport.h>
 
 int inet6_csk_bind_conflict(const struct sock *sk,
 			    const struct inet_bind_bucket *tb, bool relax)
@@ -48,6 +49,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 			if ((!reuse || !sk2->sk_reuse ||
 			     sk2->sk_state == TCP_LISTEN) &&
 			    (!reuseport || !sk2->sk_reuseport ||
+			     rcu_access_pointer(sk->sk_reuseport_cb) ||
 			     (sk2->sk_state != TCP_TIME_WAIT &&
 			      !uid_eq(uid,
 				      sock_i_uid((struct sock *)sk2))))) {
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 19913e9e09e0..1ec87f62bdd7 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -17,11 +17,13 @@
 #include <linux/module.h>
 #include <linux/random.h>
 
+#include <net/addrconf.h>
 #include <net/inet_connection_sock.h>
 #include <net/inet_hashtables.h>
 #include <net/inet6_hashtables.h>
 #include <net/secure_seq.h>
 #include <net/ip.h>
+#include <net/sock_reuseport.h>
 
 u32 inet6_ehashfn(const struct net *net,
 		  const struct in6_addr *laddr, const u16 lport,
@@ -131,6 +133,7 @@ struct sock *inet6_lookup_listener(struct net *net,
 	const struct hlist_nulls_node *node;
 	struct sock *result;
 	int score, hiscore, matches = 0, reuseport = 0;
+	bool select_ok = true;
 	u32 phash = 0;
 	unsigned int hash = inet_lhashfn(net, hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
@@ -148,6 +151,15 @@ begin:
 			if (reuseport) {
 				phash = inet6_ehashfn(net, daddr, hnum,
 						      saddr, sport);
+				if (select_ok) {
+					struct sock *sk2;
+					sk2 = reuseport_select_sock(sk, phash,
+								    skb, doff);
+					if (sk2) {
+						result = sk2;
+						goto found;
+					}
+				}
 				matches = 1;
 			}
 		} else if (score == hiscore && reuseport) {
@@ -165,11 +177,13 @@ begin:
 	if (get_nulls_value(node) != hash + LISTENING_NULLS_BASE)
 		goto begin;
 	if (result) {
+found:
 		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
 			result = NULL;
 		else if (unlikely(compute_score(result, net, hnum, daddr,
 				  dif) < hiscore)) {
 			sock_put(result);
+			select_ok = false;
 			goto begin;
 		}
 	}
@@ -283,7 +297,7 @@ int inet6_hash(struct sock *sk)
 {
 	if (sk->sk_state != TCP_CLOSE) {
 		local_bh_disable();
-		__inet_hash(sk, NULL);
+		__inet_hash(sk, NULL, ipv6_rcv_saddr_equal);
 		local_bh_enable();
 	}
 
-- 
2.7.0.rc3.207.g0ac5344
