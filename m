From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/2] virtio: put last seen used index into ring itself
Date: Thu, 17 Mar 2011 14:20:37 +0200
Message-ID: <20110317122035.GA15902@redhat.com>
References: <cover.1300134326.git.mst@redhat.com>
 <a38d4f036fc471c4ea2a5c61e355813576a4ee3a.1300134326.git.mst@redhat.com>
 <1300148495.11514.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com, jasowang@redhat.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1300148495.11514.1.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following is needed on top: still compiled only, post
here in case Tom is willing to test this meanwhile.

-->

virtio: fix vring_last_used
 
Reported-by: Shirley Ma <mashirle@us.ibm.com>   
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index a6fc537..a84b056 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -280,7 +280,7 @@ static void detach_buf(struct vring_virtqueue *vq, unsigned int head)
 
 static inline bool more_used(const struct vring_virtqueue *vq)
 {
-	return vring_last_used(vq) != vq->vring.used->idx;
+	return vring_last_used(&vq->vring) != vq->vring.used->idx;
 }
 
 void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
@@ -306,7 +306,7 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 	/* Only get used array entries after they have been exposed by host. */
 	virtio_rmb();
 
-	u = &vq->vring.used->ring[vring_last_used(vq) % vq->vring.num];
+	u = &vq->vring.used->ring[vring_last_used(&vq->vring) % vq->vring.num];
 	i = u->id;
 	*len = u->len;
 	if (unlikely(i >= vq->vring.num)) {
@@ -321,7 +321,7 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 	/* detach_buf clears data, so grab it now. */
 	ret = vq->data[i];
 	detach_buf(vq, i);
-	(vring_last_used(vq))++;
+	(vring_last_used(&vq->vring))++;
 	/* If we expect an interrupt for the next entry, flush out
 	 * last used index write. */
 	if (!(vq->vring.avail->flags & VRING_AVAIL_F_NO_INTERRUPT))
@@ -434,7 +434,7 @@ struct virtqueue *vring_new_virtqueue(unsigned int num,
 	vq->vq.name = name;
 	vq->notify = notify;
 	vq->broken = false;
-	vring_last_used(vq) = 0;
+	vring_last_used(&vq->vring) = 0;
 	vq->num_added = 0;
 	list_add_tail(&vq->vq.list, &vdev->vqs);
 #ifdef DEBUG
diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
index 4587ea2..462756d 100644
--- a/include/linux/virtio_ring.h
+++ b/include/linux/virtio_ring.h
@@ -100,7 +100,7 @@ struct vring {
 
 /* We publish the last-seen used index at the end of the available ring.
  * It is at the end for backwards compatibility. */
-#define vring_last_used(vr) ((vr)->avail->ring[num])
+#define vring_last_used(vr) ((vr)->avail->ring[(vr)->num])
 static inline void vring_init(struct vring *vr, unsigned int num, void *p,
 			      unsigned long align)
 {
