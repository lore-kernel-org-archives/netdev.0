From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 1/3] Fix for IPsec leakage with SELinux enabled - V.03: Fix
 xfrm code
Date: Thu, 05 Oct 2006 15:42:18 -0500
Message-ID: <45256E2A.6080807@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	eparis@redhat.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:21071 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932118AbWJEUn4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 16:43:56 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently when an IPSec policy rule doesn't specify a security
context, it is assumed to be "unlabeled" by SELinux, and so
the IPSec policy rule fails to match to a flow that it would
otherwise match to, unless one has explicitly added an SELinux
policy rule allowing the flow to "polmatch" to the "unlabeled"
IPSec policy rules. In the absence of such an explicitly added
SELinux policy rule, the IPSec policy rule fails to match and
so the packet(s) flow in clear text without the otherwise applicable
xfrm(s) applied.

The above SELinux behavior violates the SELinux security notion of
"deny by default" which should actually translate to "encrypt by
default" in the above case.

This was first reported by Evgeniy Polyakov and the way James Morris
was seeing the problem was when connecting via IPsec to a 
confined service on an SELinux box (vsftpd), which did not have the 
appropriate SELinux policy permissions to send packets via IPsec.

With this patch applied, SELinux "polmatching" of flows Vs. IPSec
policy rules will only come into play when there's a explicit context
specified for the IPSec policy rule (which also means there's corresponding
SELinux policy allowing appropriate domains/flows to polmatch to this context).

Secondly, when a security module is loaded (in this case, SELinux), the 
security_xfrm_policy_lookup() hook can return errors other than access denied,
such as -EINVAL.  We were not handling that correctly, and in fact 
inverting the return logic and propagating a false "ok" back up to 
xfrm_lookup(), which then allowed packets to pass as if they were not 
associated with an xfrm policy.

The solution for this is to first ensure that errno values are 
correctly propagated all the way back up through the various call chains 
from security_xfrm_policy_lookup(), and handled correctly.

Then, flow_cache_lookup() is modified, so that if the policy resolver 
fails (typically a permission denied via the security module), the flow 
cache entry is killed rather than having a null policy assigned (which 
indicates that the packet can pass freely).  This also forces any future 
lookups for the same flow to consult the security module (e.g. SELinux) 
for current security policy (rather than, say, caching the error on the 
flow cache entry).

This patch: Fix the selinux side of things.

This makes sure SELinux polmatching of flow contexts to IPSec policy
rules comes into play only when an explicit context is associated
with the IPSec policy rule.

Also, this no longer defaults the context of a socket policy to
the context of the socket since the "no explicit context" case
is now handled properly.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h        |   24 +++++--------
 include/net/xfrm.h              |    3 +
 net/ipv4/xfrm4_policy.c         |    2 -
 net/ipv6/xfrm6_policy.c         |    2 -
 net/key/af_key.c                |    5 --
 net/xfrm/xfrm_policy.c          |    7 ++-
 net/xfrm/xfrm_user.c            |    9 -----
 security/dummy.c                |    3 +
 security/selinux/include/xfrm.h |    3 +
 security/selinux/xfrm.c         |   53 +++++++++++++++++++++++-------
 10 files changed, 62 insertions(+), 49 deletions(-)

--- net-2.6.sid3/include/linux/security.h	2006-10-01 15:18:23.000000000 -0500
+++ net-2.6.sid4/include/linux/security.h	2006-10-05 12:03:39.000000000 -0500
@@ -893,7 +893,8 @@ struct request_sock;
  *	Check permission when a flow selects a xfrm_policy for processing
  *	XFRMs on a packet.  The hook is called when selecting either a
  *	per-socket policy or a generic xfrm policy.
- *	Return 0 if permission is granted.
+ *	Return 0 if permission is granted, -ESRCH otherwise, or -errno
+ *	on other errors.
  * @xfrm_state_pol_flow_match:
  *	@x contains the state to match.
  *	@xp contains the policy to check for a match.
@@ -902,6 +903,7 @@ struct request_sock;
  * @xfrm_flow_state_match:
  *	@fl contains the flow key to match.
  *	@xfrm points to the xfrm_state to match.
+ *	@xp points to the xfrm_policy to match.
  *	Return 1 if there is a match.
  * @xfrm_decode_session:
  *	@skb points to skb to decode.
@@ -1402,7 +1404,8 @@ struct security_operations {
 	int (*xfrm_policy_lookup)(struct xfrm_policy *xp, u32 fl_secid, u8 dir);
 	int (*xfrm_state_pol_flow_match)(struct xfrm_state *x,
 			struct xfrm_policy *xp, struct flowi *fl);
-	int (*xfrm_flow_state_match)(struct flowi *fl, struct xfrm_state *xfrm);
+	int (*xfrm_flow_state_match)(struct flowi *fl, struct xfrm_state *xfrm,
+			struct xfrm_policy *xp);
 	int (*xfrm_decode_session)(struct sk_buff *skb, u32 *secid, int ckall);
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 
@@ -3168,11 +3171,6 @@ static inline int security_xfrm_policy_a
 	return security_ops->xfrm_policy_alloc_security(xp, sec_ctx, NULL);
 }
 
-static inline int security_xfrm_sock_policy_alloc(struct xfrm_policy *xp, struct sock *sk)
-{
-	return security_ops->xfrm_policy_alloc_security(xp, NULL, sk);
-}
-
 static inline int security_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new)
 {
 	return security_ops->xfrm_policy_clone_security(old, new);
@@ -3227,9 +3225,10 @@ static inline int security_xfrm_state_po
 	return security_ops->xfrm_state_pol_flow_match(x, xp, fl);
 }
 
-static inline int security_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm)
+static inline int security_xfrm_flow_state_match(struct flowi *fl,
+			struct xfrm_state *xfrm, struct xfrm_policy *xp)
 {
-	return security_ops->xfrm_flow_state_match(fl, xfrm);
+	return security_ops->xfrm_flow_state_match(fl, xfrm, xp);
 }
 
 static inline int security_xfrm_decode_session(struct sk_buff *skb, u32 *secid)
@@ -3243,11 +3242,6 @@ static inline int security_xfrm_policy_a
 	return 0;
 }
 
-static inline int security_xfrm_sock_policy_alloc(struct xfrm_policy *xp, struct sock *sk)
-{
-	return 0;
-}
-
 static inline int security_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new)
 {
 	return 0;
@@ -3295,7 +3289,7 @@ static inline int security_xfrm_state_po
 }
 
 static inline int security_xfrm_flow_state_match(struct flowi *fl,
-                                struct xfrm_state *xfrm)
+			struct xfrm_state *xfrm, struct xfrm_policy *xp)
 {
 	return 1;
 }
--- net-2.6.sid3/security/dummy.c	2006-10-01 15:45:26.000000000 -0500
+++ net-2.6.sid4/security/dummy.c	2006-10-03 12:36:00.000000000 -0500
@@ -897,7 +897,8 @@ static int dummy_xfrm_state_pol_flow_mat
 	return 1;
 }
 
-static int dummy_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm)
+static int dummy_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm,
+				struct xfrm_policy *xp)
 {
 	return 1;
 }
--- net-2.6.sid3/security/selinux/include/xfrm.h	2006-10-01 12:24:54.000000000 -0500
+++ net-2.6.sid4/security/selinux/include/xfrm.h	2006-10-03 12:42:28.000000000 -0500
@@ -19,7 +19,8 @@ int selinux_xfrm_state_delete(struct xfr
 int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir);
 int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x,
 			struct xfrm_policy *xp, struct flowi *fl);
-int selinux_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm);
+int selinux_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm,
+			struct xfrm_policy *xp);
 
 
 /*
--- net-2.6.sid3/security/selinux/xfrm.c	2006-10-01 12:32:09.000000000 -0500
+++ net-2.6.sid4/security/selinux/xfrm.c	2006-10-05 11:45:18.000000000 -0500
@@ -77,8 +77,8 @@ static inline int selinux_authorizable_x
  */
 int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir)
 {
-	int rc = 0;
-	u32 sel_sid = SECINITSID_UNLABELED;
+	int rc;
+	u32 sel_sid;
 	struct xfrm_sec_ctx *ctx;
 
 	/* Context sid is either set to label or ANY_ASSOC */
@@ -88,11 +88,21 @@ int selinux_xfrm_policy_lookup(struct xf
 
 		sel_sid = ctx->ctx_sid;
 	}
+	else
+		/*
+		 * All flows should be treated as polmatch'ing an
+		 * otherwise applicable "non-labeled" policy. This
+		 * would prevent inadvertent "leaks".
+		 */
+		return 0;
 
 	rc = avc_has_perm(fl_secid, sel_sid, SECCLASS_ASSOCIATION,
 			  ASSOCIATION__POLMATCH,
 			  NULL);
 
+	if (rc == -EACCES)
+		rc = -ESRCH;
+
 	return rc;
 }
 
@@ -108,15 +118,20 @@ int selinux_xfrm_state_pol_flow_match(st
 	u32 pol_sid;
 	int err;
 
-	if (x->security)
-		state_sid = x->security->ctx_sid;
-	else
-		state_sid = SECINITSID_UNLABELED;
-
-	if (xp->security)
+	if (xp->security) {
+		if (!x->security)
+			/* unlabeled SA and labeled policy can't match */
+			return 0;
+		else
+			state_sid = x->security->ctx_sid;
 		pol_sid = xp->security->ctx_sid;
-	else
-		pol_sid = SECINITSID_UNLABELED;
+	} else
+		if (x->security)
+			/* unlabeled policy and labeled SA can't match */
+			return 0;
+		else
+			/* unlabeled policy and unlabeled SA match all flows */
+			return 1;
 
 	err = avc_has_perm(state_sid, pol_sid, SECCLASS_ASSOCIATION,
 			  ASSOCIATION__POLMATCH,
@@ -125,7 +140,11 @@ int selinux_xfrm_state_pol_flow_match(st
 	if (err)
 		return 0;
 
-	return selinux_xfrm_flow_state_match(fl, x);
+	err = avc_has_perm(fl->secid, state_sid, SECCLASS_ASSOCIATION,
+			  ASSOCIATION__SENDTO,
+			  NULL)? 0:1;
+
+	return err;
 }
 
 /*
@@ -133,12 +152,22 @@ int selinux_xfrm_state_pol_flow_match(st
  * can use a given security association.
  */
 
-int selinux_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm)
+int selinux_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm,
+				  struct xfrm_policy *xp)
 {
 	int rc = 0;
 	u32 sel_sid = SECINITSID_UNLABELED;
 	struct xfrm_sec_ctx *ctx;
 
+	if (!xp->security)
+		if (!xfrm->security)
+			return 1;
+		else
+			return 0;
+	else
+		if (!xfrm->security)
+			return 0;
+
 	/* Context sid is either set to label or ANY_ASSOC */
 	if ((ctx = xfrm->security)) {
 		if (!selinux_authorizable_ctx(ctx))
--- net-2.6.sid3/net/key/af_key.c	2006-10-05 11:57:55.000000000 -0500
+++ net-2.6.sid4/net/key/af_key.c	2006-10-05 11:59:41.000000000 -0500
@@ -2928,11 +2928,6 @@ static struct xfrm_policy *pfkey_compile
 		if (*dir)
 			goto out;
 	}
-	else {
-		*dir = security_xfrm_sock_policy_alloc(xp, sk);
-		if (*dir)
-			goto out;
-	}
 
 	*dir = pol->sadb_x_policy_dir-1;
 	return xp;
--- net-2.6.sid3/include/net/xfrm.h	2006-09-27 14:16:42.000000000 -0500
+++ net-2.6.sid4/include/net/xfrm.h	2006-10-03 12:29:35.000000000 -0500
@@ -994,7 +994,8 @@ struct xfrm_state * xfrm_find_acq(u8 mod
 				  int create, unsigned short family);
 extern void xfrm_policy_flush(u8 type);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
-extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family, int strict);
+extern int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *xdst,
+			  struct flowi *fl, int family, int strict);
 extern void xfrm_init_pmtu(struct dst_entry *dst);
 
 extern wait_queue_head_t km_waitq;
--- net-2.6.sid3/net/xfrm/xfrm_user.c	2006-10-05 11:58:07.000000000 -0500
+++ net-2.6.sid4/net/xfrm/xfrm_user.c	2006-10-05 12:00:19.000000000 -0500
@@ -1991,15 +1991,6 @@ static struct xfrm_policy *xfrm_compile_
 	xp->type = XFRM_POLICY_TYPE_MAIN;
 	copy_templates(xp, ut, nr);
 
-	if (!xp->security) {
-		int err = security_xfrm_sock_policy_alloc(xp, sk);
-		if (err) {
-			kfree(xp);
-			*dir = err;
-			return NULL;
-		}
-	}
-
 	*dir = p->dir;
 
 	return xp;
--- net-2.6.sid3/net/xfrm/xfrm_policy.c	2006-09-26 15:08:30.000000000 -0500
+++ net-2.6.sid4/net/xfrm/xfrm_policy.c	2006-10-03 12:28:19.000000000 -0500
@@ -1703,7 +1703,7 @@ static struct dst_entry *xfrm_dst_check(
 
 static int stale_bundle(struct dst_entry *dst)
 {
-	return !xfrm_bundle_ok((struct xfrm_dst *)dst, NULL, AF_UNSPEC, 0);
+	return !xfrm_bundle_ok(NULL, (struct xfrm_dst *)dst, NULL, AF_UNSPEC, 0);
 }
 
 void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev)
@@ -1825,7 +1825,8 @@ EXPORT_SYMBOL(xfrm_init_pmtu);
  * still valid.
  */
 
-int xfrm_bundle_ok(struct xfrm_dst *first, struct flowi *fl, int family, int strict)
+int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
+		struct flowi *fl, int family, int strict)
 {
 	struct dst_entry *dst = &first->u.dst;
 	struct xfrm_dst *last;
@@ -1842,7 +1843,7 @@ int xfrm_bundle_ok(struct xfrm_dst *firs
 
 		if (fl && !xfrm_selector_match(&dst->xfrm->sel, fl, family))
 			return 0;
-		if (fl && !security_xfrm_flow_state_match(fl, dst->xfrm))
+		if (fl && !security_xfrm_flow_state_match(fl, dst->xfrm, pol))
 			return 0;
 		if (dst->xfrm->km.state != XFRM_STATE_VALID)
 			return 0;
--- net-2.6.sid3/net/ipv4/xfrm4_policy.c	2006-10-03 21:01:26.000000000 -0500
+++ net-2.6.sid4/net/ipv4/xfrm4_policy.c	2006-10-03 12:25:05.000000000 -0500
@@ -52,7 +52,7 @@ __xfrm4_find_bundle(struct flowi *fl, st
 		    xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
 	    	    xdst->u.rt.fl.fl4_src == fl->fl4_src &&
 	    	    xdst->u.rt.fl.fl4_tos == fl->fl4_tos &&
-		    xfrm_bundle_ok(xdst, fl, AF_INET, 0)) {
+		    xfrm_bundle_ok(policy, xdst, fl, AF_INET, 0)) {
 			dst_clone(dst);
 			break;
 		}
--- net-2.6.sid3/net/ipv6/xfrm6_policy.c	2006-10-03 21:01:41.000000000 -0500
+++ net-2.6.sid4/net/ipv6/xfrm6_policy.c	2006-10-03 12:25:59.000000000 -0500
@@ -73,7 +73,7 @@ __xfrm6_find_bundle(struct flowi *fl, st
 				 xdst->u.rt6.rt6i_src.plen);
 		if (ipv6_addr_equal(&xdst->u.rt6.rt6i_dst.addr, &fl_dst_prefix) &&
 		    ipv6_addr_equal(&xdst->u.rt6.rt6i_src.addr, &fl_src_prefix) &&
-		    xfrm_bundle_ok(xdst, fl, AF_INET6,
+		    xfrm_bundle_ok(policy, xdst, fl, AF_INET6,
 				   (xdst->u.rt6.rt6i_dst.plen != 128 ||
 				    xdst->u.rt6.rt6i_src.plen != 128))) {
 			dst_clone(dst);
