From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH][VHOST] fix race with guest on multi-buffer used buffer
	updates
Date: Mon, 24 May 2010 19:13:51 +0300
Message-ID: <20100524161351.GA6580@redhat.com>
References: <20100524101709.GA28349@redhat.com> <OF343AB88F.017B31FE-ON8825772D.00564524-8825772D.00573773@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF343AB88F.017B31FE-ON8825772D.00564524-8825772D.00573773@us.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 24, 2010 at 08:52:40AM -0700, David Stevens wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 05/24/2010 03:17:10 AM:
> 
> > On Thu, May 20, 2010 at 09:58:06AM -0700, David L Stevens wrote:
> > > [for Michael Tsirkin's vhost development git tree]
> > > 
> > > This patch fixes a race between guest and host when
> > > adding used buffers wraps the ring. Without it, guests
> > > can see partial packets before num_buffers is set in
> > > the vnet header.
> > > 
> > > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> > 
> > Could you please explain what the race is?
> 
>         Sure. The pre-patch code in the ring-wrap case
> does this:
> 
>         add part1 bufs
>         update used index
>         add part2 bufs
>         update used index
> 
>         After we update the used index for part1, the part1
> buffers are available to the guest. If the guest is
> consuming at that point, it can process the partial
> packet before the rest of the packet is there. In that
> case, num_buffers will be greater than the number of
> buffers available to the guest and it'll drop the
> packet with a framing error. I was seeing 2 or 3 framing
> errors every 100 million packets or so pre-patch, none
> post-patch.
>         Actually, the second sentence is incorrect in the
> original description-- num_buffers is up to date when
> the guest sees it, but the used index is not.
> 
>                                                 +-DLS

so this happens always - what does wrap-around refer to?

> 
> > 
> > > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > > index 7f2568d..74790ab 100644
> > > --- a/drivers/vhost/vhost.c
> > > +++ b/drivers/vhost/vhost.c
> > > @@ -1065,14 +1065,6 @@ static int __vhost_add_used_n(struct 
> vhost_virtqueue *vq,
> > >        vq_err(vq, "Failed to write used");
> > >        return -EFAULT;
> > >     }
> > > -   /* Make sure buffer is written before we update index. */
> > > -   smp_wmb();
> > > -   if (put_user(vq->last_used_idx + count, &vq->used->idx)) {
> > > -      vq_err(vq, "Failed to increment used idx");
> > > -      return -EFAULT;
> > > -   }
> > > -   if (unlikely(vq->log_used))
> > > -      vhost_log_used(vq, used);
> > >     vq->last_used_idx += count;
> > >     return 0;
> > >  }
> > > @@ -1093,7 +1085,17 @@ int vhost_add_used_n(struct vhost_virtqueue 
> *vq, 
> > struct vring_used_elem *heads,
> > >        heads += n;
> > >        count -= n;
> > >     }
> > > -   return __vhost_add_used_n(vq, heads, count);
> > > +   r = __vhost_add_used_n(vq, heads, count);
> > > +
> > > +   /* Make sure buffer is written before we update index. */
> > > +   smp_wmb();
> > > +   if (put_user(vq->last_used_idx, &vq->used->idx)) {
> > > +      vq_err(vq, "Failed to increment used idx");
> > > +      return -EFAULT;
> > > +   }
> > > +   if (unlikely(vq->log_used))
> > > +      vhost_log_used(vq, vq->used->ring + start);
> > > +   return r;
> > >  }


I think a single vhost_log_used will not DTRT here:
it only updates log for a single entry.
So we'll need to split this to functions that
1. log used entries writes: called from __vhost_add_used_n
2. log used index write: called from vhost_add_used_n

> > > 
> > >  /* This actually signals the guest, using eventfd. */
> > > 
