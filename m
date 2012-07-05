From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC V5 2/5] virtio_ring: move queue_index to vring_virtqueue
Date: Thu,  5 Jul 2012 18:29:51 +0800
Message-ID: <1341484194-8108-3-git-send-email-jasowang@redhat.com>
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

Instead of storing the queue index in virtio infos, this patch moves them to
vring_virtqueue and introduces helpers to set and get the value. This would
simplify the management and tracing.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/virtio/virtio_mmio.c |    5 +----
 drivers/virtio/virtio_pci.c  |   12 +++++-------
 drivers/virtio/virtio_ring.c |   17 +++++++++++++++++
 include/linux/virtio.h       |    4 ++++
 4 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/drivers/virtio/virtio_mmio.c b/drivers/virtio/virtio_mmio.c
index 453db0c..f5432b6 100644
--- a/drivers/virtio/virtio_mmio.c
+++ b/drivers/virtio/virtio_mmio.c
@@ -131,9 +131,6 @@ struct virtio_mmio_vq_info {
 	/* the number of entries in the queue */
 	unsigned int num;
 
-	/* the index of the queue */
-	int queue_index;
-
 	/* the virtual address of the ring queue */
 	void *queue;
 
@@ -324,7 +321,6 @@ static struct virtqueue *vm_setup_vq(struct virtio_device *vdev, unsigned index,
 		err = -ENOMEM;
 		goto error_kmalloc;
 	}
-	info->queue_index = index;
 
 	/* Allocate pages for the queue - start with a queue as big as
 	 * possible (limited by maximum size allowed by device), drop down
@@ -363,6 +359,7 @@ static struct virtqueue *vm_setup_vq(struct virtio_device *vdev, unsigned index,
 		goto error_new_virtqueue;
 	}
 
+	virtqueue_set_queue_index(vq, index);
 	vq->priv = info;
 	info->vq = vq;
 
diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
index 2e03d41..adb24f2 100644
--- a/drivers/virtio/virtio_pci.c
+++ b/drivers/virtio/virtio_pci.c
@@ -79,9 +79,6 @@ struct virtio_pci_vq_info
 	/* the number of entries in the queue */
 	int num;
 
-	/* the index of the queue */
-	int queue_index;
-
 	/* the virtual address of the ring queue */
 	void *queue;
 
@@ -202,11 +199,11 @@ static void vp_reset(struct virtio_device *vdev)
 static void vp_notify(struct virtqueue *vq)
 {
 	struct virtio_pci_device *vp_dev = to_vp_device(vq->vdev);
-	struct virtio_pci_vq_info *info = vq->priv;
 
 	/* we write the queue's selector into the notification register to
 	 * signal the other end */
-	iowrite16(info->queue_index, vp_dev->ioaddr + VIRTIO_PCI_QUEUE_NOTIFY);
+	iowrite16(virtqueue_get_queue_index(vq),
+		  vp_dev->ioaddr + VIRTIO_PCI_QUEUE_NOTIFY);
 }
 
 /* Handle a configuration change: Tell driver if it wants to know. */
@@ -402,7 +399,6 @@ static struct virtqueue *setup_vq(struct virtio_device *vdev, unsigned index,
 	if (!info)
 		return ERR_PTR(-ENOMEM);
 
-	info->queue_index = index;
 	info->num = num;
 	info->msix_vector = msix_vec;
 
@@ -425,6 +421,7 @@ static struct virtqueue *setup_vq(struct virtio_device *vdev, unsigned index,
 		goto out_activate_queue;
 	}
 
+	virtqueue_set_queue_index(vq, index);
 	vq->priv = info;
 	info->vq = vq;
 
@@ -467,7 +464,8 @@ static void vp_del_vq(struct virtqueue *vq)
 	list_del(&info->node);
 	spin_unlock_irqrestore(&vp_dev->lock, flags);
 
-	iowrite16(info->queue_index, vp_dev->ioaddr + VIRTIO_PCI_QUEUE_SEL);
+	iowrite16(virtqueue_get_queue_index(vq),
+		vp_dev->ioaddr + VIRTIO_PCI_QUEUE_SEL);
 
 	if (vp_dev->msix_enabled) {
 		iowrite16(VIRTIO_MSI_NO_VECTOR,
diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 5aa43c3..9c5aeea 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -106,6 +106,9 @@ struct vring_virtqueue
 	/* How to notify other side. FIXME: commonalize hcalls! */
 	void (*notify)(struct virtqueue *vq);
 
+	/* Index of the queue */
+	int queue_index;
+
 #ifdef DEBUG
 	/* They're supposed to lock for us. */
 	unsigned int in_use;
@@ -171,6 +174,20 @@ static int vring_add_indirect(struct vring_virtqueue *vq,
 	return head;
 }
 
+void virtqueue_set_queue_index(struct virtqueue *_vq, int queue_index)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+	vq->queue_index = queue_index;
+}
+EXPORT_SYMBOL_GPL(virtqueue_set_queue_index);
+
+int virtqueue_get_queue_index(struct virtqueue *_vq)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+	return vq->queue_index;
+}
+EXPORT_SYMBOL_GPL(virtqueue_get_queue_index);
+
 /**
  * virtqueue_add_buf - expose buffer to other end
  * @vq: the struct virtqueue we're talking about.
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index 8efd28a..0d8ed46 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -50,6 +50,10 @@ void *virtqueue_detach_unused_buf(struct virtqueue *vq);
 
 unsigned int virtqueue_get_vring_size(struct virtqueue *vq);
 
+void virtqueue_set_queue_index(struct virtqueue *vq, int queue_index);
+
+int virtqueue_get_queue_index(struct virtqueue *vq);
+
 /**
  * virtio_device - representation of a device using virtio
  * @index: unique position on the virtio bus
-- 
1.7.1
