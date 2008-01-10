From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: virtio_net and SMP guests
Date: Thu, 10 Jan 2008 16:51:58 +0100
Message-ID: <200801101651.58908.borntraeger@de.ibm.com>
References: <200712141312.05562.borntraeger@de.ibm.com> <200801101337.40433.borntraeger@de.ibm.com> <200801101639.15995.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel <kvm-devel@lists.sourceforge.net>,
	Anthony Liguori <aliguori@us.ibm.com>,
	Dor Laor <dor.laor@qumranet.com>, netdev@vger.kernel.org
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:7845 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596AbYAJPwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 10:52:36 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0AFqZGo232508
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:52:35 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0AFqZdY5103840
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:52:35 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0AFqIDH011958
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:52:19 GMT
In-Reply-To: <200801101639.15995.borntraeger@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 10. Januar 2008 schrieb Christian Borntraeger:
> Am Donnerstag, 10. Januar 2008 schrieb Christian Borntraeger:
> > Am Dienstag, 18. Dezember 2007 schrieb Rusty Russell:
> > > To me this points to doing interrupt suppression a different way.  If 
we
> > > have a ->disable_cb() virtio function, and call it before we call
> > > netif_rx_schedule, does that fix it?
> > 
> > The fix looks good and I agree with it.
> > 
> > There is one problem that I try to find for some days, but the following 
> > BUG_ON triggers:
> > 
> > static void vring_disable_cb(struct virtqueue *_vq)
> > {
> >         struct vring_virtqueue *vq = to_vvq(_vq);
> > 
> >         START_USE(vq);
> > ---->   BUG_ON(vq->vring.avail->flags & VRING_AVAIL_F_NO_INTERRUPT);
> >         vq->vring.avail->flags |= VRING_AVAIL_F_NO_INTERRUPT;
> >         END_USE(vq);
> > }
> 
> Ok, I found it:
> 
> static int virtnet_open(struct net_device *dev)
> {
>         struct virtnet_info *vi = netdev_priv(dev);
>         try_fill_recv(vi);
>         /* If we didn't even get one input buffer, we're useless. */
>         if (vi->num == 0)
>                 return -ENOMEM;
> 					---> int for new packet
> 					static void skb_recv_done(struct virtqueue *rvq)
> 					{
>         					struct virtnet_info *vi = rvq->vdev->priv;
> 					        /* Suppress further interrupts. */
> 					        rvq->vq_ops->disable_cb(rvq);
> 					        netif_rx_schedule(vi->dev, &vi->napi);
> 					}
> 					- poll is not yet possible, no softirq
> 					- return from interrupt
>         napi_enable(&vi->napi);
> 	vi->rvq->vq_ops->disable_cb(vi->rvq);
> 					---> BUG: its already disabled

Btw. this problem also happens on single processor guests.

What about the following patch:

---
 drivers/net/virtio_net.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: kvm/drivers/net/virtio_net.c
===================================================================
--- kvm.orig/drivers/net/virtio_net.c
+++ kvm/drivers/net/virtio_net.c
@@ -179,9 +179,12 @@ static void try_fill_recv(struct virtnet
 static void skb_recv_done(struct virtqueue *rvq)
 {
 	struct virtnet_info *vi = rvq->vdev->priv;
-	/* Suppress further interrupts. */
-	rvq->vq_ops->disable_cb(rvq);
-	netif_rx_schedule(vi->dev, &vi->napi);
+	/* Schedule NAPI, Suppress further interrupts if successful. */
+
+	if (netif_rx_schedule_prep(vi->dev, &vi->napi)) {
+		rvq->vq_ops->disable_cb(rvq);
+		__netif_rx_schedule(vi->dev, &vi->napi);
+	}
 }
 
 static int virtnet_poll(struct napi_struct *napi, int budget)
