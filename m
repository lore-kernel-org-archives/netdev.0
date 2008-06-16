From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 4/8] Inet: add struct net argument to inet_bhashfn
Date: Mon, 16 Jun 2008 13:43:06 +0400
Message-ID: <485635AA.5010609@openvz.org>
References: <485633E4.10900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39327 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754951AbYFPJpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:45:30 -0400
In-Reply-To: <485633E4.10900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Binding to some port in many namespaces may create too long
chains in bhash-es, so prepare the hashfn to take struct net
into account.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/inet_hashtables.h   |    3 ++-
 net/ipv4/inet_connection_sock.c |    6 ++++--
 net/ipv4/inet_hashtables.c      |   11 +++++++----
 net/ipv4/inet_timewait_sock.c   |    6 ++++--
 4 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 735b926..61dd331 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -201,7 +201,8 @@ extern struct inet_bind_bucket *
 extern void inet_bind_bucket_destroy(struct kmem_cache *cachep,
 				     struct inet_bind_bucket *tb);
 
-static inline int inet_bhashfn(const __u16 lport, const int bhash_size)
+static inline int inet_bhashfn(struct net *net,
+		const __u16 lport, const int bhash_size)
 {
 	return lport & (bhash_size - 1);
 }
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 828ea21..5c74f99 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -103,7 +103,8 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		rover = net_random() % remaining + low;
 
 		do {
-			head = &hashinfo->bhash[inet_bhashfn(rover, hashinfo->bhash_size)];
+			head = &hashinfo->bhash[inet_bhashfn(net, rover,
+					hashinfo->bhash_size)];
 			spin_lock(&head->lock);
 			inet_bind_bucket_for_each(tb, node, &head->chain)
 				if (tb->ib_net == net && tb->port == rover)
@@ -130,7 +131,8 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		 */
 		snum = rover;
 	} else {
-		head = &hashinfo->bhash[inet_bhashfn(snum, hashinfo->bhash_size)];
+		head = &hashinfo->bhash[inet_bhashfn(net, snum,
+				hashinfo->bhash_size)];
 		spin_lock(&head->lock);
 		inet_bind_bucket_for_each(tb, node, &head->chain)
 			if (tb->ib_net == net && tb->port == snum)
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 2023d37..dc1b78d 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -70,7 +70,8 @@ void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 static void __inet_put_port(struct sock *sk)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
-	const int bhash = inet_bhashfn(inet_sk(sk)->num, hashinfo->bhash_size);
+	const int bhash = inet_bhashfn(sock_net(sk), inet_sk(sk)->num,
+			hashinfo->bhash_size);
 	struct inet_bind_hashbucket *head = &hashinfo->bhash[bhash];
 	struct inet_bind_bucket *tb;
 
@@ -95,7 +96,8 @@ EXPORT_SYMBOL(inet_put_port);
 void __inet_inherit_port(struct sock *sk, struct sock *child)
 {
 	struct inet_hashinfo *table = sk->sk_prot->h.hashinfo;
-	const int bhash = inet_bhashfn(inet_sk(child)->num, table->bhash_size);
+	const int bhash = inet_bhashfn(sock_net(sk), inet_sk(child)->num,
+			table->bhash_size);
 	struct inet_bind_hashbucket *head = &table->bhash[bhash];
 	struct inet_bind_bucket *tb;
 
@@ -438,7 +440,8 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 		local_bh_disable();
 		for (i = 1; i <= remaining; i++) {
 			port = low + (i + offset) % remaining;
-			head = &hinfo->bhash[inet_bhashfn(port, hinfo->bhash_size)];
+			head = &hinfo->bhash[inet_bhashfn(net, port,
+					hinfo->bhash_size)];
 			spin_lock(&head->lock);
 
 			/* Does not bother with rcv_saddr checks,
@@ -493,7 +496,7 @@ ok:
 		goto out;
 	}
 
-	head = &hinfo->bhash[inet_bhashfn(snum, hinfo->bhash_size)];
+	head = &hinfo->bhash[inet_bhashfn(net, snum, hinfo->bhash_size)];
 	tb  = inet_csk(sk)->icsk_bind_hash;
 	spin_lock_bh(&head->lock);
 	if (sk_head(&tb->owners) == sk && !sk->sk_bind_node.next) {
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index ce16e9a..06006a5 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -32,7 +32,8 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 	write_unlock(lock);
 
 	/* Disassociate with bind bucket. */
-	bhead = &hashinfo->bhash[inet_bhashfn(tw->tw_num, hashinfo->bhash_size)];
+	bhead = &hashinfo->bhash[inet_bhashfn(twsk_net(tw), tw->tw_num,
+			hashinfo->bhash_size)];
 	spin_lock(&bhead->lock);
 	tb = tw->tw_tb;
 	__hlist_del(&tw->tw_bind_node);
@@ -81,7 +82,8 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 	   Note, that any socket with inet->num != 0 MUST be bound in
 	   binding cache, even if it is closed.
 	 */
-	bhead = &hashinfo->bhash[inet_bhashfn(inet->num, hashinfo->bhash_size)];
+	bhead = &hashinfo->bhash[inet_bhashfn(twsk_net(tw), inet->num,
+			hashinfo->bhash_size)];
 	spin_lock(&bhead->lock);
 	tw->tw_tb = icsk->icsk_bind_hash;
 	BUG_TRAP(icsk->icsk_bind_hash);
-- 
1.5.3.4

