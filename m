From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 5/7] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 17:12:42 +0300
Message-ID: <1269871964-5412-6-git-send-email-timo.teras@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:35953 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777Ab0C2OND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 10:13:03 -0400
Received: by mail-ew0-f220.google.com with SMTP id 20so705343ewy.1
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 07:13:02 -0700 (PDT)
In-Reply-To: <1269871964-5412-1-git-send-email-timo.teras@iki.fi>
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
 include/net/flow.h     |   18 ++++++--
 include/net/xfrm.h     |    2 +
 net/core/flow.c        |  112 +++++++++++++++++++++++++++---------------------
 net/xfrm/xfrm_policy.c |  111 +++++++++++++++++++++++++++++++----------------
 4 files changed, 153 insertions(+), 90 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 809970b..f462325 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -86,11 +86,21 @@ struct flowi {
 
 struct net;
 struct sock;
-typedef int (*flow_resolve_t)(struct net *net, struct flowi *key, u16 family,
-			      u8 dir, void **objp, atomic_t **obj_refp);
 
-extern void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family,
-			       u8 dir, flow_resolve_t resolver);
+struct flow_cache_entry_ops {
+	struct flow_cache_entry_ops ** (*get)(struct flow_cache_entry_ops **);
+	int (*check)(struct flow_cache_entry_ops **);
+	void (*delete)(struct flow_cache_entry_ops **);
+};
+
+typedef struct flow_cache_entry_ops **(*flow_resolve_t)(
+		struct net *net, struct flowi *key, u16 family,
+		u8 dir, struct flow_cache_entry_ops **old_ops);
+
+extern struct flow_cache_entry_ops **flow_cache_lookup(
+		struct net *net, struct flowi *key, u16 family,
+		u8 dir, flow_resolve_t resolver);
+
 extern void flow_cache_flush(void);
 extern atomic_t flow_cache_genid;
 
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d74e080..cb8934b 100644
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
 
+	struct flow_cache_entry_ops *fc_ops;
 	u32			priority;
 	u32			index;
 	struct xfrm_mark	mark;
diff --git a/net/core/flow.c b/net/core/flow.c
index 760f93d..0245455 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -30,12 +30,11 @@ struct flow_cache_entry {
 		struct hlist_node	hlist;
 		struct list_head	gc_list;
 	} u;
-	u16			family;
-	u8			dir;
-	u32			genid;
-	struct flowi		key;
-	void			*object;
-	atomic_t		*object_ref;
+	u16				family;
+	u8				dir;
+	u32				genid;
+	struct flowi			key;
+	struct flow_cache_entry_ops	**ops;
 };
 
 struct flow_cache_percpu {
@@ -84,10 +83,19 @@ static void flow_cache_new_hashrnd(unsigned long arg)
 	add_timer(&fc->rnd_timer);
 }
 
+static int flow_entry_valid(struct flow_cache_entry *fle)
+{
+	if (atomic_read(&flow_cache_genid) != fle->genid)
+		return 0;
+	if (fle->ops && !(*fle->ops)->check(fle->ops))
+		return 0;
+	return 1;
+}
+
 static void flow_entry_kill(struct flow_cache_entry *fle)
 {
-	if (fle->object)
-		atomic_dec(fle->object_ref);
+	if (fle->ops)
+		(*fle->ops)->delete(fle->ops);
 	kmem_cache_free(flow_cachep, fle);
 }
 
@@ -121,7 +129,7 @@ static void __flow_cache_shrink(struct flow_cache *fc,
 
 		hlist_for_each_entry_safe(fce, entry, tmp,
 					  &fcp->hash_table[i], u.hlist) {
-			if (saved < shrink_to) {
+			if (saved < shrink_to && flow_entry_valid(fce)) {
 				saved++;
 			} else {
 				deleted++;
@@ -198,19 +206,22 @@ static int flow_key_compare(struct flowi *key1, struct flowi *key2)
 	return 0;
 }
 
-void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
-			flow_resolve_t resolver)
+struct flow_cache_entry_ops **flow_cache_lookup(
+		struct net *net, struct flowi *key, u16 family, u8 dir,
+		flow_resolve_t resolver)
 {
 	struct flow_cache *fc = &flow_cache_global;
 	struct flow_cache_percpu *fcp;
 	struct flow_cache_entry *fle;
 	struct hlist_node *entry;
+	struct flow_cache_entry_ops **ops;
 	unsigned int hash;
 
 	local_bh_disable();
 	fcp = per_cpu_ptr(fc->percpu, smp_processor_id());
 
 	fle = NULL;
+	ops = NULL;
 	/* Packet really early in init?  Making flow_cache_init a
 	 * pre-smp initcall would solve this.  --RR */
 	if (!fcp->hash_table)
@@ -221,32 +232,46 @@ void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
 	hash = flow_hash_code(fc, fcp, key);
 
 	hlist_for_each_entry(fle, entry, &fcp->hash_table[hash], u.hlist) {
-		if (fle->family == family &&
-		    fle->dir == dir &&
-		    flow_key_compare(key, &fle->key) == 0) {
-			if (fle->genid == atomic_read(&flow_cache_genid)) {
-				void *ret = fle->object;
+		if (fle->family != family ||
+		    fle->dir != dir ||
+		    flow_key_compare(key, &fle->key) != 0)
+			continue;
+
+		ops = fle->ops;
+		if (fle->genid != atomic_read(&flow_cache_genid)) {
+			if (ops)
+				(*ops)->delete(ops);
+			fle->ops = NULL;
+			ops = NULL;
+			break;
+		}
 
-				if (ret)
-					atomic_inc(fle->object_ref);
-				local_bh_enable();
+		if (!ops) {
+			local_bh_enable();
+			return NULL;
+		}
 
-				return ret;
-			}
-			break;
+		ops = (*ops)->get(ops);
+		if (ops) {
+			local_bh_enable();
+			return ops;
 		}
+
+		ops = fle->ops;
+		break;
 	}
 
 	if (!fle) {
 		if (fcp->hash_count > fc->high_watermark)
 			flow_cache_shrink(fc, fcp);
 
+		ops = NULL;
 		fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC);
 		if (fle) {
 			fle->family = family;
 			fle->dir = dir;
 			memcpy(&fle->key, key, sizeof(*key));
-			fle->object = NULL;
+			fle->ops = NULL;
 
 			hlist_add_head(&fle->u.hlist, &fcp->hash_table[hash]);
 			fcp->hash_count++;
@@ -254,30 +279,22 @@ void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
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
+	ops = resolver(net, key, family, dir, ops);
+	if (fle) {
+		fle->genid = atomic_read(&flow_cache_genid);
+		if (IS_ERR(ops)) {
+			fle->genid--;
+			fle->ops = NULL;
+		} else {
+			fle->ops = ops;
 		}
-		local_bh_enable();
-
-		if (err)
-			obj = ERR_PTR(err);
-		return obj;
+	} else {
+		if (ops && !IS_ERR(ops))
+			(*ops)->delete(ops);
 	}
+	local_bh_enable();
+
+	return ops;
 }
 
 static void flow_cache_flush_tasklet(unsigned long data)
@@ -289,16 +306,13 @@ static void flow_cache_flush_tasklet(unsigned long data)
 	struct hlist_node *entry, *tmp;
 	struct list_head gc_list;
 	int i, deleted = 0;
-	unsigned genid;
 
 	INIT_LIST_HEAD(&gc_list);
 	fcp = per_cpu_ptr(fc->percpu, smp_processor_id());
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
 		hlist_for_each_entry_safe(fle, entry, tmp,
 					  &fcp->hash_table[i], u.hlist) {
-			genid = atomic_read(&flow_cache_genid);
-
-			if (!fle->object || fle->genid == genid)
+			if (flow_entry_valid(fle))
 				continue;
 
 			deleted++;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 595d347..cd9f2bc 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -216,6 +216,36 @@ expired:
 	xfrm_pol_put(xp);
 }
 
+static struct flow_cache_entry_ops **xfrm_policy_get_fce(
+		struct flow_cache_entry_ops **ops)
+{
+	struct xfrm_policy *pol = container_of(ops, struct xfrm_policy, fc_ops);
+
+	if (unlikely(pol->walk.dead))
+		ops = NULL;
+	else
+		xfrm_pol_hold(pol);
+
+	return ops;
+}
+
+static int xfrm_policy_check_fce(struct flow_cache_entry_ops **ops)
+{
+	struct xfrm_policy *pol = container_of(ops, struct xfrm_policy, fc_ops);
+
+	return !pol->walk.dead;
+}
+
+static void xfrm_policy_delete_fce(struct flow_cache_entry_ops **ops)
+{
+	xfrm_pol_put(container_of(ops, struct xfrm_policy, fc_ops));
+}
+
+static struct flow_cache_entry_ops xfrm_policy_fc_ops __read_mostly = {
+	.get = xfrm_policy_get_fce,
+	.check = xfrm_policy_check_fce,
+	.delete = xfrm_policy_delete_fce,
+};
 
 /* Allocate xfrm_policy. Not used here, it is supposed to be used by pfkeyv2
  * SPD calls.
@@ -236,6 +266,7 @@ struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp)
 		atomic_set(&policy->refcnt, 1);
 		setup_timer(&policy->timer, xfrm_policy_timer,
 				(unsigned long)policy);
+		policy->fc_ops = &xfrm_policy_fc_ops;
 	}
 	return policy;
 }
@@ -269,9 +300,6 @@ static void xfrm_policy_gc_kill(struct xfrm_policy *policy)
 	if (del_timer(&policy->timer))
 		atomic_dec(&policy->refcnt);
 
-	if (atomic_read(&policy->refcnt) > 1)
-		flow_cache_flush();
-
 	xfrm_pol_put(policy);
 }
 
@@ -661,10 +689,8 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
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
@@ -703,10 +729,8 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
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
@@ -822,7 +846,6 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 	}
 	if (!cnt)
 		err = -ESRCH;
-	atomic_inc(&flow_cache_genid);
 out:
 	write_unlock_bh(&xfrm_policy_lock);
 	return err;
@@ -976,32 +999,35 @@ fail:
 	return ret;
 }
 
-static int xfrm_policy_lookup(struct net *net, struct flowi *fl, u16 family,
-			      u8 dir, void **objp, atomic_t **obj_refp)
+static struct flow_cache_entry_ops **xfrm_policy_lookup(
+		struct net *net, struct flowi *fl, u16 family,
+		u8 dir, struct flow_cache_entry_ops **old_ops)
 {
 	struct xfrm_policy *pol;
-	int err = 0;
+
+	if (old_ops)
+		xfrm_pol_put(container_of(old_ops, struct xfrm_policy, fc_ops));
 
 #ifdef CONFIG_XFRM_SUB_POLICY
 	pol = xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_SUB, fl, family, dir);
-	if (IS_ERR(pol)) {
-		err = PTR_ERR(pol);
-		pol = NULL;
-	}
-	if (pol || err)
-		goto end;
+	if (IS_ERR(pol))
+		return (void *) pol;
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
+		return (void *) pol;
+	if (pol)
+		goto found;
+	return NULL;
+
+found:
+	/* Resolver returns two references:
+	 * one for cache and one for caller of flow_cache_lookup() */
+	xfrm_pol_hold(pol);
+
+	return &pol->fc_ops;
 }
 
 static inline int policy_to_flow_dir(int dir)
@@ -1091,8 +1117,6 @@ int xfrm_policy_delete(struct xfrm_policy *pol, int dir)
 	pol = __xfrm_policy_unlink(pol, dir);
 	write_unlock_bh(&xfrm_policy_lock);
 	if (pol) {
-		if (dir < XFRM_POLICY_MAX)
-			atomic_inc(&flow_cache_genid);
 		xfrm_policy_kill(pol);
 		return 0;
 	}
@@ -1575,18 +1599,24 @@ restart:
 	}
 
 	if (!policy) {
+		struct flow_cache_entry_ops **ops;
+
 		/* To accelerate a bit...  */
 		if ((dst_orig->flags & DST_NOXFRM) ||
 		    !net->xfrm.policy_count[XFRM_POLICY_OUT])
 			goto nopol;
 
-		policy = flow_cache_lookup(net, fl, dst_orig->ops->family,
-					   dir, xfrm_policy_lookup);
-		err = PTR_ERR(policy);
-		if (IS_ERR(policy)) {
+		ops = flow_cache_lookup(net, fl, dst_orig->ops->family,
+					dir, xfrm_policy_lookup);
+		err = PTR_ERR(ops);
+		if (IS_ERR(ops)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
 			goto dropdst;
 		}
+		if (ops)
+			policy = container_of(ops, struct xfrm_policy, fc_ops);
+		else
+			policy = NULL;
 	}
 
 	if (!policy)
@@ -1936,9 +1966,16 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 		}
 	}
 
-	if (!pol)
-		pol = flow_cache_lookup(net, &fl, family, fl_dir,
+	if (!pol) {
+		struct flow_cache_entry_ops **ops;
+
+		ops = flow_cache_lookup(net, &fl, family, fl_dir,
 					xfrm_policy_lookup);
+		if (IS_ERR(ops))
+			pol = (void *) ops;
+		else if (ops)
+			pol = container_of(ops, struct xfrm_policy, fc_ops);
+	}
 
 	if (IS_ERR(pol)) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);
-- 
1.6.3.3

