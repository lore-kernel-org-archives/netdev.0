From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 09/10] MLSXFRM-v02: Default labeling of socket specific IPSec
 policies
Date: Tue, 18 Jul 2006 12:24:55 -0500
Message-ID: <44BD1967.7030501@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:37286 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932324AbWGRRZM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 13:25:12 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This defaults the label of socket-specific IPSec policies to be the
same as the socket they are set on.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h        |   19 ++++++++++++++---
 include/net/xfrm.h              |    2 -
 net/key/af_key.c                |   15 ++++++++++---
 net/xfrm/xfrm_state.c           |    2 -
 net/xfrm/xfrm_user.c            |   13 ++++++++++-
 security/dummy.c                |    3 +-
 security/selinux/include/xfrm.h |    3 +-
 security/selinux/xfrm.c         |   33 ++++++++++++++++++++----------
 8 files changed, 66 insertions(+), 24 deletions(-)

--- linux-2.6.17.fl_labeling/include/linux/security.h	2006-07-17 16:25:29.000000000 -0500
+++ linux-2.6.17/include/linux/security.h	2006-07-17 16:51:22.000000000 -0500
@@ -827,8 +827,10 @@ struct swap_info_struct;
  *	used by the XFRM system.
  *	@sec_ctx contains the security context information being provided by
  *	the user-level policy update program (e.g., setkey).
+ *	@sk refers to the sock from which to derive the security context.
  *	Allocate a security structure to the xp->security field; the security
- *	field is initialized to NULL when the xfrm_policy is allocated.
+ *	field is initialized to NULL when the xfrm_policy is allocated. Only
+ *	one of sec_ctx or sock can be specified.
  *	Return 0 if operation was successful (memory to allocate, legal context)
  * @xfrm_policy_clone_security:
  *	@old contains an existing xfrm_policy in the SPD.
@@ -1347,7 +1349,8 @@ struct security_operations {
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
-	int (*xfrm_policy_alloc_security) (struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx);
+	int (*xfrm_policy_alloc_security) (struct xfrm_policy *xp,
+			struct xfrm_user_sec_ctx *sec_ctx, struct sock *sk);
 	int (*xfrm_policy_clone_security) (struct xfrm_policy *old, struct xfrm_policy *new);
 	void (*xfrm_policy_free_security) (struct xfrm_policy *xp);
 	int (*xfrm_policy_delete_security) (struct xfrm_policy *xp);
@@ -3029,7 +3032,12 @@ static inline void security_sk_classify_
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 static inline int security_xfrm_policy_alloc(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx)
 {
-	return security_ops->xfrm_policy_alloc_security(xp, sec_ctx);
+	return security_ops->xfrm_policy_alloc_security(xp, sec_ctx, NULL);
+}
+
+static inline int security_xfrm_sock_policy_alloc(struct xfrm_policy *xp, struct sock *sk)
+{
+	return security_ops->xfrm_policy_alloc_security(xp, NULL, sk);
 }
 
 static inline int security_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new)
@@ -3104,6 +3112,11 @@ static inline int security_xfrm_policy_a
 	return 0;
 }
 
+static inline int security_xfrm_sock_policy_alloc(struct xfrm_policy *xp, struct sock *sk)
+{
+	return 0;
+}
+
 static inline int security_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new)
 {
 	return 0;
--- linux-2.6.17.fl_labeling/include/net/xfrm.h	2006-07-14 09:57:15.000000000 -0500
+++ linux-2.6.17/include/net/xfrm.h	2006-07-17 16:51:22.000000000 -0500
@@ -363,7 +363,7 @@ struct xfrm_mgr
 	char			*id;
 	int			(*notify)(struct xfrm_state *x, struct km_event *c);
 	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp, int dir);
-	struct xfrm_policy	*(*compile_policy)(u16 family, int opt, u8 *data, int len, int *dir);
+	struct xfrm_policy	*(*compile_policy)(struct sock *sk, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
 	int			(*notify_policy)(struct xfrm_policy *x, int dir, struct km_event *c);
 };
--- linux-2.6.17.fl_labeling/security/dummy.c	2006-07-17 16:05:38.000000000 -0500
+++ linux-2.6.17/security/dummy.c	2006-07-17 16:51:22.000000000 -0500
@@ -816,7 +816,8 @@ static inline void dummy_sk_getsecid(str
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
-static int dummy_xfrm_policy_alloc_security(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx)
+static int dummy_xfrm_policy_alloc_security(struct xfrm_policy *xp,
+		struct xfrm_user_sec_ctx *sec_ctx, struct sock *sk)
 {
 	return 0;
 }
--- linux-2.6.17.fl_labeling/security/selinux/include/xfrm.h	2006-07-17 16:08:29.000000000 -0500
+++ linux-2.6.17/security/selinux/include/xfrm.h	2006-07-17 16:51:22.000000000 -0500
@@ -7,7 +7,8 @@
 #ifndef _SELINUX_XFRM_H_
 #define _SELINUX_XFRM_H_
 
-int selinux_xfrm_policy_alloc(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx);
+int selinux_xfrm_policy_alloc(struct xfrm_policy *xp,
+		struct xfrm_user_sec_ctx *sec_ctx, struct sock *sk);
 int selinux_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new);
 void selinux_xfrm_policy_free(struct xfrm_policy *xp);
 int selinux_xfrm_policy_delete(struct xfrm_policy *xp);
--- linux-2.6.17.fl_labeling/security/selinux/xfrm.c	2006-07-17 16:05:38.000000000 -0500
+++ linux-2.6.17/security/selinux/xfrm.c	2006-07-17 16:51:22.000000000 -0500
@@ -208,10 +208,8 @@ static int selinux_xfrm_sec_ctx_alloc(st
 
 	BUG_ON(uctx && pol);
 
-	if (pol)
-		goto from_policy;
-
-	BUG_ON(!uctx);
+	if (!uctx)
+		goto not_from_user;
 
 	if (uctx->ctx_doi != XFRM_SC_ALG_SELINUX)
 		return -EINVAL;
@@ -251,11 +249,14 @@ static int selinux_xfrm_sec_ctx_alloc(st
 
 	return rc;
 
-from_policy:
-	BUG_ON(!pol);
-	rc = security_sid_mls_copy(pol->ctx_sid, sid, &ctx_sid);
-	if (rc)
-		goto out;
+not_from_user:
+	if (pol) {
+		rc = security_sid_mls_copy(pol->ctx_sid, sid, &ctx_sid);
+		if (rc)
+			goto out;
+	}
+	else
+		ctx_sid = sid;
 
 	rc = security_sid_to_context(ctx_sid, &ctx_str, &str_len);
 	if (rc)
@@ -293,13 +294,23 @@ out2:
  * LSM hook implementation that allocs and transfers uctx spec to
  * xfrm_policy.
  */
-int selinux_xfrm_policy_alloc(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *uctx)
+int selinux_xfrm_policy_alloc(struct xfrm_policy *xp,
+		struct xfrm_user_sec_ctx *uctx, struct sock *sk)
 {
 	int err;
+	u32 sid;
 
 	BUG_ON(!xp);
+	BUG_ON(uctx && sk);
+
+	if (sk) {
+		struct sk_security_struct *ssec = sk->sk_security;
+		sid = ssec->sid;
+	}
+	else
+		sid = SECSID_NULL;
 
-	err = selinux_xfrm_sec_ctx_alloc(&xp->security, uctx, NULL, 0);
+	err = selinux_xfrm_sec_ctx_alloc(&xp->security, uctx, NULL, sid);
 	return err;
 }
 
--- linux-2.6.17.fl_labeling/net/key/af_key.c	2006-07-17 15:03:05.000000000 -0500
+++ linux-2.6.17/net/key/af_key.c	2006-07-17 16:51:22.000000000 -0500
@@ -2843,14 +2843,14 @@ static int pfkey_send_acquire(struct xfr
 	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_REGISTERED, NULL);
 }
 
-static struct xfrm_policy *pfkey_compile_policy(u16 family, int opt,
+static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
                                                 u8 *data, int len, int *dir)
 {
 	struct xfrm_policy *xp;
 	struct sadb_x_policy *pol = (struct sadb_x_policy*)data;
 	struct sadb_x_sec_ctx *sec_ctx;
 
-	switch (family) {
+	switch (sk->sk_family) {
 	case AF_INET:
 		if (opt != IP_IPSEC_POLICY) {
 			*dir = -EOPNOTSUPP;
@@ -2891,7 +2891,7 @@ static struct xfrm_policy *pfkey_compile
 	xp->lft.hard_byte_limit = XFRM_INF;
 	xp->lft.soft_packet_limit = XFRM_INF;
 	xp->lft.hard_packet_limit = XFRM_INF;
-	xp->family = family;
+	xp->family = sk->sk_family;
 
 	xp->xfrm_nr = 0;
 	if (pol->sadb_x_policy_type == IPSEC_POLICY_IPSEC &&
@@ -2907,8 +2907,10 @@ static struct xfrm_policy *pfkey_compile
 		p += pol->sadb_x_policy_len*8;
 		sec_ctx = (struct sadb_x_sec_ctx *)p;
 		if (len < pol->sadb_x_policy_len*8 +
-		    sec_ctx->sadb_x_sec_len)
+		    sec_ctx->sadb_x_sec_len) {
+			*dir = -EINVAL;
 			goto out;
+		}
 		if ((*dir = verify_sec_ctx_len(p)))
 			goto out;
 		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
@@ -2918,6 +2920,11 @@ static struct xfrm_policy *pfkey_compile
 		if (*dir)
 			goto out;
 	}
+	else {
+		*dir = security_xfrm_sock_policy_alloc(xp, sk);
+		if (*dir)
+			goto out;
+	}
 
 	*dir = pol->sadb_x_policy_dir-1;
 	return xp;
--- linux-2.6.17.fl_labeling/net/xfrm/xfrm_state.c	2006-07-17 14:10:26.000000000 -0500
+++ linux-2.6.17/net/xfrm/xfrm_state.c	2006-07-17 16:51:22.000000000 -0500
@@ -1027,7 +1027,7 @@ int xfrm_user_policy(struct sock *sk, in
 	err = -EINVAL;
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list) {
-		pol = km->compile_policy(sk->sk_family, optname, data,
+		pol = km->compile_policy(sk, optname, data,
 					 optlen, &err);
 		if (err >= 0)
 			break;
--- linux-2.6.17.fl_labeling/net/xfrm/xfrm_user.c	2006-07-17 14:58:45.000000000 -0500
+++ linux-2.6.17/net/xfrm/xfrm_user.c	2006-07-17 16:51:22.000000000 -0500
@@ -1756,7 +1756,7 @@ static int xfrm_send_acquire(struct xfrm
 /* User gives us xfrm_user_policy_info followed by an array of 0
  * or more templates.
  */
-static struct xfrm_policy *xfrm_compile_policy(u16 family, int opt,
+static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 					       u8 *data, int len, int *dir)
 {
 	struct xfrm_userpolicy_info *p = (struct xfrm_userpolicy_info *)data;
@@ -1764,7 +1764,7 @@ static struct xfrm_policy *xfrm_compile_
 	struct xfrm_policy *xp;
 	int nr;
 
-	switch (family) {
+	switch (sk->sk_family) {
 	case AF_INET:
 		if (opt != IP_XFRM_POLICY) {
 			*dir = -EOPNOTSUPP;
@@ -1806,6 +1806,15 @@ static struct xfrm_policy *xfrm_compile_
 	copy_from_user_policy(xp, p);
 	copy_templates(xp, ut, nr);
 
+	if (!xp->security) {
+		int err = security_xfrm_sock_policy_alloc(xp, sk);
+		if (err) {
+			kfree(xp);
+			*dir = err;
+			return NULL;
+		}
+	}
+
 	*dir = p->dir;
 
 	return xp;
