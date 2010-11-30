From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/8] inetpeer: Make inet_getpeer() take an
 inet_peer_adress_t pointer.
Date: Tue, 30 Nov 2010 13:22:01 -0800 (PST)
Message-ID: <20101130.132201.102572222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58854
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751682Ab0K3VVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 16:21:35 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D153824C08A
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 13:22:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And make an inet_getpeer_v4() helper, update callers.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |   11 ++++++++++-
 net/ipv4/inetpeer.c    |   10 +++++-----
 net/ipv4/ip_fragment.c |    2 +-
 net/ipv4/route.c       |    2 +-
 net/ipv4/tcp_ipv4.c    |    4 ++--
 5 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index d7e6079..834f045 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -50,7 +50,16 @@ struct inet_peer {
 void			inet_initpeers(void) __init;
 
 /* can be called with or without local BH being disabled */
-struct inet_peer	*inet_getpeer(__be32 daddr, int create);
+struct inet_peer	*inet_getpeer(inet_peer_address_t *daddr, int create);
+
+static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
+{
+	inet_peer_address_t daddr;
+
+	daddr.a4 = v4daddr;
+	daddr.family = AF_INET;
+	return inet_getpeer(&daddr, create);
+}
 
 /* can be called from BH context or outside */
 extern void inet_putpeer(struct inet_peer *p);
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 893f998..9aa76b8 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -444,7 +444,7 @@ static struct inet_peer_base *family_to_base(int family)
 }
 
 /* Called with or without local BH being disabled. */
-struct inet_peer *inet_getpeer(__be32 daddr, int create)
+struct inet_peer *inet_getpeer(inet_peer_address_t *daddr, int create)
 {
 	struct inet_peer __rcu **stack[PEER_MAXDEPTH], ***stackptr;
 	struct inet_peer_base *base = family_to_base(AF_INET);
@@ -454,7 +454,7 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 	 * Because of a concurrent writer, we might not find an existing entry.
 	 */
 	rcu_read_lock_bh();
-	p = lookup_rcu_bh(daddr, base);
+	p = lookup_rcu_bh(daddr->a4, base);
 	rcu_read_unlock_bh();
 
 	if (p) {
@@ -469,7 +469,7 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 	 * At least, nodes should be hot in our cache.
 	 */
 	spin_lock_bh(&base->lock);
-	p = lookup(daddr, stack, base);
+	p = lookup(daddr->a4, stack, base);
 	if (p != peer_avl_empty) {
 		atomic_inc(&p->refcnt);
 		spin_unlock_bh(&base->lock);
@@ -479,10 +479,10 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 	}
 	p = create ? kmem_cache_alloc(peer_cachep, GFP_ATOMIC) : NULL;
 	if (p) {
-		p->daddr.a4 = daddr;
+		p->daddr = *daddr;
 		atomic_set(&p->refcnt, 1);
 		atomic_set(&p->rid, 0);
-		atomic_set(&p->ip_id_count, secure_ip_id(daddr));
+		atomic_set(&p->ip_id_count, secure_ip_id(daddr->a4));
 		p->tcp_ts_stamp = 0;
 		INIT_LIST_HEAD(&p->unused);
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 1684408..e6215bd 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -141,7 +141,7 @@ static void ip4_frag_init(struct inet_frag_queue *q, void *a)
 	qp->daddr = arg->iph->daddr;
 	qp->user = arg->user;
 	qp->peer = sysctl_ipfrag_max_dist ?
-		inet_getpeer(arg->iph->saddr, 1) : NULL;
+		inet_getpeer_v4(arg->iph->saddr, 1) : NULL;
 }
 
 static __inline__ void ip4_frag_free(struct inet_frag_queue *q)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ec2333f..3843c2d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1289,7 +1289,7 @@ void rt_bind_peer(struct rtable *rt, int create)
 {
 	struct inet_peer *peer;
 
-	peer = inet_getpeer(rt->rt_dst, create);
+	peer = inet_getpeer_v4(rt->rt_dst, create);
 
 	if (peer && cmpxchg(&rt->peer, NULL, peer) != NULL)
 		inet_putpeer(peer);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b8bbf89..00285fc 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1778,7 +1778,7 @@ int tcp_v4_remember_stamp(struct sock *sk)
 	int release_it = 0;
 
 	if (!rt || rt->rt_dst != inet->inet_daddr) {
-		peer = inet_getpeer(inet->inet_daddr, 1);
+		peer = inet_getpeer_v4(inet->inet_daddr, 1);
 		release_it = 1;
 	} else {
 		if (!rt->peer)
@@ -1804,7 +1804,7 @@ EXPORT_SYMBOL(tcp_v4_remember_stamp);
 
 int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw)
 {
-	struct inet_peer *peer = inet_getpeer(tw->tw_daddr, 1);
+	struct inet_peer *peer = inet_getpeer_v4(tw->tw_daddr, 1);
 
 	if (peer) {
 		const struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
-- 
1.7.3.2

