From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 12/29] fib_trie: move leaf and tnode to occupy the same
 spot in the key vector
Date: Tue, 24 Feb 2015 12:49:15 -0800
Message-ID: <20150224204915.26106.34425.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323AbbBXUtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:49:18 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKnGrK018284
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:17 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKnGCI031075
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:16 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we are going to compact the leaf and tnode we first need to make sure
the fields are all in the same place.  In that regard I am moving the leaf
pointer which represents the fib_alias hash list to occupy what is
currently the first key_vector pointer.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index cffbe47..caa2e28 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -94,21 +94,19 @@ typedef unsigned int t_key;
 #define get_index(_key, _kv) (((_key) ^ (_kv)->key) >> (_kv)->pos)
 
 struct key_vector {
+	struct rcu_head rcu;
+	t_key empty_children;		/* KEYLENGTH bits needed */
+	t_key full_children;		/* KEYLENGTH bits needed */
+	struct key_vector __rcu *parent;
 	t_key key;
 	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char slen;
-	struct key_vector __rcu *parent;
-	struct rcu_head rcu;
 	union {
-		/* The fields in this struct are valid if bits > 0 (TNODE) */
-		struct {
-			t_key empty_children; /* KEYLENGTH bits needed */
-			t_key full_children;  /* KEYLENGTH bits needed */
-			struct key_vector __rcu *tnode[0];
-		};
 		/* This list pointer if valid if bits == 0 (LEAF) */
 		struct hlist_head leaf;
+		/* The fields in this struct are valid if bits > 0 (TNODE) */
+		struct key_vector __rcu *tnode[0];
 	};
 };
 
@@ -273,7 +271,7 @@ static inline void alias_free_mem_rcu(struct fib_alias *fa)
 	call_rcu(&fa->rcu, __alias_free_mem);
 }
 
-#define TNODE_SIZE sizeof(struct key_vector)
+#define TNODE_SIZE offsetof(struct key_vector, tnode[0])
 #define TNODE_KMALLOC_MAX \
 	ilog2((PAGE_SIZE - TNODE_SIZE) / sizeof(struct key_vector *))
 
@@ -1733,7 +1731,7 @@ void __init fib_trie_init(void)
 					  0, SLAB_PANIC, NULL);
 
 	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
-					   TNODE_SIZE,
+					   sizeof(struct key_vector),
 					   0, SLAB_PANIC, NULL);
 }
 
@@ -1891,7 +1889,7 @@ static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 	seq_printf(seq, "\tMax depth:      %u\n", stat->maxdepth);
 
 	seq_printf(seq, "\tLeaves:         %u\n", stat->leaves);
-	bytes = TNODE_SIZE * stat->leaves;
+	bytes = sizeof(struct key_vector) * stat->leaves;
 
 	seq_printf(seq, "\tPrefixes:       %u\n", stat->prefixes);
 	bytes += sizeof(struct fib_alias) * stat->prefixes;
@@ -1966,7 +1964,7 @@ static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq,
 		   "Basic info: size of leaf:"
 		   " %Zd bytes, size of tnode: %Zd bytes.\n",
-		   TNODE_SIZE, TNODE_SIZE);
+		   sizeof(struct key_vector), TNODE_SIZE);
 
 	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
 		struct hlist_head *head = &net->ipv4.fib_table_hash[h];
