From: Jeff Garzik <jeff@garzik.org>
Subject: Re: delay via-rhine irq initialisation.
Date: Sat, 22 Dec 2007 22:36:44 -0500
Message-ID: <476DD7CC.9090507@garzik.org>
References: <20071211233909.GA22470@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44709 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752949AbXLWDgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Dec 2007 22:36:49 -0500
In-Reply-To: <20071211233909.GA22470@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones wrote:
> With CONFIG_DEBUG_SHIRQ set, via-rhine complains during init.
> (See https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=377721 for a report).
> 
> Does this diff look right?
> (I don't have a via-rhine handy to test with)
> 
> We may be able to get away with moving the request_irq to just after the
> alloc_tbufs(), but I feel if a real interrupt occured, this diff would
> stand more chance of doing the right thing.
> 
> Comments?
> 
> 	Dave
> 
> Delay irq registration until after we've allocated ring buffers,
> otherwise DEBUG_SHIRQ will complain.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>
> 
> diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
> index 07263cd..37b3efb 100644
> --- a/drivers/net/via-rhine.c
> +++ b/drivers/net/via-rhine.c
> @@ -1151,24 +1151,28 @@ static int rhine_open(struct net_device *dev)
>  	void __iomem *ioaddr = rp->base;
>  	int rc;
>  
> -	rc = request_irq(rp->pdev->irq, &rhine_interrupt, IRQF_SHARED, dev->name,
> -			dev);
> -	if (rc)
> -		return rc;
> -
>  	if (debug > 1)
>  		printk(KERN_DEBUG "%s: rhine_open() irq %d.\n",
>  		       dev->name, rp->pdev->irq);
>  
>  	rc = alloc_ring(dev);
> -	if (rc) {
> -		free_irq(rp->pdev->irq, dev);
> +	if (rc)
>  		return rc;
> -	}
> +
>  	alloc_rbufs(dev);
>  	alloc_tbufs(dev);
>  	rhine_chip_reset(dev);
>  	init_registers(dev);
> +
> +	rc = request_irq(rp->pdev->irq, &rhine_interrupt, IRQF_SHARED, dev->name,
> +			dev);
> +	if (rc) {
> +		free_rbufs(dev);
> +		free_tbufs(dev);
> +		free_ring(dev);
> +		return rc;
> +	}
> +

Absolutely we want to do this.  DEBUG_SHIRQ is only one of many reasons 
-- quite simply, you are fixing an order-of-init bug that leads to races 
and other badness.

I would request that the error cleanup be done in the standard style for 
net drivers (indeed, most drivers):

	rc = request_irq(...);
	if (rc)
		goto err_out;

	...

	return 0;

     err_out:
	...
	return rc;

Also I would change the subject to something like "fix order of init 
bugs" or "fix races" or whatnot.

We must assume, when writing drivers, that an interrupt will be 
delivered _immediately_ once request_irq() is called -- possibly even 
before request_irq() has returned its return code.

Regards,

	Jeff


