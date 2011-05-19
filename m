From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCHv2 11/14] virtio: don't delay avail index update
Date: Fri, 20 May 2011 02:12:19 +0300
Message-ID: <33d7df119ccbedc9b54fbe4b674076b4f7ba3499.1305846412.git.mst@redhat.com>
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

Update avail index immediately instead of upon kick:
for virtio-net RX this helps parallelism with the host.

Signed-off-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/virtio/virtio_ring.c |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index eed5f29..8218fe6 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -89,7 +89,7 @@ struct vring_virtqueue
 	unsigned int num_free;
 	/* Head of free buffer list. */
 	unsigned int free_head;
-	/* Number we've added since last sync. */
+	/* Number we've added since last kick. */
 	unsigned int num_added;
 
 	/* Last used index we've seen. */
@@ -174,6 +174,13 @@ int virtqueue_add_buf_gfp(struct virtqueue *_vq,
 
 	BUG_ON(data == NULL);
 
+	/* Prevent drivers from adding more than num bufs without a kick. */
+	if (vq->num_added == vq->vring.num) {
+		printk(KERN_ERR "gaaa!!!\n");
+		END_USE(vq);
+		return -ENOSPC;
+	}
+
 	/* If the host supports indirect descriptor tables, and we have multiple
 	 * buffers, then go indirect. FIXME: tune this threshold */
 	if (vq->indirect && (out + in) > 1 && vq->num_free) {
@@ -227,8 +234,14 @@ add_head:
 
 	/* Put entry in available array (but don't update avail->idx until they
 	 * do sync).  FIXME: avoid modulus here? */
-	avail = (vq->vring.avail->idx + vq->num_added++) % vq->vring.num;
+	avail = vq->vring.avail->idx % vq->vring.num;
 	vq->vring.avail->ring[avail] = head;
+	vq->num_added++;
+
+	/* Descriptors and available array need to be set before we expose the
+	 * new available array entries. */
+	virtio_wmb();
+	vq->vring.avail->idx++;
 
 	pr_debug("Added buffer head %i to %p\n", head, vq);
 	END_USE(vq);
@@ -242,17 +255,14 @@ void virtqueue_kick(struct virtqueue *_vq)
 	struct vring_virtqueue *vq = to_vvq(_vq);
 	u16 new, old;
 	START_USE(vq);
-	/* Descriptors and available array need to be set before we expose the
-	 * new available array entries. */
-	virtio_wmb();
-
-	old = vq->vring.avail->idx;
-	new = vq->vring.avail->idx = old + vq->num_added;
-	vq->num_added = 0;
 
 	/* Need to update avail index before checking if we should notify */
 	virtio_mb();
 
+	new = vq->vring.avail->idx;
+	old = new - vq->num_added;
+	vq->num_added = 0;
+
 	if (vq->event ?
 	    vring_need_event(vring_avail_event(&vq->vring), new, old) :
 	    !(vq->vring.used->flags & VRING_USED_F_NO_NOTIFY))
-- 
1.7.5.53.gc233e
