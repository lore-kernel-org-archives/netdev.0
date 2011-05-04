From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 08/18] virtio_ring: support for used_event idx feature
Date: Wed, 4 May 2011 23:51:38 +0300
Message-ID: <dd16b9f3bad847b0eadc7f94368e27982c1a7560.1304541919.git.mst@redhat.com>
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

Add support for the used_event idx feature: when enabling
interrupts, publish the current avail index value to
the host so that we get interrupts on the next update.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/virtio/virtio_ring.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 507d6eb..3a3ed75 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -320,6 +320,14 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 	ret = vq->data[i];
 	detach_buf(vq, i);
 	vq->last_used_idx++;
+	/* If we expect an interrupt for the next entry, tell host
+	 * by writing event index and flush out the write before
+	 * the read in the next get_buf call. */
+	if (!(vq->vring.avail->flags & VRING_AVAIL_F_NO_INTERRUPT)) {
+		vring_used_event(&vq->vring) = vq->last_used_idx;
+		virtio_mb();
+	}
+
 	END_USE(vq);
 	return ret;
 }
@@ -341,7 +349,11 @@ bool virtqueue_enable_cb(struct virtqueue *_vq)
 
 	/* We optimistically turn back on interrupts, then check if there was
 	 * more to do. */
+	/* Depending on the VIRTIO_RING_F_USED_EVENT_IDX feature, we need to
+	 * either clear the flags bit or point the event index at the next
+	 * entry. Always do both to keep code simple. */
 	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
+	vring_used_event(&vq->vring) = vq->last_used_idx;
 	virtio_mb();
 	if (unlikely(more_used(vq))) {
 		END_USE(vq);
@@ -468,6 +480,8 @@ void vring_transport_features(struct virtio_device *vdev)
 			break;
 		case VIRTIO_RING_F_INDIRECT_DESC:
 			break;
+		case VIRTIO_RING_F_USED_EVENT_IDX:
+			break;
 		default:
 			/* We don't understand this bit. */
 			clear_bit(i, vdev->features);
-- 
1.7.5.53.gc233e
