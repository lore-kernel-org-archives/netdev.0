From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 04/25] virtio: defer config changed notifications
Date: Mon, 13 Oct 2014 10:50:04 +0300
Message-ID: <1413114332-626-5-git-send-email-mst-v4@redhat.com>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
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
In-Reply-To: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
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

Defer config changed notifications that arrive during
probe/scan/freeze/restore.

This will allow drivers to set DRIVER_OK earlier, without worrying about
racing with config change interrupts.

This change will also benefit old hypervisors (before 2009)
that send interrupts without checking DRIVER_OK: previously,
the callback could race with driver-specific initialization.

This will also help simplify drivers.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 include/linux/virtio.h  |  6 ++++++
 drivers/virtio/virtio.c | 57 +++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 54 insertions(+), 9 deletions(-)

diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index 8df7ba8..5636b11 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -79,6 +79,9 @@ bool virtqueue_is_broken(struct virtqueue *vq);
  * virtio_device - representation of a device using virtio
  * @index: unique position on the virtio bus
  * @failed: saved value for CONFIG_S_FAILED bit (for restore)
+ * @config_enabled: configuration change reporting enabled
+ * @config_changed: configuration change reported while disabled
+ * @config_lock: protects configuration change reporting
  * @dev: underlying device.
  * @id: the device type identification (used to match it with a driver).
  * @config: the configuration ops for this device.
@@ -90,6 +93,9 @@ bool virtqueue_is_broken(struct virtqueue *vq);
 struct virtio_device {
 	int index;
 	bool failed;
+	bool config_enabled;
+	bool config_changed;
+	spinlock_t config_lock;
 	struct device dev;
 	struct virtio_device_id id;
 	const struct virtio_config_ops *config;
diff --git a/drivers/virtio/virtio.c b/drivers/virtio/virtio.c
index 8216b73..2536701 100644
--- a/drivers/virtio/virtio.c
+++ b/drivers/virtio/virtio.c
@@ -117,6 +117,42 @@ void virtio_check_driver_offered_feature(const struct virtio_device *vdev,
 }
 EXPORT_SYMBOL_GPL(virtio_check_driver_offered_feature);
 
+static void __virtio_config_changed(struct virtio_device *dev)
+{
+	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
+
+	if (!dev->config_enabled)
+		dev->config_changed = true;
+	else if (drv && drv->config_changed)
+		drv->config_changed(dev);
+}
+
+void virtio_config_changed(struct virtio_device *dev)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&dev->config_lock, flags);
+	__virtio_config_changed(dev);
+	spin_unlock_irqrestore(&dev->config_lock, flags);
+}
+EXPORT_SYMBOL_GPL(virtio_config_changed);
+
+static void virtio_config_disable(struct virtio_device *dev)
+{
+	spin_lock_irq(&dev->config_lock);
+	dev->config_enabled = false;
+	spin_unlock_irq(&dev->config_lock);
+}
+
+static void virtio_config_enable(struct virtio_device *dev)
+{
+	spin_lock_irq(&dev->config_lock);
+	dev->config_enabled = true;
+	__virtio_config_changed(dev);
+	dev->config_changed = false;
+	spin_unlock_irq(&dev->config_lock);
+}
+
 static int virtio_dev_probe(struct device *_d)
 {
 	int err, i;
@@ -153,6 +189,8 @@ static int virtio_dev_probe(struct device *_d)
 		add_status(dev, VIRTIO_CONFIG_S_DRIVER_OK);
 		if (drv->scan)
 			drv->scan(dev);
+
+		virtio_config_enable(dev);
 	}
 
 	return err;
@@ -163,6 +201,8 @@ static int virtio_dev_remove(struct device *_d)
 	struct virtio_device *dev = dev_to_virtio(_d);
 	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
 
+	virtio_config_disable(dev);
+
 	drv->remove(dev);
 
 	/* Driver should have reset device. */
@@ -211,6 +251,10 @@ int register_virtio_device(struct virtio_device *dev)
 	dev->index = err;
 	dev_set_name(&dev->dev, "virtio%u", dev->index);
 
+	spin_lock_init(&dev->config_lock);
+	dev->config_enabled = false;
+	dev->config_changed = false;
+
 	/* We always start by resetting the device, in case a previous
 	 * driver messed it up.  This also tests that code path a little. */
 	dev->config->reset(dev);
@@ -239,20 +283,13 @@ void unregister_virtio_device(struct virtio_device *dev)
 }
 EXPORT_SYMBOL_GPL(unregister_virtio_device);
 
-void virtio_config_changed(struct virtio_device *dev)
-{
-	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
-
-	if (drv && drv->config_changed)
-		drv->config_changed(dev);
-}
-EXPORT_SYMBOL_GPL(virtio_config_changed);
-
 #ifdef CONFIG_PM_SLEEP
 int virtio_device_freeze(struct virtio_device *dev)
 {
 	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
 
+	virtio_config_disable(dev);
+
 	dev->failed = dev->config->get_status(dev) & VIRTIO_CONFIG_S_FAILED;
 
 	if (drv && drv->freeze)
@@ -297,6 +334,8 @@ int virtio_device_restore(struct virtio_device *dev)
 	/* Finally, tell the device we're all set */
 	add_status(dev, VIRTIO_CONFIG_S_DRIVER_OK);
 
+	virtio_config_enable(dev);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(virtio_device_restore);
-- 
MST
