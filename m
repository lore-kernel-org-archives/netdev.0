From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [kvm-devel] [PATCH resent] virtio_net: Fix stalled inbound trafficon early packets
Date: Tue, 11 Dec 2007 16:27:21 +0100
Message-ID: <200712111627.21364.borntraeger@de.ibm.com>
References: <200712111242.28843.borntraeger@de.ibm.com> <475E892D.9060400@qumranet.com> <200712111419.52880.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	kvm-devel <kvm-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: dor.laor@qumranet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:62553 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbXLKP1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 10:27:25 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBBFRNL7362264
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 15:27:23 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBBFRN5l2269320
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 16:27:23 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBBFRMK3020563
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 16:27:23 +0100
In-Reply-To: <200712111419.52880.borntraeger@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 11. Dezember 2007 schrieb Christian Borntraeger:
> > The way other physical NICs doing it is by dis/en/abling interrupt 
> > using registers (look at e1000).
> > I suggest we can export add_status and use the original code but
> > before enabling napi add a call to add_status(dev, 
> > VIRTIO_CONFIG_DEV_OPEN).
> > The host won't trigger an irq until it sees the above.
> 
> That would also work. We already have VRING_AVAIL_F_NO_INTERRUPT in
> virtio_ring.c - maybe we can use that. Its hidden in callback and
> restart handling, what about adding an explicit startup?

Ok, just to give an example what I thought about:
---
 drivers/block/virtio_blk.c   |    3 ++-
 drivers/net/virtio_net.c     |    2 ++
 drivers/virtio/virtio_ring.c |   16 +++++++++++++---
 include/linux/virtio.h       |    5 +++++
 4 files changed, 22 insertions(+), 4 deletions(-)

Index: kvm/drivers/virtio/virtio_ring.c
===================================================================
--- kvm.orig/drivers/virtio/virtio_ring.c
+++ kvm/drivers/virtio/virtio_ring.c
@@ -241,6 +241,16 @@ static bool vring_restart(struct virtque
 	return true;
 }
 
+static void vring_startup(struct virtqueue *_vq)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+	START_USE(vq);
+	if (vq->vq.callback)
+		vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
+	END_USE(vq);
+}
+
+
 irqreturn_t vring_interrupt(int irq, void *_vq)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
@@ -265,6 +275,7 @@ static struct virtqueue_ops vring_vq_ops
 	.get_buf = vring_get_buf,
 	.kick = vring_kick,
 	.restart = vring_restart,
+	.startup = vring_startup,
 	.shutdown = vring_shutdown,
 };
 
@@ -299,9 +310,8 @@ struct virtqueue *vring_new_virtqueue(un
 	vq->in_use = false;
 #endif
 
-	/* No callback?  Tell other side not to bother us. */
-	if (!callback)
-		vq->vring.avail->flags |= VRING_AVAIL_F_NO_INTERRUPT;
+	/* disable interrupts until we enable them */
+	vq->vring.avail->flags |= VRING_AVAIL_F_NO_INTERRUPT;
 
 	/* Put everything in free lists. */
 	vq->num_free = num;
Index: kvm/include/linux/virtio.h
===================================================================
--- kvm.orig/include/linux/virtio.h
+++ kvm/include/linux/virtio.h
@@ -45,6 +45,9 @@ struct virtqueue
  *	vq: the struct virtqueue we're talking about.
  *	This returns "false" (and doesn't re-enable) if there are pending
  *	buffers in the queue, to avoid a race.
+ * @startup: enable callbacks
+ *	vq: the struct virtqueue we're talking abount
+ *	Returns 0 or an error
  * @shutdown: "unadd" all buffers.
  *	vq: the struct virtqueue we're talking about.
  *	Remove everything from the queue.
@@ -67,6 +70,8 @@ struct virtqueue_ops {
 
 	bool (*restart)(struct virtqueue *vq);
 
+	void (*startup) (struct virtqueue *vq);
+
 	void (*shutdown)(struct virtqueue *vq);
 };
 
Index: kvm/drivers/net/virtio_net.c
===================================================================
--- kvm.orig/drivers/net/virtio_net.c
+++ kvm/drivers/net/virtio_net.c
@@ -292,6 +292,8 @@ static int virtnet_open(struct net_devic
 		return -ENOMEM;
 
 	napi_enable(&vi->napi);
+
+	vi->rvq->vq_ops->startup(vi->rvq);
 	return 0;
 }
 
Index: kvm/drivers/block/virtio_blk.c
===================================================================
--- kvm.orig/drivers/block/virtio_blk.c
+++ kvm/drivers/block/virtio_blk.c
@@ -183,7 +183,8 @@ static int virtblk_probe(struct virtio_d
 		err = PTR_ERR(vblk->vq);
 		goto out_free_vblk;
 	}
-
+	/* enable interrupts */
+	vblk->vq->vq_ops->startup(vblk->vq);
 	vblk->pool = mempool_create_kmalloc_pool(1,sizeof(struct virtblk_req));
 	if (!vblk->pool) {
 		err = -ENOMEM;



There is still one small problem: what if the host fills up all 
host-to-guest buffers before we call startup? So I start to think that your 
solution is better, given that the host is not only not sending interrupts 
but also not filling any buffers as long as VIRTIO_CONFIG_DEV_OPEN is not 
set. I will have a look but I think that add_status needs to be called 
after napi_enable, otherwise we have the same race.

Christian
