From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Tue, 28 Oct 2008 21:42:00 +0100
Message-ID: <49077918.4050706@cosmosbay.com>
References: <20081007160729.60c076c4@speedy>	<20081007.135548.56141000.davem@davemloft.net>	<48ECBBD8.9060602@cosmosbay.com> <20081008.114527.189056050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090409020203000903070001"
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	Christoph Lameter <clameter@sgi.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46925 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817AbYJ1Ups (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 16:45:48 -0400
In-Reply-To: <20081008.114527.189056050.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090409020203000903070001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

RCUification of UDP hash tables

Goals are :

1) Optimizing handling of incoming Unicast UDP frames, so that no memory
  writes should happen in the fast path. Using an array of rwlocks (one per
  slot for example is not an option in this regard)

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

In order to avoid loops, a reader must check each socket found in a chain
really belongs to the chain the reader was traversing. If it finds a
mismatch, lookup must start again at the begining. This *restart* loop
is the reason we had to use rdlock for the multicast case, because
we dont want to send same message several times to the same socket.

We use RCU only for fast path. Thus, /proc/net/udp still take rdlocks.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/sock.h |   37 ++++++++++++++++++++++++++++++++++++-
 net/core/sock.c    |    3 ++-
 net/ipv4/udp.c     |   35 ++++++++++++++++++++++++++---------
 net/ipv4/udplite.c |    1 +
 net/ipv6/udp.c     |   25 ++++++++++++++++++-------
 net/ipv6/udplite.c |    1 +
 6 files changed, 84 insertions(+), 18 deletions(-)

--------------090409020203000903070001
Content-Type: text/plain;
 name="PATCH_UDP.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="PATCH_UDP.2"

diff --git a/include/net/sock.h b/include/net/sock.h
index 4d630d5..5c1a781 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -361,6 +361,27 @@ static __inline__ int sk_del_node_init(struct sock *sk)
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
@@ -372,6 +393,17 @@ static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
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
@@ -385,6 +417,8 @@ static __inline__ void sk_add_bind_node(struct sock *sk,
 
 #define sk_for_each(__sk, node, list) \
 	hlist_for_each_entry(__sk, node, list, sk_node)
+#define sk_for_each_rcu(__sk, node, list) \
+	hlist_for_each_entry_rcu(__sk, node, list, sk_node)
 #define sk_for_each_from(__sk, node) \
 	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
 		hlist_for_each_entry_from(__sk, node, sk_node)
@@ -587,8 +621,9 @@ struct proto {
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
index 168276a..f0a573f 100644
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
 	write_unlock_bh(&hslot->lock);
@@ -252,15 +252,24 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
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
 
-	read_lock(&hslot->lock);
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
@@ -268,9 +277,16 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 			badness = score;
  		}
 	}
-	if (result)
-		sock_hold(result);
-	read_unlock(&hslot->lock);
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
 
@@ -952,7 +968,7 @@ void udp_lib_unhash(struct sock *sk)
 	struct udp_hslot *hslot = &udptable->hash[hash];
 
 	write_lock(&hslot->lock);
-	if (sk_del_node_init(sk)) {
+	if (sk_del_node_init_rcu(sk)) {
 		inet_sk(sk)->num = 0;
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 	}
@@ -1516,6 +1532,7 @@ struct proto udp_prot = {
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
index 0b76566..f7671af 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -97,24 +97,34 @@ static struct sock *__udp6_lib_lookup(struct net *net,
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
 
-	read_lock(&hslot->lock);
-	sk_for_each(sk, node, &hslot->head) {
+	rcu_read_lock();
+begin:
+	result = NULL;
+	badness = -1;
+	sk_for_each_rcu(sk, node, &hslot->head) {
 		score = compute_score(sk, net, hnum, saddr, sport, daddr, dport, dif);
 		if (score > badness) {
 			result = sk;
 			badness = score;
 		}
 	}
-	if (result)
-		sock_hold(result);
-	read_unlock(&hslot->lock);
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
 
@@ -1062,6 +1072,7 @@ struct proto udpv6_prot = {
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp6_sock),
+	.slab_flags	   = SLAB_DESTROY_BY_RCU,
 	.h.udp_table	   = &udp_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udpv6_setsockopt,
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index f67bbff..3e1663f 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -49,6 +49,7 @@ struct proto udplitev6_prot = {
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v6_get_port,
 	.obj_size	   = sizeof(struct udp6_sock),
+	.slab_flags	   = SLAB_DESTROY_BY_RCU,
 	.h.udp_table   = &udplite_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udpv6_setsockopt,

--------------090409020203000903070001--
