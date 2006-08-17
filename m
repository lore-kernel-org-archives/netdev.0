From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/15]: [XFRM]: Hash policies when non-prefixed.
Date: Thu, 17 Aug 2006 01:28:34 -0700 (PDT)
Message-ID: <20060817.012834.28784973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38586
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932445AbWHQI2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 04:28:32 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Hash policies when non-prefixed.

This idea is from Alexey Kuznetsov.

It is common for policies to be non-prefixed.  And for
that case we can optimize lookups, insert, etc. quite
a bit.

For each direction, we have a dynamically sized policy
hash table for non-prefixed policies.  We also have a
hash table on policy->index.

For prefixed policies, we have a list per-direction which
we will consult on lookups when a non-prefix hashtable
lookup fails.

This still isn't as efficient as I would like it.  There
are four immediate problems:

1) Lots of excessive refcounting, which can be fixed just
   like xfrm_state was
2) We do 2 hash probes on insert, one to look for dups and
   one to allocate a unique policy->index.  Althought I wonder
   how much this matters since xfrm_state inserts do up to
   3 hash probes and that seems to perform fine.
3) xfrm_policy_insert() is very complex because of the priority
   ordering and entry replacement logic.
4) Lots of counter bumping, in addition to policy refcounts,
   in the form of xfrm_policy_count[].  This is merely used
   to let code path(s) know that some IPSEC rules exist.  So
   this count is indexed per-direction, maybe that is overkill.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |   10 -
 net/xfrm/xfrm_policy.c |  613 ++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 516 insertions(+), 107 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 8123d49..cdd3490 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -314,8 +314,8 @@ #define XFRM_MAX_DEPTH		4
 
 struct xfrm_policy
 {
-	struct xfrm_policy	*next;
-	struct list_head	list;
+	struct hlist_node	bydst;
+	struct hlist_node	byidx;
 
 	/* This lock only affects elements except for entry. */
 	rwlock_t		lock;
@@ -368,7 +368,7 @@ extern int xfrm_register_km(struct xfrm_
 extern int xfrm_unregister_km(struct xfrm_mgr *km);
 
 
-extern struct xfrm_policy *xfrm_policy_list[XFRM_POLICY_MAX*2];
+extern unsigned int xfrm_policy_count[XFRM_POLICY_MAX*2];
 
 static inline void xfrm_pol_hold(struct xfrm_policy *policy)
 {
@@ -628,7 +628,7 @@ static inline int xfrm_policy_check(stru
 	if (sk && sk->sk_policy[XFRM_POLICY_IN])
 		return __xfrm_policy_check(sk, dir, skb, family);
 		
-	return	(!xfrm_policy_list[dir] && !skb->sp) ||
+	return	(!xfrm_policy_count[dir] && !skb->sp) ||
 		(skb->dst->flags & DST_NOPOLICY) ||
 		__xfrm_policy_check(sk, dir, skb, family);
 }
@@ -648,7 +648,7 @@ extern int __xfrm_route_forward(struct s
 
 static inline int xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 {
-	return	!xfrm_policy_list[XFRM_POLICY_OUT] ||
+	return	!xfrm_policy_count[XFRM_POLICY_OUT] ||
 		(skb->dst->flags & DST_NOXFRM) ||
 		__xfrm_route_forward(skb, family);
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index bc4d66a..0f6eff8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -22,6 +22,9 @@ #include <linux/notifier.h>
 #include <linux/netdevice.h>
 #include <linux/netfilter.h>
 #include <linux/module.h>
+#include <linux/bootmem.h>
+#include <linux/vmalloc.h>
+#include <linux/cache.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 
@@ -30,8 +33,8 @@ EXPORT_SYMBOL(xfrm_cfg_mutex);
 
 static DEFINE_RWLOCK(xfrm_policy_lock);
 
-struct xfrm_policy *xfrm_policy_list[XFRM_POLICY_MAX*2];
-EXPORT_SYMBOL(xfrm_policy_list);
+unsigned int xfrm_policy_count[XFRM_POLICY_MAX*2];
+EXPORT_SYMBOL(xfrm_policy_count);
 
 static DEFINE_RWLOCK(xfrm_policy_afinfo_lock);
 static struct xfrm_policy_afinfo *xfrm_policy_afinfo[NPROTO];
@@ -39,8 +42,7 @@ static struct xfrm_policy_afinfo *xfrm_p
 static kmem_cache_t *xfrm_dst_cache __read_mostly;
 
 static struct work_struct xfrm_policy_gc_work;
-static struct list_head xfrm_policy_gc_list =
-	LIST_HEAD_INIT(xfrm_policy_gc_list);
+static HLIST_HEAD(xfrm_policy_gc_list);
 static DEFINE_SPINLOCK(xfrm_policy_gc_lock);
 
 static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
@@ -310,8 +312,10 @@ struct xfrm_policy *xfrm_policy_alloc(gf
 	policy = kzalloc(sizeof(struct xfrm_policy), gfp);
 
 	if (policy) {
-		atomic_set(&policy->refcnt, 1);
+		INIT_HLIST_NODE(&policy->bydst);
+		INIT_HLIST_NODE(&policy->byidx);
 		rwlock_init(&policy->lock);
+		atomic_set(&policy->refcnt, 1);
 		init_timer(&policy->timer);
 		policy->timer.data = (unsigned long)policy;
 		policy->timer.function = xfrm_policy_timer;
@@ -357,17 +361,16 @@ static void xfrm_policy_gc_kill(struct x
 static void xfrm_policy_gc_task(void *data)
 {
 	struct xfrm_policy *policy;
-	struct list_head *entry, *tmp;
-	struct list_head gc_list = LIST_HEAD_INIT(gc_list);
+	struct hlist_node *entry, *tmp;
+	struct hlist_head gc_list;
 
 	spin_lock_bh(&xfrm_policy_gc_lock);
-	list_splice_init(&xfrm_policy_gc_list, &gc_list);
+	gc_list.first = xfrm_policy_gc_list.first;
+	INIT_HLIST_HEAD(&xfrm_policy_gc_list);
 	spin_unlock_bh(&xfrm_policy_gc_lock);
 
-	list_for_each_safe(entry, tmp, &gc_list) {
-		policy = list_entry(entry, struct xfrm_policy, list);
+	hlist_for_each_entry_safe(policy, entry, tmp, &gc_list, bydst)
 		xfrm_policy_gc_kill(policy);
-	}
 }
 
 /* Rule must be locked. Release descentant resources, announce
@@ -389,70 +392,353 @@ static void xfrm_policy_kill(struct xfrm
 	}
 
 	spin_lock(&xfrm_policy_gc_lock);
-	list_add(&policy->list, &xfrm_policy_gc_list);
+	hlist_add_head(&policy->bydst, &xfrm_policy_gc_list);
 	spin_unlock(&xfrm_policy_gc_lock);
 
 	schedule_work(&xfrm_policy_gc_work);
 }
 
+struct xfrm_policy_hash {
+	struct hlist_head	*table;
+	unsigned int		hmask;
+};
+
+static struct hlist_head xfrm_policy_inexact[XFRM_POLICY_MAX*2];
+static struct xfrm_policy_hash xfrm_policy_bydst[XFRM_POLICY_MAX*2] __read_mostly;
+static struct hlist_head *xfrm_policy_byidx __read_mostly;
+static unsigned int xfrm_idx_hmask __read_mostly;
+static unsigned int xfrm_policy_hashmax __read_mostly = 1 * 1024 * 1024;
+
+static inline unsigned int __idx_hash(u32 index, unsigned int hmask)
+{
+	return (index ^ (index >> 8)) & hmask;
+}
+
+static inline unsigned int idx_hash(u32 index)
+{
+	return __idx_hash(index, xfrm_idx_hmask);
+}
+
+static inline unsigned int __sel_hash(struct xfrm_selector *sel, unsigned short family, unsigned int hmask)
+{
+	xfrm_address_t *daddr = &sel->daddr;
+	xfrm_address_t *saddr = &sel->saddr;
+	unsigned int h = 0;
+
+	switch (family) {
+	case AF_INET:
+		if (sel->prefixlen_d != 32 ||
+		    sel->prefixlen_s != 32)
+			return hmask + 1;
+
+		h = ntohl(daddr->a4 ^ saddr->a4);
+		break;
+
+	case AF_INET6:
+		if (sel->prefixlen_d != 128 ||
+		    sel->prefixlen_s != 128)
+			return hmask + 1;
+
+		h = ntohl(daddr->a6[2] ^ daddr->a6[3] ^
+			  saddr->a6[2] ^ saddr->a6[3]);
+		break;
+	};
+	h ^= (h >> 16);
+	return h & hmask;
+}
+
+static inline unsigned int __addr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr, unsigned short family, unsigned int hmask)
+{
+	unsigned int h = 0;
+
+	switch (family) {
+	case AF_INET:
+		h = ntohl(daddr->a4 ^ saddr->a4);
+		break;
+
+	case AF_INET6:
+		h = ntohl(daddr->a6[2] ^ daddr->a6[3] ^
+			  saddr->a6[2] ^ saddr->a6[3]);
+		break;
+	};
+	h ^= (h >> 16);
+	return h & hmask;
+}
+
+static struct hlist_head *policy_hash_bysel(struct xfrm_selector *sel, unsigned short family, int dir)
+{
+	unsigned int hmask = xfrm_policy_bydst[dir].hmask;
+	unsigned int hash = __sel_hash(sel, family, hmask);
+
+	return (hash == hmask + 1 ?
+		&xfrm_policy_inexact[dir] :
+		xfrm_policy_bydst[dir].table + hash);
+}
+
+static struct hlist_head *policy_hash_direct(xfrm_address_t *daddr, xfrm_address_t *saddr, unsigned short family, int dir)
+{
+	unsigned int hmask = xfrm_policy_bydst[dir].hmask;
+	unsigned int hash = __addr_hash(daddr, saddr, family, hmask);
+
+	return xfrm_policy_bydst[dir].table + hash;
+}
+
+static struct hlist_head *xfrm_policy_hash_alloc(unsigned int sz)
+{
+	struct hlist_head *n;
+
+	if (sz <= PAGE_SIZE)
+		n = kmalloc(sz, GFP_KERNEL);
+	else if (hashdist)
+		n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
+	else
+		n = (struct hlist_head *)
+			__get_free_pages(GFP_KERNEL, get_order(sz));
+
+	if (n)
+		memset(n, 0, sz);
+
+	return n;
+}
+
+static void xfrm_policy_hash_free(struct hlist_head *n, unsigned int sz)
+{
+	if (sz <= PAGE_SIZE)
+		kfree(n);
+	else if (hashdist)
+		vfree(n);
+	else
+		free_pages((unsigned long)n, get_order(sz));
+}
+
+static void xfrm_dst_hash_transfer(struct hlist_head *list,
+				   struct hlist_head *ndsttable,
+				   unsigned int nhashmask)
+{
+	struct hlist_node *entry, *tmp;
+	struct xfrm_policy *pol;
+
+	hlist_for_each_entry_safe(pol, entry, tmp, list, bydst) {
+		unsigned int h;
+
+		h = __addr_hash(&pol->selector.daddr, &pol->selector.saddr,
+				pol->family, nhashmask);
+		hlist_add_head(&pol->bydst, ndsttable+h);
+	}
+}
+
+static void xfrm_idx_hash_transfer(struct hlist_head *list,
+				   struct hlist_head *nidxtable,
+				   unsigned int nhashmask)
+{
+	struct hlist_node *entry, *tmp;
+	struct xfrm_policy *pol;
+
+	hlist_for_each_entry_safe(pol, entry, tmp, list, byidx) {
+		unsigned int h;
+
+		h = __idx_hash(pol->index, nhashmask);
+		hlist_add_head(&pol->byidx, nidxtable+h);
+	}
+}
+
+static unsigned long xfrm_new_hash_mask(unsigned int old_hmask)
+{
+	return ((old_hmask + 1) << 1) - 1;
+}
+
+static void xfrm_bydst_resize(int dir)
+{
+	unsigned int hmask = xfrm_policy_bydst[dir].hmask;
+	unsigned int nhashmask = xfrm_new_hash_mask(hmask);
+	unsigned int nsize = (nhashmask + 1) * sizeof(struct hlist_head);
+	struct hlist_head *odst = xfrm_policy_bydst[dir].table;
+	struct hlist_head *ndst = xfrm_policy_hash_alloc(nsize);
+	int i;
+
+	if (!ndst)
+		return;
+
+	write_lock_bh(&xfrm_policy_lock);
+
+	for (i = hmask; i >= 0; i--)
+		xfrm_dst_hash_transfer(odst + i, ndst, nhashmask);
+
+	xfrm_policy_bydst[dir].table = ndst;
+	xfrm_policy_bydst[dir].hmask = nhashmask;
+
+	write_unlock_bh(&xfrm_policy_lock);
+
+	xfrm_policy_hash_free(odst, (hmask + 1) * sizeof(struct hlist_head));
+}
+
+static void xfrm_byidx_resize(int total)
+{
+	unsigned int hmask = xfrm_idx_hmask;
+	unsigned int nhashmask = xfrm_new_hash_mask(hmask);
+	unsigned int nsize = (nhashmask + 1) * sizeof(struct hlist_head);
+	struct hlist_head *oidx = xfrm_policy_byidx;
+	struct hlist_head *nidx = xfrm_policy_hash_alloc(nsize);
+	int i;
+
+	if (!nidx)
+		return;
+
+	write_lock_bh(&xfrm_policy_lock);
+
+	for (i = hmask; i >= 0; i--)
+		xfrm_idx_hash_transfer(oidx + i, nidx, nhashmask);
+
+	xfrm_policy_byidx = nidx;
+	xfrm_idx_hmask = nhashmask;
+
+	write_unlock_bh(&xfrm_policy_lock);
+
+	xfrm_policy_hash_free(oidx, (hmask + 1) * sizeof(struct hlist_head));
+}
+
+static inline int xfrm_bydst_should_resize(int dir, int *total)
+{
+	unsigned int cnt = xfrm_policy_count[dir];
+	unsigned int hmask = xfrm_policy_bydst[dir].hmask;
+
+	if (total)
+		*total += cnt;
+
+	if ((hmask + 1) < xfrm_policy_hashmax &&
+	    cnt > hmask)
+		return 1;
+
+	return 0;
+}
+
+static inline int xfrm_byidx_should_resize(int total)
+{
+	unsigned int hmask = xfrm_idx_hmask;
+
+	if ((hmask + 1) < xfrm_policy_hashmax &&
+	    total > hmask)
+		return 1;
+
+	return 0;
+}
+
+static DEFINE_MUTEX(hash_resize_mutex);
+
+static void xfrm_hash_resize(void *__unused)
+{
+	int dir, total;
+
+	mutex_lock(&hash_resize_mutex);
+
+	total = 0;
+	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
+		if (xfrm_bydst_should_resize(dir, &total))
+			xfrm_bydst_resize(dir);
+	}
+	if (xfrm_byidx_should_resize(total))
+		xfrm_byidx_resize(total);
+
+	mutex_unlock(&hash_resize_mutex);
+}
+
+static DECLARE_WORK(xfrm_hash_work, xfrm_hash_resize, NULL);
+
 /* Generate new index... KAME seems to generate them ordered by cost
  * of an absolute inpredictability of ordering of rules. This will not pass. */
 static u32 xfrm_gen_index(int dir)
 {
-	u32 idx;
-	struct xfrm_policy *p;
 	static u32 idx_generator;
 
 	for (;;) {
+		struct hlist_node *entry;
+		struct hlist_head *list;
+		struct xfrm_policy *p;
+		u32 idx;
+		int found;
+
 		idx = (idx_generator | dir);
 		idx_generator += 8;
 		if (idx == 0)
 			idx = 8;
-		for (p = xfrm_policy_list[dir]; p; p = p->next) {
-			if (p->index == idx)
+		list = xfrm_policy_byidx + idx_hash(idx);
+		found = 0;
+		hlist_for_each_entry(p, entry, list, byidx) {
+			if (p->index == idx) {
+				found = 1;
 				break;
+			}
 		}
-		if (!p)
+		if (!found)
 			return idx;
 	}
 }
 
+static inline int selector_cmp(struct xfrm_selector *s1, struct xfrm_selector *s2)
+{
+	u32 *p1 = (u32 *) s1;
+	u32 *p2 = (u32 *) s2;
+	int len = sizeof(struct xfrm_selector) / sizeof(u32);
+	int i;
+
+	for (i = 0; i < len; i++) {
+		if (p1[i] != p2[i])
+			return 1;
+	}
+
+	return 0;
+}
+
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 {
-	struct xfrm_policy *pol, **p;
-	struct xfrm_policy *delpol = NULL;
-	struct xfrm_policy **newpos = NULL;
+	struct xfrm_policy *pol;
+	struct xfrm_policy *delpol;
+	struct hlist_head *chain;
+	struct hlist_node *entry, *newpos, *last;
 	struct dst_entry *gc_list;
 
 	write_lock_bh(&xfrm_policy_lock);
-	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL;) {
-		if (!delpol && memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0 &&
+	chain = policy_hash_bysel(&policy->selector, policy->family, dir);
+	delpol = NULL;
+	newpos = NULL;
+	last = NULL;
+	hlist_for_each_entry(pol, entry, chain, bydst) {
+		if (!delpol &&
+		    !selector_cmp(&pol->selector, &policy->selector) &&
 		    xfrm_sec_ctx_match(pol->security, policy->security)) {
 			if (excl) {
 				write_unlock_bh(&xfrm_policy_lock);
 				return -EEXIST;
 			}
-			*p = pol->next;
 			delpol = pol;
 			if (policy->priority > pol->priority)
 				continue;
 		} else if (policy->priority >= pol->priority) {
-			p = &pol->next;
+			last = &pol->bydst;
 			continue;
 		}
 		if (!newpos)
-			newpos = p;
+			newpos = &pol->bydst;
 		if (delpol)
 			break;
-		p = &pol->next;
+		last = &pol->bydst;
 	}
+	if (!newpos)
+		newpos = last;
 	if (newpos)
-		p = newpos;
+		hlist_add_after(newpos, &policy->bydst);
+	else
+		hlist_add_head(&policy->bydst, chain);
 	xfrm_pol_hold(policy);
-	policy->next = *p;
-	*p = policy;
+	xfrm_policy_count[dir]++;
 	atomic_inc(&flow_cache_genid);
+	if (delpol) {
+		hlist_del(&delpol->bydst);
+		hlist_del(&delpol->byidx);
+		xfrm_policy_count[dir]--;
+	}
 	policy->index = delpol ? delpol->index : xfrm_gen_index(dir);
+	hlist_add_head(&policy->byidx, xfrm_policy_byidx+idx_hash(policy->index));
 	policy->curlft.add_time = (unsigned long)xtime.tv_sec;
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
@@ -461,10 +747,13 @@ int xfrm_policy_insert(int dir, struct x
 
 	if (delpol)
 		xfrm_policy_kill(delpol);
+	else if (xfrm_bydst_should_resize(dir, NULL))
+		schedule_work(&xfrm_hash_work);
 
 	read_lock_bh(&xfrm_policy_lock);
 	gc_list = NULL;
-	for (policy = policy->next; policy; policy = policy->next) {
+	entry = &policy->bydst;
+	hlist_for_each_entry_continue(policy, entry, bydst) {
 		struct dst_entry *dst;
 
 		write_lock(&policy->lock);
@@ -496,66 +785,104 @@ EXPORT_SYMBOL(xfrm_policy_insert);
 struct xfrm_policy *xfrm_policy_bysel_ctx(int dir, struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete)
 {
-	struct xfrm_policy *pol, **p;
+	struct xfrm_policy *pol, *ret;
+	struct hlist_head *chain;
+	struct hlist_node *entry;
 
 	write_lock_bh(&xfrm_policy_lock);
-	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL; p = &pol->next) {
-		if ((memcmp(sel, &pol->selector, sizeof(*sel)) == 0) &&
-		    (xfrm_sec_ctx_match(ctx, pol->security))) {
+	chain = policy_hash_bysel(sel, sel->family, dir);
+	ret = NULL;
+	hlist_for_each_entry(pol, entry, chain, bydst) {
+		if (!selector_cmp(sel, &pol->selector) &&
+		    xfrm_sec_ctx_match(ctx, pol->security)) {
 			xfrm_pol_hold(pol);
-			if (delete)
-				*p = pol->next;
+			if (delete) {
+				hlist_del(&pol->bydst);
+				hlist_del(&pol->byidx);
+				xfrm_policy_count[dir]--;
+			}
+			ret = pol;
 			break;
 		}
 	}
 	write_unlock_bh(&xfrm_policy_lock);
 
-	if (pol && delete) {
+	if (ret && delete) {
 		atomic_inc(&flow_cache_genid);
-		xfrm_policy_kill(pol);
+		xfrm_policy_kill(ret);
 	}
-	return pol;
+	return ret;
 }
 EXPORT_SYMBOL(xfrm_policy_bysel_ctx);
 
 struct xfrm_policy *xfrm_policy_byid(int dir, u32 id, int delete)
 {
-	struct xfrm_policy *pol, **p;
+	struct xfrm_policy *pol, *ret;
+	struct hlist_head *chain;
+	struct hlist_node *entry;
 
 	write_lock_bh(&xfrm_policy_lock);
-	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL; p = &pol->next) {
+	chain = xfrm_policy_byidx + idx_hash(id);
+	ret = NULL;
+	hlist_for_each_entry(pol, entry, chain, byidx) {
 		if (pol->index == id) {
 			xfrm_pol_hold(pol);
-			if (delete)
-				*p = pol->next;
+			if (delete) {
+				hlist_del(&pol->bydst);
+				hlist_del(&pol->byidx);
+				xfrm_policy_count[dir]--;
+			}
+			ret = pol;
 			break;
 		}
 	}
 	write_unlock_bh(&xfrm_policy_lock);
 
-	if (pol && delete) {
+	if (ret && delete) {
 		atomic_inc(&flow_cache_genid);
-		xfrm_policy_kill(pol);
+		xfrm_policy_kill(ret);
 	}
-	return pol;
+	return ret;
 }
 EXPORT_SYMBOL(xfrm_policy_byid);
 
 void xfrm_policy_flush(void)
 {
-	struct xfrm_policy *xp;
 	int dir;
 
 	write_lock_bh(&xfrm_policy_lock);
 	for (dir = 0; dir < XFRM_POLICY_MAX; dir++) {
-		while ((xp = xfrm_policy_list[dir]) != NULL) {
-			xfrm_policy_list[dir] = xp->next;
+		struct xfrm_policy *pol;
+		struct hlist_node *entry;
+		int i;
+
+	again1:
+		hlist_for_each_entry(pol, entry, &xfrm_policy_inexact[dir], bydst) {
+			hlist_del(&pol->bydst);
+			hlist_del(&pol->byidx);
 			write_unlock_bh(&xfrm_policy_lock);
 
-			xfrm_policy_kill(xp);
+			xfrm_policy_kill(pol);
 
 			write_lock_bh(&xfrm_policy_lock);
+			goto again1;
+		}
+
+		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
+	again2:
+			hlist_for_each_entry(pol, entry, xfrm_policy_bydst[dir].table + i, bydst) {
+				hlist_del(&pol->bydst);
+				hlist_del(&pol->byidx);
+				write_unlock_bh(&xfrm_policy_lock);
+
+				xfrm_policy_kill(pol);
+
+				write_lock_bh(&xfrm_policy_lock);
+				goto again2;
+			}
 		}
+
+		xfrm_policy_count[dir] = 0;
 	}
 	atomic_inc(&flow_cache_genid);
 	write_unlock_bh(&xfrm_policy_lock);
@@ -565,16 +892,15 @@ EXPORT_SYMBOL(xfrm_policy_flush);
 int xfrm_policy_walk(int (*func)(struct xfrm_policy *, int, int, void*),
 		     void *data)
 {
-	struct xfrm_policy *xp;
+	struct xfrm_policy *pol;
+	struct hlist_node *entry;
 	int dir;
 	int count = 0;
 	int error = 0;
 
 	read_lock_bh(&xfrm_policy_lock);
-	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
-		for (xp = xfrm_policy_list[dir]; xp; xp = xp->next)
-			count++;
-	}
+	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++)
+		count += xfrm_policy_count[dir];
 
 	if (count == 0) {
 		error = -ENOENT;
@@ -582,13 +908,23 @@ int xfrm_policy_walk(int (*func)(struct 
 	}
 
 	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
-		for (xp = xfrm_policy_list[dir]; xp; xp = xp->next) {
-			error = func(xp, dir%XFRM_POLICY_MAX, --count, data);
+		struct hlist_head *table = xfrm_policy_bydst[dir].table;
+		int i;
+
+		hlist_for_each_entry(pol, entry, &xfrm_policy_inexact[dir], bydst) {
+			error = func(pol, dir % XFRM_POLICY_MAX, --count, data);
 			if (error)
 				goto out;
 		}
-	}
 
+		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
+			hlist_for_each_entry(pol, entry, table + i, bydst) {
+				error = func(pol, dir % XFRM_POLICY_MAX, --count, data);
+				if (error)
+					goto out;
+			}
+		}
+	}
 out:
 	read_unlock_bh(&xfrm_policy_lock);
 	return error;
@@ -597,31 +933,60 @@ EXPORT_SYMBOL(xfrm_policy_walk);
 
 /* Find policy to apply to this flow. */
 
-static void xfrm_policy_lookup(struct flowi *fl, u32 sk_sid, u16 family, u8 dir,
-			       void **objp, atomic_t **obj_refp)
+static int xfrm_policy_match(struct xfrm_policy *pol, struct flowi *fl,
+			     u16 family, u32 sk_sid, int dir)
 {
-	struct xfrm_policy *pol;
+	struct xfrm_selector *sel = &pol->selector;
+	int match;
 
-	read_lock_bh(&xfrm_policy_lock);
-	for (pol = xfrm_policy_list[dir]; pol; pol = pol->next) {
-		struct xfrm_selector *sel = &pol->selector;
-		int match;
+	if (pol->family != family)
+		return 0;
 
-		if (pol->family != family)
-			continue;
+	match = xfrm_selector_match(sel, fl, family);
+	if (match) {
+		if (!security_xfrm_policy_lookup(pol, sk_sid, dir))
+			return 1;
+	}
 
-		match = xfrm_selector_match(sel, fl, family);
+	return 0;
+}
 
-		if (match) {
- 			if (!security_xfrm_policy_lookup(pol, sk_sid, dir)) {
+static void xfrm_policy_lookup(struct flowi *fl, u32 sk_sid, u16 family, u8 dir,
+			       void **objp, atomic_t **obj_refp)
+{
+	struct xfrm_policy *pol, *ret;
+	xfrm_address_t *daddr, *saddr;
+	struct hlist_node *entry;
+	struct hlist_head *chain;
+
+	daddr = xfrm_flowi_daddr(fl, family);
+	saddr = xfrm_flowi_saddr(fl, family);
+	if (unlikely(!daddr || !saddr))
+		return;
+
+	read_lock_bh(&xfrm_policy_lock);
+	chain = policy_hash_direct(daddr, saddr, family, dir);
+	ret = NULL;
+	hlist_for_each_entry(pol, entry, chain, bydst) {
+		if (xfrm_policy_match(pol, fl, family, sk_sid, dir)) {
+			xfrm_pol_hold(pol);
+			ret = pol;
+			break;
+		}
+	}
+	if (!ret) {
+		chain = &xfrm_policy_inexact[dir];
+		hlist_for_each_entry(pol, entry, chain, bydst) {
+			if (xfrm_policy_match(pol, fl, family, sk_sid, dir)) {
 				xfrm_pol_hold(pol);
+				ret = pol;
 				break;
 			}
 		}
 	}
 	read_unlock_bh(&xfrm_policy_lock);
-	if ((*objp = (void *) pol) != NULL)
-		*obj_refp = &pol->refcnt;
+	if ((*objp = (void *) ret) != NULL)
+		*obj_refp = &ret->refcnt;
 }
 
 static inline int policy_to_flow_dir(int dir)
@@ -665,24 +1030,29 @@ static struct xfrm_policy *xfrm_sk_polic
 
 static void __xfrm_policy_link(struct xfrm_policy *pol, int dir)
 {
-	pol->next = xfrm_policy_list[dir];
-	xfrm_policy_list[dir] = pol;
+	struct hlist_head *chain = policy_hash_bysel(&pol->selector,
+						     pol->family, dir);
+
+	hlist_add_head(&pol->bydst, chain);
+	hlist_add_head(&pol->byidx, xfrm_policy_byidx+idx_hash(pol->index));
+	xfrm_policy_count[dir]++;
 	xfrm_pol_hold(pol);
+
+	if (xfrm_bydst_should_resize(dir, NULL))
+		schedule_work(&xfrm_hash_work);
 }
 
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 						int dir)
 {
-	struct xfrm_policy **polp;
+	if (hlist_unhashed(&pol->bydst))
+		return NULL;
 
-	for (polp = &xfrm_policy_list[dir];
-	     *polp != NULL; polp = &(*polp)->next) {
-		if (*polp == pol) {
-			*polp = pol->next;
-			return pol;
-		}
-	}
-	return NULL;
+	hlist_del(&pol->bydst);
+	hlist_del(&pol->byidx);
+	xfrm_policy_count[dir]--;
+
+	return pol;
 }
 
 int xfrm_policy_delete(struct xfrm_policy *pol, int dir)
@@ -871,7 +1241,7 @@ restart:
 
 	if (!policy) {
 		/* To accelerate a bit...  */
-		if ((dst_orig->flags & DST_NOXFRM) || !xfrm_policy_list[XFRM_POLICY_OUT])
+		if ((dst_orig->flags & DST_NOXFRM) || !xfrm_policy_count[XFRM_POLICY_OUT])
 			return 0;
 
 		policy = flow_cache_lookup(fl, sk_sid, dst_orig->ops->family,
@@ -1196,33 +1566,49 @@ static struct dst_entry *xfrm_negative_a
 	return dst;
 }
 
+static void prune_one_bundle(struct xfrm_policy *pol, int (*func)(struct dst_entry *), struct dst_entry **gc_list_p)
+{
+	struct dst_entry *dst, **dstp;
+
+	write_lock(&pol->lock);
+	dstp = &pol->bundles;
+	while ((dst=*dstp) != NULL) {
+		if (func(dst)) {
+			*dstp = dst->next;
+			dst->next = *gc_list_p;
+			*gc_list_p = dst;
+		} else {
+			dstp = &dst->next;
+		}
+	}
+	write_unlock(&pol->lock);
+}
+
 static void xfrm_prune_bundles(int (*func)(struct dst_entry *))
 {
-	int i;
-	struct xfrm_policy *pol;
-	struct dst_entry *dst, **dstp, *gc_list = NULL;
+	struct dst_entry *gc_list = NULL;
+	int dir;
 
 	read_lock_bh(&xfrm_policy_lock);
-	for (i=0; i<2*XFRM_POLICY_MAX; i++) {
-		for (pol = xfrm_policy_list[i]; pol; pol = pol->next) {
-			write_lock(&pol->lock);
-			dstp = &pol->bundles;
-			while ((dst=*dstp) != NULL) {
-				if (func(dst)) {
-					*dstp = dst->next;
-					dst->next = gc_list;
-					gc_list = dst;
-				} else {
-					dstp = &dst->next;
-				}
-			}
-			write_unlock(&pol->lock);
+	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
+		struct xfrm_policy *pol;
+		struct hlist_node *entry;
+		struct hlist_head *table;
+		int i;
+
+		hlist_for_each_entry(pol, entry, &xfrm_policy_inexact[dir], bydst)
+			prune_one_bundle(pol, func, &gc_list);
+
+		table = xfrm_policy_bydst[dir].table;
+		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
+			hlist_for_each_entry(pol, entry, table + i, bydst)
+				prune_one_bundle(pol, func, &gc_list);
 		}
 	}
 	read_unlock_bh(&xfrm_policy_lock);
 
 	while (gc_list) {
-		dst = gc_list;
+		struct dst_entry *dst = gc_list;
 		gc_list = dst->next;
 		dst_free(dst);
 	}
@@ -1440,6 +1826,9 @@ static struct notifier_block xfrm_dev_no
 
 static void __init xfrm_policy_init(void)
 {
+	unsigned int hmask, sz;
+	int dir;
+
 	xfrm_dst_cache = kmem_cache_create("xfrm_dst_cache",
 					   sizeof(struct xfrm_dst),
 					   0, SLAB_HWCACHE_ALIGN,
@@ -1447,6 +1836,26 @@ static void __init xfrm_policy_init(void
 	if (!xfrm_dst_cache)
 		panic("XFRM: failed to allocate xfrm_dst_cache\n");
 
+	hmask = 8 - 1;
+	sz = (hmask+1) * sizeof(struct hlist_head);
+
+	xfrm_policy_byidx = xfrm_policy_hash_alloc(sz);
+	xfrm_idx_hmask = hmask;
+	if (!xfrm_policy_byidx)
+		panic("XFRM: failed to allocate byidx hash\n");
+
+	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
+		struct xfrm_policy_hash *htab;
+
+		INIT_HLIST_HEAD(&xfrm_policy_inexact[dir]);
+
+		htab = &xfrm_policy_bydst[dir];
+		htab->table = xfrm_policy_hash_alloc(sz);
+		htab->hmask = hmask;
+		if (!htab->table)
+			panic("XFRM: failed to allocate bydst hash\n");
+	}
+
 	INIT_WORK(&xfrm_policy_gc_work, xfrm_policy_gc_task, NULL);
 	register_netdevice_notifier(&xfrm_dev_notifier);
 }
-- 
1.4.2.rc2.g3e042

