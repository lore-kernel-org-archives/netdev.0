From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [RFC PATCH 4/4] inet: use second hash in inet_csk_get_port
Date: Wed, 30 May 2012 10:36:50 +0300
Message-ID: <1338363410-6562-5-git-send-email-alex.mihai.c@gmail.com>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
Cc: gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60430 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab2E3HjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 03:39:01 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so4725525wgb.1
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 00:39:01 -0700 (PDT)
In-Reply-To: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This results in a massive improvement when there are many sockets
bound to the same port, but different addresses for both bind() and
listen() system calls (both call inet_csk_get_port).

Tests were run with 16000 subinterfaces each with a distinct
IPv4 address. The sockets are first bound to the same port and
then put on listen().

* Without patch and without SO_REUSEADDR:
    * bind:   1.543 s
    * listen: 3.050 s

* Without patch and with SO_REUSEADDR set:
    * bind:   0.066 s
    * listen: 3.050 s

* With patch and SO_REUSEADDR set / without SO_REUSEADDR:
    * bind:   0.066 s
    * listen: 0.095 s

Signed-off-by: Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
Cc: Lucian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/inet_hashtables.h   |   48 +++++++++++++++
 net/ipv4/inet_connection_sock.c |   63 ++++++++------------
 net/ipv4/inet_hashtables.c      |  125 ++++++++++++++++++++++++++++++++++++++-
 net/ipv6/inet6_hashtables.c     |   95 +++++++++++++++++++++++++++++
 4 files changed, 292 insertions(+), 39 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index bc06168..2f589bb 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -81,6 +81,15 @@ struct inet_bind_bucket {
 	struct net		*ib_net;
 #endif
 	unsigned short		port;
+	union {
+		struct in6_addr ib_addr_ipv6;
+		struct {
+			__be32	_1;
+			__be32	_2;
+			__be32	_3;
+			__be32	ib_addr_ipv4;
+		};
+	};
 	signed short		fastreuse;
 	int			num_owners;
 	struct hlist_node	node;
@@ -226,6 +235,7 @@ static inline void inet_ehash_locks_free(struct inet_hashinfo *hashinfo)
 
 extern struct inet_bind_bucket *
 	    inet_bind_bucket_create(struct kmem_cache *cachep,
+				    struct sock *sk,
 				    struct net *net,
 				    struct inet_bind_hashbucket *head,
 				    struct inet_bind_hashbucket *portaddr_head,
@@ -257,6 +267,14 @@ static inline struct inet_bind_hashbucket *
 	return &hinfo->portaddr_bhash[h & (hinfo->portaddr_bhash_size - 1)];
 }
 
+
+struct inet_bind_bucket *
+inet4_find_bind_buckets(struct sock *sk,
+			unsigned short port,
+			struct inet_bind_hashbucket **p_bhead,
+			struct inet_bind_hashbucket **p_portaddr_bhead);
+
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static inline unsigned int inet6_portaddr_bhashfn(struct net *net,
 						  const struct in6_addr *addr6,
@@ -283,6 +301,14 @@ static inline struct inet_bind_hashbucket *
 	unsigned int h = inet6_portaddr_bhashfn(net, addr6, port);
 	return &hinfo->portaddr_bhash[h & (hinfo->portaddr_bhash_size - 1)];
 }
+
+
+struct inet_bind_bucket *
+	inet6_find_bind_buckets(struct sock *sk,
+				unsigned short port,
+				struct inet_bind_hashbucket **p_bhead,
+				struct inet_bind_hashbucket **p_portaddr_bhead);
+
 #endif
 
 
@@ -306,6 +332,28 @@ static inline struct inet_bind_hashbucket *
 	return inet4_portaddr_hashbucket(hinfo, net, INADDR_ANY, port);
 }
 
+
+static inline struct inet_bind_bucket *
+	inet_find_bind_buckets(struct sock *sk,
+			       unsigned short port,
+			       struct inet_bind_hashbucket **p_bhead,
+			       struct inet_bind_hashbucket **p_portaddr_bhead)
+{
+	switch (sk->sk_family) {
+	case AF_INET:
+		return inet4_find_bind_buckets(sk, port, p_bhead,
+				p_portaddr_bhead);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		return inet6_find_bind_buckets(sk, port, p_bhead,
+				p_portaddr_bhead);
+#endif
+	}
+	WARN(1, "unrecognised sk->sk_family in inet_portaddr_hashbucket");
+	return NULL;
+}
+
+
 extern void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 			   const unsigned short snum);
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 336531a..bd92466 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -100,8 +100,7 @@ EXPORT_SYMBOL_GPL(inet_csk_bind_conflict);
 int inet_csk_get_port(struct sock *sk, unsigned short snum)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
-	struct inet_bind_hashbucket *head;
-	struct hlist_node *node;
+	struct inet_bind_hashbucket *head, *portaddr_bhead;
 	struct inet_bind_bucket *tb;
 	int ret, attempts = 5;
 	struct net *net = sock_net(sk);
@@ -120,31 +119,26 @@ again:
 		do {
 			if (inet_is_reserved_local_port(rover))
 				goto next_nolock;
-			head = &hashinfo->bhash[inet_bhashfn(net, rover,
-					hashinfo->bhash_size)];
-			spin_lock(&head->lock);
-			inet_bind_bucket_for_each(tb, node, &head->chain)
-				if (net_eq(ib_net(tb), net) && tb->port == rover) {
-					if (tb->fastreuse > 0 &&
-					    sk->sk_reuse &&
-					    sk->sk_state != TCP_LISTEN &&
-					    (tb->num_owners < smallest_size || smallest_size == -1)) {
-						smallest_size = tb->num_owners;
-						smallest_rover = rover;
-						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1 &&
-						    !inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false)) {
-							snum = smallest_rover;
-							goto tb_found;
-						}
-					}
-					if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false)) {
-						snum = rover;
-						goto tb_found;
-					}
-					goto next;
+
+			tb = inet_find_bind_buckets(sk, rover, &head, &portaddr_bhead);
+			if (!tb)
+				break;
+			if (tb->fastreuse > 0 && sk->sk_reuse &&
+			    sk->sk_state != TCP_LISTEN &&
+			    (tb->num_owners < smallest_size || smallest_size == -1)) {
+				smallest_size = tb->num_owners;
+				smallest_rover = rover;
+				if (atomic_read(&hashinfo->bsockets) > (high - low) + 1 &&
+				    !inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false)) {
+					snum = smallest_rover;
+					goto tb_found;
 				}
-			break;
-		next:
+			}
+			if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false)) {
+				snum = rover;
+				goto tb_found;
+			}
+			spin_unlock(&portaddr_bhead->lock);
 			spin_unlock(&head->lock);
 		next_nolock:
 			if (++rover > high)
@@ -171,12 +165,9 @@ again:
 		snum = rover;
 	} else {
 have_snum:
-		head = &hashinfo->bhash[inet_bhashfn(net, snum,
-				hashinfo->bhash_size)];
-		spin_lock(&head->lock);
-		inet_bind_bucket_for_each(tb, node, &head->chain)
-			if (net_eq(ib_net(tb), net) && tb->port == snum)
-				goto tb_found;
+		tb = inet_find_bind_buckets(sk, snum, &head, &portaddr_bhead);
+		if (tb)
+			goto tb_found;
 	}
 	tb = NULL;
 	goto tb_not_found;
@@ -194,6 +185,7 @@ tb_found:
 			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
 				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
 				    smallest_size != -1 && --attempts >= 0) {
+					spin_unlock(&portaddr_bhead->lock);
 					spin_unlock(&head->lock);
 					goto again;
 				}
@@ -205,12 +197,8 @@ tb_found:
 tb_not_found:
 	ret = 1;
 	if (!tb) {
-		struct inet_bind_hashbucket *portaddr_head;
-		portaddr_head = inet_portaddr_hashbucket(hashinfo, sk, snum);
-		spin_lock(&portaddr_head->lock);
 		tb = inet_bind_bucket_create(hashinfo->bind_bucket_cachep,
-				net, head, portaddr_head, snum);
-		spin_unlock(&portaddr_head->lock);
+				sk, net, head, portaddr_bhead, snum);
 		if (!tb)
 			goto fail_unlock;
 	}
@@ -229,6 +217,7 @@ success:
 	ret = 0;
 
 fail_unlock:
+	spin_unlock(&portaddr_bhead->lock);
 	spin_unlock(&head->lock);
 fail:
 	local_bh_enable();
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index edb2a4e..26c7f9d 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -29,6 +29,7 @@
  * The bindhash mutex for snum's hash chain must be held here.
  */
 struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
+						 struct sock *sk,
 						 struct net *net,
 						 struct inet_bind_hashbucket *head,
 						 struct inet_bind_hashbucket *portaddr_head,
@@ -37,6 +38,32 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
 
 	if (tb != NULL) {
+		switch (sk->sk_family) {
+		case AF_INET:
+			/* ::ffff:x.y.z.y is the IPv4-mapped IPv6 address for
+			 * IPv4 address x.y.z.t, but only if it's not the any addr */
+			if (INADDR_ANY == sk_rcv_saddr(sk))
+				memset(&tb->ib_addr_ipv6, 0, sizeof(struct in6_addr));
+			else
+				ipv6_addr_set(&tb->ib_addr_ipv6, 0, 0,
+					      htonl(0x0000FFFF),
+					      sk_rcv_saddr(sk));
+
+			/* if no alignment problems appear, the IPv4 address
+			 * should be written to ib_addr_ipv6. If this gets
+			 * triggered check the inet_bind_bucket structure. */
+			WARN_ON(tb->ib_addr_ipv4 != sk_rcv_saddr(sk));
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case AF_INET6:
+			memcpy(&tb->ib_addr_ipv6, &inet6_sk(sk)->rcv_saddr,
+					sizeof(struct in6_addr));
+			break;
+#endif
+		default:
+			WARN(1, "unrecognised sk_family in inet_bind_bucket_create");
+		}
+
 		write_pnet(&tb->ib_net, hold_net(net));
 		tb->port      = snum;
 		tb->fastreuse = 0;
@@ -142,8 +169,10 @@ int __inet_inherit_port(struct sock *sk, struct sock *child)
 				break;
 		}
 		if (!node) {
+			portaddr_head = inet_portaddr_hashbucket(table, sk, tb->port);
+
 			tb = inet_bind_bucket_create(table->bind_bucket_cachep,
-						     sock_net(sk), head,
+						     sk, sock_net(sk), head,
 						     portaddr_head, port);
 			if (!tb) {
 				spin_unlock(&head->lock);
@@ -521,7 +550,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			portaddr_head = inet_portaddr_hashbucket(hinfo, sk, port);
 			spin_lock(&portaddr_head->lock);
 			tb = inet_bind_bucket_create(hinfo->bind_bucket_cachep,
-					net, head, portaddr_head, port);
+					sk, net, head, portaddr_head, port);
 			spin_unlock(&portaddr_head->lock);
 
 			if (!tb) {
@@ -584,6 +613,98 @@ out:
 	}
 }
 
+struct inet_bind_bucket *
+inet4_find_bind_buckets(struct sock *sk,
+			unsigned short port,
+			struct inet_bind_hashbucket **p_bhead,
+			struct inet_bind_hashbucket **p_portaddr_bhead)
+{
+	struct net *net = sock_net(sk);
+	struct inet_hashinfo *hinfo = sk->sk_prot->h.hashinfo;
+	struct inet_bind_bucket *tb = NULL;
+	struct hlist_node *node;
+
+	struct inet_bind_hashbucket *bhead, *portaddr_bhead, *portaddrany_bhead;
+	bhead = &hinfo->bhash[inet_bhashfn(net, port, hinfo->bhash_size)];
+	portaddr_bhead = inet4_portaddr_hashbucket(hinfo, net,
+				sk_rcv_saddr(sk), port);
+	portaddrany_bhead = inet4_portaddr_hashbucket(hinfo, net,
+						INADDR_ANY, port);
+
+	*p_portaddr_bhead = portaddr_bhead;
+	*p_bhead = bhead;
+
+	/*
+	 * prevent dead locks by always taking locks in a fixed order:
+	 * - always take the port-only lock first. This is done because in some
+	 *   other places this is the lock taken, being folllowed in only some
+	 *   cases by the portaddr lock.
+	 * - between portaddr and portaddrany always choose the one with the
+	 *   lower address. Unlock ordering is not important, as long as the
+	 *   locking order is consistent.
+	 * - make sure to not take the same lock twice
+	 */
+	spin_lock(&bhead->lock);
+	if (portaddr_bhead > portaddrany_bhead) {
+		spin_lock(&portaddrany_bhead->lock);
+		spin_lock(&portaddr_bhead->lock);
+	} else if (portaddr_bhead < portaddrany_bhead) {
+		spin_lock(&portaddr_bhead->lock);
+		spin_lock(&portaddrany_bhead->lock);
+	} else {
+		spin_lock(&portaddr_bhead->lock);
+	}
+
+	if (sk_rcv_saddr(sk) != INADDR_ANY) {
+		struct inet_bind_hashbucket *_head;
+
+		_head = portaddr_bhead;
+		if (bhead->count < portaddr_bhead->count) {
+			_head = bhead;
+			inet_bind_bucket_for_each(tb, node, &_head->chain)
+				if ((net_eq(ib_net(tb), net)) &&
+				    (tb->port == port) &&
+				    (tb->ib_addr_ipv4 == sk_rcv_saddr(sk)))
+					goto found;
+		} else {
+			inet_portaddr_bind_bucket_for_each(tb, node, &_head->chain)
+				if ((net_eq(ib_net(tb), net)) &&
+				    (tb->port == port) &&
+				    (tb->ib_addr_ipv4 == sk_rcv_saddr(sk)))
+					goto found;
+		}
+		_head = portaddrany_bhead;
+		if (bhead->count < portaddrany_bhead->count) {
+			_head = bhead;
+			inet_bind_bucket_for_each(tb, node, &_head->chain)
+				if ((ib_net(tb) == net) &&
+				    (tb->port == port) &&
+				    (tb->ib_addr_ipv4 == INADDR_ANY))
+					goto found;
+		} else {
+			inet_portaddr_bind_bucket_for_each(tb, node, &_head->chain)
+				if ((ib_net(tb) == net) &&
+				    (tb->port == port) &&
+				    (tb->ib_addr_ipv4 == INADDR_ANY))
+					goto found;
+		}
+	} else {
+		inet_bind_bucket_for_each(tb, node, &bhead->chain)
+			if ((ib_net(tb) == net) && (tb->port == port))
+				goto found;
+	}
+
+	tb = NULL;
+found:
+	if (portaddr_bhead != portaddrany_bhead)
+		spin_unlock(&portaddrany_bhead->lock);
+
+	/* the other locks remain taken, as the caller
+	 * may want to change the hash tabels */
+	return tb;
+}
+
+
 /*
  * Bind a port for a connect operation and hash it.
  */
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 73f1a00..62f1eff 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -294,6 +294,101 @@ static inline u32 inet6_sk_port_offset(const struct sock *sk)
 					  inet->inet_dport);
 }
 
+
+struct inet_bind_bucket *
+inet6_find_bind_buckets(struct sock *sk,
+			unsigned short port,
+			struct inet_bind_hashbucket **p_bhead,
+			struct inet_bind_hashbucket **p_portaddr_bhead)
+{
+	struct net *net = sock_net(sk);
+	struct inet_hashinfo *hinfo = sk->sk_prot->h.hashinfo;
+	struct inet_bind_bucket *tb = NULL;
+	struct hlist_node *node;
+
+	struct inet_bind_hashbucket *bhead, *portaddr_bhead, *portaddrany_bhead;
+	bhead = &hinfo->bhash[inet_bhashfn(net, port, hinfo->bhash_size)];
+	portaddr_bhead = inet6_portaddr_hashbucket(hinfo, net,
+				inet6_rcv_saddr(sk), port);
+	portaddrany_bhead = inet6_portaddr_hashbucket(hinfo, net,
+				&in6addr_any, port);
+
+	*p_portaddr_bhead = portaddr_bhead;
+	*p_bhead = bhead;
+
+	/*
+	 * prevent dead locks by always taking locks in a fixed order:
+	 * - always take the port-only lock first. This is done because in some
+	 *   other places this is the lock taken, being folllowed in only some
+	 *   cases by the portaddr lock.
+	 * - between portaddr and portaddrany always choose the one with the
+	 *   lower address. Unlock ordering is not important, as long as the
+	 *   locking order is consistent.
+	 * - make sure to not take the same lock twice
+	 */
+	spin_lock(&bhead->lock);
+	if (portaddr_bhead > portaddrany_bhead) {
+		spin_lock(&portaddrany_bhead->lock);
+		spin_lock(&portaddr_bhead->lock);
+	} else if (portaddr_bhead < portaddrany_bhead) {
+		spin_lock(&portaddr_bhead->lock);
+		spin_lock(&portaddrany_bhead->lock);
+	} else {
+		spin_lock(&portaddr_bhead->lock);
+	}
+
+	if (ipv6_addr_any(inet6_rcv_saddr(sk))) {
+		struct inet_bind_hashbucket *_head;
+
+		_head = portaddr_bhead;
+		if (bhead->count < portaddr_bhead->count) {
+			_head = bhead;
+			inet_bind_bucket_for_each(tb, node, &_head->chain)
+				if ((net_eq(ib_net(tb), net)) &&
+				    (tb->port == port) &&
+				    ipv6_addr_equal(&tb->ib_addr_ipv6,
+						    inet6_rcv_saddr(sk)))
+					goto found;
+		} else {
+			inet_portaddr_bind_bucket_for_each(tb, node, &_head->chain)
+				if ((net_eq(ib_net(tb), net)) &&
+				    (tb->port == port) &&
+				    ipv6_addr_equal(&tb->ib_addr_ipv6,
+						    inet6_rcv_saddr(sk)))
+					goto found;
+		}
+		_head = portaddrany_bhead;
+		if (bhead->count < portaddrany_bhead->count) {
+			_head = bhead;
+			inet_bind_bucket_for_each(tb, node, &_head->chain)
+				if ((ib_net(tb) == net) &&
+				    (tb->port == port) &&
+				    ipv6_addr_any(&tb->ib_addr_ipv6))
+					goto found;
+		} else {
+			inet_portaddr_bind_bucket_for_each(tb, node, &_head->chain)
+				if ((ib_net(tb) == net) &&
+				    (tb->port == port) &&
+				    ipv6_addr_any(&tb->ib_addr_ipv6))
+					goto found;
+		}
+	} else {
+		inet_bind_bucket_for_each(tb, node, &bhead->chain)
+			if ((ib_net(tb) == net) && (tb->port == port))
+				goto found;
+	}
+
+	tb = NULL;
+found:
+	if (portaddr_bhead != portaddrany_bhead)
+		spin_unlock(&portaddrany_bhead->lock);
+
+	/* the other locks remain taken, as the caller
+	 * may want to change the hash tabels */
+	return tb;
+}
+
+
 int inet6_hash_connect(struct inet_timewait_death_row *death_row,
 		       struct sock *sk)
 {
-- 
1.7.10.2
