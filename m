From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH 1/1 net-next] virtio_net: remove send queue
Date: Mon, 08 Feb 2010 16:14:42 -0800
Message-ID: <1265674482.4484.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org, rusty@rustcorp.com.au,
	mst@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now we have a virtio detach API (in commit
f9bfbebf34eab707b065116cdc9699d25ba4252a), we don't need to track xmit
skbs in the virio_net driver, which improves transmission performance.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
Acked-by: Rusty Russell <rusty@rustcorp.com.au>
Acked-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c |   26 ++++++++------------------
 1 files changed, 8 insertions(+), 18 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9d8984a..8069c08 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -56,9 +56,6 @@ struct virtnet_info
 	/* Host will merge rx buffers for big packets (shake it! shake it!) */
 	bool mergeable_rx_bufs;
 
-	/* Send queue. */
-	struct sk_buff_head send;
-
 	/* Work struct for refilling if we run low on memory. */
 	struct delayed_work refill;
 
@@ -505,7 +502,6 @@ static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
 
 	while ((skb = vi->svq->vq_ops->get_buf(vi->svq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
-		__skb_unlink(skb, &vi->send);
 		vi->dev->stats.tx_bytes += skb->len;
 		vi->dev->stats.tx_packets++;
 		tot_sgs += skb_vnet_hdr(skb)->num_sg;
@@ -588,15 +584,6 @@ again:
 	}
 	vi->svq->vq_ops->kick(vi->svq);
 
-	/*
-	 * Put new one in send queue.  You'd expect we'd need this before
-	 * xmit_skb calls add_buf(), since the callback can be triggered
-	 * immediately after that.  But since the callback just triggers
-	 * another call back here, normal network xmit locking prevents the
-	 * race.
-	 */
-	__skb_queue_head(&vi->send, skb);
-
 	/* Don't wait up for transmitted skbs to be freed. */
 	skb_orphan(skb);
 	nf_reset(skb);
@@ -977,9 +964,6 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->features |= NETIF_F_HW_VLAN_FILTER;
 	}
 
-	/* Initialize our empty send queue. */
-	skb_queue_head_init(&vi->send);
-
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
@@ -1016,6 +1000,12 @@ static void free_unused_bufs(struct virtnet_info *vi)
 {
 	void *buf;
 	while (1) {
+		buf = vi->svq->vq_ops->detach_unused_buf(vi->svq);
+		if (!buf)
+			break;
+		dev_kfree_skb(buf);
+	}
+	while (1) {
 		buf = vi->rvq->vq_ops->detach_unused_buf(vi->rvq);
 		if (!buf)
 			break;
@@ -1035,11 +1025,11 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
-	/* Free our skbs in send queue, if any. */
-	__skb_queue_purge(&vi->send);
 
 	unregister_netdev(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
+
+	/* Free unused buffers in both send and recv, if any. */
 	free_unused_bufs(vi);
 
 	vdev->config->del_vqs(vi->vdev);
