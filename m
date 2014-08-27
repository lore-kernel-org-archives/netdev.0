From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] xfrm: remove useless hash_resize_mutex locks
Date: Wed, 27 Aug 2014 17:49:46 +0800
Message-ID: <1409132986-12224-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:44240 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808AbaH0Jt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 05:49:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In xfrm_policy.c, hash_resize_mutex is defined as a local variable
and only used in xfrm_hash_resize() which is declared as a work
handler of xfrm.policy_hash_work. But when the xfrm.policy_hash_work
work is put in the global workqueue(system_wq) with schedule_work(),
the work will be really inserted in the global workqueue if it was
not already queued, otherwise, it is still left in the same position
on the the global workqueue. This means the xfrm_hash_resize() work
handler is only executed once at any time no matter how many times
its work is scheduled, that is, xfrm_hash_resize() is not called
concurrently at all, so hash_resize_mutex is redundant for us.

Additionally hash_resize_mutex defined in xfrm_state.c can be removed
as the same reason.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
Just resend the patch after RFC flag is removed from below
version:
http://patchwork.ozlabs.org/patch/369818/

 net/xfrm/xfrm_policy.c |    5 -----
 net/xfrm/xfrm_state.c  |   13 +++----------
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index beeed60..b559a90 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -510,14 +510,11 @@ void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si)
 }
 EXPORT_SYMBOL(xfrm_spd_getinfo);
 
-static DEFINE_MUTEX(hash_resize_mutex);
 static void xfrm_hash_resize(struct work_struct *work)
 {
 	struct net *net = container_of(work, struct net, xfrm.policy_hash_work);
 	int dir, total;
 
-	mutex_lock(&hash_resize_mutex);
-
 	total = 0;
 	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
 		if (xfrm_bydst_should_resize(net, dir, &total))
@@ -525,8 +522,6 @@ static void xfrm_hash_resize(struct work_struct *work)
 	}
 	if (xfrm_byidx_should_resize(net, total))
 		xfrm_byidx_resize(net, total);
-
-	mutex_unlock(&hash_resize_mutex);
 }
 
 /* Generate new index... KAME seems to generate them ordered by cost
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
