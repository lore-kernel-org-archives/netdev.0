From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] inet_hashinfo: remove bsocket counter
Date: Wed, 20 May 2015 10:59:01 -0700
Message-ID: <1432144742-17786-2-git-send-email-edumazet@google.com>
References: <1432144742-17786-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Flavio Leitner <fbl@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f73.google.com ([209.85.192.73]:33406 "EHLO
	mail-qg0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbbETR7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 13:59:11 -0400
Received: by qgdq107 with SMTP id q107so1658771qgd.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 10:59:10 -0700 (PDT)
In-Reply-To: <1432144742-17786-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We no longer need bsocket atomic counter, as inet_csk_get_port()
calls bind_conflict() regardless of its value, after commit
2b05ad33e1e624e ("tcp: bind() fix autoselection to share ports")

This patch removes overhead of maintaining this counter and
double inet_csk_get_port() calls under pressure.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>
Cc: Flavio Leitner <fbl@redhat.com>
---
 include/net/inet_hashtables.h   | 2 --
 net/ipv4/inet_connection_sock.c | 5 -----
 net/ipv4/inet_hashtables.c      | 7 -------
 3 files changed, 14 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 73fe0f9525d9..774d24151d4a 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -148,8 +148,6 @@ struct inet_hashinfo {
 	 */
 	struct inet_listen_hashbucket	listening_hash[INET_LHTABLE_SIZE]
 					____cacheline_aligned_in_smp;
-
-	atomic_t			bsockets;
 };
 
 static inline struct inet_ehash_bucket *inet_ehash_bucket(
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 8976ca423a07..b95fb263a13f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -127,11 +127,6 @@ again:
 					    (tb->num_owners < smallest_size || smallest_size == -1)) {
 						smallest_size = tb->num_owners;
 						smallest_rover = rover;
-						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1 &&
-						    !inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false)) {
-							snum = smallest_rover;
-							goto tb_found;
-						}
 					}
 					if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false)) {
 						snum = rover;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index c6fb80bd5826..3766bddb3e8a 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -90,10 +90,6 @@ void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket
 void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 		    const unsigned short snum)
 {
-	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
-
-	atomic_inc(&hashinfo->bsockets);
-
 	inet_sk(sk)->inet_num = snum;
 	sk_add_bind_node(sk, &tb->owners);
 	tb->num_owners++;
@@ -111,8 +107,6 @@ static void __inet_put_port(struct sock *sk)
 	struct inet_bind_hashbucket *head = &hashinfo->bhash[bhash];
 	struct inet_bind_bucket *tb;
 
-	atomic_dec(&hashinfo->bsockets);
-
 	spin_lock(&head->lock);
 	tb = inet_csk(sk)->icsk_bind_hash;
 	__sk_del_bind_node(sk);
@@ -608,7 +602,6 @@ void inet_hashinfo_init(struct inet_hashinfo *h)
 {
 	int i;
 
-	atomic_set(&h->bsockets, 0);
 	for (i = 0; i < INET_LHTABLE_SIZE; i++) {
 		spin_lock_init(&h->listening_hash[i].lock);
 		INIT_HLIST_NULLS_HEAD(&h->listening_hash[i].head,
-- 
2.2.0.rc0.207.ga3a616c
