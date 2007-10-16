From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 8/12] [IPSEC]: Store afinfo pointer in xfrm_mode
Date: Tue, 16 Oct 2007 22:33:16 +0800
Message-ID: <E1IhnTw-0003H8-00@gondolin.me.apana.org.au>
References: <20071016141843.GA11956@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3005 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932909AbXJPOxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:53:51 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1Ihnnl-0001GY-Vm
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 00:53:46 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Store afinfo pointer in xfrm_mode

It is convenient to have a pointer from xfrm_state to address-specific
functions such as the output function for a family.  Currently the
address-specific policy code calls out to the xfrm state code to get
those pointers when we could get it in an easier way via the state
itself.

This patch adds an xfrm_state_afinfo to xfrm_mode (since they're
address-specific) and changes the policy code to use it.  I've also
added an owner field to do reference counting on the module providing
the afinfo even though it isn't strictly necessary today since IPv6
can't be unloaded yet.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h      |    6 +++---
 net/ipv4/xfrm4_policy.c |   13 +------------
 net/ipv4/xfrm4_state.c  |    1 +
 net/ipv6/xfrm6_policy.c |   14 +-------------
 net/ipv6/xfrm6_state.c  |    1 +
 net/xfrm/xfrm_state.c   |   26 +++++++++++++++++---------
 6 files changed, 24 insertions(+), 37 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 7f156a0..a9e8247 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -253,7 +253,8 @@ extern void km_state_expired(struct xfrm_state *x, int hard, u32 pid);
 extern int __xfrm_state_delete(struct xfrm_state *x);
 
 struct xfrm_state_afinfo {
-	unsigned short		family;
+	unsigned int		family;
+	struct module		*owner;
 	struct xfrm_type	*type_map[IPPROTO_MAX];
 	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
 	int			(*init_flags)(struct xfrm_state *x);
@@ -267,8 +268,6 @@ struct xfrm_state_afinfo {
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
 extern int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo);
-extern struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family);
-extern void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
 
 extern void xfrm_state_delete_tunnel(struct xfrm_state *x);
 
@@ -312,6 +311,7 @@ struct xfrm_mode {
 	 */
 	int (*output)(struct xfrm_state *x,struct sk_buff *skb);
 
+	struct xfrm_state_afinfo *afinfo;
 	struct module *owner;
 	unsigned int encap;
 };
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 329825c..bd07a98 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -151,7 +151,6 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 	i = 0;
 	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
-		struct xfrm_state_afinfo *afinfo;
 		x->u.rt.fl = *fl;
 
 		dst_prev->xfrm = xfrm[i++];
@@ -169,17 +168,7 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		/* Copy neighbout for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
-		/* XXX: When IPv6 module can be unloaded, we should manage reference
-		 * to xfrm6_output in afinfo->output. Miyazawa
-		 * */
-		afinfo = xfrm_state_get_afinfo(dst_prev->xfrm->props.family);
-		if (!afinfo) {
-			dst = *dst_p;
-			err = -EAFNOSUPPORT;
-			goto error;
-		}
-		dst_prev->output = afinfo->output;
-		xfrm_state_put_afinfo(afinfo);
+		dst_prev->output = dst_prev->xfrm->mode->afinfo->output;
 		if (dst_prev->xfrm->props.family == AF_INET && rt->peer)
 			atomic_inc(&rt->peer->refcnt);
 		x->u.rt.peer = rt->peer;
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 93e2c06..13d54a1 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -49,6 +49,7 @@ __xfrm4_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 
 static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.family			= AF_INET,
+	.owner			= THIS_MODULE,
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
 	.output			= xfrm4_output,
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 15aa4c5..e473708 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -215,7 +215,6 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 	i = 0;
 	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
-		struct xfrm_state_afinfo *afinfo;
 
 		dst_prev->xfrm = xfrm[i++];
 		dst_prev->dev = rt->u.dst.dev;
@@ -232,18 +231,7 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		/* Copy neighbour for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
-		/* XXX: When IPv4 is implemented as module and can be unloaded,
-		 * we should manage reference to xfrm4_output in afinfo->output.
-		 * Miyazawa
-		 */
-		afinfo = xfrm_state_get_afinfo(dst_prev->xfrm->props.family);
-		if (!afinfo) {
-			dst = *dst_p;
-			goto error;
-		}
-
-		dst_prev->output = afinfo->output;
-		xfrm_state_put_afinfo(afinfo);
+		dst_prev->output = dst_prev->xfrm->mode->afinfo->output;
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
 		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index cdadb48..8bb9b08 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -168,6 +168,7 @@ __xfrm6_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n)
 
 static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.family			= AF_INET6,
+	.owner			= THIS_MODULE,
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.tmpl_sort		= __xfrm6_tmpl_sort,
 	.state_sort		= __xfrm6_state_sort,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index dc438f2..48b4a06 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -57,6 +57,9 @@ static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
 static unsigned int xfrm_state_num;
 static unsigned int xfrm_state_genid;
 
+static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
+static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
+
 static inline unsigned int xfrm_dst_hash(xfrm_address_t *daddr,
 					 xfrm_address_t *saddr,
 					 u32 reqid,
@@ -289,11 +292,18 @@ int xfrm_register_mode(struct xfrm_mode *mode, int family)
 
 	err = -EEXIST;
 	modemap = afinfo->mode_map;
-	if (likely(modemap[mode->encap] == NULL)) {
-		modemap[mode->encap] = mode;
-		err = 0;
-	}
+	if (modemap[mode->encap])
+		goto out;
 
+	err = -ENOENT;
+	if (!try_module_get(afinfo->owner))
+		goto out;
+
+	mode->afinfo = afinfo;
+	modemap[mode->encap] = mode;
+	err = 0;
+
+out:
 	xfrm_state_unlock_afinfo(afinfo);
 	return err;
 }
@@ -316,6 +326,7 @@ int xfrm_unregister_mode(struct xfrm_mode *mode, int family)
 	modemap = afinfo->mode_map;
 	if (likely(modemap[mode->encap] == mode)) {
 		modemap[mode->encap] = NULL;
+		module_put(mode->afinfo->owner);
 		err = 0;
 	}
 
@@ -1869,7 +1880,7 @@ int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo)
 }
 EXPORT_SYMBOL(xfrm_state_unregister_afinfo);
 
-struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family)
+static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family)
 {
 	struct xfrm_state_afinfo *afinfo;
 	if (unlikely(family >= NPROTO))
@@ -1881,14 +1892,11 @@ struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family)
 	return afinfo;
 }
 
-void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
+static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
 {
 	read_unlock(&xfrm_state_afinfo_lock);
 }
 
-EXPORT_SYMBOL(xfrm_state_get_afinfo);
-EXPORT_SYMBOL(xfrm_state_put_afinfo);
-
 /* Temporarily located here until net/xfrm/xfrm_tunnel.c is created */
 void xfrm_state_delete_tunnel(struct xfrm_state *x)
 {
