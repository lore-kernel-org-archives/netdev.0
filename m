From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC 6/6] fib_trie: combine leaf and info
Date: Tue, 15 Jan 2008 07:16:30 +0100
Message-ID: <478C4FBE.5040308@cosmosbay.com>
References: <20080112064646.282104074@linux-foundation.org>	<20080112.205520.55747078.davem@davemloft.net>	<4789A29C.6080000@linux-foundation.org>	<20080112.214417.154179770.davem@davemloft.net>	<20080114125755.6157a3bf@deepthought>	<20080114164450.55f8c9b2@deepthought>	<20080114164621.2bc5011f@deepthought>	<20080114164727.210047f6@deepthought>	<20080114185843.0981f0ff@deepthought> <20080114210716.4b09c84d@deepthought> <478C4EB7.6060807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080604070207070004080001"
Cc: David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43083 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbYAOGQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 01:16:42 -0500
In-Reply-To: <478C4EB7.6060807@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080604070207070004080001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Eric Dumazet a écrit :
> Stephen Hemminger a écrit :
>> Combine the prefix information and the leaf together into one
>> allocation. This is furthur simplified by converting the hlist
>> into a simple bitfield.
>>
>> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
>>
>> This patch is experimental (ie it boots and loads routes), but
>> is slower for the 163,000 route dump test.
>>
> 
> Its also very memory expensive. That was not Robert suggestion I believe.
> 
> Its suggestion is to embedd one info into each leaves.
> 
> Please find attached to this mail a preliminary and incomplete patch I 
> wrote this morning before coffee :), to get the idea.

Oops, patch reversed, sorry, and against another work pending in my tree.

Now time for cofee :)


--------------080604070207070004080001
Content-Type: text/plain;
 name="info_embedded.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="info_embedded.patch"

--- net/ipv4/fib_trie.c.old
+++ net/ipv4/fib_trie.c
@@ -97,22 +97,30 @@
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
+	 * Because we have at least one info per leaf, we embedd one here
+	 * to save some space and speedup lookups (sharing cache line)
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
@@ -373,11 +381,13 @@
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
@@ -899,7 +909,12 @@
 
 static inline struct list_head * get_fa_head(struct leaf *l, int plen)
 {
-	struct leaf_info *li = find_leaf_info(l, plen);
+	struct leaf_info *li;
+
+	if (plen == l->plen_iinfo)
+		return &l->falh_iinfo;
+
+	li = find_leaf_info(l, plen);
 
 	if (!li)
 		return NULL;
@@ -1056,21 +1071,22 @@
 		goto done;
 	}
 	t->size++;
-	l = leaf_new();
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
+//	li = leaf_info_new(plen);
 
-	fa_head = &li->falh;
-	insert_leaf_info(&l->list, li);
+//	if (!li) {
+//		tnode_free((struct tnode *) l);
+//		return NULL;
+//	}
+
+//	fa_head = &li->falh;
+//	insert_leaf_info(&l->list, li);
+	fa_head = &l->falh_iinfo;
 
 	if (t->trie && n == NULL) {
 		/* Case 2: n is NULL, and will just insert a new leaf */
@@ -1100,7 +1116,7 @@
 		}
 
 		if (!tn) {
-			free_leaf_info(li);
+//			free_leaf_info(li);
 			tnode_free((struct tnode *) l);
 			return NULL;
 		}
@@ -1624,7 +1640,7 @@
 	li = find_leaf_info(l, plen);
 
 	list_del_rcu(&fa->fa_list);
-
+// FIXME
 	if (list_empty(fa_head)) {
 		hlist_del_rcu(&li->hlist);
 		free_leaf_info(li);
@@ -2366,10 +2382,11 @@
 		seq_indent(seq, iter->depth);
 		seq_printf(seq, "  |-- %d.%d.%d.%d\n", NIPQUAD(val));
 		for (i = 32; i >= 0; i--) {
-			struct leaf_info *li = find_leaf_info(l, i);
-			if (li) {
+//			struct leaf_info *li = get_fa_head(l, i); //find_leaf_info(l, i);
+			struct list_head *fa_head = get_fa_head(l, i);
+			if (fa_head) {
 				struct fib_alias *fa;
-				list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+				list_for_each_entry_rcu(fa, fa_head, fa_list) {
 					seq_indent(seq, iter->depth+1);
 					seq_printf(seq, "  /%d %s %s", i,
 						   rtn_scope(fa->fa_scope),
@@ -2448,17 +2465,18 @@
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
 

--------------080604070207070004080001--
