From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] xfrm: remove useless hash_resize_mutex locks
Date: Thu, 25 Sep 2014 11:10:22 +0200
Message-ID: <1411636225-4433-2-git-send-email-steffen.klassert@secunet.com>
References: <1411636225-4433-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54379 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752384AbaIYJKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 05:10:38 -0400
In-Reply-To: <1411636225-4433-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

In xfrm_state.c, hash_resize_mutex is defined as a local variable
and only used in xfrm_hash_resize() which is declared as a work
handler of xfrm.state_hash_work. But when the xfrm.state_hash_work
work is put in the global workqueue(system_wq) with schedule_work(),
the work will be really inserted in the global workqueue if it was
not already queued, otherwise, it is still left in the same position
on the the global workqueue. This means the xfrm_hash_resize() work
handler is only executed once at any time no matter how many times
its work is scheduled, that is, xfrm_hash_resize() is not called
concurrently at all, so hash_resize_mutex is redundant for us.

Cc: Christophe Gouault <christophe.gouault@6wind.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0ab5413..de971b6 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -97,8 +97,6 @@ static unsigned long xfrm_hash_new_size(unsigned int state_hmask)
 	return ((state_hmask + 1) << 1) * sizeof(struct hlist_head);
 }
 
-static DEFINE_MUTEX(hash_resize_mutex);
-
 static void xfrm_hash_resize(struct work_struct *work)
 {
 	struct net *net = container_of(work, struct net, xfrm.state_hash_work);
@@ -107,22 +105,20 @@ static void xfrm_hash_resize(struct work_struct *work)
 	unsigned int nhashmask, ohashmask;
 	int i;
 
-	mutex_lock(&hash_resize_mutex);
-
 	nsize = xfrm_hash_new_size(net->xfrm.state_hmask);
 	ndst = xfrm_hash_alloc(nsize);
 	if (!ndst)
-		goto out_unlock;
+		return;
 	nsrc = xfrm_hash_alloc(nsize);
 	if (!nsrc) {
 		xfrm_hash_free(ndst, nsize);
-		goto out_unlock;
+		return;
 	}
 	nspi = xfrm_hash_alloc(nsize);
 	if (!nspi) {
 		xfrm_hash_free(ndst, nsize);
 		xfrm_hash_free(nsrc, nsize);
-		goto out_unlock;
+		return;
 	}
 
 	spin_lock_bh(&net->xfrm.xfrm_state_lock);
@@ -148,9 +144,6 @@ static void xfrm_hash_resize(struct work_struct *work)
 	xfrm_hash_free(odst, osize);
 	xfrm_hash_free(osrc, osize);
 	xfrm_hash_free(ospi, osize);
-
-out_unlock:
-	mutex_unlock(&hash_resize_mutex);
 }
 
 static DEFINE_SPINLOCK(xfrm_state_afinfo_lock);
-- 
1.9.1
