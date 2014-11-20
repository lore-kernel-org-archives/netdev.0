From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH v4 net] virtio-net: validate features during probe
Date: Thu, 20 Nov 2014 16:27:23 +0800
Message-ID: <1416472043-9875-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

We currently trigger BUG when VIRTIO_NET_F_CTRL_VQ
is not set but one of features depending on it is.
That's not a friendly way to report errors to
hypervisors.
Let's check, and fail probe instead.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
Changes from V1:
- Drop NETIF_F_*_UFO from checklist
Changes from V2:
- only check the features for ctrl vq (this fix the real bug)
- better error message and simplify API
Changes from V3:
- pass dbit directly and even better error message
- typo fix
---
 drivers/net/virtio_net.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ec2a8b4..cc53ff1 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1673,6 +1673,40 @@ static const struct attribute_group virtio_net_mrg_rx_group = {
 };
 #endif
 
+static bool virtnet_fail_on_feature(struct virtio_device *vdev,
+				    unsigned int fbit,
+				    const char *fname, const char *dname)
+{
+	if (!virtio_has_feature(vdev, fbit))
+		return false;
+
+	dev_err(&vdev->dev, "advertise feature %s but not %s",
+		fname, dname);
+
+	return true;
+}
+
+#define VIRTNET_FAIL_ON(vdev, fbit, dbit)			\
+	virtnet_fail_on_feature(vdev, fbit, #fbit, dbit)
+
+static bool virtnet_validate_features(struct virtio_device *vdev)
+{
+	if (!virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ) &&
+	    (VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_RX,
+			     "VIRTIO_NET_F_CTRL_VQ") ||
+	     VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_VLAN,
+			     "VIRTIO_NET_F_CTRL_VQ") ||
+	     VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_GUEST_ANNOUNCE,
+			     "VIRTIO_NET_F_CTRL_VQ") ||
+	     VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_MQ, "VIRTIO_NET_F_CTRL_VQ") ||
+	     VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR,
+			     "VIRTIO_NET_F_CTRL_VQ"))) {
+		return false;
+	}
+
+	return true;
+}
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int i, err;
@@ -1680,6 +1714,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 	struct virtnet_info *vi;
 	u16 max_queue_pairs;
 
+	if (!virtnet_validate_features(vdev))
+		return -EINVAL;
+
 	/* Find if host supports multiqueue virtio_net device */
 	err = virtio_cread_feature(vdev, VIRTIO_NET_F_MQ,
 				   struct virtio_net_config,
-- 
1.9.1
