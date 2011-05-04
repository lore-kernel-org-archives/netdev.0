From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 18/18] virtio_net: limit xmit polling
Date: Wed, 4 May 2011 23:53:13 +0300
Message-ID: <5964e2f3d6aac5cd48f467848eed6570517470ef.1304541919.git.mst@redhat.com>
References: <cover.1304541918.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, Carsten Otte <cotte@de.ibm.com>,
        lguest@lists.ozlabs.org, Shirley Ma <xma@us.ibm.com>,
        kvm@vger.kernel.org, linux-s390@vger.kernel.org,
        netdev@vger.kernel.org, habanero@linux.vnet.ibm.com,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, steved@us.ibm.com,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Tom Lendacky <tahm@linux.vnet.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1304541918.git.mst@redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Current code might introduce a lot of latency variation
if there are many pending bufs at the time we
attempt to transmit a new one. This is bad for
real-time applications and can't be good for TCP either.

Free up just enough to both clean up all buffers
eventually and to be able to xmit the next packet.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f33c92b..9982bd7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -509,17 +509,23 @@ again:
 	return received;
 }
 
-static void free_old_xmit_skbs(struct virtnet_info *vi)
+static bool free_old_xmit_skbs(struct virtnet_info *vi, int capacity)
 {
 	struct sk_buff *skb;
 	unsigned int len;
+	bool c;
+	/* We try to free up at least 2 skbs per one sent, so that we'll get
+	 * all of the memory back if they are used fast enough. */
+	int n = 2;
 
-	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
+	while ((c = virtqueue_get_capacity(vi->svq) >= capacity) && --n > 0 &&
+	       (skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 		vi->dev->stats.tx_bytes += skb->len;
 		vi->dev->stats.tx_packets++;
 		dev_kfree_skb_any(skb);
 	}
+	return c;
 }
 
 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
@@ -574,8 +580,8 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct virtnet_info *vi = netdev_priv(dev);
 	int capacity;
 
-	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(vi);
+	/* Free enough pending old buffers to enable queueing new ones. */
+	free_old_xmit_skbs(vi, 2+MAX_SKB_FRAGS);
 
 	/* Try to transmit */
 	capacity = xmit_skb(vi, skb);
@@ -609,9 +615,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
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
