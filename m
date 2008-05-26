From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/3] virtio: fix delayed xmit of packet and freeing of old packets.
Date: Mon, 26 May 2008 17:48:13 +1000
Message-ID: <200805261748.13449.rusty@rustcorp.com.au>
References: <200805261742.43215.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46692 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752363AbYEZHsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 03:48:35 -0400
In-Reply-To: <200805261742.43215.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because we cache the last failed-to-xmit packet, if there are no
packets queued behind that one we may never send it (reproduced here
as TCP stalls, "cured" by an outgoing ping).

Cc: Mark McLoughlin <markmc@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff -r 1d1ff03de434 drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Mon May 26 11:03:26 2008 +1000
+++ b/drivers/net/virtio_net.c	Mon May 26 16:37:20 2008 +1000
@@ -47,6 +47,9 @@ struct virtnet_info
 	/* Number of input buffers, and max we've ever had. */
 	unsigned int num, max;
 
+	/* For cleaning up after transmission. */
+	struct tasklet_struct tasklet;
+
 	/* Receive & send queues. */
 	struct sk_buff_head recv;
 	struct sk_buff_head send;
@@ -68,8 +71,13 @@ static void skb_xmit_done(struct virtque
 
 	/* Suppress further interrupts. */
 	svq->vq_ops->disable_cb(svq);
+
 	/* We were waiting for more output buffers. */
 	netif_wake_queue(vi->dev);
+
+	/* Make sure we re-xmit last_xmit_skb: if there are no more packets
+	 * queued, start_xmit won't be called. */
+	tasklet_schedule(&vi->tasklet);
 }
 
 static void receive_skb(struct net_device *dev, struct sk_buff *skb,
@@ -278,6 +286,18 @@ static int xmit_skb(struct virtnet_info 
 	return vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
 }
 
+static void xmit_tasklet(unsigned long data)
+{
+	struct virtnet_info *vi = (void *)data;
+
+	netif_tx_lock_bh(vi->dev);
+	if (vi->last_xmit_skb && xmit_skb(vi, vi->last_xmit_skb) == 0) {
+		vi->svq->vq_ops->kick(vi->svq);
+		vi->last_xmit_skb = NULL;
+	}
+	netif_tx_unlock_bh(vi->dev);
+}
+
 static int start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -432,6 +452,8 @@ static int virtnet_probe(struct virtio_d
 	skb_queue_head_init(&vi->recv);
 	skb_queue_head_init(&vi->send);
 
+	tasklet_init(&vi->tasklet, xmit_tasklet, (unsigned long)vi);
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
