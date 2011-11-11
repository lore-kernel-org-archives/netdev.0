From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [ver3 PATCH 2/6] virtio: Move 'num_queues' to virtqueue
Date: Fri, 11 Nov 2011 18:33:19 +0530
Message-ID: <20111111130319.9878.31938.sendpatchset@krkumar2.in.ibm.com>
References: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	davem@davemloft.net, Krishna Kumar <krkumar2@in.ibm.com>,
	kvm@vger.kernel.org
To: rusty@rustcorp.com.au, mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move queue_index from "virtio_net_config" to "virtqueue". This is
needed to figure out the queue number of the vq in the 'done'
handler of the device.

Signed-off-by: krkumar2@in.ibm.com
---
 drivers/virtio/virtio_pci.c |   10 +++-------
 include/linux/virtio.h      |    1 +
 2 files changed, 4 insertions(+), 7 deletions(-)

diff -ruNp org/drivers/virtio/virtio_pci.c new/drivers/virtio/virtio_pci.c
--- org/drivers/virtio/virtio_pci.c	2011-11-11 16:44:30.000000000 +0530
+++ new/drivers/virtio/virtio_pci.c	2011-11-11 16:44:45.000000000 +0530
@@ -75,9 +75,6 @@ struct virtio_pci_vq_info
 	/* the number of entries in the queue */
 	int num;
 
-	/* the index of the queue */
-	int queue_index;
-
 	/* the virtual address of the ring queue */
 	void *queue;
 
@@ -180,11 +177,10 @@ static void vp_reset(struct virtio_devic
 static void vp_notify(struct virtqueue *vq)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vq->vdev);
-	struct virtio_pci_vq_info *info = vq->priv;
 
 	/* we write the queue's selector into the notification register to
 	 * signal the other end */
-	iowrite16(info->queue_index, vp_dev->ioaddr + VIRTIO_PCI_QUEUE_NOTIFY);
+	iowrite16(vq->queue_index, vp_dev->ioaddr + VIRTIO_PCI_QUEUE_NOTIFY);
 }
 
 /* Handle a configuration change: Tell driver if it wants to know. */
@@ -380,7 +376,6 @@ static struct virtqueue *setup_vq(struct
 	if (!info)
 		return ERR_PTR(-ENOMEM);
 
-	info->queue_index = index;
 	info->num = num;
 	info->msix_vector = msix_vec;
 
@@ -403,6 +398,7 @@ static struct virtqueue *setup_vq(struct
 		goto out_activate_queue;
 	}
 
+	vq->queue_index = index;
 	vq->priv = info;
 	info->vq = vq;
 
@@ -445,7 +441,7 @@ static void vp_del_vq(struct virtqueue *
 	list_del(&info->node);
 	spin_unlock_irqrestore(&vp_dev->lock, flags);
 
-	iowrite16(info->queue_index, vp_dev->ioaddr + VIRTIO_PCI_QUEUE_SEL);
+	iowrite16(vq->queue_index, vp_dev->ioaddr + VIRTIO_PCI_QUEUE_SEL);
 
 	if (vp_dev->msix_enabled) {
 		iowrite16(VIRTIO_MSI_NO_VECTOR,
diff -ruNp org/include/linux/virtio.h new/include/linux/virtio.h
--- org/include/linux/virtio.h	2011-11-11 16:44:30.000000000 +0530
+++ new/include/linux/virtio.h	2011-11-11 16:44:45.000000000 +0530
@@ -22,6 +22,7 @@ struct virtqueue {
 	void (*callback)(struct virtqueue *vq);
 	const char *name;
 	struct virtio_device *vdev;
+	int queue_index;	/* the index of the queue */
 	void *priv;
 };
 
