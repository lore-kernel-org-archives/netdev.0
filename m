From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [kvm-devel] [PATCH resent] virtio_net: Fix stalled inbound trafficon early packets
Date: Wed, 12 Dec 2007 12:39:51 +0100
Message-ID: <200712121239.51435.borntraeger@de.ibm.com>
References: <200712111242.28843.borntraeger@de.ibm.com> <200712111416.12655.borntraeger@de.ibm.com> <200712121254.13865.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dor.laor@qumranet.com, kvm-devel <kvm-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:11368 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758207AbXLLLjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 06:39:55 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBCBdsRG156580
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 11:39:54 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBCBdsuL3010584
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 12:39:54 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBCBdrmx011909
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 12:39:54 +0100
In-Reply-To: <200712121254.13865.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 12. Dezember 2007 schrieb Rusty Russell:
> On Wednesday 12 December 2007 00:16:12 Christian Borntraeger wrote:
> > That would also work. We already have VRING_AVAIL_F_NO_INTERRUPT in
> > virtio_ring.c - maybe we can use that. Its hidden in callback and
> > restart handling, what about adding an explicit startup?
> 
> Yes, I debated whether to make this a separate hook or not; the current
> method  reduces the number of function calls without having two ways of
> disabling  callbacks.
> 
> In this case, simply starting devices with callbacks disabled and 
> renaming 'restart' to 'enable' (or something) and calling it at the
> beginning is probably sufficient?

So you suggest something like the following patch? It seems to work but 
there is still a theoretical race at startup. Therefore, I tend to agree 
with Dor that a separate hook seems prefereable, so I am not fully sure if 
the patch is the final solution:

ps: Its ok to answer that after your vacation. 

---
 drivers/block/virtio_blk.c   |    3 ++-
 drivers/net/virtio_net.c     |    5 ++++-
 drivers/virtio/virtio_ring.c |    9 ++++-----
 include/linux/virtio.h       |    4 ++--
 4 files changed, 12 insertions(+), 9 deletions(-)

Index: kvm/drivers/virtio/virtio_ring.c
===================================================================
--- kvm.orig/drivers/virtio/virtio_ring.c
+++ kvm/drivers/virtio/virtio_ring.c
@@ -220,7 +220,7 @@ static void *vring_get_buf(struct virtqu
 	return ret;
 }
 
-static bool vring_restart(struct virtqueue *_vq)
+static bool vring_enable(struct virtqueue *_vq)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
 
@@ -264,7 +264,7 @@ static struct virtqueue_ops vring_vq_ops
 	.add_buf = vring_add_buf,
 	.get_buf = vring_get_buf,
 	.kick = vring_kick,
-	.restart = vring_restart,
+	.enable = vring_enable,
 	.shutdown = vring_shutdown,
 };
 
@@ -299,9 +299,8 @@ struct virtqueue *vring_new_virtqueue(un
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
@@ -41,7 +41,7 @@ struct virtqueue
  *	vq: the struct virtqueue we're talking about.
  *	len: the length written into the buffer
  *	Returns NULL or the "data" token handed to add_buf.
- * @restart: restart callbacks after callback returned false.
+ * @enable: restart callbacks after callback returned false.
  *	vq: the struct virtqueue we're talking about.
  *	This returns "false" (and doesn't re-enable) if there are pending
  *	buffers in the queue, to avoid a race.
@@ -65,7 +65,7 @@ struct virtqueue_ops {
 
 	void *(*get_buf)(struct virtqueue *vq, unsigned int *len);
 
-	bool (*restart)(struct virtqueue *vq);
+	bool (*enable)(struct virtqueue *vq);
 
 	void (*shutdown)(struct virtqueue *vq);
 };
Index: kvm/drivers/net/virtio_net.c
===================================================================
--- kvm.orig/drivers/net/virtio_net.c
+++ kvm/drivers/net/virtio_net.c
@@ -201,7 +201,7 @@ again:
 	/* Out of packets? */
 	if (received < budget) {
 		netif_rx_complete(vi->dev, napi);
-		if (unlikely(!vi->rvq->vq_ops->restart(vi->rvq))
+		if (unlikely(!vi->rvq->vq_ops->enable(vi->rvq))
 		    && netif_rx_reschedule(vi->dev, napi))
 			goto again;
 	}
@@ -292,6 +292,9 @@ static int virtnet_open(struct net_devic
 		return -ENOMEM;
 
 	napi_enable(&vi->napi);
+
+	vi->rvq->vq_ops->enable(vi->rvq);
+	vi->svq->vq_ops->enable(vi->svq);
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
+	vblk->vq->vq_ops->enable(vblk->vq);
 	vblk->pool = mempool_create_kmalloc_pool(1,sizeof(struct virtblk_req));
 	if (!vblk->pool) {
 		err = -ENOMEM;

