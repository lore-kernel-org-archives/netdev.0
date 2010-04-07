From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH v3] Add Mergeable receive buffer support to vhost_net
Date: Wed, 7 Apr 2010 10:37:17 -0700
Message-ID: <OFC2D0B87C.35124B1B-ON882576FE.005ADDB2-882576FE.0060CB7B@us.ibm.com>
References: <20100407105910.GD9550@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, kvm-owner@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100407105910.GD9550@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Thanks!
> There's some whitespace damage, are you sending with your new
> sendmail setup? It seems to have worked for qemu patches ...

        Yes, I saw some line wraps in what I received, but I checked
the original draft to be sure and they weren't there. Possibly from
the relay; Sigh.


> > @@ -167,8 +166,15 @@ static void handle_tx(struct vhost_net *
> >        /* TODO: Check specific error and bomb out unless ENOBUFS? */
> >        err = sock->ops->sendmsg(NULL, sock, &msg, len);
> >        if (unlikely(err < 0)) {
> > -         vhost_discard_vq_desc(vq);
> > -         tx_poll_start(net, sock);
> > +         if (err == -EAGAIN) {
> > +            vhost_discard_desc(vq, 1);
> > +            tx_poll_start(net, sock);
> > +         } else {
> > +            vq_err(vq, "sendmsg: errno %d\n", -err);
> > +            /* drop packet; do not discard/resend */
> > +            vhost_add_used_and_signal(&net->dev, vq, head,
> > +                       0);
> 
> vhost does not currently has a consistent error handling strategy:
> if we drop packets, need to think which other errors should cause
> packet drops.  I prefer to just call vq_err for now,
> and have us look at handling segfaults etc in a consistent way
> separately.

I had to add this to avoid an infinite loop when I wrote a bad
packet on the socket. I agree error handling needs a better look,
but retrying a bad packet continuously while dumping in the log
is what it was doing when I hit an error before this code. Isn't
this better, at least until a second look?


> > +}
> > +
> 
> I wonder whether it makes sense to check
> skb_queue_empty(&sk->sk_receive_queue)
> outside the lock, to reduce the cost of this call
> on an empty queue (we know that it happens at least once
> each time we exit the loop on rx)?

        I was looking at alternatives to adding the lock in the
first place, but I found I couldn't measure a difference in the
cost with and without the lock.


> > +   int retries = 0;
> >     size_t len, total_len = 0;
> > -   int err;
> > +   int err, headcount, datalen;
> >     size_t hdr_size;
> >     struct socket *sock = rcu_dereference(vq->private_data);
> >     if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
> > @@ -222,31 +242,25 @@ static void handle_rx(struct vhost_net *
> >     vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
> >        vq->log : NULL;
> > 
> > -   for (;;) {
> > -      head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> > -                ARRAY_SIZE(vq->iov),
> > -                &out, &in,
> > -                vq_log, &log);
> > +   while ((datalen = vhost_head_len(sock->sk))) {
> > +      headcount = vhost_get_desc_n(vq, vq->heads, datalen, &in,
> > +                    vq_log, &log);
> 
> This looks like a bug, I think we need to pass
> datalen + header size to vhost_get_desc_n.
> Not sure how we know the header size that backend will use though.
> Maybe just look at our features.

        Yes; we have hdr_size, so I can add it here. It'll be 0 for
the cases where the backend and guest both have vnet header (either
the regular or larger mergeable buffers one), but should be added
in for future raw socket support.

> 
> >        /* OK, now we need to know about added descriptors. */
> > -      if (head == vq->num) {
> > -         if (unlikely(vhost_enable_notify(vq))) {
> > +      if (!headcount) {
> > +         if (retries == 0 && unlikely(vhost_enable_notify(vq))) {
> >              /* They have slipped one in as we were
> >               * doing that: check again. */
> >              vhost_disable_notify(vq);
> > +            retries++;
> >              continue;
> >           }
> 
> Hmm. The reason we have the code at all, as the comment says, is because
> guest could have added more buffers between the time we read last index
> and the time we enabled notification. So if we just break like this
> the race still exists. We could remember the
> last head value we observed, and have vhost_enable_notify check
> against this value?

        This is to prevent a spin loop in the case where we have some
buffers available, but not enough for the current packet (ie, this
is the replacement code for the "rxmaxheadcount" business). If they
actually added something new, retrying once should see it, but what
vhost_enable_notify() returns non-zero on is not "new buffers" but
rather "not empty". In the case mentioned, we aren't empty, so
vhost_enable_notify() returns nonzero every time, but the guest hasn't
given us enough buffers to proceed, so we continuously retry; this
code breaks the spin loop until we've really got new buffers from
the guest.

> 
> Need to think about it.
> 
> Another concern here is that on retries vhost_get_desc_n
> is doing extra work, rescanning the same descriptor
> again and again. Not sure how common this is, might be
> worthwhile to add a TODO to consider this at least.

        I had a printk in there to test the code and with the
retries counter, it happens when we fill the ring (once,
because of the retries checks), and then proceeds as
desired when the guest gives us more buffers. Without the
check, it spews until we hear from the guest.

> > @@ -261,14 +275,33 @@ static void handle_rx(struct vhost_net *
> >                  len, MSG_DONTWAIT | MSG_TRUNC);
> >        /* TODO: Check specific error and bomb out unless EAGAIN? */
> >        if (err < 0) {
> 
> I think we need to compare err and datalen and drop packet on mismatch 
as well.
> The check err > len won't be needed then.

        OK, but this is the original code, unchanged by my patch. :-)
> 
> > -         vhost_discard_vq_desc(vq);
> > +         vhost_discard_desc(vq, headcount);
> >           break;
> >        }
> >        /* TODO: Should check and handle checksum. */
> > +      if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF)) {
> > +         struct virtio_net_hdr_mrg_rxbuf *vhdr =
> > +            (struct virtio_net_hdr_mrg_rxbuf *)
> > +            vq->iov[0].iov_base;
> > +         /* add num_buffers */
> > +         if (vhost_has_feature(&net->dev,
> > +                     VHOST_NET_F_VIRTIO_NET_HDR))
> > +            hdr.num_buffers = headcount;
> 
> Why is the above necessary?

        This adds mergeable buffer support for the raw case.
> 
> > +         else if (vq->iov[0].iov_len < sizeof(*vhdr)) {
> 
> I think length check is already done when we copy the header. No?

        This sets num_buffers for the tap case (where hdr_size is 0).
We don't copy any headers at all for this case, but we need to
add num_buffers at offset 10 in the user buffer already read by
recvmsg().

> 
> > +            vq_err(vq, "tiny buffers < %d unsupported",
> > +               vq->iov[0].iov_len);
> > +            vhost_discard_desc(vq, headcount);
> > +            break;
> 
> Problem here is that recvmsg might modify iov.
> This is why I think we need to use vq->hdr here.

        rcvmsg() can never modify the iovec; it's the
standard socket call. To use vq->hdr, we'd have to copy
it in from user space, modify it, and then copy it back
in to user space, on every packet. In the normal tap case,
hdr_size is 0 and we read it directly from the socket to
user space. It is already correct for mergeable buffers,
except for the num_buffers value added here.

> 
> > +         } else if (put_user(headcount, &vhdr->num_buffers)) {
> 
> The above put_user writes out a 32 bit value, right?
> This seems wrong.

        I'll recheck this -- I'll make the type of "headcount" be
the type of "num_buffers" in the MRXB vnet header, if it isn't
already.

> 
> How about using
>    memcpy_toiovecend(vq->hdr, &headcount,
>            offsetof(struct virtio_net_hdr_mrg_rxbuf, num_buffers),
>            sizeof headcount);
> 
> this way we also do not make any assumptions about layout.

        Because this overwrites the valid vnet header we got from
the tap socket with a local copy that isn't correct. For this to
work, we first need to copy_from_user() the vnet header from the
socket into vq->hdr (on every packet).
        It doesn't assume anything here-- it requires (and checks)
that the user didn't give us a <12 byte buffer, which I think is
reasonable. That's about the size of the descriptor for the buffer,
and I'd call that a broken guest. The cost of supporting those
tiny buffers in the general case would be a copy_from_user() and
copy_to_user() of the vnet_hdr on every packet, which I think is
not worth it (and especially since I don't expect any guest is
ever going to give us a <12 byte buffer in the first place).


> > @@ -560,9 +593,14 @@ done:
> > 
> >  static int vhost_net_set_features(struct vhost_net *n, u64 features)
> >  {
> > -   size_t hdr_size = features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
> > -      sizeof(struct virtio_net_hdr) : 0;
> > +   size_t hdr_size = 0;
> >     int i;
> > +
> > +   if (features & (1 << VHOST_NET_F_VIRTIO_NET_HDR)) {
> > +      hdr_size = sizeof(struct virtio_net_hdr);
> > +      if (features & (1 << VIRTIO_NET_F_MRG_RXBUF))
> > +         hdr_size = sizeof(struct virtio_net_hdr_mrg_rxbuf);
> 
> My personal style for this would be:
>      if (!(features & (1 << VHOST_NET_F_VIRTIO_NET_HDR)))
>       hdr_size = 0
>    else if (!(features & (1 << VIRTIO_NET_F_MRG_RXBUF)))
>       hdr_size = sizeof(virtio_net_hdr);
>    else
>       hdr_size = sizeof(struct virtio_net_hdr_mrg_rxbuf);
> 
> which results in more symmetry and less nesting.

OK.

> 
> >     mutex_lock(&n->dev.mutex);
> >     if ((features & (1 << VHOST_F_LOG_ALL)) &&
> >         !vhost_log_access_ok(&n->dev)) {
> > diff -ruNp net-next-p0/drivers/vhost/vhost.c
> > net-next-v3/drivers/vhost/vhost.c
> > --- net-next-p0/drivers/vhost/vhost.c   2010-03-22 12:04:38.000000000
> > -0700
> > +++ net-next-v3/drivers/vhost/vhost.c   2010-04-06 12:57:51.000000000
> > -0700
> > @@ -856,6 +856,47 @@ static unsigned get_indirect(struct vhos
> >     return 0;
> >  }
> > 
> > +/* This is a multi-buffer version of vhost_get_vq_desc
> > + * @vq      - the relevant virtqueue
> > + * datalen   - data length we'll be reading
> > + * @iovcount   - returned count of io vectors we fill
> > + * @log      - vhost log
> > + * @log_num   - log offset
> > + *   returns number of buffer heads allocated, 0 on error
> 
> This is unusual. Let's return a negative error code on error.

        This is like malloc -- "0" is never a valid return value, and
we don't have actual error values to return and handle; they generate
vq_err() messages within the code itself. In all cases,
it is the count of buffers we allocated (which is 0 when we fail to
allocate). So, I don't agree with this, but can do it if you insist.

> 
> > + */
> > +int vhost_get_desc_n(struct vhost_virtqueue *vq, struct 
vring_used_elem
> > *heads,
> > +           int datalen, int *iovcount, struct vhost_log *log,
> > +           unsigned int *log_num)
> > +{
> > +   int out, in;
> > +   int seg = 0;      /* iov index */
> > +   int hc = 0;      /* head count */
> > +
> > +   while (datalen > 0) {
> > +      if (hc >= VHOST_NET_MAX_SG)
> > +         goto err;
> > +      heads[hc].id = vhost_get_desc(vq->dev, vq, vq->iov+seg,
> > +                     ARRAY_SIZE(vq->iov)-seg, &out,
> > +                     &in, log, log_num);
> > +      if (heads[hc].id == vq->num)
> > +         goto err;
> > +      if (out || in <= 0) {
> > +         vq_err(vq, "unexpected descriptor format for RX: "
> > +            "out %d, in %d\n", out, in);
> > +         goto err;
> > +      }
> > +      heads[hc].len = iov_length(vq->iov+seg, in);
> > +      datalen -= heads[hc].len;
> 
> This signed/unsigned mix makes me nervuous.
> Let's make datalen unsigned, add unsigned total_len, and
> while (datalen < total_len).
> 
> > +      hc++;
> > +      seg += in;
> > +   }
> > +   *iovcount = seg;
> > +   return hc;
> > +err:
> > +   vhost_discard_desc(vq, hc);
> > +   return 0;
> > +}
> > +
> >  /* This looks in the virtqueue and for the first available buffer, 
and
> > converts
> >   * it to an iovec for convenient access.  Since descriptors consist 
of
> > some
> >   * number of output then some number of input descriptors, it's
> > actually two
> > @@ -863,7 +904,7 @@ static unsigned get_indirect(struct vhos
> >   *
> >   * This function returns the descriptor number found, or vq->num 
(which
> >   * is never a valid descriptor number) if none was found. */
> > -unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct
> > vhost_virtqueue *vq,
> > +unsigned vhost_get_desc(struct vhost_dev *dev, struct vhost_virtqueue
> > *vq,
> >              struct iovec iov[], unsigned int iov_size,
> >              unsigned int *out_num, unsigned int *in_num,
> >              struct vhost_log *log, unsigned int *log_num)
> > @@ -981,31 +1022,42 @@ unsigned vhost_get_vq_desc(struct vhost_
> >  }
> > 
> >  /* Reverse the effect of vhost_get_vq_desc. Useful for error 
handling.
> > */
> > -void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
> > +void vhost_discard_desc(struct vhost_virtqueue *vq, int n)
> >  {
> > -   vq->last_avail_idx--;
> > +   vq->last_avail_idx -= n;
> >  }
> > 
> >  /* After we've used one of their buffers, we tell them about it. 
We'll
> > then
> >   * want to notify the guest, using eventfd. */
> > -int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int
> > len)
> > +int vhost_add_used(struct vhost_virtqueue *vq, struct vring_used_elem
> > *heads,
> > +         int count)
> 
> I think we are better off with vhost_add_used and vhost_add_used_n:
> the version with _n has a lot of extra complexity, and tx always
> adds them 1 by one.

        The external code only calls vhost_add_used_and_signal(), so I
split that. I can add a single variant of vhost_add_used() too, but
I was trying to avoid adding duplicate code and external interface.
I don't actually agree with splitting these; isn't it better to have
them going through the same code path whether it's single or multiple?
A bug in one would show up as an intermittent failure, and a change
to one requires changing both. I don't think the multiple should just
do the single repeatedly, either, since the multiple variant now can
do the work in one or two copy_to_user()'s, without a loop; so splitting
these just makes a special case for single to carry in code maintenance
with no benefit, I think.

> 
> >  {
> >     struct vring_used_elem *used;
> > +   int start, n;
> > +
> > +   if (count <= 0)
> > +      return -EINVAL;
> > 
> > -   /* The virtqueue contains a ring of used buffers.  Get a pointer 
to
> > the
> > -    * next entry in that used ring. */
> > -   used = &vq->used->ring[vq->last_used_idx % vq->num];
> > -   if (put_user(head, &used->id)) {
> > -      vq_err(vq, "Failed to write used id");
> > +   start = vq->last_used_idx % vq->num;
> > +   if (vq->num - start < count)
> > +      n = vq->num - start;
> > +   else
> > +      n = count;
> 
> use min?

        Sure.

> 
> > +   used = vq->used->ring + start;
> > +   if (copy_to_user(used, heads, sizeof(heads[0])*n)) {
> > +      vq_err(vq, "Failed to write used");
> >        return -EFAULT;
> >     }
> > -   if (put_user(len, &used->len)) {
> > -      vq_err(vq, "Failed to write used len");
> > -      return -EFAULT;
> > +   if (n < count) {   /* wrapped the ring */
> > +      used = vq->used->ring;
> > +      if (copy_to_user(used, heads+n, sizeof(heads[0])*(count-n))) {
> > +         vq_err(vq, "Failed to write used");
> > +         return -EFAULT;
> > +      }
> >     }
> >     /* Make sure buffer is written before we update index. */
> >     smp_wmb();
> > -   if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
> > +   if (put_user(vq->last_used_idx+count, &vq->used->idx)) {
> 
> I am a bit confused ... will this write a 32 or 16 bit value?
> count is 32 bit ... Maybe we are better off with
>   u16 idx = vq->last_used_idx + count
>   put_user(idx, &vq->used->idx)
>   vq->last_used_idx = idx

        How about a cast?:

        if (put_user((u16)(vq->last_used_idx+count), &vq->used->idx)) {


                                        +-DLS

