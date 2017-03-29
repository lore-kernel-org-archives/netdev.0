From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 2/2] virtio_net: clear MTU when out of range
Date: Wed, 29 Mar 2017 20:14:46 +0300
Message-ID: <1490807652-27889-2-git-send-email-mst@redhat.com>
References: <1490807652-27889-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1490807652-27889-1-git-send-email-mst@redhat.com>
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

virtio attempts to clear the MTU feature bit if the value is out of the
supported range, but this has no real effect since FEATURES_OK has
already been set.

Fix this up by checking the MTU in the new validate callback.

Fixes: 14de9d114a82 ("virtio-net: Add initial MTU advice feature")
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f6a379d..6aba098 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2312,14 +2312,8 @@ static bool virtnet_validate_features(struct virtio_device *vdev)
 #define MIN_MTU ETH_MIN_MTU
 #define MAX_MTU ETH_MAX_MTU
 
-static int virtnet_probe(struct virtio_device *vdev)
+static int virtnet_validate(struct virtio_device *vdev)
 {
-	int i, err;
-	struct net_device *dev;
-	struct virtnet_info *vi;
-	u16 max_queue_pairs;
-	int mtu;
-
 	if (!vdev->config->get) {
 		dev_err(&vdev->dev, "%s failure: config access disabled\n",
 			__func__);
@@ -2329,6 +2323,25 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (!virtnet_validate_features(vdev))
 		return -EINVAL;
 
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_MTU)) {
+		int mtu = virtio_cread16(vdev,
+					 offsetof(struct virtio_net_config,
+						  mtu));
+		if (mtu < MIN_MTU)
+			__virtio_clear_bit(vdev, VIRTIO_NET_F_MTU);
+	}
+
+	return 0;
+}
+
+static int virtnet_probe(struct virtio_device *vdev)
+{
+	int i, err;
+	struct net_device *dev;
+	struct virtnet_info *vi;
+	u16 max_queue_pairs;
+	int mtu;
+
 	/* Find if host supports multiqueue virtio_net device */
 	err = virtio_cread_feature(vdev, VIRTIO_NET_F_MQ,
 				   struct virtio_net_config,
@@ -2444,12 +2457,17 @@ static int virtnet_probe(struct virtio_device *vdev)
 				     offsetof(struct virtio_net_config,
 					      mtu));
 		if (mtu < dev->min_mtu) {
-			__virtio_clear_bit(vdev, VIRTIO_NET_F_MTU);
-		} else {
-			dev->mtu = mtu;
-			dev->max_mtu = mtu;
+			/* Should never trigger: MTU was previously validated
+			 * in virtnet_validate.
+			 */
+			dev_err(&vdev->dev, "device MTU appears to have changed "
+				"it is now %d < %d", mtu, dev->min_mtu);
+			goto free_stats;
 		}
 
+		dev->mtu = mtu;
+		dev->max_mtu = mtu;
+
 		/* TODO: size buffers correctly in this case. */
 		if (dev->mtu > ETH_DATA_LEN)
 			vi->big_packets = true;
@@ -2630,6 +2648,7 @@ static struct virtio_driver virtio_net_driver = {
 	.driver.name =	KBUILD_MODNAME,
 	.driver.owner =	THIS_MODULE,
 	.id_table =	id_table,
+	.validate =	virtnet_validate,
 	.probe =	virtnet_probe,
 	.remove =	virtnet_remove,
 	.config_changed = virtnet_config_changed,
-- 
MST
