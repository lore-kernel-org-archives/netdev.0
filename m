From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 10:04:24 +0100
Message-ID: <49082718.2030201@cosmosbay.com>
References: <20081008.114527.189056050.davem@davemloft.net>	<49077918.4050706@cosmosbay.com>	<490795FB.2000201@cosmosbay.com> <20081028.220536.183082966.davem@davemloft.net> <49081D67.3050502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010104030505050809050403"
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:32823 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384AbYJ2JIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 05:08:15 -0400
In-Reply-To: <49081D67.3050502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010104030505050809050403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Tue, 28 Oct 2008 23:45:15 +0100
>>
>>> I will submit a new patch serie tomorrow, with :
>>>
>>> Patch 1 : spinlocks instead of rwlocks, and bug spotted by Christian =

>>> Bell
>>>
>>> Patch 2 : splited on two parts (2 & 3) , one for IPV4, one for IPV6, =

>>
>> I very much look forward to this :-)
>>
>> I like these changes and can't wait to add them to net-next-2.6
>=20

Please find updated patch 2

Missing check in __udp6_lib_lookup() was added,
and based on spinlock version ([PATCH] udp: introduce struct udp_table an=
d multiple spinlocks)

Thank you

[PATCH] udp: RCU handling for Unicast packets.

Goals are :

1) Optimizing handling of incoming Unicast UDP frames, so that no memory
 writes should happen in the fast path.

 Note: Multicasts and broadcasts still will need to take a lock,
 because doing a full lockless lookup in this case is difficult.

2) No expensive operations in the socket bind/unhash phases :
  - No expensive synchronize_rcu() calls.

  - No added rcu_head in socket structure, increasing memory needs,
  but more important, forcing us to use call_rcu() calls,
  that have the bad property of making sockets structure cold.
  (rcu grace period between socket freeing and its potential reuse
   make this socket being cold in CPU cache).
  David did a previous patch using call_rcu() and noticed a 20%
  impact on TCP connection rates.
  Quoting Cristopher Lameter :
   "Right. That results in cacheline cooldown. You'd want to recycle
    the object as they are cache hot on a per cpu basis. That is screwed
    up by the delayed regular rcu processing. We have seen multiple
    regressions due to cacheline cooldown.
    The only choice in cacheline hot sensitive areas is to deal with the
    complexity that comes with SLAB_DESTROY_BY_RCU or give up on RCU."

  - Because udp sockets are allocated from dedicated kmem_cache,
  use of SLAB_DESTROY_BY_RCU can help here.

Theory of operation :
---------------------

As the lookup is lockfree (using rcu_read_lock()/rcu_read_unlock()),
special attention must be taken by readers and writers.

Use of SLAB_DESTROY_BY_RCU is tricky too, because a socket can be freed,
reused, inserted in a different chain or in worst case in the same chain
while readers could do lookups in the same time.

In order to avoid loops, a reader must check each socket found in a chain=

really belongs to the chain the reader was traversing. If it finds a
mismatch, lookup must start again at the begining. This *restart* loop
is the reason we had to use rdlock for the multicast case, because
we dont want to send same message several times to the same socket.

We use RCU only for fast path.
Thus, /proc/net/udp still takes spinlocks.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/sock.h |   37 ++++++++++++++++++++++++++++++++++++-
 net/core/sock.c    |    3 ++-
 net/ipv4/udp.c     |   35 ++++++++++++++++++++++++++---------
 net/ipv4/udplite.c |    1 +
 net/ipv6/udp.c     |   31 ++++++++++++++++++++++++-------
 net/ipv6/udplite.c |    1 +
 6 files changed, 90 insertions(+), 18 deletions(-)

--------------010104030505050809050403
Content-Type: text/plain;
 name="patch_udp_2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_udp_2.patch"

diff --git a/include/net/sock.h b/include/net/sock.h
index d200dfb..0bea25d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -363,6 +363,27 @@ static __inline__ int sk_del_node_init(struct sock *sk)
 	return rc;
 }
 
+static __inline__ int __sk_del_node_init_rcu(struct sock *sk)
+{
+	if (sk_hashed(sk)) {
+		hlist_del_init_rcu(&sk->sk_node);
+		return 1;
+	}
+	return 0;
+}
+
+static __inline__ int sk_del_node_init_rcu(struct sock *sk)
+{
+	int rc = __sk_del_node_init_rcu(sk);
+
+	if (rc) {
+		/* paranoid for a while -acme */
+		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
+		__sock_put(sk);
+	}
+	return rc;
+}
+
 static __inline__ void __sk_add_node(struct sock *sk, struct hlist_head *list)
 {
 	hlist_add_head(&sk->sk_node, list);
@@ -374,6 +395,17 @@ static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
 	__sk_add_node(sk, list);
 }
 
+static __inline__ void __sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
+{
+	hlist_add_head_rcu(&sk->sk_node, list);
+}
+
+static __inline__ void sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
+{
+	sock_hold(sk);
+	__sk_add_node_rcu(sk, list);
+}
+
 static __inline__ void __sk_del_bind_node(struct sock *sk)
 {
 	__hlist_del(&sk->sk_bind_node);
@@ -387,6 +419,8 @@ static __inline__ void sk_add_bind_node(struct sock *sk,
 
 #define sk_for_each(__sk, node, list) \
 	hlist_for_each_entry(__sk, node, list, sk_node)
+#define sk_for_each_rcu(__sk, node, list) \
+	hlist_for_each_entry_rcu(__sk, node, list, sk_node)
 #define sk_for_each_from(__sk, node) \
 	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
 		hlist_for_each_entry_from(__sk, node, sk_node)
@@ -589,8 +623,9 @@ struct proto {
 	int			*sysctl_rmem;
 	int			max_header;
 
-	struct kmem_cache		*slab;
+	struct kmem_cache	*slab;
 	unsigned int		obj_size;
+	int			slab_flags;
 
 	atomic_t		*orphan_count;
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 5e2a313..ded1eb5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2042,7 +2042,8 @@ int proto_register(struct proto *prot, int alloc_slab)
 
 	if (alloc_slab) {
 		prot->slab = kmem_cache_create(prot->name, prot->obj_size, 0,
-					       SLAB_HWCACHE_ALIGN, NULL);
+					SLAB_HWCACHE_ALIGN | prot->slab_flags,
+					NULL);
 
 		if (prot->slab == NULL) {
 			printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b91cd0a..5c1cbe1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -187,7 +187,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 	inet_sk(sk)->num = snum;
 	sk->sk_hash = snum;
 	if (sk_unhashed(sk)) {
-		sk_add_node(sk, &hslot->head);
+		sk_add_node_rcu(sk, &hslot->head);
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	}
 	error = 0;
@@ -253,15 +253,24 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 		__be16 sport, __be32 daddr, __be16 dport,
 		int dif, struct udp_table *udptable)
 {
-	struct sock *sk, *result = NULL;
+	struct sock *sk, *result;
 	struct hlist_node *node;
 	unsigned short hnum = ntohs(dport);
 	unsigned int hash = udp_hashfn(net, hnum);
 	struct udp_hslot *hslot = &udptable->hash[hash];
-	int score, badness = -1;
+	int score, badness;
 
-	spin_lock(&hslot->lock);
-	sk_for_each(sk, node, &hslot->head) {
+	rcu_read_lock();
+begin:
+	result = NULL;
+	badness = -1;
+	sk_for_each_rcu(sk, node, &hslot->head) {
+		/*
+		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
+		 * We must check this item was not moved to another chain
+		 */
+		if (udp_hashfn(net, sk->sk_hash) != hash)
+			goto begin;
 		score = compute_score(sk, net, saddr, hnum, sport,
 				      daddr, dport, dif);
 		if (score > badness) {
@@ -269,9 +278,16 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 			badness = score;
  		}
 	}
-	if (result)
-		sock_hold(result);
-	spin_unlock(&hslot->lock);
+	if (result) {
+		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
+			result = NULL;
+		else if (unlikely(compute_score(result, net, saddr, hnum, sport,
+				  daddr, dport, dif) < badness)) {
+			sock_put(result);
+			goto begin;
+		}
+	}
+	rcu_read_unlock();
 	return result;
 }
 
@@ -953,7 +969,7 @@ void udp_lib_unhash(struct sock *sk)
 	struct udp_hslot *hslot = &udptable->hash[hash];
 
 	spin_lock(&hslot->lock);
-	if (sk_del_node_init(sk)) {
+	if (sk_del_node_init_rcu(sk)) {
 		inet_sk(sk)->num = 0;
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 	}
@@ -1517,6 +1533,7 @@ struct proto udp_prot = {
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp_sock),
+	.slab_flags	   = SLAB_DESTROY_BY_RCU,
 	.h.udp_table	   = &udp_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index d8ea8e5..c784891 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -51,6 +51,7 @@ struct proto 	udplite_prot = {
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
 	.obj_size	   = sizeof(struct udp_sock),
+	.slab_flags	   = SLAB_DESTROY_BY_RCU,
 	.h.udp_table	   = &udplite_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index ccee724..df78ddc 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -97,24 +97,40 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 				      struct in6_addr *daddr, __be16 dport,
 				      int dif, struct udp_table *udptable)
 {
-	struct sock *sk, *result = NULL;
+	struct sock *sk, *result;
 	struct hlist_node *node;
 	unsigned short hnum = ntohs(dport);
 	unsigned int hash = udp_hashfn(net, hnum);
 	struct udp_hslot *hslot = &udptable->hash[hash];
-	int score, badness = -1;
+	int score, badness;
 
-	spin_lock(&hslot->lock);
-	sk_for_each(sk, node, &hslot->head) {
+	rcu_read_lock();
+begin:
+	result = NULL;
+	badness = -1;
+	sk_for_each_rcu(sk, node, &hslot->head) {
+		/*
+		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
+		 * We must check this item was not moved to another chain
+		 */
+		if (udp_hashfn(net, sk->sk_hash) != hash)
+			goto begin;
 		score = compute_score(sk, net, hnum, saddr, sport, daddr, dport, dif);
 		if (score > badness) {
 			result = sk;
 			badness = score;
 		}
 	}
-	if (result)
-		sock_hold(result);
-	spin_unlock(&hslot->lock);
+	if (result) {
+		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
+			result = NULL;
+		else if (unlikely(compute_score(result, net, hnum, saddr, sport,
+					daddr, dport, dif) < badness)) {
+			sock_put(result);
+			goto begin;
+ 		}
+	}
+	rcu_read_unlock();
 	return result;
 }
 
@@ -1062,6 +1078,7 @@ struct proto udpv6_prot = {
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp6_sock),
+	.slab_flags	   = SLAB_DESTROY_BY_RCU,
 	.h.udp_table	   = &udp_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udpv6_setsockopt,
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index f1e892a..05ab176 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -49,6 +49,7 @@ struct proto udplitev6_prot = {
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v6_get_port,
 	.obj_size	   = sizeof(struct udp6_sock),
+ 	.slab_flags	   = SLAB_DESTROY_BY_RCU,
 	.h.udp_table	   = &udplite_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udpv6_setsockopt,

--------------010104030505050809050403--
