From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][VHOST] fix race with guest on multi-buffer used buffer	updates
Date: Mon, 24 May 2010 08:52:40 -0700
Message-ID: <OF343AB88F.017B31FE-ON8825772D.00564524-8825772D.00573773@us.ibm.com>
References: <20100524101709.GA28349@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:32863 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537Ab0EXPw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 11:52:57 -0400
In-Reply-To: <20100524101709.GA28349@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/24/2010 03:17:10 AM:

> On Thu, May 20, 2010 at 09:58:06AM -0700, David L Stevens wrote:
> > [for Michael Tsirkin's vhost development git tree]
> > 
> > This patch fixes a race between guest and host when
> > adding used buffers wraps the ring. Without it, guests
> > can see partial packets before num_buffers is set in
> > the vnet header.
> > 
> > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> 
> Could you please explain what the race is?

        Sure. The pre-patch code in the ring-wrap case
does this:

        add part1 bufs
        update used index
        add part2 bufs
        update used index

        After we update the used index for part1, the part1
buffers are available to the guest. If the guest is
consuming at that point, it can process the partial
packet before the rest of the packet is there. In that
case, num_buffers will be greater than the number of
buffers available to the guest and it'll drop the
packet with a framing error. I was seeing 2 or 3 framing
errors every 100 million packets or so pre-patch, none
post-patch.
        Actually, the second sentence is incorrect in the
original description-- num_buffers is up to date when
the guest sees it, but the used index is not.

                                                +-DLS


> 
> > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > index 7f2568d..74790ab 100644
> > --- a/drivers/vhost/vhost.c
> > +++ b/drivers/vhost/vhost.c
> > @@ -1065,14 +1065,6 @@ static int __vhost_add_used_n(struct 
vhost_virtqueue *vq,
> >        vq_err(vq, "Failed to write used");
> >        return -EFAULT;
> >     }
> > -   /* Make sure buffer is written before we update index. */
> > -   smp_wmb();
> > -   if (put_user(vq->last_used_idx + count, &vq->used->idx)) {
> > -      vq_err(vq, "Failed to increment used idx");
> > -      return -EFAULT;
> > -   }
> > -   if (unlikely(vq->log_used))
> > -      vhost_log_used(vq, used);
> >     vq->last_used_idx += count;
> >     return 0;
> >  }
> > @@ -1093,7 +1085,17 @@ int vhost_add_used_n(struct vhost_virtqueue 
*vq, 
> struct vring_used_elem *heads,
> >        heads += n;
> >        count -= n;
> >     }
> > -   return __vhost_add_used_n(vq, heads, count);
> > +   r = __vhost_add_used_n(vq, heads, count);
> > +
> > +   /* Make sure buffer is written before we update index. */
> > +   smp_wmb();
> > +   if (put_user(vq->last_used_idx, &vq->used->idx)) {
> > +      vq_err(vq, "Failed to increment used idx");
> > +      return -EFAULT;
> > +   }
> > +   if (unlikely(vq->log_used))
> > +      vhost_log_used(vq, vq->used->ring + start);
> > +   return r;
> >  }
> > 
> >  /* This actually signals the guest, using eventfd. */
> > 

