From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [RFC PATCH 3/4] inet: add/remove inet buckets in the second bind hash
Date: Wed, 30 May 2012 10:36:49 +0300
Message-ID: <1338363410-6562-4-git-send-email-alex.mihai.c@gmail.com>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
Cc: gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43274 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048Ab2E3HjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 03:39:00 -0400
Received: by weyu7 with SMTP id u7so3152004wey.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 00:38:59 -0700 (PDT)
In-Reply-To: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
Cc: Lucian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/inet_hashtables.h    |   77 +++++++++++++++++++++++++++++++++++---
 include/net/inet_timewait_sock.h |    3 +-
 net/ipv4/inet_connection_sock.c  |   13 +++++--
 net/ipv4/inet_hashtables.c       |   34 ++++++++++++++---
 net/ipv4/inet_timewait_sock.c    |   15 +++++---
 5 files changed, 122 insertions(+), 20 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index a6d0db2..bc06168 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -225,13 +225,15 @@ static inline void inet_ehash_locks_free(struct inet_hashinfo *hashinfo)
 }
 
 extern struct inet_bind_bucket *
-		    inet_bind_bucket_create(struct kmem_cache *cachep,
-					    struct net *net,
-					    struct inet_bind_hashbucket *head,
-					    const unsigned short snum);
+	    inet_bind_bucket_create(struct kmem_cache *cachep,
+				    struct net *net,
+				    struct inet_bind_hashbucket *head,
+				    struct inet_bind_hashbucket *portaddr_head,
+				    const unsigned short snum);
 extern void inet_bind_bucket_destroy(struct kmem_cache *cachep,
 				     struct inet_bind_bucket *tb,
-				     struct inet_bind_hashbucket *head);
+				     struct inet_bind_hashbucket *head,
+				     struct inet_bind_hashbucket *portaddr_head);
 
 static inline int inet_bhashfn(struct net *net,
 		const __u16 lport, const int bhash_size)
@@ -239,6 +241,71 @@ static inline int inet_bhashfn(struct net *net,
 	return (lport + net_hash_mix(net)) & (bhash_size - 1);
 }
 
+static inline unsigned int inet4_portaddr_bhashfn(struct net *net, __be32 saddr,
+						  unsigned int port)
+{
+	return jhash_1word(saddr, net_hash_mix(net)) ^ port;
+}
+
+static inline struct inet_bind_hashbucket *
+		inet4_portaddr_hashbucket(struct inet_hashinfo *hinfo,
+					  struct net *net,
+					  __be32 saddr,
+					  unsigned int port)
+{
+	unsigned int h = inet4_portaddr_bhashfn(net, saddr, port);
+	return &hinfo->portaddr_bhash[h & (hinfo->portaddr_bhash_size - 1)];
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static inline unsigned int inet6_portaddr_bhashfn(struct net *net,
+						  const struct in6_addr *addr6,
+						  unsigned int port)
+{
+	unsigned int hash, mix = net_hash_mix(net);
+
+	if (ipv6_addr_any(addr6))
+		hash = jhash_1word(0, mix);
+	else if (ipv6_addr_v4mapped(addr6))
+		hash = jhash_1word(addr6->s6_addr32[3], mix);
+	else
+		hash = jhash2(addr6->s6_addr32, 4, mix);
+
+	return hash ^ port;
+}
+
+static inline struct inet_bind_hashbucket *
+		inet6_portaddr_hashbucket(struct inet_hashinfo *hinfo,
+					  struct net *net,
+					  const struct in6_addr *addr6,
+					  unsigned int port)
+{
+	unsigned int h = inet6_portaddr_bhashfn(net, addr6, port);
+	return &hinfo->portaddr_bhash[h & (hinfo->portaddr_bhash_size - 1)];
+}
+#endif
+
+
+static inline struct inet_bind_hashbucket *
+		inet_portaddr_hashbucket(struct inet_hashinfo *hinfo,
+					 struct sock  *sk,
+					 unsigned int port)
+{
+	struct net *net = sock_net(sk);
+	switch (sk->sk_family) {
+	case AF_INET:
+		return inet4_portaddr_hashbucket(hinfo, net,
+				inet_sk(sk)->inet_rcv_saddr, port);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		return inet6_portaddr_hashbucket(hinfo, net,
+				&inet6_sk(sk)->rcv_saddr, port);
+#endif
+	}
+	WARN(1, "unrecognised sk->sk_family in inet_portaddr_hashbucket");
+	return inet4_portaddr_hashbucket(hinfo, net, INADDR_ANY, port);
+}
+
 extern void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 			   const unsigned short snum);
 
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 725e903..d60d8a9 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -199,7 +199,8 @@ extern int inet_twsk_unhash(struct inet_timewait_sock *tw);
 
 extern int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
 				 struct inet_hashinfo *hashinfo,
-				 struct inet_bind_hashbucket *head);
+				 struct inet_bind_hashbucket *head,
+				 struct inet_bind_hashbucket *portaddr_head);
 
 extern struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
 						  const int state);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 95e61596..336531a 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -204,9 +204,16 @@ tb_found:
 	}
 tb_not_found:
 	ret = 1;
-	if (!tb && (tb = inet_bind_bucket_create(hashinfo->bind_bucket_cachep,
-					net, head, snum)) == NULL)
-		goto fail_unlock;
+	if (!tb) {
+		struct inet_bind_hashbucket *portaddr_head;
+		portaddr_head = inet_portaddr_hashbucket(hashinfo, sk, snum);
+		spin_lock(&portaddr_head->lock);
+		tb = inet_bind_bucket_create(hashinfo->bind_bucket_cachep,
+				net, head, portaddr_head, snum);
+		spin_unlock(&portaddr_head->lock);
+		if (!tb)
+			goto fail_unlock;
+	}
 	if (hlist_empty(&tb->owners)) {
 		if (sk->sk_reuse && sk->sk_state != TCP_LISTEN)
 			tb->fastreuse = 1;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index c1f6f28..edb2a4e 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -31,6 +31,7 @@
 struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 						 struct net *net,
 						 struct inet_bind_hashbucket *head,
+						 struct inet_bind_hashbucket *portaddr_head,
 						 const unsigned short snum)
 {
 	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
@@ -43,6 +44,8 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 		INIT_HLIST_HEAD(&tb->owners);
 		hlist_add_head(&tb->node, &head->chain);
 		head->count++;
+		hlist_add_head(&tb->portaddr_node, &portaddr_head->chain);
+		portaddr_head->count++;
 	}
 	return tb;
 }
@@ -51,11 +54,14 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
  * Caller must hold hashbucket lock for this tb with local BH disabled
  */
 void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket *tb,
-			      struct inet_bind_hashbucket *head)
+			      struct inet_bind_hashbucket *head,
+			      struct inet_bind_hashbucket *portaddr_head)
 {
 	if (hlist_empty(&tb->owners)) {
 		head->count--;
 		__hlist_del(&tb->node);
+		portaddr_head->count--;
+		__hlist_del(&tb->portaddr_node);
 		release_net(ib_net(tb));
 		kmem_cache_free(cachep, tb);
 	}
@@ -83,17 +89,22 @@ static void __inet_put_port(struct sock *sk)
 	const int bhash = inet_bhashfn(sock_net(sk), inet_sk(sk)->inet_num,
 			hashinfo->bhash_size);
 	struct inet_bind_hashbucket *head = &hashinfo->bhash[bhash];
+	struct inet_bind_hashbucket *portaddr_head =
+		inet_portaddr_hashbucket(hashinfo, sk, inet_sk(sk)->inet_num);
 	struct inet_bind_bucket *tb;
 
 	atomic_dec(&hashinfo->bsockets);
 
 	spin_lock(&head->lock);
+	spin_lock(&portaddr_head->lock);
 	tb = inet_csk(sk)->icsk_bind_hash;
 	__sk_del_bind_node(sk);
 	tb->num_owners--;
 	inet_csk(sk)->icsk_bind_hash = NULL;
 	inet_sk(sk)->inet_num = 0;
-	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb, head);
+	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb,
+				 head, portaddr_head);
+	spin_unlock(&portaddr_head->lock);
 	spin_unlock(&head->lock);
 }
 
@@ -112,6 +123,8 @@ int __inet_inherit_port(struct sock *sk, struct sock *child)
 	const int bhash = inet_bhashfn(sock_net(sk), port,
 			table->bhash_size);
 	struct inet_bind_hashbucket *head = &table->bhash[bhash];
+	struct inet_bind_hashbucket *portaddr_head =
+		inet_portaddr_hashbucket(table, sk, port);
 	struct inet_bind_bucket *tb;
 
 	spin_lock(&head->lock);
@@ -130,7 +143,8 @@ int __inet_inherit_port(struct sock *sk, struct sock *child)
 		}
 		if (!node) {
 			tb = inet_bind_bucket_create(table->bind_bucket_cachep,
-						     sock_net(sk), head, port);
+						     sock_net(sk), head,
+						     portaddr_head, port);
 			if (!tb) {
 				spin_unlock(&head->lock);
 				return -ENOMEM;
@@ -462,7 +476,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 {
 	struct inet_hashinfo *hinfo = death_row->hashinfo;
 	const unsigned short snum = inet_sk(sk)->inet_num;
-	struct inet_bind_hashbucket *head;
+	struct inet_bind_hashbucket *head, *portaddr_head;
 	struct inet_bind_bucket *tb;
 	int ret;
 	struct net *net = sock_net(sk);
@@ -504,8 +518,12 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 				}
 			}
 
+			portaddr_head = inet_portaddr_hashbucket(hinfo, sk, port);
+			spin_lock(&portaddr_head->lock);
 			tb = inet_bind_bucket_create(hinfo->bind_bucket_cachep,
-					net, head, port);
+					net, head, portaddr_head, port);
+			spin_unlock(&portaddr_head->lock);
+
 			if (!tb) {
 				spin_unlock(&head->lock);
 				break;
@@ -529,8 +547,12 @@ ok:
 			inet_sk(sk)->inet_sport = htons(port);
 			twrefcnt += hash(sk, tw);
 		}
+		portaddr_head = inet_portaddr_hashbucket(hinfo, sk, port);
+		spin_lock(&portaddr_head->lock);
 		if (tw)
-			twrefcnt += inet_twsk_bind_unhash(tw, hinfo, head);
+			twrefcnt += inet_twsk_bind_unhash(tw, hinfo,
+							  head, portaddr_head);
+		spin_unlock(&portaddr_head->lock);
 		spin_unlock(&head->lock);
 
 		if (tw) {
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 5b7bcd0..29f8061 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -50,7 +50,8 @@ int inet_twsk_unhash(struct inet_timewait_sock *tw)
  */
 int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
 			  struct inet_hashinfo *hashinfo,
-			  struct inet_bind_hashbucket *head)
+			  struct inet_bind_hashbucket *head,
+			  struct inet_bind_hashbucket *portaddr_head)
 {
 	struct inet_bind_bucket *tb = tw->tw_tb;
 
@@ -59,7 +60,8 @@ int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
 
 	__hlist_del(&tw->tw_bind_node);
 	tw->tw_tb = NULL;
-	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb, head);
+	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb,
+				 head, portaddr_head);
 	/*
 	 * We cannot call inet_twsk_put() ourself under lock,
 	 * caller must call it for us.
@@ -71,7 +73,7 @@ int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
 static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 			     struct inet_hashinfo *hashinfo)
 {
-	struct inet_bind_hashbucket *bhead;
+	struct inet_bind_hashbucket *bhead, *portaddr_bhead;
 	int refcnt;
 	/* Unlink from established hashes. */
 	spinlock_t *lock = inet_ehash_lockp(hashinfo, tw->tw_hash);
@@ -83,9 +85,12 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 	/* Disassociate with bind bucket. */
 	bhead = &hashinfo->bhash[inet_bhashfn(twsk_net(tw), tw->tw_num,
 			hashinfo->bhash_size)];
-
+	portaddr_bhead = inet_portaddr_hashbucket(hashinfo, (struct sock *)tw,
+						  tw->tw_num);
 	spin_lock(&bhead->lock);
-	refcnt += inet_twsk_bind_unhash(tw, hashinfo, bhead);
+	spin_lock(&portaddr_bhead->lock);
+	refcnt += inet_twsk_bind_unhash(tw, hashinfo, bhead, portaddr_bhead);
+	spin_unlock(&portaddr_bhead->lock);
 	spin_unlock(&bhead->lock);
 
 #ifdef SOCK_REFCNT_DEBUG
-- 
1.7.10.2
