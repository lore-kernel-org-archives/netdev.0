From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] udp: dynamically size hash tables at boot time
Date: Wed, 07 Oct 2009 12:37:59 +0200
Message-ID: <4ACC6F87.1050306@gmail.com>
References: <4ACBE3E7.60404@hp.com>	<4ACC0CDE.1020907@gmail.com>	<4ACC1C73.1010506@gmail.com> <20091006.222935.231081303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56125 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445AbZJGKil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:38:41 -0400
In-Reply-To: <20091006.222935.231081303.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
>=20
> That's incredible that it's been that low for so long :-)
>=20
> Bug please, dynamically size this thing, maybe with a cap of say 64K
> to start with.  If you don't have time for it I'll take care of this.

Here we are.

Thank you

[PATCH] udp: dynamically size hash tables at boot time

UDP_HTABLE_SIZE was initialy defined to 128, which is a bit small for s=
everal setups.

4000 active UDP sockets -> 32 sockets per chain in average. An incoming=
 frame
has to lookup all sockets to find best match, so long chains hurt laten=
cy.

Instead of a fixed size hash table that cant be perfect for every needs=
,
let UDP stack choose its table size at boot time like tcp/ip route,
using alloc_large_system_hash() helper

Add an optional boot parameter, uhash_entries=3Dx so that an admin can =
force a size
between 256 and 65536 if needed, like thash_entries and rhash_entries.

dmesg logs two new lines :
[    0.647039] UDP hash table entries: 512 (order: 0, 4096 bytes)
[    0.647099] UDP Lite hash table entries: 512 (order: 0, 4096 bytes)


Maximal size on 64bit arches would be 65536 slots, ie 1 MBytes for non =
debugging spinlocks.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/kernel-parameters.txt |    3
 include/linux/udp.h                 |    6 -
 include/net/udp.h                   |   13 ++-
 net/ipv4/udp.c                      |   91 ++++++++++++++++++--------
 net/ipv4/udplite.c                  |    4 -
 net/ipv6/udp.c                      |    6 -
 6 files changed, 87 insertions(+), 36 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel=
-parameters.txt
index 6fa7292..02df20b 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2589,6 +2589,9 @@ and is between 256 and 4096 characters. It is def=
ined in the file
 	uart6850=3D	[HW,OSS]
 			Format: <io>,<irq>
=20
+	uhash_entries=3D	[KNL,NET]
+			Set number of hash buckets for UDP/UDP-Lite connections
+
 	uhci-hcd.ignore_oc=3D
 			[USB] Ignore overcurrent events (default N).
 			Some badly-designed motherboards generate lots of
diff --git a/include/linux/udp.h b/include/linux/udp.h
index 0cf5c4c..832361e 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -45,11 +45,11 @@ static inline struct udphdr *udp_hdr(const struct s=
k_buff *skb)
 	return (struct udphdr *)skb_transport_header(skb);
 }
=20
-#define UDP_HTABLE_SIZE		128
+#define UDP_HTABLE_SIZE_MIN		(CONFIG_BASE_SMALL ? 128 : 256)
=20
-static inline int udp_hashfn(struct net *net, const unsigned num)
+static inline int udp_hashfn(struct net *net, unsigned num, unsigned m=
ask)
 {
-	return (num + net_hash_mix(net)) & (UDP_HTABLE_SIZE - 1);
+	return (num + net_hash_mix(net)) & mask;
 }
=20
 struct udp_sock {
diff --git a/include/net/udp.h b/include/net/udp.h
index f98abd2..22aa2e7 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -54,12 +54,19 @@ struct udp_hslot {
 	struct hlist_nulls_head	head;
 	spinlock_t		lock;
 } __attribute__((aligned(2 * sizeof(long))));
+
 struct udp_table {
-	struct udp_hslot	hash[UDP_HTABLE_SIZE];
+	struct udp_hslot	*hash;
+	unsigned int mask;
+	unsigned int log;
 };
 extern struct udp_table udp_table;
-extern void udp_table_init(struct udp_table *);
-
+extern void udp_table_init(struct udp_table *, const char *);
+static inline struct udp_hslot *udp_hashslot(struct udp_table *table,
+					     struct net *net, unsigned num)
+{
+	return &table->hash[udp_hashfn(net, num, table->mask)];
+}
=20
 /* Note: this must match 'valbool' in sock_setsockopt */
 #define UDP_CSUM_NOXMIT		1
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6ec6a8a..194bcdc 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -106,7 +106,7 @@
 #include <net/xfrm.h>
 #include "udp_impl.h"
=20
-struct udp_table udp_table;
+struct udp_table udp_table __read_mostly;
 EXPORT_SYMBOL(udp_table);
=20
 int sysctl_udp_mem[3] __read_mostly;
@@ -121,14 +121,16 @@ EXPORT_SYMBOL(sysctl_udp_wmem_min);
 atomic_t udp_memory_allocated;
 EXPORT_SYMBOL(udp_memory_allocated);
=20
-#define PORTS_PER_CHAIN (65536 / UDP_HTABLE_SIZE)
+#define MAX_UDP_PORTS 65536
+#define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
=20
 static int udp_lib_lport_inuse(struct net *net, __u16 num,
 			       const struct udp_hslot *hslot,
 			       unsigned long *bitmap,
 			       struct sock *sk,
 			       int (*saddr_comp)(const struct sock *sk1,
-						 const struct sock *sk2))
+						 const struct sock *sk2),
+			       unsigned int log)
 {
 	struct sock *sk2;
 	struct hlist_nulls_node *node;
@@ -142,8 +144,7 @@ static int udp_lib_lport_inuse(struct net *net, __u=
16 num,
 			|| sk2->sk_bound_dev_if =3D=3D sk->sk_bound_dev_if) &&
 		    (*saddr_comp)(sk, sk2)) {
 			if (bitmap)
-				__set_bit(sk2->sk_hash / UDP_HTABLE_SIZE,
-					  bitmap);
+				__set_bit(sk2->sk_hash >> log, bitmap);
 			else
 				return 1;
 		}
@@ -180,13 +181,15 @@ int udp_lib_get_port(struct sock *sk, unsigned sh=
ort snum,
 		/*
 		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
 		 */
-		rand =3D (rand | 1) * UDP_HTABLE_SIZE;
-		for (last =3D first + UDP_HTABLE_SIZE; first !=3D last; first++) {
-			hslot =3D &udptable->hash[udp_hashfn(net, first)];
+		rand =3D (rand | 1) * (udptable->mask + 1);
+		for (last =3D first + udptable->mask + 1;
+		     first !=3D last;
+		     first++) {
+			hslot =3D udp_hashslot(udptable, net, first);
 			bitmap_zero(bitmap, PORTS_PER_CHAIN);
 			spin_lock_bh(&hslot->lock);
 			udp_lib_lport_inuse(net, snum, hslot, bitmap, sk,
-					    saddr_comp);
+					    saddr_comp, udptable->log);
=20
 			snum =3D first;
 			/*
@@ -196,7 +199,7 @@ int udp_lib_get_port(struct sock *sk, unsigned shor=
t snum,
 			 */
 			do {
 				if (low <=3D snum && snum <=3D high &&
-				    !test_bit(snum / UDP_HTABLE_SIZE, bitmap))
+				    !test_bit(snum >> udptable->log, bitmap))
 					goto found;
 				snum +=3D rand;
 			} while (snum !=3D first);
@@ -204,9 +207,10 @@ int udp_lib_get_port(struct sock *sk, unsigned sho=
rt snum,
 		}
 		goto fail;
 	} else {
-		hslot =3D &udptable->hash[udp_hashfn(net, snum)];
+		hslot =3D udp_hashslot(udptable, net, snum);
 		spin_lock_bh(&hslot->lock);
-		if (udp_lib_lport_inuse(net, snum, hslot, NULL, sk, saddr_comp))
+		if (udp_lib_lport_inuse(net, snum, hslot, NULL, sk,
+					saddr_comp, 0))
 			goto fail_unlock;
 	}
 found:
@@ -283,7 +287,7 @@ static struct sock *__udp4_lib_lookup(struct net *n=
et, __be32 saddr,
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
 	unsigned short hnum =3D ntohs(dport);
-	unsigned int hash =3D udp_hashfn(net, hnum);
+	unsigned int hash =3D udp_hashfn(net, hnum, udptable->mask);
 	struct udp_hslot *hslot =3D &udptable->hash[hash];
 	int score, badness;
=20
@@ -1013,8 +1017,8 @@ void udp_lib_unhash(struct sock *sk)
 {
 	if (sk_hashed(sk)) {
 		struct udp_table *udptable =3D sk->sk_prot->h.udp_table;
-		unsigned int hash =3D udp_hashfn(sock_net(sk), sk->sk_hash);
-		struct udp_hslot *hslot =3D &udptable->hash[hash];
+		struct udp_hslot *hslot =3D udp_hashslot(udptable, sock_net(sk),
+						     sk->sk_hash);
=20
 		spin_lock_bh(&hslot->lock);
 		if (sk_nulls_del_node_init_rcu(sk)) {
@@ -1169,7 +1173,7 @@ static int __udp4_lib_mcast_deliver(struct net *n=
et, struct sk_buff *skb,
 				    struct udp_table *udptable)
 {
 	struct sock *sk;
-	struct udp_hslot *hslot =3D &udptable->hash[udp_hashfn(net, ntohs(uh-=
>dest))];
+	struct udp_hslot *hslot =3D udp_hashslot(udptable, net, ntohs(uh->des=
t));
 	int dif;
=20
 	spin_lock(&hslot->lock);
@@ -1609,9 +1613,14 @@ static struct sock *udp_get_first(struct seq_fil=
e *seq, int start)
 	struct udp_iter_state *state =3D seq->private;
 	struct net *net =3D seq_file_net(seq);
=20
-	for (state->bucket =3D start; state->bucket < UDP_HTABLE_SIZE; ++stat=
e->bucket) {
+	for (state->bucket =3D start; state->bucket <=3D state->udp_table->ma=
sk;
+	     ++state->bucket) {
 		struct hlist_nulls_node *node;
 		struct udp_hslot *hslot =3D &state->udp_table->hash[state->bucket];
+
+		if (hlist_nulls_empty(&hslot->head))
+			continue;
+
 		spin_lock_bh(&hslot->lock);
 		sk_nulls_for_each(sk, node, &hslot->head) {
 			if (!net_eq(sock_net(sk), net))
@@ -1636,7 +1645,7 @@ static struct sock *udp_get_next(struct seq_file =
*seq, struct sock *sk)
 	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family !=3D stat=
e->family));
=20
 	if (!sk) {
-		if (state->bucket < UDP_HTABLE_SIZE)
+		if (state->bucket <=3D state->udp_table->mask)
 			spin_unlock_bh(&state->udp_table->hash[state->bucket].lock);
 		return udp_get_first(seq, state->bucket + 1);
 	}
@@ -1656,7 +1665,7 @@ static struct sock *udp_get_idx(struct seq_file *=
seq, loff_t pos)
 static void *udp_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct udp_iter_state *state =3D seq->private;
-	state->bucket =3D UDP_HTABLE_SIZE;
+	state->bucket =3D MAX_UDP_PORTS;
=20
 	return *pos ? udp_get_idx(seq, *pos-1) : SEQ_START_TOKEN;
 }
@@ -1678,7 +1687,7 @@ static void udp_seq_stop(struct seq_file *seq, vo=
id *v)
 {
 	struct udp_iter_state *state =3D seq->private;
=20
-	if (state->bucket < UDP_HTABLE_SIZE)
+	if (state->bucket <=3D state->udp_table->mask)
 		spin_unlock_bh(&state->udp_table->hash[state->bucket].lock);
 }
=20
@@ -1738,7 +1747,7 @@ static void udp4_format_sock(struct sock *sp, str=
uct seq_file *f,
 	__u16 destp	  =3D ntohs(inet->dport);
 	__u16 srcp	  =3D ntohs(inet->sport);
=20
-	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
+	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
 		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d%n",
 		bucket, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
@@ -1804,11 +1813,43 @@ void udp4_proc_exit(void)
 }
 #endif /* CONFIG_PROC_FS */
=20
-void __init udp_table_init(struct udp_table *table)
+static __initdata unsigned long uhash_entries;
+static int __init set_uhash_entries(char *str)
 {
-	int i;
+	if (!str)
+		return 0;
+	uhash_entries =3D simple_strtoul(str, &str, 0);
+	if (uhash_entries && uhash_entries < UDP_HTABLE_SIZE_MIN)
+		uhash_entries =3D UDP_HTABLE_SIZE_MIN;
+	return 1;
+}
+__setup("uhash_entries=3D", set_uhash_entries);
=20
-	for (i =3D 0; i < UDP_HTABLE_SIZE; i++) {
+void __init udp_table_init(struct udp_table *table, const char *name)
+{
+	unsigned int i;
+
+	if (!CONFIG_BASE_SMALL)
+		table->hash =3D alloc_large_system_hash(name,
+			sizeof(struct udp_hslot),
+			uhash_entries,
+			21, /* one slot per 2 MB */
+			0,
+			&table->log,
+			&table->mask,
+			64 * 1024);
+	/*
+	 * Make sure hash table has the minimum size
+	 */
+	if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - 1) {
+		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
+				      sizeof(struct udp_hslot), GFP_KERNEL);
+		if (!table->hash)
+			panic(name);
+		table->log =3D ilog2(UDP_HTABLE_SIZE_MIN);
+		table->mask =3D UDP_HTABLE_SIZE_MIN - 1;
+	}
+	for (i =3D 0; i <=3D table->mask; i++) {
 		INIT_HLIST_NULLS_HEAD(&table->hash[i].head, i);
 		spin_lock_init(&table->hash[i].lock);
 	}
@@ -1818,7 +1859,7 @@ void __init udp_init(void)
 {
 	unsigned long nr_pages, limit;
=20
-	udp_table_init(&udp_table);
+	udp_table_init(&udp_table, "UDP");
 	/* Set the pressure threshold up by the same strategy of TCP. It is a
 	 * fraction of global memory that is up to 1/2 at 256 MB, decreasing
 	 * toward zero with the amount of memory, with a floor of 128 pages.
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 95248d7..a495ca8 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -12,7 +12,7 @@
  */
 #include "udp_impl.h"
=20
-struct udp_table 	udplite_table;
+struct udp_table 	udplite_table __read_mostly;
 EXPORT_SYMBOL(udplite_table);
=20
 static int udplite_rcv(struct sk_buff *skb)
@@ -110,7 +110,7 @@ static inline int udplite4_proc_init(void)
=20
 void __init udplite4_register(void)
 {
-	udp_table_init(&udplite_table);
+	udp_table_init(&udplite_table, "UDP-Lite");
 	if (proto_register(&udplite_prot, 1))
 		goto out_register_err;
=20
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3a60f12..d42f503 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -132,7 +132,7 @@ static struct sock *__udp6_lib_lookup(struct net *n=
et,
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
 	unsigned short hnum =3D ntohs(dport);
-	unsigned int hash =3D udp_hashfn(net, hnum);
+	unsigned int hash =3D udp_hashfn(net, hnum, udptable->mask);
 	struct udp_hslot *hslot =3D &udptable->hash[hash];
 	int score, badness;
=20
@@ -452,7 +452,7 @@ static int __udp6_lib_mcast_deliver(struct net *net=
, struct sk_buff *skb,
 {
 	struct sock *sk, *sk2;
 	const struct udphdr *uh =3D udp_hdr(skb);
-	struct udp_hslot *hslot =3D &udptable->hash[udp_hashfn(net, ntohs(uh-=
>dest))];
+	struct udp_hslot *hslot =3D udp_hashslot(udptable, net, ntohs(uh->des=
t));
 	int dif;
=20
 	spin_lock(&hslot->lock);
@@ -1195,7 +1195,7 @@ static void udp6_sock_seq_show(struct seq_file *s=
eq, struct sock *sp, int bucket
 	destp =3D ntohs(inet->dport);
 	srcp  =3D ntohs(inet->sport);
 	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+		   "%5d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
 		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
 		   bucket,
 		   src->s6_addr32[0], src->s6_addr32[1],
