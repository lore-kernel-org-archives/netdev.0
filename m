From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [ver3 PATCH 5/6] virtio: Implement find_vqs_irq()
Date: Fri, 11 Nov 2011 18:36:15 +0530
Message-ID: <20111111130615.9878.93574.sendpatchset@krkumar2.in.ibm.com>
References: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	davem@davemloft.net, Krishna Kumar <krkumar2@in.ibm.com>,
	kvm@vger.kernel.org
To: rusty@rustcorp.com.au, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:33847 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762Ab1KKOAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 09:00:33 -0500
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Fri, 11 Nov 2011 18:40:39 +0530
In-Reply-To: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement find_vqs_irq() to reduce number of vectors. It can
be used to specify which vq's need their own irqs, and which
can share irqs with other vq's.

Signed-off-by: krkumar2@in.ibm.com
---
 drivers/virtio/virtio_pci.c   |  108 ++++++++++++++++++++++++--------
 include/linux/virtio_config.h |   14 ++++
 2 files changed, 95 insertions(+), 27 deletions(-)

diff -ruNp org/drivers/virtio/virtio_pci.c new/drivers/virtio/virtio_pci.c
--- org/drivers/virtio/virtio_pci.c	2011-11-11 16:45:09.000000000 +0530
+++ new/drivers/virtio/virtio_pci.c	2011-11-11 16:54:35.000000000 +0530
@@ -40,7 +40,7 @@ struct virtio_pci_device
 	/* the IO mapping for the PCI config space */
 	void __iomem *ioaddr;
 
-	/* a list of queues so we can dispatch IRQs */
+	/* a list of queues which have registered to receive IRQs */
 	spinlock_t lock;
 	struct list_head virtqueues;
 
@@ -196,7 +196,7 @@ static irqreturn_t vp_config_changed(int
 	return IRQ_HANDLED;
 }
 
-/* Notify all virtqueues on an interrupt. */
+/* Notify all vq's on 'virtqueues' list on an interrupt. */
 static irqreturn_t vp_vring_interrupt(int irq, void *opaque)
 {
 	struct virtio_pci_device *vp_dev = opaque;
@@ -358,7 +358,7 @@ static struct virtqueue *setup_vq(struct
 	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
 	struct virtio_pci_vq_info *info;
 	struct virtqueue *vq;
-	unsigned long flags, size;
+	unsigned long size;
 	u16 num;
 	int err;
 
@@ -378,6 +378,7 @@ static struct virtqueue *setup_vq(struct
 
 	info->num = num;
 	info->msix_vector = msix_vec;
+	INIT_LIST_HEAD(&info->node);
 
 	size = PAGE_ALIGN(vring_size(num, VIRTIO_PCI_VRING_ALIGN));
 	info->queue = alloc_pages_exact(size, GFP_KERNEL|__GFP_ZERO);
@@ -411,14 +412,6 @@ static struct virtqueue *setup_vq(struct
 		}
 	}
 
-	if (callback) {
-		spin_lock_irqsave(&vp_dev->lock, flags);
-		list_add(&info->node, &vp_dev->virtqueues);
-		spin_unlock_irqrestore(&vp_dev->lock, flags);
-	} else {
-		INIT_LIST_HEAD(&info->node);
-	}
-
 	return vq;
 
 out_assign:
@@ -472,7 +465,8 @@ static void vp_del_vqs(struct virtio_dev
 		if (vp_dev->per_vq_vectors &&
 			info->msix_vector != VIRTIO_MSI_NO_VECTOR)
 			free_irq(vp_dev->msix_entries[info->msix_vector].vector,
-				 vq);
+				 list_empty(&info->node) ?
+				     (void *)vq : (void *)vp_dev);
 		vp_del_vq(vq);
 	}
 	vp_dev->per_vq_vectors = false;
@@ -480,16 +474,37 @@ static void vp_del_vqs(struct virtio_dev
 	vp_free_vectors(vdev);
 }
 
+static void add_vq_to_list(struct virtqueue *vq,
+			   struct virtio_pci_device *vp_dev,
+			   vq_callback_t *cb)
+{
+	struct virtio_pci_vq_info *info = vq->priv;
+	unsigned long flags;
+
+	if (cb) {
+		spin_lock_irqsave(&vp_dev->lock, flags);
+		list_add(&info->node, &vp_dev->virtqueues);
+		spin_unlock_irqrestore(&vp_dev->lock, flags);
+	}
+}
+
+/* Return true if flags is NULL, or 'bit'# in flags is clear */
+static bool bit_clear(unsigned long *flags, int bit)
+{
+	return flags ? !test_bit(bit, flags) : true;
+}
+
 static int vp_try_to_find_vqs(struct virtio_device *vdev, unsigned nvqs,
 			      struct virtqueue *vqs[],
 			      vq_callback_t *callbacks[],
 			      const char *names[],
 			      bool use_msix,
-			      bool per_vq_vectors)
+			      bool per_vq_vectors, unsigned long *flags)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
 	u16 msix_vec;
 	int i, err, nvectors, allocated_vectors;
+	int count = 0;	/* Count of vq's using shared irq's */
 
 	if (!use_msix) {
 		/* Old style: one normal interrupt for change and all vqs. */
@@ -500,9 +515,19 @@ static int vp_try_to_find_vqs(struct vir
 		if (per_vq_vectors) {
 			/* Best option: one for change interrupt, one per vq. */
 			nvectors = 1;
-			for (i = 0; i < nvqs; ++i)
-				if (callbacks[i])
+			for (i = 0; i < nvqs; ++i) {
+				bool alloc_irq = bit_clear(flags, i);
+
+				/*
+				 * We allocate a vector if cb is present,
+				 * AND (driver requested a vector OR this
+				 * is the first shared vector).
+				 */
+				if (callbacks[i] &&
+				    (alloc_irq || ++count == 1))
 					++nvectors;
+			}
+			count = 0;
 		} else {
 			/* Second best: one for change, shared for all vqs. */
 			nvectors = 2;
@@ -516,20 +541,38 @@ static int vp_try_to_find_vqs(struct vir
 	vp_dev->per_vq_vectors = per_vq_vectors;
 	allocated_vectors = vp_dev->msix_used_vectors;
 	for (i = 0; i < nvqs; ++i) {
-		if (!callbacks[i] || !vp_dev->msix_enabled)
+		bool alloc_irq = bit_clear(flags, i);
+		irq_handler_t irq_handler;
+		void *data;
+
+		if (!callbacks[i] || !vp_dev->msix_enabled ||
+		    !(alloc_irq || ++count == 1))
 			msix_vec = VIRTIO_MSI_NO_VECTOR;
 		else if (vp_dev->per_vq_vectors)
 			msix_vec = allocated_vectors++;
 		else
 			msix_vec = VP_MSIX_VQ_VECTOR;
+
 		vqs[i] = setup_vq(vdev, i, callbacks[i], names[i], msix_vec);
 		if (IS_ERR(vqs[i])) {
 			err = PTR_ERR(vqs[i]);
 			goto error_find;
 		}
 
-		if (!vp_dev->per_vq_vectors || msix_vec == VIRTIO_MSI_NO_VECTOR)
+		if (!vp_dev->per_vq_vectors ||
+		    msix_vec == VIRTIO_MSI_NO_VECTOR) {
+			add_vq_to_list(vqs[i], vp_dev, callbacks[i]);
 			continue;
+		}
+
+		if (alloc_irq) {
+			irq_handler = vring_interrupt;
+			data = vqs[i];
+		} else {
+			add_vq_to_list(vqs[i], vp_dev, callbacks[i]);
+			irq_handler = vp_vring_interrupt;
+			data = vp_dev;
+		}
 
 		/* allocate per-vq irq if available and necessary */
 		snprintf(vp_dev->msix_names[msix_vec],
@@ -537,9 +580,9 @@ static int vp_try_to_find_vqs(struct vir
 			 "%s-%s",
 			 dev_name(&vp_dev->vdev.dev), names[i]);
 		err = request_irq(vp_dev->msix_entries[msix_vec].vector,
-				  vring_interrupt, 0,
+				  irq_handler, 0,
 				  vp_dev->msix_names[msix_vec],
-				  vqs[i]);
+				  data);
 		if (err) {
 			vp_del_vq(vqs[i]);
 			goto error_find;
@@ -554,26 +597,36 @@ error_request:
 	return err;
 }
 
-/* the config->find_vqs() implementation */
-static int vp_find_vqs(struct virtio_device *vdev, unsigned nvqs,
-		       struct virtqueue *vqs[],
-		       vq_callback_t *callbacks[],
-		       const char *names[])
+/* the config->find_vqs_irq() implementation */
+static int vp_find_vqs_irq(struct virtio_device *vdev, unsigned nvqs,
+			  struct virtqueue *vqs[],
+			  vq_callback_t *callbacks[],
+			  const char *names[], unsigned long *flags)
 {
 	int err;
 
 	/* Try MSI-X with one vector per queue. */
-	err = vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names, true, true);
+	err = vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names, true, true,
+				 flags);
 	if (!err)
 		return 0;
 	/* Fallback: MSI-X with one vector for config, one shared for queues. */
 	err = vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names,
-				 true, false);
+				 true, false, NULL);
 	if (!err)
 		return 0;
 	/* Finally fall back to regular interrupts. */
 	return vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names,
-				  false, false);
+				  false, false, NULL);
+}
+
+/* the config->find_vqs() implementation */
+static int vp_find_vqs(struct virtio_device *vdev, unsigned nvqs,
+		       struct virtqueue *vqs[],
+		       vq_callback_t *callbacks[],
+		       const char *names[])
+{
+	return vp_find_vqs_irq(vdev, nvqs, vqs, callbacks, names, NULL);
 }
 
 static struct virtio_config_ops virtio_pci_config_ops = {
@@ -583,6 +636,7 @@ static struct virtio_config_ops virtio_p
 	.set_status	= vp_set_status,
 	.reset		= vp_reset,
 	.find_vqs	= vp_find_vqs,
+	.find_vqs_irq	= vp_find_vqs_irq,
 	.del_vqs	= vp_del_vqs,
 	.get_features	= vp_get_features,
 	.finalize_features = vp_finalize_features,
diff -ruNp org/include/linux/virtio_config.h new/include/linux/virtio_config.h
--- org/include/linux/virtio_config.h	2011-11-11 16:45:09.000000000 +0530
+++ new/include/linux/virtio_config.h	2011-11-11 16:45:21.000000000 +0530
@@ -92,6 +92,16 @@
  *	callbacks: array of callbacks, for each virtqueue
  *	names: array of virtqueue names (mainly for debugging)
  *	Returns 0 on success or error status
+ * @find_vqs_irq: find virtqueues and instantiate them. The flags parameter
+ *		  indicates the vq's that can share irq's.
+ *	vdev: the virtio_device
+ *	nvqs: the number of virtqueues to find
+ *	vqs: on success, includes new virtqueues
+ *	callbacks: array of callbacks, for each virtqueue
+ *	names: array of virtqueue names (mainly for debugging)
+ *	flags: indicates which vq's need their own irq and which can share.
+ *	       See example usage in virtio_net.c
+ *	Returns 0 on success or error status
  * @del_vqs: free virtqueues found by find_vqs().
  * @get_features: get the array of feature bits for this device.
  *	vdev: the virtio_device
@@ -114,6 +124,10 @@ struct virtio_config_ops {
 			struct virtqueue *vqs[],
 			vq_callback_t *callbacks[],
 			const char *names[]);
+	int (*find_vqs_irq)(struct virtio_device *vdev, unsigned nvqs,
+			    struct virtqueue *vqs[],
+			    vq_callback_t *callbacks[],
+			    const char *names[], unsigned long *flags);
 	void (*del_vqs)(struct virtio_device *);
 	u32 (*get_features)(struct virtio_device *vdev);
 	void (*finalize_features)(struct virtio_device *vdev);
