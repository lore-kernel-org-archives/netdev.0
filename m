From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH] Clean up fib_hash datastructures
Date: Sat, 18 Sep 2004 20:33:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918203319.24004d6e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


So, before we even think about trying new faster algorithms
in net/ipv4/fib_hash.c we have to clean it up.

Currently there is a lot of behavior hidden in the hash chain
list ordering that could be explicitly described using better
datastructures.  What happens now is that, within each hash
chain, entries with the same destination address key are
ordered by TOS then by priority.

So this patch below attempts to do two things:

1) Split fib_node to fib_node and fib_alias.

   The fib_node is purely a lookup object keyed
   on destination address and prefix only.
   Any new lookup algorithm we attempt will modify
   _only_ the code handling fib_node objects.

   The fib_alias, on the other hand, describes
   a sub-route of a fib_node that has different
   TOS and PRIORITY keys.  Each fib_node has
   a list of fib_alias objects.

2) Use linux/list.h list facilities instead of
   by-hand list implementations.

I would say that the most complicated part of the
patch below is the insertion handling.  If an
entry exists matching the insert request, we have
to check if this is an exclusive add.  If so,
then we error, else we append/prepend to the alias
list depending upon what the user asked for.  Finally
we also have to check if we are doing a replace.

The procfs support got slightly trickier as well.

Does anyone know what this test:

		if (!iter->zone->fz_next)
			continue;

in fib_get_first() is doing?  I kept it there
but it looks fishy.  Does it prevent default
routes (that is, routes with prefix zero) from
being displayed in /proc/net/route?  Effectively
what this test does is make the last zone in the
zone list not be displayed if you have nothing
but default routes.

Please help me review and test this patch.
Thanks.

===== net/ipv4/fib_hash.c 1.19 vs edited =====
--- 1.19/net/ipv4/fib_hash.c	2004-09-15 13:54:54 -07:00
+++ edited/net/ipv4/fib_hash.c	2004-09-18 20:05:05 -07:00
@@ -43,49 +43,45 @@
 #include <net/sock.h>
 #include <net/ip_fib.h>
 
-#define FTprint(a...)
-/*
-   printk(KERN_DEBUG a)
- */
-
 static kmem_cache_t *fn_hash_kmem;
+static kmem_cache_t *fn_alias_kmem;
 
 struct fib_node {
-	struct fib_node		*fn_next;
-	struct fib_info		*fn_info;
-#define FIB_INFO(f)	((f)->fn_info)
+	struct hlist_node	fn_hash;
+	struct list_head	fn_alias;
 	u32			fn_key;
-	u8			fn_tos;
-	u8			fn_type;
-	u8			fn_scope;
-	u8			fn_state;
 };
 
-#define FN_S_ZOMBIE	1
-#define FN_S_ACCESSED	2
+struct fib_alias {
+	struct list_head	fa_list;
+	struct fib_info		*fa_info;
+	u8			fa_tos;
+	u8			fa_type;
+	u8			fa_scope;
+	u8			fa_state;
+};
 
-static int fib_hash_zombies;
+#define FN_S_ACCESSED	1
 
 struct fn_zone {
-	struct fn_zone	*fz_next;	/* Next not empty zone	*/
-	struct fib_node	**fz_hash;	/* Hash table pointer	*/
-	int		fz_nent;	/* Number of entries	*/
-
-	int		fz_divisor;	/* Hash divisor		*/
-	u32		fz_hashmask;	/* (fz_divisor - 1)	*/
-#define FZ_HASHMASK(fz)	((fz)->fz_hashmask)
-
-	int		fz_order;	/* Zone order		*/
-	u32		fz_mask;
-#define FZ_MASK(fz)	((fz)->fz_mask)
+	struct fn_zone		*fz_next;	/* Next not empty zone	*/
+	struct hlist_head	*fz_hash;	/* Hash table pointer	*/
+	int			fz_nent;	/* Number of entries	*/
+
+	int			fz_divisor;	/* Hash divisor		*/
+	u32			fz_hashmask;	/* (fz_divisor - 1)	*/
+#define FZ_HASHMASK(fz)		((fz)->fz_hashmask)
+
+	int			fz_order;	/* Zone order		*/
+	u32			fz_mask;
+#define FZ_MASK(fz)		((fz)->fz_mask)
 };
 
 /* NOTE. On fast computers evaluation of fz_hashmask and fz_mask
-   can be cheaper than memory lookup, so that FZ_* macros are used.
+ * can be cheaper than memory lookup, so that FZ_* macros are used.
  */
 
-struct fn_hash
-{
+struct fn_hash {
 	struct fn_zone	*fn_zones[33];
 	struct fn_zone	*fn_zone_list;
 };
@@ -105,65 +101,56 @@
 	return dst & FZ_MASK(fz);
 }
 
-static inline struct fib_node ** fz_chain_p(u32 key, struct fn_zone *fz)
-{
-	return &fz->fz_hash[fn_hash(key, fz)];
-}
-
-static inline struct fib_node * fz_chain(u32 key, struct fn_zone *fz)
-{
-	return fz->fz_hash[fn_hash(key, fz)];
-}
-
 static rwlock_t fib_hash_lock = RW_LOCK_UNLOCKED;
 
-#define FZ_MAX_DIVISOR ((PAGE_SIZE<<MAX_ORDER) / sizeof(struct fib_node *))
+#define FZ_MAX_DIVISOR ((PAGE_SIZE<<MAX_ORDER) / sizeof(struct hlist_head))
 
-static struct fib_node **fz_hash_alloc(int divisor)
+static struct hlist_head *fz_hash_alloc(int divisor)
 {
-	unsigned long size = divisor * sizeof(struct fib_node *);
+	unsigned long size = divisor * sizeof(struct hlist_head);
 
 	if (divisor <= 1024) {
 		return kmalloc(size, GFP_KERNEL);
 	} else {
-		return (struct fib_node **)
+		return (struct hlist_head *)
 			__get_free_pages(GFP_KERNEL, get_order(size));
 	}
 }
 
 /* The fib hash lock must be held when this is called. */
 static inline void fn_rebuild_zone(struct fn_zone *fz,
-				       struct fib_node **old_ht,
-				       int old_divisor)
+				   struct hlist_head *old_ht,
+				   int old_divisor)
 {
 	int i;
-	struct fib_node *f, **fp, *next;
 
-	for (i=0; i<old_divisor; i++) {
-		for (f=old_ht[i]; f; f=next) {
-			next = f->fn_next;
-			for (fp = fz_chain_p(f->fn_key, fz);
-			     *fp && ((*fp)->fn_key <= f->fn_key);
-			     fp = &(*fp)->fn_next)
-				/* NONE */;
-			f->fn_next = *fp;
-			*fp = f;
+	for (i = 0; i < old_divisor; i++) {
+		struct hlist_node *node, *n;
+		struct fib_node *f;
+
+		hlist_for_each_entry_safe(f, node, n, &old_ht[i], fn_hash) {
+			struct hlist_head *new_head;
+
+			hlist_del(&f->fn_hash);
+
+			new_head = &fz->fz_hash[fn_hash(f->fn_key, fz)];
+			hlist_add_head(&f->fn_hash, new_head);
 		}
 	}
 }
 
-static void fz_hash_free(struct fib_node **hash, int divisor)
+static void fz_hash_free(struct hlist_head *hash, int divisor)
 {
 	if (divisor <= 1024)
 		kfree(hash);
 	else
 		free_pages((unsigned long) hash,
-			   get_order(divisor * sizeof(struct fib_node *)));
+			   get_order(divisor * sizeof(struct hlist_head)));
 }
 
 static void fn_rehash_zone(struct fn_zone *fz)
 {
-	struct fib_node **ht, **old_ht;
+	struct hlist_head *ht, *old_ht;
 	int old_divisor, new_divisor;
 	u32 new_hashmask;
 		
@@ -194,7 +181,7 @@
 	ht = fz_hash_alloc(new_divisor);
 
 	if (ht)	{
-		memset(ht, 0, new_divisor*sizeof(struct fib_node*));
+		memset(ht, 0, new_divisor * sizeof(struct hlist_head));
 
 		write_lock_bh(&fib_hash_lock);
 		old_ht = fz->fz_hash;
@@ -208,12 +195,16 @@
 	}
 }
 
-static void fn_free_node(struct fib_node * f)
+static inline void fn_free_node(struct fib_node * f)
 {
-	fib_release_info(FIB_INFO(f));
 	kmem_cache_free(fn_hash_kmem, f);
 }
 
+static inline void fn_free_alias(struct fib_alias *fa)
+{
+	fib_release_info(fa->fa_info);
+	kmem_cache_free(fn_alias_kmem, fa);
+}
 
 static struct fn_zone *
 fn_new_zone(struct fn_hash *table, int z)
@@ -235,7 +226,7 @@
 		kfree(fz);
 		return NULL;
 	}
-	memset(fz->fz_hash, 0, fz->fz_divisor*sizeof(struct fib_node*));
+	memset(fz->fz_hash, 0, fz->fz_divisor * sizeof(struct hlist_head *));
 	fz->fz_order = z;
 	fz->fz_mask = inet_make_mask(z);
 
@@ -266,36 +257,41 @@
 
 	read_lock(&fib_hash_lock);
 	for (fz = t->fn_zone_list; fz; fz = fz->fz_next) {
+		struct hlist_head *head;
+		struct hlist_node *node;
 		struct fib_node *f;
 		u32 k = fz_key(flp->fl4_dst, fz);
 
-		for (f = fz_chain(k, fz); f; f = f->fn_next) {
-			if (k != f->fn_key) {
-				if (k <= f->fn_key)
-					break;
-				else
-					continue;
-			}
-#ifdef CONFIG_IP_ROUTE_TOS
-			if (f->fn_tos && f->fn_tos != flp->fl4_tos)
+		head = &fz->fz_hash[fn_hash(k, fz)];
+		hlist_for_each_entry(f, node, head, fn_hash) {
+			struct fib_alias *fa;
+
+			if (f->fn_key != k)
 				continue;
+
+			list_for_each_entry(fa, &f->fn_alias, fa_list) {
+#ifdef CONFIG_IP_ROUTE_TOS
+				if (fa->fa_tos &&
+				    fa->fa_tos != flp->fl4_tos)
+					continue;
 #endif
-			f->fn_state |= FN_S_ACCESSED;
+				if (fa->fa_scope < flp->fl4_scope)
+					continue;
 
-			if (f->fn_state&FN_S_ZOMBIE)
-				continue;
-			if (f->fn_scope < flp->fl4_scope)
-				continue;
+				fa->fa_state |= FN_S_ACCESSED;
 
-			err = fib_semantic_match(f->fn_type, FIB_INFO(f), flp, res);
-			if (err == 0) {
-				res->type = f->fn_type;
-				res->scope = f->fn_scope;
-				res->prefixlen = fz->fz_order;
-				goto out;
+				err = fib_semantic_match(fa->fa_type,
+							 fa->fa_info,
+							 flp, res);
+				if (err == 0) {
+					res->type = fa->fa_type;
+					res->scope = fa->fa_scope;
+					res->prefixlen = fz->fz_order;
+					goto out;
+				}
+				if (err < 0)
+					goto out;
 			}
-			if (err < 0)
-				goto out;
 		}
 	}
 	err = 1;
@@ -333,6 +329,7 @@
 fn_hash_select_default(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
 {
 	int order, last_idx;
+	struct hlist_node *node;
 	struct fib_node *f;
 	struct fib_info *fi = NULL;
 	struct fib_info *last_resort;
@@ -347,36 +344,41 @@
 	order = -1;
 
 	read_lock(&fib_hash_lock);
-	for (f = fz->fz_hash[0]; f; f = f->fn_next) {
-		struct fib_info *next_fi = FIB_INFO(f);
+	hlist_for_each_entry(f, node, &fz->fz_hash[0], fn_hash) {
+		struct fib_alias *fa;
 
-		if ((f->fn_state&FN_S_ZOMBIE) ||
-		    f->fn_scope != res->scope ||
-		    f->fn_type != RTN_UNICAST)
-			continue;
+		list_for_each_entry(fa, &f->fn_alias, fa_list) {
+			struct fib_info *next_fi = fa->fa_info;
 
-		if (next_fi->fib_priority > res->fi->fib_priority)
-			break;
-		if (!next_fi->fib_nh[0].nh_gw || next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
-			continue;
-		f->fn_state |= FN_S_ACCESSED;
+			if (fa->fa_scope != res->scope ||
+			    fa->fa_type != RTN_UNICAST)
+				continue;
 
-		if (fi == NULL) {
-			if (next_fi != res->fi)
+			if (next_fi->fib_priority > res->fi->fib_priority)
 				break;
-		} else if (!fib_detect_death(fi, order, &last_resort, &last_idx)) {
-			if (res->fi)
-				fib_info_put(res->fi);
-			res->fi = fi;
-			atomic_inc(&fi->fib_clntref);
-			fn_hash_last_dflt = order;
-			goto out;
+			if (!next_fi->fib_nh[0].nh_gw ||
+			    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
+				continue;
+			fa->fa_state |= FN_S_ACCESSED;
+
+			if (fi == NULL) {
+				if (next_fi != res->fi)
+					break;
+			} else if (!fib_detect_death(fi, order, &last_resort,
+						     &last_idx)) {
+				if (res->fi)
+					fib_info_put(res->fi);
+				res->fi = fi;
+				atomic_inc(&fi->fib_clntref);
+				fn_hash_last_dflt = order;
+				goto out;
+			}
+			fi = next_fi;
+			order++;
 		}
-		fi = next_fi;
-		order++;
 	}
 
-	if (order<=0 || fi==NULL) {
+	if (order <= 0 || fi == NULL) {
 		fn_hash_last_dflt = -1;
 		goto out;
 	}
@@ -402,45 +404,76 @@
 	read_unlock(&fib_hash_lock);
 }
 
-#define FIB_SCAN(f, fp) \
-for ( ; ((f) = *(fp)) != NULL; (fp) = &(f)->fn_next)
+static void rtmsg_fib(int, struct fib_node *, struct fib_alias *,
+		      int, int,
+		      struct nlmsghdr *n,
+		      struct netlink_skb_parms *);
 
-#define FIB_SCAN_KEY(f, fp, key) \
-for ( ; ((f) = *(fp)) != NULL && ((f)->fn_key == (key)); (fp) = &(f)->fn_next)
+/* Insert node F to FZ. */
+static inline void fib_insert_node(struct fn_zone *fz, struct fib_node *f)
+{
+	struct hlist_head *head = &fz->fz_hash[fn_hash(f->fn_key, fz)];
 
-#ifndef CONFIG_IP_ROUTE_TOS
-#define FIB_SCAN_TOS(f, fp, key, tos) FIB_SCAN_KEY(f, fp, key)
-#else
-#define FIB_SCAN_TOS(f, fp, key, tos) \
-for ( ; ((f) = *(fp)) != NULL && ((f)->fn_key == (key)) && \
-     (f)->fn_tos == (tos) ; (fp) = &(f)->fn_next)
-#endif
+	hlist_add_head(&f->fn_hash, head);
+}
 
+/* Return the node in FZ matching KEY. */
+static struct fib_node *fib_find_node(struct fn_zone *fz, u32 key)
+{
+	struct hlist_head *head = &fz->fz_hash[fn_hash(key, fz)];
+	struct hlist_node *node;
+	struct fib_node *f;
 
-static void rtmsg_fib(int, struct fib_node*, int, int,
-		      struct nlmsghdr *n,
-		      struct netlink_skb_parms *);
+	hlist_for_each_entry(f, node, head, fn_hash) {
+		if (f->fn_key == key)
+			return f;
+	}
+
+	return NULL;
+}
+
+/* Return the first fib alias matching TOS with
+ * priority less than or equal to PRIO.
+ */
+static struct fib_alias *fib_find_alias(struct fib_node *fn, u8 tos, u32 prio)
+{
+	if (fn) {
+		struct list_head *head = &fn->fn_alias;
+		struct fib_alias *fa, *prev_fa;
+
+		prev_fa = NULL;
+		list_for_each_entry(fa, head, fa_list) {
+#ifdef CONFIG_IP_ROUTE_TOS
+			if (fa->fa_tos != tos)
+				continue;
+#endif
+			prev_fa = fa;
+			if (prio <= fa->fa_info->fib_priority)
+				break;
+		}
+		return fa;
+	}
+	return NULL;
+}
 
 static int
 fn_hash_insert(struct fib_table *tb, struct rtmsg *r, struct kern_rta *rta,
-		struct nlmsghdr *n, struct netlink_skb_parms *req)
+	       struct nlmsghdr *n, struct netlink_skb_parms *req)
 {
-	struct fn_hash *table = (struct fn_hash*)tb->tb_data;
-	struct fib_node *new_f, *f, **fp, **del_fp;
+	struct fn_hash *table = (struct fn_hash *) tb->tb_data;
+	struct fib_node *new_f, *f;
+	struct fib_alias *fa, *new_fa;
 	struct fn_zone *fz;
 	struct fib_info *fi;
-
 	int z = r->rtm_dst_len;
 	int type = r->rtm_type;
-#ifdef CONFIG_IP_ROUTE_TOS
 	u8 tos = r->rtm_tos;
-#endif
 	u32 key;
 	int err;
 
-FTprint("tb(%d)_insert: %d %08x/%d %d %08x\n", tb->tb_id, r->rtm_type, rta->rta_dst ?
-*(u32*)rta->rta_dst : 0, z, rta->rta_oif ? *rta->rta_oif : -1,
-rta->rta_prefsrc ? *(u32*)rta->rta_prefsrc : 0);
+#ifndef CONFIG_IP_ROUTE_TOS
+	tos = 0;
+#endif
 	if (z > 32)
 		return -EINVAL;
 	fz = table->fn_zones[z];
@@ -464,136 +497,111 @@
 	    (z==32 || (1<<z) > fz->fz_divisor))
 		fn_rehash_zone(fz);
 
-	fp = fz_chain_p(key, fz);
-
+	f = fib_find_node(fz, key);
+	fa = fib_find_alias(f, tos, fi->fib_priority);
 
-	/*
-	 * Scan list to find the first route with the same destination
-	 */
-	FIB_SCAN(f, fp) {
-		if (key <= f->fn_key)
-			break;
-	}
-
-#ifdef CONFIG_IP_ROUTE_TOS
-	/*
-	 * Find route with the same destination and tos.
+	/* Now fa, if non-NULL, points to the first fib alias
+	 * with the same keys [prefix,tos,priority], if such key already
+	 * exists or to the node before which we will insert new one.
+	 *
+	 * If fa is NULL, we will need to allocate a new one and
+	 * insert to the head of f.
+	 *
+	 * If f is NULL, no fib node matched the destination key
+	 * and we need to allocate a new one of those as well.
 	 */
-	FIB_SCAN_KEY(f, fp, key) {
-		if (f->fn_tos <= tos)
-			break;
-	}
-#endif
-
-	del_fp = NULL;
 
-	if (f && (f->fn_state&FN_S_ZOMBIE) &&
-#ifdef CONFIG_IP_ROUTE_TOS
-	    f->fn_tos == tos &&
-#endif
-	    (f->fn_key == key)) {
-		del_fp = fp;
-		fp = &f->fn_next;
-		f = *fp;
-		goto create;
-	}
-
-	FIB_SCAN_TOS(f, fp, key, tos) {
-		if (fi->fib_priority <= FIB_INFO(f)->fib_priority)
-			break;
-	}
-
-	/* Now f==*fp points to the first node with the same
-	   keys [prefix,tos,priority], if such key already
-	   exists or to the node, before which we will insert new one.
-	 */
-
-	if (f && 
-#ifdef CONFIG_IP_ROUTE_TOS
-	    f->fn_tos == tos &&
-#endif
-	    (f->fn_key == key) &&
-	    fi->fib_priority == FIB_INFO(f)->fib_priority) {
-		struct fib_node **ins_fp;
+	if (fa &&
+	    fa->fa_info->fib_priority == fi->fib_priority) {
+		struct fib_alias *fa_orig;
 
 		err = -EEXIST;
-		if (n->nlmsg_flags&NLM_F_EXCL)
+		if (n->nlmsg_flags & NLM_F_EXCL)
 			goto out;
 
-		if (n->nlmsg_flags&NLM_F_REPLACE) {
-			del_fp = fp;
-			fp = &f->fn_next;
-			f = *fp;
-			goto replace;
-		}
+		if (n->nlmsg_flags & NLM_F_REPLACE) {
+			struct fib_info *fi_drop;
+			u8 state;
 
-		ins_fp = fp;
-		err = -EEXIST;
+			write_lock_bh(&fib_hash_lock);
+			fi_drop = fa->fa_info;
+			fa->fa_info = fi;
+			fa->fa_type = type;
+			fa->fa_scope = r->rtm_scope;
+			state = fa->fa_state;
+			fa->fa_state &= ~FN_S_ACCESSED;
+			write_unlock_bh(&fib_hash_lock);
 
-		FIB_SCAN_TOS(f, fp, key, tos) {
-			if (fi->fib_priority != FIB_INFO(f)->fib_priority)
-				break;
-			if (f->fn_type == type && f->fn_scope == r->rtm_scope
-			    && FIB_INFO(f) == fi)
-				goto out;
+			fib_release_info(fi_drop);
+			if (state & FN_S_ACCESSED)
+				rt_cache_flush(-1);
+			return 0;
 		}
 
-		if (!(n->nlmsg_flags&NLM_F_APPEND)) {
-			fp = ins_fp;
-			f = *fp;
+		/* Error if we find a perfect match which
+		 * uses the same scope, type, and nexthop
+		 * information.
+		 */
+		fa_orig = fa;
+		list_for_each_entry(fa, fa->fa_list.prev, fa_list) {
+			if (fa->fa_info->fib_priority != fi->fib_priority)
+				break;
+			if (fa->fa_type == type &&
+			    fa->fa_scope == r->rtm_scope &&
+			    fa->fa_info == fi)
+				goto out;
 		}
+		if (!(n->nlmsg_flags & NLM_F_APPEND))
+			fa = fa_orig;
 	}
 
-create:
 	err = -ENOENT;
 	if (!(n->nlmsg_flags&NLM_F_CREATE))
 		goto out;
 
-replace:
 	err = -ENOBUFS;
-	new_f = kmem_cache_alloc(fn_hash_kmem, SLAB_KERNEL);
-	if (new_f == NULL)
+	new_fa = kmem_cache_alloc(fn_alias_kmem, SLAB_KERNEL);
+	if (new_fa == NULL)
 		goto out;
 
-	memset(new_f, 0, sizeof(struct fib_node));
-
-	new_f->fn_key = key;
-#ifdef CONFIG_IP_ROUTE_TOS
-	new_f->fn_tos = tos;
-#endif
-	new_f->fn_type = type;
-	new_f->fn_scope = r->rtm_scope;
-	FIB_INFO(new_f) = fi;
+	new_f = NULL;
+	if (!f) {
+		new_f = kmem_cache_alloc(fn_hash_kmem, SLAB_KERNEL);
+		if (new_f == NULL)
+			goto out_free_new_fa;
+
+		INIT_HLIST_NODE(&new_f->fn_hash);
+		INIT_LIST_HEAD(&new_f->fn_alias);
+		new_f->fn_key = key;
+		f = new_f;
+	}
+
+	new_fa->fa_info = fi;
+	new_fa->fa_tos = tos;
+	new_fa->fa_type = type;
+	new_fa->fa_scope = r->rtm_scope;
+	new_fa->fa_state = 0;
 
 	/*
 	 * Insert new entry to the list.
 	 */
 
-	new_f->fn_next = f;
 	write_lock_bh(&fib_hash_lock);
-	*fp = new_f;
+	if (new_f)
+		fib_insert_node(fz, new_f);
+	list_add(&new_fa->fa_list,
+		 (fa ? &fa->fa_list : &f->fn_alias));
 	write_unlock_bh(&fib_hash_lock);
-	fz->fz_nent++;
 
-	if (del_fp) {
-		f = *del_fp;
-		/* Unlink replaced node */
-		write_lock_bh(&fib_hash_lock);
-		*del_fp = f->fn_next;
-		write_unlock_bh(&fib_hash_lock);
+	if (new_f)
+		fz->fz_nent++;
+	rt_cache_flush(-1);
 
-		if (!(f->fn_state&FN_S_ZOMBIE))
-			rtmsg_fib(RTM_DELROUTE, f, z, tb->tb_id, n, req);
-		if (f->fn_state&FN_S_ACCESSED)
-			rt_cache_flush(-1);
-		fn_free_node(f);
-		fz->fz_nent--;
-	} else {
-		rt_cache_flush(-1);
-	}
-	rtmsg_fib(RTM_NEWROUTE, new_f, z, tb->tb_id, n, req);
+	rtmsg_fib(RTM_NEWROUTE, f, new_fa, z, tb->tb_id, n, req);
 	return 0;
 
+out_free_new_fa:
+	kmem_cache_free(fn_alias_kmem, new_fa);
 out:
 	fib_release_info(fi);
 	return err;
@@ -602,20 +610,19 @@
 
 static int
 fn_hash_delete(struct fib_table *tb, struct rtmsg *r, struct kern_rta *rta,
-		struct nlmsghdr *n, struct netlink_skb_parms *req)
+	       struct nlmsghdr *n, struct netlink_skb_parms *req)
 {
 	struct fn_hash *table = (struct fn_hash*)tb->tb_data;
-	struct fib_node **fp, **del_fp, *f;
+	struct fib_node *f;
+	struct fib_alias *fa, *fa_to_delete;
 	int z = r->rtm_dst_len;
 	struct fn_zone *fz;
 	u32 key;
-	int matched;
-#ifdef CONFIG_IP_ROUTE_TOS
 	u8 tos = r->rtm_tos;
-#endif
 
-FTprint("tb(%d)_delete: %d %08x/%d %d\n", tb->tb_id, r->rtm_type, rta->rta_dst ?
-       *(u32*)rta->rta_dst : 0, z, rta->rta_oif ? *rta->rta_oif : -1);
+#ifndef CONFIG_IP_ROUTE_TOS
+	tos = 0;
+#endif
 	if (z > 32)
 		return -EINVAL;
 	if ((fz  = table->fn_zones[z]) == NULL)
@@ -630,61 +637,48 @@
 		key = fz_key(dst, fz);
 	}
 
-	fp = fz_chain_p(key, fz);
-
+	f = fib_find_node(fz, key);
+	fa = fib_find_alias(f, tos, 0);
+	if (!fa)
+		return -ESRCH;
 
-	FIB_SCAN(f, fp) {
-		if (f->fn_key == key)
-			break;
-		if (key <= f->fn_key)
-			return -ESRCH;
-	}
-#ifdef CONFIG_IP_ROUTE_TOS
-	FIB_SCAN_KEY(f, fp, key) {
-		if (f->fn_tos == tos)
+	fa_to_delete = NULL;
+	list_for_each_entry(fa, fa->fa_list.prev, fa_list) {
+		struct fib_info *fi = fa->fa_info;
+
+		if ((!r->rtm_type ||
+		     fa->fa_type == r->rtm_type) &&
+		    (r->rtm_scope == RT_SCOPE_NOWHERE ||
+		     fa->fa_scope == r->rtm_scope) &&
+		    (!r->rtm_protocol ||
+		     fi->fib_protocol == r->rtm_protocol) &&
+		    fib_nh_match(r, n, rta, fi) == 0) {
+			fa_to_delete = fa;
 			break;
-	}
-#endif
-
-	matched = 0;
-	del_fp = NULL;
-	FIB_SCAN_TOS(f, fp, key, tos) {
-		struct fib_info * fi = FIB_INFO(f);
-
-		if (f->fn_state&FN_S_ZOMBIE) {
-			return -ESRCH;
 		}
-		matched++;
-
-		if (del_fp == NULL &&
-		    (!r->rtm_type || f->fn_type == r->rtm_type) &&
-		    (r->rtm_scope == RT_SCOPE_NOWHERE || f->fn_scope == r->rtm_scope) &&
-		    (!r->rtm_protocol || fi->fib_protocol == r->rtm_protocol) &&
-		    fib_nh_match(r, n, rta, fi) == 0)
-			del_fp = fp;
 	}
 
-	if (del_fp) {
-		f = *del_fp;
-		rtmsg_fib(RTM_DELROUTE, f, z, tb->tb_id, n, req);
+	if (fa_to_delete) {
+		int kill_fn;
 
-		if (matched != 1) {
-			write_lock_bh(&fib_hash_lock);
-			*del_fp = f->fn_next;
-			write_unlock_bh(&fib_hash_lock);
+		fa = fa_to_delete;
+		rtmsg_fib(RTM_DELROUTE, f, fa, z, tb->tb_id, n, req);
 
-			if (f->fn_state&FN_S_ACCESSED)
-				rt_cache_flush(-1);
+		kill_fn = 0;
+		write_lock_bh(&fib_hash_lock);
+		list_del(&fa->fa_list);
+		if (list_empty(&f->fn_alias)) {
+			hlist_del(&f->fn_hash);
+			kill_fn = 1;
+		}
+		write_unlock_bh(&fib_hash_lock);
+
+		if (fa->fa_state & FN_S_ACCESSED)
+			rt_cache_flush(-1);
+		fn_free_alias(fa);
+		if (kill_fn) {
 			fn_free_node(f);
 			fz->fz_nent--;
-		} else {
-			f->fn_state |= FN_S_ZOMBIE;
-			if (f->fn_state&FN_S_ACCESSED) {
-				f->fn_state &= ~FN_S_ACCESSED;
-				rt_cache_flush(-1);
-			}
-			if (++fib_hash_zombies > 128)
-				fib_flush();
 		}
 
 		return 0;
@@ -692,43 +686,53 @@
 	return -ESRCH;
 }
 
-static inline int
-fn_flush_list(struct fib_node ** fp, int z, struct fn_hash *table)
+static int fn_flush_list(struct fn_zone *fz, int idx)
 {
-	int found = 0;
+	struct hlist_head *head = &fz->fz_hash[idx];
+	struct hlist_node *node, *n;
 	struct fib_node *f;
+	int found = 0;
 
-	while ((f = *fp) != NULL) {
-		struct fib_info *fi = FIB_INFO(f);
-
-		if (fi && ((f->fn_state&FN_S_ZOMBIE) || (fi->fib_flags&RTNH_F_DEAD))) {
-			write_lock_bh(&fib_hash_lock);
-			*fp = f->fn_next;
-			write_unlock_bh(&fib_hash_lock);
+	hlist_for_each_entry_safe(f, node, n, head, fn_hash) {
+		struct fib_alias *fa, *fa_node;
+		int kill_f;
+
+		kill_f = 0;
+		list_for_each_entry_safe(fa, fa_node, &f->fn_alias, fa_list) {
+			struct fib_info *fi = fa->fa_info;
+
+			if (fi && (fi->fib_flags&RTNH_F_DEAD)) {
+				write_lock_bh(&fib_hash_lock);
+				list_del(&fa->fa_list);
+				if (list_empty(&f->fn_alias)) {
+					hlist_del(&f->fn_hash);
+					kill_f = 1;
+				}
+				write_unlock_bh(&fib_hash_lock);
 
+				fn_free_alias(fa);
+				found++;
+			}
+		}
+		if (kill_f) {
 			fn_free_node(f);
-			found++;
-			continue;
+			fz->fz_nent--;
 		}
-		fp = &f->fn_next;
 	}
 	return found;
 }
 
 static int fn_hash_flush(struct fib_table *tb)
 {
-	struct fn_hash *table = (struct fn_hash*)tb->tb_data;
+	struct fn_hash *table = (struct fn_hash *) tb->tb_data;
 	struct fn_zone *fz;
 	int found = 0;
 
-	fib_hash_zombies = 0;
 	for (fz = table->fn_zone_list; fz; fz = fz->fz_next) {
 		int i;
-		int tmp = 0;
-		for (i=fz->fz_divisor-1; i>=0; i--)
-			tmp += fn_flush_list(&fz->fz_hash[i], fz->fz_order, table);
-		fz->fz_nent -= tmp;
-		found += tmp;
+
+		for (i = fz->fz_divisor - 1; i >= 0; i--)
+			found += fn_flush_list(fz, i);
 	}
 	return found;
 }
@@ -738,21 +742,36 @@
 fn_hash_dump_bucket(struct sk_buff *skb, struct netlink_callback *cb,
 		     struct fib_table *tb,
 		     struct fn_zone *fz,
-		     struct fib_node *f)
+		     struct hlist_head *head)
 {
+	struct hlist_node *node;
+	struct fib_node *f;
 	int i, s_i;
 
 	s_i = cb->args[3];
-	for (i=0; f; i++, f=f->fn_next) {
-		if (i < s_i) continue;
-		if (f->fn_state&FN_S_ZOMBIE) continue;
-		if (fib_dump_info(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
-				  RTM_NEWROUTE,
-				  tb->tb_id, (f->fn_state&FN_S_ZOMBIE) ? 0 : f->fn_type, f->fn_scope,
-				  &f->fn_key, fz->fz_order, f->fn_tos,
-				  f->fn_info) < 0) {
-			cb->args[3] = i;
-			return -1;
+	i = 0;
+	hlist_for_each_entry(f, node, head, fn_hash) {
+		struct fib_alias *fa;
+
+		list_for_each_entry(fa, &f->fn_alias, fa_list) {
+			if (i < s_i)
+				continue;
+
+			if (fib_dump_info(skb, NETLINK_CB(cb->skb).pid,
+					  cb->nlh->nlmsg_seq,
+					  RTM_NEWROUTE,
+					  tb->tb_id,
+					  fa->fa_type,
+					  fa->fa_scope,
+					  &f->fn_key,
+					  fz->fz_order,
+					  fa->fa_tos,
+					  fa->fa_info) < 0) {
+				cb->args[3] = i;
+				return -1;
+			}
+
+			i++;
 		}
 	}
 	cb->args[3] = i;
@@ -770,10 +789,12 @@
 	for (h=0; h < fz->fz_divisor; h++) {
 		if (h < s_h) continue;
 		if (h > s_h)
-			memset(&cb->args[3], 0, sizeof(cb->args) - 3*sizeof(cb->args[0]));
-		if (fz->fz_hash == NULL || fz->fz_hash[h] == NULL)
+			memset(&cb->args[3], 0,
+			       sizeof(cb->args) - 3*sizeof(cb->args[0]));
+		if (fz->fz_hash == NULL ||
+		    hlist_empty(&fz->fz_hash[h]))
 			continue;
-		if (fn_hash_dump_bucket(skb, cb, tb, fz, fz->fz_hash[h]) < 0) {
+		if (fn_hash_dump_bucket(skb, cb, tb, fz, &fz->fz_hash[h])<0) {
 			cb->args[2] = h;
 			return -1;
 		}
@@ -793,7 +814,8 @@
 	for (fz = table->fn_zone_list, m=0; fz; fz = fz->fz_next, m++) {
 		if (m < s_m) continue;
 		if (m > s_m)
-			memset(&cb->args[2], 0, sizeof(cb->args) - 2*sizeof(cb->args[0]));
+			memset(&cb->args[2], 0,
+			       sizeof(cb->args) - 2*sizeof(cb->args[0]));
 		if (fn_hash_dump_zone(skb, cb, tb, fz) < 0) {
 			cb->args[1] = m;
 			read_unlock(&fib_hash_lock);
@@ -805,7 +827,8 @@
 	return skb->len;
 }
 
-static void rtmsg_fib(int event, struct fib_node* f, int z, int tb_id,
+static void rtmsg_fib(int event, struct fib_node *f, struct fib_alias *fa,
+		      int z, int tb_id,
 		      struct nlmsghdr *n, struct netlink_skb_parms *req)
 {
 	struct sk_buff *skb;
@@ -817,8 +840,9 @@
 		return;
 
 	if (fib_dump_info(skb, pid, n->nlmsg_seq, event, tb_id,
-			  f->fn_type, f->fn_scope, &f->fn_key, z, f->fn_tos,
-			  FIB_INFO(f)) < 0) {
+			  fa->fa_type, fa->fa_scope, &f->fn_key, z,
+			  fa->fa_tos,
+			  fa->fa_info) < 0) {
 		kfree_skb(skb);
 		return;
 	}
@@ -844,7 +868,14 @@
 						 0, SLAB_HWCACHE_ALIGN,
 						 NULL, NULL);
 
-	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct fn_hash), GFP_KERNEL);
+	if (fn_alias_kmem == NULL)
+		fn_alias_kmem = kmem_cache_create("ip_fib_alias",
+						  sizeof(struct fib_alias),
+						  0, SLAB_HWCACHE_ALIGN,
+						  NULL, NULL);
+
+	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct fn_hash),
+		     GFP_KERNEL);
 	if (tb == NULL)
 		return NULL;
 
@@ -865,18 +896,20 @@
 struct fib_iter_state {
 	struct fn_zone	*zone;
 	int		bucket;
-	struct fib_node **hash;
-	struct fib_node *node;
+	struct hlist_head *hash_head;
+	struct fib_node *fn;
+	struct fib_alias *fa;
 };
 
-static inline struct fib_node *fib_get_first(struct seq_file *seq)
+static struct fib_alias *fib_get_first(struct seq_file *seq)
 {
-	struct fib_iter_state* iter = seq->private;
-	struct fn_hash *table = (struct fn_hash *)ip_fib_main_table->tb_data;
+	struct fib_iter_state *iter = seq->private;
+	struct fn_hash *table = (struct fn_hash *) ip_fib_main_table->tb_data;
 
-	iter->bucket = 0;
-	iter->hash   = NULL;
-	iter->node   = NULL;
+	iter->bucket    = 0;
+	iter->hash_head = NULL;
+	iter->fn        = NULL;
+	iter->fa        = NULL;
 
 	for (iter->zone = table->fn_zone_list; iter->zone;
 	     iter->zone = iter->zone->fz_next) {
@@ -885,44 +918,83 @@
 		if (!iter->zone->fz_next)
 			continue;
 
-		iter->hash = iter->zone->fz_hash;
+		iter->hash_head = iter->zone->fz_hash;
 		maxslot = iter->zone->fz_divisor;
 
 		for (iter->bucket = 0; iter->bucket < maxslot;
-		     ++iter->bucket, ++iter->hash) {
-			iter->node = *iter->hash;
-
-			if (iter->node)
-				goto out;
+		     ++iter->bucket, ++iter->hash_head) {
+			struct hlist_node *node;
+			struct fib_node *fn;
+
+			hlist_for_each_entry(fn,node,iter->hash_head,fn_hash) {
+				struct fib_alias *fa;
+
+				list_for_each_entry(fa,&fn->fn_alias,fa_list) {
+					iter->fn = fn;
+					iter->fa = fa;
+					goto out;
+				}
+			}
 		}
 	}
 out:
-	return iter->node;
+	return iter->fa;
 }
 
-static inline struct fib_node *fib_get_next(struct seq_file *seq)
+static struct fib_alias *fib_get_next(struct seq_file *seq)
 {
-	struct fib_iter_state* iter = seq->private;
+	struct fib_iter_state *iter = seq->private;
+	struct fib_node *fn;
+	struct fib_alias *fa;
+
+	/* Advance FA, if any. */
+	fn = iter->fn;
+	fa = iter->fa;
+	if (fa) {
+		BUG_ON(!fn);
+		list_for_each_entry_continue(fa, &fn->fn_alias, fa_list) {
+			iter->fa = fa;
+			goto out;
+		}
+	}
 
-	if (iter->node)
-		iter->node = iter->node->fn_next;
+	fa = iter->fa = NULL;
 
-	if (iter->node)
-		goto out;
+	/* Advance FN. */
+	if (fn) {
+		struct hlist_node *node = &fn->fn_hash;
+		hlist_for_each_entry_continue(fn, node, fn_hash) {
+			iter->fn = fn;
+
+			list_for_each_entry(fa, &fn->fn_alias, fa_list) {
+				iter->fa = fa;
+				goto out;
+			}
+		}
+	}
 
+	fn = iter->fn = NULL;
+
+	/* Advance hash chain. */
 	if (!iter->zone)
 		goto out;
 
 	for (;;) {
+		struct hlist_node *node;
 		int maxslot;
 
 		maxslot = iter->zone->fz_divisor;
 
 		while (++iter->bucket < maxslot) {
-			iter->node = *++iter->hash;
+			iter->hash_head++;
 
-			if (iter->node)
-				goto out;
+			hlist_for_each_entry(fn, node, iter->hash_head, fn_hash) {
+				list_for_each_entry(fa, &fn->fn_alias, fa_list) {
+					iter->fn = fn;
+					iter->fa = fa;
+					goto out;
+				}
+			}
 		}
 
 		iter->zone = iter->zone->fz_next;
@@ -930,14 +1002,19 @@
 		if (!iter->zone)
 			goto out;
 		
-		iter->hash = iter->zone->fz_hash;
 		iter->bucket = 0;
-		iter->node = *iter->hash;
-		if (iter->node)
-			break;
+		iter->hash_head = iter->zone->fz_hash;
+
+		hlist_for_each_entry(fn, node, iter->hash_head, fn_hash) {
+			list_for_each_entry(fa, &fn->fn_alias, fa_list) {
+				iter->fn = fn;
+				iter->fa = fa;
+				goto out;
+			}
+		}
 	}
 out:
-	return iter->node;
+	return fa;
 }
 
 static void *fib_seq_start(struct seq_file *seq, loff_t *pos)
@@ -961,7 +1038,7 @@
 	read_unlock(&fib_hash_lock);
 }
 
-static unsigned fib_flag_trans(int type, int dead, u32 mask, struct fib_info *fi)
+static unsigned fib_flag_trans(int type, u32 mask, struct fib_info *fi)
 {
 	static unsigned type2flags[RTN_MAX + 1] = {
 		[7] = RTF_REJECT, [8] = RTF_REJECT,
@@ -972,8 +1049,7 @@
 		flags |= RTF_GATEWAY;
 	if (mask == 0xFFFFFFFF)
 		flags |= RTF_HOST;
-	if (!dead)
-		flags |= RTF_UP;
+	flags |= RTF_UP;
 	return flags;
 }
 
@@ -985,11 +1061,12 @@
  */
 static int fib_seq_show(struct seq_file *seq, void *v)
 {
-	struct fib_iter_state* iter;
+	struct fib_iter_state *iter;
 	char bf[128];
 	u32 prefix, mask;
 	unsigned flags;
 	struct fib_node *f;
+	struct fib_alias *fa;
 	struct fib_info *fi;
 
 	if (v == SEQ_START_TOKEN) {
@@ -999,13 +1076,13 @@
 		goto out;
 	}
 
-	f	= v;
-	fi	= FIB_INFO(f);
 	iter	= seq->private;
+	f	= iter->fn;
+	fa	= iter->fa;
+	fi	= fa->fa_info;
 	prefix	= f->fn_key;
 	mask	= FZ_MASK(iter->zone);
-	flags	= fib_flag_trans(f->fn_type, f->fn_state & FN_S_ZOMBIE,
-				 mask, fi);
+	flags	= fib_flag_trans(fa->fa_type, mask, fi);
 	if (fi)
 		snprintf(bf, sizeof(bf),
 			 "%s\t%08X\t%08X\t%04X\t%d\t%u\t%d\t%08X\t%d\t%u\t%u",
