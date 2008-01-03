From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [NET]: prot_inuse cleanups and optimizations
Date: Thu, 3 Jan 2008 18:41:54 +0100
Message-ID: <20080103184154.220b5294.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"acme@redhat.com" <acme@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:56522 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752303AbYACRl6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2008 12:41:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Cleanups (all functions are prefixed by sock_prot_inuse)

sock_prot_inc_use(prot) -> sock_prot_inuse_add(prot,-1)
sock_prot_dec_use(prot) -> sock_prot_inuse_add(prot,-1)
sock_prot_inuse()       -> sock_prot_inuse_get()

New functions :

sock_prot_inuse_init() and sock_prot_inuse_free() to abstract pcounter use.

2) if CONFIG_PROC_FS=n, we can zap 'inuse' member from "struct proto",
since nobody wants to read the inuse value.

This saves 1372 bytes on i386/SMP and some cpu cycles.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 include/net/inet_hashtables.h |    2 -
 include/net/sock.h            |   40 ++++++++++++++++++++++++--------
 include/net/udp.h             |    2 -
 net/core/sock.c               |    6 ++--
 net/ipv4/inet_hashtables.c    |    6 ++--
 net/ipv4/inet_timewait_sock.c |    2 -
 net/ipv4/proc.c               |    9 ++++---
 net/ipv4/raw.c                |    4 +--
 net/ipv4/udp.c                |    2 -
 net/ipv6/inet6_hashtables.c   |    4 +--
 net/ipv6/ipv6_sockglue.c      |    8 +++---
 net/ipv6/proc.c               |    8 +++---
 12 files changed, 57 insertions(+), 36 deletions(-)


diff --git a/include/net/sock.h b/include/net/sock.h
index a52c2ea..89e04e4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -548,7 +548,9 @@ struct proto {
 	int			(*get_port)(struct sock *sk, unsigned short snum);
 
 	/* Keeping track of sockets in use */
+#ifdef CONFIG_PROC_FS
 	struct pcounter		inuse;
+#endif
 
 	/* Memory pressure */
 	void			(*enter_memory_pressure)(void);
@@ -584,9 +586,6 @@ struct proto {
 #endif
 };
 
-#define DEFINE_PROTO_INUSE(NAME) DEFINE_PCOUNTER(NAME)
-#define REF_PROTO_INUSE(NAME) PCOUNTER_MEMBER_INITIALIZER(NAME, .inuse)
-
 extern int proto_register(struct proto *prot, int alloc_slab);
 extern void proto_unregister(struct proto *prot);
 
@@ -615,21 +614,42 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
 #define sk_refcnt_debug_release(sk) do { } while (0)
 #endif /* SOCK_REFCNT_DEBUG */
 
+
+#ifdef CONFIG_PROC_FS
+# define DEFINE_PROTO_INUSE(NAME) DEFINE_PCOUNTER(NAME)
+# define REF_PROTO_INUSE(NAME) PCOUNTER_MEMBER_INITIALIZER(NAME, .inuse)
 /* Called with local bh disabled */
-static __inline__ void sock_prot_inc_use(struct proto *prot)
+static inline void sock_prot_inuse_add(struct proto *prot, int inc)
 {
-	pcounter_add(&prot->inuse, 1);
+	pcounter_add(&prot->inuse, inc);
 }
-
-static __inline__ void sock_prot_dec_use(struct proto *prot)
+static inline int sock_prot_inuse_init(struct proto *proto)
 {
-	pcounter_add(&prot->inuse, -1);
+	return pcounter_alloc(&proto->inuse);
 }
-
-static __inline__ int sock_prot_inuse(struct proto *proto)
+static inline int sock_prot_inuse_get(struct proto *proto)
 {
 	return pcounter_getval(&proto->inuse);
 }
+static inline void sock_prot_inuse_free(struct proto *proto)
+{
+	pcounter_free(&proto->inuse);
+}
+#else
+# define DEFINE_PROTO_INUSE(NAME)
+# define REF_PROTO_INUSE(NAME)
+static void inline sock_prot_inuse_add(struct proto *prot, int inc)
+{
+}
+static int inline sock_prot_inuse_init(struct proto *proto)
+{
+	return 0;
+}
+static void inline sock_prot_inuse_free(struct proto *proto)
+{
+}
+#endif
+
 
 /* With per-bucket locks this operation is not-atomic, so that
  * this version is not worse.
diff --git a/include/net/udp.h b/include/net/udp.h
index 93796be..c6669c0 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -115,7 +115,7 @@ static inline void udp_lib_unhash(struct sock *sk)
 	write_lock_bh(&udp_hash_lock);
 	if (sk_del_node_init(sk)) {
 		inet_sk(sk)->num = 0;
-		sock_prot_dec_use(sk->sk_prot);
+		sock_prot_inuse_add(sk->sk_prot, -1);
 	}
 	write_unlock_bh(&udp_hash_lock);
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 3d7757e..1c4b1cd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1913,7 +1913,7 @@ int proto_register(struct proto *prot, int alloc_slab)
 	char *request_sock_slab_name = NULL;
 	char *timewait_sock_slab_name;
 
-	if (pcounter_alloc(&prot->inuse) != 0) {
+	if (sock_prot_inuse_init(prot) != 0) {
 		printk(KERN_CRIT "%s: Can't alloc inuse counters!\n", prot->name);
 		goto out;
 	}
@@ -1984,7 +1984,7 @@ out_free_sock_slab:
 	kmem_cache_destroy(prot->slab);
 	prot->slab = NULL;
 out_free_inuse:
-	pcounter_free(&prot->inuse);
+	sock_prot_inuse_free(prot);
 out:
 	return -ENOBUFS;
 }
@@ -1997,7 +1997,7 @@ void proto_unregister(struct proto *prot)
 	list_del(&prot->node);
 	write_unlock(&proto_list_lock);
 
-	pcounter_free(&prot->inuse);
+	sock_prot_inuse_free(prot);
 
 	if (prot->slab != NULL) {
 		kmem_cache_destroy(prot->slab);
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 88a059e..619c63c 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -278,7 +278,7 @@ unique:
 	sk->sk_hash = hash;
 	BUG_TRAP(sk_unhashed(sk));
 	__sk_add_node(sk, &head->chain);
-	sock_prot_inc_use(sk->sk_prot);
+	sock_prot_inuse_add(sk->sk_prot, 1);
 	write_unlock(lock);
 
 	if (twp) {
@@ -321,7 +321,7 @@ void __inet_hash_nolisten(struct inet_hashinfo *hashinfo, struct sock *sk)
 
 	write_lock(lock);
 	__sk_add_node(sk, list);
-	sock_prot_inc_use(sk->sk_prot);
+	sock_prot_inuse_add(sk->sk_prot, 1);
 	write_unlock(lock);
 }
 EXPORT_SYMBOL_GPL(__inet_hash_nolisten);
@@ -342,7 +342,7 @@ void __inet_hash(struct inet_hashinfo *hashinfo, struct sock *sk)
 
 	inet_listen_wlock(hashinfo);
 	__sk_add_node(sk, list);
-	sock_prot_inc_use(sk->sk_prot);
+	sock_prot_inuse_add(sk->sk_prot, 1);
 	write_unlock(lock);
 	wake_up(&hashinfo->lhash_wait);
 }
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 1b7db42..876169f 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -91,7 +91,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 
 	/* Step 2: Remove SK from established hash. */
 	if (__sk_del_node_init(sk))
-		sock_prot_dec_use(sk->sk_prot);
+		sock_prot_inuse_add(sk->sk_prot, -1);
 
 	/* Step 3: Hash TW into TIMEWAIT chain. */
 	inet_twsk_add_node(tw, &ehead->twchain);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 53bc010..cb3787f 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -53,13 +53,14 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 {
 	socket_seq_show(seq);
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %d\n",
-		   sock_prot_inuse(&tcp_prot), atomic_read(&tcp_orphan_count),
+		   sock_prot_inuse_get(&tcp_prot),
+		   atomic_read(&tcp_orphan_count),
 		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
 		   atomic_read(&tcp_memory_allocated));
-	seq_printf(seq, "UDP: inuse %d mem %d\n", sock_prot_inuse(&udp_prot),
+	seq_printf(seq, "UDP: inuse %d mem %d\n", sock_prot_inuse_get(&udp_prot),
 		   atomic_read(&udp_memory_allocated));
-	seq_printf(seq, "UDPLITE: inuse %d\n", sock_prot_inuse(&udplite_prot));
-	seq_printf(seq, "RAW: inuse %d\n", sock_prot_inuse(&raw_prot));
+	seq_printf(seq, "UDPLITE: inuse %d\n", sock_prot_inuse_get(&udplite_prot));
+	seq_printf(seq, "RAW: inuse %d\n", sock_prot_inuse_get(&raw_prot));
 	seq_printf(seq,  "FRAG: inuse %d memory %d\n",
 			ip_frag_nqueues(), ip_frag_mem());
 	return 0;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 1bd188f..b1c423a 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -92,7 +92,7 @@ void raw_hash_sk(struct sock *sk, struct raw_hashinfo *h)
 
 	write_lock_bh(&h->lock);
 	sk_add_node(sk, head);
-	sock_prot_inc_use(sk->sk_prot);
+	sock_prot_inuse_add(sk->sk_prot, 1);
 	write_unlock_bh(&h->lock);
 }
 EXPORT_SYMBOL_GPL(raw_hash_sk);
@@ -101,7 +101,7 @@ void raw_unhash_sk(struct sock *sk, struct raw_hashinfo *h)
 {
 	write_lock_bh(&h->lock);
 	if (sk_del_node_init(sk))
-		sock_prot_dec_use(sk->sk_prot);
+		sock_prot_inuse_add(sk->sk_prot, -1);
 	write_unlock_bh(&h->lock);
 }
 EXPORT_SYMBOL_GPL(raw_unhash_sk);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 02fcccd..cb2411c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -230,7 +230,7 @@ gotit:
 	if (sk_unhashed(sk)) {
 		head = &udptable[snum & (UDP_HTABLE_SIZE - 1)];
 		sk_add_node(sk, head);
-		sock_prot_inc_use(sk->sk_prot);
+		sock_prot_inuse_add(sk->sk_prot, 1);
 	}
 	error = 0;
 fail:
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index adc73ad..d0b3447 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -43,7 +43,7 @@ void __inet6_hash(struct inet_hashinfo *hashinfo,
 	}
 
 	__sk_add_node(sk, list);
-	sock_prot_inc_use(sk->sk_prot);
+	sock_prot_inuse_add(sk->sk_prot, 1);
 	write_unlock(lock);
 }
 EXPORT_SYMBOL(__inet6_hash);
@@ -216,7 +216,7 @@ unique:
 	BUG_TRAP(sk_unhashed(sk));
 	__sk_add_node(sk, &head->chain);
 	sk->sk_hash = hash;
-	sock_prot_inc_use(sk->sk_prot);
+	sock_prot_inuse_add(sk->sk_prot, 1);
 	write_unlock(lock);
 
 	if (twp != NULL) {
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 20fece4..bf2a686 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -268,8 +268,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 				struct inet_connection_sock *icsk = inet_csk(sk);
 
 				local_bh_disable();
-				sock_prot_dec_use(sk->sk_prot);
-				sock_prot_inc_use(&tcp_prot);
+				sock_prot_inuse_add(sk->sk_prot, -1);
+				sock_prot_inuse_add(&tcp_prot, 1);
 				local_bh_enable();
 				sk->sk_prot = &tcp_prot;
 				icsk->icsk_af_ops = &ipv4_specific;
@@ -282,8 +282,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 				if (sk->sk_protocol == IPPROTO_UDPLITE)
 					prot = &udplite_prot;
 				local_bh_disable();
-				sock_prot_dec_use(sk->sk_prot);
-				sock_prot_inc_use(prot);
+				sock_prot_inuse_add(sk->sk_prot, -1);
+				sock_prot_inuse_add(prot, 1);
 				local_bh_enable();
 				sk->sk_prot = prot;
 				sk->sk_socket->ops = &inet_dgram_ops;
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 9fc2428..6b0314e 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -36,13 +36,13 @@ static struct proc_dir_entry *proc_net_devsnmp6;
 static int sockstat6_seq_show(struct seq_file *seq, void *v)
 {
 	seq_printf(seq, "TCP6: inuse %d\n",
-		       sock_prot_inuse(&tcpv6_prot));
+		       sock_prot_inuse_get(&tcpv6_prot));
 	seq_printf(seq, "UDP6: inuse %d\n",
-		       sock_prot_inuse(&udpv6_prot));
+		       sock_prot_inuse_get(&udpv6_prot));
 	seq_printf(seq, "UDPLITE6: inuse %d\n",
-			sock_prot_inuse(&udplitev6_prot));
+			sock_prot_inuse_get(&udplitev6_prot));
 	seq_printf(seq, "RAW6: inuse %d\n",
-		       sock_prot_inuse(&rawv6_prot));
+		       sock_prot_inuse_get(&rawv6_prot));
 	seq_printf(seq, "FRAG6: inuse %d memory %d\n",
 		       ip6_frag_nqueues(), ip6_frag_mem());
 	return 0;
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 65ddb25..761bdc0 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -293,7 +293,7 @@ static inline void inet_unhash(struct inet_hashinfo *hashinfo, struct sock *sk)
 	}
 
 	if (__sk_del_node_init(sk))
-		sock_prot_dec_use(sk->sk_prot);
+		sock_prot_inuse_add(sk->sk_prot, -1);
 	write_unlock_bh(lock);
 out:
 	if (sk->sk_state == TCP_LISTEN)
