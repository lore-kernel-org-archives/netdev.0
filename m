From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 02/16] xfrm: Add a xfrm type offload.
Date: Thu, 20 Apr 2017 10:55:01 +0200
Message-ID: <1492678515-14347-3-git-send-email-steffen.klassert@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51562 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939519AbdDTI4M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:56:12 -0400
In-Reply-To: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We add a struct  xfrm_type_offload so that we have the offloaded
codepath separated to the non offloaded codepath. With this the
non offloade and the offloaded codepath can coexist.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h    | 28 +++++++++++++++-----
 net/xfrm/xfrm_state.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 95 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9e3dc7b..159342f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -222,6 +222,8 @@ struct xfrm_state {
 	struct xfrm_mode	*inner_mode_iaf;
 	struct xfrm_mode	*outer_mode;
 
+	const struct xfrm_type_offload	*type_offload;
+
 	/* Security context */
 	struct xfrm_sec_ctx	*security;
 
@@ -314,12 +316,14 @@ void km_state_expired(struct xfrm_state *x, int hard, u32 portid);
 int __xfrm_state_delete(struct xfrm_state *x);
 
 struct xfrm_state_afinfo {
-	unsigned int		family;
-	unsigned int		proto;
-	__be16			eth_proto;
-	struct module		*owner;
-	const struct xfrm_type	*type_map[IPPROTO_MAX];
-	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
+	unsigned int			family;
+	unsigned int			proto;
+	__be16				eth_proto;
+	struct module			*owner;
+	const struct xfrm_type		*type_map[IPPROTO_MAX];
+	const struct xfrm_type_offload	*type_offload_map[IPPROTO_MAX];
+	struct xfrm_mode		*mode_map[XFRM_MODE_MAX];
+
 	int			(*init_flags)(struct xfrm_state *x);
 	void			(*init_tempsel)(struct xfrm_selector *sel,
 						const struct flowi *fl);
@@ -380,6 +384,18 @@ struct xfrm_type {
 int xfrm_register_type(const struct xfrm_type *type, unsigned short family);
 int xfrm_unregister_type(const struct xfrm_type *type, unsigned short family);
 
+struct xfrm_type_offload {
+	char		*description;
+	struct module	*owner;
+	u8		proto;
+	void		(*encap)(struct xfrm_state *, struct sk_buff *pskb);
+	int		(*input_tail)(struct xfrm_state *x, struct sk_buff *skb);
+	int		(*xmit)(struct xfrm_state *, struct sk_buff *pskb, netdev_features_t features);
+};
+
+int xfrm_register_type_offload(const struct xfrm_type_offload *type, unsigned short family);
+int xfrm_unregister_type_offload(const struct xfrm_type_offload *type, unsigned short family);
+
 struct xfrm_mode {
 	/*
 	 * Remove encapsulation header.
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5a597db..47fefe9 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -251,6 +251,75 @@ static void xfrm_put_type(const struct xfrm_type *type)
 	module_put(type->owner);
 }
 
+static DEFINE_SPINLOCK(xfrm_type_offload_lock);
+int xfrm_register_type_offload(const struct xfrm_type_offload *type,
+			       unsigned short family)
+{
+	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
+	const struct xfrm_type_offload **typemap;
+	int err = 0;
+
+	if (unlikely(afinfo == NULL))
+		return -EAFNOSUPPORT;
+	typemap = afinfo->type_offload_map;
+	spin_lock_bh(&xfrm_type_offload_lock);
+
+	if (likely(typemap[type->proto] == NULL))
+		typemap[type->proto] = type;
+	else
+		err = -EEXIST;
+	spin_unlock_bh(&xfrm_type_offload_lock);
+	rcu_read_unlock();
+	return err;
+}
+EXPORT_SYMBOL(xfrm_register_type_offload);
+
+int xfrm_unregister_type_offload(const struct xfrm_type_offload *type,
+				 unsigned short family)
+{
+	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
+	const struct xfrm_type_offload **typemap;
+	int err = 0;
+
+	if (unlikely(afinfo == NULL))
+		return -EAFNOSUPPORT;
+	typemap = afinfo->type_offload_map;
+	spin_lock_bh(&xfrm_type_offload_lock);
+
+	if (unlikely(typemap[type->proto] != type))
+		err = -ENOENT;
+	else
+		typemap[type->proto] = NULL;
+	spin_unlock_bh(&xfrm_type_offload_lock);
+	rcu_read_unlock();
+	return err;
+}
+EXPORT_SYMBOL(xfrm_unregister_type_offload);
+
+static const struct xfrm_type_offload *xfrm_get_type_offload(u8 proto, unsigned short family)
+{
+	struct xfrm_state_afinfo *afinfo;
+	const struct xfrm_type_offload **typemap;
+	const struct xfrm_type_offload *type;
+
+	afinfo = xfrm_state_get_afinfo(family);
+	if (unlikely(afinfo == NULL))
+		return NULL;
+	typemap = afinfo->type_offload_map;
+
+	type = typemap[proto];
+	if ((type && !try_module_get(type->owner)))
+		type = NULL;
+
+	rcu_read_unlock();
+	return type;
+}
+
+static void xfrm_put_type_offload(const struct xfrm_type_offload *type)
+{
+	module_put(type->owner);
+}
+
 static DEFINE_SPINLOCK(xfrm_mode_lock);
 int xfrm_register_mode(struct xfrm_mode *mode, int family)
 {
@@ -365,6 +434,8 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
 		xfrm_put_mode(x->inner_mode_iaf);
 	if (x->outer_mode)
 		xfrm_put_mode(x->outer_mode);
+	if (x->type_offload)
+		xfrm_put_type_offload(x->type_offload);
 	if (x->type) {
 		x->type->destructor(x);
 		xfrm_put_type(x->type);
@@ -2077,6 +2148,8 @@ int __xfrm_init_state(struct xfrm_state *x, bool init_replay)
 	if (x->type == NULL)
 		goto error;
 
+	x->type_offload = xfrm_get_type_offload(x->id.proto, family);
+
 	err = x->type->init_state(x);
 	if (err)
 		goto error;
-- 
2.7.4
