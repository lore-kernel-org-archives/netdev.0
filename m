From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 4/4] virtio: use callback on empty in virtio_net
Date: Sun, 8 Jun 2008 20:51:55 +1000
Message-ID: <200806082051.56269.rusty@rustcorp.com.au>
References: <200806082049.00641.rusty@rustcorp.com.au> <200806082050.00149.rusty@rustcorp.com.au> <200806082050.56535.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33239 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757506AbYFHKwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2008 06:52:09 -0400
In-Reply-To: <200806082050.56535.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

virtio_net uses a timer to free old transmitted packets, rather than
leaving callbacks enabled all the time.  If the host promises to
always notify us when the transmit ring is empty, we can free packets
at that point and avoid the timer.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff -r 95a02f0e0e21 drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Tue May 27 12:45:17 2008 +1000
+++ b/drivers/net/virtio_net.c	Tue May 27 15:53:41 2008 +1000
@@ -44,6 +44,7 @@ struct virtnet_info
 	/* The skb we couldn't send because buffers were full. */
 	struct sk_buff *last_xmit_skb;
 
+	/* If we need to free in a timer, this is it. */
 	struct timer_list xmit_free_timer;
 
 	/* Number of input buffers, and max we've ever had. */
@@ -51,6 +52,7 @@ struct virtnet_info
 
 	/* For cleaning up after transmission. */
 	struct tasklet_struct tasklet;
+	bool free_in_tasklet;
 
 	/* Receive & send queues. */
 	struct sk_buff_head recv;
@@ -74,7 +76,7 @@ static void skb_xmit_done(struct virtque
 	/* Suppress further interrupts. */
 	svq->vq_ops->disable_cb(svq);
 
-	/* We were waiting for more output buffers. */
+	/* We were probably waiting for more output buffers. */
 	netif_wake_queue(vi->dev);
 
 	/* Make sure we re-xmit last_xmit_skb: if there are no more packets
@@ -240,6 +242,8 @@ static void free_old_xmit_skbs(struct vi
 	}
 }
 
+/* If the virtio transport doesn't always notify us when all in-flight packets
+ * are consumed, we fall back to using this function on a timer to free them. */
 static void xmit_free(unsigned long data)
 {
 	struct virtnet_info *vi = (void *)data;
@@ -300,7 +304,7 @@ static int xmit_skb(struct virtnet_info 
 	num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 
 	err = vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
-	if (!err)
+	if (!err && !vi->free_in_tasklet)
 		mod_timer(&vi->xmit_free_timer, jiffies + (HZ/10));
 
 	return err;
@@ -315,6 +319,8 @@ static void xmit_tasklet(unsigned long d
 		vi->svq->vq_ops->kick(vi->svq);
 		vi->last_xmit_skb = NULL;
 	}
+	if (vi->free_in_tasklet)
+		free_old_xmit_skbs(vi);
 	netif_tx_unlock_bh(vi->dev);
 }
 
@@ -455,6 +461,10 @@ static int virtnet_probe(struct virtio_d
 	vi->vdev = vdev;
 	vdev->priv = vi;
 
+	/* If they give us a callback when all buffers are done, we don't need
+	 * the timer. */
+	vi->free_in_tasklet = virtio_has_feature(vdev,VIRTIO_F_NOTIFY_ON_EMPTY);
+
 	/* We expect two virtqueues, receive then send. */
 	vi->rvq = vdev->config->find_vq(vdev, 0, skb_recv_done);
 	if (IS_ERR(vi->rvq)) {
@@ -474,7 +487,8 @@ static int virtnet_probe(struct virtio_d
 
 	tasklet_init(&vi->tasklet, xmit_tasklet, (unsigned long)vi);
 
-	setup_timer(&vi->xmit_free_timer, xmit_free, (unsigned long)vi);
+	if (!vi->free_in_tasklet)
+		setup_timer(&vi->xmit_free_timer, xmit_free, (unsigned long)vi);
 
 	err = register_netdev(dev);
 	if (err) {
@@ -513,7 +527,8 @@ static void virtnet_remove(struct virtio
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
-	del_timer_sync(&vi->xmit_free_timer);
+	if (!vi->free_in_tasklet)
+		del_timer_sync(&vi->xmit_free_timer);
 
 	/* Free our skbs in send and recv queues, if any. */
 	while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
@@ -538,7 +553,7 @@ static unsigned int features[] = {
 static unsigned int features[] = {
 	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
-	VIRTIO_NET_F_HOST_ECN,
+	VIRTIO_NET_F_HOST_ECN, VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
 static struct virtio_driver virtio_net = {
