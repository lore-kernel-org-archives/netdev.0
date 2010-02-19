From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] vhost: Restart tx poll when socket send
 queue is full
Date: Fri, 19 Feb 2010 13:19:45 -0800
Message-ID: <1266614385.17881.7.camel@w-sridhar.beaverton.ibm.com>
References: <1266526751.15681.71.camel@w-sridhar.beaverton.ibm.com>
	 <20100218223021.GB14847@redhat.com>
	 <1266544807.15681.259.camel@w-sridhar.beaverton.ibm.com>
	 <20100219144203.GD14847@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:47038 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754719Ab0BSVT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 16:19:58 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1JLH4W2017024
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 14:17:04 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1JLJk75177542
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 14:19:51 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1JLJj5w016462
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 14:19:46 -0700
In-Reply-To: <20100219144203.GD14847@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-19 at 16:42 +0200, Michael S. Tsirkin wrote:

> > > Hmm. We already do
> > >                        if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
> > >                                 tx_poll_start(net, sock);
> > >                                 set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
> > >                                 break;
> > >                         }
> > > why does not this code trigger here?
> > 
> > This check is done only when the ring is empty(head == vq->num).
> > But we are breaking out of the loop here.
> >                 if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
> >                         vhost_poll_queue(&vq->poll);
> >                         break;
> >                 }
> > 
> > I guess tx_poll_start() is missing here. The following patch fixes
> > the hang and may be a better fix.
> > 
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> > 
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index 4c89283..fe9d296 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -172,6 +172,7 @@ static void handle_tx(struct vhost_net *net)
> >  		vhost_add_used_and_signal(&net->dev, vq, head, 0);
> >  		total_len += len;
> >  		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
> > +			tx_poll_start(net, sock);
> >  			vhost_poll_queue(&vq->poll);
> >  			break;
> >  		}
> > 
> > Thanks
> > Sridhar
> 
> 
> Hmm, this happens when
> we have polled a lot of packets, and want to
> give another vq a chance to poll.
> Looks like a strange place to add it.

I am also seeing sendmsg() calls failing with EAGAIN. Could be a bug in
handling this error. The check for sendq full is done outside the for
loop. It is possible that we can run out of sendq space within the for
loop. Should we check for wmem within the for loop?

Thanks
Sridhar

