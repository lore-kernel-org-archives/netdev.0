From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next v2 1/2] tcp/dccp: remove twchain
Date: Thu, 03 Oct 2013 15:41:07 -0700
Message-ID: <1380840067.19002.255.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:41777 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113Ab3JCWlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 18:41:09 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so3098073pbb.24
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 15:41:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP listener refactoring, part 3 :

Our goal is to hash SYN_RECV sockets into main ehash for fast lookup,
and parallel SYN processing.

Current inet_ehash_bucket contains two chains, one for ESTABLISH (and
friend states) sockets, another for TIME_WAIT sockets only.

As the hash table is sized to get at most one socket per bucket, it
makes little sense to have separate twchain, as it makes the lookup
slightly more complicated, and doubles hash table memory usage.

If we make sure all socket types have the lookup keys at the same
offsets, we can use a generic and faster lookup. It turns out TIME_WAIT
and ESTABLISHED sockets already have common lookup fields for IPv4.

[ INET_TW_MATCH() is no longer needed ]

I'll provide a follow-up to factorize IPv6 lookup as well, to remove
INET6_TW_MATCH()

This way, SYN_RECV pseudo sockets will be supported the same.

A new sock_gen_put() helper is added, doing either a sock_put() or
inet_twsk_put() [ and will support SYN_RECV later ].

Note this helper should only be called in real slow path, when rcu
lookup found a socket that was moved to another identity (freed/reused
immediately), but could eventually be used in other contexts, like
sock_edemux()

Before patch :

dmesg | grep "TCP established"

TCP established hash table entries: 524288 (order: 11, 8388608 bytes)

After patch :

TCP established hash table entries: 524288 (order: 10, 4194304 bytes)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Note: This depends on this commit in net tree :

"net: do not call sock_put() on TIMEWAIT sockets"

v2: respin on latest net-next

 include/net/inet_hashtables.h    |    9 ---
 include/net/inet_timewait_sock.h |   13 ----
 include/net/sock.h               |    8 ++
 include/net/tcp.h                |    1 
 net/dccp/proto.c                 |    4 -
 net/ipv4/inet_diag.c             |   48 ++++------------
 net/ipv4/inet_hashtables.c       |   83 ++++++++++-------------------
 net/ipv4/inet_timewait_sock.c    |   55 +++++++++----------
 net/ipv4/tcp.c                   |    5 -
 net/ipv4/tcp_ipv4.c              |   83 ++++-------------------------
 net/ipv6/inet6_hashtables.c      |   75 ++++++++++----------------
 net/ipv6/tcp_ipv6.c              |    9 +--
 12 files changed, 132 insertions(+), 261 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 10d6838..1bdb477 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -37,12 +37,11 @@
 #include <asm/byteorder.h>
 
 /* This is for all connections with a full identity, no wildcards.
- * One chain is dedicated to TIME_WAIT sockets.
- * I'll experiment with dynamic table growth later.
+ * The 'e' prefix stands for Establish, but we really put all sockets
+ * but LISTEN ones.
  */
 struct inet_ehash_bucket {
 	struct hlist_nulls_head chain;
-	struct hlist_nulls_head twchain;
 };
 
 /* There are a few simple rules, which allow for local port reuse by
@@ -123,7 +122,6 @@ struct inet_hashinfo {
 	 *
 	 *          TCP_ESTABLISHED <= sk->sk_state < TCP_CLOSE
 	 *
-	 * TIME_WAIT sockets use a separate chain (twchain).
 	 */
 	struct inet_ehash_bucket	*ehash;
 	spinlock_t			*ehash_locks;
@@ -318,9 +316,6 @@ static inline struct sock *inet_lookup_listener(struct net *net,
 	 net_eq(sock_net(__sk), (__net)))
 #endif /* 64-bit arch */
 
-#define INET_TW_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)\
-	INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)
-
 /*
  * Sockets in TCP_CLOSE state are _always_ taken out of the hash, so we need
  * not check it for lookups anymore, thanks Alexey. -DaveM
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index f528d1b..de9e3ab 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -141,18 +141,6 @@ struct inet_timewait_sock {
 };
 #define tw_tclass tw_tos
 
-static inline void inet_twsk_add_node_rcu(struct inet_timewait_sock *tw,
-				      struct hlist_nulls_head *list)
-{
-	hlist_nulls_add_head_rcu(&tw->tw_node, list);
-}
-
-static inline void inet_twsk_add_bind_node(struct inet_timewait_sock *tw,
-					   struct hlist_head *list)
-{
-	hlist_add_head(&tw->tw_bind_node, list);
-}
-
 static inline int inet_twsk_dead_hashed(const struct inet_timewait_sock *tw)
 {
 	return !hlist_unhashed(&tw->tw_death_node);
@@ -192,6 +180,7 @@ static inline struct inet_timewait_sock *inet_twsk(const struct sock *sk)
 	return (struct inet_timewait_sock *)sk;
 }
 
+void inet_twsk_free(struct inet_timewait_sock *tw);
 void inet_twsk_put(struct inet_timewait_sock *tw);
 
 int inet_twsk_unhash(struct inet_timewait_sock *tw);
diff --git a/include/net/sock.h b/include/net/sock.h
index e3bf213..ef80ea5 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -156,7 +156,7 @@ typedef __u64 __bitwise __addrpair;
  */
 struct sock_common {
 	/* skc_daddr and skc_rcv_saddr must be grouped on a 8 bytes aligned
-	 * address on 64bit arches : cf INET_MATCH() and INET_TW_MATCH()
+	 * address on 64bit arches : cf INET_MATCH()
 	 */
 	union {
 		__addrpair	skc_addrpair;
@@ -301,6 +301,8 @@ struct sock {
 #define sk_dontcopy_end		__sk_common.skc_dontcopy_end
 #define sk_hash			__sk_common.skc_hash
 #define sk_portpair		__sk_common.skc_portpair
+#define sk_num			__sk_common.skc_num
+#define sk_dport		__sk_common.skc_dport
 #define sk_addrpair		__sk_common.skc_addrpair
 #define sk_daddr		__sk_common.skc_daddr
 #define sk_rcv_saddr		__sk_common.skc_rcv_saddr
@@ -1655,6 +1657,10 @@ static inline void sock_put(struct sock *sk)
 	if (atomic_dec_and_test(&sk->sk_refcnt))
 		sk_free(sk);
 }
+/* Generic version of sock_put(), dealing with all sockets
+ * (TCP_TIMEWAIT, ESTABLISHED...)
+ */
+void sock_gen_put(struct sock *sk);
 
 int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested);
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index de870ee..39bbfa1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1519,7 +1519,6 @@ enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
 	TCP_SEQ_STATE_OPENREQ,
 	TCP_SEQ_STATE_ESTABLISHED,
-	TCP_SEQ_STATE_TIME_WAIT,
 };
 
 int tcp_seq_open(struct inode *inode, struct file *file);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index ba64750..eb892b4 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1158,10 +1158,8 @@ static int __init dccp_init(void)
 		goto out_free_bind_bucket_cachep;
 	}
 
-	for (i = 0; i <= dccp_hashinfo.ehash_mask; i++) {
+	for (i = 0; i <= dccp_hashinfo.ehash_mask; i++)
 		INIT_HLIST_NULLS_HEAD(&dccp_hashinfo.ehash[i].chain, i);
-		INIT_HLIST_NULLS_HEAD(&dccp_hashinfo.ehash[i].twchain, i);
-	}
 
 	if (inet_ehash_locks_alloc(&dccp_hashinfo))
 			goto out_free_dccp_ehash;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 2200027..8e1e406 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -635,12 +635,14 @@ static int inet_csk_diag_dump(struct sock *sk,
 				  cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
 
-static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
+static int inet_twsk_diag_dump(struct sock *sk,
 			       struct sk_buff *skb,
 			       struct netlink_callback *cb,
 			       struct inet_diag_req_v2 *r,
 			       const struct nlattr *bc)
 {
+	struct inet_timewait_sock *tw = inet_twsk(sk);
+
 	if (bc != NULL) {
 		struct inet_diag_entry entry;
 
@@ -911,8 +913,7 @@ skip_listen_ht:
 
 		num = 0;
 
-		if (hlist_nulls_empty(&head->chain) &&
-			hlist_nulls_empty(&head->twchain))
+		if (hlist_nulls_empty(&head->chain))
 			continue;
 
 		if (i > s_i)
@@ -920,7 +921,7 @@ skip_listen_ht:
 
 		spin_lock_bh(lock);
 		sk_nulls_for_each(sk, node, &head->chain) {
-			struct inet_sock *inet = inet_sk(sk);
+			int res;
 
 			if (!net_eq(sock_net(sk), net))
 				continue;
@@ -929,15 +930,19 @@ skip_listen_ht:
 			if (!(r->idiag_states & (1 << sk->sk_state)))
 				goto next_normal;
 			if (r->sdiag_family != AF_UNSPEC &&
-					sk->sk_family != r->sdiag_family)
+			    sk->sk_family != r->sdiag_family)
 				goto next_normal;
-			if (r->id.idiag_sport != inet->inet_sport &&
+			if (r->id.idiag_sport != htons(sk->sk_num) &&
 			    r->id.idiag_sport)
 				goto next_normal;
-			if (r->id.idiag_dport != inet->inet_dport &&
+			if (r->id.idiag_dport != sk->sk_dport &&
 			    r->id.idiag_dport)
 				goto next_normal;
-			if (inet_csk_diag_dump(sk, skb, cb, r, bc) < 0) {
+			if (sk->sk_state == TCP_TIME_WAIT)
+				res = inet_twsk_diag_dump(sk, skb, cb, r, bc);
+			else
+				res = inet_csk_diag_dump(sk, skb, cb, r, bc);
+			if (res < 0) {
 				spin_unlock_bh(lock);
 				goto done;
 			}
@@ -945,33 +950,6 @@ next_normal:
 			++num;
 		}
 
-		if (r->idiag_states & TCPF_TIME_WAIT) {
-			struct inet_timewait_sock *tw;
-
-			inet_twsk_for_each(tw, node,
-				    &head->twchain) {
-				if (!net_eq(twsk_net(tw), net))
-					continue;
-
-				if (num < s_num)
-					goto next_dying;
-				if (r->sdiag_family != AF_UNSPEC &&
-						tw->tw_family != r->sdiag_family)
-					goto next_dying;
-				if (r->id.idiag_sport != tw->tw_sport &&
-				    r->id.idiag_sport)
-					goto next_dying;
-				if (r->id.idiag_dport != tw->tw_dport &&
-				    r->id.idiag_dport)
-					goto next_dying;
-				if (inet_twsk_diag_dump(tw, skb, cb, r, bc) < 0) {
-					spin_unlock_bh(lock);
-					goto done;
-				}
-next_dying:
-				++num;
-			}
-		}
 		spin_unlock_bh(lock);
 	}
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index ae19959..a4b66bb 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -230,6 +230,19 @@ begin:
 }
 EXPORT_SYMBOL_GPL(__inet_lookup_listener);
 
+/* All sockets share common refcount, but have different destructors */
+void sock_gen_put(struct sock *sk)
+{
+	if (!atomic_dec_and_test(&sk->sk_refcnt))
+		return;
+
+	if (sk->sk_state == TCP_TIME_WAIT)
+		inet_twsk_free(inet_twsk(sk));
+	else
+		sk_free(sk);
+}
+EXPORT_SYMBOL_GPL(sock_gen_put);
+
 struct sock *__inet_lookup_established(struct net *net,
 				  struct inet_hashinfo *hashinfo,
 				  const __be32 saddr, const __be16 sport,
@@ -255,13 +268,13 @@ begin:
 		if (likely(INET_MATCH(sk, net, acookie,
 				      saddr, daddr, ports, dif))) {
 			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
-				goto begintw;
+				goto out;
 			if (unlikely(!INET_MATCH(sk, net, acookie,
 						 saddr, daddr, ports, dif))) {
-				sock_put(sk);
+				sock_gen_put(sk);
 				goto begin;
 			}
-			goto out;
+			goto found;
 		}
 	}
 	/*
@@ -271,37 +284,9 @@ begin:
 	 */
 	if (get_nulls_value(node) != slot)
 		goto begin;
-
-begintw:
-	/* Must check for a TIME_WAIT'er before going to listener hash. */
-	sk_nulls_for_each_rcu(sk, node, &head->twchain) {
-		if (sk->sk_hash != hash)
-			continue;
-		if (likely(INET_TW_MATCH(sk, net, acookie,
-					 saddr, daddr, ports,
-					 dif))) {
-			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt))) {
-				sk = NULL;
-				goto out;
-			}
-			if (unlikely(!INET_TW_MATCH(sk, net, acookie,
-						    saddr, daddr, ports,
-						    dif))) {
-				inet_twsk_put(inet_twsk(sk));
-				goto begintw;
-			}
-			goto out;
-		}
-	}
-	/*
-	 * if the nulls value we got at the end of this lookup is
-	 * not the expected one, we must restart lookup.
-	 * We probably met an item that was moved to another chain.
-	 */
-	if (get_nulls_value(node) != slot)
-		goto begintw;
-	sk = NULL;
 out:
+	sk = NULL;
+found:
 	rcu_read_unlock();
 	return sk;
 }
@@ -326,39 +311,29 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 	spinlock_t *lock = inet_ehash_lockp(hinfo, hash);
 	struct sock *sk2;
 	const struct hlist_nulls_node *node;
-	struct inet_timewait_sock *tw;
+	struct inet_timewait_sock *tw = NULL;
 	int twrefcnt = 0;
 
 	spin_lock(lock);
 
-	/* Check TIME-WAIT sockets first. */
-	sk_nulls_for_each(sk2, node, &head->twchain) {
-		if (sk2->sk_hash != hash)
-			continue;
-
-		if (likely(INET_TW_MATCH(sk2, net, acookie,
-					 saddr, daddr, ports, dif))) {
-			tw = inet_twsk(sk2);
-			if (twsk_unique(sk, sk2, twp))
-				goto unique;
-			else
-				goto not_unique;
-		}
-	}
-	tw = NULL;
-
-	/* And established part... */
 	sk_nulls_for_each(sk2, node, &head->chain) {
 		if (sk2->sk_hash != hash)
 			continue;
+
 		if (likely(INET_MATCH(sk2, net, acookie,
-				      saddr, daddr, ports, dif)))
+					 saddr, daddr, ports, dif))) {
+			if (sk2->sk_state == TCP_TIME_WAIT) {
+				tw = inet_twsk(sk2);
+				if (twsk_unique(sk, sk2, twp))
+					break;
+			}
 			goto not_unique;
+		}
 	}
 
-unique:
 	/* Must record num and sport now. Otherwise we will see
-	 * in hash table socket with a funny identity. */
+	 * in hash table socket with a funny identity.
+	 */
 	inet->inet_num = lport;
 	inet->inet_sport = htons(lport);
 	sk->sk_hash = hash;
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 9bcd8f7..6d592f8 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -87,19 +87,11 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 	refcnt += inet_twsk_bind_unhash(tw, hashinfo);
 	spin_unlock(&bhead->lock);
 
-#ifdef SOCK_REFCNT_DEBUG
-	if (atomic_read(&tw->tw_refcnt) != 1) {
-		pr_debug("%s timewait_sock %p refcnt=%d\n",
-			 tw->tw_prot->name, tw, atomic_read(&tw->tw_refcnt));
-	}
-#endif
-	while (refcnt) {
-		inet_twsk_put(tw);
-		refcnt--;
-	}
+	BUG_ON(refcnt >= atomic_read(&tw->tw_refcnt));
+	atomic_sub(refcnt, &tw->tw_refcnt);
 }
 
-static noinline void inet_twsk_free(struct inet_timewait_sock *tw)
+void inet_twsk_free(struct inet_timewait_sock *tw)
 {
 	struct module *owner = tw->tw_prot->owner;
 	twsk_destructor((struct sock *)tw);
@@ -118,6 +110,18 @@ void inet_twsk_put(struct inet_timewait_sock *tw)
 }
 EXPORT_SYMBOL_GPL(inet_twsk_put);
 
+static void inet_twsk_add_node_rcu(struct inet_timewait_sock *tw,
+				   struct hlist_nulls_head *list)
+{
+	hlist_nulls_add_head_rcu(&tw->tw_node, list);
+}
+
+static void inet_twsk_add_bind_node(struct inet_timewait_sock *tw,
+				    struct hlist_head *list)
+{
+	hlist_add_head(&tw->tw_bind_node, list);
+}
+
 /*
  * Enter the time wait state. This is called with locally disabled BH.
  * Essentially we whip up a timewait bucket, copy the relevant info into it
@@ -146,26 +150,21 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 	spin_lock(lock);
 
 	/*
-	 * Step 2: Hash TW into TIMEWAIT chain.
-	 * Should be done before removing sk from established chain
-	 * because readers are lockless and search established first.
+	 * Step 2: Hash TW into tcp ehash chain.
+	 * Notes :
+	 * - tw_refcnt is set to 3 because :
+	 * - We have one reference from bhash chain.
+	 * - We have one reference from ehash chain.
+	 * We can use atomic_set() because prior spin_lock()/spin_unlock()
+	 * committed into memory all tw fields.
 	 */
-	inet_twsk_add_node_rcu(tw, &ehead->twchain);
+	atomic_set(&tw->tw_refcnt, 1 + 1 + 1);
+	inet_twsk_add_node_rcu(tw, &ehead->chain);
 
-	/* Step 3: Remove SK from established hash. */
+	/* Step 3: Remove SK from hash chain */
 	if (__sk_nulls_del_node_init_rcu(sk))
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 
-	/*
-	 * Notes :
-	 * - We initially set tw_refcnt to 0 in inet_twsk_alloc()
-	 * - We add one reference for the bhash link
-	 * - We add one reference for the ehash link
-	 * - We want this refcnt update done before allowing other
-	 *   threads to find this tw in ehash chain.
-	 */
-	atomic_add(1 + 1 + 1, &tw->tw_refcnt);
-
 	spin_unlock(lock);
 }
 EXPORT_SYMBOL_GPL(__inet_twsk_hashdance);
@@ -490,7 +489,9 @@ void inet_twsk_purge(struct inet_hashinfo *hashinfo,
 restart_rcu:
 		rcu_read_lock();
 restart:
-		sk_nulls_for_each_rcu(sk, node, &head->twchain) {
+		sk_nulls_for_each_rcu(sk, node, &head->chain) {
+			if (sk->sk_state != TCP_TIME_WAIT)
+				continue;
 			tw = inet_twsk(sk);
 			if ((tw->tw_family != family) ||
 				atomic_read(&twsk_net(tw)->count))
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6e5617b..be4b161 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3137,10 +3137,9 @@ void __init tcp_init(void)
 					&tcp_hashinfo.ehash_mask,
 					0,
 					thash_entries ? 0 : 512 * 1024);
-	for (i = 0; i <= tcp_hashinfo.ehash_mask; i++) {
+	for (i = 0; i <= tcp_hashinfo.ehash_mask; i++)
 		INIT_HLIST_NULLS_HEAD(&tcp_hashinfo.ehash[i].chain, i);
-		INIT_HLIST_NULLS_HEAD(&tcp_hashinfo.ehash[i].twchain, i);
-	}
+
 	if (inet_ehash_locks_alloc(&tcp_hashinfo))
 		panic("TCP: failed to alloc ehash_locks");
 	tcp_hashinfo.bhash =
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5d6b1a6..e4695dd 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2194,18 +2194,6 @@ EXPORT_SYMBOL(tcp_v4_destroy_sock);
 #ifdef CONFIG_PROC_FS
 /* Proc filesystem TCP sock list dumping. */
 
-static inline struct inet_timewait_sock *tw_head(struct hlist_nulls_head *head)
-{
-	return hlist_nulls_empty(head) ? NULL :
-		list_entry(head->first, struct inet_timewait_sock, tw_node);
-}
-
-static inline struct inet_timewait_sock *tw_next(struct inet_timewait_sock *tw)
-{
-	return !is_a_nulls(tw->tw_node.next) ?
-		hlist_nulls_entry(tw->tw_node.next, typeof(*tw), tw_node) : NULL;
-}
-
 /*
  * Get next listener socket follow cur.  If cur is NULL, get first socket
  * starting from bucket given in st->bucket; when st->bucket is zero the
@@ -2309,10 +2297,9 @@ static void *listening_get_idx(struct seq_file *seq, loff_t *pos)
 	return rc;
 }
 
-static inline bool empty_bucket(struct tcp_iter_state *st)
+static inline bool empty_bucket(const struct tcp_iter_state *st)
 {
-	return hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].chain) &&
-		hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].twchain);
+	return hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].chain);
 }
 
 /*
@@ -2329,7 +2316,6 @@ static void *established_get_first(struct seq_file *seq)
 	for (; st->bucket <= tcp_hashinfo.ehash_mask; ++st->bucket) {
 		struct sock *sk;
 		struct hlist_nulls_node *node;
-		struct inet_timewait_sock *tw;
 		spinlock_t *lock = inet_ehash_lockp(&tcp_hashinfo, st->bucket);
 
 		/* Lockless fast path for the common case of empty buckets */
@@ -2345,18 +2331,7 @@ static void *established_get_first(struct seq_file *seq)
 			rc = sk;
 			goto out;
 		}
-		st->state = TCP_SEQ_STATE_TIME_WAIT;
-		inet_twsk_for_each(tw, node,
-				   &tcp_hashinfo.ehash[st->bucket].twchain) {
-			if (tw->tw_family != st->family ||
-			    !net_eq(twsk_net(tw), net)) {
-				continue;
-			}
-			rc = tw;
-			goto out;
-		}
 		spin_unlock_bh(lock);
-		st->state = TCP_SEQ_STATE_ESTABLISHED;
 	}
 out:
 	return rc;
@@ -2365,7 +2340,6 @@ out:
 static void *established_get_next(struct seq_file *seq, void *cur)
 {
 	struct sock *sk = cur;
-	struct inet_timewait_sock *tw;
 	struct hlist_nulls_node *node;
 	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
@@ -2373,45 +2347,16 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 	++st->num;
 	++st->offset;
 
-	if (st->state == TCP_SEQ_STATE_TIME_WAIT) {
-		tw = cur;
-		tw = tw_next(tw);
-get_tw:
-		while (tw && (tw->tw_family != st->family || !net_eq(twsk_net(tw), net))) {
-			tw = tw_next(tw);
-		}
-		if (tw) {
-			cur = tw;
-			goto out;
-		}
-		spin_unlock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
-		st->state = TCP_SEQ_STATE_ESTABLISHED;
-
-		/* Look for next non empty bucket */
-		st->offset = 0;
-		while (++st->bucket <= tcp_hashinfo.ehash_mask &&
-				empty_bucket(st))
-			;
-		if (st->bucket > tcp_hashinfo.ehash_mask)
-			return NULL;
-
-		spin_lock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
-		sk = sk_nulls_head(&tcp_hashinfo.ehash[st->bucket].chain);
-	} else
-		sk = sk_nulls_next(sk);
+	sk = sk_nulls_next(sk);
 
 	sk_nulls_for_each_from(sk, node) {
 		if (sk->sk_family == st->family && net_eq(sock_net(sk), net))
-			goto found;
+			return sk;
 	}
 
-	st->state = TCP_SEQ_STATE_TIME_WAIT;
-	tw = tw_head(&tcp_hashinfo.ehash[st->bucket].twchain);
-	goto get_tw;
-found:
-	cur = sk;
-out:
-	return cur;
+	spin_unlock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
+	++st->bucket;
+	return established_get_first(seq);
 }
 
 static void *established_get_idx(struct seq_file *seq, loff_t pos)
@@ -2464,10 +2409,9 @@ static void *tcp_seek_last_pos(struct seq_file *seq)
 		if (rc)
 			break;
 		st->bucket = 0;
+		st->state = TCP_SEQ_STATE_ESTABLISHED;
 		/* Fallthrough */
 	case TCP_SEQ_STATE_ESTABLISHED:
-	case TCP_SEQ_STATE_TIME_WAIT:
-		st->state = TCP_SEQ_STATE_ESTABLISHED;
 		if (st->bucket > tcp_hashinfo.ehash_mask)
 			break;
 		rc = established_get_first(seq);
@@ -2524,7 +2468,6 @@ static void *tcp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		}
 		break;
 	case TCP_SEQ_STATE_ESTABLISHED:
-	case TCP_SEQ_STATE_TIME_WAIT:
 		rc = established_get_next(seq, v);
 		break;
 	}
@@ -2548,7 +2491,6 @@ static void tcp_seq_stop(struct seq_file *seq, void *v)
 		if (v != SEQ_START_TOKEN)
 			spin_unlock_bh(&tcp_hashinfo.listening_hash[st->bucket].lock);
 		break;
-	case TCP_SEQ_STATE_TIME_WAIT:
 	case TCP_SEQ_STATE_ESTABLISHED:
 		if (v)
 			spin_unlock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
@@ -2707,6 +2649,7 @@ static void get_timewait4_sock(const struct inet_timewait_sock *tw,
 static int tcp4_seq_show(struct seq_file *seq, void *v)
 {
 	struct tcp_iter_state *st;
+	struct sock *sk = v;
 	int len;
 
 	if (v == SEQ_START_TOKEN) {
@@ -2721,14 +2664,14 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
 	switch (st->state) {
 	case TCP_SEQ_STATE_LISTENING:
 	case TCP_SEQ_STATE_ESTABLISHED:
-		get_tcp4_sock(v, seq, st->num, &len);
+		if (sk->sk_state == TCP_TIME_WAIT)
+			get_timewait4_sock(v, seq, st->num, &len);
+		else
+			get_tcp4_sock(v, seq, st->num, &len);
 		break;
 	case TCP_SEQ_STATE_OPENREQ:
 		get_openreq4(st->syn_wait_sk, v, seq, st->num, st->uid, &len);
 		break;
-	case TCP_SEQ_STATE_TIME_WAIT:
-		get_timewait4_sock(v, seq, st->num, &len);
-		break;
 	}
 	seq_printf(seq, "%*s\n", TMPSZ - 1 - len, "");
 out:
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 066640e..4644077 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -89,43 +89,36 @@ begin:
 	sk_nulls_for_each_rcu(sk, node, &head->chain) {
 		if (sk->sk_hash != hash)
 			continue;
-		if (likely(INET6_MATCH(sk, net, saddr, daddr, ports, dif))) {
-			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
-				goto begintw;
+		if (sk->sk_state == TCP_TIME_WAIT) {
+			if (!INET6_TW_MATCH(sk, net, saddr, daddr, ports, dif))
+				continue;
+		} else {
+			if (!INET6_MATCH(sk, net, saddr, daddr, ports, dif))
+				continue;
+		}
+		if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
+			goto out;
+
+		if (sk->sk_state == TCP_TIME_WAIT) {
+			if (unlikely(!INET6_TW_MATCH(sk, net, saddr, daddr,
+						     ports, dif))) {
+				sock_gen_put(sk);
+				goto begin;
+			}
+		} else {
 			if (unlikely(!INET6_MATCH(sk, net, saddr, daddr,
 						  ports, dif))) {
 				sock_put(sk);
 				goto begin;
 			}
-		goto out;
+		goto found;
 		}
 	}
 	if (get_nulls_value(node) != slot)
 		goto begin;
-
-begintw:
-	/* Must check for a TIME_WAIT'er before going to listener hash. */
-	sk_nulls_for_each_rcu(sk, node, &head->twchain) {
-		if (sk->sk_hash != hash)
-			continue;
-		if (likely(INET6_TW_MATCH(sk, net, saddr, daddr,
-					  ports, dif))) {
-			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt))) {
-				sk = NULL;
-				goto out;
-			}
-			if (unlikely(!INET6_TW_MATCH(sk, net, saddr, daddr,
-						     ports, dif))) {
-				inet_twsk_put(inet_twsk(sk));
-				goto begintw;
-			}
-			goto out;
-		}
-	}
-	if (get_nulls_value(node) != slot)
-		goto begintw;
-	sk = NULL;
 out:
+	sk = NULL;
+found:
 	rcu_read_unlock();
 	return sk;
 }
@@ -248,31 +241,25 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 	spinlock_t *lock = inet_ehash_lockp(hinfo, hash);
 	struct sock *sk2;
 	const struct hlist_nulls_node *node;
-	struct inet_timewait_sock *tw;
+	struct inet_timewait_sock *tw = NULL;
 	int twrefcnt = 0;
 
 	spin_lock(lock);
 
-	/* Check TIME-WAIT sockets first. */
-	sk_nulls_for_each(sk2, node, &head->twchain) {
+	sk_nulls_for_each(sk2, node, &head->chain) {
 		if (sk2->sk_hash != hash)
 			continue;
 
-		if (likely(INET6_TW_MATCH(sk2, net, saddr, daddr,
-					  ports, dif))) {
-			tw = inet_twsk(sk2);
-			if (twsk_unique(sk, sk2, twp))
-				goto unique;
-			else
-				goto not_unique;
+		if (sk2->sk_state == TCP_TIME_WAIT) {
+			if (likely(INET6_TW_MATCH(sk2, net, saddr, daddr,
+						  ports, dif))) {
+				tw = inet_twsk(sk2);
+				if (twsk_unique(sk, sk2, twp))
+					goto unique;
+				else
+					goto not_unique;
+			}
 		}
-	}
-	tw = NULL;
-
-	/* And established part... */
-	sk_nulls_for_each(sk2, node, &head->chain) {
-		if (sk2->sk_hash != hash)
-			continue;
 		if (likely(INET6_MATCH(sk2, net, saddr, daddr, ports, dif)))
 			goto not_unique;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index dde8bad..528e61a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1834,6 +1834,7 @@ static void get_timewait6_sock(struct seq_file *seq,
 static int tcp6_seq_show(struct seq_file *seq, void *v)
 {
 	struct tcp_iter_state *st;
+	struct sock *sk = v;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
@@ -1849,14 +1850,14 @@ static int tcp6_seq_show(struct seq_file *seq, void *v)
 	switch (st->state) {
 	case TCP_SEQ_STATE_LISTENING:
 	case TCP_SEQ_STATE_ESTABLISHED:
-		get_tcp6_sock(seq, v, st->num);
+		if (sk->sk_state == TCP_TIME_WAIT)
+			get_timewait6_sock(seq, v, st->num);
+		else
+			get_tcp6_sock(seq, v, st->num);
 		break;
 	case TCP_SEQ_STATE_OPENREQ:
 		get_openreq6(seq, st->syn_wait_sk, v, st->num, st->uid);
 		break;
-	case TCP_SEQ_STATE_TIME_WAIT:
-		get_timewait6_sock(seq, v, st->num);
-		break;
 	}
 out:
 	return 0;
