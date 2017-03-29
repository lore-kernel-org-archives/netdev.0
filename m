From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2] virtio_net: fix support for small rings
Date: Wed, 29 Mar 2017 20:42:31 +0300
Message-ID: <1490809332-14457-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

When ring size is small (<32 entries) making buffers smaller means a
full ring might not be able to hold enough buffers to fit a single large
packet.

Make sure a ring full of buffers is large enough to allow at least one
packet of max size.

Fixes: 2613af0ed18a ("virtio_net: migrate mergeable rx buffers to page frag allocators")
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

changes from v1:
	typo fix

 drivers/net/virtio_net.c | 30 ++++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9dc31dc..e5f6e34 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -29,6 +29,7 @@
 #include <linux/slab.h>
 #include <linux/cpu.h>
 #include <linux/average.h>
+#include <net/route.h>
 
 static int napi_weight = NAPI_POLL_WEIGHT;
 module_param(napi_weight, int, 0444);
@@ -98,6 +99,9 @@ struct receive_queue {
 	/* RX: fragments + linear part + virtio header */
 	struct scatterlist sg[MAX_SKB_FRAGS + 2];
 
+	/* Min single buffer size for mergeable buffers case. */
+	unsigned int min_buf_len;
+
 	/* Name of this receive queue: input.$index */
 	char name[40];
 };
@@ -894,13 +898,14 @@ static int add_recvbuf_big(struct virtnet_info *vi, struct receive_queue *rq,
 	return err;
 }
 
-static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
+static unsigned int get_mergeable_buf_len(struct receive_queue *rq,
+					  struct ewma_pkt_len *avg_pkt_len)
 {
 	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
 	unsigned int len;
 
 	len = hdr_len + clamp_t(unsigned int, ewma_pkt_len_read(avg_pkt_len),
-			GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
+				rq->min_buf_len - hdr_len, PAGE_SIZE - hdr_len);
 	return ALIGN(len, L1_CACHE_BYTES);
 }
 
@@ -914,7 +919,7 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi,
 	int err;
 	unsigned int len, hole;
 
-	len = get_mergeable_buf_len(&rq->mrg_avg_pkt_len);
+	len = get_mergeable_buf_len(rq, &rq->mrg_avg_pkt_len);
 	if (unlikely(!skb_page_frag_refill(len + headroom, alloc_frag, gfp)))
 		return -ENOMEM;
 
@@ -2086,6 +2091,21 @@ static void virtnet_del_vqs(struct virtnet_info *vi)
 	virtnet_free_queues(vi);
 }
 
+/* How large should a single buffer be so a queue full of these can fit at
+ * least one full packet?
+ * Logic below assumes the mergeable buffer header is used.
+ */
+static unsigned int mergeable_min_buf_len(struct virtnet_info *vi, struct virtqueue *vq)
+{
+	const unsigned int hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
+	unsigned int rq_size = virtqueue_get_vring_size(vq);
+	unsigned int packet_len = vi->big_packets ? IP_MAX_MTU : vi->dev->max_mtu;
+	unsigned int buf_len = hdr_len + ETH_HLEN + VLAN_HLEN + packet_len;
+	unsigned int min_buf_len = DIV_ROUND_UP(buf_len, rq_size);
+
+	return max(min_buf_len, hdr_len);
+}
+
 static int virtnet_find_vqs(struct virtnet_info *vi)
 {
 	vq_callback_t **callbacks;
@@ -2151,6 +2171,7 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
 
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		vi->rq[i].vq = vqs[rxq2vq(i)];
+		vi->rq[i].min_buf_len = mergeable_min_buf_len(vi, vi->rq[i].vq);
 		vi->sq[i].vq = vqs[txq2vq(i)];
 	}
 
@@ -2237,7 +2258,8 @@ static ssize_t mergeable_rx_buffer_size_show(struct netdev_rx_queue *queue,
 
 	BUG_ON(queue_index >= vi->max_queue_pairs);
 	avg = &vi->rq[queue_index].mrg_avg_pkt_len;
-	return sprintf(buf, "%u\n", get_mergeable_buf_len(avg));
+	return sprintf(buf, "%u\n",
+		       get_mergeable_buf_len(&vi->rq[queue_index], avg));
 }
 
 static struct rx_queue_attribute mergeable_rx_buffer_size_attribute =
-- 
MST
