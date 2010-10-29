From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] virtio_net: Fix queue full check
Date: Fri, 29 Oct 2010 16:25:09 +0530
Message-ID: <OF30574F6E.113EC5F4-ON652577CB.0037DAB5-652577CB.003BACE8@in.ibm.com>
References: <20101028051036.25340.23442.sendpatchset@krkumar2.in.ibm.com> <201010292017.25099.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:41988 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760985Ab0J2Kvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 06:51:55 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id o9TApp14023287
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 16:21:51 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9TAppQI3919948
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 16:21:51 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9TApp4w024171
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 21:51:51 +1100
In-Reply-To: <201010292017.25099.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell <rusty@rustcorp.com.au> wrote on 10/29/2010 03:17:24 PM:

> > Oct 17 10:22:40 localhost kernel: net eth0: Unexpected TX queue
failure: -28
> > Oct 17 10:28:22 localhost kernel: net eth0: Unexpected TX queue
failure: -28
> > Oct 17 10:35:58 localhost kernel: net eth0: Unexpected TX queue
failure: -28
> > Oct 17 10:41:06 localhost kernel: net eth0: Unexpected TX queue
failure: -28
> >
> > I initially changed the check from -ENOMEM to -ENOSPC, but
> > virtqueue_add_buf can return only -ENOSPC when it doesn't have
> > space for new request.  Patch removes redundant checks but
> > displays the failure errno.
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > ---
> >  drivers/net/virtio_net.c |   15 ++++-----------
> >  1 file changed, 4 insertions(+), 11 deletions(-)
> >
> > diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
> > --- org/drivers/net/virtio_net.c   2010-10-11 10:20:02.000000000 +0530
> > +++ new/drivers/net/virtio_net.c   2010-10-21 17:37:45.000000000 +0530
> > @@ -570,17 +570,10 @@ static netdev_tx_t start_xmit(struct sk_
> >
> >     /* This can happen with OOM and indirect buffers. */
> >     if (unlikely(capacity < 0)) {
> > -      if (net_ratelimit()) {
> > -         if (likely(capacity == -ENOMEM)) {
> > -            dev_warn(&dev->dev,
> > -                "TX queue failure: out of memory\n");
> > -         } else {
> > -            dev->stats.tx_fifo_errors++;
> > -            dev_warn(&dev->dev,
> > -                "Unexpected TX queue failure: %d\n",
> > -                capacity);
> > -         }
> > -      }
> > +      if (net_ratelimit())
> > +         dev_warn(&dev->dev,
> > +             "TX queue failure (%d): out of memory\n",
> > +             capacity);
>
> Hold on... you were getting -ENOSPC, which shouldn't happen.  What makes
you
> think it's out of memory?

virtqueue_add_buf_gfp returns only -ENOSPC on failure, whether
direct or indirect descriptors are used, so isn't -ENOSPC
"expected"? (vring_add_indirect returns -ENOMEM on memory
failure, but that is masked out and we go direct which is
the failure point).

Thanks,

- KK

