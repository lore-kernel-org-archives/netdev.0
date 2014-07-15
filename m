From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH RFC net-next] xfrm: remove useless hash_resize_mutex locks
Date: Tue, 15 Jul 2014 09:33:41 +0800
Message-ID: <1405388021-29105-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shan.hai@windriver.com>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63196 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949AbaGOBeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 21:34:00 -0400
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
---
 net/xfrm/xfrm_policy.c |    5 -----
 net/xfrm/xfrm_state.c  |   13 +++----------
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a8ef510..039c2c4 100644
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
