From: Jason Wang <jasowang@redhat.com>
Subject: [RFC PATCH net-next 2/6] virtio: introduce virtio_enable_cb_avail()
Date: Wed, 15 Oct 2014 15:25:26 +0800
Message-ID: <1413357930-45302-3-git-send-email-jasowang@redhat.com>
References: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
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

This patch introduces virtio_enable_cb_avail() to publish avail idx
and used event. This could be used by batched buffer submitting to
reduce the number of tx interrupts.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/virtio/virtio_ring.c |   22 ++++++++++++++++++++--
 include/linux/virtio.h       |    2 ++
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 1b3929f..d67fbf8 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -567,14 +567,32 @@ unsigned virtqueue_enable_cb_prepare(struct virtqueue *_vq)
 	 * entry. Always do both to keep code simple. */
 	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
 	/* Make sure used event never go backwards */
-	if (!vring_need_event(vring_used_event(&vq->vring),
-			      vq->vring.avail->idx, last_used_idx))
+	if (vq->vring.avail->idx != vring_used_event(&vq->vring) &&
+	    !vring_need_event(vring_used_event(&vq->vring),
+			      vq->vring.avail->idx, last_used_idx)) {
 		vring_used_event(&vq->vring) = last_used_idx;
+	}
 	END_USE(vq);
 	return last_used_idx;
 }
 EXPORT_SYMBOL_GPL(virtqueue_enable_cb_prepare);
 
+bool virtqueue_enable_cb_avail(struct virtqueue *_vq)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+	bool ret;
+
+	START_USE(vq);
+	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
+	vring_used_event(&vq->vring) = vq->vring.avail->idx;
+	ret = vring_need_event(vq->vring.avail->idx,
+			       vq->last_used_idx, vq->vring.used->idx);
+	END_USE(vq);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(virtqueue_enable_cb_avail);
+
 /**
  * virtqueue_poll - query pending used buffers
  * @vq: the struct virtqueue we're talking about.
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index b46671e..bfaf058 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -65,6 +65,8 @@ bool virtqueue_enable_cb(struct virtqueue *vq);
 
 unsigned virtqueue_enable_cb_prepare(struct virtqueue *vq);
 
+bool virtqueue_enable_cb_avail(struct virtqueue *vq);
+
 bool virtqueue_poll(struct virtqueue *vq, unsigned);
 
 bool virtqueue_enable_cb_delayed(struct virtqueue *vq);
-- 
1.7.1
