From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: [PATCH 2/2] virtio: free transmit skbs when notified,
	not on next xmit.
Date: Mon, 19 Nov 2007 11:25:44 +1100
Message-ID: <200711191125.45065.rusty@rustcorp.com.au>
References: <200711191120.15596.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Anthony Liguori <aliguori-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lguest <lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
In-Reply-To: <200711191120.15596.rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

This fixes a potential dangling xmit problem.

We also suppress refill interrupts until we need them.
(Anthony and I have been working on performance recently, so this
is a WIP).

Signed-off-by: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>

diff -r 586fb6ff29dd drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Thu Nov 15 23:19:12 2007 +1100
+++ b/drivers/net/virtio_net.c	Thu Nov 15 23:21:18 2007 +1100
@@ -35,6 +35,8 @@ struct virtnet_info
 	struct net_device *dev;
 	struct napi_struct napi;
 
+	struct tasklet_struct xmit_free;
+
 	/* TX coalescing. */
 	struct hrtimer tx_timer;
 
@@ -59,13 +61,40 @@ static inline void vnet_hdr_to_sg(struct
 	sg_init_one(sg, skb_vnet_hdr(skb), sizeof(struct virtio_net_hdr));
 }
 
+static unsigned free_old_xmit_skbs(struct virtnet_info *vi)
+{
+	struct sk_buff *skb;
+	unsigned int len, i = 0;
+
+	while ((skb = vi->svq->vq_ops->get_buf(vi->svq, &len)) != NULL) {
+		pr_debug("Sent skb %p\n", skb);
+		__skb_unlink(skb, &vi->send);
+		vi->dev->stats.tx_bytes += len;
+		vi->dev->stats.tx_packets++;
+		kfree_skb(skb);
+		i++;
+	}
+	return i;
+}
+
+static void xmit_free(unsigned long data)
+{
+	struct virtnet_info *vi = (void *)data;
+
+	netif_tx_lock(vi->dev);
+	free_old_xmit_skbs(vi);
+	netif_tx_unlock(vi->dev);
+
+	/* In case we were waiting for output buffers. */
+	netif_wake_queue(vi->dev);
+}	
+
 static bool skb_xmit_done(struct virtqueue *rvq)
 {
 	struct virtnet_info *vi = rvq->vdev->priv;
 
-	/* In case we were waiting for output buffers. */
-	netif_wake_queue(vi->dev);
-	return true;
+	tasklet_schedule(&vi->xmit_free);
+	return false;
 }
 
 static void receive_skb(struct net_device *dev, struct sk_buff *skb,
@@ -216,20 +245,6 @@ again:
 	return received;
 }
 
-static void free_old_xmit_skbs(struct virtnet_info *vi)
-{
-	struct sk_buff *skb;
-	unsigned int len;
-
-	while ((skb = vi->svq->vq_ops->get_buf(vi->svq, &len)) != NULL) {
-		pr_debug("Sent skb %p\n", skb);
-		__skb_unlink(skb, &vi->send);
-		vi->dev->stats.tx_bytes += len;
-		vi->dev->stats.tx_packets++;
-		kfree_skb(skb);
-	}
-}
-
 static enum hrtimer_restart kick_xmit(struct hrtimer *t)
 {
 	struct virtnet_info *vi = container_of(t,struct virtnet_info,tx_timer);
@@ -256,8 +271,6 @@ static int start_xmit(struct sk_buff *sk
 	sg_init_table(sg, 1+MAX_SKB_FRAGS);
 
 	pr_debug("%s: xmit %p %s\n", dev->name, skb, print_mac(mac, dest));
-
-	free_old_xmit_skbs(vi);
 
 	/* Encode metadata header at front. */
 	hdr = skb_vnet_hdr(skb);
@@ -290,11 +303,25 @@ static int start_xmit(struct sk_buff *sk
 	vnet_hdr_to_sg(sg, skb);
 	num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 	__skb_queue_head(&vi->send, skb);
+
+again:
 	err = vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
 	if (err) {
+		/* Can we free any used skbs? */
+		if (free_old_xmit_skbs(vi))
+			goto again;
+
+		/* Activate callback for using skbs: if this fails it
+		 * means some were used in the meantime. */
+		if (unlikely(!vi->svq->vq_ops->restart(vi->svq))) {
+			printk("Unlikely: restart svq failed\n");
+			goto again;
+		}
+
+		__skb_unlink(skb, &vi->send);
+
 		pr_debug("%s: virtio not prepared to send\n", dev->name);
-		skb_unlink(skb, &vi->send);
 		if (vi->out_max != vi->out_num)
 			printk("%s: out_max changed from %u to %u\n",
 			       dev->name, vi->out_max, vi->out_num);
 		vi->out_max = vi->out_num;
@@ -400,5 +428,7 @@ static int virtnet_probe(struct virtio_d
 	vi->out_max = -1U;
 
+	tasklet_init(&vi->xmit_free, xmit_free, (unsigned long)vi);
+	
 	/* We expect two virtqueues, receive then send. */
 	vi->rvq = vdev->config->find_vq(vdev, 0, skb_recv_done);
 	if (IS_ERR(vi->rvq)) {
