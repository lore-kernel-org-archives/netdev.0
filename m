From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] virtio_net: fix refill related races
Date: Wed, 7 Dec 2011 17:21:22 +0200
Message-ID: <20111207152120.GA23417@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Amit Shah <amit.shah@redhat.com>
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
2. Refill can reschedule itself, if this happens
   it can run after cancel_delayed_work_sync,
   and will access device after it is destroyed.

As a solution, add flags to track napi state and
to disable refill, and toggle them on start, stop
and remove; check these flags on refill.

refill work structure and new fields aren't used
on data path, so put them together near the end of
struct virtnet_info.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

RFC only since it's untested at this point.
A bugfix so 3.2 material?
Comments?


 drivers/net/virtio_net.c |   57 +++++++++++++++++++++++++++++++++++++---------
 1 files changed, 46 insertions(+), 11 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f5b3f19..39eb24c 100644
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
@@ -68,15 +69,24 @@ struct virtnet_info {
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
+	/* Set flag to allow delayed refill work, protected by a refill_lock. */
+	bool refill_enable;
+
+	/* Whether napi is enabled, protected by a refill_lock. */
+	bool napi_enable;
+
+	/* Lock to protect refill and napi enable/disable operations. */
+	struct mutex refill_lock;
 };
 
 struct skb_vnet_hdr {
@@ -477,20 +487,35 @@ static void virtnet_napi_enable(struct virtnet_info *vi)
 	}
 }
 
+static void virtnet_refill_enable(struct virtnet_info *vi, bool enable)
+{
+	mutex_lock(&vi->refill_lock);
+	vi->refill_enable = enable;
+	mutex_unlock(&vi->refill_lock);
+}
+
 static void refill_work(struct work_struct *work)
 {
 	struct virtnet_info *vi;
 	bool still_empty;
 
 	vi = container_of(work, struct virtnet_info, refill.work);
-	napi_disable(&vi->napi);
-	still_empty = !try_fill_recv(vi, GFP_KERNEL);
-	virtnet_napi_enable(vi);
 
-	/* In theory, this can happen: if we don't get any buffers in
-	 * we will *never* try to fill again. */
-	if (still_empty)
-		schedule_delayed_work(&vi->refill, HZ/2);
+	mutex_lock(&vi->refill_lock);
+	if (vi->refill_enable) {
+		if (vi->napi_enable)
+			napi_disable(&vi->napi);
+		still_empty = !try_fill_recv(vi, GFP_KERNEL);
+		if (vi->napi_enable)
+			virtnet_napi_enable(vi);
+
+		/* In theory, this can happen: if we don't get any buffers in
+		 * we will *never* try to fill again. */
+		if (still_empty)
+			schedule_delayed_work(&vi->refill, HZ/2);
+
+	}
+	mutex_unlock(&vi->refill_lock);
 }
 
 static int virtnet_poll(struct napi_struct *napi, int budget)
@@ -708,7 +733,10 @@ static int virtnet_open(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
+	mutex_lock(&vi->refill_lock);
+	vi->napi_enable = true;
 	virtnet_napi_enable(vi);
+	mutex_unlock(&vi->refill_lock);
 	return 0;
 }
 
@@ -761,7 +789,10 @@ static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
+	mutex_lock(&vi->refill_lock);
+	vi->napi_enable = false;
 	napi_disable(&vi->napi);
+	mutex_unlock(&vi->refill_lock);
 
 	return 0;
 }
@@ -1010,6 +1041,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (vi->stats == NULL)
 		goto free;
 
+	mutex_init(&vi->refill_lock);
 	INIT_DELAYED_WORK(&vi->refill, refill_work);
 	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
 	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
@@ -1047,6 +1079,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free_vqs;
 	}
 
+	virtnet_refill_enable(vi, true);
+
 	/* Last of all, set up some receive buffers. */
 	try_fill_recv(vi, GFP_KERNEL);
 
@@ -1107,10 +1141,11 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
 
+	virtnet_refill_enable(vi, false);
+
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
-
 	unregister_netdev(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
 
-- 
1.7.5.53.gc233e
