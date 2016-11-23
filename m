From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] phy: fix error case of phy_led_triggers_(un)register
Date: Wed, 23 Nov 2016 23:15:25 +0100
Message-ID: <20161123221525.GD12343@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40969D0E@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zach.brown@ni.com, davem@davemloft.net, netdev@vger.kernel.org,
        f.fainelli@gmail.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52816 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752437AbcKWWPc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 17:15:32 -0500
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40969D0E@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 09:39:37PM +0000, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <woojung.huh@microchip.com>
> 
> When phy_init_hw() fails at phy_attach_direct();
> - phy_detach() calls phy_led_triggers_unregister() without 
>   previous call of phy_led_triggers_register().
> - still call phy_led_triggers_register() and cause memory leak.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>  drivers/net/phy/phy_device.c       | 6 +++---
>  drivers/net/phy/phy_led_triggers.c | 3 +++
>  2 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 9e8f048..094a959 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -915,10 +915,10 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  	err = phy_init_hw(phydev);
>  	if (err)
>  		phy_detach(phydev);
> -	else
> +	else {
>  		phy_resume(phydev);
> -
> -	phy_led_triggers_register(phydev);
> +		phy_led_triggers_register(phydev);
> +	}

Hi Woojung

The code layout is rather unusual, putting the success case inside the
else {}. It would be better to do a goto out: on error, and detach the
phy there.

>  
>  	return err;
>  
> diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
> index cda600a..3b0b726 100644
> --- a/drivers/net/phy/phy_led_triggers.c
> +++ b/drivers/net/phy/phy_led_triggers.c
> @@ -128,6 +128,9 @@ void phy_led_triggers_unregister(struct phy_device *phy)
>  {
>  	int i;
>  
> +	if (!phy->phy_num_led_triggers)
> +		return;
> +
>  	for (i = 0; i < phy->phy_num_led_triggers; i++)
>  		phy_led_trigger_unregister(&phy->phy_led_triggers[i]);

And this seems to be the wrong fix. The point of devm_kzalloc() is
that you don't need to free it, it will happen automatically. So why
not just remove the devm_kfree(&phy->mdio.dev, phy->phy_led_triggers).

    Andrew
