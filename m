From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] 3c515: Write outside array bounds
Date: Wed, 29 Jul 2009 22:43:00 +0200
Message-ID: <20090729204300.GC3058@ami.dom.local>
References: <4A6B88B1.9000907@gmail.com> <4A6CC7BD.9020602@gmail.com> <4A705904.4020505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f228.google.com ([209.85.220.228]:64877 "EHLO
	mail-fx0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755616AbZG2Unl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 16:43:41 -0400
Received: by fxm28 with SMTP id 28so232202fxm.17
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 13:43:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A705904.4020505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 04:13:24PM +0200, Roel Kluin wrote:
> Op 26-07-09 23:16, Jarek Poplawski schreef:
> > Roel Kluin wrote, On 07/26/2009 12:35 AM:
> > 
> >> if dev_alloc_skb() fails on the first iteration, a write to
> >> cp->rx_ring[-1] occurs.
> >>
> >> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> >> ---
> >> Please review: can we error return like this?
> > 
> > 
> > I doubt we can return here: there is a lot of cleaning missing.
> > 
> > Jarek P.
> I took drivers/net/3c59x.c as an example
> 
> Is this going in the right direction?

The direction is right but a long and winding road... I guess it's for
somebody with drivers knowhow. It seems most of the corkscrew_close()
might be needed, including del_timer(). So, since this -1 case looks
quite unlikely, it might be reasonable to only limit the most obvious
damage with 'if (i != 0)' before [i - 1] write, like David advised
in lmc case?

Cheers,
Jarek P.

> 
> diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
> index 3e00fa8..e94867d 100644
> --- a/drivers/net/3c515.c
> +++ b/drivers/net/3c515.c
> @@ -827,7 +827,7 @@ static int corkscrew_open(struct net_device *dev)
>  			skb = dev_alloc_skb(PKT_BUF_SZ);
>  			vp->rx_skbuff[i] = skb;
>  			if (skb == NULL)
> -				break;	/* Bad news!  */
> +				goto error;	/* Bad news!  */
>  			skb->dev = dev;	/* Mark as being used by this device. */
>  			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
>  			vp->rx_ring[i].addr = isa_virt_to_bus(skb->data);
> @@ -864,6 +864,17 @@ static int corkscrew_open(struct net_device *dev)
>  	     ioaddr + EL3_CMD);
>  
>  	return 0;
> +error:
> +	pr_emerg("%s: no memory for rx ring\n", dev->name);
> +	int j;
> +	for (j = 0; j < i; j++) {
> +		if (vp->rx_skbuff[j]) {
> +			dev_kfree_skb(vp->rx_skbuff[j]);
> +			vp->rx_skbuff[j] = NULL;
> +		}
> +	}
> +	free_irq(dev->irq, dev);
> +	return -ENOMEM;
>  }
>  
>  static void corkscrew_timer(unsigned long data)
