From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v3 9/9] xen-netback: Aggregate TX unmap
	operations
Date: Wed, 8 Jan 2014 00:10:18 +0000
Message-ID: <1389139818-24458-10-git-send-email-zoltan.kiss@citrix.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

Unmapping causes TLB flushing, therefore we should make it in the largest
possible batches. However we shouldn't starve the guest for too long. So if
the guest has space for at least two big packets and we don't have at least a
quarter ring to unmap, delay it for at most 1 milisec.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/common.h    |    2 ++
 drivers/net/xen-netback/interface.c |    2 ++
 drivers/net/xen-netback/netback.c   |   31 ++++++++++++++++++++++++++++++-
 3 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 063fcda..55d1f14 100644
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
index ce032f9..0287d62 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -406,6 +406,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 			  .desc = i };
 		vif->grant_tx_handle[i] = NETBACK_INVALID_HANDLE;
 	}
+	init_timer(&vif->dealloc_delay);
 
 	/*
 	 * Initialise a dummy MAC address. We choose the numerically
@@ -551,6 +552,7 @@ void xenvif_disconnect(struct xenvif *vif)
 	}
 
 	if (vif->dealloc_task) {
+		del_timer_sync(&vif->dealloc_delay);
 		kthread_stop(vif->dealloc_task);
 		vif->dealloc_task = NULL;
 	}
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 6bc5413..27cc36c 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -134,6 +134,11 @@ static inline pending_ring_idx_t nr_pending_reqs(struct xenvif *vif)
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
@@ -1904,10 +1909,34 @@ static inline int tx_work_todo(struct xenvif *vif)
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
 static inline int tx_dealloc_work_todo(struct xenvif *vif)
 {
-	if (vif->dealloc_cons != vif->dealloc_prod)
+	if (vif->dealloc_cons != vif->dealloc_prod) {
+		if ((nr_free_slots(&vif->tx) > 2 * XEN_NETBK_LEGACY_SLOTS_MAX) &&
+			(vif->dealloc_prod - vif->dealloc_cons < MAX_PENDING_REQS / 4) &&
+			!vif->dealloc_delay_timed_out) {
+			if (!timer_pending(&vif->dealloc_delay)) {
+				vif->dealloc_delay.function =
+					xenvif_dealloc_delay;
+				vif->dealloc_delay.data = (unsigned long)vif;
+				mod_timer(&vif->dealloc_delay,
+					jiffies + msecs_to_jiffies(1));
+
+			}
+			return 0;
+		}
+		del_timer_sync(&vif->dealloc_delay);
+		vif->dealloc_delay_timed_out = false;
 		return 1;
+	}
 
 	return 0;
 }
