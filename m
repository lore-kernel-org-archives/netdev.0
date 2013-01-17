From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 3/2] xfrm: use separated locks to protect pointers of struct xfrm_state_afinfo
Date: Thu, 17 Jan 2013 16:34:11 +0800
Message-ID: <1358411651-3579-1-git-send-email-amwang@redhat.com>
References: <1358323506-19571-2-git-send-email-amwang@redhat.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932144Ab3AQIf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 03:35:27 -0500
In-Reply-To: <1358323506-19571-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(On top of my previous RCU convert patches)

afinfo->type_map and afinfo->mode_map deserve separated locks,
they are different things.

We should just take RCU read lock to protect afinfo itself,
but not for the inner pointers.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b40baf7..727e357 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -168,57 +168,45 @@ int __xfrm_state_delete(struct xfrm_state *x);
 int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol);
 void km_state_expired(struct xfrm_state *x, int hard, u32 portid);
 
-static struct xfrm_state_afinfo *xfrm_state_lock_afinfo(unsigned int family)
-{
-	struct xfrm_state_afinfo *afinfo;
-	if (unlikely(family >= NPROTO))
-		return NULL;
-	spin_lock_bh(&xfrm_state_afinfo_lock);
-	afinfo = xfrm_state_afinfo[family];
-	if (unlikely(!afinfo))
-		spin_unlock_bh(&xfrm_state_afinfo_lock);
-	return afinfo;
-}
-
-static void xfrm_state_unlock_afinfo(struct xfrm_state_afinfo *afinfo)
-{
-	spin_unlock_bh(&xfrm_state_afinfo_lock);
-}
-
+static DEFINE_SPINLOCK(xfrm_type_lock);
 int xfrm_register_type(const struct xfrm_type *type, unsigned short family)
 {
-	struct xfrm_state_afinfo *afinfo = xfrm_state_lock_afinfo(family);
+	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
 	const struct xfrm_type **typemap;
 	int err = 0;
 
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 	typemap = afinfo->type_map;
+	spin_lock_bh(&xfrm_type_lock);
 
 	if (likely(typemap[type->proto] == NULL))
 		typemap[type->proto] = type;
 	else
 		err = -EEXIST;
-	xfrm_state_unlock_afinfo(afinfo);
+	spin_unlock_bh(&xfrm_type_lock);
+	xfrm_state_put_afinfo(afinfo);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_register_type);
 
 int xfrm_unregister_type(const struct xfrm_type *type, unsigned short family)
 {
-	struct xfrm_state_afinfo *afinfo = xfrm_state_lock_afinfo(family);
+	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
 	const struct xfrm_type **typemap;
 	int err = 0;
 
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 	typemap = afinfo->type_map;
+	spin_lock_bh(&xfrm_type_lock);
 
 	if (unlikely(typemap[type->proto] != type))
 		err = -ENOENT;
 	else
 		typemap[type->proto] = NULL;
-	xfrm_state_unlock_afinfo(afinfo);
+	spin_unlock_bh(&xfrm_type_lock);
+	xfrm_state_put_afinfo(afinfo);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_unregister_type);
@@ -255,6 +243,7 @@ static void xfrm_put_type(const struct xfrm_type *type)
 	module_put(type->owner);
 }
 
+static DEFINE_SPINLOCK(xfrm_mode_lock);
 int xfrm_register_mode(struct xfrm_mode *mode, int family)
 {
 	struct xfrm_state_afinfo *afinfo;
@@ -264,12 +253,13 @@ int xfrm_register_mode(struct xfrm_mode *mode, int family)
 	if (unlikely(mode->encap >= XFRM_MODE_MAX))
 		return -EINVAL;
 
-	afinfo = xfrm_state_lock_afinfo(family);
+	afinfo = xfrm_state_get_afinfo(family);
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 
 	err = -EEXIST;
 	modemap = afinfo->mode_map;
+	spin_lock_bh(&xfrm_mode_lock);
 	if (modemap[mode->encap])
 		goto out;
 
@@ -282,7 +272,8 @@ int xfrm_register_mode(struct xfrm_mode *mode, int family)
 	err = 0;
 
 out:
-	xfrm_state_unlock_afinfo(afinfo);
+	spin_unlock_bh(&xfrm_mode_lock);
+	xfrm_state_put_afinfo(afinfo);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_register_mode);
@@ -296,19 +287,21 @@ int xfrm_unregister_mode(struct xfrm_mode *mode, int family)
 	if (unlikely(mode->encap >= XFRM_MODE_MAX))
 		return -EINVAL;
 
-	afinfo = xfrm_state_lock_afinfo(family);
+	afinfo = xfrm_state_get_afinfo(family);
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 
 	err = -ENOENT;
 	modemap = afinfo->mode_map;
+	spin_lock_bh(&xfrm_mode_lock);
 	if (likely(modemap[mode->encap] == mode)) {
 		modemap[mode->encap] = NULL;
 		module_put(mode->afinfo->owner);
 		err = 0;
 	}
 
-	xfrm_state_unlock_afinfo(afinfo);
+	spin_unlock_bh(&xfrm_mode_lock);
+	xfrm_state_put_afinfo(afinfo);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_unregister_mode);
