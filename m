From: Corey Minyard <minyard@acm.org>
Subject: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Mon, 06 Oct 2008 13:50:26 -0500
Message-ID: <20081006185026.GA10383@minyard.local>
Reply-To: minyard@acm.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, paulmck@linux.vnet.ibm.com
To: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms172071pub.verizon.net ([206.46.172.71]:57133 "EHLO
	vms172071pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755265AbYJFTua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 15:50:30 -0400
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the UDP hash lock from an rwlock to RCU.

Signed-off-by: Corey Minyard <cminyard@mvista.com>
---
 include/net/udp.h |    9 +++++----
 net/ipv4/udp.c    |   47 +++++++++++++++++++++++++++--------------------
 net/ipv6/udp.c    |   17 +++++++++--------
 3 files changed, 41 insertions(+), 32 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index addcdc6..35aa104 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -51,7 +51,7 @@ struct udp_skb_cb {
 #define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
 
 extern struct hlist_head udp_hash[UDP_HTABLE_SIZE];
-extern rwlock_t udp_hash_lock;
+extern spinlock_t udp_hash_wlock;
 
 
 /* Note: this must match 'valbool' in sock_setsockopt */
@@ -112,12 +112,13 @@ static inline void udp_lib_hash(struct sock *sk)
 
 static inline void udp_lib_unhash(struct sock *sk)
 {
-	write_lock_bh(&udp_hash_lock);
-	if (sk_del_node_init(sk)) {
+	spin_lock_bh(&udp_hash_wlock);
+	if (sk_del_node_init_rcu(sk)) {
 		inet_sk(sk)->num = 0;
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 	}
-	write_unlock_bh(&udp_hash_lock);
+	spin_unlock_bh(&udp_hash_wlock);
+	synchronize_rcu();
 }
 
 static inline void udp_lib_close(struct sock *sk, long timeout)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 57e26fa..1b65cb6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -112,7 +112,8 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6) __read_mostly;
 EXPORT_SYMBOL(udp_stats_in6);
 
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
-DEFINE_RWLOCK(udp_hash_lock);
+DEFINE_SPINLOCK(udp_hash_wlock);
+EXPORT_SYMBOL(udp_hash_wlock);
 
 int sysctl_udp_mem[3] __read_mostly;
 int sysctl_udp_rmem_min __read_mostly;
@@ -155,7 +156,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 	int    error = 1;
 	struct net *net = sock_net(sk);
 
-	write_lock_bh(&udp_hash_lock);
+	spin_lock_bh(&udp_hash_wlock);
 
 	if (!snum) {
 		int i, low, high, remaining;
@@ -225,12 +226,12 @@ gotit:
 	sk->sk_hash = snum;
 	if (sk_unhashed(sk)) {
 		head = &udptable[udp_hashfn(net, snum)];
-		sk_add_node(sk, head);
+		sk_add_node_rcu(sk, head);
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	}
 	error = 0;
 fail:
-	write_unlock_bh(&udp_hash_lock);
+	spin_unlock_bh(&udp_hash_wlock);
 	return error;
 }
 
@@ -260,8 +261,8 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	unsigned short hnum = ntohs(dport);
 	int badness = -1;
 
-	read_lock(&udp_hash_lock);
-	sk_for_each(sk, node, &udptable[udp_hashfn(net, hnum)]) {
+	rcu_read_lock();
+	sk_for_each_rcu(sk, node, &udptable[udp_hashfn(net, hnum)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
 		if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
@@ -296,9 +297,17 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 			}
 		}
 	}
+	/*
+	 * Note that this is safe, even with an RCU lock.
+	 * udp_lib_unhash() is the removal function, it calls
+	 * synchronize_rcu() and the socket counter cannot go to
+	 * zero until it returns.  So if we increment it inside the
+	 * RCU read lock, it should never go to zero and then be
+	 * incremented again.
+	 */
 	if (result)
 		sock_hold(result);
-	read_unlock(&udp_hash_lock);
+	rcu_read_unlock();
 	return result;
 }
 
@@ -311,7 +320,7 @@ static inline struct sock *udp_v4_mcast_next(struct sock *sk,
 	struct sock *s = sk;
 	unsigned short hnum = ntohs(loc_port);
 
-	sk_for_each_from(s, node) {
+	sk_for_each_from_rcu(s, node) {
 		struct inet_sock *inet = inet_sk(s);
 
 		if (s->sk_hash != hnum					||
@@ -1094,8 +1103,8 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	struct sock *sk;
 	int dif;
 
-	read_lock(&udp_hash_lock);
-	sk = sk_head(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
+	rcu_read_lock();
+	sk = sk_head_rcu(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
 	dif = skb->dev->ifindex;
 	sk = udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (sk) {
@@ -1104,8 +1113,9 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		do {
 			struct sk_buff *skb1 = skb;
 
-			sknext = udp_v4_mcast_next(sk_next(sk), uh->dest, daddr,
-						   uh->source, saddr, dif);
+			sknext = udp_v4_mcast_next(sk_next_rcu(sk), uh->dest,
+						   daddr, uh->source, saddr,
+						   dif);
 			if (sknext)
 				skb1 = skb_clone(skb, GFP_ATOMIC);
 
@@ -1120,7 +1130,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		} while (sknext);
 	} else
 		kfree_skb(skb);
-	read_unlock(&udp_hash_lock);
+	rcu_read_unlock();
 	return 0;
 }
 
@@ -1543,13 +1553,13 @@ static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
 	struct net *net = seq_file_net(seq);
 
 	do {
-		sk = sk_next(sk);
+		sk = sk_next_rcu(sk);
 try_again:
 		;
 	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family != state->family));
 
 	if (!sk && ++state->bucket < UDP_HTABLE_SIZE) {
-		sk = sk_head(state->hashtable + state->bucket);
+		sk = sk_head_rcu(state->hashtable + state->bucket);
 		goto try_again;
 	}
 	return sk;
@@ -1566,9 +1576,8 @@ static struct sock *udp_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *udp_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(udp_hash_lock)
 {
-	read_lock(&udp_hash_lock);
+	rcu_read_lock();
 	return *pos ? udp_get_idx(seq, *pos-1) : SEQ_START_TOKEN;
 }
 
@@ -1586,9 +1595,8 @@ static void *udp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void udp_seq_stop(struct seq_file *seq, void *v)
-	__releases(udp_hash_lock)
 {
-	read_unlock(&udp_hash_lock);
+	rcu_read_unlock();
 }
 
 static int udp_seq_open(struct inode *inode, struct file *file)
@@ -1732,7 +1740,6 @@ void __init udp_init(void)
 
 EXPORT_SYMBOL(udp_disconnect);
 EXPORT_SYMBOL(udp_hash);
-EXPORT_SYMBOL(udp_hash_lock);
 EXPORT_SYMBOL(udp_ioctl);
 EXPORT_SYMBOL(udp_prot);
 EXPORT_SYMBOL(udp_sendmsg);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a6aecf7..b807de7 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -64,8 +64,8 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 	unsigned short hnum = ntohs(dport);
 	int badness = -1;
 
-	read_lock(&udp_hash_lock);
-	sk_for_each(sk, node, &udptable[udp_hashfn(net, hnum)]) {
+	rcu_read_lock();
+	sk_for_each_rcu(sk, node, &udptable[udp_hashfn(net, hnum)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
 		if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
@@ -101,9 +101,10 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 			}
 		}
 	}
+	/* See comment in __udp4_lib_lookup on why this is safe. */
 	if (result)
 		sock_hold(result);
-	read_unlock(&udp_hash_lock);
+	rcu_read_unlock();
 	return result;
 }
 
@@ -322,7 +323,7 @@ static struct sock *udp_v6_mcast_next(struct sock *sk,
 	struct sock *s = sk;
 	unsigned short num = ntohs(loc_port);
 
-	sk_for_each_from(s, node) {
+	sk_for_each_from_rcu(s, node) {
 		struct inet_sock *inet = inet_sk(s);
 
 		if (sock_net(s) != sock_net(sk))
@@ -365,8 +366,8 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	const struct udphdr *uh = udp_hdr(skb);
 	int dif;
 
-	read_lock(&udp_hash_lock);
-	sk = sk_head(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
+	rcu_read_lock();
+	sk = sk_head_rcu(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
 	dif = inet6_iif(skb);
 	sk = udp_v6_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (!sk) {
@@ -375,7 +376,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	}
 
 	sk2 = sk;
-	while ((sk2 = udp_v6_mcast_next(sk_next(sk2), uh->dest, daddr,
+	while ((sk2 = udp_v6_mcast_next(sk_next_rcu(sk2), uh->dest, daddr,
 					uh->source, saddr, dif))) {
 		struct sk_buff *buff = skb_clone(skb, GFP_ATOMIC);
 		if (buff) {
@@ -394,7 +395,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		sk_add_backlog(sk, skb);
 	bh_unlock_sock(sk);
 out:
-	read_unlock(&udp_hash_lock);
+	rcu_read_unlock();
 	return 0;
 }
 
-- 
1.5.6.5

