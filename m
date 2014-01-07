From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next] xen-netback: stop vif thread spinning if frontend is unresponsive
Date: Tue, 7 Jan 2014 16:25:29 +0000
Message-ID: <1389111929-37231-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:16786 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbaAGQm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 11:42:56 -0500
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
 drivers/net/xen-netback/common.h  |    1 +
 drivers/net/xen-netback/netback.c |   12 ++++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

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
index 4f81ac0..1c31ac5 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -477,6 +477,7 @@ static void xenvif_rx_action(struct xenvif *vif)
 	unsigned long offset;
 	struct skb_cb_overlay *sco;
 	int need_to_notify = 0;
+	int ring_full = 0;
 
 	struct netrx_pending_operations npo = {
 		.copy  = vif->grant_copy_op,
@@ -509,6 +510,7 @@ static void xenvif_rx_action(struct xenvif *vif)
 		if (!xenvif_rx_ring_slots_available(vif, max_slots_needed)) {
 			skb_queue_head(&vif->rx_queue, skb);
 			need_to_notify = 1;
+			ring_full = 1;
 			break;
 		}
 
@@ -521,8 +523,13 @@ static void xenvif_rx_action(struct xenvif *vif)
 
 	BUG_ON(npo.meta_prod > ARRAY_SIZE(vif->meta));
 
-	if (!npo.copy_prod)
+	if (!npo.copy_prod) {
+		if (ring_full)
+			vif->rx_queue_stopped = true;
 		goto done;
+	}
+
+	vif->rx_queue_stopped = false;
 
 	BUG_ON(npo.copy_prod > MAX_GRANT_COPY_OPS);
 	gnttab_batch_copy(vif->grant_copy_op, npo.copy_prod);
@@ -1724,7 +1731,8 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 
 static inline int rx_work_todo(struct xenvif *vif)
 {
-	return !skb_queue_empty(&vif->rx_queue) || vif->rx_event;
+	return (!skb_queue_empty(&vif->rx_queue) && !vif->rx_queue_stopped) ||
+		vif->rx_event;
 }
 
 static inline int tx_work_todo(struct xenvif *vif)
-- 
1.7.10.4
