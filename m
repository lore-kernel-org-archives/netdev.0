From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][ PATCH 3/3] vhost-net: Add mergeable RX buffer support
	to vhost-net
Date: Mon, 8 Mar 2010 10:07:33 +0200
Message-ID: <20100308080733.GC7482@redhat.com>
References: <20100307162633.GC24997@redhat.com> <OF8D4A9381.FF5A483F-ON882576E0.0008221D-882576E0.000B9D4A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF8D4A9381.FF5A483F-ON882576E0.0008221D-882576E0.000B9D4A@us.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 07, 2010 at 06:06:51PM -0800, David Stevens wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 03/07/2010 08:26:33 AM:
> 
> > On Tue, Mar 02, 2010 at 05:20:34PM -0700, David Stevens wrote:
> > > This patch glues them all together and makes sure we
> > > notify whenever we don't have enough buffers to receive
> > > a max-sized packet, and adds the feature bit.
> > > 
> > > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> > 
> > Maybe split this up?
> 
>         I can. I was looking mostly at size (and this is the smallest
> of the bunch). But the feature requires all of them together, of course.
> This last one is just "everything left over" from the other two.
> 
> > > @@ -110,6 +90,7 @@
> > >         size_t len, total_len = 0;
> > >         int err, wmem;
> > >         struct socket *sock = rcu_dereference(vq->private_data);
> > > +
> > 
> > I tend not to add empty lines if line below it is already short.
> 
>         This leaves no blank line between the declarations and the start
> of code. It's habit for me-- not sure of kernel coding standards address
> that or not, but I don't think I've seen it anywhere else.
> 
> > 
> > >         if (!sock)
> > >                 return;
> > > 
> > > @@ -166,11 +147,11 @@
> > >                 /* Skip header. TODO: support TSO. */
> > >                 msg.msg_iovlen = out;
> > >                 head.iov_len = len = iov_length(vq->iov, out);
> > > +
> > 
> > I tend not to add empty lines if line below it is a comment.
> 
>         I added this to separate the logical "skip header" block from
> the next, unrelated piece. Not important to me, though.
> 
> > 
> > >                 /* Sanity check */
> > >                 if (!len) {
> > >                         vq_err(vq, "Unexpected header len for TX: "
> > > -                              "%zd expected %zd\n",
> > > -                              len, vq->guest_hlen);
> > > +                              "%zd expected %zd\n", len, 
> vq->guest_hlen);
> > >                         break;
> > >                 }
> > >                 /* TODO: Check specific error and bomb out unless 
> ENOBUFS? 
> > > */
> 
> 
> > >                 /* TODO: Should check and handle checksum. */
> > > +               if (vhost_has_feature(&net->dev, 
> VIRTIO_NET_F_MRG_RXBUF)) 
> > > {
> > > +                       struct virtio_net_hdr_mrg_rxbuf *vhdr =
> > > +                               (struct virtio_net_hdr_mrg_rxbuf *)
> > > +                               vq->iov[0].iov_base;
> > > +                       /* add num_bufs */
> > > +                       vq->iov[0].iov_len = vq->guest_hlen;
> > > +                       vhdr->num_buffers = headcount;
> > 
> > I don't understand this. iov_base is a userspace pointer, isn't it.
> > How can you assign values to it like that?
> > Rusty also commented earlier that it's not a good idea to assume
> > specific layout, such as first chunk being large enough to
> > include virtio_net_hdr_mrg_rxbuf.
> > 
> > I think we need to use memcpy to/from iovec etc.
> 
>         I guess you mean put_user() or copy_to_user(); yes, I suppose
> it could be paged since we read it.
>         The code doesn't assume that it'll fit so much as arranged for
> it to fit. We allocate guest_hlen bytes in the buffer, but set the
> iovec to the (smaller) sock_hlen; do the read, then this code adds
> back the 2 bytes in the middle that we didn't read into (where
> num_buffers goes). But the allocator does require that guest_hlen
> will fit in a single buffer (and reports error if it doesn't). The
> alternative is significantly more complicated,

I'm not sure why. Can't we just call memcpy_from_iovec
and then read the structure as usual?

> and only fails if
> the guest doesn't give us at least the buffer size the guest header
> requires (a truly lame guest). I'm not sure it's worth a lot of
> complexity in vhost to support the guest giving us <12 byte buffers;
> those guests don't exist now and maybe they never should?
> 
> 
> > >  /* This actually signals the guest, using eventfd. */
> > >  void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
> > >  {
> > >         __u16 flags = 0;
> > > +
> > 
> > I tend not to add empty lines if a line above it is already short.
> 
>         Again, separating declarations from code-- never seen different
> in any other kernel code.
> 
> > 
> > >         if (get_user(flags, &vq->avail->flags)) {
> > >                 vq_err(vq, "Failed to get flags");
> > >                 return;
> > > @@ -1125,7 +1140,7 @@
> > > 
> > >         /* If they don't want an interrupt, don't signal, unless 
> empty. */
> > >         if ((flags & VRING_AVAIL_F_NO_INTERRUPT) &&
> > > -           (vq->avail_idx != vq->last_avail_idx ||
> > > +           (vhost_available(vq) > vq->maxheadcount ||
> > 
> > I don't understand this change. It seems to make
> > code not match the comments.
> 
>         It redefines "empty". Without mergeable buffers, we can empty
> the ring down to nothing before we require notification. With
> mergeable buffers, if the packet requires, say, 3 buffers, and we
> have only 2 left, we are empty and require notification and new
> buffers to read anything. In both cases, we notify when we can't
> read another packet without more buffers.

I don't really see how you can find this out from just the number of
heads. A head can address buffer of any size. Need to think
about this code some more.

>         I can think about changing the comment to reflect this more
> clearly.

Also, this is all for rx only, so names should reflect this I think.

> > 
> > >              !vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY)))
> > >                 return;
> > > 
> > > diff -ruN net-next-p2/drivers/vhost/vhost.h 
> > > net-next-p3/drivers/vhost/vhost.h
> > > --- net-next-p2/drivers/vhost/vhost.h   2010-03-02 13:02:03.000000000 
> > > -0800
> > > +++ net-next-p3/drivers/vhost/vhost.h   2010-03-02 14:29:44.000000000 
> > > -0800
> > > @@ -85,6 +85,7 @@
> > >         struct iovec iov[VHOST_NET_MAX_SG+1]; /* an extra for vnet hdr 
> */
> > >         struct iovec heads[VHOST_NET_MAX_SG];
> > >         size_t guest_hlen, sock_hlen;
> > > +       int maxheadcount;
> > 
> > I don't completely understand what does this field does.
> > It seems to be only set on rx? Maybe name should reflect this?
> 
>         This is a way for me to dynamically guess how many heads I need 
> for a
> max-sized packet for whatever the MTU/GRO settings are without waiting to
> detect the need for more buffers until a read fails. Without mergeable 
> buffers,
> we can always fit a max-sized packet in 1 head, but with, we need more 
> than
> one head to do the read.
> 
> I didn't want to hard-code 64K (which it usually is, but not always), and
> I didn't want to wait until a read fails every time the ring is near full.
> I played with re-enabling notify on 1/4 available or some such, but that 
> delays
> reads unnecessarily, so I came up with this method: use maxheadcount to 
> track
> the biggest packet we've ever seen and always make sure we have at least 
> that
> many available for the next read. If it increases, we may fail the read, 
> which'll
> notify, but this allows us to notify before we try and fail in normal 
> operation,
> while still not doing a notify on every read.
> 
>                                                                 +-DLS


Hmm, yes. One of the horrors of the mergeable buffer hack.

Not sure all this is worth the complexity though: I don't think this
covers all cases whether the size would be < 64K, anyway: you don't get
notified when user disables GRO on physical NIC, for example.  So maybe
just go ahead with hard-coding 64K.

In any case, number of heads does not necessarily tell us much either,
does it?

Would interrupt when we actually don't have room on RX work better? I'll
think about it some more.

-- 
MST

