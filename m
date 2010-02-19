From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next-2.6] vhost: Restart tx poll when socket send
	queue is full
Date: Fri, 19 Feb 2010 16:42:03 +0200
Message-ID: <20100219144203.GD14847@redhat.com>
References: <1266526751.15681.71.camel@w-sridhar.beaverton.ibm.com> <20100218223021.GB14847@redhat.com> <1266544807.15681.259.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344Ab0BSOpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2010 09:45:21 -0500
Content-Disposition: inline
In-Reply-To: <1266544807.15681.259.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2010 at 06:00:07PM -0800, Sridhar Samudrala wrote:
> On Fri, 2010-02-19 at 00:30 +0200, Michael S. Tsirkin wrote:
> > On Thu, Feb 18, 2010 at 12:59:11PM -0800, Sridhar Samudrala wrote:
> > > When running guest to remote host TCP stream test using vhost-net
> > > via tap/macvtap, i am seeing network transmit hangs. This happens
> > > when handle_tx() returns because of the socket send queue full 
> > > condition.
> > > This patch fixes this by restarting tx poll when hitting this
> > > condition.
> > 
> > 
> > Thanks! I would like to better understand what happens exactly.
> > Some questions below:
> > 
> > > 
> > > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> > > 
> > > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > > index 91a324c..82d4bbe 100644
> > > --- a/drivers/vhost/net.c
> > > +++ b/drivers/vhost/net.c
> > > @@ -113,12 +113,16 @@ static void handle_tx(struct vhost_net *net)
> > >  	if (!sock)
> > >  		return;
> > >  
> > > -	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> > > -	if (wmem >= sock->sk->sk_sndbuf)
> > > -		return;
> > > -
> > 
> > The disadvantage here is that a spurious wakeup
> > when queue is still full becomes more expensive.
> > 
> > >  	use_mm(net->dev.mm);
> > >  	mutex_lock(&vq->mutex);
> > > +
> > > +	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> > > +	if (wmem >= sock->sk->sk_sndbuf) {
> > > +		tx_poll_start(net, sock);
> > 
> > Hmm. We already do
> >                        if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
> >                                 tx_poll_start(net, sock);
> >                                 set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
> >                                 break;
> >                         }
> > why does not this code trigger here?
> 
> This check is done only when the ring is empty(head == vq->num).
> But we are breaking out of the loop here.
>                 if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
>                         vhost_poll_queue(&vq->poll);
>                         break;
>                 }
> 
> I guess tx_poll_start() is missing here. The following patch fixes
> the hang and may be a better fix.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 4c89283..fe9d296 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -172,6 +172,7 @@ static void handle_tx(struct vhost_net *net)
>  		vhost_add_used_and_signal(&net->dev, vq, head, 0);
>  		total_len += len;
>  		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
> +			tx_poll_start(net, sock);
>  			vhost_poll_queue(&vq->poll);
>  			break;
>  		}
> 
> Thanks
> Sridhar


Hmm, this happens when
we have polled a lot of packets, and want to
give another vq a chance to poll.
Looks like a strange place to add it.

-- 
MST
