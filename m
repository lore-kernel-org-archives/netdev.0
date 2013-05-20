From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: remove spinlock usage in fast path
Date: Mon, 20 May 2013 09:52:26 -0700
Message-ID: <1369068746.3301.194.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:38278 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755575Ab3ETQw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 12:52:28 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp6so5827688pab.21
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 09:52:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP md5 code uses per cpu variables but protects access to them with
a shared spinlock, which is a contention point.

[ tcp_md5sig_pool_lock is locked twice per incoming packet ]

Makes things much simpler, by allocating crypto structures once, first
time a socket needs md5 keys, and not deallocating them as they are
really small.

Next step would be to allow crypto allocations being done in a NUMA
aware way.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 include/net/tcp.h        |    8 +--
 net/ipv4/tcp.c           |   98 +++++++------------------------------
 net/ipv4/tcp_ipv4.c      |   10 ---
 net/ipv4/tcp_minisocks.c |    6 --
 4 files changed, 29 insertions(+), 93 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e1c3723..bf1cc3d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1283,11 +1283,13 @@ static inline struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
 #define tcp_twsk_md5_key(twsk)	NULL
 #endif
 
-extern struct tcp_md5sig_pool __percpu *tcp_alloc_md5sig_pool(struct sock *);
-extern void tcp_free_md5sig_pool(void);
+extern bool tcp_alloc_md5sig_pool(void);
 
 extern struct tcp_md5sig_pool	*tcp_get_md5sig_pool(void);
-extern void tcp_put_md5sig_pool(void);
+static inline void tcp_put_md5sig_pool(void)
+{
+	local_bh_enable();
+}
 
 extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, const struct tcphdr *);
 extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, const struct sk_buff *,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index dcb116d..9551171 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3095,9 +3095,8 @@ int tcp_gro_complete(struct sk_buff *skb)
 EXPORT_SYMBOL(tcp_gro_complete);
 
 #ifdef CONFIG_TCP_MD5SIG
-static unsigned long tcp_md5sig_users;
-static struct tcp_md5sig_pool __percpu *tcp_md5sig_pool;
-static DEFINE_SPINLOCK(tcp_md5sig_pool_lock);
+static struct tcp_md5sig_pool __percpu *tcp_md5sig_pool __read_mostly;
+static DEFINE_MUTEX(tcp_md5sig_mutex);
 
 static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool __percpu *pool)
 {
@@ -3112,30 +3111,14 @@ static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool __percpu *pool)
 	free_percpu(pool);
 }
 
-void tcp_free_md5sig_pool(void)
-{
-	struct tcp_md5sig_pool __percpu *pool = NULL;
-
-	spin_lock_bh(&tcp_md5sig_pool_lock);
-	if (--tcp_md5sig_users == 0) {
-		pool = tcp_md5sig_pool;
-		tcp_md5sig_pool = NULL;
-	}
-	spin_unlock_bh(&tcp_md5sig_pool_lock);
-	if (pool)
-		__tcp_free_md5sig_pool(pool);
-}
-EXPORT_SYMBOL(tcp_free_md5sig_pool);
-
-static struct tcp_md5sig_pool __percpu *
-__tcp_alloc_md5sig_pool(struct sock *sk)
+static void __tcp_alloc_md5sig_pool(void)
 {
 	int cpu;
 	struct tcp_md5sig_pool __percpu *pool;
 
 	pool = alloc_percpu(struct tcp_md5sig_pool);
 	if (!pool)
-		return NULL;
+		return;
 
 	for_each_possible_cpu(cpu) {
 		struct crypto_hash *hash;
@@ -3146,53 +3129,27 @@ __tcp_alloc_md5sig_pool(struct sock *sk)
 
 		per_cpu_ptr(pool, cpu)->md5_desc.tfm = hash;
 	}
-	return pool;
+	/* before setting tcp_md5sig_pool, we must commit all writes
+	 * to memory. See ACCESS_ONCE() in tcp_get_md5sig_pool()
+	 */
+	smp_wmb();
+	tcp_md5sig_pool = pool;
+	return;
 out_free:
 	__tcp_free_md5sig_pool(pool);
-	return NULL;
 }
 
-struct tcp_md5sig_pool __percpu *tcp_alloc_md5sig_pool(struct sock *sk)
+bool tcp_alloc_md5sig_pool(void)
 {
-	struct tcp_md5sig_pool __percpu *pool;
-	bool alloc = false;
-
-retry:
-	spin_lock_bh(&tcp_md5sig_pool_lock);
-	pool = tcp_md5sig_pool;
-	if (tcp_md5sig_users++ == 0) {
-		alloc = true;
-		spin_unlock_bh(&tcp_md5sig_pool_lock);
-	} else if (!pool) {
-		tcp_md5sig_users--;
-		spin_unlock_bh(&tcp_md5sig_pool_lock);
-		cpu_relax();
-		goto retry;
-	} else
-		spin_unlock_bh(&tcp_md5sig_pool_lock);
-
-	if (alloc) {
-		/* we cannot hold spinlock here because this may sleep. */
-		struct tcp_md5sig_pool __percpu *p;
-
-		p = __tcp_alloc_md5sig_pool(sk);
-		spin_lock_bh(&tcp_md5sig_pool_lock);
-		if (!p) {
-			tcp_md5sig_users--;
-			spin_unlock_bh(&tcp_md5sig_pool_lock);
-			return NULL;
-		}
-		pool = tcp_md5sig_pool;
-		if (pool) {
-			/* oops, it has already been assigned. */
-			spin_unlock_bh(&tcp_md5sig_pool_lock);
-			__tcp_free_md5sig_pool(p);
-		} else {
-			tcp_md5sig_pool = pool = p;
-			spin_unlock_bh(&tcp_md5sig_pool_lock);
-		}
+	if (unlikely(!tcp_md5sig_pool)) {
+		mutex_lock(&tcp_md5sig_mutex);
+
+		if (!tcp_md5sig_pool)
+			__tcp_alloc_md5sig_pool();
+
+		mutex_unlock(&tcp_md5sig_mutex);
 	}
-	return pool;
+	return tcp_md5sig_pool != NULL;
 }
 EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
 
@@ -3209,28 +3166,15 @@ struct tcp_md5sig_pool *tcp_get_md5sig_pool(void)
 	struct tcp_md5sig_pool __percpu *p;
 
 	local_bh_disable();
-
-	spin_lock(&tcp_md5sig_pool_lock);
-	p = tcp_md5sig_pool;
-	if (p)
-		tcp_md5sig_users++;
-	spin_unlock(&tcp_md5sig_pool_lock);
-
+	p = ACCESS_ONCE(tcp_md5sig_pool);
 	if (p)
-		return this_cpu_ptr(p);
+		return __this_cpu_ptr(p);
 
 	local_bh_enable();
 	return NULL;
 }
 EXPORT_SYMBOL(tcp_get_md5sig_pool);
 
-void tcp_put_md5sig_pool(void)
-{
-	local_bh_enable();
-	tcp_free_md5sig_pool();
-}
-EXPORT_SYMBOL(tcp_put_md5sig_pool);
-
 int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
 			const struct tcphdr *th)
 {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7196523..d20ede0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1026,7 +1026,7 @@ int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 	key = sock_kmalloc(sk, sizeof(*key), gfp);
 	if (!key)
 		return -ENOMEM;
-	if (hlist_empty(&md5sig->head) && !tcp_alloc_md5sig_pool(sk)) {
+	if (!tcp_alloc_md5sig_pool()) {
 		sock_kfree_s(sk, key, sizeof(*key));
 		return -ENOMEM;
 	}
@@ -1044,9 +1044,7 @@ EXPORT_SYMBOL(tcp_md5_do_add);
 
 int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr, int family)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_md5sig_key *key;
-	struct tcp_md5sig_info *md5sig;
 
 	key = tcp_md5_do_lookup(sk, (union tcp_md5_addr *)&addr, AF_INET);
 	if (!key)
@@ -1054,10 +1052,6 @@ int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr, int family)
 	hlist_del_rcu(&key->node);
 	atomic_sub(sizeof(*key), &sk->sk_omem_alloc);
 	kfree_rcu(key, rcu);
-	md5sig = rcu_dereference_protected(tp->md5sig_info,
-					   sock_owned_by_user(sk));
-	if (hlist_empty(&md5sig->head))
-		tcp_free_md5sig_pool();
 	return 0;
 }
 EXPORT_SYMBOL(tcp_md5_do_del);
@@ -1071,8 +1065,6 @@ static void tcp_clear_md5_list(struct sock *sk)
 
 	md5sig = rcu_dereference_protected(tp->md5sig_info, 1);
 
-	if (!hlist_empty(&md5sig->head))
-		tcp_free_md5sig_pool();
 	hlist_for_each_entry_safe(key, n, &md5sig->head, node) {
 		hlist_del_rcu(&key->node);
 		atomic_sub(sizeof(*key), &sk->sk_omem_alloc);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0f01788..ab1c086 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -317,7 +317,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 			key = tp->af_specific->md5_lookup(sk, sk);
 			if (key != NULL) {
 				tcptw->tw_md5_key = kmemdup(key, sizeof(*key), GFP_ATOMIC);
-				if (tcptw->tw_md5_key && tcp_alloc_md5sig_pool(sk) == NULL)
+				if (tcptw->tw_md5_key && !tcp_alloc_md5sig_pool())
 					BUG();
 			}
 		} while (0);
@@ -358,10 +358,8 @@ void tcp_twsk_destructor(struct sock *sk)
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_timewait_sock *twsk = tcp_twsk(sk);
 
-	if (twsk->tw_md5_key) {
-		tcp_free_md5sig_pool();
+	if (twsk->tw_md5_key)
 		kfree_rcu(twsk->tw_md5_key, rcu);
-	}
 #endif
 }
 EXPORT_SYMBOL_GPL(tcp_twsk_destructor);
