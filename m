From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v4 9/9] xen-netback: Aggregate TX unmap operations
Date: Tue, 14 Jan 2014 20:39:55 +0000
Message-ID: <1389731995-9887-10-git-send-email-zoltan.kiss@citrix.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unmapping causes TLB flushing, therefore we should make it in the largest
possible batches. However we shouldn't starve the guest for too long. So if
the guest has space for at least two big packets and we don't have at least a
quarter ring to unmap, delay it for at most 1 milisec.

v4:
- use bool for tx_dealloc_work_todo

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/common.h    |    2 ++
 drivers/net/xen-netback/interface.c |    2 ++
 drivers/net/xen-netback/netback.c   |   31 ++++++++++++++++++++++++++++++-
 3 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 1594109..ce6b5b5 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -115,6 +115,8 @@ struct xenvif {
 	u16 dealloc_ring[MAX_PENDING_REQS];
 	struct task_struct *dealloc_task;
 	wait_queue_head_t dealloc_wq;
+	struct timer_list dealloc_delay;
+	bool dealloc_delay_timed_out;
 
 	/* Use kthread for guest RX */
 	struct task_struct *task;
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 669bd55..1c34f56 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -406,6 +406,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 			  .desc = i };
 		vif->grant_tx_handle[i] = NETBACK_INVALID_HANDLE;
 	}
+	init_timer(&vif->dealloc_delay);
 
 	/*
 	 * Initialise a dummy MAC address. We choose the numerically
@@ -553,6 +554,7 @@ void xenvif_disconnect(struct xenvif *vif)
 	}
 
 	if (vif->dealloc_task) {
+		del_timer_sync(&vif->dealloc_delay);
 		kthread_stop(vif->dealloc_task);
 		vif->dealloc_task = NULL;
 	}
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 9e7ba04..b1d1d4c 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -135,6 +135,11 @@ static inline pending_ring_idx_t nr_pending_reqs(struct xenvif *vif)
 		vif->pending_prod + vif->pending_cons;
 }
 
+static inline pending_ring_idx_t nr_free_slots(struct xen_netif_tx_back_ring *ring)
+{
+	return ring->nr_ents -	(ring->sring->req_prod - ring->rsp_prod_pvt);
+}
+
 bool xenvif_rx_ring_slots_available(struct xenvif *vif, int needed)
 {
 	RING_IDX prod, cons;
@@ -1936,10 +1941,34 @@ static inline int tx_work_todo(struct xenvif *vif)
 	return 0;
 }
 
+static void xenvif_dealloc_delay(unsigned long data)
+{
+	struct xenvif *vif = (struct xenvif *)data;
+
+	vif->dealloc_delay_timed_out = true;
+	wake_up(&vif->dealloc_wq);
+}
+
 static inline bool tx_dealloc_work_todo(struct xenvif *vif)
 {
-	if (vif->dealloc_cons != vif->dealloc_prod)
+	if (vif->dealloc_cons != vif->dealloc_prod) {
+		if ((nr_free_slots(&vif->tx) > 2 * XEN_NETBK_LEGACY_SLOTS_MAX) &&
+		    (vif->dealloc_prod - vif->dealloc_cons < MAX_PENDING_REQS / 4) &&
+		    !vif->dealloc_delay_timed_out) {
+			if (!timer_pending(&vif->dealloc_delay)) {
+				vif->dealloc_delay.function =
+					xenvif_dealloc_delay;
+				vif->dealloc_delay.data = (unsigned long)vif;
+				mod_timer(&vif->dealloc_delay,
+					  jiffies + msecs_to_jiffies(1));
+
+			}
+			return false;
+		}
+		del_timer_sync(&vif->dealloc_delay);
+		vif->dealloc_delay_timed_out = false;
 		return true;
+	}
 
 	return false;
 }
