From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/8] xfrm: replace rwlock on xfrm_state_afinfo with rcu
Date: Wed, 23 Jan 2013 09:19:01 +0100
Message-ID: <1358929144-17806-6-git-send-email-steffen.klassert@secunet.com>
References: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50737 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098Ab3AWITd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 03:19:33 -0500
In-Reply-To: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Similar to commit 418a99ac6ad487dc9c42e6b0e85f941af56330f2
(Replace rwlock on xfrm_policy_afinfo with rcu), the rwlock
on xfrm_state_afinfo can be replaced by RCU too.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |   33 ++++++++++++++++-----------------
 1 file changed, 16 insertions(+), 17 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 05db236..64780a6 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -158,8 +158,8 @@ out_unlock:
 	mutex_unlock(&hash_resize_mutex);
 }
 
-static DEFINE_RWLOCK(xfrm_state_afinfo_lock);
-static struct xfrm_state_afinfo *xfrm_state_afinfo[NPROTO];
+static DEFINE_SPINLOCK(xfrm_state_afinfo_lock);
+static struct xfrm_state_afinfo __rcu *xfrm_state_afinfo[NPROTO];
 
 static DEFINE_SPINLOCK(xfrm_state_gc_lock);
 
@@ -173,17 +173,16 @@ static struct xfrm_state_afinfo *xfrm_state_lock_afinfo(unsigned int family)
 	struct xfrm_state_afinfo *afinfo;
 	if (unlikely(family >= NPROTO))
 		return NULL;
-	write_lock_bh(&xfrm_state_afinfo_lock);
+	spin_lock_bh(&xfrm_state_afinfo_lock);
 	afinfo = xfrm_state_afinfo[family];
 	if (unlikely(!afinfo))
-		write_unlock_bh(&xfrm_state_afinfo_lock);
+		spin_unlock_bh(&xfrm_state_afinfo_lock);
 	return afinfo;
 }
 
 static void xfrm_state_unlock_afinfo(struct xfrm_state_afinfo *afinfo)
-	__releases(xfrm_state_afinfo_lock)
 {
-	write_unlock_bh(&xfrm_state_afinfo_lock);
+	spin_unlock_bh(&xfrm_state_afinfo_lock);
 }
 
 int xfrm_register_type(const struct xfrm_type *type, unsigned short family)
@@ -1845,12 +1844,12 @@ int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo)
 		return -EINVAL;
 	if (unlikely(afinfo->family >= NPROTO))
 		return -EAFNOSUPPORT;
-	write_lock_bh(&xfrm_state_afinfo_lock);
+	spin_lock_bh(&xfrm_state_afinfo_lock);
 	if (unlikely(xfrm_state_afinfo[afinfo->family] != NULL))
 		err = -ENOBUFS;
 	else
-		xfrm_state_afinfo[afinfo->family] = afinfo;
-	write_unlock_bh(&xfrm_state_afinfo_lock);
+		rcu_assign_pointer(xfrm_state_afinfo[afinfo->family], afinfo);
+	spin_unlock_bh(&xfrm_state_afinfo_lock);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_register_afinfo);
@@ -1862,14 +1861,15 @@ int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo)
 		return -EINVAL;
 	if (unlikely(afinfo->family >= NPROTO))
 		return -EAFNOSUPPORT;
-	write_lock_bh(&xfrm_state_afinfo_lock);
+	spin_lock_bh(&xfrm_state_afinfo_lock);
 	if (likely(xfrm_state_afinfo[afinfo->family] != NULL)) {
 		if (unlikely(xfrm_state_afinfo[afinfo->family] != afinfo))
 			err = -EINVAL;
 		else
-			xfrm_state_afinfo[afinfo->family] = NULL;
+			RCU_INIT_POINTER(xfrm_state_afinfo[afinfo->family], NULL);
 	}
-	write_unlock_bh(&xfrm_state_afinfo_lock);
+	spin_unlock_bh(&xfrm_state_afinfo_lock);
+	synchronize_rcu();
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_unregister_afinfo);
@@ -1879,17 +1879,16 @@ static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family)
 	struct xfrm_state_afinfo *afinfo;
 	if (unlikely(family >= NPROTO))
 		return NULL;
-	read_lock(&xfrm_state_afinfo_lock);
-	afinfo = xfrm_state_afinfo[family];
+	rcu_read_lock();
+	afinfo = rcu_dereference(xfrm_state_afinfo[family]);
 	if (unlikely(!afinfo))
-		read_unlock(&xfrm_state_afinfo_lock);
+		rcu_read_unlock();
 	return afinfo;
 }
 
 static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
-	__releases(xfrm_state_afinfo_lock)
 {
-	read_unlock(&xfrm_state_afinfo_lock);
+	rcu_read_unlock();
 }
 
 /* Temporarily located here until net/xfrm/xfrm_tunnel.c is created */
-- 
1.7.9.5
