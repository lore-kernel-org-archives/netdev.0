From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 3/6 net-next] inet: kill smallest_size and smallest_port
Date: Tue, 17 Jan 2017 07:51:03 -0800
Message-ID: <20170117155106.22637-4-jbacik@fb.com>
References: <20170117155106.22637-1-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <hannes@stressinduktion.org>,
        <kraigatgoog@gmail.com>, <eric.dumazet@gmail.com>,
        <tom@herbertland.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37345 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751002AbdAQPvc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 10:51:32 -0500
In-Reply-To: <20170117155106.22637-1-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In inet_csk_get_port we seem to be using smallest_port to figure out where the
best place to look for a SO_REUSEPORT sk that matches with an existing set of
SO_REUSEPORT's.  However if we get to the logic

if (smallest_size != -1) {
	port = smallest_port;
	goto have_port;
}

we will do a useless search, because we would have already done the
inet_csk_bind_conflict for that port and it would have returned 1, otherwise we
would have gone to found_tb and succeeded.  Since this logic makes us do yet
another trip through inet_csk_bind_conflict for a port we know won't work just
delete this code and save us the time.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 include/net/inet_hashtables.h   |  1 -
 net/ipv4/inet_connection_sock.c | 26 ++++----------------------
 net/ipv4/inet_hashtables.c      |  3 ---
 3 files changed, 4 insertions(+), 26 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 756ed16..3fc0366 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -80,7 +80,6 @@ struct inet_bind_bucket {
 	signed char		fastreuse;
 	signed char		fastreuseport;
 	kuid_t			fastuid;
-	int			num_owners;
 	struct hlist_node	node;
 	struct hlist_head	owners;
 };
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index a1c9055..d352366 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -165,7 +165,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	bool reuse = sk->sk_reuse && sk->sk_state != TCP_LISTEN;
 	struct inet_hashinfo *hinfo = sk->sk_prot->h.hashinfo;
 	int ret = 1, attempts = 5, port = snum;
-	int smallest_size = -1, smallest_port;
 	struct inet_bind_hashbucket *head;
 	struct net *net = sock_net(sk);
 	int i, low, high, attempt_half;
@@ -175,7 +174,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	bool reuseport_ok = !!snum;
 
 	if (port) {
-have_port:
 		head = &hinfo->bhash[inet_bhashfn(net, port,
 						  hinfo->bhash_size)];
 		spin_lock_bh(&head->lock);
@@ -209,8 +207,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	 * We do the opposite to not pollute connect() users.
 	 */
 	offset |= 1U;
-	smallest_size = -1;
-	smallest_port = low; /* avoid compiler warning */
 
 other_parity_scan:
 	port = low + offset;
@@ -224,15 +220,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		spin_lock_bh(&head->lock);
 		inet_bind_bucket_for_each(tb, &head->chain)
 			if (net_eq(ib_net(tb), net) && tb->port == port) {
-				if (((tb->fastreuse > 0 && reuse) ||
-				     (tb->fastreuseport > 0 &&
-				      sk->sk_reuseport &&
-				      !rcu_access_pointer(sk->sk_reuseport_cb) &&
-				      uid_eq(tb->fastuid, uid))) &&
-				    (tb->num_owners < smallest_size || smallest_size == -1)) {
-					smallest_size = tb->num_owners;
-					smallest_port = port;
-				}
 				if (!inet_csk_bind_conflict(sk, tb, false, reuseport_ok))
 					goto tb_found;
 				goto next_port;
@@ -243,10 +230,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		cond_resched();
 	}
 
-	if (smallest_size != -1) {
-		port = smallest_port;
-		goto have_port;
-	}
 	offset--;
 	if (!(offset & 1))
 		goto other_parity_scan;
@@ -268,19 +251,18 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		if (sk->sk_reuse == SK_FORCE_REUSE)
 			goto success;
 
-		if (((tb->fastreuse > 0 && reuse) ||
+		if ((tb->fastreuse > 0 && reuse) ||
 		     (tb->fastreuseport > 0 &&
 		      !rcu_access_pointer(sk->sk_reuseport_cb) &&
-		      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
-		    smallest_size == -1)
+		      sk->sk_reuseport && uid_eq(tb->fastuid, uid)))
 			goto success;
 		if (inet_csk_bind_conflict(sk, tb, true, reuseport_ok)) {
 			if ((reuse ||
 			     (tb->fastreuseport > 0 &&
 			      sk->sk_reuseport &&
 			      !rcu_access_pointer(sk->sk_reuseport_cb) &&
-			      uid_eq(tb->fastuid, uid))) &&
-			    !snum && smallest_size != -1 && --attempts >= 0) {
+			      uid_eq(tb->fastuid, uid))) && !snum &&
+			    --attempts >= 0) {
 				spin_unlock_bh(&head->lock);
 				goto again;
 			}
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 2ef9b01..8bea742 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -73,7 +73,6 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 		tb->port      = snum;
 		tb->fastreuse = 0;
 		tb->fastreuseport = 0;
-		tb->num_owners = 0;
 		INIT_HLIST_HEAD(&tb->owners);
 		hlist_add_head(&tb->node, &head->chain);
 	}
@@ -96,7 +95,6 @@ void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 {
 	inet_sk(sk)->inet_num = snum;
 	sk_add_bind_node(sk, &tb->owners);
-	tb->num_owners++;
 	inet_csk(sk)->icsk_bind_hash = tb;
 }
 
@@ -114,7 +112,6 @@ static void __inet_put_port(struct sock *sk)
 	spin_lock(&head->lock);
 	tb = inet_csk(sk)->icsk_bind_hash;
 	__sk_del_bind_node(sk);
-	tb->num_owners--;
 	inet_csk(sk)->icsk_bind_hash = NULL;
 	inet_sk(sk)->inet_num = 0;
 	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
-- 
2.9.3
