From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next RFC 1/4] virtio-net: napi helper functions
Date: Fri,  3 Mar 2017 09:39:06 -0500
Message-ID: <20170303143909.80001-2-willemdebruijn.kernel@gmail.com>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
Cc: jasowang@redhat.com, mst@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35770 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751637AbdCCOpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 09:45:44 -0500
Received: by mail-qk0-f195.google.com with SMTP id n127so27523010qkf.2
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 06:45:42 -0800 (PST)
In-Reply-To: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Prepare virtio-net for tx napi by converting existing napi code to
use helper functions. This also deduplicates some logic.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/virtio_net.c | 65 ++++++++++++++++++++++++++----------------------
 1 file changed, 35 insertions(+), 30 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index bf95016f442a..8c21e9a4adc7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -239,6 +239,26 @@ static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
 	return p;
 }
 
+static void virtqueue_napi_schedule(struct napi_struct *napi,
+				    struct virtqueue *vq)
+{
+	if (napi_schedule_prep(napi)) {
+		virtqueue_disable_cb(vq);
+		__napi_schedule(napi);
+	}
+}
+
+static void virtqueue_napi_complete(struct napi_struct *napi,
+				    struct virtqueue *vq, int processed)
+{
+	int opaque;
+
+	opaque = virtqueue_enable_cb_prepare(vq);
+	if (napi_complete_done(napi, processed) &&
+	    unlikely(virtqueue_poll(vq, opaque)))
+		virtqueue_napi_schedule(napi, vq);
+}
+
 static void skb_xmit_done(struct virtqueue *vq)
 {
 	struct virtnet_info *vi = vq->vdev->priv;
@@ -936,27 +956,20 @@ static void skb_recv_done(struct virtqueue *rvq)
 	struct virtnet_info *vi = rvq->vdev->priv;
 	struct receive_queue *rq = &vi->rq[vq2rxq(rvq)];
 
-	/* Schedule NAPI, Suppress further interrupts if successful. */
-	if (napi_schedule_prep(&rq->napi)) {
-		virtqueue_disable_cb(rvq);
-		__napi_schedule(&rq->napi);
-	}
+	virtqueue_napi_schedule(&rq->napi, rvq);
 }
 
-static void virtnet_napi_enable(struct receive_queue *rq)
+static void virtnet_napi_enable(struct virtqueue *vq, struct napi_struct *napi)
 {
-	napi_enable(&rq->napi);
+	napi_enable(napi);
 
 	/* If all buffers were filled by other side before we napi_enabled, we
-	 * won't get another interrupt, so process any outstanding packets
-	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
-	 * We synchronize against interrupts via NAPI_STATE_SCHED */
-	if (napi_schedule_prep(&rq->napi)) {
-		virtqueue_disable_cb(rq->vq);
-		local_bh_disable();
-		__napi_schedule(&rq->napi);
-		local_bh_enable();
-	}
+	 * won't get another interrupt, so process any outstanding packets now.
+	 * Call local_bh_enable after to trigger softIRQ processing.
+	 */
+	local_bh_disable();
+	virtqueue_napi_schedule(napi, vq);
+	local_bh_enable();
 }
 
 static void refill_work(struct work_struct *work)
@@ -971,7 +984,7 @@ static void refill_work(struct work_struct *work)
 
 		napi_disable(&rq->napi);
 		still_empty = !try_fill_recv(vi, rq, GFP_KERNEL);
-		virtnet_napi_enable(rq);
+		virtnet_napi_enable(rq->vq, &rq->napi);
 
 		/* In theory, this can happen: if we don't get any buffers in
 		 * we will *never* try to fill again.
@@ -1011,21 +1024,13 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
 {
 	struct receive_queue *rq =
 		container_of(napi, struct receive_queue, napi);
-	unsigned int r, received;
+	unsigned int received;
 
 	received = virtnet_receive(rq, budget);
 
 	/* Out of packets? */
-	if (received < budget) {
-		r = virtqueue_enable_cb_prepare(rq->vq);
-		if (napi_complete_done(napi, received)) {
-			if (unlikely(virtqueue_poll(rq->vq, r)) &&
-			    napi_schedule_prep(napi)) {
-				virtqueue_disable_cb(rq->vq);
-				__napi_schedule(napi);
-			}
-		}
-	}
+	if (received < budget)
+		virtqueue_napi_complete(napi, rq->vq, received);
 
 	return received;
 }
@@ -1040,7 +1045,7 @@ static int virtnet_open(struct net_device *dev)
 			/* Make sure we have some buffers: if oom use wq. */
 			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
-		virtnet_napi_enable(&vi->rq[i]);
+		virtnet_napi_enable(vi->rq[i].vq, &vi->rq[i].napi);
 	}
 
 	return 0;
@@ -1737,7 +1742,7 @@ static int virtnet_restore_up(struct virtio_device *vdev)
 				schedule_delayed_work(&vi->refill, 0);
 
 		for (i = 0; i < vi->max_queue_pairs; i++)
-			virtnet_napi_enable(&vi->rq[i]);
+			virtnet_napi_enable(vi->rq[i].vq, &vi->rq[i].napi);
 	}
 
 	netif_device_attach(vi->dev);
-- 
2.12.0.rc1.440.g5b76565f74-goog
