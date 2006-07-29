From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 20/23] [PATCH] [XFRM] POLICY: sub policy support.
Date: Sat, 29 Jul 2006 18:30:51 +0900
Message-ID: <1154165451738-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:31363 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1161096AbWG2Jaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:52 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sub policy is introduced. Main and sub policy are applied the same flow.
(Policy that current kernel uses is named as main.)
It is required another transformation policy management to keep IPsec
and Mobile IPv6 lives separate.
Policy which lives shorter time in kernel should be a sub i.e. normally
main is for IPsec and sub is for Mobile IPv6.
(Such usage as two IPsec policies on different database can be used, too.)

Limitation or TODOs:
 - Sub policy is not supported for per socket one (it is always inserted as main).
 - Current kernel makes cached outbound with flowi to skip searching database.
   However this patch makes it disabled only when "two policies are used and
   the first matched one is bypass case" because neither flowi nor bundle
   information knows about transformation template size.
---
 include/linux/xfrm.h   |    7 +
 include/net/xfrm.h     |   45 +++++++-
 net/xfrm/xfrm_policy.c |  255 +++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 263 insertions(+), 44 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 84a3e76..901bb65 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -104,6 +104,13 @@ struct xfrm_stats {
 
 enum
 {
+	XFRM_POLICY_TYPE_MAIN	= 0,
+	XFRM_POLICY_TYPE_SUB	= 1,
+	XFRM_POLICY_TYPE_MAX	= 2
+};
+
+enum
+{
 	XFRM_POLICY_IN	= 0,
 	XFRM_POLICY_OUT	= 1,
 	XFRM_POLICY_FWD	= 2,
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 05d4257..3fe621f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -343,6 +343,7 @@ struct xfrm_policy
 	atomic_t		refcnt;
 	struct timer_list	timer;
 
+	u8			type;
 	u32			priority;
 	u32			index;
 	struct xfrm_selector	selector;
@@ -393,6 +394,19 @@ extern int xfrm_unregister_km(struct xfr
 
 
 extern struct xfrm_policy *xfrm_policy_list[XFRM_POLICY_MAX*2];
+#ifdef CONFIG_XFRM_SUB_POLICY
+extern struct xfrm_policy *xfrm_policy_list_sub[XFRM_POLICY_MAX*2];
+
+static inline int xfrm_policy_lists_empty(int dir)
+{
+	return (!xfrm_policy_list[dir] && !xfrm_policy_list_sub[dir]);
+}
+#else
+static inline int xfrm_policy_lists_empty(int dir)
+{
+	return (!xfrm_policy_list[dir]);
+}
+#endif
 
 static inline void xfrm_pol_hold(struct xfrm_policy *policy)
 {
@@ -408,6 +422,20 @@ static inline void xfrm_pol_put(struct x
 		__xfrm_policy_destroy(policy);
 }
 
+#ifdef CONFIG_XFRM_SUB_POLICY
+static inline void xfrm_pols_put(struct xfrm_policy **pols, int npols)
+{
+	int i;
+	for (i = npols - 1; i >= 0; --i)
+		xfrm_pol_put(pols[i]);
+}
+#else
+static inline void xfrm_pols_put(struct xfrm_policy **pols, int npols)
+{
+	xfrm_pol_put(pols[0]);
+}
+#endif
+
 #define XFRM_DST_HSIZE		1024
 
 static __inline__
@@ -738,8 +766,8 @@ static inline int xfrm_policy_check(stru
 {
 	if (sk && sk->sk_policy[XFRM_POLICY_IN])
 		return __xfrm_policy_check(sk, dir, skb, family);
-		
-	return	(!xfrm_policy_list[dir] && !skb->sp) ||
+
+	return	(xfrm_policy_lists_empty(dir) && !skb->sp) ||
 		(skb->dst->flags & DST_NOPOLICY) ||
 		__xfrm_policy_check(sk, dir, skb, family);
 }
@@ -759,7 +787,7 @@ extern int __xfrm_route_forward(struct s
 
 static inline int xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 {
-	return	!xfrm_policy_list[XFRM_POLICY_OUT] ||
+	return	xfrm_policy_lists_empty(XFRM_POLICY_OUT) ||
 		(skb->dst->flags & DST_NOXFRM) ||
 		__xfrm_route_forward(skb, family);
 }
@@ -1023,18 +1051,19 @@ static inline int xfrm_dst_lookup(struct
 #endif
 
 struct xfrm_policy *xfrm_policy_alloc(gfp_t gfp);
-extern int xfrm_policy_walk(int (*func)(struct xfrm_policy *, int, int, void*), void *);
+extern int xfrm_policy_walk(u8 type, int (*func)(struct xfrm_policy *, int, int, void*), void *);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
-struct xfrm_policy *xfrm_policy_bysel_ctx(int dir, struct xfrm_selector *sel,
+struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
+					  struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete);
-struct xfrm_policy *xfrm_policy_byid(int dir, u32 id, int delete);
-void xfrm_policy_flush(void);
+struct xfrm_policy *xfrm_policy_byid(u8, int dir, u32 id, int delete);
+void xfrm_policy_flush(u8 type);
 u32 xfrm_get_acqseq(void);
 void xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
 struct xfrm_state * xfrm_find_acq(u8 mode, u32 reqid, u8 proto, 
 				  xfrm_address_t *daddr, xfrm_address_t *saddr, 
 				  int create, unsigned short family);
-extern void xfrm_policy_flush(void);
+extern void xfrm_policy_flush(u8 type);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_flush_bundles(void);
 extern void xfrm_flush_all_bundles(void);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7368f8a..d105e2e 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -33,6 +33,24 @@ static DEFINE_RWLOCK(xfrm_policy_lock);
 
 struct xfrm_policy *xfrm_policy_list[XFRM_POLICY_MAX*2];
 EXPORT_SYMBOL(xfrm_policy_list);
+#ifdef CONFIG_XFRM_SUB_POLICY
+struct xfrm_policy *xfrm_policy_list_sub[XFRM_POLICY_MAX*2];
+EXPORT_SYMBOL(xfrm_policy_list_sub);
+
+#define XFRM_POLICY_LISTS(type) \
+	((type == XFRM_POLICY_TYPE_SUB) ? xfrm_policy_list_sub : \
+	 xfrm_policy_list)
+#define XFRM_POLICY_LISTHEAD(type, dir) \
+	((type == XFRM_POLICY_TYPE_SUB) ? xfrm_policy_list_sub[dir] : \
+	 xfrm_policy_list[dir])
+#define XFRM_POLICY_LISTHEADP(type, dir) \
+	((type == XFRM_POLICY_TYPE_SUB) ? &xfrm_policy_list_sub[dir] : \
+	 &xfrm_policy_list[dir])
+#else
+#define XFRM_POLICY_LISTS(type)              xfrm_policy_list
+#define XFRM_POLICY_LISTHEAD(type, dif)      xfrm_policy_list[dir]
+#define XFRM_POLICY_LISTHEADP(type, dif)     &xfrm_policy_list[dir]
+#endif
 
 static DEFINE_RWLOCK(xfrm_policy_afinfo_lock);
 static struct xfrm_policy_afinfo *xfrm_policy_afinfo[NPROTO];
@@ -320,7 +338,7 @@ static void xfrm_policy_kill(struct xfrm
 
 /* Generate new index... KAME seems to generate them ordered by cost
  * of an absolute inpredictability of ordering of rules. This will not pass. */
-static u32 xfrm_gen_index(int dir)
+static u32 xfrm_gen_index(u8 type, int dir)
 {
 	u32 idx;
 	struct xfrm_policy *p;
@@ -331,7 +349,7 @@ static u32 xfrm_gen_index(int dir)
 		idx_generator += 8;
 		if (idx == 0)
 			idx = 8;
-		for (p = xfrm_policy_list[dir]; p; p = p->next) {
+		for (p = XFRM_POLICY_LISTHEAD(type, dir); p; p = p->next) {
 			if (p->index == idx)
 				break;
 		}
@@ -348,7 +366,7 @@ int xfrm_policy_insert(int dir, struct x
 	struct dst_entry *gc_list;
 
 	write_lock_bh(&xfrm_policy_lock);
-	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL;) {
+	for (p = XFRM_POLICY_LISTHEADP(policy->type, dir); (pol=*p)!=NULL;) {
 		if (!delpol && memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0 &&
 		    xfrm_sec_ctx_match(pol->security, policy->security)) {
 			if (excl) {
@@ -375,7 +393,7 @@ int xfrm_policy_insert(int dir, struct x
 	policy->next = *p;
 	*p = policy;
 	atomic_inc(&flow_cache_genid);
-	policy->index = delpol ? delpol->index : xfrm_gen_index(dir);
+	policy->index = delpol ? delpol->index : xfrm_gen_index(policy->type, dir);
 	policy->curlft.add_time = (unsigned long)xtime.tv_sec;
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
@@ -416,13 +434,14 @@ int xfrm_policy_insert(int dir, struct x
 }
 EXPORT_SYMBOL(xfrm_policy_insert);
 
-struct xfrm_policy *xfrm_policy_bysel_ctx(int dir, struct xfrm_selector *sel,
+struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
+					  struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete)
 {
 	struct xfrm_policy *pol, **p;
 
 	write_lock_bh(&xfrm_policy_lock);
-	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL; p = &pol->next) {
+	for (p = XFRM_POLICY_LISTHEADP(type, dir); (pol=*p)!=NULL; p = &pol->next) {
 		if ((memcmp(sel, &pol->selector, sizeof(*sel)) == 0) &&
 		    (xfrm_sec_ctx_match(ctx, pol->security))) {
 			xfrm_pol_hold(pol);
@@ -441,12 +460,12 @@ struct xfrm_policy *xfrm_policy_bysel_ct
 }
 EXPORT_SYMBOL(xfrm_policy_bysel_ctx);
 
-struct xfrm_policy *xfrm_policy_byid(int dir, u32 id, int delete)
+struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete)
 {
 	struct xfrm_policy *pol, **p;
 
 	write_lock_bh(&xfrm_policy_lock);
-	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL; p = &pol->next) {
+	for (p = XFRM_POLICY_LISTHEADP(type, dir); (pol=*p)!=NULL; p = &pol->next) {
 		if (pol->index == id) {
 			xfrm_pol_hold(pol);
 			if (delete)
@@ -464,15 +483,16 @@ struct xfrm_policy *xfrm_policy_byid(int
 }
 EXPORT_SYMBOL(xfrm_policy_byid);
 
-void xfrm_policy_flush(void)
+void xfrm_policy_flush(u8 type)
 {
 	struct xfrm_policy *xp;
+	struct xfrm_policy **p_list = XFRM_POLICY_LISTS(type);
 	int dir;
 
 	write_lock_bh(&xfrm_policy_lock);
 	for (dir = 0; dir < XFRM_POLICY_MAX; dir++) {
-		while ((xp = xfrm_policy_list[dir]) != NULL) {
-			xfrm_policy_list[dir] = xp->next;
+		while ((xp = p_list[dir]) != NULL) {
+			p_list[dir] = xp->next;
 			write_unlock_bh(&xfrm_policy_lock);
 
 			xfrm_policy_kill(xp);
@@ -485,7 +505,7 @@ void xfrm_policy_flush(void)
 }
 EXPORT_SYMBOL(xfrm_policy_flush);
 
-int xfrm_policy_walk(int (*func)(struct xfrm_policy *, int, int, void*),
+int xfrm_policy_walk(u8 type, int (*func)(struct xfrm_policy *, int, int, void*),
 		     void *data)
 {
 	struct xfrm_policy *xp;
@@ -495,7 +515,7 @@ int xfrm_policy_walk(int (*func)(struct 
 
 	read_lock_bh(&xfrm_policy_lock);
 	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
-		for (xp = xfrm_policy_list[dir]; xp; xp = xp->next)
+		for (xp = XFRM_POLICY_LISTHEAD(type, dir); xp; xp = xp->next)
 			count++;
 	}
 
@@ -505,7 +525,7 @@ int xfrm_policy_walk(int (*func)(struct 
 	}
 
 	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
-		for (xp = xfrm_policy_list[dir]; xp; xp = xp->next) {
+		for (xp = XFRM_POLICY_LISTHEAD(type, dir); xp; xp = xp->next) {
 			error = func(xp, dir%XFRM_POLICY_MAX, --count, data);
 			if (error)
 				goto out;
@@ -520,13 +540,14 @@ EXPORT_SYMBOL(xfrm_policy_walk);
 
 /* Find policy to apply to this flow. */
 
-static void xfrm_policy_lookup(struct flowi *fl, u32 sk_sid, u16 family, u8 dir,
-			       void **objp, atomic_t **obj_refp)
+static struct xfrm_policy *xfrm_policy_lookup_bytype(u8 type, struct flowi *fl,
+						     u32 sk_sid, u16 family,
+						     u8 dir)
 {
 	struct xfrm_policy *pol;
 
 	read_lock_bh(&xfrm_policy_lock);
-	for (pol = xfrm_policy_list[dir]; pol; pol = pol->next) {
+	for (pol = XFRM_POLICY_LISTHEAD(type, dir); pol; pol = pol->next) {
 		struct xfrm_selector *sel = &pol->selector;
 		int match;
 
@@ -543,6 +564,27 @@ static void xfrm_policy_lookup(struct fl
 		}
 	}
 	read_unlock_bh(&xfrm_policy_lock);
+
+	return pol;
+}
+
+static void xfrm_policy_lookup(struct flowi *fl, u32 sk_sid, u16 family, u8 dir,
+			       void **objp, atomic_t **obj_refp)
+{
+	struct xfrm_policy *pol;
+
+#ifdef CONFIG_XFRM_SUB_POLICY
+	pol = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_SUB, fl, sk_sid,
+					family, dir);
+	if (pol)
+		goto end;
+#endif
+	pol = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_MAIN, fl, sk_sid,
+					family, dir);
+
+#ifdef CONFIG_XFRM_SUB_POLICY
+ end:
+#endif
 	if ((*objp = (void *) pol) != NULL)
 		*obj_refp = &pol->refcnt;
 }
@@ -588,8 +630,10 @@ static struct xfrm_policy *xfrm_sk_polic
 
 static void __xfrm_policy_link(struct xfrm_policy *pol, int dir)
 {
-	pol->next = xfrm_policy_list[dir];
-	xfrm_policy_list[dir] = pol;
+	struct xfrm_policy **p_list = XFRM_POLICY_LISTS(pol->type);
+
+	pol->next = p_list[dir];
+	p_list[dir] = pol;
 	xfrm_pol_hold(pol);
 }
 
@@ -598,7 +642,7 @@ static struct xfrm_policy *__xfrm_policy
 {
 	struct xfrm_policy **polp;
 
-	for (polp = &xfrm_policy_list[dir];
+	for (polp = XFRM_POLICY_LISTHEADP(pol->type, dir);
 	     *polp != NULL; polp = &(*polp)->next) {
 		if (*polp == pol) {
 			*polp = pol->next;
@@ -627,12 +671,17 @@ int xfrm_sk_policy_insert(struct sock *s
 {
 	struct xfrm_policy *old_pol;
 
+#ifdef CONFIG_XFRM_SUB_POLICY
+	if (pol && pol->type != XFRM_POLICY_TYPE_MAIN)
+		return -EINVAL;
+#endif
+
 	write_lock_bh(&xfrm_policy_lock);
 	old_pol = sk->sk_policy[dir];
 	sk->sk_policy[dir] = pol;
 	if (pol) {
 		pol->curlft.add_time = (unsigned long)xtime.tv_sec;
-		pol->index = xfrm_gen_index(XFRM_POLICY_MAX+dir);
+		pol->index = xfrm_gen_index(pol->type, XFRM_POLICY_MAX+dir);
 		__xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
 	}
 	if (old_pol)
@@ -661,6 +710,7 @@ static struct xfrm_policy *clone_policy(
 		newp->flags = old->flags;
 		newp->xfrm_nr = old->xfrm_nr;
 		newp->index = old->index;
+		newp->type = old->type;
 		memcpy(newp->xfrm_vec, old->xfrm_vec,
 		       newp->xfrm_nr*sizeof(struct xfrm_tmpl));
 		write_lock_bh(&xfrm_policy_lock);
@@ -687,9 +737,9 @@ int __xfrm_sk_clone_policy(struct sock *
 /* Resolve list of templates for the flow, given policy. */
 
 static int
-xfrm_tmpl_resolve(struct xfrm_policy *policy, struct flowi *fl,
-		  struct xfrm_state **xfrm,
-		  unsigned short family)
+xfrm_tmpl_resolve_one(struct xfrm_policy *policy, struct flowi *fl,
+		      struct xfrm_state **xfrm,
+		      unsigned short family)
 {
 	int nx;
 	int i, error;
@@ -732,6 +782,38 @@ fail:
 	return error;
 }
 
+static int
+xfrm_tmpl_resolve(struct xfrm_policy **pols, int npols, struct flowi *fl,
+		  struct xfrm_state **xfrm,
+		  unsigned short family)
+{
+	int cnx = 0;
+	int error;
+	int ret;
+	int i;
+
+	for (i = 0; i < npols; i++) {
+		if (cnx + pols[i]->xfrm_nr >= XFRM_MAX_DEPTH) {
+			error = -ENOBUFS;
+			goto fail;
+		}
+		ret = xfrm_tmpl_resolve_one(pols[i], fl, &xfrm[cnx], family);
+		if (ret < 0) {
+			error = ret;
+			goto fail;
+		} else
+			cnx += ret;
+	}
+
+	return cnx;
+
+ fail:
+	for (cnx--; cnx>=0; cnx--)
+		xfrm_state_put(xfrm[cnx]);
+	return error;
+
+}
+
 /* Check that the bundle accepts the flow and its components are
  * still valid.
  */
@@ -778,6 +860,11 @@ int xfrm_lookup(struct dst_entry **dst_p
 		struct sock *sk, int flags)
 {
 	struct xfrm_policy *policy;
+	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
+	int npols;
+	int pol_dead;
+	int xfrm_nr;
+	int pi;
 	struct xfrm_state *xfrm[XFRM_MAX_DEPTH];
 	struct dst_entry *dst, *dst_orig = *dst_p;
 	int nx = 0;
@@ -789,12 +876,18 @@ int xfrm_lookup(struct dst_entry **dst_p
 restart:
 	genid = atomic_read(&flow_cache_genid);
 	policy = NULL;
+	for (pi = 0; pi < ARRAY_SIZE(pols); pi++)
+		pols[pi] = NULL;
+	npols = 0;
+	pol_dead = 0;
+	xfrm_nr = 0;
+
 	if (sk && sk->sk_policy[1])
 		policy = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl, sk_sid);
 
 	if (!policy) {
 		/* To accelerate a bit...  */
-		if ((dst_orig->flags & DST_NOXFRM) || !xfrm_policy_list[XFRM_POLICY_OUT])
+		if ((dst_orig->flags & DST_NOXFRM) || xfrm_policy_lists_empty(XFRM_POLICY_OUT))
 			return 0;
 
 		policy = flow_cache_lookup(fl, sk_sid, dst_orig->ops->family,
@@ -806,6 +899,9 @@ restart:
 
 	family = dst_orig->ops->family;
 	policy->curlft.use_time = (unsigned long)xtime.tv_sec;
+	pols[0] = policy;
+	npols ++;
+	xfrm_nr += pols[0]->xfrm_nr;
 
 	switch (policy->action) {
 	case XFRM_POLICY_BLOCK:
@@ -814,11 +910,13 @@ restart:
 		goto error;
 
 	case XFRM_POLICY_ALLOW:
+#ifndef CONFIG_XFRM_SUB_POLICY
 		if (policy->xfrm_nr == 0) {
 			/* Flow passes not transformed. */
 			xfrm_pol_put(policy);
 			return 0;
 		}
+#endif
 
 		/* Try to find matching bundle.
 		 *
@@ -834,7 +932,36 @@ restart:
 		if (dst)
 			break;
 
-		nx = xfrm_tmpl_resolve(policy, fl, xfrm, family);
+#ifdef CONFIG_XFRM_SUB_POLICY
+		if (pols[0]->type != XFRM_POLICY_TYPE_MAIN) {
+			pols[1] = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_MAIN,
+							    fl, sk_sid, family,
+							    XFRM_POLICY_OUT);
+			if (pols[1]) {
+				if (pols[1]->action == XFRM_POLICY_BLOCK) {
+					err = -EPERM;
+					goto error;
+				}
+				npols ++;
+				xfrm_nr += pols[1]->xfrm_nr;
+			}
+		}
+
+		/*
+		 * Because neither flowi nor bundle information knows about
+		 * transformation template size. On more than one policy usage
+		 * we can realize whether all of them is bypass or not after
+		 * they are searched. See above not-transformed bypass
+		 * is surrounded by non-sub policy configuration, too.
+		 */
+		if (xfrm_nr == 0) {
+			/* Flow passes not transformed. */
+			xfrm_pols_put(pols, npols);
+			return 0;
+		}
+
+#endif
+		nx = xfrm_tmpl_resolve(pols, npols, fl, xfrm, family);
 
 		if (unlikely(nx<0)) {
 			err = nx;
@@ -847,7 +974,7 @@ restart:
 				set_current_state(TASK_RUNNING);
 				remove_wait_queue(&km_waitq, &wait);
 
-				nx = xfrm_tmpl_resolve(policy, fl, xfrm, family);
+				nx = xfrm_tmpl_resolve(pols, npols, fl, xfrm, family);
 
 				if (nx == -EAGAIN && signal_pending(current)) {
 					err = -ERESTART;
@@ -855,7 +982,7 @@ restart:
 				}
 				if (nx == -EAGAIN ||
 				    genid != atomic_read(&flow_cache_genid)) {
-					xfrm_pol_put(policy);
+					xfrm_pols_put(pols, npols);
 					goto restart;
 				}
 				err = nx;
@@ -865,7 +992,7 @@ restart:
 		}
 		if (nx == 0) {
 			/* Flow passes not transformed. */
-			xfrm_pol_put(policy);
+			xfrm_pols_put(pols, npols);
 			return 0;
 		}
 
@@ -879,8 +1006,14 @@ restart:
 			goto error;
 		}
 
+		for (pi = 0; pi < npols; pi++) {
+			read_lock_bh(&pols[pi]->lock);
+			pol_dead |= pols[pi]->dead;
+			read_unlock_bh(&pols[pi]->lock);
+		}
+
 		write_lock_bh(&policy->lock);
-		if (unlikely(policy->dead || stale_bundle(dst))) {
+		if (unlikely(pol_dead || stale_bundle(dst))) {
 			/* Wow! While we worked on resolving, this
 			 * policy has gone. Retry. It is not paranoia,
 			 * we just cannot enlist new bundle to dead object.
@@ -900,12 +1033,12 @@ restart:
 	}
 	*dst_p = dst;
 	dst_release(dst_orig);
-	xfrm_pol_put(policy);
+ 	xfrm_pols_put(pols, npols);
 	return 0;
 
 error:
 	dst_release(dst_orig);
-	xfrm_pol_put(policy);
+	xfrm_pols_put(pols, npols);
 	*dst_p = NULL;
 	return err;
 }
@@ -1019,6 +1152,10 @@ int __xfrm_policy_check(struct sock *sk,
 			unsigned short family)
 {
 	struct xfrm_policy *pol;
+	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
+	int npols = 0;
+	int xfrm_nr;
+	int pi;
 	struct flowi fl;
 	u8 fl_dir = policy_to_flow_dir(dir);
 	u32 sk_sid;
@@ -1064,22 +1201,50 @@ #endif
 
 	pol->curlft.use_time = (unsigned long)xtime.tv_sec;
 
+	pols[0] = pol;
+	npols ++;
+#ifdef CONFIG_XFRM_SUB_POLICY
+	if (pols[0]->type != XFRM_POLICY_TYPE_MAIN) {
+		pols[1] = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_MAIN,
+						    &fl, sk_sid, family,
+						    XFRM_POLICY_IN);
+		if (pols[1]) {
+			pols[1]->curlft.use_time = (unsigned long)xtime.tv_sec;
+			npols ++;
+		}
+	}
+#endif
+
 	if (pol->action == XFRM_POLICY_ALLOW) {
 		struct sec_path *sp;
 		static struct sec_path dummy;
+		struct xfrm_tmpl *tp[XFRM_MAX_DEPTH];
+		struct xfrm_tmpl **tpp = tp;
+		int ti = 0;
 		int i, k;
 
 		if ((sp = skb->sp) == NULL)
 			sp = &dummy;
 
+		for (pi = 0; pi < npols; pi++) {
+			if (pols[pi] != pol &&
+			    pols[pi]->action != XFRM_POLICY_ALLOW)
+				goto reject;
+			if (ti + pols[pi]->xfrm_nr >= XFRM_MAX_DEPTH)
+				goto reject_error;
+			for (i = 0; i < pols[pi]->xfrm_nr; i++)
+				tpp[ti++] = &pols[pi]->xfrm_vec[i];
+		}
+		xfrm_nr = ti;
+
 		/* For each tunnel xfrm, find the first matching tmpl.
 		 * For each tmpl before that, find corresponding xfrm.
 		 * Order is _important_. Later we will implement
 		 * some barriers, but at the moment barriers
 		 * are implied between each two transformations.
 		 */
-		for (i = pol->xfrm_nr-1, k = 0; i >= 0; i--) {
-			k = xfrm_policy_ok(pol->xfrm_vec+i, sp, k, family);
+		for (i = xfrm_nr-1, k = 0; i >= 0; i--) {
+			k = xfrm_policy_ok(tpp[i], sp, k, family);
 			if (k < 0) {
 				if (k < -1 && xerr_idxp)
 					*xerr_idxp = -(2+k);
@@ -1090,13 +1255,14 @@ #endif
 		if (secpath_has_nontransport(sp, k, xerr_idxp))
 			goto reject;
 
-		xfrm_pol_put(pol);
+		xfrm_pols_put(pols, npols);
 		return 1;
 	}
 
 reject:
 	xfrm_secpath_reject(xerr_idx, skb, &fl);
-	xfrm_pol_put(pol);
+reject_error:
+	xfrm_pols_put(pols, npols);
 	return 0;
 }
 EXPORT_SYMBOL(__xfrm_policy_check);
@@ -1161,6 +1327,23 @@ static void xfrm_prune_bundles(int (*fun
 
 	read_lock_bh(&xfrm_policy_lock);
 	for (i=0; i<2*XFRM_POLICY_MAX; i++) {
+#ifdef CONFIG_XFRM_SUB_POLICY
+		for (pol = xfrm_policy_list_sub[i]; pol; pol = pol->next) {
+			write_lock(&pol->lock);
+			dstp = &pol->bundles;
+			while ((dst=*dstp) != NULL) {
+				if (func(dst)) {
+					*dstp = dst->next;
+					dst->next = gc_list;
+					gc_list = dst;
+				} else {
+					dstp = &dst->next;
+				}
+			}
+			write_unlock(&pol->lock);
+		}
+
+#endif
 		for (pol = xfrm_policy_list[i]; pol; pol = pol->next) {
 			write_lock(&pol->lock);
 			dstp = &pol->bundles;
-- 
1.4.1

