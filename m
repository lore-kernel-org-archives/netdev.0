From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Mon,  5 Apr 2010 20:01:24 +0300
Message-ID: <1270486884-10905-1-git-send-email-timo.teras@iki.fi>
References: <20100405091228.GA17059@gondor.apana.org.au>
Cc: netdev@vger.kernel.org, Timo Teras <timo.teras@iki.fi>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:47666 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755289Ab0DERBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 13:01:35 -0400
Received: by ewy20 with SMTP id 20so57955ewy.1
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 10:01:32 -0700 (PDT)
In-Reply-To: <20100405091228.GA17059@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows to validate the cached object before returning it.
It also allows to destruct object properly, if the last reference
was held in flow cache. This is also a prepartion for caching
bundles in the flow cache.

In return for virtualizing the methods, we save on:
- not having to regenerate the whole flow cache on policy removal:
  each flow matching a killed policy gets refreshed as the getter
  function notices it smartly.
- we do not have to call flow_cache_flush from policy gc, since the
  flow cache now properly deletes the object if it had any references

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 include/net/flow.h     |   23 +++++++--
 include/net/xfrm.h     |    2 +
 net/core/flow.c        |  122 +++++++++++++++++++++++++-----------------------
 net/xfrm/xfrm_policy.c |  112 +++++++++++++++++++++++++++++---------------
 4 files changed, 158 insertions(+), 101 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 809970b..bb08692 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -86,11 +86,26 @@ struct flowi {
 
 struct net;
 struct sock;
-typedef int (*flow_resolve_t)(struct net *net, struct flowi *key, u16 family,
-			      u8 dir, void **objp, atomic_t **obj_refp);
+struct flow_cache_ops;
+
+struct flow_cache_object {
+	const struct flow_cache_ops *ops;
+};
+
+struct flow_cache_ops {
+	struct flow_cache_object *(*get)(struct flow_cache_object *);
+	int (*check)(struct flow_cache_object *);
+	void (*delete)(struct flow_cache_object *);
+};
+
+typedef struct flow_cache_object *(*flow_resolve_t)(
+		struct net *net, struct flowi *key, u16 family,
+		u8 dir, struct flow_cache_object *oldobj, void *ctx);
+
+extern struct flow_cache_object *flow_cache_lookup(
+		struct net *net, struct flowi *key, u16 family,
+		u8 dir, flow_resolve_t resolver, void *ctx);
 
-extern void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family,
-			       u8 dir, flow_resolve_t resolver);
 extern void flow_cache_flush(void);
 extern atomic_t flow_cache_genid;
 
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d74e080..35396e2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -19,6 +19,7 @@
 #include <net/route.h>
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
+#include <net/flow.h>
 
 #include <linux/interrupt.h>
 
@@ -481,6 +482,7 @@ struct xfrm_policy {
 	atomic_t		refcnt;
 	struct timer_list	timer;
 
+	struct flow_cache_object flo;
 	u32			priority;
 	u32			index;
 	struct xfrm_mark	mark;
diff --git a/net/core/flow.c b/net/core/flow.c
index 1d27ca6..4e9fd37 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -26,17 +26,16 @@
 #include <linux/security.h>
 
 struct flow_cache_entry {
-	struct flow_cache_entry	*next;
-	u16			family;
-	u8			dir;
-	u32			genid;
-	struct flowi		key;
-	void			*object;
-	atomic_t		*object_ref;
+	struct flow_cache_entry		*next;
+	u16				family;
+	u8				dir;
+	u32				genid;
+	struct flowi			key;
+	struct flow_cache_object	*object;
 };
 
 struct flow_cache_percpu {
-	struct flow_cache_entry **	hash_table;
+	struct flow_cache_entry		**hash_table;
 	int				hash_count;
 	u32				hash_rnd;
 	int				hash_rnd_recalc;
@@ -44,7 +43,7 @@ struct flow_cache_percpu {
 };
 
 struct flow_flush_info {
-	struct flow_cache *		cache;
+	struct flow_cache		*cache;
 	atomic_t			cpuleft;
 	struct completion		completion;
 };
@@ -52,7 +51,7 @@ struct flow_flush_info {
 struct flow_cache {
 	u32				hash_shift;
 	unsigned long			order;
-	struct flow_cache_percpu *	percpu;
+	struct flow_cache_percpu	*percpu;
 	struct notifier_block		hotcpu_notifier;
 	int				low_watermark;
 	int				high_watermark;
@@ -78,12 +77,21 @@ static void flow_cache_new_hashrnd(unsigned long arg)
 	add_timer(&fc->rnd_timer);
 }
 
+static int flow_entry_valid(struct flow_cache_entry *fle)
+{
+	if (atomic_read(&flow_cache_genid) != fle->genid)
+		return 0;
+	if (fle->object && !fle->object->ops->check(fle->object))
+		return 0;
+	return 1;
+}
+
 static void flow_entry_kill(struct flow_cache *fc,
 			    struct flow_cache_percpu *fcp,
 			    struct flow_cache_entry *fle)
 {
 	if (fle->object)
-		atomic_dec(fle->object_ref);
+		fle->object->ops->delete(fle->object);
 	kmem_cache_free(flow_cachep, fle);
 	fcp->hash_count--;
 }
@@ -96,16 +104,18 @@ static void __flow_cache_shrink(struct flow_cache *fc,
 	int i;
 
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
-		int k = 0;
+		int saved = 0;
 
 		flp = &fcp->hash_table[i];
-		while ((fle = *flp) != NULL && k < shrink_to) {
-			k++;
-			flp = &fle->next;
-		}
 		while ((fle = *flp) != NULL) {
-			*flp = fle->next;
-			flow_entry_kill(fc, fcp, fle);
+			if (saved < shrink_to &&
+			    flow_entry_valid(fle)) {
+				saved++;
+				flp = &fle->next;
+			} else {
+				*flp = fle->next;
+				flow_entry_kill(fc, fcp, fle);
+			}
 		}
 	}
 }
@@ -166,18 +176,21 @@ static int flow_key_compare(struct flowi *key1, struct flowi *key2)
 	return 0;
 }
 
-void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
-			flow_resolve_t resolver)
+struct flow_cache_object *
+flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
+		  flow_resolve_t resolver, void *ctx)
 {
 	struct flow_cache *fc = &flow_cache_global;
 	struct flow_cache_percpu *fcp;
 	struct flow_cache_entry *fle, **head;
+	struct flow_cache_object *flo;
 	unsigned int hash;
 
 	local_bh_disable();
 	fcp = per_cpu_ptr(fc->percpu, smp_processor_id());
 
 	fle = NULL;
+	flo = NULL;
 	/* Packet really early in init?  Making flow_cache_init a
 	 * pre-smp initcall would solve this.  --RR */
 	if (!fcp->hash_table)
@@ -185,24 +198,14 @@ void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
 
 	if (fcp->hash_rnd_recalc)
 		flow_new_hash_rnd(fc, fcp);
-	hash = flow_hash_code(fc, fcp, key);
 
+	hash = flow_hash_code(fc, fcp, key);
 	head = &fcp->hash_table[hash];
 	for (fle = *head; fle; fle = fle->next) {
 		if (fle->family == family &&
 		    fle->dir == dir &&
-		    flow_key_compare(key, &fle->key) == 0) {
-			if (fle->genid == atomic_read(&flow_cache_genid)) {
-				void *ret = fle->object;
-
-				if (ret)
-					atomic_inc(fle->object_ref);
-				local_bh_enable();
-
-				return ret;
-			}
+		    flow_key_compare(key, &fle->key) == 0)
 			break;
-		}
 	}
 
 	if (!fle) {
@@ -219,33 +222,35 @@ void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
 			fle->object = NULL;
 			fcp->hash_count++;
 		}
+	} else if (fle->genid == atomic_read(&flow_cache_genid)) {
+		flo = fle->object;
+		if (!flo)
+			goto ret_object;
+		flo = flo->ops->get(flo);
+		if (flo)
+			goto ret_object;
 	}
 
 nocache:
-	{
-		int err;
-		void *obj;
-		atomic_t *obj_ref;
-
-		err = resolver(net, key, family, dir, &obj, &obj_ref);
-
-		if (fle && !err) {
-			fle->genid = atomic_read(&flow_cache_genid);
-
-			if (fle->object)
-				atomic_dec(fle->object_ref);
-
-			fle->object = obj;
-			fle->object_ref = obj_ref;
-			if (obj)
-				atomic_inc(fle->object_ref);
-		}
-		local_bh_enable();
-
-		if (err)
-			obj = ERR_PTR(err);
-		return obj;
+	flo = NULL;
+	if (fle) {
+		flo = fle->object;
+		fle->object = NULL;
+	}
+	flo = resolver(net, key, family, dir, flo, ctx);
+	if (fle) {
+		fle->genid = atomic_read(&flow_cache_genid);
+		if (!IS_ERR(flo))
+			fle->object = flo;
+		else
+			fle->genid--;
+	} else {
+		if (flo && !IS_ERR(flo))
+			flo->ops->delete(flo);
 	}
+ret_object:
+	local_bh_enable();
+	return flo;
 }
 
 static void flow_cache_flush_tasklet(unsigned long data)
@@ -261,13 +266,12 @@ static void flow_cache_flush_tasklet(unsigned long data)
 
 		fle = fcp->hash_table[i];
 		for (; fle; fle = fle->next) {
-			unsigned genid = atomic_read(&flow_cache_genid);
-
-			if (!fle->object || fle->genid == genid)
+			if (flow_entry_valid(fle))
 				continue;
 
+			if (fle->object)
+				fle->object->ops->delete(fle->object);
 			fle->object = NULL;
-			atomic_dec(fle->object_ref);
 		}
 	}
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 82789cf..7722bae 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -216,6 +216,35 @@ expired:
 	xfrm_pol_put(xp);
 }
 
+static struct flow_cache_object *xfrm_policy_flo_get(struct flow_cache_object *flo)
+{
+	struct xfrm_policy *pol = container_of(flo, struct xfrm_policy, flo);
+
+	if (unlikely(pol->walk.dead))
+		flo = NULL;
+	else
+		xfrm_pol_hold(pol);
+
+	return flo;
+}
+
+static int xfrm_policy_flo_check(struct flow_cache_object *flo)
+{
+	struct xfrm_policy *pol = container_of(flo, struct xfrm_policy, flo);
+
+	return !pol->walk.dead;
+}
+
+static void xfrm_policy_flo_delete(struct flow_cache_object *flo)
+{
+	xfrm_pol_put(container_of(flo, struct xfrm_policy, flo));
+}
+
+static const struct flow_cache_ops xfrm_policy_fc_ops = {
+	.get = xfrm_policy_flo_get,
+	.check = xfrm_policy_flo_check,
+	.delete = xfrm_policy_flo_delete,
+};
 
 /* Allocate xfrm_policy. Not used here, it is supposed to be used by pfkeyv2
  * SPD calls.
@@ -236,6 +265,7 @@ struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp)
 		atomic_set(&policy->refcnt, 1);
 		setup_timer(&policy->timer, xfrm_policy_timer,
 				(unsigned long)policy);
+		policy->flo.ops = &xfrm_policy_fc_ops;
 	}
 	return policy;
 }
@@ -269,9 +299,6 @@ static void xfrm_policy_gc_kill(struct xfrm_policy *policy)
 	if (del_timer(&policy->timer))
 		atomic_dec(&policy->refcnt);
 
-	if (atomic_read(&policy->refcnt) > 1)
-		flow_cache_flush();
-
 	xfrm_pol_put(policy);
 }
 
@@ -661,10 +688,8 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
 	}
 	write_unlock_bh(&xfrm_policy_lock);
 
-	if (ret && delete) {
-		atomic_inc(&flow_cache_genid);
+	if (ret && delete)
 		xfrm_policy_kill(ret);
-	}
 	return ret;
 }
 EXPORT_SYMBOL(xfrm_policy_bysel_ctx);
@@ -703,10 +728,8 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
 	}
 	write_unlock_bh(&xfrm_policy_lock);
 
-	if (ret && delete) {
-		atomic_inc(&flow_cache_genid);
+	if (ret && delete)
 		xfrm_policy_kill(ret);
-	}
 	return ret;
 }
 EXPORT_SYMBOL(xfrm_policy_byid);
@@ -822,7 +845,6 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 	}
 	if (!cnt)
 		err = -ESRCH;
-	atomic_inc(&flow_cache_genid);
 out:
 	write_unlock_bh(&xfrm_policy_lock);
 	return err;
@@ -976,32 +998,35 @@ fail:
 	return ret;
 }
 
-static int xfrm_policy_lookup(struct net *net, struct flowi *fl, u16 family,
-			      u8 dir, void **objp, atomic_t **obj_refp)
+static struct flow_cache_object *
+xfrm_policy_lookup(struct net *net, struct flowi *fl, u16 family,
+		   u8 dir, struct flow_cache_object *old_obj, void *ctx)
 {
 	struct xfrm_policy *pol;
-	int err = 0;
+
+	if (old_obj)
+		xfrm_pol_put(container_of(old_obj, struct xfrm_policy, flo));
 
 #ifdef CONFIG_XFRM_SUB_POLICY
 	pol = xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_SUB, fl, family, dir);
-	if (IS_ERR(pol)) {
-		err = PTR_ERR(pol);
-		pol = NULL;
-	}
-	if (pol || err)
-		goto end;
+	if (IS_ERR(pol))
+		return ERR_CAST(pol);
+	if (pol)
+		goto found;
 #endif
 	pol = xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_MAIN, fl, family, dir);
-	if (IS_ERR(pol)) {
-		err = PTR_ERR(pol);
-		pol = NULL;
-	}
-#ifdef CONFIG_XFRM_SUB_POLICY
-end:
-#endif
-	if ((*objp = (void *) pol) != NULL)
-		*obj_refp = &pol->refcnt;
-	return err;
+	if (IS_ERR(pol))
+		return ERR_CAST(pol);
+	if (pol)
+		goto found;
+	return NULL;
+
+found:
+	/* Resolver returns two references:
+	 * one for cache and one for caller of flow_cache_lookup() */
+	xfrm_pol_hold(pol);
+
+	return &pol->flo;
 }
 
 static inline int policy_to_flow_dir(int dir)
@@ -1091,8 +1116,6 @@ int xfrm_policy_delete(struct xfrm_policy *pol, int dir)
 	pol = __xfrm_policy_unlink(pol, dir);
 	write_unlock_bh(&xfrm_policy_lock);
 	if (pol) {
-		if (dir < XFRM_POLICY_MAX)
-			atomic_inc(&flow_cache_genid);
 		xfrm_policy_kill(pol);
 		return 0;
 	}
@@ -1578,18 +1601,24 @@ restart:
 	}
 
 	if (!policy) {
+		struct flow_cache_object *flo;
+
 		/* To accelerate a bit...  */
 		if ((dst_orig->flags & DST_NOXFRM) ||
 		    !net->xfrm.policy_count[XFRM_POLICY_OUT])
 			goto nopol;
 
-		policy = flow_cache_lookup(net, fl, dst_orig->ops->family,
-					   dir, xfrm_policy_lookup);
-		err = PTR_ERR(policy);
-		if (IS_ERR(policy)) {
+		flo = flow_cache_lookup(net, fl, dst_orig->ops->family,
+					dir, xfrm_policy_lookup, NULL);
+		err = PTR_ERR(flo);
+		if (IS_ERR(flo)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
 			goto dropdst;
 		}
+		if (flo)
+			policy = container_of(flo, struct xfrm_policy, flo);
+		else
+			policy = NULL;
 	}
 
 	if (!policy)
@@ -1939,9 +1968,16 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 		}
 	}
 
-	if (!pol)
-		pol = flow_cache_lookup(net, &fl, family, fl_dir,
-					xfrm_policy_lookup);
+	if (!pol) {
+		struct flow_cache_object *flo;
+
+		flo = flow_cache_lookup(net, &fl, family, fl_dir,
+					xfrm_policy_lookup, NULL);
+		if (IS_ERR_OR_NULL(flo))
+			pol = ERR_CAST(flo);
+		else
+			pol = container_of(flo, struct xfrm_policy, flo);
+	}
 
 	if (IS_ERR(pol)) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);
-- 
1.6.3.3

