From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] via-velocity: earlier name allocation
Date: Wed, 22 Oct 2008 17:04:22 -0700
Message-ID: <20081022170422.7851ea9a@extreme>
References: <alpine.DEB.2.00.0810230114180.17076@ds9.feds.ath.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sven Hartge <sven@svenhartge.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60278 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804AbYJWAEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 20:04:25 -0400
In-Reply-To: <alpine.DEB.2.00.0810230114180.17076@ds9.feds.ath.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Oct 2008 01:24:25 +0200 (CEST)
Sven Hartge <sven@svenhartge.de> wrote:

> Hi.
> 
> This is my first attempt at a kernel patch ever, so please be gentle :)
> (And please CC me, as I am not subscribed to netdev.)
> 
> This patch corrects a cosmetic bug in the via-velocity driver which 
> bothered me for some time.
> 
> The messages printed during device init look like the following:
> 
> [    8.486422] eth%d: set value of parameter Wake On Lan options to 0
>                   ^^!
> [    8.487340] eth0: VIA Networking Velocity Family Gigabit Ethernet Adapter
> 
> Note the unresolved format string.
> 
> I just copied and adapted the name allocation code from register_netdev 
> and call it before the first use of dev->name 
> 
> Even if my attempt is incorrect, it should give you an idea what needs 
> fixing here.
> 
> Signed-off-by: Sven Hartge <sven@svenhartge.de>
> 
> diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
> index 2dced38..15f2c19 100644
> --- a/drivers/net/via-velocity.c
> +++ b/drivers/net/via-velocity.c
> @@ -934,6 +934,16 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
>  	for (i = 0; i < 6; i++)
>  		dev->dev_addr[i] = readb(&regs->PAR[i]);
>  
> +	/*
> +	 *  Do name allocation.
> +	 */
> +
> +	if (strchr(dev->name, '%')) {
> +		ret = dev_alloc_name(dev, dev->name);
> +			if (ret < 0)
> +				dev_err(&pdev->dev, "Name allocation failed.\n");
> +				goto err_disable;
> +	}
>  
>  	velocity_get_options(&vptr->options, velocity_nics, dev->name);
>  

NAK

There is nothing to prevent that device name from being allocated by another device
at that point.  The correct fix is to not use dev->name until after registering
the network device.  Change the order of registration or pass dev_driver_string(&pdev->dev)
instead of dev->name to velocity_get_options
