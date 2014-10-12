From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 02/25] virtio: unify config_changed handling
Date: Sun, 12 Oct 2014 14:46:33 +0300
Message-ID: <1413114332-626-3-git-send-email-mst@redhat.com>
References: <1413114332-626-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, Wolfram Sang <wsa@the-dreams.de>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Sudeep Dutt <sudeep.dutt@intel.com>,
	virtualization@lists.linux-foundation.org,
	linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	v9fs-developer@lists.sourceforge.net,
	Siva Yerramreddy <yshivakrishna@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Paolo Bonzini <pbonzini@redhat.com>, netdev@vger.kernel.org,
	Ashutosh Dixit <ashutosh.dixit@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Amit Shah <amit.shah@redhat.com>, linux390@de.ibm.com,
	Andrew Morton <akpm@linux-foundation.org>,
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

Replace duplicated code in all transports with a single wrapper in
virtio.c.

The only functional change is in virtio_mmio.c: if a buggy device sends
us an interrupt before driver is set, we previously returned IRQ_NONE,
now we return IRQ_HANDLED.

As this must not happen in practice, this does not look like a big deal.

See also commit 3fff0179e33cd7d0a688dab65700c46ad089e934
	virtio-pci: do not oops on config change if driver not loaded.
for the original motivation behind the driver check.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 include/linux/virtio.h             | 2 ++
 drivers/misc/mic/card/mic_virtio.c | 6 +-----
 drivers/s390/kvm/kvm_virtio.c      | 9 +--------
 drivers/s390/kvm/virtio_ccw.c      | 6 +-----
 drivers/virtio/virtio.c            | 9 +++++++++
 drivers/virtio/virtio_mmio.c       | 7 ++-----
 drivers/virtio/virtio_pci.c        | 6 +-----
 7 files changed, 17 insertions(+), 28 deletions(-)

diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index b46671e..3c19bd3 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -108,6 +108,8 @@ void unregister_virtio_device(struct virtio_device *dev);
 
 void virtio_break_device(struct virtio_device *dev);
 
+void virtio_config_changed(struct virtio_device *dev);
+
 /**
  * virtio_driver - operations for a virtio I/O driver
  * @driver: underlying device driver (populate name and owner).
diff --git a/drivers/misc/mic/card/mic_virtio.c b/drivers/misc/mic/card/mic_virtio.c
index f14b600..e647947 100644
--- a/drivers/misc/mic/card/mic_virtio.c
+++ b/drivers/misc/mic/card/mic_virtio.c
@@ -462,16 +462,12 @@ static void mic_handle_config_change(struct mic_device_desc __iomem *d,
 	struct mic_device_ctrl __iomem *dc
 		= (void __iomem *)d + mic_aligned_desc_size(d);
 	struct mic_vdev *mvdev = (struct mic_vdev *)ioread64(&dc->vdev);
-	struct virtio_driver *drv;
 
 	if (ioread8(&dc->config_change) != MIC_VIRTIO_PARAM_CONFIG_CHANGED)
 		return;
 
 	dev_dbg(mdrv->dev, "%s %d\n", __func__, __LINE__);
-	drv = container_of(mvdev->vdev.dev.driver,
-				struct virtio_driver, driver);
-	if (drv->config_changed)
-		drv->config_changed(&mvdev->vdev);
+	virtio_config_changed(&mvdev->vdev);
 	iowrite8(1, &dc->guest_ack);
 }
 
diff --git a/drivers/s390/kvm/kvm_virtio.c b/drivers/s390/kvm/kvm_virtio.c
index a134965..6431290 100644
--- a/drivers/s390/kvm/kvm_virtio.c
+++ b/drivers/s390/kvm/kvm_virtio.c
@@ -406,15 +406,8 @@ static void kvm_extint_handler(struct ext_code ext_code,
 
 	switch (param) {
 	case VIRTIO_PARAM_CONFIG_CHANGED:
-	{
-		struct virtio_driver *drv;
-		drv = container_of(vq->vdev->dev.driver,
-				   struct virtio_driver, driver);
-		if (drv->config_changed)
-			drv->config_changed(vq->vdev);
-
+		virtio_config_changed(vq->vdev);
 		break;
-	}
 	case VIRTIO_PARAM_DEV_ADD:
 		schedule_work(&hotplug_work);
 		break;
diff --git a/drivers/s390/kvm/virtio_ccw.c b/drivers/s390/kvm/virtio_ccw.c
index d2c0b44..6cbe6ef 100644
--- a/drivers/s390/kvm/virtio_ccw.c
+++ b/drivers/s390/kvm/virtio_ccw.c
@@ -940,11 +940,7 @@ static void virtio_ccw_int_handler(struct ccw_device *cdev,
 		vring_interrupt(0, vq);
 	}
 	if (test_bit(0, &vcdev->indicators2)) {
-		drv = container_of(vcdev->vdev.dev.driver,
-				   struct virtio_driver, driver);
-
-		if (drv && drv->config_changed)
-			drv->config_changed(&vcdev->vdev);
+		virtio_config_changed(&vcdev->vdev);
 		clear_bit(0, &vcdev->indicators2);
 	}
 }
diff --git a/drivers/virtio/virtio.c b/drivers/virtio/virtio.c
index fed0ce1..3980687 100644
--- a/drivers/virtio/virtio.c
+++ b/drivers/virtio/virtio.c
@@ -239,6 +239,15 @@ void unregister_virtio_device(struct virtio_device *dev)
 }
 EXPORT_SYMBOL_GPL(unregister_virtio_device);
 
+void virtio_config_changed(struct virtio_device *dev)
+{
+	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
+
+	if (drv && drv->config_changed)
+		drv->config_changed(dev);
+}
+EXPORT_SYMBOL_GPL(virtio_config_changed);
+
 static int virtio_init(void)
 {
 	if (bus_register(&virtio_bus) != 0)
diff --git a/drivers/virtio/virtio_mmio.c b/drivers/virtio/virtio_mmio.c
index c600ccf..ef9a165 100644
--- a/drivers/virtio/virtio_mmio.c
+++ b/drivers/virtio/virtio_mmio.c
@@ -234,8 +234,6 @@ static irqreturn_t vm_interrupt(int irq, void *opaque)
 {
 	struct virtio_mmio_device *vm_dev = opaque;
 	struct virtio_mmio_vq_info *info;
-	struct virtio_driver *vdrv = container_of(vm_dev->vdev.dev.driver,
-			struct virtio_driver, driver);
 	unsigned long status;
 	unsigned long flags;
 	irqreturn_t ret = IRQ_NONE;
@@ -244,9 +242,8 @@ static irqreturn_t vm_interrupt(int irq, void *opaque)
 	status = readl(vm_dev->base + VIRTIO_MMIO_INTERRUPT_STATUS);
 	writel(status, vm_dev->base + VIRTIO_MMIO_INTERRUPT_ACK);
 
-	if (unlikely(status & VIRTIO_MMIO_INT_CONFIG)
-			&& vdrv && vdrv->config_changed) {
-		vdrv->config_changed(&vm_dev->vdev);
+	if (unlikely(status & VIRTIO_MMIO_INT_CONFIG)) {
+		virtio_config_changed(&vm_dev->vdev);
 		ret = IRQ_HANDLED;
 	}
 
diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
index add40d0..f39f4e7 100644
--- a/drivers/virtio/virtio_pci.c
+++ b/drivers/virtio/virtio_pci.c
@@ -211,12 +211,8 @@ static bool vp_notify(struct virtqueue *vq)
 static irqreturn_t vp_config_changed(int irq, void *opaque)
 {
 	struct virtio_pci_device *vp_dev = opaque;
-	struct virtio_driver *drv;
-	drv = container_of(vp_dev->vdev.dev.driver,
-			   struct virtio_driver, driver);
 
-	if (drv && drv->config_changed)
-		drv->config_changed(&vp_dev->vdev);
+	virtio_config_changed(&vp_dev->vdev);
 	return IRQ_HANDLED;
 }
 
-- 
MST
