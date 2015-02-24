From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 23/29] fib_trie: Add leaf_init
Date: Tue, 24 Feb 2015 12:50:30 -0800
Message-ID: <20150224205030.26106.12411.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54293 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753066AbbBXUub (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:50:31 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKoVsx009167
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:31 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKoUqH015357
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:31 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the leaf will now need to configure an entry in the key_vector array
of the parent I am adding a new function called leaf_init.  It will
eventually replace leaf_new as we begin to pull fields out of the leaf
key_vector and push them into the parent.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index f9abbf4..65ea194 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -412,6 +412,31 @@ static inline void put_child_root(struct key_vector *tp, t_key key,
 		put_child(tp, get_index(key, tp), n);
 }
 
+static void leaf_init(struct key_vector *tn, t_key key, struct key_vector *l)
+{
+	/* link leaf to parent */
+	NODE_INIT_PARENT(l, tn);
+
+	/* update parent node stats */
+	if (!IS_TRIE(tn)) {
+		unsigned long i = get_index(key, tn);
+		struct key_vector *n = get_child(tn + i);
+
+		BUG_ON(i >= child_length(tn));
+
+		if (!n)
+			empty_child_dec(tn);
+		else if (tnode_full(tn, n))
+			tn_info(tn)->full_children--;
+
+		/* update offset to correct key_vector for update */
+		tn += i;
+	}
+
+	/* populate key vector */
+	rcu_assign_pointer(tn->tnode, l);
+}
+
 static struct key_vector *tnode_new(struct key_vector *pn, t_key key,
 				    int pos, int bits)
 {
@@ -1128,8 +1153,7 @@ static struct fib_table *fib_insert_node(struct net *net, struct trie *t,
 	}
 
 	/* Case 3: n is NULL, and will just insert a new leaf */
-	NODE_INIT_PARENT(l, n);
-	put_child_root(n, key, l);
+	leaf_init(n, key, l);
 
 	vector_replace(net, tp, tn);
 
