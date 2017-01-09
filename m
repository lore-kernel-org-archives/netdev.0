From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 6/6] xfrm: remove xfrm_state_get_afinfo
Date: Mon,  9 Jan 2017 14:20:50 +0100
Message-ID: <1483968050-788-7-git-send-email-fw@strlen.de>
References: <1483968050-788-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:48784 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S940286AbdAINUw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 08:20:52 -0500
In-Reply-To: <1483968050-788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use xfrm_state_afinfo_get_rcu() everywhere, this also moves
rcu read (un)lock responsibility to the callers.

This avoids the conditional locking scheme we currently have.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/xfrm.h     |  1 -
 net/xfrm/xfrm_output.c |  3 +-
 net/xfrm/xfrm_state.c  | 97 +++++++++++++++++++++++++++++++-------------------
 3 files changed, 62 insertions(+), 39 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index c52197cf51dc..d81e153bfeee 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -342,7 +342,6 @@ struct xfrm_state_afinfo {
 
 int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
 int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo);
-struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
 struct xfrm_state_afinfo *xfrm_state_afinfo_get_rcu(unsigned int family);
 
 struct xfrm_input_afinfo {
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 8ba29fe58352..351efd207d88 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -245,7 +245,8 @@ void xfrm_local_error(struct sk_buff *skb, int mtu)
 	else
 		return;
 
-	afinfo = xfrm_state_get_afinfo(proto);
+	rcu_read_lock();
+	afinfo = xfrm_state_afinfo_get_rcu(proto);
 	if (afinfo)
 		afinfo->local_error(skb, mtu);
 	rcu_read_unlock();
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0245df063bd7..1a7f0c0ec3bd 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -178,12 +178,17 @@ void km_state_expired(struct xfrm_state *x, int hard, u32 portid);
 static DEFINE_SPINLOCK(xfrm_type_lock);
 int xfrm_register_type(const struct xfrm_type *type, unsigned short family)
 {
-	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
+	struct xfrm_state_afinfo *afinfo;
 	const struct xfrm_type **typemap;
 	int err = 0;
 
-	if (unlikely(afinfo == NULL))
+	rcu_read_lock();
+
+	afinfo = xfrm_state_afinfo_get_rcu(family);
+	if (!afinfo) {
+		rcu_read_unlock();
 		return -EAFNOSUPPORT;
+	}
 	typemap = afinfo->type_map;
 	spin_lock_bh(&xfrm_type_lock);
 
@@ -199,12 +204,17 @@ EXPORT_SYMBOL(xfrm_register_type);
 
 int xfrm_unregister_type(const struct xfrm_type *type, unsigned short family)
 {
-	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
+	struct xfrm_state_afinfo *afinfo;
 	const struct xfrm_type **typemap;
 	int err = 0;
 
-	if (unlikely(afinfo == NULL))
+	rcu_read_lock();
+
+	afinfo = xfrm_state_afinfo_get_rcu(family);
+	if (!afinfo) {
+		rcu_read_unlock();
 		return -EAFNOSUPPORT;
+	}
 	typemap = afinfo->type_map;
 	spin_lock_bh(&xfrm_type_lock);
 
@@ -226,9 +236,13 @@ static const struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family)
 	int modload_attempted = 0;
 
 retry:
-	afinfo = xfrm_state_get_afinfo(family);
-	if (unlikely(afinfo == NULL))
+	rcu_read_lock();
+	afinfo = xfrm_state_afinfo_get_rcu(family);
+	if (unlikely(!afinfo)) {
+		rcu_read_unlock();
 		return NULL;
+	}
+
 	typemap = afinfo->type_map;
 
 	type = READ_ONCE(typemap[proto]);
@@ -261,9 +275,12 @@ int xfrm_register_mode(struct xfrm_mode *mode, int family)
 	if (unlikely(mode->encap >= XFRM_MODE_MAX))
 		return -EINVAL;
 
-	afinfo = xfrm_state_get_afinfo(family);
-	if (unlikely(afinfo == NULL))
+	rcu_read_lock();
+	afinfo = xfrm_state_afinfo_get_rcu(family);
+	if (!afinfo) {
+		rcu_read_unlock();
 		return -EAFNOSUPPORT;
+	}
 
 	err = -EEXIST;
 	modemap = afinfo->mode_map;
@@ -295,9 +312,12 @@ int xfrm_unregister_mode(struct xfrm_mode *mode, int family)
 	if (unlikely(mode->encap >= XFRM_MODE_MAX))
 		return -EINVAL;
 
-	afinfo = xfrm_state_get_afinfo(family);
-	if (unlikely(afinfo == NULL))
+	rcu_read_lock();
+	afinfo = xfrm_state_afinfo_get_rcu(family);
+	if (!afinfo) {
+		rcu_read_unlock();
 		return -EAFNOSUPPORT;
+	}
 
 	err = -ENOENT;
 	modemap = afinfo->mode_map;
@@ -322,17 +342,21 @@ static struct xfrm_mode *xfrm_get_mode(unsigned int encap, int family)
 
 	if (unlikely(encap >= XFRM_MODE_MAX))
 		return NULL;
-
 retry:
-	afinfo = xfrm_state_get_afinfo(family);
-	if (unlikely(afinfo == NULL))
+	rcu_read_lock();
+
+	afinfo = xfrm_state_afinfo_get_rcu(family);
+	if (unlikely(!afinfo)) {
+		rcu_read_unlock();
 		return NULL;
+	}
 
 	mode = READ_ONCE(afinfo->mode_map[encap]);
 	if (unlikely(mode && !try_module_get(mode->owner)))
 		mode = NULL;
 
 	rcu_read_unlock();
+
 	if (!mode && !modload_attempted) {
 		request_module("xfrm-mode-%d-%d", family, encap);
 		modload_attempted = 1;
@@ -1463,15 +1487,21 @@ int
 xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n,
 	       unsigned short family, struct net *net)
 {
-	int err = 0;
-	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
+	struct xfrm_state_afinfo *afinfo;
+	int err = -EAFNOSUPPORT;
+
+	rcu_read_lock();
+
+	afinfo = xfrm_state_afinfo_get_rcu(family);
 	if (!afinfo)
-		return -EAFNOSUPPORT;
+		goto error;
 
+	err = 0;
 	spin_lock_bh(&net->xfrm.xfrm_state_lock); /*FIXME*/
 	if (afinfo->tmpl_sort)
 		err = afinfo->tmpl_sort(dst, src, n);
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
+error:
 	rcu_read_unlock();
 	return err;
 }
@@ -1481,17 +1511,20 @@ int
 xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n,
 		unsigned short family)
 {
-	int err = 0;
-	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
+	struct xfrm_state_afinfo *afinfo;
 	struct net *net = xs_net(*src);
+	int err = -EAFNOSUPPORT;
 
+	afinfo = xfrm_state_afinfo_get_rcu(family);
 	if (!afinfo)
-		return -EAFNOSUPPORT;
+		goto error;
 
+	err = 0;
 	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	if (afinfo->state_sort)
 		err = afinfo->state_sort(dst, src, n);
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
+error:
 	rcu_read_unlock();
 	return err;
 }
@@ -1972,18 +2005,6 @@ struct xfrm_state_afinfo *xfrm_state_afinfo_get_rcu(unsigned int family)
 	return rcu_dereference(xfrm_state_afinfo[family]);
 }
 
-struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family)
-{
-	struct xfrm_state_afinfo *afinfo;
-	if (unlikely(family >= NPROTO))
-		return NULL;
-	rcu_read_lock();
-	afinfo = rcu_dereference(xfrm_state_afinfo[family]);
-	if (unlikely(!afinfo))
-		rcu_read_unlock();
-	return afinfo;
-}
-
 /* Temporarily located here until net/xfrm/xfrm_tunnel.c is created */
 void xfrm_state_delete_tunnel(struct xfrm_state *x)
 {
@@ -2018,14 +2039,16 @@ int __xfrm_init_state(struct xfrm_state *x, bool init_replay)
 	struct xfrm_state_afinfo *afinfo;
 	struct xfrm_mode *inner_mode;
 	int family = x->props.family;
-	int err;
+	int err = 0;
 
-	err = -EAFNOSUPPORT;
-	afinfo = xfrm_state_get_afinfo(family);
-	if (!afinfo)
-		goto error;
+	rcu_read_lock();
+
+	afinfo = xfrm_state_afinfo_get_rcu(family);
+	if (!afinfo) {
+		rcu_read_unlock();
+		return -EAFNOSUPPORT;
+	}
 
-	err = 0;
 	if (afinfo->init_flags)
 		err = afinfo->init_flags(x);
 
-- 
2.7.3
