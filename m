From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 1/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Thu, 05 Oct 2006 15:42:27 -0500
Message-ID: <45256E33.8080205@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	eparis@redhat.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:10775 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932118AbWJEUoC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 16:44:02 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>

When a security module is loaded (in this case, SELinux), the 
security_xfrm_policy_lookup() hook can return an access denied permission 
(or other error).  We were not handling that correctly, and in fact 
inverting the return logic and propagating a false "ok" back up to 
xfrm_lookup(), which then allowed packets to pass as if they were not 
associated with an xfrm policy.

The way I was seeing the problem was when connecting via IPsec to a 
confined service on an SELinux box (vsftpd), which did not have the 
appropriate SELinux policy permissions to send packets via IPsec.

The first SYNACK would be blocked, because of an uncached lookup via 
flow_cache_lookup(), which would fail to resolve an xfrm policy because 
the SELinux policy is checked at that point via the resolver.

However, retransmitted SYNACKs would then find a cached flow entry when 
calling into flow_cache_lookup() with a null xfrm policy, which is 
interpreted by xfrm_lookup() as the packet not having any associated 
policy and similarly to the first case, allowing it to pass without 
transformation.

The solution presented here is to first ensure that errno values are 
correctly propagated all the way back up through the various call chains 
from security_xfrm_policy_lookup(), and handled correctly.

Then, flow_cache_lookup() is modified, so that if the policy resolver 
fails (typically a permission denied via the security module), the flow 
cache entry is killed rather than having a null policy assigned (which 
indicates that the packet can pass freely).  This also forces any future 
lookups for the same flow to consult the security module (e.g. SELinux) 
for current security policy (rather than, say, caching the error on the 
flow cache entry).

Signed-off-by: James Morris <jmorris@namei.org>
---
 include/net/flow.h     |    2 -
 net/core/flow.c        |   42 ++++++++++++++++--------
 net/xfrm/xfrm_policy.c |   68 ++++++++++++++++++++++++++++++---------
 3 files changed, 82 insertions(+), 30 deletions(-)

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
