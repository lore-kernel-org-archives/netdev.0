From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: efficient port randomisation
Date: Fri, 29 Oct 2004 10:28:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029102828.123502e7@zqx3.pdx.osdl.net>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net>
	<200410291048.01955.michael.vittrup.larsen@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <200410291048.01955.michael.vittrup.larsen@ericsson.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Provide port randomization for incoming connections using variation of
existing sequence number hash. Replace tcp_portalloc_lock and tcp_port_rover
with atomic operation to allow better parallelism.

This is based on 
http://www.ietf.org/internet-drafts/draft-larsen-tsvwg-port-randomisation-00.txt
(with confirmation of of no IPR issues).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -urNp -X dontdiff linux-2.6/drivers/char/random.c port-2.6/drivers/char/random.c
--- linux-2.6/drivers/char/random.c	2004-10-28 11:06:09.000000000 -0700
+++ port-2.6/drivers/char/random.c	2004-10-28 15:53:50.000000000 -0700
@@ -2352,6 +2352,24 @@ __u32 secure_ip_id(__u32 daddr)
 	return halfMD4Transform(hash, keyptr->secret);
 }
 
+/* Generate secure starting point for ephemeral TCP port search */
+__u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport)
+{
+	struct keydata *keyptr = get_keyptr();
+	u32 hash[4];
+
+	/*
+	 *  Pick a unique starting offset for each ephemeral port search
+	 *  (saddr, daddr, dport).
+	 */
+	hash[0] = saddr;
+	hash[1] = daddr;
+	hash[2] = dport << 16 | smp_processor_id();
+	hash[3] = keyptr->secret[11];
+
+	return halfMD4Transform(hash, keyptr->secret);
+}
+
 #ifdef CONFIG_SYN_COOKIES
 /*
  * Secure SYN cookie computation. This is the algorithm worked out by
diff -urNp -X dontdiff linux-2.6/include/linux/random.h port-2.6/include/linux/random.h
--- linux-2.6/include/linux/random.h	2004-09-13 09:09:19.000000000 -0700
+++ port-2.6/include/linux/random.h	2004-10-28 15:13:34.000000000 -0700
@@ -54,6 +54,7 @@ extern void get_random_bytes(void *buf, 
 void generate_random_uuid(unsigned char uuid_out[16]);
 
 extern __u32 secure_ip_id(__u32 daddr);
+extern __u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport);
 extern __u32 secure_tcp_sequence_number(__u32 saddr, __u32 daddr,
 					__u16 sport, __u16 dport);
 extern __u32 secure_tcp_syn_cookie(__u32 saddr, __u32 daddr,
diff -urNp -X dontdiff linux-2.6/include/net/tcp.h port-2.6/include/net/tcp.h
--- linux-2.6/include/net/tcp.h	2004-10-26 16:57:47.000000000 -0700
+++ port-2.6/include/net/tcp.h	2004-10-28 15:13:34.000000000 -0700
@@ -140,7 +140,6 @@ extern struct tcp_hashinfo {
 	rwlock_t __tcp_lhash_lock ____cacheline_aligned;
 	atomic_t __tcp_lhash_users;
 	wait_queue_head_t __tcp_lhash_wait;
-	spinlock_t __tcp_portalloc_lock;
 } tcp_hashinfo;
 
 #define tcp_ehash	(tcp_hashinfo.__tcp_ehash)
@@ -151,14 +150,19 @@ extern struct tcp_hashinfo {
 #define tcp_lhash_lock	(tcp_hashinfo.__tcp_lhash_lock)
 #define tcp_lhash_users	(tcp_hashinfo.__tcp_lhash_users)
 #define tcp_lhash_wait	(tcp_hashinfo.__tcp_lhash_wait)
-#define tcp_portalloc_lock (tcp_hashinfo.__tcp_portalloc_lock)
 
 extern kmem_cache_t *tcp_bucket_cachep;
 extern struct tcp_bind_bucket *tcp_bucket_create(struct tcp_bind_hashbucket *head,
 						 unsigned short snum);
 extern void tcp_bucket_destroy(struct tcp_bind_bucket *tb);
 extern void tcp_bucket_unlock(struct sock *sk);
-extern int tcp_port_rover;
+extern atomic_t tcp_rover_next;
+
+/* offset in ephemeral port space to start next scan */
+static inline u32 tcp_port_rover(void)
+{
+	return (u32) atomic_inc_return(&tcp_rover_next);
+}
 
 /* These are AF independent. */
 static __inline__ int tcp_bhashfn(__u16 lport)
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp.c port-2.6/net/ipv4/tcp.c
--- linux-2.6/net/ipv4/tcp.c	2004-10-28 11:06:09.000000000 -0700
+++ port-2.6/net/ipv4/tcp.c	2004-10-28 15:13:34.000000000 -0700
@@ -2342,7 +2342,6 @@ void __init tcp_init(void)
 		sysctl_tcp_max_orphans >>= (3 - order);
 		sysctl_max_syn_backlog = 128;
 	}
-	tcp_port_rover = sysctl_local_port_range[0] - 1;
 
 	sysctl_tcp_mem[0] =  768 << order;
 	sysctl_tcp_mem[1] = 1024 << order;
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_ipv4.c port-2.6/net/ipv4/tcp_ipv4.c
--- linux-2.6/net/ipv4/tcp_ipv4.c	2004-10-26 16:57:48.000000000 -0700
+++ port-2.6/net/ipv4/tcp_ipv4.c	2004-10-28 15:13:34.000000000 -0700
@@ -93,7 +93,6 @@ struct tcp_hashinfo __cacheline_aligned 
 	.__tcp_lhash_users	=	ATOMIC_INIT(0),
 	.__tcp_lhash_wait
 	  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.__tcp_lhash_wait),
-	.__tcp_portalloc_lock	=	SPIN_LOCK_UNLOCKED
 };
 
 /*
@@ -102,7 +101,8 @@ struct tcp_hashinfo __cacheline_aligned 
  * 32768-61000
  */
 int sysctl_local_port_range[2] = { 1024, 4999 };
-int tcp_port_rover = 1024 - 1;
+
+atomic_t tcp_rover_next = ATOMIC_INIT(0);
 
 static __inline__ int tcp_hashfn(__u32 laddr, __u16 lport,
 				 __u32 faddr, __u16 fport)
@@ -219,14 +219,10 @@ static int tcp_v4_get_port(struct sock *
 		int low = sysctl_local_port_range[0];
 		int high = sysctl_local_port_range[1];
 		int remaining = (high - low) + 1;
-		int rover;
+		__u16 rover;
 
-		spin_lock(&tcp_portalloc_lock);
-		rover = tcp_port_rover;
+		rover = low + tcp_port_rover() % (high - low);
 		do {
-			rover++;
-			if (rover < low || rover > high)
-				rover = low;
 			head = &tcp_bhash[tcp_bhashfn(rover)];
 			spin_lock(&head->lock);
 			tb_for_each(tb, node, &head->chain)
@@ -235,9 +231,9 @@ static int tcp_v4_get_port(struct sock *
 			break;
 		next:
 			spin_unlock(&head->lock);
+			if (++rover >= high)
+				rover = low;
 		} while (--remaining > 0);
-		tcp_port_rover = rover;
-		spin_unlock(&tcp_portalloc_lock);
 
 		/* Exhausted local port range during search? */
 		ret = 1;
@@ -634,6 +630,13 @@ not_unique:
 	return -EADDRNOTAVAIL;
 }
 
+static inline u32 connect_port_offset(const struct sock *sk)
+{
+	const struct inet_opt *inet = inet_sk(sk);
+	return secure_tcp_port_ephemeral(inet->rcv_saddr, inet->daddr, 
+					 inet->dport);
+}
+
 /*
  * Bind a port for a connect operation and hash it.
  */
@@ -645,35 +648,17 @@ static int tcp_v4_hash_connect(struct so
 	int ret;
 
  	if (!snum) {
- 		int rover;
  		int low = sysctl_local_port_range[0];
  		int high = sysctl_local_port_range[1];
  		int remaining = (high - low) + 1;
 		struct hlist_node *node;
  		struct tcp_tw_bucket *tw = NULL;
+		__u16 rover;
 
+		rover = low + (tcp_port_rover() + connect_port_offset(sk)) 
+			      % (high - low);
  		local_bh_disable();
-
- 		/* TODO. Actually it is not so bad idea to remove
- 		 * tcp_portalloc_lock before next submission to Linus.
- 		 * As soon as we touch this place at all it is time to think.
- 		 *
- 		 * Now it protects single _advisory_ variable tcp_port_rover,
- 		 * hence it is mostly useless.
- 		 * Code will work nicely if we just delete it, but
- 		 * I am afraid in contented case it will work not better or
- 		 * even worse: another cpu just will hit the same bucket
- 		 * and spin there.
- 		 * So some cpu salt could remove both contention and
- 		 * memory pingpong. Any ideas how to do this in a nice way?
- 		 */
- 		spin_lock(&tcp_portalloc_lock);
- 		rover = tcp_port_rover;
-
  		do {
- 			rover++;
- 			if ((rover < low) || (rover > high))
- 				rover = low;
  			head = &tcp_bhash[tcp_bhashfn(rover)];
  			spin_lock(&head->lock);
 
@@ -704,9 +689,10 @@ static int tcp_v4_hash_connect(struct so
 
  		next_port:
  			spin_unlock(&head->lock);
+
+			if (++rover >= high)
+				rover = low;
  		} while (--remaining > 0);
- 		tcp_port_rover = rover;
- 		spin_unlock(&tcp_portalloc_lock);
 
  		local_bh_enable();
 
@@ -714,9 +700,6 @@ static int tcp_v4_hash_connect(struct so
 
 ok:
  		/* All locks still held and bhs disabled */
- 		tcp_port_rover = rover;
- 		spin_unlock(&tcp_portalloc_lock);
-
  		tcp_bind_hash(sk, tb, rover);
 		if (sk_unhashed(sk)) {
  			inet_sk(sk)->sport = htons(rover);
@@ -2646,8 +2629,8 @@ EXPORT_SYMBOL(tcp_bucket_create);
 EXPORT_SYMBOL(tcp_hashinfo);
 EXPORT_SYMBOL(tcp_inherit_port);
 EXPORT_SYMBOL(tcp_listen_wlock);
-EXPORT_SYMBOL(tcp_port_rover);
 EXPORT_SYMBOL(tcp_prot);
+EXPORT_SYMBOL(tcp_rover_next);
 EXPORT_SYMBOL(tcp_put_port);
 EXPORT_SYMBOL(tcp_unhash);
 EXPORT_SYMBOL(tcp_v4_conn_request);
diff -urNp -X dontdiff linux-2.6/net/ipv6/tcp_ipv6.c port-2.6/net/ipv6/tcp_ipv6.c
--- linux-2.6/net/ipv6/tcp_ipv6.c	2004-10-26 16:57:48.000000000 -0700
+++ port-2.6/net/ipv6/tcp_ipv6.c	2004-10-28 15:13:34.000000000 -0700
@@ -136,13 +136,10 @@ static int tcp_v6_get_port(struct sock *
 		int low = sysctl_local_port_range[0];
 		int high = sysctl_local_port_range[1];
 		int remaining = (high - low) + 1;
-		int rover;
+		u16 rover;
 
-		spin_lock(&tcp_portalloc_lock);
-		rover = tcp_port_rover;
-		do {	rover++;
-			if ((rover < low) || (rover > high))
-				rover = low;
+		rover = low + tcp_port_rover() % (high - low);
+		do {
 			head = &tcp_bhash[tcp_bhashfn(rover)];
 			spin_lock(&head->lock);
 			tb_for_each(tb, node, &head->chain)
@@ -151,9 +148,9 @@ static int tcp_v6_get_port(struct sock *
 			break;
 		next:
 			spin_unlock(&head->lock);
+			if (++rover >= high)
+				rover = low;
 		} while (--remaining > 0);
-		tcp_port_rover = rover;
-		spin_unlock(&tcp_portalloc_lock);
 
 		/* Exhausted local port range during search? */
 		ret = 1;
