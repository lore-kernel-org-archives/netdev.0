From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC PATCH 4/5] virtio: introduce a method to get the irq of
	a specific virtqueue
Date: Mon, 05 Dec 2011 16:59:16 +0800
Message-ID: <20111205085916.6116.23553.stgit@dhcp-8-146.nay.redhat.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org, levinsasha928@gmail.com,
	bhutchings@solarflare.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
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

Device specific irq configuration may be need in order to do some
optimization. So a new configuration is needed to get the irq of a
virtqueue.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/lguest/lguest_device.c |    8 ++++++++
 drivers/s390/kvm/kvm_virtio.c  |    6 ++++++
 drivers/virtio/virtio_mmio.c   |    8 ++++++++
 drivers/virtio/virtio_pci.c    |   12 ++++++++++++
 include/linux/virtio_config.h  |    4 ++++
 5 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/lguest/lguest_device.c b/drivers/lguest/lguest_device.c
index 595d731..6483bff 100644
--- a/drivers/lguest/lguest_device.c
+++ b/drivers/lguest/lguest_device.c
@@ -386,6 +386,13 @@ static const char *lg_bus_name(struct virtio_device *vdev)
 	return "";
 }
 
+static int lg_get_vq_irq(struct virtio_device *vdev, struct virtqueue *vq)
+{
+	struct lguest_vq_info *lvq = vq->priv;
+
+	return lvq->config.irq;
+}
+
 /* The ops structure which hooks everything together. */
 static struct virtio_config_ops lguest_config_ops = {
 	.get_features = lg_get_features,
@@ -398,6 +405,7 @@ static struct virtio_config_ops lguest_config_ops = {
 	.find_vqs = lg_find_vqs,
 	.del_vqs = lg_del_vqs,
 	.bus_name = lg_bus_name,
+	.get_vq_irq = lg_get_vq_irq,
 };
 
 /*
diff --git a/drivers/s390/kvm/kvm_virtio.c b/drivers/s390/kvm/kvm_virtio.c
index 8af868b..a8d5ca1 100644
--- a/drivers/s390/kvm/kvm_virtio.c
+++ b/drivers/s390/kvm/kvm_virtio.c
@@ -268,6 +268,11 @@ static const char *kvm_bus_name(struct virtio_device *vdev)
 	return "";
 }
 
+static int kvm_get_vq_irq(struct virtio_device *vdev, struct virtqueue *vq)
+{
+	return 0x2603;
+}
+
 /*
  * The config ops structure as defined by virtio config
  */
@@ -282,6 +287,7 @@ static struct virtio_config_ops kvm_vq_configspace_ops = {
 	.find_vqs = kvm_find_vqs,
 	.del_vqs = kvm_del_vqs,
 	.bus_name = kvm_bus_name,
+	.get_vq_irq = kvm_get_vq_irq,
 };
 
 /*
diff --git a/drivers/virtio/virtio_mmio.c b/drivers/virtio/virtio_mmio.c
index 2f57380..309d471 100644
--- a/drivers/virtio/virtio_mmio.c
+++ b/drivers/virtio/virtio_mmio.c
@@ -368,6 +368,13 @@ static const char *vm_bus_name(struct virtio_device *vdev)
 	return vm_dev->pdev->name;
 }
 
+static int vm_get_vq_irq(struct virtio_device *vdev, struct virtqueue *vq)
+{
+	struct virtio_mmio_device *vm_dev = to_virtio_mmio_device(vdev);
+
+	return platform_get_irq(vm_dev->pdev, 0);
+}
+
 static struct virtio_config_ops virtio_mmio_config_ops = {
 	.get		= vm_get,
 	.set		= vm_set,
@@ -379,6 +386,7 @@ static struct virtio_config_ops virtio_mmio_config_ops = {
 	.get_features	= vm_get_features,
 	.finalize_features = vm_finalize_features,
 	.bus_name	= vm_bus_name,
+	.get_vq_irq     = vm_get_vq_irq,
 };
 
 
diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
index 229ea56..4f99164 100644
--- a/drivers/virtio/virtio_pci.c
+++ b/drivers/virtio/virtio_pci.c
@@ -583,6 +583,17 @@ static const char *vp_bus_name(struct virtio_device *vdev)
 	return pci_name(vp_dev->pci_dev);
 }
 
+static int vp_get_vq_irq(struct virtio_device *vdev, struct virtqueue *vq)
+{
+	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
+	struct virtio_pci_vq_info *info = vq->priv;
+
+	if (vp_dev->intx_enabled)
+		return vp_dev->pci_dev->irq;
+	else
+		return vp_dev->msix_entries[info->msix_vector].vector;
+}
+
 static struct virtio_config_ops virtio_pci_config_ops = {
 	.get		= vp_get,
 	.set		= vp_set,
@@ -594,6 +605,7 @@ static struct virtio_config_ops virtio_pci_config_ops = {
 	.get_features	= vp_get_features,
 	.finalize_features = vp_finalize_features,
 	.bus_name	= vp_bus_name,
+	.get_vq_irq     = vp_get_vq_irq,
 };
 
 static void virtio_pci_release_dev(struct device *_d)
diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
index 63f98d0..7b783a6 100644
--- a/include/linux/virtio_config.h
+++ b/include/linux/virtio_config.h
@@ -104,6 +104,9 @@
  *	vdev: the virtio_device
  *      This returns a pointer to the bus name a la pci_name from which
  *      the caller can then copy.
+ * @get_vq_irq: get the irq numer of the specific virt queue.
+ *      vdev: the virtio_device
+ *      vq: the virtqueue
  */
 typedef void vq_callback_t(struct virtqueue *);
 struct virtio_config_ops {
@@ -122,6 +125,7 @@ struct virtio_config_ops {
 	u32 (*get_features)(struct virtio_device *vdev);
 	void (*finalize_features)(struct virtio_device *vdev);
 	const char *(*bus_name)(struct virtio_device *vdev);
+	int (*get_vq_irq)(struct virtio_device *vdev, struct virtqueue *vq);
 };
 
 /* If driver didn't advertise the feature, it will never appear. */
