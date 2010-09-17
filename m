From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [v2 RFC PATCH 1/4] Change virtqueue structure
Date: Fri, 17 Sep 2010 15:33:13 +0530
Message-ID: <20100917100313.21276.64524.sendpatchset@krkumar2.in.ibm.com>
References: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com>
Cc: kvm@vger.kernel.org, arnd@arndb.de, netdev@vger.kernel.org,
	avi@redhat.com, anthony@codemonkey.ws,
	Krishna Kumar <krkumar2@in.ibm.com>
To: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move queue_index from virtio_pci_vq_info to virtqueue. This
allows callback handlers to figure out the queue number for
the vq that needs attention.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com> 
---
 drivers/virtio/virtio_pci.c |   10 +++-------
 include/linux/virtio.h      |    1 +
 2 files changed, 4 insertions(+), 7 deletions(-)

diff -ruNp org2/include/linux/virtio.h tx_only2/include/linux/virtio.h
--- org2/include/linux/virtio.h	2010-06-02 18:46:43.000000000 +0530
+++ tx_only2/include/linux/virtio.h	2010-09-16 15:24:01.000000000 +0530
@@ -22,6 +22,7 @@ struct virtqueue {
 	void (*callback)(struct virtqueue *vq);
 	const char *name;
 	struct virtio_device *vdev;
+	int queue_index;	/* the index of the queue */
 	void *priv;
 };
 
diff -ruNp org2/drivers/virtio/virtio_pci.c tx_only2/drivers/virtio/virtio_pci.c
--- org2/drivers/virtio/virtio_pci.c	2010-08-05 14:48:06.000000000 +0530
+++ tx_only2/drivers/virtio/virtio_pci.c	2010-09-16 15:24:01.000000000 +0530
@@ -75,9 +75,6 @@ struct virtio_pci_vq_info
 	/* the number of entries in the queue */
 	int num;
 
-	/* the index of the queue */
-	int queue_index;
-
 	/* the virtual address of the ring queue */
 	void *queue;
 
@@ -185,11 +182,10 @@ static void vp_reset(struct virtio_devic
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
@@ -385,7 +381,6 @@ static struct virtqueue *setup_vq(struct
 	if (!info)
 		return ERR_PTR(-ENOMEM);
 
-	info->queue_index = index;
 	info->num = num;
 	info->msix_vector = msix_vec;
 
@@ -408,6 +403,7 @@ static struct virtqueue *setup_vq(struct
 		goto out_activate_queue;
 	}
 
+	vq->queue_index = index;
 	vq->priv = info;
 	info->vq = vq;
 
@@ -446,7 +442,7 @@ static void vp_del_vq(struct virtqueue *
 	list_del(&info->node);
 	spin_unlock_irqrestore(&vp_dev->lock, flags);
 
-	iowrite16(info->queue_index, vp_dev->ioaddr + VIRTIO_PCI_QUEUE_SEL);
+	iowrite16(vq->queue_index, vp_dev->ioaddr + VIRTIO_PCI_QUEUE_SEL);
 
 	if (vp_dev->msix_enabled) {
 		iowrite16(VIRTIO_MSI_NO_VECTOR,
