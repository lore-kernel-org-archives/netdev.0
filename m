From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 05/15] xfrm: remove xfrm_state_put_afinfo
Date: Wed, 1 Feb 2017 09:17:47 +0100
Message-ID: <1485937077-612-6-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37068 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751725AbdBAISK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:10 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

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
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     |  1 -
 net/xfrm/xfrm_output.c |  8 +++-----
 net/xfrm/xfrm_state.c  | 31 +++++++++++++------------------
 3 files changed, 16 insertions(+), 24 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 31947b9..957d0cc 100644
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
index 637387b..8ba29fe 100644
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
index 57e9578..7830844 100644
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
 
@@ -651,13 +651,13 @@ void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si)
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
 
@@ -1474,7 +1474,7 @@ struct xfrm_state *
 	if (afinfo->tmpl_sort)
 		err = afinfo->tmpl_sort(dst, src, n);
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(xfrm_tmpl_sort);
@@ -1494,7 +1494,7 @@ struct xfrm_state *
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
@@ -2025,7 +2020,7 @@ int __xfrm_init_state(struct xfrm_state *x, bool init_replay)
 	if (afinfo->init_flags)
 		err = afinfo->init_flags(x);
 
-	xfrm_state_put_afinfo(afinfo);
+	rcu_read_unlock();
 
 	if (err)
 		goto error;
-- 
1.9.1
