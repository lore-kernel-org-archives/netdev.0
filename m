From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] vhost: Restart tx poll when socket send
 queue is full
Date: Thu, 18 Feb 2010 18:00:07 -0800
Message-ID: <1266544807.15681.259.camel@w-sridhar.beaverton.ibm.com>
References: <1266526751.15681.71.camel@w-sridhar.beaverton.ibm.com>
	 <20100218223021.GB14847@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:34126 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145Ab0BSCA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 21:00:27 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1J1vXL5002636
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 18:57:33 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1J20816085684
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 19:00:08 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1J208Eq030595
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 19:00:08 -0700
In-Reply-To: <20100218223021.GB14847@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-19 at 00:30 +0200, Michael S. Tsirkin wrote:
> On Thu, Feb 18, 2010 at 12:59:11PM -0800, Sridhar Samudrala wrote:
> > When running guest to remote host TCP stream test using vhost-net
> > via tap/macvtap, i am seeing network transmit hangs. This happens
> > when handle_tx() returns because of the socket send queue full 
> > condition.
> > This patch fixes this by restarting tx poll when hitting this
> > condition.
> 
> 
> Thanks! I would like to better understand what happens exactly.
> Some questions below:
> 
> > 
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> > 
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index 91a324c..82d4bbe 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -113,12 +113,16 @@ static void handle_tx(struct vhost_net *net)
> >  	if (!sock)
> >  		return;
> >  
> > -	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> > -	if (wmem >= sock->sk->sk_sndbuf)
> > -		return;
> > -
> 
> The disadvantage here is that a spurious wakeup
> when queue is still full becomes more expensive.
> 
> >  	use_mm(net->dev.mm);
> >  	mutex_lock(&vq->mutex);
> > +
> > +	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> > +	if (wmem >= sock->sk->sk_sndbuf) {
> > +		tx_poll_start(net, sock);
> 
> Hmm. We already do
>                        if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
>                                 tx_poll_start(net, sock);
>                                 set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
>                                 break;
>                         }
> why does not this code trigger here?

This check is done only when the ring is empty(head == vq->num).
But we are breaking out of the loop here.
                if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
                        vhost_poll_queue(&vq->poll);
                        break;
                }

I guess tx_poll_start() is missing here. The following patch fixes
the hang and may be a better fix.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 4c89283..fe9d296 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -172,6 +172,7 @@ static void handle_tx(struct vhost_net *net)
 		vhost_add_used_and_signal(&net->dev, vq, head, 0);
 		total_len += len;
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
+			tx_poll_start(net, sock);
 			vhost_poll_queue(&vq->poll);
 			break;
 		}

Thanks
Sridhar

