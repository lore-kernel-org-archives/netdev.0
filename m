From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH] vhost: clean up outstanding buffers before setting
 vring
Date: Tue, 19 Jul 2011 13:50:53 -0700
Message-ID: <1311108653.8573.25.camel@localhost.localdomain>
References: <1311098546.8573.13.camel@localhost.localdomain>
	 <20110719194956.GC8667@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:33819 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668Ab1GSUu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 16:50:58 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6JKIiDM020621
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 16:18:45 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6JKovY4178050
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 16:50:57 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6JGoi9f015120
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 13:50:45 -0300
In-Reply-To: <20110719194956.GC8667@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-19 at 22:49 +0300, Michael S. Tsirkin wrote:
> On Tue, Jul 19, 2011 at 11:02:26AM -0700, Shirley Ma wrote:
> > The outstanding DMA buffers need to be clean up before setting vring
> in
> > vhost. Otherwise the vring would be out of sync.
> > 
> > Signed-off-by: Shirley Ma<xma@us.ibm.com>
> 
> I suspect what is missing is calling
> vhost_zerocopy_signal_used then?
> 
> If yes we probably should do it after
> changing the backend, not on vring set.

I think vhost_zerocopy_signal_used might not be sufficient. But we can
test it out by remove/reloading the guest virtio_net module.

> > ---
> > 
> >  drivers/vhost/vhost.c |   11 +++++++++--
> >  1 files changed, 9 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > index c14c42b..d6315b4 100644
> > --- a/drivers/vhost/vhost.c
> > +++ b/drivers/vhost/vhost.c
> > @@ -445,8 +445,10 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
> >                       vhost_poll_flush(&dev->vqs[i].poll);
> >               }
> >               /* Wait for all lower device DMAs done. */
> > -             if (dev->vqs[i].ubufs)
> > +             if (dev->vqs[i].ubufs) {
> >                       vhost_ubuf_put_and_wait(dev->vqs[i].ubufs);
> > +                     kfree(dev->vqs[i].ubufs);
> > +             }
> >  
> >               /* Signal guest as appropriate. */
> >               vhost_zerocopy_signal_used(&dev->vqs[i]);
> > @@ -651,6 +653,12 @@ static long vhost_set_vring(struct vhost_dev
> *d, int ioctl, void __user *argp)
> >       vq = d->vqs + idx;
> >  
> >       mutex_lock(&vq->mutex);
> > +     /* Wait for all lower device DMAs done. */
> > +     if (vq->ubufs)
> > +             vhost_ubuf_put_and_wait(vq->ubufs);
> 
> Could you elaborate on the problem you observe please?
> At least in theory, existing code flushes outstanding
> requests when backend is changed.
> And since vring set verifies no backend is active,
> we should be fine?

The problem encounters when guest rmmod virtio_net module, then reload
the module, and configure the interface, it complains about some ring id
is not a head. With this patch, the problem is solved. 

> 
> > +
> > +     /* Signal guest as appropriate. */
> > +     vhost_zerocopy_signal_used(vq);
> >  
> >       switch (ioctl) {
> >       case VHOST_SET_VRING_NUM:
> > @@ -1592,7 +1600,6 @@ void vhost_ubuf_put_and_wait(struct
> vhost_ubuf_ref *ubufs)
> >  {
> >       kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
> >       wait_event(ubufs->wait, !atomic_read(&ubufs->kref.refcount));
> > -     kfree(ubufs);
> 
> Won't this leak memory when ubufs are switched in
> vhost_net_set_backend? 

Right, I forgot to check net.c, whenever it calls
vhot_ubuf_put_and_wait, it should call kfree(ubufs).



