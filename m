From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: efficient port randomisation (rev 3)
Date: Mon, 6 Dec 2004 09:42:34 -0800
Message-ID: <20041206094234.34861c78@dxpl.pdx.osdl.net>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net>
	<20041202135252.04e64f51.davem@davemloft.net>
	<41B14E57.5080803@osdl.org>
	<200412060918.04441.michael.vittrup.larsen@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <200412060918.04441.michael.vittrup.larsen@ericsson.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Third revision of the TCP port randomization patch. It randomizes
TCP ephemeral ports of incoming connections using variation of existing
sequence number hash. This one avoids the MD4 for the loopback case since 
there is no reason to bother over loopback and it improves benchmark numbers.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Thanks to original author Michael Larsen. 
http://www.ietf.org/internet-drafts/draft-larsen-tsvwg-port-randomisation-00.txt 

diff -urNp -X dontdiff test-2.6/drivers/char/random.c tcpport/drivers/char/random.c
--- test-2.6/drivers/char/random.c	2004-11-30 16:26:41.000000000 -0800
+++ tcpport/drivers/char/random.c	2004-12-03 17:04:18.267850607 -0800
@@ -2347,6 +2347,24 @@ __u32 secure_ip_id(__u32 daddr)
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
diff -urNp -X dontdiff test-2.6/include/linux/random.h tcpport/include/linux/random.h
--- test-2.6/include/linux/random.h	2004-11-30 16:26:51.000000000 -0800
+++ tcpport/include/linux/random.h	2004-12-02 17:07:13.000000000 -0800
@@ -52,6 +52,7 @@ extern void get_random_bytes(void *buf, 
 void generate_random_uuid(unsigned char uuid_out[16]);
 
 extern __u32 secure_ip_id(__u32 daddr);
+extern u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport);
 extern __u32 secure_tcp_sequence_number(__u32 saddr, __u32 daddr,
 					__u16 sport, __u16 dport);
 extern __u32 secure_tcp_syn_cookie(__u32 saddr, __u32 daddr,
diff -urNp -X dontdiff test-2.6/net/ipv4/tcp_ipv4.c tcpport/net/ipv4/tcp_ipv4.c
--- test-2.6/net/ipv4/tcp_ipv4.c	2004-11-30 16:26:51.000000000 -0800
+++ tcpport/net/ipv4/tcp_ipv4.c	2004-12-03 17:04:26.454562583 -0800
@@ -636,10 +636,18 @@ not_unique:
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
+static int tcp_v4_hash_connect(struct sock *sk, int loopback)
 {
 	unsigned short snum = inet_sk(sk)->num;
  	struct tcp_bind_hashbucket *head;
@@ -647,36 +655,23 @@ static int tcp_v4_hash_connect(struct so
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
+		u32 offset = hint;
 		struct hlist_node *node;
  		struct tcp_tw_bucket *tw = NULL;
 
+		if (!loopback) 
+			offset += connect_port_offset(sk);
+		
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
@@ -684,19 +679,19 @@ static int tcp_v4_hash_connect(struct so
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
@@ -706,22 +701,18 @@ static int tcp_v4_hash_connect(struct so
 
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
@@ -832,7 +823,7 @@ int tcp_v4_connect(struct sock *sk, stru
 	 * complete initialization after this.
 	 */
 	tcp_set_state(sk, TCP_SYN_SENT);
-	err = tcp_v4_hash_connect(sk);
+	err = tcp_v4_hash_connect(sk, rt->rt_flags & RTCF_LOCAL);
 	if (err)
 		goto failure;
 
