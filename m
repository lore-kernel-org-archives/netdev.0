From: Ravi Kerur <rkerur@gmail.com>
Subject: [PATCH v1 3/3] virtio-pci: Introduce channels
Date: Mon, 26 Oct 2015 10:52:49 -0700
Message-ID: <1445881969-24663-3-git-send-email-rkerur@gmail.com>
References: <1445881969-24663-1-git-send-email-rkerur@gmail.com>
Cc: jasowang@redhat.com, mst@redhat.com, rusty@rustcorp.com.au,
	Ravi Kerur <rkerur@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35401 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbbJZRwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 13:52:39 -0400
Received: by pasz6 with SMTP id z6so194560734pas.2
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 10:52:39 -0700 (PDT)
In-Reply-To: <1445881969-24663-1-git-send-email-rkerur@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port earlier patch from Jason Wang (dated 12/26/2014).

This patch introduces virtio pci channel which are virtqueue groups
that sharing a single MSIX irq. This can be used to reduce the irqs
needed by virtio device.

The channel are in fact a list of virtqueues, and vp_channel_interrupt()
was introduced to traverse the list. The current strategy was kept but
is converted to channel internally:

- per vq vectors was implemented through per vq channel
- sharing interrupts was implemented through a single channel for all
  virtqueues

This is done by letting vp_try_to_find_vqs() to accept the array of
channel names and the channels that each vq belongs to.

Signed-off-by: Ravi Kerur <rkerur@gmail.com>
---
 drivers/virtio/virtio_pci_common.c | 208 +++++++++++++++++++++++--------------
 drivers/virtio/virtio_pci_common.h |  23 ++--
 2 files changed, 146 insertions(+), 85 deletions(-)

diff --git a/drivers/virtio/virtio_pci_common.c b/drivers/virtio/virtio_pci_common.c
index 78f804a..5c0594e 100644
--- a/drivers/virtio/virtio_pci_common.c
+++ b/drivers/virtio/virtio_pci_common.c
@@ -76,6 +76,23 @@ static irqreturn_t vp_vring_interrupt(int irq, void *opaque)
 	return ret;
 }
 
+static irqreturn_t vp_channel_interrupt(int irq, void *opaque)
+{
+	struct virtio_pci_channel *vp_channel = opaque;
+	struct virtio_pci_vq_info *info;
+	irqreturn_t ret = IRQ_NONE;
+	unsigned long flags;
+
+	spin_lock_irqsave(&vp_channel->lock, flags);
+	list_for_each_entry(info, &vp_channel->virtqueues, node) {
+		if (vring_interrupt(irq, info->vq) == IRQ_HANDLED)
+			ret = IRQ_HANDLED;
+	}
+	spin_unlock_irqrestore(&vp_channel->lock, flags);
+
+	return ret;
+}
+
 /* A small wrapper to also acknowledge the interrupt when it's handled.
  * I really need an EIO hook for the vring so I can ack the interrupt once we
  * know that we'll be handling the IRQ but before we invoke the callback since
@@ -112,8 +129,12 @@ static void vp_free_vectors(struct virtio_device *vdev)
 		vp_dev->intx_enabled = 0;
 	}
 
-	for (i = 0; i < vp_dev->msix_used_vectors; ++i)
-		free_irq(vp_dev->msix_entries[i].vector, vp_dev);
+	if (vp_dev->msix_used_vectors)
+		free_irq(vp_dev->msix_entries[0].vector, vp_dev);
+
+	for (i = 1; i < vp_dev->msix_used_vectors; ++i)
+		free_irq(vp_dev->msix_entries[i].vector,
+			 &vp_dev->channels[i - 1]);
 
 	for (i = 0; i < vp_dev->msix_vectors; i++)
 		if (vp_dev->msix_affinity_masks[i])
@@ -137,8 +158,7 @@ static void vp_free_vectors(struct virtio_device *vdev)
 	vp_dev->msix_affinity_masks = NULL;
 }
 
-static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors,
-				   bool per_vq_vectors)
+static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
 	const char *name = dev_name(&vp_dev->vdev.dev);
@@ -175,8 +195,8 @@ static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors,
 	vp_dev->msix_enabled = 1;
 
 	/* Set the vector used for configuration */
-	v = vp_dev->msix_used_vectors;
-	snprintf(vp_dev->msix_names[v], sizeof *vp_dev->msix_names,
+	v = 0;
+	snprintf(vp_dev->msix_names[0], sizeof(*vp_dev->msix_names),
 		 "%s-config", name);
 	err = request_irq(vp_dev->msix_entries[v].vector,
 			  vp_config_changed, 0, vp_dev->msix_names[v],
@@ -192,18 +212,6 @@ static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors,
 		goto error;
 	}
 
-	if (!per_vq_vectors) {
-		/* Shared vector for all VQs */
-		v = vp_dev->msix_used_vectors;
-		snprintf(vp_dev->msix_names[v], sizeof *vp_dev->msix_names,
-			 "%s-virtqueues", name);
-		err = request_irq(vp_dev->msix_entries[v].vector,
-				  vp_vring_interrupt, 0, vp_dev->msix_names[v],
-				  vp_dev);
-		if (err)
-			goto error;
-		++vp_dev->msix_used_vectors;
-	}
 	return 0;
 error:
 	vp_free_vectors(vdev);
@@ -228,6 +236,7 @@ static struct virtqueue *vp_setup_vq(struct virtio_device *vdev, unsigned index,
 				     u16 msix_vec)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
+	struct virtio_pci_channel *vp_channel;
 	struct virtio_pci_vq_info *info = kmalloc(sizeof *info, GFP_KERNEL);
 	struct virtqueue *vq;
 	unsigned long flags;
@@ -242,9 +251,16 @@ static struct virtqueue *vp_setup_vq(struct virtio_device *vdev, unsigned index,
 
 	info->vq = vq;
 	if (callback) {
-		spin_lock_irqsave(&vp_dev->lock, flags);
-		list_add(&info->node, &vp_dev->virtqueues);
-		spin_unlock_irqrestore(&vp_dev->lock, flags);
+		if (msix_vec != VIRTIO_MSI_NO_VECTOR) {
+			vp_channel = &vp_dev->channels[msix_vec - 1];
+			spin_lock_irqsave(&vp_channel->lock, flags);
+			list_add(&info->node, &vp_channel->virtqueues);
+			spin_unlock_irqrestore(&vp_channel->lock, flags);
+		} else {
+			spin_lock_irqsave(&vp_dev->lock, flags);
+			list_add(&info->node, &vp_dev->virtqueues);
+			spin_unlock_irqrestore(&vp_dev->lock, flags);
+		}
 	} else {
 		INIT_LIST_HEAD(&info->node);
 	}
@@ -257,15 +273,17 @@ out_info:
 	return vq;
 }
 
-static void vp_del_vq(struct virtqueue *vq)
+static void vp_del_vq(struct virtqueue *vq,
+		      struct virtio_pci_channel *channel)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vq->vdev);
 	struct virtio_pci_vq_info *info = vp_dev->vqs[vq->index];
+	spinlock_t *lock = channel ? &channel->lock : &vp_dev->lock;
 	unsigned long flags;
 
-	spin_lock_irqsave(&vp_dev->lock, flags);
+	spin_lock_irqsave(lock, flags);
 	list_del(&info->node);
-	spin_unlock_irqrestore(&vp_dev->lock, flags);
+	spin_unlock_irqrestore(lock, flags);
 
 	vp_dev->del_vq(info);
 	kfree(info);
@@ -275,95 +293,103 @@ static void vp_del_vq(struct virtqueue *vq)
 void vp_del_vqs(struct virtio_device *vdev)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
+	struct virtio_pci_vq_info *info, *ninfo;
+	struct virtio_pci_channel *channel;
 	struct virtqueue *vq, *n;
-	struct virtio_pci_vq_info *info;
+	int i;
 
-	list_for_each_entry_safe(vq, n, &vdev->vqs, list) {
-		info = vp_dev->vqs[vq->index];
-		if (vp_dev->per_vq_vectors &&
-			info->msix_vector != VIRTIO_MSI_NO_VECTOR)
-			free_irq(vp_dev->msix_entries[info->msix_vector].vector,
-				 vq);
-		vp_del_vq(vq);
+	if (vp_dev->nchannels) {
+		for (i = 0; i < vp_dev->nchannels; i++) {
+			channel = &vp_dev->channels[i];
+			list_for_each_entry_safe(info, ninfo,
+						&channel->virtqueues, node) {
+				vp_del_vq(info->vq, channel);
+			}
+		}
+	} else {
+		list_for_each_entry_safe(vq, n, &vdev->vqs, list) {
+			vp_del_vq(vq, NULL);
+		}
 	}
-	vp_dev->per_vq_vectors = false;
+
+	vp_dev->nchannels = 0;
 
 	vp_free_vectors(vdev);
 	kfree(vp_dev->vqs);
 	vp_dev->vqs = NULL;
+	kfree(vp_dev->channels);
 }
 
 static int vp_try_to_find_vqs(struct virtio_device *vdev, unsigned nvqs,
 			      struct virtqueue *vqs[],
 			      vq_callback_t *callbacks[],
 			      const char *names[],
-			      bool use_msix,
-			      bool per_vq_vectors)
+			      unsigned *channels,
+			      const char *channel_names[],
+			      unsigned nchannels)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
 	u16 msix_vec;
-	int i, err, nvectors, allocated_vectors;
+	int i, err = 0;
 
 	vp_dev->vqs = kmalloc(nvqs * sizeof *vp_dev->vqs, GFP_KERNEL);
 	if (!vp_dev->vqs)
 		return -ENOMEM;
 
-	if (!use_msix) {
+	if (nchannels) {
+		vp_dev->channels = kmalloc(nchannels *
+					   sizeof(*vp_dev->channels),
+					   GFP_KERNEL);
+		if (!vp_dev->channels)
+			goto error_find;
+	}
+	vp_dev->nchannels = nchannels;
+
+	for (i = 0; i < nchannels; i++) {
+		spin_lock_init(&vp_dev->channels[i].lock);
+		INIT_LIST_HEAD(&vp_dev->channels[i].virtqueues);
+	}
+
+	if (!nchannels) {
 		/* Old style: one normal interrupt for change and all vqs. */
 		err = vp_request_intx(vdev);
 		if (err)
 			goto error_find;
 	} else {
-		if (per_vq_vectors) {
-			/* Best option: one for change interrupt, one per vq. */
-			nvectors = 1;
-			for (i = 0; i < nvqs; ++i)
-				if (callbacks[i])
-					++nvectors;
-		} else {
-			/* Second best: one for change, shared for all vqs. */
-			nvectors = 2;
-		}
+		err = vp_request_msix_vectors(vdev, nchannels + 1);
+		if (err)
+			goto error_find;
+	}
+
+	for (i = 0; i < nchannels; i++) {
+		snprintf(vp_dev->msix_names[i + 1],
+			sizeof(*vp_dev->msix_names),
+			"%s-%s",
+			dev_name(&vp_dev->vdev.dev), channel_names[i]);
+		err = request_irq(vp_dev->msix_entries[i + 1].vector,
+				vp_channel_interrupt, 0,
+				vp_dev->msix_names[i + 1],
+				&vp_dev->channels[i]);
 
-		err = vp_request_msix_vectors(vdev, nvectors, per_vq_vectors);
 		if (err)
 			goto error_find;
+		++vp_dev->msix_used_vectors;
 	}
 
-	vp_dev->per_vq_vectors = per_vq_vectors;
-	allocated_vectors = vp_dev->msix_used_vectors;
 	for (i = 0; i < nvqs; ++i) {
 		if (!names[i]) {
 			vqs[i] = NULL;
 			continue;
 		} else if (!callbacks[i] || !vp_dev->msix_enabled)
 			msix_vec = VIRTIO_MSI_NO_VECTOR;
-		else if (vp_dev->per_vq_vectors)
-			msix_vec = allocated_vectors++;
 		else
-			msix_vec = VP_MSIX_VQ_VECTOR;
+			msix_vec = channels[i] + 1;
 		vqs[i] = vp_setup_vq(vdev, i, callbacks[i], names[i], msix_vec);
 		if (IS_ERR(vqs[i])) {
 			err = PTR_ERR(vqs[i]);
 			goto error_find;
 		}
 
-		if (!vp_dev->per_vq_vectors || msix_vec == VIRTIO_MSI_NO_VECTOR)
-			continue;
-
-		/* allocate per-vq irq if available and necessary */
-		snprintf(vp_dev->msix_names[msix_vec],
-			 sizeof *vp_dev->msix_names,
-			 "%s-%s",
-			 dev_name(&vp_dev->vdev.dev), names[i]);
-		err = request_irq(vp_dev->msix_entries[msix_vec].vector,
-				  vring_interrupt, 0,
-				  vp_dev->msix_names[msix_vec],
-				  vqs[i]);
-		if (err) {
-			vp_del_vq(vqs[i]);
-			goto error_find;
-		}
 	}
 	return 0;
 
@@ -376,22 +402,48 @@ error_find:
 int vp_find_vqs(struct virtio_device *vdev, unsigned nvqs,
 		struct virtqueue *vqs[],
 		vq_callback_t *callbacks[],
-		const char *names[])
+		const char *names[],
+		unsigned channels[],
+		const char *channel_names[],
+		unsigned nchannels)
 {
-	int err;
+	int err, i;
+	const char *cnames[] = {"virtqueues"};
+
+	if (nchannels) {
+		/* Try channel settings */
+		err = vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names,
+					 channels, channel_names, nchannels);
+		if (!err)
+			return 0;
+	}
+
+	channels = kmalloc_array(nvqs, sizeof(unsigned), GFP_KERNEL);
+	if (!channels)
+		return -ENOMEM;
 
 	/* Try MSI-X with one vector per queue. */
-	err = vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names, true, true);
+	for (i = 0; i < nvqs; i++)
+		channels[i] = i;
+	err = vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names, channels,
+				 names, nvqs);
 	if (!err)
-		return 0;
+		goto out;
+
 	/* Fallback: MSI-X with one vector for config, one shared for queues. */
-	err = vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names,
-				 true, false);
+	for (i = 0; i < nvqs; i++)
+		channels[i] = 0;
+	err = vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names, channels,
+				 cnames, 1);
 	if (!err)
-		return 0;
+		goto out;
+
 	/* Finally fall back to regular interrupts. */
-	return vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names,
-				  false, false);
+	err = vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names,
+				NULL, NULL, 0);
+out:
+	kfree(channels);
+	return err;
 }
 
 const char *vp_bus_name(struct virtio_device *vdev)
diff --git a/drivers/virtio/virtio_pci_common.h b/drivers/virtio/virtio_pci_common.h
index b976d96..e8a739d 100644
--- a/drivers/virtio/virtio_pci_common.h
+++ b/drivers/virtio/virtio_pci_common.h
@@ -48,6 +48,11 @@ struct virtio_pci_vq_info {
 	unsigned msix_vector;
 };
 
+struct virtio_pci_channel {
+	spinlock_t lock;
+	struct list_head virtqueues;
+};
+
 /* Our device structure */
 struct virtio_pci_device {
 	struct virtio_device vdev;
@@ -88,6 +93,10 @@ struct virtio_pci_device {
 	/* array of all queues for house-keeping */
 	struct virtio_pci_vq_info **vqs;
 
+	/* array of channels */
+	struct virtio_pci_channel *channels;
+	unsigned nchannels;
+
 	/* MSI-X support */
 	int msix_enabled;
 	int intx_enabled;
@@ -98,12 +107,9 @@ struct virtio_pci_device {
 	char (*msix_names)[256];
 	/* Number of available vectors */
 	unsigned msix_vectors;
-	/* Vectors allocated, excluding per-vq vectors if any */
+	/* Vectors allocated */
 	unsigned msix_used_vectors;
 
-	/* Whether we have vector per vq */
-	bool per_vq_vectors;
-
 	struct virtqueue *(*setup_vq)(struct virtio_pci_device *vp_dev,
 				      struct virtio_pci_vq_info *info,
 				      unsigned idx,
@@ -137,9 +143,12 @@ bool vp_notify(struct virtqueue *vq);
 void vp_del_vqs(struct virtio_device *vdev);
 /* the config->find_vqs() implementation */
 int vp_find_vqs(struct virtio_device *vdev, unsigned nvqs,
-		       struct virtqueue *vqs[],
-		       vq_callback_t *callbacks[],
-		       const char *names[]);
+		struct virtqueue *vqs[],
+		vq_callback_t *callbacks[],
+		const char *names[],
+		unsigned channels[],
+		const char *channel_names[],
+		unsigned nchannels);
 const char *vp_bus_name(struct virtio_device *vdev);
 
 /* Setup the affinity for a virtqueue:
-- 
1.9.1
