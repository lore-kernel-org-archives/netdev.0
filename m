From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 24/29] fib_trie: Update tnode_new to drop use of
 put_child_root
Date: Tue, 24 Feb 2015 12:50:36 -0800
Message-ID: <20150224205036.26106.23633.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59644 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079AbbBXUui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:50:38 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKobHA021289
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:38 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKoaNK030783
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:37 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the tnode_new function will now insert itself
into the parent.  This is to enable the eventual moving of fields from the
key_vector of the local node into the parent.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   47 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 35 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 65ea194..e91233b 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -437,40 +437,63 @@ static void leaf_init(struct key_vector *tn, t_key key, struct key_vector *l)
 	rcu_assign_pointer(tn->tnode, l);
 }
 
-static struct key_vector *tnode_new(struct key_vector *pn, t_key key,
+static struct key_vector *tnode_new(struct key_vector *tn, t_key key,
 				    int pos, int bits)
 {
 	size_t sz = TNODE_SIZE(1ul << bits);
 	struct tnode *tnode = tnode_alloc(sz);
-	struct key_vector *tn = tnode->kv;
 	unsigned int shift = pos + bits;
+	unsigned long i;
 
 	/* verify bits and pos their msb bits clear and values are valid */
 	BUG_ON(!bits || (shift > KEYLENGTH));
 
-	pr_debug("AT %p s=%zu %zu\n", tnode, TNODE_SIZE(0),
-		 sizeof(struct key_vector *) << bits);
+	pr_debug("AT %p s=%zu %zu\n", tnode, TNODE_SIZE(0), sz - TNODE_SIZE(0));
 
 	if (!tnode)
 		return NULL;
 
+	/* link tnode to parent */
+	NODE_INIT_PARENT(tnode->kv, tn);
+
+	/* update parent node stats */
+	if (!IS_TRIE(tn)) {
+		unsigned long idx = get_index(key, tn);
+		struct key_vector *n = get_child(tn + idx);
+
+		BUG_ON(idx >= child_length(tn));
+
+		if (!n)
+			empty_child_dec(tn);
+		else if (tnode_full(tn, n))
+			tn_info(tn)->full_children--;
+		if ((pos + bits) == tn->pos)
+			tn_info(tn)->full_children++;
+
+		/* update offset to correct key_vector for update */
+		tn += idx;
+	}
+
 	/* populate tn_info section */
+	key = (shift < KEYLENGTH) ? (key >> shift) << shift : 0;
 	if (bits == KEYLENGTH)
 		tnode->full_children = 1;
 	else
 		tnode->empty_children = 1ul << bits;
 
+	/* populate keys as though we are full of leaves */
+	for (i = (1ul << bits); i--;)
+		tnode->kv[i].key = key + (i << pos);
+
 	/* populate key vector */
-	tn->key = (shift < KEYLENGTH) ? (key >> shift) << shift : 0;
-	tn->pos = pos;
-	tn->bits = bits;
-	tn->slen = pos;
+	tnode->kv[0].pos = pos;
+	tnode->kv[0].bits = bits;
+	tnode->kv[0].slen = pos;
 
 	/* link parent to node */
-	NODE_INIT_PARENT(tn, pn);
-	put_child_root(pn, tn->key, tn);
+	rcu_assign_pointer(tn->tnode, tnode->kv);
 
-	return tn;
+	return tnode->kv;
 }
 
 static struct key_vector *tnode_clone(struct tnode *oldtnode)
@@ -2256,7 +2279,7 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 		fib_table_print(seq, iter->tb);
 
 	if (IS_TNODE(n)) {
-		__be32 prf = htonl(n->key);
+		__be32 prf = htonl((n->key >> n->pos) << n->pos);
 
 		seq_indent(seq, iter->depth-1);
 		seq_printf(seq, "  +-- %pI4/%zu %u %u %u\n",
