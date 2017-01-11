From: Vineeth Remanan Pillai <vineethp@amazon.com>
Subject: [PATCH] xen-netfront: Fix Rx stall during network stress and OOM
Date: Wed, 11 Jan 2017 23:17:17 +0000
Message-ID: <1484176637-2869-1-git-send-email-vineethp@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vineeth Remanan Pillai <vineethp@amazon.com>, <kamatam@amazon.com>,
        <aliguori@amazon.com>
To: <boris.ostrovsky@oracle.com>, <jgross@suse.com>,
        <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During an OOM scenario, request slots could not be created as skb
allocation fails. So the netback cannot pass in packets and netfront
wrongly assumes that there is no more work to be done and it disables
polling. This causes Rx to stall.

Fix is to consider the skb allocation failure as an error and in the
event of this error, re-enable polling so that request slots could be
created when memory is available.

Signed-off-by: Vineeth Remanan Pillai <vineethp@amazon.com>
---
 drivers/net/xen-netfront.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 40f26b6..8275549 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -277,13 +277,14 @@ static struct sk_buff *xennet_alloc_one_rx_buffer(struct netfront_queue *queue)
 }
 
 
-static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
+static int xennet_alloc_rx_buffers(struct netfront_queue *queue)
 {
 	RING_IDX req_prod = queue->rx.req_prod_pvt;
 	int notify;
+	int err = 0;
 
 	if (unlikely(!netif_carrier_ok(queue->info->netdev)))
-		return;
+		return err;
 
 	for (req_prod = queue->rx.req_prod_pvt;
 	     req_prod - queue->rx.rsp_cons < NET_RX_RING_SIZE;
@@ -295,8 +296,10 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
 		struct xen_netif_rx_request *req;
 
 		skb = xennet_alloc_one_rx_buffer(queue);
-		if (!skb)
+		if (!skb) {
+			err = -ENOMEM;
 			break;
+		}
 
 		id = xennet_rxidx(req_prod);
 
@@ -321,9 +324,9 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
 	queue->rx.req_prod_pvt = req_prod;
 
 	/* Not enough requests? Try again later. */
-	if (req_prod - queue->rx.rsp_cons < NET_RX_SLOTS_MIN) {
+	if (req_prod - queue->rx.sring->rsp_prod < NET_RX_SLOTS_MIN) {
 		mod_timer(&queue->rx_refill_timer, jiffies + (HZ/10));
-		return;
+		return err;
 	}
 
 	wmb();		/* barrier so backend seens requests */
@@ -331,6 +334,8 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
 	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&queue->rx, notify);
 	if (notify)
 		notify_remote_via_irq(queue->rx_irq);
+
+	return err;
 }
 
 static int xennet_open(struct net_device *dev)
@@ -1046,7 +1051,7 @@ static int xennet_poll(struct napi_struct *napi, int budget)
 
 	work_done -= handle_incoming_queue(queue, &rxq);
 
-	xennet_alloc_rx_buffers(queue);
+	err = xennet_alloc_rx_buffers(queue);
 
 	if (work_done < budget) {
 		int more_to_do = 0;
@@ -1054,7 +1059,11 @@ static int xennet_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 
 		RING_FINAL_CHECK_FOR_RESPONSES(&queue->rx, more_to_do);
-		if (more_to_do)
+
+		/* If there is more work to do or could not allocate
+		 * rx buffers, re-enable polling.
+		 */
+		if (more_to_do || err != 0)
 			napi_schedule(napi);
 	}
 
-- 
2.1.2.AMZN
