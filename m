From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH for-2.6.35] virtio_net: fix oom handling on tx
Date: Mon, 21 Jun 2010 13:53:29 +0300
Message-ID: <20100621105329.GA9506@redhat.com>
References: <20100610152041.GA3480@redhat.com> <201006211213.49600.rusty@rustcorp.com.au> <20100621083315.GA8665@redhat.com> <201006211953.44724.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	virtualization@lists.linux-foundation.org,
	Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757620Ab0FUK7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 06:59:12 -0400
Content-Disposition: inline
In-Reply-To: <201006211953.44724.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 21, 2010 at 07:53:43PM +0930, Rusty Russell wrote:
> On Mon, 21 Jun 2010 06:03:16 pm Michael S. Tsirkin wrote:
> > On Mon, Jun 21, 2010 at 12:13:49PM +0930, Rusty Russell wrote:
> > > -		return NETDEV_TX_BUSY;
> > > +		kfree_skb(skb);
> > > +		return NETDEV_TX_OK;
> > 
> > If we do so, let's increment the dropped counter and/or error counter?
> 
> Yep, here's the extra change:

Looks good to me.

> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -571,14 +571,16 @@ static netdev_tx_t start_xmit(struct sk_
>  	/* This can happen with OOM and indirect buffers. */
>  	if (unlikely(capacity < 0)) {
>  		if (net_ratelimit()) {
> -			if (likely(capacity == -ENOMEM))
> +			if (likely(capacity == -ENOMEM)) {
>  				dev_warn(&dev->dev,
>  					 "TX queue failure: out of memory\n");
> -			else
> +			} else {
> +				dev->stats.tx_fifo_errors++;
>  				dev_warn(&dev->dev,
>  					 "Unexpected TX queue failure: %d\n",
>  					 capacity);
>  		}
> +		dev->stats.tx_dropped++;
>  		kfree_skb(skb);
>  		return NETDEV_TX_OK;
>  	}
