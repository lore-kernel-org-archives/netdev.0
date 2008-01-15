From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [RFC 6/6] fib_trie: combine leaf and info
Date: Tue, 15 Jan 2008 17:44:47 +0100
Message-ID: <18316.58111.211387.271534@robur.slu.se>
References: <20080112064646.282104074@linux-foundation.org>
	<20080112.205520.55747078.davem@davemloft.net>
	<4789A29C.6080000@linux-foundation.org>
	<20080112.214417.154179770.davem@davemloft.net>
	<20080114125755.6157a3bf@deepthought>
	<20080114164450.55f8c9b2@deepthought>
	<20080114164621.2bc5011f@deepthought>
	<20080114164727.210047f6@deepthought>
	<20080114185843.0981f0ff@deepthought>
	<20080114210716.4b09c84d@deepthought>
	<478C4EB7.6060807@cosmosbay.com>
	<478C4FBE.5040308@cosmosbay.com>
	<20080115081905.3b8b6f05@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:54923 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238AbYAOQpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 11:45:22 -0500
In-Reply-To: <20080115081905.3b8b6f05@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen Hemminger writes:

 > Okay, I would rather see the leaf_info explicit inside the leaf, also
 > your scheme probably breaks if I add two prefixes and then delete the first.
 > Let me have a go at it.

 I took Eric's patch a bit further... 
 
 Support for delete and dump is needed before any testing at all
 and maybe some macro for checking and setting FP-leaf's

 Cheers.
					--ro


diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 6dab753..f5b276c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -97,22 +97,32 @@ typedef unsigned int t_key;
 #define IS_LEAF(n) (n->parent & T_LEAF)
 
 struct node {
-	unsigned long parent;
-	t_key key;
+	unsigned long		parent;
+	t_key			key;
 };
 
 struct leaf {
-	unsigned long parent;
-	t_key key;
-	struct hlist_head list;
-	struct rcu_head rcu;
+	unsigned long		parent;
+	t_key			key;
+	/*
+	 * Because we often have only one info per leaf, we embedd one here
+	 * to save some space and speedup lookups (sharing cache line)
+	 * a sort of fastpatch leaf (FP-leaf) this indicated a negative of
+	 * plen_iinfo.
+	 * Note : not inside a structure so that we dont have holes on 64bit 
+	 */
+	int 			plen_iinfo;
+	struct list_head	falh_iinfo;
+
+	struct hlist_head	list;
+	struct rcu_head		rcu;
 };
 
 struct leaf_info {
-	struct hlist_node hlist;
-	struct rcu_head rcu;
-	int plen;
-	struct list_head falh;
+	struct hlist_node	hlist;
+	int			plen;
+	struct list_head	falh;
+	struct rcu_head		rcu;
 };
 
 struct tnode {
@@ -364,11 +374,13 @@ static inline void tnode_free(struct tnode *tn)
 		call_rcu(&tn->rcu, __tnode_free_rcu);
 }
 
-static struct leaf *leaf_new(void)
+static struct leaf *leaf_new(int plen)
 {
 	struct leaf *l = kmalloc(sizeof(struct leaf),  GFP_KERNEL);
 	if (l) {
 		l->parent = T_LEAF;
+		l->plen_iinfo = plen;
+		INIT_LIST_HEAD(&l->falh_iinfo);
 		INIT_HLIST_HEAD(&l->list);
 	}
 	return l;
@@ -890,7 +902,16 @@ static struct leaf_info *find_leaf_info(struct leaf *l, int plen)
 
 static inline struct list_head * get_fa_head(struct leaf *l, int plen)
 {
-	struct leaf_info *li = find_leaf_info(l, plen);
+	struct leaf_info *li;
+
+	if (l->plen_iinfo >= 0) {
+		if(l->plen_iinfo == plen)
+			return &l->falh_iinfo;
+		else
+			return NULL;
+	}
+
+	li = find_leaf_info(l, plen);
 
 	if (!li)
 		return NULL;
@@ -1036,6 +1057,21 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 
 	if (n != NULL && IS_LEAF(n) && tkey_equals(key, n->key)) {
 		l = (struct leaf *) n;
+
+		/* 
+		 * Check if it is a FP-leaf if so we have to convert 
+		 * it to an ordinary leaf with leaf_infos
+		 */
+
+		if( l->plen_iinfo >= 0 ) {
+			li = leaf_info_new(l->plen_iinfo);
+			if (!li)
+				return NULL;
+
+			insert_leaf_info(&l->list, li);
+			l->plen_iinfo = -1;
+		}
+
 		li = leaf_info_new(plen);
 
 		if (!li)
@@ -1045,21 +1081,16 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 		insert_leaf_info(&l->list, li);
 		goto done;
 	}
-	l = leaf_new();
+
+	/* Insert a FP-leaf */
+	l = leaf_new(plen);
 
 	if (!l)
 		return NULL;
 
 	l->key = key;
-	li = leaf_info_new(plen);
-
-	if (!li) {
-		tnode_free((struct tnode *) l);
-		return NULL;
-	}
+	fa_head = &l->falh_iinfo;
 
-	fa_head = &li->falh;
-	insert_leaf_info(&l->list, li);
 
 	if (t->trie && n == NULL) {
 		/* Case 2: n is NULL, and will just insert a new leaf */
@@ -1089,7 +1120,6 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 		}
 
 		if (!tn) {
-			free_leaf_info(li);
 			tnode_free((struct tnode *) l);
 			return NULL;
 		}
@@ -1285,6 +1315,20 @@ static inline int check_leaf(struct trie *t, struct leaf *l,
 	struct hlist_head *hhead = &l->list;
 	struct hlist_node *node;
 
+	i = l->plen_iinfo;	
+	if( i >= 0) {   /* FP-leaf */
+		mask = inet_make_mask(i);
+		err = fib_semantic_match(&l->falh_iinfo, flp, res, htonl(l->key), mask, i);
+		if(err <= 0 ) {
+			*plen = i;
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+			t->stats.semantic_match_passed++;
+#endif
+		return err;
+		}
+	}
+
+
 	hlist_for_each_entry_rcu(li, node, hhead, hlist) {
 		i = li->plen;
 		mask = inet_make_mask(i);
@@ -1614,7 +1658,7 @@ static int fn_trie_delete(struct fib_table *tb, struct fib_config *cfg)
 	li = find_leaf_info(l, plen);
 
 	list_del_rcu(&fa->fa_list);
-
+// FIXME
 	if (list_empty(fa_head)) {
 		hlist_del_rcu(&li->hlist);
 		free_leaf_info(li);
@@ -2336,12 +2380,11 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 		seq_indent(seq, iter->depth);
 		seq_printf(seq, "  |-- %d.%d.%d.%d\n", NIPQUAD(val));
 		for (i = 32; i >= 0; i--) {
-			struct leaf_info *li = find_leaf_info(l, i);
+			struct list_head *fa_head = get_fa_head(l, i);
+			if (fa_head) {
 
-			if (li) {
 				struct fib_alias *fa;
-
-				list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+				list_for_each_entry_rcu(fa, fa_head, fa_list) {
 					char buf1[32], buf2[32];
 
 					seq_indent(seq, iter->depth+1);
@@ -2424,17 +2467,18 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 		return 0;
 
 	for (i=32; i>=0; i--) {
-		struct leaf_info *li = find_leaf_info(l, i);
+		//struct leaf_info *li = find_leaf_info(l, i);
+		struct list_head *fa_head = get_fa_head(l, i);
 		struct fib_alias *fa;
 		__be32 mask, prefix;
 
-		if (!li)
+		if (!fa_head)
 			continue;
 
-		mask = inet_make_mask(li->plen);
+		mask = inet_make_mask(i);
 		prefix = htonl(l->key);
 
-		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+		list_for_each_entry_rcu(fa, fa_head, fa_list) {
 			const struct fib_info *fi = fa->fa_info;
 			unsigned flags = fib_flag_trans(fa->fa_type, mask, fi);
 
