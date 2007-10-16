From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/12] [IPSEC]: Move type and mode map into xfrm_state.c
Date: Tue, 16 Oct 2007 22:33:14 +0800
Message-ID: <E1IhnTu-0003Gn-00@gondolin.me.apana.org.au>
References: <20071016141843.GA11956@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3008 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932937AbXJPOxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:53:53 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1Ihnnn-0001GY-IY
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 00:53:48 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move type and mode map into xfrm_state.c

The type and mode maps are only used by SAs, not policies.  So it makes
sense to move them from xfrm_policy.c into xfrm_state.c.  This alos allows
us to mark xfrm_get_type/xfrm_put_type/xfrm_get_mode/xfrm_put_mode as
static.

The only other change I've made in the move is to get rid of the casts
on the request_module call for types.  They're unnecessary because C
will promote them to ints anyway.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h     |    8 --
 net/xfrm/xfrm_policy.c |  173 -------------------------------------------------
 net/xfrm/xfrm_state.c  |  170 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 172 insertions(+), 179 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d8974ca..7f156a0 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -228,8 +228,6 @@ struct xfrm_type;
 struct xfrm_dst;
 struct xfrm_policy_afinfo {
 	unsigned short		family;
-	struct xfrm_type	*type_map[IPPROTO_MAX];
-	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
 	struct dst_ops		*dst_ops;
 	void			(*garbage_collect)(void);
 	int			(*dst_lookup)(struct xfrm_dst **dst, struct flowi *fl);
@@ -256,6 +254,8 @@ extern int __xfrm_state_delete(struct xfrm_state *x);
 
 struct xfrm_state_afinfo {
 	unsigned short		family;
+	struct xfrm_type	*type_map[IPPROTO_MAX];
+	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
 	int			(*init_flags)(struct xfrm_state *x);
 	void			(*init_tempsel)(struct xfrm_state *x, struct flowi *fl,
 						struct xfrm_tmpl *tmpl,
@@ -295,8 +295,6 @@ struct xfrm_type
 
 extern int xfrm_register_type(struct xfrm_type *type, unsigned short family);
 extern int xfrm_unregister_type(struct xfrm_type *type, unsigned short family);
-extern struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family);
-extern void xfrm_put_type(struct xfrm_type *type);
 
 struct xfrm_mode {
 	int (*input)(struct xfrm_state *x, struct sk_buff *skb);
@@ -320,8 +318,6 @@ struct xfrm_mode {
 
 extern int xfrm_register_mode(struct xfrm_mode *mode, int family);
 extern int xfrm_unregister_mode(struct xfrm_mode *mode, int family);
-extern struct xfrm_mode *xfrm_get_mode(unsigned int encap, int family);
-extern void xfrm_put_mode(struct xfrm_mode *mode);
 
 struct xfrm_tmpl
 {
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index af27c19..ca24c90 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -49,8 +49,6 @@ static DEFINE_SPINLOCK(xfrm_policy_gc_lock);
 
 static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
 static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
-static struct xfrm_policy_afinfo *xfrm_policy_lock_afinfo(unsigned int family);
-static void xfrm_policy_unlock_afinfo(struct xfrm_policy_afinfo *afinfo);
 
 static inline int
 __xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
@@ -86,72 +84,6 @@ int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
 	return 0;
 }
 
-int xfrm_register_type(struct xfrm_type *type, unsigned short family)
-{
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_lock_afinfo(family);
-	struct xfrm_type **typemap;
-	int err = 0;
-
-	if (unlikely(afinfo == NULL))
-		return -EAFNOSUPPORT;
-	typemap = afinfo->type_map;
-
-	if (likely(typemap[type->proto] == NULL))
-		typemap[type->proto] = type;
-	else
-		err = -EEXIST;
-	xfrm_policy_unlock_afinfo(afinfo);
-	return err;
-}
-EXPORT_SYMBOL(xfrm_register_type);
-
-int xfrm_unregister_type(struct xfrm_type *type, unsigned short family)
-{
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_lock_afinfo(family);
-	struct xfrm_type **typemap;
-	int err = 0;
-
-	if (unlikely(afinfo == NULL))
-		return -EAFNOSUPPORT;
-	typemap = afinfo->type_map;
-
-	if (unlikely(typemap[type->proto] != type))
-		err = -ENOENT;
-	else
-		typemap[type->proto] = NULL;
-	xfrm_policy_unlock_afinfo(afinfo);
-	return err;
-}
-EXPORT_SYMBOL(xfrm_unregister_type);
-
-struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family)
-{
-	struct xfrm_policy_afinfo *afinfo;
-	struct xfrm_type **typemap;
-	struct xfrm_type *type;
-	int modload_attempted = 0;
-
-retry:
-	afinfo = xfrm_policy_get_afinfo(family);
-	if (unlikely(afinfo == NULL))
-		return NULL;
-	typemap = afinfo->type_map;
-
-	type = typemap[proto];
-	if (unlikely(type && !try_module_get(type->owner)))
-		type = NULL;
-	if (!type && !modload_attempted) {
-		xfrm_policy_put_afinfo(afinfo);
-		request_module("xfrm-type-%d-%d",
-			       (int) family, (int) proto);
-		modload_attempted = 1;
-		goto retry;
-	}
-
-	xfrm_policy_put_afinfo(afinfo);
-	return type;
-}
-
 int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl,
 		    unsigned short family)
 {
@@ -170,94 +102,6 @@ int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl,
 }
 EXPORT_SYMBOL(xfrm_dst_lookup);
 
-void xfrm_put_type(struct xfrm_type *type)
-{
-	module_put(type->owner);
-}
-
-int xfrm_register_mode(struct xfrm_mode *mode, int family)
-{
-	struct xfrm_policy_afinfo *afinfo;
-	struct xfrm_mode **modemap;
-	int err;
-
-	if (unlikely(mode->encap >= XFRM_MODE_MAX))
-		return -EINVAL;
-
-	afinfo = xfrm_policy_lock_afinfo(family);
-	if (unlikely(afinfo == NULL))
-		return -EAFNOSUPPORT;
-
-	err = -EEXIST;
-	modemap = afinfo->mode_map;
-	if (likely(modemap[mode->encap] == NULL)) {
-		modemap[mode->encap] = mode;
-		err = 0;
-	}
-
-	xfrm_policy_unlock_afinfo(afinfo);
-	return err;
-}
-EXPORT_SYMBOL(xfrm_register_mode);
-
-int xfrm_unregister_mode(struct xfrm_mode *mode, int family)
-{
-	struct xfrm_policy_afinfo *afinfo;
-	struct xfrm_mode **modemap;
-	int err;
-
-	if (unlikely(mode->encap >= XFRM_MODE_MAX))
-		return -EINVAL;
-
-	afinfo = xfrm_policy_lock_afinfo(family);
-	if (unlikely(afinfo == NULL))
-		return -EAFNOSUPPORT;
-
-	err = -ENOENT;
-	modemap = afinfo->mode_map;
-	if (likely(modemap[mode->encap] == mode)) {
-		modemap[mode->encap] = NULL;
-		err = 0;
-	}
-
-	xfrm_policy_unlock_afinfo(afinfo);
-	return err;
-}
-EXPORT_SYMBOL(xfrm_unregister_mode);
-
-struct xfrm_mode *xfrm_get_mode(unsigned int encap, int family)
-{
-	struct xfrm_policy_afinfo *afinfo;
-	struct xfrm_mode *mode;
-	int modload_attempted = 0;
-
-	if (unlikely(encap >= XFRM_MODE_MAX))
-		return NULL;
-
-retry:
-	afinfo = xfrm_policy_get_afinfo(family);
-	if (unlikely(afinfo == NULL))
-		return NULL;
-
-	mode = afinfo->mode_map[encap];
-	if (unlikely(mode && !try_module_get(mode->owner)))
-		mode = NULL;
-	if (!mode && !modload_attempted) {
-		xfrm_policy_put_afinfo(afinfo);
-		request_module("xfrm-mode-%d-%d", family, encap);
-		modload_attempted = 1;
-		goto retry;
-	}
-
-	xfrm_policy_put_afinfo(afinfo);
-	return mode;
-}
-
-void xfrm_put_mode(struct xfrm_mode *mode)
-{
-	module_put(mode->owner);
-}
-
 static inline unsigned long make_jiffies(long secs)
 {
 	if (secs >= (MAX_SCHEDULE_TIMEOUT-1)/HZ)
@@ -2213,23 +2057,6 @@ static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo)
 	read_unlock(&xfrm_policy_afinfo_lock);
 }
 
-static struct xfrm_policy_afinfo *xfrm_policy_lock_afinfo(unsigned int family)
-{
-	struct xfrm_policy_afinfo *afinfo;
-	if (unlikely(family >= NPROTO))
-		return NULL;
-	write_lock_bh(&xfrm_policy_afinfo_lock);
-	afinfo = xfrm_policy_afinfo[family];
-	if (unlikely(!afinfo))
-		write_unlock_bh(&xfrm_policy_afinfo_lock);
-	return afinfo;
-}
-
-static void xfrm_policy_unlock_afinfo(struct xfrm_policy_afinfo *afinfo)
-{
-	write_unlock_bh(&xfrm_policy_afinfo_lock);
-}
-
 static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 344f0a6..dc438f2 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -187,6 +187,176 @@ int __xfrm_state_delete(struct xfrm_state *x);
 int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol);
 void km_state_expired(struct xfrm_state *x, int hard, u32 pid);
 
+static struct xfrm_state_afinfo *xfrm_state_lock_afinfo(unsigned int family)
+{
+	struct xfrm_state_afinfo *afinfo;
+	if (unlikely(family >= NPROTO))
+		return NULL;
+	write_lock_bh(&xfrm_state_afinfo_lock);
+	afinfo = xfrm_state_afinfo[family];
+	if (unlikely(!afinfo))
+		write_unlock_bh(&xfrm_state_afinfo_lock);
+	return afinfo;
+}
+
+static void xfrm_state_unlock_afinfo(struct xfrm_state_afinfo *afinfo)
+{
+	write_unlock_bh(&xfrm_state_afinfo_lock);
+}
+
+int xfrm_register_type(struct xfrm_type *type, unsigned short family)
+{
+	struct xfrm_state_afinfo *afinfo = xfrm_state_lock_afinfo(family);
+	struct xfrm_type **typemap;
+	int err = 0;
+
+	if (unlikely(afinfo == NULL))
+		return -EAFNOSUPPORT;
+	typemap = afinfo->type_map;
+
+	if (likely(typemap[type->proto] == NULL))
+		typemap[type->proto] = type;
+	else
+		err = -EEXIST;
+	xfrm_state_unlock_afinfo(afinfo);
+	return err;
+}
+EXPORT_SYMBOL(xfrm_register_type);
+
+int xfrm_unregister_type(struct xfrm_type *type, unsigned short family)
+{
+	struct xfrm_state_afinfo *afinfo = xfrm_state_lock_afinfo(family);
+	struct xfrm_type **typemap;
+	int err = 0;
+
+	if (unlikely(afinfo == NULL))
+		return -EAFNOSUPPORT;
+	typemap = afinfo->type_map;
+
+	if (unlikely(typemap[type->proto] != type))
+		err = -ENOENT;
+	else
+		typemap[type->proto] = NULL;
+	xfrm_state_unlock_afinfo(afinfo);
+	return err;
+}
+EXPORT_SYMBOL(xfrm_unregister_type);
+
+static struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family)
+{
+	struct xfrm_state_afinfo *afinfo;
+	struct xfrm_type **typemap;
+	struct xfrm_type *type;
+	int modload_attempted = 0;
+
+retry:
+	afinfo = xfrm_state_get_afinfo(family);
+	if (unlikely(afinfo == NULL))
+		return NULL;
+	typemap = afinfo->type_map;
+
+	type = typemap[proto];
+	if (unlikely(type && !try_module_get(type->owner)))
+		type = NULL;
+	if (!type && !modload_attempted) {
+		xfrm_state_put_afinfo(afinfo);
+		request_module("xfrm-type-%d-%d", family, proto);
+		modload_attempted = 1;
+		goto retry;
+	}
+
+	xfrm_state_put_afinfo(afinfo);
+	return type;
+}
+
+static void xfrm_put_type(struct xfrm_type *type)
+{
+	module_put(type->owner);
+}
+
+int xfrm_register_mode(struct xfrm_mode *mode, int family)
+{
+	struct xfrm_state_afinfo *afinfo;
+	struct xfrm_mode **modemap;
+	int err;
+
+	if (unlikely(mode->encap >= XFRM_MODE_MAX))
+		return -EINVAL;
+
+	afinfo = xfrm_state_lock_afinfo(family);
+	if (unlikely(afinfo == NULL))
+		return -EAFNOSUPPORT;
+
+	err = -EEXIST;
+	modemap = afinfo->mode_map;
+	if (likely(modemap[mode->encap] == NULL)) {
+		modemap[mode->encap] = mode;
+		err = 0;
+	}
+
+	xfrm_state_unlock_afinfo(afinfo);
+	return err;
+}
+EXPORT_SYMBOL(xfrm_register_mode);
+
+int xfrm_unregister_mode(struct xfrm_mode *mode, int family)
+{
+	struct xfrm_state_afinfo *afinfo;
+	struct xfrm_mode **modemap;
+	int err;
+
+	if (unlikely(mode->encap >= XFRM_MODE_MAX))
+		return -EINVAL;
+
+	afinfo = xfrm_state_lock_afinfo(family);
+	if (unlikely(afinfo == NULL))
+		return -EAFNOSUPPORT;
+
+	err = -ENOENT;
+	modemap = afinfo->mode_map;
+	if (likely(modemap[mode->encap] == mode)) {
+		modemap[mode->encap] = NULL;
+		err = 0;
+	}
+
+	xfrm_state_unlock_afinfo(afinfo);
+	return err;
+}
+EXPORT_SYMBOL(xfrm_unregister_mode);
+
+static struct xfrm_mode *xfrm_get_mode(unsigned int encap, int family)
+{
+	struct xfrm_state_afinfo *afinfo;
+	struct xfrm_mode *mode;
+	int modload_attempted = 0;
+
+	if (unlikely(encap >= XFRM_MODE_MAX))
+		return NULL;
+
+retry:
+	afinfo = xfrm_state_get_afinfo(family);
+	if (unlikely(afinfo == NULL))
+		return NULL;
+
+	mode = afinfo->mode_map[encap];
+	if (unlikely(mode && !try_module_get(mode->owner)))
+		mode = NULL;
+	if (!mode && !modload_attempted) {
+		xfrm_state_put_afinfo(afinfo);
+		request_module("xfrm-mode-%d-%d", family, encap);
+		modload_attempted = 1;
+		goto retry;
+	}
+
+	xfrm_state_put_afinfo(afinfo);
+	return mode;
+}
+
+static void xfrm_put_mode(struct xfrm_mode *mode)
+{
+	module_put(mode->owner);
+}
+
 static void xfrm_state_gc_destroy(struct xfrm_state *x)
 {
 	del_timer_sync(&x->timer);
