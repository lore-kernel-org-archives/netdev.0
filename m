From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] tcp ephemeral port selection
Date: Mon, 11 Oct 2004 17:14:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011171422.65f88472@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a test patch which changes how TCP ephemeral ports are selected from a simple
roving pointer to:
	* net_random() as starting point when doing pure local searchs.
	* use md hash (like isn) when doing connection based assignments with a rover

This is *not* for 2.6.9 but wanted to get it out for comment for future versions.

diff -Nru a/drivers/char/random.c b/drivers/char/random.c
--- a/drivers/char/random.c	2004-10-11 17:08:33 -07:00
+++ b/drivers/char/random.c	2004-10-11 17:08:33 -07:00
@@ -2354,6 +2354,23 @@
 	return halfMD4Transform(hash, keyptr->secret);
 }
 
+/* Generate secure starting point for ephemeral TCP port search */
+__u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport)
+{
+	__u32 hash[4];
+	struct keydata *keyptr = get_keyptr();
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
diff -Nru a/include/linux/random.h b/include/linux/random.h
--- a/include/linux/random.h	2004-10-11 17:08:33 -07:00
+++ b/include/linux/random.h	2004-10-11 17:08:33 -07:00
@@ -54,6 +54,7 @@
 void generate_random_uuid(unsigned char uuid_out[16]);
 
 extern __u32 secure_ip_id(__u32 daddr);
+extern __u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport);
 extern __u32 secure_tcp_sequence_number(__u32 saddr, __u32 daddr,
 					__u16 sport, __u16 dport);
 extern __u32 secure_tcp_syn_cookie(__u32 saddr, __u32 daddr,
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-10-11 17:08:33 -07:00
+++ b/include/net/tcp.h	2004-10-11 17:08:33 -07:00
@@ -140,7 +140,6 @@
 	rwlock_t __tcp_lhash_lock ____cacheline_aligned;
 	atomic_t __tcp_lhash_users;
 	wait_queue_head_t __tcp_lhash_wait;
-	spinlock_t __tcp_portalloc_lock;
 } tcp_hashinfo;
 
 #define tcp_ehash	(tcp_hashinfo.__tcp_ehash)
@@ -151,14 +150,12 @@
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
 extern struct sock *tcp_v4_lookup_listener(u32 addr, unsigned short hnum, int dif);
 
 /* These are AF independent. */
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	2004-10-11 17:08:33 -07:00
+++ b/net/ipv4/tcp.c	2004-10-11 17:08:33 -07:00
@@ -2285,7 +2285,6 @@
 		sysctl_tcp_max_orphans >>= (3 - order);
 		sysctl_max_syn_backlog = 128;
 	}
-	tcp_port_rover = sysctl_local_port_range[0] - 1;
 
 	sysctl_tcp_mem[0] =  768 << order;
 	sysctl_tcp_mem[1] = 1024 << order;
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2004-10-11 17:08:33 -07:00
+++ b/net/ipv4/tcp_ipv4.c	2004-10-11 17:08:33 -07:00
@@ -93,7 +93,6 @@
 	.__tcp_lhash_users	=	ATOMIC_INIT(0),
 	.__tcp_lhash_wait
 	  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.__tcp_lhash_wait),
-	.__tcp_portalloc_lock	=	SPIN_LOCK_UNLOCKED
 };
 
 /*
@@ -102,7 +101,6 @@
  * 32768-61000
  */
 int sysctl_local_port_range[2] = { 1024, 4999 };
-int tcp_port_rover = 1024 - 1;
 
 static __inline__ int tcp_hashfn(__u32 laddr, __u16 lport,
 				 __u32 faddr, __u16 fport)
@@ -219,14 +217,10 @@
 		int low = sysctl_local_port_range[0];
 		int high = sysctl_local_port_range[1];
 		int remaining = (high - low) + 1;
-		int rover;
+		__u16 rover;
 
-		spin_lock(&tcp_portalloc_lock);
-		rover = tcp_port_rover;
+		rover = low + net_random() % (high - low);
 		do {
-			rover++;
-			if (rover < low || rover > high)
-				rover = low;
 			head = &tcp_bhash[tcp_bhashfn(rover)];
 			spin_lock(&head->lock);
 			tb_for_each(tb, node, &head->chain)
@@ -234,10 +228,10 @@
 					goto next;
 			break;
 		next:
+			if (++rover >= high)
+				rover = low;
 			spin_unlock(&head->lock);
 		} while (--remaining > 0);
-		tcp_port_rover = rover;
-		spin_unlock(&tcp_portalloc_lock);
 
 		/* Exhausted local port range during search? */
 		ret = 1;
@@ -634,18 +628,26 @@
 	return -EADDRNOTAVAIL;
 }
 
+static inline __u32 ephemeral_port_offset(const struct sock *sk)
+{
+	const struct inet_opt *inet = inet_sk(sk);
+	return secure_tcp_port_ephemeral(inet->rcv_saddr, inet->daddr, 
+					 inet->dport);
+}
+
 /*
  * Bind a port for a connect operation and hash it.
  */
 static int tcp_v4_hash_connect(struct sock *sk)
 {
-	unsigned short snum = inet_sk(sk)->num;
+	__u16 snum = inet_sk(sk)->num;
  	struct tcp_bind_hashbucket *head;
  	struct tcp_bind_bucket *tb;
 	int ret;
+	static int next_rover = 1024;
 
  	if (!snum) {
- 		int rover;
+ 		__u16 rover;
  		int low = sysctl_local_port_range[0];
  		int high = sysctl_local_port_range[1];
  		int remaining = (high - low) + 1;
@@ -654,26 +656,10 @@
 
  		local_bh_disable();
 
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
+		/* next_rover is only advisory, don't bother with lock. */
+ 		rover = low + (next_rover - low
+			       + ephemeral_port_offset(sk)) % (high - low);
  		do {
- 			rover++;
- 			if ((rover < low) || (rover > high))
- 				rover = low;
  			head = &tcp_bhash[tcp_bhashfn(rover)];
  			spin_lock(&head->lock);
 
@@ -703,19 +689,17 @@
  			goto ok;
 
  		next_port:
+			if (++rover == high)
+				rover = low;
  			spin_unlock(&head->lock);
  		} while (--remaining > 0);
- 		tcp_port_rover = rover;
- 		spin_unlock(&tcp_portalloc_lock);
-
  		local_bh_enable();
 
  		return -EADDRNOTAVAIL;
 
 ok:
  		/* All locks still held and bhs disabled */
- 		tcp_port_rover = rover;
- 		spin_unlock(&tcp_portalloc_lock);
+ 		next_rover = rover;
 
  		tcp_bind_hash(sk, tb, rover);
 		if (sk_unhashed(sk)) {
@@ -2646,7 +2630,6 @@
 EXPORT_SYMBOL(tcp_hashinfo);
 EXPORT_SYMBOL(tcp_inherit_port);
 EXPORT_SYMBOL(tcp_listen_wlock);
-EXPORT_SYMBOL(tcp_port_rover);
 EXPORT_SYMBOL(tcp_prot);
 EXPORT_SYMBOL(tcp_put_port);
 EXPORT_SYMBOL(tcp_unhash);
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2004-10-11 17:08:33 -07:00
+++ b/net/ipv6/tcp_ipv6.c	2004-10-11 17:08:33 -07:00
@@ -136,13 +136,10 @@
 		int low = sysctl_local_port_range[0];
 		int high = sysctl_local_port_range[1];
 		int remaining = (high - low) + 1;
-		int rover;
+		__u16 rover;
 
-		spin_lock(&tcp_portalloc_lock);
-		rover = tcp_port_rover;
-		do {	rover++;
-			if ((rover < low) || (rover > high))
-				rover = low;
+		rover = low + net_random() % (high - low);
+		do {	
 			head = &tcp_bhash[tcp_bhashfn(rover)];
 			spin_lock(&head->lock);
 			tb_for_each(tb, node, &head->chain)
@@ -150,10 +147,10 @@
 					goto next;
 			break;
 		next:
+			if (++rover >= high)
+				rover = low;
 			spin_unlock(&head->lock);
 		} while (--remaining > 0);
-		tcp_port_rover = rover;
-		spin_unlock(&tcp_portalloc_lock);
 
 		/* Exhausted local port range during search? */
 		ret = 1;
