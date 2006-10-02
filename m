From: James Morris <jmorris@namei.org>
Subject: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Mon, 2 Oct 2006 10:27:13 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610021020390.9909@d.namei>
References: <20060925120519.GA19010@2ka.mipt.ru> <Pine.LNX.4.64.0609300037460.12011@d.namei>
 <Pine.LNX.4.64.0609300110190.12422@d.namei> <20060930111521.GA646@2ka.mipt.ru>
 <Pine.LNX.4.64.0609301035020.26766@d.namei> <20060930144018.GA16918@2ka.mipt.ru>
 <Pine.LNX.4.64.0609301044090.26813@d.namei> <Pine.LNX.4.64.0610010203440.8658@d.namei>
 <20061002112050.GA772@2ka.mipt.ru> <Pine.LNX.4.64.0610020919050.9400@d.namei>
 <20061002134200.GA20441@2ka.mipt.ru> <Pine.LNX.4.64.0610021004180.9739@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:9632 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932459AbWJBO1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 10:27:15 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <Pine.LNX.4.64.0610021004180.9739@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updated version of the patch, which return directly after a flow cache 
lookup error in xfrm_lookup rather than returing via the cleanup path 
(which was causing a spurious dst_release).

This works for me, although I never saw the oops with the old patch.

Evgeniy, let me know if this fixes the oops you're seeing.


Signed-off-by: James Morris <jmorris@namei.org>

---

diff -purN -X dontdiff net-2.6.o/include/net/flow.h net-2.6.w/include/net/flow.h
--- net-2.6.o/include/net/flow.h	2006-09-29 11:33:58.000000000 -0400
+++ net-2.6.w/include/net/flow.h	2006-09-30 23:50:32.000000000 -0400
@@ -97,7 +97,7 @@ struct flowi {
 #define FLOW_DIR_FWD	2
 
 struct sock;
-typedef void (*flow_resolve_t)(struct flowi *key, u16 family, u8 dir,
+typedef int (*flow_resolve_t)(struct flowi *key, u16 family, u8 dir,
 			       void **objp, atomic_t **obj_refp);
 
 extern void *flow_cache_lookup(struct flowi *key, u16 family, u8 dir,
diff -purN -X dontdiff net-2.6.o/net/core/flow.c net-2.6.w/net/core/flow.c
--- net-2.6.o/net/core/flow.c	2006-09-29 11:33:59.000000000 -0400
+++ net-2.6.w/net/core/flow.c	2006-10-01 01:07:24.000000000 -0400
@@ -85,6 +85,14 @@ static void flow_cache_new_hashrnd(unsig
 	add_timer(&flow_hash_rnd_timer);
 }
 
+static void flow_entry_kill(int cpu, struct flow_cache_entry *fle)
+{
+	if (fle->object)
+		atomic_dec(fle->object_ref);
+	kmem_cache_free(flow_cachep, fle);
+	flow_count(cpu)--;
+}
+
 static void __flow_cache_shrink(int cpu, int shrink_to)
 {
 	struct flow_cache_entry *fle, **flp;
@@ -100,10 +108,7 @@ static void __flow_cache_shrink(int cpu,
 		}
 		while ((fle = *flp) != NULL) {
 			*flp = fle->next;
-			if (fle->object)
-				atomic_dec(fle->object_ref);
-			kmem_cache_free(flow_cachep, fle);
-			flow_count(cpu)--;
+			flow_entry_kill(cpu, fle);
 		}
 	}
 }
@@ -220,24 +225,33 @@ void *flow_cache_lookup(struct flowi *ke
 
 nocache:
 	{
+		int err;
 		void *obj;
 		atomic_t *obj_ref;
 
-		resolver(key, family, dir, &obj, &obj_ref);
+		err = resolver(key, family, dir, &obj, &obj_ref);
 
 		if (fle) {
-			fle->genid = atomic_read(&flow_cache_genid);
-
-			if (fle->object)
-				atomic_dec(fle->object_ref);
-
-			fle->object = obj;
-			fle->object_ref = obj_ref;
-			if (obj)
-				atomic_inc(fle->object_ref);
+			if (err) {
+				/* Force security policy check on next lookup */
+				*head = fle->next;
+				flow_entry_kill(cpu, fle);
+			} else {
+				fle->genid = atomic_read(&flow_cache_genid);
+				
+				if (fle->object)
+					atomic_dec(fle->object_ref);
+					
+				fle->object = obj;
+				fle->object_ref = obj_ref;
+				if (obj)
+					atomic_inc(fle->object_ref);
+			}
 		}
 		local_bh_enable();
 
+		if (err)
+			obj = ERR_PTR(err);
 		return obj;
 	}
 }
diff -purN -X dontdiff net-2.6.o/net/xfrm/xfrm_policy.c net-2.6.w/net/xfrm/xfrm_policy.c
--- net-2.6.o/net/xfrm/xfrm_policy.c	2006-09-29 11:34:00.000000000 -0400
+++ net-2.6.w/net/xfrm/xfrm_policy.c	2006-10-02 10:02:18.000000000 -0400
@@ -880,30 +880,32 @@ out:
 }
 EXPORT_SYMBOL(xfrm_policy_walk);
 
-/* Find policy to apply to this flow. */
-
+/*
+ * Find policy to apply to this flow.
+ *
+ * Returns 0 if policy found, else an -errno.
+ */
 static int xfrm_policy_match(struct xfrm_policy *pol, struct flowi *fl,
 			     u8 type, u16 family, int dir)
 {
 	struct xfrm_selector *sel = &pol->selector;
-	int match;
+	int match, ret = -ESRCH;
 
 	if (pol->family != family ||
 	    pol->type != type)
-		return 0;
+		return ret;
 
 	match = xfrm_selector_match(sel, fl, family);
-	if (match) {
-		if (!security_xfrm_policy_lookup(pol, fl->secid, dir))
-			return 1;
-	}
+	if (match)
+		ret = security_xfrm_policy_lookup(pol, fl->secid, dir);
 
-	return 0;
+	return ret;
 }
 
 static struct xfrm_policy *xfrm_policy_lookup_bytype(u8 type, struct flowi *fl,
 						     u16 family, u8 dir)
 {
+	int err;
 	struct xfrm_policy *pol, *ret;
 	xfrm_address_t *daddr, *saddr;
 	struct hlist_node *entry;
@@ -919,7 +921,15 @@ static struct xfrm_policy *xfrm_policy_l
 	chain = policy_hash_direct(daddr, saddr, family, dir);
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, bydst) {
-		if (xfrm_policy_match(pol, fl, type, family, dir)) {
+		err = xfrm_policy_match(pol, fl, type, family, dir);
+		if (err) {
+			if (err == -ESRCH)
+				continue;
+			else {
+				ret = ERR_PTR(err);
+				goto fail;
+			}
+		} else {
 			ret = pol;
 			priority = ret->priority;
 			break;
@@ -927,36 +937,53 @@ static struct xfrm_policy *xfrm_policy_l
 	}
 	chain = &xfrm_policy_inexact[dir];
 	hlist_for_each_entry(pol, entry, chain, bydst) {
-		if (xfrm_policy_match(pol, fl, type, family, dir) &&
-		    pol->priority < priority) {
+		err = xfrm_policy_match(pol, fl, type, family, dir);
+		if (err) {
+			if (err == -ESRCH)
+				continue;
+			else {
+				ret = ERR_PTR(err);
+				goto fail;
+			}
+		} else if (pol->priority < priority) {
 			ret = pol;
 			break;
 		}
 	}
 	if (ret)
 		xfrm_pol_hold(ret);
+fail:
 	read_unlock_bh(&xfrm_policy_lock);
 
 	return ret;
 }
 
-static void xfrm_policy_lookup(struct flowi *fl, u16 family, u8 dir,
+static int xfrm_policy_lookup(struct flowi *fl, u16 family, u8 dir,
 			       void **objp, atomic_t **obj_refp)
 {
 	struct xfrm_policy *pol;
+	int err = 0;
 
 #ifdef CONFIG_XFRM_SUB_POLICY
 	pol = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_SUB, fl, family, dir);
-	if (pol)
+	if (IS_ERR(pol)) {
+		err = PTR_ERR(pol);
+		pol = NULL;
+	}
+	if (pol || err)
 		goto end;
 #endif
 	pol = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_MAIN, fl, family, dir);
-
+	if (IS_ERR(pol)) {
+		err = PTR_ERR(pol);
+		pol = NULL;
+	}
 #ifdef CONFIG_XFRM_SUB_POLICY
 end:
 #endif
 	if ((*objp = (void *) pol) != NULL)
 		*obj_refp = &pol->refcnt;
+	return err;
 }
 
 static inline int policy_to_flow_dir(int dir)
@@ -1294,6 +1321,8 @@ restart:
 
 		policy = flow_cache_lookup(fl, dst_orig->ops->family,
 					   dir, xfrm_policy_lookup);
+		if (IS_ERR(policy))
+			return PTR_ERR(policy);
 	}
 
 	if (!policy)
@@ -1340,6 +1369,10 @@ restart:
 							    fl, family,
 							    XFRM_POLICY_OUT);
 			if (pols[1]) {
+				if (IS_ERR(pols[1])) {
+					err = PTR_ERR(pols[1]);
+					goto error;
+				}
 				if (pols[1]->action == XFRM_POLICY_BLOCK) {
 					err = -EPERM;
 					goto error;
@@ -1578,6 +1611,9 @@ int __xfrm_policy_check(struct sock *sk,
 		pol = flow_cache_lookup(&fl, family, fl_dir,
 					xfrm_policy_lookup);
 
+	if (IS_ERR(pol))
+		return 0;
+
 	if (!pol) {
 		if (skb->sp && secpath_has_nontransport(skb->sp, 0, &xerr_idx)) {
 			xfrm_secpath_reject(xerr_idx, skb, &fl);
@@ -1596,6 +1632,8 @@ int __xfrm_policy_check(struct sock *sk,
 						    &fl, family,
 						    XFRM_POLICY_IN);
 		if (pols[1]) {
+			if (IS_ERR(pols[1]))
+				return 0;
 			pols[1]->curlft.use_time = (unsigned long)xtime.tv_sec;
 			npols ++;
 		}
