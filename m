From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 3/8] udp: secondary hash on (local port, local address)
Date: Sun, 08 Nov 2009 21:17:58 +0100
Message-ID: <4AF72776.8040300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39135 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755166AbZKHUSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 15:18:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extends udp_table to contain a secondary hash table.

socket anchor for this second hash is free, because UDP
doesnt use skc_bind_node : We define an union to hold
both skc_bind_node & a new hlist_nulls_node udp_portaddr_node

udp_lib_get_port() inserts sockets into second hash chain
(additional cost of one atomic op)

udp_lib_unhash() deletes socket from second hash chain
(additional cost of one atomic op)

Note : No spinlock lockdep annotation is needed, because
lock for the secondary hash chain is always get after
lock for primary hash chain.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/udp.h |    1 +
 include/net/sock.h  |    8 ++++++--
 include/net/udp.h   |   22 ++++++++++++++++++++--
 net/ipv4/udp.c      |   31 ++++++++++++++++++++++++++-----
 4 files changed, 53 insertions(+), 9 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 5b4b527..59f0ddf 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -57,6 +57,7 @@ struct udp_sock {
 	struct inet_sock inet;
 #define udp_port_hash		inet.sk.__sk_common.skc_u16hashes[0]
 #define udp_portaddr_hash	inet.sk.__sk_common.skc_u16hashes[1]
+#define udp_portaddr_node	inet.sk.__sk_common.skc_portaddr_node
 	int		 pending;	/* Any pending frames ? */
 	unsigned int	 corkflag;	/* Cork is required */
   	__u16		 encap_type;	/* Is this an Encapsulation socket? */
diff --git a/include/net/sock.h b/include/net/sock.h
index 827366b..3f1a480 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -105,7 +105,7 @@ struct net;
 /**
  *	struct sock_common - minimal network layer representation of sockets
  *	@skc_node: main hash linkage for various protocol lookup tables
- *	@skc_nulls_node: main hash linkage for UDP/UDP-Lite protocol
+ *	@skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
  *	@skc_refcnt: reference count
  *	@skc_tx_queue_mapping: tx queue number for this connection
  *	@skc_hash: hash value used with various protocol lookup tables
@@ -115,6 +115,7 @@ struct net;
  *	@skc_reuse: %SO_REUSEADDR setting
  *	@skc_bound_dev_if: bound device index if != 0
  *	@skc_bind_node: bind hash linkage for various protocol lookup tables
+ *	@skc_portaddr_node: second hash linkage for UDP/UDP-Lite protocol
  *	@skc_prot: protocol handlers inside a network family
  *	@skc_net: reference to the network namespace of this socket
  *
@@ -140,7 +141,10 @@ struct sock_common {
 	volatile unsigned char	skc_state;
 	unsigned char		skc_reuse;
 	int			skc_bound_dev_if;
-	struct hlist_node	skc_bind_node;
+	union {
+		struct hlist_node	skc_bind_node;
+		struct hlist_nulls_node skc_portaddr_node;
+	};
 	struct proto		*skc_prot;
 #ifdef CONFIG_NET_NS
 	struct net	 	*skc_net;
diff --git a/include/net/udp.h b/include/net/udp.h
index 9167281..af41850 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -63,10 +63,19 @@ struct udp_hslot {
 	spinlock_t		lock;
 } __attribute__((aligned(2 * sizeof(long))));
 
+/**
+ *	struct udp_table - UDP table
+ *
+ *	@hash:	hash table, sockets are hashed on (local port)
+ *	@hash2:	hash table, sockets are hashed on (local port, local address)
+ *	@mask:	number of slots in hash tables, minus 1
+ *	@log:	log2(number of slots in hash table)
+ */
 struct udp_table {
 	struct udp_hslot	*hash;
-	unsigned int mask;
-	unsigned int log;
+	struct udp_hslot	*hash2;
+	unsigned int		mask;
+	unsigned int		log;
 };
 extern struct udp_table udp_table;
 extern void udp_table_init(struct udp_table *, const char *);
@@ -75,6 +84,15 @@ static inline struct udp_hslot *udp_hashslot(struct udp_table *table,
 {
 	return &table->hash[udp_hashfn(net, num, table->mask)];
 }
+/*
+ * For secondary hash, net_hash_mix() is performed before calling
+ * udp_hashslot2(), this explains difference with udp_hashslot()
+ */
+static inline struct udp_hslot *udp_hashslot2(struct udp_table *table,
+					      unsigned int hash)
+{
+	return &table->hash2[hash & table->mask];
+}
 
 /* Note: this must match 'valbool' in sock_setsockopt */
 #define UDP_CSUM_NOXMIT		1
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index af72de1..5f04216 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -163,7 +163,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		       int (*saddr_comp)(const struct sock *sk1,
 					 const struct sock *sk2))
 {
-	struct udp_hslot *hslot;
+	struct udp_hslot *hslot, *hslot2;
 	struct udp_table *udptable = sk->sk_prot->h.udp_table;
 	int    error = 1;
 	struct net *net = sock_net(sk);
@@ -222,6 +222,13 @@ found:
 		sk_nulls_add_node_rcu(sk, &hslot->head);
 		hslot->count++;
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+
+		hslot2 = udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);
+		spin_lock(&hslot2->lock);
+		hlist_nulls_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
+					 &hslot2->head);
+		hslot2->count++;
+		spin_unlock(&hslot2->lock);
 	}
 	error = 0;
 fail_unlock:
@@ -1062,14 +1069,22 @@ void udp_lib_unhash(struct sock *sk)
 {
 	if (sk_hashed(sk)) {
 		struct udp_table *udptable = sk->sk_prot->h.udp_table;
-		struct udp_hslot *hslot = udp_hashslot(udptable, sock_net(sk),
-						       udp_sk(sk)->udp_port_hash);
+		struct udp_hslot *hslot, *hslot2;
+
+		hslot  = udp_hashslot(udptable, sock_net(sk),
+				      udp_sk(sk)->udp_port_hash);
+		hslot2 = udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);
 
 		spin_lock_bh(&hslot->lock);
 		if (sk_nulls_del_node_init_rcu(sk)) {
 			hslot->count--;
 			inet_sk(sk)->inet_num = 0;
 			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+
+			spin_lock(&hslot2->lock);
+			hlist_nulls_del_init_rcu(&udp_sk(sk)->udp_portaddr_node);
+			hslot2->count--;
+			spin_unlock(&hslot2->lock);
 		}
 		spin_unlock_bh(&hslot->lock);
 	}
@@ -1857,7 +1872,7 @@ void __init udp_table_init(struct udp_table *table, const char *name)
 
 	if (!CONFIG_BASE_SMALL)
 		table->hash = alloc_large_system_hash(name,
-			sizeof(struct udp_hslot),
+			2 * sizeof(struct udp_hslot),
 			uhash_entries,
 			21, /* one slot per 2 MB */
 			0,
@@ -1869,17 +1884,23 @@ void __init udp_table_init(struct udp_table *table, const char *name)
 	 */
 	if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - 1) {
 		table->hash = kmalloc(UDP_HTABLE_SIZE_MIN *
-				      sizeof(struct udp_hslot), GFP_KERNEL);
+				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
 		if (!table->hash)
 			panic(name);
 		table->log = ilog2(UDP_HTABLE_SIZE_MIN);
 		table->mask = UDP_HTABLE_SIZE_MIN - 1;
 	}
+	table->hash2 = table->hash + (table->mask + 1);
 	for (i = 0; i <= table->mask; i++) {
 		INIT_HLIST_NULLS_HEAD(&table->hash[i].head, i);
 		table->hash[i].count = 0;
 		spin_lock_init(&table->hash[i].lock);
 	}
+	for (i = 0; i <= table->mask; i++) {
+		INIT_HLIST_NULLS_HEAD(&table->hash2[i].head, i);
+		table->hash2[i].count = 0;
+		spin_lock_init(&table->hash2[i].lock);
+	}
 }
 
 void __init udp_init(void)
