From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH v3] Add Mergeable receive buffer support to vhost_net
Date: Wed, 7 Apr 2010 14:07:18 -0700
Message-ID: <OF09358937.789A275B-ON882576FE.0067E654-882576FE.007405B5@us.ibm.com>
References: <20100407180929.GB26186@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, kvm-owner@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:46747 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835Ab0DGVHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 17:07:24 -0400
In-Reply-To: <20100407180929.GB26186@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kvm-owner@vger.kernel.org wrote on 04/07/2010 11:09:30 AM:

> On Wed, Apr 07, 2010 at 10:37:17AM -0700, David Stevens wrote:
> > > 
> > > Thanks!
> > > There's some whitespace damage, are you sending with your new
> > > sendmail setup? It seems to have worked for qemu patches ...
> > 
> >         Yes, I saw some line wraps in what I received, but I checked
> > the original draft to be sure and they weren't there. Possibly from
> > the relay; Sigh.
> > 
> > 
> > > > @@ -167,8 +166,15 @@ static void handle_tx(struct vhost_net *
> > > >        /* TODO: Check specific error and bomb out unless ENOBUFS? 
*/
> > > >        err = sock->ops->sendmsg(NULL, sock, &msg, len);
> > > >        if (unlikely(err < 0)) {
> > > > -         vhost_discard_vq_desc(vq);
> > > > -         tx_poll_start(net, sock);
> > > > +         if (err == -EAGAIN) {
> > > > +            vhost_discard_desc(vq, 1);
> > > > +            tx_poll_start(net, sock);
> > > > +         } else {
> > > > +            vq_err(vq, "sendmsg: errno %d\n", -err);
> > > > +            /* drop packet; do not discard/resend */
> > > > +            vhost_add_used_and_signal(&net->dev, vq, head,
> > > > +                       0);
> > > 
> > > vhost does not currently has a consistent error handling strategy:
> > > if we drop packets, need to think which other errors should cause
> > > packet drops.  I prefer to just call vq_err for now,
> > > and have us look at handling segfaults etc in a consistent way
> > > separately.
> > 
> > I had to add this to avoid an infinite loop when I wrote a bad
> > packet on the socket. I agree error handling needs a better look,
> > but retrying a bad packet continuously while dumping in the log
> > is what it was doing when I hit an error before this code. Isn't
> > this better, at least until a second look?
> > 
> 
> Hmm, what do you mean 'continuously'? Don't we only try again
> on next kick?

        If the packet is corrupt (in my case, a missing vnet header
during testing), every send will fail and we never make progress.
I had thousands of error messages in the log (for the same packet)
before I added this code. If the problem is with the packet,
retrying the same one as the original code does will never recover.
        This isn't required for mergeable rx buffer support, so I
can certainly remove it from this patch, but I think the original
error handling doesn't handle a single corrupted packet very
gracefully.


> > > > @@ -222,31 +242,25 @@ static void handle_rx(struct vhost_net *
> > > >     vq_log = unlikely(vhost_has_feature(&net->dev, 
VHOST_F_LOG_ALL)) ?
> > > >        vq->log : NULL;
> > > > 
> > > > -   for (;;) {
> > > > -      head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> > > > -                ARRAY_SIZE(vq->iov),
> > > > -                &out, &in,
> > > > -                vq_log, &log);
> > > > +   while ((datalen = vhost_head_len(sock->sk))) {
> > > > +      headcount = vhost_get_desc_n(vq, vq->heads, datalen, &in,
> > > > +                    vq_log, &log);
> > > 
> > > This looks like a bug, I think we need to pass
> > > datalen + header size to vhost_get_desc_n.
> > > Not sure how we know the header size that backend will use though.
> > > Maybe just look at our features.
> > 
> >         Yes; we have hdr_size, so I can add it here. It'll be 0 for
> > the cases where the backend and guest both have vnet header (either
> > the regular or larger mergeable buffers one), but should be added
> > in for future raw socket support.
> 
> So hdr_size is the wrong thing to add then.
> We need to add non-zero value for tap now.

        datalen includes the vnet_hdr in the tap case, so we don't need
a non-zero hdr_size. The socket data has the entire packet and vnet_hdr
and that length is what we're getting from vhost_head_len().

> 
> > > 
> > > >        /* OK, now we need to know about added descriptors. */
> > > > -      if (head == vq->num) {
> > > > -         if (unlikely(vhost_enable_notify(vq))) {
> > > > +      if (!headcount) {
> > > > +         if (retries == 0 && unlikely(vhost_enable_notify(vq))) {
> > > >              /* They have slipped one in as we were
> > > >               * doing that: check again. */
> > > >              vhost_disable_notify(vq);
> > > > +            retries++;
> > > >              continue;
> > > >           }
> > > 
> > > Hmm. The reason we have the code at all, as the comment says, is 
because
> > > guest could have added more buffers between the time we read last 
index
> > > and the time we enabled notification. So if we just break like this
> > > the race still exists. We could remember the
> > > last head value we observed, and have vhost_enable_notify check
> > > against this value?
> > 
> >         This is to prevent a spin loop in the case where we have some
> > buffers available, but not enough for the current packet (ie, this
> > is the replacement code for the "rxmaxheadcount" business). If they
> > actually added something new, retrying once should see it, but what
> > vhost_enable_notify() returns non-zero on is not "new buffers" but
> > rather "not empty". In the case mentioned, we aren't empty, so
> > vhost_enable_notify() returns nonzero every time, but the guest hasn't
> > given us enough buffers to proceed, so we continuously retry; this
> > code breaks the spin loop until we've really got new buffers from
> > the guest.
> 
> What about the race I point out above? It seems to potentially
> cause a deadlock.

        It certainly handles a single race, since the code is identical
when retries==0. I was assuming that a real update would always get us
enough buffers, so could not happen twice in a row. The false case of
having 1 buffer when we need 3, say, would return nonzero every time,
so this code would detect that and break that loop; never hang if a
real guest update gives us a full ring.
        If we think we've exhausted the ring and a guest update gives us
a couple buffers, but not the complete ring (which is what it does in
practice), then we'd still have a race. In that case, we should be
comparing avail_idx with itself across multiple calls, rather than
last_avail_idx (which is only updated when we post a new packet).
        I'll look at this some more. With the guest I have, this code
will always work, but I don't know that the guest is required to fill
the ring, which is what this assumes.

> 
> > > 
> > > Need to think about it.
> > > 
> > > Another concern here is that on retries vhost_get_desc_n
> > > is doing extra work, rescanning the same descriptor
> > > again and again. Not sure how common this is, might be
> > > worthwhile to add a TODO to consider this at least.
> > 
> >         I had a printk in there to test the code and with the
> > retries counter, it happens when we fill the ring (once,
> > because of the retries checks), and then proceeds as
> > desired when the guest gives us more buffers. Without the
> > check, it spews until we hear from the guest.
> 
> I don't understand whether what you write above means 'yes this happens
> and is worth optimizing for' or 'this happens very rarely
> and is not worth optimizing for'.

        I'm saying "no", even with high load, we don't hit the
retries==1 very often with the new code. It only happens when the ring
is completely full. In that case, with the old code, we would spin until 
we
hear from the guest (tens of thousands of times); with the new code,
we hit it once when the ring is full and wait for the guest to give
us more buffers; then we proceed.
        With the new code in a test run of tens of millions of packets,
I got maybe 5 or 6 times where we exhausted the ring and waited, but
with the old code, we did enable/disable tens of thousands of times
because the ring wasn't completely empty and we were spinning until
we got new buffers from the guest.


> > > > -         vhost_discard_vq_desc(vq);
> > > > +         vhost_discard_desc(vq, headcount);
> > > >           break;
> > > >        }
> > > >        /* TODO: Should check and handle checksum. */
> > > > +      if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF)) {
> > > > +         struct virtio_net_hdr_mrg_rxbuf *vhdr =
> > > > +            (struct virtio_net_hdr_mrg_rxbuf *)
> > > > +            vq->iov[0].iov_base;
> > > > +         /* add num_buffers */
> > > > +         if (vhost_has_feature(&net->dev,
> > > > +                     VHOST_NET_F_VIRTIO_NET_HDR))
> > > > +            hdr.num_buffers = headcount;
> > > 
> > > Why is the above necessary?
> > 
> >         This adds mergeable buffer support for the raw case.
> 
> So my suggestion is to have a copy of the header
> and then same code will fill in the field for
> both raw and tap.

        The recvmsg() has written the vnethdr into the user
buffer in the tap case. We don't have an in-kernel copy of it at
all (hdr_size == 0) in vhost. In the raw case, recvmsg isn't writing it
to the user buffer and then we do have the local copy in hdr.
        So the code updates num_buffer (only) in user space in
the tap case, and does the necessary copy of the entire header
in the raw case. I don't think a double copy of the entire vnet_hdr
on every packet is a good idea in the tap case, and the simple
assignment with the existing copy_to_user() of the header is
cheaper than double-copying num_buffers in the raw case. So, I
do think this code is best. It could use hdr_size instead of
the (in-line) feature-bit check, but there are no unnecessary
copies as-is, and I think there would be if we don't use the
two separate ways of updating num_buffers.

> > 
> > > 
> > > > +            vq_err(vq, "tiny buffers < %d unsupported",
> > > > +               vq->iov[0].iov_len);
> > > > +            vhost_discard_desc(vq, headcount);
> > > > +            break;
> > > 
> > > Problem here is that recvmsg might modify iov.
> > > This is why I think we need to use vq->hdr here.
> > 
> >         rcvmsg() can never modify the iovec;
> 
> 
> Look at af_packet code for an example where it does.
> The pointer is non-const, it's OK to modify.
> tap used to modify iovec as well, the fact it doesn't
> now is a side-effect of reusing same code for
> recvmsg and aio read.

        OK, even assuming it can, the check is done after
the recvmsg -- it can't change between the length check
and the put_user() of num_buffer, so I'm not sure what
your concern is here. Are you saying that vq->iov may
be trashed so that it no longer points to the ring buffer?
        What I need is to write the num_buffer value at
offset 10 in the userspace ring buffer after the recvmsg().
If the iovec has been modified, I'm using the modified.
If you're saying that it may be garbage, then your suggestion
is that I save the pointer to offset 10 of the ring buffer
before the call to recvmsg so I can update it after?

> > To use vq->hdr, we'd have to copy
> > it in from user space, modify it, and then copy it back
> > in to user space, on every packet. In the normal tap case,
> > hdr_size is 0 and we read it directly from the socket to
> > user space. It is already correct for mergeable buffers,
> > except for the num_buffers value added here.
> 
> 
> I don't understand what you write above, sorry.
> We have iov, all we need is store the first address+length
> in the hdr field.

Sorry, in that discussion, I was confusing "hdr" with vq->hdr.
In the tap case, hdr_size is 0 and we have nothing in vq->hdr.
As discussed before, if you mean updating a local copy of the
header, we don't have a local copy of the header -- recvmsg()
has written it directly to the user buffer. To get a local
copy, we'd need to either copy_from_user() out of the ring or
get it from recvmsg() by changing the iovec and then later
do an extra copy of it to get it in the user buffer where we
need it.

> 
> > > 
> > > How about using
> > >    memcpy_toiovecend(vq->hdr, &headcount,
> > >            offsetof(struct virtio_net_hdr_mrg_rxbuf, num_buffers),
> > >            sizeof headcount);
> > > 
> > > this way we also do not make any assumptions about layout.
> > 
> >         Because this overwrites the valid vnet header we got from
> > the tap socket with a local copy that isn't correct.
> 
> It does? I think that this only writes out 2 bytes at an offset.

        Oh, sorry, I misread. vq->hdr doesn't have anything in it in
the tap case, but something like this may eliminate the need to check
iov_len > sizeof(*vhdr); will investigate.


                                                        +-DLS


