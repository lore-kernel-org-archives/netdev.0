From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 14/18] virtio: add api for delayed callbacks
Date: Wed, 4 May 2011 23:52:33 +0300
Message-ID: <64d47c628b3fdc0ac156aed4be182933d8bcc0db.1304541919.git.mst@redhat.com>
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

Add an API that tells the other side that callbacks
should be delayed until a lot of work has been done.
Implement using the new used_event feature.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/virtio/virtio_ring.c |   27 +++++++++++++++++++++++++++
 include/linux/virtio.h       |    9 +++++++++
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 262dfe6..3a70d70 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -397,6 +397,33 @@ bool virtqueue_enable_cb(struct virtqueue *_vq)
 }
 EXPORT_SYMBOL_GPL(virtqueue_enable_cb);
 
+bool virtqueue_enable_cb_delayed(struct virtqueue *_vq)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+	int bufs;
+
+	START_USE(vq);
+
+	/* We optimistically turn back on interrupts, then check if there was
+	 * more to do. */
+	/* Depending on the VIRTIO_RING_F_USED_EVENT_IDX feature, we need to
+	 * either clear the flags bit or point the event index at the next
+	 * entry. Always do both to keep code simple. */
+	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
+	/* TODO: tune this threshold */
+	bufs = (vq->vring.avail->idx - vq->last_used_idx) * 3 / 4;
+	vring_used_event(&vq->vring) = vq->last_used_idx + bufs;
+	virtio_mb();
+	if (unlikely(vq->vring.used->idx - vq->last_used_idx > bufs)) {
+		END_USE(vq);
+		return false;
+	}
+
+	END_USE(vq);
+	return true;
+}
+EXPORT_SYMBOL_GPL(virtqueue_enable_cb_delayed);
+
 void *virtqueue_detach_unused_buf(struct virtqueue *_vq)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index 718336b..5151fd1 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -51,6 +51,13 @@ struct virtqueue {
  *	This re-enables callbacks; it returns "false" if there are pending
  *	buffers in the queue, to detect a possible race between the driver
  *	checking for more work, and enabling callbacks.
+ * virtqueue_enable_cb_delayed: restart callbacks after disable_cb.
+ *	vq: the struct virtqueue we're talking about.
+ *	This re-enables callbacks but hints to the other side to delay
+ *	interrupts until most of the available buffers have been processed;
+ *	it returns "false" if there are many pending buffers in the queue,
+ *	to detect a possible race between the driver checking for more work,
+ *	and enabling callbacks.
  * virtqueue_detach_unused_buf: detach first unused buffer
  * 	vq: the struct virtqueue we're talking about.
  * 	Returns NULL or the "data" token handed to add_buf
@@ -86,6 +93,8 @@ void virtqueue_disable_cb(struct virtqueue *vq);
 
 bool virtqueue_enable_cb(struct virtqueue *vq);
 
+bool virtqueue_enable_cb_delayed(struct virtqueue *vq);
+
 void *virtqueue_detach_unused_buf(struct virtqueue *vq);
 
 /**
-- 
1.7.5.53.gc233e
