From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 3/6] xfrm: remove xfrm_state_put_afinfo
Date: Mon,  9 Jan 2017 14:20:47 +0100
Message-ID: <1483968050-788-4-git-send-email-fw@strlen.de>
References: <1483968050-788-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:48770 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S938904AbdAINUm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 08:20:42 -0500
In-Reply-To: <1483968050-788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 44abdc3047aecafc141dfbaf1ed
("xfrm: replace rwlock on xfrm_state_afinfo with rcu") made
xfrm_state_put_afinfo equivalent to rcu_read_unlock.

Use spatch to replace it with direct calls to rcu_read_unlock:

@@
struct xfrm_state_afinfo *a;
@@

-  xfrm_state_put_afinfo(a);
+  rcu_read_unlock();

old:
 text    data     bss     dec     hex filename
22570      72     424   23066    5a1a xfrm_state.o
 1612       0       0    1612     64c xfrm_output.o
new:
22554      72     424   23050    5a0a xfrm_state.o
 1596       0       0    1596     63c xfrm_output.o

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/xfrm.h     |  1 -
 net/xfrm/xfrm_output.c |  8 +++-----
 net/xfrm/xfrm_state.c  | 31 +++++++++++++------------------
 3 files changed, 16 insertions(+), 24 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 31947b9c21d6..957d0cc30691 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -343,7 +343,6 @@ struct xfrm_state_afinfo {
 int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
 int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo);
 struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
-void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
 
 struct xfrm_input_afinfo {
 	unsigned int		family;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 637387bbaaea..8ba29fe58352 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -246,10 +246,8 @@ void xfrm_local_error(struct sk_buff *skb, int mtu)
 		return;
 
 	afinfo = xfrm_state_get_afinfo(proto);
-	if (!afinfo)
-		return;
-
-	afinfo->local_error(skb, mtu);
-	xfrm_state_put_afinfo(afinfo);
+	if (afinfo)
+		afinfo->local_error(skb, mtu);
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(xfrm_local_error);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index e3c15ad1b246..8a9ec1b80bf5 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -192,7 +192,7 @@ int xfrm_register_type(const struct xfrm_type *type, unsigned short family)
 	else
 		err = -EEXIST;
 	spin_unlock_bh(&xfrm_type_lock);
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(xfrm_register_type);
@@ -213,7 +213,7 @@ int xfrm_unregister_type(const struct xfrm_type *type, unsigned short family)
 	else
 		typemap[type->proto] = NULL;
 	spin_unlock_bh(&xfrm_type_lock);
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(xfrm_unregister_type);
@@ -235,13 +235,13 @@ static const struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family)
 	if (unlikely(type && !try_module_get(type->owner)))
 		type = NULL;
 	if (!type && !modload_attempted) {
-		xfrm_state_put_afinfo(afinfo);
+		rcu_read_unlock();
 		request_module("xfrm-type-%d-%d", family, proto);
 		modload_attempted = 1;
 		goto retry;
 	}
 
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return type;
 }
 
@@ -280,7 +280,7 @@ int xfrm_register_mode(struct xfrm_mode *mode, int family)
 
 out:
 	spin_unlock_bh(&xfrm_mode_lock);
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(xfrm_register_mode);
@@ -308,7 +308,7 @@ int xfrm_unregister_mode(struct xfrm_mode *mode, int family)
 	}
 
 	spin_unlock_bh(&xfrm_mode_lock);
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(xfrm_unregister_mode);
@@ -331,13 +331,13 @@ static struct xfrm_mode *xfrm_get_mode(unsigned int encap, int family)
 	if (unlikely(mode && !try_module_get(mode->owner)))
 		mode = NULL;
 	if (!mode && !modload_attempted) {
-		xfrm_state_put_afinfo(afinfo);
+		rcu_read_unlock();
 		request_module("xfrm-mode-%d-%d", family, encap);
 		modload_attempted = 1;
 		goto retry;
 	}
 
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return mode;
 }
 
@@ -651,13 +651,13 @@ xfrm_init_tempstate(struct xfrm_state *x, const struct flowi *fl,
 	afinfo->init_tempsel(&x->sel, fl);
 
 	if (family != tmpl->encap_family) {
-		xfrm_state_put_afinfo(afinfo);
+		rcu_read_unlock();
 		afinfo = xfrm_state_get_afinfo(tmpl->encap_family);
 		if (!afinfo)
 			return -1;
 	}
 	afinfo->init_temprop(x, tmpl, daddr, saddr);
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return 0;
 }
 
@@ -1474,7 +1474,7 @@ xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n,
 	if (afinfo->tmpl_sort)
 		err = afinfo->tmpl_sort(dst, src, n);
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(xfrm_tmpl_sort);
@@ -1494,7 +1494,7 @@ xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n,
 	if (afinfo->state_sort)
 		err = afinfo->state_sort(dst, src, n);
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_sort);
@@ -1978,11 +1978,6 @@ struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family)
 	return afinfo;
 }
 
-void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
-{
-	rcu_read_unlock();
-}
-
 /* Temporarily located here until net/xfrm/xfrm_tunnel.c is created */
 void xfrm_state_delete_tunnel(struct xfrm_state *x)
 {
@@ -2028,7 +2023,7 @@ int __xfrm_init_state(struct xfrm_state *x, bool init_replay)
 	if (afinfo->init_flags)
 		err = afinfo->init_flags(x);
 
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 
 	if (err)
 		goto error;
-- 
2.7.3
