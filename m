From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inetpeer: inetpeer_invalidate_tree() cleanup
Date: Wed, 20 Jun 2012 16:02:10 +0200
Message-ID: <1340200930.4604.1028.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45602 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756310Ab2FTOCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 10:02:14 -0400
Received: by bkcji2 with SMTP id ji2so6204541bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 07:02:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

No need to use cmpxchg() in inetpeer_invalidate_tree() since we hold
base lock.

Also use correct rcu annotations to remove sparse errors
(CONFIG_SPARSE_RCU_POINTER=y)

net/ipv4/inetpeer.c:144:19: error: incompatible types in comparison
expression (different address spaces)
net/ipv4/inetpeer.c:149:20: error: incompatible types in comparison
expression (different address spaces)
net/ipv4/inetpeer.c:595:10: error: incompatible types in comparison
expression (different address spaces)


Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/inetpeer.c |   34 +++++++++++++++-------------------
 1 file changed, 15 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index cac02ad..da90a8c 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -126,7 +126,7 @@ int inet_peer_maxttl __read_mostly = 10 * 60 * HZ;	/* usual time to live: 10 min
 
 static void inetpeer_gc_worker(struct work_struct *work)
 {
-	struct inet_peer *p, *n;
+	struct inet_peer *p, *n, *c;
 	LIST_HEAD(list);
 
 	spin_lock_bh(&gc_lock);
@@ -138,17 +138,19 @@ static void inetpeer_gc_worker(struct work_struct *work)
 
 	list_for_each_entry_safe(p, n, &list, gc_list) {
 
-		if(need_resched())
+		if (need_resched())
 			cond_resched();
 
-		if (p->avl_left != peer_avl_empty) {
-			list_add_tail(&p->avl_left->gc_list, &list);
-			p->avl_left = peer_avl_empty;
+		c = rcu_dereference_protected(p->avl_left, 1);
+		if (c != peer_avl_empty) {
+			list_add_tail(&c->gc_list, &list);
+			p->avl_left = peer_avl_empty_rcu;
 		}
 
-		if (p->avl_right != peer_avl_empty) {
-			list_add_tail(&p->avl_right->gc_list, &list);
-			p->avl_right = peer_avl_empty;
+		c = rcu_dereference_protected(p->avl_right, 1);
+		if (c != peer_avl_empty) {
+			list_add_tail(&c->gc_list, &list);
+			p->avl_right = peer_avl_empty_rcu;
 		}
 
 		n = list_entry(p->gc_list.next, struct inet_peer, gc_list);
@@ -587,23 +589,17 @@ static void inetpeer_inval_rcu(struct rcu_head *head)
 
 void inetpeer_invalidate_tree(struct inet_peer_base *base)
 {
-	struct inet_peer *old, *new, *prev;
+	struct inet_peer *root;
 
 	write_seqlock_bh(&base->lock);
 
-	old = base->root;
-	if (old == peer_avl_empty_rcu)
-		goto out;
-
-	new = peer_avl_empty_rcu;
-
-	prev = cmpxchg(&base->root, old, new);
-	if (prev == old) {
+	root = rcu_deref_locked(base->root, base);
+	if (root != peer_avl_empty) {
+		base->root = peer_avl_empty_rcu;
 		base->total = 0;
-		call_rcu(&prev->gc_rcu, inetpeer_inval_rcu);
+		call_rcu(&root->gc_rcu, inetpeer_inval_rcu);
 	}
 
-out:
 	write_sequnlock_bh(&base->lock);
 }
 EXPORT_SYMBOL(inetpeer_invalidate_tree);
