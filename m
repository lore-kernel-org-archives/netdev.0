From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH v2 net-next 06/12] ep93xx_eth: add GRO support
Date: Mon, 15 May 2017 13:31:32 +0300
Message-ID: <20170515103132.GA24992@wantstofly.org>
References: <20170204232502.22361-1-edumazet@google.com>
 <20170204232502.22361-7-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Ryan Mallon <rmallon@gmail.com>,
        Hartley Sweeten <hsweeten@visionengravers.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:48582 "EHLO
        mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751898AbdEOKgt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 06:36:49 -0400
Content-Disposition: inline
In-Reply-To: <20170204232502.22361-7-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 03:24:56PM -0800, Eric Dumazet wrote:

> Use napi_complete_done() instead of __napi_complete() to :
> 
> 1) Get support of gro_flush_timeout if opt-in
> 2) Not rearm interrupts for busy-polling users.
> 3) use standard NAPI API.
> 4) get rid of baroque code and ease maintenance.
>
> [...]
>
> @@ -310,35 +311,17 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
>  	return processed;
>  }
>  
> -static int ep93xx_have_more_rx(struct ep93xx_priv *ep)
> -{
> -	struct ep93xx_rstat *rstat = ep->descs->rstat + ep->rx_pointer;
> -	return !!((rstat->rstat0 & RSTAT0_RFP) && (rstat->rstat1 & RSTAT1_RFP));
> -}
> -
>  static int ep93xx_poll(struct napi_struct *napi, int budget)
>  {
>  	struct ep93xx_priv *ep = container_of(napi, struct ep93xx_priv, napi);
>  	struct net_device *dev = ep->dev;
> -	int rx = 0;
> -
> -poll_some_more:
> -	rx = ep93xx_rx(dev, rx, budget);
> -	if (rx < budget) {
> -		int more = 0;
> +	int rx;
>  
> +	rx = ep93xx_rx(dev, budget);
> +	if (rx < budget && napi_complete_done(napi, rx)) {
>  		spin_lock_irq(&ep->rx_lock);
> -		__napi_complete(napi);
>  		wrl(ep, REG_INTEN, REG_INTEN_TX | REG_INTEN_RX);
> -		if (ep93xx_have_more_rx(ep)) {
> -			wrl(ep, REG_INTEN, REG_INTEN_TX);
> -			wrl(ep, REG_INTSTSP, REG_INTSTS_RX);
> -			more = 1;
> -		}
>  		spin_unlock_irq(&ep->rx_lock);
> -
> -		if (more && napi_reschedule(napi))
> -			goto poll_some_more;
>  	}
>  
>  	if (rx) {

This code was the way it was because the ep93xx hardware is somewhat
braindead.  If I remember correctly (but it's been a while since I wrote
this code):

1. ep93xx netdev IRQs are edge-triggered, so if you re-enable IRQs
   while there was still work to be done, you will not get another IRQ.

2. Disabling an interrupt source in the interrupt mask register will
   cause its interrupt status bit to always return zero, so you cannot
   check whether an interrupt status is pending without having the
   interrupt source enabled.

(I'll admit that a comment explaining this would have been in order.)

I don't know if we really care about this hardware anymore (I don't),
but the ep93xx platform is still listed as being maintained in the
MAINTAINERS file -- adding Ryan and Hartley.
