From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: R[PATCH 2.6.10-rc1 8/15] wireless/orinoco: Refactor spinlocks
 so	we don't necessarily have to disable interrupts
Date: Tue, 26 Oct 2004 15:44:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417EA915.9090500@pobox.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098817472.3663.66.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1098817472.3663.66.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> Update in-kernel orinoco wireless drivers to upstream CVS.
> None of this is original code by Dan Williams, simply a
> broken down patch set split-out from upstream orinoco CVS.
> 
> o Refactor spinlocks so we don't necessarily have to disable interrupts
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> 
> --- a/drivers/net/wireless/orinoco.h.8-orinoco-spinlock	2004-10-26 10:44:41.445687264 -0400
> +++ b/drivers/net/wireless/orinoco.h	2004-10-26 10:45:39.296892544 -0400
> @@ -71,6 +71,8 @@
>  	u16 channel_mask;
>  	int broken_disableport;
>  
> +	unsigned int irq_no_disable:1;
> +
>  	/* Configuration paramaters */
>  	u32 iw_mode;
>  	int prefer_port3;
> @@ -129,11 +131,17 @@
>  extern inline int orinoco_lock(struct orinoco_private *priv,
>  			       unsigned long *flags)
>  {
> -	spin_lock_irqsave(&priv->lock, *flags);
> +	if (priv->irq_no_disable)
> +		spin_lock_bh(&priv->lock);
> +	else
> +		spin_lock_irqsave(&priv->lock, *flags);
>  	if (priv->hw_unavailable) {
> -		printk(KERN_DEBUG "orinoco_lock() called with hw_unavailable (dev=%p)\n",
> +		DEBUG(1, "orinoco_lock() called with hw_unavailable (dev=%p)\n",
>  		       priv->ndev);
> -		spin_unlock_irqrestore(&priv->lock, *flags);
> +		if (priv->irq_no_disable)
> +			spin_unlock_bh(&priv->lock);
> +		else
> +			spin_unlock_irqrestore(&priv->lock, *flags);
>  		return -EBUSY;

This entire area has problems.

Orinoco doesn't need to invent its own locking primitives, nor does it 
need to be inventing functions that take *flags as an argument.

	Jeff
