From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: Fix queue full check
Date: Fri, 29 Oct 2010 21:58:40 +1030
Message-ID: <201010292158.40411.rusty@rustcorp.com.au>
References: <20101028051036.25340.23442.sendpatchset@krkumar2.in.ibm.com> <201010292017.25099.rusty@rustcorp.com.au> <OF30574F6E.113EC5F4-ON652577CB.0037DAB5-652577CB.003BACE8@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45182 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933746Ab0J2L2r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 07:28:47 -0400
In-Reply-To: <OF30574F6E.113EC5F4-ON652577CB.0037DAB5-652577CB.003BACE8@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Oct 2010 09:25:09 pm Krishna Kumar2 wrote:
> Rusty Russell <rusty@rustcorp.com.au> wrote on 10/29/2010 03:17:24 PM:
> 
> > > Oct 17 10:22:40 localhost kernel: net eth0: Unexpected TX queue
> failure: -28
> > > Oct 17 10:28:22 localhost kernel: net eth0: Unexpected TX queue
> failure: -28
> > > Oct 17 10:35:58 localhost kernel: net eth0: Unexpected TX queue
> failure: -28
> > > Oct 17 10:41:06 localhost kernel: net eth0: Unexpected TX queue
> failure: -28
> > >
> > > I initially changed the check from -ENOMEM to -ENOSPC, but
> > > virtqueue_add_buf can return only -ENOSPC when it doesn't have
> > > space for new request.  Patch removes redundant checks but
> > > displays the failure errno.
> > >
> > > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > > ---
> > >  drivers/net/virtio_net.c |   15 ++++-----------
> > >  1 file changed, 4 insertions(+), 11 deletions(-)
> > >
> > > diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
> > > --- org/drivers/net/virtio_net.c   2010-10-11 10:20:02.000000000 +0530
> > > +++ new/drivers/net/virtio_net.c   2010-10-21 17:37:45.000000000 +0530
> > > @@ -570,17 +570,10 @@ static netdev_tx_t start_xmit(struct sk_
> > >
> > >     /* This can happen with OOM and indirect buffers. */
> > >     if (unlikely(capacity < 0)) {
> > > -      if (net_ratelimit()) {
> > > -         if (likely(capacity == -ENOMEM)) {
> > > -            dev_warn(&dev->dev,
> > > -                "TX queue failure: out of memory\n");
> > > -         } else {
> > > -            dev->stats.tx_fifo_errors++;
> > > -            dev_warn(&dev->dev,
> > > -                "Unexpected TX queue failure: %d\n",
> > > -                capacity);
> > > -         }
> > > -      }
> > > +      if (net_ratelimit())
> > > +         dev_warn(&dev->dev,
> > > +             "TX queue failure (%d): out of memory\n",
> > > +             capacity);
> >
> > Hold on... you were getting -ENOSPC, which shouldn't happen.  What makes
> you
> > think it's out of memory?
> 
> virtqueue_add_buf_gfp returns only -ENOSPC on failure, whether
> direct or indirect descriptors are used, so isn't -ENOSPC
> "expected"? (vring_add_indirect returns -ENOMEM on memory
> failure, but that is masked out and we go direct which is
> the failure point).

Ah, OK, gotchya.

I'm not even sure the fallback to linear makes sense; if we're failing
kmallocs we should probably just return -ENOMEM.  Would mean we can
tell the difference between "out of space" (which should never happen
since we stop the queue when we have < 2+MAX_SKB_FRAGS slots left)
and this case.

Michael, what do you think?

Thanks,
Rusty.
