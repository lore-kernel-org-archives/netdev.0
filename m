From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Tcp port selection for IPV6.
Date: Thu, 20 Jan 2005 16:45:29 -0800
Message-ID: <20050120164529.6d6a5f0b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        "YOSHIFUJI Hideaki / _$B5HF#1QL@"
 <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch makes TCP over IPV6 select ports the same way the current
TCPv4 code does. It uses a hash function to provide a starting offset
and a free running counter to provide seed.

This changes the port selection semantics to match TCPv4 as well.
If the port is in use but to a different remote address, it will get
reused. It looks like the TCPv6 code was not updated when the TCPv4
code changed. Now the code in ipv4/tcp_ipv4.c and ipv6/tcp_ipv6.c are
almost identical for tcp_hash_connect.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/drivers/char/random.c b/drivers/char/random.c
--- a/drivers/char/random.c	2005-01-18 14:06:54 -08:00
+++ b/drivers/char/random.c	2005-01-18 14:06:54 -08:00
@@ -2283,6 +2283,21 @@
 	return halfMD4Transform(hash, keyptr->secret);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+u32 secure_tcpv6_port_ephemeral(const __u32 *saddr, const __u32 *daddr, __u16 dport)
+{
+	struct keydata *keyptr = get_keyptr();
+	u32 hash[12];
+
+	memcpy(hash, saddr, 16);
+	hash[4] = dport;
+	memcpy(&hash[5],keyptr->secret,sizeof(__u32) * 7);
+
+	return twothirdsMD4Transform(daddr, hash);
+}
+EXPORT_SYMBOL(secure_tcpv6_port_ephemeral);
+#endif
+
 #ifdef CONFIG_SYN_COOKIES
 /*
  * Secure SYN cookie computation. This is the algorithm worked out by
diff -Nru a/include/linux/random.h b/include/linux/random.h
--- a/include/linux/random.h	2005-01-18 14:06:54 -08:00
+++ b/include/linux/random.h	2005-01-18 14:06:54 -08:00
@@ -53,6 +53,8 @@
 
 extern __u32 secure_ip_id(__u32 daddr);
 extern u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport);
+extern u32 secure_tcpv6_port_ephemeral(const __u32 *saddr, const __u32 *daddr, 
+				       __u16 dport);
 extern __u32 secure_tcp_sequence_number(__u32 saddr, __u32 daddr,
 					__u16 sport, __u16 dport);
 extern __u32 secure_tcp_syn_cookie(__u32 saddr, __u32 daddr,
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2005-01-18 14:06:54 -08:00
+++ b/net/ipv4/tcp_ipv4.c	2005-01-18 14:06:54 -08:00
@@ -2663,4 +2663,5 @@
 EXPORT_SYMBOL(sysctl_local_port_range);
 EXPORT_SYMBOL(sysctl_max_syn_backlog);
 EXPORT_SYMBOL(sysctl_tcp_low_latency);
+EXPORT_SYMBOL(sysctl_tcp_tw_reuse);
 
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2005-01-18 14:06:54 -08:00
+++ b/net/ipv6/tcp_ipv6.c	2005-01-18 14:06:54 -08:00
@@ -441,21 +441,22 @@
 	}
 }
 
-static int tcp_v6_check_established(struct sock *sk)
+static int __tcp_v6_check_established(struct sock *sk, __u16 lport,
+				      struct tcp_tw_bucket **twp)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_addr *daddr = &np->rcv_saddr;
 	struct in6_addr *saddr = &np->daddr;
 	int dif = sk->sk_bound_dev_if;
-	u32 ports = TCP_COMBINED_PORTS(inet->dport, inet->num);
+	u32 ports = TCP_COMBINED_PORTS(inet->dport, lport);
 	int hash = tcp_v6_hashfn(daddr, inet->num, saddr, inet->dport);
 	struct tcp_ehash_bucket *head = &tcp_ehash[hash];
 	struct sock *sk2;
 	struct hlist_node *node;
 	struct tcp_tw_bucket *tw;
 
-	write_lock_bh(&head->lock);
+	write_lock(&head->lock);
 
 	/* Check TIME-WAIT sockets first. */
 	sk_for_each(sk2, node, &(head + tcp_ehash_size)->chain) {
@@ -468,7 +469,10 @@
 		   sk2->sk_bound_dev_if == sk->sk_bound_dev_if) {
 			struct tcp_sock *tp = tcp_sk(sk);
 
-			if (tw->tw_ts_recent_stamp) {
+			if (tw->tw_ts_recent_stamp &&
+			    (!twp || (sysctl_tcp_tw_reuse &&
+				      xtime.tv_sec - 
+				      tw->tw_ts_recent_stamp > 1))) {
 				/* See comment in tcp_ipv4.c */
 				tp->write_seq = tw->tw_snd_nxt + 65535 + 2;
 				if (!tp->write_seq)
@@ -494,40 +498,113 @@
 	__sk_add_node(sk, &head->chain);
 	sk->sk_hashent = hash;
 	sock_prot_inc_use(sk->sk_prot);
-	write_unlock_bh(&head->lock);
+	write_unlock(&head->lock);
 
-	if (tw) {
+	if (twp) {
+		*twp = tw;
+		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
+	} else if (tw) {
 		/* Silly. Should hash-dance instead... */
-		local_bh_disable();
 		tcp_tw_deschedule(tw);
 		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
-		local_bh_enable();
 
 		tcp_tw_put(tw);
 	}
 	return 0;
 
 not_unique:
-	write_unlock_bh(&head->lock);
+	write_unlock(&head->lock);
 	return -EADDRNOTAVAIL;
 }
 
-static int tcp_v6_hash_connect(struct sock *sk)
+static inline u32 tcpv6_port_offset(const struct sock *sk)
 {
-	struct tcp_bind_hashbucket *head;
-	struct tcp_bind_bucket *tb;
+	const struct inet_sock *inet = inet_sk(sk);
+	const struct ipv6_pinfo *np = inet6_sk(sk);
 
-	/* XXX */
-	if (inet_sk(sk)->num == 0) { 
-		int err = tcp_v6_get_port(sk, inet_sk(sk)->num);
-		if (err)
-			return err;
-		inet_sk(sk)->sport = htons(inet_sk(sk)->num);
-	}
+	return secure_tcpv6_port_ephemeral(np->rcv_saddr.s6_addr32,
+					   np->daddr.s6_addr32,
+					   inet->dport);
+}
 
-	head = &tcp_bhash[tcp_bhashfn(inet_sk(sk)->num)];
-	tb = tb_head(head);
+static int tcp_v6_hash_connect(struct sock *sk)
+{
+	unsigned short snum = inet_sk(sk)->num;
+ 	struct tcp_bind_hashbucket *head;
+ 	struct tcp_bind_bucket *tb;
+	int ret;
+
+ 	if (!snum) {
+ 		int low = sysctl_local_port_range[0];
+ 		int high = sysctl_local_port_range[1];
+		int range = high - low;
+ 		int i;
+		int port;
+		static u32 hint;
+		u32 offset = hint + tcpv6_port_offset(sk);
+		struct hlist_node *node;
+ 		struct tcp_tw_bucket *tw = NULL;
+
+ 		local_bh_disable();
+		for (i = 1; i <= range; i++) {
+			port = low + (i + offset) % range;
+ 			head = &tcp_bhash[tcp_bhashfn(port)];
+ 			spin_lock(&head->lock);
+
+ 			/* Does not bother with rcv_saddr checks,
+ 			 * because the established check is already
+ 			 * unique enough.
+ 			 */
+			tb_for_each(tb, node, &head->chain) {
+ 				if (tb->port == port) {
+ 					BUG_TRAP(!hlist_empty(&tb->owners));
+ 					if (tb->fastreuse >= 0)
+ 						goto next_port;
+ 					if (!__tcp_v6_check_established(sk,
+									port,
+									&tw))
+ 						goto ok;
+ 					goto next_port;
+ 				}
+ 			}
+
+ 			tb = tcp_bucket_create(head, port);
+ 			if (!tb) {
+ 				spin_unlock(&head->lock);
+ 				break;
+ 			}
+ 			tb->fastreuse = -1;
+ 			goto ok;
+
+ 		next_port:
+ 			spin_unlock(&head->lock);
+ 		}
+ 		local_bh_enable();
+
+ 		return -EADDRNOTAVAIL;
+
+ok:
+		hint += i;
+
+ 		/* Head lock still held and bh's disabled */
+ 		tcp_bind_hash(sk, tb, port);
+		if (sk_unhashed(sk)) {
+ 			inet_sk(sk)->sport = htons(port);
+ 			__tcp_v6_hash(sk);
+ 		}
+ 		spin_unlock(&head->lock);
+
+ 		if (tw) {
+ 			tcp_tw_deschedule(tw);
+ 			tcp_tw_put(tw);
+ 		}
+
+		ret = 0;
+		goto out;
+ 	}
 
+ 	head  = &tcp_bhash[tcp_bhashfn(snum)];
+ 	tb  = tcp_sk(sk)->bind_hash;
 	spin_lock_bh(&head->lock);
 
 	if (sk_head(&tb->owners) == sk && !sk->sk_bind_node.next) {
@@ -535,8 +612,12 @@
 		spin_unlock_bh(&head->lock);
 		return 0;
 	} else {
-		spin_unlock_bh(&head->lock);
-		return tcp_v6_check_established(sk);
+		spin_unlock(&head->lock);
+		/* No definite answer... Walk to established hash table */
+		ret = __tcp_v6_check_established(sk, snum, NULL);
+out:
+		local_bh_enable();
+		return ret;
 	}
 }
 
