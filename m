From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next RFC 2/4] virtio-net: transmit napi
Date: Fri,  3 Mar 2017 10:23:20 -0500
Message-ID: <20170303152320.84134-1-willemdebruijn.kernel@gmail.com>
Cc: jasowang@redhat.com, mst@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34716 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdCCPbH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 10:31:07 -0500
Received: by mail-qk0-f195.google.com with SMTP id s186so27939239qkb.1
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 07:29:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Convert virtio-net to a standard napi tx completion path. This enables
better TCP pacing using TCP small queues and increases single stream
throughput.

The virtio-net driver currently cleans tx descriptors on transmission
of new packets in ndo_start_xmit. Latency depends on new traffic, so
is unbounded. To avoid deadlock when a socket reaches its snd limit,
packets are orphaned on tranmission. This breaks socket backpressure,
including TSQ.

Napi increases the number of interrupts generated compared to the
current model, which keeps interrupts disabled as long as the ring
has enough free descriptors. Keep tx napi optional for now. Follow-on
patches will reduce the interrupt cost.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/virtio_net.c | 73 ++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 61 insertions(+), 12 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 8c21e9a4adc7..9a9031640179 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -33,6 +33,8 @@
 static int napi_weight = NAPI_POLL_WEIGHT;
 module_param(napi_weight, int, 0444);
 
+static int napi_tx_weight = NAPI_POLL_WEIGHT;
+
 static bool csum = true, gso = true;
 module_param(csum, bool, 0444);
 module_param(gso, bool, 0444);
@@ -86,6 +88,8 @@ struct send_queue {
 
 	/* Name of the send queue: output.$index */
 	char name[40];
+
+	struct napi_struct napi;
 };
 
 /* Internal representation of a receive virtqueue */
@@ -262,12 +266,16 @@ static void virtqueue_napi_complete(struct napi_struct *napi,
 static void skb_xmit_done(struct virtqueue *vq)
 {
 	struct virtnet_info *vi = vq->vdev->priv;
+	struct napi_struct *napi = &vi->sq[vq2txq(vq)].napi;
 
 	/* Suppress further interrupts. */
 	virtqueue_disable_cb(vq);
 
-	/* We were probably waiting for more output buffers. */
-	netif_wake_subqueue(vi->dev, vq2txq(vq));
+	if (napi->weight)
+		virtqueue_napi_schedule(napi, vq);
+	else
+		/* We were probably waiting for more output buffers. */
+		netif_wake_subqueue(vi->dev, vq2txq(vq));
 }
 
 static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
@@ -961,6 +969,9 @@ static void skb_recv_done(struct virtqueue *rvq)
 
 static void virtnet_napi_enable(struct virtqueue *vq, struct napi_struct *napi)
 {
+	if (!napi->weight)
+		return;
+
 	napi_enable(napi);
 
 	/* If all buffers were filled by other side before we napi_enabled, we
@@ -1046,12 +1057,13 @@ static int virtnet_open(struct net_device *dev)
 			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
 		virtnet_napi_enable(vi->rq[i].vq, &vi->rq[i].napi);
+		virtnet_napi_enable(vi->sq[i].vq, &vi->sq[i].napi);
 	}
 
 	return 0;
 }
 
-static void free_old_xmit_skbs(struct send_queue *sq)
+static unsigned int free_old_xmit_skbs(struct send_queue *sq, int budget)
 {
 	struct sk_buff *skb;
 	unsigned int len;
@@ -1060,7 +1072,8 @@ static void free_old_xmit_skbs(struct send_queue *sq)
 	unsigned int packets = 0;
 	unsigned int bytes = 0;
 
-	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
+	while (packets < budget &&
+	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 
 		bytes += skb->len;
@@ -1073,12 +1086,35 @@ static void free_old_xmit_skbs(struct send_queue *sq)
 	 * happens when called speculatively from start_xmit.
 	 */
 	if (!packets)
-		return;
+		return 0;
 
 	u64_stats_update_begin(&stats->tx_syncp);
 	stats->tx_bytes += bytes;
 	stats->tx_packets += packets;
 	u64_stats_update_end(&stats->tx_syncp);
+
+	return packets;
+}
+
+static int virtnet_poll_tx(struct napi_struct *napi, int budget)
+{
+	struct send_queue *sq = container_of(napi, struct send_queue, napi);
+	struct virtnet_info *vi = sq->vq->vdev->priv;
+	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, vq2txq(sq->vq));
+	bool complete = false;
+
+	__netif_tx_lock(txq, smp_processor_id());
+	if (free_old_xmit_skbs(sq, budget) < budget)
+		complete = true;
+	__netif_tx_unlock(txq);
+
+	if (complete)
+		virtqueue_napi_complete(napi, sq->vq, 0);
+
+	if (sq->vq->num_free >= 2 + MAX_SKB_FRAGS)
+		netif_wake_subqueue(vi->dev, vq2txq(sq->vq));
+
+	return complete ? 0 : budget;
 }
 
 static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
@@ -1130,9 +1166,11 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int err;
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
 	bool kick = !skb->xmit_more;
+	bool use_napi = sq->napi.weight;
 
 	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(sq);
+	if (!use_napi)
+		free_old_xmit_skbs(sq, napi_weight);
 
 	/* timestamp packet in software */
 	skb_tx_timestamp(skb);
@@ -1152,8 +1190,10 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Don't wait up for transmitted skbs to be freed. */
-	skb_orphan(skb);
-	nf_reset(skb);
+	if (!use_napi) {
+		skb_orphan(skb);
+		nf_reset(skb);
+	}
 
 	/* If running out of space, stop queue to avoid getting packets that we
 	 * are then unable to transmit.
@@ -1167,9 +1207,10 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
 		netif_stop_subqueue(dev, qnum);
-		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
+		if (!use_napi &&
+		    unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
 			/* More just got used, free them then recheck. */
-			free_old_xmit_skbs(sq);
+			free_old_xmit_skbs(sq, virtqueue_get_vring_size(sq->vq));
 			if (sq->vq->num_free >= 2+MAX_SKB_FRAGS) {
 				netif_start_subqueue(dev, qnum);
 				virtqueue_disable_cb(sq->vq);
@@ -1371,8 +1412,10 @@ static int virtnet_close(struct net_device *dev)
 	/* Make sure refill_work doesn't re-enable napi! */
 	cancel_delayed_work_sync(&vi->refill);
 
-	for (i = 0; i < vi->max_queue_pairs; i++)
+	for (i = 0; i < vi->max_queue_pairs; i++) {
 		napi_disable(&vi->rq[i].napi);
+		napi_disable(&vi->sq[i].napi);
+	}
 
 	return 0;
 }
@@ -1719,6 +1762,7 @@ static void virtnet_freeze_down(struct virtio_device *vdev)
 	if (netif_running(vi->dev)) {
 		for (i = 0; i < vi->max_queue_pairs; i++)
 			napi_disable(&vi->rq[i].napi);
+			napi_disable(&vi->sq[i].napi);
 	}
 }
 
@@ -1741,8 +1785,10 @@ static int virtnet_restore_up(struct virtio_device *vdev)
 			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
 
-		for (i = 0; i < vi->max_queue_pairs; i++)
+		for (i = 0; i < vi->max_queue_pairs; i++) {
 			virtnet_napi_enable(vi->rq[i].vq, &vi->rq[i].napi);
+			virtnet_napi_enable(vi->sq[i].vq, &vi->sq[i].napi);
+		}
 	}
 
 	netif_device_attach(vi->dev);
@@ -1947,6 +1993,7 @@ static void virtnet_free_queues(struct virtnet_info *vi)
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		napi_hash_del(&vi->rq[i].napi);
 		netif_napi_del(&vi->rq[i].napi);
+		netif_napi_del(&vi->sq[i].napi);
 	}
 
 	/* We called napi_hash_del() before netif_napi_del(),
@@ -2132,6 +2179,8 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 		vi->rq[i].pages = NULL;
 		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
 			       napi_weight);
+		netif_napi_add(vi->dev, &vi->sq[i].napi, virtnet_poll_tx,
+			       napi_tx_weight);
 
 		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
 		ewma_pkt_len_init(&vi->rq[i].mrg_avg_pkt_len);
-- 
2.12.0.rc1.440.g5b76565f74-goog
