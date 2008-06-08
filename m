From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 3/4] virtio: virtio_net free transmit skbs in a timer
Date: Sun, 8 Jun 2008 20:50:56 +1000
Message-ID: <200806082050.56535.rusty@rustcorp.com.au>
References: <200806082049.00641.rusty@rustcorp.com.au> <200806082050.00149.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33227 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757486AbYFHKvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2008 06:51:08 -0400
In-Reply-To: <200806082050.00149.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>

virtio_net currently only frees old transmit skbs just
before queueing new ones. If the queue is full, it then
enables interrupts and waits for notification that more
work has been performed.

However, a side-effect of this scheme is that there are
always xmit skbs left dangling when no new packets are
sent, against the Documentation/networking/driver.txt
guideline:

  "... it is not allowed for your TX mitigation scheme
   to let TX packets "hang out" in the TX ring unreclaimed
   forever if no new TX packets are sent."

Add a timer to ensure that any time we queue new TX
skbs, we will shortly free them again.

This fixes an easily reproduced hang at shutdown where
iptables attempts to unload nf_conntrack and nf_conntrack
waits for an skb it is tracking to be freed, but virtio_net
never frees it.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -43,6 +43,8 @@ struct virtnet_info
 
 	/* The skb we couldn't send because buffers were full. */
 	struct sk_buff *last_xmit_skb;
+
+	struct timer_list xmit_free_timer;
 
 	/* Number of input buffers, and max we've ever had. */
 	unsigned int num, max;
@@ -238,9 +240,23 @@ static void free_old_xmit_skbs(struct vi
 	}
 }
 
+static void xmit_free(unsigned long data)
+{
+	struct virtnet_info *vi = (void *)data;
+
+	netif_tx_lock(vi->dev);
+
+	free_old_xmit_skbs(vi);
+
+	if (!skb_queue_empty(&vi->send))
+		mod_timer(&vi->xmit_free_timer, jiffies + (HZ/10));
+
+	netif_tx_unlock(vi->dev);
+}
+
 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 {
-	int num;
+	int num, err;
 	struct scatterlist sg[2+MAX_SKB_FRAGS];
 	struct virtio_net_hdr *hdr;
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
@@ -283,7 +299,11 @@ static int xmit_skb(struct virtnet_info 
 	vnet_hdr_to_sg(sg, skb);
 	num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 
-	return vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
+	err = vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
+	if (!err)
+		mod_timer(&vi->xmit_free_timer, jiffies + (HZ/10));
+
+	return err;
 }
 
 static void xmit_tasklet(unsigned long data)
@@ -452,6 +472,8 @@ static int virtnet_probe(struct virtio_d
 
 	tasklet_init(&vi->tasklet, xmit_tasklet, (unsigned long)vi);
 
+	setup_timer(&vi->xmit_free_timer, xmit_free, (unsigned long)vi);
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
@@ -488,6 +510,8 @@ static void virtnet_remove(struct virtio
 
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
+
+	del_timer_sync(&vi->xmit_free_timer);
 
 	/* Free our skbs in send and recv queues, if any. */
 	while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
