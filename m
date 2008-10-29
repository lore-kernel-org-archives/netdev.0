From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 23:08:30 +0100
Message-ID: <4908DEDE.5030706@cosmosbay.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070202070503030008050306"
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58016 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbYJ2WKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 18:10:04 -0400
In-Reply-To: <20081029201759.GF6732@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070202070503030008050306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Paul E. McKenney a =E9crit :
> On Wed, Oct 29, 2008 at 09:00:13PM +0100, Eric Dumazet wrote:
>> Hum... Another way of handling all those cases and avoid memory barrie=
rs
>> would be to have different "NULL" pointers.
>>
>> Each hash chain should have a unique "NULL" pointer (in the case of UD=
P, it
>> can be the 128 values : [ (void*)0 .. (void *)127 ]
>>
>> Then, when performing a lookup, a reader should check the "NULL" point=
er
>> it get at the end of its lookup has is the "hash" value of its chain.
>>
>> If not -> restart the loop, aka "goto begin;" :)
>>
>> We could avoid memory barriers then.
>>
>> In the two cases Corey mentioned, this trick could let us avoid memory=
=20
>> barriers.
>> (existing one in sk_add_node_rcu(sk, &hslot->head); should be enough)
>>
>> What do you think ?
>=20
> Kinky!!!  ;-)
>=20
> Then the rcu_dereference() would be supplying the needed memory barrier=
s.
>=20
> Hmmm...  I guess that the only confusion would be if the element got
> removed and then added to the same list.  But then if its pointer was
> pseudo-NULL, then that would mean that all subsequent elements had been=

> removed, and all preceding ones added after the scan started.
>=20
> Which might well be harmless, but I must defer to you on this one at
> the moment.
>=20
> If you need a larger hash table, another approach would be to set the
> pointer's low-order bit, allowing the upper bits to be a full-sized
> index -- or even a pointer to the list header.  Just make very sure
> to clear the pointer when freeing, or an element on the freelist
> could end up looking like a legitimate end of list...  Which again
> might well be safe, but why inflict this on oneself?

Well, for UDP case, hash table will be <=3D 65536 anyway, we can assume
no dynamic kernel memory is in the range [0 .. 65535]

Here is a patch (untested yet, its really time for a sleep for me ;) )

[PATCH] udp: Introduce special NULL pointers for hlist termination

In order to safely detect changes in chains, we would like to have differ=
ent
'NULL' pointers. Each chain in hash table is terminated by an unique 'NUL=
L'
value, so that the lockless readers can detect their lookups evaded from
their starting chain.

We define 'NULL' values as ((unsigned long)values < UDP_HTABLE_SIZE)

This saves memory barriers (a read barrier to fetch 'next' pointers
*before* checking key values) we added in commit=20
96631ed16c514cf8b28fab991a076985ce378c26 (udp: introduce=20
sk_for_each_rcu_safenext())=20

This also saves a missing memory barrier spotted by Corey Minyard=20
(a write one in udp_lib_get_port(), between sk_hash update and ->next upd=
ate)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
include/linux/list.h    |   32 ++++++++++++++++++++++++++++++++
include/linux/rculist.h |   15 ++++++++-------
include/net/sock.h      |    9 +++++++--
net/ipv4/udp.c          |   19 +++++++++++++------
net/ipv6/udp.c          |   16 ++++++++++++----
5 files changed, 72 insertions(+), 19 deletions(-)



--------------070202070503030008050306
Content-Type: text/plain;
 name="nulls.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nulls.patch"

diff --git a/include/linux/list.h b/include/linux/list.h
index 969f6e9..a3d5dd1 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -654,6 +654,22 @@ static inline void hlist_move_list(struct hlist_head *old,
 	     pos && ({ prefetch(pos->next); 1;}) &&			 \
 		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
 	     pos = pos->next)
+/**
+ * hlist_for_each_entry_nulls	- iterate over list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ * @nullval: the iteration should stop if a pointer is < nullval
+ *
+ * Special version of hlist_for_each_entry where the end pointer
+ * can be NULL but also any value < nullval.
+ */
+#define hlist_for_each_entry_nulls(tpos, pos, head, member, nullval)	 \
+	for (pos = (head)->first;					 \
+	     ((unsigned long)pos >= nullval) && ({ prefetch(pos->next); 1;}) && \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
 
 /**
  * hlist_for_each_entry_continue - iterate over a hlist continuing after current point
@@ -679,6 +695,22 @@ static inline void hlist_move_list(struct hlist_head *old,
 	     pos = pos->next)
 
 /**
+ * hlist_for_each_entry_from_nulls - iterate over a hlist continuing from current point
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @member:	the name of the hlist_node within the struct.
+ * @nullval: the iteration should stop if a pointer is < nullval
+ *
+ * Special version of hlist_for_each_entry_from where the end pointer
+ * can be NULL but also any value < nullval.
+ */
+#define hlist_for_each_entry_from_nulls(tpos, pos, member, nullval)	\
+	for (; ((unsigned long)pos >= nullval) && \
+		({ prefetch(pos->next); 1;})   && \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+/**
  * hlist_for_each_entry_safe - iterate over list of given type safe against removal of list entry
  * @tpos:	the type * to use as a loop cursor.
  * @pos:	the &struct hlist_node to use as a loop cursor.
diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 3ba2998..6f78e2b 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -384,21 +384,22 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
 		pos = rcu_dereference(pos->next))
 
 /**
- * hlist_for_each_entry_rcu_safenext - iterate over rcu list of given type
+ * hlist_for_each_entry_rcu_nulls - iterate over rcu list of given type
  * @tpos:	the type * to use as a loop cursor.
  * @pos:	the &struct hlist_node to use as a loop cursor.
  * @head:	the head for your list.
  * @member:	the name of the hlist_node within the struct.
- * @next:       the &struct hlist_node to use as a next cursor
+ * @nullval:       the iteration should stop if a pointer is < nullval
  *
- * Special version of hlist_for_each_entry_rcu that make sure
- * each next pointer is fetched before each iteration.
+ * Special version of hlist_for_each_entry_rcu where the end pointer
+ * can be NULL but also any value < nullval.
  */
-#define hlist_for_each_entry_rcu_safenext(tpos, pos, head, member, next) \
+#define hlist_for_each_entry_rcu_nulls(tpos, pos, head, member, nullval) \
 	for (pos = rcu_dereference((head)->first);			 \
-		pos && ({ next = pos->next; smp_rmb(); prefetch(next); 1; }) &&	\
+		((unsigned long)pos >= nullval) && 			\
+		({ prefetch(pos->next); 1; }) &&			\
 		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
-		pos = rcu_dereference(next))
+		pos = rcu_dereference(pos->next))
 
 #endif	/* __KERNEL__ */
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index a4f6d3f..efe4def 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -419,11 +419,16 @@ static __inline__ void sk_add_bind_node(struct sock *sk,
 
 #define sk_for_each(__sk, node, list) \
 	hlist_for_each_entry(__sk, node, list, sk_node)
-#define sk_for_each_rcu_safenext(__sk, node, list, next) \
-	hlist_for_each_entry_rcu_safenext(__sk, node, list, sk_node, next)
+#define sk_for_each_nulls(__sk, node, list, nullval) \
+	hlist_for_each_entry_nulls(__sk, node, list, sk_node, nullval)
+#define sk_for_each_rcu_nulls(__sk, node, list, nullval) \
+	hlist_for_each_entry_rcu_nulls(__sk, node, list, sk_node, nullval)
 #define sk_for_each_from(__sk, node) \
 	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
 		hlist_for_each_entry_from(__sk, node, sk_node)
+#define sk_for_each_from_nulls(__sk, node, nullval) \
+	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
+		hlist_for_each_entry_from_nulls(__sk, node, sk_node, nullval)
 #define sk_for_each_continue(__sk, node) \
 	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
 		hlist_for_each_entry_continue(__sk, node, sk_node)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c3ecec8..a61fe89 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -129,7 +129,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 	struct sock *sk2;
 	struct hlist_node *node;
 
-	sk_for_each(sk2, node, &hslot->head)
+	sk_for_each_nulls(sk2, node, &hslot->head, UDP_HTABLE_SIZE)
 		if (net_eq(sock_net(sk2), net)			&&
 		    sk2 != sk					&&
 		    sk2->sk_hash == num				&&
@@ -256,7 +256,7 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 		int dif, struct udp_table *udptable)
 {
 	struct sock *sk, *result;
-	struct hlist_node *node, *next;
+	struct hlist_node *node;
 	unsigned short hnum = ntohs(dport);
 	unsigned int hash = udp_hashfn(net, hnum);
 	struct udp_hslot *hslot = &udptable->hash[hash];
@@ -266,7 +266,7 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 begin:
 	result = NULL;
 	badness = -1;
-	sk_for_each_rcu_safenext(sk, node, &hslot->head, next) {
+	sk_for_each_rcu_nulls(sk, node, &hslot->head, UDP_HTABLE_SIZE) {
 		/*
 		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
 		 * We must check this item was not moved to another chain
@@ -280,6 +280,13 @@ begin:
 			badness = score;
 		}
 	}
+	/*
+	 * if the 'NULL' pointer we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 */
+	if ((unsigned long)node != hash)
+		goto begin;
+
 	if (result) {
 		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
 			result = NULL;
@@ -324,7 +331,7 @@ static inline struct sock *udp_v4_mcast_next(struct sock *sk,
 	struct sock *s = sk;
 	unsigned short hnum = ntohs(loc_port);
 
-	sk_for_each_from(s, node) {
+	sk_for_each_from_nulls(s, node, UDP_HTABLE_SIZE) {
 		struct inet_sock *inet = inet_sk(s);
 
 		if (s->sk_hash != hnum					||
@@ -1556,7 +1563,7 @@ static struct sock *udp_get_first(struct seq_file *seq, int start)
 		struct hlist_node *node;
 		struct udp_hslot *hslot = &state->udp_table->hash[state->bucket];
 		spin_lock_bh(&hslot->lock);
-		sk_for_each(sk, node, &hslot->head) {
+		sk_for_each_nulls(sk, node, &hslot->head, UDP_HTABLE_SIZE) {
 			if (!net_eq(sock_net(sk), net))
 				continue;
 			if (sk->sk_family == state->family)
@@ -1746,7 +1753,7 @@ void __init udp_table_init(struct udp_table *table)
 	int i;
 
 	for (i = 0; i < UDP_HTABLE_SIZE; i++) {
-		INIT_HLIST_HEAD(&table->hash[i].head);
+		table->hash[i].head.first = (struct hlist_node *)i;
 		spin_lock_init(&table->hash[i].lock);
 	}
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 32d914d..13635ef 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -98,7 +98,7 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 				      int dif, struct udp_table *udptable)
 {
 	struct sock *sk, *result;
-	struct hlist_node *node, *next;
+	struct hlist_node *node;
 	unsigned short hnum = ntohs(dport);
 	unsigned int hash = udp_hashfn(net, hnum);
 	struct udp_hslot *hslot = &udptable->hash[hash];
@@ -108,19 +108,27 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 begin:
 	result = NULL;
 	badness = -1;
-	sk_for_each_rcu_safenext(sk, node, &hslot->head, next) {
+	sk_for_each_rcu_nulls(sk, node, &hslot->head, UDP_HTABLE_SIZE) {
 		/*
 		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
 		 * We must check this item was not moved to another chain
 		 */
 		if (udp_hashfn(net, sk->sk_hash) != hash)
 			goto begin;
-		score = compute_score(sk, net, hnum, saddr, sport, daddr, dport, dif);
+		score = compute_score(sk, net, hnum, saddr, sport,
+				      daddr, dport, dif);
 		if (score > badness) {
 			result = sk;
 			badness = score;
 		}
 	}
+	/*
+	 * if the 'NULL' pointer we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 */
+	if ((unsigned long)node != hash)
+		goto begin;
+
 	if (result) {
 		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
 			result = NULL;
@@ -364,7 +372,7 @@ static struct sock *udp_v6_mcast_next(struct sock *sk,
 	struct sock *s = sk;
 	unsigned short num = ntohs(loc_port);
 
-	sk_for_each_from(s, node) {
+	sk_for_each_from_nulls(s, node, UDP_HTABLE_SIZE) {
 		struct inet_sock *inet = inet_sk(s);
 
 		if (sock_net(s) != sock_net(sk))

--------------070202070503030008050306--
