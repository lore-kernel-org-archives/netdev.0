From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2 12/14] virtio: 64 bit features
Date: Fri, 20 May 2011 02:12:28 +0300
Message-ID: <6f89ede81c34d0b9a7cf8fea03e1c4c77b5cbfdb.1305846412.git.mst@redhat.com>
References: <cover.1305846412.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Carsten Otte <cotte@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	linux390@de.ibm.com, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Shirley Ma <xma@us.ibm.com>, lguest@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, kvm@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>, steved@us.ibm.com,
	habanero@linux.vnet.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1305846412.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extend features to 64 bit so we can use more
transport bits.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/lguest/lguest_device.c |    8 ++++----
 drivers/s390/kvm/kvm_virtio.c  |    8 ++++----
 drivers/virtio/virtio.c        |    8 ++++----
 drivers/virtio/virtio_pci.c    |   34 ++++++++++++++++++++++++++++------
 drivers/virtio/virtio_ring.c   |    2 ++
 include/linux/virtio.h         |    2 +-
 include/linux/virtio_config.h  |   15 +++++++++------
 include/linux/virtio_pci.h     |    9 ++++++++-
 8 files changed, 60 insertions(+), 26 deletions(-)

diff --git a/drivers/lguest/lguest_device.c b/drivers/lguest/lguest_device.c
index 69c84a1..d2d6953 100644
--- a/drivers/lguest/lguest_device.c
+++ b/drivers/lguest/lguest_device.c
@@ -93,17 +93,17 @@ static unsigned desc_size(const struct lguest_device_desc *desc)
 }
 
 /* This gets the device's feature bits. */
-static u32 lg_get_features(struct virtio_device *vdev)
+static u64 lg_get_features(struct virtio_device *vdev)
 {
 	unsigned int i;
-	u32 features = 0;
+	u64 features = 0;
 	struct lguest_device_desc *desc = to_lgdev(vdev)->desc;
 	u8 *in_features = lg_features(desc);
 
 	/* We do this the slow but generic way. */
-	for (i = 0; i < min(desc->feature_len * 8, 32); i++)
+	for (i = 0; i < min(desc->feature_len * 8, 64); i++)
 		if (in_features[i / 8] & (1 << (i % 8)))
-			features |= (1 << i);
+			features |= (1ull << i);
 
 	return features;
 }
diff --git a/drivers/s390/kvm/kvm_virtio.c b/drivers/s390/kvm/kvm_virtio.c
index 414427d..c56293c 100644
--- a/drivers/s390/kvm/kvm_virtio.c
+++ b/drivers/s390/kvm/kvm_virtio.c
@@ -79,16 +79,16 @@ static unsigned desc_size(const struct kvm_device_desc *desc)
 }
 
 /* This gets the device's feature bits. */
-static u32 kvm_get_features(struct virtio_device *vdev)
+static u64 kvm_get_features(struct virtio_device *vdev)
 {
 	unsigned int i;
-	u32 features = 0;
+	u64 features = 0;
 	struct kvm_device_desc *desc = to_kvmdev(vdev)->desc;
 	u8 *in_features = kvm_vq_features(desc);
 
-	for (i = 0; i < min(desc->feature_len * 8, 32); i++)
+	for (i = 0; i < min(desc->feature_len * 8, 64); i++)
 		if (in_features[i / 8] & (1 << (i % 8)))
-			features |= (1 << i);
+			features |= (1ull << i);
 	return features;
 }
 
diff --git a/drivers/virtio/virtio.c b/drivers/virtio/virtio.c
index efb35aa..52b24d7 100644
--- a/drivers/virtio/virtio.c
+++ b/drivers/virtio/virtio.c
@@ -112,7 +112,7 @@ static int virtio_dev_probe(struct device *_d)
 	struct virtio_device *dev = container_of(_d,struct virtio_device,dev);
 	struct virtio_driver *drv = container_of(dev->dev.driver,
 						 struct virtio_driver, driver);
-	u32 device_features;
+	u64 device_features;
 
 	/* We have a driver! */
 	add_status(dev, VIRTIO_CONFIG_S_DRIVER);
@@ -124,14 +124,14 @@ static int virtio_dev_probe(struct device *_d)
 	memset(dev->features, 0, sizeof(dev->features));
 	for (i = 0; i < drv->feature_table_size; i++) {
 		unsigned int f = drv->feature_table[i];
-		BUG_ON(f >= 32);
-		if (device_features & (1 << f))
+		BUG_ON(f >= 64);
+		if (device_features & (1ull << f))
 			set_bit(f, dev->features);
 	}
 
 	/* Transport features always preserved to pass to finalize_features. */
 	for (i = VIRTIO_TRANSPORT_F_START; i < VIRTIO_TRANSPORT_F_END; i++)
-		if (device_features & (1 << i))
+		if (device_features & (1ull << i))
 			set_bit(i, dev->features);
 
 	dev->config->finalize_features(dev);
diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
index 4fb5b2b..04b216f 100644
--- a/drivers/virtio/virtio_pci.c
+++ b/drivers/virtio/virtio_pci.c
@@ -44,6 +44,8 @@ struct virtio_pci_device
 	spinlock_t lock;
 	struct list_head virtqueues;
 
+	/* 64 bit features */
+	int features_hi;
 	/* MSI-X support */
 	int msix_enabled;
 	int intx_enabled;
@@ -103,26 +105,46 @@ static struct virtio_pci_device *to_vp_device(struct virtio_device *vdev)
 }
 
 /* virtio config->get_features() implementation */
-static u32 vp_get_features(struct virtio_device *vdev)
+static u64 vp_get_features(struct virtio_device *vdev)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
+	u32 flo, fhi;
 
-	/* When someone needs more than 32 feature bits, we'll need to
+	/* When someone needs more than 32 feature bits, we need to
 	 * steal a bit to indicate that the rest are somewhere else. */
-	return ioread32(vp_dev->ioaddr + VIRTIO_PCI_HOST_FEATURES);
+	flo = ioread32(vp_dev->ioaddr + VIRTIO_PCI_HOST_FEATURES);
+	if (flo & (0x1 << VIRTIO_F_FEATURES_HI)) {
+		vp_dev->features_hi = 1;
+		iowrite32(0x1 << VIRTIO_F_FEATURES_HI,
+			  vp_dev->ioaddr + VIRTIO_PCI_GUEST_FEATURES);
+		fhi = ioread32(vp_dev->ioaddr + VIRTIO_PCI_HOST_FEATURES_HI);
+	} else {
+		vp_dev->features_hi = 0;
+		fhi = 0;
+	}
+	return (((u64)fhi) << 32) | flo;
 }
 
 /* virtio config->finalize_features() implementation */
 static void vp_finalize_features(struct virtio_device *vdev)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
+	u32 flo, fhi;
 
 	/* Give virtio_ring a chance to accept features. */
 	vring_transport_features(vdev);
 
-	/* We only support 32 feature bits. */
-	BUILD_BUG_ON(ARRAY_SIZE(vdev->features) != 1);
-	iowrite32(vdev->features[0], vp_dev->ioaddr+VIRTIO_PCI_GUEST_FEATURES);
+	/* We only support 64 feature bits. */
+	BUILD_BUG_ON(ARRAY_SIZE(vdev->features) != 64 / BITS_PER_LONG);
+	flo = vdev->features[0];
+	fhi = vdev->features[64 / BITS_PER_LONG - 1] >> (BITS_PER_LONG - 32);
+	iowrite32(flo, vp_dev->ioaddr + VIRTIO_PCI_GUEST_FEATURES);
+	if (flo & (0x1 << VIRTIO_F_FEATURES_HI)) {
+		vp_dev->features_hi = 1;
+		iowrite32(fhi, vp_dev->ioaddr + VIRTIO_PCI_GUEST_FEATURES_HI);
+	} else {
+		vp_dev->features_hi = 0;
+	}
 }
 
 /* virtio config->get() implementation */
diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 8218fe6..4a7a651 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -534,6 +534,8 @@ void vring_transport_features(struct virtio_device *vdev)
 
 	for (i = VIRTIO_TRANSPORT_F_START; i < VIRTIO_TRANSPORT_F_END; i++) {
 		switch (i) {
+		case VIRTIO_F_FEATURES_HI:
+			break;
 		case VIRTIO_RING_F_INDIRECT_DESC:
 			break;
 		case VIRTIO_RING_F_EVENT_IDX:
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index 58c0953..944ebcd 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -119,7 +119,7 @@ struct virtio_device {
 	struct virtio_config_ops *config;
 	struct list_head vqs;
 	/* Note that this is a Linux set_bit-style bitmap. */
-	unsigned long features[1];
+	unsigned long features[64 / BITS_PER_LONG];
 	void *priv;
 };
 
diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
index 800617b..b1a1981 100644
--- a/include/linux/virtio_config.h
+++ b/include/linux/virtio_config.h
@@ -18,16 +18,19 @@
 /* We've given up on this device. */
 #define VIRTIO_CONFIG_S_FAILED		0x80
 
-/* Some virtio feature bits (currently bits 28 through 31) are reserved for the
+/* Some virtio feature bits (currently bits 28 through 39) are reserved for the
  * transport being used (eg. virtio_ring), the rest are per-device feature
  * bits. */
 #define VIRTIO_TRANSPORT_F_START	28
-#define VIRTIO_TRANSPORT_F_END		32
+#define VIRTIO_TRANSPORT_F_END		40
 
 /* Do we get callbacks when the ring is completely used, even if we've
  * suppressed them? */
 #define VIRTIO_F_NOTIFY_ON_EMPTY	24
 
+/* Enables feature bits 32 to 63 (only really required for virtio_pci). */
+#define VIRTIO_F_FEATURES_HI		31
+
 #ifdef __KERNEL__
 #include <linux/err.h>
 #include <linux/virtio.h>
@@ -72,7 +75,7 @@
  * @del_vqs: free virtqueues found by find_vqs().
  * @get_features: get the array of feature bits for this device.
  *	vdev: the virtio_device
- *	Returns the first 32 feature bits (all we currently need).
+ *	Returns the first 64 feature bits (all we currently need).
  * @finalize_features: confirm what device features we'll be using.
  *	vdev: the virtio_device
  *	This gives the final feature bits for the device: it can change
@@ -92,7 +95,7 @@ struct virtio_config_ops {
 			vq_callback_t *callbacks[],
 			const char *names[]);
 	void (*del_vqs)(struct virtio_device *);
-	u32 (*get_features)(struct virtio_device *vdev);
+	u64 (*get_features)(struct virtio_device *vdev);
 	void (*finalize_features)(struct virtio_device *vdev);
 };
 
@@ -110,9 +113,9 @@ static inline bool virtio_has_feature(const struct virtio_device *vdev,
 {
 	/* Did you forget to fix assumptions on max features? */
 	if (__builtin_constant_p(fbit))
-		BUILD_BUG_ON(fbit >= 32);
+		BUILD_BUG_ON(fbit >= 64);
 	else
-		BUG_ON(fbit >= 32);
+		BUG_ON(fbit >= 64);
 
 	if (fbit < VIRTIO_TRANSPORT_F_START)
 		virtio_check_driver_offered_feature(vdev, fbit);
diff --git a/include/linux/virtio_pci.h b/include/linux/virtio_pci.h
index 9a3d7c4..90f9725 100644
--- a/include/linux/virtio_pci.h
+++ b/include/linux/virtio_pci.h
@@ -55,9 +55,16 @@
 /* Vector value used to disable MSI for queue */
 #define VIRTIO_MSI_NO_VECTOR            0xffff
 
+/* An extended 32-bit r/o bitmask of the features supported by the host */
+#define VIRTIO_PCI_HOST_FEATURES_HI	24
+
+/* An extended 32-bit r/w bitmask of features activated by the guest */
+#define VIRTIO_PCI_GUEST_FEATURES_HI	28
+
 /* The remaining space is defined by each driver as the per-driver
  * configuration space */
-#define VIRTIO_PCI_CONFIG(dev)		((dev)->msix_enabled ? 24 : 20)
+#define VIRTIO_PCI_CONFIG(dev)		((dev)->features_hi ? 32 : \
+						(dev)->msix_enabled ? 24 : 20)
 
 /* Virtio ABI version, this must match exactly */
 #define VIRTIO_PCI_ABI_VERSION		0
-- 
1.7.5.53.gc233e
