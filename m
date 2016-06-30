From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 19/19] rxrpc: Use RCU to access a peer's service connection tree
Date: Thu, 30 Jun 2016 17:36:51 +0100
Message-ID: <587.1467304611@warthog.procyon.org.uk>
References: <19436.1467303739@warthog.procyon.org.uk> <20160630153049.GG30935@twins.programming.kicks-ass.net> <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk> <146729597856.26306.17024362508555652794.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752625AbcF3QqD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 12:46:03 -0400
In-Reply-To: <19436.1467303739@warthog.procyon.org.uk>
Content-ID: <586.1467304611.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> > You want rb_link_node_rcu() here.
> 
> Should there be an rb_replace_node_rcu() also?

Or I could make rb_replace_node() RCU friendly.  What do you think of the
attached changes (split into appropriate patches)?  It's a case of changing
the order in which pointers are set in the rbtree code and inserting a
barrier.

I also wonder if rb_insert_color() needs some attention - though possibly
that's okay as it doesn't start with unset pointers (since you call
rb_link_node_rcu() first).

David
---
diff --git a/include/linux/rbtree_augmented.h b/include/linux/rbtree_augmented.h
index 14d7b831b63a..d076183e49be 100644
--- a/include/linux/rbtree_augmented.h
+++ b/include/linux/rbtree_augmented.h
@@ -130,6 +130,19 @@ __rb_change_child(struct rb_node *old, struct rb_node *new,
 		WRITE_ONCE(root->rb_node, new);
 }
 
+static inline void
+__rb_change_child_rcu(struct rb_node *old, struct rb_node *new,
+		      struct rb_node *parent, struct rb_root *root)
+{
+	if (parent) {
+		if (parent->rb_left == old)
+			rcu_assign_pointer(parent->rb_left, new);
+		else
+			rcu_assign_pointer(parent->rb_right, new);
+	} else
+		rcu_assign_pointer(root->rb_node, new);
+}
+
 extern void __rb_erase_color(struct rb_node *parent, struct rb_root *root,
 	void (*augment_rotate)(struct rb_node *old, struct rb_node *new));
 
diff --git a/lib/rbtree.c b/lib/rbtree.c
index 1356454e36de..2b1a190c737c 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -539,15 +539,17 @@ void rb_replace_node(struct rb_node *victim, struct rb_node *new,
 {
 	struct rb_node *parent = rb_parent(victim);
 
+	/* Copy the pointers/colour from the victim to the replacement */
+	*new = *victim;
+
 	/* Set the surrounding nodes to point to the replacement */
-	__rb_change_child(victim, new, parent, root);
 	if (victim->rb_left)
 		rb_set_parent(victim->rb_left, new);
 	if (victim->rb_right)
 		rb_set_parent(victim->rb_right, new);
 
-	/* Copy the pointers/colour from the victim to the replacement */
-	*new = *victim;
+	/* Set the onward pointer last with an RCU barrier */
+	__rb_change_child_rcu(victim, new, parent, root);
 }
 EXPORT_SYMBOL(rb_replace_node);
 
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index dc64211c5ee8..298ec300cfcc 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -41,14 +41,14 @@ struct rxrpc_connection *rxrpc_find_service_conn_rcu(struct rxrpc_peer *peer,
 		 */
 		read_seqbegin_or_lock(&peer->service_conn_lock, &seq);
 
-		p = peer->service_conns.rb_node;
+		p = rcu_dereference(peer->service_conns.rb_node);
 		while (p) {
 			conn = rb_entry(p, struct rxrpc_connection, service_node);
 
 			if (conn->proto.index_key < k.index_key)
-				p = p->rb_left;
+				p = rcu_dereference(p->rb_left);
 			else if (conn->proto.index_key > k.index_key)
-				p = p->rb_right;
+				p = rcu_dereference(p->rb_right);
 			else
 				goto done;
 			conn = NULL;
@@ -90,7 +90,7 @@ rxrpc_publish_service_conn(struct rxrpc_peer *peer,
 			goto found_extant_conn;
 	}
 
-	rb_link_node(&conn->service_node, parent, pp);
+	rb_link_node_rcu(&conn->service_node, parent, pp);
 	rb_insert_color(&conn->service_node, &peer->service_conns);
 conn_published:
 	set_bit(RXRPC_CONN_IN_SERVICE_CONNS, &conn->flags);
