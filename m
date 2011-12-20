From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] virtio_net: fix refill related races
Date: Tue, 20 Dec 2011 23:01:06 +0200
Message-ID: <20111220210105.GA28790@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Amit Shah <amit.shah@redhat.com>, Tejun Heo <tj@kernel.org>
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

Fix theoretical races related to refill work:
1. After napi is disabled by ndo_stop, refill work
   can run and re-enable it.
2. Refill can get scheduled on many cpus in parallel.
   if this happens it will corrupt the vq linked list
   as there's no locking
3. refill work is cancelled after unregister netdev
   For small bufs this means it can alloc an skb
   for a device which is unregistered which is
   not a good idea.

As a solution, add flag to track napi state
and toggle it on start/stop
check on refill. Add a mutex to pretect the flag,
as well as serial refills.

Move refill cancellation to after unregister.

refill work structure and new fields aren't used
on data path, so put them together near the end of
struct virtnet_info.

TODO: consider using system_nrq_wq as suggested by
Tejun Heo. Probably be a good idea but not  a must for
correctness.

Lightly tested.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c |   34 +++++++++++++++++++++++++++-------
 1 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 6ee8410..452f186 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -21,6 +21,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/module.h>
+#include <linux/mutex.h>
 #include <linux/virtio.h>
 #include <linux/virtio_net.h>
 #include <linux/scatterlist.h>
@@ -68,15 +69,21 @@ struct virtnet_info {
 	/* Active statistics */
 	struct virtnet_stats __percpu *stats;
 
-	/* Work struct for refilling if we run low on memory. */
-	struct delayed_work refill;
-
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
 	/* fragments + linear part + virtio header */
 	struct scatterlist rx_sg[MAX_SKB_FRAGS + 2];
 	struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
+
+	/* Work struct for refilling if we run low on memory. */
+	struct delayed_work refill;
+
+	/* Whether napi is enabled, protected by a refill_lock. */
+	bool napi_enable;
+
+	/* Lock to protect refill and napi enable/disable operations. */
+	struct mutex refill_lock;
 };
 
 struct skb_vnet_hdr {
@@ -494,14 +501,20 @@ static void refill_work(struct work_struct *work)
 	bool still_empty;
 
 	vi = container_of(work, struct virtnet_info, refill.work);
-	napi_disable(&vi->napi);
+
+	mutex_lock(&vi->refill_lock);
+	if (vi->napi_enable)
+		napi_disable(&vi->napi);
 	still_empty = !try_fill_recv(vi, GFP_KERNEL);
-	virtnet_napi_enable(vi);
+	if (vi->napi_enable)
+		virtnet_napi_enable(vi);
 
 	/* In theory, this can happen: if we don't get any buffers in
 	 * we will *never* try to fill again. */
 	if (still_empty)
 		schedule_delayed_work(&vi->refill, HZ/2);
+
+	mutex_unlock(&vi->refill_lock);
 }
 
 static int virtnet_poll(struct napi_struct *napi, int budget)
@@ -719,7 +732,10 @@ static int virtnet_open(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
+	mutex_lock(&vi->refill_lock);
+	vi->napi_enable = true;
 	virtnet_napi_enable(vi);
+	mutex_unlock(&vi->refill_lock);
 	return 0;
 }
 
@@ -772,7 +788,10 @@ static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
+	mutex_lock(&vi->refill_lock);
+	vi->napi_enable = false;
 	napi_disable(&vi->napi);
+	mutex_unlock(&vi->refill_lock);
 
 	return 0;
 }
@@ -1021,6 +1040,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (vi->stats == NULL)
 		goto free;
 
+	mutex_init(&vi->refill_lock);
 	INIT_DELAYED_WORK(&vi->refill, refill_work);
 	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
 	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
@@ -1081,8 +1101,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	return 0;
 
 unregister:
-	unregister_netdev(dev);
 	cancel_delayed_work_sync(&vi->refill);
+	unregister_netdev(dev);
 free_vqs:
 	vdev->config->del_vqs(vdev);
 free_stats:
@@ -1121,9 +1141,9 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
+	cancel_delayed_work_sync(&vi->refill);
 
 	unregister_netdev(vi->dev);
-	cancel_delayed_work_sync(&vi->refill);
 
 	/* Free unused buffers in both send and recv, if any. */
 	free_unused_bufs(vi);
-- 
1.7.5.53.gc233e
