From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/8] inetpeer: Introduce inet_peer_address_t.
Date: Tue, 30 Nov 2010 13:21:59 -0800 (PST)
Message-ID: <20101130.132159.28791471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58851
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751682Ab0K3VVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 16:21:32 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7AF1424C088
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 13:21:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently only the v4 aspect is used, but this will change.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |   10 +++++++++-
 net/ipv4/inetpeer.c    |   16 ++++++++--------
 net/ipv4/tcp_ipv4.c    |    2 +-
 3 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index fe239bf..d7e6079 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -13,10 +13,18 @@
 #include <linux/spinlock.h>
 #include <asm/atomic.h>
 
+typedef struct {
+	union {
+		__be32		a4;
+		__be32		a6[4];
+	};
+	__u16	family;
+} inet_peer_address_t;
+
 struct inet_peer {
 	/* group together avl_left,avl_right,v4daddr to speedup lookups */
 	struct inet_peer __rcu	*avl_left, *avl_right;
-	__be32			v4daddr;	/* peer's address */
+	inet_peer_address_t	daddr;
 	__u32			avl_height;
 	struct list_head	unused;
 	__u32			dtime;		/* the time of last use of not
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index f944008..893f998 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -63,7 +63,7 @@
  *		refcnt: atomically against modifications on other CPU;
  *		   usually under some other lock to prevent node disappearing
  *		dtime: unused node list lock
- *		v4daddr: unchangeable
+ *		daddr: unchangeable
  *		ip_id_count: atomic value (no lock needed)
  */
 
@@ -165,9 +165,9 @@ static void unlink_from_unused(struct inet_peer *p)
 	for (u = rcu_dereference_protected(_base->root,		\
 			lockdep_is_held(&_base->lock));		\
 	     u != peer_avl_empty; ) {				\
-		if (_daddr == u->v4daddr)			\
+		if (_daddr == u->daddr.a4)			\
 			break;					\
-		if ((__force __u32)_daddr < (__force __u32)u->v4daddr)	\
+		if ((__force __u32)_daddr < (__force __u32)u->daddr.a4)	\
 			v = &u->avl_left;			\
 		else						\
 			v = &u->avl_right;			\
@@ -191,7 +191,7 @@ static struct inet_peer *lookup_rcu_bh(__be32 daddr, struct inet_peer_base *base
 	int count = 0;
 
 	while (u != peer_avl_empty) {
-		if (daddr == u->v4daddr) {
+		if (daddr == u->daddr.a4) {
 			/* Before taking a reference, check if this entry was
 			 * deleted, unlink_from_pool() sets refcnt=-1 to make
 			 * distinction between an unused entry (refcnt=0) and
@@ -201,7 +201,7 @@ static struct inet_peer *lookup_rcu_bh(__be32 daddr, struct inet_peer_base *base
 				u = NULL;
 			return u;
 		}
-		if ((__force __u32)daddr < (__force __u32)u->v4daddr)
+		if ((__force __u32)daddr < (__force __u32)u->daddr.a4)
 			u = rcu_dereference_bh(u->avl_left);
 		else
 			u = rcu_dereference_bh(u->avl_right);
@@ -354,7 +354,7 @@ static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base)
 	if (atomic_cmpxchg(&p->refcnt, 1, -1) == 1) {
 		struct inet_peer __rcu **stack[PEER_MAXDEPTH];
 		struct inet_peer __rcu ***stackptr, ***delp;
-		if (lookup(p->v4daddr, stack, base) != p)
+		if (lookup(p->daddr.a4, stack, base) != p)
 			BUG();
 		delp = stackptr - 1; /* *delp[0] == p */
 		if (p->avl_left == peer_avl_empty_rcu) {
@@ -367,7 +367,7 @@ static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base)
 			BUG_ON(rcu_dereference_protected(*stackptr[-1],
 					lockdep_is_held(&base->lock)) != t);
 			**--stackptr = t->avl_left;
-			/* t is removed, t->v4daddr > x->v4daddr for any
+			/* t is removed, t->daddr > x->daddr for any
 			 * x in p->avl_left subtree.
 			 * Put t in the old place of p. */
 			RCU_INIT_POINTER(*delp[0], t);
@@ -479,7 +479,7 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 	}
 	p = create ? kmem_cache_alloc(peer_cachep, GFP_ATOMIC) : NULL;
 	if (p) {
-		p->v4daddr = daddr;
+		p->daddr.a4 = daddr;
 		atomic_set(&p->refcnt, 1);
 		atomic_set(&p->rid, 0);
 		atomic_set(&p->ip_id_count, secure_ip_id(daddr));
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 69ccbc1..b8bbf89 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1347,7 +1347,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		    tcp_death_row.sysctl_tw_recycle &&
 		    (dst = inet_csk_route_req(sk, req)) != NULL &&
 		    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
-		    peer->v4daddr == saddr) {
+		    peer->daddr.a4 == saddr) {
 			inet_peer_refcheck(peer);
 			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
 			    (s32)(peer->tcp_ts - req->ts_recent) >
-- 
1.7.3.2

