From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC 6/6] fib_trie: combine leaf and info
Date: Tue, 15 Jan 2008 07:12:07 +0100
Message-ID: <478C4EB7.6060807@cosmosbay.com>
References: <20080112064646.282104074@linux-foundation.org>	<20080112.205520.55747078.davem@davemloft.net>	<4789A29C.6080000@linux-foundation.org>	<20080112.214417.154179770.davem@davemloft.net>	<20080114125755.6157a3bf@deepthought>	<20080114164450.55f8c9b2@deepthought>	<20080114164621.2bc5011f@deepthought>	<20080114164727.210047f6@deepthought>	<20080114185843.0981f0ff@deepthought> <20080114210716.4b09c84d@deepthought>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050000010104040401030703"
Cc: David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43068 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbYAOGMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 01:12:21 -0500
In-Reply-To: <20080114210716.4b09c84d@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050000010104040401030703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Stephen Hemminger a écrit :
> Combine the prefix information and the leaf together into one
> allocation. This is furthur simplified by converting the hlist
> into a simple bitfield.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
> 
> This patch is experimental (ie it boots and loads routes), but
> is slower for the 163,000 route dump test.
> 

Its also very memory expensive. That was not Robert suggestion I believe.

Its suggestion is to embedd one info into each leaves.

Please find attached to this mail a preliminary and incomplete patch I wrote 
this morning before coffee :), to get the idea.

Before patching this file, maybe we should first do a cleanup (checkpatch.pl 
and obvious modern style formating :) )
> ---
>  net/ipv4/fib_trie.c |  165 ++++++++++++++++++++--------------------------------
>  1 file changed, 65 insertions(+), 100 deletions(-)
> 
> --- a/net/ipv4/fib_trie.c	2008-01-14 18:37:51.000000000 -0800
> +++ b/net/ipv4/fib_trie.c	2008-01-14 20:57:12.000000000 -0800
> @@ -50,10 +50,9 @@
>   *		Patrick McHardy <kaber@trash.net>
>   */
>  
> -#define VERSION "0.408"
> +#define VERSION "0.409"
> +
>  
> -#include <asm/uaccess.h>
> -#include <asm/system.h>
>  #include <linux/bitops.h>
>  #include <linux/types.h>
>  #include <linux/kernel.h>
> @@ -80,6 +79,8 @@
>  #include <net/tcp.h>
>  #include <net/sock.h>
>  #include <net/ip_fib.h>
> +#include <asm/bitops.h>
> +
>  #include "fib_lookup.h"
>  
>  #define MAX_STAT_DEPTH 32
> @@ -101,20 +102,24 @@ struct node {
>  	t_key key;
>  };
>  
> +struct leaf_info {
> +	struct list_head falh;
> +};
> +
> +#define INFO_SIZE	33
> +/* NB: bitmap is in reverse order, so that find_first returns largest prefix */
> +#define PLEN2BIT(x)	(INFO_SIZE - (x))
> +
>  struct leaf {
>  	unsigned long parent;
>  	t_key key;
> -	struct hlist_head list;
>  	struct rcu_head rcu;
> -};
>  
> -struct leaf_info {
> -	struct hlist_node hlist;
> -	struct rcu_head rcu;
> -	int plen;
> -	struct list_head falh;
> +	unsigned long bitmap[INFO_SIZE / BITS_PER_LONG + 1];
> +	struct leaf_info info[INFO_SIZE];
>  };
>  
> +
>  struct tnode {
>  	unsigned long parent;
>  	t_key key;
> @@ -321,16 +326,6 @@ static void __leaf_free_rcu(struct rcu_h
>  	kmem_cache_free(trie_leaf_kmem, leaf);
>  }
>  
> -static void __leaf_info_free_rcu(struct rcu_head *head)
> -{
> -	kfree(container_of(head, struct leaf_info, rcu));
> -}
> -
> -static inline void free_leaf_info(struct leaf_info *leaf)
> -{
> -	call_rcu(&leaf->rcu, __leaf_info_free_rcu);
> -}
> -
>  static struct tnode *tnode_alloc(size_t size)
>  {
>  	struct page *pages;
> @@ -371,21 +366,37 @@ static struct leaf *leaf_new(void)
>  	struct leaf *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
>  	if (l) {
>  		l->parent = T_LEAF;
> -		INIT_HLIST_HEAD(&l->list);
> +		bitmap_zero(l->bitmap, INFO_SIZE);
>  	}
>  	return l;
>  }
>  
> -static struct leaf_info *leaf_info_new(int plen)
> +static inline struct leaf_info *find_leaf_info(struct leaf *l, int plen)
>  {
> -	struct leaf_info *li = kmalloc(sizeof(struct leaf_info),  GFP_KERNEL);
> -	if (li) {
> -		li->plen = plen;
> -		INIT_LIST_HEAD(&li->falh);
> -	}
> +	return test_bit(PLEN2BIT(plen), l->bitmap) ? &l->info[plen] : NULL;
> +}
> +
> +static struct leaf_info *set_leaf_info(struct leaf *l, int plen)
> +{
> +	struct leaf_info *li = &l->info[plen];
> +
> +	INIT_LIST_HEAD(&li->falh);
> +	set_bit(PLEN2BIT(plen), l->bitmap);
> +
>  	return li;
>  }
>  
> +static inline void clear_leaf_info(struct leaf *l, int plen)
> +{
> +	smp_mb__before_clear_bit();
> +	clear_bit(PLEN2BIT(plen), &l->bitmap);
> +}
> +
> +static inline int leaf_info_empty(const struct leaf *l)
> +{
> +	return find_first_bit(l->bitmap, INFO_SIZE) >= INFO_SIZE;
> +}
> +
>  static struct tnode* tnode_new(t_key key, int pos, int bits)
>  {
>  	size_t sz = sizeof(struct tnode) + (sizeof(struct node *) << bits);
> @@ -876,20 +887,6 @@ nomem:
>  
>  /* readside must use rcu_read_lock currently dump routines
>   via get_fa_head and dump */
> -
> -static struct leaf_info *find_leaf_info(struct leaf *l, int plen)
> -{
> -	struct hlist_head *head = &l->list;
> -	struct hlist_node *node;
> -	struct leaf_info *li;
> -
> -	hlist_for_each_entry_rcu(li, node, head, hlist)
> -		if (li->plen == plen)
> -			return li;
> -
> -	return NULL;
> -}
> -
>  static inline struct list_head * get_fa_head(struct leaf *l, int plen)
>  {
>  	struct leaf_info *li = find_leaf_info(l, plen);
> @@ -900,26 +897,6 @@ static inline struct list_head * get_fa_
>  	return &li->falh;
>  }
>  
> -static void insert_leaf_info(struct hlist_head *head, struct leaf_info *new)
> -{
> -	struct leaf_info *li = NULL, *last = NULL;
> -	struct hlist_node *node;
> -
> -	if (hlist_empty(head)) {
> -		hlist_add_head_rcu(&new->hlist, head);
> -	} else {
> -		hlist_for_each_entry(li, node, head, hlist) {
> -			if (new->plen > li->plen)
> -				break;
> -
> -			last = li;
> -		}
> -		if (last)
> -			hlist_add_after_rcu(&last->hlist, &new->hlist);
> -		else
> -			hlist_add_before_rcu(&new->hlist, &li->hlist);
> -	}
> -}
>  
>  /* rcu_read_lock needs to be hold by caller from readside */
>  
> @@ -993,6 +970,8 @@ static struct list_head *fib_insert_node
>  	pos = 0;
>  	n = t->trie;
>  
> +	pr_debug("fib_insert_node: %x/%d\n", key, plen);
> +
>  	/* If we point to NULL, stop. Either the tree is empty and we should
>  	 * just put a new leaf in if, or we have reached an empty child slot,
>  	 * and we should just put our new leaf in that.
> @@ -1038,13 +1017,9 @@ static struct list_head *fib_insert_node
>  
>  	if (n != NULL && IS_LEAF(n) && tkey_equals(key, n->key)) {
>  		l = (struct leaf *) n;
> -		li = leaf_info_new(plen);
> -
> -		if (!li)
> -			return NULL;
> -
> +		li = set_leaf_info(l, plen);
>  		fa_head = &li->falh;
> -		insert_leaf_info(&l->list, li);
> +
>  		goto done;
>  	}
>  	l = leaf_new();
> @@ -1053,15 +1028,8 @@ static struct list_head *fib_insert_node
>  		return NULL;
>  
>  	l->key = key;
> -	li = leaf_info_new(plen);
> -
> -	if (!li) {
> -		tnode_free((struct tnode *) l);
> -		return NULL;
> -	}
> -
> +	li = set_leaf_info(l, plen);
>  	fa_head = &li->falh;
> -	insert_leaf_info(&l->list, li);
>  
>  	if (t->trie && n == NULL) {
>  		/* Case 2: n is NULL, and will just insert a new leaf */
> @@ -1091,7 +1059,6 @@ static struct list_head *fib_insert_node
>  		}
>  
>  		if (!tn) {
> -			free_leaf_info(li);
>  			tnode_free((struct tnode *) l);
>  			return NULL;
>  		}
> @@ -1119,7 +1086,7 @@ static struct list_head *fib_insert_node
>  
>  	rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
>  done:
> -	return fa_head;
> +	return &li->falh;
>  }
>  
>  /*
> @@ -1281,14 +1248,14 @@ static int check_leaf(struct trie *t, st
>  		      t_key key,  const struct flowi *flp,
>  		      struct fib_result *res)
>  {
> -	struct leaf_info *li;
> -	struct hlist_head *hhead = &l->list;
> -	struct hlist_node *node;
> +	int bit;
>  
> -	hlist_for_each_entry_rcu(li, node, hhead, hlist) {
> -		int err;
> -		int plen = li->plen;
> +	/* need find highest prefix */
> +	for_each_bit(bit, l->bitmap, INFO_SIZE) {
> +		int plen = PLEN2BIT(bit);
> +		struct leaf_info *li = &l->info[plen];
>  		__be32 mask = inet_make_mask(plen);
> +		int err;
>  
>  		if (l->key != (key & ntohl(mask)))
>  			continue;
> @@ -1622,12 +1589,10 @@ static int fn_trie_delete(struct fib_tab
>  
>  	list_del_rcu(&fa->fa_list);
>  
> -	if (list_empty(fa_head)) {
> -		hlist_del_rcu(&li->hlist);
> -		free_leaf_info(li);
> -	}
> +	if (list_empty(fa_head))
> +		clear_leaf_info(l, plen);
>  
> -	if (hlist_empty(&l->list))
> +	if (leaf_info_empty(l))
>  		trie_leaf_remove(t, key);
>  
>  	if (fa->fa_state & FA_S_ACCESSED)
> @@ -1659,18 +1624,17 @@ static int trie_flush_list(struct trie *
>  static int trie_flush_leaf(struct trie *t, struct leaf *l)
>  {
>  	int found = 0;
> -	struct hlist_head *lih = &l->list;
> -	struct hlist_node *node, *tmp;
> -	struct leaf_info *li = NULL;
> +	int bit;
>  
> -	hlist_for_each_entry_safe(li, node, tmp, lih, hlist) {
> +	for_each_bit(bit, l->bitmap, INFO_SIZE) {
> +		int plen = PLEN2BIT(bit);
> +		struct leaf_info *li = &l->info[plen];
>  		found += trie_flush_list(t, &li->falh);
>  
> -		if (list_empty(&li->falh)) {
> -			hlist_del_rcu(&li->hlist);
> -			free_leaf_info(li);
> -		}
> +		if (list_empty(&li->falh))
> +			clear_leaf_info(l, plen);
>  	}
> +
>  	return found;
>  }
>  
> @@ -1746,12 +1710,12 @@ static int fn_trie_flush(struct fib_tabl
>  	for (h = 0; (l = nextleaf(t, l)) != NULL; h++) {
>  		found += trie_flush_leaf(t, l);
>  
> -		if (ll && hlist_empty(&ll->list))
> +		if (ll && leaf_info_empty(ll))
>  			trie_leaf_remove(t, ll->key);
>  		ll = l;
>  	}
>  
> -	if (ll && hlist_empty(&ll->list))
> +	if (ll && leaf_info_empty(ll))
>  		trie_leaf_remove(t, ll->key);
>  
>  	pr_debug("trie_flush found=%d\n", found);
> @@ -2428,10 +2392,11 @@ static int fib_route_seq_show(struct seq
>  
>  	if (iter->trie == iter->trie_local)
>  		return 0;
> +
>  	if (IS_TNODE(l))
>  		return 0;
>  
> -	for (i=32; i>=0; i--) {
> +	for (i = 32; i >= 0; i--) {
>  		struct leaf_info *li = find_leaf_info(l, i);
>  		struct fib_alias *fa;
>  		__be32 mask, prefix;
> @@ -2439,7 +2404,7 @@ static int fib_route_seq_show(struct seq
>  		if (!li)
>  			continue;
>  
> -		mask = inet_make_mask(li->plen);
> +		mask = inet_make_mask(i);
>  		prefix = htonl(l->key);
>  
>  		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


--------------050000010104040401030703
Content-Type: text/plain;
 name="info_embedded.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="info_embedded.patch"

--- net/ipv4/fib_trie.c
+++ net/ipv4/fib_trie.c.rcu
@@ -97,30 +97,22 @@
 #define IS_LEAF(n) (n->parent & T_LEAF)
 
 struct node {
-	unsigned long		parent;
-	t_key			key;
+	unsigned long parent;
+	t_key key;
 };
 
 struct leaf {
-	unsigned long		parent;
-	t_key			key;
-	/*
-	 * Because we have at least one info per leaf, we embedd one here
-	 * to save some space and speedup lookups (sharing cache line)
-	 * Note : not inside a structure so that we dont have holes on 64bit 
-	 */
-	int 			plen_iinfo;
-	struct list_head	falh_iinfo;
-
-	struct hlist_head	list;
-	struct rcu_head		rcu;
+	unsigned long parent;
+	t_key key;
+	struct hlist_head list;
+	struct rcu_head rcu;
 };
 
 struct leaf_info {
-	struct hlist_node	hlist;
-	int			plen;
-	struct list_head	falh;
-	struct rcu_head		rcu;
+	struct hlist_node hlist;
+	struct rcu_head rcu;
+	int plen;
+	struct list_head falh;
 };
 
 struct tnode {
@@ -381,13 +373,11 @@
 		call_rcu(&tn->rcu, __tnode_free_rcu);
 }
 
-static struct leaf *leaf_new(int plen)
+static struct leaf *leaf_new(void)
 {
 	struct leaf *l = kmalloc(sizeof(struct leaf),  GFP_KERNEL);
 	if (l) {
 		l->parent = T_LEAF;
-		l->plen_iinfo = plen;
-		INIT_LIST_HEAD(&l->falh_iinfo);
 		INIT_HLIST_HEAD(&l->list);
 	}
 	return l;
@@ -909,12 +899,7 @@
 
 static inline struct list_head * get_fa_head(struct leaf *l, int plen)
 {
-	struct leaf_info *li;
-
-	if (plen == l->plen_iinfo)
-		return &l->falh_iinfo;
-
-	li = find_leaf_info(l, plen);
+	struct leaf_info *li = find_leaf_info(l, plen);
 
 	if (!li)
 		return NULL;
@@ -1071,22 +1056,21 @@
 		goto done;
 	}
 	t->size++;
-	l = leaf_new(plen);
+	l = leaf_new();
 
 	if (!l)
 		return NULL;
 
 	l->key = key;
-//	li = leaf_info_new(plen);
+	li = leaf_info_new(plen);
+
+	if (!li) {
+		tnode_free((struct tnode *) l);
+		return NULL;
+	}
 
-//	if (!li) {
-//		tnode_free((struct tnode *) l);
-//		return NULL;
-//	}
-
-//	fa_head = &li->falh;
-//	insert_leaf_info(&l->list, li);
-	fa_head = &l->falh_iinfo;
+	fa_head = &li->falh;
+	insert_leaf_info(&l->list, li);
 
 	if (t->trie && n == NULL) {
 		/* Case 2: n is NULL, and will just insert a new leaf */
@@ -1116,7 +1100,7 @@
 		}
 
 		if (!tn) {
-//			free_leaf_info(li);
+			free_leaf_info(li);
 			tnode_free((struct tnode *) l);
 			return NULL;
 		}
@@ -1640,7 +1624,7 @@
 	li = find_leaf_info(l, plen);
 
 	list_del_rcu(&fa->fa_list);
-// FIXME
+
 	if (list_empty(fa_head)) {
 		hlist_del_rcu(&li->hlist);
 		free_leaf_info(li);
@@ -2382,11 +2366,10 @@
 		seq_indent(seq, iter->depth);
 		seq_printf(seq, "  |-- %d.%d.%d.%d\n", NIPQUAD(val));
 		for (i = 32; i >= 0; i--) {
-//			struct leaf_info *li = get_fa_head(l, i); //find_leaf_info(l, i);
-			struct list_head *fa_head = get_fa_head(l, i);
-			if (fa_head) {
+			struct leaf_info *li = find_leaf_info(l, i);
+			if (li) {
 				struct fib_alias *fa;
-				list_for_each_entry_rcu(fa, fa_head, fa_list) {
+				list_for_each_entry_rcu(fa, &li->falh, fa_list) {
 					seq_indent(seq, iter->depth+1);
 					seq_printf(seq, "  /%d %s %s", i,
 						   rtn_scope(fa->fa_scope),
@@ -2465,18 +2448,17 @@
 		return 0;
 
 	for (i=32; i>=0; i--) {
-		//struct leaf_info *li = find_leaf_info(l, i);
-		struct list_head *fa_head = get_fa_head(l, i);
+		struct leaf_info *li = find_leaf_info(l, i);
 		struct fib_alias *fa;
 		__be32 mask, prefix;
 
-		if (!fa_head)
+		if (!li)
 			continue;
 
-		mask = inet_make_mask(i);
+		mask = inet_make_mask(li->plen);
 		prefix = htonl(l->key);
 
-		list_for_each_entry_rcu(fa, fa_head, fa_list) {
+		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
 			const struct fib_info *fi = fa->fa_info;
 			unsigned flags = fib_flag_trans(fa->fa_type, mask, fi);
 

--------------050000010104040401030703--
