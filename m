From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: efficient port randomistion (rev 3)
Date: Fri, 10 Dec 2004 17:09:00 -0800
Message-ID: <20041210170900.11d41d56.shemminger@osdl.org>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net>
	<20041202135252.04e64f51.davem@davemloft.net>
	<41B14E57.5080803@osdl.org>
	<200412060918.04441.michael.vittrup.larsen@ericsson.com>
	<20041206094234.34861c78@dxpl.pdx.osdl.net>
	<20041208235524.202ff3a1.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: michael.vittrup.larsen@ericsson.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041208235524.202ff3a1.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

okay, here is the revised version. Testing shows that it
is more consistent, and just as fast as existing code,
probably because of the getting rid of portalloc_lock and
better distribution.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/char/random.c b/drivers/char/random.c
--- a/drivers/char/random.c	2004-12-09 23:08:07 -08:00
+++ b/drivers/char/random.c	2004-12-09 23:08:07 -08:00
@@ -2347,6 +2347,24 @@
 	return halfMD4Transform(hash, keyptr->secret);
 }
 
+/* Generate secure starting point for ephemeral TCP port search */
+u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport)
+{
+	struct keydata *keyptr = get_keyptr();
+	u32 hash[4];
+
+	/*
+	 *  Pick a unique starting offset for each ephemeral port search
+	 *  (saddr, daddr, dport) and 48bits of random data.
+	 */
+	hash[0] = saddr;
+	hash[1] = daddr;
+	hash[2] = dport ^ keyptr->secret[10];
+	hash[3] = keyptr->secret[11];
+
+	return halfMD4Transform(hash, keyptr->secret);
+}
+
 #ifdef CONFIG_SYN_COOKIES
 /*
  * Secure SYN cookie computation. This is the algorithm worked out by
diff -Nru a/include/linux/random.h b/include/linux/random.h
--- a/include/linux/random.h	2004-12-09 23:08:07 -08:00
+++ b/include/linux/random.h	2004-12-09 23:08:07 -08:00
@@ -52,6 +52,7 @@
 void generate_random_uuid(unsigned char uuid_out[16]);
 
 extern __u32 secure_ip_id(__u32 daddr);
+extern u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport);
 extern __u32 secure_tcp_sequence_number(__u32 saddr, __u32 daddr,
 					__u16 sport, __u16 dport);
 extern __u32 secure_tcp_syn_cookie(__u32 saddr, __u32 daddr,
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2004-12-09 23:08:07 -08:00
+++ b/net/ipv4/tcp_ipv4.c	2004-12-09 23:08:07 -08:00
@@ -636,10 +636,18 @@
 	return -EADDRNOTAVAIL;
 }
 
+static inline u32 connect_port_offset(const struct sock *sk)
+{
+	const struct inet_opt *inet = inet_sk(sk);
+
+	return secure_tcp_port_ephemeral(inet->rcv_saddr, inet->daddr, 
+					 inet->dport);
+}
+
 /*
  * Bind a port for a connect operation and hash it.
  */
-static int tcp_v4_hash_connect(struct sock *sk)
+static inline int tcp_v4_hash_connect(struct sock *sk)
 {
 	unsigned short snum = inet_sk(sk)->num;
  	struct tcp_bind_hashbucket *head;
@@ -647,36 +655,20 @@
 	int ret;
 
  	if (!snum) {
- 		int rover;
  		int low = sysctl_local_port_range[0];
  		int high = sysctl_local_port_range[1];
- 		int remaining = (high - low) + 1;
+		int range = high - low;
+ 		int i;
+		int port;
+		static u32 hint;
+		u32 offset = hint + connect_port_offset(sk);
 		struct hlist_node *node;
  		struct tcp_tw_bucket *tw = NULL;
 
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
- 		do {
- 			rover++;
- 			if ((rover < low) || (rover > high))
- 				rover = low;
- 			head = &tcp_bhash[tcp_bhashfn(rover)];
+		for (i = 1; i <= range; i++) {
+			port = low + (i + offset) % range;
+ 			head = &tcp_bhash[tcp_bhashfn(port)];
  			spin_lock(&head->lock);
 
  			/* Does not bother with rcv_saddr checks,
@@ -684,19 +676,19 @@
  			 * unique enough.
  			 */
 			tb_for_each(tb, node, &head->chain) {
- 				if (tb->port == rover) {
+ 				if (tb->port == port) {
  					BUG_TRAP(!hlist_empty(&tb->owners));
  					if (tb->fastreuse >= 0)
  						goto next_port;
  					if (!__tcp_v4_check_established(sk,
-									rover,
+									port,
 									&tw))
  						goto ok;
  					goto next_port;
  				}
  			}
 
- 			tb = tcp_bucket_create(head, rover);
+ 			tb = tcp_bucket_create(head, port);
  			if (!tb) {
  				spin_unlock(&head->lock);
  				break;
@@ -706,22 +698,18 @@
 
  		next_port:
  			spin_unlock(&head->lock);
- 		} while (--remaining > 0);
- 		tcp_port_rover = rover;
- 		spin_unlock(&tcp_portalloc_lock);
-
+ 		}
  		local_bh_enable();
 
  		return -EADDRNOTAVAIL;
 
 ok:
- 		/* All locks still held and bhs disabled */
- 		tcp_port_rover = rover;
- 		spin_unlock(&tcp_portalloc_lock);
+		hint += i;
 
- 		tcp_bind_hash(sk, tb, rover);
+ 		/* Head lock still held and bh's disabled */
+ 		tcp_bind_hash(sk, tb, port);
 		if (sk_unhashed(sk)) {
- 			inet_sk(sk)->sport = htons(rover);
+ 			inet_sk(sk)->sport = htons(port);
  			__tcp_v4_hash(sk, 0);
  		}
  		spin_unlock(&head->lock);
