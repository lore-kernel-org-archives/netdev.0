From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] sky2: fix hard hang with netconsoling and iface going
	up
Date: Tue, 27 Jan 2009 16:35:04 +0300
Message-ID: <20090127133504.GA10091@x200.localdomain>
References: <20090127120129.GA9696@x200.localdomain> <20090127132718.GA10001@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:63607 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255AbZA0N31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 08:29:27 -0500
Received: by ewy14 with SMTP id 14so1685746ewy.13
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 05:29:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090127132718.GA10001@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 04:27:18PM +0300, Alexey Dobriyan wrote:
> On Tue, Jan 27, 2009 at 03:01:29PM +0300, Alexey Dobriyan wrote:
> > If sky2 interface is netconsoling, then
> > 
> > 	ifconfig down; ifconfig up
> > 
> > leads to hard hang after printing
> > 
> > 	sky2 eth0: enabling interface
> > 
> > SysRq+b reboots the box, nothing else works (or prints something).
> > 
> > This is with 2.6.28.2 and 2.6.29-rc2-5ee810072175042775e39bdd3eaaa68884c27805.
> > Most certainly was there since day one.
> > 
> > Haven't investigated further.
> 
> Well, duh...
> 
> 
> [PATCH] sky2: fix hard hang with netconsoling and iface going up
> 
> Printing anything over netconsole before hw is up and running is,
> of course, not going to work.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  drivers/net/sky2.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -1403,9 +1403,6 @@ static int sky2_up(struct net_device *dev)
>  
>   	}
>  
> -	if (netif_msg_ifup(sky2))
> -		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
> -
>  	netif_carrier_off(dev);
>  
>  	/* must be power of 2 */
> @@ -1484,6 +1481,9 @@ static int sky2_up(struct net_device *dev)
>  	sky2_write32(hw, B0_IMSK, imask);
>  
>  	sky2_set_multicast(dev);
> +
> +	if (netif_msg_ifup(sky2))
> +		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
>  	return 0;

Oh, this means that most printks on error path in ->ndo_open are broken
and every early enough "I'm up!" printk is broken is well. :-(
