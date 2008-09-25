From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.27? 10/10] gianfar: free/iounmap memory after
 an error in mii bus initialization
Date: Wed, 24 Sep 2008 20:49:59 -0400
Message-ID: <48DAE037.4040501@garzik.org>
References: <200809222110.m8MLAPWg029903@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com, danielm77@spray.se
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47018 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752258AbYIYAuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 20:50:04 -0400
In-Reply-To: <200809222110.m8MLAPWg029903@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Andy Fleming <afleming@freescale.com>
> 
> Recent changes to MII bus initialization code added exit points which
> didn't free or iounmap the bus before returning.
> 
> Addresses http://bugzilla.kernel.org/show_bug.cgi?id=11372.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> Reported-by: Daniel Marjamki <danielm77@spray.se>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/gianfar_mii.c |   14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
> 
> diff -puN drivers/net/gianfar_mii.c~gianfar-free-iounmap-memory-after-an-error-in-mii-bus-initialization drivers/net/gianfar_mii.c
> --- a/drivers/net/gianfar_mii.c~gianfar-free-iounmap-memory-after-an-error-in-mii-bus-initialization
> +++ a/drivers/net/gianfar_mii.c
> @@ -211,19 +211,21 @@ static int gfar_mdio_probe(struct device
>  	gfar_write(&enet_regs->tbipa, 0);
>  	for (i = PHY_MAX_ADDR; i > 0; i--) {
>  		u32 phy_id;
> -		int r;
>  
> -		r = get_phy_id(new_bus, i, &phy_id);
> -		if (r)
> -			return r;
> +		err = get_phy_id(new_bus, i, &phy_id);
> +		if (err)
> +			goto bus_register_fail;
>  
>  		if (phy_id == 0xffffffff)
>  			break;
>  	}
>  
>  	/* The bus is full.  We don't support using 31 PHYs, sorry */
> -	if (i == 0)
> -		return -EBUSY;
> +	if (i == 0) {
> +		err = -EBUSY;
> +
> +		goto bus_register_fail;
> +	}
>  
>  	gfar_write(&enet_regs->tbipa, i);

applied


