From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 7/8] xfrm: use separated locks to protect pointers of struct xfrm_state_afinfo
Date: Wed, 23 Jan 2013 09:19:03 +0100
Message-ID: <1358929144-17806-8-git-send-email-steffen.klassert@secunet.com>
References: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50747 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754329Ab3AWITh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 03:19:37 -0500
In-Reply-To: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

afinfo->type_map and afinfo->mode_map deserve separated locks,
they are different things.

We should just take RCU read lock to protect afinfo itself,
but not for the inner pointers.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |   43 ++++++++++++++++++-------------------------
 1 file changed, 18 insertions(+), 25 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 1522f19..0adae91 100644
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
-- 
1.7.9.5
