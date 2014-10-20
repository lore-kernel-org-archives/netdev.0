From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC v3 1/3] virtio_net: enable tx interrupt
Date: Mon, 20 Oct 2014 09:52:34 +0300
Message-ID: <1413787824-16130-2-git-send-email-mst@redhat.com>
References: <1413787824-16130-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413787824-16130-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On newer hosts that support delayed tx interrupts,
we probably don't have much to gain from orphaning
packets early.

Based on patch by Jason Wang.

Note: this might degrade performance for
hosts without event idx support.
Should be addressed by the next patch.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 133 +++++++++++++++++++++++++++++++----------------
 1 file changed, 89 insertions(+), 44 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 13d0a8b..14f4cda 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -72,6 +72,8 @@ struct send_queue {
 
 	/* Name of the send queue: output.$index */
 	char name[40];
+
+	struct napi_struct napi;
 };
 
 /* Internal representation of a receive virtqueue */
@@ -217,15 +219,41 @@ static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
 	return p;
 }
 
+static unsigned int free_old_xmit_skbs(struct netdev_queue *txq,
+				       struct send_queue *sq, int budget)
+{
+	struct sk_buff *skb;
+	unsigned int len;
+	struct virtnet_info *vi = sq->vq->vdev->priv;
+	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
+	unsigned int packets = 0;
+
+	while (packets < budget &&
+	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
+		pr_debug("Sent skb %p\n", skb);
+
+		u64_stats_update_begin(&stats->tx_syncp);
+		stats->tx_bytes += skb->len;
+		stats->tx_packets++;
+		u64_stats_update_end(&stats->tx_syncp);
+
+		dev_kfree_skb_any(skb);
+		packets++;
+	}
+
+	if (sq->vq->num_free >= 2+MAX_SKB_FRAGS)
+		netif_tx_start_queue(txq);
+
+	return packets;
+}
+
 static void skb_xmit_done(struct virtqueue *vq)
 {
 	struct virtnet_info *vi = vq->vdev->priv;
+	struct send_queue *sq = &vi->sq[vq2txq(vq)];
 
-	/* Suppress further interrupts. */
-	virtqueue_disable_cb(vq);
-
-	/* We were probably waiting for more output buffers. */
-	netif_wake_subqueue(vi->dev, vq2txq(vq));
+	virtqueue_disable_cb(sq->vq);
+	napi_schedule(&sq->napi);
 }
 
 static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
@@ -774,6 +802,31 @@ again:
 	return received;
 }
 
+static int virtnet_poll_tx(struct napi_struct *napi, int budget)
+{
+	struct send_queue *sq =
+		container_of(napi, struct send_queue, napi);
+	struct virtnet_info *vi = sq->vq->vdev->priv;
+	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, vq2txq(sq->vq));
+	unsigned int sent;
+
+	__netif_tx_lock(txq, smp_processor_id());
+	sent = free_old_xmit_skbs(txq, sq, budget);
+	if (sent < budget) {
+		napi_complete(napi);
+		/* Note: we must enable cb *after* napi_complete, because
+		 * napi_schedule calls from callbacks that trigger before
+		 * napi_complete are ignored.
+		 */
+		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
+			virtqueue_disable_cb(sq->vq);
+			napi_schedule(&sq->napi);
+		}
+	}
+	__netif_tx_unlock(txq);
+	return sent;
+}
+
 #ifdef CONFIG_NET_RX_BUSY_POLL
 /* must be called with local_bh_disable()d */
 static int virtnet_busy_poll(struct napi_struct *napi)
@@ -822,30 +875,12 @@ static int virtnet_open(struct net_device *dev)
 			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
 		virtnet_napi_enable(&vi->rq[i]);
+		napi_enable(&vi->sq[i].napi);
 	}
 
 	return 0;
 }
 
-static void free_old_xmit_skbs(struct send_queue *sq)
-{
-	struct sk_buff *skb;
-	unsigned int len;
-	struct virtnet_info *vi = sq->vq->vdev->priv;
-	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
-
-	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
-		pr_debug("Sent skb %p\n", skb);
-
-		u64_stats_update_begin(&stats->tx_syncp);
-		stats->tx_bytes += skb->len;
-		stats->tx_packets++;
-		u64_stats_update_end(&stats->tx_syncp);
-
-		dev_kfree_skb_any(skb);
-	}
-}
-
 static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 {
 	struct skb_vnet_hdr *hdr;
@@ -911,7 +946,9 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 		sg_set_buf(sq->sg, hdr, hdr_len);
 		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
 	}
-	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb, GFP_ATOMIC);
+
+	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb,
+				    GFP_ATOMIC);
 }
 
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -923,8 +960,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
 	bool kick = !skb->xmit_more;
 
-	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(sq);
+	virtqueue_disable_cb(sq->vq);
 
 	/* Try to transmit */
 	err = xmit_skb(sq, skb);
@@ -940,27 +976,26 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
-	/* Don't wait up for transmitted skbs to be freed. */
-	skb_orphan(skb);
-	nf_reset(skb);
-
 	/* Apparently nice girls don't return TX_BUSY; stop the queue
 	 * before it gets out of hand.  Naturally, this wastes entries. */
-	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
+	if (sq->vq->num_free < 2+MAX_SKB_FRAGS)
 		netif_stop_subqueue(dev, qnum);
-		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
-			/* More just got used, free them then recheck. */
-			free_old_xmit_skbs(sq);
-			if (sq->vq->num_free >= 2+MAX_SKB_FRAGS) {
-				netif_start_subqueue(dev, qnum);
-				virtqueue_disable_cb(sq->vq);
-			}
-		}
-	}
 
 	if (kick || netif_xmit_stopped(txq))
 		virtqueue_kick(sq->vq);
 
+	/* Try to pop off some buffers before we re-enable callbacks.
+	 * It makes sense to do it after kick, since that causes
+	 * device to process packets.
+	 */
+	if (free_old_xmit_skbs(txq, sq, NAPI_POLL_WEIGHT) < NAPI_POLL_WEIGHT) {
+		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
+			virtqueue_disable_cb(sq->vq);
+			napi_schedule(&sq->napi);
+		}
+	} else {
+		napi_schedule(&sq->napi);
+	}
 	return NETDEV_TX_OK;
 }
 
@@ -1137,8 +1172,10 @@ static int virtnet_close(struct net_device *dev)
 	/* Make sure refill_work doesn't re-enable napi! */
 	cancel_delayed_work_sync(&vi->refill);
 
-	for (i = 0; i < vi->max_queue_pairs; i++)
+	for (i = 0; i < vi->max_queue_pairs; i++) {
 		napi_disable(&vi->rq[i].napi);
+		napi_disable(&vi->sq[i].napi);
+	}
 
 	return 0;
 }
@@ -1457,8 +1494,10 @@ static void virtnet_free_queues(struct virtnet_info *vi)
 {
 	int i;
 
-	for (i = 0; i < vi->max_queue_pairs; i++)
+	for (i = 0; i < vi->max_queue_pairs; i++) {
 		netif_napi_del(&vi->rq[i].napi);
+		netif_napi_del(&vi->sq[i].napi);
+	}
 
 	kfree(vi->rq);
 	kfree(vi->sq);
@@ -1612,6 +1651,8 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
 			       napi_weight);
 		napi_hash_add(&vi->rq[i].napi);
+		netif_napi_add(vi->dev, &vi->sq[i].napi, virtnet_poll_tx,
+			       napi_weight);
 
 		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
 		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
@@ -1916,8 +1957,10 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	if (netif_running(vi->dev)) {
 		for (i = 0; i < vi->max_queue_pairs; i++) {
 			napi_disable(&vi->rq[i].napi);
+			napi_disable(&vi->sq[i].napi);
 			napi_hash_del(&vi->rq[i].napi);
 			netif_napi_del(&vi->rq[i].napi);
+			netif_napi_del(&vi->sq[i].napi);
 		}
 	}
 
@@ -1942,8 +1985,10 @@ static int virtnet_restore(struct virtio_device *vdev)
 			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
 
-		for (i = 0; i < vi->max_queue_pairs; i++)
+		for (i = 0; i < vi->max_queue_pairs; i++) {
 			virtnet_napi_enable(&vi->rq[i]);
+			napi_enable(&vi->sq[i].napi);
+		}
 	}
 
 	netif_device_attach(vi->dev);
-- 
MST
