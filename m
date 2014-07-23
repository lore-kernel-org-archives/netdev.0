From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH v3 net-next 2/2] virtio-net: rx busy polling support
Date: Wed, 23 Jul 2014 16:33:55 +0800
Message-ID: <1406104435-24077-3-git-send-email-jasowang@redhat.com>
References: <1406104435-24077-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1406104435-24077-1-git-send-email-jasowang@redhat.com>
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

Add basic support for rx busy polling. Instead of introducing new
states and spinlock to synchronize between NAPI and polling method,
this patch just reuse NAPI state to avoid extra overhead for fast path
and simplified the codes.

Test was done between a kvm guest and an external host. Two hosts were
connected through 40gb mlx4 cards. With both busy_poll and busy_read
are set to 50 in guest, 1 byte netperf tcp_rr shows 127% improvement:
transaction rate was increased from 8353.33 to 18966.87.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 48 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 47 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b647d0d..59caa06 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -27,6 +27,7 @@
 #include <linux/slab.h>
 #include <linux/cpu.h>
 #include <linux/average.h>
+#include <net/busy_poll.h>
 
 static int napi_weight = NAPI_POLL_WEIGHT;
 module_param(napi_weight, int, 0444);
@@ -521,6 +522,8 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		skb_shinfo(skb)->gso_segs = 0;
 	}
 
+	skb_mark_napi_id(skb, &rq->napi);
+
 	netif_receive_skb(skb);
 	return;
 
@@ -769,6 +772,43 @@ again:
 	return received;
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+/* must be called with local_bh_disable()d */
+static int virtnet_busy_poll(struct napi_struct *napi)
+{
+	struct receive_queue *rq =
+		container_of(napi, struct receive_queue, napi);
+	struct virtnet_info *vi = rq->vq->vdev->priv;
+	int r, received = 0, budget = 4;
+
+	if (!(vi->status & VIRTIO_NET_S_LINK_UP))
+		return LL_FLUSH_FAILED;
+
+	if (!napi_schedule_prep(napi))
+		return LL_FLUSH_BUSY;
+
+	virtqueue_disable_cb(rq->vq);
+
+again:
+	received += virtnet_receive(rq, budget);
+
+	r = virtqueue_enable_cb_prepare(rq->vq);
+	clear_bit(NAPI_STATE_SCHED, &napi->state);
+	if (unlikely(virtqueue_poll(rq->vq, r)) &&
+	    napi_schedule_prep(napi)) {
+		virtqueue_disable_cb(rq->vq);
+		if (received < budget) {
+			budget -= received;
+			goto again;
+		} else {
+			__napi_schedule(napi);
+		}
+	}
+
+	return received;
+}
+#endif	/* CONFIG_NET_RX_BUSY_POLL */
+
 static int virtnet_open(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -1356,6 +1396,9 @@ static const struct net_device_ops virtnet_netdev = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	.ndo_busy_poll		= virtnet_busy_poll,
+#endif
 };
 
 static void virtnet_config_changed_work(struct work_struct *work)
@@ -1561,6 +1604,7 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 		vi->rq[i].pages = NULL;
 		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
 			       napi_weight);
+		napi_hash_add(&vi->rq[i].napi);
 
 		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
 		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
@@ -1862,11 +1906,13 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	netif_device_detach(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
 
-	if (netif_running(vi->dev))
+	if (netif_running(vi->dev)) {
 		for (i = 0; i < vi->max_queue_pairs; i++) {
 			napi_disable(&vi->rq[i].napi);
+			napi_hash_del(&vi->rq[i].napi);
 			netif_napi_del(&vi->rq[i].napi);
 		}
+	}
 
 	remove_vq_common(vi);
 
-- 
1.8.3.1
