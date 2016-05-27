From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,RFC] macvlan: Handle broadcasts inline if we have only a
 few macvlans.
Date: Fri, 27 May 2016 21:03:59 +0300
Message-ID: <20160527180359.GW8402@wantstofly.org>
References: <20160526234433.GU8402@wantstofly.org>
 <CAM_iQpWwX_tJVk-96v2Xjwrm+Nijk1AkRhe+aoNU6o_3bQh_BA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:50052 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756372AbcE0SEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 14:04:02 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpWwX_tJVk-96v2Xjwrm+Nijk1AkRhe+aoNU6o_3bQh_BA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2016 at 10:56:44AM -0700, Cong Wang wrote:

> > Commit 412ca1550cbecb2c ("macvlan: Move broadcasts into a work queue")
> > moved processing of all macvlan multicasts into a work queue.  This
> > causes a noticable performance regression when there is heavy multicast
> > traffic on the underlying interface for multicast groups that the
> > macvlan subinterfaces are not members of, in which case we end up
> > cloning all those packets and then freeing them again from a work queue
> > without really doing any useful work with them in between.
> 
> But we only queue up to 1000 packets in our backlog.
> 
> How about adding a quick check before cloning it?
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index cb01023..1c73d0f 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -315,6 +315,9 @@ static void macvlan_broadcast_enqueue(struct
> macvlan_port *port,
>         struct sk_buff *nskb;
>         int err = -ENOMEM;
> 
> +       if (skb_queue_len(&port->bc_queue) >= MACVLAN_BC_QUEUE_LEN)
> +               return;
> +
>         nskb = skb_clone(skb, GFP_ATOMIC);
>         if (!nskb)
>                 goto err;

We're not hitting the bc_queue skb limit in our environment, as the
machine can keep up with the traffic -- it's just that taking an
extra clone of the skb and queueing and running the work queue item
to free it again is eating up a lot of cycles.

But doing the queue length check before the clone might not be a bad
idea?  (You'd probably want to atomic_long_inc(&skb->dev->rx_dropped)
before returning, though?)
