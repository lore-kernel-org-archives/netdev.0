From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 2/2] selinux: add gfp argument to security_xfrm_policy_alloc and fix callers
Date: Tue,  4 Mar 2014 13:26:24 +0100
Message-ID: <1393935984-8733-3-git-send-email-nikolay@redhat.com>
References: <20140227151954.GA30946@redhat.com>
 <1393935984-8733-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Paul Moore <paul@paul-moore.com>,
	Dave Jones <davej@redhat.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	LSM list <linux-security-module@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1393935984-8733-1-git-send-email-nikolay@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

security_xfrm_policy_alloc can be called in atomic context so the
allocation should be done with GFP_ATOMIC. Add an argument to let the
callers choose the appropriate way. In order to do so a gfp argument
needs to be added to the method xfrm_policy_alloc_security in struct
security_operations and to the internal function
selinux_xfrm_alloc_user. After that switch to GFP_ATOMIC in the atomic
callers and leave GFP_KERNEL as before for the rest.
The path that needed the gfp argument addition is:
security_xfrm_policy_alloc -> security_ops.xfrm_policy_alloc_security ->
all users of xfrm_policy_alloc_security (e.g. selinux_xfrm_policy_alloc) ->
selinux_xfrm_alloc_user (here the allocation used to be GFP_KERNEL only)

CC: Paul Moore <paul@paul-moore.com>
CC: Dave Jones <davej@redhat.com>
CC: Steffen Klassert <steffen.klassert@secunet.com>
CC: Fan Du <fan.du@windriver.com>
CC: David S. Miller <davem@davemloft.net>
CC: LSM list <linux-security-module@vger.kernel.org>

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 include/linux/security.h        | 10 +++++++---
 net/key/af_key.c                |  6 +++---
 net/xfrm/xfrm_user.c            |  6 +++---
 security/capability.c           |  3 ++-
 security/security.c             |  6 ++++--
 security/selinux/include/xfrm.h |  3 ++-
 security/selinux/xfrm.c         | 12 +++++++-----
 7 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 5623a7f965b7..2fc42d191f79 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1040,6 +1040,7 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	Allocate a security structure to the xp->security field; the security
  *	field is initialized to NULL when the xfrm_policy is allocated.
  *	Return 0 if operation was successful (memory to allocate, legal context)
+ *	@gfp is to specify the context for the allocation
  * @xfrm_policy_clone_security:
  *	@old_ctx contains an existing xfrm_sec_ctx.
  *	@new_ctxp contains a new xfrm_sec_ctx being cloned from old.
@@ -1683,7 +1684,7 @@ struct security_operations {
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	int (*xfrm_policy_alloc_security) (struct xfrm_sec_ctx **ctxp,
-			struct xfrm_user_sec_ctx *sec_ctx);
+			struct xfrm_user_sec_ctx *sec_ctx, gfp_t gfp);
 	int (*xfrm_policy_clone_security) (struct xfrm_sec_ctx *old_ctx, struct xfrm_sec_ctx **new_ctx);
 	void (*xfrm_policy_free_security) (struct xfrm_sec_ctx *ctx);
 	int (*xfrm_policy_delete_security) (struct xfrm_sec_ctx *ctx);
@@ -2859,7 +2860,8 @@ static inline void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 
-int security_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp, struct xfrm_user_sec_ctx *sec_ctx);
+int security_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp,
+			       struct xfrm_user_sec_ctx *sec_ctx, gfp_t gfp);
 int security_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx, struct xfrm_sec_ctx **new_ctxp);
 void security_xfrm_policy_free(struct xfrm_sec_ctx *ctx);
 int security_xfrm_policy_delete(struct xfrm_sec_ctx *ctx);
@@ -2877,7 +2879,9 @@ void security_skb_classify_flow(struct sk_buff *skb, struct flowi *fl);
 
 #else	/* CONFIG_SECURITY_NETWORK_XFRM */
 
-static inline int security_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp, struct xfrm_user_sec_ctx *sec_ctx)
+static inline int security_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp,
+					     struct xfrm_user_sec_ctx *sec_ctx,
+					     gfp_t gfp)
 {
 	return 0;
 }
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1526023f99ed..79326978517a 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2239,7 +2239,7 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, const struct sadb_
 			goto out;
 		}
 
-		err = security_xfrm_policy_alloc(&xp->security, uctx);
+		err = security_xfrm_policy_alloc(&xp->security, uctx, GFP_KERNEL);
 		kfree(uctx);
 
 		if (err)
@@ -2341,7 +2341,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, const struct sa
 		if (!uctx)
 			return -ENOMEM;
 
-		err = security_xfrm_policy_alloc(&pol_ctx, uctx);
+		err = security_xfrm_policy_alloc(&pol_ctx, uctx, GFP_KERNEL);
 		kfree(uctx);
 		if (err)
 			return err;
@@ -3241,7 +3241,7 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
 		if ((*dir = verify_sec_ctx_len(p)))
 			goto out;
 		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_ATOMIC);
-		*dir = security_xfrm_policy_alloc(&xp->security, uctx);
+		*dir = security_xfrm_policy_alloc(&xp->security, uctx, GFP_ATOMIC);
 		kfree(uctx);
 
 		if (*dir)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1ae3ec7c18b0..7c8278e55bde 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1226,7 +1226,7 @@ static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct nlattr **attrs
 		return 0;
 
 	uctx = nla_data(rt);
-	return security_xfrm_policy_alloc(&pol->security, uctx);
+	return security_xfrm_policy_alloc(&pol->security, uctx, GFP_KERNEL);
 }
 
 static void copy_templates(struct xfrm_policy *xp, struct xfrm_user_tmpl *ut,
@@ -1631,7 +1631,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		if (rt) {
 			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
 
-			err = security_xfrm_policy_alloc(&ctx, uctx);
+			err = security_xfrm_policy_alloc(&ctx, uctx, GFP_KERNEL);
 			if (err)
 				return err;
 		}
@@ -1933,7 +1933,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		if (rt) {
 			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
 
-			err = security_xfrm_policy_alloc(&ctx, uctx);
+			err = security_xfrm_policy_alloc(&ctx, uctx, GFP_KERNEL);
 			if (err)
 				return err;
 		}
diff --git a/security/capability.c b/security/capability.c
index 8b4f24ae4338..21e2b9cae685 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -757,7 +757,8 @@ static void cap_skb_owned_by(struct sk_buff *skb, struct sock *sk)
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 static int cap_xfrm_policy_alloc_security(struct xfrm_sec_ctx **ctxp,
-					  struct xfrm_user_sec_ctx *sec_ctx)
+					  struct xfrm_user_sec_ctx *sec_ctx,
+					  gfp_t gfp)
 {
 	return 0;
 }
diff --git a/security/security.c b/security/security.c
index 15b6928592ef..919cad93ac82 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1317,9 +1317,11 @@ void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 
-int security_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp, struct xfrm_user_sec_ctx *sec_ctx)
+int security_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp,
+			       struct xfrm_user_sec_ctx *sec_ctx,
+			       gfp_t gfp)
 {
-	return security_ops->xfrm_policy_alloc_security(ctxp, sec_ctx);
+	return security_ops->xfrm_policy_alloc_security(ctxp, sec_ctx, gfp);
 }
 EXPORT_SYMBOL(security_xfrm_policy_alloc);
 
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 48c3cc94c168..9f0584710c85 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -10,7 +10,8 @@
 #include <net/flow.h>
 
 int selinux_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp,
-			      struct xfrm_user_sec_ctx *uctx);
+			      struct xfrm_user_sec_ctx *uctx,
+			      gfp_t gfp);
 int selinux_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx,
 			      struct xfrm_sec_ctx **new_ctxp);
 void selinux_xfrm_policy_free(struct xfrm_sec_ctx *ctx);
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index 0462cb3ff0a7..7ae773f4fe38 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -78,7 +78,8 @@ static inline int selinux_authorizable_xfrm(struct xfrm_state *x)
  * xfrm_user_sec_ctx context.
  */
 static int selinux_xfrm_alloc_user(struct xfrm_sec_ctx **ctxp,
-				   struct xfrm_user_sec_ctx *uctx)
+				   struct xfrm_user_sec_ctx *uctx,
+				   gfp_t gfp)
 {
 	int rc;
 	const struct task_security_struct *tsec = current_security();
@@ -94,7 +95,7 @@ static int selinux_xfrm_alloc_user(struct xfrm_sec_ctx **ctxp,
 	if (str_len >= PAGE_SIZE)
 		return -ENOMEM;
 
-	ctx = kmalloc(sizeof(*ctx) + str_len + 1, GFP_KERNEL);
+	ctx = kmalloc(sizeof(*ctx) + str_len + 1, gfp);
 	if (!ctx)
 		return -ENOMEM;
 
@@ -282,9 +283,10 @@ int selinux_xfrm_skb_sid(struct sk_buff *skb, u32 *sid)
  * LSM hook implementation that allocs and transfers uctx spec to xfrm_policy.
  */
 int selinux_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp,
-			      struct xfrm_user_sec_ctx *uctx)
+			      struct xfrm_user_sec_ctx *uctx,
+			      gfp_t gfp)
 {
-	return selinux_xfrm_alloc_user(ctxp, uctx);
+	return selinux_xfrm_alloc_user(ctxp, uctx, gfp);
 }
 
 /*
@@ -332,7 +334,7 @@ int selinux_xfrm_policy_delete(struct xfrm_sec_ctx *ctx)
 int selinux_xfrm_state_alloc(struct xfrm_state *x,
 			     struct xfrm_user_sec_ctx *uctx)
 {
-	return selinux_xfrm_alloc_user(&x->security, uctx);
+	return selinux_xfrm_alloc_user(&x->security, uctx, GFP_KERNEL);
 }
 
 /*
-- 
1.8.5.3

