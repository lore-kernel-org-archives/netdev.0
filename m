From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/8] inetpeer: Abstract address comparisons.
Date: Tue, 30 Nov 2010 13:22:04 -0800 (PST)
Message-ID: <20101130.132204.179955630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58857
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751526Ab0K3VVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 16:21:37 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5B2D624C08A
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 13:22:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now v4 and v6 addresses will both work properly.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inetpeer.c |   35 +++++++++++++++++++++++++++--------
 1 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 9aa76b8..c96dc51 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -152,6 +152,22 @@ static void unlink_from_unused(struct inet_peer *p)
 	}
 }
 
+static int addr_compare(const inet_peer_address_t *a,
+			const inet_peer_address_t *b)
+{
+	int i, n = (a->family == AF_INET ? 1 : 4);
+
+	for (i = 0; i < n; i++) {
+		if (a->a6[i] == b->a6[i])
+			continue;
+		if (a->a6[i] < b->a6[i])
+			return -1;
+		return 1;
+	}
+
+	return 0;
+}
+
 /*
  * Called with local BH disabled and the pool lock held.
  */
@@ -165,9 +181,10 @@ static void unlink_from_unused(struct inet_peer *p)
 	for (u = rcu_dereference_protected(_base->root,		\
 			lockdep_is_held(&_base->lock));		\
 	     u != peer_avl_empty; ) {				\
-		if (_daddr == u->daddr.a4)			\
+		int cmp = addr_compare(_daddr, &u->daddr);	\
+		if (cmp == 0)					\
 			break;					\
-		if ((__force __u32)_daddr < (__force __u32)u->daddr.a4)	\
+		if (cmp == -1)					\
 			v = &u->avl_left;			\
 		else						\
 			v = &u->avl_right;			\
@@ -185,13 +202,15 @@ static void unlink_from_unused(struct inet_peer *p)
  * But every pointer we follow is guaranteed to be valid thanks to RCU.
  * We exit from this function if number of links exceeds PEER_MAXDEPTH
  */
-static struct inet_peer *lookup_rcu_bh(__be32 daddr, struct inet_peer_base *base)
+static struct inet_peer *lookup_rcu_bh(const inet_peer_address_t *daddr,
+				       struct inet_peer_base *base)
 {
 	struct inet_peer *u = rcu_dereference_bh(base->root);
 	int count = 0;
 
 	while (u != peer_avl_empty) {
-		if (daddr == u->daddr.a4) {
+		int cmp = addr_compare(daddr, &u->daddr);
+		if (cmp == 0) {
 			/* Before taking a reference, check if this entry was
 			 * deleted, unlink_from_pool() sets refcnt=-1 to make
 			 * distinction between an unused entry (refcnt=0) and
@@ -201,7 +220,7 @@ static struct inet_peer *lookup_rcu_bh(__be32 daddr, struct inet_peer_base *base
 				u = NULL;
 			return u;
 		}
-		if ((__force __u32)daddr < (__force __u32)u->daddr.a4)
+		if (cmp == -1)
 			u = rcu_dereference_bh(u->avl_left);
 		else
 			u = rcu_dereference_bh(u->avl_right);
@@ -354,7 +373,7 @@ static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base)
 	if (atomic_cmpxchg(&p->refcnt, 1, -1) == 1) {
 		struct inet_peer __rcu **stack[PEER_MAXDEPTH];
 		struct inet_peer __rcu ***stackptr, ***delp;
-		if (lookup(p->daddr.a4, stack, base) != p)
+		if (lookup(&p->daddr, stack, base) != p)
 			BUG();
 		delp = stackptr - 1; /* *delp[0] == p */
 		if (p->avl_left == peer_avl_empty_rcu) {
@@ -454,7 +473,7 @@ struct inet_peer *inet_getpeer(inet_peer_address_t *daddr, int create)
 	 * Because of a concurrent writer, we might not find an existing entry.
 	 */
 	rcu_read_lock_bh();
-	p = lookup_rcu_bh(daddr->a4, base);
+	p = lookup_rcu_bh(daddr, base);
 	rcu_read_unlock_bh();
 
 	if (p) {
@@ -469,7 +488,7 @@ struct inet_peer *inet_getpeer(inet_peer_address_t *daddr, int create)
 	 * At least, nodes should be hot in our cache.
 	 */
 	spin_lock_bh(&base->lock);
-	p = lookup(daddr->a4, stack, base);
+	p = lookup(daddr, stack, base);
 	if (p != peer_avl_empty) {
 		atomic_inc(&p->refcnt);
 		spin_unlock_bh(&base->lock);
-- 
1.7.3.2

