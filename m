From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC V5 3/5] virtio: intorduce an API to set affinity for a
	virtqueue
Date: Thu,  5 Jul 2012 18:29:52 +0800
Message-ID: <1341484194-8108-4-git-send-email-jasowang@redhat.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, sri@us.ibm.com
To: mst@redhat.com, mashirle@us.ibm.com, krkumar2@in.ibm.com,
	habanero@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr, davem@davemloft.net
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
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

Sometimes, virtio device need to configure irq affiniry hint to maximize the
performance. Instead of just exposing the irq of a virtqueue, this patch
introduce an API to set the affinity for a virtqueue.

The api is best-effort, the affinity hint may not be set as expected due to
platform support, irq sharing or irq type. Currently, only pci method were
implemented and we set the affinity according to:

- if device uses INTX, we just ignore the request
- if device has per vq vector, we force the affinity hint
- if the virtqueues share MSI, make the affinity OR over all affinities
 requested

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/virtio/virtio_pci.c   |   46 +++++++++++++++++++++++++++++++++++++++++
 include/linux/virtio_config.h |   21 ++++++++++++++++++
 2 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
index adb24f2..2ff0451 100644
--- a/drivers/virtio/virtio_pci.c
+++ b/drivers/virtio/virtio_pci.c
@@ -48,6 +48,7 @@ struct virtio_pci_device
 	int msix_enabled;
 	int intx_enabled;
 	struct msix_entry *msix_entries;
+	cpumask_var_t *msix_affinity_masks;
 	/* Name strings for interrupts. This size should be enough,
 	 * and I'm too lazy to allocate each name separately. */
 	char (*msix_names)[256];
@@ -276,6 +277,10 @@ static void vp_free_vectors(struct virtio_device *vdev)
 	for (i = 0; i < vp_dev->msix_used_vectors; ++i)
 		free_irq(vp_dev->msix_entries[i].vector, vp_dev);
 
+	for (i = 0; i < vp_dev->msix_vectors; i++)
+		if (vp_dev->msix_affinity_masks[i])
+			free_cpumask_var(vp_dev->msix_affinity_masks[i]);
+
 	if (vp_dev->msix_enabled) {
 		/* Disable the vector used for configuration */
 		iowrite16(VIRTIO_MSI_NO_VECTOR,
@@ -293,6 +298,8 @@ static void vp_free_vectors(struct virtio_device *vdev)
 	vp_dev->msix_names = NULL;
 	kfree(vp_dev->msix_entries);
 	vp_dev->msix_entries = NULL;
+	kfree(vp_dev->msix_affinity_masks);
+	vp_dev->msix_affinity_masks = NULL;
 }
 
 static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors,
@@ -311,6 +318,15 @@ static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors,
 				     GFP_KERNEL);
 	if (!vp_dev->msix_names)
 		goto error;
+	vp_dev->msix_affinity_masks
+		= kzalloc(nvectors * sizeof *vp_dev->msix_affinity_masks,
+			  GFP_KERNEL);
+	if (!vp_dev->msix_affinity_masks)
+		goto error;
+	for (i = 0; i < nvectors; ++i)
+		if (!alloc_cpumask_var(&vp_dev->msix_affinity_masks[i],
+					GFP_KERNEL))
+			goto error;
 
 	for (i = 0; i < nvectors; ++i)
 		vp_dev->msix_entries[i].entry = i;
@@ -607,6 +623,35 @@ static const char *vp_bus_name(struct virtio_device *vdev)
 	return pci_name(vp_dev->pci_dev);
 }
 
+/* Setup the affinity for a virtqueue:
+ * - force the affinity for per vq vector
+ * - OR over all affinities for shared MSI
+ * - ignore the affinity request if we're using INTX
+ */
+static int vp_set_vq_affinity(struct virtqueue *vq, int cpu)
+{
+	struct virtio_device *vdev = vq->vdev;
+	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
+	struct virtio_pci_vq_info *info = vq->priv;
+	struct cpumask *mask;
+	unsigned int irq;
+
+	if (!vq->callback)
+		return -EINVAL;
+
+	if (vp_dev->msix_enabled) {
+		mask = vp_dev->msix_affinity_masks[info->msix_vector];
+		irq = vp_dev->msix_entries[info->msix_vector].vector;
+		if (cpu == -1)
+			irq_set_affinity_hint(irq, NULL);
+		else {
+			cpumask_set_cpu(cpu, mask);
+			irq_set_affinity_hint(irq, mask);
+		}
+	}
+	return 0;
+}
+
 static struct virtio_config_ops virtio_pci_config_ops = {
 	.get		= vp_get,
 	.set		= vp_set,
@@ -618,6 +663,7 @@ static struct virtio_config_ops virtio_pci_config_ops = {
 	.get_features	= vp_get_features,
 	.finalize_features = vp_finalize_features,
 	.bus_name	= vp_bus_name,
+	.set_vq_affinity = vp_set_vq_affinity,
 };
 
 static void virtio_pci_release_dev(struct device *_d)
diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
index fc457f4..2c4a989 100644
--- a/include/linux/virtio_config.h
+++ b/include/linux/virtio_config.h
@@ -98,6 +98,7 @@
  *	vdev: the virtio_device
  *      This returns a pointer to the bus name a la pci_name from which
  *      the caller can then copy.
+ * @set_vq_affinity: set the affinity for a virtqueue.
  */
 typedef void vq_callback_t(struct virtqueue *);
 struct virtio_config_ops {
@@ -116,6 +117,7 @@ struct virtio_config_ops {
 	u32 (*get_features)(struct virtio_device *vdev);
 	void (*finalize_features)(struct virtio_device *vdev);
 	const char *(*bus_name)(struct virtio_device *vdev);
+	int (*set_vq_affinity)(struct virtqueue *vq, int cpu);
 };
 
 /* If driver didn't advertise the feature, it will never appear. */
@@ -190,5 +192,24 @@ const char *virtio_bus_name(struct virtio_device *vdev)
 	return vdev->config->bus_name(vdev);
 }
 
+/**
+ * virtqueue_set_affinity - setting affinity for a virtqueue
+ * @vq: the virtqueue
+ * @cpu: the cpu no.
+ *
+ * Pay attention the function are best-effort: the affinity hint may not be set
+ * due to config support, irq type and sharing.
+ *
+ */
+static inline
+int virtqueue_set_affinity(struct virtqueue *vq, int cpu)
+{
+	struct virtio_device *vdev = vq->vdev;
+	if (vdev->config->set_vq_affinity)
+		return vdev->config->set_vq_affinity(vq, cpu);
+	return 0;
+}
+
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_VIRTIO_CONFIG_H */
-- 
1.7.1
