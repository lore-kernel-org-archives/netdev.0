From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Network performance with small packets
Date: Thu, 10 Mar 2011 12:19:42 +1030
Message-ID: <87fwqv4udl.fsf@rustcorp.com.au>
References: <20110127.130240.104065182.davem@davemloft.net> <OF5CFD7B6A.4CBE4E3B-ON6525782B.0014DC5B-6525782B.001979CB@in.ibm.com> <20110202044222.GC3818@redhat.com> <201102091107.20270.rusty@rustcorp.com.au> <1299621444.25664.77.camel@localhost.localdomain> <1299637278.13202.61.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com,
	Tom Lendacky <tahm@linux.vnet.ibm.com>
To: habanero@linux.vnet.ibm.com, Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56769 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804Ab1CKDiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 22:38:03 -0500
In-Reply-To: <1299637278.13202.61.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Mar 2011 20:21:18 -0600, Andrew Theurer <habanero@linux.vnet.ibm.com> wrote:
> On Tue, 2011-03-08 at 13:57 -0800, Shirley Ma wrote:
> > On Wed, 2011-02-09 at 11:07 +1030, Rusty Russell wrote:
> > > I've finally read this thread... I think we need to get more serious
> > > with our stats gathering to diagnose these kind of performance issues.
> > > 
> > > This is a start; it should tell us what is actually happening to the
> > > virtio ring(s) without significant performance impact... 
> > 
> > Should we also add similar stat on vhost vq as well for monitoring
> > vhost_signal & vhost_notify?
> 
> Tom L has started using Rusty's patches and found some interesting
> results, sent yesterday:
> http://marc.info/?l=kvm&m=129953710930124&w=2

Hmm, I'm not subscribed to kvm@ any more, so I didn't get this, so
replying here:

> Also, it looks like vhost is sending a lot of notifications for
> packets it has received before the guest can get scheduled to disable
> notifications and begin processing the packets resulting in some lock
> contention in the guest (and high interrupt rates).

Yes, this is a virtio design flaw, but one that should be fixable.
We have room at the end of the ring, which we can put a "last_used"
count.  Then we can tell if wakeups are redundant, before the guest
updates the flag.

Here's an old patch where I played with implementing this:

virtio: put last_used and last_avail index into ring itself.

Generally, the other end of the virtio ring doesn't need to see where
you're up to in consuming the ring.  However, to completely understand
what's going on from the outside, this information must be exposed.
For example, if you want to save and restore a virtio_ring, but you're
not the consumer because the kernel is using it directly.

Fortunately, we have room to expand: the ring is always a whole number
of pages and there's hundreds of bytes of padding after the avail ring
and the used ring, whatever the number of descriptors (which must be a
power of 2).

We add a feature bit so the guest can tell the host that it's writing
out the current value there, if it wants to use that.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/virtio/virtio_ring.c |   23 +++++++++++++++--------
 include/linux/virtio_ring.h  |   12 +++++++++++-
 2 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -71,9 +71,6 @@ struct vring_virtqueue
 	/* Number we've added since last sync. */
 	unsigned int num_added;
 
-	/* Last used index we've seen. */
-	u16 last_used_idx;
-
 	/* How to notify other side. FIXME: commonalize hcalls! */
 	void (*notify)(struct virtqueue *vq);
 
@@ -278,12 +275,13 @@ static void detach_buf(struct vring_virt
 
 static inline bool more_used(const struct vring_virtqueue *vq)
 {
-	return vq->last_used_idx != vq->vring.used->idx;
+	return vring_last_used(&vq->vring) != vq->vring.used->idx;
 }
 
 static void *vring_get_buf(struct virtqueue *_vq, unsigned int *len)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
+	struct vring_used_elem *u;
 	void *ret;
 	unsigned int i;
 
@@ -300,8 +298,11 @@ static void *vring_get_buf(struct virtqu
 		return NULL;
 	}
 
-	i = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].id;
-	*len = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].len;
+	u = &vq->vring.used->ring[vring_last_used(&vq->vring) % vq->vring.num];
+	i = u->id;
+	*len = u->len;
+	/* Make sure we don't reload i after doing checks. */
+	rmb();
 
 	if (unlikely(i >= vq->vring.num)) {
 		BAD_RING(vq, "id %u out of range\n", i);
@@ -315,7 +316,8 @@ static void *vring_get_buf(struct virtqu
 	/* detach_buf clears data, so grab it now. */
 	ret = vq->data[i];
 	detach_buf(vq, i);
-	vq->last_used_idx++;
+	vring_last_used(&vq->vring)++;
+
 	END_USE(vq);
 	return ret;
 }
@@ -402,7 +404,6 @@ struct virtqueue *vring_new_virtqueue(un
 	vq->vq.name = name;
 	vq->notify = notify;
 	vq->broken = false;
-	vq->last_used_idx = 0;
 	vq->num_added = 0;
 	list_add_tail(&vq->vq.list, &vdev->vqs);
 #ifdef DEBUG
@@ -413,6 +414,10 @@ struct virtqueue *vring_new_virtqueue(un
 
 	vq->indirect = virtio_has_feature(vdev, VIRTIO_RING_F_INDIRECT_DESC);
 
+	/* We publish indices whether they offer it or not: if not, it's junk
+	 * space anyway.  But calling this acknowledges the feature. */
+	virtio_has_feature(vdev, VIRTIO_RING_F_PUBLISH_INDICES);
+
 	/* No callback?  Tell other side not to bother us. */
 	if (!callback)
 		vq->vring.avail->flags |= VRING_AVAIL_F_NO_INTERRUPT;
@@ -443,6 +448,8 @@ void vring_transport_features(struct vir
 		switch (i) {
 		case VIRTIO_RING_F_INDIRECT_DESC:
 			break;
+		case VIRTIO_RING_F_PUBLISH_INDICES:
+			break;
 		default:
 			/* We don't understand this bit. */
 			clear_bit(i, vdev->features);
diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
--- a/include/linux/virtio_ring.h
+++ b/include/linux/virtio_ring.h
@@ -29,6 +29,9 @@
 /* We support indirect buffer descriptors */
 #define VIRTIO_RING_F_INDIRECT_DESC	28
 
+/* We publish our last-seen used index at the end of the avail ring. */
+#define VIRTIO_RING_F_PUBLISH_INDICES	29
+
 /* Virtio ring descriptors: 16 bytes.  These can chain together via "next". */
 struct vring_desc
 {
@@ -87,6 +90,7 @@ struct vring {
  *	__u16 avail_flags;
  *	__u16 avail_idx;
  *	__u16 available[num];
+ *	__u16 last_used_idx;
  *
  *	// Padding to the next align boundary.
  *	char pad[];
@@ -95,6 +99,7 @@ struct vring {
  *	__u16 used_flags;
  *	__u16 used_idx;
  *	struct vring_used_elem used[num];
+ *	__u16 last_avail_idx;
  * };
  */
 static inline void vring_init(struct vring *vr, unsigned int num, void *p,
@@ -111,9 +116,14 @@ static inline unsigned vring_size(unsign
 {
 	return ((sizeof(struct vring_desc) * num + sizeof(__u16) * (2 + num)
 		 + align - 1) & ~(align - 1))
-		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num;
+		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num + 2;
 }
 
+/* We publish the last-seen used index at the end of the available ring, and
+ * vice-versa.  These are at the end for backwards compatibility. */
+#define vring_last_used(vr) ((vr)->avail->ring[(vr)->num])
+#define vring_last_avail(vr) (*(__u16 *)&(vr)->used->ring[(vr)->num])
+
 #ifdef __KERNEL__
 #include <linux/irqreturn.h>
 struct virtio_device;
