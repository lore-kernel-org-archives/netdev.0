From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC 3/3] virtio_net: limit xmit polling
Date: Wed, 1 Jun 2011 12:50:03 +0300
Message-ID: <1ec8eec325839ecf2eac9930a230361e7956047c.1306921434.git.mst@redhat.com>
References: <cover.1306921434.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1306921434.git.mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Current code might introduce a lot of latency variation
if there are many pending bufs at the time we
attempt to transmit a new one. This is bad for
real-time applications and can't be good for TCP either.

Free up just enough to both clean up all buffers
eventually and to be able to xmit the next packet.

Signed-off-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/virtio_net.c |   62 ++++++++++++++++++++++++++--------------------
 1 files changed, 35 insertions(+), 27 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index a0ee78d..6045510 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -509,17 +509,27 @@ again:
 	return received;
 }
 
-static void free_old_xmit_skbs(struct virtnet_info *vi)
+/* Check capacity and try to free enough pending old buffers to enable queueing
+ * new ones.  If min_skbs > 0, try to free at least the specified number of skbs
+ * even if the ring already has sufficient capacity.  Return true if we can
+ * guarantee that a following virtqueue_add_buf will succeed. */
+static bool free_old_xmit_skbs(struct virtnet_info *vi, int min_skbs)
 {
 	struct sk_buff *skb;
 	unsigned int len;
+	bool r;
 
-	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
+	while ((r = virtqueue_min_capacity(vi->svq) < MAX_SKB_FRAGS + 2) ||
+	       min_skbs-- > 0) {
+		skb = virtqueue_get_buf(vi->svq, &len);
+		if (unlikely(!skb))
+			break;
 		pr_debug("Sent skb %p\n", skb);
 		vi->dev->stats.tx_bytes += skb->len;
 		vi->dev->stats.tx_packets++;
 		dev_kfree_skb_any(skb);
 	}
+	return r;
 }
 
 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
@@ -572,27 +582,24 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-	int capacity;
+	int ret, n;
 
-	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(vi);
+	/* Free up space in the ring in case this is the first time we get
+	 * woken up after ring full condition.  Note: this might try to free
+	 * more than strictly necessary if the skb has a small
+	 * number of fragments, but keep it simple. */
+	free_old_xmit_skbs(vi, 0);
 
 	/* Try to transmit */
-	capacity = xmit_skb(vi, skb);
-
-	/* This can happen with OOM and indirect buffers. */
-	if (unlikely(capacity < 0)) {
-		if (net_ratelimit()) {
-			if (likely(capacity == -ENOMEM)) {
-				dev_warn(&dev->dev,
-					 "TX queue failure: out of memory\n");
-			} else {
-				dev->stats.tx_fifo_errors++;
-				dev_warn(&dev->dev,
-					 "Unexpected TX queue failure: %d\n",
-					 capacity);
-			}
-		}
+	ret = xmit_skb(vi, skb);
+
+	/* Failure to queue is unlikely. It's not a bug though: it might happen
+	 * if we get an interrupt while the queue is still mostly full.
+	 * We could stop the queue and re-enable callbacks (and possibly return
+	 * TX_BUSY), but as this should be rare, we don't bother. */
+	if (unlikely(ret < 0)) {
+		if (net_ratelimit())
+			dev_info(&dev->dev, "TX queue failure: %d\n", ret);
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
@@ -603,15 +610,16 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_orphan(skb);
 	nf_reset(skb);
 
-	/* Apparently nice girls don't return TX_BUSY; stop the queue
-	 * before it gets out of hand.  Naturally, this wastes entries. */
-	if (capacity < 2+MAX_SKB_FRAGS) {
+	/* Apparently nice girls don't return TX_BUSY; check capacity and stop
+	 * the queue before it gets out of hand.
+	 * Naturally, this wastes entries. */
+	/* We transmit one skb, so try to free at least two pending skbs.
+	 * This is so that we don't hog the skb memory unnecessarily. */
+	if (!likely(free_old_xmit_skbs(vi, 2))) {
 		netif_stop_queue(dev);
 		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
-			/* More just got used, free them then recheck. */
-			free_old_xmit_skbs(vi);
-			capacity = virtqueue_min_capacity(vi->svq);
-			if (capacity >= 2+MAX_SKB_FRAGS) {
+			/* More just got used, free them and recheck. */
+			if (!likely(free_old_xmit_skbs(vi, 0))) {
 				netif_start_queue(dev);
 				virtqueue_disable_cb(vi->svq);
 			}
-- 
1.7.5.53.gc233e
