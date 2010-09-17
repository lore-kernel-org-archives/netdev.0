From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v2 RFC PATCH 2/4] Changes for virtio-net
Date: Fri, 17 Sep 2010 17:57:54 +0530
Message-ID: <OF4A8774FB.F21849D9-ON652577A1.003A4D4E-652577A1.00443FC7@in.ibm.com>
References: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com>	 <20100917100319.21276.271.sendpatchset@krkumar2.in.ibm.com> <1284719154.3391.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:57481 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab0IQMZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 08:25:35 -0400
In-Reply-To: <1284719154.3391.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 09/17/2010 03:55:54 PM:

> > +/* Our representation of a send virtqueue */
> > +struct send_queue {
> > +   struct virtqueue *svq;
> > +
> > +   /* TX: fragments + linear part + virtio header */
> > +   struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
> > +};
>
> You probably want ____cacheline_aligned_in_smp

I had tried this and mentioned this in Patch 0/4:
"2. Cache-align data structures: I didn't see any BW/SD improvement
   after making the sq's (and similarly for vhost) cache-aligned
   statically:
        struct virtnet_info {
                ...
                struct send_queue sq[16] ____cacheline_aligned_in_smp;
                ...
        };
"

I am not sure why this made no difference?

> > +
> >  struct virtnet_info {
> >     struct virtio_device *vdev;
> > -   struct virtqueue *rvq, *svq, *cvq;
> > +   int numtxqs;         /* Number of tx queues */
> > +   struct send_queue *sq;
> > +   struct virtqueue *rvq;
> > +   struct virtqueue *cvq;
> >     struct net_device *dev;
>
> struct napi will probably be dirtied by RX processing
>
> You should make sure it doesnt dirty cache line of above (read mostly)
> fields

I am changing the layout of napi wrt other pointers in
this patch, though the to-be-submitted RX patch does that.
Should I do something for this TX-only patch?

> > +#define MAX_DEVICE_NAME      16
> > +static int initialize_vqs(struct virtnet_info *vi, int numtxqs)
> > +{
> > +   vq_callback_t **callbacks;
> > +   struct virtqueue **vqs;
> > +   int i, err = -ENOMEM;
> > +   int totalvqs;
> > +   char **names;
> > +
> > +   /* Allocate send queues */
>
> no check on numtxqs ? Hmm...
>
> Please then use kcalloc(numtxqs, sizeof(*vi->sq), GFP_KERNEL) so that
> some check is done for you ;)

Right! I need to re-introduce some limit. Rusty, should I simply
add a check for a constant (like 256) here?

Thanks for your review, Eric!

- KK

