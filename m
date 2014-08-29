From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v3] xfrm: remove useless hash_resize_mutex locks
Date: Fri, 29 Aug 2014 17:09:07 +0800
Message-ID: <1409303348-23262-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <christophe.gouault@6wind.com>,
	<netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33490 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaH2JJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 05:09:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/xfrm/xfrm_state.c |   13 +++----------
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
1.7.9.5
