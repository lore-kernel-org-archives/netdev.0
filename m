From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 09/10] fib_trie: Move parent from key_vector to
 tnode
Date: Fri, 06 Mar 2015 09:54:46 -0800
Message-ID: <20150306175446.2452.77278.stgit@ahduyck-vm-fedora20>
References: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754987AbbCFRys (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 12:54:48 -0500
In-Reply-To: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change pulls the parent pointer from the key_vector and places it in
the tnode structure.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index acbed2d..b5fed2f 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -93,8 +93,6 @@ typedef unsigned int t_key;
 #define IS_LEAF(n) (!(n)->bits)
 
 struct key_vector {
-	struct key_vector __rcu *parent;
-
 	t_key key;
 	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
@@ -111,6 +109,7 @@ struct tnode {
 	struct rcu_head rcu;
 	t_key empty_children;		/* KEYLENGTH bits needed */
 	t_key full_children;		/* KEYLENGTH bits needed */
+	struct key_vector __rcu *parent;
 	struct key_vector kv[1];
 #define tn_bits kv[0].bits
 };
@@ -165,21 +164,21 @@ static inline struct tnode *tn_info(struct key_vector *kv)
 }
 
 /* caller must hold RTNL */
-#define node_parent(n) rtnl_dereference((n)->parent)
+#define node_parent(tn) rtnl_dereference(tn_info(tn)->parent)
 #define get_child(tn, i) rtnl_dereference((tn)->tnode[i])
 
 /* caller must hold RCU read lock or RTNL */
-#define node_parent_rcu(n) rcu_dereference_rtnl((n)->parent)
+#define node_parent_rcu(tn) rcu_dereference_rtnl(tn_info(tn)->parent)
 #define get_child_rcu(tn, i) rcu_dereference_rtnl((tn)->tnode[i])
 
 /* wrapper for rcu_assign_pointer */
 static inline void node_set_parent(struct key_vector *n, struct key_vector *tp)
 {
 	if (n)
-		rcu_assign_pointer(n->parent, tp);
+		rcu_assign_pointer(tn_info(n)->parent, tp);
 }
 
-#define NODE_INIT_PARENT(n, p) RCU_INIT_POINTER((n)->parent, p)
+#define NODE_INIT_PARENT(n, p) RCU_INIT_POINTER(tn_info(n)->parent, p)
 
 /* This provides us with the number of children in this node, in the case of a
  * leaf this will return 0 meaning none of the children are accessible.
