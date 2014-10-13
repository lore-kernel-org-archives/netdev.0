From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 10/25] virtio: add API to enable VQs early
Date: Mon, 13 Oct 2014 10:50:33 +0300
Message-ID: <1413114332-626-11-git-send-email-mst-v4@redhat.com>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	linux-scsi@vger.kernel.org, linux-s390@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Amit Shah <amit.shah@redhat.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paolo Bonzini <pbonzini@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtio spec 0.9.X requires DRIVER_OK to be set before
VQs are used, but some drivers use VQs before probe
function returns.
Since DRIVER_OK is set after probe, this violates the spec.

Even though under virtio 1.0 transitional devices support this
behaviour, we want to make it possible for those early callers to become
spec compliant and eventually support non-transitional devices.

Add API for drivers to call before using VQs.

Sets DRIVER_OK internally.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 include/linux/virtio_config.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
index e8f8f71..e36403b 100644
--- a/include/linux/virtio_config.h
+++ b/include/linux/virtio_config.h
@@ -109,6 +109,23 @@ struct virtqueue *virtio_find_single_vq(struct virtio_device *vdev,
 	return vq;
 }
 
+/**
+ * virtio_device_ready - enable vq use in probe function
+ * @vdev: the device
+ *
+ * Driver must call this to use vqs in the probe function.
+ *
+ * Note: vqs are enabled automatically after probe returns.
+ */
+static inline
+void virtio_device_ready(struct virtio_device *dev)
+{
+	unsigned status = dev->config->get_status(dev);
+
+	BUG_ON(status & VIRTIO_CONFIG_S_DRIVER_OK);
+	dev->config->set_status(dev, status | VIRTIO_CONFIG_S_DRIVER_OK);
+}
+
 static inline
 const char *virtio_bus_name(struct virtio_device *vdev)
 {
-- 
MST
