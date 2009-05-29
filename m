From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of queueing an extra skb.
Date: Fri, 29 May 2009 23:46:04 +0930
Message-ID: <200905292346.04815.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38989 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757472AbZE2OQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 10:16:06 -0400
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This effectively reverts 99ffc696d10b28580fe93441d627cf290ac4484c
"virtio: wean net driver off NETDEV_TX_BUSY".

The complexity of queuing an skb (setting a tasklet to re-xmit) is
questionable, especially once we get rid of the other reason for the
tasklet in the next patch.

If the skb won't fit in the tx queue, just return NETDEV_TX_BUSY.  It
might be frowned upon, but it's common and not going away any time
soon.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 drivers/net/virtio_net.c |   49 ++++++++++-------------------------------------
 1 file changed, 11 insertions(+), 38 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -47,9 +47,6 @@ struct virtnet_info
 	struct napi_struct napi;
 	unsigned int status;
 
-	/* The skb we couldn't send because buffers were full. */
-	struct sk_buff *last_xmit_skb;
-
 	/* If we need to free in a timer, this is it. */
 	struct timer_list xmit_free_timer;
 
@@ -116,9 +113,8 @@ static void skb_xmit_done(struct virtque
 	/* We were probably waiting for more output buffers. */
 	netif_wake_queue(vi->dev);
 
-	/* Make sure we re-xmit last_xmit_skb: if there are no more packets
-	 * queued, start_xmit won't be called. */
-	tasklet_schedule(&vi->tasklet);
+	if (vi->free_in_tasklet)
+		tasklet_schedule(&vi->tasklet);
 }
 
 static void receive_skb(struct net_device *dev, struct sk_buff *skb,
@@ -509,12 +505,7 @@ static void xmit_tasklet(unsigned long d
 	struct virtnet_info *vi = (void *)data;
 
 	netif_tx_lock_bh(vi->dev);
-	if (vi->last_xmit_skb && xmit_skb(vi, vi->last_xmit_skb) == 0) {
-		vi->svq->vq_ops->kick(vi->svq);
-		vi->last_xmit_skb = NULL;
-	}
-	if (vi->free_in_tasklet)
-		free_old_xmit_skbs(vi);
+	free_old_xmit_skbs(vi);
 	netif_tx_unlock_bh(vi->dev);
 }
 
@@ -526,27 +517,14 @@ again:
 	/* Free up any pending old buffers before queueing new ones. */
 	free_old_xmit_skbs(vi);
 
-	/* If we has a buffer left over from last time, send it now. */
-	if (unlikely(vi->last_xmit_skb) &&
-	    xmit_skb(vi, vi->last_xmit_skb) != 0)
-		goto stop_queue;
+	/* Put new one in send queue and do transmit */
+	__skb_queue_head(&vi->send, skb);
+	if (likely(xmit_skb(vi, skb) == 0)) {
+		vi->svq->vq_ops->kick(vi->svq);
+		return NETDEV_TX_OK;
+	}
 
-	vi->last_xmit_skb = NULL;
-
-	/* Put new one in send queue and do transmit */
-	if (likely(skb)) {
-		__skb_queue_head(&vi->send, skb);
-		if (xmit_skb(vi, skb) != 0) {
-			vi->last_xmit_skb = skb;
-			skb = NULL;
-			goto stop_queue;
-		}
-	}
-done:
-	vi->svq->vq_ops->kick(vi->svq);
-	return NETDEV_TX_OK;
-
-stop_queue:
+	/* Ring too full for this packet. */
 	pr_debug("%s: virtio not prepared to send\n", dev->name);
 	netif_stop_queue(dev);
 
@@ -557,12 +535,7 @@ stop_queue:
 		netif_start_queue(dev);
 		goto again;
 	}
-	if (skb) {
-		/* Drop this skb: we only queue one. */
-		vi->dev->stats.tx_dropped++;
-		kfree_skb(skb);
-	}
-	goto done;
+	return NETDEV_TX_BUSY;
 }
 
 static int virtnet_set_mac_address(struct net_device *dev, void *p)


