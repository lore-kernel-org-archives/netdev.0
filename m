From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC] question about inet_listen_lock(), and [PATCH] net: listening_hash
 get a spinlock per bucket
Date: Mon, 17 Nov 2008 17:21:19 +0100
Message-ID: <492199FF.3030205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030905020309080106040402"
To: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:60548 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbYKQQV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 11:21:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030905020309080106040402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi all

I was looking at converting tcp ehash/listening_hash rwlocks to spinlocks, and found
inet_listen_lock()/unlock() definition :

/*
 * - We may sleep inside this lock.
 * - If sleeping is not required (or called from BH),
 *   use plain read_(un)lock(&inet_hashinfo.lhash_lock).
 */
static inline void inet_listen_lock(struct inet_hashinfo *hashinfo)
{
        /* read_lock synchronizes to candidates to writers */
        read_lock(&hashinfo->lhash_lock);
        atomic_inc(&hashinfo->lhash_users);
        read_unlock(&hashinfo->lhash_lock);
}

static inline void inet_listen_unlock(struct inet_hashinfo *hashinfo)
{
        if (atomic_dec_and_test(&hashinfo->lhash_users))
                wake_up(&hashinfo->lhash_wait);
}

Then for the writer part :
---------------------------

void inet_listen_wlock(struct inet_hashinfo *hashinfo)
        __acquires(hashinfo->lhash_lock)
{
        write_lock(&hashinfo->lhash_lock);

        if (atomic_read(&hashinfo->lhash_users)) {
                DEFINE_WAIT(wait);

                for (;;) {
                        prepare_to_wait_exclusive(&hashinfo->lhash_wait,
                                                  &wait, TASK_UNINTERRUPTIBLE);
                        if (!atomic_read(&hashinfo->lhash_users))
                                break;
                        write_unlock_bh(&hashinfo->lhash_lock);
                        schedule();
                        write_lock_bh(&hashinfo->lhash_lock);
                }

                finish_wait(&hashinfo->lhash_wait, &wait);
        }
}



Other than BH protection, I dont understand why we could sleep while 
"holding" lhash_lock, inside a section protected by :

inet_listen_lock();
...
inet_listen_unlock();

If this was true, then we should have a problem when holding a 
inet_ehash_lockp() lock as well ?

Users of inet_listen_lock() are inet_diag_dump() and tcp_get_idx(), and
I fail to see them eventually sleeping.

IFF its just about BH being allowed, it seems quite a complex/unusual locking
scheme only to avoid holding read_lock_bh() for too long while reading
/proc/net/tcp or inet_diag equivalent.

Using 32 spinlocks (one for each chain) should help to reduce hold time, and
help writers concurrency. With RCU lookup, these spinlocks wont be taken
very much.

Thank you

[PATCH] net: listening_hash get a spinlock per bucket

This patch prepares RCU migration of listening_hash table for
TCP/DCCP protocols.

listening_hash table being small (32 slots per protocol), we add
a spinlock for each slot, instead of a single rwlock for whole table.

This should reduce hold time of readers, and writers concurrency.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/inet_hashtables.h |   45 +++++-----------
 net/dccp/proto.c              |    8 --
 net/ipv4/inet_diag.c          |   12 ++--
 net/ipv4/inet_hashtables.c    |   86 +++++++++++---------------------
 net/ipv4/tcp_ipv4.c           |   24 ++++----
 net/ipv6/inet6_hashtables.c   |   23 ++++----
 6 files changed, 79 insertions(+), 119 deletions(-)


--------------030905020309080106040402
Content-Type: text/plain;
 name="listening_lock_per_chain.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="listening_lock_per_chain.patch"

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 4818960..ab03d5c 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -99,6 +99,11 @@ struct inet_bind_hashbucket {
 	struct hlist_head	chain;
 };
 
+struct inet_listen_hashbucket {
+	spinlock_t		lock;
+	struct hlist_head	head;
+};
+
 /* This is for listening sockets, thus all sockets which possess wildcards. */
 #define INET_LHTABLE_SIZE	32	/* Yes, really, this is all you need. */
 
@@ -123,22 +128,21 @@ struct inet_hashinfo {
 	unsigned int			bhash_size;
 	/* Note : 4 bytes padding on 64 bit arches */
 
-	/* All sockets in TCP_LISTEN state will be in here.  This is the only
-	 * table where wildcard'd TCP sockets can exist.  Hash function here
-	 * is just local port number.
-	 */
-	struct hlist_head		listening_hash[INET_LHTABLE_SIZE];
+	struct kmem_cache		*bind_bucket_cachep;
 
 	/* All the above members are written once at bootup and
 	 * never written again _or_ are predominantly read-access.
 	 *
 	 * Now align to a new cache line as all the following members
-	 * are often dirty.
+	 * might be often dirty.
 	 */
-	rwlock_t			lhash_lock ____cacheline_aligned;
-	atomic_t			lhash_users;
-	wait_queue_head_t		lhash_wait;
-	struct kmem_cache			*bind_bucket_cachep;
+	/* All sockets in TCP_LISTEN state will be in here.  This is the only
+	 * table where wildcard'd TCP sockets can exist.  Hash function here
+	 * is just local port number.
+	 */
+	struct inet_listen_hashbucket	listening_hash[INET_LHTABLE_SIZE]
+					____cacheline_aligned_in_smp;
+
 };
 
 static inline struct inet_ehash_bucket *inet_ehash_bucket(
@@ -236,26 +240,7 @@ extern void __inet_inherit_port(struct sock *sk, struct sock *child);
 
 extern void inet_put_port(struct sock *sk);
 
-extern void inet_listen_wlock(struct inet_hashinfo *hashinfo);
-
-/*
- * - We may sleep inside this lock.
- * - If sleeping is not required (or called from BH),
- *   use plain read_(un)lock(&inet_hashinfo.lhash_lock).
- */
-static inline void inet_listen_lock(struct inet_hashinfo *hashinfo)
-{
-	/* read_lock synchronizes to candidates to writers */
-	read_lock(&hashinfo->lhash_lock);
-	atomic_inc(&hashinfo->lhash_users);
-	read_unlock(&hashinfo->lhash_lock);
-}
-
-static inline void inet_listen_unlock(struct inet_hashinfo *hashinfo)
-{
-	if (atomic_dec_and_test(&hashinfo->lhash_users))
-		wake_up(&hashinfo->lhash_wait);
-}
+void inet_hashinfo_init(struct inet_hashinfo *h);
 
 extern void __inet_hash_nolisten(struct sock *sk);
 extern void inet_hash(struct sock *sk);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index bdf784c..8b63394 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -44,12 +44,7 @@ atomic_t dccp_orphan_count = ATOMIC_INIT(0);
 
 EXPORT_SYMBOL_GPL(dccp_orphan_count);
 
-struct inet_hashinfo __cacheline_aligned dccp_hashinfo = {
-	.lhash_lock	= RW_LOCK_UNLOCKED,
-	.lhash_users	= ATOMIC_INIT(0),
-	.lhash_wait = __WAIT_QUEUE_HEAD_INITIALIZER(dccp_hashinfo.lhash_wait),
-};
-
+struct inet_hashinfo dccp_hashinfo;
 EXPORT_SYMBOL_GPL(dccp_hashinfo);
 
 /* the maximum queue length for tx in packets. 0 is no limit */
@@ -1030,6 +1025,7 @@ static int __init dccp_init(void)
 	BUILD_BUG_ON(sizeof(struct dccp_skb_cb) >
 		     FIELD_SIZEOF(struct sk_buff, cb));
 
+	inet_hashinfo_init(&dccp_hashinfo);
 	dccp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("dccp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 41b3672..1cb154e 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -718,13 +718,15 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (!(r->idiag_states & (TCPF_LISTEN | TCPF_SYN_RECV)))
 			goto skip_listen_ht;
 
-		inet_listen_lock(hashinfo);
 		for (i = s_i; i < INET_LHTABLE_SIZE; i++) {
 			struct sock *sk;
 			struct hlist_node *node;
+			struct inet_listen_hashbucket *ilb;
 
 			num = 0;
-			sk_for_each(sk, node, &hashinfo->listening_hash[i]) {
+			ilb = &hashinfo->listening_hash[i];
+			spin_lock_bh(&ilb->lock);
+			sk_for_each(sk, node, &ilb->head) {
 				struct inet_sock *inet = inet_sk(sk);
 
 				if (num < s_num) {
@@ -742,7 +744,7 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 					goto syn_recv;
 
 				if (inet_csk_diag_dump(sk, skb, cb) < 0) {
-					inet_listen_unlock(hashinfo);
+					spin_unlock_bh(&ilb->lock);
 					goto done;
 				}
 
@@ -751,7 +753,7 @@ syn_recv:
 					goto next_listen;
 
 				if (inet_diag_dump_reqs(skb, sk, cb) < 0) {
-					inet_listen_unlock(hashinfo);
+					spin_unlock_bh(&ilb->lock);
 					goto done;
 				}
 
@@ -760,12 +762,12 @@ next_listen:
 				cb->args[4] = 0;
 				++num;
 			}
+			spin_unlock_bh(&ilb->lock);
 
 			s_num = 0;
 			cb->args[3] = 0;
 			cb->args[4] = 0;
 		}
-		inet_listen_unlock(hashinfo);
 skip_listen_ht:
 		cb->args[0] = 1;
 		s_i = num = s_num = 0;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index fd269cf..377d004 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -111,35 +111,6 @@ void __inet_inherit_port(struct sock *sk, struct sock *child)
 EXPORT_SYMBOL_GPL(__inet_inherit_port);
 
 /*
- * This lock without WQ_FLAG_EXCLUSIVE is good on UP and it can be very bad on SMP.
- * Look, when several writers sleep and reader wakes them up, all but one
- * immediately hit write lock and grab all the cpus. Exclusive sleep solves
- * this, _but_ remember, it adds useless work on UP machines (wake up each
- * exclusive lock release). It should be ifdefed really.
- */
-void inet_listen_wlock(struct inet_hashinfo *hashinfo)
-	__acquires(hashinfo->lhash_lock)
-{
-	write_lock(&hashinfo->lhash_lock);
-
-	if (atomic_read(&hashinfo->lhash_users)) {
-		DEFINE_WAIT(wait);
-
-		for (;;) {
-			prepare_to_wait_exclusive(&hashinfo->lhash_wait,
-						  &wait, TASK_UNINTERRUPTIBLE);
-			if (!atomic_read(&hashinfo->lhash_users))
-				break;
-			write_unlock_bh(&hashinfo->lhash_lock);
-			schedule();
-			write_lock_bh(&hashinfo->lhash_lock);
-		}
-
-		finish_wait(&hashinfo->lhash_wait, &wait);
-	}
-}
-
-/*
  * Don't inline this cruft. Here are some nice properties to exploit here. The
  * BSD API does not allow a listening sock to specify the remote port nor the
  * remote address for the connection. So always assume those are both
@@ -191,25 +162,25 @@ struct sock *__inet_lookup_listener(struct net *net,
 				    const int dif)
 {
 	struct sock *sk = NULL;
-	const struct hlist_head *head;
+	struct inet_listen_hashbucket *ilb;
 
-	read_lock(&hashinfo->lhash_lock);
-	head = &hashinfo->listening_hash[inet_lhashfn(net, hnum)];
-	if (!hlist_empty(head)) {
-		const struct inet_sock *inet = inet_sk((sk = __sk_head(head)));
+	ilb = &hashinfo->listening_hash[inet_lhashfn(net, hnum)];
+	spin_lock(&ilb->lock);
+	if (!hlist_empty(&ilb->head)) {
+		const struct inet_sock *inet = inet_sk((sk = __sk_head(&ilb->head)));
 
 		if (inet->num == hnum && !sk->sk_node.next &&
 		    (!inet->rcv_saddr || inet->rcv_saddr == daddr) &&
 		    (sk->sk_family == PF_INET || !ipv6_only_sock(sk)) &&
 		    !sk->sk_bound_dev_if && net_eq(sock_net(sk), net))
 			goto sherry_cache;
-		sk = inet_lookup_listener_slow(net, head, daddr, hnum, dif);
+		sk = inet_lookup_listener_slow(net, &ilb->head, daddr, hnum, dif);
 	}
 	if (sk) {
 sherry_cache:
 		sock_hold(sk);
 	}
-	read_unlock(&hashinfo->lhash_lock);
+	spin_unlock(&ilb->lock);
 	return sk;
 }
 EXPORT_SYMBOL_GPL(__inet_lookup_listener);
@@ -389,8 +360,7 @@ EXPORT_SYMBOL_GPL(__inet_hash_nolisten);
 static void __inet_hash(struct sock *sk)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
-	struct hlist_head *list;
-	rwlock_t *lock;
+	struct inet_listen_hashbucket *ilb;
 
 	if (sk->sk_state != TCP_LISTEN) {
 		__inet_hash_nolisten(sk);
@@ -398,14 +368,12 @@ static void __inet_hash(struct sock *sk)
 	}
 
 	WARN_ON(!sk_unhashed(sk));
-	list = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
-	lock = &hashinfo->lhash_lock;
+	ilb = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
 
-	inet_listen_wlock(hashinfo);
-	__sk_add_node(sk, list);
+	spin_lock(&ilb->lock);
+	__sk_add_node(sk, &ilb->head);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
-	write_unlock(lock);
-	wake_up(&hashinfo->lhash_wait);
+	spin_unlock(&ilb->lock);
 }
 
 void inet_hash(struct sock *sk)
@@ -420,29 +388,27 @@ EXPORT_SYMBOL_GPL(inet_hash);
 
 void inet_unhash(struct sock *sk)
 {
-	rwlock_t *lock;
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 
 	if (sk_unhashed(sk))
-		goto out;
+		return;
 
 	if (sk->sk_state == TCP_LISTEN) {
-		local_bh_disable();
-		inet_listen_wlock(hashinfo);
-		lock = &hashinfo->lhash_lock;
+		struct inet_listen_hashbucket *ilb;
+
+		ilb = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
+		spin_lock_bh(&ilb->lock);
 		if (__sk_del_node_init(sk))
 			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+		spin_unlock_bh(&ilb->lock);
 	} else {
-		lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
+		rwlock_t *lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
+
 		write_lock_bh(lock);
 		if (__sk_nulls_del_node_init_rcu(sk))
 			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+		write_unlock_bh(lock);
 	}
-
-	write_unlock_bh(lock);
-out:
-	if (sk->sk_state == TCP_LISTEN)
-		wake_up(&hashinfo->lhash_wait);
 }
 EXPORT_SYMBOL_GPL(inet_unhash);
 
@@ -556,3 +522,13 @@ int inet_hash_connect(struct inet_timewait_death_row *death_row,
 }
 
 EXPORT_SYMBOL_GPL(inet_hash_connect);
+
+void inet_hashinfo_init(struct inet_hashinfo *h)
+{
+	int i;
+
+	for (i = 0; i < INET_LHTABLE_SIZE; i++)
+		spin_lock_init(&h->listening_hash[i].lock);
+}
+
+EXPORT_SYMBOL_GPL(inet_hashinfo_init);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b2e3ab2..ed0b9eb 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -97,11 +97,7 @@ struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
 }
 #endif
 
-struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
-	.lhash_lock  = __RW_LOCK_UNLOCKED(tcp_hashinfo.lhash_lock),
-	.lhash_users = ATOMIC_INIT(0),
-	.lhash_wait  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.lhash_wait),
-};
+struct inet_hashinfo tcp_hashinfo;
 
 static inline __u32 tcp_v4_init_sequence(struct sk_buff *skb)
 {
@@ -1874,15 +1870,18 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 	struct inet_connection_sock *icsk;
 	struct hlist_node *node;
 	struct sock *sk = cur;
+	struct inet_listen_hashbucket *ilb;
 	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 
 	if (!sk) {
 		st->bucket = 0;
-		sk = sk_head(&tcp_hashinfo.listening_hash[0]);
+		ilb = &tcp_hashinfo.listening_hash[0];
+		spin_lock_bh(&ilb->lock);
+		sk = sk_head(&ilb->head);
 		goto get_sk;
 	}
-
+	ilb = &tcp_hashinfo.listening_hash[st->bucket];
 	++st->num;
 
 	if (st->state == TCP_SEQ_STATE_OPENREQ) {
@@ -1932,8 +1931,11 @@ start_req:
 		}
 		read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 	}
+	spin_unlock_bh(&ilb->lock);
 	if (++st->bucket < INET_LHTABLE_SIZE) {
-		sk = sk_head(&tcp_hashinfo.listening_hash[st->bucket]);
+		ilb = &tcp_hashinfo.listening_hash[st->bucket];
+		spin_lock_bh(&ilb->lock);
+		sk = sk_head(&ilb->head);
 		goto get_sk;
 	}
 	cur = NULL;
@@ -2066,12 +2068,10 @@ static void *tcp_get_idx(struct seq_file *seq, loff_t pos)
 	void *rc;
 	struct tcp_iter_state *st = seq->private;
 
-	inet_listen_lock(&tcp_hashinfo);
 	st->state = TCP_SEQ_STATE_LISTENING;
 	rc	  = listening_get_idx(seq, &pos);
 
 	if (!rc) {
-		inet_listen_unlock(&tcp_hashinfo);
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 		rc	  = established_get_idx(seq, pos);
 	}
@@ -2103,7 +2103,6 @@ static void *tcp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	case TCP_SEQ_STATE_LISTENING:
 		rc = listening_get_next(seq, v);
 		if (!rc) {
-			inet_listen_unlock(&tcp_hashinfo);
 			st->state = TCP_SEQ_STATE_ESTABLISHED;
 			rc	  = established_get_first(seq);
 		}
@@ -2130,7 +2129,7 @@ static void tcp_seq_stop(struct seq_file *seq, void *v)
 		}
 	case TCP_SEQ_STATE_LISTENING:
 		if (v != SEQ_START_TOKEN)
-			inet_listen_unlock(&tcp_hashinfo);
+			spin_unlock_bh(&tcp_hashinfo.listening_hash[st->bucket].lock);
 		break;
 	case TCP_SEQ_STATE_TIME_WAIT:
 	case TCP_SEQ_STATE_ESTABLISHED:
@@ -2405,6 +2404,7 @@ static struct pernet_operations __net_initdata tcp_sk_ops = {
 
 void __init tcp_v4_init(void)
 {
+	inet_hashinfo_init(&tcp_hashinfo);
 	if (register_pernet_device(&tcp_sk_ops))
 		panic("Failed to create the TCP control socket.\n");
 }
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index c1b4d40..21544b9 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -25,30 +25,30 @@
 void __inet6_hash(struct sock *sk)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
-	rwlock_t *lock;
 
 	WARN_ON(!sk_unhashed(sk));
 
 	if (sk->sk_state == TCP_LISTEN) {
-		struct hlist_head *list;
+		struct inet_listen_hashbucket *ilb;
 
-		list = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
-		lock = &hashinfo->lhash_lock;
-		inet_listen_wlock(hashinfo);
-		__sk_add_node(sk, list);
+		ilb = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
+		spin_lock(&ilb->lock);
+		__sk_add_node(sk, &ilb->head);
+		spin_unlock(&ilb->lock);
 	} else {
 		unsigned int hash;
 		struct hlist_nulls_head *list;
+		rwlock_t *lock;
 
 		sk->sk_hash = hash = inet6_sk_ehashfn(sk);
 		list = &inet_ehash_bucket(hashinfo, hash)->chain;
 		lock = inet_ehash_lockp(hashinfo, hash);
 		write_lock(lock);
 		__sk_nulls_add_node_rcu(sk, list);
+		write_unlock(lock);
 	}
 
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
-	write_unlock(lock);
 }
 EXPORT_SYMBOL(__inet6_hash);
 
@@ -126,10 +126,11 @@ struct sock *inet6_lookup_listener(struct net *net,
 	const struct hlist_node *node;
 	struct sock *result = NULL;
 	int score, hiscore = 0;
+	struct inet_listen_hashbucket *ilb;
 
-	read_lock(&hashinfo->lhash_lock);
-	sk_for_each(sk, node,
-			&hashinfo->listening_hash[inet_lhashfn(net, hnum)]) {
+	ilb = &hashinfo->listening_hash[inet_lhashfn(net, hnum)];
+	spin_lock(&ilb->lock);
+	sk_for_each(sk, node, &ilb->head) {
 		if (net_eq(sock_net(sk), net) && inet_sk(sk)->num == hnum &&
 				sk->sk_family == PF_INET6) {
 			const struct ipv6_pinfo *np = inet6_sk(sk);
@@ -157,7 +158,7 @@ struct sock *inet6_lookup_listener(struct net *net,
 	}
 	if (result)
 		sock_hold(result);
-	read_unlock(&hashinfo->lhash_lock);
+	spin_unlock(&ilb->lock);
 	return result;
 }
 

--------------030905020309080106040402--
