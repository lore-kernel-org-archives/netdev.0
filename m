From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 17/18] virtio_net: fix TX capacity checks using new API
Date: Wed, 4 May 2011 23:53:03 +0300
Message-ID: <f972a4fea3a8ff973f3a7ac07f2d0e30ad75ea16.1304541919.git.mst@redhat.com>
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

virtio net uses the number of sg entries to
check for TX ring capacity freed. But this
gives incorrect results when indirect buffers
are used. Use the new capacity API instead.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f685324..f33c92b 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -509,19 +509,17 @@ again:
 	return received;
 }
 
-static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
+static void free_old_xmit_skbs(struct virtnet_info *vi)
 {
 	struct sk_buff *skb;
-	unsigned int len, tot_sgs = 0;
+	unsigned int len;
 
 	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 		vi->dev->stats.tx_bytes += skb->len;
 		vi->dev->stats.tx_packets++;
-		tot_sgs += skb_vnet_hdr(skb)->num_sg;
 		dev_kfree_skb_any(skb);
 	}
-	return tot_sgs;
 }
 
 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
@@ -611,7 +609,8 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
 			/* More just got used, free them then recheck. */
-			capacity += free_old_xmit_skbs(vi);
+			free_old_xmit_skbs(vi);
+			capacity = virtqueue_get_capacity(vi->svq);
 			if (capacity >= 2+MAX_SKB_FRAGS) {
 				netif_start_queue(dev);
 				virtqueue_disable_cb(vi->svq);
-- 
1.7.5.53.gc233e
