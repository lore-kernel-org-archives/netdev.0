From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 net] xen-netback: require fewer guest Rx slots when not using GSO
Date: Tue, 8 Sep 2015 14:25:14 +0100
Message-ID: <1441718714-3256-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:6591 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754553AbbIHNZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2015 09:25:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f48da8b14d04ca87ffcffe68829afd45f926ec6a (xen-netback: fix
unlimited guest Rx internal queue and carrier flapping) introduced a
regression.

The PV frontend in IPXE only places 4 requests on the guest Rx ring.
Since netback required at least (MAX_SKB_FRAGS + 1) slots, IPXE could
not receive any packets.

a) If GSO is not enabled on the VIF, fewer guest Rx slots are required
   for the largest possible packet.  Calculate the required slots
   based on the maximum GSO size or the MTU.

   This calculation of the number of required slots relies on
   1650d5455bd2 (xen-netback: always fully coalesce guest Rx packets)
   which present in 4.0-rc1 and later.

b) Reduce the Rx stall detection to checking for at least one
   available Rx request.  This is fine since we're predominately
   concerned with detecting interfaces which are down and thus have
   zero available Rx requests.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/common.h  | 10 ----------
 drivers/net/xen-netback/netback.c | 23 ++++++++++++++++-------
 2 files changed, 16 insertions(+), 17 deletions(-)

Note that this can only be backported as-is on top of
1650d5455bd2dc6b5ee134bd6fc1a3236c266b5b (xen-netback: always fully
coalesce guest Rx packets) which is in 4.0 and later.

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 8a495b3..25990b1 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -200,11 +200,6 @@ struct xenvif_queue { /* Per-queue data for xenvif */
 	struct xenvif_stats stats;
 };
 
-/* Maximum number of Rx slots a to-guest packet may use, including the
- * slot needed for GSO meta-data.
- */
-#define XEN_NETBK_RX_SLOTS_MAX (MAX_SKB_FRAGS + 1)
-
 enum state_bit_shift {
 	/* This bit marks that the vif is connected */
 	VIF_STATUS_CONNECTED,
@@ -306,11 +301,6 @@ int xenvif_dealloc_kthread(void *data);
 
 void xenvif_rx_queue_tail(struct xenvif_queue *queue, struct sk_buff *skb);
 
-/* Determine whether the needed number of slots (req) are available,
- * and set req_event if not.
- */
-bool xenvif_rx_ring_slots_available(struct xenvif_queue *queue, int needed);
-
 void xenvif_carrier_on(struct xenvif *vif);
 
 /* Callback from stack when TX packet can be released */
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 3f44b52..e791930 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -149,9 +149,20 @@ static inline pending_ring_idx_t pending_index(unsigned i)
 	return i & (MAX_PENDING_REQS-1);
 }
 
-bool xenvif_rx_ring_slots_available(struct xenvif_queue *queue, int needed)
+static int xenvif_rx_ring_slots_needed(struct xenvif *vif)
+{
+	if (vif->gso_mask)
+		return DIV_ROUND_UP(vif->dev->gso_max_size, PAGE_SIZE) + 1;
+	else
+		return DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
+}
+
+static bool xenvif_rx_ring_slots_available(struct xenvif_queue *queue)
 {
 	RING_IDX prod, cons;
+	int needed;
+
+	needed = xenvif_rx_ring_slots_needed(queue->vif);
 
 	do {
 		prod = queue->rx.sring->req_prod;
@@ -513,7 +524,7 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 
 	skb_queue_head_init(&rxq);
 
-	while (xenvif_rx_ring_slots_available(queue, XEN_NETBK_RX_SLOTS_MAX)
+	while (xenvif_rx_ring_slots_available(queue)
 	       && (skb = xenvif_rx_dequeue(queue)) != NULL) {
 		queue->last_rx_time = jiffies;
 
@@ -1839,8 +1850,7 @@ static bool xenvif_rx_queue_stalled(struct xenvif_queue *queue)
 	prod = queue->rx.sring->req_prod;
 	cons = queue->rx.req_cons;
 
-	return !queue->stalled
-		&& prod - cons < XEN_NETBK_RX_SLOTS_MAX
+	return !queue->stalled && prod - cons < 1
 		&& time_after(jiffies,
 			      queue->last_rx_time + queue->vif->stall_timeout);
 }
@@ -1852,14 +1862,13 @@ static bool xenvif_rx_queue_ready(struct xenvif_queue *queue)
 	prod = queue->rx.sring->req_prod;
 	cons = queue->rx.req_cons;
 
-	return queue->stalled
-		&& prod - cons >= XEN_NETBK_RX_SLOTS_MAX;
+	return queue->stalled && prod - cons >= 1;
 }
 
 static bool xenvif_have_rx_work(struct xenvif_queue *queue)
 {
 	return (!skb_queue_empty(&queue->rx_queue)
-		&& xenvif_rx_ring_slots_available(queue, XEN_NETBK_RX_SLOTS_MAX))
+		&& xenvif_rx_ring_slots_available(queue))
 		|| (queue->vif->stall_timeout &&
 		    (xenvif_rx_queue_stalled(queue)
 		     || xenvif_rx_queue_ready(queue)))
-- 
2.1.4
