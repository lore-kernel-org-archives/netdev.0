From: Jason Wang <jasowang@redhat.com>
Subject: [RFC V7 PATCH 1/7] virito-pci: add coalescing parameters setting
Date: Mon, 25 May 2015 01:23:58 -0400
Message-ID: <1432531444-50193-2-git-send-email-jasowang@redhat.com>
References: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
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

This patch introduces a transport specific methods to set or get the
coalescing parameters and implement the pci methods.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/virtio/virtio_pci_modern.c | 15 +++++++++++++++
 include/linux/virtio_config.h      |  8 ++++++++
 include/uapi/linux/virtio_pci.h    |  4 ++++
 3 files changed, 27 insertions(+)

diff --git a/drivers/virtio/virtio_pci_modern.c b/drivers/virtio/virtio_pci_modern.c
index e88e099..ce801ae 100644
--- a/drivers/virtio/virtio_pci_modern.c
+++ b/drivers/virtio/virtio_pci_modern.c
@@ -266,6 +266,16 @@ static void vp_set_status(struct virtio_device *vdev, u8 status)
 	vp_iowrite8(status, &vp_dev->common->device_status);
 }
 
+static void vp_set_coalesce(struct virtio_device *vdev, int n,
+			    u32 coalesce_count, u32 coalesce_us)
+{
+	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
+
+	iowrite16(n, &vp_dev->common->queue_select);
+	iowrite32(coalesce_count, &vp_dev->common->queue_coalesce_count);
+	iowrite32(coalesce_us, &vp_dev->common->queue_coalesce_us);
+}
+
 static void vp_reset(struct virtio_device *vdev)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
@@ -481,6 +491,7 @@ static const struct virtio_config_ops virtio_pci_config_ops = {
 	.generation	= vp_generation,
 	.get_status	= vp_get_status,
 	.set_status	= vp_set_status,
+	.set_coalesce   = vp_set_coalesce,
 	.reset		= vp_reset,
 	.find_vqs	= vp_modern_find_vqs,
 	.del_vqs	= vp_del_vqs,
@@ -588,6 +599,10 @@ static inline void check_offsets(void)
 		     offsetof(struct virtio_pci_common_cfg, queue_used_lo));
 	BUILD_BUG_ON(VIRTIO_PCI_COMMON_Q_USEDHI !=
 		     offsetof(struct virtio_pci_common_cfg, queue_used_hi));
+	BUILD_BUG_ON(VIRTIO_PCI_COMMON_Q_COALESCE_C !=
+		offsetof(struct virtio_pci_common_cfg, queue_coalesce_count));
+	BUILD_BUG_ON(VIRTIO_PCI_COMMON_Q_COALESCE_U !=
+		offsetof(struct virtio_pci_common_cfg, queue_coalesce_us));
 }
 
 /* the PCI probing function */
diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
index 1e306f7..d100c32 100644
--- a/include/linux/virtio_config.h
+++ b/include/linux/virtio_config.h
@@ -28,6 +28,12 @@
  * @set_status: write the status byte
  *	vdev: the virtio_device
  *	status: the new status byte
+ * @set_coalesce: set coalescing parameters
+ *	vdev: the virtio_device
+ *	n: the queue index
+ *	coalesce_count: maximum coalesced count before issuing interrupt
+ *      coalesce_count: maximum micro seconds to wait if there's a
+ *      pending buffer
  * @reset: reset the device
  *	vdev: the virtio device
  *	After this, status and feature negotiation must be done again
@@ -66,6 +72,8 @@ struct virtio_config_ops {
 	u32 (*generation)(struct virtio_device *vdev);
 	u8 (*get_status)(struct virtio_device *vdev);
 	void (*set_status)(struct virtio_device *vdev, u8 status);
+	void (*set_coalesce)(struct virtio_device *vdev, int n,
+			     u32 coalesce_count, u32 coalesce_us);
 	void (*reset)(struct virtio_device *vdev);
 	int (*find_vqs)(struct virtio_device *, unsigned nvqs,
 			struct virtqueue *vqs[],
diff --git a/include/uapi/linux/virtio_pci.h b/include/uapi/linux/virtio_pci.h
index 7530146..3396026 100644
--- a/include/uapi/linux/virtio_pci.h
+++ b/include/uapi/linux/virtio_pci.h
@@ -155,6 +155,8 @@ struct virtio_pci_common_cfg {
 	__le32 queue_avail_hi;		/* read-write */
 	__le32 queue_used_lo;		/* read-write */
 	__le32 queue_used_hi;		/* read-write */
+	__le32 queue_coalesce_count;    /* read-write */
+	__le32 queue_coalesce_us;       /* read-write */
 };
 
 /* Macro versions of offsets for the Old Timers! */
@@ -187,6 +189,8 @@ struct virtio_pci_common_cfg {
 #define VIRTIO_PCI_COMMON_Q_AVAILHI	44
 #define VIRTIO_PCI_COMMON_Q_USEDLO	48
 #define VIRTIO_PCI_COMMON_Q_USEDHI	52
+#define VIRTIO_PCI_COMMON_Q_COALESCE_C  56
+#define VIRTIO_PCI_COMMON_Q_COALESCE_U  60
 
 #endif /* VIRTIO_PCI_NO_MODERN */
 
-- 
1.8.3.1
