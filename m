From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCHv2 10/14] virtio_net: limit xmit polling
Date: Fri, 20 May 2011 02:11:56 +0300
Message-ID: <aced8619c07018b5495f9ceb2c02d4fbf897a098.1305846412.git.mst@redhat.com>
References: <cover.1305846412.git.mst@redhat.com>
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
In-Reply-To: <cover.1305846412.git.mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
 drivers/net/virtio_net.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f33c92b..42935cb 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -509,17 +509,25 @@ again:
 	return received;
 }
 
-static void free_old_xmit_skbs(struct virtnet_info *vi)
+static bool free_old_xmit_skbs(struct virtnet_info *vi, int capacity)
 {
 	struct sk_buff *skb;
 	unsigned int len;
-
-	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
+	bool c;
+	int n;
+
+	/* We try to free up at least 2 skbs per one sent, so that we'll get
+	 * all of the memory back if they are used fast enough. */
+	for (n = 0;
+	     ((c = virtqueue_get_capacity(vi->svq) < capacity) || n < 2) &&
+	     ((skb = virtqueue_get_buf(vi->svq, &len)));
+	     ++n) {
 		pr_debug("Sent skb %p\n", skb);
 		vi->dev->stats.tx_bytes += skb->len;
 		vi->dev->stats.tx_packets++;
 		dev_kfree_skb_any(skb);
 	}
+	return !c;
 }
 
 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
@@ -574,8 +582,8 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct virtnet_info *vi = netdev_priv(dev);
 	int capacity;
 
-	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(vi);
+	/* Free enough pending old buffers to enable queueing new ones. */
+	free_old_xmit_skbs(vi, 2+MAX_SKB_FRAGS);
 
 	/* Try to transmit */
 	capacity = xmit_skb(vi, skb);
@@ -609,9 +617,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
 			/* More just got used, free them then recheck. */
-			free_old_xmit_skbs(vi);
-			capacity = virtqueue_get_capacity(vi->svq);
-			if (capacity >= 2+MAX_SKB_FRAGS) {
+			if (!likely(free_old_xmit_skbs(vi, 2+MAX_SKB_FRAGS))) {
 				netif_start_queue(dev);
 				virtqueue_disable_cb(vi->svq);
 			}
-- 
1.7.5.53.gc233e
