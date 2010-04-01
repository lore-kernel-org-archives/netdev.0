From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] Add Mergeable RX buffer feature to vhost_net
Date: Thu, 1 Apr 2010 13:54:15 +0300
Message-ID: <20100401105415.GA3323@redhat.com>
References: <20100331120228.GH31085@redhat.com>
	<OF5F520CEF.01718090-ON882576F7.006C8152-882576F7.0079481F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm-owner@vger.kernel.org, kvm@vger.kernel.org,
        virtualization@lists.osdl.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <OF5F520CEF.01718090-ON882576F7.006C8152-882576F7.0079481F@us.ibm.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 31, 2010 at 03:04:43PM -0700, David Stevens wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 03/31/2010 05:02:28 AM:
> > 
> > attached patch seems to be whiespace damaged as well.
> > Does the origin pass checkpatch.pl for you?
> 
>         Yes, but I probably broke it in the transfer -- will be more
> careful with the next revision.
> 
> 
> 
> > > +               head.iov_base = (void *)vhost_get_vq_desc(&net->dev, 
> vq,
> > > +                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, NULL, 
> 
> > > NULL);
> > 
> > I this casting confusing.
> > Is it really expensive to add an array of heads so that
> > we do not need to cast?
> 
>         It needs the heads and the lengths, which looks a lot
> like an iovec. I was trying to resist adding a new
> struct XXX { unsigned head; unsigned len; } just for this,
> but I could make these parallel arrays, one with head index and
> the other with length.
> 
> > > +               if (vq->rxmaxheadcount < headcount)
> > > +                       vq->rxmaxheadcount = headcount;
> > 
> > This seems the only place where we set the rxmaxheadcount
> > value. Maybe it can be moved out of vhost.c to net.c?
> > If vhost library needs this it can get it as function
> > parameter.
> 
>         I can move it to vhost_get_heads(), sure.
> > 
> > > +               /* Skip header. TODO: support TSO. */
> > 
> > You seem to have removed the code that skips the header.
> > Won't this break non-GSO backends such as raw?
> 
>         From our prior discussion, what I had in mind was that
> we'd remove all special-header processing by using the ioctl
> you added for TUN and later, an equivalent ioctl for raw (when
> supported in qemu-kvm). Qemu would arrange headers with tap
> (and later raw) to get what the guest expects, and vhost then
> just passes all data as-is between the socket and the ring.
>         That not only removes the different-header-len code
> for mergeable buffers, but also eliminates making a copy of the
> header for every packet as before.

Yes but please note that in practice if this is what we do,
then vhost header size is 0 and then there is no actual copy.

> Vhost has no need to do
> anything with the header, or even know its length. It also
> doesn't have to care what the type of the backend is-- raw or
> tap.
>         I think that simplifies everything, but it does mean that
> raw socket support requires a header ioctl for the different
> vnethdr sizes if the guest wants a vnethdr with and without
> mergeable buffers. Actually, I thought this was your idea and
> the point of the TUNSETVNETHDRSZ ioctl, but I guess you had
> something else in mind?

Yes. However, we also have an ioctl that sets vhost header size, and it
allows supporting simple backends which do not support an (equivalent
of) TUNSETVNETHDRSZ. We have two of these now: packet and macvtap.
So I thought that unless there are gains in code simplicity and/or
performance we can keep supporting these just as well.

> > > -               /* TODO: Check specific error and bomb out unless 
> EAGAIN? 
> > > */
> > 
> > Do you think it's not a good idea?
> 
>         EAGAIN is not possible after the change, because we don't
> even enter the loop unless we have an skb on the read queue; the
> other cases bomb out, so I figured the comment for future work is
> now done. :-)

Guest could be buggy so we'll get EFAULT.
If skb is taken off the rx queue (as below), we might get EAGAIN.

> > 
> > >                 if (err < 0) {
> > > -                       vhost_discard_vq_desc(vq);
> > > +                       vhost_discard_vq_desc(vq, headcount);
> > >                         break;
> > >                 }
> > 
> > I think we should detect and discard truncated messages,
> > since len might not be reliable if userspace pulls
> > a packet from under us. Also, if new packet is
> > shorter than the old one, there's no truncation but
> > headcount is wrong.
> > 
> > So simplest fix IMO would be to compare err with expected len.
> > If there's a difference, we hit the race and so
> > we would discard the packet.
> 
> Sure.
> 
> > 
> > 
> > >                 /* TODO: Should check and handle checksum. */
> > > +               if (vhost_has_feature(&net->dev, 
> VIRTIO_NET_F_MRG_RXBUF)) 
> > > {
> > > +                       struct virtio_net_hdr_mrg_rxbuf *vhdr =
> > > +                               (struct virtio_net_hdr_mrg_rxbuf *)
> > > +                               vq->iov[0].iov_base;
> > > +                       /* add num_bufs */
> > > +                       if (put_user(headcount, &vhdr->num_buffers)) {
> > > +                               vq_err(vq, "Failed to write 
> num_buffers");
> > > +                               vhost_discard_vq_desc(vq, headcount);
> > 
> > Let's do memcpy_to_iovecend etc so that we do not assume layout.
> > This is also why we need move_iovec: sendmsg might modify the iovec.
> > It would also be nice not to corrupt memory and
> > get a reasonable error if buffer size
> > that we get is smaller than expected header size.
> 
>         I wanted to avoid the header copy here, with the reasonable 
> restriction
> that the guest gives you a buffer at least big enough for the vnet_hdr.
> A
> length check alone (on iov[0].iov_len) could enforce that without copying
> headers back and forth to support silly cases like 8-byte buffers or
> num_buffers spanning multiple iovecs, and I think paying the price of the
> copy on every packet to support guests that broken isn't worth it.

In practice, when the first iovec includes the header what
we will copy is iov[0].iov_len + iov[0].iov_base.

We also still have the problem that sendmsg might modify the iovec,
(for tap it doesn't) so using iov_len after sendmsg isn't legal,
you need to copy it anyway.

>         So, my preference here would be to add:
> 
>         if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF))
>                 struct virtio_net_mrg_rxbuf *vhdr...
> 
>                 if (vq->iov[0].iov_len < sizeof(*vhdr)) {
>                         vq_err(vq, "tiny buffers (len %d < %d) are not 
> supported",
>                                 vq->iov[0].iov_len, sizeof(*vhdr));
>                         break;
>                 }
>                 /* add num_bufs */
>                 ...
> 
> Does that work for you?

Seems more code, doesn't it? Do you really believe this is a performance gain?
It looks a bit like prepature optimization ...

> > > -               if (err) {
> > > -                       vq_err(vq, "Unable to write vnet_hdr at addr 
> %p: 
> > > %d\n",
> > > -                              vq->iov->iov_base, err);
> > > -                       break;
> > > -               }
> > > -               len += hdr_size;
> > 
> > This seems to break non-GSO backends as well.
> 
> I don't have any to test with w/ current qemu-kvm,

I can dig up the demo, but there's also the macvtap backend. Try using that.

> but again, I thought
> your plan was to remove special header processing from vhost and let
> the socket end do it via ioctl. Wouldn't a similar ioctl for raw
> sockets when supported by qemu do that?

I just don't want to require that backends support GSO/vnet header,
so vhost needs an ability to skip the header.

> > >         }
> > >         n->dev.acked_features = features;
> > >         smp_wmb();
> > > -       for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
> > > -               mutex_lock(&n->vqs[i].mutex);
> > > -               n->vqs[i].hdr_size = hdr_size;
> > > -               mutex_unlock(&n->vqs[i].mutex);
> > 
> > I expect the above is a leftover from the previous version
> > which calculated header size in kernel?
> 
>         Right. With the ioctl, and assuming raw gets a similar
> one, we don't need to know anything about the header size in
> vhost, except that qemu needs to make sure mergeable rxbufs is
> only set when the socket has the larger vnet_hdr that includes
> the num_bufs field.
> 

Note that vhost doesn't really *know* about header, per se,
it just skips the first X bytes in iovec.

> > > @@ -410,6 +410,7 @@ static long vhost_set_vring(struct vhost
> > >                 vq->last_avail_idx = s.num;
> > >                 /* Forget the cached index value. */
> > >                 vq->avail_idx = vq->last_avail_idx;
> > > +               vq->rxmaxheadcount = 0;
> > >                 break;
> > >         case VHOST_GET_VRING_BASE:
> > >                 s.index = idx;
> > > @@ -856,6 +857,48 @@ static unsigned get_indirect(struct vhos
> > >         return 0;
> > >  }
> > > 
> > > +/* This is a multi-head version of vhost_get_vq_desc
> > 
> > How about:
> > version of vhost_get_vq_desc that returns multiple
> > descriptors
> 
> OK.
> 
> > 
> > > + * @vq         - the relevant virtqueue
> > > + * datalen     - data length we'll be reading
> > > + * @iovcount   - returned count of io vectors we fill
> > > + * @log                - vhost log
> > > + * @log_num    - log offset
> > 
> > return value?
> > Also - why unsigned?
> 
>         Returned value is the number of heads, which is
> 0 or greater.

The advantage of using int is that you'll be able to return
an error code. Good for debugging.

> > 
> > > + */
> > > +unsigned vhost_get_heads(struct vhost_virtqueue *vq, int datalen, int 
> 
> > 
> > Would vhost_get_vq_desc_multiple be a better name?
> 
>         26 chars for the function name with indentation and
> argument list might not be pretty on the calls. What about
> changing vhost_get_desc() and vhost_get_desc_n() [make them
> both shorter]? ("_n" indicating >= 1 instead of just one).

OK.

> > > +       struct vhost_log *log, unsigned int *log_num)
> > > +{
> > > +       struct iovec *heads = vq->heads;
> > 
> > I think it's better to pass in heads array than take it from vq->heads.
> 
>         I'd actually prefer to go the other way, and remove the
> log stuff, for example, since they are accessible from vq which
> we have already.

The main reason is that long term, we might want to
detach the arrays from vq - they are there simply to
avoid sticking too much data on stack - and the
fixed size becomes limiting for vhost block.
The advantage of passing them would be that
vhost won't have to change.

> Adding heads make it look less similar to the
> arg list for vhost_get_vq_desc(), but I'm more interested in
> getting the feature than particular arg lists, so your call.

Well, vhost_get_desc_n is just like vhost_get_desc but returns
multiple heads. In C you can return a single int by value
but many ints must be returned in an array, so I don't
think it is that dissimilar.

> > 
> > > +       int out, in = 0;
> > 
> > Why is in initialized here?
> 
> Needed in the previous version, but not here.
> 
> > 
> > > +       int seg = 0;            /* iov index */
> > > +       int hc = 0;             /* head count */
> > > +
> > > +       while (datalen > 0) {
> > 
> > Can't this simply call vhost_get_vq_desc in a loop somehow,
> > or use a common function that both this and vhost_get_vq_desc call?
> 
> It is calling vhost_get_vq_desc() in this loop; that's how it
> gets the indiviual heads and iov entries. The rest of it is just
> massaging the offsets so vhost_get_vq_desc puts them all in the
> right places and tracks the heads and lengths correctly for add_used.

Sorry, will have to re-read.

> > 
> > > +               if (hc >= VHOST_NET_MAX_SG) {
> > > +                       vhost_discard_vq_desc(vq, hc);
> > > +                       return 0;
> > > +               }
> > > +               heads[hc].iov_base = (void 
> *)vhost_get_vq_desc(vq->dev, 
> > > vq,
> > > +                       vq->iov+seg, ARRAY_SIZE(vq->iov)-seg, &out, 
> &in, 
> > > log,
> > > +                       log_num);
> > > +               if (heads[hc].iov_base == (void *)vq->num) {
> > > +                       vhost_discard_vq_desc(vq, hc);
> > > +                       return 0;
> > > +               }
> > > +               if (out || in <= 0) {
> > > +                       vq_err(vq, "unexpected descriptor format for 
> RX: "
> > > +                               "out %d, in %d\n", out, in);
> > > +                       vhost_discard_vq_desc(vq, hc);
> > 
> > goto err above might help simplify cleanup.
> 
> I generally would rather see the error cleanup explicitly where the
> error detection and message are, for code readability, but I can change
> it to a goto here if you think that's clearer.

This is the idiom I use all over this code.

> > > -int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int 
> 
> > > len)
> > > +int vhost_add_used(struct vhost_virtqueue *vq, struct iovec *heads, 
> int 
> > > count)
> > 
> > count is always 0 for send, right?
> > I think it is better to have two APIs here as well:
> > vhost_add_used
> > vhost_add_used_multiple
> > we can use functions to avoid code duplication.
> > 
> > >  {
> > > -       struct vring_used_elem *used;
> > > +       struct vring_used_elem *used = 0;
> > 
> > why is used initialized here?
> 
>         This is to remove a compiler warning that "used" may
> be used unitialized, for a case that can't happen (count <= 0).
> 

I think there's some macro in kernel to shut the compiler up.
Or just ignore the warning. Let's not add extra initializers
just to shut up compiler, I think this might hide real bugs.

> > > +               vq->last_used_idx++;
> > 
> > I think we should update last_used_idx on success only,
> > at the end. Simply use last_used_idx + count
> > instead of last_used_idx + 1.
> 
>         OK.
> 
> > > @@ -1023,22 +1071,35 @@ int vhost_add_used(struct vhost_virtqueu
> > >                 if (vq->log_ctx)
> > >                         eventfd_signal(vq->log_ctx, 1);
> > >         }
> > > -       vq->last_used_idx++;
> > >         return 0;
> > >  }
> > > 
> > > +int vhost_available(struct vhost_virtqueue *vq)
> > 
> > since this function is non-static, please document what it does.
> 
>         OK.
> 
> > > +{
> > > +       int avail;
> > > +
> > > +       if (!vq->rxmaxheadcount)        /* haven't got any yet */
> > > +               return 1;
> > 
> > since seems to make net - specific asumptions.
> > How about moving this check out to net.c?
> 
>         I can, but its only user is vhost_signal() in this file.

So why isn't it static?

> > > +       avail = vq->avail_idx - vq->last_avail_idx;
> > > +       if (avail < 0)
> > > +               avail += 0x10000; /* wrapped */
> > 
> > A branch that is likely non-taken. Also, rxmaxheadcount
> > is really unlikely to get as large as half the ring.
> > So this just wastes cycles?
> 
>         The indexes are free-running counters, so if
> avail_idx has overflowed but last_avail_idx has not
> then the result will be (incorrectly) negative. It
> has nothing to do with how many buffers are in use--
> consider avail_idx = 2 and last_avail_idx = 65534,
> then avail = will be -65532, but we want it to be 4.

Right. Sorry about the noise.

> > 
> > > +       return avail;
> > > +}
> > > +
> > >  /* This actually signals the guest, using eventfd. */
> > > -void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
> > > +void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq, 
> bool 
> > > recvr)
> > 
> > This one is not elegant. receive is net.c concept, let's not
> > put it in vhost.c. Pass in headcount if you must.
> 
>         Mainly what I was after here is to not affect signal's
> for the transmit side. I thought about splitting it into a
> separate function entirely for the transmit, but came up with
> this, instead. I can't tell if it's a receiver from the vq,
> but I don't want to override NOTIFY_ON_EMPTY or the headcount
> check (which has nothing to do with transmitters) for the
> transmitter at all.
>         The vq doesn't tell you if it is a receiver or not,
> so I either need a flag as argument to tell, or I need to
> split into a transmit vhost_signal and a receive vhost_signal.

You see, receive is really a net concept. virtio has in and out,
and a single descriptor can do both.

>         I can do the available check before calling vhost_signal,
> but then I need to remove the NOTIFY check entirely so it'll
> still notify for the receiver case when available is not
> enough but still not 0.

My question is, guests can not rely on the 'available is not
enough but still not 0' to work because it relies on a heuristic
to figure out how much is 'not enough'. So why do we need it at all.

>         So, I think the options are:
> 1) a flag
> 2) separate transmit or receive signal functions
> 3) move NOTIFY_ON_EMPTY out of vhost_signal and
>         check that or available (for recvr) before
>         calling vhost_signal().

There are ordering rules that make 3 impossible.
Let's try to rethink the concept of redefining NOTIFY_ON_EMPTY.
Is it really necessary?

> > 
> > >  {
> > >         __u16 flags = 0;
> > > +
> > >         if (get_user(flags, &vq->avail->flags)) {
> > >                 vq_err(vq, "Failed to get flags");
> > >                 return;
> > >         }
> > > 
> > > -       /* If they don't want an interrupt, don't signal, unless 
> empty. */
> > > +       /* If they don't want an interrupt, don't signal, unless
> > > +        * empty or receiver can't get a max-sized packet. */
> > >         if ((flags & VRING_AVAIL_F_NO_INTERRUPT) &&
> > > -           (vq->avail_idx != vq->last_avail_idx ||
> > > +           (!recvr || vhost_available(vq) >= vq->rxmaxheadcount ||
> > 
> > Is the above really worth the complexity?
> > Guests can't rely on this kind of fuzzy logic, can they?
> > Do you see this helping performance at all?
> 
>         It definitely hurts performance to allocate max-sized buffers
> and then free up the excess (the translate_desc is expensive).

Well, we do not need to rerun translate_desc, we can keep
the results around, however ...

> It is
> a heuristic, but it's one that keeps the notifies flowing without
> having to fail on a packet to reenable them.

I don't understand completely. We looked into the skb, so
we know the required length?

>         The notify code has to change because there is no recovery
> if we need 5 buffers and have only 3, while notification is
> disabled unless we go all the way to 0. We can't honor NOTIFY_ON_EMPTY
> in that case because it will never proceed. We can remove the
> NOTIFY_ON_EMPTY check in vhost_signal and do it in the caller; then allow
> receiver to fail a buffer allocation and signal unconditionally,
> but we cannot wait for it to be 0 even if NOTIFY_ON_EMPTY is set--
> that's a deadlock.
> 

Which guest kernel or spec are you looking at? As far as I know
F_NOTIFY_ON_EMPTY was only used for TX at some point.
I am not aware of this bit having the meaning you assign it.
I suspect that what you outline above simply means guest
can not combine F_NOTIFY_ON_EMPTY with mergeable buffers for
virtio net RX VQ.

> > >  /* OK, now we need to know about added descriptors. */
> > > -bool vhost_enable_notify(struct vhost_virtqueue *vq)
> > > +bool vhost_enable_notify(struct vhost_virtqueue *vq, bool recvr)
> > >  {
> > >         u16 avail_idx;
> > >         int r;
> > > @@ -1080,6 +1141,8 @@ bool vhost_enable_notify(struct vhost_vi
> > >                 return false;
> > >         }
> > > 
> > > +       if (recvr && vq->rxmaxheadcount)
> > > +               return (avail_idx - vq->last_avail_idx) >= 
> > > vq->rxmaxheadcount;
> > 
> > The fuzzy logic behind rxmaxheadcount might be a good
> > optimization, but I am not comfortable using it
> > for correctness. Maybe vhost_enable_notify should get
> > the last head so we can redo poll when another one
> > is added.
> 
>         I tried requiring at least 64K here always, but as
> I said before, the cost of doing the translate_desc and
> then throwing those away for small packets killed performance.
> I also considered using a highwater mark on the ring, but
> potentially differing buffer sizes makes that less useful,
> and a small ring may only have enough space for 1 max-sized
> packet. 
>         Maybe we should just remove NOTIFY_ON_EMPTY if we
> fail a packet allocation; I can try that out.
>         Another alternative I considered was splitting out
> the translate_desc stuff in the hopes that we could found
> out how many buffers we need in a less-expensive way; then
> we could go for max-sized and free the excess without too
> much overhead, maybe.
>         Anyway, I'll look harder at working around this.

I am kind of confused. We did a peek and have the skb length,
why do we need the maxheads?

Hmm, the iovec consumed is not just skb length, it is skb length + vnet
header. Is this it? Maybe we can just export this from socket somehow?

> > >         struct iovec indirect[VHOST_NET_MAX_SG];
> > > -       struct iovec iov[VHOST_NET_MAX_SG];
> > > -       struct iovec hdr[VHOST_NET_MAX_SG];
> > > -       size_t hdr_size;
> > > +       struct iovec iov[VHOST_NET_MAX_SG+1]; /* an extra for vnet hdr 
> */
> > 
> > VHOST_NET_MAX_SG should already include iovec vnet hdr.
> 
>         That's actually an artifact from the previous patch. I
> was arranging the iovec to have just the header needed by the
> guest and this simplified the bounds checking. It can be
> removed if we leave header size management to the socket side,
> but if vhost is going to be doing vnet_hdr manipulation for
> raw sockets, then it'll depend on what that new code needs
> to do to manage the header, I suppose.
> 
>                                                 +-DLS

Note it doesn't manipluate the header, just skips it.

-- 
MST
