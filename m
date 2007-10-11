From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH]race between open and disconnect in irda-usb
Date: Thu, 11 Oct 2007 09:23:11 -0700
Message-ID: <20071011162311.GA26354@bougret.hpl.hp.com>
References: <200710111745.28594.oliver@neukum.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Fedchik <nick@fedchik.org.ua>, netdev@vger.kernel.org,
	USB development list <linux-usb-devel@lists.sourceforge.net>
To: Oliver Neukum <oliver@neukum.org>, Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:49775 "EHLO madara.hpl.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752467AbXJKQ1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 12:27:23 -0400
Content-Disposition: inline
In-Reply-To: <200710111745.28594.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2007 at 05:45:28PM +0200, Oliver Neukum wrote:
> Hi,
> 

	Hi,

	You need to cc Samuel Ortiz and the IrDA mailing list if you
want any meaningful response.

> it seems to me that irda_usb_net_open() must set self->netopen
> under spinlock or disconnect() may fail to kill all URBs.

	I believe to patch is correct, but in practice I fail to see
how it could happen. Anyway, Samuel will have the final word.

> Signed-off-by: Oliver Neukum <oneukum@suse.de>
> 
> 	Regards
> 		Oliver

	Have fun...

	Jean

> ----
> 
> --- a/drivers/net/irda/irda-usb.c	2007-10-11 17:24:35.000000000 +0200
> +++ b/drivers/net/irda/irda-usb.c	2007-10-11 17:30:30.000000000 +0200
> @@ -1168,6 +1168,7 @@ static int stir421x_patch_device(struct 
>  static int irda_usb_net_open(struct net_device *netdev)
>  {
>  	struct irda_usb_cb *self;
> +	unsigned long flags;
>  	char	hwname[16];
>  	int i;
>  	
> @@ -1177,13 +1178,16 @@ static int irda_usb_net_open(struct net_
>  	self = (struct irda_usb_cb *) netdev->priv;
>  	IRDA_ASSERT(self != NULL, return -1;);
>  
> +	spin_lock_irqsave(&self->lock, flags);
>  	/* Can only open the device if it's there */
>  	if(!self->present) {
> +		spin_unlock_irqrestore(&self->lock, flags);
>  		IRDA_WARNING("%s(), device not present!\n", __FUNCTION__);
>  		return -1;
>  	}
>  
>  	if(self->needspatch) {
> +		spin_unlock_irqrestore(&self->lock, flags);
>  		IRDA_WARNING("%s(), device needs patch\n", __FUNCTION__) ;
>  		return -EIO ;
>  	}
> @@ -1198,6 +1202,7 @@ static int irda_usb_net_open(struct net_
>  	/* To do *before* submitting Rx urbs and starting net Tx queue
>  	 * Jean II */
>  	self->netopen = 1;
> +	spin_unlock_irqrestore(&self->lock, flags);
>  
>  	/* 
>  	 * Now that everything should be initialized properly,
> 
