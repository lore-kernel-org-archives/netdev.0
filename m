From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next] xen-netback: Schedule NAPI from dealloc thread instead of callback
Date: Wed, 12 Mar 2014 21:04:41 +0000
Message-ID: <1394658281-2488-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>, Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If there are unconsumed requests in the ring, but there isn't enough free
pending slots, the NAPI instance deschedule itself. As the frontend won't send
any more interrupts in this case, it is the task of whoever release the pending
slots to schedule the NAPI instance in this case. Originally it was done in the
callback, but it's better at the end of the dealloc thread, otherwise there is
a risk that the NAPI instance just deschedule itself as the dealloc thread
couldn't release any used slot yet. However, as there are a lot of pending
packets, NAPI will be scheduled again, and it is very unlikely that the dealloc
thread can't release enough slots in the meantime.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index eae9724..07c9677 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1516,13 +1516,6 @@ void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
 	wake_up(&vif->dealloc_wq);
 	spin_unlock_irqrestore(&vif->callback_lock, flags);
 
-	if (RING_HAS_UNCONSUMED_REQUESTS(&vif->tx) &&
-	    xenvif_tx_pending_slots_available(vif)) {
-		local_bh_disable();
-		napi_schedule(&vif->napi);
-		local_bh_enable();
-	}
-
 	if (likely(zerocopy_success))
 		vif->tx_zerocopy_success++;
 	else
@@ -1594,6 +1587,13 @@ static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
 	for (i = 0; i < gop - vif->tx_unmap_ops; ++i)
 		xenvif_idx_release(vif, pending_idx_release[i],
 				   XEN_NETIF_RSP_OKAY);
+
+	if (RING_HAS_UNCONSUMED_REQUESTS(&vif->tx) &&
+	    xenvif_tx_pending_slots_available(vif)) {
+		local_bh_disable();
+		napi_schedule(&vif->napi);
+		local_bh_enable();
+	}
 }
 
 
