From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 03/25] virtio-pci: move freeze/restore to virtio core
Date: Sun, 12 Oct 2014 14:46:41 +0300
Message-ID: <1413114332-626-4-git-send-email-mst@redhat.com>
References: <1413114332-626-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-scsi@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>, Amit Shah <amit.shah@redhat.com>,
	v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst@redhat.com>
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

This is in preparation to extending config changed event handling
in core.
Wrapping these in an API also seems to make for a cleaner code.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 include/linux/virtio.h      |  6 +++++
 drivers/virtio/virtio.c     | 54 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/virtio/virtio_pci.c | 54 ++-------------------------------------------
 3 files changed, 62 insertions(+), 52 deletions(-)

diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index 3c19bd3..8df7ba8 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -78,6 +78,7 @@ bool virtqueue_is_broken(struct virtqueue *vq);
 /**
  * virtio_device - representation of a device using virtio
  * @index: unique position on the virtio bus
+ * @failed: saved value for CONFIG_S_FAILED bit (for restore)
  * @dev: underlying device.
  * @id: the device type identification (used to match it with a driver).
  * @config: the configuration ops for this device.
@@ -88,6 +89,7 @@ bool virtqueue_is_broken(struct virtqueue *vq);
  */
 struct virtio_device {
 	int index;
+	bool failed;
 	struct device dev;
 	struct virtio_device_id id;
 	const struct virtio_config_ops *config;
@@ -109,6 +111,10 @@ void unregister_virtio_device(struct virtio_device *dev);
 void virtio_break_device(struct virtio_device *dev);
 
 void virtio_config_changed(struct virtio_device *dev);
+#ifdef CONFIG_PM_SLEEP
+int virtio_device_freeze(struct virtio_device *dev);
+int virtio_device_restore(struct virtio_device *dev);
+#endif
 
 /**
  * virtio_driver - operations for a virtio I/O driver
diff --git a/drivers/virtio/virtio.c b/drivers/virtio/virtio.c
index 3980687..8216b73 100644
--- a/drivers/virtio/virtio.c
+++ b/drivers/virtio/virtio.c
@@ -248,6 +248,60 @@ void virtio_config_changed(struct virtio_device *dev)
 }
 EXPORT_SYMBOL_GPL(virtio_config_changed);
 
+#ifdef CONFIG_PM_SLEEP
+int virtio_device_freeze(struct virtio_device *dev)
+{
+	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
+
+	dev->failed = dev->config->get_status(dev) & VIRTIO_CONFIG_S_FAILED;
+
+	if (drv && drv->freeze)
+		return drv->freeze(dev);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_device_freeze);
+
+int virtio_device_restore(struct virtio_device *dev)
+{
+	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
+
+	/* We always start by resetting the device, in case a previous
+	 * driver messed it up. */
+	dev->config->reset(dev);
+
+	/* Acknowledge that we've seen the device. */
+	add_status(dev, VIRTIO_CONFIG_S_ACKNOWLEDGE);
+
+	/* Maybe driver failed before freeze.
+	 * Restore the failed status, for debugging. */
+	if (dev->failed)
+		add_status(dev, VIRTIO_CONFIG_S_FAILED);
+
+	if (!drv)
+		return 0;
+
+	/* We have a driver! */
+	add_status(dev, VIRTIO_CONFIG_S_DRIVER);
+
+	dev->config->finalize_features(dev);
+
+	if (drv->restore) {
+		int ret = drv->restore(dev);
+		if (ret) {
+			add_status(dev, VIRTIO_CONFIG_S_FAILED);
+			return ret;
+		}
+	}
+
+	/* Finally, tell the device we're all set */
+	add_status(dev, VIRTIO_CONFIG_S_DRIVER_OK);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_device_restore);
+#endif
+
 static int virtio_init(void)
 {
 	if (bus_register(&virtio_bus) != 0)
diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
index f39f4e7..d34ebfa 100644
--- a/drivers/virtio/virtio_pci.c
+++ b/drivers/virtio/virtio_pci.c
@@ -57,9 +57,6 @@ struct virtio_pci_device
 	/* Vectors allocated, excluding per-vq vectors if any */
 	unsigned msix_used_vectors;
 
-	/* Status saved during hibernate/restore */
-	u8 saved_status;
-
 	/* Whether we have vector per vq */
 	bool per_vq_vectors;
 };
@@ -764,16 +761,9 @@ static int virtio_pci_freeze(struct device *dev)
 {
 	struct pci_dev *pci_dev = to_pci_dev(dev);
 	struct virtio_pci_device *vp_dev = pci_get_drvdata(pci_dev);
-	struct virtio_driver *drv;
 	int ret;
 
-	drv = container_of(vp_dev->vdev.dev.driver,
-			   struct virtio_driver, driver);
-
-	ret = 0;
-	vp_dev->saved_status = vp_get_status(&vp_dev->vdev);
-	if (drv && drv->freeze)
-		ret = drv->freeze(&vp_dev->vdev);
+	ret = virtio_device_freeze(&vp_dev->vdev);
 
 	if (!ret)
 		pci_disable_device(pci_dev);
@@ -784,54 +774,14 @@ static int virtio_pci_restore(struct device *dev)
 {
 	struct pci_dev *pci_dev = to_pci_dev(dev);
 	struct virtio_pci_device *vp_dev = pci_get_drvdata(pci_dev);
-	struct virtio_driver *drv;
-	unsigned status = 0;
 	int ret;
 
-	drv = container_of(vp_dev->vdev.dev.driver,
-			   struct virtio_driver, driver);
-
 	ret = pci_enable_device(pci_dev);
 	if (ret)
 		return ret;
 
 	pci_set_master(pci_dev);
-	/* We always start by resetting the device, in case a previous
-	 * driver messed it up. */
-	vp_reset(&vp_dev->vdev);
-
-	/* Acknowledge that we've seen the device. */
-	status |= VIRTIO_CONFIG_S_ACKNOWLEDGE;
-	vp_set_status(&vp_dev->vdev, status);
-
-	/* Maybe driver failed before freeze.
-	 * Restore the failed status, for debugging. */
-	status |= vp_dev->saved_status & VIRTIO_CONFIG_S_FAILED;
-	vp_set_status(&vp_dev->vdev, status);
-
-	if (!drv)
-		return 0;
-
-	/* We have a driver! */
-	status |= VIRTIO_CONFIG_S_DRIVER;
-	vp_set_status(&vp_dev->vdev, status);
-
-	vp_finalize_features(&vp_dev->vdev);
-
-	if (drv->restore) {
-		ret = drv->restore(&vp_dev->vdev);
-		if (ret) {
-			status |= VIRTIO_CONFIG_S_FAILED;
-			vp_set_status(&vp_dev->vdev, status);
-			return ret;
-		}
-	}
-
-	/* Finally, tell the device we're all set */
-	status |= VIRTIO_CONFIG_S_DRIVER_OK;
-	vp_set_status(&vp_dev->vdev, status);
-
-	return ret;
+	return virtio_device_restore(&vp_dev->vdev);
 }
 
 static const struct dev_pm_ops virtio_pci_pm_ops = {
-- 
MST
