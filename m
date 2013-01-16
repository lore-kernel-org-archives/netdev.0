From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 1/2] xfrm: replace rwlock on xfrm_state_afinfo with rcu
Date: Wed, 16 Jan 2013 16:05:05 +0800
Message-ID: <1358323506-19571-1-git-send-email-amwang@redhat.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19315 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752471Ab3APIGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 03:06:33 -0500
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
---
 net/xfrm/xfrm_state.c |   33 ++++++++++++++++-----------------
 1 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 3459692..f567716 100644
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
@@ -1848,12 +1847,12 @@ int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo)
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
@@ -1865,14 +1864,15 @@ int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo)
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
@@ -1882,17 +1882,16 @@ static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family)
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
1.7.7.6
