From: Kevin Cernekee <cernekee@chromium.org>
Subject: [PATCH 2/4] xfrm_user: Allow common functions to be called from another file
Date: Fri, 20 Jan 2017 16:05:05 -0800
Message-ID: <20170121000507.34381-3-cernekee@chromium.org>
References: <20170121000507.34381-1-cernekee@chromium.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        selinux@tycho.nsa.gov, fw@strlen.de, fan.du@windriver.com,
        dianders@chromium.org, dtor@chromium.org
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, paul@paul-moore.com, sds@tycho.nsa.gov,
        eparis@parisplace.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35967 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752415AbdAUAG1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:06:27 -0500
Received: by mail-pf0-f169.google.com with SMTP id 189so25929594pfu.3
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 16:06:27 -0800 (PST)
In-Reply-To: <20170121000507.34381-1-cernekee@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_user_legacy.c will need to call a few common functions.  Make
sure them have an "xfrm_" prefix, and declare them in a new xfrm_user.h
header.

Signed-off-by: Kevin Cernekee <cernekee@chromium.org>
---
 net/xfrm/xfrm_user.c | 147 +++++++++++++++++----------------------------------
 net/xfrm/xfrm_user.h |  90 +++++++++++++++++++++++++++++++
 2 files changed, 138 insertions(+), 99 deletions(-)
 create mode 100644 net/xfrm/xfrm_user.h

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ed389aad4994..4d733f02c3a1 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -32,6 +32,7 @@
 #include <linux/in6.h>
 #endif
 #include <asm/unaligned.h>
+#include "xfrm_user.h"
 
 static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 {
@@ -100,7 +101,7 @@ static void verify_one_addr(struct nlattr **attrs, enum xfrm_attr_type_t type,
 		*addrp = nla_data(rt);
 }
 
-static inline int verify_sec_ctx_len(struct nlattr **attrs)
+int xfrm_verify_sec_ctx_len(struct nlattr **attrs)
 {
 	struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 	struct xfrm_user_sec_ctx *uctx;
@@ -148,8 +149,8 @@ static inline int verify_replay(const struct xfrm_usersa_info *p,
 	return 0;
 }
 
-static int verify_newsa_info(const struct xfrm_usersa_info *p,
-			     struct nlattr **attrs)
+int xfrm_verify_newsa_info(const struct xfrm_usersa_info *p,
+			   struct nlattr **attrs)
 {
 	int err;
 
@@ -241,7 +242,7 @@ static int verify_newsa_info(const struct xfrm_usersa_info *p,
 		goto out;
 	if ((err = verify_one_alg(attrs, XFRMA_ALG_COMP)))
 		goto out;
-	if ((err = verify_sec_ctx_len(attrs)))
+	if ((err = xfrm_verify_sec_ctx_len(attrs)))
 		goto out;
 	if ((err = verify_replay(p, attrs)))
 		goto out;
@@ -460,17 +461,6 @@ static int xfrm_alloc_replay_state_esn(
 	return 0;
 }
 
-static inline int xfrm_user_sec_ctx_size(const struct xfrm_sec_ctx *xfrm_ctx)
-{
-	int len = 0;
-
-	if (xfrm_ctx) {
-		len += sizeof(struct xfrm_user_sec_ctx);
-		len += xfrm_ctx->ctx_len;
-	}
-	return len;
-}
-
 static void copy_from_user_state(struct xfrm_state *x,
 				 const struct xfrm_usersa_info *p)
 {
@@ -537,10 +527,10 @@ static void xfrm_update_ae_params(struct xfrm_state *x,
 		x->replay_maxdiff = nla_get_u32(rt);
 }
 
-static struct xfrm_state *xfrm_state_construct(struct net *net,
-					       const struct xfrm_usersa_info *p,
-					       struct nlattr **attrs,
-					       int *errp)
+struct xfrm_state *xfrm_state_construct(struct net *net,
+					const struct xfrm_usersa_info *p,
+					struct nlattr **attrs,
+					int *errp)
 {
 	struct xfrm_state *x = xfrm_state_alloc(net);
 	int err = -ENOMEM;
@@ -634,7 +624,7 @@ static int xfrm_add_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	int err;
 	struct km_event c;
 
-	err = verify_newsa_info(p, attrs);
+	err = xfrm_verify_newsa_info(p, attrs);
 	if (err)
 		return err;
 
@@ -666,10 +656,10 @@ static int xfrm_add_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	return err;
 }
 
-static struct xfrm_state *xfrm_user_state_lookup(struct net *net,
-						 const struct xfrm_usersa_id *p,
-						 struct nlattr **attrs,
-						 int *errp)
+struct xfrm_state *xfrm_user_state_lookup(struct net *net,
+					  const struct xfrm_usersa_id *p,
+					  struct nlattr **attrs,
+					  int *errp)
 {
 	struct xfrm_state *x = NULL;
 	struct xfrm_mark m;
@@ -757,14 +747,7 @@ static void copy_to_user_state(const struct xfrm_state *x,
 	p->seq = x->km.seq;
 }
 
-struct xfrm_dump_info {
-	struct sk_buff *in_skb;
-	struct sk_buff *out_skb;
-	u32 nlmsg_seq;
-	u16 nlmsg_flags;
-};
-
-static int copy_sec_ctx(const struct xfrm_sec_ctx *s, struct sk_buff *skb)
+int xfrm_copy_sec_ctx(const struct xfrm_sec_ctx *s, struct sk_buff *skb)
 {
 	struct xfrm_user_sec_ctx *uctx;
 	struct nlattr *attr;
@@ -785,8 +768,8 @@ static int copy_sec_ctx(const struct xfrm_sec_ctx *s, struct sk_buff *skb)
 	return 0;
 }
 
-static int copy_to_user_auth(const struct xfrm_algo_auth *auth,
-			     struct sk_buff *skb)
+int xfrm_copy_to_user_auth(const struct xfrm_algo_auth *auth,
+			   struct sk_buff *skb)
 {
 	struct xfrm_algo *algo;
 	struct nlattr *nla;
@@ -837,7 +820,7 @@ static int copy_to_user_state_extra(const struct xfrm_state *x,
 			goto out;
 	}
 	if (x->aalg) {
-		ret = copy_to_user_auth(x->aalg, skb);
+		ret = xfrm_copy_to_user_auth(x->aalg, skb);
 		if (!ret)
 			ret = nla_put(skb, XFRMA_ALG_AUTH_TRUNC,
 				      xfrm_alg_auth_len(x->aalg), x->aalg);
@@ -877,7 +860,7 @@ static int copy_to_user_state_extra(const struct xfrm_state *x,
 	if (ret)
 		goto out;
 	if (x->security)
-		ret = copy_sec_ctx(x->security, skb);
+		ret = xfrm_copy_sec_ctx(x->security, skb);
 out:
 	return ret;
 }
@@ -992,8 +975,8 @@ static struct sk_buff *xfrm_state_netlink(struct sk_buff *in_skb,
 /* A wrapper for nlmsg_multicast() checking that nlsk is still available.
  * Must be called with RCU read lock.
  */
-static inline int xfrm_nlmsg_multicast(struct net *net, struct sk_buff *skb,
-				       u32 pid, unsigned int group)
+int xfrm_nlmsg_multicast(struct net *net, struct sk_buff *skb,
+			 u32 pid, unsigned int group)
 {
 	struct sock *nlsk = rcu_dereference(net->xfrm.nlsk);
 
@@ -1270,7 +1253,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	return err;
 }
 
-static int verify_policy_dir(u8 dir)
+int xfrm_verify_policy_dir(u8 dir)
 {
 	switch (dir) {
 	case XFRM_POLICY_IN:
@@ -1301,7 +1284,7 @@ static int verify_policy_type(u8 type)
 	return 0;
 }
 
-static int verify_newpolicy_info(const struct xfrm_userpolicy_info *p)
+int xfrm_verify_newpolicy_info(const struct xfrm_userpolicy_info *p)
 {
 	int ret;
 
@@ -1340,7 +1323,7 @@ static int verify_newpolicy_info(const struct xfrm_userpolicy_info *p)
 		return -EINVAL;
 	}
 
-	ret = verify_policy_dir(p->dir);
+	ret = xfrm_verify_policy_dir(p->dir);
 	if (ret)
 		return ret;
 	if (p->index && ((p->index & XFRM_POLICY_MAX) != p->dir))
@@ -1440,7 +1423,7 @@ static int copy_from_user_tmpl(struct xfrm_policy *pol, struct nlattr **attrs)
 	return 0;
 }
 
-static int copy_from_user_policy_type(u8 *tp, struct nlattr **attrs)
+int xfrm_copy_from_user_policy_type(u8 *tp, struct nlattr **attrs)
 {
 	struct nlattr *rt = attrs[XFRMA_POLICY_TYPE];
 	struct xfrm_userpolicy_type *upt;
@@ -1490,11 +1473,10 @@ static void copy_to_user_policy(const struct xfrm_policy *xp,
 	p->share = XFRM_SHARE_ANY; /* XXX xp->share */
 }
 
-static struct xfrm_policy *xfrm_policy_construct(
-	struct net *net,
-	const struct xfrm_userpolicy_info *p,
-	struct nlattr **attrs,
-	int *errp)
+struct xfrm_policy *xfrm_policy_construct(struct net *net,
+					  const struct xfrm_userpolicy_info *p,
+					  struct nlattr **attrs,
+					  int *errp)
 {
 	struct xfrm_policy *xp = xfrm_policy_alloc(net, GFP_KERNEL);
 	int err;
@@ -1506,7 +1488,7 @@ static struct xfrm_policy *xfrm_policy_construct(
 
 	copy_from_user_policy(xp, p);
 
-	err = copy_from_user_policy_type(&xp->type, attrs);
+	err = xfrm_copy_from_user_policy_type(&xp->type, attrs);
 	if (err)
 		goto error;
 
@@ -1535,10 +1517,10 @@ static int xfrm_add_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	int err;
 	int excl;
 
-	err = verify_newpolicy_info(p);
+	err = xfrm_verify_newpolicy_info(p);
 	if (err)
 		return err;
-	err = verify_sec_ctx_len(attrs);
+	err = xfrm_verify_sec_ctx_len(attrs);
 	if (err)
 		return err;
 
@@ -1570,7 +1552,7 @@ static int xfrm_add_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	return 0;
 }
 
-static int copy_to_user_tmpl(const struct xfrm_policy *xp, struct sk_buff *skb)
+int xfrm_copy_to_user_tmpl(const struct xfrm_policy *xp, struct sk_buff *skb)
 {
 	struct xfrm_user_tmpl vec[XFRM_MAX_DEPTH];
 	int i;
@@ -1599,22 +1581,6 @@ static int copy_to_user_tmpl(const struct xfrm_policy *xp, struct sk_buff *skb)
 		       sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr, vec);
 }
 
-static inline int copy_to_user_state_sec_ctx(const struct xfrm_state *x,
-					     struct sk_buff *skb)
-{
-	if (x->security) {
-		return copy_sec_ctx(x->security, skb);
-	}
-	return 0;
-}
-
-static inline int copy_to_user_sec_ctx(const struct xfrm_policy *xp,
-				       struct sk_buff *skb)
-{
-	if (xp->security)
-		return copy_sec_ctx(xp->security, skb);
-	return 0;
-}
 static inline size_t userpolicy_type_attrsize(void)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
@@ -1624,23 +1590,6 @@ static inline size_t userpolicy_type_attrsize(void)
 #endif
 }
 
-#ifdef CONFIG_XFRM_SUB_POLICY
-static int copy_to_user_policy_type(u8 type, struct sk_buff *skb)
-{
-	struct xfrm_userpolicy_type upt = {
-		.type = type,
-	};
-
-	return nla_put(skb, XFRMA_POLICY_TYPE, sizeof(upt), &upt);
-}
-
-#else
-static inline int copy_to_user_policy_type(u8 type, struct sk_buff *skb)
-{
-	return 0;
-}
-#endif
-
 static int dump_one_policy(const struct xfrm_policy *xp,
 			   int dir,
 			   int count,
@@ -1660,7 +1609,7 @@ static int dump_one_policy(const struct xfrm_policy *xp,
 
 	p = nlmsg_data(nlh);
 	copy_to_user_policy(xp, p, dir);
-	err = copy_to_user_tmpl(xp, skb);
+	err = xfrm_copy_to_user_tmpl(xp, skb);
 	if (!err)
 		err = copy_to_user_sec_ctx(xp, skb);
 	if (!err)
@@ -1751,11 +1700,11 @@ static int xfrm_get_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	p = nlmsg_data(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
 
-	err = copy_from_user_policy_type(&type, attrs);
+	err = xfrm_copy_from_user_policy_type(&type, attrs);
 	if (err)
 		return err;
 
-	err = verify_policy_dir(p->dir);
+	err = xfrm_verify_policy_dir(p->dir);
 	if (err)
 		return err;
 
@@ -1765,7 +1714,7 @@ static int xfrm_get_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
 
-		err = verify_sec_ctx_len(attrs);
+		err = xfrm_verify_sec_ctx_len(attrs);
 		if (err)
 			return err;
 
@@ -2013,7 +1962,7 @@ static int xfrm_flush_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
 
-	err = copy_from_user_policy_type(&type, attrs);
+	err = xfrm_copy_from_user_policy_type(&type, attrs);
 	if (err)
 		return err;
 
@@ -2045,11 +1994,11 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	struct xfrm_mark m;
 	u32 mark = xfrm_mark_get(attrs, &m);
 
-	err = copy_from_user_policy_type(&type, attrs);
+	err = xfrm_copy_from_user_policy_type(&type, attrs);
 	if (err)
 		return err;
 
-	err = verify_policy_dir(p->dir);
+	err = xfrm_verify_policy_dir(p->dir);
 	if (err)
 		return err;
 
@@ -2059,7 +2008,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, const struct nlmsghdr *nlh,
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
 
-		err = verify_sec_ctx_len(attrs);
+		err = xfrm_verify_sec_ctx_len(attrs);
 		if (err)
 			return err;
 
@@ -2146,7 +2095,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, const struct nlmsghdr *nlh,
 
 	xfrm_mark_get(attrs, &mark);
 
-	err = verify_newpolicy_info(&ua->policy);
+	err = xfrm_verify_newpolicy_info(&ua->policy);
 	if (err)
 		goto free_state;
 
@@ -2245,7 +2194,7 @@ static int xfrm_do_migrate(struct sk_buff *skb, const struct nlmsghdr *nlh,
 
 	kmp = attrs[XFRMA_KMADDRESS] ? &km : NULL;
 
-	err = copy_from_user_policy_type(&type, attrs);
+	err = xfrm_copy_from_user_policy_type(&type, attrs);
 	if (err)
 		return err;
 
@@ -2625,7 +2574,7 @@ static int xfrm_notify_sa_flush(const struct km_event *c)
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_SA);
 }
 
-static inline size_t xfrm_sa_len(const struct xfrm_state *x)
+size_t xfrm_sa_len(const struct xfrm_state *x)
 {
 	size_t l = 0;
 	if (x->aead)
@@ -2777,7 +2726,7 @@ static int build_acquire(struct sk_buff *skb,
 	ua->calgos = xt->calgos;
 	ua->seq = x->km.seq = seq;
 
-	err = copy_to_user_tmpl(xp, skb);
+	err = xfrm_copy_to_user_tmpl(xp, skb);
 	if (!err)
 		err = copy_to_user_state_sec_ctx(x, skb);
 	if (!err)
@@ -2846,7 +2795,7 @@ static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 	*dir = -EINVAL;
 
 	if (len < sizeof(*p) ||
-	    verify_newpolicy_info(p))
+	    xfrm_verify_newpolicy_info(p))
 		return NULL;
 
 	nr = ((len - sizeof(*p)) / sizeof(*ut));
@@ -2896,7 +2845,7 @@ static int build_polexpire(struct sk_buff *skb,
 
 	upe = nlmsg_data(nlh);
 	copy_to_user_policy(xp, &upe->pol, dir);
-	err = copy_to_user_tmpl(xp, skb);
+	err = xfrm_copy_to_user_tmpl(xp, skb);
 	if (!err)
 		err = copy_to_user_sec_ctx(xp, skb);
 	if (!err)
@@ -2981,7 +2930,7 @@ static int xfrm_notify_policy(const struct xfrm_policy *xp,
 	}
 
 	copy_to_user_policy(xp, p, dir);
-	err = copy_to_user_tmpl(xp, skb);
+	err = xfrm_copy_to_user_tmpl(xp, skb);
 	if (!err)
 		err = copy_to_user_policy_type(xp->type, skb);
 	if (!err)
diff --git a/net/xfrm/xfrm_user.h b/net/xfrm/xfrm_user.h
new file mode 100644
index 000000000000..29bab2ebee83
--- /dev/null
+++ b/net/xfrm/xfrm_user.h
@@ -0,0 +1,90 @@
+#ifndef _XFRM_USER_H
+#define _XFRM_USER_H
+
+#include <linux/netlink.h>
+#include <linux/skbuff.h>
+#include <linux/types.h>
+#include <linux/xfrm.h>
+#include <net/net_namespace.h>
+
+struct xfrm_dump_info {
+	struct sk_buff *in_skb;
+	struct sk_buff *out_skb;
+	u32 nlmsg_seq;
+	u16 nlmsg_flags;
+};
+
+/* Common functions */
+
+int xfrm_copy_sec_ctx(const struct xfrm_sec_ctx *s, struct sk_buff *skb);
+int xfrm_copy_to_user_auth(const struct xfrm_algo_auth *auth,
+			   struct sk_buff *skb);
+int xfrm_verify_newpolicy_info(const struct xfrm_userpolicy_info *p);
+struct xfrm_policy *xfrm_policy_construct(struct net *net,
+					  const struct xfrm_userpolicy_info *p,
+					  struct nlattr **attrs,
+					  int *errp);
+int xfrm_copy_from_user_policy_type(u8 *tp, struct nlattr **attrs);
+int xfrm_verify_policy_dir(u8 dir);
+int xfrm_verify_sec_ctx_len(struct nlattr **attrs);
+int xfrm_nlmsg_multicast(struct net *net, struct sk_buff *skb,
+			 u32 pid, unsigned int group);
+int xfrm_copy_to_user_tmpl(const struct xfrm_policy *xp, struct sk_buff *skb);
+size_t xfrm_sa_len(const struct xfrm_state *x);
+int xfrm_verify_newsa_info(const struct xfrm_usersa_info *p,
+			   struct nlattr **attrs);
+struct xfrm_state *xfrm_state_construct(struct net *net,
+					const struct xfrm_usersa_info *p,
+					struct nlattr **attrs,
+					int *errp);
+struct xfrm_state *xfrm_user_state_lookup(struct net *net,
+					  const struct xfrm_usersa_id *p,
+					  struct nlattr **attrs,
+					  int *errp);
+
+#ifdef CONFIG_XFRM_SUB_POLICY
+static inline int copy_to_user_policy_type(u8 type, struct sk_buff *skb)
+{
+	struct xfrm_userpolicy_type upt = {
+		.type = type,
+	};
+
+	return nla_put(skb, XFRMA_POLICY_TYPE, sizeof(upt), &upt);
+}
+
+#else
+static inline int copy_to_user_policy_type(u8 type, struct sk_buff *skb)
+{
+	return 0;
+}
+#endif
+
+static inline int copy_to_user_sec_ctx(const struct xfrm_policy *xp,
+				       struct sk_buff *skb)
+{
+	if (xp->security)
+		return xfrm_copy_sec_ctx(xp->security, skb);
+	return 0;
+}
+
+static inline int xfrm_user_sec_ctx_size(const struct xfrm_sec_ctx *xfrm_ctx)
+{
+	int len = 0;
+
+	if (xfrm_ctx) {
+		len += sizeof(struct xfrm_user_sec_ctx);
+		len += xfrm_ctx->ctx_len;
+	}
+	return len;
+}
+
+static inline int copy_to_user_state_sec_ctx(const struct xfrm_state *x,
+					     struct sk_buff *skb)
+{
+	if (x->security) {
+		return xfrm_copy_sec_ctx(x->security, skb);
+	}
+	return 0;
+}
+
+#endif /* _XFRM_USER_H */
-- 
2.11.0.483.g087da7b7c-goog
