From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH] Making fib_semantics.c scale
Date: Tue, 14 Sep 2004 16:39:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914163950.0ae81d45.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bcrl@kvack.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ben, I've been hacking on fixing the routing scaling
issues you found with your L2TP work.

You mention dev_get_by_index() et al, those are already
using nicer lookup schemes in the 2.6.x kernel and I'd
happily accept a 2.4.x backport.

The patch below is what I'm working with, against current
2.6.x  It takes care of the fib_create_info() and fib_sync_down()
overhead.  fn_hash_flush() will probably still show up in your
profiles and slow things down a bit, that one is a little harder
to solve.

Give this a go and let me know how well it works to improve
your test case.

Thanks.

--- ../linus-2.6/include/net/ip_fib.h	2004-09-14 16:18:53.000000000 -0700
+++ include/net/ip_fib.h	2004-09-14 15:35:01.000000000 -0700
@@ -23,8 +23,7 @@
 /* WARNING: The ordering of these elements must match ordering
  *          of RTA_* rtnetlink attribute numbers.
  */
-struct kern_rta
-{
+struct kern_rta {
 	void		*rta_dst;
 	void		*rta_src;
 	int		*rta_iif;
@@ -40,9 +39,12 @@
 	struct rta_session *rta_sess;
 };
 
-struct fib_nh
-{
-	struct net_device		*nh_dev;
+struct fib_info;
+
+struct fib_nh {
+	struct net_device	*nh_dev;
+	struct hlist_node	nh_hash;
+	struct fib_info		*nh_parent;
 	unsigned		nh_flags;
 	unsigned char		nh_scope;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
@@ -60,10 +62,9 @@
  * This structure contains data shared by many of routes.
  */
 
-struct fib_info
-{
-	struct fib_info		*fib_next;
-	struct fib_info		*fib_prev;
+struct fib_info {
+	struct hlist_node	fib_hash;
+	struct hlist_node	fib_lhash;
 	int			fib_treeref;
 	atomic_t		fib_clntref;
 	int			fib_dead;
@@ -89,8 +90,7 @@
 struct fib_rule;
 #endif
 
-struct fib_result
-{
+struct fib_result {
 	unsigned char	prefixlen;
 	unsigned char	nh_sel;
 	unsigned char	type;
@@ -119,8 +119,7 @@
 #define FIB_RES_DEV(res)		(FIB_RES_NH(res).nh_dev)
 #define FIB_RES_OIF(res)		(FIB_RES_NH(res).nh_oif)
 
-struct fib_table
-{
+struct fib_table {
 	unsigned char	tb_id;
 	unsigned	tb_stamp;
 	int		(*tb_lookup)(struct fib_table *tb, const struct flowi *flp, struct fib_result *res);
--- ../linus-2.6/net/ipv4/fib_semantics.c	2004-09-14 16:18:56.000000000 -0700
+++ net/ipv4/fib_semantics.c	2004-09-14 16:18:26.000000000 -0700
@@ -45,14 +45,12 @@
 
 #define FSprintk(a...)
 
-static struct fib_info 	*fib_info_list;
 static rwlock_t fib_info_lock = RW_LOCK_UNLOCKED;
-int fib_info_cnt;
-
-#define for_fib_info() { struct fib_info *fi; \
-	for (fi = fib_info_list; fi; fi = fi->fib_next)
-
-#define endfor_fib_info() }
+static struct hlist_head *fib_info_hash;
+static struct hlist_head *fib_info_devhash;
+static struct hlist_head *fib_info_laddrhash;
+static unsigned int fib_hash_size;
+static unsigned int fib_info_cnt;
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
@@ -156,12 +154,12 @@
 {
 	write_lock(&fib_info_lock);
 	if (fi && --fi->fib_treeref == 0) {
-		if (fi->fib_next)
-			fi->fib_next->fib_prev = fi->fib_prev;
-		if (fi->fib_prev)
-			fi->fib_prev->fib_next = fi->fib_next;
-		if (fi == fib_info_list)
-			fib_info_list = fi->fib_next;
+		hlist_del(&fi->fib_hash);
+		if (fi->fib_prefsrc)
+			hlist_del(&fi->fib_lhash);
+		change_nexthops(fi) {
+			hlist_del(&nh->nh_hash);
+		} endfor_nexthops(fi)
 		fi->fib_dead = 1;
 		fib_info_put(fi);
 	}
@@ -189,42 +187,77 @@
 	return 0;
 }
 
-static __inline__ struct fib_info * fib_find_info(const struct fib_info *nfi)
+static unsigned int fib_info_hashfn(const struct fib_info *fi)
+{
+	unsigned int mask = (fib_hash_size - 1);
+	unsigned int val = fi->fib_nhs;
+
+	val ^= fi->fib_protocol;
+	val ^= fi->fib_prefsrc;
+	val ^= fi->fib_priority;
+
+	return (val ^ (val >> 7) ^ (val >> 12)) & mask;
+}
+
+static struct fib_info *fib_find_info(const struct fib_info *nfi)
 {
-	for_fib_info() {
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct fib_info *fi;
+	unsigned int hash;
+
+	hash = fib_info_hashfn(nfi);
+	head = &fib_info_hash[hash];
+
+	hlist_for_each_entry(fi, node, head, fib_hash) {
 		if (fi->fib_nhs != nfi->fib_nhs)
 			continue;
 		if (nfi->fib_protocol == fi->fib_protocol &&
 		    nfi->fib_prefsrc == fi->fib_prefsrc &&
 		    nfi->fib_priority == fi->fib_priority &&
-		    memcmp(nfi->fib_metrics, fi->fib_metrics, sizeof(fi->fib_metrics)) == 0 &&
+		    memcmp(nfi->fib_metrics, fi->fib_metrics,
+			   sizeof(fi->fib_metrics)) == 0 &&
 		    ((nfi->fib_flags^fi->fib_flags)&~RTNH_F_DEAD) == 0 &&
 		    (nfi->fib_nhs == 0 || nh_comp(fi, nfi) == 0))
 			return fi;
-	} endfor_fib_info();
+	}
+
 	return NULL;
 }
 
+static unsigned int fib_devindex_hashfn(unsigned int val)
+{
+	unsigned int mask = (fib_hash_size - 1);
+
+	return (val ^ (val >> 4) ^ (val >> 9)) & mask;
+}
+
 /* Check, that the gateway is already configured.
    Used only by redirect accept routine.
  */
 
 int ip_fib_check_default(u32 gw, struct net_device *dev)
 {
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct fib_nh *nh;
+	unsigned int hash;
+
 	read_lock(&fib_info_lock);
-	for_fib_info() {
-		if (fi->fib_flags & RTNH_F_DEAD)
-			continue;
-		for_nexthops(fi) {
-			if (nh->nh_dev == dev && nh->nh_gw == gw &&
-			    nh->nh_scope == RT_SCOPE_LINK &&
-			    !(nh->nh_flags&RTNH_F_DEAD)) {
-				read_unlock(&fib_info_lock);
-				return 0;
-			}
-		} endfor_nexthops(fi);
-	} endfor_fib_info();
+
+	hash = fib_devindex_hashfn(dev->ifindex);
+	head = &fib_info_devhash[hash];
+	hlist_for_each_entry(nh, node, head, nh_hash) {
+		if (nh->nh_dev == dev &&
+		    nh->nh_gw == gw &&
+		    !(nh->nh_flags&RTNH_F_DEAD)) {
+			read_unlock(&fib_info_lock);
+			return 0;
+		}
+	}
+
 	read_unlock(&fib_info_lock);
+
 	return -1;
 }
 
@@ -451,6 +484,101 @@
 	return 0;
 }
 
+static unsigned int fib_laddr_hashfn(u32 val)
+{
+	unsigned int mask = (fib_hash_size - 1);
+
+	return (val ^ (val >> 7) ^ (val >> 14)) & mask;
+}
+
+static struct hlist_head *fib_hash_alloc(int bytes)
+{
+	if (bytes <= PAGE_SIZE)
+		return kmalloc(bytes, GFP_KERNEL);
+	else
+		return (struct hlist_head *)
+			__get_free_pages(GFP_KERNEL, get_order(bytes));
+}
+
+static void fib_hash_free(struct hlist_head *hash, int bytes)
+{
+	if (!hash)
+		return;
+
+	if (bytes <= PAGE_SIZE)
+		kfree(hash);
+	else
+		free_pages((unsigned long) hash, get_order(bytes));
+}
+
+static void fib_hash_move(struct hlist_head *new_info_hash,
+			  struct hlist_head *new_devhash,
+			  struct hlist_head *new_laddrhash,
+			  unsigned int new_size)
+{
+	unsigned int old_size = fib_hash_size;
+	unsigned int i;
+
+	write_lock(&fib_info_lock);
+	fib_hash_size = new_size;
+
+	for (i = 0; i < old_size; i++) {
+		struct hlist_head *head = &fib_info_hash[i];
+		struct hlist_node *node;
+		struct fib_info *fi;
+
+		hlist_for_each_entry(fi, node, head, fib_hash) {
+			struct hlist_head *dest;
+			unsigned int new_hash;
+
+			hlist_del(&fi->fib_hash);
+
+			new_hash = fib_info_hashfn(fi);
+			dest = &new_info_hash[new_hash];
+			hlist_add_head(&fi->fib_hash, dest);
+		}
+	}
+	fib_info_hash = new_info_hash;
+
+	for (i = 0; i < old_size; i++) {
+		struct hlist_head *dhead = &fib_info_devhash[i];
+		struct hlist_node *node;
+		struct fib_nh *nh;
+
+		hlist_for_each_entry(nh, node, dhead, nh_hash) {
+			struct hlist_head *ddest;
+			unsigned int new_hash;
+
+			hlist_del(&nh->nh_hash);
+
+			new_hash = fib_devindex_hashfn(nh->nh_dev->ifindex);
+			ddest = &new_devhash[new_hash];
+			hlist_add_head(&nh->nh_hash, ddest);
+		}
+	}
+	fib_info_devhash = new_devhash;
+
+	for (i = 0; i < old_size; i++) {
+		struct hlist_head *lhead = &fib_info_laddrhash[i];
+		struct hlist_node *node;
+		struct fib_info *fi;
+
+		hlist_for_each_entry(fi, node, lhead, fib_lhash) {
+			struct hlist_head *ldest;
+			unsigned int new_hash;
+
+			hlist_del(&fi->fib_lhash);
+
+			new_hash = fib_laddr_hashfn(fi->fib_prefsrc);
+			ldest = &new_laddrhash[new_hash];
+			hlist_add_head(&fi->fib_lhash, ldest);
+		}
+	}
+	fib_info_laddrhash = new_laddrhash;
+
+	write_unlock(&fib_info_lock);
+}
+
 struct fib_info *
 fib_create_info(const struct rtmsg *r, struct kern_rta *rta,
 		const struct nlmsghdr *nlh, int *errp)
@@ -476,15 +604,45 @@
 	}
 #endif
 
-	fi = kmalloc(sizeof(*fi)+nhs*sizeof(struct fib_nh), GFP_KERNEL);
 	err = -ENOBUFS;
+	if (fib_info_cnt >= fib_hash_size) {
+		unsigned int new_size = fib_hash_size << 1;
+		struct hlist_head *new_info_hash;
+		struct hlist_head *new_devhash;
+		struct hlist_head *new_laddrhash;
+		unsigned int bytes;
+
+		if (!new_size)
+			new_size = 1;
+		bytes = new_size * sizeof(struct hlist_head *);
+		new_info_hash = fib_hash_alloc(bytes);
+		new_devhash = fib_hash_alloc(bytes);
+		new_laddrhash = fib_hash_alloc(bytes);
+		if (!new_info_hash || !new_devhash || !new_laddrhash) {
+			fib_hash_free(new_info_hash, bytes);
+			fib_hash_free(new_devhash, bytes);
+			fib_hash_free(new_laddrhash, bytes);
+		} else
+			fib_hash_move(new_info_hash, new_devhash,
+				      new_laddrhash, new_size);
+
+		if (!fib_hash_size)
+			goto failure;
+	}
+
+	fi = kmalloc(sizeof(*fi)+nhs*sizeof(struct fib_nh), GFP_KERNEL);
 	if (fi == NULL)
 		goto failure;
 	fib_info_cnt++;
 	memset(fi, 0, sizeof(*fi)+nhs*sizeof(struct fib_nh));
 
 	fi->fib_protocol = r->rtm_protocol;
+
 	fi->fib_nhs = nhs;
+	change_nexthops(fi) {
+		nh->nh_parent = fi;
+	} endfor_nexthops(fi)
+
 	fi->fib_flags = r->rtm_flags;
 	if (rta->rta_priority)
 		fi->fib_priority = *rta->rta_priority;
@@ -581,11 +739,24 @@
 	fi->fib_treeref++;
 	atomic_inc(&fi->fib_clntref);
 	write_lock(&fib_info_lock);
-	fi->fib_next = fib_info_list;
-	fi->fib_prev = NULL;
-	if (fib_info_list)
-		fib_info_list->fib_prev = fi;
-	fib_info_list = fi;
+	hlist_add_head(&fi->fib_hash,
+		       &fib_info_hash[fib_info_hashfn(fi)]);
+	if (fi->fib_prefsrc) {
+		struct hlist_head *head;
+
+		head = &fib_info_laddrhash[fib_laddr_hashfn(fi->fib_prefsrc)];
+		hlist_add_head(&fi->fib_lhash, head);
+	}
+	change_nexthops(fi) {
+		struct hlist_head *head;
+		unsigned int hash;
+
+		if (!nh->nh_dev)
+			continue;
+		hash = fib_devindex_hashfn(nh->nh_dev->ifindex);
+		head = &fib_info_devhash[hash];
+		hlist_add_head(&nh->nh_hash, head);
+	} endfor_nexthops(fi)
 	write_unlock(&fib_info_lock);
 	return fi;
 
@@ -884,13 +1055,38 @@
 	if (force)
 		scope = -1;
 
-	for_fib_info() {
-		if (local && fi->fib_prefsrc == local) {
-			fi->fib_flags |= RTNH_F_DEAD;
-			ret++;
-		} else if (dev && fi->fib_nhs) {
-			int dead = 0;
+	BUG_ON(!fib_info_laddrhash || !fib_info_devhash);
+
+	if (local) {
+		unsigned int hash = fib_laddr_hashfn(local);
+		struct hlist_head *head = &fib_info_laddrhash[hash];
+		struct hlist_node *node;
+		struct fib_info *fi;
+
+		hlist_for_each_entry(fi, node, head, fib_lhash) {
+			if (fi->fib_prefsrc == local) {
+				fi->fib_flags |= RTNH_F_DEAD;
+				ret++;
+			}
+		}
+	}
+
+	if (dev) {
+		struct fib_info *prev_fi = NULL;
+		unsigned int hash = fib_devindex_hashfn(dev->ifindex);
+		struct hlist_head *head = &fib_info_devhash[hash];
+		struct hlist_node *node;
+		struct fib_nh *nh;
+
+		hlist_for_each_entry(nh, node, head, nh_hash) {
+			struct fib_info *fi = nh->nh_parent;
+			int dead;
 
+			BUG_ON(!fi->fib_nhs);
+			if (nh->nh_dev != dev || fi == prev_fi)
+				continue;
+			prev_fi = fi;
+			dead = 0;
 			change_nexthops(fi) {
 				if (nh->nh_flags&RTNH_F_DEAD)
 					dead++;
@@ -917,7 +1113,8 @@
 				ret++;
 			}
 		}
-	} endfor_fib_info();
+	}
+
 	return ret;
 }
 
@@ -930,14 +1127,33 @@
 
 int fib_sync_up(struct net_device *dev)
 {
-	int ret = 0;
+	struct fib_info *prev_fi;
+	unsigned int hash;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct fib_nh *nh;
+	int ret;
+
+	BUG_ON(!fib_info_devhash);
 
 	if (!(dev->flags&IFF_UP))
 		return 0;
 
-	for_fib_info() {
-		int alive = 0;
+	prev_fi = NULL;
+	hash = fib_devindex_hashfn(dev->ifindex);
+	head = &fib_info_devhash[hash];
+	ret = 0;
+
+	hlist_for_each_entry(nh, node, head, nh_hash) {
+		struct fib_info *fi = nh->nh_parent;
+		int alive;
+
+		BUG_ON(!fi->fib_nhs);
+		if (nh->nh_dev != dev || fi == prev_fi)
+			continue;
 
+		prev_fi = fi;
+		alive = 0;
 		change_nexthops(fi) {
 			if (!(nh->nh_flags&RTNH_F_DEAD)) {
 				alive++;
@@ -958,7 +1174,8 @@
 			fi->fib_flags &= ~RTNH_F_DEAD;
 			ret++;
 		}
-	} endfor_fib_info();
+	}
+
 	return ret;
 }
 
