From: Liu Ping Fan <kernelfans@gmail.com>
Subject: [PATCH 1/2] [kvm/virtio]: make virtio support NUMA attr
Date: Thu, 17 May 2012 17:20:55 +0800
Message-ID: <1337246456-30909-4-git-send-email-kernelfans@gmail.com>
References: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org,
	Avi Kivity <avi@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ryan Harper <ryanh@us.ibm.com>, Shirley Ma <xma@us.ibm.com>,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>
To: kvm@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liu Ping Fan <pingfank@linux.vnet.ibm.com>

For each numa node reported by vhost, we alloc a pair of i/o vq,
and assign them msix IRQ, and set irq affinity to a set of vcpu
in the same node.
Also we alloc vqs on PAGE_SIZE align, so they will be allocated by
host when pg fault happen on different node.

Signed-off-by: Liu Ping Fan <pingfank@linux.vnet.ibm.com>
---
 drivers/virtio/virtio.c       |    2 +-
 drivers/virtio/virtio_pci.c   |   35 +++++++++++++++++++++++++++++++++--
 drivers/virtio/virtio_ring.c  |    9 ++++++---
 include/linux/virtio.h        |    9 +++++++++
 include/linux/virtio_config.h |    1 +
 include/linux/virtio_pci.h    |    9 +++++++++
 6 files changed, 59 insertions(+), 6 deletions(-)

diff --git a/drivers/virtio/virtio.c b/drivers/virtio/virtio.c
index 984c501..79e873f 100644
--- a/drivers/virtio/virtio.c
+++ b/drivers/virtio/virtio.c
@@ -136,7 +136,7 @@ static int virtio_dev_probe(struct device *_d)
 			set_bit(i, dev->features);
 
 	dev->config->finalize_features(dev);
-
+	dev->config->get_numa_map(dev);
 	err = drv->probe(dev);
 	if (err)
 		add_status(dev, VIRTIO_CONFIG_S_FAILED);
diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
index 2e03d41..5bb8a97 100644
--- a/drivers/virtio/virtio_pci.c
+++ b/drivers/virtio/virtio_pci.c
@@ -129,6 +129,24 @@ static void vp_finalize_features(struct virtio_device *vdev)
 	iowrite32(vdev->features[0], vp_dev->ioaddr+VIRTIO_PCI_GUEST_FEATURES);
 }
 
+static void vp_get_numa_map(struct virtio_device *vdev)
+{
+	int i, cnt,  sz = 32;
+	int cur, prev = 0;
+	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
+
+	/* We only support 32 numa bits. */
+	vdev->allow_map = ioread32(vp_dev->ioaddr+VIRTIO_PCI_NUMA_MAP);
+	for (i = 0; i < sz; i++) {
+		cur = find_next_bit(&vdev->allow_map, sz, prev);
+		prev = cur;
+		if (cur >= sz)
+			break;
+		cnt++;
+	}
+	vdev->node_cnt = cnt;
+}
+
 /* virtio config->get() implementation */
 static void vp_get(struct virtio_device *vdev, unsigned offset,
 		   void *buf, unsigned len)
@@ -516,6 +534,8 @@ static int vp_try_to_find_vqs(struct virtio_device *vdev, unsigned nvqs,
 	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
 	u16 msix_vec;
 	int i, err, nvectors, allocated_vectors;
+	int irq, next, prev = 0;
+	struct cpumask *mask;
 
 	if (!use_msix) {
 		/* Old style: one normal interrupt for change and all vqs. */
@@ -562,14 +582,24 @@ static int vp_try_to_find_vqs(struct virtio_device *vdev, unsigned nvqs,
 			 sizeof *vp_dev->msix_names,
 			 "%s-%s",
 			 dev_name(&vp_dev->vdev.dev), names[i]);
-		err = request_irq(vp_dev->msix_entries[msix_vec].vector,
-				  vring_interrupt, 0,
+		irq = vp_dev->msix_entries[msix_vec].vector;
+		err = request_irq(irq, vring_interrupt, 0,
 				  vp_dev->msix_names[msix_vec],
 				  vqs[i]);
 		if (err) {
 			vp_del_vq(vqs[i]);
 			goto error_find;
 		}
+		if (i == vdev->node_cnt)
+			prev = 0;
+		/* fix me the @size */
+		next = find_next_bit(vdev->allow_map, 64, prev);
+		prev = next;
+		if (next < 64) {
+			mask = vnode_to_vcpumask(next);
+			mask = cpumask_and(mask, cpu_online_mask, mask);
+			irq_set_affinity(irq, mask);
+		}
 	}
 	return 0;
 
@@ -619,6 +649,7 @@ static struct virtio_config_ops virtio_pci_config_ops = {
 	.del_vqs	= vp_del_vqs,
 	.get_features	= vp_get_features,
 	.finalize_features = vp_finalize_features,
+	.get_numa_map = vp_get_numa_map,
 	.bus_name	= vp_bus_name,
 };
 
diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 5aa43c3..5baa949 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -626,15 +626,18 @@ struct virtqueue *vring_new_virtqueue(unsigned int num,
 				      const char *name)
 {
 	struct vring_virtqueue *vq;
-	unsigned int i;
+	unsigned int i, size, max;
 
 	/* We assume num is a power of 2. */
 	if (num & (num - 1)) {
 		dev_warn(&vdev->dev, "Bad virtqueue length %u\n", num);
 		return NULL;
 	}
-
-	vq = kmalloc(sizeof(*vq) + sizeof(void *)*num, GFP_KERNEL);
+	size = PAGE_ALIGN (sizeof(*vq) + sizeof(void *)*num);
+	/* Allocate on PAGE boundary, so host can locate them at proper
+	 * node
+	 */
+	vq = kmalloc(size, GFP_KERNEL);
 	if (!vq)
 		return NULL;
 
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index 8efd28a..ec992c9 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -9,6 +9,12 @@
 #include <linux/mod_devicetable.h>
 #include <linux/gfp.h>
 
+struct virtio_node {
+	int node_id;
+	struct virtqueue *rvq;
+	struct virtqueue *svq;
+};
+
 /**
  * virtqueue - a queue to register buffers for sending or receiving.
  * @list: the chain of virtqueues for this device
@@ -22,6 +28,7 @@ struct virtqueue {
 	void (*callback)(struct virtqueue *vq);
 	const char *name;
 	struct virtio_device *vdev;
+	struct virtio_node *node;
 	void *priv;
 };
 
@@ -66,6 +73,8 @@ struct virtio_device {
 	struct virtio_device_id id;
 	struct virtio_config_ops *config;
 	struct list_head vqs;
+	int node_cnt;
+	unsigned long allow_map;
 	/* Note that this is a Linux set_bit-style bitmap. */
 	unsigned long features[1];
 	void *priv;
diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
index 7323a33..5e2fd77 100644
--- a/include/linux/virtio_config.h
+++ b/include/linux/virtio_config.h
@@ -124,6 +124,7 @@ struct virtio_config_ops {
 	void (*del_vqs)(struct virtio_device *);
 	u32 (*get_features)(struct virtio_device *vdev);
 	void (*finalize_features)(struct virtio_device *vdev);
+	void (*get_numa_map)(struct virtio_device *vdev);
 	const char *(*bus_name)(struct virtio_device *vdev);
 };
 
diff --git a/include/linux/virtio_pci.h b/include/linux/virtio_pci.h
index ea66f3f..1426717 100644
--- a/include/linux/virtio_pci.h
+++ b/include/linux/virtio_pci.h
@@ -78,9 +78,18 @@
 /* Vector value used to disable MSI for queue */
 #define VIRTIO_MSI_NO_VECTOR            0xffff
 
+#ifdef VIRTIO_NUMA
+/* 32bits to show allowed numa */
+#define VIRTIO_PCI_NUMA_MAP         24
+
+/* The remaining space is defined by each driver as the per-driver
+ * configuration space */
+#define VIRTIO_PCI_CONFIG(dev)		28
+#else
 /* The remaining space is defined by each driver as the per-driver
  * configuration space */
 #define VIRTIO_PCI_CONFIG(dev)		((dev)->msix_enabled ? 24 : 20)
+#endif
 
 /* Virtio ABI version, this must match exactly */
 #define VIRTIO_PCI_ABI_VERSION		0
-- 
1.7.4.4
