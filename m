From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Thu, 01 Nov 2007 11:16:20 +0100
Message-ID: <4729A774.9030409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010409010109060108030002"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <ak@suse.de>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46222 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714AbXKAKQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 06:16:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010409010109060108030002
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

As done two years ago on IP route cache table (commit 
22c047ccbc68fa8f3fa57f0e8f906479a062c426) , we can avoid using one lock per 
hash bucket for the huge TCP/DCCP hash tables.

On a typical x86_64 platform, this saves about 2MB or 4MB of ram, for litle 
performance differences. (we hit a different cache line for the rwlock, but 
then the bucket cache line have a better sharing factor among cpus, since we 
dirty it less often)

Using a 'small' table of hashed rwlocks should be more than enough to provide 
correct SMP concurrency between different buckets, without using too much 
memory. Sizing of this table depends on NR_CPUS and various CONFIG settings.

This patch provides some locking abstraction that may ease a future work using 
  a different model for TCP/DCCP table.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

  include/net/inet_hashtables.h |   40 ++++++++++++++++++++++++++++----
  net/dccp/proto.c              |   16 ++++++++++--
  net/ipv4/inet_diag.c          |    9 ++++---
  net/ipv4/inet_hashtables.c    |    7 +++--
  net/ipv4/inet_timewait_sock.c |   13 +++++-----
  net/ipv4/tcp.c                |   11 +++++++-
  net/ipv4/tcp_ipv4.c           |   11 ++++----
  net/ipv6/inet6_hashtables.c   |   19 ++++++++-------
  8 files changed, 89 insertions(+), 37 deletions(-)


--------------010409010109060108030002
Content-Type: text/plain;
 name="tcp_ehash_locks.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp_ehash_locks.patch"

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 4427dcd..5cbfbac 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -37,7 +37,6 @@
  * I'll experiment with dynamic table growth later.
  */
 struct inet_ehash_bucket {
-	rwlock_t	  lock;
 	struct hlist_head chain;
 	struct hlist_head twchain;
 };
@@ -91,6 +90,28 @@ struct inet_bind_hashbucket {
 /* This is for listening sockets, thus all sockets which possess wildcards. */
 #define INET_LHTABLE_SIZE	32	/* Yes, really, this is all you need. */
 
+#if defined(CONFIG_SMP) || defined(CONFIG_PROVE_LOCKING)
+/*
+ * Instead of using one rwlock for each inet_ehash_bucket, we use a table of locks
+ * The size of this table is a power of two and depends on the number of CPUS.
+ */
+# if defined(CONFIG_DEBUG_LOCK_ALLOC)
+#  define EHASH_LOCK_SZ 256
+# elif NR_CPUS >= 32
+#  define EHASH_LOCK_SZ	4096
+# elif NR_CPUS >= 16
+#  define EHASH_LOCK_SZ	2048
+# elif NR_CPUS >= 8
+#  define EHASH_LOCK_SZ	1024
+# elif NR_CPUS >= 4
+#  define EHASH_LOCK_SZ	512
+# else
+#  define EHASH_LOCK_SZ	256
+# endif
+#else
+# define EHASH_LOCK_SZ 0
+#endif
+
 struct inet_hashinfo {
 	/* This is for sockets with full identity only.  Sockets here will
 	 * always be without wildcards and will have the following invariant:
@@ -100,6 +121,7 @@ struct inet_hashinfo {
 	 * TIME_WAIT sockets use a separate chain (twchain).
 	 */
 	struct inet_ehash_bucket	*ehash;
+	rwlock_t			*ehash_locks;
 
 	/* Ok, let's try this, I give up, we do need a local binding
 	 * TCP hash as well as the others for fast bind/connect.
@@ -134,6 +156,13 @@ static inline struct inet_ehash_bucket *inet_ehash_bucket(
 	return &hashinfo->ehash[hash & (hashinfo->ehash_size - 1)];
 }
 
+static inline rwlock_t *inet_ehash_lockp(
+	struct inet_hashinfo *hashinfo,
+	unsigned int hash)
+{
+	return &hashinfo->ehash_locks[hash & (EHASH_LOCK_SZ - 1)];
+}
+
 extern struct inet_bind_bucket *
 		    inet_bind_bucket_create(struct kmem_cache *cachep,
 					    struct inet_bind_hashbucket *head,
@@ -222,7 +251,7 @@ static inline void __inet_hash(struct inet_hashinfo *hashinfo,
 		sk->sk_hash = inet_sk_ehashfn(sk);
 		head = inet_ehash_bucket(hashinfo, sk->sk_hash);
 		list = &head->chain;
-		lock = &head->lock;
+		lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 		write_lock(lock);
 	}
 	__sk_add_node(sk, list);
@@ -253,7 +282,7 @@ static inline void inet_unhash(struct inet_hashinfo *hashinfo, struct sock *sk)
 		inet_listen_wlock(hashinfo);
 		lock = &hashinfo->lhash_lock;
 	} else {
-		lock = &inet_ehash_bucket(hashinfo, sk->sk_hash)->lock;
+		lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 		write_lock_bh(lock);
 	}
 
@@ -354,9 +383,10 @@ static inline struct sock *
 	 */
 	unsigned int hash = inet_ehashfn(daddr, hnum, saddr, sport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hashinfo, hash);
+	rwlock_t *lock = inet_ehash_lockp(hashinfo, hash);
 
 	prefetch(head->chain.first);
-	read_lock(&head->lock);
+	read_lock(lock);
 	sk_for_each(sk, node, &head->chain) {
 		if (INET_MATCH(sk, hash, acookie, saddr, daddr, ports, dif))
 			goto hit; /* You sunk my battleship! */
@@ -369,7 +399,7 @@ static inline struct sock *
 	}
 	sk = NULL;
 out:
-	read_unlock(&head->lock);
+	read_unlock(lock);
 	return sk;
 hit:
 	sock_hold(sk);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index d849739..3b5f97a 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1072,11 +1072,18 @@ static int __init dccp_init(void)
 	}
 
 	for (i = 0; i < dccp_hashinfo.ehash_size; i++) {
-		rwlock_init(&dccp_hashinfo.ehash[i].lock);
 		INIT_HLIST_HEAD(&dccp_hashinfo.ehash[i].chain);
 		INIT_HLIST_HEAD(&dccp_hashinfo.ehash[i].twchain);
 	}
-
+	if (EHASH_LOCK_SZ) {
+		dccp_hashinfo.ehash_locks =
+			kmalloc(EHASH_LOCK_SZ * sizeof(rwlock_t),
+				GFP_KERNEL);
+		if (!dccp_hashinfo.ehash_locks)
+			goto out_free_dccp_ehash;
+		for (i = 0; i < EHASH_LOCK_SZ; i++)
+			rwlock_init(&dccp_hashinfo.ehash_locks[i]);
+	}
 	bhash_order = ehash_order;
 
 	do {
@@ -1091,7 +1098,7 @@ static int __init dccp_init(void)
 
 	if (!dccp_hashinfo.bhash) {
 		DCCP_CRIT("Failed to allocate DCCP bind hash table");
-		goto out_free_dccp_ehash;
+		goto out_free_dccp_locks;
 	}
 
 	for (i = 0; i < dccp_hashinfo.bhash_size; i++) {
@@ -1121,6 +1128,9 @@ out_free_dccp_mib:
 out_free_dccp_bhash:
 	free_pages((unsigned long)dccp_hashinfo.bhash, bhash_order);
 	dccp_hashinfo.bhash = NULL;
+out_free_dccp_locks:
+	kfree(dccp_hashinfo.ehash_locks);
+	dccp_hashinfo.ehash_locks = NULL;
 out_free_dccp_ehash:
 	free_pages((unsigned long)dccp_hashinfo.ehash, ehash_order);
 	dccp_hashinfo.ehash = NULL;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index dc429b6..b017073 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -747,13 +747,14 @@ skip_listen_ht:
 
 	for (i = s_i; i < hashinfo->ehash_size; i++) {
 		struct inet_ehash_bucket *head = &hashinfo->ehash[i];
+		rwlock_t *lock = inet_ehash_lockp(hashinfo, i);
 		struct sock *sk;
 		struct hlist_node *node;
 
 		if (i > s_i)
 			s_num = 0;
 
-		read_lock_bh(&head->lock);
+		read_lock_bh(lock);
 		num = 0;
 		sk_for_each(sk, node, &head->chain) {
 			struct inet_sock *inet = inet_sk(sk);
@@ -769,7 +770,7 @@ skip_listen_ht:
 			    r->id.idiag_dport)
 				goto next_normal;
 			if (inet_csk_diag_dump(sk, skb, cb) < 0) {
-				read_unlock_bh(&head->lock);
+				read_unlock_bh(lock);
 				goto done;
 			}
 next_normal:
@@ -791,14 +792,14 @@ next_normal:
 				    r->id.idiag_dport)
 					goto next_dying;
 				if (inet_twsk_diag_dump(tw, skb, cb) < 0) {
-					read_unlock_bh(&head->lock);
+					read_unlock_bh(lock);
 					goto done;
 				}
 next_dying:
 				++num;
 			}
 		}
-		read_unlock_bh(&head->lock);
+		read_unlock_bh(lock);
 	}
 
 done:
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 16eecc7..67704da 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -204,12 +204,13 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 	const __portpair ports = INET_COMBINED_PORTS(inet->dport, lport);
 	unsigned int hash = inet_ehashfn(daddr, lport, saddr, inet->dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
+	rwlock_t *lock = inet_ehash_lockp(hinfo, hash);
 	struct sock *sk2;
 	const struct hlist_node *node;
 	struct inet_timewait_sock *tw;
 
 	prefetch(head->chain.first);
-	write_lock(&head->lock);
+	write_lock(lock);
 
 	/* Check TIME-WAIT sockets first. */
 	sk_for_each(sk2, node, &head->twchain) {
@@ -239,7 +240,7 @@ unique:
 	BUG_TRAP(sk_unhashed(sk));
 	__sk_add_node(sk, &head->chain);
 	sock_prot_inc_use(sk->sk_prot);
-	write_unlock(&head->lock);
+	write_unlock(lock);
 
 	if (twp) {
 		*twp = tw;
@@ -255,7 +256,7 @@ unique:
 	return 0;
 
 not_unique:
-	write_unlock(&head->lock);
+	write_unlock(lock);
 	return -EADDRNOTAVAIL;
 }
 
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 4e189e2..a60b99e 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -20,16 +20,16 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 	struct inet_bind_hashbucket *bhead;
 	struct inet_bind_bucket *tb;
 	/* Unlink from established hashes. */
-	struct inet_ehash_bucket *ehead = inet_ehash_bucket(hashinfo, tw->tw_hash);
+	rwlock_t *lock = inet_ehash_lockp(hashinfo, tw->tw_hash);
 
-	write_lock(&ehead->lock);
+	write_lock(lock);
 	if (hlist_unhashed(&tw->tw_node)) {
-		write_unlock(&ehead->lock);
+		write_unlock(lock);
 		return;
 	}
 	__hlist_del(&tw->tw_node);
 	sk_node_init(&tw->tw_node);
-	write_unlock(&ehead->lock);
+	write_unlock(lock);
 
 	/* Disassociate with bind bucket. */
 	bhead = &hashinfo->bhash[inet_bhashfn(tw->tw_num, hashinfo->bhash_size)];
@@ -59,6 +59,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 	const struct inet_sock *inet = inet_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct inet_ehash_bucket *ehead = inet_ehash_bucket(hashinfo, sk->sk_hash);
+	rwlock_t *lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 	struct inet_bind_hashbucket *bhead;
 	/* Step 1: Put TW into bind hash. Original socket stays there too.
 	   Note, that any socket with inet->num != 0 MUST be bound in
@@ -71,7 +72,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 	inet_twsk_add_bind_node(tw, &tw->tw_tb->owners);
 	spin_unlock(&bhead->lock);
 
-	write_lock(&ehead->lock);
+	write_lock(lock);
 
 	/* Step 2: Remove SK from established hash. */
 	if (__sk_del_node_init(sk))
@@ -81,7 +82,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 	inet_twsk_add_node(tw, &ehead->twchain);
 	atomic_inc(&tw->tw_refcnt);
 
-	write_unlock(&ehead->lock);
+	write_unlock(lock);
 }
 
 EXPORT_SYMBOL_GPL(__inet_twsk_hashdance);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c64072b..e7aca8e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2456,11 +2456,18 @@ void __init tcp_init(void)
 					thash_entries ? 0 : 512 * 1024);
 	tcp_hashinfo.ehash_size = 1 << tcp_hashinfo.ehash_size;
 	for (i = 0; i < tcp_hashinfo.ehash_size; i++) {
-		rwlock_init(&tcp_hashinfo.ehash[i].lock);
 		INIT_HLIST_HEAD(&tcp_hashinfo.ehash[i].chain);
 		INIT_HLIST_HEAD(&tcp_hashinfo.ehash[i].twchain);
 	}
-
+	if (EHASH_LOCK_SZ) {
+		tcp_hashinfo.ehash_locks =
+			kmalloc(EHASH_LOCK_SZ * sizeof(rwlock_t),
+				GFP_KERNEL);
+		if (!tcp_hashinfo.ehash_locks)
+			panic("TCP: failed to alloc ehash_locks");
+		for (i = 0; i < EHASH_LOCK_SZ; i++)
+			rwlock_init(&tcp_hashinfo.ehash_locks[i]);
+	}
 	tcp_hashinfo.bhash =
 		alloc_large_system_hash("TCP bind",
 					sizeof(struct inet_bind_hashbucket),
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index eec02b2..cd82c0e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2049,8 +2049,9 @@ static void *established_get_first(struct seq_file *seq)
 		struct sock *sk;
 		struct hlist_node *node;
 		struct inet_timewait_sock *tw;
+		rwlock_t *lock = inet_ehash_lockp(&tcp_hashinfo, st->bucket);
 
-		read_lock_bh(&tcp_hashinfo.ehash[st->bucket].lock);
+		read_lock_bh(lock);
 		sk_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
 			if (sk->sk_family != st->family) {
 				continue;
@@ -2067,7 +2068,7 @@ static void *established_get_first(struct seq_file *seq)
 			rc = tw;
 			goto out;
 		}
-		read_unlock_bh(&tcp_hashinfo.ehash[st->bucket].lock);
+		read_unlock_bh(lock);
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 	}
 out:
@@ -2094,11 +2095,11 @@ get_tw:
 			cur = tw;
 			goto out;
 		}
-		read_unlock_bh(&tcp_hashinfo.ehash[st->bucket].lock);
+		read_unlock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 
 		if (++st->bucket < tcp_hashinfo.ehash_size) {
-			read_lock_bh(&tcp_hashinfo.ehash[st->bucket].lock);
+			read_lock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
 			sk = sk_head(&tcp_hashinfo.ehash[st->bucket].chain);
 		} else {
 			cur = NULL;
@@ -2206,7 +2207,7 @@ static void tcp_seq_stop(struct seq_file *seq, void *v)
 	case TCP_SEQ_STATE_TIME_WAIT:
 	case TCP_SEQ_STATE_ESTABLISHED:
 		if (v)
-			read_unlock_bh(&tcp_hashinfo.ehash[st->bucket].lock);
+			read_unlock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
 		break;
 	}
 }
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index d6f1026..adc73ad 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -37,9 +37,8 @@ void __inet6_hash(struct inet_hashinfo *hashinfo,
 	} else {
 		unsigned int hash;
 		sk->sk_hash = hash = inet6_sk_ehashfn(sk);
-		hash &= (hashinfo->ehash_size - 1);
-		list = &hashinfo->ehash[hash].chain;
-		lock = &hashinfo->ehash[hash].lock;
+		list = &inet_ehash_bucket(hashinfo, hash)->chain;
+		lock = inet_ehash_lockp(hashinfo, hash);
 		write_lock(lock);
 	}
 
@@ -70,9 +69,10 @@ struct sock *__inet6_lookup_established(struct inet_hashinfo *hashinfo,
 	 */
 	unsigned int hash = inet6_ehashfn(daddr, hnum, saddr, sport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hashinfo, hash);
+	rwlock_t *lock = inet_ehash_lockp(hashinfo, hash);
 
 	prefetch(head->chain.first);
-	read_lock(&head->lock);
+	read_lock(lock);
 	sk_for_each(sk, node, &head->chain) {
 		/* For IPV6 do the cheaper port and family tests first. */
 		if (INET6_MATCH(sk, hash, saddr, daddr, ports, dif))
@@ -92,12 +92,12 @@ struct sock *__inet6_lookup_established(struct inet_hashinfo *hashinfo,
 				goto hit;
 		}
 	}
-	read_unlock(&head->lock);
+	read_unlock(lock);
 	return NULL;
 
 hit:
 	sock_hold(sk);
-	read_unlock(&head->lock);
+	read_unlock(lock);
 	return sk;
 }
 EXPORT_SYMBOL(__inet6_lookup_established);
@@ -175,12 +175,13 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 	const unsigned int hash = inet6_ehashfn(daddr, lport, saddr,
 						inet->dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
+	rwlock_t *lock = inet_ehash_lockp(hinfo, hash);
 	struct sock *sk2;
 	const struct hlist_node *node;
 	struct inet_timewait_sock *tw;
 
 	prefetch(head->chain.first);
-	write_lock(&head->lock);
+	write_lock(lock);
 
 	/* Check TIME-WAIT sockets first. */
 	sk_for_each(sk2, node, &head->twchain) {
@@ -216,7 +217,7 @@ unique:
 	__sk_add_node(sk, &head->chain);
 	sk->sk_hash = hash;
 	sock_prot_inc_use(sk->sk_prot);
-	write_unlock(&head->lock);
+	write_unlock(lock);
 
 	if (twp != NULL) {
 		*twp = tw;
@@ -231,7 +232,7 @@ unique:
 	return 0;
 
 not_unique:
-	write_unlock(&head->lock);
+	write_unlock(lock);
 	return -EADDRNOTAVAIL;
 }
 

--------------010409010109060108030002--
