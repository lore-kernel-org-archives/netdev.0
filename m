From: Jason Wang <jasowang@redhat.com>
Subject: [RFC PATCH net-next 1/6] virtio: make sure used event never go
	backwards
Date: Wed, 15 Oct 2014 15:25:25 +0800
Message-ID: <1413357930-45302-2-git-send-email-jasowang@redhat.com>
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

This patch checks the new event idx to make sure used event idx never
goes back. This is used to synchronize the calls between
virtqueue_enable_cb_delayed() and virtqueue_enable_cb().

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/virtio/virtio_ring.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 3b1f89b..1b3929f 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -559,14 +559,17 @@ unsigned virtqueue_enable_cb_prepare(struct virtqueue *_vq)
 	u16 last_used_idx;
 
 	START_USE(vq);
-
+	last_used_idx = vq->last_used_idx;
 	/* We optimistically turn back on interrupts, then check if there was
 	 * more to do. */
 	/* Depending on the VIRTIO_RING_F_EVENT_IDX feature, we need to
 	 * either clear the flags bit or point the event index at the next
 	 * entry. Always do both to keep code simple. */
 	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
-	vring_used_event(&vq->vring) = last_used_idx = vq->last_used_idx;
+	/* Make sure used event never go backwards */
+	if (!vring_need_event(vring_used_event(&vq->vring),
+			      vq->vring.avail->idx, last_used_idx))
+		vring_used_event(&vq->vring) = last_used_idx;
 	END_USE(vq);
 	return last_used_idx;
 }
-- 
1.7.1
