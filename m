From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 1/3] [RFC] Change virtqueue structure
Date: Mon, 28 Feb 2011 12:04:32 +0530
Message-ID: <20110228063432.24908.97160.sendpatchset@krkumar2.in.ibm.com>
References: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com>
Cc: eric.dumazet@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	horms@verge.net.au, avi@redhat.com, anthony@codemonkey.ws,
	kvm@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:38504 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413Ab1B1Gei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 01:34:38 -0500
In-Reply-To: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com>
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

diff -ruNp org/include/linux/virtio.h new/include/linux/virtio.h
--- org/include/linux/virtio.h	2010-10-11 10:20:22.000000000 +0530
+++ new/include/linux/virtio.h	2011-02-23 16:26:18.000000000 +0530
@@ -22,6 +22,7 @@ struct virtqueue {
 	void (*callback)(struct virtqueue *vq);
 	const char *name;
 	struct virtio_device *vdev;
+	int queue_index;	/* the index of the queue */
 	void *priv;
 };
 
diff -ruNp org/drivers/virtio/virtio_pci.c new/drivers/virtio/virtio_pci.c
--- org/drivers/virtio/virtio_pci.c	2011-01-28 11:38:24.000000000 +0530
+++ new/drivers/virtio/virtio_pci.c	2011-02-25 10:11:22.000000000 +0530
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
 
@@ -441,7 +437,7 @@ static void vp_del_vq(struct virtqueue *
 	list_del(&info->node);
 	spin_unlock_irqrestore(&vp_dev->lock, flags);
 
-	iowrite16(info->queue_index, vp_dev->ioaddr + VIRTIO_PCI_QUEUE_SEL);
+	iowrite16(vq->queue_index, vp_dev->ioaddr + VIRTIO_PCI_QUEUE_SEL);
 
 	if (vp_dev->msix_enabled) {
 		iowrite16(VIRTIO_MSI_NO_VECTOR,
