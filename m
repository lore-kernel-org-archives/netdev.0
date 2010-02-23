From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] vhost: Restart tx poll when socket send
 queue is full
Date: Tue, 23 Feb 2010 09:31:32 -0800
Message-ID: <1266946292.6364.6.camel@w-sridhar.beaverton.ibm.com>
References: <1266526751.15681.71.camel@w-sridhar.beaverton.ibm.com>
	 <20100223102437.GA23835@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:42157 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752544Ab0BWRbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2010 12:31:36 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1NHKelN024894
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 12:20:40 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1NHVZ1e107268
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 12:31:35 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1NHVYfd008130
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 12:31:35 -0500
In-Reply-To: <20100223102437.GA23835@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-23 at 12:24 +0200, Michael S. Tsirkin wrote:
> On Thu, Feb 18, 2010 at 12:59:11PM -0800, Sridhar Samudrala wrote:
> > When running guest to remote host TCP stream test using vhost-net
> > via tap/macvtap, i am seeing network transmit hangs. This happens
> > when handle_tx() returns because of the socket send queue full 
> > condition.
> > This patch fixes this by restarting tx poll when hitting this
> > condition.
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
> >  	use_mm(net->dev.mm);
> >  	mutex_lock(&vq->mutex);
> > +
> > +	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> > +	if (wmem >= sock->sk->sk_sndbuf) {
> > +		tx_poll_start(net, sock);
> > +		set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
> > +		goto unlock;
> > +	}
> > +
> >  	vhost_disable_notify(vq);
> >  
> >  	if (wmem < sock->sk->sk_sndbuf * 2)
> > @@ -178,6 +182,7 @@ static void handle_tx(struct vhost_net *net)
> >  		}
> >  	}
> >  
> > +unlock:
> >  	mutex_unlock(&vq->mutex);
> >  	unuse_mm(net->dev.mm);
> >  }
> 
> 
> It might be better to avoid use_mm when ring is full.
> Does the following fix the tx hang for you?

Yes. this fixes the tx hang.

Thanks
Sridhar

> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 4c89283..f5f6efe 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -113,8 +113,12 @@ static void handle_tx(struct vhost_net *net)
>  		return;
> 
>  	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> -	if (wmem >= sock->sk->sk_sndbuf)
> -		return;
> +	if (wmem >= sock->sk->sk_sndbuf) {
> +		mutex_lock(&vq->mutex);
> +		tx_poll_start(net, sock);
> +		mutex_unlock(&vq->mutex);
> +                return;
> +	}
> 
>  	use_mm(net->dev.mm);
>  	mutex_lock(&vq->mutex);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

