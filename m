From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCHv2 06/14] virtio: add api for delayed callbacks
Date: Fri, 20 May 2011 02:11:14 +0300
Message-ID: <8f343dcaa996f6b10499468c49508ba9d6fb6f5a.1305846412.git.mst@redhat.com>
References: <cover.1305846412.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1305846412.git.mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Add an API that tells the other side that callbacks
should be delayed until a lot of work has been done.
Implement using the new event_idx feature.

Note: it might seem advantageous to let the drivers
ask for a callback after a specific capacity has
been reached. However, as a single head can
free many entries in the descriptor table,
we don't really have a clue about capacity
until get_buf is called. The API is the simplest
to implement at the moment, we'll see what kind of
hints drivers can pass when there's more than one
user of the feature.

Signed-off-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/virtio/virtio_ring.c |   27 +++++++++++++++++++++++++++
 include/linux/virtio.h       |    9 +++++++++
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 1d0f9be..6578e1a 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -376,6 +376,33 @@ bool virtqueue_enable_cb(struct virtqueue *_vq)
 }
 EXPORT_SYMBOL_GPL(virtqueue_enable_cb);
 
+bool virtqueue_enable_cb_delayed(struct virtqueue *_vq)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+	u16 bufs;
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
+	bufs = (u16)(vq->vring.avail->idx - vq->last_used_idx) * 3 / 4;
+	vring_used_event(&vq->vring) = vq->last_used_idx + bufs;
+	virtio_mb();
+	if (unlikely((u16)(vq->vring.used->idx - vq->last_used_idx) > bufs)) {
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
index aff5b4f..7108857 100644
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
