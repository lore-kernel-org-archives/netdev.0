From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 3/3] net: Convert TCP & DCCP hash tables to use RCU / hlist_nulls
Date: Thu, 13 Nov 2008 14:15:31 +0100
Message-ID: <491C2873.60004@cosmosbay.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070602050206080507020108"
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Corey Minyard <minyard@acm.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44953 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286AbYKMNQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 08:16:19 -0500
In-Reply-To: <4909D551.9080309@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070602050206080507020108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

RCU was added to UDP lookups, using a fast infrastructure :
- sockets kmem_cache use SLAB_DESTROY_BY_RCU and dont pay the
  price of call_rcu() at freeing time.
- hlist_nulls permits to use few memory barriers.

This patch uses same infrastructure for TCP/DCCP established
and timewait sockets.

Thanks to SLAB_DESTROY_BY_RCU, no slowdown for applications
using short lived TCP connections. A followup patch, converting
rwlocks to spinlocks will even speedup this case.

__inet_lookup_established() is pretty fast now we dont have to
dirty a contended cache line (read_lock/read_unlock)

Only established and timewait hashtable are converted to RCU
(bind table and listen table are still using traditional locking)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/inet_hashtables.h    |    4 -
 include/net/inet_timewait_sock.h |   10 +--
 net/core/sock.c                  |    4 +
 net/dccp/ipv4.c                  |    1
 net/dccp/ipv6.c                  |    1
 net/dccp/proto.c                 |    4 -
 net/ipv4/inet_diag.c             |    6 +-
 net/ipv4/inet_hashtables.c       |   78 ++++++++++++++++++++---------
 net/ipv4/inet_timewait_sock.c    |   26 +++++----
 net/ipv4/tcp.c                   |    4 -
 net/ipv4/tcp_ipv4.c              |   25 ++++-----
 net/ipv6/inet6_hashtables.c      |   70 +++++++++++++++++---------
 net/ipv6/tcp_ipv6.c              |    1
 13 files changed, 150 insertions(+), 84 deletions(-)

--------------070602050206080507020108
Content-Type: text/plain;
 name="TCP_RCU.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCP_RCU.patch"

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index cb31fbf..4818960 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -41,8 +41,8 @@
  * I'll experiment with dynamic table growth later.
  */
 struct inet_ehash_bucket {
-	struct hlist_head chain;
-	struct hlist_head twchain;
+	struct hlist_nulls_head chain;
+	struct hlist_nulls_head twchain;
 };
 
 /* There are a few simple rules, which allow for local port reuse by
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 80e4977..4b8ece2 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -110,7 +110,7 @@ struct inet_timewait_sock {
 #define tw_state		__tw_common.skc_state
 #define tw_reuse		__tw_common.skc_reuse
 #define tw_bound_dev_if		__tw_common.skc_bound_dev_if
-#define tw_node			__tw_common.skc_node
+#define tw_node			__tw_common.skc_nulls_node
 #define tw_bind_node		__tw_common.skc_bind_node
 #define tw_refcnt		__tw_common.skc_refcnt
 #define tw_hash			__tw_common.skc_hash
@@ -137,10 +137,10 @@ struct inet_timewait_sock {
 	struct hlist_node	tw_death_node;
 };
 
-static inline void inet_twsk_add_node(struct inet_timewait_sock *tw,
-				      struct hlist_head *list)
+static inline void inet_twsk_add_node_rcu(struct inet_timewait_sock *tw,
+				      struct hlist_nulls_head *list)
 {
-	hlist_add_head(&tw->tw_node, list);
+	hlist_nulls_add_head_rcu(&tw->tw_node, list);
 }
 
 static inline void inet_twsk_add_bind_node(struct inet_timewait_sock *tw,
@@ -175,7 +175,7 @@ static inline int inet_twsk_del_dead_node(struct inet_timewait_sock *tw)
 }
 
 #define inet_twsk_for_each(tw, node, head) \
-	hlist_for_each_entry(tw, node, head, tw_node)
+	hlist_nulls_for_each_entry(tw, node, head, tw_node)
 
 #define inet_twsk_for_each_inmate(tw, node, jail) \
 	hlist_for_each_entry(tw, node, jail, tw_death_node)
diff --git a/net/core/sock.c b/net/core/sock.c
index ded1eb5..38de9c3 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2082,7 +2082,9 @@ int proto_register(struct proto *prot, int alloc_slab)
 			prot->twsk_prot->twsk_slab =
 				kmem_cache_create(timewait_sock_slab_name,
 						  prot->twsk_prot->twsk_obj_size,
-						  0, SLAB_HWCACHE_ALIGN,
+						  0,
+						  SLAB_HWCACHE_ALIGN |
+							prot->slab_flags,
 						  NULL);
 			if (prot->twsk_prot->twsk_slab == NULL)
 				goto out_free_timewait_sock_slab_name;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 528baa2..d1dd952 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -938,6 +938,7 @@ static struct proto dccp_v4_prot = {
 	.orphan_count		= &dccp_orphan_count,
 	.max_header		= MAX_DCCP_HEADER,
 	.obj_size		= sizeof(struct dccp_sock),
+	.slab_flags		= SLAB_DESTROY_BY_RCU,
 	.rsk_prot		= &dccp_request_sock_ops,
 	.twsk_prot		= &dccp_timewait_sock_ops,
 	.h.hashinfo		= &dccp_hashinfo,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4aa1148..f033e84 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1140,6 +1140,7 @@ static struct proto dccp_v6_prot = {
 	.orphan_count	   = &dccp_orphan_count,
 	.max_header	   = MAX_DCCP_HEADER,
 	.obj_size	   = sizeof(struct dccp6_sock),
+	.slab_flags	   = SLAB_DESTROY_BY_RCU,
 	.rsk_prot	   = &dccp6_request_sock_ops,
 	.twsk_prot	   = &dccp6_timewait_sock_ops,
 	.h.hashinfo	   = &dccp_hashinfo,
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 46cb349..1117d4d 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1090,8 +1090,8 @@ static int __init dccp_init(void)
 	}
 
 	for (i = 0; i < dccp_hashinfo.ehash_size; i++) {
-		INIT_HLIST_HEAD(&dccp_hashinfo.ehash[i].chain);
-		INIT_HLIST_HEAD(&dccp_hashinfo.ehash[i].twchain);
+		INIT_HLIST_NULLS_HEAD(&dccp_hashinfo.ehash[i].chain, i);
+		INIT_HLIST_NULLS_HEAD(&dccp_hashinfo.ehash[i].twchain, i);
 	}
 
 	if (inet_ehash_locks_alloc(&dccp_hashinfo))
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 564230d..41b3672 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -778,18 +778,19 @@ skip_listen_ht:
 		struct inet_ehash_bucket *head = &hashinfo->ehash[i];
 		rwlock_t *lock = inet_ehash_lockp(hashinfo, i);
 		struct sock *sk;
-		struct hlist_node *node;
+		struct hlist_nulls_node *node;
 
 		num = 0;
 
-		if (hlist_empty(&head->chain) && hlist_empty(&head->twchain))
+		if (hlist_nulls_empty(&head->chain) &&
+			hlist_nulls_empty(&head->twchain))
 			continue;
 
 		if (i > s_i)
 			s_num = 0;
 
 		read_lock_bh(lock);
-		sk_for_each(sk, node, &head->chain) {
+		sk_nulls_for_each(sk, node, &head->chain) {
 			struct inet_sock *inet = inet_sk(sk);
 
 			if (num < s_num)
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index be41ebb..fd269cf 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -223,35 +223,65 @@ struct sock * __inet_lookup_established(struct net *net,
 	INET_ADDR_COOKIE(acookie, saddr, daddr)
 	const __portpair ports = INET_COMBINED_PORTS(sport, hnum);
 	struct sock *sk;
-	const struct hlist_node *node;
+	const struct hlist_nulls_node *node;
 	/* Optimize here for direct hit, only listening connections can
 	 * have wildcards anyways.
 	 */
 	unsigned int hash = inet_ehashfn(net, daddr, hnum, saddr, sport);
-	struct inet_ehash_bucket *head = inet_ehash_bucket(hashinfo, hash);
-	rwlock_t *lock = inet_ehash_lockp(hashinfo, hash);
+	unsigned int slot = hash & (hashinfo->ehash_size - 1);
+	struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
 
-	prefetch(head->chain.first);
-	read_lock(lock);
-	sk_for_each(sk, node, &head->chain) {
+	rcu_read_lock();
+begin:
+	sk_nulls_for_each_rcu(sk, node, &head->chain) {
 		if (INET_MATCH(sk, net, hash, acookie,
-					saddr, daddr, ports, dif))
-			goto hit; /* You sunk my battleship! */
+					saddr, daddr, ports, dif)) {
+			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
+				goto begintw;
+			if (unlikely(!INET_MATCH(sk, net, hash, acookie,
+				saddr, daddr, ports, dif))) {
+				sock_put(sk);
+				goto begin;
+			}
+			goto out;
+		}
 	}
+	/*
+	 * if the nulls value we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 * We probably met an item that was moved to another chain.
+	 */
+	if (get_nulls_value(node) != slot)
+		goto begin;
 
+begintw:
 	/* Must check for a TIME_WAIT'er before going to listener hash. */
-	sk_for_each(sk, node, &head->twchain) {
+	sk_nulls_for_each_rcu(sk, node, &head->twchain) {
 		if (INET_TW_MATCH(sk, net, hash, acookie,
-					saddr, daddr, ports, dif))
-			goto hit;
+					saddr, daddr, ports, dif)) {
+			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt))) {
+				sk = NULL;
+				goto out;
+			}
+			if (unlikely(!INET_TW_MATCH(sk, net, hash, acookie,
+				 saddr, daddr, ports, dif))) {
+				sock_put(sk);
+				goto begintw;
+			}
+			goto out;
+		}
 	}
+	/*
+	 * if the nulls value we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 * We probably met an item that was moved to another chain.
+	 */
+	if (get_nulls_value(node) != slot)
+		goto begintw;
 	sk = NULL;
 out:
-	read_unlock(lock);
+	rcu_read_unlock();
 	return sk;
-hit:
-	sock_hold(sk);
-	goto out;
 }
 EXPORT_SYMBOL_GPL(__inet_lookup_established);
 
@@ -272,14 +302,14 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
 	rwlock_t *lock = inet_ehash_lockp(hinfo, hash);
 	struct sock *sk2;
-	const struct hlist_node *node;
+	const struct hlist_nulls_node *node;
 	struct inet_timewait_sock *tw;
 
 	prefetch(head->chain.first);
 	write_lock(lock);
 
 	/* Check TIME-WAIT sockets first. */
-	sk_for_each(sk2, node, &head->twchain) {
+	sk_nulls_for_each(sk2, node, &head->twchain) {
 		tw = inet_twsk(sk2);
 
 		if (INET_TW_MATCH(sk2, net, hash, acookie,
@@ -293,7 +323,7 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 	tw = NULL;
 
 	/* And established part... */
-	sk_for_each(sk2, node, &head->chain) {
+	sk_nulls_for_each(sk2, node, &head->chain) {
 		if (INET_MATCH(sk2, net, hash, acookie,
 					saddr, daddr, ports, dif))
 			goto not_unique;
@@ -306,7 +336,7 @@ unique:
 	inet->sport = htons(lport);
 	sk->sk_hash = hash;
 	WARN_ON(!sk_unhashed(sk));
-	__sk_add_node(sk, &head->chain);
+	__sk_nulls_add_node_rcu(sk, &head->chain);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	write_unlock(lock);
 
@@ -338,7 +368,7 @@ static inline u32 inet_sk_port_offset(const struct sock *sk)
 void __inet_hash_nolisten(struct sock *sk)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
-	struct hlist_head *list;
+	struct hlist_nulls_head *list;
 	rwlock_t *lock;
 	struct inet_ehash_bucket *head;
 
@@ -350,7 +380,7 @@ void __inet_hash_nolisten(struct sock *sk)
 	lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 
 	write_lock(lock);
-	__sk_add_node(sk, list);
+	__sk_nulls_add_node_rcu(sk, list);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	write_unlock(lock);
 }
@@ -400,13 +430,15 @@ void inet_unhash(struct sock *sk)
 		local_bh_disable();
 		inet_listen_wlock(hashinfo);
 		lock = &hashinfo->lhash_lock;
+		if (__sk_del_node_init(sk))
+			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 	} else {
 		lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 		write_lock_bh(lock);
+		if (__sk_nulls_del_node_init_rcu(sk))
+			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 	}
 
-	if (__sk_del_node_init(sk))
-		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 	write_unlock_bh(lock);
 out:
 	if (sk->sk_state == TCP_LISTEN)
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 1c5fd38..6068995 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -23,12 +23,12 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 	rwlock_t *lock = inet_ehash_lockp(hashinfo, tw->tw_hash);
 
 	write_lock(lock);
-	if (hlist_unhashed(&tw->tw_node)) {
+	if (hlist_nulls_unhashed(&tw->tw_node)) {
 		write_unlock(lock);
 		return;
 	}
-	__hlist_del(&tw->tw_node);
-	sk_node_init(&tw->tw_node);
+	hlist_nulls_del_rcu(&tw->tw_node);
+	sk_nulls_node_init(&tw->tw_node);
 	write_unlock(lock);
 
 	/* Disassociate with bind bucket. */
@@ -92,13 +92,17 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 
 	write_lock(lock);
 
-	/* Step 2: Remove SK from established hash. */
-	if (__sk_del_node_init(sk))
-		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
-
-	/* Step 3: Hash TW into TIMEWAIT chain. */
-	inet_twsk_add_node(tw, &ehead->twchain);
+	/*
+	 * Step 2: Hash TW into TIMEWAIT chain.
+	 * Should be done before removing sk from established chain
+	 * because readers are lockless and search established first.
+	 */
 	atomic_inc(&tw->tw_refcnt);
+	inet_twsk_add_node_rcu(tw, &ehead->twchain);
+
+	/* Step 3: Remove SK from established hash. */
+	if (__sk_nulls_del_node_init_rcu(sk))
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 
 	write_unlock(lock);
 }
@@ -416,7 +420,7 @@ void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinfo,
 {
 	struct inet_timewait_sock *tw;
 	struct sock *sk;
-	struct hlist_node *node;
+	struct hlist_nulls_node *node;
 	int h;
 
 	local_bh_disable();
@@ -426,7 +430,7 @@ void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinfo,
 		rwlock_t *lock = inet_ehash_lockp(hashinfo, h);
 restart:
 		write_lock(lock);
-		sk_for_each(sk, node, &head->twchain) {
+		sk_nulls_for_each(sk, node, &head->twchain) {
 
 			tw = inet_twsk(sk);
 			if (!net_eq(twsk_net(tw), net) ||
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f60a591..044224a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2707,8 +2707,8 @@ void __init tcp_init(void)
 					thash_entries ? 0 : 512 * 1024);
 	tcp_hashinfo.ehash_size = 1 << tcp_hashinfo.ehash_size;
 	for (i = 0; i < tcp_hashinfo.ehash_size; i++) {
-		INIT_HLIST_HEAD(&tcp_hashinfo.ehash[i].chain);
-		INIT_HLIST_HEAD(&tcp_hashinfo.ehash[i].twchain);
+		INIT_HLIST_NULLS_HEAD(&tcp_hashinfo.ehash[i].chain, i);
+		INIT_HLIST_NULLS_HEAD(&tcp_hashinfo.ehash[i].twchain, i);
 	}
 	if (inet_ehash_locks_alloc(&tcp_hashinfo))
 		panic("TCP: failed to alloc ehash_locks");
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d49233f..b2e3ab2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1857,16 +1857,16 @@ EXPORT_SYMBOL(tcp_v4_destroy_sock);
 #ifdef CONFIG_PROC_FS
 /* Proc filesystem TCP sock list dumping. */
 
-static inline struct inet_timewait_sock *tw_head(struct hlist_head *head)
+static inline struct inet_timewait_sock *tw_head(struct hlist_nulls_head *head)
 {
-	return hlist_empty(head) ? NULL :
+	return hlist_nulls_empty(head) ? NULL :
 		list_entry(head->first, struct inet_timewait_sock, tw_node);
 }
 
 static inline struct inet_timewait_sock *tw_next(struct inet_timewait_sock *tw)
 {
-	return tw->tw_node.next ?
-		hlist_entry(tw->tw_node.next, typeof(*tw), tw_node) : NULL;
+	return !is_a_nulls(tw->tw_node.next) ?
+		hlist_nulls_entry(tw->tw_node.next, typeof(*tw), tw_node) : NULL;
 }
 
 static void *listening_get_next(struct seq_file *seq, void *cur)
@@ -1954,8 +1954,8 @@ static void *listening_get_idx(struct seq_file *seq, loff_t *pos)
 
 static inline int empty_bucket(struct tcp_iter_state *st)
 {
-	return hlist_empty(&tcp_hashinfo.ehash[st->bucket].chain) &&
-		hlist_empty(&tcp_hashinfo.ehash[st->bucket].twchain);
+	return hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].chain) &&
+		hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].twchain);
 }
 
 static void *established_get_first(struct seq_file *seq)
@@ -1966,7 +1966,7 @@ static void *established_get_first(struct seq_file *seq)
 
 	for (st->bucket = 0; st->bucket < tcp_hashinfo.ehash_size; ++st->bucket) {
 		struct sock *sk;
-		struct hlist_node *node;
+		struct hlist_nulls_node *node;
 		struct inet_timewait_sock *tw;
 		rwlock_t *lock = inet_ehash_lockp(&tcp_hashinfo, st->bucket);
 
@@ -1975,7 +1975,7 @@ static void *established_get_first(struct seq_file *seq)
 			continue;
 
 		read_lock_bh(lock);
-		sk_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
+		sk_nulls_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
 			if (sk->sk_family != st->family ||
 			    !net_eq(sock_net(sk), net)) {
 				continue;
@@ -2004,7 +2004,7 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 {
 	struct sock *sk = cur;
 	struct inet_timewait_sock *tw;
-	struct hlist_node *node;
+	struct hlist_nulls_node *node;
 	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 
@@ -2032,11 +2032,11 @@ get_tw:
 			return NULL;
 
 		read_lock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
-		sk = sk_head(&tcp_hashinfo.ehash[st->bucket].chain);
+		sk = sk_nulls_head(&tcp_hashinfo.ehash[st->bucket].chain);
 	} else
-		sk = sk_next(sk);
+		sk = sk_nulls_next(sk);
 
-	sk_for_each_from(sk, node) {
+	sk_nulls_for_each_from(sk, node) {
 		if (sk->sk_family == st->family && net_eq(sock_net(sk), net))
 			goto found;
 	}
@@ -2375,6 +2375,7 @@ struct proto tcp_prot = {
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp_sock),
+	.slab_flags		= SLAB_DESTROY_BY_RCU,
 	.twsk_prot		= &tcp_timewait_sock_ops,
 	.rsk_prot		= &tcp_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 1646a56..c1b4d40 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -25,24 +25,28 @@
 void __inet6_hash(struct sock *sk)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
-	struct hlist_head *list;
 	rwlock_t *lock;
 
 	WARN_ON(!sk_unhashed(sk));
 
 	if (sk->sk_state == TCP_LISTEN) {
+		struct hlist_head *list;
+
 		list = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
 		lock = &hashinfo->lhash_lock;
 		inet_listen_wlock(hashinfo);
+		__sk_add_node(sk, list);
 	} else {
 		unsigned int hash;
+		struct hlist_nulls_head *list;
+
 		sk->sk_hash = hash = inet6_sk_ehashfn(sk);
 		list = &inet_ehash_bucket(hashinfo, hash)->chain;
 		lock = inet_ehash_lockp(hashinfo, hash);
 		write_lock(lock);
+		__sk_nulls_add_node_rcu(sk, list);
 	}
 
-	__sk_add_node(sk, list);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	write_unlock(lock);
 }
@@ -63,33 +67,53 @@ struct sock *__inet6_lookup_established(struct net *net,
 					   const int dif)
 {
 	struct sock *sk;
-	const struct hlist_node *node;
+	const struct hlist_nulls_node *node;
 	const __portpair ports = INET_COMBINED_PORTS(sport, hnum);
 	/* Optimize here for direct hit, only listening connections can
 	 * have wildcards anyways.
 	 */
 	unsigned int hash = inet6_ehashfn(net, daddr, hnum, saddr, sport);
-	struct inet_ehash_bucket *head = inet_ehash_bucket(hashinfo, hash);
-	rwlock_t *lock = inet_ehash_lockp(hashinfo, hash);
+	unsigned int slot = hash & (hashinfo->ehash_size - 1);
+	struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
 
-	prefetch(head->chain.first);
-	read_lock(lock);
-	sk_for_each(sk, node, &head->chain) {
+
+	rcu_read_lock();
+begin:
+	sk_nulls_for_each_rcu(sk, node, &head->chain) {
 		/* For IPV6 do the cheaper port and family tests first. */
-		if (INET6_MATCH(sk, net, hash, saddr, daddr, ports, dif))
-			goto hit; /* You sunk my battleship! */
+		if (INET6_MATCH(sk, net, hash, saddr, daddr, ports, dif)) {
+			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
+				goto begintw;
+			if (!INET6_MATCH(sk, net, hash, saddr, daddr, ports, dif)) {
+				sock_put(sk);
+				goto begin;
+			}
+		goto out;
+		}
 	}
+	if (get_nulls_value(node) != slot)
+		goto begin;
+
+begintw:
 	/* Must check for a TIME_WAIT'er before going to listener hash. */
-	sk_for_each(sk, node, &head->twchain) {
-		if (INET6_TW_MATCH(sk, net, hash, saddr, daddr, ports, dif))
-			goto hit;
+	sk_nulls_for_each_rcu(sk, node, &head->twchain) {
+		if (INET6_TW_MATCH(sk, net, hash, saddr, daddr, ports, dif)) {
+			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt))) {
+				sk = NULL;
+				goto out;
+			}
+			if (!INET6_TW_MATCH(sk, net, hash, saddr, daddr, ports, dif)) {
+				sock_put(sk);
+				goto begintw;
+			}
+			goto out;
+		}
 	}
-	read_unlock(lock);
-	return NULL;
-
-hit:
-	sock_hold(sk);
-	read_unlock(lock);
+	if (get_nulls_value(node) != slot)
+		goto begintw;
+	sk = NULL;
+out:
+	rcu_read_unlock();
 	return sk;
 }
 EXPORT_SYMBOL(__inet6_lookup_established);
@@ -172,14 +196,14 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
 	rwlock_t *lock = inet_ehash_lockp(hinfo, hash);
 	struct sock *sk2;
-	const struct hlist_node *node;
+	const struct hlist_nulls_node *node;
 	struct inet_timewait_sock *tw;
 
 	prefetch(head->chain.first);
 	write_lock(lock);
 
 	/* Check TIME-WAIT sockets first. */
-	sk_for_each(sk2, node, &head->twchain) {
+	sk_nulls_for_each(sk2, node, &head->twchain) {
 		tw = inet_twsk(sk2);
 
 		if (INET6_TW_MATCH(sk2, net, hash, saddr, daddr, ports, dif)) {
@@ -192,7 +216,7 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 	tw = NULL;
 
 	/* And established part... */
-	sk_for_each(sk2, node, &head->chain) {
+	sk_nulls_for_each(sk2, node, &head->chain) {
 		if (INET6_MATCH(sk2, net, hash, saddr, daddr, ports, dif))
 			goto not_unique;
 	}
@@ -203,7 +227,7 @@ unique:
 	inet->num = lport;
 	inet->sport = htons(lport);
 	WARN_ON(!sk_unhashed(sk));
-	__sk_add_node(sk, &head->chain);
+	__sk_nulls_add_node_rcu(sk, &head->chain);
 	sk->sk_hash = hash;
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	write_unlock(lock);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9842764..b357870 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2043,6 +2043,7 @@ struct proto tcpv6_prot = {
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp6_sock),
+	.slab_flags		= SLAB_DESTROY_BY_RCU,
 	.twsk_prot		= &tcp6_timewait_sock_ops,
 	.rsk_prot		= &tcp6_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,

--------------070602050206080507020108--
