From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [v3 RFC PATCH 1/4] Change virtqueue structure
Date: Wed, 20 Oct 2010 14:24:59 +0530
Message-ID: <20101020085459.15579.37705.sendpatchset@krkumar2.in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
Cc: eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, arnd@arndb.de, avi@redhat.com,
	anthony@codemonkey.ws, Krishna Kumar <krkumar2@in.ibm.com>
To: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:54028 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334Ab0JTIzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 04:55:09 -0400
In-Reply-To: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move queue_index from virtio_pci_vq_info to virtqueue.  This
allows callback handlers to figure out the queue number for
the vq that needs attention.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>  
---
 drivers/virtio/virtio_pci.c |   10 +++-------
 include/linux/virtio.h      |    1 +
 2 files changed, 4 insertions(+), 7 deletions(-)

diff -ruNp org/include/linux/virtio.h new.dynamic.optimize_vhost/include/linux/virtio.h
--- org/include/linux/virtio.h	2010-10-11 10:20:22.000000000 +0530
+++ new.dynamic.optimize_vhost/include/linux/virtio.h	2010-10-15 13:25:42.000000000 +0530
@@ -22,6 +22,7 @@ struct virtqueue {
 	void (*callback)(struct virtqueue *vq);
 	const char *name;
 	struct virtio_device *vdev;
+	int queue_index;	/* the index of the queue */
 	void *priv;
 };
 
diff -ruNp org/drivers/virtio/virtio_pci.c new.dynamic.optimize_vhost/drivers/virtio/virtio_pci.c
--- org/drivers/virtio/virtio_pci.c	2010-10-11 10:20:15.000000000 +0530
+++ new.dynamic.optimize_vhost/drivers/virtio/virtio_pci.c	2010-10-15 13:25:42.000000000 +0530
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
