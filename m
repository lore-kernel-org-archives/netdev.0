From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 05/10] MLSXFRM: Flow based matching of xfrm policy and state
Date: Wed, 12 Jul 2006 16:14:19 -0500
Message-ID: <44B5662B.30204@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:21913 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932440AbWGLVO2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 17:14:28 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This implements a seemless mechanism for xfrm policy selection and state
matching based on the flow sid. This also includes the necessary SELinux
enforcement pieces.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h        |  106 +++++++++++++--
 include/net/flow.h              |    4 
 net/core/flow.c                 |    7 -
 net/xfrm/xfrm_policy.c          |   28 ++--
 net/xfrm/xfrm_state.c           |   12 +
 security/dummy.c                |   23 +++
 security/selinux/hooks.c        |    7 -
 security/selinux/include/xfrm.h |   23 ++-
 security/selinux/xfrm.c         |  199 +++++++++++++++++++++++++-----
 9 files changed, 329 insertions(+), 80 deletions(-)

--- linux-2.6.17.fl_secid/include/linux/security.h	2006-07-11 18:54:56.000000000 -0500
+++ linux-2.6.17/include/linux/security.h	2006-07-11 20:34:16.000000000 -0500
@@ -31,6 +31,7 @@
 #include <linux/msg.h>
 #include <linux/sched.h>
 #include <linux/key.h>
+#include <linux/xfrm.h>
 
 struct ctl_table;
 
@@ -825,9 +826,8 @@ struct swap_info_struct;
  *	used by the XFRM system.
  *	@sec_ctx contains the security context information being provided by
  *	the user-level policy update program (e.g., setkey).
- *	Allocate a security structure to the xp->security field.
- *	The security field is initialized to NULL when the xfrm_policy is
- *	allocated.
+ *	Allocate a security structure to the xp->security field; the security
+ *	field is initialized to NULL when the xfrm_policy is allocated.
  *	Return 0 if operation was successful (memory to allocate, legal context)
  * @xfrm_policy_clone_security:
  *	@old contains an existing xfrm_policy in the SPD.
@@ -846,9 +846,14 @@ struct swap_info_struct;
  *	Database by the XFRM system.
  *	@sec_ctx contains the security context information being provided by
  *	the user-level SA generation program (e.g., setkey or racoon).
- *	Allocate a security structure to the x->security field.  The
- *	security field is initialized to NULL when the xfrm_state is
- *	allocated.
+ *	@polsec contains the security context information associated with a xfrm
+ *	policy rule from which to take the base context. polsec must be NULL
+ *	when sec_ctx is specified.
+ *	@secid contains the secid from which to take the mls portion of the context.
+ *	Allocate a security structure to the x->security field; the security
+ *	field is initialized to NULL when the xfrm_state is allocated. Set the
+ *	context to correspond to either sec_ctx or polsec, with the mls portion
+ *	taken from secid in the latter case.
  *	Return 0 if operation was successful (memory to allocate, legal context).
  * @xfrm_state_free_security:
  *	@x contains the xfrm_state.
@@ -859,13 +864,26 @@ struct swap_info_struct;
  * @xfrm_policy_lookup:
  *	@xp contains the xfrm_policy for which the access control is being
  *	checked.
- *	@sk_sid contains the sock security label that is used to authorize
+ *	@fl_secid contains the flow security label that is used to authorize
  *	access to the policy xp.
  *	@dir contains the direction of the flow (input or output).
- *	Check permission when a sock selects a xfrm_policy for processing
+ *	Check permission when a flow selects a xfrm_policy for processing
  *	XFRMs on a packet.  The hook is called when selecting either a
  *	per-socket policy or a generic xfrm policy.
  *	Return 0 if permission is granted.
+ * @xfrm_state_pol_flow_match:
+ *	@x contains the state to match.
+ *	@xp contains the policy to check for a match.
+ *	@fl contains the flow to check for a match.
+ *	Return 1 if there is a match.
+ * @xfrm_flow_state_match:
+ *	@fl contains the flow key to match.
+ *	@xfrm points to the xfrm_state to match.
+ *	Return 1 if there is a match.
+ * @xfrm_decode_session:
+ *	@skb points to skb to decode.
+ *	@fl points to the flow key to set.
+ *	Return 0 if successful decoding.
  *
  * Security hooks affecting all Key Management operations
  *
@@ -1331,10 +1349,16 @@ struct security_operations {
 	int (*xfrm_policy_clone_security) (struct xfrm_policy *old, struct xfrm_policy *new);
 	void (*xfrm_policy_free_security) (struct xfrm_policy *xp);
 	int (*xfrm_policy_delete_security) (struct xfrm_policy *xp);
-	int (*xfrm_state_alloc_security) (struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx);
+	int (*xfrm_state_alloc_security) (struct xfrm_state *x,
+		struct xfrm_user_sec_ctx *sec_ctx, struct xfrm_sec_ctx *polsec,
+		u32 secid);
 	void (*xfrm_state_free_security) (struct xfrm_state *x);
 	int (*xfrm_state_delete_security) (struct xfrm_state *x);
-	int (*xfrm_policy_lookup)(struct xfrm_policy *xp, u32 sk_sid, u8 dir);
+	int (*xfrm_policy_lookup)(struct xfrm_policy *xp, u32 fl_secid, u8 dir);
+	int (*xfrm_state_pol_flow_match)(struct xfrm_state *x,
+			struct xfrm_policy *xp, struct flowi *fl);
+	int (*xfrm_flow_state_match)(struct flowi *fl, struct xfrm_state *xfrm);
+	int (*xfrm_decode_session)(struct sk_buff *skb, struct flowi *fl);
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 
 	/* key management security hooks */
@@ -3022,9 +3046,18 @@ static inline int security_xfrm_policy_d
 	return security_ops->xfrm_policy_delete_security(xp);
 }
 
-static inline int security_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx)
+static inline int security_xfrm_state_alloc(struct xfrm_state *x,
+			struct xfrm_user_sec_ctx *sec_ctx)
+{
+	return security_ops->xfrm_state_alloc_security(x, sec_ctx, NULL, 0);
+}
+
+static inline int security_xfrm_state_alloc_acquire(struct xfrm_state *x,
+				struct xfrm_sec_ctx *polsec, u32 secid)
 {
-	return security_ops->xfrm_state_alloc_security(x, sec_ctx);
+	if (!polsec)
+		return 0;
+	return security_ops->xfrm_state_alloc_security(x, NULL, polsec, secid);
 }
 
 static inline int security_xfrm_state_delete(struct xfrm_state *x)
@@ -3037,9 +3070,25 @@ static inline void security_xfrm_state_f
 	security_ops->xfrm_state_free_security(x);
 }
 
-static inline int security_xfrm_policy_lookup(struct xfrm_policy *xp, u32 sk_sid, u8 dir)
+static inline int security_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir)
+{
+	return security_ops->xfrm_policy_lookup(xp, fl_secid, dir);
+}
+
+static inline int security_xfrm_state_pol_flow_match(struct xfrm_state *x,
+			struct xfrm_policy *xp, struct flowi *fl)
+{
+	return security_ops->xfrm_state_pol_flow_match(x, xp, fl);
+}
+
+static inline int security_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm)
+{
+	return security_ops->xfrm_flow_state_match(fl, xfrm);
+}
+
+static inline int security_xfrm_decode_session(struct sk_buff *skb, struct flowi *fl)
 {
-	return security_ops->xfrm_policy_lookup(xp, sk_sid, dir);
+	return security_ops->xfrm_decode_session(skb, fl);
 }
 #else	/* CONFIG_SECURITY_NETWORK_XFRM */
 static inline int security_xfrm_policy_alloc(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx)
@@ -3061,7 +3110,14 @@ static inline int security_xfrm_policy_d
 	return 0;
 }
 
-static inline int security_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx)
+static inline int security_xfrm_state_alloc(struct xfrm_state *x,
+					struct xfrm_user_sec_ctx *sec_ctx)
+{
+	return 0;
+}
+
+static inline int security_xfrm_state_alloc_acquire(struct xfrm_state *x,
+					struct xfrm_sec_ctx *polsec, u32 secid)
 {
 	return 0;
 }
@@ -3075,10 +3131,28 @@ static inline int security_xfrm_state_de
 	return 0;
 }
 
-static inline int security_xfrm_policy_lookup(struct xfrm_policy *xp, u32 sk_sid, u8 dir)
+static inline int security_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir)
 {
 	return 0;
 }
+
+static inline int security_xfrm_state_pol_flow_match(struct xfrm_state *x,
+			struct xfrm_policy *xp, struct flowi *fl)
+{
+	return 1;
+}
+
+static inline int security_xfrm_flow_state_match(struct flowi *fl,
+                                struct xfrm_state *xfrm)
+{
+	return 1;
+}
+
+static inline int security_xfrm_decode_session(struct sk_buff *skb, struct flowi *fl)
+{
+	return 0;
+}
+
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 
 #ifdef CONFIG_KEYS
--- linux-2.6.17.fl_secid/include/net/flow.h	2006-07-11 19:51:26.000000000 -0500
+++ linux-2.6.17/include/net/flow.h	2006-07-11 19:57:00.000000000 -0500
@@ -86,10 +86,10 @@ struct flowi {
 #define FLOW_DIR_FWD	2
 
 struct sock;
-typedef void (*flow_resolve_t)(struct flowi *key, u32 sk_sid, u16 family, u8 dir,
+typedef void (*flow_resolve_t)(struct flowi *key, u16 family, u8 dir,
 			       void **objp, atomic_t **obj_refp);
 
-extern void *flow_cache_lookup(struct flowi *key, u32 sk_sid, u16 family, u8 dir,
+extern void *flow_cache_lookup(struct flowi *key, u16 family, u8 dir,
 	 		       flow_resolve_t resolver);
 extern void flow_cache_flush(void);
 extern atomic_t flow_cache_genid;
--- linux-2.6.17.fl_secid/net/core/flow.c	2006-06-17 20:49:35.000000000 -0500
+++ linux-2.6.17/net/core/flow.c	2006-07-11 19:57:00.000000000 -0500
@@ -32,7 +32,6 @@ struct flow_cache_entry {
 	u8			dir;
 	struct flowi		key;
 	u32			genid;
-	u32			sk_sid;
 	void			*object;
 	atomic_t		*object_ref;
 };
@@ -165,7 +164,7 @@ static int flow_key_compare(struct flowi
 	return 0;
 }
 
-void *flow_cache_lookup(struct flowi *key, u32 sk_sid, u16 family, u8 dir,
+void *flow_cache_lookup(struct flowi *key, u16 family, u8 dir,
 			flow_resolve_t resolver)
 {
 	struct flow_cache_entry *fle, **head;
@@ -189,7 +188,6 @@ void *flow_cache_lookup(struct flowi *ke
 	for (fle = *head; fle; fle = fle->next) {
 		if (fle->family == family &&
 		    fle->dir == dir &&
-		    fle->sk_sid == sk_sid &&
 		    flow_key_compare(key, &fle->key) == 0) {
 			if (fle->genid == atomic_read(&flow_cache_genid)) {
 				void *ret = fle->object;
@@ -214,7 +212,6 @@ void *flow_cache_lookup(struct flowi *ke
 			*head = fle;
 			fle->family = family;
 			fle->dir = dir;
-			fle->sk_sid = sk_sid;
 			memcpy(&fle->key, key, sizeof(*key));
 			fle->object = NULL;
 			flow_count(cpu)++;
@@ -226,7 +223,7 @@ nocache:
 		void *obj;
 		atomic_t *obj_ref;
 
-		resolver(key, sk_sid, family, dir, &obj, &obj_ref);
+		resolver(key, family, dir, &obj, &obj_ref);
 
 		if (fle) {
 			fle->genid = atomic_read(&flow_cache_genid);
--- linux-2.6.17.fl_secid/security/dummy.c	2006-07-11 18:54:56.000000000 -0500
+++ linux-2.6.17/security/dummy.c	2006-07-11 19:57:00.000000000 -0500
@@ -836,7 +836,8 @@ static int dummy_xfrm_policy_delete_secu
 	return 0;
 }
 
-static int dummy_xfrm_state_alloc_security(struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx)
+static int dummy_xfrm_state_alloc_security(struct xfrm_state *x,
+	struct xfrm_user_sec_ctx *sec_ctx, struct xfrm_sec_ctx *pol, u32 secid)
 {
 	return 0;
 }
@@ -854,6 +855,23 @@ static int dummy_xfrm_policy_lookup(stru
 {
 	return 0;
 }
+
+static int dummy_xfrm_state_pol_flow_match(struct xfrm_state *x,
+				struct xfrm_policy *xp, struct flowi *fl)
+{
+	return 1;
+}
+
+static int dummy_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm)
+{
+	return 1;
+}
+
+static int dummy_xfrm_decode_session(struct sk_buff *skb, struct flowi *fl)
+{
+	return 0;
+}
+
 #endif /* CONFIG_SECURITY_NETWORK_XFRM */
 static int dummy_register_security (const char *name, struct security_operations *ops)
 {
@@ -1066,6 +1084,9 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, xfrm_state_free_security);
 	set_to_dummy_if_null(ops, xfrm_state_delete_security);
 	set_to_dummy_if_null(ops, xfrm_policy_lookup);
+	set_to_dummy_if_null(ops, xfrm_state_pol_flow_match);
+	set_to_dummy_if_null(ops, xfrm_flow_state_match);
+	set_to_dummy_if_null(ops, xfrm_decode_session);
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 #ifdef CONFIG_KEYS
 	set_to_dummy_if_null(ops, key_alloc);
--- linux-2.6.17.fl_secid/security/selinux/hooks.c	2006-07-11 19:05:17.000000000 -0500
+++ linux-2.6.17/security/selinux/hooks.c	2006-07-11 20:14:10.000000000 -0500
@@ -3464,7 +3464,7 @@ static int selinux_socket_sock_rcv_skb(s
 	if (err)
 		goto out;
 
-	err = selinux_xfrm_sock_rcv_skb(sock_sid, skb);
+	err = selinux_xfrm_sock_rcv_skb(sock_sid, skb, &ad);
 out:	
 	return err;
 }
@@ -3731,7 +3731,7 @@ static unsigned int selinux_ip_postroute
 	if (err)
 		goto out;
 
-	err = selinux_xfrm_postroute_last(isec->sid, skb);
+	err = selinux_xfrm_postroute_last(isec->sid, skb, &ad);
 out:
 	return err ? NF_DROP : NF_ACCEPT;
 }
@@ -4630,6 +4630,9 @@ static struct security_operations selinu
 	.xfrm_state_free_security =	selinux_xfrm_state_free,
 	.xfrm_state_delete_security =	selinux_xfrm_state_delete,
 	.xfrm_policy_lookup = 		selinux_xfrm_policy_lookup,
+	.xfrm_state_pol_flow_match =	selinux_xfrm_state_pol_flow_match,
+	.xfrm_flow_state_match =	selinux_xfrm_flow_state_match,
+	.xfrm_decode_session =		selinux_xfrm_decode_session,
 #endif
 
 #ifdef CONFIG_KEYS
--- linux-2.6.17.fl_secid/security/selinux/include/xfrm.h	2006-07-11 16:04:22.000000000 -0500
+++ linux-2.6.17/security/selinux/include/xfrm.h	2006-07-11 20:17:10.000000000 -0500
@@ -2,6 +2,7 @@
  * SELinux support for the XFRM LSM hooks
  *
  * Author : Trent Jaeger, <jaegert@us.ibm.com>
+ * Updated : Venkat Yekkirala, <vyekkirala@TrustedCS.com>
  */
 #ifndef _SELINUX_XFRM_H_
 #define _SELINUX_XFRM_H_
@@ -10,10 +11,16 @@ int selinux_xfrm_policy_alloc(struct xfr
 int selinux_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new);
 void selinux_xfrm_policy_free(struct xfrm_policy *xp);
 int selinux_xfrm_policy_delete(struct xfrm_policy *xp);
-int selinux_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx);
+int selinux_xfrm_state_alloc(struct xfrm_state *x,
+	struct xfrm_user_sec_ctx *sec_ctx, struct xfrm_sec_ctx *pol, u32 secid);
 void selinux_xfrm_state_free(struct xfrm_state *x);
 int selinux_xfrm_state_delete(struct xfrm_state *x);
-int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 sk_sid, u8 dir);
+int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir);
+int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x,
+			struct xfrm_policy *xp, struct flowi *fl);
+int selinux_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm);
+int selinux_xfrm_decode_session(struct sk_buff *skb, struct flowi *fl);
+
 
 /*
  * Extract the security blob from the sock (it's actually on the socket)
@@ -39,17 +46,21 @@ static inline u32 selinux_no_sk_sid(stru
 }
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
-int selinux_xfrm_sock_rcv_skb(u32 sid, struct sk_buff *skb);
-int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb);
+int selinux_xfrm_sock_rcv_skb(u32 sid, struct sk_buff *skb,
+			struct avc_audit_data *ad);
+int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
+			struct avc_audit_data *ad);
 u32 selinux_socket_getpeer_stream(struct sock *sk);
 u32 selinux_socket_getpeer_dgram(struct sk_buff *skb);
 #else
-static inline int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb)
+static inline int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb,
+			struct avc_audit_data *ad)
 {
 	return 0;
 }
 
-static inline int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb)
+static inline int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
+			struct avc_audit_data *ad)
 {
 	return 0;
 }
--- linux-2.6.17.fl_secid/security/selinux/xfrm.c	2006-07-11 16:04:22.000000000 -0500
+++ linux-2.6.17/security/selinux/xfrm.c	2006-07-11 20:18:59.000000000 -0500
@@ -6,7 +6,12 @@
  *  Authors:  Serge Hallyn <sergeh@us.ibm.com>
  *	      Trent Jaeger <jaegert@us.ibm.com>
  *
+ *  Updated: Venkat Yekkirala <vyekkirala@TrustedCS.com>
+ *
+ *           Granular IPSec Associations for use in MLS environments.
+ *
  *  Copyright (C) 2005 International Business Machines Corporation
+ *  Copyright (C) 2006 Trusted Computer Solutions, Inc.
  *
  *	This program is free software; you can redistribute it and/or modify
  *	it under the terms of the GNU General Public License version 2,
@@ -67,10 +72,10 @@ static inline int selinux_authorizable_x
 }
 
 /*
- * LSM hook implementation that authorizes that a socket can be used
- * with the corresponding xfrm_sec_ctx and direction.
+ * LSM hook implementation that authorizes that a flow can use
+ * a xfrm policy rule.
  */
-int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 sk_sid, u8 dir)
+int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir)
 {
 	int rc = 0;
 	u32 sel_sid = SECINITSID_UNLABELED;
@@ -84,27 +89,129 @@ int selinux_xfrm_policy_lookup(struct xf
 		sel_sid = ctx->ctx_sid;
 	}
 
-	rc = avc_has_perm(sk_sid, sel_sid, SECCLASS_ASSOCIATION,
-			  ((dir == FLOW_DIR_IN) ? ASSOCIATION__RECVFROM :
-			   ((dir == FLOW_DIR_OUT) ?  ASSOCIATION__SENDTO :
-			    (ASSOCIATION__SENDTO | ASSOCIATION__RECVFROM))),
+	rc = avc_has_perm(fl_secid, sel_sid, SECCLASS_ASSOCIATION,
+			  ASSOCIATION__POLMATCH,
 			  NULL);
 
 	return rc;
 }
 
 /*
+ * LSM hook implementation that authorizes that a state matches
+ * the given policy, flow combo.
+ */
+
+int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x, struct xfrm_policy *xp,
+			struct flowi *fl)
+{
+	u32 state_sid;
+	u32 pol_sid;
+	int err;
+
+	if (x->security)
+		state_sid = x->security->ctx_sid;
+	else
+		state_sid = SECINITSID_UNLABELED;
+
+	if (xp->security)
+		pol_sid = xp->security->ctx_sid;
+	else
+		pol_sid = SECINITSID_UNLABELED;
+
+	err = avc_has_perm(state_sid, pol_sid, SECCLASS_ASSOCIATION,
+			  ASSOCIATION__POLMATCH,
+			  NULL);
+
+	if (err)
+		return 0;
+
+	return selinux_xfrm_flow_state_match(fl, x);
+}
+
+/*
+ * LSM hook implementation that authorizes that a particular outgoing flow
+ * can use a given security association.
+ */
+
+int selinux_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm)
+{
+	int rc = 0;
+	u32 sel_sid = SECINITSID_UNLABELED;
+	struct xfrm_sec_ctx *ctx;
+
+	/* Context sid is either set to label or ANY_ASSOC */
+	if ((ctx = xfrm->security)) {
+		if (!selinux_authorizable_ctx(ctx))
+			return 0;
+
+		sel_sid = ctx->ctx_sid;
+	}
+
+	rc = avc_has_perm(fl->secid, sel_sid, SECCLASS_ASSOCIATION,
+			  ASSOCIATION__SENDTO,
+			  NULL)? 0:1;
+
+	return rc;
+}
+
+/*
+ * LSM hook implementation that determines the sid for the session.
+ */
+
+int selinux_xfrm_decode_session(struct sk_buff *skb, struct flowi *fl)
+{
+	struct sec_path *sp;
+
+	fl->secid = SECSID_NULL;
+
+	if (skb == NULL)
+		return 0;
+
+	sp = skb->sp;
+	if (sp) {
+		int i, sid_set = 0;
+
+		for (i = sp->len-1; i >= 0; i--) {
+			struct xfrm_state *x = sp->xvec[i];
+			if (selinux_authorizable_xfrm(x)) {
+				struct xfrm_sec_ctx *ctx = x->security;
+
+				if (!sid_set) {
+					fl->secid = ctx->ctx_sid;
+					sid_set = 1;
+				}
+				else if (fl->secid != ctx->ctx_sid)
+					return -EINVAL;
+			}
+		}
+	}
+
+	return 0;
+}
+
+/*
  * Security blob allocation for xfrm_policy and xfrm_state
  * CTX does not have a meaningful value on input
  */
-static int selinux_xfrm_sec_ctx_alloc(struct xfrm_sec_ctx **ctxp, struct xfrm_user_sec_ctx *uctx)
+static int selinux_xfrm_sec_ctx_alloc(struct xfrm_sec_ctx **ctxp,
+	struct xfrm_user_sec_ctx *uctx, struct xfrm_sec_ctx *pol, u32 sid)
 {
 	int rc = 0;
 	struct task_security_struct *tsec = current->security;
-	struct xfrm_sec_ctx *ctx;
+	struct xfrm_sec_ctx *ctx = NULL;
+	char *ctx_str = NULL;
+	u32 str_len;
+	u32 ctx_sid;
+
+	BUG_ON(uctx && pol);
+
+	if (pol)
+		goto from_policy;
 
 	BUG_ON(!uctx);
-	BUG_ON(uctx->ctx_doi != XFRM_SC_ALG_SELINUX);
+
+	if (uctx->ctx_doi != XFRM_SC_ALG_SELINUX)
+		return -EINVAL;
 
 	if (uctx->ctx_len >= PAGE_SIZE)
 		return -ENOMEM;
@@ -141,9 +248,41 @@ static int selinux_xfrm_sec_ctx_alloc(st
 
 	return rc;
 
+from_policy:
+	BUG_ON(!pol);
+	rc = security_sid_mls_copy(pol->ctx_sid, sid, &ctx_sid);
+	if (rc)
+		goto out;
+
+	rc = security_sid_to_context(ctx_sid, &ctx_str, &str_len);
+	if (rc)
+		goto out;
+
+	*ctxp = ctx = kmalloc(sizeof(*ctx) +
+			      str_len,
+			      GFP_ATOMIC);
+
+	if (!ctx) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+
+	ctx->ctx_doi = XFRM_SC_DOI_LSM;
+	ctx->ctx_alg = XFRM_SC_ALG_SELINUX;
+	ctx->ctx_sid = ctx_sid;
+	ctx->ctx_len = str_len;
+	memcpy(ctx->ctx_str,
+	       ctx_str,
+	       str_len);
+
+	goto out2;
+
 out:
 	*ctxp = NULL;
 	kfree(ctx);
+out2:
+	kfree(ctx_str);
 	return rc;
 }
 
@@ -157,7 +296,7 @@ int selinux_xfrm_policy_alloc(struct xfr
 
 	BUG_ON(!xp);
 
-	err = selinux_xfrm_sec_ctx_alloc(&xp->security, uctx);
+	err = selinux_xfrm_sec_ctx_alloc(&xp->security, uctx, NULL, 0);
 	return err;
 }
 
@@ -217,13 +356,14 @@ int selinux_xfrm_policy_delete(struct xf
  * LSM hook implementation that allocs and transfers sec_ctx spec to
  * xfrm_state.
  */
-int selinux_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *uctx)
+int selinux_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *uctx,
+		struct xfrm_sec_ctx *pol, u32 secid)
 {
 	int err;
 
 	BUG_ON(!x);
 
-	err = selinux_xfrm_sec_ctx_alloc(&x->security, uctx);
+	err = selinux_xfrm_sec_ctx_alloc(&x->security, uctx, pol, secid);
 	return err;
 }
 
@@ -329,38 +469,30 @@ int selinux_xfrm_state_delete(struct xfr
  * we need to check for unlabelled access since this may not have
  * gone thru the IPSec process.
  */
-int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb)
+int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb,
+				struct avc_audit_data *ad)
 {
 	int i, rc = 0;
 	struct sec_path *sp;
+	u32 sel_sid = SECINITSID_UNLABELED;
 
 	sp = skb->sp;
 
 	if (sp) {
-		/*
-		 * __xfrm_policy_check does not approve unless xfrm_policy_ok
-		 * says that spi's match for policy and the socket.
-		 *
-		 *  Only need to verify the existence of an authorizable sp.
-		 */
 		for (i = 0; i < sp->len; i++) {
 			struct xfrm_state *x = sp->xvec[i];
 
-			if (x && selinux_authorizable_xfrm(x))
-				goto accept;
+			if (x && selinux_authorizable_xfrm(x)) {
+				struct xfrm_sec_ctx *ctx = x->security;
+				sel_sid = ctx->ctx_sid;
+				break;
+			}
 		}
 	}
 
-	/* check SELinux sock for unlabelled access */
-	rc = avc_has_perm(isec_sid, SECINITSID_UNLABELED, SECCLASS_ASSOCIATION,
-			  ASSOCIATION__RECVFROM, NULL);
-	if (rc)
-		goto drop;
-
-accept:
-	return 0;
+	rc = avc_has_perm(isec_sid, sel_sid, SECCLASS_ASSOCIATION,
+			  ASSOCIATION__RECVFROM, ad);
 
-drop:
 	return rc;
 }
 
@@ -371,7 +503,8 @@ drop:
  * If we do have a authorizable security association, then it has already been
  * checked in xfrm_policy_lookup hook.
  */
-int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb)
+int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
+					struct avc_audit_data *ad)
 {
 	struct dst_entry *dst;
 	int rc = 0;
@@ -391,7 +524,7 @@ int selinux_xfrm_postroute_last(u32 isec
 	}
 
 	rc = avc_has_perm(isec_sid, SECINITSID_UNLABELED, SECCLASS_ASSOCIATION,
-			  ASSOCIATION__SENDTO, NULL);
+			  ASSOCIATION__SENDTO, ad);
 out:
 	return rc;
 }
--- linux-2.6.17.fl_secid/net/xfrm/xfrm_policy.c	2006-07-11 16:04:21.000000000 -0500
+++ linux-2.6.17/net/xfrm/xfrm_policy.c	2006-07-11 19:57:00.000000000 -0500
@@ -598,7 +598,7 @@ EXPORT_SYMBOL(xfrm_policy_walk);
 
 /* Find policy to apply to this flow. */
 
-static void xfrm_policy_lookup(struct flowi *fl, u32 sk_sid, u16 family, u8 dir,
+static void xfrm_policy_lookup(struct flowi *fl, u16 family, u8 dir,
 			       void **objp, atomic_t **obj_refp)
 {
 	struct xfrm_policy *pol;
@@ -614,7 +614,7 @@ static void xfrm_policy_lookup(struct fl
 		match = xfrm_selector_match(sel, fl, family);
 
 		if (match) {
- 			if (!security_xfrm_policy_lookup(pol, sk_sid, dir)) {
+ 			if (!security_xfrm_policy_lookup(pol, fl->secid, dir)) {
 				xfrm_pol_hold(pol);
 				break;
 			}
@@ -642,7 +642,7 @@ static inline int policy_to_flow_dir(int
 	};
 }
 
-static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struct flowi *fl, u32 sk_sid)
+static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struct flowi *fl)
 {
 	struct xfrm_policy *pol;
 
@@ -653,7 +653,7 @@ static struct xfrm_policy *xfrm_sk_polic
  		int err = 0;
 
 		if (match)
-		  err = security_xfrm_policy_lookup(pol, sk_sid, policy_to_flow_dir(dir));
+		  err = security_xfrm_policy_lookup(pol, fl->secid, policy_to_flow_dir(dir));
 
  		if (match && !err)
 			xfrm_pol_hold(pol);
@@ -863,19 +863,20 @@ int xfrm_lookup(struct dst_entry **dst_p
 	u32 genid;
 	u16 family;
 	u8 dir = policy_to_flow_dir(XFRM_POLICY_OUT);
-	u32 sk_sid = security_sk_sid(sk, fl, dir);
+
+	fl->secid = security_sk_sid(sk, fl, dir);
 restart:
 	genid = atomic_read(&flow_cache_genid);
 	policy = NULL;
 	if (sk && sk->sk_policy[1])
-		policy = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl, sk_sid);
+		policy = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
 
 	if (!policy) {
 		/* To accelerate a bit...  */
 		if ((dst_orig->flags & DST_NOXFRM) || !xfrm_policy_list[XFRM_POLICY_OUT])
 			return 0;
 
-		policy = flow_cache_lookup(fl, sk_sid, dst_orig->ops->family,
+		policy = flow_cache_lookup(fl, dst_orig->ops->family,
 					   dir, xfrm_policy_lookup);
 	}
 
@@ -1033,13 +1034,15 @@ int
 xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family)
 {
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	int err;
 
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 
 	afinfo->decode_session(skb, fl);
+	err = security_xfrm_decode_session(skb, fl);
 	xfrm_policy_put_afinfo(afinfo);
-	return 0;
+	return err;
 }
 EXPORT_SYMBOL(xfrm_decode_session);
 
@@ -1059,14 +1062,11 @@ int __xfrm_policy_check(struct sock *sk,
 	struct xfrm_policy *pol;
 	struct flowi fl;
 	u8 fl_dir = policy_to_flow_dir(dir);
-	u32 sk_sid;
 
 	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
 	nf_nat_decode_session(skb, &fl, family);
 
-	sk_sid = security_sk_sid(sk, &fl, fl_dir);
-
 	/* First, check used SA against their selectors. */
 	if (skb->sp) {
 		int i;
@@ -1080,10 +1080,10 @@ int __xfrm_policy_check(struct sock *sk,
 
 	pol = NULL;
 	if (sk && sk->sk_policy[dir])
-		pol = xfrm_sk_policy_lookup(sk, dir, &fl, sk_sid);
+		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
 
 	if (!pol)
-		pol = flow_cache_lookup(&fl, sk_sid, family, fl_dir,
+		pol = flow_cache_lookup(&fl, family, fl_dir,
 					xfrm_policy_lookup);
 
 	if (!pol)
@@ -1278,6 +1278,8 @@ int xfrm_bundle_ok(struct xfrm_dst *firs
 
 		if (fl && !xfrm_selector_match(&dst->xfrm->sel, fl, family))
 			return 0;
+		if (fl && !security_xfrm_flow_state_match(fl, dst->xfrm))
+			return 0;
 		if (dst->xfrm->km.state != XFRM_STATE_VALID)
 			return 0;
 
--- linux-2.6.17.fl_secid/net/xfrm/xfrm_state.c	2006-07-11 16:04:21.000000000 -0500
+++ linux-2.6.17/net/xfrm/xfrm_state.c	2006-07-11 19:57:00.000000000 -0500
@@ -368,7 +368,7 @@ xfrm_state_find(xfrm_address_t *daddr, x
 			 */
 			if (x->km.state == XFRM_STATE_VALID) {
 				if (!xfrm_selector_match(&x->sel, fl, family) ||
-				    !xfrm_sec_ctx_match(pol->security, x->security))
+				    !security_xfrm_state_pol_flow_match(x, pol, fl))
 					continue;
 				if (!best ||
 				    best->km.dying > x->km.dying ||
@@ -380,7 +380,7 @@ xfrm_state_find(xfrm_address_t *daddr, x
 			} else if (x->km.state == XFRM_STATE_ERROR ||
 				   x->km.state == XFRM_STATE_EXPIRED) {
  				if (xfrm_selector_match(&x->sel, fl, family) &&
-				    xfrm_sec_ctx_match(pol->security, x->security))
+				    security_xfrm_state_pol_flow_match(x, pol, fl))
 					error = -ESRCH;
 			}
 		}
@@ -404,6 +404,14 @@ xfrm_state_find(xfrm_address_t *daddr, x
 		 * to current session. */
 		xfrm_init_tempsel(x, fl, tmpl, daddr, saddr, family);
 
+		error = security_xfrm_state_alloc_acquire(x, pol->security, fl->secid);
+		if (error) {
+			x->km.state = XFRM_STATE_DEAD;
+			xfrm_state_put(x);
+			x = NULL;
+			goto out;
+		}
+
 		if (km_query(x, tmpl, pol) == 0) {
 			x->km.state = XFRM_STATE_ACQ;
 			list_add_tail(&x->bydst, xfrm_state_bydst+h);
