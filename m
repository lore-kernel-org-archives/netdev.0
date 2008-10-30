From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] udp: Introduce special NULL pointers for hlist termination
Date: Thu, 30 Oct 2008 16:40:01 +0100
Message-ID: <4909D551.9080309@cosmosbay.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010204080106050704030600"
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: paulmck@linux.vnet.ibm.com, Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:38530 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582AbYJ3Pry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 11:47:54 -0400
In-Reply-To: <4908DEDE.5030706@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010204080106050704030600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Eric Dumazet a =E9crit :
> Paul E. McKenney a =E9crit :
>> On Wed, Oct 29, 2008 at 09:00:13PM +0100, Eric Dumazet wrote:
>>> Hum... Another way of handling all those cases and avoid memory barri=
ers
>>> would be to have different "NULL" pointers.
>>>
>>> Each hash chain should have a unique "NULL" pointer (in the case of=20
>>> UDP, it
>>> can be the 128 values : [ (void*)0 .. (void *)127 ]
>>>
>>> Then, when performing a lookup, a reader should check the "NULL" poin=
ter
>>> it get at the end of its lookup has is the "hash" value of its chain.=

>>>
>>> If not -> restart the loop, aka "goto begin;" :)
>>>
>>> We could avoid memory barriers then.
>>>
>>> In the two cases Corey mentioned, this trick could let us avoid=20
>>> memory barriers.
>>> (existing one in sk_add_node_rcu(sk, &hslot->head); should be enough)=

>>>
>>> What do you think ?
>>
>> Kinky!!!  ;-)
>>
>> Then the rcu_dereference() would be supplying the needed memory barrie=
rs.
>>
>> Hmmm...  I guess that the only confusion would be if the element got
>> removed and then added to the same list.  But then if its pointer was
>> pseudo-NULL, then that would mean that all subsequent elements had bee=
n
>> removed, and all preceding ones added after the scan started.
>>
>> Which might well be harmless, but I must defer to you on this one at
>> the moment.
>>
>> If you need a larger hash table, another approach would be to set the
>> pointer's low-order bit, allowing the upper bits to be a full-sized
>> index -- or even a pointer to the list header.  Just make very sure
>> to clear the pointer when freeing, or an element on the freelist
>> could end up looking like a legitimate end of list...  Which again
>> might well be safe, but why inflict this on oneself?
>=20

Ok, here is an updated and tested patch.

Thanks everybody

[PATCH] udp: Introduce special NULL pointers for hlist termination

In order to safely detect changes in chains, we would like to have differ=
ent
'NULL' pointers. Each chain in hash table is terminated by an unique 'NUL=
L'
value, so that the lockless readers can detect their lookups evaded from
their starting chain.

We introduce a new type of hlist implementation, named hlist_nulls, were
we use the least significant bit of the 'ptr' to tell if its a "NULL" val=
ue
or a pointer to an object. We expect to use this new hlist variant for TC=
P
as well.

For UDP/UDP-Lite hash table, we use 128 different "NULL" values,
(UDP_HTABLE_SIZE=3D128)

Using hlist_nulls saves memory barriers (a read barrier to fetch 'next'
pointers *before* checking key values) we added in commit=20
96631ed16c514cf8b28fab991a076985ce378c26
(udp: introduce sk_for_each_rcu_safenext())

This also saves a write memory barrier in udp_lib_get_port(), between
sk->sk_hash update and sk->next update)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/list_nulls.h    |   97 ++++++++++++++++++++++++++++++++
 include/linux/rculist.h       |   17 -----
 include/linux/rculist_nulls.h |   55 ++++++++++++++++++
 include/net/sock.h            |   50 ++++++++++++----
 include/net/udp.h             |    2
 net/ipv4/udp.c                |   40 ++++++-------
 net/ipv6/udp.c                |   22 ++++---
 7 files changed, 228 insertions(+), 55 deletions(-)


--------------010204080106050704030600
Content-Type: text/plain;
 name="PATCH_NULLS.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="PATCH_NULLS.patch"

diff --git a/include/linux/list_nulls.h b/include/linux/list_nulls.h
index e69de29..6adaa75 100644
--- a/include/linux/list_nulls.h
+++ b/include/linux/list_nulls.h
@@ -0,0 +1,97 @@
+#ifndef _LINUX_LIST_NULLS_H
+#define _LINUX_LIST_NULLS_H
+
+#include <linux/list.h>
+
+/*
+ * Special versions of lists, where a NULL pointer may have different values.
+ * (up to 2^31 different values guaranteed on all platforms)
+ *
+ * The least significant bit of 'ptr' is used to encode the 'NULL' value.
+ * Set to 1 : This is a NULL value (ptr >> 1)
+ * Set to 0 : This is a pointer to some object (ptr)
+ *
+ * Used for UDP sockets.
+ */
+
+struct hlist_nulls_head {
+	struct hlist_nulls_node *first;
+};
+
+struct hlist_nulls_node {
+	struct hlist_nulls_node *next, **pprev;
+};
+
+#define INIT_HLIST_NULLS_HEAD(ptr, nulls) \
+	((ptr)->first = (struct hlist_nulls_node *) (1UL | ((nulls) << 1)))
+
+#define hlist_nulls_entry(ptr, type, member) container_of(ptr,type,member)
+
+/**
+ * ptr_is_a_nulls - Test if a ptr to struct hlist_nulls_node is a nulls
+ * @ptr: ptr to be tested
+ *
+ */
+static inline int is_a_nulls(struct hlist_nulls_node *ptr)
+{
+	return ((unsigned long)ptr & 1);
+}
+
+/**
+ * get_nulls_value - Returns the null associated with a ptr
+ * @ptr: ptr to struct hlist_nulls_node
+ *
+ * Caller must check is_a_nulls(ptr) is true before calling this.
+ */
+static inline unsigned long get_nulls_value(struct hlist_nulls_node *ptr)
+{
+	return ((unsigned long)ptr) >> 1;
+}
+
+static inline int hlist_nulls_unhashed(const struct hlist_nulls_node *h)
+{
+	return !h->pprev;
+}
+
+static inline int hlist_nulls_empty(const struct hlist_nulls_head *h)
+{
+	return is_a_nulls(h->first);
+}
+
+static inline void __hlist_nulls_del(struct hlist_nulls_node *n)
+{
+	struct hlist_nulls_node *next = n->next;
+	struct hlist_nulls_node **pprev = n->pprev;
+	*pprev = next;
+	if (!is_a_nulls(next))
+		next->pprev = pprev;
+}
+
+/**
+ * hlist_nulls_for_each_entry	- iterate over list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ *
+ */
+#define hlist_nulls_for_each_entry(tpos, pos, head, member)	 \
+	for (pos = (head)->first;				 \
+	     (!is_a_nulls(pos)) && ({ prefetch(pos->next); 1;}) && \
+		({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+/**
+ * hlist_nulls_for_each_entry_from - iterate over a hlist continuing from current point
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @member:	the name of the hlist_node within the struct.
+ *
+ */
+#define hlist_nulls_for_each_entry_from(tpos, pos, member)	\
+	for (; (!is_a_nulls(pos)) && 				\
+		({ prefetch(pos->next); 1;})   &&		\
+		({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+#endif
diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 3ba2998..e649bd3 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -383,22 +383,5 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
 		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
 		pos = rcu_dereference(pos->next))
 
-/**
- * hlist_for_each_entry_rcu_safenext - iterate over rcu list of given type
- * @tpos:	the type * to use as a loop cursor.
- * @pos:	the &struct hlist_node to use as a loop cursor.
- * @head:	the head for your list.
- * @member:	the name of the hlist_node within the struct.
- * @next:       the &struct hlist_node to use as a next cursor
- *
- * Special version of hlist_for_each_entry_rcu that make sure
- * each next pointer is fetched before each iteration.
- */
-#define hlist_for_each_entry_rcu_safenext(tpos, pos, head, member, next) \
-	for (pos = rcu_dereference((head)->first);			 \
-		pos && ({ next = pos->next; smp_rmb(); prefetch(next); 1; }) &&	\
-		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
-		pos = rcu_dereference(next))
-
 #endif	/* __KERNEL__ */
 #endif
diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_nulls.h
index e69de29..f16b455 100644
--- a/include/linux/rculist_nulls.h
+++ b/include/linux/rculist_nulls.h
@@ -0,0 +1,55 @@
+#ifndef _LINUX_RCULIST_NULLS_H
+#define _LINUX_RCULIST_NULLS_H
+
+#ifdef __KERNEL__
+
+/*
+ * RCU-protected list version, based on 'hlist_nulls' variant
+ *
+ * Used for UDP sockets.
+ */
+#include <linux/list_nulls.h>
+#include <linux/rcupdate.h>
+
+static inline void hlist_nulls_del_init_rcu(struct hlist_nulls_node *n)
+{
+	if (!hlist_nulls_unhashed(n)) {
+		__hlist_nulls_del(n);
+		n->pprev = NULL;
+	}
+}
+
+static inline void hlist_nulls_del_rcu(struct hlist_nulls_node *n)
+{
+	__hlist_nulls_del(n);
+	n->pprev = LIST_POISON2;
+}
+
+static inline void hlist_nulls_add_head_rcu(struct hlist_nulls_node *n,
+					struct hlist_nulls_head *h)
+{
+	struct hlist_nulls_node *first = h->first;
+
+	n->next = first;
+	n->pprev = &h->first;
+	rcu_assign_pointer(h->first, n);
+	if (!is_a_nulls(first))
+		first->pprev = &n->next;
+}
+/**
+ * hlist_nulls_for_each_entry_rcu - iterate over rcu list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ *
+ */
+#define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member) \
+	for (pos = rcu_dereference((head)->first);			 \
+		(!is_a_nulls(pos)) && 			\
+		({ prefetch(pos->next); 1; }) &&			\
+		({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
+		pos = rcu_dereference(pos->next))
+
+#endif  /* __KERNEL__ */
+#endif
diff --git a/include/net/sock.h b/include/net/sock.h
index a4f6d3f..ece2235 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -42,6 +42,7 @@
 
 #include <linux/kernel.h>
 #include <linux/list.h>
+#include <linux/list_nulls.h>
 #include <linux/timer.h>
 #include <linux/cache.h>
 #include <linux/module.h>
@@ -52,6 +53,7 @@
 #include <linux/security.h>
 
 #include <linux/filter.h>
+#include <linux/rculist_nulls.h>
 
 #include <asm/atomic.h>
 #include <net/dst.h>
@@ -106,6 +108,7 @@ struct net;
  *	@skc_reuse: %SO_REUSEADDR setting
  *	@skc_bound_dev_if: bound device index if != 0
  *	@skc_node: main hash linkage for various protocol lookup tables
+ *	@skc_nulls_node: main hash linkage for UDP/UDP-Lite protocol
  *	@skc_bind_node: bind hash linkage for various protocol lookup tables
  *	@skc_refcnt: reference count
  *	@skc_hash: hash value used with various protocol lookup tables
@@ -120,7 +123,10 @@ struct sock_common {
 	volatile unsigned char	skc_state;
 	unsigned char		skc_reuse;
 	int			skc_bound_dev_if;
-	struct hlist_node	skc_node;
+	union {
+		struct hlist_node	skc_node;
+		struct hlist_nulls_node skc_nulls_node;
+	};
 	struct hlist_node	skc_bind_node;
 	atomic_t		skc_refcnt;
 	unsigned int		skc_hash;
@@ -206,6 +212,7 @@ struct sock {
 #define sk_reuse		__sk_common.skc_reuse
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
 #define sk_node			__sk_common.skc_node
+#define sk_nulls_node		__sk_common.skc_nulls_node
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_refcnt		__sk_common.skc_refcnt
 #define sk_hash			__sk_common.skc_hash
@@ -296,12 +303,28 @@ static inline struct sock *sk_head(const struct hlist_head *head)
 	return hlist_empty(head) ? NULL : __sk_head(head);
 }
 
+static inline struct sock *__sk_nulls_head(const struct hlist_nulls_head *head)
+{
+	return hlist_nulls_entry(head->first, struct sock, sk_nulls_node);
+}
+
+static inline struct sock *sk_nulls_head(const struct hlist_nulls_head *head)
+{
+	return hlist_nulls_empty(head) ? NULL : __sk_nulls_head(head);
+}
+
 static inline struct sock *sk_next(const struct sock *sk)
 {
 	return sk->sk_node.next ?
 		hlist_entry(sk->sk_node.next, struct sock, sk_node) : NULL;
 }
 
+static inline struct sock *sk_nulls_next(const struct sock *sk)
+{
+	return (!is_a_nulls(sk->sk_nulls_node.next)) ?
+		hlist_entry(sk->sk_nulls_node.next, struct sock, sk_nulls_node) : NULL;
+}
+
 static inline int sk_unhashed(const struct sock *sk)
 {
 	return hlist_unhashed(&sk->sk_node);
@@ -363,18 +386,18 @@ static __inline__ int sk_del_node_init(struct sock *sk)
 	return rc;
 }
 
-static __inline__ int __sk_del_node_init_rcu(struct sock *sk)
+static __inline__ int __sk_nulls_del_node_init_rcu(struct sock *sk)
 {
 	if (sk_hashed(sk)) {
-		hlist_del_init_rcu(&sk->sk_node);
+		hlist_nulls_del_init_rcu(&sk->sk_nulls_node);
 		return 1;
 	}
 	return 0;
 }
 
-static __inline__ int sk_del_node_init_rcu(struct sock *sk)
+static __inline__ int sk_nulls_del_node_init_rcu(struct sock *sk)
 {
-	int rc = __sk_del_node_init_rcu(sk);
+	int rc = __sk_nulls_del_node_init_rcu(sk);
 
 	if (rc) {
 		/* paranoid for a while -acme */
@@ -395,15 +418,15 @@ static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
 	__sk_add_node(sk, list);
 }
 
-static __inline__ void __sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
+static __inline__ void __sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
 {
-	hlist_add_head_rcu(&sk->sk_node, list);
+	hlist_nulls_add_head_rcu(&sk->sk_nulls_node, list);
 }
 
-static __inline__ void sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
+static __inline__ void sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
 {
 	sock_hold(sk);
-	__sk_add_node_rcu(sk, list);
+	__sk_nulls_add_node_rcu(sk, list);
 }
 
 static __inline__ void __sk_del_bind_node(struct sock *sk)
@@ -419,11 +442,16 @@ static __inline__ void sk_add_bind_node(struct sock *sk,
 
 #define sk_for_each(__sk, node, list) \
 	hlist_for_each_entry(__sk, node, list, sk_node)
-#define sk_for_each_rcu_safenext(__sk, node, list, next) \
-	hlist_for_each_entry_rcu_safenext(__sk, node, list, sk_node, next)
+#define sk_nulls_for_each(__sk, node, list) \
+	hlist_nulls_for_each_entry(__sk, node, list, sk_nulls_node)
+#define sk_nulls_for_each_rcu(__sk, node, list) \
+	hlist_nulls_for_each_entry_rcu(__sk, node, list, sk_nulls_node)
 #define sk_for_each_from(__sk, node) \
 	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
 		hlist_for_each_entry_from(__sk, node, sk_node)
+#define sk_nulls_for_each_from(__sk, node) \
+	if (__sk && ({ node = &(__sk)->sk_nulls_node; 1; })) \
+		hlist_nulls_for_each_entry_from(__sk, node, sk_nulls_node)
 #define sk_for_each_continue(__sk, node) \
 	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
 		hlist_for_each_entry_continue(__sk, node, sk_node)
diff --git a/include/net/udp.h b/include/net/udp.h
index df2bfe5..90e6ce5 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -51,7 +51,7 @@ struct udp_skb_cb {
 #define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
 
 struct udp_hslot {
-	struct hlist_head	head;
+	struct hlist_nulls_head	head;
 	spinlock_t		lock;
 } __attribute__((aligned(2 * sizeof(long))));
 struct udp_table {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1789b35..0f7ed53 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -127,9 +127,9 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 						 const struct sock *sk2))
 {
 	struct sock *sk2;
-	struct hlist_node *node;
+	struct hlist_nulls_node *node;
 
-	sk_for_each(sk2, node, &hslot->head)
+	sk_nulls_for_each(sk2, node, &hslot->head)
 		if (net_eq(sock_net(sk2), net)			&&
 		    sk2 != sk					&&
 		    sk2->sk_hash == num				&&
@@ -189,12 +189,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 	inet_sk(sk)->num = snum;
 	sk->sk_hash = snum;
 	if (sk_unhashed(sk)) {
-		/*
-		 * We need that previous write to sk->sk_hash committed
-		 * before write to sk->next done in following add_node() variant
-		 */
-		smp_wmb();
-		sk_add_node_rcu(sk, &hslot->head);
+		sk_nulls_add_node_rcu(sk, &hslot->head);
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	}
 	error = 0;
@@ -261,7 +256,7 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 		int dif, struct udp_table *udptable)
 {
 	struct sock *sk, *result;
-	struct hlist_node *node, *next;
+	struct hlist_nulls_node *node;
 	unsigned short hnum = ntohs(dport);
 	unsigned int hash = udp_hashfn(net, hnum);
 	struct udp_hslot *hslot = &udptable->hash[hash];
@@ -271,7 +266,7 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 begin:
 	result = NULL;
 	badness = -1;
-	sk_for_each_rcu_safenext(sk, node, &hslot->head, next) {
+	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
 		/*
 		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
 		 * We must check this item was not moved to another chain
@@ -285,6 +280,13 @@ begin:
 			badness = score;
 		}
 	}
+	/*
+	 * if the nulls value we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 */
+	if (get_nulls_value(node) != hash)
+		goto begin;
+
 	if (result) {
 		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
 			result = NULL;
@@ -325,11 +327,11 @@ static inline struct sock *udp_v4_mcast_next(struct sock *sk,
 					     __be16 rmt_port, __be32 rmt_addr,
 					     int dif)
 {
-	struct hlist_node *node;
+	struct hlist_nulls_node *node;
 	struct sock *s = sk;
 	unsigned short hnum = ntohs(loc_port);
 
-	sk_for_each_from(s, node) {
+	sk_nulls_for_each_from(s, node) {
 		struct inet_sock *inet = inet_sk(s);
 
 		if (s->sk_hash != hnum					||
@@ -976,7 +978,7 @@ void udp_lib_unhash(struct sock *sk)
 	struct udp_hslot *hslot = &udptable->hash[hash];
 
 	spin_lock_bh(&hslot->lock);
-	if (sk_del_node_init_rcu(sk)) {
+	if (sk_nulls_del_node_init_rcu(sk)) {
 		inet_sk(sk)->num = 0;
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 	}
@@ -1129,7 +1131,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	int dif;
 
 	spin_lock(&hslot->lock);
-	sk = sk_head(&hslot->head);
+	sk = sk_nulls_head(&hslot->head);
 	dif = skb->dev->ifindex;
 	sk = udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (sk) {
@@ -1138,7 +1140,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		do {
 			struct sk_buff *skb1 = skb;
 
-			sknext = udp_v4_mcast_next(sk_next(sk), uh->dest, daddr,
+			sknext = udp_v4_mcast_next(sk_nulls_next(sk), uh->dest, daddr,
 						   uh->source, saddr, dif);
 			if (sknext)
 				skb1 = skb_clone(skb, GFP_ATOMIC);
@@ -1558,10 +1560,10 @@ static struct sock *udp_get_first(struct seq_file *seq, int start)
 	struct net *net = seq_file_net(seq);
 
 	for (state->bucket = start; state->bucket < UDP_HTABLE_SIZE; ++state->bucket) {
-		struct hlist_node *node;
+		struct hlist_nulls_node *node;
 		struct udp_hslot *hslot = &state->udp_table->hash[state->bucket];
 		spin_lock_bh(&hslot->lock);
-		sk_for_each(sk, node, &hslot->head) {
+		sk_nulls_for_each(sk, node, &hslot->head) {
 			if (!net_eq(sock_net(sk), net))
 				continue;
 			if (sk->sk_family == state->family)
@@ -1580,7 +1582,7 @@ static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
 	struct net *net = seq_file_net(seq);
 
 	do {
-		sk = sk_next(sk);
+		sk = sk_nulls_next(sk);
 	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family != state->family));
 
 	if (!sk) {
@@ -1751,7 +1753,7 @@ void __init udp_table_init(struct udp_table *table)
 	int i;
 
 	for (i = 0; i < UDP_HTABLE_SIZE; i++) {
-		INIT_HLIST_HEAD(&table->hash[i].head);
+		INIT_HLIST_NULLS_HEAD(&table->hash[i].head, i);
 		spin_lock_init(&table->hash[i].lock);
 	}
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 32d914d..581fcc1 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -98,7 +98,7 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 				      int dif, struct udp_table *udptable)
 {
 	struct sock *sk, *result;
-	struct hlist_node *node, *next;
+	struct hlist_nulls_node *node;
 	unsigned short hnum = ntohs(dport);
 	unsigned int hash = udp_hashfn(net, hnum);
 	struct udp_hslot *hslot = &udptable->hash[hash];
@@ -108,19 +108,27 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 begin:
 	result = NULL;
 	badness = -1;
-	sk_for_each_rcu_safenext(sk, node, &hslot->head, next) {
+	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
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
+	 * if the nulls value we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 */
+	if (get_nulls_value(node) != hash)
+		goto begin;
+
 	if (result) {
 		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
 			result = NULL;
@@ -360,11 +368,11 @@ static struct sock *udp_v6_mcast_next(struct sock *sk,
 				      __be16 rmt_port, struct in6_addr *rmt_addr,
 				      int dif)
 {
-	struct hlist_node *node;
+	struct hlist_nulls_node *node;
 	struct sock *s = sk;
 	unsigned short num = ntohs(loc_port);
 
-	sk_for_each_from(s, node) {
+	sk_nulls_for_each_from(s, node) {
 		struct inet_sock *inet = inet_sk(s);
 
 		if (sock_net(s) != sock_net(sk))
@@ -409,7 +417,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	int dif;
 
 	spin_lock(&hslot->lock);
-	sk = sk_head(&hslot->head);
+	sk = sk_nulls_head(&hslot->head);
 	dif = inet6_iif(skb);
 	sk = udp_v6_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (!sk) {
@@ -418,7 +426,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	}
 
 	sk2 = sk;
-	while ((sk2 = udp_v6_mcast_next(sk_next(sk2), uh->dest, daddr,
+	while ((sk2 = udp_v6_mcast_next(sk_nulls_next(sk2), uh->dest, daddr,
 					uh->source, saddr, dif))) {
 		struct sk_buff *buff = skb_clone(skb, GFP_ATOMIC);
 		if (buff) {

--------------010204080106050704030600--
