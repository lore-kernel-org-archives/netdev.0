From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: convert TCP/DCCP ehash rwlocks to spinlocks
Date: Thu, 20 Nov 2008 19:53:56 +0100
Message-ID: <4925B244.3090807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080303000606060602090205"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:45902 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755965AbYKTSyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 13:54:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080303000606060602090205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Now TCP & DCCP use RCU lookups, we can convert ehash rwlocks to spinlocks.

/proc/net/tcp and other seq_file 'readers' can safely be converted to 'writers'.

This should speedup writers, since spin_lock()/spin_unlock()
only use one atomic operation instead of two for write_lock()/write_unlock()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/inet_hashtables.h |   14 +++++++-------
 net/ipv4/inet_hashtables.c    |   21 ++++++++++-----------
 net/ipv4/inet_timewait_sock.c |   22 +++++++++++-----------
 net/ipv4/tcp_ipv4.c           |   12 ++++++------
 net/ipv6/inet6_hashtables.c   |   15 +++++++--------
 5 files changed, 41 insertions(+), 43 deletions(-)

--------------080303000606060602090205
Content-Type: text/plain;
 name="ehash_rwlock_to_spinlock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ehash_rwlock_to_spinlock.patch"

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 62d2dd0..28b3ee3 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -116,7 +116,7 @@ struct inet_hashinfo {
 	 * TIME_WAIT sockets use a separate chain (twchain).
 	 */
 	struct inet_ehash_bucket	*ehash;
-	rwlock_t			*ehash_locks;
+	spinlock_t			*ehash_locks;
 	unsigned int			ehash_size;
 	unsigned int			ehash_locks_mask;
 
@@ -152,7 +152,7 @@ static inline struct inet_ehash_bucket *inet_ehash_bucket(
 	return &hashinfo->ehash[hash & (hashinfo->ehash_size - 1)];
 }
 
-static inline rwlock_t *inet_ehash_lockp(
+static inline spinlock_t *inet_ehash_lockp(
 	struct inet_hashinfo *hashinfo,
 	unsigned int hash)
 {
@@ -177,16 +177,16 @@ static inline int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
 		size = 4096;
 	if (sizeof(rwlock_t) != 0) {
 #ifdef CONFIG_NUMA
-		if (size * sizeof(rwlock_t) > PAGE_SIZE)
-			hashinfo->ehash_locks = vmalloc(size * sizeof(rwlock_t));
+		if (size * sizeof(spinlock_t) > PAGE_SIZE)
+			hashinfo->ehash_locks = vmalloc(size * sizeof(spinlock_t));
 		else
 #endif
-		hashinfo->ehash_locks =	kmalloc(size * sizeof(rwlock_t),
+		hashinfo->ehash_locks =	kmalloc(size * sizeof(spinlock_t),
 						GFP_KERNEL);
 		if (!hashinfo->ehash_locks)
 			return ENOMEM;
 		for (i = 0; i < size; i++)
-			rwlock_init(&hashinfo->ehash_locks[i]);
+			spin_lock_init(&hashinfo->ehash_locks[i]);
 	}
 	hashinfo->ehash_locks_mask = size - 1;
 	return 0;
@@ -197,7 +197,7 @@ static inline void inet_ehash_locks_free(struct inet_hashinfo *hashinfo)
 	if (hashinfo->ehash_locks) {
 #ifdef CONFIG_NUMA
 		unsigned int size = (hashinfo->ehash_locks_mask + 1) *
-							sizeof(rwlock_t);
+							sizeof(spinlock_t);
 		if (size > PAGE_SIZE)
 			vfree(hashinfo->ehash_locks);
 		else
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 377d004..4c273a9 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -271,13 +271,12 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 	struct net *net = sock_net(sk);
 	unsigned int hash = inet_ehashfn(net, daddr, lport, saddr, inet->dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
-	rwlock_t *lock = inet_ehash_lockp(hinfo, hash);
+	spinlock_t *lock = inet_ehash_lockp(hinfo, hash);
 	struct sock *sk2;
 	const struct hlist_nulls_node *node;
 	struct inet_timewait_sock *tw;
 
-	prefetch(head->chain.first);
-	write_lock(lock);
+	spin_lock(lock);
 
 	/* Check TIME-WAIT sockets first. */
 	sk_nulls_for_each(sk2, node, &head->twchain) {
@@ -308,8 +307,8 @@ unique:
 	sk->sk_hash = hash;
 	WARN_ON(!sk_unhashed(sk));
 	__sk_nulls_add_node_rcu(sk, &head->chain);
+	spin_unlock(lock);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
-	write_unlock(lock);
 
 	if (twp) {
 		*twp = tw;
@@ -325,7 +324,7 @@ unique:
 	return 0;
 
 not_unique:
-	write_unlock(lock);
+	spin_unlock(lock);
 	return -EADDRNOTAVAIL;
 }
 
@@ -340,7 +339,7 @@ void __inet_hash_nolisten(struct sock *sk)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct hlist_nulls_head *list;
-	rwlock_t *lock;
+	spinlock_t *lock;
 	struct inet_ehash_bucket *head;
 
 	WARN_ON(!sk_unhashed(sk));
@@ -350,10 +349,10 @@ void __inet_hash_nolisten(struct sock *sk)
 	list = &head->chain;
 	lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 
-	write_lock(lock);
+	spin_lock(lock);
 	__sk_nulls_add_node_rcu(sk, list);
+	spin_unlock(lock);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
-	write_unlock(lock);
 }
 EXPORT_SYMBOL_GPL(__inet_hash_nolisten);
 
@@ -402,12 +401,12 @@ void inet_unhash(struct sock *sk)
 			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 		spin_unlock_bh(&ilb->lock);
 	} else {
-		rwlock_t *lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
+		spinlock_t *lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 
-		write_lock_bh(lock);
+		spin_lock_bh(lock);
 		if (__sk_nulls_del_node_init_rcu(sk))
 			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
-		write_unlock_bh(lock);
+		spin_unlock_bh(lock);
 	}
 }
 EXPORT_SYMBOL_GPL(inet_unhash);
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 6068995..8554d0e 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -20,16 +20,16 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 	struct inet_bind_hashbucket *bhead;
 	struct inet_bind_bucket *tb;
 	/* Unlink from established hashes. */
-	rwlock_t *lock = inet_ehash_lockp(hashinfo, tw->tw_hash);
+	spinlock_t *lock = inet_ehash_lockp(hashinfo, tw->tw_hash);
 
-	write_lock(lock);
+	spin_lock(lock);
 	if (hlist_nulls_unhashed(&tw->tw_node)) {
-		write_unlock(lock);
+		spin_unlock(lock);
 		return;
 	}
 	hlist_nulls_del_rcu(&tw->tw_node);
 	sk_nulls_node_init(&tw->tw_node);
-	write_unlock(lock);
+	spin_unlock(lock);
 
 	/* Disassociate with bind bucket. */
 	bhead = &hashinfo->bhash[inet_bhashfn(twsk_net(tw), tw->tw_num,
@@ -76,7 +76,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 	const struct inet_sock *inet = inet_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct inet_ehash_bucket *ehead = inet_ehash_bucket(hashinfo, sk->sk_hash);
-	rwlock_t *lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
+	spinlock_t *lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 	struct inet_bind_hashbucket *bhead;
 	/* Step 1: Put TW into bind hash. Original socket stays there too.
 	   Note, that any socket with inet->num != 0 MUST be bound in
@@ -90,7 +90,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 	inet_twsk_add_bind_node(tw, &tw->tw_tb->owners);
 	spin_unlock(&bhead->lock);
 
-	write_lock(lock);
+	spin_lock(lock);
 
 	/*
 	 * Step 2: Hash TW into TIMEWAIT chain.
@@ -104,7 +104,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 	if (__sk_nulls_del_node_init_rcu(sk))
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 
-	write_unlock(lock);
+	spin_unlock(lock);
 }
 
 EXPORT_SYMBOL_GPL(__inet_twsk_hashdance);
@@ -427,9 +427,9 @@ void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinfo,
 	for (h = 0; h < (hashinfo->ehash_size); h++) {
 		struct inet_ehash_bucket *head =
 			inet_ehash_bucket(hashinfo, h);
-		rwlock_t *lock = inet_ehash_lockp(hashinfo, h);
+		spinlock_t *lock = inet_ehash_lockp(hashinfo, h);
 restart:
-		write_lock(lock);
+		spin_lock(lock);
 		sk_nulls_for_each(sk, node, &head->twchain) {
 
 			tw = inet_twsk(sk);
@@ -438,13 +438,13 @@ restart:
 				continue;
 
 			atomic_inc(&tw->tw_refcnt);
-			write_unlock(lock);
+			spin_unlock(lock);
 			inet_twsk_deschedule(tw, twdr);
 			inet_twsk_put(tw);
 
 			goto restart;
 		}
-		write_unlock(lock);
+		spin_unlock(lock);
 	}
 	local_bh_enable();
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 330b08a..a81caa1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1970,13 +1970,13 @@ static void *established_get_first(struct seq_file *seq)
 		struct sock *sk;
 		struct hlist_nulls_node *node;
 		struct inet_timewait_sock *tw;
-		rwlock_t *lock = inet_ehash_lockp(&tcp_hashinfo, st->bucket);
+		spinlock_t *lock = inet_ehash_lockp(&tcp_hashinfo, st->bucket);
 
 		/* Lockless fast path for the common case of empty buckets */
 		if (empty_bucket(st))
 			continue;
 
-		read_lock_bh(lock);
+		spin_lock_bh(lock);
 		sk_nulls_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
 			if (sk->sk_family != st->family ||
 			    !net_eq(sock_net(sk), net)) {
@@ -1995,7 +1995,7 @@ static void *established_get_first(struct seq_file *seq)
 			rc = tw;
 			goto out;
 		}
-		read_unlock_bh(lock);
+		spin_unlock_bh(lock);
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 	}
 out:
@@ -2023,7 +2023,7 @@ get_tw:
 			cur = tw;
 			goto out;
 		}
-		read_unlock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
+		spin_unlock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 
 		/* Look for next non empty bucket */
@@ -2033,7 +2033,7 @@ get_tw:
 		if (st->bucket >= tcp_hashinfo.ehash_size)
 			return NULL;
 
-		read_lock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
+		spin_lock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
 		sk = sk_nulls_head(&tcp_hashinfo.ehash[st->bucket].chain);
 	} else
 		sk = sk_nulls_next(sk);
@@ -2134,7 +2134,7 @@ static void tcp_seq_stop(struct seq_file *seq, void *v)
 	case TCP_SEQ_STATE_TIME_WAIT:
 	case TCP_SEQ_STATE_ESTABLISHED:
 		if (v)
-			read_unlock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
+			spin_unlock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
 		break;
 	}
 }
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 21544b9..e0fd681 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -38,14 +38,14 @@ void __inet6_hash(struct sock *sk)
 	} else {
 		unsigned int hash;
 		struct hlist_nulls_head *list;
-		rwlock_t *lock;
+		spinlock_t *lock;
 
 		sk->sk_hash = hash = inet6_sk_ehashfn(sk);
 		list = &inet_ehash_bucket(hashinfo, hash)->chain;
 		lock = inet_ehash_lockp(hashinfo, hash);
-		write_lock(lock);
+		spin_lock(lock);
 		__sk_nulls_add_node_rcu(sk, list);
-		write_unlock(lock);
+		spin_unlock(lock);
 	}
 
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
@@ -195,13 +195,12 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 	const unsigned int hash = inet6_ehashfn(net, daddr, lport, saddr,
 						inet->dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
-	rwlock_t *lock = inet_ehash_lockp(hinfo, hash);
+	spinlock_t *lock = inet_ehash_lockp(hinfo, hash);
 	struct sock *sk2;
 	const struct hlist_nulls_node *node;
 	struct inet_timewait_sock *tw;
 
-	prefetch(head->chain.first);
-	write_lock(lock);
+	spin_lock(lock);
 
 	/* Check TIME-WAIT sockets first. */
 	sk_nulls_for_each(sk2, node, &head->twchain) {
@@ -230,8 +229,8 @@ unique:
 	WARN_ON(!sk_unhashed(sk));
 	__sk_nulls_add_node_rcu(sk, &head->chain);
 	sk->sk_hash = hash;
+	spin_unlock(lock);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
-	write_unlock(lock);
 
 	if (twp != NULL) {
 		*twp = tw;
@@ -246,7 +245,7 @@ unique:
 	return 0;
 
 not_unique:
-	write_unlock(lock);
+	spin_unlock(lock);
 	return -EADDRNOTAVAIL;
 }
 

--------------080303000606060602090205--
