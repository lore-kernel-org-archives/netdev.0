From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next] Revert "xen-netback: Aggregate TX unmap operations"
Date: Fri, 21 Mar 2014 17:23:04 +0000
Message-ID: <1395422584-16213-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:48433 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760575AbaCURXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 13:23:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit e9275f5e2df1b2098a8cc405d87b88b9affd73e6. This commit is the
last in the netback grant mapping series, and it tries to do more aggressive
aggreagtion of unmap operations. However practical use showed almost no
positive effect, whilst with certain frontends it causes significant performance
regression.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/common.h    |    2 --
 drivers/net/xen-netback/interface.c |    2 --
 drivers/net/xen-netback/netback.c   |   34 +---------------------------------
 3 files changed, 1 insertion(+), 37 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index bef37be..0355f87 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -137,8 +137,6 @@ struct xenvif {
 	u16 dealloc_ring[MAX_PENDING_REQS];
 	struct task_struct *dealloc_task;
 	wait_queue_head_t dealloc_wq;
-	struct timer_list dealloc_delay;
-	bool dealloc_delay_timed_out;
 
 	/* Use kthread for guest RX */
 	struct task_struct *task;
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index a6a8c15..23bb2f4 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -407,7 +407,6 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 			  .desc = i };
 		vif->grant_tx_handle[i] = NETBACK_INVALID_HANDLE;
 	}
-	init_timer(&vif->dealloc_delay);
 
 	/*
 	 * Initialise a dummy MAC address. We choose the numerically
@@ -556,7 +555,6 @@ void xenvif_disconnect(struct xenvif *vif)
 	}
 
 	if (vif->dealloc_task) {
-		del_timer_sync(&vif->dealloc_delay);
 		kthread_stop(vif->dealloc_task);
 		vif->dealloc_task = NULL;
 	}
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 5a8c4a4..1f595e5 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -133,11 +133,6 @@ static inline pending_ring_idx_t pending_index(unsigned i)
 	return i & (MAX_PENDING_REQS-1);
 }
 
-static inline pending_ring_idx_t nr_free_slots(struct xen_netif_tx_back_ring *ring)
-{
-	return ring->nr_ents -	(ring->sring->req_prod - ring->rsp_prod_pvt);
-}
-
 bool xenvif_rx_ring_slots_available(struct xenvif *vif, int needed)
 {
 	RING_IDX prod, cons;
@@ -1718,36 +1713,9 @@ static inline int tx_work_todo(struct xenvif *vif)
 	return 0;
 }
 
-static void xenvif_dealloc_delay(unsigned long data)
-{
-	struct xenvif *vif = (struct xenvif *)data;
-
-	vif->dealloc_delay_timed_out = true;
-	wake_up(&vif->dealloc_wq);
-}
-
 static inline bool tx_dealloc_work_todo(struct xenvif *vif)
 {
-	if (vif->dealloc_cons != vif->dealloc_prod) {
-		if ((nr_free_slots(&vif->tx) > 2 * XEN_NETBK_LEGACY_SLOTS_MAX) &&
-		    (vif->dealloc_prod - vif->dealloc_cons < MAX_PENDING_REQS / 4) &&
-		    !vif->dealloc_delay_timed_out) {
-			if (!timer_pending(&vif->dealloc_delay)) {
-				vif->dealloc_delay.function =
-					xenvif_dealloc_delay;
-				vif->dealloc_delay.data = (unsigned long)vif;
-				mod_timer(&vif->dealloc_delay,
-					  jiffies + msecs_to_jiffies(1));
-
-			}
-			return false;
-		}
-		del_timer_sync(&vif->dealloc_delay);
-		vif->dealloc_delay_timed_out = false;
-		return true;
-	}
-
-	return false;
+	return vif->dealloc_cons != vif->dealloc_prod;
 }
 
 void xenvif_unmap_frontend_rings(struct xenvif *vif)
-- 
1.7.9.5
