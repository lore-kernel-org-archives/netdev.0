From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: clean up outstanding buffers before setting vring
Date: Wed, 20 Jul 2011 13:41:31 +0300
Message-ID: <20110720104131.GB5164@redhat.com>
References: <1311098546.8573.13.camel@localhost.localdomain>
 <20110719194956.GC8667@redhat.com>
 <1311108653.8573.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jasowang@redhat.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751376Ab1GTKlM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 06:41:12 -0400
Content-Disposition: inline
In-Reply-To: <1311108653.8573.25.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2011 at 01:50:53PM -0700, Shirley Ma wrote:
> On Tue, 2011-07-19 at 22:49 +0300, Michael S. Tsirkin wrote:
> > On Tue, Jul 19, 2011 at 11:02:26AM -0700, Shirley Ma wrote:
> > > The outstanding DMA buffers need to be clean up before setting vring
> > in
> > > vhost. Otherwise the vring would be out of sync.
> > > 
> > > Signed-off-by: Shirley Ma<xma@us.ibm.com>
> > 
> > I suspect what is missing is calling
> > vhost_zerocopy_signal_used then?
> > 
> > If yes we probably should do it after
> > changing the backend, not on vring set.
> 
> I think vhost_zerocopy_signal_used might not be sufficient.

If not, I'd like to understand what the root cause of
the problem is.

> But we can
> test it out by remove/reloading the guest virtio_net module.

Well, try out something like the below patch then.

> 
> The problem encounters when guest rmmod virtio_net module, then reload
> the module, and configure the interface, it complains about some ring id
> is not a head.

OK, good, such a problem decription belongs in the patch commit log.

> With this patch, the problem is solved. 

Additional info you want to put in the commit log is what in the code
triggers the problem and how your patch fixes it.

> > 
> > > +
> > > +     /* Signal guest as appropriate. */
> > > +     vhost_zerocopy_signal_used(vq);
> > >  
> > >       switch (ioctl) {
> > >       case VHOST_SET_VRING_NUM:
> > > @@ -1592,7 +1600,6 @@ void vhost_ubuf_put_and_wait(struct
> > vhost_ubuf_ref *ubufs)
> > >  {
> > >       kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
> > >       wait_event(ubufs->wait, !atomic_read(&ubufs->kref.refcount));
> > > -     kfree(ubufs);
> > 
> > Won't this leak memory when ubufs are switched in
> > vhost_net_set_backend? 
> 
> Right, I forgot to check net.c, whenever it calls
> vhot_ubuf_put_and_wait, it should call kfree(ubufs).
> 

-->

vhost-net: update used ring on backend change

On backend change, we flushed out outstanding skbs
but forgot to update the used ring. Do that to
avoid losing heads.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

--

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 70ac604..248b250 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -711,8 +711,12 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 
 	mutex_unlock(&vq->mutex);
 
-	if (oldubufs)
+	if (oldubufs) {
 		vhost_ubuf_put_and_wait(oldubufs);
+		mutex_lock(&vq->mutex);
+		vhost_zerocopy_signal_used(vq);
+		mutex_unlock(&vq->mutex);
+	}
 
 	if (oldsock) {
 		vhost_net_flush_vq(n, index);

-- 
MST
