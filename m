From: Zach Brown <zach.brown@ni.com>
Subject: Re: [PATCH v2] net: phy: Fix use after free in phy_detach()
Date: Mon, 28 Nov 2016 18:05:57 -0600
Message-ID: <20161129000556.GA11698@zach-desktop>
References: <1480342711-26407-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Josh Cartwright <josh.cartwright@ni.com>,
        Nathan Sullivan <nathan.sullivan@ni.com>,
        Woojung Huh <woojung.huh@microchip.com>,
        <netdev@vger.kernel.org>, <linux-renesas-soc@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1480342711-26407-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 03:18:31PM +0100, Geert Uytterhoeven wrote:
> If device_release_driver(&phydev->mdio.dev) is called, it releases all
> resources belonging to the PHY device. Hence the subsequent call to
> phy_led_triggers_unregister() will access already freed memory when
> unregistering the LEDs.
> 
> Move the call to phy_led_triggers_unregister() before the possible call
> to device_release_driver() to fix this.
> 
> Fixes: 2e0bc452f4721520 ("net: phy: leds: add support for led triggers on phy link state change")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
> This is v2 of "[RFC] net: phy: Fix double free in phy_detach()".
> 
> v2:
>   - Dropped RFC,
>   - Reworded, as commit a7dac9f9c1695d74 ("phy: fix error case of
>     phy_led_triggers_(un)register") fixed the double free, and thus the
>     warning I was seeing during "poweroff" on sh73a0/kzm9g,
>   - Verified use after free using CONFIG_DEBUG_DEVRES, log_devres = 1,
>     and additional debug code printing the address of
>     phy->phy_led_triggers. Adding poisoning of freed memory to
>     devres_log() will cause a crash.
> ---
>  drivers/net/phy/phy_device.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index ba86c191a13ea81c..a1d6e13b1b4113a4 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -981,6 +981,8 @@ void phy_detach(struct phy_device *phydev)
>  	phydev->attached_dev = NULL;
>  	phy_suspend(phydev);
>  
> +	phy_led_triggers_unregister(phydev);
> +
>  	/* If the device had no specific driver before (i.e. - it
>  	 * was using the generic driver), we unbind the device
>  	 * from the generic driver so that there's a chance a
> @@ -994,8 +996,6 @@ void phy_detach(struct phy_device *phydev)
>  		}
>  	}
>  
> -	phy_led_triggers_unregister(phydev);
> -
>  	/*
>  	 * The phydev might go away on the put_device() below, so avoid
>  	 * a use-after-free bug by reading the underlying bus first.
> -- 
> 1.9.1
> 

I was able to recreate the issue and confirmed this patch fixes it.
Tested-by: Zach Brown <zach.brown@ni.com>

--Zach
