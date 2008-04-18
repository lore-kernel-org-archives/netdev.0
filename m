From: Rusty Russell <rusty@rustcorp.com.au>
Subject: virtio: wean net driver off NETDEV_TX_BUSY
Date: Fri, 18 Apr 2008 14:17:30 +1000
Message-ID: <200804181417.31505.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38551 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750707AbYDRERw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 00:17:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert tells me that returning NETDEV_TX_BUSY from hard_start_xmit is
seen as a poor thing to do; we should cache the packet and stop the queue.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   57 +++++++++++++++++++++++++++++++----------------
 1 file changed, 38 insertions(+), 19 deletions(-)

diff -r a936d320f6d5 drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Thu Apr 17 05:03:18 2008 +1000
+++ b/drivers/net/virtio_net.c	Thu Apr 17 06:15:40 2008 +1000
@@ -40,6 +40,9 @@ struct virtnet_info
 	struct virtqueue *rvq, *svq;
 	struct net_device *dev;
 	struct napi_struct napi;
+
+	/* The skb we couldn't send because buffers were full. */
+	struct sk_buff *last_xmit_skb;
 
 	/* Number of input buffers, and max we've ever had. */
 	unsigned int num, max;
@@ -227,10 +230,9 @@ static void free_old_xmit_skbs(struct vi
 	}
 }
 
-static int start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 {
-	struct virtnet_info *vi = netdev_priv(dev);
-	int num, err;
+	int num;
 	struct scatterlist sg[1+MAX_SKB_FRAGS];
 	struct virtio_net_hdr *hdr;
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
@@ -238,7 +240,7 @@ static int start_xmit(struct sk_buff *sk
 
 	sg_init_table(sg, 1+MAX_SKB_FRAGS);
 
-	pr_debug("%s: xmit %p %s\n", dev->name, skb, print_mac(mac, dest));
+	pr_debug("%s: xmit %p %s\n", vi->dev->name, skb, print_mac(mac, dest));
 
 	/* Encode metadata header at front. */
 	hdr = skb_vnet_hdr(skb);
@@ -271,30 +273,47 @@ static int start_xmit(struct sk_buff *sk
 
 	vnet_hdr_to_sg(sg, skb);
 	num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
-	__skb_queue_head(&vi->send, skb);
+
+	return vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
+}
+
+static int start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
 
 again:
 	/* Free up any pending old buffers before queueing new ones. */
 	free_old_xmit_skbs(vi);
-	err = vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
-	if (err) {
-		pr_debug("%s: virtio not prepared to send\n", dev->name);
-		netif_stop_queue(dev);
 
-		/* Activate callback for using skbs: if this returns false it
-		 * means some were used in the meantime. */
-		if (unlikely(!vi->svq->vq_ops->enable_cb(vi->svq))) {
-			vi->svq->vq_ops->disable_cb(vi->svq);
-			netif_start_queue(dev);
-			goto again;
-		}
-		__skb_unlink(skb, &vi->send);
+	/* If we has a buffer left over from last time, send it now. */
+	if (vi->last_xmit_skb) {
+		if (xmit_skb(vi, vi->last_xmit_skb) != 0)
+			goto stop_queue;
+		vi->last_xmit_skb = NULL;
+	}
 
-		return NETDEV_TX_BUSY;
+	/* Put new one in send queue and do transmit */
+	__skb_queue_head(&vi->send, skb);
+	if (xmit_skb(vi, skb) != 0) {
+		vi->last_xmit_skb = skb;
+		goto stop_queue;
 	}
+done:
 	vi->svq->vq_ops->kick(vi->svq);
+	return NETDEV_TX_OK;
 
-	return 0;
+stop_queue:
+	pr_debug("%s: virtio not prepared to send\n", dev->name);
+	netif_stop_queue(dev);
+
+	/* Activate callback for using skbs: if this returns false it
+	 * means some were used in the meantime. */
+	if (unlikely(!vi->svq->vq_ops->enable_cb(vi->svq))) {
+		vi->svq->vq_ops->disable_cb(vi->svq);
+		netif_start_queue(dev);
+		goto again;
+	}
+	goto done;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
