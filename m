From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2] xen-netback: stop vif thread spinning if frontend is unresponsive
Date: Wed, 8 Jan 2014 12:41:58 +0000
Message-ID: <1389184918-42790-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:12486 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755200AbaAHMmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 07:42:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent patch to improve guest receive side flow control (ca2f09f2) had a
slight flaw in the wait condition for the vif thread in that any remaining
skbs in the guest receive side netback internal queue would prevent the
thread from sleeping. An unresponsive frontend can lead to a permanently
non-empty internal queue and thus the thread will spin. In this case the
thread should really sleep until the frontend becomes responsive again.

This patch adds an extra flag to the vif which is set if the shared ring
is full and cleared when skbs are drained into the shared ring. Thus,
if the thread runs, finds the shared ring full and can make no progress the
flag remains set. If the flag remains set then the thread will sleep,
regardless of a non-empty queue, until the next event from the frontend.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
v2:
- Use bool for ring_full
- Convert need_to_notify to bool for consistency

 drivers/net/xen-netback/common.h  |    1 +
 drivers/net/xen-netback/netback.c |   14 +++++++++-----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index c955fc3..4c76bcb 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -143,6 +143,7 @@ struct xenvif {
 	char rx_irq_name[IFNAMSIZ+4]; /* DEVNAME-rx */
 	struct xen_netif_rx_back_ring rx;
 	struct sk_buff_head rx_queue;
+	bool rx_queue_stopped;
 	/* Set when the RX interrupt is triggered by the frontend.
 	 * The worker thread may need to wake the queue.
 	 */
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 4f81ac0..2738563 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -476,7 +476,8 @@ static void xenvif_rx_action(struct xenvif *vif)
 	int ret;
 	unsigned long offset;
 	struct skb_cb_overlay *sco;
-	int need_to_notify = 0;
+	bool need_to_notify = false;
+	bool ring_full = false;
 
 	struct netrx_pending_operations npo = {
 		.copy  = vif->grant_copy_op,
@@ -508,7 +509,8 @@ static void xenvif_rx_action(struct xenvif *vif)
 		/* If the skb may not fit then bail out now */
 		if (!xenvif_rx_ring_slots_available(vif, max_slots_needed)) {
 			skb_queue_head(&vif->rx_queue, skb);
-			need_to_notify = 1;
+			need_to_notify = true;
+			ring_full = true;
 			break;
 		}
 
@@ -521,6 +523,8 @@ static void xenvif_rx_action(struct xenvif *vif)
 
 	BUG_ON(npo.meta_prod > ARRAY_SIZE(vif->meta));
 
+	vif->rx_queue_stopped = !npo.copy_prod && ring_full;
+
 	if (!npo.copy_prod)
 		goto done;
 
@@ -592,8 +596,7 @@ static void xenvif_rx_action(struct xenvif *vif)
 
 		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
 
-		if (ret)
-			need_to_notify = 1;
+		need_to_notify |= !!ret;
 
 		npo.meta_cons += sco->meta_slots_used;
 		dev_kfree_skb(skb);
@@ -1724,7 +1727,8 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 
 static inline int rx_work_todo(struct xenvif *vif)
 {
-	return !skb_queue_empty(&vif->rx_queue) || vif->rx_event;
+	return (!skb_queue_empty(&vif->rx_queue) && !vif->rx_queue_stopped) ||
+		vif->rx_event;
 }
 
 static inline int tx_work_todo(struct xenvif *vif)
-- 
1.7.10.4
