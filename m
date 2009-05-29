From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 3/4] virtio_net: don't free buffers in xmit ring
Date: Fri, 29 May 2009 23:46:23 +0930
Message-ID: <200905292346.24141.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39000 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758046AbZE2OQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 10:16:27 -0400
Cc: Mark McLoughlin <markmc@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The virtio_net driver is complicated by the two methods of freeing old
xmit buffers (in addition to freeing old ones at the start of the xmit
path).

The original code used a 1/10 second timer attached to xmit_free(),
reset on every xmit.  Before we orphaned skbs on xmit, the
transmitting userspace could block with a full socket until the timer
fired, the skb destructor was called, and they were re-woken.

So we added the VIRTIO_F_NOTIFY_ON_EMPTY feature: supporting devices
send an interrupt (even if normally suppressed) on an empty xmit ring
which makes us schedule xmit_tasklet().  This was a benchmark win.

Unfortunately, VIRTIO_F_NOTIFY_ON_EMPTY makes quite a lot of work: a
host which is faster than the guest will fire the interrupt every xmit
packet (slowing the guest down further).  Attempting mitigation in the
host adds overhead of userspace timers (possibly with the additional
pain of signals), and risks increasing latency anyway if you get it
wrong.

In practice, this effect was masked by benchmarks which take advantage
of GSO (with its inherent transmit batching), but it's still there.

Now we orphan xmitted skbs, the pressure is off: remove both paths and
no longer request VIRTIO_F_NOTIFY_ON_EMPTY.  Note that the current
QEMU will notify us even if we don't negotiate this feature (legal,
but suboptimal); a patch is outstanding to improve that.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Cc: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/virtio_net.c |   56 +----------------------------------------------
 1 file changed, 2 insertions(+), 54 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -47,16 +47,9 @@ struct virtnet_info
 	struct napi_struct napi;
 	unsigned int status;
 
-	/* If we need to free in a timer, this is it. */
-	struct timer_list xmit_free_timer;
-
 	/* Number of input buffers, and max we've ever had. */
 	unsigned int num, max;
 
-	/* For cleaning up after transmission. */
-	struct tasklet_struct tasklet;
-	bool free_in_tasklet;
-
 	/* I like... big packets and I cannot lie! */
 	bool big_packets;
 
@@ -112,9 +105,6 @@ static void skb_xmit_done(struct virtque
 
 	/* We were probably waiting for more output buffers. */
 	netif_wake_queue(vi->dev);
-
-	if (vi->free_in_tasklet)
-		tasklet_schedule(&vi->tasklet);
 }
 
 static void receive_skb(struct net_device *dev, struct sk_buff *skb,
@@ -428,25 +418,9 @@ static void free_old_xmit_skbs(struct vi
 	}
 }
 
-/* If the virtio transport doesn't always notify us when all in-flight packets
- * are consumed, we fall back to using this function on a timer to free them. */
-static void xmit_free(unsigned long data)
-{
-	struct virtnet_info *vi = (void *)data;
-
-	netif_tx_lock(vi->dev);
-
-	free_old_xmit_skbs(vi);
-
-	if (!skb_queue_empty(&vi->send))
-		mod_timer(&vi->xmit_free_timer, jiffies + (HZ/10));
-
-	netif_tx_unlock(vi->dev);
-}
-
 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 {
-	int num, err;
+	int num;
 	struct scatterlist sg[2+MAX_SKB_FRAGS];
 	struct virtio_net_hdr_mrg_rxbuf *mhdr = skb_vnet_hdr(skb);
 	struct virtio_net_hdr *hdr = skb_vnet_hdr(skb);
@@ -493,20 +467,7 @@ static int xmit_skb(struct virtnet_info 
 
 	num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 
-	err = vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
-	if (!err && !vi->free_in_tasklet)
-		mod_timer(&vi->xmit_free_timer, jiffies + (HZ/10));
-
-	return err;
-}
-
-static void xmit_tasklet(unsigned long data)
-{
-	struct virtnet_info *vi = (void *)data;
-
-	netif_tx_lock_bh(vi->dev);
-	free_old_xmit_skbs(vi);
-	netif_tx_unlock_bh(vi->dev);
+	return vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
 }
 
 static int start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -869,10 +830,6 @@ static int virtnet_probe(struct virtio_d
 	vdev->priv = vi;
 	vi->pages = NULL;
 
-	/* If they give us a callback when all buffers are done, we don't need
-	 * the timer. */
-	vi->free_in_tasklet = virtio_has_feature(vdev,VIRTIO_F_NOTIFY_ON_EMPTY);
-
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4)
 	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6)
@@ -904,11 +861,6 @@ static int virtnet_probe(struct virtio_d
 	skb_queue_head_init(&vi->recv);
 	skb_queue_head_init(&vi->send);
 
-	tasklet_init(&vi->tasklet, xmit_tasklet, (unsigned long)vi);
-
-	if (!vi->free_in_tasklet)
-		setup_timer(&vi->xmit_free_timer, xmit_free, (unsigned long)vi);
-
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
@@ -948,9 +900,6 @@ static void virtnet_remove(struct virtio
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
-	if (!vi->free_in_tasklet)
-		del_timer_sync(&vi->xmit_free_timer);
-
 	/* Free our skbs in send and recv queues, if any. */
 	while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
 		kfree_skb(skb);
@@ -983,7 +932,6 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
-	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
 static struct virtio_driver virtio_net = {


