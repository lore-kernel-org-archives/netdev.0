From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] selinux: add gfp argument to security_xfrm_policy_alloc and fix callers
Date: Tue, 18 Mar 2014 08:43:03 +0100
Message-ID: <1395128583-26274-3-git-send-email-steffen.klassert@secunet.com>
References: <1395128583-26274-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54083 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752902AbaCRHnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:43:18 -0400
In-Reply-To: <1395128583-26274-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>

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

Now adding a gfp argument to selinux_xfrm_alloc_user requires us to also
add it to security_context_to_sid which is used inside and prior to this
patch did only GFP_KERNEL allocation. So add gfp argument to
security_context_to_sid and adjust all of its callers as well.

CC: Paul Moore <paul@paul-moore.com>
CC: Dave Jones <davej@redhat.com>
CC: Steffen Klassert <steffen.klassert@secunet.com>
CC: Fan Du <fan.du@windriver.com>
CC: David S. Miller <davem@davemloft.net>
CC: LSM list <linux-security-module@vger.kernel.org>
CC: SELinux list <selinux@tycho.nsa.gov>

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
Acked-by: Paul Moore <paul@paul-moore.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/security.h            |   10 +++++++---
 net/key/af_key.c                    |    6 +++---
 net/xfrm/xfrm_user.c                |    6 +++---
 security/capability.c               |    3 ++-
 security/security.c                 |    6 ++++--
 security/selinux/hooks.c            |   13 +++++++------
 security/selinux/include/security.h |    2 +-
 security/selinux/include/xfrm.h     |    3 ++-
 security/selinux/selinuxfs.c        |   28 ++++++++++++++++++----------
 security/selinux/ss/services.c      |    6 ++++--
 security/selinux/xfrm.c             |   14 ++++++++------
 11 files changed, 59 insertions(+), 38 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 5623a7f..2fc42d1 100644
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
index 1526023..7932697 100644
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
index c274179..2f7ddc3 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1221,7 +1221,7 @@ static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct nlattr **attrs
 		return 0;
 
 	uctx = nla_data(rt);
-	return security_xfrm_policy_alloc(&pol->security, uctx);
+	return security_xfrm_policy_alloc(&pol->security, uctx, GFP_KERNEL);
 }
 
 static void copy_templates(struct xfrm_policy *xp, struct xfrm_user_tmpl *ut,
@@ -1626,7 +1626,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		if (rt) {
 			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
 
-			err = security_xfrm_policy_alloc(&ctx, uctx);
+			err = security_xfrm_policy_alloc(&ctx, uctx, GFP_KERNEL);
 			if (err)
 				return err;
 		}
@@ -1928,7 +1928,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		if (rt) {
 			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
 
-			err = security_xfrm_policy_alloc(&ctx, uctx);
+			err = security_xfrm_policy_alloc(&ctx, uctx, GFP_KERNEL);
 			if (err)
 				return err;
 		}
diff --git a/security/capability.c b/security/capability.c
index 8b4f24a..21e2b9c 100644
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
index 15b6928..919cad9 100644
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
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 4b34847..b332e2c 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -668,7 +668,7 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 		if (flags[i] == SBLABEL_MNT)
 			continue;
 		rc = security_context_to_sid(mount_options[i],
-					     strlen(mount_options[i]), &sid);
+					     strlen(mount_options[i]), &sid, GFP_KERNEL);
 		if (rc) {
 			printk(KERN_WARNING "SELinux: security_context_to_sid"
 			       "(%s) failed for (dev %s, type %s) errno=%d\n",
@@ -2489,7 +2489,8 @@ static int selinux_sb_remount(struct super_block *sb, void *data)
 		if (flags[i] == SBLABEL_MNT)
 			continue;
 		len = strlen(mount_options[i]);
-		rc = security_context_to_sid(mount_options[i], len, &sid);
+		rc = security_context_to_sid(mount_options[i], len, &sid,
+					     GFP_KERNEL);
 		if (rc) {
 			printk(KERN_WARNING "SELinux: security_context_to_sid"
 			       "(%s) failed for (dev %s, type %s) errno=%d\n",
@@ -2893,7 +2894,7 @@ static int selinux_inode_setxattr(struct dentry *dentry, const char *name,
 	if (rc)
 		return rc;
 
-	rc = security_context_to_sid(value, size, &newsid);
+	rc = security_context_to_sid(value, size, &newsid, GFP_KERNEL);
 	if (rc == -EINVAL) {
 		if (!capable(CAP_MAC_ADMIN)) {
 			struct audit_buffer *ab;
@@ -3050,7 +3051,7 @@ static int selinux_inode_setsecurity(struct inode *inode, const char *name,
 	if (!value || !size)
 		return -EACCES;
 
-	rc = security_context_to_sid((void *)value, size, &newsid);
+	rc = security_context_to_sid((void *)value, size, &newsid, GFP_KERNEL);
 	if (rc)
 		return rc;
 
@@ -5529,7 +5530,7 @@ static int selinux_setprocattr(struct task_struct *p,
 			str[size-1] = 0;
 			size--;
 		}
-		error = security_context_to_sid(value, size, &sid);
+		error = security_context_to_sid(value, size, &sid, GFP_KERNEL);
 		if (error == -EINVAL && !strcmp(name, "fscreate")) {
 			if (!capable(CAP_MAC_ADMIN)) {
 				struct audit_buffer *ab;
@@ -5638,7 +5639,7 @@ static int selinux_secid_to_secctx(u32 secid, char **secdata, u32 *seclen)
 
 static int selinux_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid)
 {
-	return security_context_to_sid(secdata, seclen, secid);
+	return security_context_to_sid(secdata, seclen, secid, GFP_KERNEL);
 }
 
 static void selinux_release_secctx(char *secdata, u32 seclen)
diff --git a/security/selinux/include/security.h b/security/selinux/include/security.h
index 8ed8daf..ce7852c 100644
--- a/security/selinux/include/security.h
+++ b/security/selinux/include/security.h
@@ -134,7 +134,7 @@ int security_sid_to_context(u32 sid, char **scontext,
 int security_sid_to_context_force(u32 sid, char **scontext, u32 *scontext_len);
 
 int security_context_to_sid(const char *scontext, u32 scontext_len,
-	u32 *out_sid);
+			    u32 *out_sid, gfp_t gfp);
 
 int security_context_to_sid_default(const char *scontext, u32 scontext_len,
 				    u32 *out_sid, u32 def_sid, gfp_t gfp_flags);
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 48c3cc9..9f05847 100644
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
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index 5122aff..d60c0ee 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -576,7 +576,7 @@ static ssize_t sel_write_context(struct file *file, char *buf, size_t size)
 	if (length)
 		goto out;
 
-	length = security_context_to_sid(buf, size, &sid);
+	length = security_context_to_sid(buf, size, &sid, GFP_KERNEL);
 	if (length)
 		goto out;
 
@@ -731,11 +731,13 @@ static ssize_t sel_write_access(struct file *file, char *buf, size_t size)
 	if (sscanf(buf, "%s %s %hu", scon, tcon, &tclass) != 3)
 		goto out;
 
-	length = security_context_to_sid(scon, strlen(scon) + 1, &ssid);
+	length = security_context_to_sid(scon, strlen(scon) + 1, &ssid,
+					 GFP_KERNEL);
 	if (length)
 		goto out;
 
-	length = security_context_to_sid(tcon, strlen(tcon) + 1, &tsid);
+	length = security_context_to_sid(tcon, strlen(tcon) + 1, &tsid,
+					 GFP_KERNEL);
 	if (length)
 		goto out;
 
@@ -817,11 +819,13 @@ static ssize_t sel_write_create(struct file *file, char *buf, size_t size)
 		objname = namebuf;
 	}
 
-	length = security_context_to_sid(scon, strlen(scon) + 1, &ssid);
+	length = security_context_to_sid(scon, strlen(scon) + 1, &ssid,
+					 GFP_KERNEL);
 	if (length)
 		goto out;
 
-	length = security_context_to_sid(tcon, strlen(tcon) + 1, &tsid);
+	length = security_context_to_sid(tcon, strlen(tcon) + 1, &tsid,
+					 GFP_KERNEL);
 	if (length)
 		goto out;
 
@@ -878,11 +882,13 @@ static ssize_t sel_write_relabel(struct file *file, char *buf, size_t size)
 	if (sscanf(buf, "%s %s %hu", scon, tcon, &tclass) != 3)
 		goto out;
 
-	length = security_context_to_sid(scon, strlen(scon) + 1, &ssid);
+	length = security_context_to_sid(scon, strlen(scon) + 1, &ssid,
+					 GFP_KERNEL);
 	if (length)
 		goto out;
 
-	length = security_context_to_sid(tcon, strlen(tcon) + 1, &tsid);
+	length = security_context_to_sid(tcon, strlen(tcon) + 1, &tsid,
+					 GFP_KERNEL);
 	if (length)
 		goto out;
 
@@ -934,7 +940,7 @@ static ssize_t sel_write_user(struct file *file, char *buf, size_t size)
 	if (sscanf(buf, "%s %s", con, user) != 2)
 		goto out;
 
-	length = security_context_to_sid(con, strlen(con) + 1, &sid);
+	length = security_context_to_sid(con, strlen(con) + 1, &sid, GFP_KERNEL);
 	if (length)
 		goto out;
 
@@ -994,11 +1000,13 @@ static ssize_t sel_write_member(struct file *file, char *buf, size_t size)
 	if (sscanf(buf, "%s %s %hu", scon, tcon, &tclass) != 3)
 		goto out;
 
-	length = security_context_to_sid(scon, strlen(scon) + 1, &ssid);
+	length = security_context_to_sid(scon, strlen(scon) + 1, &ssid,
+					 GFP_KERNEL);
 	if (length)
 		goto out;
 
-	length = security_context_to_sid(tcon, strlen(tcon) + 1, &tsid);
+	length = security_context_to_sid(tcon, strlen(tcon) + 1, &tsid,
+					 GFP_KERNEL);
 	if (length)
 		goto out;
 
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index 5d0144e..4bca494 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -1289,16 +1289,18 @@ out:
  * @scontext: security context
  * @scontext_len: length in bytes
  * @sid: security identifier, SID
+ * @gfp: context for the allocation
  *
  * Obtains a SID associated with the security context that
  * has the string representation specified by @scontext.
  * Returns -%EINVAL if the context is invalid, -%ENOMEM if insufficient
  * memory is available, or 0 on success.
  */
-int security_context_to_sid(const char *scontext, u32 scontext_len, u32 *sid)
+int security_context_to_sid(const char *scontext, u32 scontext_len, u32 *sid,
+			    gfp_t gfp)
 {
 	return security_context_to_sid_core(scontext, scontext_len,
-					    sid, SECSID_NULL, GFP_KERNEL, 0);
+					    sid, SECSID_NULL, gfp, 0);
 }
 
 /**
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index 0462cb3..98b0426 100644
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
 
@@ -103,7 +104,7 @@ static int selinux_xfrm_alloc_user(struct xfrm_sec_ctx **ctxp,
 	ctx->ctx_len = str_len;
 	memcpy(ctx->ctx_str, &uctx[1], str_len);
 	ctx->ctx_str[str_len] = '\0';
-	rc = security_context_to_sid(ctx->ctx_str, str_len, &ctx->ctx_sid);
+	rc = security_context_to_sid(ctx->ctx_str, str_len, &ctx->ctx_sid, gfp);
 	if (rc)
 		goto err;
 
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
1.7.9.5
