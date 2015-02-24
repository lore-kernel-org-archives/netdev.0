From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 18/29] fib_trie: Move parent from key_vector to tnode
Date: Tue, 24 Feb 2015 12:49:55 -0800
Message-ID: <20150224204955.26106.93183.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752913AbbBXUt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:49:56 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKnuH9018455
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:56 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKntLT031368
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:56 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change pulls the parent pointer from the key_vector and places it in
the tnode structure.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 4386db7..b2737b7 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -92,10 +92,9 @@ typedef unsigned int t_key;
 #define IS_LEAF(n) (!(n)->bits)
 
 struct key_vector {
-	struct key_vector __rcu *parent;
 	t_key key;
-	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
+	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char slen;
 	union {
 		/* This list pointer if valid if bits == 0 (LEAF) */
@@ -109,6 +108,7 @@ struct tnode {
 	struct rcu_head rcu;
 	t_key empty_children;		/* KEYLENGTH bits needed */
 	t_key full_children;		/* KEYLENGTH bits needed */
+	struct key_vector __rcu *parent;
 	struct key_vector kv[1];
 #define tn_bits kv[0].bits
 };
@@ -168,21 +168,21 @@ static inline struct fib_table *table_info(struct trie *t)
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
