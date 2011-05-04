From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 09/18] virtio: use avail_event index
Date: Wed, 4 May 2011 23:51:47 +0300
Message-ID: <8bba6a0a8eee17e741c5155b04ff1b1c9f34bf94.1304541919.git.mst@redhat.com>
References: <cover.1304541918.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, Carsten Otte <cotte@de.ibm.com>,
        lguest@lists.ozlabs.org, Shirley Ma <xma@us.ibm.com>,
        kvm@vger.kernel.org, linux-s390@vger.kernel.org,
        netdev@vger.kernel.org, habanero@linux.vnet.ibm.com,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, steved@us.ibm.com,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Tom Lendacky <tahm@linux.vnet.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1304541918.git.mst@redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Use the new avail_event feature to reduce the number
of exits from the guest.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/virtio/virtio_ring.c |   39 ++++++++++++++++++++++++++++++++++++++-
 1 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 3a3ed75..262dfe6 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -82,6 +82,15 @@ struct vring_virtqueue
 	/* Host supports indirect buffers */
 	bool indirect;
 
+	/* Host publishes avail event idx */
+	bool event;
+
+	/* Is kicked_avail below valid? */
+	bool kicked_avail_valid;
+
+	/* avail idx value we already kicked. */
+	u16 kicked_avail;
+
 	/* Number of free buffers */
 	unsigned int num_free;
 	/* Head of free buffer list. */
@@ -228,6 +237,12 @@ add_head:
 	 * new available array entries. */
 	virtio_wmb();
 	vq->vring.avail->idx++;
+	/* If the driver never bothers to kick in a very long while,
+	 * avail index might wrap around. If that happens, invalidate
+	 * kicked_avail index we stored. TODO: make sure all drivers
+	 * kick at least once in 2^16 and remove this. */
+	if (unlikely(vq->vring.avail->idx == vq->kicked_avail))
+		vq->kicked_avail_valid = true;
 
 	pr_debug("Added buffer head %i to %p\n", head, vq);
 	END_USE(vq);
@@ -236,6 +251,23 @@ add_head:
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_buf_gfp);
 
+
+static bool vring_notify(struct vring_virtqueue *vq)
+{
+	u16 old, new;
+	bool v;
+	if (!vq->event)
+		return !(vq->vring.used->flags & VRING_USED_F_NO_NOTIFY);
+
+	v = vq->kicked_avail_valid;
+	old = vq->kicked_avail;
+	new = vq->kicked_avail = vq->vring.avail->idx;
+	vq->kicked_avail_valid = true;
+	if (unlikely(!v))
+		return true;
+	return vring_need_event(vring_avail_event(&vq->vring), new, old);
+}
+
 void virtqueue_kick(struct virtqueue *_vq)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
@@ -244,7 +276,7 @@ void virtqueue_kick(struct virtqueue *_vq)
 	/* Need to update avail index before checking if we should notify */
 	virtio_mb();
 
-	if (!(vq->vring.used->flags & VRING_USED_F_NO_NOTIFY))
+	if (vring_notify(vq))
 		/* Prod other side to tell it about changes. */
 		vq->notify(&vq->vq);
 
@@ -437,6 +469,8 @@ struct virtqueue *vring_new_virtqueue(unsigned int num,
 	vq->vq.name = name;
 	vq->notify = notify;
 	vq->broken = false;
+	vq->kicked_avail_valid = false;
+	vq->kicked_avail = 0;
 	vq->last_used_idx = 0;
 	list_add_tail(&vq->vq.list, &vdev->vqs);
 #ifdef DEBUG
@@ -444,6 +478,7 @@ struct virtqueue *vring_new_virtqueue(unsigned int num,
 #endif
 
 	vq->indirect = virtio_has_feature(vdev, VIRTIO_RING_F_INDIRECT_DESC);
+	vq->event = virtio_has_feature(vdev, VIRTIO_RING_F_AVAIL_EVENT_IDX);
 
 	/* No callback?  Tell other side not to bother us. */
 	if (!callback)
@@ -482,6 +517,8 @@ void vring_transport_features(struct virtio_device *vdev)
 			break;
 		case VIRTIO_RING_F_USED_EVENT_IDX:
 			break;
+		case VIRTIO_RING_F_AVAIL_EVENT_IDX:
+			break;
 		default:
 			/* We don't understand this bit. */
 			clear_bit(i, vdev->features);
-- 
1.7.5.53.gc233e
