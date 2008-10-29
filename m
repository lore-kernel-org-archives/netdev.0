From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 09:23:03 +0100
Message-ID: <49081D67.3050502@cosmosbay.com>
References: <20081008.114527.189056050.davem@davemloft.net>	<49077918.4050706@cosmosbay.com>	<490795FB.2000201@cosmosbay.com> <20081028.220536.183082966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000603020101010505090802"
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:55943 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbYJ2I1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 04:27:45 -0400
In-Reply-To: <20081028.220536.183082966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000603020101010505090802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 28 Oct 2008 23:45:15 +0100
>=20
>> I will submit a new patch serie tomorrow, with :
>>
>> Patch 1 : spinlocks instead of rwlocks, and bug spotted by Christian B=
ell
>>
>> Patch 2 : splited on two parts (2 & 3) , one for IPV4, one for IPV6,=20
>=20
> I very much look forward to this :-)
>=20
> I like these changes and can't wait to add them to net-next-2.6

Thanks David, please find first updated patch 1

Thanks to Christian Bell and Stephen for their usefull review.


[PATCH] udp: introduce struct udp_table and multiple spinlocks

UDP sockets are hashed in a 128 slots hash table.

This hash table is protected by *one* rwlock.

This rwlock is readlocked each time an incoming UDP message is handled.

This rwlock is writelocked each time a socket must be inserted in
hash table (bind time), or deleted from this table (close time)

This is not scalable on SMP machines :

1) Even in read mode, lock() and unlock() are atomic operations and
 must dirty a contended cache line, shared by all cpus.

2) A writer might be starved if many readers are 'in flight'. This can
 happen on a machine with some NIC receiving many UDP messages. User
 process can be delayed a long time at socket creation/dismantle time.

This patch prepares RCU migration, by introducing 'struct udp_table
and struct udp_hslot', and using one spinlock per chain, to reduce
contention on central rwlock.

Introducing one spinlock per chain reduces latencies, for port
randomization on heavily loaded UDP servers. This also speedup
bindings to specific ports.

udp_lib_unhash() was uninlined, becoming to big.

Some cleanups were done to ease review of following patch
(RCUification of UDP Unicast lookups)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/sock.h    |    2
 include/net/udp.h     |   25 ++--
 include/net/udplite.h |    2
 net/ipv4/udp.c        |  209 +++++++++++++++++++++++-----------------
 net/ipv4/udp_impl.h   |    4
 net/ipv4/udplite.c    |   13 +-
 net/ipv6/udp.c        |  112 +++++++++++----------
 net/ipv6/udp_impl.h   |    4
 net/ipv6/udplite.c    |    8 -
 9 files changed, 215 insertions(+), 164 deletions(-)

--------------000603020101010505090802
Content-Type: text/plain;
 name="patch_udp_cleanup1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_udp_cleanup1.patch"

diff --git a/include/net/sock.h b/include/net/sock.h
index d6b750a..d200dfb 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -599,7 +599,7 @@ struct proto {
 
 	union {
 		struct inet_hashinfo	*hashinfo;
-		struct hlist_head	*udp_hash;
+		struct udp_table	*udp_table;
 		struct raw_hashinfo	*raw_hash;
 	} h;
 
diff --git a/include/net/udp.h b/include/net/udp.h
index 1e20509..df2bfe5 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -50,8 +50,15 @@ struct udp_skb_cb {
 };
 #define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
 
-extern struct hlist_head udp_hash[UDP_HTABLE_SIZE];
-extern rwlock_t udp_hash_lock;
+struct udp_hslot {
+	struct hlist_head	head;
+	spinlock_t		lock;
+} __attribute__((aligned(2 * sizeof(long))));
+struct udp_table {
+	struct udp_hslot	hash[UDP_HTABLE_SIZE];
+};
+extern struct udp_table udp_table;
+extern void udp_table_init(struct udp_table *);
 
 
 /* Note: this must match 'valbool' in sock_setsockopt */
@@ -110,15 +117,7 @@ static inline void udp_lib_hash(struct sock *sk)
 	BUG();
 }
 
-static inline void udp_lib_unhash(struct sock *sk)
-{
-	write_lock_bh(&udp_hash_lock);
-	if (sk_del_node_init(sk)) {
-		inet_sk(sk)->num = 0;
-		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
-	}
-	write_unlock_bh(&udp_hash_lock);
-}
+extern void udp_lib_unhash(struct sock *sk);
 
 static inline void udp_lib_close(struct sock *sk, long timeout)
 {
@@ -187,7 +186,7 @@ extern struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 struct udp_seq_afinfo {
 	char			*name;
 	sa_family_t		family;
-	struct hlist_head	*hashtable;
+	struct udp_table	*udp_table;
 	struct file_operations	seq_fops;
 	struct seq_operations	seq_ops;
 };
@@ -196,7 +195,7 @@ struct udp_iter_state {
 	struct seq_net_private  p;
 	sa_family_t		family;
 	int			bucket;
-	struct hlist_head	*hashtable;
+	struct udp_table	*udp_table;
 };
 
 #ifdef CONFIG_PROC_FS
diff --git a/include/net/udplite.h b/include/net/udplite.h
index b76b2e3..afdffe6 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -11,7 +11,7 @@
 #define UDPLITE_RECV_CSCOV   11 /* receiver partial coverage (threshold ) */
 
 extern struct proto 		udplite_prot;
-extern struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
+extern struct udp_table		udplite_table;
 
 /*
  *	Checksum computation is all in software, hence simpler getfrag.
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2095abc..b91cd0a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -104,12 +104,8 @@
 #include <net/xfrm.h>
 #include "udp_impl.h"
 
-/*
- *	Snmp MIB for the UDP layer
- */
-
-struct hlist_head udp_hash[UDP_HTABLE_SIZE];
-DEFINE_RWLOCK(udp_hash_lock);
+struct udp_table udp_table;
+EXPORT_SYMBOL(udp_table);
 
 int sysctl_udp_mem[3] __read_mostly;
 int sysctl_udp_rmem_min __read_mostly;
@@ -123,7 +119,7 @@ atomic_t udp_memory_allocated;
 EXPORT_SYMBOL(udp_memory_allocated);
 
 static int udp_lib_lport_inuse(struct net *net, __u16 num,
-			       const struct hlist_head udptable[],
+			       const struct udp_hslot *hslot,
 			       struct sock *sk,
 			       int (*saddr_comp)(const struct sock *sk1,
 						 const struct sock *sk2))
@@ -131,7 +127,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 	struct sock *sk2;
 	struct hlist_node *node;
 
-	sk_for_each(sk2, node, &udptable[udp_hashfn(net, num)])
+	sk_for_each(sk2, node, &hslot->head)
 		if (net_eq(sock_net(sk2), net)			&&
 		    sk2 != sk					&&
 		    sk2->sk_hash == num				&&
@@ -154,12 +150,11 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		       int (*saddr_comp)(const struct sock *sk1,
 					 const struct sock *sk2 )    )
 {
-	struct hlist_head *udptable = sk->sk_prot->h.udp_hash;
+	struct udp_hslot *hslot;
+	struct udp_table *udptable = sk->sk_prot->h.udp_table;
 	int    error = 1;
 	struct net *net = sock_net(sk);
 
-	write_lock_bh(&udp_hash_lock);
-
 	if (!snum) {
 		int low, high, remaining;
 		unsigned rand;
@@ -171,26 +166,34 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		rand = net_random();
 		snum = first = rand % remaining + low;
 		rand |= 1;
-		while (udp_lib_lport_inuse(net, snum, udptable, sk,
-					   saddr_comp)) {
+		for (;;) {
+			hslot = &udptable->hash[udp_hashfn(net, snum)];
+			spin_lock_bh(&hslot->lock);
+			if (!udp_lib_lport_inuse(net, snum, hslot, sk, saddr_comp))
+				break;
+			spin_unlock_bh(&hslot->lock);
 			do {
 				snum = snum + rand;
 			} while (snum < low || snum > high);
 			if (snum == first)
 				goto fail;
 		}
-	} else if (udp_lib_lport_inuse(net, snum, udptable, sk, saddr_comp))
-		goto fail;
-
+	} else {
+		hslot = &udptable->hash[udp_hashfn(net, snum)];
+		spin_lock_bh(&hslot->lock);
+		if (udp_lib_lport_inuse(net, snum, hslot, sk, saddr_comp))
+			goto fail_unlock;
+	}
 	inet_sk(sk)->num = snum;
 	sk->sk_hash = snum;
 	if (sk_unhashed(sk)) {
-		sk_add_node(sk, &udptable[udp_hashfn(net, snum)]);
+		sk_add_node(sk, &hslot->head);
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	}
 	error = 0;
+fail_unlock:
+	spin_unlock_bh(&hslot->lock);
 fail:
-	write_unlock_bh(&udp_hash_lock);
 	return error;
 }
 
@@ -208,63 +211,73 @@ int udp_v4_get_port(struct sock *sk, unsigned short snum)
 	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal);
 }
 
+static inline int compute_score(struct sock *sk, struct net *net, __be32 saddr,
+			 unsigned short hnum,
+			 __be16 sport, __be32 daddr, __be16 dport, int dif)
+{
+	int score = -1;
+
+	if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
+			!ipv6_only_sock(sk)) {
+		struct inet_sock *inet = inet_sk(sk);
+
+		score = (sk->sk_family == PF_INET ? 1 : 0);
+		if (inet->rcv_saddr) {
+			if (inet->rcv_saddr != daddr)
+				return -1;
+			score += 2;
+		}
+		if (inet->daddr) {
+			if (inet->daddr != saddr)
+				return -1;
+			score += 2;
+		}
+		if (inet->dport) {
+			if (inet->dport != sport)
+				return -1;
+			score += 2;
+		}
+		if (sk->sk_bound_dev_if) {
+			if (sk->sk_bound_dev_if != dif)
+				return -1;
+			score += 2;
+		}
+	}
+	return score;
+}
+
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
 static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 		__be16 sport, __be32 daddr, __be16 dport,
-		int dif, struct hlist_head udptable[])
+		int dif, struct udp_table *udptable)
 {
 	struct sock *sk, *result = NULL;
 	struct hlist_node *node;
 	unsigned short hnum = ntohs(dport);
-	int badness = -1;
-
-	read_lock(&udp_hash_lock);
-	sk_for_each(sk, node, &udptable[udp_hashfn(net, hnum)]) {
-		struct inet_sock *inet = inet_sk(sk);
-
-		if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
-				!ipv6_only_sock(sk)) {
-			int score = (sk->sk_family == PF_INET ? 1 : 0);
-			if (inet->rcv_saddr) {
-				if (inet->rcv_saddr != daddr)
-					continue;
-				score+=2;
-			}
-			if (inet->daddr) {
-				if (inet->daddr != saddr)
-					continue;
-				score+=2;
-			}
-			if (inet->dport) {
-				if (inet->dport != sport)
-					continue;
-				score+=2;
-			}
-			if (sk->sk_bound_dev_if) {
-				if (sk->sk_bound_dev_if != dif)
-					continue;
-				score+=2;
-			}
-			if (score == 9) {
-				result = sk;
-				break;
-			} else if (score > badness) {
-				result = sk;
-				badness = score;
-			}
-		}
+	unsigned int hash = udp_hashfn(net, hnum);
+	struct udp_hslot *hslot = &udptable->hash[hash];
+	int score, badness = -1;
+
+	spin_lock(&hslot->lock);
+	sk_for_each(sk, node, &hslot->head) {
+		score = compute_score(sk, net, saddr, hnum, sport,
+				      daddr, dport, dif);
+		if (score > badness) {
+			result = sk;
+			badness = score;
+ 		}
 	}
 	if (result)
 		sock_hold(result);
-	read_unlock(&udp_hash_lock);
+	spin_unlock(&hslot->lock);
 	return result;
 }
 
 static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 						 __be16 sport, __be16 dport,
-						 struct hlist_head udptable[])
+						 struct udp_table *udptable)
 {
 	struct sock *sk;
 	const struct iphdr *iph = ip_hdr(skb);
@@ -280,7 +293,7 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif)
 {
-	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif, udp_hash);
+	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif, &udp_table);
 }
 EXPORT_SYMBOL_GPL(udp4_lib_lookup);
 
@@ -323,7 +336,7 @@ found:
  * to find the appropriate port.
  */
 
-void __udp4_lib_err(struct sk_buff *skb, u32 info, struct hlist_head udptable[])
+void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 {
 	struct inet_sock *inet;
 	struct iphdr *iph = (struct iphdr*)skb->data;
@@ -392,7 +405,7 @@ out:
 
 void udp_err(struct sk_buff *skb, u32 info)
 {
-	__udp4_lib_err(skb, info, udp_hash);
+	__udp4_lib_err(skb, info, &udp_table);
 }
 
 /*
@@ -933,6 +946,21 @@ int udp_disconnect(struct sock *sk, int flags)
 	return 0;
 }
 
+void udp_lib_unhash(struct sock *sk)
+{
+	struct udp_table *udptable = sk->sk_prot->h.udp_table;
+	unsigned int hash = udp_hashfn(sock_net(sk), sk->sk_hash);
+	struct udp_hslot *hslot = &udptable->hash[hash];
+
+	spin_lock(&hslot->lock);
+	if (sk_del_node_init(sk)) {
+		inet_sk(sk)->num = 0;
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+	}
+	spin_unlock(&hslot->lock);
+}
+EXPORT_SYMBOL(udp_lib_unhash);
+
 static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int is_udplite = IS_UDPLITE(sk);
@@ -1071,13 +1099,14 @@ drop:
 static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 				    struct udphdr  *uh,
 				    __be32 saddr, __be32 daddr,
-				    struct hlist_head udptable[])
+				    struct udp_table *udptable)
 {
 	struct sock *sk;
+	struct udp_hslot *hslot = &udptable->hash[udp_hashfn(net, ntohs(uh->dest))];
 	int dif;
 
-	read_lock(&udp_hash_lock);
-	sk = sk_head(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
+	spin_lock(&hslot->lock);
+	sk = sk_head(&hslot->head);
 	dif = skb->dev->ifindex;
 	sk = udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (sk) {
@@ -1102,7 +1131,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		} while (sknext);
 	} else
 		kfree_skb(skb);
-	read_unlock(&udp_hash_lock);
+	spin_unlock(&hslot->lock);
 	return 0;
 }
 
@@ -1148,7 +1177,7 @@ static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
  *	All we need to do is get the socket, and then do a checksum.
  */
 
-int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
+int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		   int proto)
 {
 	struct sock *sk;
@@ -1246,7 +1275,7 @@ drop:
 
 int udp_rcv(struct sk_buff *skb)
 {
-	return __udp4_lib_rcv(skb, udp_hash, IPPROTO_UDP);
+	return __udp4_lib_rcv(skb, &udp_table, IPPROTO_UDP);
 }
 
 void udp_destroy_sock(struct sock *sk)
@@ -1488,7 +1517,7 @@ struct proto udp_prot = {
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp_sock),
-	.h.udp_hash	   = udp_hash,
+	.h.udp_table	   = &udp_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
@@ -1498,20 +1527,23 @@ struct proto udp_prot = {
 /* ------------------------------------------------------------------------ */
 #ifdef CONFIG_PROC_FS
 
-static struct sock *udp_get_first(struct seq_file *seq)
+static struct sock *udp_get_first(struct seq_file *seq, int start)
 {
 	struct sock *sk;
 	struct udp_iter_state *state = seq->private;
 	struct net *net = seq_file_net(seq);
 
-	for (state->bucket = 0; state->bucket < UDP_HTABLE_SIZE; ++state->bucket) {
+	for (state->bucket = start; state->bucket < UDP_HTABLE_SIZE; ++state->bucket) {
 		struct hlist_node *node;
-		sk_for_each(sk, node, state->hashtable + state->bucket) {
+		struct udp_hslot *hslot = &state->udp_table->hash[state->bucket];
+		spin_lock_bh(&hslot->lock);
+		sk_for_each(sk, node, &hslot->head) {
 			if (!net_eq(sock_net(sk), net))
 				continue;
 			if (sk->sk_family == state->family)
 				goto found;
 		}
+		spin_unlock_bh(&hslot->lock);
 	}
 	sk = NULL;
 found:
@@ -1525,20 +1557,18 @@ static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
 
 	do {
 		sk = sk_next(sk);
-try_again:
-		;
 	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family != state->family));
 
-	if (!sk && ++state->bucket < UDP_HTABLE_SIZE) {
-		sk = sk_head(state->hashtable + state->bucket);
-		goto try_again;
+	if (!sk) {
+		spin_unlock(&state->udp_table->hash[state->bucket].lock);
+		return udp_get_first(seq, state->bucket + 1);
 	}
 	return sk;
 }
 
 static struct sock *udp_get_idx(struct seq_file *seq, loff_t pos)
 {
-	struct sock *sk = udp_get_first(seq);
+	struct sock *sk = udp_get_first(seq, 0);
 
 	if (sk)
 		while (pos && (sk = udp_get_next(seq, sk)) != NULL)
@@ -1547,9 +1577,7 @@ static struct sock *udp_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *udp_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(udp_hash_lock)
 {
-	read_lock(&udp_hash_lock);
 	return *pos ? udp_get_idx(seq, *pos-1) : SEQ_START_TOKEN;
 }
 
@@ -1567,9 +1595,11 @@ static void *udp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void udp_seq_stop(struct seq_file *seq, void *v)
-	__releases(udp_hash_lock)
 {
-	read_unlock(&udp_hash_lock);
+	struct udp_iter_state *state = seq->private;
+
+	if (state->bucket < UDP_HTABLE_SIZE)
+		spin_unlock_bh(&state->udp_table->hash[state->bucket].lock);
 }
 
 static int udp_seq_open(struct inode *inode, struct file *file)
@@ -1585,7 +1615,7 @@ static int udp_seq_open(struct inode *inode, struct file *file)
 
 	s = ((struct seq_file *)file->private_data)->private;
 	s->family		= afinfo->family;
-	s->hashtable		= afinfo->hashtable;
+	s->udp_table		= afinfo->udp_table;
 	return err;
 }
 
@@ -1657,7 +1687,7 @@ int udp4_seq_show(struct seq_file *seq, void *v)
 static struct udp_seq_afinfo udp4_seq_afinfo = {
 	.name		= "udp",
 	.family		= AF_INET,
-	.hashtable	= udp_hash,
+	.udp_table	= &udp_table,
 	.seq_fops	= {
 		.owner	=	THIS_MODULE,
 	},
@@ -1692,10 +1722,21 @@ void udp4_proc_exit(void)
 }
 #endif /* CONFIG_PROC_FS */
 
+void __init udp_table_init(struct udp_table *table)
+{
+	int i;
+	
+	for (i = 0; i < UDP_HTABLE_SIZE; i++) {
+		INIT_HLIST_HEAD(&table->hash[i].head);
+		spin_lock_init(&table->hash[i].lock);
+	}
+}
+
 void __init udp_init(void)
 {
 	unsigned long limit;
 
+	udp_table_init(&udp_table);
 	/* Set the pressure threshold up by the same strategy of TCP. It is a
 	 * fraction of global memory that is up to 1/2 at 256 MB, decreasing
 	 * toward zero with the amount of memory, with a floor of 128 pages.
@@ -1712,8 +1753,6 @@ void __init udp_init(void)
 }
 
 EXPORT_SYMBOL(udp_disconnect);
-EXPORT_SYMBOL(udp_hash);
-EXPORT_SYMBOL(udp_hash_lock);
 EXPORT_SYMBOL(udp_ioctl);
 EXPORT_SYMBOL(udp_prot);
 EXPORT_SYMBOL(udp_sendmsg);
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index 2e9bad2..9f4a616 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -5,8 +5,8 @@
 #include <net/protocol.h>
 #include <net/inet_common.h>
 
-extern int  	__udp4_lib_rcv(struct sk_buff *, struct hlist_head [], int );
-extern void 	__udp4_lib_err(struct sk_buff *, u32, struct hlist_head []);
+extern int  	__udp4_lib_rcv(struct sk_buff *, struct udp_table *, int );
+extern void 	__udp4_lib_err(struct sk_buff *, u32, struct udp_table *);
 
 extern int	udp_v4_get_port(struct sock *sk, unsigned short snum);
 
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 3c80796..d8ea8e5 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -12,16 +12,17 @@
  */
 #include "udp_impl.h"
 
-struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
+struct udp_table 	udplite_table;
+EXPORT_SYMBOL(udplite_table);
 
 static int udplite_rcv(struct sk_buff *skb)
 {
-	return __udp4_lib_rcv(skb, udplite_hash, IPPROTO_UDPLITE);
+	return __udp4_lib_rcv(skb, &udplite_table, IPPROTO_UDPLITE);
 }
 
 static void udplite_err(struct sk_buff *skb, u32 info)
 {
-	__udp4_lib_err(skb, info, udplite_hash);
+	__udp4_lib_err(skb, info, &udplite_table);
 }
 
 static	struct net_protocol udplite_protocol = {
@@ -50,7 +51,7 @@ struct proto 	udplite_prot = {
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
 	.obj_size	   = sizeof(struct udp_sock),
-	.h.udp_hash	   = udplite_hash,
+	.h.udp_table	   = &udplite_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
@@ -71,7 +72,7 @@ static struct inet_protosw udplite4_protosw = {
 static struct udp_seq_afinfo udplite4_seq_afinfo = {
 	.name		= "udplite",
 	.family		= AF_INET,
-	.hashtable	= udplite_hash,
+	.udp_table 	= &udplite_table,
 	.seq_fops	= {
 		.owner	=	THIS_MODULE,
 	},
@@ -108,6 +109,7 @@ static inline int udplite4_proc_init(void)
 
 void __init udplite4_register(void)
 {
+	udp_table_init(&udplite_table);
 	if (proto_register(&udplite_prot, 1))
 		goto out_register_err;
 
@@ -126,5 +128,4 @@ out_register_err:
 	printk(KERN_CRIT "%s: Cannot add UDP-Lite protocol.\n", __func__);
 }
 
-EXPORT_SYMBOL(udplite_hash);
 EXPORT_SYMBOL(udplite_prot);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e51da8c..ccee724 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -54,62 +54,73 @@ int udp_v6_get_port(struct sock *sk, unsigned short snum)
 	return udp_lib_get_port(sk, snum, ipv6_rcv_saddr_equal);
 }
 
+static inline int compute_score(struct sock *sk, struct net *net,
+				unsigned short hnum,
+				struct in6_addr *saddr, __be16 sport,
+				struct in6_addr *daddr, __be16 dport,
+				int dif)
+{
+	int score = -1;
+
+	if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
+			sk->sk_family == PF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
+
+		score = 0;
+		if (inet->dport) {
+			if (inet->dport != sport)
+				return -1;
+			score++;
+		}
+		if (!ipv6_addr_any(&np->rcv_saddr)) {
+			if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
+				return -1;
+			score++;
+		}
+		if (!ipv6_addr_any(&np->daddr)) {
+			if (!ipv6_addr_equal(&np->daddr, saddr))
+				return -1;
+			score++;
+		}
+		if (sk->sk_bound_dev_if) {
+			if (sk->sk_bound_dev_if != dif)
+				return -1;
+			score++;
+		}
+	}
+	return score;
+}
+
 static struct sock *__udp6_lib_lookup(struct net *net,
 				      struct in6_addr *saddr, __be16 sport,
 				      struct in6_addr *daddr, __be16 dport,
-				      int dif, struct hlist_head udptable[])
+				      int dif, struct udp_table *udptable)
 {
 	struct sock *sk, *result = NULL;
 	struct hlist_node *node;
 	unsigned short hnum = ntohs(dport);
-	int badness = -1;
-
-	read_lock(&udp_hash_lock);
-	sk_for_each(sk, node, &udptable[udp_hashfn(net, hnum)]) {
-		struct inet_sock *inet = inet_sk(sk);
-
-		if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
-				sk->sk_family == PF_INET6) {
-			struct ipv6_pinfo *np = inet6_sk(sk);
-			int score = 0;
-			if (inet->dport) {
-				if (inet->dport != sport)
-					continue;
-				score++;
-			}
-			if (!ipv6_addr_any(&np->rcv_saddr)) {
-				if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
-					continue;
-				score++;
-			}
-			if (!ipv6_addr_any(&np->daddr)) {
-				if (!ipv6_addr_equal(&np->daddr, saddr))
-					continue;
-				score++;
-			}
-			if (sk->sk_bound_dev_if) {
-				if (sk->sk_bound_dev_if != dif)
-					continue;
-				score++;
-			}
-			if (score == 4) {
-				result = sk;
-				break;
-			} else if (score > badness) {
-				result = sk;
-				badness = score;
-			}
+	unsigned int hash = udp_hashfn(net, hnum);
+	struct udp_hslot *hslot = &udptable->hash[hash];
+	int score, badness = -1;
+
+	spin_lock(&hslot->lock);
+	sk_for_each(sk, node, &hslot->head) {
+		score = compute_score(sk, net, hnum, saddr, sport, daddr, dport, dif);
+		if (score > badness) {
+			result = sk;
+			badness = score;
 		}
 	}
 	if (result)
 		sock_hold(result);
-	read_unlock(&udp_hash_lock);
+	spin_unlock(&hslot->lock);
 	return result;
 }
 
 static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 					  __be16 sport, __be16 dport,
-					  struct hlist_head udptable[])
+					  struct udp_table *udptable)
 {
 	struct sock *sk;
 	struct ipv6hdr *iph = ipv6_hdr(skb);
@@ -239,7 +250,7 @@ csum_copy_err:
 
 void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		    int type, int code, int offset, __be32 info,
-		    struct hlist_head udptable[]                    )
+		    struct udp_table *udptable)
 {
 	struct ipv6_pinfo *np;
 	struct ipv6hdr *hdr = (struct ipv6hdr*)skb->data;
@@ -275,7 +286,7 @@ static __inline__ void udpv6_err(struct sk_buff *skb,
 				 struct inet6_skb_parm *opt, int type,
 				 int code, int offset, __be32 info     )
 {
-	__udp6_lib_err(skb, opt, type, code, offset, info, udp_hash);
+	__udp6_lib_err(skb, opt, type, code, offset, info, &udp_table);
 }
 
 int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
@@ -374,14 +385,15 @@ static struct sock *udp_v6_mcast_next(struct sock *sk,
  */
 static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		struct in6_addr *saddr, struct in6_addr *daddr,
-		struct hlist_head udptable[])
+		struct udp_table *udptable)
 {
 	struct sock *sk, *sk2;
 	const struct udphdr *uh = udp_hdr(skb);
+	struct udp_hslot *hslot = &udptable->hash[udp_hashfn(net, ntohs(uh->dest))];
 	int dif;
 
-	read_lock(&udp_hash_lock);
-	sk = sk_head(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
+	spin_lock(&hslot->lock);
+	sk = sk_head(&hslot->head);
 	dif = inet6_iif(skb);
 	sk = udp_v6_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (!sk) {
@@ -409,7 +421,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		sk_add_backlog(sk, skb);
 	bh_unlock_sock(sk);
 out:
-	read_unlock(&udp_hash_lock);
+	spin_unlock(&hslot->lock);
 	return 0;
 }
 
@@ -447,7 +459,7 @@ static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh,
 	return 0;
 }
 
-int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
+int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		   int proto)
 {
 	struct sock *sk;
@@ -544,7 +556,7 @@ discard:
 
 static __inline__ int udpv6_rcv(struct sk_buff *skb)
 {
-	return __udp6_lib_rcv(skb, udp_hash, IPPROTO_UDP);
+	return __udp6_lib_rcv(skb, &udp_table, IPPROTO_UDP);
 }
 
 /*
@@ -1008,7 +1020,7 @@ int udp6_seq_show(struct seq_file *seq, void *v)
 static struct udp_seq_afinfo udp6_seq_afinfo = {
 	.name		= "udp6",
 	.family		= AF_INET6,
-	.hashtable	= udp_hash,
+	.udp_table	= &udp_table,
 	.seq_fops	= {
 		.owner	=	THIS_MODULE,
 	},
@@ -1050,7 +1062,7 @@ struct proto udpv6_prot = {
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp6_sock),
-	.h.udp_hash	   = udp_hash,
+	.h.udp_table	   = &udp_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index 92dd7da..2377920 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -7,9 +7,9 @@
 #include <net/inet_common.h>
 #include <net/transp_v6.h>
 
-extern int  	__udp6_lib_rcv(struct sk_buff *, struct hlist_head [], int );
+extern int  	__udp6_lib_rcv(struct sk_buff *, struct udp_table *, int );
 extern void 	__udp6_lib_err(struct sk_buff *, struct inet6_skb_parm *,
-			       int , int , int , __be32 , struct hlist_head []);
+			       int , int , int , __be32 , struct udp_table *);
 
 extern int	udp_v6_get_port(struct sock *sk, unsigned short snum);
 
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 3cd1a1a..f1e892a 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -15,14 +15,14 @@
 
 static int udplitev6_rcv(struct sk_buff *skb)
 {
-	return __udp6_lib_rcv(skb, udplite_hash, IPPROTO_UDPLITE);
+	return __udp6_lib_rcv(skb, &udplite_table, IPPROTO_UDPLITE);
 }
 
 static void udplitev6_err(struct sk_buff *skb,
 			  struct inet6_skb_parm *opt,
 			  int type, int code, int offset, __be32 info)
 {
-	__udp6_lib_err(skb, opt, type, code, offset, info, udplite_hash);
+	__udp6_lib_err(skb, opt, type, code, offset, info, &udplite_table);
 }
 
 static struct inet6_protocol udplitev6_protocol = {
@@ -49,7 +49,7 @@ struct proto udplitev6_prot = {
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v6_get_port,
 	.obj_size	   = sizeof(struct udp6_sock),
-	.h.udp_hash	   = udplite_hash,
+	.h.udp_table	   = &udplite_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
@@ -95,7 +95,7 @@ void udplitev6_exit(void)
 static struct udp_seq_afinfo udplite6_seq_afinfo = {
 	.name		= "udplite6",
 	.family		= AF_INET6,
-	.hashtable	= udplite_hash,
+	.udp_table	= &udplite_table,
 	.seq_fops	= {
 		.owner	=	THIS_MODULE,
 	},

--------------000603020101010505090802--
